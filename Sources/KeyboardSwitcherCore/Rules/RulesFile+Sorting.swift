import Foundation

extension RulesFile {
    public var appRulesByName: [AppRule] {
        appRules.sorted { firstRule, secondRule in
            firstRule.appName.localizedStandardCompare(secondRule.appName) == .orderedAscending
        }
    }

    public var websiteRulesByAddress: [WebsiteRule] {
        websiteRules.sorted { firstRule, secondRule in
            firstRule.website.localizedStandardCompare(secondRule.website) == .orderedAscending
        }
    }
}
