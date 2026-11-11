public protocol KeyboardRuleSource: Sendable {
    func decision(for context: SwitchContext, in rules: RulesFile) -> KeyboardDecision?
}
