import KeyboardSwitcherCore

extension OtherAppsBehavior {
    var title: String {
        switch self {
        case .lastUsed: "Last one used"
        case .leaveAsIs: "Leave as is"
        }
    }
}
