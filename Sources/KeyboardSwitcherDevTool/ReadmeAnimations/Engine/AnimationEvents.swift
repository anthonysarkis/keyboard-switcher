import Foundation

enum AnimationEvents {
    static let stepGap = 0.0006

    static func window(from start: Double, to end: Double, fadeIn: Double, fadeOut: Double, low: Double = 0, high: Double = 1) -> [AnimationEvent] {
        [
            AnimationEvent(time: start, value: low),
            AnimationEvent(time: start + fadeIn, value: high),
            AnimationEvent(time: end, value: high),
            AnimationEvent(time: end + fadeOut, value: low),
        ]
    }

    static func steps(_ points: [AnimationEvent]) -> [AnimationEvent] {
        guard var previousValue = points.last?.value else { return [] }
        var events: [AnimationEvent] = []
        for point in points {
            let lastMomentBefore = AnimationEvent(time: point.time - stepGap, value: previousValue)
            events.append(lastMomentBefore)
            events.append(point)
            previousValue = point.value
        }
        return events
    }

    static func easedOut(from start: Double, to end: Double, startValue: Double, endValue: Double, stepCount: Int = 4) -> [AnimationEvent] {
        (0...stepCount).map { step in
            let progress = Double(step) / Double(stepCount)
            let remaining = 1 - progress
            let remainingCubed = pow(remaining, 3)
            let easedProgress = 1 - remainingCubed
            let time = start + (end - start) * progress
            let value = startValue + (endValue - startValue) * easedProgress
            return AnimationEvent(time: time, value: value)
        }
    }
}
