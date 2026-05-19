import AppKit

public enum System {
    /// Standard clipboard shortcut to synthesize via Cmd + key.
    public enum ClipboardAction {
        case copy, paste, cut

        fileprivate var keyChar: String {
            switch self {
            case .copy: return "c"
            case .paste: return "v"
            case .cut: return "x"
            }
        }
    }

    public static func getActiveApp() -> NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }

    public static func getActiveAppName() -> String? {
        getActiveApp()?.localizedName
    }

    /// Post a Cmd+<key> shortcut to the frontmost app. Used as the fallback
    /// when AX direct-action APIs are unavailable (which is basically always
    /// for copy/paste/cut — AppKit doesn't expose them as AX actions).
    public static func simulate(_ action: ClipboardAction) {
        let source = CGEventSource(stateID: .combinedSessionState)
        guard let keyCode = charToKeyCodeMap[action.keyChar] else {
            debug("System.simulate: no keyCode for '\(action.keyChar)'")
            return
        }
        guard
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        else {
            debug("System.simulate: failed to create CGEvent for '\(action.keyChar)'")
            return
        }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
