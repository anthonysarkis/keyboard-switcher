import Testing
import KeyboardSwitcherCore

struct PreferencesTests {
    @Test func newSettingsStartWithTheBubbleOffAndRememberingOn() {
        let preferences = Preferences()

        #expect(preferences.showBubble == false)
        #expect(preferences.remembersManualSwitches)
    }
}
