import AppKit

public enum BadgeMetrics {
    public static let size = NSSize(width: 22, height: 16)
    public static let cornerRadius: CGFloat = 5
    public static let lineWidth: CGFloat = 1
    static let horizontalPadding: CGFloat = 1.5
    public static let capitalsDrop: CGFloat = 0.5
    public static let fontSize: CGFloat = 11
    public static let fontWeight = NSFont.Weight.semibold
    static let narrowFontWidth = 65
    static let narrowFontOpticalSize = 16

    static var textWidthLimit: CGFloat {
        size.width - horizontalPadding * 2
    }
}
