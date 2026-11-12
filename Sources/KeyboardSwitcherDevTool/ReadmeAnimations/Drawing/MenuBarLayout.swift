import AppKit

struct MenuBarLayout {
    static let clockText = "Wed 9:41"
    private static let textBaselineDrop = 5.4

    let height: Double
    let fontSize: Double
    let baseline: Double
    let spacing: Double
    let firstMenuLeft: Double
    let badgeLeft: Double
    let badgeTop: Double
    private let padding: Double
    private let appleSize: Double
    private let clockLeft: Double
    private let batteryCentre: Double
    private let wifiCentre: Double

    init() {
        let scale = ReadmeCanvas.interfaceScale
        height = 30 * scale
        fontSize = 13 * scale
        baseline = height / 2 + Self.textBaselineDrop
        padding = 18 * scale
        spacing = 18 * scale
        appleSize = 15 * scale
        firstMenuLeft = padding + appleSize * 0.84 + spacing
        let menuFont = TextMeasure.systemFont(size: fontSize)
        let clockWidth = TextMeasure.width(of: Self.clockText, in: menuFont)
        clockLeft = ReadmeCanvas.width - padding - clockWidth
        batteryCentre = clockLeft - spacing - 13
        wifiCentre = batteryCentre - spacing - 20
        badgeLeft = wifiCentre - 12 - spacing - BadgeMarkup.width * scale
        badgeTop = (height - BadgeMarkup.height * scale) / 2
    }

    var menuFont: NSFont {
        TextMeasure.systemFont(size: fontSize)
    }

    var appNameFont: NSFont {
        TextMeasure.systemFont(size: fontSize, weight: .bold)
    }

    func background(_ theme: AnimationTheme) -> String {
        let width = ReadmeCanvas.width - 1
        let innerHeight = height - 1
        return "<rect x=\"0.5\" y=\"0.5\" width=\"\(width.svgNumber)\" height=\"\(innerHeight.svgNumber)\" rx=\"12\" fill=\"\(theme.menuFill)\" stroke=\"\(theme.menuStroke)\"/>"
    }

    func appleLogo(_ symbols: SymbolPictures) -> String {
        symbols.markup("apple.logo", centreX: padding + appleSize * 0.42, centreY: height / 2 - 0.6, height: appleSize, opacity: 1)
    }

    func clock() -> String {
        "<text x=\"\(clockLeft.svgNumber)\" y=\"\(baseline.svgNumber)\">\(Self.clockText)</text>"
    }

    func battery(_ symbols: SymbolPictures) -> String {
        let scale = ReadmeCanvas.interfaceScale
        return symbols.markup("battery.75percent", centreX: batteryCentre, centreY: height / 2, height: 13 * scale * 0.78, opacity: 1)
    }

    func wifi(_ symbols: SymbolPictures) -> String {
        let scale = ReadmeCanvas.interfaceScale
        return symbols.markup("wifi", centreX: wifiCentre, centreY: height / 2, height: 13 * scale * 0.8, opacity: 1)
    }

    func group(_ parts: [String], theme: AnimationTheme) -> String {
        let joinedParts = parts.joined()
        return "<g font-family=\"\(ReadmeCanvas.systemFontFamily)\" font-size=\"\(fontSize.svgNumber)\" fill=\"\(theme.ink)\">\(joinedParts)</g>"
    }
}
