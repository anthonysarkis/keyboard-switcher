import Foundation

public final class TextInputMenuIcon: MacKeyboardIconControlling {
    private let preferencesDomain = "com.apple.TextInputMenu" as CFString
    private let visibleKey = "visible" as CFString
    private let menuAgentName = "TextInputMenuAgent"
    private let killallPath = "/usr/bin/killall"

    public init() {}

    public var isShown: Bool {
        CFPreferencesAppSynchronize(preferencesDomain)
        let storedValue = CFPreferencesCopyAppValue(visibleKey, preferencesDomain)
        return (storedValue as? Bool) ?? true
    }

    public func setShown(_ shown: Bool) {
        let visibleValue = shown ? kCFBooleanTrue : kCFBooleanFalse
        CFPreferencesSetAppValue(visibleKey, visibleValue, preferencesDomain)
        CFPreferencesAppSynchronize(preferencesDomain)
        restartMenuAgentSoItRereadsTheSetting()
    }

    private func restartMenuAgentSoItRereadsTheSetting() {
        let killall = Process()
        killall.executableURL = URL(fileURLWithPath: killallPath)
        killall.arguments = [menuAgentName]
        try? killall.run()
    }
}
