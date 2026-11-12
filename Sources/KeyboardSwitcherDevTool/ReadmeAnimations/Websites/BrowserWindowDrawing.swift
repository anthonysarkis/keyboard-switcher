enum BrowserWindowDrawing {
    private static let cornerRadius = 12.0
    private static let shadowMargin = 34.0
    private static let windowLayers = [ShadowLayer(blur: 9, drop: 8, opacity: 0.8), ShadowLayer(blur: 1, drop: 1, opacity: 0.5)]
    private static let trafficLights = ["#ff5f57", "#febc2e", "#28c840"]
    private static let tabCornerRadius = 10.0
    private static let inactiveTitleOpacity = 0.62
    private static let toolbarSymbols = ["arrow.left", "arrow.right", "arrow.clockwise"]
    private static let omniboxInset = 128.0
    private static let omniboxEndMargin = 18.0
    private static let omniboxHeight = 34.0
    private static let hostBaselineDrop = 5.4
    private static let fadeAbove = 40.0
    private static let pageOverhang = 20.0

    static func definitions() -> String {
        let window = WebsitesStage.window
        let maskTop = window.y - fadeAbove
        let maskHeight = window.height + fadeAbove * 2
        let fadeHeight = window.height + fadeAbove
        let clipHeight = window.height + pageOverhang
        let width = ReadmeCanvas.width.svgNumber
        let fade = "<linearGradient id=\"pageFade\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\"><stop offset=\"0\" stop-color=\"#fff\"/><stop offset=\"0.72\" stop-color=\"#fff\"/><stop offset=\"1\" stop-color=\"#fff\" stop-opacity=\"0\"/></linearGradient>"
        let mask = "<mask id=\"windowFade\" maskUnits=\"userSpaceOnUse\" x=\"0\" y=\"\(maskTop.svgNumber)\" width=\"\(width)\" height=\"\(maskHeight.svgNumber)\"><rect x=\"0\" y=\"\(maskTop.svgNumber)\" width=\"\(width)\" height=\"\(fadeHeight.svgNumber)\" fill=\"url(#pageFade)\"/></mask>"
        let clip = "<clipPath id=\"windowShape\"><rect x=\"\(window.x.svgNumber)\" y=\"\(window.y.svgNumber)\" width=\"\(window.width.svgNumber)\" height=\"\(clipHeight.svgNumber)\" rx=\"\(cornerRadius.svgNumber)\"/></clipPath>"
        return "\(fade)\(mask)\(clip)\(PointerMarkup.shadowFilter)"
    }

    static func markup(_ stage: WebsitesStage) -> String {
        let window = WebsitesStage.window
        let browser = stage.browserTheme
        let shadowShape = ShadowShape(width: window.width, height: window.height, cornerRadius: cornerRadius, margin: shadowMargin, layers: windowLayers)
        let shadow = ShadowPainter.markup(shadowShape, x: window.x, y: window.y, opacity: stage.theme.shadowOpacity)
        let frame = frameParts(browser)
        let tabs = tabParts(stage)
        let toolbar = toolbarParts(stage)
        var parts = [shadow, "<g clip-path=\"url(#windowShape)\">"]
        parts += frame
        parts += tabs
        parts += toolbar
        parts.append("</g>")
        let outlineLeft = window.x + 0.5
        let outlineTop = window.y + 0.5
        let outlineWidth = window.width - 1
        let outlineHeight = window.height + pageOverhang
        parts.append("<rect x=\"\(outlineLeft.svgNumber)\" y=\"\(outlineTop.svgNumber)\" width=\"\(outlineWidth.svgNumber)\" height=\"\(outlineHeight.svgNumber)\" rx=\"\(cornerRadius.svgNumber)\" fill=\"none\" stroke=\"\(browser.windowStroke)\"/>")
        let joinedParts = parts.joined()
        return "<g mask=\"url(#windowFade)\">\(joinedParts)</g>"
    }

    private static func frameParts(_ browser: BrowserTheme) -> [String] {
        let window = WebsitesStage.window
        let left = window.x.svgNumber
        let width = window.width.svgNumber
        let toolbarTop = window.y + WebsitesStage.stripHeight
        let pageTop = toolbarTop + WebsitesStage.toolbarHeight
        let pageHeight = WebsitesStage.pageHeight + pageOverhang
        let separatorY = pageTop + 0.5
        let separatorEnd = window.x + window.width
        var parts = [
            "<rect x=\"\(left)\" y=\"\(window.y.svgNumber)\" width=\"\(width)\" height=\"\(WebsitesStage.stripHeight.svgNumber)\" fill=\"\(browser.frame)\"/>",
            "<rect x=\"\(left)\" y=\"\(toolbarTop.svgNumber)\" width=\"\(width)\" height=\"\(WebsitesStage.toolbarHeight.svgNumber)\" fill=\"\(browser.toolbar)\"/>",
            "<rect x=\"\(left)\" y=\"\(pageTop.svgNumber)\" width=\"\(width)\" height=\"\(pageHeight.svgNumber)\" fill=\"\(browser.page)\"/>",
            "<path d=\"M\(left) \(separatorY.svgNumber) H\(separatorEnd.svgNumber)\" stroke=\"\(browser.separator)\" stroke-width=\"1\" opacity=\"0.6\"/>",
        ]
        let lightsCentreY = window.y + WebsitesStage.stripHeight / 2 + 2
        for (lightIndex, lightColor) in trafficLights.enumerated() {
            let lightCentreX = window.x + 24 + Double(lightIndex) * 21
            parts.append("<circle cx=\"\(lightCentreX.svgNumber)\" cy=\"\(lightsCentreY.svgNumber)\" r=\"6.5\" fill=\"\(lightColor)\" stroke=\"rgba(0,0,0,0.12)\" stroke-width=\"0.5\"/>")
        }
        return parts
    }

    private static func tabParts(_ stage: WebsitesStage) -> [String] {
        let browser = stage.browserTheme
        let tabTop = WebsitesStage.tabTop
        let tabBottom = WebsitesStage.window.y + WebsitesStage.stripHeight
        let titleCentreY = tabTop + (WebsitesStage.stripHeight - 8) / 2
        let titleFontSize = 12 * ReadmeCanvas.interfaceScale
        var parts: [String] = []
        for (websiteIndex, website) in stage.websites.enumerated() {
            let left = stage.tabLeft(websiteIndex)
            let activeEvents = stage.activeSteps(for: websiteIndex)
            let activeStyle = stage.sheet.style(.opacity, activeEvents)
            let shape = tabShape(left: left, top: tabTop, bottom: tabBottom)
            parts.append("<path d=\"\(shape)\" fill=\"\(browser.toolbar)\" style=\"\(activeStyle)\"/>")
            if websiteIndex > 0 {
                let separatorTop = tabTop + 12
                let separatorBottom = tabBottom - 10
                parts.append("<path d=\"M\(left.svgNumber) \(separatorTop.svgNumber) V\(separatorBottom.svgNumber)\" stroke=\"\(browser.separator)\" stroke-width=\"1\"/>")
            }
            let titleEvents = activeEvents.map { activeEvent in
                AnimationEvent(time: activeEvent.time, value: inactiveTitleOpacity + (1 - inactiveTitleOpacity) * activeEvent.value)
            }
            let titleStyle = stage.sheet.style(.opacity, titleEvents)
            let iconLeft = left + 14
            let iconTop = titleCentreY - 9
            parts.append("<use href=\"#icon-\(website.iconName)\" x=\"\(iconLeft.svgNumber)\" y=\"\(iconTop.svgNumber)\" width=\"18\" height=\"18\"/>")
            let titleLeft = left + 42
            let titleBaseline = titleCentreY + 5
            let escapedTitle = website.title.xmlEscaped
            parts.append("<text x=\"\(titleLeft.svgNumber)\" y=\"\(titleBaseline.svgNumber)\" font-family=\"\(ReadmeCanvas.systemFontFamily)\" font-size=\"\(titleFontSize.svgNumber)\" fill=\"\(stage.theme.ink)\" style=\"\(titleStyle)\">\(escapedTitle)</text>")
            let closeButton = stage.symbols.markup("xmark", centreX: left + WebsitesStage.tabWidth - 20, centreY: titleCentreY, height: 9, opacity: 0.5)
            parts.append(closeButton)
        }
        let tabsEnd = stage.tabLeft(stage.websites.count)
        let newTabButton = stage.symbols.markup("plus", centreX: tabsEnd + 22, centreY: WebsitesStage.window.y + WebsitesStage.stripHeight / 2 + 2, height: 13, opacity: 0.65)
        parts.append(newTabButton)
        return parts
    }

    private static func tabShape(left: Double, top: Double, bottom: Double) -> String {
        let radius = tabCornerRadius
        let right = left + WebsitesStage.tabWidth
        let start = "M\((left - radius).svgNumber) \(bottom.svgNumber) Q\(left.svgNumber) \(bottom.svgNumber) \(left.svgNumber) \((bottom - radius).svgNumber) "
        let leftSide = "V\((top + radius).svgNumber) Q\(left.svgNumber) \(top.svgNumber) \((left + radius).svgNumber) \(top.svgNumber) "
        let topSide = "H\((right - radius).svgNumber) Q\(right.svgNumber) \(top.svgNumber) \(right.svgNumber) \((top + radius).svgNumber) "
        let rightSide = "V\((bottom - radius).svgNumber) Q\(right.svgNumber) \(bottom.svgNumber) \((right + radius).svgNumber) \(bottom.svgNumber) Z"
        return "\(start)\(leftSide)\(topSide)\(rightSide)"
    }

    private static func toolbarParts(_ stage: WebsitesStage) -> [String] {
        let window = WebsitesStage.window
        let toolbarCentre = window.y + WebsitesStage.stripHeight + WebsitesStage.toolbarHeight / 2
        var parts: [String] = []
        for (symbolIndex, symbolName) in toolbarSymbols.enumerated() {
            let symbolCentreX = window.x + 26 + Double(symbolIndex) * 36
            let opacity = symbolIndex == 1 ? 0.32 : 0.7
            let symbol = stage.symbols.markup(symbolName, centreX: symbolCentreX, centreY: toolbarCentre, height: 15, opacity: opacity)
            parts.append(symbol)
        }
        let omniboxLeft = window.x + omniboxInset
        let omniboxWidth = window.width - omniboxInset - omniboxEndMargin
        let omniboxTop = toolbarCentre - omniboxHeight / 2
        let omniboxRadius = omniboxHeight / 2
        parts.append("<rect x=\"\(omniboxLeft.svgNumber)\" y=\"\(omniboxTop.svgNumber)\" width=\"\(omniboxWidth.svgNumber)\" height=\"\(omniboxHeight.svgNumber)\" rx=\"\(omniboxRadius.svgNumber)\" fill=\"\(stage.browserTheme.omnibox)\"/>")
        let siteSettings = stage.symbols.markup("slider.horizontal.3", centreX: omniboxLeft + 20, centreY: toolbarCentre, height: 13, opacity: 0.6)
        parts.append(siteSettings)
        let hostLeft = omniboxLeft + 40
        let hostBaseline = toolbarCentre + hostBaselineDrop
        let hostFontSize = 12.5 * ReadmeCanvas.interfaceScale
        for (websiteIndex, website) in stage.websites.enumerated() {
            let activeEvents = stage.activeSteps(for: websiteIndex)
            let style = stage.sheet.style(.opacity, activeEvents)
            let escapedHost = website.host.xmlEscaped
            parts.append("<text x=\"\(hostLeft.svgNumber)\" y=\"\(hostBaseline.svgNumber)\" font-family=\"\(ReadmeCanvas.systemFontFamily)\" font-size=\"\(hostFontSize.svgNumber)\" fill=\"\(stage.theme.ink)\" style=\"\(style)\">\(escapedHost)</text>")
        }
        return parts
    }
}
