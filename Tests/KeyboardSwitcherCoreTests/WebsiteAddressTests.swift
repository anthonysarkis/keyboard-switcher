import Testing
import KeyboardSwitcherCore

struct WebsiteAddressTests {
    @Test(arguments: [
        ("https://www.Claude.ai/new?model=x", "claude.ai"),
        ("https://web.whatsapp.com/", "web.whatsapp.com"),
        ("http://localhost:3000/settings", "localhost"),
        ("https://github.com./anthonysarkis", "github.com"),
    ])
    func tabAddressGivesTheWebsite(address: String, expectedWebsite: String) {
        #expect(WebsiteAddress.website(fromTabAddress: address) == expectedWebsite)
    }

    @Test(arguments: ["chrome://newtab/", "about:blank", "file:///Users/anthony/notes.txt", ""])
    func pagesThatAreNotWebsitesGiveNothing(address: String) {
        #expect(WebsiteAddress.website(fromTabAddress: address) == nil)
    }

    @Test(arguments: [
        ("claude.ai", "claude.ai"),
        ("https://claude.ai/chats", "claude.ai"),
        ("  www.GitHub.com  ", "github.com"),
        ("web.whatsapp.com/", "web.whatsapp.com"),
    ])
    func typedTextIsCleanedUp(text: String, expectedWebsite: String) {
        #expect(WebsiteAddress.website(fromTypedText: text) == expectedWebsite)
    }

    @Test(arguments: ["", "   ", "not a site", "claude"])
    func typedTextThatIsNotAWebsiteIsRefused(text: String) {
        #expect(WebsiteAddress.website(fromTypedText: text) == nil)
    }
}
