public struct LastUsedRuleSource: KeyboardRuleSource {
    public init() {}

    public func decision(for context: SwitchContext, in rules: RulesFile) -> KeyboardDecision? {
        guard rules.preferences.remembersManualSwitches,
              let rememberedKeyboardID = rules.lastUsedByApp[context.bundleIdentifier]
        else { return nil }

        return KeyboardDecision(keyboardID: rememberedKeyboardID, source: .lastUsed)
    }
}
