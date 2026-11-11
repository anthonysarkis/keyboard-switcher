import Carbon
import Foundation
import KeyboardSwitcherCore

public final class TextInputSources: KeyboardSystem {
    private var notificationRelays: [DistributedNotificationRelay] = []

    public init() {}

    public func enabledKeyboards() -> [Keyboard] {
        let selectableKeyboardsFilter = [
            kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String,
            kTISPropertyInputSourceIsSelectCapable as String: true,
        ] as CFDictionary
        let sources = inputSources(matching: selectableKeyboardsFilter)
        return sources.compactMap(Self.keyboard(from:))
    }

    public func currentKeyboardID() -> String? {
        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        return Self.stringProperty(kTISPropertyInputSourceID, of: currentSource)
    }

    public func select(keyboardID: String) -> Bool {
        let keyboardFilter = [kTISPropertyInputSourceID as String: keyboardID] as CFDictionary
        let matchingSources = inputSources(matching: keyboardFilter)
        guard let source = matchingSources.first else { return false }
        let selectStatus = TISSelectInputSource(source)
        return selectStatus == noErr
    }

    public func observeChanges(
        selectionChanged: @escaping @MainActor () -> Void,
        keyboardsChanged: @escaping @MainActor () -> Void
    ) {
        let selectionNotification = Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String)
        let keyboardListNotification = Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String)
        let selectionRelay = DistributedNotificationRelay(name: selectionNotification, action: selectionChanged)
        let keyboardListRelay = DistributedNotificationRelay(name: keyboardListNotification, action: keyboardsChanged)
        notificationRelays = [selectionRelay, keyboardListRelay]
    }

    private func inputSources(matching filter: CFDictionary) -> [TISInputSource] {
        guard let sourceList = TISCreateInputSourceList(filter, false)?.takeRetainedValue() else { return [] }
        return sourceList as? [TISInputSource] ?? []
    }

    private static func keyboard(from source: TISInputSource) -> Keyboard? {
        guard let identifier = stringProperty(kTISPropertyInputSourceID, of: source),
              let name = stringProperty(kTISPropertyLocalizedName, of: source)
        else { return nil }
        return Keyboard(id: identifier, name: name)
    }

    private static func stringProperty(_ key: CFString, of source: TISInputSource) -> String? {
        guard let rawValue = TISGetInputSourceProperty(source, key) else { return nil }
        let value = Unmanaged<CFString>.fromOpaque(rawValue).takeUnretainedValue()
        return value as String
    }
}
