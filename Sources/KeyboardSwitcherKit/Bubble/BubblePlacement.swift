import AppKit

enum BubblePlacement {
    private static let offsetFromPointer = NSSize(width: 4, height: 22)
    private static let screenMargin: CGFloat = 6

    static func origin(for bubbleSize: NSSize, pointer: NSPoint, visibleFrame: NSRect) -> NSPoint {
        let preferredLeftEdge = pointer.x + offsetFromPointer.width
        let preferredBottomEdge = pointer.y - offsetFromPointer.height - bubbleSize.height
        let lowestLeftEdge = visibleFrame.minX + screenMargin
        let highestLeftEdge = visibleFrame.maxX - bubbleSize.width - screenMargin
        let lowestBottomEdge = visibleFrame.minY + screenMargin
        let highestBottomEdge = visibleFrame.maxY - bubbleSize.height - screenMargin

        let leftEdge = clamp(preferredLeftEdge, lowest: lowestLeftEdge, highest: highestLeftEdge)
        let bottomEdge = clamp(preferredBottomEdge, lowest: lowestBottomEdge, highest: highestBottomEdge)
        return NSPoint(x: leftEdge, y: bottomEdge)
    }

    private static func clamp(_ value: CGFloat, lowest: CGFloat, highest: CGFloat) -> CGFloat {
        let atLeastLowest = max(value, lowest)
        return min(atLeastLowest, highest)
    }
}
