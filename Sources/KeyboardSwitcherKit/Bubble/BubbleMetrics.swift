import AppKit

public enum BubbleMetrics {
    public static let height: CGFloat = 28
    public static let leadingPadding: CGFloat = 8
    public static let badgeToNameSpacing: CGFloat = 7
    public static let trailingPadding: CGFloat = 12
    public static let nameFontSize: CGFloat = 12
    public static let shadowPadding: CGFloat = 12
    public static let offsetFromPointer = NSSize(width: 4, height: 22)
    public static let visibleDuration: Duration = .milliseconds(1200)
    public static let fadeInDuration: TimeInterval = 0.12
    public static let fadeOutDuration: TimeInterval = 0.25
}
