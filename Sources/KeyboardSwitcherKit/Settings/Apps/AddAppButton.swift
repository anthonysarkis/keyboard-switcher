import SwiftUI

struct AddAppButton: View {
    let ruleBook: RuleBook
    let catalog: KeyboardCatalog
    let ownBundleIdentifier: String

    var body: some View {
        Menu("Add App…") {
            let addableApps = openAppsWithoutRule
            ForEach(addableApps) { openApp in
                Button {
                    add(openApp)
                } label: {
                    let appIcon = InstalledApps.menuIcon(for: openApp.bundleIdentifier)
                    Label {
                        Text(openApp.name)
                    } icon: {
                        Image(nsImage: appIcon)
                    }
                }
            }
            if !addableApps.isEmpty {
                Divider()
            }
            Button("Choose from Applications…", action: chooseFromApplications)
        }
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private var openAppsWithoutRule: [AppIdentity] {
        let ruledBundleIdentifiers = ruleBook.rules.appRules.map(\.bundleIdentifier)
        let excludedBundleIdentifiers = Set(ruledBundleIdentifiers).union([ownBundleIdentifier])
        return InstalledApps.openApps(excluding: excludedBundleIdentifiers)
    }

    private func chooseFromApplications() {
        guard let pickedApp = ApplicationPicker.pick() else { return }
        add(pickedApp)
    }

    private func add(_ app: AppIdentity) {
        guard let keyboardID = catalog.currentKeyboardID ?? catalog.keyboards.first?.id else { return }
        ruleBook.setAppRule(bundleIdentifier: app.bundleIdentifier, appName: app.name, keyboardID: keyboardID)
    }
}
