import Testing
import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct WebsiteRulesInBrowsersTests {
    private let canadian = SampleKeyboards.canadian.id
    private let canadianCSA = SampleKeyboards.canadianCSA.id
    private let chromeBundleIdentifier = TestHarness.chrome.bundleIdentifier

    private func rulesWithWhatsAppWeb() -> RulesFile {
        var rules = TestHarness.sampleRules()
        rules.setAppRule(bundleIdentifier: TestHarness.chrome.bundleIdentifier, appName: TestHarness.chrome.name, keyboardID: canadian)
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)
        return rules
    }

    @Test func websiteRuleWinsInABrowserAndFollowsTabChanges() async throws {
        let rules = rulesWithWhatsAppWeb()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        await harness.waitForTabRead()
        #expect(harness.tabTracker.currentWebsite == "web.whatsapp.com")
        #expect(harness.keyboardSystem.currentID == canadianCSA)

        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        await harness.tabTracker.readNow()?.value
        #expect(harness.keyboardSystem.currentID == canadian)
    }

    @Test func enteringABrowserGoesStraightToTheSiteKeyboard() async throws {
        var rules = TestHarness.sampleRules()
        rules.setAppRule(bundleIdentifier: chromeBundleIdentifier, appName: TestHarness.chrome.name, keyboardID: canadianCSA)
        rules.setWebsiteRule(website: "github.com", keyboardID: canadian)
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.coordinator.start(frontApp: TestHarness.ghostty)
        let selectionsBefore = harness.keyboardSystem.selections

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        await harness.waitForTabRead()

        #expect(harness.keyboardSystem.selections == selectionsBefore)
        #expect(harness.keyboardSystem.currentID == canadian)
    }

    @Test(.timeLimit(.minutes(1)))
    func aFrozenBrowserNeverHoldsTheAppUp() async throws {
        var rules = TestHarness.sampleRules()
        rules.setAppRule(bundleIdentifier: chromeBundleIdentifier, appName: TestHarness.chrome.name, keyboardID: canadianCSA)
        rules.setWebsiteRule(website: "github.com", keyboardID: canadian)
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.browsers.holdsAnswers = true
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        let keyboardRightAfterEntering = harness.keyboardSystem.currentID
        await harness.waitForPatienceToRunOut()
        let keyboardOncePatienceRanOut = harness.keyboardSystem.currentID
        harness.browsers.releaseAnswers()
        await harness.waitForTabRead()

        #expect(keyboardRightAfterEntering == canadian)
        #expect(keyboardOncePatienceRanOut == canadianCSA)
        #expect(harness.tabTracker.currentWebsite == "github.com")
        #expect(harness.keyboardSystem.currentID == canadian)
    }

    @Test func aLateAnswerFromABrowserYouLeftChangesNothing() async throws {
        let rules = rulesWithWhatsAppWeb()
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.browsers.holdsAnswers = true
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        let lateRead = harness.tabTracker.tabRead
        harness.coordinator.frontAppDidChange(to: TestHarness.ghostty)
        harness.browsers.releaseAnswers()
        await lateRead?.value

        #expect(lateRead != nil)
        #expect(harness.tabTracker.currentWebsite == nil)
        #expect(harness.keyboardSystem.currentID == canadian)
        #expect(harness.keyboardSystem.selections.isEmpty)
    }

    @Test func browserOpenedOnAWebsiteWithARuleRemembersNothing() async throws {
        var rules = TestHarness.sampleRules()
        rules.setWebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        await harness.waitForTabRead()

        #expect(harness.keyboardSystem.currentID == canadianCSA)
        #expect(harness.ruleBook.rules.appRule(for: chromeBundleIdentifier) == nil)
    }

    @Test func aSiteYouSwitchOnJoinsTheWebsitesList() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.coordinator.start(frontApp: TestHarness.ghostty)
        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        let tabReadsBeforeTheSwitch = harness.browsers.tabReadCount

        harness.keyboardSystem.switchByHand(to: canadianCSA)
        await harness.waitForManualSwitch()

        let githubRule = harness.ruleBook.rules.websiteRules.first { websiteRule in websiteRule.website == "github.com" }
        #expect(tabReadsBeforeTheSwitch == 0)
        #expect(githubRule?.keyboardID == canadianCSA)
        #expect(harness.ruleBook.rules.appRule(for: chromeBundleIdentifier)?.keyboardID == canadian)
    }

    @Test func everySiteYouVisitJoinsTheList() async throws {
        var rules = TestHarness.sampleRules()
        rules.preferences.websitesRemembering = .everyOne
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: rules)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.coordinator.frontAppDidChange(to: TestHarness.chrome)
        await harness.waitForTabRead()
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://claude.ai/new"
        await harness.tabTracker.readNow()?.value

        #expect(harness.ruleBook.rules.websiteRules.map(\.website) == ["github.com", "claude.ai"])
        #expect(harness.ruleBook.rules.appRule(for: chromeBundleIdentifier) == nil)
    }

    @Test func aSwitchInABrowserNotAllowedYetAsksAndKeepsYourPickForTheBrowser() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian, savedRules: TestHarness.sampleRules())
        harness.browsers.permissions[chromeBundleIdentifier] = .asksFirstTime
        harness.coordinator.start(frontApp: TestHarness.chrome)

        harness.keyboardSystem.switchByHand(to: canadianCSA)
        await harness.tabTracker.permissionQuestions[chromeBundleIdentifier]?.value

        #expect(harness.browsers.permissionQuestionsAsked == [chromeBundleIdentifier])
        #expect(harness.ruleBook.rules.appRule(for: chromeBundleIdentifier)?.keyboardID == canadianCSA)
        #expect(harness.ruleBook.rules.websiteRules.isEmpty)
        #expect(harness.keyboardSystem.currentID == canadianCSA)
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
        await harness.waitForTabRead()

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

    @Test func readsTheTabOnlyWhenTheMenuNeedsItWhileThereAreNoWebsiteRules() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://github.com/anthonysarkis"
        harness.coordinator.start(frontApp: TestHarness.chrome)
        #expect(harness.browsers.tabReadCount == 0)

        await harness.tabTracker.readNow()?.value

        #expect(harness.tabTracker.currentWebsite == "github.com")
    }

    @Test func firstWebsiteRuleStartsReadingTabsRightAway() async throws {
        let harness = try TestHarness(currentKeyboardID: canadian)
        harness.browsers.permissions[chromeBundleIdentifier] = .allowed
        harness.browsers.tabAddresses[chromeBundleIdentifier] = "https://web.whatsapp.com/"
        harness.coordinator.start(frontApp: TestHarness.chrome)

        harness.ruleBook.setWebsiteRule(website: "web.whatsapp.com", keyboardID: canadianCSA)
        await harness.waitForTabRead()

        #expect(harness.tabTracker.currentWebsite == "web.whatsapp.com")
        #expect(harness.keyboardSystem.currentID == canadianCSA)
    }

    @Test func aSiteJoiningTheListGetsItsIconFromTheSite() async throws {
        let iconData = SampleWebsiteIcons.png(pixels: 180, shape: .square)
        let websiteIconFetcher = FakeWebsiteIcons(answers: ["claude.ai": iconData])
        let harness = try TestHarness(currentKeyboardID: canadian, websiteIconFetcher: websiteIconFetcher)
        harness.coordinator.start(frontApp: TestHarness.ghostty)

        harness.ruleBook.setWebsiteRule(website: "claude.ai", keyboardID: canadianCSA)
        await harness.context.websiteIcons.waitForLoads()

        #expect(websiteIconFetcher.requests == ["claude.ai"])
        #expect(harness.context.websiteIcons.icon(for: "claude.ai")?.fillsShape == true)
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
