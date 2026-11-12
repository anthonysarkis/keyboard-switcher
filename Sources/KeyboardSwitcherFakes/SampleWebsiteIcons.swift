import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum SampleWebsiteIcons {
    public enum Shape {
        case square
        case circleOnClear
    }

    public static func png(pixels: Int, shape: Shape, red: Double = 0.85, green: Double = 0.45, blue: Double = 0.3) -> Data {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                  data: nil,
                  width: pixels,
                  height: pixels,
                  bitsPerComponent: 8,
                  bytesPerRow: 0,
                  space: colorSpace,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { preconditionFailure("Could not draw a sample icon") }

        context.setFillColor(red: red, green: green, blue: blue, alpha: 1)
        let canvas = CGRect(x: 0, y: 0, width: pixels, height: pixels)
        switch shape {
        case .square:
            context.fill(canvas)
        case .circleOnClear:
            context.fillEllipse(in: canvas.insetBy(dx: Double(pixels) * 0.1, dy: Double(pixels) * 0.1))
        }

        guard let image = context.makeImage() else { preconditionFailure("Could not finish a sample icon") }
        let pngData = NSMutableData()
        let pngType = UTType.png.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(pngData as CFMutableData, pngType, 1, nil) else {
            preconditionFailure("Could not encode a sample icon")
        }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        return pngData as Data
    }
}
