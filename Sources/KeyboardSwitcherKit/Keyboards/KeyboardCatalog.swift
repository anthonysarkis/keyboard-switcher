import AppKit
import Observation
import KeyboardSwitcherCore

@Observable
public final class KeyboardCatalog {
    public private(set) var keyboards: [Keyboard] = []
    public private(set) var currentKeyboardID: String?
    private var badgeImages: [String: NSImage] = [:]

    private let keyboardSystem: any KeyboardSystem
    private let badgeImageMaker: any BadgeImageMaking

    public init(keyboardSystem: any KeyboardSystem, badgeImageMaker: any BadgeImageMaking) {
        self.keyboardSystem = keyboardSystem
        self.badgeImageMaker = badgeImageMaker
    }

    public var availableKeyboardIDs: Set<String> {
        let keyboardIDs = keyboards.map(\.id)
        return Set(keyboardIDs)
    }

    public var currentKeyboard: Keyboard? {
        keyboard(id: currentKeyboardID)
    }

    public func keyboard(id keyboardID: String?) -> Keyboard? {
        keyboards.first { keyboard in keyboard.id == keyboardID }
    }

    public func badgeImage(for keyboardID: String) -> NSImage? {
        badgeImages[keyboardID]
    }

    func refresh() {
        refreshKeyboards()
        readCurrentKeyboardID()
    }

    @discardableResult
    func readCurrentKeyboardID() -> String? {
        let selectedKeyboardID = keyboardSystem.currentKeyboardID()
        if currentKeyboardID != selectedKeyboardID {
            currentKeyboardID = selectedKeyboardID
        }
        return selectedKeyboardID
    }

    func select(_ keyboardID: String) -> Bool {
        let wasSelected = keyboardSystem.select(keyboardID: keyboardID)
        if wasSelected, currentKeyboardID != keyboardID {
            currentKeyboardID = keyboardID
        }
        return wasSelected
    }

    func observeChanges(selectionChanged: @escaping @MainActor () -> Void) {
        keyboardSystem.observeChanges(
            selectionChanged: selectionChanged,
            keyboardsChanged: { [weak self] in self?.refreshKeyboards() }
        )
    }

    private func refreshKeyboards() {
        let enabledKeyboards = keyboardSystem.enabledKeyboards()
        guard enabledKeyboards != keyboards else { return }
        keyboards = enabledKeyboards
        badgeImages = badgeImageMaker.badgeImages(for: enabledKeyboards)
    }
}
