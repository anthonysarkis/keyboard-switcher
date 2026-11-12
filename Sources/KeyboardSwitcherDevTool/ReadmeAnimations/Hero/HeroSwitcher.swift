enum HeroSwitcher {
    private static let iconSize = 66.0
    private static let cellSize = 84.0
    private static let inset = 14.0
    private static let nameHeight = 46.0
    private static let cornerRadius = 22.0
    private static let highlightRadius = 16.0
    private static let shadowMargin = 28.0
    private static let dropBelowComposerMiddle = 6.0
    private static let nameAboveBottom = 15.0
    private static let fadeIn = 0.07
    private static let fadeOut = 0.1
    private static let highlightLead = 0.02

    static func markup(_ stage: HeroStage) -> String {
        let appCount = stage.apps.count
        let width = cellSize * Double(appCount) + inset * 2
        let height = cellSize + nameHeight
        let left = (ReadmeCanvas.width - width) / 2
        let top = stage.composer.middleY - height / 2 + dropBelowComposerMiddle
        var shownEvents: [AnimationEvent] = []
        var highlightPoints: [AnimationEvent] = []
        for segment in stage.schedule.segments {
            shownEvents += AnimationEvents.window(from: segment.tabDown, to: segment.nextActivation, fadeIn: fadeIn, fadeOut: fadeOut)
            let targetIndex = (segment.appIndex + 1) % appCount
            let highlightPoint = AnimationEvent(time: segment.tabDown - highlightLead, value: Double(targetIndex) * cellSize)
            highlightPoints.append(highlightPoint)
        }
        let switcherStyle = stage.sheet.style(.opacity, shownEvents)
        let orderedHighlightPoints = highlightPoints.sorted()
        let highlightSteps = AnimationEvents.steps(orderedHighlightPoints)
        let highlightStyle = stage.sheet.style(.translateX, highlightSteps)
        let theme = stage.theme
        let shadowShape = ShadowShape(width: width, height: height, cornerRadius: cornerRadius, margin: shadowMargin, layers: ShadowShape.floatingLayers)
        let shadow = ShadowPainter.markup(shadowShape, x: left, y: top, opacity: theme.shadowOpacity)
        let panel = "<rect x=\"\(left.svgNumber)\" y=\"\(top.svgNumber)\" width=\"\(width.svgNumber)\" height=\"\(height.svgNumber)\" rx=\"\(cornerRadius.svgNumber)\" fill=\"\(theme.switcherFill)\" stroke=\"\(theme.switcherStroke)\"/>"
        let highlightLeft = left + inset
        let highlightTop = top + inset
        let highlight = "<rect x=\"\(highlightLeft.svgNumber)\" y=\"\(highlightTop.svgNumber)\" width=\"\(cellSize.svgNumber)\" height=\"\(cellSize.svgNumber)\" rx=\"\(highlightRadius.svgNumber)\" fill=\"\(theme.switcherHighlight)\" style=\"\(highlightStyle)\"/>"
        var parts = [shadow, panel, highlight]
        let nameCentre = ReadmeCanvas.width / 2
        let nameBaseline = top + height - nameAboveBottom
        for (appIndex, app) in stage.apps.enumerated() {
            let cellLeft = left + inset + Double(appIndex) * cellSize
            let iconLeft = cellLeft + (cellSize - iconSize) / 2
            let iconTop = top + inset + (cellSize - iconSize) / 2
            parts.append("<use href=\"#icon-\(app.iconName)\" x=\"\(iconLeft.svgNumber)\" y=\"\(iconTop.svgNumber)\" width=\"\(iconSize.svgNumber)\" height=\"\(iconSize.svgNumber)\"/>")
            var nameEvents: [AnimationEvent] = []
            for segment in stage.schedule.segments where (segment.appIndex + 1) % appCount == appIndex {
                nameEvents += AnimationEvents.window(from: segment.tabDown, to: segment.nextActivation, fadeIn: fadeIn, fadeOut: fadeOut)
            }
            let nameStyle = stage.sheet.style(.opacity, nameEvents)
            let escapedName = app.appName.xmlEscaped
            parts.append("<text x=\"\(nameCentre.svgNumber)\" y=\"\(nameBaseline.svgNumber)\" text-anchor=\"middle\" font-family=\"\(ReadmeCanvas.systemFontFamily)\" font-size=\"14\" font-weight=\"500\" fill=\"\(theme.ink)\" style=\"\(nameStyle)\">\(escapedName)</text>")
        }
        let joinedParts = parts.joined()
        return "<g style=\"\(switcherStyle)\">\(joinedParts)</g>"
    }
}
