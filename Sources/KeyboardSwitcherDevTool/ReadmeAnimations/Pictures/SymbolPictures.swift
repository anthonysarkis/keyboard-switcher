import AppKit

final class SymbolPictures {
    private static let renderScale: CGFloat = 4
    private static let defaultPointSize: CGFloat = 12
    private static let pointSizes: [String: CGFloat] = [
        "apple.logo": 14,
        "wifi": 13,
        "battery.75percent": 13,
        "arrow.left": 13,
        "arrow.right": 13,
        "arrow.clockwise": 13,
        "xmark": 9,
    ]
    private static let semiboldSymbols: Set<String> = ["xmark"]

    private let tint: SymbolTint
    private let defaultOpacity: Double
    private var renderedSymbols: [String: RenderedSymbol] = [:]

    init(tint: SymbolTint, defaultOpacity: Double) {
        self.tint = tint
        self.defaultOpacity = defaultOpacity
    }

    func markup(_ symbolName: String, centreX: Double, centreY: Double, height: Double, opacity: Double? = nil) -> String {
        let symbol = rendered(symbolName)
        let scale = height / symbol.height
        let width = symbol.width * scale
        let chosenOpacity = opacity ?? defaultOpacity
        let left = centreX - width / 2
        let top = centreY - height / 2
        return "<image x=\"\(left.svgNumber)\" y=\"\(top.svgNumber)\" width=\"\(width.svgNumber)\" height=\"\(height.svgNumber)\" opacity=\"\(chosenOpacity.svgNumber)\" href=\"\(symbol.dataURI)\"/>"
    }

    private func rendered(_ symbolName: String) -> RenderedSymbol {
        if let renderedSymbol = renderedSymbols[symbolName] {
            return renderedSymbol
        }
        let renderedSymbol = render(symbolName)
        renderedSymbols[symbolName] = renderedSymbol
        return renderedSymbol
    }

    private func render(_ symbolName: String) -> RenderedSymbol {
        let pointSize = Self.pointSizes[symbolName] ?? Self.defaultPointSize
        let weight: NSFont.Weight = Self.semiboldSymbols.contains(symbolName) ? .semibold : .regular
        let configuration = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let plainImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        guard let image = plainImage?.withSymbolConfiguration(configuration) else {
            preconditionFailure("macOS has no SF Symbol named \(symbolName)")
        }
        let tintColor = tint.color
        let pngData = BitmapCanvas.pngData(pointSize: image.size, scale: Self.renderScale) { _ in
            let bounds = NSRect(origin: .zero, size: image.size)
            image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)
            tintColor.setFill()
            bounds.fill(using: .sourceIn)
        }
        guard let pngData else {
            preconditionFailure("Could not draw the SF Symbol \(symbolName)")
        }
        let dataURI = ImageDataURI.png(pngData)
        return RenderedSymbol(width: image.size.width, height: image.size.height, dataURI: dataURI)
    }
}
