import AppKit
import KeyboardSwitcherCore

public enum BadgeImage {
    public static func make(for badge: KeyboardBadge) -> NSImage {
        let font = BadgeFont.fitting(badge.text)
        let text = NSAttributedString(string: badge.text, attributes: [
            .font: font,
            .foregroundColor: NSColor.black,
        ])
        let textOrigin = centeredOrigin(of: text, font: font)

        let image = NSImage(size: BadgeMetrics.size, flipped: false) { imageFrame in
            NSColor.black.set()
            switch badge.style {
            case .filled:
                fillBox(in: imageFrame)
                cutOut(text, at: textOrigin)
            case .outlined:
                strokeBox(in: imageFrame)
                text.draw(at: textOrigin)
            }
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func fillBox(in imageFrame: NSRect) {
        let box = NSBezierPath(roundedRect: imageFrame, xRadius: BadgeMetrics.cornerRadius, yRadius: BadgeMetrics.cornerRadius)
        box.fill()
    }

    private static func strokeBox(in imageFrame: NSRect) {
        let halfLine = BadgeMetrics.lineWidth / 2
        let lineFrame = imageFrame.insetBy(dx: halfLine, dy: halfLine)
        let box = NSBezierPath(roundedRect: lineFrame, xRadius: BadgeMetrics.cornerRadius, yRadius: BadgeMetrics.cornerRadius)
        box.lineWidth = BadgeMetrics.lineWidth
        box.stroke()
    }

    private static func cutOut(_ text: NSAttributedString, at textOrigin: NSPoint) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current?.compositingOperation = .destinationOut
        text.draw(at: textOrigin)
        NSGraphicsContext.restoreGraphicsState()
    }

    private static func centeredOrigin(of text: NSAttributedString, font: NSFont) -> NSPoint {
        let textWidth = text.size().width
        let leftEdge = (BadgeMetrics.size.width - textWidth) / 2
        let capitalsBaseline = (BadgeMetrics.size.height - font.capHeight) / 2 - BadgeMetrics.capitalsDrop
        return NSPoint(x: leftEdge, y: capitalsBaseline + font.descender)
    }
}
