import KeyboardSwitcherKit

enum BadgeCheck {
    static func compareMacAndDrawnBadges() -> Bool {
        guard let macBadgeImages = MacBadgeImages() else {
            print("macOS's own badge drawer is missing, so the app draws its own badges.")
            return false
        }

        let textInputSources = TextInputSources()
        let keyboards = textInputSources.enabledKeyboards()
        let macImages = macBadgeImages.badgeImages(for: keyboards)
        let drawnBadgeImages = DrawnBadgeImages()
        let drawnImages = drawnBadgeImages.badgeImages(for: keyboards)

        print("The app shows macOS's own badges. Its fallback drawing, compared pixel by pixel on a Retina screen:")
        for keyboard in keyboards {
            guard let macImage = macImages[keyboard.id], let drawnImage = drawnImages[keyboard.id] else {
                print("  \(keyboard.name): macOS has no badge for it, so the app draws one")
                continue
            }
            let differingPixels = BadgePixels.differingPixelCount(between: macImage, and: drawnImage)
            let pixelCount = BadgePixels.pixelCount(of: macImage)
            print("  \(keyboard.name): \(differingPixels) of \(pixelCount) pixels differ")
        }
        return true
    }
}
