public enum DecisionSource: Equatable, Sendable {
    case websiteRule(website: String)
    case appRule
}
