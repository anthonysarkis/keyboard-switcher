public struct SupportedBrowser: Hashable, Sendable, Identifiable {
    public enum Family: Sendable {
        case chromium
        case safari
    }

    public static let all = [
        SupportedBrowser(bundleIdentifier: "com.google.Chrome", name: "Google Chrome", family: .chromium),
        SupportedBrowser(bundleIdentifier: "com.brave.Browser", name: "Brave Browser", family: .chromium),
        SupportedBrowser(bundleIdentifier: "com.apple.Safari", name: "Safari", family: .safari),
    ]

    public let bundleIdentifier: String
    public let name: String
    public let family: Family

    public var id: String { bundleIdentifier }

    public static func browser(bundleIdentifier: String) -> SupportedBrowser? {
        all.first { browser in browser.bundleIdentifier == bundleIdentifier }
    }
}
