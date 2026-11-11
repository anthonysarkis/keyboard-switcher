import AppKit
import SwiftUI

struct ReadmeHero: View {
    private static let width: CGFloat = 880
    private static let height: CGFloat = 450
    private static let headlineFont = Font.system(size: 36, weight: .bold)
    private static let subheadlineFont = Font.system(size: 17, weight: .medium)
    private static let subheadlineColor = Color.white.opacity(0.85)
    private static let clockText = "Wed 9:41"
    private static let wallpaperColors = [
        Color(red: 0.10, green: 0.14, blue: 0.38),
        Color(red: 0.40, green: 0.21, blue: 0.62),
        Color(red: 0.96, green: 0.52, blue: 0.45),
    ]

    let apps: [ReadmeHeroApp]
    let badgeImages: [String: NSImage]

    var body: some View {
        let wallpaper = LinearGradient(colors: Self.wallpaperColors, startPoint: .topLeading, endPoint: .bottomTrailing)

        VStack(spacing: 0) {
            menuBar
            Spacer(minLength: 0)
            Text("Every app gets its keyboard.")
                .font(Self.headlineFont)
                .foregroundStyle(.white)
            Text("It switches the moment you change apps or tabs.")
                .font(Self.subheadlineFont)
                .foregroundStyle(Self.subheadlineColor)
                .padding(.top, 6)
            Spacer(minLength: 0)
            HStack(alignment: .top, spacing: 24) {
                ForEach(apps) { app in
                    card(for: app)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(width: Self.width, height: Self.height)
        .background(wallpaper)
    }

    @ViewBuilder
    private var menuBar: some View {
        if let frontApp = apps.first, let badgeImage = badgeImages[frontApp.keyboard.id] {
            ReadmeHeroMenuBar(frontAppName: frontApp.caption, badgeImage: badgeImage, clockText: Self.clockText)
        }
    }

    @ViewBuilder
    private func card(for app: ReadmeHeroApp) -> some View {
        if let badgeImage = badgeImages[app.keyboard.id] {
            ReadmeHeroAppCard(app: app, badgeImage: badgeImage)
        }
    }
}
