public struct KeyboardDecision: Equatable, Sendable {
    public var keyboardID: String
    public var source: DecisionSource

    public init(keyboardID: String, source: DecisionSource) {
        self.keyboardID = keyboardID
        self.source = source
    }
}
