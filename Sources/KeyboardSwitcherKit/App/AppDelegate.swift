import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let fallbackBundleIdentifier = "com.anthonysarkis.keyboard-switcher"

    private var context: AppContext?
    private var frontAppWatcher: FrontAppWatcher?
    private var statusItemController: StatusItemController?
    private var settingsWindowController: SettingsWindowController?

    override public init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? Self.fallbackBundleIdentifier
        let services = AppServices.live(bundleIdentifier: bundleIdentifier)
        let context = AppContext(services: services)
        let frontAppWatcher = FrontAppWatcher { [weak context] frontApp in
            context?.coordinator.frontAppDidChange(to: frontApp)
        }

        context.coordinator.start(frontApp: frontAppWatcher.currentFrontApp)
        frontAppWatcher.start()
        openAtLoginOnFirstLaunch(context)

        self.context = context
        self.frontAppWatcher = frontAppWatcher
        NSApp.mainMenu = MainMenu.make()
        statusItemController = makeStatusItemController(for: context)
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return false
    }

    @objc public func showSettings() {
        guard let context else { return }
        let controller = settingsWindowController ?? SettingsWindowController(context: context)
        settingsWindowController = controller
        controller.show()
    }

    private func openAtLoginOnFirstLaunch(_ context: AppContext) {
        guard context.ruleBook.startedWithoutRulesFile else { return }
        context.systemToggles.setLaunchAtLogin(true)
    }

    private func makeStatusItemController(for context: AppContext) -> StatusItemController {
        let menuBuilder = StatusMenuBuilder(
            coordinator: context.coordinator,
            catalog: context.catalog,
            ruleBook: context.ruleBook,
            tabTracker: context.tabTracker,
            openSettings: { [weak self] in self?.showSettings() }
        )
        return StatusItemController(catalog: context.catalog, menuBuilder: menuBuilder)
    }
}
