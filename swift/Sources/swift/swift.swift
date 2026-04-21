import AppKit
import SwiftUI

class NeoMouseState: ObservableObject {
    @Published var isNeomouseMode = false
    @Published var isFindMode = false
    @Published var mouseX: CGFloat = 0
    @Published var mouseY: CGFloat = 0
    @Published var gridInset: CGFloat = 10
    @Published var gridDivisions: Int = 5
    @Published var innerGridDivisions: Int = 3
    @Published var findModeGridDivisionCharacters: [String] = "abcdefghijklmnopqrstuvwxyz".map {
        String($0)
    }
    @Published var findModeInnerGridDivisionCharacters: [String] = "abcdefghijklmnopqrstuvwxyz".map
    { String($0) }
}

@main
struct NeoMouse: App {
    private static var keyMonitor: Any?
    private static var mouseMonitor: Any?
    @StateObject private var appState = NeoMouseState()

    init() {
        //TODO add checks to make sure no unintended behavior of out of bounds access happens
        // eg.. gridDivisions * gridDivisions <=findModeGridDivisionCharacters.count, and similar for
        // innerGridDivisions

        let appState = appState
        NeoMouse.keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                //TODO: create a map to their respective keys, else it just looks like magic numbers
                debug("Key code without modifierFlags: \(event.keyCode)")
                switch event.keyCode {
                case keyCodeToCharMap["f"]:
                    guard appState.isNeomouseMode else { break }
                    appState.isFindMode.toggle()
                    ToastManager.shared.show(
                        "Find Mode \(appState.isFindMode ? "On" : "Off")")
                default: break
                }
                guard event.modifierFlags.contains(.command) else { return }
                debug("Key code with modifierFlags: \(event.keyCode)")
                switch event.keyCode {
                case keyCodeToCharMap["e"]:
                    appState.isNeomouseMode.toggle()
                    ToastManager.shared.show(
                        "NeoMouse Mode \(appState.isNeomouseMode ? "On" : "Off")")
                case keyCodeToCharMap["g"]:
                    guard appState.isNeomouseMode else { break }
                    GridOverlay.shared.toggle(state: appState)
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
    private weak var appState: NeoMouseState?

    func toggle(state: NeoMouseState) {
        appState = state
        isVisible ? hide() : show()
        isVisible.toggle()
    }

    private func show() {
        guard let screen = NSScreen.main, let appState else { return }
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
            win.contentView = NSHostingView(rootView: GridOverlayView(state: appState))
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
    @ObservedObject var state: NeoMouseState
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.15)
                Canvas { ctx, _ in
                    let inset = state.gridInset
                    let startX = inset
                    let endX = geo.size.width - inset
                    let startY = inset
                    let endY = geo.size.height - inset
                    let cellWidth = (endX - startX) / CGFloat(state.gridDivisions)
                    let cellHeight = (endY - startY) / CGFloat(state.gridDivisions)
                    // var findCharGridDivisionTextIndex: Int = 1

                    let innerCellWidth = cellWidth / CGFloat(state.innerGridDivisions)
                    let innerCellHeight = cellHeight / CGFloat(state.innerGridDivisions)
                    let totalInner = state.gridDivisions * state.innerGridDivisions

                    var innerPath = Path()
                    for i in 1..<totalInner {
                        guard i % state.innerGridDivisions != 0 else { continue }
                        let x = startX + innerCellWidth * CGFloat(i)
                        innerPath.move(to: CGPoint(x: x, y: startY))
                        innerPath.addLine(to: CGPoint(x: x, y: endY))
                        let y = startY + innerCellHeight * CGFloat(i)
                        innerPath.move(to: CGPoint(x: startX, y: y))
                        innerPath.addLine(to: CGPoint(x: endX, y: y))
                    }
                    ctx.stroke(innerPath, with: .color(.white.opacity(0.3)), lineWidth: 0.5)

                    var outerPath = Path()
                    for i in 0...state.gridDivisions {
                        let x = startX + cellWidth * CGFloat(i)
                        outerPath.move(to: CGPoint(x: x, y: startY))
                        outerPath.addLine(to: CGPoint(x: x, y: endY))
                        let y = startY + cellHeight * CGFloat(i)
                        outerPath.move(to: CGPoint(x: startX, y: y))
                        outerPath.addLine(to: CGPoint(x: endX, y: y))
                    }
                    ctx.stroke(outerPath, with: .color(.white.opacity(0.6)), lineWidth: 1)

                    // INFO: the -1 is to make sure it does not go beyond the gridInset
                    for col in 0...state.gridDivisions - 1 {
                        for row in 0...state.gridDivisions - 1 {
                            let x = startX + cellWidth * CGFloat(col)
                            let y = startY + cellHeight * CGFloat(row)
                            let middleX = x + (cellWidth / 2)
                            let middleY = y + (cellHeight / 2)
                            let label = Text("\(Int(x)),\(Int(y))")
                                .font(.system(size: 8))
                                .foregroundColor(.white)

                            let index = row * state.gridDivisions + col
                            let findCharGridDivisionText = Text(
                                "\(state.findModeGridDivisionCharacters[index])"
                            )
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            ctx.draw(label, at: CGPoint(x: x + 2, y: y + 2), anchor: .topLeading)
                            ctx.draw(
                                findCharGridDivisionText, at: CGPoint(x: middleX, y: middleY),
                                anchor: .topLeading)
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
