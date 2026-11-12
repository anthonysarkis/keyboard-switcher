public enum AppEntryPolicy {
    public static func record(keyboardID: String, appName: String, in context: SwitchContext, rules: inout RulesFile) {
        guard rules.preferences.remembersManualSwitches,
              rules.appRule(for: context.bundleIdentifier) == nil
        else { return }

        rules.setAppRule(bundleIdentifier: context.bundleIdentifier, appName: appName, keyboardID: keyboardID)
    }
}
