struct WebsitesStage {
    static let window = SceneRect(x: 40, y: 58, width: 800, height: 170)
    static let stripHeight = 46.0
    static let toolbarHeight = 50.0
    static let pageHeight = 74.0
    static let tabsLeft = 132.0
    static let tabWidth = 232.0
    static let tabTop = 66.0
    static let pointerIntoTab = 92.0
    static let switchStep = 2.9
    static let readDelay = 0.3

    let websites: [ReadmeExampleWebsite]
    let theme: AnimationTheme
    let browserTheme: BrowserTheme
    let symbols: SymbolPictures
    let sheet: KeyframeSheet
    let menuBar: MenuBarLayout

    var arrivals: [Double] {
        websites.indices.map { websiteIndex in Double(websiteIndex) * Self.switchStep }
    }

    var tabTitleTop: Double {
        Self.tabTop + (Self.stripHeight - 8) / 2 - 2
    }

    func arrival(after websiteIndex: Int) -> Double {
        let nextIndex = (websiteIndex + 1) % websites.count
        let wrapsAround = websiteIndex == websites.count - 1
        return arrivals[nextIndex] + (wrapsAround ? sheet.timeline.period : 0)
    }

    func activeSteps(for websiteIndex: Int) -> [AnimationEvent] {
        let activePoints = [
            AnimationEvent(time: arrivals[websiteIndex], value: 1),
            AnimationEvent(time: arrival(after: websiteIndex), value: 0),
        ]
        return AnimationEvents.steps(activePoints)
    }

    func tabLeft(_ websiteIndex: Int) -> Double {
        Self.tabsLeft + Double(websiteIndex) * Self.tabWidth
    }

    func pointerX(onTab websiteIndex: Int) -> Double {
        tabLeft(websiteIndex) + Self.pointerIntoTab
    }
}
