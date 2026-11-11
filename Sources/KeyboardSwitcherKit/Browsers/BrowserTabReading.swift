public protocol BrowserTabReading: AnyObject {
    func currentTabAddress(in browser: SupportedBrowser) -> TabAddressResult
}
