import AppKit
import Observation
import KeyboardSwitcherCore

final class StatusItemController: NSObject, NSMenuDelegate {
    private static let unknownKeyboardBadge = KeyboardBadge(text: "?", style: .outlined)
    private static let unknownKeyboardImage = BadgeImage.make(for: unknownKeyboardBadge)
    private static let unknownKeyboardName = "Unknown keyboard"

    private let catalog: KeyboardCatalog
    private let menuBuilder: StatusMenuBuilder
    private let statusItem: NSStatusItem

    init(catalog: KeyboardCatalog, menuBuilder: StatusMenuBuilder) {
        self.catalog = catalog
        self.menuBuilder = menuBuilder
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        statusItem.menu = makeMenu()
        followCurrentKeyboard()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menuBuilder.rebuild(menu)
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        return menu
    }

    private func followCurrentKeyboard() {
        withObservationTracking {
            showCurrentKeyboard()
        } onChange: { [weak self] in
            Task { @MainActor in self?.followCurrentKeyboard() }
        }
    }

    private func showCurrentKeyboard() {
        let keyboard = catalog.currentKeyboard
        let badgeImage = keyboard.flatMap { currentKeyboard in catalog.badgeImage(for: currentKeyboard.id) } ?? Self.unknownKeyboardImage
        let keyboardName = keyboard?.name ?? Self.unknownKeyboardName

        statusItem.button?.image = badgeImage
        statusItem.button?.toolTip = keyboardName
        statusItem.button?.setAccessibilityLabel("Keyboard Switcher, \(keyboardName)")
    }
}
