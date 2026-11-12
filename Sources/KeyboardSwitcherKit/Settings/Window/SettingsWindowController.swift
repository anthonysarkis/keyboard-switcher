import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {
    private static let frameAutosaveName = "Settings"

    convenience init(context: AppContext) {
        let tabViewController = SettingsTabViewController()
        tabViewController.tabStyle = .toolbar
        tabViewController.transitionOptions = []
        let tabs = Self.tabs(for: context)
        for tab in tabs {
            tabViewController.addTabViewItem(tab)
        }
        let window = Self.makeWindow(showing: tabViewController)
        self.init(window: window)
    }

    func show() {
        NSApp.activate()
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }

    private static func tabs(for context: AppContext) -> [NSTabViewItem] {
        let appsTab = AppsTab(
            ruleBook: context.ruleBook,
            catalog: context.catalog,
            ownBundleIdentifier: context.coordinator.ownBundleIdentifier
        )
        let websitesTab = WebsitesTab(ruleBook: context.ruleBook, catalog: context.catalog, tabTracker: context.tabTracker)
        let generalTab = GeneralTab(ruleBook: context.ruleBook, systemToggles: context.systemToggles)
        return [
            tabItem(label: "Apps", symbolName: "square.grid.2x2", content: appsTab),
            tabItem(label: "Websites", symbolName: "globe", content: websitesTab),
            tabItem(label: "General", symbolName: "gearshape", content: generalTab),
        ]
    }

    private static func tabItem(label: String, symbolName: String, content: some View) -> NSTabViewItem {
        let hostingController = NSHostingController(rootView: content)
        hostingController.title = label
        hostingController.sizingOptions = [.preferredContentSize]
        let tabItem = NSTabViewItem(viewController: hostingController)
        tabItem.label = label
        tabItem.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: label)
        return tabItem
    }

    private static func makeWindow(showing contentViewController: NSViewController) -> NSWindow {
        let window = NSWindow(contentViewController: contentViewController)
        window.styleMask = [.titled, .closable]
        window.toolbarStyle = .preference
        window.isReleasedWhenClosed = false
        let restoredSavedFrame = window.setFrameUsingName(frameAutosaveName)
        if !restoredSavedFrame {
            window.center()
        }
        window.setFrameAutosaveName(frameAutosaveName)
        return window
    }
}
