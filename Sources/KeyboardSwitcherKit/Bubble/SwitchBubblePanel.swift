import AppKit
import SwiftUI

public final class SwitchBubblePanel: BubblePresenting {
    private var panel: NSPanel?
    private var hideTask: Task<Void, Never>?

    public init() {}

    public func showBubble(badgeImage: NSImage, keyboardName: String) {
        let bubbleView = BubbleView(badgeImage: badgeImage, keyboardName: keyboardName)
        let hostingView = NSHostingView(rootView: bubbleView)
        let bubbleSize = hostingView.fittingSize
        let bubbleOrigin = originNearPointer(for: bubbleSize)
        let bubbleFrame = NSRect(origin: bubbleOrigin, size: bubbleSize)
        let bubblePanel = panel ?? Self.makePanel()
        panel = bubblePanel

        bubblePanel.contentView = hostingView
        bubblePanel.setFrame(bubbleFrame, display: true)
        fadeIn(bubblePanel)
        scheduleFadeOut()
    }

    private func fadeIn(_ bubblePanel: NSPanel) {
        bubblePanel.alphaValue = 0
        bubblePanel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = BubbleMetrics.fadeInDuration
            bubblePanel.animator().alphaValue = 1
        }
    }

    private func scheduleFadeOut() {
        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(for: BubbleMetrics.visibleDuration)
            guard !Task.isCancelled else { return }
            self?.fadeOut()
        }
    }

    private func fadeOut() {
        guard let bubblePanel = panel else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = BubbleMetrics.fadeOutDuration
            bubblePanel.animator().alphaValue = 0
        } completionHandler: {
            MainActor.assumeIsolated {
                if bubblePanel.alphaValue == 0 {
                    bubblePanel.orderOut(nil)
                }
            }
        }
    }

    private func originNearPointer(for bubbleSize: NSSize) -> NSPoint {
        let pointer = NSEvent.mouseLocation
        let pointerScreen = NSScreen.screens.first { screen in NSMouseInRect(pointer, screen.frame, false) }
        let screen = pointerScreen ?? NSScreen.main
        let fallbackFrame = NSRect(origin: .zero, size: bubbleSize)
        let visibleFrame = screen?.visibleFrame ?? fallbackFrame
        return BubblePlacement.origin(for: bubbleSize, pointer: pointer, visibleFrame: visibleFrame)
    }

    private static func makePanel() -> NSPanel {
        let bubblePanel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        bubblePanel.isOpaque = false
        bubblePanel.backgroundColor = .clear
        bubblePanel.hasShadow = false
        bubblePanel.ignoresMouseEvents = true
        bubblePanel.level = .statusBar
        bubblePanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        bubblePanel.isReleasedWhenClosed = false
        return bubblePanel
    }
}
