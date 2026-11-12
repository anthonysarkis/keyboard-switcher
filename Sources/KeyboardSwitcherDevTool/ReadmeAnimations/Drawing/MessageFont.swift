import AppKit

enum MessageFont {
    case system(size: Double)
    case monospaced(size: Double)

    var size: Double {
        switch self {
        case .system(let size), .monospaced(let size):
            return size
        }
    }

    var isCode: Bool {
        if case .monospaced = self {
            return true
        }
        return false
    }

    var font: NSFont {
        let pointSize = CGFloat(size.svgRounded)
        switch self {
        case .system:
            return NSFont.systemFont(ofSize: pointSize, weight: .regular)
        case .monospaced:
            return NSFont.monospacedSystemFont(ofSize: pointSize, weight: .regular)
        }
    }

    var svgFamily: String {
        isCode ? ReadmeCanvas.monospacedFontFamily : ReadmeCanvas.systemFontFamily
    }
}
