import Foundation
import Testing
import KeyboardSwitcherCore

struct RulesStoreTests {
    private let folder = RulesStoreTests.makeTemporaryFolder()
    private var store: RulesStore {
        let fileURL = folder.appending(path: "rules.json")
        return RulesStore(fileURL: fileURL)
    }

    private static func makeTemporaryFolder() -> URL {
        let uniqueSuffix = UUID().uuidString
        let folderName = "keyboard-switcher-tests-\(uniqueSuffix)"
        return FileManager.default.temporaryDirectory.appending(path: folderName)
    }

    @Test func noFileMeansFirstLaunch() throws {
        #expect(try store.load() == nil)
    }

    @Test func savedRulesComeBackTheSame() throws {
        var rules = StarterRules.make(availableKeyboardIDs: [StarterRules.canadianKeyboardID, StarterRules.canadianCSAKeyboardID])
        rules.setWebsiteRule(website: "claude.ai", keyboardID: StarterRules.canadianKeyboardID)
        rules.lastUsedByApp["com.apple.Notes"] = StarterRules.canadianCSAKeyboardID
        rules.preferences.manualSwitch = .becomesRule

        try store.save(rules)

        #expect(try store.load() == rules)
    }

    @Test func olderFileWithMissingFieldsStillOpens() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let olderFile = #"{"version": 1, "appRules": [{"bundleIdentifier": "net.whatsapp.WhatsApp", "appName": "WhatsApp", "keyboardID": "com.apple.keylayout.Canadian-CSA"}]}"#
        try Data(olderFile.utf8).write(to: store.fileURL)

        let rules = try #require(try store.load())

        #expect(rules.appRules.count == 1)
        #expect(rules.websiteRules.isEmpty)
        #expect(rules.preferences == Preferences())
    }

    @Test func unreadableFileCanBeMovedAside() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: store.fileURL)
        #expect(throws: (any Error).self) { try store.load() }

        let movedTo = try store.moveAsideUnreadableFile()

        #expect(FileManager.default.fileExists(atPath: movedTo.path))
        #expect(try store.load() == nil)
    }
}
