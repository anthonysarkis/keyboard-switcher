import Foundation

public enum KeyboardBadgeMaker {
    private static let dashSeparators = [" – ", " - "]
    private static let shortCodeLengths = 2...4
    private static let fallbackLetterCount = 2
    private static let disambiguatingLetterCount = 3

    public static func badge(for keyboardName: String) -> KeyboardBadge {
        if let suffix = suffixAfterDash(in: keyboardName), isShortCode(suffix) {
            return KeyboardBadge(text: suffix, style: .outlined)
        }

        let letters = keyboardName.filter(\.isLetter)
        if isShortCode(letters) {
            return KeyboardBadge(text: letters, style: .filled)
        }

        let leadingLetters = letters.prefix(fallbackLetterCount)
        let text = leadingLetters.uppercased()
        return KeyboardBadge(text: text, style: .filled)
    }

    public static func badges(for keyboards: [Keyboard]) -> [String: KeyboardBadge] {
        let proposedBadges = keyboards.map { keyboard in badge(for: keyboard.name) }
        let badgeCounts = proposedBadges.reduce(into: [KeyboardBadge: Int]()) { counts, proposedBadge in
            counts[proposedBadge, default: 0] += 1
        }

        var badges: [String: KeyboardBadge] = [:]
        for (keyboard, proposedBadge) in zip(keyboards, proposedBadges) {
            let isShared = badgeCounts[proposedBadge, default: 0] > 1
            badges[keyboard.id] = isShared ? disambiguatedBadge(for: keyboard.name, style: proposedBadge.style) : proposedBadge
        }
        return badges
    }

    private static func disambiguatedBadge(for keyboardName: String, style: KeyboardBadge.Style) -> KeyboardBadge {
        let letters = keyboardName.filter(\.isLetter)
        let leadingLetters = letters.prefix(disambiguatingLetterCount)
        let text = leadingLetters.uppercased()
        return KeyboardBadge(text: text, style: style)
    }

    private static func suffixAfterDash(in keyboardName: String) -> String? {
        for separator in dashSeparators {
            guard let separatorRange = keyboardName.range(of: separator, options: .backwards) else { continue }
            let suffix = keyboardName[separatorRange.upperBound...]
            return suffix.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private static func isShortCode(_ text: String) -> Bool {
        let hasShortCodeLength = shortCodeLengths.contains(text.count)
        let isAllCapitals = text.allSatisfy { character in character.isLetter && character.isUppercase }
        return hasShortCodeLength && isAllCapitals
    }
}
