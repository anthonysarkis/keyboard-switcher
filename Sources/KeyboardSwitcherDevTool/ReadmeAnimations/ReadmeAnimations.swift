import Foundation

enum ReadmeAnimations {
    static func write(in folder: URL) throws {
        let apps = ReadmeExample.apps
        let layouts = try apps.map { app in try KeyboardLayoutKeys.read(layoutID: app.keyboard.id) }
        for theme in AnimationTheme.both {
            let hero = try HeroScene.picture(apps: apps, layouts: layouts, theme: theme)
            try write(hero, in: folder)
            let websites = try WebsitesScene.picture(websites: ReadmeExample.websites, theme: theme)
            try write(websites, in: folder)
        }
        let languageNames = LanguageOwnNames.sortedByEnglishName()
        for theme in LanguagesTheme.both {
            let languages = try LanguagesScene.picture(names: languageNames, theme: theme)
            try write(languages, in: folder)
        }
    }

    private static func write(_ picture: AnimatedPicture, in folder: URL) throws {
        let fileURL = folder.appending(path: picture.fileName)
        try picture.markup.write(to: fileURL, atomically: true, encoding: .utf8)
        let byteCount = picture.markup.utf8.count
        let kilobytes = (Double(byteCount) / 1024).rounded()
        let wholeKilobytes = Int(kilobytes)
        let width = Int(picture.width)
        let height = Int(picture.height)
        let loopSeconds = String(format: "%.2f", picture.loopSeconds)
        print("\(picture.fileName): \(wholeKilobytes) KB, \(width) × \(height) points, loops every \(loopSeconds) s")
    }
}
