import Foundation

nonisolated struct SavedWebsiteIcon: Sendable, Equatable {
    let icon: PreparedWebsiteIcon
    let savedAt: Date
}

// Every file operation goes through one serial queue, so a removal and a later save of the same site never swap places.
nonisolated final class WebsiteIconCache: Sendable {
    private static let fileExtension = "png"
    private static let fileNameCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789.-")

    let folder: URL
    private let queue = DispatchQueue(label: "com.anthonysarkis.keyboard-switcher.website-icons", qos: .utility)

    init(folder: URL) {
        self.folder = folder
    }

    static func fileName(for website: String) -> String {
        let safeName = website.addingPercentEncoding(withAllowedCharacters: fileNameCharacters) ?? website
        return "\(safeName).\(fileExtension)"
    }

    func fileURL(for website: String) -> URL {
        folder.appending(path: Self.fileName(for: website), directoryHint: .notDirectory)
    }

    func savedIcon(for website: String) async -> SavedWebsiteIcon? {
        await onQueue {
            let fileURL = self.fileURL(for: website)
            guard let pngData = try? Data(contentsOf: fileURL),
                  let icon = WebsiteIconImages.prepared(from: pngData),
                  let savedAt = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
            else { return nil }
            return SavedWebsiteIcon(icon: icon, savedAt: savedAt)
        }
    }

    func prepared(from imageData: Data) async -> PreparedWebsiteIcon? {
        await onQueue { WebsiteIconImages.prepared(from: imageData) }
    }

    func save(_ icon: PreparedWebsiteIcon, for website: String) async -> Bool {
        await onQueue {
            do {
                try FileManager.default.createDirectory(at: self.folder, withIntermediateDirectories: true)
                try icon.pngData.write(to: self.fileURL(for: website), options: .atomic)
                return true
            } catch {
                return false
            }
        }
    }

    func remove(_ website: String) {
        queue.async {
            try? FileManager.default.removeItem(at: self.fileURL(for: website))
        }
    }

    func keepOnly(_ websites: Set<String>) {
        queue.async {
            let keptFileNames = Set(websites.map(Self.fileName(for:)))
            let savedFiles = (try? FileManager.default.contentsOfDirectory(at: self.folder, includingPropertiesForKeys: nil)) ?? []
            for savedFile in savedFiles where savedFile.pathExtension == Self.fileExtension && !keptFileNames.contains(savedFile.lastPathComponent) {
                try? FileManager.default.removeItem(at: savedFile)
            }
        }
    }

    func waitForPendingWork() async {
        await onQueue {}
    }

    private func onQueue<Result: Sendable>(_ work: @escaping @Sendable () -> Result) async -> Result {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: work())
            }
        }
    }
}
