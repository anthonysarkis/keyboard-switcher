import AppKit

enum BadgePixels {
    private static let retinaScale: CGFloat = 2
    private static let visibleAlphaDifference: CGFloat = 0.1

    static func differingPixelCount(between firstImage: NSImage, and secondImage: NSImage) -> Int {
        let firstAlphas = alphaValues(of: firstImage)
        let secondAlphas = alphaValues(of: secondImage)
        guard firstAlphas.count == secondAlphas.count else { return max(firstAlphas.count, secondAlphas.count) }
        let alphaPairs = zip(firstAlphas, secondAlphas)
        let differingPairs = alphaPairs.filter { firstAlpha, secondAlpha in
            abs(firstAlpha - secondAlpha) > visibleAlphaDifference
        }
        return differingPairs.count
    }

    static func pixelCount(of image: NSImage) -> Int {
        let pixelWidth = Int(image.size.width * retinaScale)
        let pixelHeight = Int(image.size.height * retinaScale)
        return pixelWidth * pixelHeight
    }

    private static func alphaValues(of image: NSImage) -> [CGFloat] {
        let pixelWidth = Int(image.size.width * retinaScale)
        let pixelHeight = Int(image.size.height * retinaScale)
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixelWidth, pixelsHigh: pixelHeight,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { return [] }
        bitmap.size = image.size

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let imageFrame = NSRect(origin: .zero, size: image.size)
        image.draw(in: imageFrame)
        NSGraphicsContext.restoreGraphicsState()

        var alphas: [CGFloat] = []
        for row in 0..<pixelHeight {
            for column in 0..<pixelWidth {
                let color = bitmap.colorAt(x: column, y: row)
                alphas.append(color?.alphaComponent ?? 0)
            }
        }
        return alphas
    }
}
