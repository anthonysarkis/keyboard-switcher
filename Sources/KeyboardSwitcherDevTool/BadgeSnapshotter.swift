import AppKit

enum BadgeSnapshotter {
    private struct MenuBarLook {
        let bar: NSColor
        let badge: NSColor
    }

    private static let retinaScale: CGFloat = 2
    private static let magnification: CGFloat = 6
    private static let barHeight: CGFloat = 24
    private static let sideMargin: CGFloat = 8
    private static let lightBarColor = NSColor(white: 0.93, alpha: 1)
    private static let darkBarColor = NSColor(white: 0.16, alpha: 1)
    private static let wallpaperBarColor = NSColor(red: 0.37, green: 0.44, blue: 0.57, alpha: 1)
    private static let looks = [
        MenuBarLook(bar: lightBarColor, badge: .black),
        MenuBarLook(bar: darkBarColor, badge: .white),
        MenuBarLook(bar: wallpaperBarColor, badge: .white),
    ]

    static func write(_ badge: NSImage, named name: String, in folder: URL) throws {
        let sectionWidth = badge.size.width + sideMargin * 2
        let lookCount = CGFloat(looks.count)
        let canvasSize = NSSize(width: sectionWidth * lookCount, height: barHeight)
        let retinaBitmap = try makeBitmap(size: canvasSize, pixelsPerPoint: retinaScale, name: name)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: retinaBitmap)
        for (index, look) in looks.enumerated() {
            let sectionOrigin = CGFloat(index) * sectionWidth
            draw(badge, look: look, sectionOrigin: sectionOrigin, sectionWidth: sectionWidth)
        }
        NSGraphicsContext.restoreGraphicsState()

        let magnifiedBitmap = try magnified(retinaBitmap, size: canvasSize, name: name)
        guard let pngData = magnifiedBitmap.representation(using: .png, properties: [:]) else { throw SnapshotError.noPNG(name) }
        let fileURL = folder.appending(path: "\(name).png")
        try pngData.write(to: fileURL)
        let magnificationFactor = Int(magnification)
        print("\(name): \(badge.size.width) × \(badge.size.height) points, Retina pixels shown \(magnificationFactor) times larger")
    }

    private static func magnified(_ retinaBitmap: NSBitmapImageRep, size: NSSize, name: String) throws -> NSBitmapImageRep {
        let magnifiedBitmap = try makeBitmap(size: size, pixelsPerPoint: retinaScale * magnification, name: name)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: magnifiedBitmap)
        NSGraphicsContext.current?.imageInterpolation = .none
        let canvasFrame = NSRect(origin: .zero, size: size)
        retinaBitmap.draw(in: canvasFrame)
        NSGraphicsContext.restoreGraphicsState()
        return magnifiedBitmap
    }

    private static func makeBitmap(size: NSSize, pixelsPerPoint: CGFloat, name: String) throws -> NSBitmapImageRep {
        let pixelWidth = Int(size.width * pixelsPerPoint)
        let pixelHeight = Int(size.height * pixelsPerPoint)
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixelWidth, pixelsHigh: pixelHeight,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { throw SnapshotError.noBitmap(name) }
        bitmap.size = size
        return bitmap
    }

    private static func draw(_ badge: NSImage, look: MenuBarLook, sectionOrigin: CGFloat, sectionWidth: CGFloat) {
        let sectionFrame = NSRect(x: sectionOrigin, y: 0, width: sectionWidth, height: barHeight)
        look.bar.setFill()
        sectionFrame.fill()

        let badgeOrigin = NSPoint(x: sectionFrame.midX - badge.size.width / 2, y: (barHeight - badge.size.height) / 2)
        let badgeFrame = NSRect(origin: badgeOrigin, size: badge.size)
        let tintedBadge = tinted(badge, with: look.badge)
        tintedBadge.draw(in: badgeFrame)
    }

    private static func tinted(_ image: NSImage, with color: NSColor) -> NSImage {
        NSImage(size: image.size, flipped: false) { imageFrame in
            image.draw(in: imageFrame)
            color.set()
            imageFrame.fill(using: .sourceAtop)
            return true
        }
    }
}
