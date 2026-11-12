import Foundation

enum LanguageFlag {
    private static let worldSymbol = "🌐"
    private static let regionalIndicatorOffset: UInt32 = 127_397
    private static let countryCodeLength = 2
    private static let welshFlag = "🏴\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}"
    private static let languagesSpokenAcrossBorders: Set<String> = ["ku", "ckb", "ug", "bo", "rhg", "syr", "yi", "hmn"]

    static func emoji(forLanguageCode languageCode: String) -> String {
        let language = Locale.Language(identifier: languageCode)
        let baseLanguageCode = language.languageCode?.identifier ?? languageCode
        if baseLanguageCode == "cy" {
            return welshFlag
        }
        if languagesSpokenAcrossBorders.contains(baseLanguageCode) {
            return worldSymbol
        }
        let likelyLanguage = Locale.Language(identifier: language.maximalIdentifier)
        guard let countryCode = likelyLanguage.region?.identifier, isCountry(countryCode) else { return worldSymbol }
        return flag(forCountryCode: countryCode)
    }

    private static func isCountry(_ regionCode: String) -> Bool {
        let hasCountryLength = regionCode.count == countryCodeLength
        let isLetters = regionCode.allSatisfy(\.isLetter)
        return hasCountryLength && isLetters
    }

    private static func flag(forCountryCode countryCode: String) -> String {
        var flag = ""
        for letter in countryCode.unicodeScalars {
            let indicatorValue = letter.value + regionalIndicatorOffset
            guard let indicator = UnicodeScalar(indicatorValue) else { return worldSymbol }
            flag.unicodeScalars.append(indicator)
        }
        return flag
    }
}
