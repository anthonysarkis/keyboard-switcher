import Foundation

public enum WebsiteAddress {
    private static let webSchemes: Set<String> = ["http", "https"]
    private static let assumedScheme = "https://"
    private static let schemeSeparator = "://"
    private static let wwwPrefix = "www."
    private static let localhost = "localhost"

    public static func website(fromTabAddress address: String) -> String? {
        guard let components = URLComponents(string: address),
              let scheme = components.scheme?.lowercased(),
              webSchemes.contains(scheme),
              let host = components.host?.lowercased(),
              !host.isEmpty
        else { return nil }

        let hostWithoutTrailingDot = withoutTrailingDot(host)
        return withoutWWW(hostWithoutTrailingDot)
    }

    public static func website(fromTypedText text: String) -> String? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedText.contains(" ") else { return nil }

        let address = trimmedText.contains(schemeSeparator) ? trimmedText : assumedScheme + trimmedText
        guard let website = website(fromTabAddress: address), looksLikeWebsite(website) else { return nil }
        return website
    }

    private static func withoutTrailingDot(_ host: String) -> String {
        guard host.hasSuffix(".") else { return host }
        let trimmedHost = host.dropLast()
        return String(trimmedHost)
    }

    private static func withoutWWW(_ host: String) -> String {
        guard host.hasPrefix(wwwPrefix) else { return host }
        let hostAfterPrefix = host.dropFirst(wwwPrefix.count)
        return String(hostAfterPrefix)
    }

    private static func looksLikeWebsite(_ host: String) -> Bool {
        host.contains(".") || host == localhost
    }
}
