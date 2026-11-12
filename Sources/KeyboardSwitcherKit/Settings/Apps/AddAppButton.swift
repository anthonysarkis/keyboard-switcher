import SwiftUI

struct AddAppButton: View {
    let ruleBook: RuleBook
    let catalog: KeyboardCatalog
    let ownBundleIdentifier: String

    var body: some View {
        Button("Add App…", action: chooseFromApplications)
    }

    private func chooseFromApplications() {
        guard let pickedApp = ApplicationPicker.pick(),
              pickedApp.bundleIdentifier != ownBundleIdentifier,
              ruleBook.rules.appRule(for: pickedApp.bundleIdentifier) == nil,
              let keyboardID = catalog.currentKeyboardID ?? catalog.keyboards.first?.id
        else { return }
        ruleBook.setAppRule(bundleIdentifier: pickedApp.bundleIdentifier, appName: pickedApp.name, keyboardID: keyboardID)
    }
}
