import Testing
import KeyboardSwitcherCore

struct ManualSwitchPolicyTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
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

        ManualSwitchPolicy.record(keyboardID: canadian, appName: "WhatsApp", in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.keyboardID == canadian)
    }

    @Test func anAppInTheListKeepsTheNameItHasThere() {
        var rules = rules(remembersManualSwitches: true)

        ManualSwitchPolicy.record(keyboardID: canadian, appName: "WhatsApp Beta", in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.appName == "WhatsApp")
    }

    @Test func rememberingUpdatesTheWebsiteRuleBeforeTheBrowserRule() {
        var rules = rules(remembersManualSwitches: true)
        rules.setAppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", keyboardID: canadian)
        let claudeInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "claude.ai")

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Google Chrome", in: claudeInChrome, rules: &rules)

        let claudeRule = rules.websiteRules.first { websiteRule in websiteRule.website == "claude.ai" }
        #expect(claudeRule?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)
    }

    @Test func aSwitchByHandAddsAnAppOutsideTheListToTheList() {
        var rules = rules(remembersManualSwitches: true)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Notes", in: notesContext, rules: &rules)

        let notesRule = AppRule(bundleIdentifier: "com.apple.Notes", appName: "Notes", keyboardID: canadianCSA)
        #expect(rules.appRule(for: notesContext.bundleIdentifier) == notesRule)
    }

    @Test(arguments: ["net.whatsapp.WhatsApp", "com.apple.Notes"])
    func notRememberingChangesNothing(bundleIdentifier: String) {
        var rules = rules(remembersManualSwitches: false)
        let rulesBefore = rules
        let context = SwitchContext(bundleIdentifier: bundleIdentifier)

        ManualSwitchPolicy.record(keyboardID: canadian, appName: "Some App", in: context, rules: &rules)

        #expect(rules == rulesBefore)
    }
}
