import Testing
import KeyboardSwitcherCore

struct ManualSwitchPolicyTests {
    private let canadian = "com.apple.keylayout.Canadian"
    private let canadianCSA = "com.apple.keylayout.Canadian-CSA"
    private let whatsAppContext = SwitchContext(bundleIdentifier: "net.whatsapp.WhatsApp")
    private let notesContext = SwitchContext(bundleIdentifier: "com.apple.Notes")
    private let claudeInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "claude.ai")
    private let githubInChrome = SwitchContext(bundleIdentifier: "com.google.Chrome", website: "github.com")

    private func rules(apps: RememberingMode = .everyOne, websites: RememberingMode = .switchedByHand) -> RulesFile {
        let whatsAppRule = AppRule(bundleIdentifier: "net.whatsapp.WhatsApp", appName: "WhatsApp", keyboardID: canadianCSA)
        let chromeRule = AppRule(bundleIdentifier: "com.google.Chrome", appName: "Google Chrome", keyboardID: canadian)
        let claudeRule = WebsiteRule(website: "claude.ai", keyboardID: canadian)
        let preferences = Preferences(appsRemembering: apps, websitesRemembering: websites)
        return RulesFile(appRules: [whatsAppRule, chromeRule], websiteRules: [claudeRule], preferences: preferences)
    }

    @Test(arguments: [RememberingMode.everyOne, .switchedByHand])
    func aSwitchByHandUpdatesTheAppInTheList(apps: RememberingMode) {
        var rules = rules(apps: apps)

        ManualSwitchPolicy.record(keyboardID: canadian, appName: "WhatsApp", in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.keyboardID == canadian)
    }

    @Test func anAppInTheListKeepsTheNameItHasThere() {
        var rules = rules()

        ManualSwitchPolicy.record(keyboardID: canadian, appName: "WhatsApp Beta", in: whatsAppContext, rules: &rules)

        #expect(rules.appRule(for: whatsAppContext.bundleIdentifier)?.appName == "WhatsApp")
    }

    @Test(arguments: [RememberingMode.everyOne, .switchedByHand])
    func aSwitchByHandAddsAnAppOutsideTheList(apps: RememberingMode) {
        var rules = rules(apps: apps)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Notes", in: notesContext, rules: &rules)

        let notesRule = AppRule(bundleIdentifier: "com.apple.Notes", appName: "Notes", keyboardID: canadianCSA)
        #expect(rules.appRule(for: notesContext.bundleIdentifier) == notesRule)
    }

    @Test func aSwitchByHandIsTemporaryWhenOnlyAddedAppsAreRemembered() {
        var rules = rules(apps: .addedByYou)
        let rulesBefore = rules

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Notes", in: notesContext, rules: &rules)
        ManualSwitchPolicy.record(keyboardID: canadian, appName: "WhatsApp", in: whatsAppContext, rules: &rules)

        #expect(rules == rulesBefore)
    }

    @Test(arguments: [RememberingMode.everyOne, .switchedByHand])
    func aSwitchByHandOnAListedSiteUpdatesThatSite(websites: RememberingMode) {
        var rules = rules(websites: websites)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Google Chrome", in: claudeInChrome, rules: &rules)

        let claudeRule = rules.websiteRules.first { websiteRule in websiteRule.website == "claude.ai" }
        #expect(claudeRule?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)
    }

    @Test func aSwitchByHandOnANewSiteAddsTheSiteAndLeavesTheBrowserAlone() {
        var rules = rules(websites: .switchedByHand)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Google Chrome", in: githubInChrome, rules: &rules)

        let githubRule = rules.websiteRules.first { websiteRule in websiteRule.website == "github.com" }
        #expect(githubRule?.keyboardID == canadianCSA)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)
    }

    @Test func onlyAddedSitesKeepTheirKeyboardAndOtherSitesChangeTheBrowser() {
        var rules = rules(websites: .addedByYou)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Google Chrome", in: claudeInChrome, rules: &rules)
        let claudeRule = rules.websiteRules.first { websiteRule in websiteRule.website == "claude.ai" }
        #expect(claudeRule?.keyboardID == canadian)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadian)

        ManualSwitchPolicy.record(keyboardID: canadianCSA, appName: "Google Chrome", in: githubInChrome, rules: &rules)
        #expect(rules.websiteRules.count == 1)
        #expect(rules.appRule(for: "com.google.Chrome")?.keyboardID == canadianCSA)
    }
}
