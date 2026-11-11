import AppKit
import SwiftUI

public struct BubbleView: View {
    private static let outlineColor = Color.primary.opacity(0.1)
    private static let shadowColor = Color.black.opacity(0.16)
    private static let nameFont = Font.system(size: 12, weight: .semibold)

    let badgeImage: NSImage
    let keyboardName: String

    public init(badgeImage: NSImage, keyboardName: String) {
        self.badgeImage = badgeImage
        self.keyboardName = keyboardName
    }

    public var body: some View {
        let capsule = Capsule()
        let outline = capsule.strokeBorder(Self.outlineColor, lineWidth: 0.5)

        HStack(spacing: 7) {
            Image(nsImage: badgeImage)
                .renderingMode(.template)
                .accessibilityHidden(true)
            Text(keyboardName)
                .font(Self.nameFont)
        }
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .frame(height: 28)
        .background(.regularMaterial, in: capsule)
        .overlay(outline)
        .shadow(color: Self.shadowColor, radius: 9, y: 4)
        .padding(12)
        .accessibilityElement(children: .combine)
    }
}
