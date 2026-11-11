import AppKit
import KeyboardSwitcherCore

struct ReadmeHeroApp: Identifiable {
    let caption: String
    let bundleIdentifier: String
    let keyboard: Keyboard

    var id: String {
        caption
    }

    var icon: NSImage {
        let workspace = NSWorkspace.shared
        guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            return workspace.icon(for: .application)
        }
        let resolvedURL = applicationURL.resolvingSymlinksInPath()
        return workspace.icon(forFile: resolvedURL.path)
    }
}
