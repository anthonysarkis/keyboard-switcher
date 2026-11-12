struct MacKeyboardGeometry {
    private static let functionKeys = [
        ("F1", "sun.min"), ("F2", "sun.max"), ("F3", "rectangle.3.group"), ("F4", "magnifyingglass"),
        ("F5", "mic"), ("F6", "moon"), ("F7", "backward"), ("F8", "playpause"), ("F9", "forward"),
        ("F10", "speaker.slash"), ("F11", "speaker.wave.1"), ("F12", "speaker.wave.3"),
    ]
    private static let numberRowKeyCodes: [Int?] = [nil, 18, 19, 20, 21, 23, 22, 26, 28, 25, 29, 27, 24]
    private static let topLetterRowKeyCodes = [12, 13, 14, 15, 17, 16, 32, 34, 31, 35, 33, 30, 42]
    private static let middleLetterRowKeyCodes = [0, 1, 2, 3, 5, 4, 38, 40, 37, 41, 39]
    private static let bottomLetterRowKeyCodes = [6, 7, 8, 9, 11, 45, 46, 43, 47, 44]
    private static let arrowScale = 0.55

    let left: Double
    let top: Double
    let width: Double
    let unit: Double
    let height: Double
    private let margin: Double
    private let gap: Double
    private let functionRowPitch: Double
    private(set) var keys: [KeyboardKey] = []

    init(left: Double, top: Double, width: Double) {
        self.left = left
        self.top = top
        self.width = width
        unit = width / 15.04
        margin = 0.27 * unit
        gap = 0.16 * unit
        functionRowPitch = 0.62 * unit
        height = 6.16 * unit
        addFunctionRow()
        addNumberRow()
        addLetterRows()
        addBottomRow()
    }

    var middle: Double {
        left + width / 2
    }

    private mutating func addFunctionRow() {
        add(row: 0, at: 0, width: 1.5, legend: .word("esc", anchor: .start))
        for (index, functionKey) in Self.functionKeys.enumerated() {
            let position = 1.5 + Double(index)
            add(row: 0, at: position, width: 1, legend: .function(label: functionKey.0, symbolName: functionKey.1))
        }
        add(row: 0, at: 13.5, width: 1, legend: .symbol("lock"))
    }

    private mutating func addNumberRow() {
        for (index, keyCode) in Self.numberRowKeyCodes.enumerated() {
            let identity: KeyIdentity = keyCode.map { code in .code(code) } ?? .topLeft
            let position = Double(index)
            add(row: 1, at: position, width: 1, identity: identity)
        }
        add(row: 1, at: 13, width: 1.5, identity: .code(51), legend: .word("delete", anchor: .end))
    }

    private mutating func addLetterRows() {
        add(row: 2, at: 0, width: 1.5, identity: .code(48), legend: .word("tab", anchor: .start))
        addLetterKeys(Self.topLetterRowKeyCodes, row: 2, startingAt: 1.5)
        add(row: 3, at: 0, width: 1.75, identity: .code(57), legend: .word("caps lock", anchor: .start, hasLight: true))
        addLetterKeys(Self.middleLetterRowKeyCodes, row: 3, startingAt: 1.75)
        add(row: 3, at: 12.75, width: 1.75, identity: .code(36), legend: .word("return", anchor: .end))
        add(row: 4, at: 0, width: 2.25, identity: .code(56), legend: .word("shift", anchor: .start))
        addLetterKeys(Self.bottomLetterRowKeyCodes, row: 4, startingAt: 2.25)
        add(row: 4, at: 12.25, width: 2.25, identity: .code(60), legend: .word("shift", anchor: .end))
    }

    private mutating func addLetterKeys(_ keyCodes: [Int], row: Int, startingAt firstPosition: Double) {
        for (index, keyCode) in keyCodes.enumerated() {
            let position = firstPosition + Double(index)
            add(row: row, at: position, width: 1, identity: .code(keyCode))
        }
    }

    private mutating func addBottomRow() {
        add(row: 5, at: 0, width: 1, identity: .code(63), legend: .globe)
        add(row: 5, at: 1, width: 1, identity: .code(59), legend: .modifier(symbol: "⌃", label: "control", side: .left))
        add(row: 5, at: 2, width: 1, identity: .code(58), legend: .modifier(symbol: "⌥", label: "option", side: .left))
        add(row: 5, at: 3, width: 1.25, identity: .code(55), legend: .modifier(symbol: "⌘", label: "command", side: .left))
        add(row: 5, at: 4.25, width: 5, identity: .code(49))
        add(row: 5, at: 9.25, width: 1.25, identity: .code(54), legend: .modifier(symbol: "⌘", label: "command", side: .right))
        add(row: 5, at: 10.5, width: 1, identity: .code(61), legend: .modifier(symbol: "⌥", label: "option", side: .right))
        add(row: 5, at: 11.5, width: 1, identity: .code(123), legend: .symbol("arrowtriangle.left.fill", scale: Self.arrowScale), keyHeight: .lowerHalf)
        add(row: 5, at: 12.5, width: 1, identity: .code(126), legend: .symbol("arrowtriangle.up.fill", scale: Self.arrowScale), keyHeight: .upperHalf)
        add(row: 5, at: 12.5, width: 1, identity: .code(125), legend: .symbol("arrowtriangle.down.fill", scale: Self.arrowScale), keyHeight: .lowerHalf)
        add(row: 5, at: 13.5, width: 1, identity: .code(124), legend: .symbol("arrowtriangle.right.fill", scale: Self.arrowScale), keyHeight: .lowerHalf)
    }

    private mutating func add(row: Int, at position: Double, width widthInUnits: Double, identity: KeyIdentity = .withoutKeyCode, legend: KeyLegend? = nil, keyHeight: KeyHeight = .full) {
        let x = left + margin + position * unit + gap / 2
        let keyWidth = widthInUnits * unit - gap
        let y: Double
        let keyHeightInPoints: Double
        if row == 0 {
            y = top + margin + gap / 2
            keyHeightInPoints = functionRowPitch - gap
        } else {
            let rowTop = top + margin + functionRowPitch + Double(row - 1) * unit
            let fullHeight = unit - gap
            switch keyHeight {
            case .full:
                y = rowTop + gap / 2
                keyHeightInPoints = fullHeight
            case .upperHalf, .lowerHalf:
                let halfGap = gap * 0.55
                let halfHeight = (fullHeight - halfGap) / 2
                y = keyHeight == .upperHalf ? rowTop + gap / 2 : rowTop + gap / 2 + halfHeight + halfGap
                keyHeightInPoints = halfHeight
            }
        }
        let key = KeyboardKey(row: row, x: x, y: y, width: keyWidth, height: keyHeightInPoints, identity: identity, legend: legend)
        keys.append(key)
    }
}
