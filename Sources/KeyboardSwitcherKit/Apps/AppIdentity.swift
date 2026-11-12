public struct AppIdentity: Equatable, Sendable, Identifiable {
    public let bundleIdentifier: String
    public let name: String
    public let isRegularApp: Bool

    public var id: String { bundleIdentifier }

    public init(bundleIdentifier: String, name: String, isRegularApp: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.isRegularApp = isRegularApp
    }
}
