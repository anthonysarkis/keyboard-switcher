public struct KeyboardBadge: Hashable, Sendable {
    public enum Style: Hashable, Sendable {
        case filled
        case outlined
    }

    public let text: String
    public let style: Style

    public init(text: String, style: Style) {
        self.text = text
        self.style = style
    }
}
