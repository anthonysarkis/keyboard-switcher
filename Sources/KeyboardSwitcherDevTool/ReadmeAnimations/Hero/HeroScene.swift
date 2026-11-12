enum HeroScene {
    private static let composer = SceneRect(x: 150, y: 70, width: 580, height: 62)
    private static let keyboardLeft = 40.0
    private static let keyboardTop = 176.0
    private static let keyboardWidth = 800.0
    private static let bottomMargin = 34.0
    private static let pointerLeftOfComposerEnd = 128.0
    private static let pointerBelowComposerTop = 22.0

    static func picture(apps: [ReadmeExampleApp], layouts: [KeyboardLayoutKeys], theme: AnimationTheme) throws -> AnimatedPicture {
        let keyboard = MacKeyboardGeometry(left: keyboardLeft, top: keyboardTop, width: keyboardWidth)
        let canvasHeight = (keyboard.top + keyboard.height + bottomMargin).rounded()
        let schedule = try HeroSchedule(apps: apps, layouts: layouts, keyboard: keyboard)
        let sheet = KeyframeSheet(timeline: schedule.timeline)
        let symbols = theme.symbolPictures()
        let menuBar = MenuBarLayout()
        let stage = HeroStage(
            apps: apps, layouts: layouts, keyboard: keyboard, schedule: schedule, theme: theme, symbols: symbols, sheet: sheet,
            menuBar: menuBar, composer: composer, pointerX: composer.maxX - pointerLeftOfComposerEnd, pointerY: composer.y + pointerBelowComposerTop
        )

        var definitions = [gradients(theme)]
        for app in apps {
            let iconDefinition = try AppIconPictures.symbolDefinition(for: app.iconName)
            definitions.append(iconDefinition)
        }
        let menuBarMarkup = HeroMenuBar.markup(stage)
        let composerMarkup = HeroComposer.markup(stage)
        let bubblesMarkup = HeroBubbles.markup(stage)
        let keyboardMarkup = HeroKeyboardDrawing.markup(stage)
        let switcherMarkup = HeroSwitcher.markup(stage)
        let pointerMarkup = PointerMarkup.arrow(x: stage.pointerX, y: stage.pointerY)
        let document = SVGDocument(
            width: ReadmeCanvas.width, height: canvasHeight, label: ReadmeExample.heroDescription, leadingStyle: ReadmeCanvas.textStyle,
            keyframeRules: sheet.rules, definitions: definitions,
            body: [menuBarMarkup, composerMarkup, keyboardMarkup, bubblesMarkup, switcherMarkup, pointerMarkup]
        )
        return AnimatedPicture(
            fileName: "hero-\(theme.name).svg", markup: document.markup, width: ReadmeCanvas.width, height: canvasHeight,
            loopSeconds: schedule.timeline.period
        )
    }

    private static func gradients(_ theme: AnimationTheme) -> String {
        let plate = "<linearGradient id=\"plate\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\"><stop offset=\"0\" stop-color=\"\(theme.plateTop)\"/><stop offset=\"1\" stop-color=\"\(theme.plateBottom)\"/></linearGradient>"
        let cap = "<linearGradient id=\"cap\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\"><stop offset=\"0\" stop-color=\"\(theme.capTop)\"/><stop offset=\"1\" stop-color=\"\(theme.capBottom)\"/></linearGradient>"
        return "\(plate)\(cap)\(PointerMarkup.shadowFilter)"
    }
}
