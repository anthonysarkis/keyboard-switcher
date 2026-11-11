final class ManualSwitchDetector {
    var onSettled: (@MainActor (String) -> Void)?
    private(set) var settleCheck: Task<Void, Never>?

    private let settleDuration: Duration
    private var knownKeyboardID: String?
    private var settlingKeyboardID: String?

    init(settleDuration: Duration) {
        self.settleDuration = settleDuration
    }

    func note(_ keyboardID: String?) {
        knownKeyboardID = keyboardID
    }

    func beginSwitch(to keyboardID: String) {
        knownKeyboardID = keyboardID
        settlingKeyboardID = keyboardID
        settleCheck?.cancel()
        settleCheck = Task { [weak self, settleDuration] in
            try? await Task.sleep(for: settleDuration)
            guard !Task.isCancelled else { return }
            self?.finishSettling()
        }
    }

    func cancelSwitch(keeping keyboardID: String?) {
        settleCheck?.cancel()
        settleCheck = nil
        settlingKeyboardID = nil
        knownKeyboardID = keyboardID
    }

    func isManualChange(to keyboardID: String) -> Bool {
        guard settlingKeyboardID == nil, keyboardID != knownKeyboardID else { return false }
        knownKeyboardID = keyboardID
        return true
    }

    private func finishSettling() {
        guard let settledKeyboardID = settlingKeyboardID else { return }
        settlingKeyboardID = nil
        knownKeyboardID = settledKeyboardID
        onSettled?(settledKeyboardID)
    }
}
