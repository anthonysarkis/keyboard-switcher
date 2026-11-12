import KeyboardSwitcherCore
import KeyboardSwitcherKit

extension AppServices {
    public static let fakeOwnBundleIdentifier = "com.anthonysarkis.keyboard-switcher"
    public static let fakeInstalledAppNames = ["com.apple.Notes": "Notes", "com.apple.Safari": "Safari", "com.apple.TextEdit": "TextEdit"]

    public static func fake(
        keyboardSystem: FakeKeyboardSystem,
        browsers: FakeBrowsers,
        bubble: RecordingBubble,
        rulesStore: RulesStore,
        loginItem: FakeLoginItem = FakeLoginItem(isEnabled: false),
        macKeyboardIcon: FakeMacKeyboardIcon = FakeMacKeyboardIcon(isShown: true),
        settleDuration: Duration = .milliseconds(5),
        firstTabReadPatience: Duration = .milliseconds(50)
    ) -> AppServices {
        let badgeImageMaker = DrawnBadgeImages()
        return AppServices(
            keyboardSystem: keyboardSystem,
            badgeImageMaker: badgeImageMaker,
            tabReader: browsers,
            permissionChecker: browsers,
            bubble: bubble,
            loginItem: loginItem,
            macKeyboardIcon: macKeyboardIcon,
            rulesStore: rulesStore,
            installedAppName: { bundleIdentifier in fakeInstalledAppNames[bundleIdentifier] },
            ownBundleIdentifier: fakeOwnBundleIdentifier,
            settleDuration: settleDuration,
            browserCheckInterval: 0.5,
            firstTabReadPatience: firstTabReadPatience
        )
    }
}
