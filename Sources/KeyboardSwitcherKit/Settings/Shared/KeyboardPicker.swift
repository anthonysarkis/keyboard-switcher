import SwiftUI
import KeyboardSwitcherCore

struct KeyboardPicker: View {
    private static let missingKeyboardTitle = "Keyboard turned off in macOS"

    let title: String
    let keyboards: [Keyboard]
    @Binding var keyboardID: String

    var body: some View {
        Picker(title, selection: $keyboardID) {
            ForEach(keyboards) { keyboard in
                Text(keyboard.name).tag(keyboard.id)
            }
            if isMissingSelectedKeyboard {
                Text(Self.missingKeyboardTitle).tag(keyboardID)
            }
        }
        .labelsHidden()
        .fixedSize()
    }

    private var isMissingSelectedKeyboard: Bool {
        !keyboards.contains { keyboard in keyboard.id == keyboardID }
    }
}
