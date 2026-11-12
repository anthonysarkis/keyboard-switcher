import SwiftUI
import KeyboardSwitcherCore

public struct WebsitesTab: View {
    let ruleBook: RuleBook
    let catalog: KeyboardCatalog
    let tabTracker: BrowserTabTracker
    let websiteIcons: WebsiteIconStore
    @State private var isAddingWebsite = false

    public init(ruleBook: RuleBook, catalog: KeyboardCatalog, tabTracker: BrowserTabTracker, websiteIcons: WebsiteIconStore) {
        self.ruleBook = ruleBook
        self.catalog = catalog
        self.tabTracker = tabTracker
        self.websiteIcons = websiteIcons
    }

    public var body: some View {
        Form {
            Section {
                let sortedWebsiteRules = ruleBook.rules.websiteRulesByAddress
                if sortedWebsiteRules.isEmpty {
                    Text("No websites yet")
                        .foregroundStyle(.secondary)
                }
                ForEach(sortedWebsiteRules) { websiteRule in
                    WebsiteRuleRow(websiteRule: websiteRule, ruleBook: ruleBook, keyboards: catalog.keyboards, websiteIcons: websiteIcons)
                }
            } header: {
                HStack {
                    Spacer()
                    Button("Add Website…") { isAddingWebsite = true }
                }
            }

            Section("Browsers") {
                ForEach(installedBrowsers) { browser in
                    BrowserPermissionRow(browser: browser, tabTracker: tabTracker)
                }
            }
        }
        .animation(.snappy, value: ruleBook.rules.websiteRules)
        .settingsListTabFrame()
        .sheet(isPresented: $isAddingWebsite) {
            AddWebsiteSheet(ruleBook: ruleBook, catalog: catalog, suggestedWebsite: tabTracker.currentWebsite)
        }
        .onAppear { tabTracker.refreshPermissions() }
    }

    private var installedBrowsers: [SupportedBrowser] {
        SupportedBrowser.all.filter { browser in InstalledApps.isInstalled(browser.bundleIdentifier) }
    }
}
