public enum ManualSwitchPolicy {
    public static func record(keyboardID: String, appName: String, in context: SwitchContext, rules: inout RulesFile) {
        guard rules.preferences.remembersManualSwitches else { return }

        let websiteRule = context.website.flatMap { website in
            WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules)
        }

        if let websiteRule {
            rules.setWebsiteRule(website: websiteRule.website, keyboardID: keyboardID)
        } else {
            let listedName = rules.appRule(for: context.bundleIdentifier)?.appName ?? appName
            rules.setAppRule(bundleIdentifier: context.bundleIdentifier, appName: listedName, keyboardID: keyboardID)
        }
    }
}
