import KeyboardSwitcherCore

public enum SampleKeyboards {
    public static let canadian = Keyboard(id: "com.apple.keylayout.Canadian", name: "Canadian")
    public static let canadianCSA = Keyboard(id: "com.apple.keylayout.Canadian-CSA", name: "Canadian – CSA")
    public static let both = [canadian, canadianCSA]
    public static let bothIDs: Set<String> = [canadian.id, canadianCSA.id]
}
