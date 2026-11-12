import Foundation
import Observation

@Observable
public final class WebsiteIconStore {
    static let refreshAge: TimeInterval = 30 * 24 * 60 * 60
    static let retryPause: TimeInterval = 5 * 60

    private var icons: [String: WebsiteIcon] = [:]
    @ObservationIgnored private(set) var loads: [String: Task<Void, Never>] = [:]
    @ObservationIgnored private var loadNumbers: [String: Int] = [:]
    @ObservationIgnored private var lastLoadNumber = 0
    @ObservationIgnored private var followedWebsites: Set<String> = []
    @ObservationIgnored private var hasFollowedOnce = false
    @ObservationIgnored private var failedAt: [String: Date] = [:]

    private let fetcher: any WebsiteIconFetching
    let cache: WebsiteIconCache
    private let now: () -> Date

    public init(fetcher: any WebsiteIconFetching, folder: URL, now: @escaping () -> Date = Date.init) {
        self.fetcher = fetcher
        self.cache = WebsiteIconCache(folder: folder)
        self.now = now
    }

    public static func fileName(for website: String) -> String {
        WebsiteIconCache.fileName(for: website)
    }

    public func icon(for website: String) -> WebsiteIcon? {
        icons[website]
    }

    public func follow(websites: [String]) {
        let wantedWebsites = Set(websites)
        let removedWebsites = followedWebsites.subtracting(wantedWebsites)
        let addedWebsites = wantedWebsites.subtracting(followedWebsites)
        followedWebsites = wantedWebsites

        for website in removedWebsites {
            forget(website)
        }
        if !hasFollowedOnce {
            hasFollowedOnce = true
            cache.keepOnly(wantedWebsites)
        }
        for website in addedWebsites.sorted() {
            startLoad(of: website, readsSavedIconFirst: true)
        }
    }

    // A row on screen asks again for a site that had no icon, at most once per pause.
    func iconWanted(for website: String) {
        guard followedWebsites.contains(website), icons[website] == nil, loads[website] == nil else { return }
        if let lastFailure = failedAt[website], now().timeIntervalSince(lastFailure) < Self.retryPause { return }
        startLoad(of: website, readsSavedIconFirst: false)
    }

    public func waitForLoads() async {
        while let pendingLoad = loads.values.first {
            await pendingLoad.value
        }
        await cache.waitForPendingWork()
    }

    private func forget(_ website: String) {
        icons[website] = nil
        loads[website]?.cancel()
        loads[website] = nil
        loadNumbers[website] = nil
        failedAt[website] = nil
        cache.remove(website)
    }

    private func startLoad(of website: String, readsSavedIconFirst: Bool) {
        lastLoadNumber += 1
        let loadNumber = lastLoadNumber
        loadNumbers[website] = loadNumber
        loads[website] = Task { [weak self] in
            await self?.load(website, loadNumber: loadNumber, readsSavedIconFirst: readsSavedIconFirst)
            self?.finishLoad(of: website, loadNumber: loadNumber)
        }
    }

    private func finishLoad(of website: String, loadNumber: Int) {
        guard loadNumbers[website] == loadNumber else { return }
        loads[website] = nil
    }

    private func isCurrent(_ website: String, loadNumber: Int) -> Bool {
        loadNumbers[website] == loadNumber && !Task.isCancelled
    }

    private func load(_ website: String, loadNumber: Int, readsSavedIconFirst: Bool) async {
        if readsSavedIconFirst {
            let savedIcon = await cache.savedIcon(for: website)
            guard isCurrent(website, loadNumber: loadNumber) else { return }
            if let savedIcon {
                icons[website] = WebsiteIcon(prepared: savedIcon.icon)
                let age = now().timeIntervalSince(savedIcon.savedAt)
                guard age >= Self.refreshAge else { return }
            }
        }

        let imageData = await fetcher.iconData(for: website)
        guard isCurrent(website, loadNumber: loadNumber) else { return }
        let preparedIcon: PreparedWebsiteIcon?
        if let imageData {
            preparedIcon = await cache.prepared(from: imageData)
        } else {
            preparedIcon = nil
        }
        guard isCurrent(website, loadNumber: loadNumber) else { return }

        guard let preparedIcon, let icon = WebsiteIcon(prepared: preparedIcon) else {
            failedAt[website] = now()
            Log.websiteIcons.notice("No icon from \(website, privacy: .private) yet")
            return
        }
        failedAt[website] = nil
        icons[website] = icon
        let wasSaved = await cache.save(preparedIcon, for: website)
        if !wasSaved {
            Log.websiteIcons.error("Could not save the icon for \(website, privacy: .private)")
        }
    }
}
