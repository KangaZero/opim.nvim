import AppKit
import SwiftUI

@main
struct NeoMouse: App {
    private static var keyMonitor: Any?

    init() {

        NeoMouse.keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                debug("Key code without modifierFlags: \(event.keyCode)")
                guard event.modifierFlags.contains(.command) else { return }
                debug("Key code with modifierFlags: \(event.keyCode)")
                switch event.keyCode {
                case 34: sendNotification()  // ⌘I
                case 5: GridOverlay.shared.toggle()  // ⌘G
                default: break
                }
            }
        }
        NeoMouse.keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            MainActor.assumeIsolated {
                debug("Mouse x: \(event.absoluteX)")
                debug("Mouse y: \(event.absoluteY)")
                switch event {
                default: break
                }
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("neomouse", systemImage: "bell") {
            Button("Notify") { sendNotification() }
            Divider()
            Button("Quit") { NSApp.terminate(nil) }
        }
    }
}

// MARK: - Notification

func sendNotification() {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", #"display notification "⌘I pressed" with title "neomouse""#]
    try? task.run()
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
                }
            }
        }
        .ignoresSafeArea()
    }
}
