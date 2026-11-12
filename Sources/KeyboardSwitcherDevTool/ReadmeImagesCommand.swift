import AppKit
import KeyboardSwitcherKit
import KeyboardSwitcherFakes

enum ReadmeImagesCommand {
    static func run(writingTo folder: URL) throws {
        try SnapshotSetup.prepare(folder: folder)
        try ReadmeBadgeCheck.compareWithMac()
        let exampleRules = ReadmeExample.rules()
        let context = PreviewContext.make(
            keyboards: ReadmeExample.keyboards,
            rules: exampleRules,
            browserPermissions: ReadmeExample.browserPermissions
        )

        let appIcons = ReadmeExample.appIcons()
        try SettingsTabSnapshots.writeAppsTab(of: context, in: folder, appIcons: appIcons)
        try SettingsTabSnapshots.writeWebsitesTab(of: context, in: folder)
        try ReadmeAnimations.write(in: folder)
    }
}
