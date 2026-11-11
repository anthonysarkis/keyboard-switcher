public struct RuleResolver: Sendable {
    public static let standard = RuleResolver(sources: [
        WebsiteRuleSource(),
        AppRuleSource(),
        LastUsedRuleSource(),
    ])

    private let sources: [any KeyboardRuleSource]

    public init(sources: [any KeyboardRuleSource]) {
        self.sources = sources
    }

    public func decision(
        for context: SwitchContext,
        rules: RulesFile,
        availableKeyboardIDs: Set<String>
    ) -> KeyboardDecision? {
        for source in sources {
            guard let decision = source.decision(for: context, in: rules),
                  availableKeyboardIDs.contains(decision.keyboardID)
            else { continue }
            return decision
        }
        return nil
    }
}
