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
            contentRect: CGRect(x: 0, y: 0, width: 420, height: 60),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.isOpaque = false
        // Without .clear, AppKit fills the panel backing under the SwiftUI
        // material → invisible (or grey) window.
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: CommandLineView(state: appState))
        // Auto-resize the panel to whatever SwiftUI wants. Without this
        // option the NSHostingView fills a fixed 60pt-tall panel and the
        // wildmenu list is clipped off-screen.
        hosting.sizingOptions = .preferredContentSize
        panel.contentView = hosting

        // Bottom-left of the display under the cursor. visibleFrame already
        // excludes the menu bar + Dock.
        let x = currentScreen.visibleFrame.minX + 20
        let y = currentScreen.visibleFrame.maxY + 20
        panel.setFrameOrigin(CGPoint(x: x, y: y))

        panel.orderFront(nil)
        window = panel
    }
    struct CommandLineView: View {
        @ObservedObject var state: NeoMouseState

        private var commandText: String {
            if case .command(let s, _) = state.mode { return s }
            return ""
        }

        private var suggestionIndex: Int? {
            if case .command(_, let idx) = state.mode { return idx }
            return nil
        }

        private var filtered: [String] {
            commandText.isEmpty
                ? state.commands
                : state.commands.filter { $0.localizedCaseInsensitiveContains(commandText) }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(":").foregroundColor(.secondary)
                    Text(commandText).font(.system(.body, design: .monospaced))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                if !filtered.isEmpty {
                    Divider()
                    // nvim-style wildmenu: list always visible while typing,
                    // Tab / Shift-Tab cycles the highlight (driven by
                    // suggestionIndex on the .command mode payload).
                    ForEach(Array(filtered.enumerated()), id: \.element) { idx, suggestion in
                        Text(suggestion)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(idx == suggestionIndex ? Color.accentColor.opacity(0.35) : .clear)
                    }
                }
            }
            .frame(minWidth: 400, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
