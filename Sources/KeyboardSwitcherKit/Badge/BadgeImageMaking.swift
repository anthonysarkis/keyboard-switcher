import AppKit
import KeyboardSwitcherCore

public protocol BadgeImageMaking: AnyObject {
    func badgeImages(for keyboards: [Keyboard]) -> [String: NSImage]
}
