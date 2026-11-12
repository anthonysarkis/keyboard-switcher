enum HeroKeyboardDrawing {
    private static let shadowMargin = 48.0
    private static let plateLayers = [ShadowLayer(blur: 11, drop: 12, opacity: 1), ShadowLayer(blur: 1.5, drop: 1.5, opacity: 0.9)]
    private static let plateRadiusInUnits = 0.33
    private static let capRadiusInUnits = 0.085
    private static let capLip = 1.6
    private static let spaceKeyCode = 49
    private static let waveStart = 0.07
    private static let waveEnd = 0.27
    private static let waveLift = 5.0
    private static let waveExit = 0.08
    private static let waveSpread = 0.28
    private static let waveRowDelay = 0.028
    private static let pressDepth = 1.4
    private static let pressFadeOut = 0.05
    private static let pressRise = 0.04

    static func markup(_ stage: HeroStage) -> String {
        let keyboard = stage.keyboard
        let theme = stage.theme
        let plateRadius = plateRadiusInUnits * keyboard.unit
        let shadowShape = ShadowShape(width: keyboard.width, height: keyboard.height, cornerRadius: plateRadius, margin: shadowMargin, layers: plateLayers)
        let plateShadow = ShadowPainter.markup(shadowShape, x: keyboard.left, y: keyboard.top, opacity: theme.shadowOpacity)
        let plate = "<rect x=\"\(keyboard.left.svgNumber)\" y=\"\(keyboard.top.svgNumber)\" width=\"\(keyboard.width.svgNumber)\" height=\"\(keyboard.height.svgNumber)\" rx=\"\(plateRadius.svgNumber)\" fill=\"url(#plate)\" stroke=\"\(theme.plateStroke)\"/>"
        let highlightStart = keyboard.left + plateRadius
        let highlightTop = keyboard.top + 0.9
        let highlightEnd = keyboard.left + keyboard.width - plateRadius
        let highlight = "<path d=\"M\(highlightStart.svgNumber) \(highlightTop.svgNumber) H\(highlightEnd.svgNumber)\" stroke=\"\(theme.plateHighlight)\" stroke-width=\"1.2\" stroke-linecap=\"round\"/>"
        var parts = [plateShadow, plate, highlight]
        let pressesByKeyCode = Dictionary(grouping: stage.schedule.presses) { keyPress in keyPress.keyCode }
        let layoutAnimations = layoutAnimations(stage)
        for key in keyboard.keys {
            let keyMarkup = keyMarkup(key, stage: stage, layoutAnimations: layoutAnimations, pressesByKeyCode: pressesByKeyCode)
            parts.append(keyMarkup)
        }
        let joinedParts = parts.joined()
        return "<g font-family=\"\(ReadmeCanvas.systemFontFamily)\" fill=\"\(theme.legend)\">\(joinedParts)</g>"
    }

    private static func layoutAnimations(_ stage: HeroStage) -> [NamedAnimation] {
        stage.schedule.segments.map { segment in
            let start = segment.activation
            let end = segment.nextActivation
            let fadingIn = AnimationEvents.easedOut(from: start + waveStart, to: start + waveEnd, startValue: 0, endValue: 1)
            let opacityEvents = [AnimationEvent(time: start + waveStart, value: 0)] + fadingIn.dropFirst() + [
                AnimationEvent(time: end, value: 1),
                AnimationEvent(time: end + waveExit, value: 0),
            ]
            let settling = AnimationEvents.easedOut(from: start + waveStart, to: start + waveEnd, startValue: waveLift, endValue: 0)
            let moveEvents = [AnimationEvent(time: start + waveStart, value: waveLift)] + settling.dropFirst() + [
                AnimationEvent(time: end, value: 0),
                AnimationEvent(time: end + waveExit, value: -waveLift),
                AnimationEvent(time: end + waveExit + AnimationEvents.stepGap, value: waveLift),
            ]
            let opacityTrack = stage.sheet.track(.opacity, opacityEvents)
            let moveTrack = stage.sheet.track(.translateY, moveEvents)
            return stage.sheet.animation(of: [opacityTrack, moveTrack], named: "layout\(segment.appIndex)")
        }
    }

    private static func keyMarkup(_ key: KeyboardKey, stage: HeroStage, layoutAnimations: [NamedAnimation], pressesByKeyCode: [Int: [KeyPress]]) -> String {
        let theme = stage.theme
        let radius = capRadiusInUnits * stage.keyboard.unit
        let wellLeft = key.x - 1
        let wellTop = key.y - 1
        let wellWidth = key.width + 2
        let wellHeight = key.height + 2.4
        let wellRadius = radius + 1
        let well = "<rect x=\"\(wellLeft.svgNumber)\" y=\"\(wellTop.svgNumber)\" width=\"\(wellWidth.svgNumber)\" height=\"\(wellHeight.svgNumber)\" rx=\"\(wellRadius.svgNumber)\" fill=\"\(theme.well)\"/>"
        let lipTop = key.y + capLip
        let lip = "<rect x=\"\(key.x.svgNumber)\" y=\"\(lipTop.svgNumber)\" width=\"\(key.width.svgNumber)\" height=\"\(key.height.svgNumber)\" rx=\"\(radius.svgNumber)\" fill=\"\(theme.capLip)\"/>"
        let capShape = "x=\"\(key.x.svgNumber)\" y=\"\(key.y.svgNumber)\" width=\"\(key.width.svgNumber)\" height=\"\(key.height.svgNumber)\" rx=\"\(radius.svgNumber)\""
        var faceItems = ["<rect \(capShape) fill=\"url(#cap)\"/>"]
        if let legend = key.legend {
            let legendItems = HeroKeyLegends.markup(legend, on: key, unit: stage.keyboard.unit, symbols: stage.symbols, theme: theme)
            faceItems += legendItems
        } else if key.identity != .withoutKeyCode, key.identity != .code(spaceKeyCode) {
            let layoutItems = layoutLegends(on: key, stage: stage, layoutAnimations: layoutAnimations)
            faceItems += layoutItems
        }
        let keyPresses = key.identity.keyCode.flatMap { keyCode in pressesByKeyCode[keyCode] } ?? []
        guard !keyPresses.isEmpty else {
            let joinedFace = faceItems.joined()
            return "<g>\(well)\(lip)<g>\(joinedFace)</g></g>"
        }
        var overlayEvents: [AnimationEvent] = []
        var moveEvents: [AnimationEvent] = []
        for keyPress in keyPresses.sorted() {
            overlayEvents += [
                AnimationEvent(time: keyPress.down - AnimationEvents.stepGap, value: 0),
                AnimationEvent(time: keyPress.down, value: 1),
                AnimationEvent(time: keyPress.up, value: 1),
                AnimationEvent(time: keyPress.up + pressFadeOut, value: 0),
            ]
            moveEvents += [
                AnimationEvent(time: keyPress.down - AnimationEvents.stepGap, value: 0),
                AnimationEvent(time: keyPress.down, value: pressDepth),
                AnimationEvent(time: keyPress.up, value: pressDepth),
                AnimationEvent(time: keyPress.up + pressRise, value: 0),
            ]
        }
        let overlayStyle = stage.sheet.style(.opacity, overlayEvents)
        let moveStyle = stage.sheet.style(.translateY, moveEvents)
        faceItems.append("<rect \(capShape) fill=\"\(theme.pressed)\" style=\"\(overlayStyle)\"/>")
        let joinedFace = faceItems.joined()
        return "<g>\(well)\(lip)<g style=\"\(moveStyle)\">\(joinedFace)</g></g>"
    }

    private static func layoutLegends(on key: KeyboardKey, stage: HeroStage, layoutAnimations: [NamedAnimation]) -> [String] {
        let keyboard = stage.keyboard
        let singleFontSize = 0.29 * keyboard.unit
        let doubleFontSize = 0.205 * keyboard.unit
        let delay = waveSpread * (key.centreX - keyboard.left) / keyboard.width + waveRowDelay * Double(key.row)
        return stage.layouts.enumerated().map { layoutIndex, layout in
            let keyCode = key.identity == .topLeft ? layout.topLeftKeyCode : key.identity.keyCode ?? 0
            let legends = layout.printedLegends(forKeyCode: keyCode)
            let style = stage.sheet.style(playing: layoutAnimations[layoutIndex], delay: delay)
            let centreX = key.centreX.svgNumber
            let inner: String
            if legends.count == 1 {
                let text = legends[0].xmlEscaped
                let baseline = key.centreY + singleFontSize * 0.36
                inner = "<text x=\"\(centreX)\" y=\"\(baseline.svgNumber)\" font-size=\"\(singleFontSize.svgNumber)\" text-anchor=\"middle\">\(text)</text>"
            } else {
                let upper = legends[0].xmlEscaped
                let lower = legends[1].xmlEscaped
                let upperBaseline = key.centreY - 0.07 * keyboard.unit
                let lowerBaseline = key.centreY + 0.235 * keyboard.unit
                let upperText = "<text x=\"\(centreX)\" y=\"\(upperBaseline.svgNumber)\" font-size=\"\(doubleFontSize.svgNumber)\" text-anchor=\"middle\">\(upper)</text>"
                let lowerText = "<text x=\"\(centreX)\" y=\"\(lowerBaseline.svgNumber)\" font-size=\"\(doubleFontSize.svgNumber)\" text-anchor=\"middle\">\(lower)</text>"
                inner = "\(upperText)\(lowerText)"
            }
            return "<g style=\"\(style)\">\(inner)</g>"
        }
    }
}
