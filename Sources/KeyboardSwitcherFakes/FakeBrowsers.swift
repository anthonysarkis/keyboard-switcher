import KeyboardSwitcherKit

public final class FakeBrowsers: BrowserTabReading, BrowserPermissionChecking {
    public var tabAddresses: [String: String]
    public var permissions: [String: BrowserPermission]
    public var answerToPermissionQuestion = BrowserPermission.allowed
    public private(set) var permissionQuestionsAsked: [String] = []
    public private(set) var tabReadCount = 0

    public init(tabAddresses: [String: String] = [:], permissions: [String: BrowserPermission] = [:]) {
        self.tabAddresses = tabAddresses
        self.permissions = permissions
    }

    public func currentTabAddress(in browser: SupportedBrowser) -> TabAddressResult {
        tabReadCount += 1
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
