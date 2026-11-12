import Testing
import KeyboardSwitcherCore

struct RulesSortingTests {
    private let canadian = "com.apple.keylayout.Canadian"

    @Test func appsAreListedFromAToZWhateverTheCase() {
        let appNames = ["WhatsApp", "activity Monitor", "Xcode", "Calculator", "Microsoft Teams"]
        let appRules = appNames.map { appName in
            AppRule(bundleIdentifier: "com.example.\(appName)", appName: appName, keyboardID: canadian)
        }
        let rules = RulesFile(appRules: appRules)

        #expect(rules.appRulesByName.map(\.appName) == ["activity Monitor", "Calculator", "Microsoft Teams", "WhatsApp", "Xcode"])
    }

    @Test func websitesAreListedFromAToZ() {
        let websites = ["web.whatsapp.com", "claude.ai", "teams.microsoft.com"]
        let websiteRules = websites.map { website in WebsiteRule(website: website, keyboardID: canadian) }
        let rules = RulesFile(websiteRules: websiteRules)

        #expect(rules.websiteRulesByAddress.map(\.website) == ["claude.ai", "teams.microsoft.com", "web.whatsapp.com"])
    }
}
