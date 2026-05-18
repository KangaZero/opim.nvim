import AppKit

/// Namespace for NSPasteboard helpers.
public enum Pasteboard {
    /// Return the first item on the general pasteboard, preserving every type
    /// representation the source app wrote. Pure read — no side effects.
    ///
    /// Most copies push a single item with multiple type-reps (e.g. webpage
    /// selection = `.string` + `.rtf` + `.html` on one item). If you need the
    /// full list, read `NSPasteboard.general.pasteboardItems` directly.
    public static func getFirst() -> NSPasteboardItem? {
        NSPasteboard.general.pasteboardItems?.first
    }

    public static func isEmpty() -> Bool {
        NSPasteboard.general.pasteboardItems?.isEmpty ?? true
    }

    /// One-line, human-readable summary of an item — `.string` first N chars
    /// when present, else a `<binary; types: ...>` tag listing the type-reps.
    /// Use at debug sites instead of dumping raw `Data` byte counts.
    public static func preview(_ item: NSPasteboardItem, max: Int = 50) -> String {
        if let s = item.string(forType: .string) {
            return s.count > max ? "\(s.prefix(max))…" : s
        }
        let types = item.types.map(\.rawValue).joined(separator: ", ")
        return "<binary; types: \(types)>"
    }

    /// Flatten every type-rep of `item` into a single archived blob — suitable
    /// for DB storage, file write, IPC. Round-trip via `toItem(_:)`. Throws if
    /// the dictionary can't be secure-encoded (shouldn't happen for plain
    /// `[String: Data]` but preserves NSKeyedArchiver errors).
    public static func toData(_ item: NSPasteboardItem) throws -> Data {
        var dict: [String: Data] = [:]
        for type in item.types {
            if let data = item.data(forType: type) {
                dict[type.rawValue] = data
            }
        }
        return try NSKeyedArchiver.archivedData(
            withRootObject: dict as NSDictionary,
            requiringSecureCoding: true
        )
    }

    /// Inverse of `toData(_:)`. Returns `nil` if the blob doesn't decode to a
    /// `[String: Data]` dict (corruption or wrong source).
    public static func toItem(_ data: Data) throws -> NSPasteboardItem? {
        let classes: [AnyClass] = [NSDictionary.self, NSString.self, NSData.self]
        guard
            let dict = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: data)
                as? [String: Data]
        else { return nil }
        let item = NSPasteboardItem()
        for (key, value) in dict {
            item.setData(value, forType: NSPasteboard.PasteboardType(key))
        }
        return item
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
