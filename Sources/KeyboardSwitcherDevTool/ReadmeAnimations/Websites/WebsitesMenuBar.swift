enum WebsitesMenuBar {
    private static let browserName = "Chrome"
    private static let browserMenus = ["File", "Edit", "View", "History", "Bookmarks", "Profiles", "Tab", "Window", "Help"]

    static func markup(_ stage: WebsitesStage) -> String {
        let layout = stage.menuBar
        let background = layout.background(stage.theme)
        let appleLogo = layout.appleLogo(stage.symbols)
        let clock = layout.clock()
        let battery = layout.battery(stage.symbols)
        let wifi = layout.wifi(stage.symbols)
        var parts = [background, appleLogo, clock, battery, wifi]
        let menus = menusThatFit(layout)
        parts += menus
        for (websiteIndex, website) in stage.websites.enumerated() {
            let switchTime = stage.arrivals[websiteIndex] + WebsitesStage.readDelay
            let nextSwitchTime = stage.arrival(after: websiteIndex) + WebsitesStage.readDelay
            let shownPoints = [AnimationEvent(time: switchTime, value: 1), AnimationEvent(time: nextSwitchTime, value: 0)]
            let shownEvents = AnimationEvents.steps(shownPoints)
            let style = stage.sheet.style(.opacity, shownEvents)
            let badge = ReadmeExample.macBadge(for: website.keyboard)
            let badgeMarkup = BadgeMarkup.badge(
                badge, x: layout.badgeLeft, y: layout.badgeTop, scale: ReadmeCanvas.interfaceScale, color: stage.theme.ink, maskID: "tabs-menu-badge-\(websiteIndex)"
            )
            parts.append("<g style=\"\(style)\">\(badgeMarkup)</g>")
        }
        return layout.group(parts, theme: stage.theme)
    }

    private static func menusThatFit(_ layout: MenuBarLayout) -> [String] {
        let baseline = layout.baseline.svgNumber
        let appNameFont = layout.appNameFont
        let menuFont = layout.menuFont
        var left = layout.firstMenuLeft
        var menus = ["<text x=\"\(left.svgNumber)\" y=\"\(baseline)\" font-weight=\"700\">\(browserName)</text>"]
        let browserNameWidth = TextMeasure.width(of: browserName, in: appNameFont)
        left += browserNameWidth + layout.spacing
        for menuTitle in browserMenus {
            let menuWidth = TextMeasure.width(of: menuTitle, in: menuFont)
            guard left + menuWidth <= layout.badgeLeft - layout.spacing else { break }
            menus.append("<text x=\"\(left.svgNumber)\" y=\"\(baseline)\">\(menuTitle)</text>")
            left += menuWidth + layout.spacing
        }
        return menus
    }
}
