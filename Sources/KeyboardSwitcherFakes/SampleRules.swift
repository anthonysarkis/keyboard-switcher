import KeyboardSwitcherCore

public enum SampleRules {
    public static func make() -> RulesFile {
        RulesFile(appRules: [
            AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: SampleKeyboards.canadianCSA.id),
            AppRule(bundleIdentifier: "com.microsoft.VSCode", appName: "Visual Studio Code", keyboardID: SampleKeyboards.canadian.id),
            AppRule(bundleIdentifier: "com.mitchellh.ghostty", appName: "Ghostty", keyboardID: SampleKeyboards.canadian.id),
        ])
    }
}
