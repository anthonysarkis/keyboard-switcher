public enum AppEntryPolicy {
    public static func record(keyboardID: String, in context: SwitchContext, rules: inout RulesFile) {
        guard rules.preferences.remembersManualSwitches,
              rules.appRule(for: context.bundleIdentifier) == nil,
              rules.lastUsedByApp[context.bundleIdentifier] == nil
        else { return }

        rules.lastUsedByApp[context.bundleIdentifier] = keyboardID
    }
}
