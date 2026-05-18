import Foundation
import GRDB

import neomouseUtils

//TODO decide what counts as a jump
public struct Jump: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "jump"
    public var id: Int64?
    public var CGXPoint: Double
    public var CGYPoint: Double
    public var createdAt: Date
    public var sessionId: Int64

    public enum Columns {
        static let id = Column(CodingKeys.id)
        static let CGXPoint = Column(CodingKeys.CGXPoint)
        static let CGYPoint = Column(CodingKeys.CGYPoint)
        static let createdAt = Column(CodingKeys.createdAt)
        static let sessionId = Column(CodingKeys.sessionId)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    public static func get(
        id: Int64,
        sessionId: Int64
    ) -> Jump? {
        do {
            return try dbQueue.read { db in
                try Jump
                    .filter(Jump.Columns.sessionId == sessionId)
                    .filter(Jump.Columns.id == id)
                    .fetchOne(db)
            }
        } catch {
            debug("Jump - get error: ", error)
            return nil
        }
    }

    public static func getAll(
        sessionId: Int64
    ) -> [Jump]? {
        do {
            return try dbQueue.read { db in
                try Jump
                    .filter(Jump.Columns.sessionId == sessionId)
                    .fetchAll(db)
            }
        } catch {
            debug("Jump - getAll error: ", error)
            return nil
        }
    }

    public static func set(
        sessionId: Int64,
        CGXPoint: Double,
        CGYPoint: Double
    ) {
        do {
            let jumpCount = getAll(sessionId: sessionId)?.count ?? 0
            try dbQueue.write { db in
                debug("Jump - set: Creating new jump")
                var newJump = Jump(
                    id: Int64(jumpCount + 1),
                    CGXPoint: CGXPoint,
                    CGYPoint: CGYPoint,
                    createdAt: Date(),
                    sessionId: sessionId
                )
                try newJump.insert(db)
            }
        } catch {
            debug("Jump - set error: ", error)
        }
    }

    public static func deleteAfter(
        excludingCurrentId: Int64,
        sessionId: Int64
    ) {
        do {
            try dbQueue.write { db in
                let existing =
                    try Jump
                    .filter(Jump.Columns.sessionId == sessionId)
                    .filter(Jump.Columns.id > excludingCurrentId)
                    .fetchAll(db)

                if existing.isEmpty {
                    debug("Cannot find existing jumps to deleteAfter")
                    return
                }

                for jump in existing {
                    try jump.delete(db)
                }
            }
        } catch {
            debug("Jump - deleteAfter error: ", error)
        }
    }
}
