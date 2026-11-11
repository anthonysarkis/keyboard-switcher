import AppKit
import UniformTypeIdentifiers

enum ApplicationPicker {
    private static let applicationsFolder = URL(fileURLWithPath: "/Applications")

    static func pick() -> AppIdentity? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = applicationsFolder
        openPanel.prompt = "Add"

        let response = openPanel.runModal()
        guard response == .OK, let applicationURL = openPanel.url else { return nil }
        return AppIdentity(applicationURL: applicationURL)
    }
}
