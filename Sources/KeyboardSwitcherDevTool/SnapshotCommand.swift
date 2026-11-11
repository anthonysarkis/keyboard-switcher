import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit
import KeyboardSwitcherFakes

enum SnapshotCommand {
    private static let wideBadge = KeyboardBadge(text: "WXYZ", style: .outlined)

    static func run(writingTo folder: URL) throws {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let context = PreviewContext.make()

        let appsTab = AppsTab(
            ruleBook: context.ruleBook,
            catalog: context.catalog,
            ownBundleIdentifier: context.coordinator.ownBundleIdentifier
        )
        let websitesTab = WebsitesTab(ruleBook: context.ruleBook, catalog: context.catalog, tabTracker: context.tabTracker)
        let generalTab = GeneralTab(ruleBook: context.ruleBook, systemToggles: context.systemToggles)

        try ViewSnapshotter.write(appsTab, named: "settings-apps", in: folder)
        try ViewSnapshotter.write(websitesTab, named: "settings-websites", in: folder)
        try ViewSnapshotter.write(generalTab, named: "settings-general", in: folder)
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
