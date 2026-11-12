enum HeroBubbles {
    private static let delayAfterSwitch = 0.05

    static func markup(_ stage: HeroStage) -> String {
        let origin = BubbleMarkup.origin(belowPointerAtX: stage.pointerX, y: stage.pointerY)
        let bubbles = stage.apps.enumerated().map { appIndex, app in
            let segment = stage.schedule.segments[appIndex]
            let shownEvents = BubbleMarkup.visibleEvents(shownAt: segment.activation + delayAfterSwitch)
            let style = stage.sheet.style(.opacity, shownEvents)
            let badge = ReadmeExample.macBadge(for: app.keyboard)
            let bubble = BubbleMarkup(keyboardName: app.keyboard.name, badge: badge)
            return bubble.markup(x: origin.x, y: origin.y, style: style, theme: stage.theme, maskID: "bubble-badge-\(appIndex)")
        }
        let joinedBubbles = bubbles.joined()
        return "<g>\(joinedBubbles)</g>"
    }
}
