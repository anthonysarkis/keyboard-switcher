import KeyboardSwitcherCore

extension DecisionSource {
    var logDescription: String {
        switch self {
        case .websiteRule: "website rule"
        case .appRule: "app rule"
        }
    }
}
