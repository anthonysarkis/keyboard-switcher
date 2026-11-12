import Testing
import KeyboardSwitcherCore

struct RememberedAppsTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
    private let installedAppNames = ["com.apple.Safari": "Safari", "com.apple.Notes": "Notes"]

    private func rules(appsRemembering: RememberingMode) -> RulesFile {
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        let preferences = Preferences(appsRemembering: appsRemembering)
        var rules = RulesFile(appRules: [whatsAppRule], preferences: preferences)
        rules.lastUsedByApp = [
            "com.apple.Safari": canadianCSA,
            "com.apple.Notes": canadian,
            "net.whatsapp.WhatsApp": canadian,
            "com.example.Uninstalled": canadian,
        ]
        return rules
    }

    @Test func rememberedAppsJoinTheListByNameAndTheMemoryEmpties() {
        var rules = rules(appsRemembering: .everyOne)

        rules.moveRememberedAppsIntoTheList { bundleIdentifier in installedAppNames[bundleIdentifier] }

        #expect(rules.appRules.map(\.appName) == ["WhatsApp", "Notes", "Safari"])
        #expect(rules.appRule(for: "com.apple.Safari")?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "net.whatsapp.WhatsApp")?.keyboardID == canadianCSA)
        #expect(rules.lastUsedByApp.isEmpty)
    }

    @Test func nothingJoinsTheListWhenRememberingIsOff() {
        var rules = rules(appsRemembering: .addedByYou)

        rules.moveRememberedAppsIntoTheList { bundleIdentifier in installedAppNames[bundleIdentifier] }

        #expect(rules.appRules.map(\.appName) == ["WhatsApp"])
        #expect(rules.lastUsedByApp.isEmpty)
    }
}
