import Testing
import KeyboardSwitcherCore

struct StarterRulesTests {
    @Test func startsWithWhatsAppOnCSAAndTheCodingAppsOnCanadian() {
        let rules = StarterRules.make(availableKeyboardIDs: [StarterRules.canadianKeyboardID, StarterRules.canadianCSAKeyboardID])

        #expect(rules.appRule(for: "net.whatsapp.WhatsApp")?.keyboardID == StarterRules.canadianCSAKeyboardID)
        #expect(rules.appRule(for: "com.microsoft.VSCode")?.keyboardID == StarterRules.canadianKeyboardID)
        #expect(rules.appRule(for: "com.mitchellh.ghostty")?.keyboardID == StarterRules.canadianKeyboardID)
        #expect(rules.websiteRules.isEmpty)
    }

    @Test func skipsRulesForKeyboardsThatAreNotEnabled() {
        let rules = StarterRules.make(availableKeyboardIDs: [StarterRules.canadianKeyboardID])

        #expect(rules.appRules.map(\.bundleIdentifier) == ["com.microsoft.VSCode", "com.mitchellh.ghostty"])
    }
}
