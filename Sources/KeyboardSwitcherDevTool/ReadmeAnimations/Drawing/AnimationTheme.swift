struct AnimationTheme {
    static let light = AnimationTheme(
        name: "light",
        ink: "#1d1d1f",
        menuFill: "rgba(255,255,255,0.78)",
        menuStroke: "rgba(0,0,0,0.08)",
        composerFill: "#ffffff",
        composerStroke: "rgba(0,0,0,0.10)",
        caret: "#2f6df6",
        codeFunction: "#795e26",
        codeString: "#a31515",
        bubbleFill: "rgba(246,246,247,0.96)",
        bubbleStroke: "rgba(0,0,0,0.10)",
        switcherFill: "rgba(246,246,247,0.94)",
        switcherStroke: "rgba(0,0,0,0.10)",
        switcherHighlight: "rgba(0,0,0,0.11)",
        plateTop: "#e9eaec",
        plateBottom: "#d8d9dc",
        plateStroke: "rgba(0,0,0,0.10)",
        plateHighlight: "rgba(255,255,255,0.85)",
        well: "#c4c5c9",
        capLip: "#d3d4d7",
        capTop: "#ffffff",
        capBottom: "#f3f3f5",
        legend: "#2c2c2e",
        pressed: "rgba(0,0,0,0.13)",
        shadowOpacity: 0.20,
        symbolTint: .black,
        symbolOpacity: 0.82
    )

    static let dark = AnimationTheme(
        name: "dark",
        ink: "#f0f0f2",
        menuFill: "rgba(255,255,255,0.06)",
        menuStroke: "rgba(255,255,255,0.11)",
        composerFill: "#1b1f26",
        composerStroke: "rgba(255,255,255,0.12)",
        caret: "#4c8dff",
        codeFunction: "#dcdcaa",
        codeString: "#ce9178",
        bubbleFill: "rgba(44,44,47,0.96)",
        bubbleStroke: "rgba(255,255,255,0.12)",
        switcherFill: "rgba(38,38,41,0.95)",
        switcherStroke: "rgba(255,255,255,0.12)",
        switcherHighlight: "rgba(255,255,255,0.15)",
        plateTop: "#323337",
        plateBottom: "#26272a",
        plateStroke: "rgba(255,255,255,0.07)",
        plateHighlight: "rgba(255,255,255,0.10)",
        well: "#121214",
        capLip: "#0b0b0d",
        capTop: "#232326",
        capBottom: "#1b1b1e",
        legend: "#e6e6eb",
        pressed: "rgba(255,255,255,0.14)",
        shadowOpacity: 0.55,
        symbolTint: .white,
        symbolOpacity: 0.86
    )

    static let both = [light, dark]

    let name: String
    let ink: String
    let menuFill: String
    let menuStroke: String
    let composerFill: String
    let composerStroke: String
    let caret: String
    let codeFunction: String
    let codeString: String
    let bubbleFill: String
    let bubbleStroke: String
    let switcherFill: String
    let switcherStroke: String
    let switcherHighlight: String
    let plateTop: String
    let plateBottom: String
    let plateStroke: String
    let plateHighlight: String
    let well: String
    let capLip: String
    let capTop: String
    let capBottom: String
    let legend: String
    let pressed: String
    let shadowOpacity: Double
    let symbolTint: SymbolTint
    let symbolOpacity: Double

    func symbolPictures() -> SymbolPictures {
        SymbolPictures(tint: symbolTint, defaultOpacity: symbolOpacity)
    }
}
