import KeyboardSwitcherKit

public final class FakeBrowsers: BrowserTabReading, BrowserPermissionChecking {
    public var tabAddresses: [String: String]
    public var permissions: [String: BrowserPermission]
    public var answerToPermissionQuestion = BrowserPermission.allowed
    public private(set) var permissionQuestionsAsked: [String] = []
    public private(set) var tabReadCount = 0
    public var holdsAnswers = false
    private var heldAnswers: [CheckedContinuation<Void, Never>] = []

    public init(tabAddresses: [String: String] = [:], permissions: [String: BrowserPermission] = [:]) {
        self.tabAddresses = tabAddresses
        self.permissions = permissions
    }

    public func releaseAnswers() {
        holdsAnswers = false
        let waitingAnswers = heldAnswers
        heldAnswers = []
        for waitingAnswer in waitingAnswers {
            waitingAnswer.resume()
        }
    }

    public func currentTabAddress(in browser: SupportedBrowser) async -> TabAddressResult {
        tabReadCount += 1
        if holdsAnswers {
            await withCheckedContinuation { waitingAnswer in heldAnswers.append(waitingAnswer) }
        }
        if permissions[browser.bundleIdentifier] == .denied {
            return .denied
        }
        guard let tabAddress = tabAddresses[browser.bundleIdentifier] else { return .noWindow }
        return .address(tabAddress)
    }

    public func permission(for browser: SupportedBrowser) -> BrowserPermission {
        permissions[browser.bundleIdentifier] ?? .asksFirstTime
    }

    public func requestPermission(for browser: SupportedBrowser) async -> BrowserPermission {
        permissionQuestionsAsked.append(browser.bundleIdentifier)
        permissions[browser.bundleIdentifier] = answerToPermissionQuestion
        return answerToPermissionQuestion
    }
}
