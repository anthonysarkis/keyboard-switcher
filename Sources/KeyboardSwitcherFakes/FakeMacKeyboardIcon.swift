import KeyboardSwitcherKit

public final class FakeMacKeyboardIcon: MacKeyboardIconControlling {
    public private(set) var isShown: Bool

    public init(isShown: Bool) {
        self.isShown = isShown
    }

    public func setShown(_ shown: Bool) {
        isShown = shown
    }
}
