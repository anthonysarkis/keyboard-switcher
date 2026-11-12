public enum WebsiteVisitPolicy {
    public static func record(keyboardID: String, in context: SwitchContext, rules: inout RulesFile) {
        guard rules.preferences.websitesRemembering == .everyOne,
              let website = context.website,
              WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules) == nil
        else { return }

        rules.setWebsiteRule(website: website, keyboardID: keyboardID)
    }
}
