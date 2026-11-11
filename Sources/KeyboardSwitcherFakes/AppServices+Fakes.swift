import KeyboardSwitcherCore
import KeyboardSwitcherKit

extension AppServices {
    public static let fakeOwnBundleIdentifier = "com.anthonysarkis.keyboard-switcher"

    public static func fake(
        keyboardSystem: FakeKeyboardSystem,
        browsers: FakeBrowsers,
        bubble: RecordingBubble,
        rulesStore: RulesStore,
        loginItem: FakeLoginItem = FakeLoginItem(isEnabled: false),
        macKeyboardIcon: FakeMacKeyboardIcon = FakeMacKeyboardIcon(isShown: true),
        settleDuration: Duration = .milliseconds(5)
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
            ownBundleIdentifier: fakeOwnBundleIdentifier,
            settleDuration: settleDuration,
            browserCheckInterval: 0.5
        )
    }
}
