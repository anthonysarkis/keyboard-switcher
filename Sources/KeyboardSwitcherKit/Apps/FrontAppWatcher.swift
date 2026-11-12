import AppKit

public final class FrontAppWatcher {
    private let onChange: @MainActor (AppIdentity?) -> Void
    private var activationObserver: (any NSObjectProtocol)?

    public init(onChange: @escaping @MainActor (AppIdentity?) -> Void) {
        self.onChange = onChange
    }

    public var currentFrontApp: AppIdentity? {
        guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else { return nil }
        return AppIdentity(application: frontmostApplication)
    }

    public func start() {
        let workspaceNotifications = NSWorkspace.shared.notificationCenter
        activationObserver = workspaceNotifications.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [onChange] notification in
            let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            let bundleIdentifier = application?.bundleIdentifier
            let localizedName = application?.localizedName
            let isRegularApp = application?.activationPolicy == .regular
            MainActor.assumeIsolated {
                let frontApp = AppIdentity(bundleIdentifier: bundleIdentifier, localizedName: localizedName, isRegularApp: isRegularApp)
                onChange(frontApp)
            }
        }
    }
}
