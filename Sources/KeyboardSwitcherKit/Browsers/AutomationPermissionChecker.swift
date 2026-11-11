import AppKit
import Carbon

public final class AutomationPermissionChecker: BrowserPermissionChecking {
    public init() {}

    public func permission(for browser: SupportedBrowser) -> BrowserPermission {
        let permissionStatus = Self.determinePermission(bundleIdentifier: browser.bundleIdentifier, askUserIfNeeded: false)
        return Self.permission(from: permissionStatus)
    }

    public func requestPermission(for browser: SupportedBrowser) async -> BrowserPermission {
        let bundleIdentifier = browser.bundleIdentifier
        let questionWaitingForAnswer = Task.detached {
            Self.determinePermission(bundleIdentifier: bundleIdentifier, askUserIfNeeded: true)
        }
        let permissionStatus = await questionWaitingForAnswer.value
        return Self.permission(from: permissionStatus)
    }

    private nonisolated static func determinePermission(bundleIdentifier: String, askUserIfNeeded: Bool) -> OSStatus {
        let target = NSAppleEventDescriptor(bundleIdentifier: bundleIdentifier)
        let readTabEventClass = AEEventClass(kAECoreSuite)
        let readTabEventID = AEEventID(kAEGetData)
        return AEDeterminePermissionToAutomateTarget(target.aeDesc, readTabEventClass, readTabEventID, askUserIfNeeded)
    }

    private nonisolated static func permission(from permissionStatus: OSStatus) -> BrowserPermission {
        switch permissionStatus {
        case noErr: .allowed
        case OSStatus(errAEEventNotPermitted): .denied
        case OSStatus(procNotFound): .notOpen
        default: .asksFirstTime
        }
    }
}
