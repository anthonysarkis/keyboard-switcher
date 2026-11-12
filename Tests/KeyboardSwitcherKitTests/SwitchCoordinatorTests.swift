import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct SwitchCoordinatorTests {
    private let canadian = SampleKeyboards.canadian.id
    private let canadianCSA = SampleKeyboards.canadianCSA.id

    @Test func firstLaunchStartsWithAnEmptyListAndSavesIt() throws {
        let harness = try TestHarness(currentKeyboardID: canadian)

        harness.coordinator.start(frontApp: nil)

        #expect(harness.ruleBook.startedWithoutRulesFile)
        #expect(harness.ruleBook.rules == RulesFile())
        #expect(try harness.rulesStore.load() == RulesFile())
    }

    @Test func appliesTheRuleOfTheAppInFrontWhenItStartsWithoutABubble() throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.showBubble = true
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)

        harness.coordinator.start(frontApp: TestHarness.whatsApp)

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.bubble.shownKeyboardNames.isEmpty)
    }

    @Test func switchesWithABubbleWhenAnAppWithARuleComesToTheFront() throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.showBubble = true
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.context.catalog.currentKeyboardID == canadianCSA)
        #expect(harness.bubble.shownKeyboardNames == ["Canadian – CSA"])
        let menuBarBadgeImage = harness.context.catalog.badgeImage(for: canadianCSA)
        #expect(harness.bubble.shownBadgeImages.first === menuBarBadgeImage)
    }

    @Test func noBubbleUnlessItIsTurnedOn() throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.bubble.shownKeyboardNames.isEmpty)
    }

    @Test func itsOwnSwitchIsNotMistakenForOneByHand() throws {
        let rules = TestHarness.sampleRules()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)

        #expect(harness.ruleBook.rules == rules)
    }

    @Test func macOSPuttingBackThePreviousKeyboardRightAfterASwitchIsUndone() async throws {
        let rules = TestHarness.sampleRules()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)
        harness.keyboardSystem.switchByHand(to: canadian)
        await harness.waitForMacOSToSettle()

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.context.catalog.currentKeyboardID == canadianCSA)
        #expect(harness.ruleBook.rules == rules)
    }

    @Test func appOutsideTheListJoinsItWithTheKeyboardItWasOpenedWith() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.whatsApp)
        await harness.waitForMacOSToSettle()

        harness.coordinator.frontAppDidChange(to: TestHarness.notes)
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.notes)

        let notesRule = AppRule(bundleIdentifier: TestHarness.notes.bundleIdentifier, appName: "Notes", keyboardID: canadianCSA)
        #expect(harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier) == notesRule)
        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(try harness.rulesStore.load()?.appRule(for: TestHarness.notes.bundleIdentifier) == notesRule)
    }

    @Test func backgroundWindowsNeverJoinTheList() throws {
        let passwordDialog = AppIdentity(bundleIdentifier: "com.apple.SecurityAgent", name: "SecurityAgent", isRegularApp: false)
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: passwordDialog)

        #expect(harness.ruleBook.rules == TestHarness.sampleRules())
    }

    @Test func appOpenedWhileMacOSPutsBackTheOldKeyboardKeepsTheNewOne() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)
        harness.keyboardSystem.switchByHand(to: canadian)
        harness.coordinator.frontAppDidChange(to: TestHarness.notes)
        await harness.waitForMacOSToSettle()

        #expect(harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier)?.keyboardID == canadianCSA)
        #expect(harness.keyboardSystem.currentID == canadianCSA)
    }

    @Test func appsYouSwitchOnJoinOnlyOnceYouSwitch() throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.appsRemembering = .switchedByHand
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.notes)
        let notesRuleAfterOpening = harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier)

        harness.keyboardSystem.switchByHand(to: canadianCSA)

        #expect(notesRuleAfterOpening == nil)
        #expect(harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier)?.keyboardID == canadianCSA)
    }

    @Test func appWithoutARuleRemembersTheKeyboardPickedByHand() throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.notes)

        harness.keyboardSystem.switchByHand(to: canadianCSA)
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.notes)

        #expect(harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier)?.keyboardID == canadianCSA)
        #expect(harness.keyboardSystem.currentID == canadianCSA)
    }

    @Test func appWithoutARuleChangesNothingWhenSwitchesByHandAreNotRemembered() throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.appsRemembering = .addedByYou
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.notes)

        harness.keyboardSystem.switchByHand(to: canadianCSA)
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.notes)

        #expect(harness.ruleBook.rules.appRule(for: TestHarness.notes.bundleIdentifier) == nil)
        #expect(harness.keyboardSystem.currentID == canadian)
    }

    @Test func backToTheListKeyboardNextTimeWhenSwitchesByHandAreNotRemembered() async throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.appsRemembering = .addedByYou
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.whatsApp)
        await harness.waitForMacOSToSettle()

        harness.keyboardSystem.switchByHand(to: canadian)
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.whatsApp)

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.ruleBook.rules.appRule(for: TestHarness.whatsApp.bundleIdentifier)?.keyboardID == canadianCSA)
    }

    @Test func aRememberedSwitchByHandBecomesTheListKeyboard() async throws {
        let rules = TestHarness.sampleRules()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.whatsApp)
        await harness.waitForMacOSToSettle()

        harness.keyboardSystem.switchByHand(to: canadian)

        #expect(harness.ruleBook.rules.appRule(for: TestHarness.whatsApp.bundleIdentifier)?.keyboardID == canadian)
        #expect(try harness.rulesStore.load()?.appRule(for: TestHarness.whatsApp.bundleIdentifier)?.keyboardID == canadian)
    }

    @Test func choosingFromTheMenuSwitchesRightAwayWithoutABubble() throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.showBubble = true
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.coordinator.start(frontApp: TestHarness.notes)

        harness.ruleBook.setAppRule(bundleIdentifier: TestHarness.notes.bundleIdentifier, appName: TestHarness.notes.name, keyboardID: canadianCSA)

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.bubble.shownKeyboardNames.isEmpty)
    }

    @Test func itsOwnSettingsWindowNeverSwitchesAnything() throws {
        let harness = try TestHarness(currentKeyboardID: canadianCSA, savedRules: TestHarness.sampleRules())
        harness.coordinator.start(frontApp: TestHarness.whatsApp)
        let selectionsBefore = harness.keyboardSystem.selections

        harness.coordinator.frontAppDidChange(to: TestHarness.keyboardSwitcher)
        harness.keyboardSystem.switchByHand(to: canadian)

        #expect(harness.keyboardSystem.selections == selectionsBefore)
        #expect(harness.ruleBook.rules == TestHarness.sampleRules())
    }
}
