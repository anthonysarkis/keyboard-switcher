import Foundation
import Observation
import KeyboardSwitcherCore

@Observable
public final class BrowserTabTracker {
    public private(set) var currentWebsite: String?
    public private(set) var permissions: [String: BrowserPermission] = [:]
    @ObservationIgnored var onWebsiteChange: (@MainActor () -> Void)?
    @ObservationIgnored private(set) var permissionQuestions: [String: Task<Void, Never>] = [:]

    @ObservationIgnored private var trackedBrowser: SupportedBrowser?
    @ObservationIgnored private var needsTabAddresses = false
    @ObservationIgnored private var checkTimer: Timer?

    private let tabReader: any BrowserTabReading
    private let permissionChecker: any BrowserPermissionChecking
    private let checkInterval: TimeInterval

    public init(
        tabReader: any BrowserTabReading,
        permissionChecker: any BrowserPermissionChecking,
        checkInterval: TimeInterval
    ) {
        self.tabReader = tabReader
        self.permissionChecker = permissionChecker
        self.checkInterval = checkInterval
    }

    public func readNow() {
        guard let trackedBrowser else { return }
        let permission = checkPermission(for: trackedBrowser)
        if permission == .allowed {
            readTab(in: trackedBrowser)
        }
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

    func track(_ browser: SupportedBrowser?, needsTabAddresses: Bool, mayAsk: Bool) {
        stopChecking()
        trackedBrowser = browser
        self.needsTabAddresses = needsTabAddresses
        setCurrentWebsite(nil)
        guard let browser else { return }

        let permission = checkPermission(for: browser)
        switch permission {
        case .allowed where needsTabAddresses:
            readTab(in: browser)
            startChecking(browser)
        case .asksFirstTime where needsTabAddresses && mayAsk:
            requestPermission(for: browser)
        default:
            break
        }
    }

    func updateNeedsTabAddresses(_ needsTabAddresses: Bool) {
        track(trackedBrowser, needsTabAddresses: needsTabAddresses, mayAsk: false)
    }

    private func receiveAnswer(_ permission: BrowserPermission, for browser: SupportedBrowser) {
        setPermission(permission, for: browser)
        let answer = String(describing: permission)
        Log.browsers.notice("Tabs in \(browser.bundleIdentifier, privacy: .public): \(answer, privacy: .public)")
        guard trackedBrowser == browser else { return }

        track(browser, needsTabAddresses: needsTabAddresses, mayAsk: false)
        onWebsiteChange?()
    }

    private func checkTab() {
        guard let trackedBrowser else { return }
        let previousWebsite = currentWebsite
        readTab(in: trackedBrowser)
        if currentWebsite != previousWebsite {
            onWebsiteChange?()
        }
    }

    private func readTab(in browser: SupportedBrowser) {
        let tabAddressResult = tabReader.currentTabAddress(in: browser)
        switch tabAddressResult {
        case .address(let address):
            let website = WebsiteAddress.website(fromTabAddress: address)
            setCurrentWebsite(website)
            setPermission(.allowed, for: browser)
        case .noWindow:
            setCurrentWebsite(nil)
        case .denied:
            setCurrentWebsite(nil)
            setPermission(.denied, for: browser)
            stopChecking()
            Log.browsers.notice("Not allowed to read tabs in \(browser.bundleIdentifier, privacy: .public)")
        case .failed:
            break
        }
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
