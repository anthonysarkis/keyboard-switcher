import AppKit
import KeyboardSwitcherCore

final class StatusMenuBuilder {
    private let coordinator: SwitchCoordinator
    private let catalog: KeyboardCatalog
    private let ruleBook: RuleBook
    private let tabTracker: BrowserTabTracker
    private let openSettings: @MainActor () -> Void

    init(
        coordinator: SwitchCoordinator,
        catalog: KeyboardCatalog,
        ruleBook: RuleBook,
        tabTracker: BrowserTabTracker,
        openSettings: @escaping @MainActor () -> Void
    ) {
        self.coordinator = coordinator
        self.catalog = catalog
        self.ruleBook = ruleBook
        self.tabTracker = tabTracker
        self.openSettings = openSettings
    }

    func rebuild(_ menu: NSMenu) {
        menu.removeAllItems()
        let sections = [websiteSection(), appSection(), appControlSection()]
        let filledSections = sections.filter { section in !section.isEmpty }

        for (index, section) in filledSections.enumerated() {
            if index > 0 {
                let separator = NSMenuItem.separator()
                menu.addItem(separator)
            }
            for item in section {
                menu.addItem(item)
            }
        }
    }

    private func websiteSection() -> [NSMenuItem] {
        guard let frontApp = coordinator.frontAppOtherThanOurs,
              let browser = SupportedBrowser.browser(bundleIdentifier: frontApp.bundleIdentifier)
        else { return [] }

        tabTracker.readNow()
        switch tabTracker.permissions[browser.bundleIdentifier] {
        case .asksFirstTime:
            let allowItem = MenuItemFactory.actionItem("Allow Website Rules in \(browser.name)…") { [tabTracker] in
                tabTracker.requestPermission(for: browser)
            }
            return [allowItem]
        case .denied:
            let allowInSettingsItem = MenuItemFactory.actionItem("Allow Website Rules in \(browser.name)…") {
                SystemSettingsLinks.openAutomationPrivacy()
            }
            return [allowInSettingsItem]
        case .allowed, .notOpen, nil:
            return websiteRuleItems(in: browser)
        }
    }

    private func websiteRuleItems(in browser: SupportedBrowser) -> [NSMenuItem] {
        guard let website = tabTracker.currentWebsite else { return [] }
        let appliedRule = WebsiteRuleMatcher.bestRule(for: website, in: ruleBook.rules.websiteRules)
        let ruleWebsite = appliedRule?.website ?? website

        let header = MenuItemFactory.header(ruleWebsite)
        let keyboardItems = catalog.keyboards.map { keyboard in
            MenuItemFactory.actionItem(keyboard.name, isChecked: appliedRule?.keyboardID == keyboard.id) { [ruleBook] in
                ruleBook.setWebsiteRule(website: ruleWebsite, keyboardID: keyboard.id)
            }
        }
        let followBrowserItem = MenuItemFactory.actionItem("Same as \(browser.name)", isChecked: appliedRule == nil) { [ruleBook] in
            ruleBook.removeWebsiteRule(website: ruleWebsite)
        }
        return [header] + keyboardItems + [followBrowserItem]
    }

    private func appSection() -> [NSMenuItem] {
        guard let frontApp = coordinator.frontAppOtherThanOurs else { return [] }
        let appIcon = InstalledApps.menuIcon(for: frontApp.bundleIdentifier)
        let appRule = ruleBook.rules.appRule(for: frontApp.bundleIdentifier)

        let header = MenuItemFactory.header(frontApp.name, image: appIcon)
        let keyboardItems = catalog.keyboards.map { keyboard in
            MenuItemFactory.actionItem(keyboard.name, isChecked: appRule?.keyboardID == keyboard.id) { [ruleBook] in
                ruleBook.setAppRule(bundleIdentifier: frontApp.bundleIdentifier, appName: frontApp.name, keyboardID: keyboard.id)
            }
        }
        let noRuleTitle = ruleBook.rules.preferences.noRuleTitle
        let noRuleItem = MenuItemFactory.actionItem(noRuleTitle, isChecked: appRule == nil) { [ruleBook] in
            ruleBook.removeAppRule(bundleIdentifier: frontApp.bundleIdentifier)
        }
        return [header] + keyboardItems + [noRuleItem]
    }

    private func appControlSection() -> [NSMenuItem] {
        let settingsItem = MenuItemFactory.actionItem("Settings…", keyEquivalent: ",") { [openSettings] in
            openSettings()
        }
        let quitItem = MenuItemFactory.actionItem("Quit Keyboard Switcher", keyEquivalent: "q") {
            NSApp.terminate(nil)
        }
        return [settingsItem, quitItem]
    }
}
