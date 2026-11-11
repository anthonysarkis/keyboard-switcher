import KeyboardSwitcherCore

extension ManualSwitchBehavior {
    var title: String {
        switch self {
        case .backToRule: "Back to the rule next time"
        case .becomesRule: "Make it the new rule"
        }
    }
}
