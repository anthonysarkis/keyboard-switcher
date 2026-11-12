import Observation
import KeyboardSwitcherCore

@Observable
public final class SwitchCoordinator {
    public private(set) var frontApp: AppIdentity?
    public let ownBundleIdentifier: String
    @ObservationIgnored private(set) var manualSwitchRecording: Task<Void, Never>?

    private let catalog: KeyboardCatalog
    private let ruleBook: RuleBook
    private let tabTracker: BrowserTabTracker
    private let bubble: any BubblePresenting
    private let manualSwitchDetector: ManualSwitchDetector
    private let resolver = RuleResolver.standard

    init(
        catalog: KeyboardCatalog,
        ruleBook: RuleBook,
        tabTracker: BrowserTabTracker,
        bubble: any BubblePresenting,
        manualSwitchDetector: ManualSwitchDetector,
        ownBundleIdentifier: String
    ) {
        self.catalog = catalog
        self.ruleBook = ruleBook
        self.tabTracker = tabTracker
        self.bubble = bubble
        self.manualSwitchDetector = manualSwitchDetector
        self.ownBundleIdentifier = ownBundleIdentifier
    }

    var settleCheck: Task<Void, Never>? {
        manualSwitchDetector.settleCheck
    }

    public var frontAppOtherThanOurs: AppIdentity? {
        guard let frontApp, frontApp.bundleIdentifier != ownBundleIdentifier else { return nil }
        return frontApp
    }

    public func start(frontApp: AppIdentity?) {
        catalog.refresh()
        ruleBook.load()
        manualSwitchDetector.note(catalog.currentKeyboardID)
        connectEvents()
        Log.switching.notice("Started with \(self.catalog.keyboards.count) keyboards, \(self.ruleBook.rules.appRules.count) app rules, \(self.ruleBook.rules.websiteRules.count) website rules")
        enter(frontApp, showsBubble: false)
    }

    public func frontAppDidChange(to app: AppIdentity?) {
        enter(app, showsBubble: true)
    }

    private var currentContext: SwitchContext? {
        guard let frontApp = frontAppOtherThanOurs else { return nil }
        return SwitchContext(bundleIdentifier: frontApp.bundleIdentifier, website: tabTracker.currentWebsite)
    }

    private func connectEvents() {
        catalog.observeChanges { [weak self] in self?.keyboardSelectionDidChange() }
        ruleBook.onEdit = { [weak self] in self?.rulesWereEdited() }
        tabTracker.onWebsiteChange = { [weak self] in self?.websiteDidChange() }
        manualSwitchDetector.onSettled = { [weak self] settledKeyboardID in self?.restoreIfMacOSChanged(settledKeyboardID) }
    }

    private func enter(_ app: AppIdentity?, showsBubble: Bool) {
        frontApp = app
        let browser = frontAppOtherThanOurs.flatMap { otherApp in
            SupportedBrowser.browser(bundleIdentifier: otherApp.bundleIdentifier)
        }
        tabTracker.track(browser, needsTabAddresses: ruleBook.needsTabAddresses, mayAsk: true) { [weak self] in
            self?.finishEntering(showsBubble: showsBubble)
        }
    }

    private func finishEntering(showsBubble: Bool) {
        guard let otherApp = frontAppOtherThanOurs else { return }

        Log.switching.notice("In front: \(otherApp.bundleIdentifier, privacy: .public)")
        applyRules(showsBubble: showsBubble)
        rememberNewWebsite()
        rememberNewApp()
    }

    private func websiteDidChange() {
        applyRules(showsBubble: true)
        rememberNewWebsite()
    }

    private var enteredKeyboardID: String? {
        manualSwitchDetector.settlingKeyboardID ?? catalog.readCurrentKeyboardID()
    }

    private func rememberNewWebsite() {
        guard let context = currentContext, context.website != nil, let keyboardID = enteredKeyboardID else { return }
        ruleBook.rememberWebsiteOnVisit(keyboardID: keyboardID, in: context)
    }

    private func rememberNewApp() {
        guard let frontApp = frontAppOtherThanOurs, frontApp.isRegularApp,
              let context = currentContext, ruleDecision(for: context) == nil,
              let keyboardID = enteredKeyboardID
        else { return }
        ruleBook.rememberKeyboardOnEntry(keyboardID: keyboardID, appName: frontApp.name, in: context)
    }

