import AppKit
import Carbon

public final class AppleScriptTabReader: BrowserTabReading {
    private static let timeoutSeconds = 1

    private var compiledScripts: [String: NSAppleScript] = [:]

    public init() {}

    public func currentTabAddress(in browser: SupportedBrowser) -> TabAddressResult {
        guard let script = compiledScript(for: browser) else { return .failed }

        var errorInfo: NSDictionary?
        let scriptResult = script.executeAndReturnError(&errorInfo)
        if let errorInfo {
            return Self.result(forError: errorInfo)
        }

        guard let address = scriptResult.stringValue, !address.isEmpty else { return .noWindow }
        return .address(address)
    }

    private func compiledScript(for browser: SupportedBrowser) -> NSAppleScript? {
        if let cachedScript = compiledScripts[browser.bundleIdentifier] {
            return cachedScript
        }

        let source = Self.tabAddressScript(for: browser)
        guard let script = NSAppleScript(source: source) else { return nil }
        var compileError: NSDictionary?
        guard script.compileAndReturnError(&compileError) else { return nil }

        compiledScripts[browser.bundleIdentifier] = script
        return script
    }

    private static func result(forError errorInfo: NSDictionary) -> TabAddressResult {
        let errorNumber = errorInfo[NSAppleScript.errorNumber] as? Int
        return errorNumber == errAEEventNotPermitted ? .denied : .failed
    }

    private static func tabAddressScript(for browser: SupportedBrowser) -> String {
        let currentTab = currentTabObject(in: browser.family)
        return """
        with timeout of \(timeoutSeconds) seconds
            tell application id "\(browser.bundleIdentifier)"
                if (count of windows) is 0 then return ""
                return URL of \(currentTab) of front window
            end tell
        end timeout
        """
    }

    private static func currentTabObject(in family: SupportedBrowser.Family) -> String {
        switch family {
        case .chromium: "active tab"
        case .safari: "current tab"
        }
    }
}
