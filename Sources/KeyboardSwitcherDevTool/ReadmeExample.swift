import AppKit
import KeyboardSwitcherCore
import KeyboardSwitcherKit

enum ReadmeExample {
    static let english = Keyboard(id: "com.apple.keylayout.US", name: "U.S.")
    static let spanish = Keyboard(id: "com.apple.keylayout.Spanish-ISO", name: "Spanish")
    static let french = Keyboard(id: "com.apple.keylayout.French", name: "French")
    static let russian = Keyboard(id: "com.apple.keylayout.Russian", name: "Russian")
    static let keyboards = [english, spanish, french, russian]

    static let macBadges: [String: KeyboardBadge] = [
        english.id: KeyboardBadge(text: "US", style: .outlined),
        spanish.id: KeyboardBadge(text: "ES", style: .outlined),
        french.id: KeyboardBadge(text: "FR", style: .outlined),
        russian.id: KeyboardBadge(text: "РУ", style: .filled),
    ]

    static let browserPermissions: [String: BrowserPermission] = [
        "com.google.Chrome": .allowed,
        "com.apple.Safari": .allowed,
        "com.brave.Browser": .asksFirstTime,
    ]

    static let apps = [
        ReadmeExampleApp(
            appName: "Visual Studio Code", menuTitle: "Code", bundleIdentifier: "com.microsoft.VSCode", iconName: "vscode",
            keyboard: english, typedText: "print(\"Hello, world!\")", typedFont: .monospaced(size: 19)
        ),
        ReadmeExampleApp(
            appName: "WhatsApp", menuTitle: "WhatsApp", bundleIdentifier: "net.whatsapp.WhatsApp", iconName: "whatsapp",
            keyboard: french, typedText: "Génial, j'arrive à 18 h.", typedFont: .system(size: 21)
        ),
        ReadmeExampleApp(
            appName: "Microsoft Teams", menuTitle: "Microsoft Teams", bundleIdentifier: "com.microsoft.teams2", iconName: "teams",
            keyboard: spanish, typedText: "¡Hola! ¿Mañana a las 10?", typedFont: .system(size: 21)
        ),
        ReadmeExampleApp(
            appName: "Claude", menuTitle: "Claude", bundleIdentifier: "com.anthropic.claudefordesktop", iconName: "claude",
            keyboard: russian, typedText: "Привет! Можешь помочь?", typedFont: .system(size: 21)
        ),
    ]

    static let websites = [
        ReadmeExampleWebsite(title: "Microsoft Teams", host: "teams.microsoft.com", iconName: "teams", keyboard: spanish),
        ReadmeExampleWebsite(title: "WhatsApp", host: "web.whatsapp.com", iconName: "whatsapp", keyboard: french),
        ReadmeExampleWebsite(title: "Claude", host: "claude.ai", iconName: "claude", keyboard: russian),
    ]

    static let heroDescription = "Keyboard Switcher in action: switching from VS Code to WhatsApp, Teams and Claude turns the keyboard into U.S., French, Spanish and Russian, and each message types right the first time."
    static let websitesDescription = "In Chrome, clicking the teams.microsoft.com, web.whatsapp.com and claude.ai tabs turns the keyboard into Spanish, French and Russian."

    static func macBadge(for keyboard: Keyboard) -> KeyboardBadge {
        guard let badge = macBadges[keyboard.id] else {
            preconditionFailure("ReadmeExample.macBadges has no badge for \(keyboard.name)")
        }
        return badge
    }

    static func appIcons() -> [String: NSImage] {
        var appIcons: [String: NSImage] = [:]
        for app in apps {
            appIcons[app.bundleIdentifier] = app.icon
        }
        return appIcons
    }

    static func rules() -> RulesFile {
        var rules = RulesFile()
        for app in apps {
            rules.setAppRule(bundleIdentifier: app.bundleIdentifier, appName: app.appName, keyboardID: app.keyboard.id)
        }
        for website in websites {
            rules.setWebsiteRule(website: website.host, keyboardID: website.keyboard.id)
        }
        return rules
    }
}
