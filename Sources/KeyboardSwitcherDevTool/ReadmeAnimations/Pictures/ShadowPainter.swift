import AppKit

enum ShadowPainter {
    private static let blurScale = 2.0
    private static let separation = 400.0

    static func markup(_ shape: ShadowShape, x: Double, y: Double, opacity: Double) -> String {
        guard let pngData = pngData(for: shape) else {
            preconditionFailure("Could not draw a shadow")
        }
        let dataURI = ImageDataURI.png(pngData)
        let left = x - shape.margin
        let top = y - shape.margin
        let width = shape.width + shape.margin * 2
        let height = shape.height + shape.margin * 2
        return "<image x=\"\(left.svgNumber)\" y=\"\(top.svgNumber)\" width=\"\(width.svgNumber)\" height=\"\(height.svgNumber)\" opacity=\"\(opacity.svgNumber)\" href=\"\(dataURI)\"/>"
    }

    private static func pngData(for shape: ShadowShape) -> Data? {
        let canvasWidth = (shape.width + shape.margin * 2).rounded(.up)
        let canvasHeight = (shape.height + shape.margin * 2).rounded(.up)
        let shift = canvasWidth + separation
        let workingSize = NSSize(width: canvasWidth * 2 + separation, height: canvasHeight)
        guard let bitmap = BitmapCanvas.bitmap(pointSize: workingSize, scale: 1) else { return nil }
        let drew = BitmapCanvas.draw(into: bitmap) { context in
            for layer in shape.layers {
                drawFarAway(shape, layer: layer, shift: shift, canvasHeight: canvasHeight, in: context)
            }
        }
        guard drew, let workingImage = bitmap.cgImage else { return nil }
        let shadowArea = CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)
        guard let shadowImage = workingImage.cropping(to: shadowArea) else { return nil }
        let shadowBitmap = NSBitmapImageRep(cgImage: shadowImage)
        return shadowBitmap.representation(using: .png, properties: [:])
    }

    private static func drawFarAway(_ shape: ShadowShape, layer: ShadowLayer, shift: Double, canvasHeight: Double, in context: CGContext) {
        context.saveGState()
        let shadowColor = CGColor(gray: 0, alpha: layer.opacity)
        let shadowOffset = CGSize(width: -shift, height: -layer.drop)
        context.setShadow(offset: shadowOffset, blur: layer.blur * blurScale, color: shadowColor)
        let shapeFrame = CGRect(x: shape.margin + shift, y: canvasHeight - shape.margin - shape.height, width: shape.width, height: shape.height)
        let shapePath = CGPath(roundedRect: shapeFrame, cornerWidth: shape.cornerRadius, cornerHeight: shape.cornerRadius, transform: nil)
        let fillColor = CGColor(gray: 0, alpha: 1)
        context.addPath(shapePath)
        context.setFillColor(fillColor)
        context.fillPath()
        context.restoreGState()
    }
}
