import Testing
import KeyboardSwitcherCore

struct AppEntryPolicyTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
    private let whatsAppContext = SwitchContext(bundleIdentifier: "net.whatsapp.WhatsApp")
    private let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")

    private func rules(remembersManualSwitches: Bool) -> RulesFile {
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        let preferences = Preferences(remembersManualSwitches: remembersManualSwitches)
        return RulesFile(appRules: [whatsAppRule], preferences: preferences)
    }

    @Test func aNewAppJoinsTheListWithTheKeyboardItWasOpenedWith() {
        var rules = rules(remembersManualSwitches: true)

        AppEntryPolicy.record(keyboardID: canadian, appName: "Notes", in: notesContext, rules: &rules)

        let notesRule = AppRule(bundleIdentifier: "com.apple.Notes", appName: "Notes", keyboardID: canadian)
        #expect(rules.appRule(for: notesContext.bundleIdentifier) == notesRule)
    }

    @Test func anAppInTheListKeepsItsKeyboard() {
        var rules = rules(remembersManualSwitches: true)
        let rulesBefore = rules

        AppEntryPolicy.record(keyboardID: canadian, appName: "WhatsApp", in: whatsAppContext, rules: &rules)

        #expect(rules == rulesBefore)
    }

    @Test func nothingJoinsTheListWhenRememberingIsOff() {
        var rules = rules(remembersManualSwitches: false)
        let rulesBefore = rules

        AppEntryPolicy.record(keyboardID: canadian, appName: "Notes", in: notesContext, rules: &rules)

        #expect(rules == rulesBefore)
    }
}
