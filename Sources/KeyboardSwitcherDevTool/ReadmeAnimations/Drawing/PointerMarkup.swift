enum PointerMarkup {
    static let shadowFilter = "<filter id=\"pointerShadow\" filterUnits=\"userSpaceOnUse\" x=\"-12\" y=\"-12\" width=\"40\" height=\"46\">"
        + "<feGaussianBlur in=\"SourceAlpha\" stdDeviation=\"1.1\"/><feOffset dy=\"1\" result=\"blur\"/>"
        + "<feFlood flood-color=\"#000\" flood-opacity=\"0.35\"/><feComposite in2=\"blur\" operator=\"in\" result=\"shadow\"/>"
        + "<feMerge><feMergeNode in=\"shadow\"/><feMergeNode in=\"SourceGraphic\"/></feMerge></filter>"

    private static let outline = "M0 0 L0 16.6 L3.95 12.95 L6.55 19.05 L9.1 17.95 L6.55 12.05 L11.75 12.05 Z"

    static func arrow(x: Double, y: Double) -> String {
        "<g transform=\"translate(\(x.svgNumber) \(y.svgNumber)) scale(1.15)\" filter=\"url(#pointerShadow)\"><path d=\"\(outline)\" fill=\"#000\" stroke=\"#fff\" stroke-width=\"1.15\" stroke-linejoin=\"round\"/></g>"
    }
}
