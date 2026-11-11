import Foundation
import KeyboardSwitcherCore

public enum TemporaryRulesStore {
    public static func make() -> RulesStore {
        let uniqueSuffix = UUID().uuidString
        let uniqueFolderName = "keyboard-switcher-\(uniqueSuffix)"
        let folder = FileManager.default.temporaryDirectory.appending(path: uniqueFolderName)
        let fileURL = folder.appending(path: "rules.json")
        return RulesStore(fileURL: fileURL)
    }
}
