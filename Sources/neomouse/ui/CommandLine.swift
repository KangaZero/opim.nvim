import AppKit
import SwiftUI

import neomouseUtils

@MainActor
final class CommandLine {
    static let shared = CommandLine()
    private var window: NSWindow?
    private weak var appState: NeoMouseState?

    func toggle() {
        if let window, window.isVisible {
            hide()
        } else {
            show()
        }
    }

    func passAppState(state: NeoMouseState) {
        appState = state
    }

    func hide() {
        window?.orderOut(nil)
    }

    private func show() {

        guard
            let currentScreen =
                (NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) }),
            let appState,
            case .command = appState.mode
        else {
            return debug(
                "Could not retrieve current screen in CommandLine.show and/or appState is \(appState == nil ? "nil" : "not nil")"
            )
        }
        let panel = NSPanel(
            contentRect: CGRect(x: 0, y: 0, width: 300, height: 60),
            styleMask: [.fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.contentView = NSHostingView(rootView: CommandLineView(state: appState))

        // Bottom-left of the display under the cursor. visibleFrame already
        // excludes the menu bar + Dock.
        let x = currentScreen.visibleFrame.minX + 20
        let y = currentScreen.visibleFrame.minY + 20
        panel.setFrameOrigin(CGPoint(x: x, y: y))

        panel.orderFront(nil)
        window = panel
    }
    struct CommandLineView: View {
        @ObservedObject var state: NeoMouseState

        // Project the .command associated-value String as a SwiftUI Binding
        // so .searchable's two-way binding writes flow straight back into
        // state.mode. Pattern-bound `let` can't be used with `$`; this is
        // the canonical workaround for binding to an enum's payload.
        private var commandText: Binding<String> {
            Binding(
                get: {
                    if case .command(let s) = state.mode { return s }
                    return ""
                },
                set: { state.mode = .command(command: $0) }
            )
        }

        var filteredSuggestions: [String] {
            let text = commandText.wrappedValue
            if text.isEmpty { return state.commands }
            return state.commands.filter { $0.localizedCaseInsensitiveContains(text) }
        }

        var body: some View {
            NavigationStack {
                GroupBox(label: Label("Command Line", systemImage: "building.columns")) {
                    Text(commandText.wrappedValue)
                }
                .searchable(text: commandText, prompt: "Type a command...") {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Text(suggestion).searchCompletion(suggestion)
                    }
                }
            }
        }
    }
}
