// let keyCodeToCharMap: [String: UInt16] = [
//     "a": 0,
//     "b": 11,
//     "c": 8,
//     "d": 2,
//     "e": 14,
//     "f": 3,
//     "g": 5,
//     "h": 4,
//     "i": 34,
//     "j": 38,
//     "k": 40,
//     "l": 37,
//     "m": 46,
//     "n": 45,
//     "o": 31,
//     "p": 35,
//     "q": 12,
//     "r": 15,
//     "s": 1,
//     "t": 17,
//     "u": 32,
//     "v": 9,
//     "w": 13,
//     "y": 16,
//     "x": 7,
//     "z": 6,
//     "0": 29,
//     "1": 18,
//     "2": 19,
//     "3": 20,
//     "4": 21,
//     "5": 23,
//     "6": 22,
//     "7": 26,
//     "8": 28,
//     "9": 25,
//     "Esc": 53,
//     "`": 50,
//     ".": 47,
//     ",": 43,
//     "/": 44,
//     ";": 41,
//     "'": 39,
//     "[": 33,
//     "]": 30,
//     "\\": 42,
//     "-": 27,
//     "+": 24,
// ]
import Carbon

public func keyCodeToChar(_ keyCode: UInt16) -> String? {
    let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    guard let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
    else { return nil }
    let layout = unsafeBitCast(layoutData, to: CFData.self)
    let layoutPtr = unsafeBitCast(
        CFDataGetBytePtr(layout), to: UnsafePointer<UCKeyboardLayout>.self)

    var deadKeyState: UInt32 = 0
    var chars = [UniChar](repeating: 0, count: 4)
    var charCount = 0

    UCKeyTranslate(
        layoutPtr,
        keyCode,
        UInt16(kUCKeyActionDown),
        0,  // no modifiers
        UInt32(LMGetKbdType()),
        OptionBits(kUCKeyTranslateNoDeadKeysBit),
        &deadKeyState,
        4,
        &charCount,
        &chars
    )

    guard charCount > 0 else { return nil }
    return String(utf16CodeUnits: chars, count: charCount)
}

// reverse — build the map dynamically
public func buildKeyCodeMap() -> [String: UInt16] {
    var map: [String: UInt16] = [:]
    //INFO: macOS hardware keyboards have keycodes that only go up to 127 (0–127), so 128 covers the full range. It's not a magic number — it's just UInt7 max + 1.
    for keyCode in 0..<128 {
        if let char = keyCodeToChar(UInt16(keyCode)), !char.isEmpty {
            map[char] = UInt16(keyCode)
        }
    }
    let remainingKeys: [String: UInt16] = [
        "0": 29,
        "1": 18,
        "2": 19,
        "3": 20,
        "4": 21,
        "5": 23,
        "6": 22,
        "7": 26,
        "8": 28,
        "9": 25,
        "-": 27,
        ".": 47,
        "/": 44,
        "=": 24,
        "Tab": 48,
        "Backspace": 51,
        "Return": 36,
        "Space": 49,
        "Esc": 53,
        "Enter": 76,
        "LeftArrow": 123,
        "RightArrow": 124,
        "DownArrow": 125,
        "UpArrow": 126,
        "Fn": 179,
        "F1": 122,
        "F2": 120,
        "F3": 99,
        "F4": 118,
        "F5": 96,
        "F6": 97,
        "F7": 98,
        "F8": 100,
        "F9": 101,
        "F10": 109,
        "F11": 103,
        "F12": 111,
        "F13": 105,
        "F14": 107,
        "F15": 113,
        "F16": 106,
        "F17": 64,
        "F18": 79,
        "F19": 80,
        "F20": 90,
    ]
    for remainingKey in remainingKeys {
        map[remainingKey.key] = remainingKey.value
    }
    return map
}

public let charToKeyCodeMap = buildKeyCodeMap()
