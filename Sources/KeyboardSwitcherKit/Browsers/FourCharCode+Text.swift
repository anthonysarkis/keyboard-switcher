import CoreServices

extension FourCharCode {
    nonisolated init(text: String) {
        self = text.utf8.reduce(0) { code, byte in (code << 8) | FourCharCode(byte) }
    }
}
