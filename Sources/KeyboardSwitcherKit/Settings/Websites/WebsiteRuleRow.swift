import SwiftUI
import KeyboardSwitcherCore

struct WebsiteRuleRow: View {
    let websiteRule: WebsiteRule
    let ruleBook: RuleBook
    let keyboards: [Keyboard]
    let websiteIcons: WebsiteIconStore
    @State private var isHovering = false

    var body: some View {
        LabeledContent {
            KeyboardPicker(title: "Keyboard for \(websiteRule.website)", keyboards: keyboards, keyboardID: keyboardBinding)
                .removeButton(accessibilityLabel: "Remove the rule for \(websiteRule.website)", isVisible: isHovering, action: remove)
        } label: {
            HStack(spacing: 10) {
                WebsiteIconView(website: websiteRule.website, websiteIcons: websiteIcons)
                Text(websiteRule.website)
            }
        }
        .onHover { hovering in isHovering = hovering }
        .contextMenu {
            Button("Remove", action: remove)
        }
    }

    private var keyboardBinding: Binding<String> {
        Binding(
            get: { websiteRule.keyboardID },
            set: { keyboardID in ruleBook.setWebsiteRule(website: websiteRule.website, keyboardID: keyboardID) }
        )
    }

    private func remove() {
        ruleBook.removeWebsiteRule(website: websiteRule.website)
    }
}
