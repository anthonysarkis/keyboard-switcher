import SwiftUI

// Drawn to match the app icons beside it, measured on Chrome's icon in this window at 2x:
// a 20 pt body with 4.5 pt continuous corners, raised 0.5 pt in its 24 pt frame, over a 36 % black shadow (1 pt blur, 0.5 pt down).
struct WebsiteIconView: View {
    private static let frameSize: CGFloat = 24
    private static let bodySize: CGFloat = 20
    private static let cornerRadius: CGFloat = 4.5
    private static let bodyLift: CGFloat = 0.5
    private static let shadowOpacity = 0.36
    private static let shadowBlur: CGFloat = 1
    private static let shadowDrop: CGFloat = 0.5
    private static let globeFont = Font.system(size: 11, weight: .medium)

    @Environment(\.websiteIconOverrides) private var websiteIconOverrides

    let website: String
    let websiteIcons: WebsiteIconStore

    var body: some View {
        let icon = websiteIconOverrides[website] ?? websiteIcons.icon(for: website)

        iconBody(icon)
            .offset(y: -Self.bodyLift)
            .frame(width: Self.frameSize, height: Self.frameSize)
            .animation(.easeOut(duration: 0.2), value: icon != nil)
            .task(id: website) { websiteIcons.iconWanted(for: website) }
            .accessibilityHidden(true)
    }

    private var bodyShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private func iconBody(_ icon: WebsiteIcon?) -> some View {
        if let icon {
            Image(nsImage: icon.image)
                .resizable()
                .interpolation(.high)
                .frame(width: Self.bodySize, height: Self.bodySize)
                .clipShape(bodyShape)
                .shadow(color: .black.opacity(Self.shadowOpacity), radius: Self.shadowBlur, x: 0, y: Self.shadowDrop)
        } else {
            Image(systemName: "globe")
                .font(Self.globeFont)
                .foregroundStyle(.secondary)
                .frame(width: Self.bodySize, height: Self.bodySize)
                .background(.quaternary, in: bodyShape)
        }
    }
}
