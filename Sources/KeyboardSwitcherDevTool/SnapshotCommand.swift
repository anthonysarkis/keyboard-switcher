import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit
import KeyboardSwitcherFakes

enum SnapshotCommand {
    private static let wideBadge = KeyboardBadge(text: "WXYZ", style: .outlined)

    static func run(writingTo folder: URL) throws {
        try SnapshotSetup.prepare(folder: folder)
        let context = PreviewContext.make()

        try SettingsTabSnapshots.writeAppsTab(of: context, in: folder)
        let websiteIcons = ReadmeExample.websiteIcons()
        try SettingsTabSnapshots.writeWebsitesTab(of: context, in: folder, websiteIcons: websiteIcons)
        try SettingsTabSnapshots.writeGeneralTab(of: context, in: folder)
        try writeBadgesAndBubbles(in: folder)
    }

    private static func writeBadgesAndBubbles(in folder: URL) throws {
        let keyboards = SampleKeyboards.both
        let drawnBadgeImages = DrawnBadgeImages()
        let drawnImages = drawnBadgeImages.badgeImages(for: keyboards)
        let macBadgeImages = MacBadgeImages()
        let macImages = macBadgeImages?.badgeImages(for: keyboards) ?? [:]

        for keyboard in keyboards {
            let shortName = keyboard.shortName
            if let macImage = macImages[keyboard.id] {
                try BadgeSnapshotter.write(macImage, named: "badge-mac-\(shortName)", in: folder)
            }
            if let drawnImage = drawnImages[keyboard.id] {
                try BadgeSnapshotter.write(drawnImage, named: "badge-drawn-\(shortName)", in: folder)
            }
            guard let bubbleBadgeImage = macImages[keyboard.id] ?? drawnImages[keyboard.id] else { continue }
            let bubble = BubbleView(badgeImage: bubbleBadgeImage, keyboardName: keyboard.name)
            try ViewSnapshotter.write(bubble, named: "bubble-\(shortName)", in: folder)
        }

        let wideImage = BadgeImage.make(for: wideBadge)
        try BadgeSnapshotter.write(wideImage, named: "badge-drawn-\(wideBadge.text)", in: folder)
    }
}
