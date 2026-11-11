public struct RulesFile: Codable, Hashable, Sendable {
    public static let currentVersion = 1

    public var version: Int
    public var appRules: [AppRule]
    public var websiteRules: [WebsiteRule]
    public var lastUsedByApp: [String: String]
    public var preferences: Preferences

    public init(
        appRules: [AppRule] = [],
        websiteRules: [WebsiteRule] = [],
        lastUsedByApp: [String: String] = [:],
        preferences: Preferences = Preferences()
    ) {
        self.version = RulesFile.currentVersion
        self.appRules = appRules
        self.websiteRules = websiteRules
        self.lastUsedByApp = lastUsedByApp
        self.preferences = preferences
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? RulesFile.currentVersion
        appRules = try container.decodeIfPresent([AppRule].self, forKey: .appRules) ?? []
        websiteRules = try container.decodeIfPresent([WebsiteRule].self, forKey: .websiteRules) ?? []
        lastUsedByApp = try container.decodeIfPresent([String: String].self, forKey: .lastUsedByApp) ?? [:]
        preferences = try container.decodeIfPresent(Preferences.self, forKey: .preferences) ?? Preferences()
    }
}
