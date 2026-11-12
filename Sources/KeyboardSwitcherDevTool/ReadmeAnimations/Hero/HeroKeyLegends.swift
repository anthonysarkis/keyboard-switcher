enum HeroKeyLegends {
    static func markup(_ legend: KeyLegend, on key: KeyboardKey, unit: Double, symbols: SymbolPictures, theme: AnimationTheme) -> [String] {
        let inset = 0.13 * unit
        let bottomLine = key.y + key.height - 0.14 * unit
        let wordFontSize = 0.158 * unit
        switch legend {
        case .word(let text, let anchor, let hasLight):
            let textLeft = anchor == .start ? key.x + inset : key.x + key.width - inset
            let escapedText = text.xmlEscaped
            var items = ["<text x=\"\(textLeft.svgNumber)\" y=\"\(bottomLine.svgNumber)\" font-size=\"\(wordFontSize.svgNumber)\" text-anchor=\"\(anchor.rawValue)\">\(escapedText)</text>"]
            if hasLight {
                let lightX = key.x + inset + 2
                let lightY = key.y + inset + 1.5
                items.append("<circle cx=\"\(lightX.svgNumber)\" cy=\"\(lightY.svgNumber)\" r=\"1.9\" fill=\"\(theme.well)\"/>")
            }
            return items
        case .function(let label, let symbolName):
            let symbol = symbols.markup(symbolName, centreX: key.centreX, centreY: key.y + key.height * 0.36, height: key.height * 0.36)
            let labelBaseline = key.y + key.height - 0.075 * unit
            let labelFontSize = wordFontSize * 0.82
            let labelText = "<text x=\"\(key.centreX.svgNumber)\" y=\"\(labelBaseline.svgNumber)\" font-size=\"\(labelFontSize.svgNumber)\" text-anchor=\"middle\">\(label)</text>"
            return [symbol, labelText]
        case .symbol(let symbolName, let scale):
            let symbol = symbols.markup(symbolName, centreX: key.centreX, centreY: key.centreY, height: key.height * scale)
            return [symbol]
        case .globe:
            let fnRight = key.x + key.width - inset
            let fnBaseline = key.y + inset + wordFontSize * 0.8
            let fnText = "<text x=\"\(fnRight.svgNumber)\" y=\"\(fnBaseline.svgNumber)\" font-size=\"\(wordFontSize.svgNumber)\" text-anchor=\"end\">fn</text>"
            let globe = symbols.markup("globe", centreX: key.x + inset + wordFontSize * 0.62, centreY: bottomLine - wordFontSize * 0.4, height: wordFontSize * 1.35)
            return [fnText, globe]
        case .modifier(let symbol, let label, let side):
            let symbolLeft = side == .left ? key.x + key.width - inset : key.x + inset
            let symbolAnchor: TextAnchor = side == .left ? .end : .start
            let symbolBaseline = key.y + inset + wordFontSize * 0.95
            let symbolFontSize = wordFontSize * 1.18
            let symbolText = "<text x=\"\(symbolLeft.svgNumber)\" y=\"\(symbolBaseline.svgNumber)\" font-size=\"\(symbolFontSize.svgNumber)\" text-anchor=\"\(symbolAnchor.rawValue)\">\(symbol)</text>"
            let labelText = "<text x=\"\(key.centreX.svgNumber)\" y=\"\(bottomLine.svgNumber)\" font-size=\"\(wordFontSize.svgNumber)\" text-anchor=\"middle\">\(label)</text>"
            return [symbolText, labelText]
        }
    }
}
