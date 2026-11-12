import AppKit

extension AppIdentity {
    init?(bundleIdentifier: String?, localizedName: String?, isRegularApp: Bool) {
        guard let bundleIdentifier else { return nil }
        self.init(bundleIdentifier: bundleIdentifier, name: localizedName ?? bundleIdentifier, isRegularApp: isRegularApp)
    }

    init?(application: NSRunningApplication) {
        let isRegularApp = application.activationPolicy == .regular
        self.init(bundleIdentifier: application.bundleIdentifier, localizedName: application.localizedName, isRegularApp: isRegularApp)
    }

    init?(applicationURL: URL) {
        guard let bundleIdentifier = Bundle(url: applicationURL)?.bundleIdentifier else { return nil }
        let displayName = FileManager.default.displayName(atPath: applicationURL.path)
        let appName = displayName.replacingOccurrences(of: ".app", with: "")
        self.init(bundleIdentifier: bundleIdentifier, name: appName)
    }
}