    private func ruleDecision(for context: SwitchContext) -> KeyboardDecision? {
        resolver.decision(for: context, rules: ruleBook.rules, availableKeyboardIDs: catalog.availableKeyboardIDs)
    }

    private func rulesWereEdited() {
        tabTracker.updateNeedsTabAddresses(ruleBook.needsTabAddresses) { [weak self] in
            self?.applyRules(showsBubble: false)
        }
    }

    private func keyboardSelectionDidChange() {
        guard let selectedKeyboardID = catalog.readCurrentKeyboardID(),
              manualSwitchDetector.isManualChange(to: selectedKeyboardID),
              let frontApp = frontAppOtherThanOurs
        else { return }

        let browser = SupportedBrowser.browser(bundleIdentifier: frontApp.bundleIdentifier)
        let remembersWebsites = ruleBook.rules.preferences.websitesRemembering != .addedByYou
        guard let browser, remembersWebsites else {
            recordManualSwitch(to: selectedKeyboardID, in: frontApp, website: tabTracker.currentWebsite)
            return
        }

        guard let freshRead = tabTracker.readNow() else {
            if tabTracker.permissions[browser.bundleIdentifier] == .asksFirstTime {
                tabTracker.requestPermission(for: browser)
            }
            recordManualSwitch(to: selectedKeyboardID, in: frontApp, website: nil)
            return
        }
        manualSwitchRecording = Task { [weak self] in
            await freshRead.value
            guard let self, self.frontAppOtherThanOurs == frontApp else { return }
            self.recordManualSwitch(to: selectedKeyboardID, in: frontApp, website: self.tabTracker.currentWebsite)
        }
    }

    private func recordManualSwitch(to keyboardID: String, in app: AppIdentity, website: String?) {
        let context = SwitchContext(bundleIdentifier: app.bundleIdentifier, website: website)
        let neededTabAddresses = ruleBook.needsTabAddresses
        Log.switching.notice("Switched by hand to \(keyboardID, privacy: .public) in \(app.bundleIdentifier, privacy: .public)")
        ruleBook.recordManualSwitch(keyboardID: keyboardID, appName: app.name, in: context)
        guard ruleBook.needsTabAddresses != neededTabAddresses else { return }
        tabTracker.updateNeedsTabAddresses(ruleBook.needsTabAddresses) {}
    }

    private func applyRules(showsBubble: Bool) {
        guard let context = currentContext else { return }
        let selectedKeyboardID = catalog.readCurrentKeyboardID()
        let decision = ruleDecision(for: context)

        guard let decision, decision.keyboardID != selectedKeyboardID else {
            manualSwitchDetector.note(selectedKeyboardID)
            return
        }
        switchKeyboard(to: decision, in: context, from: selectedKeyboardID, showsBubble: showsBubble)
    }

    private func switchKeyboard(to decision: KeyboardDecision, in context: SwitchContext, from previousKeyboardID: String?, showsBubble: Bool) {
        manualSwitchDetector.beginSwitch(to: decision.keyboardID)
        guard catalog.select(decision.keyboardID) else {
            manualSwitchDetector.cancelSwitch(keeping: previousKeyboardID)
            Log.switching.error("Could not switch to \(decision.keyboardID, privacy: .public)")
            return
        }

        Log.switching.notice("Switched to \(decision.keyboardID, privacy: .public) for \(context.bundleIdentifier, privacy: .public) by \(decision.source.logDescription, privacy: .public)")
        if showsBubble {
            showBubble(for: decision.keyboardID)
        }
    }

    private func showBubble(for keyboardID: String) {
        guard ruleBook.rules.preferences.showBubble,
              let keyboard = catalog.keyboard(id: keyboardID),
              let badgeImage = catalog.badgeImage(for: keyboardID)
        else { return }
        bubble.showBubble(badgeImage: badgeImage, keyboardName: keyboard.name)
    }

    private func restoreIfMacOSChanged(_ settledKeyboardID: String) {
        let selectedKeyboardID = catalog.readCurrentKeyboardID()
        guard selectedKeyboardID != settledKeyboardID else { return }

        Log.switching.notice("macOS put back \(selectedKeyboardID ?? "no keyboard", privacy: .public) after the switch; switching to \(settledKeyboardID, privacy: .public) again")
        let wasRestored = catalog.select(settledKeyboardID)
        if !wasRestored {
            manualSwitchDetector.note(selectedKeyboardID)
        }
    }
}
