import KeyboardSwitcherCore
import KeyboardSwitcherKit

public enum PreviewContext {
    private static let sampleBrowserPermissions: [String: BrowserPermission] = [
        "com.google.Chrome": .allowed,
        "com.brave.Browser": .asksFirstTime,
        "com.apple.Safari": .notOpen,
    ]

    public static func make() -> AppContext {
        let rules = sampleRules()
        return make(keyboards: SampleKeyboards.both, rules: rules, browserPermissions: sampleBrowserPermissions)
    }

    public static func make(keyboards: [Keyboard], rules: RulesFile, browserPermissions: [String: BrowserPermission]) -> AppContext {
        let rulesStore = TemporaryRulesStore.make()
        try? rulesStore.save(rules)

        let firstKeyboardID = keyboards.first?.id
        let keyboardSystem = FakeKeyboardSystem(keyboards: keyboards, currentID: firstKeyboardID)
        let browsers = FakeBrowsers(permissions: browserPermissions)
        let bubble = RecordingBubble()
        let loginItem = FakeLoginItem(isEnabled: true)
        let services = AppServices.fake(
            keyboardSystem: keyboardSystem,
            browsers: browsers,
            bubble: bubble,
            rulesStore: rulesStore,
            loginItem: loginItem
        )

        let context = AppContext(services: services)
        context.coordinator.start(frontApp: nil)
        context.tabTracker.refreshPermissions()
        return context
    }

    private static func sampleRules() -> RulesFile {
        var rules = SampleRules.make()
        rules.setWebsiteRule(website: "claude.ai", keyboardID: SampleKeyboards.canadian.id)
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: SampleKeyboards.canadianCSA.id)
        return rules
    }
}
