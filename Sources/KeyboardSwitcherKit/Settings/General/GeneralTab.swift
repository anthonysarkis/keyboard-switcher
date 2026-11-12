import SwiftUI
import KeyboardSwitcherCore

public struct GeneralTab: View {
    let ruleBook: RuleBook
    let systemToggles: SystemToggles

    public init(ruleBook: RuleBook, systemToggles: SystemToggles) {
        self.ruleBook = ruleBook
        self.systemToggles = systemToggles
    }

    public var body: some View {
        Form {
            Section {
                Toggle("Open at login", isOn: launchAtLoginBinding)
                Toggle("Show a bubble when it switches", isOn: bubbleBinding)
                Toggle("Show the Mac's own keyboard icon", isOn: macKeyboardIconBinding)
                Toggle(isOn: remembersManualSwitchesBinding) {
                    Text("Remember keyboard changes you make yourself")
                    Text("Switch with Control-Space or \(globeKey), and that app or website gets it back next time.\nWhen off, the keyboard changes only for apps and websites in your list.")
                }
            }
        }
        .toggleStyle(.switch)
        .settingsTabFrame()
        .onAppear { systemToggles.refresh() }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { systemToggles.launchAtLogin },
            set: { enabled in systemToggles.setLaunchAtLogin(enabled) }
        )
    }

    private var macKeyboardIconBinding: Binding<Bool> {
        Binding(
            get: { systemToggles.showMacKeyboardIcon },
            set: { shown in systemToggles.setShowMacKeyboardIcon(shown) }
        )
    }

    private var bubbleBinding: Binding<Bool> {
        Binding(
            get: { ruleBook.rules.preferences.showBubble },
            set: { shown in ruleBook.updatePreferences { preferences in preferences.showBubble = shown } }
        )
    }

    private var globeKey: Image {
        Image(systemName: "globe")
    }

    private var remembersManualSwitchesBinding: Binding<Bool> {
        Binding(
            get: { ruleBook.rules.preferences.remembersManualSwitches },
            set: { remembers in
                ruleBook.updatePreferences { preferences in preferences.remembersManualSwitches = remembers }
            }
        )
    }
}
