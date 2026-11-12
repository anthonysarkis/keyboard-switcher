import Testing
import KeyboardSwitcherCore

struct ManualSwitchPolicyTests {
    private let canadian = StarterRules.canadianKeyboardID
    private let canadianCSA = StarterRules.canadianCSAKeyboardID
    private let whatsAppContext = SwitchContext(bundleIdentifier: "net.whatsapp.WhatsApp")
    private let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")

    private func rules(remembersManualSwitches: Bool) -> RulesFile {
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        let claudeRule = WebsiteRule(website: "claude.ai", keyboardID: canadian)
        let preferences = Preferences(remembersManualSwitches: remembersManualSwitches)
        return RulesFile(appRules: [whatsAppRule], websiteRules: [claudeRule], preferences: preferences)
    }

    @Test func rememberingUpdatesTheAppRule() {
        var rules = rules(remembersManualSwitches: true)

        ManualSwitchPolicy.record(keyboardID: canadian, in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.keyboardID == canadian)
    }

    @Test func rememberingUpdatesTheWebsiteRuleBeforeTheBrowserRule() {
        var rules = rules(remembersManualSwitches: true)
        rules.setAppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", keyboardID: canadian)
        let claudeInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "claude.ai")

        ManualSwitchPolicy.record(keyboardID: canadianCSA, in: claudeInChrome, rules: &rules)

        let claudeRule = rules.websiteRules.first { websiteRule in websiteRule.website == "claude.ai" }
        #expect(claudeRule?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)
    }

    @Test func rememberingKeepsThePickForAnAppWithoutARule() {
        var rules = rules(remembersManualSwitches: true)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp[notesContext.bundleIdentifier] == canadianCSA)
        #expect(rules.appRule(for: notesContext.bundleIdentifier) == nil)
    }

    @Test(arguments: ["net.whatsapp.WhatsApp", "com.apple.Notes"])
    func notRememberingChangesNothing(bundleIdentifier: String) {
        var rules = rules(remembersManualSwitches: false)
        let rulesBefore = rules
        let context = SwitchContext(bundleIdentifier: bundleIdentifier)

        ManualSwitchPolicy.record(keyboardID: canadian, in: context, rules: &rules)

        #expect(rules == rulesBefore)
    }
}
