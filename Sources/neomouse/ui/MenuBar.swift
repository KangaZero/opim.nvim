import AppKit
import SwiftUI

struct MenuBar: Scene {
    var body: some Scene {
        MenuBarExtra("NeoMouse", systemImage: "cursorarrow.motionlines") {
            Button("Quit NeoMouse") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
        .commands {
            // No Settings scene declared → the default `App > Settings…`
            // command would open an empty SwiftUI window. Replace with nothing.
            CommandGroup(replacing: .appSettings) {}
        }
    }
}
