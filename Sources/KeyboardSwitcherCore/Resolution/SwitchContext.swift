public struct SwitchContext: Equatable, Sendable {
    public var bundleIdentifier: String
    public var website: String?

    public init(bundleIdentifier: String, website: String? = nil) {
        self.bundleIdentifier = bundleIdentifier
        self.website = website
    }
}
