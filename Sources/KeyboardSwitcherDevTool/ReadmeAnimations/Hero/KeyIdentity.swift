enum KeyIdentity: Equatable {
    case withoutKeyCode
    case code(Int)
    case topLeft

    var keyCode: Int? {
        if case .code(let keyCode) = self {
            return keyCode
        }
        return nil
    }
}
