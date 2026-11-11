import AppKit
import SwiftUI

struct ReadmeHeroMenuBar: View {
    private static let height: CGFloat = 30
    private static let barColor = Color.black.opacity(0.24)
    private static let appNameFont = Font.system(size: 13, weight: .bold)
    private static let menuFont = Font.system(size: 13)
    private static let menuTitles = ["File", "Edit", "View", "Window", "Help"]

    let frontAppName: String
    let badgeImage: NSImage
    let clockText: String

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "apple.logo")
            Text(frontAppName)
                .font(Self.appNameFont)
            ForEach(Self.menuTitles, id: \.self) { menuTitle in
                Text(menuTitle)
                    .font(Self.menuFont)
            }
            Spacer()
            Image(nsImage: badgeImage)
                .renderingMode(.template)
            Image(systemName: "wifi")
            Image(systemName: "battery.75percent")
            Text(clockText)
                .font(Self.menuFont)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .frame(height: Self.height)
        .background(Self.barColor)
    }
}
