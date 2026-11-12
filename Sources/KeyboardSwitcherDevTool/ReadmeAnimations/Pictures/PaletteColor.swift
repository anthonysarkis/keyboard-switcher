struct PaletteColor {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    func withAlpha(_ newAlpha: UInt8) -> PaletteColor {
        PaletteColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }
}
