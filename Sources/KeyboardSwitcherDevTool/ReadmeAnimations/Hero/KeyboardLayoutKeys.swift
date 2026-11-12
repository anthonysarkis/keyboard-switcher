import Carbon
import Foundation

struct KeyboardLayoutKeys {
    private static let ansiKeyboardType: UInt32 = 40
    private static let spaceKeyCode = 49
    private static let usLayoutID = "com.apple.keylayout.US"
    private static let topLeftKeyCodeOnUSLayout = 50
    private static let topLeftKeyCodeOnOtherLayouts = 10
    private static let keyCodesNeverTyped: Set<Int> = [10, 50]
    private static let keyCodes: [UInt16] = [
        10, 50, 18, 19, 20, 21, 23, 22, 26, 28, 25, 29, 27, 24,
        12, 13, 14, 15, 17, 16, 32, 34, 31, 35, 33, 30, 42,
        0, 1, 2, 3, 5, 4, 38, 40, 37, 41, 39,
        6, 7, 8, 9, 11, 45, 46, 43, 47, 44,
        49,
    ]

    let layoutID: String
    private let plainOutputs: [Int: KeyOutput]
    private let shiftedOutputs: [Int: KeyOutput]

    static func read(layoutID: String) throws -> KeyboardLayoutKeys {
        guard let layoutData = layoutData(for: layoutID) else {
            throw ReadmeAnimationError.missingKeyboardLayout(layoutID)
        }
        let shiftModifier = UInt32(shiftKey)
        var plainOutputs: [Int: KeyOutput] = [:]
        var shiftedOutputs: [Int: KeyOutput] = [:]
        for keyCode in keyCodes {
            let keyNumber = Int(keyCode)
            plainOutputs[keyNumber] = output(of: layoutData, keyCode: keyCode, modifiers: 0)
            shiftedOutputs[keyNumber] = output(of: layoutData, keyCode: keyCode, modifiers: shiftModifier)
        }
        return KeyboardLayoutKeys(layoutID: layoutID, plainOutputs: plainOutputs, shiftedOutputs: shiftedOutputs)
    }

    var topLeftKeyCode: Int {
        layoutID == Self.usLayoutID ? Self.topLeftKeyCodeOnUSLayout : Self.topLeftKeyCodeOnOtherLayouts
    }

    func printedLegends(forKeyCode keyCode: Int) -> [String] {
        let plain = plainOutputs[keyCode]?.printed ?? ""
        let shifted = shiftedOutputs[keyCode]?.printed ?? ""
        let plainIsLetters = !plain.isEmpty && plain.allSatisfy(\.isLetter)
        let capitalOfPlain = plain.uppercased()
        if !plain.isEmpty, !shifted.isEmpty, plain != shifted, plainIsLetters, capitalOfPlain == shifted {
            return [shifted]
        }
        if shifted.isEmpty || plain == shifted {
            return [plain]
        }
        return [shifted, plain]
    }

    func key(typing character: Character) throws -> TypedKey {
        if character == " " {
            return TypedKey(keyCode: Self.spaceKeyCode, needsShift: false)
        }
        let text = String(character)
        let typingKeyCodes = plainOutputs.keys.filter { keyCode in !Self.keyCodesNeverTyped.contains(keyCode) }
        let searchOrder = typingKeyCodes.sorted()
        for (outputs, needsShift) in [(plainOutputs, false), (shiftedOutputs, true)] {
            for keyCode in searchOrder {
                guard let output = outputs[keyCode], output.typed == text, !output.isDeadKey else { continue }
                return TypedKey(keyCode: keyCode, needsShift: needsShift)
            }
        }
        throw ReadmeAnimationError.untypableCharacter(text, layoutID: layoutID)
    }

    private static func layoutData(for layoutID: String) -> Data? {
        let filter = [kTISPropertyInputSourceID as String: layoutID] as CFDictionary
        let sourceList = TISCreateInputSourceList(filter, true)?.takeRetainedValue()
        guard let sources = sourceList as? [TISInputSource], let source = sources.first else { return nil }
        guard let rawValue = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        let layoutBytes = Unmanaged<CFData>.fromOpaque(rawValue).takeUnretainedValue()
        return layoutBytes as Data
    }

    private static func output(of layoutData: Data, keyCode: UInt16, modifiers: UInt32) -> KeyOutput {
        let typed = translate(layoutData, keyCode: keyCode, modifiers: modifiers, ignoringDeadKeys: false)
        let printed = translate(layoutData, keyCode: keyCode, modifiers: modifiers, ignoringDeadKeys: true)
        return KeyOutput(typed: typed.text, printed: printed.text, isDeadKey: typed.isDeadKey)
    }

    private static func translate(_ layoutData: Data, keyCode: UInt16, modifiers: UInt32, ignoringDeadKeys: Bool) -> (text: String, isDeadKey: Bool) {
        var deadKeyState: UInt32 = 0
        var length = 0
        var characters = [UniChar](repeating: 0, count: 8)
        let options = ignoringDeadKeys ? OptionBits(kUCKeyTranslateNoDeadKeysMask) : OptionBits(0)
        let modifierByte = (modifiers >> 8) & 0xFF
        let keyDown = UInt16(kUCKeyActionDown)
        let status = layoutData.withUnsafeBytes { buffer -> OSStatus in
            guard let keyboardLayout = buffer.bindMemory(to: UCKeyboardLayout.self).baseAddress else { return OSStatus(paramErr) }
            return UCKeyTranslate(keyboardLayout, keyCode, keyDown, modifierByte, ansiKeyboardType, options, &deadKeyState, 8, &length, &characters)
        }
        guard status == noErr else { return ("", false) }
        let text = String(utf16CodeUnits: characters, count: length)
        let isDeadKey = !ignoringDeadKeys && length == 0 && deadKeyState != 0
        return (text, isDeadKey)
    }
}
