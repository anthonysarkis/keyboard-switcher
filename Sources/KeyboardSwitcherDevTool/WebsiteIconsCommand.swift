import Foundation
import KeyboardSwitcherKit

enum WebsiteIconsCommand {
    static func run(writingTo folder: URL, websites: [String]) async -> Bool {
        let websiteIcons = WebsiteIconStore(fetcher: LinkPresentationIconFetcher(), folder: folder)
        let clock = ContinuousClock()
        let start = clock.now
        websiteIcons.follow(websites: websites)
        await websiteIcons.waitForLoads()
        let elapsed = clock.now - start

        var everySiteHasAnIcon = true
        for website in websites {
            let iconFile = folder.appending(path: WebsiteIconStore.fileName(for: website))
            if let websiteIcon = websiteIcons.icon(for: website), FileManager.default.fileExists(atPath: iconFile.path) {
                let look = websiteIcon.fillsShape ? "fills the shape" : "logo on a plate"
                print("\(website): saved \(iconFile.lastPathComponent), \(look)")
            } else {
                everySiteHasAnIcon = false
                print("\(website): no icon")
            }
        }
        print("Asked \(websites.count) sites in \(elapsed.formatted(.units(allowed: [.seconds], fractionalPart: .show(length: 1))))")
        return everySiteHasAnIcon
    }
}
