import Foundation
import LinkPresentation
import UniformTypeIdentifiers
import KeyboardSwitcherCore

// Asks the website itself, the way Messages builds link previews; no icon service ever sees the list.
public final class LinkPresentationIconFetcher: WebsiteIconFetching {
    private static let timeout: TimeInterval = 15

    public init() {}

    public func iconData(for website: String) async -> Data? {
        guard let homePage = WebsiteAddress.homePage(of: website) else { return nil }
        let provider = LPMetadataProvider()
        provider.timeout = Self.timeout
        guard let metadata = try? await provider.startFetchingMetadata(for: homePage),
              let iconProvider = metadata.iconProvider
        else { return nil }
        return await Self.imageData(from: iconProvider)
    }

    // LinkPresentation answers on a background queue, so this closure must not inherit the main actor.
    private nonisolated static func imageData(from iconProvider: NSItemProvider) async -> Data? {
        await withCheckedContinuation { continuation in
            _ = iconProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { @Sendable imageData, _ in
                continuation.resume(returning: imageData)
            }
        }
    }
}
