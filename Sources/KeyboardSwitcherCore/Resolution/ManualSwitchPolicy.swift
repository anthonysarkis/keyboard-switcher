public enum ManualSwitchPolicy {
    public static func record(keyboardID: String, appName: String, in context: SwitchContext, rules: inout RulesFile) {
        if let website = context.website {
            let matchingRule = WebsiteRuleMatcher.bestRule(for: website, in: rules.websiteRules)
            switch rules.preferences.websitesRemembering {
            case .everyOne, .switchedByHand:
                let rememberedWebsite = matchingRule?.website ?? website
                rules.setWebsiteRule(website: rememberedWebsite, keyboardID: keyboardID)
                return
            case .addedByYou:
                guard matchingRule == nil else { return }
            }
        }

        guard rules.preferences.appsRemembering != .addedByYou else { return }
        let listedName = rules.appRule(for: context.bundleIdentifier)?.appName ?? appName
        rules.setAppRule(bundleIdentifier: context.bundleIdentifier, appName: listedName, keyboardID: keyboardID)
    }
}
