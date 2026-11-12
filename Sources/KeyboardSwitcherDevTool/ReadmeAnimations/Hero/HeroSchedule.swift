struct HeroSchedule {
    private static let randomSeed: UInt64 = 11
    private static let typingDelayAfterSwitch = 0.95
    private static let openingAfterSwitch = 0.75
    private static let keyHoldDuration = 0.085
    private static let typingInterval = 0.083
    private static let quickestJitter = -0.018
    private static let slowestJitter = 0.026
    private static let pauseAfterSpace = 0.02
    private static let pauseAfterPunctuation = 0.07
    private static let punctuation: Set<Character> = [",", ".", "!", "?", "¡", "¿"]
    private static let shiftLead = 0.055
    private static let shiftRelease = 0.09
    private static let returnAfterLastCharacter = 0.85
    private static let returnHoldDuration = 0.1
    private static let commandAfterReturn = 0.62
    private static let tabAfterCommand = 0.24
    private static let commandHoldDuration = 0.98
    private static let tabHoldDuration = 0.11
    private static let returnKeyCode = 36
    private static let commandKeyCode = 55
    private static let tabKeyCode = 48
    private static let leftShiftKeyCode = 56
    private static let rightShiftKeyCode = 60

    let segments: [HeroSegment]
    let presses: [KeyPress]
    let timeline: AnimationTimeline

    init(apps: [ReadmeExampleApp], layouts: [KeyboardLayoutKeys], keyboard: MacKeyboardGeometry) throws {
        var randomNumbers = SeededRandomNumbers(seed: Self.randomSeed)
        let keyCentres = Self.keyCentres(of: keyboard)
        var presses: [KeyPress] = []
        var segments: [HeroSegment] = []
        var sceneTime = 0.0
        for (appIndex, app) in apps.enumerated() {
            let layout = layouts[appIndex]
            let activation = sceneTime
            let typeStart = activation + Self.typingDelayAfterSwitch
            var characterTimes: [Double] = []
            var typedKeys: [(key: TypedKey, time: Double)] = []
            var time = typeStart
            for character in app.typedText {
                let typedKey = try layout.key(typing: character)
                characterTimes.append(time)
                typedKeys.append((typedKey, time))
                let keyPress = KeyPress(keyCode: typedKey.keyCode, down: time, up: time + Self.keyHoldDuration)
                presses.append(keyPress)
                let jitter = randomNumbers.next(from: Self.quickestJitter, to: Self.slowestJitter)
                var interval = Self.typingInterval + jitter
                if character == " " {
                    interval += Self.pauseAfterSpace
                }
                if Self.punctuation.contains(character) {
                    interval += Self.pauseAfterPunctuation
                }
                time += interval
            }
            let shiftPresses = Self.shiftPresses(for: typedKeys, keyCentres: keyCentres, keyboardMiddle: keyboard.middle)
            presses += shiftPresses
            let lastCharacter = characterTimes.last ?? typeStart
            let send = lastCharacter + Self.returnAfterLastCharacter
            let commandDown = send + Self.commandAfterReturn
            let tabDown = commandDown + Self.tabAfterCommand
            let nextActivation = commandDown + Self.commandHoldDuration
            presses += [
                KeyPress(keyCode: Self.returnKeyCode, down: send, up: send + Self.returnHoldDuration),
                KeyPress(keyCode: Self.commandKeyCode, down: commandDown, up: commandDown + Self.commandHoldDuration),
                KeyPress(keyCode: Self.tabKeyCode, down: tabDown, up: tabDown + Self.tabHoldDuration),
            ]
            let segment = HeroSegment(
                appIndex: appIndex, activation: activation, typeStart: typeStart, characterTimes: characterTimes,
                lastCharacter: lastCharacter, send: send, commandDown: commandDown, tabDown: tabDown, nextActivation: nextActivation
            )
            segments.append(segment)
            sceneTime = nextActivation
        }
        let openingTime = (segments.first?.activation ?? 0) + Self.openingAfterSwitch
        self.segments = segments
        self.presses = presses
        timeline = AnimationTimeline(period: sceneTime, rest: openingTime)
    }

    private static func keyCentres(of keyboard: MacKeyboardGeometry) -> [Int: Double] {
        var keyCentres: [Int: Double] = [:]
        for key in keyboard.keys {
            guard let keyCode = key.identity.keyCode else { continue }
            keyCentres[keyCode] = key.centreX
        }
        return keyCentres
    }

    private static func shiftPresses(for typedKeys: [(key: TypedKey, time: Double)], keyCentres: [Int: Double], keyboardMiddle: Double) -> [KeyPress] {
        var shiftPresses: [KeyPress] = []
        var index = 0
        while index < typedKeys.count {
            let typedKey = typedKeys[index]
            guard typedKey.key.needsShift else {
                index += 1
                continue
            }
            var runEnd = index
            while runEnd + 1 < typedKeys.count, typedKeys[runEnd + 1].key.needsShift {
                runEnd += 1
            }
            let keyCentre = keyCentres[typedKey.key.keyCode] ?? 0
            let shiftKeyCode = keyCentre > keyboardMiddle ? leftShiftKeyCode : rightShiftKeyCode
            let shiftPress = KeyPress(keyCode: shiftKeyCode, down: typedKey.time - shiftLead, up: typedKeys[runEnd].time + shiftRelease)
            shiftPresses.append(shiftPress)
            index = runEnd + 1
        }
        return shiftPresses
    }
}
