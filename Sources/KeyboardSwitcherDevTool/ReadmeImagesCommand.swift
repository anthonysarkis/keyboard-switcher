import AppKit
import KeyboardSwitcherKit
import KeyboardSwitcherFakes

enum ReadmeImagesCommand {
    private static let heroApps = [
        ReadmeHeroApp(caption: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", keyboard: SampleKeyboards.canadianCSA),
        ReadmeHeroApp(caption: "VS Code", bundleIdentifier: "com.microsoft.VSCode", keyboard: SampleKeyboards.canadian),
        ReadmeHeroApp(caption: "claude.ai in Chrome", bundleIdentifier: "com.google.Chrome", keyboard: SampleKeyboards.canadian),
    ]

    static func run(writingTo folder: URL) throws {
        try SnapshotSetup.prepare(folder: folder)
        let context = PreviewContext.make()

        let badgeImages = sampleBadgeImages()
        let hero = ReadmeHero(apps: heroApps, badgeImages: badgeImages)
        try ViewSnapshotter.write(hero, named: "hero", in: folder)
        try SettingsTabSnapshots.writeAppsTab(of: context, in: folder)
        try SettingsTabSnapshots.writeWebsitesTab(of: context, in: folder)
    }

    private static func sampleBadgeImages() -> [String: NSImage] {
        let macBadgeImages = MacBadgeImages()
        let drawnBadgeImages = DrawnBadgeImages()
        let badgeImages = BadgeImagesWithFallback(preferred: macBadgeImages, fallback: drawnBadgeImages)
        return badgeImages.badgeImages(for: SampleKeyboards.both)
    }
}
