import AppKit
import KeyboardSwitcherKit
import KeyboardSwitcherFakes

enum ReadmeImagesCommand {
    static func run(writingTo folder: URL) throws {
        try SnapshotSetup.prepare(folder: folder)
        let exampleRules = ReadmeExample.rules()
        let context = PreviewContext.make(
            keyboards: ReadmeExample.keyboards,
            rules: exampleRules,
            browserPermissions: ReadmeExample.browserPermissions
        )

        let badgeImages = exampleBadgeImages()
        let hero = ReadmeHero(apps: ReadmeExample.heroApps, badgeImages: badgeImages)
        try ViewSnapshotter.write(hero, named: "hero", in: folder)
        let appIcons = ReadmeExample.appIcons()
        try SettingsTabSnapshots.writeAppsTab(of: context, in: folder, appIcons: appIcons)
        try SettingsTabSnapshots.writeWebsitesTab(of: context, in: folder)
    }

    private static func exampleBadgeImages() -> [String: NSImage] {
        let macBadgeImages = MacBadgeImages()
        let drawnBadgeImages = DrawnBadgeImages()
        let badgeImages = BadgeImagesWithFallback(preferred: macBadgeImages, fallback: drawnBadgeImages)
        return badgeImages.badgeImages(for: ReadmeExample.keyboards)
    }
}
