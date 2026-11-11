import KeyboardSwitcherCore
import KeyboardSwitcherKit

enum KeyboardChecks {
    static func listKeyboards() {
        let textInputSources = TextInputSources()
        let currentKeyboardID = textInputSources.currentKeyboardID()
        let keyboards = textInputSources.enabledKeyboards()
        for keyboard in keyboards {
            let marker = keyboard.id == currentKeyboardID ? "→" : " "
            print("\(marker) \(keyboard.name)  \(keyboard.id)")
        }
    }

    static func switchAndRestore() -> Bool {
        let textInputSources = TextInputSources()
        guard let originalKeyboardID = textInputSources.currentKeyboardID() else {
            print("macOS reports no current keyboard.")
            return false
        }
        let keyboards = textInputSources.enabledKeyboards()
        guard let otherKeyboard = keyboards.first(where: { keyboard in keyboard.id != originalKeyboardID }) else {
            print("Only one keyboard is turned on, so there is nothing to switch to.")
            return false
        }

        let switchedAway = textInputSources.select(keyboardID: otherKeyboard.id)
        let keyboardAfterSwitch = textInputSources.currentKeyboardID()
        let switchedBack = textInputSources.select(keyboardID: originalKeyboardID)
        let keyboardAfterRestore = textInputSources.currentKeyboardID()

        report(switchTo: otherKeyboard.id, accepted: switchedAway, reported: keyboardAfterSwitch)
        report(switchTo: originalKeyboardID, accepted: switchedBack, reported: keyboardAfterRestore)
        let switchWorked = switchedAway && keyboardAfterSwitch == otherKeyboard.id
        let restoreWorked = switchedBack && keyboardAfterRestore == originalKeyboardID
        return switchWorked && restoreWorked
    }

    private static func report(switchTo keyboardID: String, accepted: Bool, reported reportedKeyboardID: String?) {
        let answer = accepted ? "accepted" : "refused"
        let reportedKeyboard = reportedKeyboardID ?? "nothing"
        print("Switch to \(keyboardID): \(answer), macOS now reports \(reportedKeyboard)")
    }
}
