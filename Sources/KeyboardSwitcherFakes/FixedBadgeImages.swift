import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit

public final class FixedBadgeImages: BadgeImageMaking {
    private let images: [String: NSImage]

    public init(images: [String: NSImage]) {
        self.images = images
    }

    public func badgeImages(for keyboards: [Keyboard]) -> [String: NSImage] {
        images
    }
}
