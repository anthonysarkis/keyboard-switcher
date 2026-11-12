struct SVGDocument {
    let width: Double
    let height: Double
    let label: String
    let leadingStyle: String
    let keyframeRules: [String]
    let definitions: [String]
    let body: [String]

    var markup: String {
        let escapedLabel = label.xmlEscaped
        let widthText = width.svgNumber
        let heightText = height.svgNumber
        let joinedRules = keyframeRules.joined()
        let joinedDefinitions = definitions.joined()
        let joinedBody = body.joined()
        let styleBlock = "<style>\(leadingStyle)@media (prefers-reduced-motion:reduce){*{animation:none!important}}\(joinedRules)</style>"
        let opening = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\(widthText)\" height=\"\(heightText)\" viewBox=\"0 0 \(widthText) \(heightText)\" role=\"img\" aria-label=\"\(escapedLabel)\">"
        return "\(opening)<title>\(escapedLabel)</title>\(styleBlock)<defs>\(joinedDefinitions)</defs>\(joinedBody)</svg>"
    }
}
