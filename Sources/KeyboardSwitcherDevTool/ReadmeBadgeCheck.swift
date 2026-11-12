import KeyboardSwitcherKit

enum ReadmeBadgeCheck {
    private static let largestDifferingShare = 0.1

    static func compareWithMac() throws {
        guard let macBadgeImages = MacBadgeImages() else {
            print("macOS's own badge drawer is missing, so the README badges were not compared with it.")
            return
        }
        let macImages = macBadgeImages.badgeImages(for: ReadmeExample.keyboards)
        for keyboard in ReadmeExample.keyboards {
            guard let macImage = macImages[keyboard.id] else { continue }
            let readmeBadge = ReadmeExample.macBadge(for: keyboard)
            let readmeImage = BadgeImage.make(for: readmeBadge)
            let differingPixels = BadgePixels.differingPixelCount(between: macImage, and: readmeImage)
            let pixelCount = BadgePixels.pixelCount(of: macImage)
            let differingShare = Double(differingPixels) / Double(pixelCount)
            print("Badge \(readmeBadge.text) for \(keyboard.name): \(differingPixels) of \(pixelCount) pixels differ from macOS's own")
            guard differingShare <= largestDifferingShare else {
                throw ReadmeAnimationError.badgeDiffersFromMac(keyboardName: keyboard.name, differingPixels: differingPixels, pixelCount: pixelCount)
            }
        }
    }
}
