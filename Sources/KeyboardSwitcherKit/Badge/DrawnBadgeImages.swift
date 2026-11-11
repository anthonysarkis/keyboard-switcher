import AppKit
import KeyboardSwitcherCore

public final class DrawnBadgeImages: BadgeImageMaking {
    public init() {}

    public func badgeImages(for keyboards: [Keyboard]) -> [String: NSImage] {
        let badges = KeyboardBadgeMaker.badges(for: keyboards)
        return badges.mapValues { badge in BadgeImage.make(for: badge) }
    }
}
