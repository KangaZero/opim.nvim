import AppKit
import Foundation
import GRDB

import neomouseUtils

/// Type-tag for `Register.content` so we know which NSSecureCoding class to
/// decode the archived blob back into. Stored as a TEXT column.
public enum RegisterContentType: String, Codable, DatabaseValueConvertible {
    case color, image, pasteboardItem, sound, textStorage
}

/// User-space wrapper. The on-disk form is `(contentType, content: Data)`;
/// callers pass / receive this enum and let the model handle archiving.
///
/// `NSFilePromiseProvider` is intentionally not included — it carries a live
/// delegate callback that can't be serialised. Persist the resolved file URL
/// or `fileType` instead if you need to round-trip a promised file.
public enum RegisterContent {
    case color(NSColor)
    case image(NSImage)
    case pasteboardItem(NSPasteboardItem)
    case sound(NSSound)
    case textStorage(NSTextStorage)

    var type: RegisterContentType {
        switch self {
        case .color: return .color
        case .image: return .image
        case .pasteboardItem: return .pasteboardItem
        case .sound: return .sound
        case .textStorage: return .textStorage
        }
    }

    fileprivate func archive() throws -> Data {
        switch self {
        case .color(let v):
            return try NSKeyedArchiver.archivedData(withRootObject: v, requiringSecureCoding: true)
        case .image(let v):
            return try NSKeyedArchiver.archivedData(withRootObject: v, requiringSecureCoding: true)
        case .sound(let v):
            return try NSKeyedArchiver.archivedData(withRootObject: v, requiringSecureCoding: true)
        case .textStorage(let v):
            return try NSKeyedArchiver.archivedData(withRootObject: v, requiringSecureCoding: true)
        case .pasteboardItem(let item):
            // NSPasteboardItem isn't NSSecureCoding, so flatten it to a
            // [typeRawValue: data] dictionary — that IS secure-codable.
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
    }

    fileprivate static func unarchive(type: RegisterContentType, data: Data) throws -> RegisterContent? {
        switch type {
        case .color:
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data).map { .color($0) }
        case .image:
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSImage.self, from: data).map { .image($0) }
        case .sound:
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSSound.self, from: data).map { .sound($0) }
        case .textStorage:
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSTextStorage.self, from: data).map {
                .textStorage($0)
            }
        case .pasteboardItem:
            let classes: [AnyClass] = [NSDictionary.self, NSString.self, NSData.self]
            guard
                let dict = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: data)
                    as? [String: Data]
            else { return nil }
            let item = NSPasteboardItem()
            for (key, value) in dict {
                item.setData(value, forType: NSPasteboard.PasteboardType(key))
            }
            return .pasteboardItem(item)
        }
    }
}

public struct Register: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "register"
    public var id: Int64?
    public var register: String  //INFO: follow same register naming as Vim (a-z, 0-9, etc.)
    public var contentType: RegisterContentType
    public var content: Data  //INFO: NSKeyedArchiver blob, decoded via contentType
    public var createdAt: Date
    public var sessionId: Int64

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let register = Column(CodingKeys.register)
        static let contentType = Column(CodingKeys.contentType)
        static let content = Column(CodingKeys.content)
        static let createdAt = Column(CodingKeys.createdAt)
        static let sessionId = Column(CodingKeys.sessionId)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    /// Decode `content` back into the typed enum. `nil` if the blob is
    /// corrupted or the class can't be instantiated (e.g. unknown subclass).
    public var decoded: RegisterContent? {
        do {
            return try RegisterContent.unarchive(type: contentType, data: content)
        } catch {
            debug("Register.decoded error: ", error)
            return nil
        }
    }

    public static func get(register: String, sessionId: Int64) -> Register? {
        do {
            return try dbQueue.read { db in
                try Register
                    .filter(Columns.sessionId == sessionId)
                    .filter(Columns.register == register)
                    .fetchOne(db)
            }
        } catch {
            debug("Register.get error: ", error)
            return nil
        }
    }

    public static func getAll(sessionId: Int64) -> [Register]? {
        do {
            return try dbQueue.read { db in
                try Register
                    .filter(Columns.sessionId == sessionId)
                    .fetchAll(db)
            }
        } catch {
            debug("Register.getAll error: ", error)
            return nil
        }
    }

    /// Upsert a register by (sessionId, register). Last write wins, matching
    /// Vim's `"ay` overwrite semantics — one row per (session, register name).
    public static func set(register: String, content: RegisterContent, sessionId: Int64) {
        do {
            let data = try content.archive()
            try dbQueue.write { db in
                if var existing =
                    try Register
                    .filter(Columns.sessionId == sessionId)
                    .filter(Columns.register == register)
                    .fetchOne(db)
                {
                    existing.contentType = content.type
                    existing.content = data
                    try existing.update(db)
                } else {
                    var newRegister = Register(
                        register: register,
                        contentType: content.type,
                        content: data,
                        createdAt: Date(),
                        sessionId: sessionId
                    )
                    try newRegister.insert(db)
                }
            }
        } catch {
            debug("Register.set error: ", error)
        }
    }

    public static func delete(register: String, sessionId: Int64) {
        do {
            try dbQueue.write { db in
                guard
                    let existing =
                        try Register
                        .filter(Columns.sessionId == sessionId)
                        .filter(Columns.register == register)
                        .fetchOne(db)
                else {
                    return debug("Cannot find existing register to delete")
                }
                try existing.delete(db)
            }
        } catch {
            debug("Register.delete error: ", error)
        }
    }
}
