import AppKit

enum BadgeMetrics {
    static let size = NSSize(width: 22, height: 16)
    static let cornerRadius: CGFloat = 5
    static let lineWidth: CGFloat = 1
    static let horizontalPadding: CGFloat = 1.5
    static let capitalsDrop: CGFloat = 0.5
    static let fontSize: CGFloat = 11
    static let fontWeight = NSFont.Weight.semibold
    static let narrowFontWidth = 65
    static let narrowFontOpticalSize = 16

    static var textWidthLimit: CGFloat {
        size.width - horizontalPadding * 2
    }
}
