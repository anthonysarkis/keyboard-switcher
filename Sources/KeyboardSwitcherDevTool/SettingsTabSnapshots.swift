import AppKit
import KeyboardSwitcherKit

enum SettingsTabSnapshots {
    static func writeAppsTab(of context: AppContext, in folder: URL, appIcons: [String: NSImage] = [:]) throws {
        let appsTab = AppsTab(
            ruleBook: context.ruleBook,
            catalog: context.catalog,
            ownBundleIdentifier: context.coordinator.ownBundleIdentifier
        )
        let appsTabWithIcons = appsTab.environment(\.appIconOverrides, appIcons)
        try ViewSnapshotter.write(appsTabWithIcons, named: "settings-apps", in: folder)
    }

    static func writeWebsitesTab(of context: AppContext, in folder: URL) throws {
        let websitesTab = WebsitesTab(ruleBook: context.ruleBook, catalog: context.catalog, tabTracker: context.tabTracker)
        try ViewSnapshotter.write(websitesTab, named: "settings-websites", in: folder)
    }

    static func writeGeneralTab(of context: AppContext, in folder: URL) throws {
        let generalTab = GeneralTab(ruleBook: context.ruleBook, systemToggles: context.systemToggles)
        try ViewSnapshotter.write(generalTab, named: "settings-general", in: folder)
    }
}
