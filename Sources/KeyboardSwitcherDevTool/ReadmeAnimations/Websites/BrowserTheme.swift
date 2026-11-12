struct BrowserTheme {
    static let light = BrowserTheme(
        frame: "#e7eaef",
        toolbar: "#ffffff",
        omnibox: "#eef1f5",
        separator: "#c3c8cf",
        windowStroke: "rgba(0,0,0,0.12)",
        page: "#ffffff"
    )

    static let dark = BrowserTheme(
        frame: "#1e1f22",
        toolbar: "#35363a",
        omnibox: "#26272a",
        separator: "#4a4c50",
        windowStroke: "rgba(255,255,255,0.10)",
        page: "#202124"
    )

    let frame: String
    let toolbar: String
    let omnibox: String
    let separator: String
    let windowStroke: String
    let page: String

    static func matching(_ theme: AnimationTheme) -> BrowserTheme {
        theme.name == AnimationTheme.dark.name ? dark : light
    }
}
