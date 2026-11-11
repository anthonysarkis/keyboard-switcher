import SwiftUI

struct AppIconView: View {
    private static let size: CGFloat = 24

    let bundleIdentifier: String

    var body: some View {
        let icon = InstalledApps.icon(for: bundleIdentifier)

        Image(nsImage: icon)
            .resizable()
            .interpolation(.high)
            .frame(width: Self.size, height: Self.size)
            .accessibilityHidden(true)
    }
}
