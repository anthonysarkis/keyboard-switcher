import AppKit
import Foundation
import Testing
import KeyboardSwitcherFakes
@testable import KeyboardSwitcherKit

struct WebsiteIconStoreTests {
    private final class TestClock {
        var now = Date()
    }

    private let squareIcon = SampleWebsiteIcons.png(pixels: 180, shape: .square)
    private let otherSquareIcon = SampleWebsiteIcons.png(pixels: 120, shape: .square, red: 0.1, green: 0.1, blue: 0.1)

    private func makeFolder() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "keyboard-switcher-icons-\(UUID().uuidString)", directoryHint: .isDirectory)
    }

    private func iconFile(for website: String, in folder: URL) -> URL {
        folder.appending(path: WebsiteIconStore.fileName(for: website))
    }

    @Test func aNewSiteGetsItsIconOnceAndKeepsItOnTheMac() async throws {
        let folder = makeFolder()
        let fetcher = FakeWebsiteIcons(answers: ["claude.ai": squareIcon])
        let firstStore = WebsiteIconStore(fetcher: fetcher, folder: folder)

        firstStore.follow(websites: ["claude.ai"])
        await firstStore.waitForLoads()
        let nextLaunchStore = WebsiteIconStore(fetcher: fetcher, folder: folder)
        nextLaunchStore.follow(websites: ["claude.ai"])
        await nextLaunchStore.waitForLoads()

        #expect(firstStore.icon(for: "claude.ai") != nil)
        #expect(nextLaunchStore.icon(for: "claude.ai")?.fillsShape == true)
        #expect(fetcher.requests == ["claude.ai"])
        #expect(FileManager.default.fileExists(atPath: iconFile(for: "claude.ai", in: folder).path))
    }

    @Test func aSiteWithoutAnIconKeepsTheGlobeAndIsAskedAgainAfterAPause() async {
        let clock = TestClock()
        let fetcher = FakeWebsiteIcons()
        let store = WebsiteIconStore(fetcher: fetcher, folder: makeFolder(), now: { clock.now })

        store.follow(websites: ["localhost"])
        await store.waitForLoads()
        store.iconWanted(for: "localhost")
        await store.waitForLoads()
        let requestsDuringThePause = fetcher.requests.count
        clock.now += WebsiteIconStore.retryPause + 1
        fetcher.answers["localhost"] = squareIcon
        store.iconWanted(for: "localhost")
        await store.waitForLoads()

        #expect(requestsDuringThePause == 1)
        #expect(fetcher.requests == ["localhost", "localhost"])
        #expect(store.icon(for: "localhost") != nil)
    }

    @Test func aMonthOldIconStaysOnScreenWhileTheSiteIsAskedAgain() async throws {
        let folder = makeFolder()
        let clock = TestClock()
        let oldFetcher = FakeWebsiteIcons(answers: ["github.com": otherSquareIcon])
        let oldStore = WebsiteIconStore(fetcher: oldFetcher, folder: folder)
        oldStore.follow(websites: ["github.com"])
        await oldStore.waitForLoads()
        let savedFile = iconFile(for: "github.com", in: folder)
        let monthAgo = clock.now - WebsiteIconStore.refreshAge - 60
        try FileManager.default.setAttributes([.modificationDate: monthAgo], ofItemAtPath: savedFile.path)

        let fetcher = FakeWebsiteIcons(answers: ["github.com": squareIcon])
        fetcher.holdsAnswers = true
        let store = WebsiteIconStore(fetcher: fetcher, folder: folder, now: { clock.now })
        store.follow(websites: ["github.com"])
        await fetcher.waitForRequest()
        let iconWhileAsking = store.icon(for: "github.com")
        fetcher.releaseAnswers()
        await store.waitForLoads()

        let savedAt = try savedFile.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        #expect(iconWhileAsking != nil)
        #expect(fetcher.requests == ["github.com"])
        #expect((savedAt ?? monthAgo) > monthAgo)
    }

    @Test func aRemovedSiteLosesItsIcon() async {
        let folder = makeFolder()
        let store = WebsiteIconStore(fetcher: FakeWebsiteIcons(answers: ["claude.ai": squareIcon]), folder: folder)
        store.follow(websites: ["claude.ai"])
        await store.waitForLoads()

        store.follow(websites: [])
        await store.waitForLoads()

        #expect(store.icon(for: "claude.ai") == nil)
        #expect(!FileManager.default.fileExists(atPath: iconFile(for: "claude.ai", in: folder).path))
    }

    @Test func iconsOfSitesNoLongerInTheListAreClearedAtLaunch() async throws {
        let folder = makeFolder()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try squareIcon.write(to: iconFile(for: "old.example", in: folder))
        let store = WebsiteIconStore(fetcher: FakeWebsiteIcons(answers: ["claude.ai": squareIcon]), folder: folder)

        store.follow(websites: ["claude.ai"])
        await store.waitForLoads()

        #expect(!FileManager.default.fileExists(atPath: iconFile(for: "old.example", in: folder).path))
        #expect(FileManager.default.fileExists(atPath: iconFile(for: "claude.ai", in: folder).path))
    }

    @Test func anAnswerForASiteRemovedMeanwhileIsDropped() async {
        let folder = makeFolder()
        let fetcher = FakeWebsiteIcons(answers: ["claude.ai": squareIcon])
        fetcher.holdsAnswers = true
        let store = WebsiteIconStore(fetcher: fetcher, folder: folder)
        store.follow(websites: ["claude.ai"])
        await fetcher.waitForRequest()
        let lateLoad = store.loads["claude.ai"]

        store.follow(websites: [])
        fetcher.releaseAnswers()
        await lateLoad?.value
        await store.waitForLoads()

        #expect(lateLoad != nil)
        #expect(store.icon(for: "claude.ai") == nil)
        #expect(!FileManager.default.fileExists(atPath: iconFile(for: "claude.ai", in: folder).path))
    }

    @Test func squareIconsFillTheShapeAndLogosSitOnAPlate() throws {
        let square = try #require(WebsiteIconImages.prepared(from: squareIcon))
        let logoData = SampleWebsiteIcons.png(pixels: 194, shape: .circleOnClear)
        let logo = try #require(WebsiteIconImages.prepared(from: logoData))

        #expect(square.fillsShape)
        #expect(!logo.fillsShape)
    }

    @Test func logosAreDrawnOnAnOpaqueWhiteSquare() throws {
        let logoData = SampleWebsiteIcons.png(pixels: 194, shape: .circleOnClear)
        let logo = try #require(WebsiteIconImages.prepared(from: logoData))
        let drawnLogo = try #require(NSBitmapImageRep(data: logo.displayPNGData))
        let corner = try #require(drawnLogo.colorAt(x: 0, y: 0)?.usingColorSpace(.sRGB))
        let middle = try #require(drawnLogo.colorAt(x: drawnLogo.pixelsWide / 2, y: drawnLogo.pixelsHigh / 2)?.usingColorSpace(.sRGB))

        #expect(drawnLogo.pixelsWide == drawnLogo.pixelsHigh)
        #expect(corner.alphaComponent > 0.99 && corner.redComponent > 0.99 && corner.blueComponent > 0.99)
        #expect(middle.blueComponent < 0.5)
    }

    @Test func anIconKeptOnTheMacComesBackTheSame() throws {
        let logoData = SampleWebsiteIcons.png(pixels: 194, shape: .circleOnClear)
        let firstTime = try #require(WebsiteIconImages.prepared(from: logoData))
        let fromTheMac = try #require(WebsiteIconImages.prepared(from: firstTime.pngData))
        let firstLook = try #require(NSBitmapImageRep(data: firstTime.displayPNGData))
        let laterLook = try #require(NSBitmapImageRep(data: fromTheMac.displayPNGData))

        #expect(fromTheMac.fillsShape == firstTime.fillsShape)
        #expect(fromTheMac.pixelSize == firstTime.pixelSize)
        #expect(laterLook.pixelsWide == firstLook.pixelsWide)
    }

    @Test func bigIconsAreShrunkAndTinyOrBrokenOnesRefused() throws {
        let big = try #require(WebsiteIconImages.prepared(from: squareIcon))
        let mediumData = SampleWebsiteIcons.png(pixels: 40, shape: .square)
        let medium = try #require(WebsiteIconImages.prepared(from: mediumData))
        let tinyData = SampleWebsiteIcons.png(pixels: 8, shape: .square)
        let brokenData = Data("not an image".utf8)

        #expect(big.pixelSize == WebsiteIconImages.largestPixelSize)
        #expect(medium.pixelSize == 40)
        #expect(WebsiteIconImages.prepared(from: tinyData) == nil)
        #expect(WebsiteIconImages.prepared(from: brokenData) == nil)
    }

    @Test(arguments: [
        ("region-app-six.vercel.app", "region-app-six.vercel.app.png"),
        ("localhost", "localhost.png"),
        ("xn--bcher-kva.example", "xn--bcher-kva.example.png"),
        ("odd/name:here", "odd%2Fname%3Ahere.png"),
    ])
    func iconFileNamesAreSafe(website: String, expectedFileName: String) {
        #expect(WebsiteIconStore.fileName(for: website) == expectedFileName)
    }
}
