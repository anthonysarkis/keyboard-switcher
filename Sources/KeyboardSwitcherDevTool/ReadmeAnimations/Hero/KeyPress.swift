struct KeyPress: Comparable {
    let keyCode: Int
    let down: Double
    let up: Double

    static func < (first: KeyPress, second: KeyPress) -> Bool {
        if first.down != second.down {
            return first.down < second.down
        }
        return first.up < second.up
    }
}
