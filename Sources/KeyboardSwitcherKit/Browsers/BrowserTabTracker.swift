import Foundation
import Observation
import KeyboardSwitcherCore

@Observable
public final class BrowserTabTracker {
    public private(set) var currentWebsite: String?
    public private(set) var permissions: [String: BrowserPermission] = [:]
    @ObservationIgnored var onWebsiteChange: (@MainActor () -> Void)?
    @ObservationIgnored private(set) var permissionQuestions: [String: Task<Void, Never>] = [:]
    @ObservationIgnored private(set) var tabRead: Task<Void, Never>?

    @ObservationIgnored private var trackedBrowser: SupportedBrowser?
    @ObservationIgnored private var needsTabAddresses = false
    @ObservationIgnored private var checkTimer: Timer?
    @ObservationIgnored private var trackingCount = 0
    @ObservationIgnored private var readyActions: [@MainActor () -> Void] = []
    @ObservationIgnored private(set) var patienceCheck: Task<Void, Never>?
    @ObservationIgnored private var isFailingToRead = false

    private let tabReader: any BrowserTabReading
    private let permissionChecker: any BrowserPermissionChecking
    private let checkInterval: TimeInterval
    private let firstReadPatience: Duration

    public init(
        tabReader: any BrowserTabReading,
        permissionChecker: any BrowserPermissionChecking,
        checkInterval: TimeInterval,
        firstReadPatience: Duration
    ) {
        self.tabReader = tabReader
        self.permissionChecker = permissionChecker
        self.checkInterval = checkInterval
        self.firstReadPatience = firstReadPatience
    }

    @discardableResult
    public func readNow() -> Task<Void, Never>? {
        guard let trackedBrowser else { return nil }
        let permission = checkPermission(for: trackedBrowser)
        guard permission == .allowed else { return nil }
        return read(in: trackedBrowser)
    }

    public func refreshPermissions() {
        for browser in SupportedBrowser.all {
            checkPermission(for: browser)
        }
    }

    @discardableResult
    public func requestPermission(for browser: SupportedBrowser) -> Task<Void, Never>? {
        guard permissionQuestions[browser.bundleIdentifier] == nil else { return nil }
        Log.browsers.notice("Asking to read tabs in \(browser.bundleIdentifier, privacy: .public)")

        let question = Task {
            let permission = await permissionChecker.requestPermission(for: browser)
            permissionQuestions[browser.bundleIdentifier] = nil
            receiveAnswer(permission, for: browser)
        }
        permissionQuestions[browser.bundleIdentifier] = question
        return question
    }

    func track(_ browser: SupportedBrowser?, needsTabAddresses: Bool, mayAsk: Bool, whenReady: @escaping @MainActor () -> Void) {
        if browser != trackedBrowser {
            readyActions = []
        }
        stopChecking()
        stopPatienceCheck()
        trackingCount += 1
        tabRead = nil
        trackedBrowser = browser
        self.needsTabAddresses = needsTabAddresses
        setCurrentWebsite(nil)
        readyActions.append(whenReady)
        guard let browser else {
            becomeReady()
            return
        }

        let permission = checkPermission(for: browser)
        switch permission {
        case .allowed where needsTabAddresses:
            startPatienceCheck()
            read(in: browser)
            startChecking(browser)
        case .asksFirstTime where needsTabAddresses && mayAsk:
            requestPermission(for: browser)
            becomeReady()
        default:
            becomeReady()
        }
    }

    func updateNeedsTabAddresses(_ needsTabAddresses: Bool, whenReady: @escaping @MainActor () -> Void) {
        track(trackedBrowser, needsTabAddresses: needsTabAddresses, mayAsk: false, whenReady: whenReady)
    }

    private func receiveAnswer(_ permission: BrowserPermission, for browser: SupportedBrowser) {
        setPermission(permission, for: browser)
        let answer = String(describing: permission)
        Log.browsers.notice("Tabs in \(browser.bundleIdentifier, privacy: .public): \(answer, privacy: .public)")
        guard trackedBrowser == browser else { return }

        track(browser, needsTabAddresses: needsTabAddresses, mayAsk: false) { [weak self] in
            self?.onWebsiteChange?()
        }
    }

