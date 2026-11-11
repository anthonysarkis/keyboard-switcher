public enum WebsiteRuleMatcher {
    public static func bestRule(for website: String, in rules: [WebsiteRule]) -> WebsiteRule? {
        let matchingRules = rules.filter { rule in covers(rule, website: website) }
        return matchingRules.max { shorterRule, longerRule in shorterRule.website.count < longerRule.website.count }
    }

    private static func covers(_ rule: WebsiteRule, website: String) -> Bool {
        let isSameWebsite = website == rule.website
        let isSubdomain = website.hasSuffix("." + rule.website)
        return isSameWebsite || isSubdomain
    }
}
