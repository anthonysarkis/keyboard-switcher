import KeyboardSwitcherKit

public final class FakeLoginItem: LoginItemControlling {
    public private(set) var isEnabled: Bool

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    public func setEnabled(_ enabled: Bool) throws {
        isEnabled = enabled
    }
}
