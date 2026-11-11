import AppKit

@objc protocol InputSourceIconManaging: NSObjectProtocol {
    @objc(initWithEnableInputSources:primaryLocale:)
    init(enabledInputSourceIDs: [String], primaryLocale: Locale)

    @objc(imageForInputSource:language:forceToFillBackground:useRoundCorenr:)
    func image(forInputSource inputSourceID: String, language: String?, forceToFillBackground: Bool, useRoundCorner: Bool) -> NSImage?
}
