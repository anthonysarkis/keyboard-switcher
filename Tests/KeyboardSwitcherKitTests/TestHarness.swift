import KeyboardSwitcherCore
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct TestHarness {
    static let whatsApp = AppIdentity(bundleIdentifier: "net.whatsapp.WhatsApp", name: "WhatsApp")
    static let ghostty = AppIdentity(bundleIdentifier: "com.mitchellh.ghostty", name: "Ghostty")
    static let notes = AppIdentity(bundleIdentifier: "com.apple.Notes", name: "Notes")
    static let chrome = AppIdentity(bundleIdentifier: "com.google.Chrome", name: "Google Chrome")
    static let keyboardSwitcher = AppIdentity(bundleIdentifier: AppServices.fakeOwnBundleIdentifier, name: "Keyboard Switcher")

    let context: AppContext
    let keyboardSystem: FakeKeyboardSystem
    let browsers: FakeBrowsers
    let bubble: RecordingBubble
    let rulesStore: RulesStore

    init(currentKeyboardID: String, savedRules: RulesFile? = nil) throws {
        let rulesStore = TemporaryRulesStore.make()
        if let savedRules {
            try rulesStore.save(savedRules)
        }
        let keyboardSystem = FakeKeyboardSystem(currentID: currentKeyboardID)
        let browsers = FakeBrowsers()
        let bubble = RecordingBubble()
        let services = AppServices.fake(keyboardSystem: keyboardSystem, browsers: browsers, bubble: bubble, rulesStore: rulesStore)

        self.context = AppContext(services: services)
        self.keyboardSystem = keyboardSystem
        self.browsers = browsers
        self.bubble = bubble
        self.rulesStore = rulesStore
    }

    static func sampleRules() -> RulesFile {
        SampleRules.make()
    }

    var coordinator: SwitchCoordinator { context.coordinator }
    var ruleBook: RuleBook { context.ruleBook }
    var tabTracker: BrowserTabTracker { context.tabTracker }

    func waitForMacOSToSettle() async {
        await coordinator.settleCheck?.value
    }
}
