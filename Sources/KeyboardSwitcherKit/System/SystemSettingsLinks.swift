import AppKit

enum SystemSettingsLinks {
    private static let automationPrivacyAddress = "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"

    static func openAutomationPrivacy() {
        open(automationPrivacyAddress)
    }

    private static func open(_ address: String) {
        guard let settingsURL = URL(string: address) else { return }
        NSWorkspace.shared.open(settingsURL)
    }
}
