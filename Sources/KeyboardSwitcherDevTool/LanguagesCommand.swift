enum LanguagesCommand {
    private static let columnCount = 4

    static func printMarkdownTable() {
        let languages = KeyboardLanguageCatalog.languages()
        let keyboardCount = KeyboardLanguageCatalog.installedKeyboardCount()
        print("\(languages.count) languages, \(keyboardCount) keyboards")
        print("")

        let emptyHeader = Array(repeating: " ", count: columnCount)
        let alignmentRow = Array(repeating: ":---", count: columnCount)
        printRow(emptyHeader)
        printRow(alignmentRow)
        for rowStart in stride(from: 0, to: languages.count, by: columnCount) {
            let rowEnd = min(rowStart + columnCount, languages.count)
            let rowLanguages = languages[rowStart..<rowEnd]
            var cells = rowLanguages.map { language in "\(language.flag) \(language.name)" }
            let missingCellCount = columnCount - cells.count
            let emptyCells = Array(repeating: " ", count: missingCellCount)
            cells.append(contentsOf: emptyCells)
            printRow(cells)
        }
    }

    private static func printRow(_ cells: [String]) {
        let joinedCells = cells.joined(separator: " | ")
        print("| \(joinedCells) |")
    }
}
