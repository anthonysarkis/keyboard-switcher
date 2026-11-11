import Foundation
import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct RuleBookTests {
    private let canadian = SampleKeyboards.canadian.id
    private let canadianCSA = SampleKeyboards.canadianCSA.id

    @Test func editsAreAnnouncedButRememberedSwitchesAreNot() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store)
        ruleBook.load(availableKeyboardIDs: SampleKeyboards.bothIDs)
        var editCount = 0
        ruleBook.onEdit = { editCount += 1 }
        let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")

        ruleBook.setAppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", keyboardID: canadianCSA)
        ruleBook.recordManualSwitch(keyboardID: canadian, in: notesContext)

        #expect(editCount == 1)
        #expect(ruleBook.rules.lastUsedByApp["com.apple.Notes"] == canadian)
    }

    @Test func anEditThatChangesNothingIsNotAnnounced() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store)
        ruleBook.load(availableKeyboardIDs: SampleKeyboards.bothIDs)
        var editCount = 0
        ruleBook.onEdit = { editCount += 1 }

        ruleBook.removeWebsiteRule(website: "claude.ai")

        #expect(editCount == 0)
    }

    @Test func unreadableRulesFileIsMovedAsideAndAFreshOneStarts() throws {
        let store = TemporaryRulesStore.make()
        let folder = store.fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let unreadableContent = Data("not json".utf8)
        try unreadableContent.write(to: store.fileURL)
        let ruleBook = RuleBook(store: store)

        ruleBook.load(availableKeyboardIDs: SampleKeyboards.bothIDs)

        let folderContents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
        #expect(ruleBook.rules == RulesFile())
        #expect(folderContents.contains { fileName in fileName.hasPrefix("rules.unreadable-") })
        #expect(try store.load() == RulesFile())
    }

    @Test func addingAWebsiteFromTypedTextCleansItUp() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store)
        ruleBook.load(availableKeyboardIDs: SampleKeyboards.bothIDs)

        let wasAdded = ruleBook.addWebsiteRule(typedText: "https://www.Claude.ai/new", keyboardID: canadian)
        let wasRefused = !ruleBook.addWebsiteRule(typedText: "not a site", keyboardID: canadian)

        #expect(wasAdded)
        #expect(wasRefused)
        #expect(ruleBook.rules.websiteRules.map(\.website) == ["claude.ai"])
    }
}
