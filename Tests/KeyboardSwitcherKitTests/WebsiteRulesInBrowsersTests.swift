import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct WebsiteRulesInBrowsersTests {
    private let canadian = SampleKeyboards.canadian.id
    private let canadianCSA = SampleKeyboards.canadianCSA.id
    private let chromeBundleIdentifier = TestHarness.chrome.bundleIdentifier

    private func rulesWithWhatsAppWeb() -> RulesFile {
        var rules = TestHarness.starterRules()
        rules.setAppRule(bundleIdentifier: TestHarness.chrome.bundleIdentifier, appName: TestHarness.chrome.name, keyboardID: canadian)
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)
        return rules
    }

    @Test func websiteRuleWinsInABrowserAndFollowsTabChanges() throws {
        let rules = rulesWithWhatsAppWeb()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        #expect(harness.tabTracker.currentWebsite == "web.whatsapp.com")
        #expect(harness.keyboardSystem.currentID == canadianCSA)

        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.tabTracker.readNow()
        harness.tabTracker.onWebsiteChange?()
        #expect(harness.keyboardSystem.currentID == canadian)
    }

    @Test func asksEachBrowserOnceAndWaitsForTheAnswer() async throws {
        let rules = rulesWithWhatsAppWeb()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .asksFirstTime
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        await harness.tabTracker.permissionQuestions[chromeBundleIdentifier]?.value

        #expect(harness.browsers.permissionQuestionsAsked == [chromeBundleIdentifier])
        #expect(harness.tabTracker.permissions[chromeBundleIdentifier] == .allowed)
        #expect(harness.keyboardSystem.currentID == canadianCSA)
    }

    @Test func neverAsksABrowserWhileThereAreNoWebsiteRules() throws {
        let harness = try TestHarness(currentKeyboardID: canadian)
        harness.browsers.permissions[chromeBundleIdentifier] = .asksFirstTime
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)

        #expect(harness.tabTracker.permissionQuestions.isEmpty)
        #expect(harness.browsers.permissionQuestionsAsked.isEmpty)
        #expect(harness.browsers.tabReadCount == 0)
    }

    @Test func readsTheTabOnlyWhenTheMenuNeedsItWhileThereAreNoWebsiteRules() throws {
        let harness = try TestHarness(currentKeyboardID: canadian)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.coordinator.start(frontApp: TestHarness.chrome)
        #expect(harness.browsers.tabReadCount == 0)

        harness.tabTracker.readNow()

        #expect(harness.tabTracker.currentWebsite == "github.com")
    }

    @Test func firstWebsiteRuleStartsReadingTabsRightAway() throws {
        let harness = try TestHarness(currentKeyboardID: canadian)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.chrome)

        harness.ruleBook.setWebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)

        #expect(harness.tabTracker.currentWebsite == "web.whatsapp.com")
        #expect(harness.keyboardSystem.currentID == canadianCSA)
    }

    @Test func browserThatSaysNoIsNeverRead() throws {
        let rules = rulesWithWhatsAppWeb()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .denied
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)

        #expect(harness.tabTracker.permissions[chromeBundleIdentifier] == .denied)
        #expect(harness.tabTracker.currentWebsite == nil)
        #expect(harness.browsers.tabReadCount == 0)
    }
}
