import AppKit
import KeyboardSwitcherCore

struct ReadmeHeroApp: Identifiable {
    private static let iconFolder = URL(fileURLWithPath: "docs/app-icons")

    let caption: String
    let appName: String
    let bundleIdentifier: String
    let iconName: String
    let keyboard: Keyboard

    var id: String {
        caption
    }

    var icon: NSImage {
        let iconFile = Self.iconFolder.appending(path: "\(iconName).png")
        return NSImage(contentsOf: iconFile) ?? NSWorkspace.shared.icon(for: .application)
    }
}
