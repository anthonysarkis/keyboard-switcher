import Testing
import KeyboardSwitcherCore

struct KeyboardBadgeMakerTests {
    @Test(arguments: [
        ("Canadian – CSA", KeyboardBadge(text: "CSA", style: .outlined)),
        ("Canadian", KeyboardBadge(text: "CA", style: .filled)),
        ("U.S.", KeyboardBadge(text: "US", style: .filled)),
        ("ABC", KeyboardBadge(text: "ABC", style: .filled)),
        ("French - PC", KeyboardBadge(text: "PC", style: .outlined)),
        ("British", KeyboardBadge(text: "BR", style: .filled)),
    ])
    func badgeComesFromTheName(name: String, expectedBadge: KeyboardBadge) {
        #expect(KeyboardBadgeMaker.badge(for: name) == expectedBadge)
    }

    @Test func twoKeyboardsNeverShareABadge() {
        let keyboards = [
            Keyboard(id: "com.apple.keylayout.French-PC", name: "French - PC"),
            Keyboard(id: "com.apple.keylayout.British-PC", name: "British - PC"),
            Keyboard(id: "com.apple.keylayout.Canadian", name: "Canadian"),
        ]

        let badges = KeyboardBadgeMaker.badges(for: keyboards)

        #expect(badges["com.apple.keylayout.French-PC"] == KeyboardBadge(text: "FRE", style: .outlined))
        #expect(badges["com.apple.keylayout.British-PC"] == KeyboardBadge(text: "BRI", style: .outlined))
        #expect(badges["com.apple.keylayout.Canadian"] == KeyboardBadge(text: "CA", style: .filled))
    }
}
