import AppKit
import SwiftUI

public struct BubbleView: View {
    private static let outlineColor = Color.primary.opacity(0.1)
    private static let shadowColor = Color.black.opacity(0.16)

    let badgeImage: NSImage
    let keyboardName: String

    public init(badgeImage: NSImage, keyboardName: String) {
        self.badgeImage = badgeImage
        self.keyboardName = keyboardName
    }

    public var body: some View {
        let capsule = Capsule(style: .circular)
        let outline = capsule.strokeBorder(Self.outlineColor, lineWidth: 0.5)

        BubbleContent(badgeImage: badgeImage, keyboardName: keyboardName)
            .background(.regularMaterial, in: capsule)
            .overlay(outline)
            .shadow(color: Self.shadowColor, radius: 9, y: 4)
            .padding(BubbleMetrics.shadowPadding)
            .accessibilityElement(children: .combine)
    }
}
