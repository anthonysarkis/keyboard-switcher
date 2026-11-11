import AppKit

final class MenuAction: NSObject {
    private let perform: @MainActor () -> Void

    init(perform: @escaping @MainActor () -> Void) {
        self.perform = perform
    }

    @objc func run() {
        perform()
    }
}
