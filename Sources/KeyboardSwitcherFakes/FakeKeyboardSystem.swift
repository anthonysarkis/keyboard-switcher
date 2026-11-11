import KeyboardSwitcherCore
import KeyboardSwitcherKit

public final class FakeKeyboardSystem: KeyboardSystem {
    public private(set) var currentID: String?
    public private(set) var selections: [String] = []

    private let keyboards: [Keyboard]
    private var selectionChanged: (@MainActor () -> Void)?

    public init(keyboards: [Keyboard] = SampleKeyboards.both, currentID: String?) {
        self.keyboards = keyboards
        self.currentID = currentID
    }

    public func enabledKeyboards() -> [Keyboard] {
        keyboards
    }

    public func currentKeyboardID() -> String? {
        currentID
    }

    public func select(keyboardID: String) -> Bool {
        let isEnabled = keyboards.contains { keyboard in keyboard.id == keyboardID }
        guard isEnabled else { return false }
        selections.append(keyboardID)
        currentID = keyboardID
        selectionChanged?()
        return true
    }

    public func observeChanges(
        selectionChanged: @escaping @MainActor () -> Void,
        keyboardsChanged: @escaping @MainActor () -> Void
    ) {
        self.selectionChanged = selectionChanged
    }

    public func switchByHand(to keyboardID: String) {
        currentID = keyboardID
        selectionChanged?()
    }
}
