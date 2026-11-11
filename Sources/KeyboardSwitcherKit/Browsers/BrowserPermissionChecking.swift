public protocol BrowserPermissionChecking: AnyObject {
    func permission(for browser: SupportedBrowser) -> BrowserPermission
    func requestPermission(for browser: SupportedBrowser) async -> BrowserPermission
}
