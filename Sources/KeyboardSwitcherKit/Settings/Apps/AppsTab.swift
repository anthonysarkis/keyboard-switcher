import SwiftUI
import KeyboardSwitcherCore

public struct AppsTab: View {
    let ruleBook: RuleBook
    let catalog: KeyboardCatalog
    let ownBundleIdentifier: String

    public init(ruleBook: RuleBook, catalog: KeyboardCatalog, ownBundleIdentifier: String) {
        self.ruleBook = ruleBook
        self.catalog = catalog
        self.ownBundleIdentifier = ownBundleIdentifier
    }

    public var body: some View {
        Form {
            Section {
                if ruleBook.rules.appRules.isEmpty {
                    Text("No apps yet")
                        .foregroundStyle(.secondary)
                }
                ForEach(ruleBook.rules.appRules) { appRule in
                    AppRuleRow(appRule: appRule, ruleBook: ruleBook, keyboards: catalog.keyboards)
                }
            } footer: {
                HStack {
                    Spacer()
                    AddAppButton(ruleBook: ruleBook, catalog: catalog, ownBundleIdentifier: ownBundleIdentifier)
                }
            }
        }
        .settingsTabFrame()
    }
}
