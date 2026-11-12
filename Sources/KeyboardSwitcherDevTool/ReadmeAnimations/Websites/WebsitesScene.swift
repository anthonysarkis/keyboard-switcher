enum WebsitesScene {
    private static let restAfterSwitch = 1.75
    private static let bottomMargin = 6.0
    private static let pointerTravel = 0.6
    private static let pointerSteps = 8
    private static let bubbleDelayAfterSwitch = 0.02

    static func picture(websites: [ReadmeExampleWebsite], theme: AnimationTheme) throws -> AnimatedPicture {
        let period = WebsitesStage.switchStep * Double(websites.count)
        let timeline = AnimationTimeline(period: period, rest: WebsitesStage.readDelay + restAfterSwitch)
        let stage = WebsitesStage(
            websites: websites, theme: theme, browserTheme: BrowserTheme.matching(theme), symbols: theme.symbolPictures(),
            sheet: KeyframeSheet(timeline: timeline), menuBar: MenuBarLayout()
        )
        let window = WebsitesStage.window
        let canvasHeight = window.y + window.height + bottomMargin

        var definitions: [String] = []
        for website in websites {
            let iconDefinition = try AppIconPictures.symbolDefinition(for: website.iconName)
            definitions.append(iconDefinition)
        }
        let windowDefinitions = BrowserWindowDrawing.definitions()
        definitions.append(windowDefinitions)

        let menuBarMarkup = WebsitesMenuBar.markup(stage)
        let windowMarkup = BrowserWindowDrawing.markup(stage)
        let pointerStyle = pointerStyle(stage)
        let bubbles = bubbles(stage)
        let pointerArrow = PointerMarkup.arrow(x: 0, y: stage.tabTitleTop)
        let pointerMarkup = "<g style=\"\(pointerStyle)\">\(pointerArrow)</g>"
        let document = SVGDocument(
            width: ReadmeCanvas.width, height: canvasHeight, label: ReadmeExample.websitesDescription, leadingStyle: ReadmeCanvas.textStyle,
            keyframeRules: stage.sheet.rules, definitions: definitions, body: [menuBarMarkup, windowMarkup, bubbles, pointerMarkup]
        )
        return AnimatedPicture(fileName: "websites-\(theme.name).svg", markup: document.markup, width: ReadmeCanvas.width, height: canvasHeight, loopSeconds: period)
    }

    private static func pointerStyle(_ stage: WebsitesStage) -> String {
        let websiteCount = stage.websites.count
        var positions: [AnimationEvent] = []
        for websiteIndex in stage.websites.indices {
            let previousIndex = (websiteIndex - 1 + websiteCount) % websiteCount
            let arrival = stage.arrivals[websiteIndex]
            let previousX = stage.pointerX(onTab: previousIndex)
            let targetX = stage.pointerX(onTab: websiteIndex)
            positions += AnimationEvents.easedOut(from: arrival - pointerTravel, to: arrival, startValue: previousX, endValue: targetX, stepCount: pointerSteps)
        }
        let numberedPositions = Array(positions.enumerated())
        let orderedPositions = numberedPositions.sorted { first, second in
            if first.element.time != second.element.time {
                return first.element.time < second.element.time
            }
            return first.offset < second.offset
        }
        let orderedEvents = orderedPositions.map(\.element)
        return stage.sheet.style(.translateX, orderedEvents)
    }

    private static func bubbles(_ stage: WebsitesStage) -> String {
        let bubbles = stage.websites.enumerated().map { websiteIndex, website in
            let origin = BubbleMarkup.origin(belowPointerAtX: stage.pointerX(onTab: websiteIndex), y: stage.tabTitleTop)
            let shownTime = stage.arrivals[websiteIndex] + WebsitesStage.readDelay + bubbleDelayAfterSwitch
            let shownEvents = BubbleMarkup.visibleEvents(shownAt: shownTime)
            let style = stage.sheet.style(.opacity, shownEvents)
            let badge = ReadmeExample.macBadge(for: website.keyboard)
            let bubble = BubbleMarkup(keyboardName: website.keyboard.name, badge: badge)
            return bubble.markup(x: origin.x, y: origin.y, style: style, theme: stage.theme, maskID: "tabs-bubble-badge-\(websiteIndex)")
        }
        return bubbles.joined()
    }
}
