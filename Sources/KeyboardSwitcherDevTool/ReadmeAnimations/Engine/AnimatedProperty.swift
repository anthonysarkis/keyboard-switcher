enum AnimatedProperty {
    case opacity
    case translateX
    case translateY

    func declaration(for value: Double) -> String {
        let number = value.svgNumber
        switch self {
        case .opacity:
            return "opacity:\(number)"
        case .translateX:
            return "transform:translateX(\(number)px)"
        case .translateY:
            return "transform:translateY(\(number)px)"
        }
    }
}
