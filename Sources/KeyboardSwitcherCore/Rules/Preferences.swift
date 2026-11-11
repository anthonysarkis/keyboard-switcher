public struct Preferences: Codable, Hashable, Sendable {
    public var showBubble: Bool
    public var otherApps: OtherAppsBehavior
    public var manualSwitch: ManualSwitchBehavior

    public init(
        showBubble: Bool = true,
        otherApps: OtherAppsBehavior = .lastUsed,
        manualSwitch: ManualSwitchBehavior = .backToRule
    ) {
        self.showBubble = showBubble
        self.otherApps = otherApps
        self.manualSwitch = manualSwitch
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = Preferences()
        showBubble = try container.decodeIfPresent(Bool.self, forKey: .showBubble) ?? defaults.showBubble
        otherApps = try container.decodeIfPresent(OtherAppsBehavior.self, forKey: .otherApps) ?? defaults.otherApps
        manualSwitch = try container.decodeIfPresent(ManualSwitchBehavior.self, forKey: .manualSwitch) ?? defaults.manualSwitch
    }
}
