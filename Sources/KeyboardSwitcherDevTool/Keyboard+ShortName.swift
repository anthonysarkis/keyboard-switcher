import KeyboardSwitcherCore

extension Keyboard {
    var shortName: String {
        let identifierParts = id.split(separator: ".")
        let lastPart = identifierParts.last.map(String.init)
        return lastPart ?? id
    }
}
