import KeyboardSwitcherCore

public protocol KeyboardSystem: AnyObject {
    func enabledKeyboards() -> [Keyboard]
    func currentKeyboardID() -> String?
    func select(keyboardID: String) -> Bool
    func observeChanges(
        selectionChanged: @escaping @MainActor () -> Void,
        keyboardsChanged: @escaping @MainActor () -> Void
    )
}
