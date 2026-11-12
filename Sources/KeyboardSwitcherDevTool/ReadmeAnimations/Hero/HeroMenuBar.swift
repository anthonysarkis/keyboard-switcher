enum HeroMenuBar {
    private static let menuTitles = ["File", "Edit", "View", "Window", "Help"]
    private static let badgeDelay = 0.06

    static func markup(_ stage: HeroStage) -> String {
        let layout = stage.menuBar
        let background = layout.background(stage.theme)
        let appleLogo = layout.appleLogo(stage.symbols)
        var parts = [background, appleLogo]
        for (appIndex, app) in stage.apps.enumerated() {
            let segment = stage.schedule.segments[appIndex]
            let shownPoints = [
                AnimationEvent(time: segment.activation, value: 1),
                AnimationEvent(time: segment.nextActivation, value: 0),
            ]
            let shownEvents = AnimationEvents.steps(shownPoints)
            let style = stage.sheet.style(.opacity, shownEvents)
            let menus = menuTexts(for: app, layout: layout)
            parts.append("<g style=\"\(style)\">\(menus)</g>")
        }
        let clock = layout.clock()
        let battery = layout.battery(stage.symbols)
        let wifi = layout.wifi(stage.symbols)
        parts += [clock, battery, wifi]
        for (appIndex, app) in stage.apps.enumerated() {
            let segment = stage.schedule.segments[appIndex]
            let shownPoints = [
                AnimationEvent(time: segment.activation + badgeDelay, value: 1),
                AnimationEvent(time: segment.nextActivation + badgeDelay, value: 0),
            ]
            let shownEvents = AnimationEvents.steps(shownPoints)
            let style = stage.sheet.style(.opacity, shownEvents)
            let badge = ReadmeExample.macBadge(for: app.keyboard)
            let badgeMarkup = BadgeMarkup.badge(
                badge, x: layout.badgeLeft, y: layout.badgeTop, scale: ReadmeCanvas.interfaceScale, color: stage.theme.ink, maskID: "menu-badge-\(appIndex)"
            )
            parts.append("<g style=\"\(style)\">\(badgeMarkup)</g>")
        }
        return layout.group(parts, theme: stage.theme)
    }

    private static func menuTexts(for app: ReadmeExampleApp, layout: MenuBarLayout) -> String {
        let appNameFont = layout.appNameFont
        let menuFont = layout.menuFont
        let baseline = layout.baseline.svgNumber
        var left = layout.firstMenuLeft
        let escapedAppName = app.menuTitle.xmlEscaped
        var texts = ["<text x=\"\(left.svgNumber)\" y=\"\(baseline)\" font-weight=\"700\">\(escapedAppName)</text>"]
        let appNameWidth = TextMeasure.width(of: app.menuTitle, in: appNameFont)
        left += appNameWidth + layout.spacing
        for menuTitle in menuTitles {
            texts.append("<text x=\"\(left.svgNumber)\" y=\"\(baseline)\">\(menuTitle)</text>")
            let menuWidth = TextMeasure.width(of: menuTitle, in: menuFont)
            left += menuWidth + layout.spacing
        }
        return texts.joined()
    }
}
