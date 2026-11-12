import Foundation
import Testing
import KeyboardSwitcherCore

struct PreferencesTests {
    private func decodedPreferences(from json: String) throws -> Preferences {
        let jsonData = Data(json.utf8)
        return try JSONDecoder().decode(Preferences.self, from: jsonData)
    }

    @Test func newSettingsRememberEveryAppAndTheSitesYouSwitchOn() {
        let preferences = Preferences()

        #expect(preferences.showBubble == false)
        #expect(preferences.appsRemembering == .everyOne)
        #expect(preferences.websitesRemembering == .switchedByHand)
    }

    @Test func rememberingTurnedOnBeforeKeepsTheNewDefaults() throws {
        let preferences = try decodedPreferences(from: #"{"showBubble": true, "remembersManualSwitches": true}"#)

        #expect(preferences == Preferences(showBubble: true, appsRemembering: .everyOne, websitesRemembering: .switchedByHand))
    }

    @Test func rememberingTurnedOffBeforeRemembersOnlyWhatYouAdd() throws {
        let preferences = try decodedPreferences(from: #"{"remembersManualSwitches": false}"#)

        #expect(preferences.appsRemembering == .addedByYou)
        #expect(preferences.websitesRemembering == .addedByYou)
    }

    @Test func anUnknownChoiceFallsBackInsteadOfBreakingTheFile() throws {
        let preferences = try decodedPreferences(from: #"{"appsRemembering": "somethingNew", "websitesRemembering": "everyOne"}"#)

        #expect(preferences.appsRemembering == .everyOne)
        #expect(preferences.websitesRemembering == .everyOne)
    }

    @Test func savingWritesOnlyTheCurrentChoices() throws {
        let preferences = Preferences(showBubble: true, appsRemembering: .switchedByHand, websitesRemembering: .addedByYou)

        let savedData = try JSONEncoder().encode(preferences)
        let savedText = String(decoding: savedData, as: UTF8.self)

        #expect(try JSONDecoder().decode(Preferences.self, from: savedData) == preferences)
        #expect(!savedText.contains("remembersManualSwitches"))
    }
}
