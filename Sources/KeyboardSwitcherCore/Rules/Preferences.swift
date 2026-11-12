public struct Preferences: Codable, Hashable, Sendable {
    public var showBubble: Bool
    public var remembersManualSwitches: Bool

    public init(showBubble: Bool = false, remembersManualSwitches: Bool = true) {
        self.showBubble = showBubble
        self.remembersManualSwitches = remembersManualSwitches
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Preferences()
        showBubble = try container.decodeIfPresent(Bool.self, forKey: .showBubble) ?? defaults.showBubble
        remembersManualSwitches = try container.decodeIfPresent(Bool.self, forKey: .remembersManualSwitches) ?? defaults.remembersManualSwitches
    }
}
