import Foundation

enum LanguageOwnNames {
    private static let englishNames = Locale(identifier: "en")
    private static let alternativeSpellingSeparator = " · "
    private static let trailingNoteInParentheses = #"\s*\([^)]*\)\s*$"#
    private static let ownNamesByCode = [
        "hmn-Hmng": "𖬌𖬣𖬵",
        "zgh-Tfng": "ⵜⴰⵎⴰⵣⵉⵖⵜ",
        "fil-Tglg": "Filipino",
    ]

    static func sortedByEnglishName() -> [String] {
        let languageCodes = KeyboardLanguageCatalog.languageCodes()
        let namedLanguages = languageCodes.map { languageCode in
            let englishName = englishNames.localizedString(forIdentifier: languageCode) ?? languageCode
            let sortKey = englishName.lowercased()
            let ownName = ownName(forCode: languageCode, englishName: englishName)
            return (sortKey: sortKey, code: languageCode, ownName: ownName)
        }
        let orderedLanguages = namedLanguages.sorted { first, second in
            if first.sortKey != second.sortKey {
                return first.sortKey < second.sortKey
            }
            return first.code < second.code
        }
        return orderedLanguages.map(\.ownName)
    }

    private static func ownName(forCode languageCode: String, englishName: String) -> String {
        if let ownName = ownNamesByCode[languageCode] {
            return ownName
        }
        let ownLocale = Locale(identifier: languageCode)
        let endonym = ownLocale.localizedString(forIdentifier: languageCode) ?? ""
        let fullName = endonym.isEmpty ? englishName : endonym
        let firstSpelling = fullName.components(separatedBy: alternativeSpellingSeparator).first ?? fullName
        let withoutNote = firstSpelling.replacingOccurrences(of: trailingNoteInParentheses, with: "", options: .regularExpression)
        return withoutNote.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
