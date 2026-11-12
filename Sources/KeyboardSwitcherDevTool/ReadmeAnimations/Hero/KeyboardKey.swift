struct KeyboardKey {
    let row: Int
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let identity: KeyIdentity
    let legend: KeyLegend?

    var centreX: Double {
        x + width / 2
    }

    var centreY: Double {
        y + height / 2
    }
}
