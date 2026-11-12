import Foundation
import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct RuleBookTests {
    private let canadian = SampleKeyboards.canadian.id
    private let canadianCSA = SampleKeyboards.canadianCSA.id
    private let installedAppName: (String) -> String? = { bundleIdentifier in AppServices.fakeInstalledAppNames[bundleIdentifier] }

    @Test func editsAreAnnouncedButRememberedKeyboardsAreNot() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store, installedAppName: installedAppName)
        ruleBook.load()
        var editCount = 0
        ruleBook.onEdit = { editCount += 1 }
        let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")
        let textEditContext = SwitchContext(bundleIdentifier: "com.apple.TextEdit")

        ruleBook.setAppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", keyboardID: canadianCSA)
        ruleBook.recordManualSwitch(keyboardID: canadian, appName: "Notes", in: notesContext)
        ruleBook.rememberKeyboardOnEntry(keyboardID: canadianCSA, appName: "TextEdit", in: textEditContext)

        #expect(editCount == 1)
        #expect(ruleBook.rules.appRule(for: "com.apple.Notes")?.keyboardID == canadian)
        #expect(ruleBook.rules.appRule(for: "com.apple.TextEdit")?.keyboardID == canadianCSA)
    }

    @Test func rememberedAppsMoveIntoTheListWhenTheFileOpens() throws {
        let store = TemporaryRulesStore.make()
        var savedRules = RulesFile()
        savedRules.lastUsedByApp = ["com.apple.Safari": canadianCSA, "com.example.Uninstalled": canadian]
        try store.save(savedRules)
        let ruleBook = RuleBook(store: store, installedAppName: installedAppName)

        ruleBook.load()

        let safariRule = AppRule(bundleIdentifier: "com.apple.Safari", appName: "Safari", keyboardID: canadianCSA)
        #expect(ruleBook.rules.appRules == [safariRule])
        #expect(ruleBook.rules.lastUsedByApp.isEmpty)
        #expect(try store.load() == ruleBook.rules)
    }

    @Test func anEditThatChangesNothingIsNotAnnounced() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store, installedAppName: installedAppName)
        ruleBook.load()
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
        let ruleBook = RuleBook(store: store, installedAppName: installedAppName)

        ruleBook.load()

        let folderContents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
        #expect(ruleBook.rules == RulesFile())
        #expect(folderContents.contains { fileName in fileName.hasPrefix("rules.unreadable-") })
        #expect(try store.load() == RulesFile())
    }

    @Test func addingAWebsiteFromTypedTextCleansItUp() {
        let store = TemporaryRulesStore.make()
        let ruleBook = RuleBook(store: store, installedAppName: installedAppName)
        ruleBook.load()

        let wasAdded = ruleBook.addWebsiteRule(typedText: "https://www.Claude.ai/new", keyboardID: canadian)
        let wasRefused = !ruleBook.addWebsiteRule(typedText: "not a site", keyboardID: canadian)

        #expect(wasAdded)
        #expect(wasRefused)
        #expect(ruleBook.rules.websiteRules.map(\.website) == ["claude.ai"])
    }
}
