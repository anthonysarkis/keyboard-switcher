import Observation
import KeyboardSwitcherCore

@Observable
public final class RuleBook {
    public private(set) var rules = RulesFile()
    public private(set) var startedWithoutRulesFile = false
    @ObservationIgnored var onEdit: (@MainActor () -> Void)?

    private let store: RulesStore
    private let installedAppName: (String) -> String?

    public init(store: RulesStore, installedAppName: @escaping (String) -> String?) {
        self.store = store
        self.installedAppName = installedAppName
    }

    public var needsTabAddresses: Bool {
        !rules.websiteRules.isEmpty || rules.preferences.websitesRemembering == .everyOne
    }

    public func setAppRule(bundleIdentifier: String, appName: String, keyboardID: String) {
        edit { editedRules in
            editedRules.setAppRule(bundleIdentifier: bundleIdentifier, appName: appName, keyboardID: keyboardID)
        }
    }

    public func removeAppRule(bundleIdentifier: String) {
        edit { editedRules in editedRules.removeAppRule(bundleIdentifier: bundleIdentifier) }
    }

    public func setWebsiteRule(website: String, keyboardID: String) {
        edit { editedRules in editedRules.setWebsiteRule(website: website, keyboardID: keyboardID) }
    }

    public func removeWebsiteRule(website: String) {
        edit { editedRules in editedRules.removeWebsiteRule(website: website) }
    }

    @discardableResult
    public func addWebsiteRule(typedText: String, keyboardID: String) -> Bool {
        guard let website = WebsiteAddress.website(fromTypedText: typedText) else { return false }
        setWebsiteRule(website: website, keyboardID: keyboardID)
        return true
    }

    public func updatePreferences(_ change: (inout Preferences) -> Void) {
        edit { editedRules in change(&editedRules.preferences) }
    }

    func load() {
        do {
            if let savedRules = try store.load() {
                rules = savedRules
                moveRememberedAppsIntoTheList()
            } else {
                startedWithoutRulesFile = true
                rules = RulesFile()
                save()
            }
        } catch {
            Log.rules.error("rules.json could not be read: \(error.localizedDescription, privacy: .public)")
            moveAsideUnreadableFile()
            rules = RulesFile()
            save()
        }
    }

    func recordManualSwitch(keyboardID: String, appName: String, in context: SwitchContext) {
        apply { editedRules in ManualSwitchPolicy.record(keyboardID: keyboardID, appName: appName, in: context, rules: &editedRules) }
    }

    func rememberKeyboardOnEntry(keyboardID: String, appName: String, in context: SwitchContext) {
        apply { editedRules in AppEntryPolicy.record(keyboardID: keyboardID, appName: appName, in: context, rules: &editedRules) }
    }

    func rememberWebsiteOnVisit(keyboardID: String, in context: SwitchContext) {
        apply { editedRules in WebsiteVisitPolicy.record(keyboardID: keyboardID, in: context, rules: &editedRules) }
    }

    private func moveRememberedAppsIntoTheList() {
        guard !rules.lastUsedByApp.isEmpty else { return }
        apply { editedRules in editedRules.moveRememberedAppsIntoTheList(appNameFor: installedAppName) }
    }

    private func edit(_ change: (inout RulesFile) -> Void) {
        let didChange = apply(change)
        if didChange {
            onEdit?()
        }
    }

    @discardableResult
    private func apply(_ change: (inout RulesFile) -> Void) -> Bool {
        var updatedRules = rules
        change(&updatedRules)
        guard updatedRules != rules else { return false }
        rules = updatedRules
        save()
        return true
    }

    private func save() {
        do {
            try store.save(rules)
        } catch {
            Log.rules.error("Could not save rules: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func moveAsideUnreadableFile() {
        guard let movedTo = try? store.moveAsideUnreadableFile() else { return }
        Log.rules.notice("Moved the unreadable rules file to \(movedTo.path, privacy: .public)")
    }
}
