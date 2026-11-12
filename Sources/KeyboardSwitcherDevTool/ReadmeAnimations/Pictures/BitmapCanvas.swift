import AppKit

enum BitmapCanvas {
    static func pngData(pointSize: NSSize, scale: CGFloat, drawing: (CGContext) -> Void) -> Data? {
        guard let bitmap = bitmap(pointSize: pointSize, scale: scale) else { return nil }
        guard draw(into: bitmap, drawing: drawing) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }

    static func bitmap(pointSize: NSSize, scale: CGFloat) -> NSBitmapImageRep? {
        let widthInPixels = (pointSize.width * scale).rounded(.up)
        let heightInPixels = (pointSize.height * scale).rounded(.up)
        let pixelWidth = Int(widthInPixels)
        let pixelHeight = Int(heightInPixels)
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixelWidth, pixelsHigh: pixelHeight,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )
        bitmap?.size = pointSize
        return bitmap
    }

    static func draw(into bitmap: NSBitmapImageRep, drawing: (CGContext) -> Void) -> Bool {
        guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap) else { return false }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        drawing(graphicsContext.cgContext)
        NSGraphicsContext.restoreGraphicsState()
        return true
    }
}
