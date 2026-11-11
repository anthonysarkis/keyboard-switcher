import AppKit

final class SettingsTabViewController: NSTabViewController {
    override func viewWillAppear() {
        super.viewWillAppear()
        fitWindowToSelectedTab(animated: false)
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        let windowIsVisible = view.window?.isVisible == true
        fitWindowToSelectedTab(animated: windowIsVisible)
    }

    override func preferredContentSizeDidChange(for viewController: NSViewController) {
        super.preferredContentSizeDidChange(for: viewController)
        guard viewController === selectedTabViewController else { return }
        fitWindowToSelectedTab(animated: true)
    }

    private var selectedTabViewController: NSViewController? {
        guard tabViewItems.indices.contains(selectedTabViewItemIndex) else { return nil }
        return tabViewItems[selectedTabViewItemIndex].viewController
    }

    private func fitWindowToSelectedTab(animated: Bool) {
        guard let window = view.window, let selectedController = selectedTabViewController else { return }
        let contentSize = selectedController.preferredContentSize
        guard contentSize.width > 0, contentSize.height > 0 else { return }

        let contentFrame = NSRect(origin: .zero, size: contentSize)
        let newFrameSize = window.frameRect(forContentRect: contentFrame).size
        var newFrame = window.frame
        newFrame.origin.y += newFrame.height - newFrameSize.height
        newFrame.size = newFrameSize
        window.setFrame(newFrame, display: true, animate: animated)
    }
}
