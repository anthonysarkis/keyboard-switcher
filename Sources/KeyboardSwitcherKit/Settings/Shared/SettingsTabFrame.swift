import SwiftUI

struct SettingsTabFrame: ViewModifier {
    private static let width: CGFloat = 520

    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(width: Self.width)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func settingsTabFrame() -> some View {
        let tabFrame = SettingsTabFrame()
        return modifier(tabFrame)
    }
}
