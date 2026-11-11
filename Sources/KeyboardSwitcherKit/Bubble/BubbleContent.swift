import AppKit
import SwiftUI

public struct BubbleContent: View {
    public static let height: CGFloat = 28
    private static let nameFont = Font.system(size: 12, weight: .semibold)

    let badgeImage: NSImage
    let keyboardName: String

    public init(badgeImage: NSImage, keyboardName: String) {
        self.badgeImage = badgeImage
        self.keyboardName = keyboardName
    }

    public var body: some View {
        HStack(spacing: 7) {
            Image(nsImage: badgeImage)
                .renderingMode(.template)
                .accessibilityHidden(true)
            Text(keyboardName)
                .font(Self.nameFont)
        }
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .frame(height: Self.height)
    }
}
