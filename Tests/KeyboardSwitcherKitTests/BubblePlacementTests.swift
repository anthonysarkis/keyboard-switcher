import AppKit
import Testing
@testable import KeyboardSwitcherKit

struct BubblePlacementTests {
    private let bubbleSize = NSSize(width: 170, height: 52)
    private let visibleFrame = NSRect(x: 0, y: 0, width: 1440, height: 875)

    @Test func appearsJustBelowAndRightOfThePointer() {
        let pointer = NSPoint(x: 600, y: 400)

        let origin = BubblePlacement.origin(for: bubbleSize, pointer: pointer, visibleFrame: visibleFrame)

        #expect(origin == NSPoint(x: 604, y: 326))
    }

    @Test func staysOnScreenNearTheBottomRightCorner() {
        let pointer = NSPoint(x: 1435, y: 10)

        let origin = BubblePlacement.origin(for: bubbleSize, pointer: pointer, visibleFrame: visibleFrame)

        #expect(origin == NSPoint(x: 1264, y: 6))
    }
}
