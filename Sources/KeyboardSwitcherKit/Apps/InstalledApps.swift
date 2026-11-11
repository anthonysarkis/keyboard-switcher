import AppKit

enum InstalledApps {
    private static let menuIconSize = NSSize(width: 16, height: 16)
    private static var iconCache: [String: NSImage] = [:]

    static func isInstalled(_ bundleIdentifier: String) -> Bool {
        applicationURL(for: bundleIdentifier) != nil
    }

    static func icon(for bundleIdentifier: String) -> NSImage {
        if let cachedIcon = iconCache[bundleIdentifier] {
            return cachedIcon
        }
        let icon = loadIcon(for: bundleIdentifier)
        iconCache[bundleIdentifier] = icon
        return icon
    }

    static func menuIcon(for bundleIdentifier: String) -> NSImage {
        let fullSizeIcon = icon(for: bundleIdentifier)
        let menuIcon = fullSizeIcon.copy() as? NSImage ?? fullSizeIcon
        menuIcon.size = menuIconSize
        return menuIcon
    }

    static func openApps(excluding excludedBundleIdentifiers: Set<String>) -> [AppIdentity] {
        let runningApplications = NSWorkspace.shared.runningApplications
        let applicationsWithWindows = runningApplications.filter { application in application.activationPolicy == .regular }
        let openApps = applicationsWithWindows.compactMap { application in AppIdentity(application: application) }
        let addableApps = openApps.filter { openApp in !excludedBundleIdentifiers.contains(openApp.bundleIdentifier) }
        return addableApps.sorted { firstApp, secondApp in
            firstApp.name.localizedCaseInsensitiveCompare(secondApp.name) == .orderedAscending
        }
    }

    private static func loadIcon(for bundleIdentifier: String) -> NSImage {
        guard let applicationURL = applicationURL(for: bundleIdentifier) else {
            return NSWorkspace.shared.icon(for: .application)
        }
        return NSWorkspace.shared.icon(forFile: applicationURL.path)
    }

    private static func applicationURL(for bundleIdentifier: String) -> URL? {
        let registeredURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
        return registeredURL?.resolvingSymlinksInPath()
    }
}
