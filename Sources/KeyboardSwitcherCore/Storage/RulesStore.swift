import Foundation

public struct RulesStore: Sendable {
    private static let fileName = "rules.json"
    private static let unreadableFilePrefix = "rules.unreadable-"

    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public static func defaultFileURL(bundleIdentifier: String) -> URL {
        let applicationSupportFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appFolder = applicationSupportFolder.appending(path: bundleIdentifier, directoryHint: .isDirectory)
        return appFolder.appending(path: fileName, directoryHint: .notDirectory)
    }

    public func load() throws -> RulesFile? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let fileData = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(RulesFile.self, from: fileData)
    }

    public func save(_ rules: RulesFile) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let fileData = try encoder.encode(rules)
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try fileData.write(to: fileURL, options: .atomic)
    }

    public func moveAsideUnreadableFile(now: Date = Date()) throws -> URL {
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: now)
        let fileNameSafeTimestamp = timestamp.replacingOccurrences(of: ":", with: "-")
        let folder = fileURL.deletingLastPathComponent()
        let destination = folder.appending(path: "\(Self.unreadableFilePrefix)\(fileNameSafeTimestamp).json")
        try FileManager.default.moveItem(at: fileURL, to: destination)
        return destination
    }
}
