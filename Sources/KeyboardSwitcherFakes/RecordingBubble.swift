import AppKit
import KeyboardSwitcherKit

public final class RecordingBubble: BubblePresenting {
    public private(set) var shownKeyboardNames: [String] = []
    public private(set) var shownBadgeImages: [NSImage] = []

    public init() {}

    public func showBubble(badgeImage: NSImage, keyboardName: String) {
        shownKeyboardNames.append(keyboardName)
        shownBadgeImages.append(badgeImage)
    }
}
