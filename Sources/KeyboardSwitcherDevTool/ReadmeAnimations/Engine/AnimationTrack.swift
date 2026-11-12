struct AnimationTrack {
    private static let sameTimeTolerance = 1e-9

    let property: AnimatedProperty
    let events: [AnimationEvent]
    private let period: Double

    init(_ property: AnimatedProperty, events sceneEvents: [AnimationEvent], on timeline: AnimationTimeline) {
        self.property = property
        period = timeline.period
        let realEvents = sceneEvents.map { sceneEvent in
            let realTime = timeline.realTime(of: sceneEvent.time)
            return AnimationEvent(time: realTime, value: sceneEvent.value)
        }
        let numberedEvents = Array(realEvents.enumerated())
        let orderedEvents = numberedEvents.sorted { first, second in
            if first.element.time != second.element.time {
                return first.element.time < second.element.time
            }
            return first.offset < second.offset
        }
        events = orderedEvents.map(\.element)
    }

    func value(at time: Double) -> Double {
        guard let firstEvent = events.first, let lastEvent = events.last else { return 0 }
        let wrappedBefore = AnimationEvent(time: lastEvent.time - period, value: lastEvent.value)
        let wrappedAfter = AnimationEvent(time: firstEvent.time + period, value: firstEvent.value)
        let extendedEvents = [wrappedBefore] + events + [wrappedAfter]
        for index in 0..<(extendedEvents.count - 1) {
            let start = extendedEvents[index]
            let end = extendedEvents[index + 1]
            guard start.time <= time, time <= end.time else { continue }
            if end.time - start.time < Self.sameTimeTolerance {
                return end.value
            }
            let progress = (time - start.time) / (end.time - start.time)
            return start.value + (end.value - start.value) * progress
        }
        return firstEvent.value
    }

    func declaration(at time: Double) -> String {
        let valueAtTime = value(at: time)
        return property.declaration(for: valueAtTime)
    }
}
