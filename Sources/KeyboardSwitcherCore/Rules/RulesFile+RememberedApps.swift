import Foundation

extension RulesFile {
    public mutating func moveRememberedAppsIntoTheList(appNameFor: (String) -> String?) {
        let rememberedApps = lastUsedByApp
        lastUsedByApp = [:]
        guard preferences.remembersManualSwitches else { return }

        let movedRules = rememberedApps.compactMap { bundleIdentifier, keyboardID -> AppRule? in
            guard appRule(for: bundleIdentifier) == nil, let appName = appNameFor(bundleIdentifier) else { return nil }
            return AppRule(bundleIdentifier: bundleIdentifier, appName: appName, keyboardID: keyboardID)
        }
        let sortedRules = movedRules.sorted { firstRule, secondRule in
            firstRule.appName.localizedCaseInsensitiveCompare(secondRule.appName) == .orderedAscending
        }
        appRules.append(contentsOf: sortedRules)
    }
}
