public struct AppRule: Codable, Hashable, Sendable, Identifiable {
    public var bundleIdentifier: String
    public var appName: String
    public var keyboardID: String

    public var id: String { bundleIdentifier }

    public init(bundleIdentifier: String, appName: String, keyboardID: String) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.keyboardID = keyboardID
    }
}
