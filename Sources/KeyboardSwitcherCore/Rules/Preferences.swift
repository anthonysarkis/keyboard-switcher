public struct Preferences: Codable, Hashable, Sendable {
    public var showBubble: Bool
    public var appsRemembering: RememberingMode
    public var websitesRemembering: RememberingMode

    public init(
        showBubble: Bool = false,
        appsRemembering: RememberingMode = .everyOne,
        websitesRemembering: RememberingMode = .switchedByHand
    ) {
        self.showBubble = showBubble
        self.appsRemembering = appsRemembering
        self.websitesRemembering = websitesRemembering
    }

    private enum CodingKeys: String, CodingKey {
        case showBubble
        case appsRemembering
        case websitesRemembering
    }

    private enum EarlierCodingKeys: String, CodingKey {
        case remembersManualSwitches
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let earlierContainer = try decoder.container(keyedBy: EarlierCodingKeys.self)
        let earlierRemembering = try earlierContainer.decodeIfPresent(Bool.self, forKey: .remembersManualSwitches)
        let startingPoint = earlierRemembering == false
            ? Preferences(appsRemembering: .addedByYou, websitesRemembering: .addedByYou)
            : Preferences()
        showBubble = try container.decodeIfPresent(Bool.self, forKey: .showBubble) ?? startingPoint.showBubble
        appsRemembering = try Self.mode(in: container, forKey: .appsRemembering) ?? startingPoint.appsRemembering
        websitesRemembering = try Self.mode(in: container, forKey: .websitesRemembering) ?? startingPoint.websitesRemembering
    }

    private static func mode(in container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> RememberingMode? {
        let storedMode = try container.decodeIfPresent(String.self, forKey: key)
        return storedMode.flatMap { rawValue in RememberingMode(rawValue: rawValue) }
    }
}
