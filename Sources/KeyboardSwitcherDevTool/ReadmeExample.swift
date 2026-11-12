import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit

enum ReadmeExample {
    static let english = Keyboard(id: "com.apple.keylayout.US", name: "U.S.")
    static let spanish = Keyboard(id: "com.apple.keylayout.Spanish-ISO", name: "Spanish")
    static let french = Keyboard(id: "com.apple.keylayout.French", name: "French")
    static let russian = Keyboard(id: "com.apple.keylayout.Russian", name: "Russian")
    static let keyboards = [english, spanish, french, russian]

    static let browserPermissions: [String: BrowserPermission] = [
        "com.google.Chrome": .allowed,
        "com.apple.Safari": .allowed,
        "com.brave.Browser": .asksFirstTime,
    ]

    static let heroApps = [
        ReadmeHeroApp(caption: "Teams", appName: "Microsoft Teams", bundleIdentifier: "com.microsoft.teams2", iconName: "teams", keyboard: spanish),
        ReadmeHeroApp(caption: "WhatsApp", appName: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", iconName: "whatsapp", keyboard: french),
        ReadmeHeroApp(caption: "VS Code", appName: "Visual Studio Code", bundleIdentifier: "com.microsoft.VSCode", iconName: "vscode", keyboard: english),
        ReadmeHeroApp(caption: "Claude Code", appName: "Claude", bundleIdentifier: "com.anthropic.claudefordesktop", iconName: "claude", keyboard: russian),
    ]

    static func appIcons() -> [String: NSImage] {
        var appIcons: [String: NSImage] = [:]
        for heroApp in heroApps {
            appIcons[heroApp.bundleIdentifier] = heroApp.icon
        }
        return appIcons
    }

    static func rules() -> RulesFile {
        var rules = RulesFile()
        for heroApp in heroApps {
            rules.setAppRule(bundleIdentifier: heroApp.bundleIdentifier, appName: heroApp.appName, keyboardID: heroApp.keyboard.id)
        }
        rules.setWebsiteRule(website: "teams.microsoft.com", keyboardID: spanish.id)
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: french.id)
        rules.setWebsiteRule(website: "claude.ai", keyboardID: russian.id)
        return rules
    }
}
