import AppKit
import SwiftUI

public struct BubbleContent: View {
    private static let nameFont = Font.system(size: BubbleMetrics.nameFontSize, weight: .semibold)

    let badgeImage: NSImage
    let keyboardName: String

    public init(badgeImage: NSImage, keyboardName: String) {
        self.badgeImage = badgeImage
        self.keyboardName = keyboardName
    }

    public var body: some View {
        HStack(spacing: BubbleMetrics.badgeToNameSpacing) {
            Image(nsImage: badgeImage)
                .renderingMode(.template)
                .accessibilityHidden(true)
            Text(keyboardName)
                .font(Self.nameFont)
        }
        .padding(.leading, BubbleMetrics.leadingPadding)
        .padding(.trailing, BubbleMetrics.trailingPadding)
        .frame(height: BubbleMetrics.height)
    }
}
