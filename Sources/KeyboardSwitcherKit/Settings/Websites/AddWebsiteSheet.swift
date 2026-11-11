import SwiftUI
import KeyboardSwitcherCore

struct AddWebsiteSheet: View {
    private static let width: CGFloat = 360

    let ruleBook: RuleBook
    let catalog: KeyboardCatalog
    let suggestedWebsite: String?
    @Environment(\.dismiss) private var dismiss
    @State private var typedAddress = ""
    @State private var keyboardID = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Website")
                .font(.headline)

            Form {
                TextField("Website", text: $typedAddress, prompt: Text("claude.ai"))
                Picker("Keyboard", selection: $keyboardID) {
                    ForEach(catalog.keyboards) { keyboard in
                        Text(keyboard.name).tag(keyboard.id)
                    }
                }
            }
            .formStyle(.columns)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add", action: add)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canAdd)
            }
        }
        .padding(20)
        .frame(width: Self.width)
        .onAppear(perform: fillSuggestions)
    }

    private var canAdd: Bool {
        let website = WebsiteAddress.website(fromTypedText: typedAddress)
        return website != nil && !keyboardID.isEmpty
    }

    private func fillSuggestions() {
        typedAddress = suggestedWebsite ?? ""
        keyboardID = catalog.currentKeyboardID ?? catalog.keyboards.first?.id ?? ""
    }

    private func add() {
        let wasAdded = ruleBook.addWebsiteRule(typedText: typedAddress, keyboardID: keyboardID)
        if wasAdded {
            dismiss()
        }
    }
}
