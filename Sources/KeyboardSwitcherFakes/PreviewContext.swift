import KeyboardSwitcherCore
import KeyboardSwitcherKit

public enum PreviewContext {
    private static let ghostty = AppIdentity(bundleIdentifier: "com.mitchellh.ghostty", name: "Ghostty")

    public static func make() -> AppContext {
        let rulesStore = TemporaryRulesStore.make()
        let rules = sampleRules()
        try? rulesStore.save(rules)

        let keyboardSystem = FakeKeyboardSystem(currentID: SampleKeyboards.canadian.id)
        let browsers = FakeBrowsers(permissions: [
            "com.google.Chrome": .allowed,
            "com.brave.Browser": .asksFirstTime,
            "com.apple.Safari": .notOpen,
        ])
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
        context.coordinator.start(frontApp: ghostty)
        context.tabTracker.refreshPermissions()
        return context
    }

    private static func sampleRules() -> RulesFile {
        var rules = StarterRules.make(availableKeyboardIDs: SampleKeyboards.bothIDs)
        rules.setWebsiteRule(website: "claude.ai", keyboardID: SampleKeyboards.canadian.id)
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: SampleKeyboards.canadianCSA.id)
        return rules
    }
}
