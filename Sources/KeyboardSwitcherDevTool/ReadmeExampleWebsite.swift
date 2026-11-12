import Foundation
import KeyboardSwitcherCore
import KeyboardSwitcherKit

struct ReadmeExampleWebsite {
    private static let iconFolder = URL(fileURLWithPath: "docs/website-icons")

    let title: String
    let host: String
    let iconName: String
    let keyboard: Keyboard

    var websiteIcon: WebsiteIcon {
        let iconFile = Self.iconFolder.appending(path: WebsiteIconStore.fileName(for: host))
        guard let iconData = try? Data(contentsOf: iconFile), let websiteIcon = WebsiteIcon.make(fromImageData: iconData) else {
            preconditionFailure("No icon for \(host) in docs/website-icons: run `swift run keyboard-switcher-dev website-icons docs/website-icons` with every README website")
        }
        return websiteIcon
    }
}
