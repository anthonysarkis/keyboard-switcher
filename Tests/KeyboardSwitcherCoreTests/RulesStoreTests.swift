import Foundation
import Testing
import KeyboardSwitcherCore

struct RulesStoreTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
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
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        var rules = RulesFile(appRules: [whatsAppRule])
        rules.setWebsiteRule(website: "claude.ai", keyboardID: canadian)
        rules.lastUsedByApp["com.apple.Notes"] = canadianCSA
        rules.preferences.appsRemembering = .switchedByHand
        rules.preferences.websitesRemembering = .everyOne
        rules.preferences.showBubble = true

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

    @Test func fileFromTheTwoSwitchVersionOpensRemembering() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let twoSwitchFile = #"{"version": 1, "preferences": {"showBubble": false, "manualSwitch": "backToRule", "otherApps": "lastUsed"}}"#
        try Data(twoSwitchFile.utf8).write(to: store.fileURL)

        let rules = try #require(try store.load())

        #expect(rules.preferences == Preferences(showBubble: false))
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
