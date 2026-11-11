import AppKit

enum SnapshotSetup {
    static func prepare(folder: URL) throws {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }
}
