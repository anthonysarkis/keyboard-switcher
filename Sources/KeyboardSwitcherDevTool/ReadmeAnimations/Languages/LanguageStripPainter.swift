import AppKit
import CoreText

enum LanguageStripPainter {
    static let rowHeight = 44.0
    private static let renderScale = 2.0
    private static let fontSize: CGFloat = 22
    private static let dotPaddingInEms: CGFloat = 0.62
    private static let separator = "·"
    private static let shadeCount = 127
    private static let dotPaletteStart = 128

    static func strip(of names: [String], theme: LanguagesTheme) -> LanguageStrip? {
        let font = NSFont.systemFont(ofSize: fontSize)
        let dotPadding = Double(dotPaddingInEms * fontSize)
        var nameLines: [PlacedLine] = []
        var dotLines: [PlacedLine] = []
        var cursor = 0.0
        for name in names {
            let nameLine = coverageLine(name, font: font)
            let placedName = PlacedLine(line: nameLine, left: cursor)
            nameLines.append(placedName)
            cursor += width(of: nameLine) + dotPadding
            let dotLine = coverageLine(separator, font: font)
            let placedDot = PlacedLine(line: dotLine, left: cursor)
            dotLines.append(placedDot)
            cursor += width(of: dotLine) + dotPadding
        }
        let pixelWidthValue = (cursor * renderScale).rounded(.up)
        let pixelWidth = Int(pixelWidthValue)
        let pixelHeight = Int(rowHeight * renderScale)
        guard
            let nameCoverage = coverage(of: nameLines, pixelWidth: pixelWidth, pixelHeight: pixelHeight),
            let dotCoverage = coverage(of: dotLines, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
        else { return nil }
        let pixelIndices = zip(nameCoverage, dotCoverage).map { nameShade, dotShade in
            dotShade > nameShade ? paletteIndex(forDotShade: dotShade) : paletteIndex(forNameShade: nameShade)
        }
        let palette = palette(for: theme)
        guard let pngData = IndexedPNG.data(width: pixelWidth, height: pixelHeight, pixelIndices: pixelIndices, palette: palette) else { return nil }
        return LanguageStrip(pngData: pngData, width: pixelWidthValue / renderScale)
    }

    private static func palette(for theme: LanguagesTheme) -> [PaletteColor] {
        (0..<256).map { paletteIndex in
            let isDot = paletteIndex >= dotPaletteStart
            let level = isDot ? paletteIndex - dotPaletteStart : paletteIndex
            let alphaValue = (Double(level) * 255 / Double(shadeCount)).rounded()
            let alpha = UInt8(alphaValue)
            return isDot ? theme.dot.withAlpha(alpha) : theme.ink.withAlpha(alpha)
        }
    }

    private static func paletteIndex(forNameShade shade: UInt8) -> UInt8 {
        let level = shadeLevel(of: shade)
        return UInt8(level)
    }

    private static func paletteIndex(forDotShade shade: UInt8) -> UInt8 {
        let level = shadeLevel(of: shade)
        return UInt8(dotPaletteStart + level)
    }

    private static func shadeLevel(of shade: UInt8) -> Int {
        let level = (Double(shade) * Double(shadeCount) / 255).rounded()
        return Int(level)
    }

    private static func coverage(of placedLines: [PlacedLine], pixelWidth: Int, pixelHeight: Int) -> [UInt8]? {
        let graySpace = CGColorSpaceCreateDeviceGray()
        let noAlpha = CGImageAlphaInfo.none.rawValue
        guard let context = CGContext(
            data: nil, width: pixelWidth, height: pixelHeight, bitsPerComponent: 8, bytesPerRow: pixelWidth, space: graySpace, bitmapInfo: noAlpha
        ) else { return nil }
        context.setShouldSmoothFonts(false)
        context.setAllowsFontSmoothing(false)
        context.scaleBy(x: renderScale, y: renderScale)
        context.textMatrix = .identity
        for placedLine in placedLines {
            let bounds = typographicBounds(of: placedLine.line)
            let baseline = (rowHeight - (bounds.ascent + bounds.descent)) / 2 + bounds.descent
            context.textPosition = CGPoint(x: placedLine.left, y: baseline)
            CTLineDraw(placedLine.line, context)
        }
        guard let pixels = context.data else { return nil }
        let pixelCount = pixelWidth * pixelHeight
        let shades = pixels.bindMemory(to: UInt8.self, capacity: pixelCount)
        let shadeBuffer = UnsafeBufferPointer(start: shades, count: pixelCount)
        return Array(shadeBuffer)
    }

    private static func coverageLine(_ text: String, font: NSFont) -> CTLine {
        let foregroundColorKey = NSAttributedString.Key(kCTForegroundColorAttributeName as String)
        let white = CGColor(gray: 1, alpha: 1)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, foregroundColorKey: white]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        return CTLineCreateWithAttributedString(attributedText)
    }

    private static func width(of line: CTLine) -> Double {
        let bounds = typographicBounds(of: line)
        return bounds.width
    }

    private static func typographicBounds(of line: CTLine) -> (width: Double, ascent: Double, descent: Double) {
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        return (width, ascent, descent)
    }
}
