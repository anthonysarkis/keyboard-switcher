import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// pngData is what the Mac keeps; displayPNGData is what gets drawn: the same square, or a logo centred on a white square.
// Preparing a kept icon again gives the same result, because both come from the same uncropped pixels.
nonisolated struct PreparedWebsiteIcon: Sendable, Equatable {
    let pngData: Data
    let displayPNGData: Data
    let pixelSize: Int
    let fillsShape: Bool
}

nonisolated enum WebsiteIconImages {
    static let largestPixelSize = 96
    static let smallestPixelSize = 16
    private static let opacitySampleSize = 32
    private static let fillingOpaqueShare = 0.9
    private static let nearWhiteLevel = 236
    private static let plateSize = 96
    private static let logoShareOfPlate = 0.66
    private static let bytesPerPixel = 4
    private static let alphaOffset = 3

    static func prepared(from imageData: Data) -> PreparedWebsiteIcon? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let frameIndex = largestFrameIndex(in: source),
              let image = shrunkImage(from: source, at: frameIndex)
        else { return nil }
        let pixelSize = min(image.width, image.height)
        guard pixelSize >= smallestPixelSize, let pngData = encodedPNG(of: image) else { return nil }
        let fillsShape = opaqueShare(of: image) >= fillingOpaqueShare
        let logo = croppedToWhatShowsOnWhite(image) ?? image
        guard let displayImage = fillsShape ? image : logoOnWhitePlate(logo),
              let displayPNGData = encodedPNG(of: displayImage)
        else { return nil }
        return PreparedWebsiteIcon(pngData: pngData, displayPNGData: displayPNGData, pixelSize: pixelSize, fillsShape: fillsShape)
    }

    private static func largestFrameIndex(in source: CGImageSource) -> Int? {
        let frameIndices = 0..<CGImageSourceGetCount(source)
        return frameIndices.max { firstIndex, secondIndex in
            pixelWidth(of: source, at: firstIndex) < pixelWidth(of: source, at: secondIndex)
        }
    }

    private static func pixelWidth(of source: CGImageSource, at frameIndex: Int) -> Int {
        let properties = CGImageSourceCopyPropertiesAtIndex(source, frameIndex, nil) as? [CFString: Any]
        return properties?[kCGImagePropertyPixelWidth] as? Int ?? 0
    }

    private static func shrunkImage(from source: CGImageSource, at frameIndex: Int) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: largestPixelSize,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, frameIndex, options as CFDictionary)
    }

    private static func encodedPNG(of image: CGImage) -> Data? {
        let output = NSMutableData()
        let pngType = UTType.png.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(output as CFMutableData, pngType, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }

    // A square or rounded-square icon is almost fully opaque; a logo with see-through corners is not.
    private static func opaqueShare(of image: CGImage) -> Double {
        let side = opacitySampleSize
        guard let pixels = premultipliedPixels(of: image, width: side, height: side) else { return 0 }
        let pixelCount = side * side
        let opaqueCount = (0..<pixelCount).count { pixelIndex in pixels[pixelIndex * bytesPerPixel + alphaOffset] > 127 }
        return Double(opaqueCount) / Double(pixelCount)
    }

    // Logos go on a white plate, so the crop keeps what shows on white: a white circle behind a logo is trimmed away with the see-through corners.
    private static func croppedToWhatShowsOnWhite(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        guard let pixels = premultipliedPixels(of: image, width: width, height: height) else { return nil }
        var left = width
        var right = -1
        var top = height
        var bottom = -1
        for row in 0..<height {
            for column in 0..<width where showsOnWhite(pixels, at: (row * width + column) * bytesPerPixel) {
                left = min(left, column)
                right = max(right, column)
                top = min(top, row)
                bottom = max(bottom, row)
            }
        }
        guard right >= left, bottom >= top else { return nil }
        let shownRect = CGRect(x: left, y: top, width: right - left + 1, height: bottom - top + 1)
        return image.cropping(to: shownRect)
    }

    // Drawn once here as one opaque square, so the logo needs no edges of its own when it is scaled into the icon shape.
    private static func logoOnWhitePlate(_ logo: CGImage) -> CGImage? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                  data: nil,
                  width: plateSize,
                  height: plateSize,
                  bitsPerComponent: 8,
                  bytesPerRow: 0,
                  space: colorSpace,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }
        let plateSide = Double(plateSize)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: plateSide, height: plateSide))
        let largestLogoSide = plateSide * logoShareOfPlate
        let logoScale = min(largestLogoSide / Double(logo.width), largestLogoSide / Double(logo.height))
        let logoWidth = Double(logo.width) * logoScale
        let logoHeight = Double(logo.height) * logoScale
        let logoRect = CGRect(x: (plateSide - logoWidth) / 2, y: (plateSide - logoHeight) / 2, width: logoWidth, height: logoHeight)
        context.interpolationQuality = .high
        context.draw(logo, in: logoRect)
        return context.makeImage()
    }

    private static func showsOnWhite(_ pixels: [UInt8], at pixelOffset: Int) -> Bool {
        let transparency = 255 - Int(pixels[pixelOffset + alphaOffset])
        let colorOffsets = 0..<alphaOffset
        return colorOffsets.contains { colorOffset in Int(pixels[pixelOffset + colorOffset]) + transparency < nearWhiteLevel }
    }

    // Premultiplied RGBA, top row first: the same row order CGImage.cropping(to:) counts in.
    private static func premultipliedPixels(of image: CGImage, width: Int, height: Int) -> [UInt8]? {
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let wasDrawn = pixels.withUnsafeMutableBytes { pixelBuffer -> Bool in
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
                  let context = CGContext(
                      data: pixelBuffer.baseAddress,
                      width: width,
                      height: height,
                      bitsPerComponent: 8,
                      bytesPerRow: width * bytesPerPixel,
                      space: colorSpace,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  )
            else { return false }
            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return wasDrawn ? pixels : nil
    }
}
