extension RulesFile {
    public func appRule(for bundleIdentifier: String) -> AppRule? {
        appRules.first { appRule in appRule.bundleIdentifier == bundleIdentifier }
    }

    public mutating func setAppRule(bundleIdentifier: String, appName: String, keyboardID: String) {
        if let index = appRules.firstIndex(where: { appRule in appRule.bundleIdentifier == bundleIdentifier }) {
            appRules[index].appName = appName
            appRules[index].keyboardID = keyboardID
        } else {
            let appRule = AppRule(bundleIdentifier: bundleIdentifier, appName: appName, keyboardID: keyboardID)
            appRules.append(appRule)
        }
        lastUsedByApp[bundleIdentifier] = nil
    }

    public mutating func removeAppRule(bundleIdentifier: String) {
        appRules.removeAll { appRule in appRule.bundleIdentifier == bundleIdentifier }
    }

    public mutating func setWebsiteRule(website: String, keyboardID: String) {
        if let index = websiteRules.firstIndex(where: { websiteRule in websiteRule.website == website }) {
            websiteRules[index].keyboardID = keyboardID
        } else {
            let websiteRule = WebsiteRule(website: website, keyboardID: keyboardID)
            websiteRules.append(websiteRule)
        }
    }

    public mutating func removeWebsiteRule(website: String) {
        websiteRules.removeAll { websiteRule in websiteRule.website == website }
    }
}
