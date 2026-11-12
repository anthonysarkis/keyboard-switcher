import AppKit
import SwiftUI
import KeyboardSwitcherKit

struct ReadmeHeroAppCard: View {
    private static let width: CGFloat = 228
    private static let iconSize: CGFloat = 64
    private static let captionFont = Font.system(size: 15, weight: .semibold)
    private static let captionColor = Color.black.opacity(0.85)
    private static let cardColor = Color.white.opacity(0.95)
    private static let shadowColor = Color.black.opacity(0.28)

    let app: ReadmeHeroApp
    let badgeImage: NSImage

    var body: some View {
        let card = RoundedRectangle(cornerRadius: 22, style: .continuous)

        VStack(spacing: 4) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
            Text(app.caption)
                .font(Self.captionFont)
                .foregroundStyle(Self.captionColor)
            ReadmeHeroBubble(badgeImage: badgeImage, keyboardName: app.keyboard.name)
                .padding(.top, 10)
        }
        .padding(.vertical, 22)
        .frame(width: Self.width)
        .background(Self.cardColor, in: card)
        .shadow(color: Self.shadowColor, radius: 24, y: 12)
    }
}
