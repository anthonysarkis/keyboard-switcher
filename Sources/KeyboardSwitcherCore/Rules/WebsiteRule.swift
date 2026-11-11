public struct WebsiteRule: Codable, Hashable, Sendable, Identifiable {
    public var website: String
    public var keyboardID: String

    public var id: String { website }

    public init(website: String, keyboardID: String) {
        self.website = website
        self.keyboardID = keyboardID
    }
}
