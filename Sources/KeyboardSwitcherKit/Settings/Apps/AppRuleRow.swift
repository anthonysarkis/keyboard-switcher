import SwiftUI
import KeyboardSwitcherCore

struct AppRuleRow: View {
    let appRule: AppRule
    let ruleBook: RuleBook
    let keyboards: [Keyboard]
    @State private var isHovering = false

    var body: some View {
        LabeledContent {
            KeyboardPicker(title: "Keyboard for \(appRule.appName)", keyboards: keyboards, keyboardID: keyboardBinding)
                .removeButton(accessibilityLabel: "Remove the rule for \(appRule.appName)", isVisible: isHovering, action: remove)
        } label: {
            HStack(spacing: 10) {
                AppIconView(bundleIdentifier: appRule.bundleIdentifier)
                Text(appRule.appName)
            }
        }
        .onHover { hovering in isHovering = hovering }
        .contextMenu {
            Button("Remove", action: remove)
        }
    }

    private var keyboardBinding: Binding<String> {
        Binding(
            get: { appRule.keyboardID },
            set: { keyboardID in
                ruleBook.setAppRule(bundleIdentifier: appRule.bundleIdentifier, appName: appRule.appName, keyboardID: keyboardID)
            }
        )
    }

    private func remove() {
        ruleBook.removeAppRule(bundleIdentifier: appRule.bundleIdentifier)
    }
}
