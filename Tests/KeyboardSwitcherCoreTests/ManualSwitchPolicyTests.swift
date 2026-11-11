import Testing
import KeyboardSwitcherCore

struct ManualSwitchPolicyTests {
    private let canadian = StarterRules.canadianKeyboardID
    private let canadianCSA = StarterRules.canadianCSAKeyboardID
    private let whatsAppContext = SwitchContext(bundleIdentifier: "net.whatsapp.WhatsApp")
    private let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")

    private func rules(manualSwitch: ManualSwitchBehavior, otherApps: OtherAppsBehavior = .lastUsed) -> RulesFile {
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        let claudeRule = WebsiteRule(website: "claude.ai", keyboardID: canadian)
        let preferences = Preferences(otherApps: otherApps, manualSwitch: manualSwitch)
        return RulesFile(appRules: [whatsAppRule], websiteRules: [claudeRule], preferences: preferences)
    }

    @Test func backToTheRuleLeavesTheRuleAlone() {
        var rules = rules(manualSwitch: .backToRule)
        let rulesBefore = rules

        ManualSwitchPolicy.record(keyboardID: canadian, in: whatsAppContext, rules: &rules)

        #expect(rules == rulesBefore)
    }

    @Test func makeItTheNewRuleUpdatesTheAppRule() {
        var rules = rules(manualSwitch: .becomesRule)

        ManualSwitchPolicy.record(keyboardID: canadian, in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.keyboardID == canadian)
    }

    @Test func makeItTheNewRuleUpdatesTheWebsiteRuleBeforeTheBrowserRule() {
        var rules = rules(manualSwitch: .becomesRule)
        rules.setAppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", keyboardID: canadian)
        let claudeInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "claude.ai")

        ManualSwitchPolicy.record(keyboardID: canadianCSA, in: claudeInChrome, rules: &rules)

        let claudeRule = rules.websiteRules.first { websiteRule in websiteRule.website == "claude.ai" }
        #expect(claudeRule?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)
    }

    @Test(arguments: [ManualSwitchBehavior.backToRule, .becomesRule])
    func appWithoutARuleRemembersThePick(manualSwitch: ManualSwitchBehavior) {
        var rules = rules(manualSwitch: manualSwitch)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp[notesContext.bundleIdentifier] == canadianCSA)
    }

    @Test func leaveAsIsRemembersNothing() {
        var rules = rules(manualSwitch: .backToRule, otherApps: .leaveAsIs)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp.isEmpty)
    }
}
