import AppKit
import KeyboardSwitcherCore

public final class BadgeImagesWithFallback: BadgeImageMaking {
    private let preferred: (any BadgeImageMaking)?
    private let fallback: any BadgeImageMaking

    public init(preferred: (any BadgeImageMaking)?, fallback: any BadgeImageMaking) {
        self.preferred = preferred
        self.fallback = fallback
    }

    public func badgeImages(for keyboards: [Keyboard]) -> [String: NSImage] {
        let fallbackImages = fallback.badgeImages(for: keyboards)
        guard let preferred else { return fallbackImages }
        let preferredImages = preferred.badgeImages(for: keyboards)
        return fallbackImages.merging(preferredImages) { _, preferredImage in preferredImage }
    }
}
