import AppKit
import KeyboardSwitcherCore

struct ReadmeExampleApp {
    private static let iconFolder = URL(fileURLWithPath: "docs/app-icons")

    let appName: String
    let menuTitle: String
    let bundleIdentifier: String
    let iconName: String
    let keyboard: Keyboard
    let typedText: String
    let typedFont: MessageFont

    var icon: NSImage {
        let iconFile = Self.iconFile(named: iconName)
        return NSImage(contentsOf: iconFile) ?? NSWorkspace.shared.icon(for: .application)
    }

    static func iconFile(named iconName: String) -> URL {
        iconFolder.appending(path: "\(iconName).png")
    }
}
