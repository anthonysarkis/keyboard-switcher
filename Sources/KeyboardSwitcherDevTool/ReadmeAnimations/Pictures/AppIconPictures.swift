import AppKit

enum AppIconPictures {
    private static let pixelSize: CGFloat = 128

    static func symbolDefinition(for iconName: String) throws -> String {
        let iconFile = ReadmeExampleApp.iconFile(named: iconName)
        guard let icon = NSImage(contentsOf: iconFile) else {
            throw ReadmeAnimationError.missingAppIcon(iconFile.path)
        }
        let iconSize = NSSize(width: pixelSize, height: pixelSize)
        let pngData = BitmapCanvas.pngData(pointSize: iconSize, scale: 1) { context in
            context.interpolationQuality = .high
            let bounds = NSRect(origin: .zero, size: iconSize)
            icon.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)
        }
        guard let pngData else {
            throw ReadmeAnimationError.missingAppIcon(iconFile.path)
        }
        let dataURI = ImageDataURI.png(pngData)
        return "<symbol id=\"icon-\(iconName)\" viewBox=\"0 0 128 128\"><image width=\"128\" height=\"128\" href=\"\(dataURI)\"/></symbol>"
    }
}
