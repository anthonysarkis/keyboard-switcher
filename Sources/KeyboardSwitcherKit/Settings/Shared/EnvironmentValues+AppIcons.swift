import AppKit
import SwiftUI

extension EnvironmentValues {
    @Entry public var appIconOverrides: [String: NSImage] = [:]
    @Entry public var fitsSettingsListsToContent = false
    @Entry public var websiteIconOverrides: [String: WebsiteIcon] = [:]
}
