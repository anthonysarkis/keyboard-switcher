import AppKit

public struct WebsiteIcon {
    public let image: NSImage
    public let fillsShape: Bool

    init?(prepared: PreparedWebsiteIcon) {
        guard let image = NSImage(data: prepared.displayPNGData) else { return nil }
        self.image = image
        self.fillsShape = prepared.fillsShape
    }

    public static func make(fromImageData imageData: Data) -> WebsiteIcon? {
        guard let prepared = WebsiteIconImages.prepared(from: imageData) else { return nil }
        return WebsiteIcon(prepared: prepared)
    }
}
