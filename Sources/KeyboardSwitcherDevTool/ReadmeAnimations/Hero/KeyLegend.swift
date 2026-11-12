enum KeyLegend {
    case word(String, anchor: TextAnchor, hasLight: Bool = false)
    case function(label: String, symbolName: String)
    case symbol(String, scale: Double = 0.42)
    case globe
    case modifier(symbol: String, label: String, side: KeyboardSide)
}
