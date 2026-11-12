struct ShadowShape {
    static let floatingLayers = [ShadowLayer(blur: 7, drop: 5, opacity: 0.75)]

    let width: Double
    let height: Double
    let cornerRadius: Double
    let margin: Double
    let layers: [ShadowLayer]
}
