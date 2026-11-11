public enum StarterRules {
    public static let canadianKeyboardID = "com.apple.keylayout.Canadian"
    public static let canadianCSAKeyboardID = "com.apple.keylayout.Canadian-CSA"

    private static let starterAppRules = [
        AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSAKeyboardID),
        AppRule(bundleIdentifier: "com.microsoft.VSCode", appName: "Visual Studio Code", keyboardID: canadianKeyboardID),
        AppRule(bundleIdentifier: "com.mitchellh.ghostty", appName: "Ghostty", keyboardID: canadianKeyboardID),
    ]

    public static func make(availableKeyboardIDs: Set<String>) -> RulesFile {
        let usableAppRules = starterAppRules.filter { appRule in availableKeyboardIDs.contains(appRule.keyboardID) }
        return RulesFile(appRules: usableAppRules)
    }
}
