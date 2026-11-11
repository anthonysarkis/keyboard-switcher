import SwiftUI

struct RemoveRowButton: View {
    private static let iconFont = Font.system(size: 15)

    let accessibilityLabel: String
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .font(Self.iconFont)
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .opacity(isVisible ? 1 : 0)
        .help("Remove")
        .accessibilityLabel(accessibilityLabel)
    }
}

extension View {
    func removeButton(accessibilityLabel: String, isVisible: Bool, action: @escaping () -> Void) -> some View {
        overlay(alignment: .leading) {
            RemoveRowButton(accessibilityLabel: accessibilityLabel, isVisible: isVisible, action: action)
                .offset(x: -28)
        }
    }
}
