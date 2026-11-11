public struct AppRuleSource: KeyboardRuleSource {
    public init() {}

    public func decision(for context: SwitchContext, in rules: RulesFile) -> KeyboardDecision? {
        guard let appRule = rules.appRule(for: context.bundleIdentifier) else { return nil }
        return KeyboardDecision(keyboardID: appRule.keyboardID, source: .appRule)
    }
}
