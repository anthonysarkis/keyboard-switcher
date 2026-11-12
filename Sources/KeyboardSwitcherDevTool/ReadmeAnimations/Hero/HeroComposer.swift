enum HeroComposer {
    private static let cornerRadius = 18.0
    private static let shadowMargin = 28.0
    private static let iconSize = 38.0
    private static let iconInset = 13.0
    private static let textInset = 66.0
    private static let iconFade = 0.16
    private static let sendDuration = 0.3
    private static let sendLift = -18.0
    private static let resetAfterNextSwitch = 0.5
    private static let vanishAfterSend = 0.4
    private static let baselineFactor = 0.355
    private static let caretHeight = 26.0
    private static let caretLeadIn = 0.3
    private static let caretBackAfterSend = 0.2
    private static let blinkHalfPeriod = 0.5
    private static let blinkPauseAfterTyping = 0.5
    private static let blinkEndMargin = 0.05
    private static let unbreakableSpace = "\u{00A0}"

    static func markup(_ stage: HeroStage) -> String {
        let composer = stage.composer
        let shadowShape = ShadowShape(
            width: composer.width, height: composer.height, cornerRadius: cornerRadius, margin: shadowMargin, layers: ShadowShape.floatingLayers
        )
        let shadow = ShadowPainter.markup(shadowShape, x: composer.x, y: composer.y, opacity: stage.theme.shadowOpacity)
        let box = "<rect x=\"\(composer.x.svgNumber)\" y=\"\(composer.y.svgNumber)\" width=\"\(composer.width.svgNumber)\" height=\"\(composer.height.svgNumber)\" rx=\"\(cornerRadius.svgNumber)\" fill=\"\(stage.theme.composerFill)\" stroke=\"\(stage.theme.composerStroke)\"/>"
        var parts = [shadow, box]
        let icons = appIcons(stage)
        let messages = typedMessages(stage)
        let caret = caret(stage)
        parts += icons
        parts += messages
        parts.append(caret)
        let joinedParts = parts.joined()
        return "<g>\(joinedParts)</g>"
    }

    private static func appIcons(_ stage: HeroStage) -> [String] {
        let composer = stage.composer
        let iconLeft = composer.x + iconInset
        let iconTop = composer.y + (composer.height - iconSize) / 2
        return stage.apps.enumerated().map { appIndex, app in
            let segment = stage.schedule.segments[appIndex]
            let shownEvents = AnimationEvents.window(from: segment.activation, to: segment.nextActivation, fadeIn: iconFade, fadeOut: iconFade)
            let style = stage.sheet.style(.opacity, shownEvents)
            return "<use href=\"#icon-\(app.iconName)\" x=\"\(iconLeft.svgNumber)\" y=\"\(iconTop.svgNumber)\" width=\"\(iconSize.svgNumber)\" height=\"\(iconSize.svgNumber)\" style=\"\(style)\"/>"
        }
    }

    private static func typedMessages(_ stage: HeroStage) -> [String] {
        let composer = stage.composer
        let textLeft = composer.x + textInset
        return stage.schedule.segments.map { segment in
            let app = stage.apps[segment.appIndex]
            let fontSize = app.typedFont.size
            let baseline = composer.middleY + fontSize * baselineFactor
            let groupStyle = messageGroupStyle(for: segment, sheet: stage.sheet)
            let spans = characterSpans(of: app, segment: segment, stage: stage)
            let family = app.typedFont.svgFamily
            return "<g style=\"\(groupStyle)\"><text x=\"\(textLeft.svgNumber)\" y=\"\(baseline.svgNumber)\" font-family=\"\(family)\" font-size=\"\(fontSize.svgNumber)\" style=\"white-space:pre;font-kerning:none;font-variant-ligatures:none\">\(spans)</text></g>"
        }
    }

    private static func messageGroupStyle(for segment: HeroSegment, sheet: KeyframeSheet) -> String {
        let resetTime = segment.nextActivation + resetAfterNextSwitch
        let fadingOut = AnimationEvents.easedOut(from: segment.send, to: segment.send + sendDuration, startValue: 1, endValue: 0)
        let opacityEvents = [AnimationEvent(time: segment.activation, value: 1)] + fadingOut + [
            AnimationEvent(time: resetTime, value: 0),
            AnimationEvent(time: resetTime + AnimationEvents.stepGap, value: 1),
        ]
        let liftingUp = AnimationEvents.easedOut(from: segment.send, to: segment.send + sendDuration, startValue: 0, endValue: sendLift)
        let moveEvents = [AnimationEvent(time: segment.activation, value: 0)] + liftingUp + [
            AnimationEvent(time: resetTime, value: sendLift),
            AnimationEvent(time: resetTime + AnimationEvents.stepGap, value: 0),
        ]
        let opacityTrack = sheet.track(.opacity, opacityEvents)
        let moveTrack = sheet.track(.translateY, moveEvents)
        return sheet.style(of: [opacityTrack, moveTrack])
    }

    private static func characterSpans(of app: ReadmeExampleApp, segment: HeroSegment, stage: HeroStage) -> String {
        let characters = Array(app.typedText)
        let vanishTime = segment.send + vanishAfterSend
        var spans = ""
        for (characterIndex, character) in characters.enumerated() {
            let appearTime = segment.characterTimes[characterIndex]
            let shownPoints = [AnimationEvent(time: appearTime, value: 1), AnimationEvent(time: vanishTime, value: 0)]
            let shownEvents = AnimationEvents.steps(shownPoints)
            let style = stage.sheet.style(.opacity, shownEvents)
            let color = codeColor(ofCharacterAt: characterIndex, in: characters, app: app, theme: stage.theme)
            let characterText = String(character)
            let shownText = character == " " ? unbreakableSpace : characterText.xmlEscaped
            spans += "<tspan fill=\"\(color)\" style=\"\(style)\">\(shownText)</tspan>"
        }
        return spans
    }

    private static func codeColor(ofCharacterAt index: Int, in characters: [Character], app: ReadmeExampleApp, theme: AnimationTheme) -> String {
        guard app.typedFont.isCode else { return theme.ink }
        let functionEnd = characters.firstIndex(of: "(") ?? 0
        if index < functionEnd {
            return theme.codeFunction
        }
        guard let stringStart = characters.firstIndex(of: "\""), let stringEnd = characters.lastIndex(of: "\"") else { return theme.ink }
        return (stringStart...stringEnd).contains(index) ? theme.codeString : theme.ink
    }

    private static func caret(_ stage: HeroStage) -> String {
        var positionEvents: [AnimationEvent] = []
        var visibilityEvents: [AnimationEvent] = []
        for segment in stage.schedule.segments {
            let app = stage.apps[segment.appIndex]
            let offsets = TextMeasure.characterOffsets(of: app.typedText, in: app.typedFont.font)
            var positionPoints = [AnimationEvent(time: segment.activation - caretLeadIn, value: offsets[0])]
            for (characterIndex, appearTime) in segment.characterTimes.enumerated() {
                let point = AnimationEvent(time: appearTime, value: offsets[characterIndex + 1])
                positionPoints.append(point)
            }
            let backToStart = AnimationEvent(time: segment.send + caretBackAfterSend, value: 0)
            positionPoints.append(backToStart)
            positionEvents += AnimationEvents.steps(positionPoints)

            visibilityEvents += [
                AnimationEvent(time: segment.activation, value: 1),
                AnimationEvent(time: segment.typeStart, value: 1),
            ]
            visibilityEvents += blinking(from: segment.lastCharacter + blinkPauseAfterTyping, to: segment.send)
            let hiddenAtSend = AnimationEvent(time: segment.send, value: 0)
            visibilityEvents.append(hiddenAtSend)
            visibilityEvents += blinking(from: segment.send + caretBackAfterSend, to: segment.nextActivation)
        }
        let orderedVisibility = stableSortedByTime(visibilityEvents)
        let orderedPositions = stableSortedByTime(positionEvents)
        let visibilitySteps = AnimationEvents.steps(orderedVisibility)
        let positionStyle = stage.sheet.style(.translateX, orderedPositions)
        let blinkStyle = stage.sheet.style(.opacity, visibilitySteps)
        let composer = stage.composer
        let caretLeft = composer.x + textInset - 1
        let caretTop = composer.middleY - caretHeight / 2
        return "<g style=\"\(positionStyle)\"><rect x=\"\(caretLeft.svgNumber)\" y=\"\(caretTop.svgNumber)\" width=\"2\" height=\"\(caretHeight.svgNumber)\" rx=\"1\" fill=\"\(stage.theme.caret)\" style=\"\(blinkStyle)\"/></g>"
    }

    private static func blinking(from start: Double, to end: Double) -> [AnimationEvent] {
        var events: [AnimationEvent] = []
        var time = start
        var isVisible = true
        while time < end - blinkEndMargin {
            let event = AnimationEvent(time: time, value: isVisible ? 1 : 0)
            events.append(event)
            time += blinkHalfPeriod
            isVisible.toggle()
        }
        return events
    }

    private static func stableSortedByTime(_ events: [AnimationEvent]) -> [AnimationEvent] {
        let numberedEvents = Array(events.enumerated())
        let orderedEvents = numberedEvents.sorted { first, second in
            if first.element.time != second.element.time {
                return first.element.time < second.element.time
            }
            return first.offset < second.offset
        }
        return orderedEvents.map(\.element)
    }
}
