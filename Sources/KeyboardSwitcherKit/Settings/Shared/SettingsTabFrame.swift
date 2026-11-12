import SwiftUI

struct SettingsTabFrame: ViewModifier {
    private static let width: CGFloat = 520
    private static let listHeight: CGFloat = 520

    let scrollsList: Bool
    @Environment(\.fitsSettingsListsToContent) private var fitsListsToContent

    func body(content: Content) -> some View {
        sizedContent(content)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func sizedContent(_ content: Content) -> some View {
        let groupedContent = content.formStyle(.grouped)
        if scrollsList && !fitsListsToContent {
            groupedContent
                .frame(width: Self.width, height: Self.listHeight)
        } else {
            groupedContent
                .scrollDisabled(true)
                .frame(width: Self.width)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension View {
    func settingsTabFrame() -> some View {
        let tabFrame = SettingsTabFrame(scrollsList: false)
        return modifier(tabFrame)
    }

    func settingsListTabFrame() -> some View {
        let tabFrame = SettingsTabFrame(scrollsList: true)
        return modifier(tabFrame)
    }
}
