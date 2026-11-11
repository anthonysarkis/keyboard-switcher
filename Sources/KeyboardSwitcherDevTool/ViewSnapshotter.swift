import AppKit
import SwiftUI

enum ViewSnapshotter {
    private static let firstLayoutWait: TimeInterval = 0.4

    static func write(_ view: some View, named name: String, in folder: URL) throws {
        let hostingView = NSHostingView(rootView: view)
        let fittingSize = hostingView.fittingSize
        let windowFrame = NSRect(origin: .zero, size: fittingSize)
        let window = NSWindow(contentRect: windowFrame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .aqua)
        window.contentView = hostingView
        hostingView.frame = windowFrame
        hostingView.layoutSubtreeIfNeeded()
        let layoutDeadline = Date().addingTimeInterval(firstLayoutWait)
        RunLoop.current.run(until: layoutDeadline)

        let fileURL = folder.appending(path: "\(name).png")
        try writePNG(of: hostingView, to: fileURL)
        let widthInPoints = Int(fittingSize.width)
        let heightInPoints = Int(fittingSize.height)
        print("\(name): \(widthInPoints) × \(heightInPoints) points")
    }

    private static func writePNG(of view: NSView, to fileURL: URL) throws {
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            throw SnapshotError.noBitmap(fileURL.lastPathComponent)
        }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw SnapshotError.noPNG(fileURL.lastPathComponent)
        }
        try pngData.write(to: fileURL)
    }
}
