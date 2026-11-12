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
                Picker("Remember apps", selection: appsRememberingBinding) {
                    Text("Every app you open").tag(RememberingMode.everyOne)
                    Text("Apps you switch language on").tag(RememberingMode.switchedByHand)
                    Text("Only apps you add").tag(RememberingMode.addedByYou)
                }
                Picker("Remember websites", selection: websitesRememberingBinding) {
                    Text("Every site you visit").tag(RememberingMode.everyOne)
                    Text("Sites you switch language on").tag(RememberingMode.switchedByHand)
                    Text("Only sites you add").tag(RememberingMode.addedByYou)
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

    private var appsRememberingBinding: Binding<RememberingMode> {
        Binding(
            get: { ruleBook.rules.preferences.appsRemembering },
            set: { mode in ruleBook.updatePreferences { preferences in preferences.appsRemembering = mode } }
        )
    }

    private var websitesRememberingBinding: Binding<RememberingMode> {
        Binding(
            get: { ruleBook.rules.preferences.websitesRemembering },
            set: { mode in ruleBook.updatePreferences { preferences in preferences.websitesRemembering = mode } }
        )
    }
}
