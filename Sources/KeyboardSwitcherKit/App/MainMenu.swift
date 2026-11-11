import AppKit

enum MainMenu {
    static func make() -> NSMenu {
        let mainMenu = NSMenu()
        let applicationMenu = makeApplicationMenu()
        let editMenu = makeEditMenu()
        let windowMenu = makeWindowMenu()
        addSubmenu(applicationMenu, titled: "Keyboard Switcher", to: mainMenu)
        addSubmenu(editMenu, titled: "Edit", to: mainMenu)
        addSubmenu(windowMenu, titled: "Window", to: mainMenu)
        return mainMenu
    }

    private static func makeApplicationMenu() -> NSMenu {
        let applicationMenu = NSMenu()
        let separator = NSMenuItem.separator()
        applicationMenu.addItem(withTitle: "Settings…", action: #selector(AppDelegate.showSettings), keyEquivalent: ",")
        applicationMenu.addItem(separator)
        applicationMenu.addItem(withTitle: "Quit Keyboard Switcher", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return applicationMenu
    }

    private static func makeEditMenu() -> NSMenu {
        let editMenu = NSMenu(title: "Edit")
        let separator = NSMenuItem.separator()
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(separator)
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        return editMenu
    }

    private static func makeWindowMenu() -> NSMenu {
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        return windowMenu
    }

    private static func addSubmenu(_ submenu: NSMenu, titled title: String, to mainMenu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.submenu = submenu
        mainMenu.addItem(item)
    }
}
