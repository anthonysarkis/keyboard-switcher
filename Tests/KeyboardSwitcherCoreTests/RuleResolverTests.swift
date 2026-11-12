import Testing
import KeyboardSwitcherCore

struct RuleResolverTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
    private let resolver = RuleResolver.standard
    private var bothKeyboards: Set<String> { [canadian, canadianCSA] }

    private func rulesWithChromeAndWhatsAppWeb() -> RulesFile {
        let chromeRule = AppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", keyboardID: canadian)
        let whatsAppWebRule = WebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)
        return RulesFile(appRules: [chromeRule], websiteRules: [whatsAppWebRule])
    }

    @Test func websiteRuleWinsOverTheBrowserRule() {
        let rules = rulesWithChromeAndWhatsAppWeb()
        let context = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "web.whatsapp.com")

        let decision = resolver.decision(for: context, rules: rules, availableKeyboardIDs: bothKeyboards)

        #expect(decision == KeyboardDecision(keyboardID: canadianCSA, source: .websiteRule(website: "web.whatsapp.com")))
    }

    @Test func browserRuleAppliesOnOtherWebsites() {
        let rules = rulesWithChromeAndWhatsAppWeb()
        let context = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "github.com")

        let decision = resolver.decision(for: context, rules: rules, availableKeyboardIDs: bothKeyboards)

        #expect(decision == KeyboardDecision(keyboardID: canadian, source: .appRule))
    }

    @Test func ruleForAKeyboardThatIsNoLongerEnabledIsSkipped() {
        let rules = rulesWithChromeAndWhatsAppWeb()
        let context = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "web.whatsapp.com")

        let decision = resolver.decision(for: context, rules: rules, availableKeyboardIDs: [canadian])

        #expect(decision == KeyboardDecision(keyboardID: canadian, source: .appRule))
    }

    @Test func nothingKnownMeansLeaveTheKeyboardAsItIs() {
        let emptyRules = RulesFile()
        let finderContext = SwitchContext(bundleIdentifier: "com.apple.finder")

        let decision = resolver.decision(for: finderContext, rules: emptyRules, availableKeyboardIDs: bothKeyboards)

        #expect(decision == nil)
    }
}

struct RuleResolverSourcesTests {
    private struct FixedSource: KeyboardRuleSource {
        let keyboardID: String

        func decision(for context: SwitchContext, in rules: RulesFile) -> KeyboardDecision? {
            KeyboardDecision(keyboardID: keyboardID, source: .appRule)
        }
    }

    @Test func sourcesAreAskedInOrderAndUnavailableKeyboardsAreSkipped() {
        let firstSource = FixedSource(keyboardID: "turned-off")
        let secondSource = FixedSource(keyboardID: "available")
        let resolver = RuleResolver(sources: [firstSource, secondSource])
        let context = SwitchContext(bundleIdentifier: "com.apple.Notes")
        let emptyRules = RulesFile()

        let decision = resolver.decision(for: context, rules: emptyRules, availableKeyboardIDs: ["available"])

        #expect(decision?.keyboardID == "available")
    }
}
