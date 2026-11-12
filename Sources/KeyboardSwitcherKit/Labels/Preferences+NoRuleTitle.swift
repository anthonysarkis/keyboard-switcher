import KeyboardSwitcherCore

extension Preferences {
    var noRuleTitle: String {
        remembersManualSwitches ? "Last one used" : "Leave as is"
    }
}
