import AppKit
import CoreText

enum TextMeasure {
    static func characterOffsets(of text: String, in font: NSFont) -> [Double] {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .kern: 0, .ligature: 0]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedText)
        var offsets: [Double] = [0]
        var utf16Index = 0
        for character in text {
            utf16Index += character.utf16.count
            let offset = CTLineGetOffsetForStringIndex(line, utf16Index, nil)
            let offsetValue = Double(offset)
            offsets.append(offsetValue)
        }
        return offsets
    }

    static func width(of text: String, in font: NSFont) -> Double {
        let offsets = characterOffsets(of: text, in: font)
        return offsets.last ?? 0
    }

    static func systemFont(size: Double, weight: NSFont.Weight = .regular) -> NSFont {
        let pointSize = CGFloat(size.svgRounded)
        return NSFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
