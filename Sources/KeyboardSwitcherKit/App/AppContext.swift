public final class AppContext {
    public let catalog: KeyboardCatalog
    public let ruleBook: RuleBook
    public let tabTracker: BrowserTabTracker
    public let coordinator: SwitchCoordinator
    public let systemToggles: SystemToggles

    public init(services: AppServices) {
        let catalog = KeyboardCatalog(keyboardSystem: services.keyboardSystem, badgeImageMaker: services.badgeImageMaker)
        let ruleBook = RuleBook(store: services.rulesStore, installedAppName: services.installedAppName)
        let tabTracker = BrowserTabTracker(
            tabReader: services.tabReader,
            permissionChecker: services.permissionChecker,
            checkInterval: services.browserCheckInterval,
            firstReadPatience: services.firstTabReadPatience
        )
        let manualSwitchDetector = ManualSwitchDetector(settleDuration: services.settleDuration)
        let coordinator = SwitchCoordinator(
            catalog: catalog,
            ruleBook: ruleBook,
            tabTracker: tabTracker,
            bubble: services.bubble,
            manualSwitchDetector: manualSwitchDetector,
            ownBundleIdentifier: services.ownBundleIdentifier
        )
        let systemToggles = SystemToggles(loginItem: services.loginItem, macKeyboardIcon: services.macKeyboardIcon)

        self.catalog = catalog
        self.ruleBook = ruleBook
        self.tabTracker = tabTracker
        self.coordinator = coordinator
        self.systemToggles = systemToggles
    }
}