    @discardableResult
    private func read(in browser: SupportedBrowser) -> Task<Void, Never> {
        if let tabRead {
            return tabRead
        }
        let trackingAtStart = trackingCount
        let newRead = Task { [weak self, tabReader] in
            let result = await tabReader.currentTabAddress(in: browser)
            self?.receive(result, from: browser, trackingAtStart: trackingAtStart)
        }
        tabRead = newRead
        return newRead
    }

    private func receive(_ result: TabAddressResult, from browser: SupportedBrowser, trackingAtStart: Int) {
        guard trackingCount == trackingAtStart else { return }
        tabRead = nil
        let previousWebsite = currentWebsite
        let isFirstReadHere = !readyActions.isEmpty
        apply(result, from: browser)
        let websiteChanged = currentWebsite != previousWebsite
        if isFirstReadHere || websiteChanged {
            logWebsite(in: browser)
        }
        if isFirstReadHere {
            becomeReady()
        } else if websiteChanged {
            onWebsiteChange?()
        }
    }

    private func logWebsite(in browser: SupportedBrowser) {
        if let currentWebsite {
            Log.browsers.notice("Tab in \(browser.bundleIdentifier, privacy: .public): \(currentWebsite, privacy: .private)")
        } else {
            Log.browsers.notice("Tab in \(browser.bundleIdentifier, privacy: .public): no website")
        }
    }

    private func apply(_ result: TabAddressResult, from browser: SupportedBrowser) {
        switch result {
        case .address(let address):
            let website = WebsiteAddress.website(fromTabAddress: address)
            setCurrentWebsite(website)
            setPermission(.allowed, for: browser)
            isFailingToRead = false
        case .noWindow:
            setCurrentWebsite(nil)
            isFailingToRead = false
        case .denied:
            setCurrentWebsite(nil)
            setPermission(.denied, for: browser)
            stopChecking()
            Log.browsers.notice("Not allowed to read tabs in \(browser.bundleIdentifier, privacy: .public)")
        case .failed(let errorCode):
            if !isFailingToRead {
                Log.browsers.error("Could not read the tab in \(browser.bundleIdentifier, privacy: .public): error \(errorCode, privacy: .public)")
            }
            isFailingToRead = true
        }
    }

    private func becomeReady() {
        stopPatienceCheck()
        let actions = readyActions
        readyActions = []
        for action in actions {
            action()
        }
    }

    private func startPatienceCheck() {
        let trackingAtStart = trackingCount
        patienceCheck = Task { [weak self, firstReadPatience] in
            try? await Task.sleep(for: firstReadPatience)
            guard let self, !Task.isCancelled, self.trackingCount == trackingAtStart else { return }
            self.becomeReady()
        }
    }

    private func stopPatienceCheck() {
        patienceCheck?.cancel()
        patienceCheck = nil
    }

    private func checkTab() {
        guard let trackedBrowser, tabRead == nil else { return }
        read(in: trackedBrowser)
    }

    @discardableResult
    private func checkPermission(for browser: SupportedBrowser) -> BrowserPermission {
        let permission = permissionChecker.permission(for: browser)
        setPermission(permission, for: browser)
        return permission
    }

    private func startChecking(_ browser: SupportedBrowser) {
        let timer = Timer(timeInterval: checkInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.checkTab() }
        }
        timer.tolerance = checkInterval / 5
        RunLoop.main.add(timer, forMode: .common)
        checkTimer = timer
    }

    private func stopChecking() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    private func setCurrentWebsite(_ website: String?) {
        guard currentWebsite != website else { return }
        currentWebsite = website
    }

    private func setPermission(_ permission: BrowserPermission, for browser: SupportedBrowser) {
        guard permissions[browser.bundleIdentifier] != permission else { return }
        permissions[browser.bundleIdentifier] = permission
    }
}
