enum ReadmeAnimationError: Error, CustomStringConvertible {
    case missingKeyboardLayout(String)
    case untypableCharacter(String, layoutID: String)
    case missingAppIcon(String)
    case couldNotDrawLanguageRow(Int)
    case badgeDiffersFromMac(keyboardName: String, differingPixels: Int, pixelCount: Int)

    var description: String {
        switch self {
        case .missingKeyboardLayout(let layoutID):
            return "macOS has no keyboard layout \(layoutID)"
        case .untypableCharacter(let character, let layoutID):
            return "\(character) can't be typed on \(layoutID)"
        case .missingAppIcon(let path):
            return "No app icon at \(path)"
        case .couldNotDrawLanguageRow(let rowIndex):
            return "Could not draw language row \(rowIndex)"
        case .badgeDiffersFromMac(let keyboardName, let differingPixels, let pixelCount):
            return "The README badge for \(keyboardName) differs from macOS's own (\(differingPixels) of \(pixelCount) pixels): fix ReadmeExample.macBadges"
        }
    }
}
