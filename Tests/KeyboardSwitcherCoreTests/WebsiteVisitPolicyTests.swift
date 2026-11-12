import Testing
import KeyboardSwitcherCore

struct WebsiteVisitPolicyTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
    private let githubInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "github.com")
    private let claudeInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "claude.ai")

    private func rules(websites: RememberingMode) -> RulesFile {
        let claudeRule = WebsiteRule(website: "claude.ai", keyboardID: canadianCSA)
        let preferences = Preferences(websitesRemembering: websites)
        return RulesFile(websiteRules: [claudeRule], preferences: preferences)
    }

    @Test func everySiteYouVisitJoinsWithTheKeyboardItHad() {
        var rules = rules(websites: .everyOne)

        WebsiteVisitPolicy.record(keyboardID: canadian, in: githubInChrome, rules: &rules)

        let githubRule = rules.websiteRules.first { websiteRule in websiteRule.website == "github.com" }
        #expect(githubRule?.keyboardID == canadian)
    }

    @Test func aListedSiteKeepsItsKeyboard() {
        var rules = rules(websites: .everyOne)
        let rulesBefore = rules

        WebsiteVisitPolicy.record(keyboardID: canadian, in: claudeInChrome, rules: &rules)

        #expect(rules == rulesBefore)
    }

    @Test(arguments: [RememberingMode.switchedByHand, .addedByYou])
    func visitingAddsNothingUnlessEverySiteIsRemembered(websites: RememberingMode) {
        var rules = rules(websites: websites)
        let rulesBefore = rules

        WebsiteVisitPolicy.record(keyboardID: canadian, in: githubInChrome, rules: &rules)

        #expect(rules == rulesBefore)
    }

    @Test func aPageWithoutAnAddressAddsNothing() {
        var rules = rules(websites: .everyOne)
        let rulesBefore = rules
        let newTabPage = SwitchContext(bundleIdentifier: "com.google.Chrome")

        WebsiteVisitPolicy.record(keyboardID: canadian, in: newTabPage, rules: &rules)

        #expect(rules == rulesBefore)
    }
}
