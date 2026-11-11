import Testing
import KeyboardSwitcherCore

struct WebsiteRuleMatcherTests {
    private let rules = [
        WebsiteRule(website: "whatsapp.com", keyboardID: "parent"),
        WebsiteRule(website: "web.whatsapp.com", keyboardID: "exact"),
    ]

    @Test func theClosestRuleWins() {
        #expect(WebsiteRuleMatcher.bestRule(for: "web.whatsapp.com", in: rules)?.keyboardID == "exact")
    }

    @Test func subdomainsUseTheParentRule() {
        #expect(WebsiteRuleMatcher.bestRule(for: "faq.whatsapp.com", in: rules)?.keyboardID == "parent")
    }

    @Test func aLookalikeDomainMatchesNothing() {
        #expect(WebsiteRuleMatcher.bestRule(for: "notwhatsapp.com", in: rules) == nil)
    }
}
