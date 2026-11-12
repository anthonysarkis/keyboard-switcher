import AppKit
import SwiftUI
import KeyboardSwitcherKit

struct ReadmeHeroBubble: View {
    private static let fillColor = Color(white: 0.96)
    private static let textColor = Color.black.opacity(0.85)
    private static let outlineColor = Color.black.opacity(0.1)
    private static let shadowColor = Color.black.opacity(0.12)

    let badgeImage: NSImage
    let keyboardName: String

    var body: some View {
        let capsule = Capsule(style: .circular)
        let outline = capsule.strokeBorder(Self.outlineColor, lineWidth: 0.5)

        BubbleContent(badgeImage: badgeImage, keyboardName: keyboardName)
            .foregroundStyle(Self.textColor)
            .background(Self.fillColor, in: capsule)
            .overlay(outline)
            .shadow(color: Self.shadowColor, radius: 6, y: 3)
    }
}
