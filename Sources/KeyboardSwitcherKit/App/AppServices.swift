import Foundation
import KeyboardSwitcherCore

public struct AppServices {
    private static let macOSSettleDuration: Duration = .milliseconds(600)
    private static let browserTabCheckInterval: TimeInterval = 0.5
    private static let firstTabReadPatience: Duration = .milliseconds(200)

    public var keyboardSystem: any KeyboardSystem
    public var badgeImageMaker: any BadgeImageMaking
    public var tabReader: any BrowserTabReading
    public var permissionChecker: any BrowserPermissionChecking
    public var bubble: any BubblePresenting
    public var loginItem: any LoginItemControlling
    public var macKeyboardIcon: any MacKeyboardIconControlling
    public var rulesStore: RulesStore
    public var installedAppName: (String) -> String?
    public var ownBundleIdentifier: String
    public var settleDuration: Duration
    public var browserCheckInterval: TimeInterval
    public var firstTabReadPatience: Duration

    public init(
        keyboardSystem: any KeyboardSystem,
        badgeImageMaker: any BadgeImageMaking,
        tabReader: any BrowserTabReading,
        permissionChecker: any BrowserPermissionChecking,
        bubble: any BubblePresenting,
        loginItem: any LoginItemControlling,
        macKeyboardIcon: any MacKeyboardIconControlling,
        rulesStore: RulesStore,
        installedAppName: @escaping (String) -> String?,
        ownBundleIdentifier: String,
        settleDuration: Duration,
        browserCheckInterval: TimeInterval,
        firstTabReadPatience: Duration
    ) {
        self.keyboardSystem = keyboardSystem
        self.badgeImageMaker = badgeImageMaker
        self.tabReader = tabReader
        self.permissionChecker = permissionChecker
        self.bubble = bubble
        self.loginItem = loginItem
        self.macKeyboardIcon = macKeyboardIcon
        self.rulesStore = rulesStore
        self.installedAppName = installedAppName
        self.ownBundleIdentifier = ownBundleIdentifier
        self.settleDuration = settleDuration
        self.browserCheckInterval = browserCheckInterval
        self.firstTabReadPatience = firstTabReadPatience
    }

    public static func live(bundleIdentifier: String) -> AppServices {
        let rulesFileURL = RulesStore.defaultFileURL(bundleIdentifier: bundleIdentifier)
        let rulesStore = RulesStore(fileURL: rulesFileURL)
        let keyboardSystem = TextInputSources()
        let badgeImageMaker = liveBadgeImageMaker()
        let tabReader = AppleEventTabReader()
        let permissionChecker = AutomationPermissionChecker()
        let bubble = SwitchBubblePanel()
        let loginItem = MainAppLoginItem()
        let macKeyboardIcon = TextInputMenuIcon()
        return AppServices(
            keyboardSystem: keyboardSystem,
            badgeImageMaker: badgeImageMaker,
            tabReader: tabReader,
            permissionChecker: permissionChecker,
            bubble: bubble,
            loginItem: loginItem,
            macKeyboardIcon: macKeyboardIcon,
            rulesStore: rulesStore,
            installedAppName: { bundleIdentifier in InstalledApps.name(for: bundleIdentifier) },
            ownBundleIdentifier: bundleIdentifier,
            settleDuration: macOSSettleDuration,
            browserCheckInterval: browserTabCheckInterval,
            firstTabReadPatience: firstTabReadPatience
        )
    }

    private static func liveBadgeImageMaker() -> any BadgeImageMaking {
        let macBadgeImages = MacBadgeImages()
        let drawnBadgeImages = DrawnBadgeImages()
        if macBadgeImages == nil {
            Log.badges.error("macOS's own badge drawer is missing, so the app draws the badges itself")
        } else {
            Log.badges.notice("Badges come from macOS's own drawer")
        }
        return BadgeImagesWithFallback(preferred: macBadgeImages, fallback: drawnBadgeImages)
    }
}
