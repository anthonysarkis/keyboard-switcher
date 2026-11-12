struct SceneRect {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    var middleY: Double {
        y + height / 2
    }

    var maxX: Double {
        x + width
    }
}
