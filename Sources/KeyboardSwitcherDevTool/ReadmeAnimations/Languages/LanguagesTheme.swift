struct LanguagesTheme {
    static let light = LanguagesTheme(
        name: "light",
        ink: PaletteColor(red: 31, green: 35, blue: 40, alpha: 255),
        dot: PaletteColor(red: 175, green: 184, blue: 193, alpha: 255)
    )

    static let dark = LanguagesTheme(
        name: "dark",
        ink: PaletteColor(red: 230, green: 237, blue: 243, alpha: 255),
        dot: PaletteColor(red: 72, green: 79, blue: 88, alpha: 255)
    )

    static let both = [light, dark]

    let name: String
    let ink: PaletteColor
    let dot: PaletteColor
}
