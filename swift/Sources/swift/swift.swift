import AppKit
import SwiftUI

class NeoMouseState: ObservableObject {
    @Published var isNeomouseMode = false
    @Published var mouseX: CGFloat = 0
    @Published var mouseY: CGFloat = 0
}

@main
struct NeoMouse: App {
    private static var keyMonitor: Any?
    private static var mouseMonitor: Any?
    @StateObject private var appState = NeoMouseState()

    init() {
        let appState = appState
        NeoMouse.keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                debug("Key code without modifierFlags: \(event.keyCode)")
                guard event.modifierFlags.contains(.command) else { return }
                debug("Key code with modifierFlags: \(event.keyCode)")
                switch event.keyCode {
                case 34:
                    appState.isNeomouseMode.toggle()
                    ToastManager.shared.show(
                        "NeoMouse Mode \(appState.isNeomouseMode ? "On" : "Off")")
                case 5:
                    guard appState.isNeomouseMode else { break }
                    GridOverlay.shared.toggle()
                default: break
                }
            }
        }
        NeoMouse.mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            MainActor.assumeIsolated {
                appState.mouseX = NSEvent.mouseLocation.x
                appState.mouseY = NSEvent.mouseLocation.y
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("neomouse", systemImage: "bell") {
            CustomMenuBarView(state: appState)
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Toast

@MainActor
final class ToastManager {
    static let shared = ToastManager()
    private var window: NSPanel?

    func show(_ message: String) {
        window?.close()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 60),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentView = NSHostingView(rootView: ToastView(message: message))

        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 320
            let y = screen.visibleFrame.minY + 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFront(nil)
        window = panel

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.window?.close()
            self?.window = nil
        }
    }
}

struct ToastView: View {
    let message: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(10)
    }
}

// MARK: - Grid Overlay

@MainActor
final class GridOverlay {
    static let shared = GridOverlay()
    private var window: NSWindow?
    private var isVisible = false

    func toggle() {
        isVisible ? hide() : show()
        isVisible.toggle()
    }

    private func show() {
        guard let screen = NSScreen.main else { return }
        if window == nil {
            let win = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.level = .screenSaver
            win.ignoresMouseEvents = true
            win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            win.contentView = NSHostingView(rootView: GridOverlayView())
            window = win
        }
        window?.setFrame(screen.frame, display: true)
        window?.orderFrontRegardless()
    }

    private func hide() {
        window?.orderOut(nil)
    }
}

// MARK: - Grid View

struct GridOverlayView: View {
    private let divisions = 10
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.15)
                Canvas { ctx, _ in
                    let cellW = geo.size.width / CGFloat(divisions)
                    let cellH = geo.size.height / CGFloat(divisions)
                    var path = Path()
                    for i in 0...divisions {
                        let x = cellW * CGFloat(i)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                        let y = cellH * CGFloat(i)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    ctx.stroke(path, with: .color(.white.opacity(0.6)), lineWidth: 1)

                    for col in 0...divisions {
                        for row in 0...divisions {
                            let x: CGFloat = cellW * CGFloat(col)
                            let y: CGFloat = cellH * CGFloat(row)
                            let label = Text("\(Int(x)),\(Int(y))")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                            ctx.draw(label, at: CGPoint(x: x + 2, y: y + 2), anchor: .topLeading)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Menu Bar View

struct CustomMenuBarView: View {
    @ObservedObject var state: NeoMouseState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cursorarrow.motionlines")
                    .font(.title2)
                Text("NeoMouse")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(state.isNeomouseMode ? .green : .red)
                    .frame(width: 8, height: 8)
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Mouse position
            VStack(alignment: .leading, spacing: 4) {
                Label("x: \(Int(state.mouseX))", systemImage: "arrow.left.and.right")
                Label("y: \(Int(state.mouseY))", systemImage: "arrow.up.and.down")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Divider()

            // Toggle
            Toggle("NeoMouse Mode", isOn: $state.isNeomouseMode)
                .padding()
                .toggleStyle(.switch)

            Divider()

            Button("Send Notification") {
                ToastManager.shared.show("Hello from NeoMouse!")
            }
            .buttonStyle(.borderless)
            .padding(.vertical, 6)

            Divider()

            Button("Quit") { NSApp.terminate(nil) }
                .foregroundColor(.red)
                .buttonStyle(.borderless)
                .padding(.vertical, 6)
        }
        .frame(width: 220)
    }
}
