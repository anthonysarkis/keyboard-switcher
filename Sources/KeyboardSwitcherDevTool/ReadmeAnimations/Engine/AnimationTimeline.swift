struct AnimationTimeline {
    let period: Double
    let rest: Double

    func realTime(of sceneTime: Double) -> Double {
        let sinceRest = sceneTime - rest
        let remainder = sinceRest.truncatingRemainder(dividingBy: period)
        if remainder == 0 {
            return 0
        }
        return remainder < 0 ? remainder + period : remainder
    }
}
