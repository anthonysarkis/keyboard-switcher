import Foundation

final class KeyframeSheet {
    let timeline: AnimationTimeline
    private(set) var rules: [String] = []
    private var animationCount = 0

    init(timeline: AnimationTimeline) {
        self.timeline = timeline
    }

    func track(_ property: AnimatedProperty, _ events: [AnimationEvent]) -> AnimationTrack {
        AnimationTrack(property, events: events, on: timeline)
    }

    func animation(of tracks: [AnimationTrack], named chosenName: String? = nil) -> NamedAnimation {
        var times: Set<Double> = [0, timeline.period]
        for track in tracks {
            for event in track.events {
                let notBeforeStart = max(event.time, 0)
                let clampedTime = min(notBeforeStart, timeline.period)
                times.insert(clampedTime)
            }
        }
        let orderedTimes = times.sorted()
        let name = chosenName ?? nextName()
        var stops = ""
        for time in orderedTimes {
            let percent = time / timeline.period * 100
            let percentText = String(format: "%.4f", percent)
            let declarations = tracks.map { track in track.declaration(at: time) }
            let joinedDeclarations = declarations.joined(separator: ";")
            stops += "\(percentText)%{\(joinedDeclarations)}"
        }
        rules.append("@keyframes \(name){\(stops)}")
        let firstDeclarations = tracks.map { track in track.declaration(at: 0) }
        let stillStyle = firstDeclarations.joined(separator: ";")
        return NamedAnimation(name: name, stillStyle: stillStyle)
    }

    func style(of tracks: [AnimationTrack]) -> String {
        let namedAnimation = animation(of: tracks)
        return style(playing: namedAnimation, delay: 0)
    }

    func style(_ property: AnimatedProperty, _ events: [AnimationEvent]) -> String {
        let singleTrack = track(property, events)
        return style(of: [singleTrack])
    }

    func style(playing namedAnimation: NamedAnimation, delay: Double) -> String {
        let periodText = timeline.period.svgNumber
        let delayNumber = delay.svgNumber
        let delayText = delay == 0 ? "" : " \(delayNumber)s"
        return "\(namedAnimation.stillStyle);animation:\(namedAnimation.name) \(periodText)s linear\(delayText) infinite backwards"
    }

    private func nextName() -> String {
        animationCount += 1
        return "a\(animationCount)"
    }
}
