import AppKit

public enum PasteboardContent {
    case text(String)
    case sound(NSSound)
    case richText(Data)  // .rtf raw bytes; decode via NSAttributedString(rtf:)
    case html(Data)  // .html raw bytes; decode via String(data:encoding:) at the call site
    case image(NSImage)
    case files([URL])
}

/// Namespace for NSPasteboard helpers.
public enum Pasteboard {
    /// Read the current general pasteboard and return the richest matching
    /// content. Order: image → files → rtf → html → sound → plain text.
    /// Pure read — no side effects.
    public static func get() -> PasteboardContent? {
        let pasteboard = NSPasteboard.general
        guard let types = pasteboard.types else { return nil }

        if types.contains(.png) || types.contains(.tiff) {
            if let image = NSImage(pasteboard: pasteboard) {
                return .image(image)
            }
        }

        if types.contains(.fileURL) {
            if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
                return .files(urls)
            }
        }

        if types.contains(.rtf), let rtfData = pasteboard.data(forType: .rtf) {
            return .richText(rtfData)
        }

        if types.contains(.html), let htmlData = pasteboard.data(forType: .html) {
            return .html(htmlData)
        }

        if types.contains(.sound), let sound = NSSound(pasteboard: pasteboard) {
            return .sound(sound)
        }

        if types.contains(.string), let text = pasteboard.string(forType: .string) {
            return .text(text)
        }

        return nil
    }

    /// Poll `NSPasteboard.general.changeCount` and invoke `onChange` whenever
    /// it ticks. NSPasteboard has no notification API on macOS; polling is the
    /// standard Cocoa pattern (Maccy, Flycut, Clipy, Pasta all do this). 250ms
    /// is imperceptible latency at negligible battery cost.
    ///
    /// The returned `Timer` must be retained for the watcher to keep firing.
    /// Drop the reference or call `.invalidate()` to stop.
    @MainActor
    @discardableResult
    public static func watch(
        interval: TimeInterval = 0.25,
        onChange: @escaping @MainActor () -> Void
    ) -> Timer {
        var lastChangeCount = NSPasteboard.general.changeCount
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            MainActor.assumeIsolated {
                let current = NSPasteboard.general.changeCount
                guard current != lastChangeCount else { return }
                lastChangeCount = current
                onChange()
            }
        }
        // .common keeps it firing during menu tracking, scrolling, etc.
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    /// Debug helper. Dumps every item + type on the general pasteboard to
    /// stdout.
    public static func dump() {
        let pb = NSPasteboard.general
        print("=== NSPasteboard.general ===")
        print("changeCount: \(pb.changeCount)")
        print("name: \(pb.name.rawValue)")
        print("top-level types: \(pb.types?.map(\.rawValue) ?? [])")

        guard let items = pb.pasteboardItems else {
            print("(no pasteboardItems)")
            return
        }
        for (idx, item) in items.enumerated() {
            print("--- item \(idx) ---")
            for type in item.types {
                let raw = type.rawValue
                if let s = item.string(forType: type) {
                    print("  \(raw): \"\(s)\"")
                } else if let d = item.data(forType: type) {
                    let hex = d.prefix(32).map { String(format: "%02x", $0) }.joined(separator: " ")
                    print("  \(raw): <\(d.count) bytes> \(hex)\(d.count > 32 ? "…" : "")")
                } else if let plist = item.propertyList(forType: type) {
                    print("  \(raw): \(plist)")
                } else {
                    print("  \(raw): (empty)")
                }
            }
        }
    }
}
