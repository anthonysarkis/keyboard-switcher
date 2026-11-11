import SwiftUI

struct WebsiteIconView: View {
    private static let size: CGFloat = 24
    private static let cornerRadius: CGFloat = 6
    private static let globeFont = Font.system(size: 13, weight: .medium)

    var body: some View {
        let tile = RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)

        Image(systemName: "globe")
            .font(Self.globeFont)
            .foregroundStyle(.secondary)
            .frame(width: Self.size, height: Self.size)
            .background(.quaternary, in: tile)
            .accessibilityHidden(true)
    }
}
