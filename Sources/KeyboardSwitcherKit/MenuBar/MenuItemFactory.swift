import AppKit

enum MenuItemFactory {
    static func actionItem(
        _ title: String,
        isChecked: Bool = false,
        keyEquivalent: String = "",
        perform: @escaping @MainActor () -> Void
    ) -> NSMenuItem {
        let menuAction = MenuAction(perform: perform)
        let item = NSMenuItem(title: title, action: #selector(MenuAction.run), keyEquivalent: keyEquivalent)
        item.target = menuAction
        item.representedObject = menuAction
        item.state = isChecked ? .on : .off
        return item
    }

    static func header(_ title: String, image: NSImage? = nil) -> NSMenuItem {
        let header = NSMenuItem.sectionHeader(title: title)
        header.image = image
        return header
    }
}
