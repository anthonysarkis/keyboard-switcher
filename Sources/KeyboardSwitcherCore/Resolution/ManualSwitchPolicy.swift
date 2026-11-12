public enum ManualSwitchPolicy {
    public static func record(keyboardID: String, in context: SwitchContext, rules: inout RulesFile) {
        guard rules.preferences.remembersManualSwitches else { return }

        let websiteRule = context.website.flatMap { website in
            WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules)
        }

        if let websiteRule {
            rules.setWebsiteRule(website: websiteRule.website, keyboardID: keyboardID)
        } else if let appRule = rules.appRule(for: context.bundleIdentifier) {
            rules.setAppRule(bundleIdentifier: appRule.bundleIdentifier, appName: appRule.appName, keyboardID: keyboardID)
        } else {
            rules.lastUsedByApp[context.bundleIdentifier] = keyboardID
        }
    }
}
