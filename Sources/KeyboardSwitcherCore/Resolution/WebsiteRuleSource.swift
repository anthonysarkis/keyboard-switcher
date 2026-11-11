public struct WebsiteRuleSource: KeyboardRuleSource {
    public init() {}

    public func decision(for context: SwitchContext, in rules: RulesFile) -> KeyboardDecision? {
        guard let website = context.website,
              let websiteRule = WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules)
        else { return nil }

        let source = DecisionSource.websiteRule(website: websiteRule.website)
        return KeyboardDecision(keyboardID: websiteRule.keyboardID, source: source)
    }
}
