import Carbon
import Foundation

enum KeyboardLanguageCatalog {
    private static let englishNames = Locale(identifier: "en")

    static func installedKeyboardCount() -> Int {
        installedKeyboards().count
    }

    static func languages() -> [KeyboardLanguage] {
        let installedLanguageCodes = languageCodes()
        let languages = installedLanguageCodes.compactMap(language(forCode:))
        return languages.sorted { first, second in first.name.localizedStandardCompare(second.name) == .orderedAscending }
    }

    static func languageCodes() -> [String] {
        var languageCodes: Set<String> = []
        for keyboard in installedKeyboards() {
            guard let languageCode = mainLanguageCode(of: keyboard) else { continue }
            languageCodes.insert(languageCode)
        }
        return languageCodes.sorted()
    }

    private static func installedKeyboards() -> [TISInputSource] {
        let selectableKeyboardsFilter = [
            kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String,
            kTISPropertyInputSourceIsSelectCapable as String: true,
        ] as CFDictionary
        let sourceList = TISCreateInputSourceList(selectableKeyboardsFilter, true)?.takeRetainedValue()
        return sourceList as? [TISInputSource] ?? []
    }

    private static func mainLanguageCode(of keyboard: TISInputSource) -> String? {
        guard let rawValue = TISGetInputSourceProperty(keyboard, kTISPropertyInputSourceLanguages) else { return nil }
        let languageCodes = Unmanaged<CFArray>.fromOpaque(rawValue).takeUnretainedValue() as? [String]
        guard let mainLanguageCode = languageCodes?.first, !mainLanguageCode.isEmpty else { return nil }
        return mainLanguageCode
    }

    private static func language(forCode languageCode: String) -> KeyboardLanguage? {
        guard let fullName = englishNames.localizedString(forIdentifier: languageCode) else { return nil }
        let name = withoutRepeatedScript(fullName)
        let flag = LanguageFlag.emoji(forLanguageCode: languageCode)
        return KeyboardLanguage(name: name, flag: flag)
    }

    private static func withoutRepeatedScript(_ name: String) -> String {
        guard let openingParenthesis = name.firstIndex(of: "("), name.hasSuffix(")") else { return name }
        let baseName = name[..<openingParenthesis].trimmingCharacters(in: .whitespaces)
        let scriptStart = name.index(after: openingParenthesis)
        let scriptEnd = name.index(before: name.endIndex)
        let scriptName = name[scriptStart..<scriptEnd]
        return baseName == scriptName ? baseName : name
    }
}
