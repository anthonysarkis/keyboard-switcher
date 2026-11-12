import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit

enum BadgeMarkup {
    static let width = Double(BadgeMetrics.size.width)
    static let height = Double(BadgeMetrics.size.height)

    private static let baselineFromTop: Double = {
        let font = NSFont.systemFont(ofSize: BadgeMetrics.fontSize, weight: BadgeMetrics.fontWeight)
        let capitalsBaselineFromBottom = (BadgeMetrics.size.height - font.capHeight) / 2 - BadgeMetrics.capitalsDrop
        return height - Double(capitalsBaselineFromBottom)
    }()

    static func badge(_ badge: KeyboardBadge, x: Double, y: Double, scale: Double, color: String, maskID: String) -> String {
        let width = width * scale
        let height = height * scale
        let radius = Double(BadgeMetrics.cornerRadius) * scale
        let lineWidth = Double(BadgeMetrics.lineWidth) * scale
        let fontSize = Double(BadgeMetrics.fontSize) * scale
        let baseline = y + baselineFromTop * scale
        let centre = x + width / 2
        let text = badge.text.xmlEscaped
        let textAttributes = "x=\"\(centre.svgNumber)\" y=\"\(baseline.svgNumber)\" text-anchor=\"middle\" font-size=\"\(fontSize.svgNumber)\" font-weight=\"600\" font-family=\"\(ReadmeCanvas.systemFontFamily)\""
        let box = "x=\"\(x.svgNumber)\" y=\"\(y.svgNumber)\" width=\"\(width.svgNumber)\" height=\"\(height.svgNumber)\""
        switch badge.style {
        case .filled:
            let mask = "<mask id=\"\(maskID)\" maskUnits=\"userSpaceOnUse\" \(box)><rect \(box) rx=\"\(radius.svgNumber)\" fill=\"#fff\"/><text \(textAttributes) fill=\"#000\">\(text)</text></mask>"
            return "\(mask)<rect \(box) rx=\"\(radius.svgNumber)\" fill=\"\(color)\" mask=\"url(#\(maskID))\"/>"
        case .outlined:
            let inset = lineWidth / 2
            let left = x + inset
            let top = y + inset
            let innerWidth = width - lineWidth
            let innerHeight = height - lineWidth
            let innerRadius = radius - inset
            let outline = "<rect x=\"\(left.svgNumber)\" y=\"\(top.svgNumber)\" width=\"\(innerWidth.svgNumber)\" height=\"\(innerHeight.svgNumber)\" rx=\"\(innerRadius.svgNumber)\" fill=\"none\" stroke=\"\(color)\" stroke-width=\"\(lineWidth.svgNumber)\"/>"
            return "\(outline)<text \(textAttributes) fill=\"\(color)\">\(text)</text>"
        }
    }
}
