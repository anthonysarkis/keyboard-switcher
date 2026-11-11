import Foundation

final class DistributedNotificationRelay: NSObject {
    private let action: @MainActor () -> Void

    init(name: Notification.Name, action: @escaping @MainActor () -> Void) {
        self.action = action
        super.init()
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(receive(_:)),
            name: name,
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
    }

    @objc private func receive(_ notification: Notification) {
        action()
    }
}
