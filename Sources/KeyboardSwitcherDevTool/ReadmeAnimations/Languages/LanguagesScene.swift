enum LanguagesScene {
    private static let rowCount = 4
    private static let padding = 6.0
    private static let rowSpeeds = [15.0, 12.0, 17.0, 13.5]

    static func picture(names: [String], theme: LanguagesTheme) throws -> AnimatedPicture {
        let rows = rowsOf(names)
        let height = Double(rowCount) * LanguageStripPainter.rowHeight + padding * 2
        let width = ReadmeCanvas.width.svgNumber
        let heightText = height.svgNumber
        var definitions = [
            "<linearGradient id=\"fade\" x1=\"0\" y1=\"0\" x2=\"1\" y2=\"0\"><stop offset=\"0\" stop-color=\"#fff\" stop-opacity=\"0\"/><stop offset=\"0.09\" stop-color=\"#fff\"/><stop offset=\"0.91\" stop-color=\"#fff\"/><stop offset=\"1\" stop-color=\"#fff\" stop-opacity=\"0\"/></linearGradient>",
            "<mask id=\"edges\" maskUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"\(width)\" height=\"\(heightText)\"><rect width=\"\(width)\" height=\"\(heightText)\" fill=\"url(#fade)\"/></mask>",
        ]
        var keyframeRules: [String] = []
        var rowGroups: [String] = []
        var longestLoop = 0.0
        for (rowIndex, row) in rows.enumerated() {
            guard let strip = LanguageStripPainter.strip(of: row, theme: theme) else {
                throw ReadmeAnimationError.couldNotDrawLanguageRow(rowIndex)
            }
            let dataURI = ImageDataURI.png(strip.pngData)
            let stripWidth = strip.width.svgNumber
            let rowHeight = LanguageStripPainter.rowHeight.svgNumber
            definitions.append("<image id=\"strip\(rowIndex)\" width=\"\(stripWidth)\" height=\"\(rowHeight)\" href=\"\(dataURI)\"/>")
            let duration = strip.width / rowSpeeds[rowIndex]
            longestLoop = max(longestLoop, duration)
            let movesLeft = rowIndex % 2 == 0
            let start = movesLeft ? 0 : -strip.width
            let end = movesLeft ? -strip.width : 0
            let startText = start.svgNumber
            let endText = end.svgNumber
            keyframeRules.append("@keyframes row\(rowIndex){from{transform:translateX(\(startText)px)}to{transform:translateX(\(endText)px)}}")
            let top = padding + Double(rowIndex) * LanguageStripPainter.rowHeight
            let durationText = duration.svgNumber
            rowGroups.append("<g style=\"transform:translateX(\(startText)px);animation:row\(rowIndex) \(durationText)s linear infinite\"><use href=\"#strip\(rowIndex)\" x=\"0\" y=\"\(top.svgNumber)\"/><use href=\"#strip\(rowIndex)\" x=\"\(stripWidth)\" y=\"\(top.svgNumber)\"/></g>")
        }
        let joinedRows = rowGroups.joined()
        let joinedNames = names.joined(separator: ", ")
        let label = "The \(names.count) languages macOS has keyboards for, each written in its own script: \(joinedNames)."
        let document = SVGDocument(
            width: ReadmeCanvas.width, height: height, label: label, leadingStyle: "",
            keyframeRules: keyframeRules, definitions: definitions, body: ["<g mask=\"url(#edges)\">\(joinedRows)</g>"]
        )
        return AnimatedPicture(fileName: "languages-\(theme.name).svg", markup: document.markup, width: ReadmeCanvas.width, height: height, loopSeconds: longestLoop)
    }

    private static func rowsOf(_ names: [String]) -> [[String]] {
        var rows = Array(repeating: [String](), count: rowCount)
        for (index, name) in names.enumerated() {
            rows[index % rowCount].append(name)
        }
        return rows
    }
}
