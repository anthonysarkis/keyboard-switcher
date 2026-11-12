struct AnimationEvent: Comparable {
    let time: Double
    let value: Double

    static func < (first: AnimationEvent, second: AnimationEvent) -> Bool {
        if first.time != second.time {
            return first.time < second.time
        }
        return first.value < second.value
    }
}
