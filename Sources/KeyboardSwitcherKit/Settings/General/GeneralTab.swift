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
            }

            Section {
                Toggle("Show a bubble when it switches", isOn: bubbleBinding)
                Toggle("Show the Mac's own keyboard icon", isOn: macKeyboardIconBinding)
            }

            Section {
                Picker("If I switch by hand", selection: manualSwitchBinding) {
                    ForEach(ManualSwitchBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.title).tag(behavior)
                    }
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

    private var manualSwitchBinding: Binding<ManualSwitchBehavior> {
        Binding(
            get: { ruleBook.rules.preferences.manualSwitch },
            set: { behavior in ruleBook.updatePreferences { preferences in preferences.manualSwitch = behavior } }
        )
    }
}
