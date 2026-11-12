import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit

struct BubbleMarkup {
    private static let nameBaselineDrop = 5.2
    private static let shadowMargin = 28.0
    private static let outlineWidth = 0.6

    let keyboardName: String
    let badge: KeyboardBadge
    let width: Double
    let height: Double

    init(keyboardName: String, badge: KeyboardBadge) {
        let scale = ReadmeCanvas.interfaceScale
        let nameFontSize = Double(BubbleMetrics.nameFontSize) * scale
        let nameFont = TextMeasure.systemFont(size: nameFontSize, weight: .semibold)
        let nameWidth = TextMeasure.width(of: keyboardName, in: nameFont)
        let fixedWidth = BubbleMetrics.leadingPadding + BadgeMetrics.size.width + BubbleMetrics.badgeToNameSpacing + BubbleMetrics.trailingPadding
        self.keyboardName = keyboardName
        self.badge = badge
        width = Double(fixedWidth) * scale + nameWidth
        height = Double(BubbleMetrics.height) * scale
    }

    var shadowShape: ShadowShape {
        ShadowShape(width: width, height: height, cornerRadius: height / 2, margin: Self.shadowMargin, layers: ShadowShape.floatingLayers)
    }

    static func origin(belowPointerAtX pointerX: Double, y pointerY: Double) -> (x: Double, y: Double) {
        let scale = ReadmeCanvas.interfaceScale
        let rightOfPointer = Double(BubbleMetrics.offsetFromPointer.width + BubbleMetrics.shadowPadding)
        let belowPointer = Double(BubbleMetrics.offsetFromPointer.height + BubbleMetrics.shadowPadding)
        return (pointerX + rightOfPointer * scale, pointerY + belowPointer * scale)
    }

    static func visibleEvents(shownAt shownTime: Double) -> [AnimationEvent] {
        let visibleSeconds = BubbleMetrics.visibleDuration / .seconds(1)
        return AnimationEvents.window(
            from: shownTime,
            to: shownTime + visibleSeconds,
            fadeIn: BubbleMetrics.fadeInDuration,
            fadeOut: BubbleMetrics.fadeOutDuration
        )
    }

    func markup(x: Double, y: Double, style: String, theme: AnimationTheme, maskID: String) -> String {
        let scale = ReadmeCanvas.interfaceScale
        let shadow = ShadowPainter.markup(shadowShape, x: x, y: y, opacity: theme.shadowOpacity)
        let radius = height / 2
        let capsule = "<rect x=\"\(x.svgNumber)\" y=\"\(y.svgNumber)\" width=\"\(width.svgNumber)\" height=\"\(height.svgNumber)\" rx=\"\(radius.svgNumber)\" fill=\"\(theme.bubbleFill)\" stroke=\"\(theme.bubbleStroke)\" stroke-width=\"\(Self.outlineWidth.svgNumber)\"/>"
        let badgeLeft = x + Double(BubbleMetrics.leadingPadding) * scale
        let badgeTop = y + (height - BadgeMarkup.height * scale) / 2
        let badgeMarkup = BadgeMarkup.badge(badge, x: badgeLeft, y: badgeTop, scale: scale, color: theme.ink, maskID: maskID)
        let nameOffset = BubbleMetrics.leadingPadding + BadgeMetrics.size.width + BubbleMetrics.badgeToNameSpacing
        let nameLeft = x + Double(nameOffset) * scale
        let nameBaseline = y + height / 2 + Self.nameBaselineDrop
        let nameFontSize = Double(BubbleMetrics.nameFontSize) * scale
        let escapedName = keyboardName.xmlEscaped
        let name = "<text x=\"\(nameLeft.svgNumber)\" y=\"\(nameBaseline.svgNumber)\" font-family=\"\(ReadmeCanvas.systemFontFamily)\" font-size=\"\(nameFontSize.svgNumber)\" font-weight=\"600\" fill=\"\(theme.ink)\">\(escapedName)</text>"
        return "<g style=\"\(style)\">\(shadow)\(capsule)\(badgeMarkup)\(name)</g>"
    }
}
