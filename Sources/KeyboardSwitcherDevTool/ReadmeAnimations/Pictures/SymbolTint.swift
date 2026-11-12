import AppKit

enum SymbolTint {
    case black
    case white

    var color: NSColor {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        }
    }
}
