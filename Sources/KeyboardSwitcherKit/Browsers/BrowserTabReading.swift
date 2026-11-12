public protocol BrowserTabReading: AnyObject, Sendable {
    func currentTabAddress(in browser: SupportedBrowser) async -> TabAddressResult
}
