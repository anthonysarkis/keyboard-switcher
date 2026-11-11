import AppKit

public protocol BubblePresenting: AnyObject {
    func showBubble(badgeImage: NSImage, keyboardName: String)
}
