import Observation

@Observable
public final class SystemToggles {
    public private(set) var launchAtLogin = false
    public private(set) var showMacKeyboardIcon = true

    private let loginItem: any LoginItemControlling
    private let macKeyboardIcon: any MacKeyboardIconControlling

    public init(loginItem: any LoginItemControlling, macKeyboardIcon: any MacKeyboardIconControlling) {
        self.loginItem = loginItem
        self.macKeyboardIcon = macKeyboardIcon
        refresh()
    }

    public func refresh() {
        let loginItemIsEnabled = loginItem.isEnabled
        let macKeyboardIconIsShown = macKeyboardIcon.isShown
        if launchAtLogin != loginItemIsEnabled {
            launchAtLogin = loginItemIsEnabled
        }
        if showMacKeyboardIcon != macKeyboardIconIsShown {
            showMacKeyboardIcon = macKeyboardIconIsShown
        }
    }

    public func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try loginItem.setEnabled(enabled)
            Log.settings.notice("Open at login: \(enabled, privacy: .public)")
        } catch {
            Log.settings.error("Could not change Open at login: \(error.localizedDescription, privacy: .public)")
        }
        refresh()
    }

    public func setShowMacKeyboardIcon(_ shown: Bool) {
        macKeyboardIcon.setShown(shown)
        Log.settings.notice("Mac's own keyboard icon shown: \(shown, privacy: .public)")
        refresh()
    }
}
