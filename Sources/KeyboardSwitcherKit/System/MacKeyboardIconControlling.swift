public protocol MacKeyboardIconControlling: AnyObject {
    var isShown: Bool { get }
    func setShown(_ shown: Bool)
}
