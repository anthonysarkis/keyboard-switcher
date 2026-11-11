public enum TabAddressResult: Equatable, Sendable {
    case address(String)
    case noWindow
    case denied
    case failed
}
