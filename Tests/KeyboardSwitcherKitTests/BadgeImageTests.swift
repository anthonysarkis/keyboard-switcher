import AppKit
import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct BadgeImageTests {
    @Test(arguments: [
        KeyboardBadge(text: "CA", style: .filled),
        KeyboardBadge(text: "CSA", style: .outlined),
        KeyboardBadge(text: "WXYZ", style: .outlined),
    ])
    func everyBadgeHasTheMacSize(badge: KeyboardBadge) {
        let image = BadgeImage.make(for: badge)

        #expect(image.size == NSSize(width: 22, height: 16))
        #expect(image.isTemplate)
    }

    @Test func shortLabelsKeepTheRegularFont() {
        let regularFont = NSFont.systemFont(ofSize: 11, weight: .semibold)

        #expect(BadgeFont.fitting("CA") == regularFont)
    }

    @Test(arguments: ["CA", "CSA", "WXYZ", "ＡＢＣ"])
    func everyLabelFitsInsideTheBox(text: String) {
        let font = BadgeFont.fitting(text)
        let textWidth = BadgeFont.width(of: text, in: font)

        #expect(textWidth <= BadgeMetrics.textWidthLimit + 0.01)
    }

    @Test func macOSBadgesWinAndDrawnOnesFillTheGaps() {
        let macImage = NSImage(size: BadgeMetrics.size)
        let macBadgeImages = FixedBadgeImages(images: [SampleKeyboards.canadian.id: macImage])
        let drawnBadgeImages = DrawnBadgeImages()
        let badgeImages = BadgeImagesWithFallback(preferred: macBadgeImages, fallback: drawnBadgeImages)

        let images = badgeImages.badgeImages(for: SampleKeyboards.both)

        #expect(images[SampleKeyboards.canadian.id] === macImage)
        #expect(images[SampleKeyboards.canadianCSA.id] != nil)
    }
}
