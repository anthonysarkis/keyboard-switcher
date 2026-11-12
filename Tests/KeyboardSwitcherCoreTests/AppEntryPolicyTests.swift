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

    @Test func aNewAppKeepsTheKeyboardItWasOpenedWith() {
        var rules = rules(remembersManualSwitches: true)

        AppEntryPolicy.record(keyboardID: canadian, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp[notesContext.bundleIdentifier] == canadian)
    }

    @Test func anAppThatAlreadyRemembersAKeyboardKeepsIt() {
        var rules = rules(remembersManualSwitches: true)
        rules.lastUsedByApp[notesContext.bundleIdentifier] = canadianCSA

        AppEntryPolicy.record(keyboardID: canadian, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp[notesContext.bundleIdentifier] == canadianCSA)
    }

    @Test func anAppInTheListKeepsItsRule() {
        var rules = rules(remembersManualSwitches: true)

        AppEntryPolicy.record(keyboardID: canadian, in: whatsAppContext, rules: &rules)

        #expect(rules.lastUsedByApp.isEmpty)
        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.keyboardID == canadianCSA)
    }

    @Test func nothingIsRememberedWhenRememberingIsOff() {
        var rules = rules(remembersManualSwitches: false)

        AppEntryPolicy.record(keyboardID: canadian, in: notesContext, rules: &rules)

        #expect(rules.lastUsedByApp.isEmpty)
    }
}
