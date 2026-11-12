struct SeededRandomNumbers {
    private static let unitScale = 1.0 / 9_007_199_254_740_992.0

    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next(from lowest: Double, to highest: Double) -> Double {
        let unit = nextUnit()
        return lowest + (highest - lowest) * unit
    }

    private mutating func nextUnit() -> Double {
        state &+= 0x9E37_79B9_7F4A_7C15
        var mixed = state
        mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
        mixed ^= mixed >> 31
        let topBits = mixed >> 11
        return Double(topBits) * Self.unitScale
    }
}
