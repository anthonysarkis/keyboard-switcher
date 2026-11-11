import AppKit

enum BadgeFont {
    private static let widthAxis = axisIdentifier("wdth")
    private static let opticalSizeAxis = axisIdentifier("opsz")
    private static let smallestFontSize: CGFloat = 6
    private static let fontSizeSearchSteps = 12

    static func fitting(_ text: String) -> NSFont {
        let regularFont = NSFont.systemFont(ofSize: BadgeMetrics.fontSize, weight: BadgeMetrics.fontWeight)
        guard !fits(text, in: regularFont) else { return regularFont }

        let narrowFont = narrowed(regularFont)
        guard !fits(text, in: narrowFont) else { return narrowFont }

        return largestFitting(narrowFont, for: text)
    }

    static func width(of text: String, in font: NSFont) -> CGFloat {
        let attributedText = NSAttributedString(string: text, attributes: [.font: font])
        return attributedText.size().width
    }

    private static func fits(_ text: String, in font: NSFont) -> Bool {
        let textWidth = width(of: text, in: font)
        return textWidth <= BadgeMetrics.textWidthLimit
    }

    private static func largestFitting(_ font: NSFont, for text: String) -> NSFont {
        var fittingSize = smallestFontSize
        var tooWideSize = font.pointSize
        for _ in 0..<fontSizeSearchSteps {
            let middleSize = (fittingSize + tooWideSize) / 2
            let middleFont = resized(font, to: middleSize)
            if fits(text, in: middleFont) {
                fittingSize = middleSize
            } else {
                tooWideSize = middleSize
            }
        }
        return resized(font, to: fittingSize)
    }

    private static func narrowed(_ font: NSFont) -> NSFont {
        let variations = [
            widthAxis: BadgeMetrics.narrowFontWidth,
            opticalSizeAxis: BadgeMetrics.narrowFontOpticalSize,
        ]
        let narrowDescriptor = font.fontDescriptor.addingAttributes([.variation: variations])
        return NSFont(descriptor: narrowDescriptor, size: font.pointSize) ?? font
    }

    private static func resized(_ font: NSFont, to pointSize: CGFloat) -> NSFont {
        NSFont(descriptor: font.fontDescriptor, size: pointSize) ?? font
    }

    private static func axisIdentifier(_ tag: String) -> NSNumber {
        var code: UInt32 = 0
        for byte in tag.utf8 {
            code = code << 8 | UInt32(byte)
        }
        return NSNumber(value: code)
    }
}
