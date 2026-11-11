public enum ManualSwitchPolicy {
    public static func record(keyboardID: String, in context: SwitchContext, rules: inout RulesFile) {
        let websiteRule = context.website.flatMap { website in
            WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules)
        }
        let appRule = rules.appRule(for: context.bundleIdentifier)
        let hasRuleHere = websiteRule != nil || appRule != nil

        if hasRuleHere {
            updateRuleIfAsked(websiteRule: websiteRule, appRule: appRule, keyboardID: keyboardID, rules: &rules)
        } else {
            rememberLastUsed(keyboardID: keyboardID, for: context.bundleIdentifier, rules: &rules)
        }
    }

    private static func updateRuleIfAsked(
        websiteRule: WebsiteRule?,
        appRule: AppRule?,
        keyboardID: String,
        rules: inout RulesFile
    ) {
        guard rules.preferences.manualSwitch == .becomesRule else { return }

        if let websiteRule {
            rules.setWebsiteRule(website: websiteRule.website, keyboardID: keyboardID)
        } else if let appRule {
            rules.setAppRule(bundleIdentifier: appRule.bundleIdentifier, appName: appRule.appName, keyboardID: keyboardID)
        }
    }

    private static func rememberLastUsed(keyboardID: String, for bundleIdentifier: String, rules: inout RulesFile) {
        guard rules.preferences.otherApps == .lastUsed else { return }
        rules.lastUsedByApp[bundleIdentifier] = keyboardID
    }
}
