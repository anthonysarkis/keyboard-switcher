import SwiftUI

struct BrowserPermissionRow: View {
    let browser: SupportedBrowser
    let tabTracker: BrowserTabTracker

    var body: some View {
        LabeledContent {
            permissionControl
        } label: {
            HStack(spacing: 10) {
                AppIconView(bundleIdentifier: browser.bundleIdentifier)
                Text(browser.name)
            }
        }
    }

    @ViewBuilder
    private var permissionControl: some View {
        switch tabTracker.permissions[browser.bundleIdentifier] {
        case .allowed:
            Text("Allowed").foregroundStyle(.secondary)
        case .asksFirstTime:
            Button("Allow…") { tabTracker.requestPermission(for: browser) }
        case .denied:
            Button("Allow in System Settings…") { SystemSettingsLinks.openAutomationPrivacy() }
        case .notOpen, nil:
            Text("Not open").foregroundStyle(.secondary)
        }
    }
}
