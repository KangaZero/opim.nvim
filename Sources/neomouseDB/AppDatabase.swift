import Foundation
import GRDB

import neomouseUtils

let dbPath = FileManager.default.temporaryDirectory.appendingPathComponent("neomouse.sqlite").path
let dbQueue: DatabaseQueue = {
    do {
        return try DatabaseQueue(path: dbPath)
    } catch {
        fatalError("Failed to open database at \(dbPath): \(error)")
    }
}()

enum ModeName: String, Codable, DatabaseValueConvertible {
    case disabled, normal, find, command
}

enum OperationName: String, Codable, DatabaseValueConvertible {
    case motionXMinus, motionXPlus, motionYMinus, motionYPlus, motionXMin, motionXMax, motionYMin,
        motionYMax, motionXMid, motionYMid, clickLeft, clickRight, clickMiddle, scrollUp,
        scrollDown, scrollLeft, scrollRight
}

public func initializeDB(forceReSeed: Bool) {
    do {
        try dbQueue.write { db in
            let isTablesExist =
                try db.tableExists("session") && db.tableExists("mark")
                && db.tableExists("operation")
            if isTablesExist && !forceReSeed {
                debug("Tables already exist, skipping initialization.")
                return
            }
            try db.execute(sql: "DROP TABLE IF EXISTS operation")
            debug("Dropped table 'operation' if it existed.")
            try db.execute(sql: "DROP TABLE IF EXISTS mark")
            debug("Dropped table 'mark' if it existed.")
            try db.execute(sql: "DROP TABLE IF EXISTS session")
            debug("Dropped table 'session' if it existed.")

            try db.create(table: "session") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }
            try db.create(table: "mark") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("mark", .text).notNull()
                t.column("startCGXPoint", .double).notNull()
                t.column("startCGYPoint", .double).notNull()
                t.column("endCGXPoint", .double).notNull()
                t.column("endCGYPoint", .double).notNull()
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.belongsTo("session", onDelete: .cascade).notNull()
                // Vim semantics: per session, each mark name is unique. Lets
                // setMark rely on a single (sessionId, mark) lookup, and makes
                // duplicates impossible at the SQL level (not just app code).
                t.uniqueKey(["sessionId", "mark"])
            }
            try db.create(table: "operation") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("isVisual", .boolean).notNull()
                t.column("startCGXPoint", .double)
                t.column("startCGYPoint", .double)
                t.column("endCGXPoint", .double).notNull()
                t.column("endCGYPoint", .double).notNull()
                t.column("keysUsed", .text).notNull()
                t.column("mode", .text).notNull()
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.belongsTo("session", onDelete: .cascade).notNull()
            }
        }
    } catch {
        debug("Initialize DB error: ", error)

    }
}

/// Upsert a mark by (sessionId, mark). Matches Vim's `ma` overwrite semantics:
/// pressing `ma` twice from different positions keeps the second position, not
/// two rows. If an existing mark with the same (sessionId, mark) is found, its
/// CG points are updated; otherwise a new row is inserted.
public func setMark(
    mark: String,
    startCGXPoint: Double,
    startCGYPoint: Double,
    endCGXPoint: Double,
    endCGYPoint: Double,
    sessionId: Int64
) {
    do {
        try dbQueue.write { db in
            if var existing =
                try Mark
                .filter(Mark.Columns.sessionId == sessionId)
                .filter(Mark.Columns.mark == mark)
                .fetchOne(db)
            {
                existing.startCGXPoint = startCGXPoint
                existing.startCGYPoint = startCGYPoint
                existing.endCGXPoint = endCGXPoint
                existing.endCGYPoint = endCGYPoint
                try existing.update(db)
            } else {
                var newMark = Mark(
                    mark: mark,
                    startCGXPoint: startCGXPoint,
                    startCGYPoint: startCGYPoint,
                    endCGXPoint: endCGXPoint,
                    endCGYPoint: endCGYPoint,
                    createdAt: Date(),
                    sessionId: sessionId
                )
                try newMark.insert(db)
            }
        }
    } catch {
        debug("setMark error: ", error)
    }
}

public func deleteMark(
    mark: String,
    sessionId: Int64
) {
    do {
        try dbQueue.write { db in
            guard
                let existing =
                    try Mark
                    .filter(Mark.Columns.sessionId == sessionId)
                    .filter(Mark.Columns.mark == mark)
                    .fetchOne(db)
            else {
                return debug("Cannot find existing mark to delete")
            }
            try existing.delete(db)
        }
    } catch {
        debug("deleteMark error: ", error)
    }
}

public struct Mark: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    public static let databaseTableName = "mark"
    public var id: Int64?
    public var mark: String
    public var startCGXPoint: Double
    public var startCGYPoint: Double
    public var endCGXPoint: Double
    public var endCGYPoint: Double
    public var createdAt: Date
    public var sessionId: Int64

    public enum Columns {
        public static let id = Column(CodingKeys.id)
        public static let mark = Column(CodingKeys.mark)
        public static let startCGXPoint = Column(CodingKeys.startCGXPoint)
        public static let startCGYPoint = Column(CodingKeys.startCGYPoint)
        public static let endCGXPoint = Column(CodingKeys.endCGXPoint)
        public static let endCGYPoint = Column(CodingKeys.endCGYPoint)
        public static let createdAt = Column(CodingKeys.createdAt)
        public static let sessionId = Column(CodingKeys.sessionId)
    }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

struct ExecutedOperation: Codable, Identifiable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "excecuted_operation"
    var id: Int64?
    var name: OperationName
    var isVisual: Bool
    var startCGXPoint: Double?  //INFO: Only exists when isVisual is true, otherwise it's null
    var startCGYPoint: Double?  //INFO: Only exists when isVisual is true, otherwise it's null
    var endCGXPoint: Double
    var endCGYPoint: Double
    var keysUsed: String  // INFO: 'ggvG', '10j' etc
    var mode: ModeName  // INFO: 'ggvG', '10j' etc
    var createdAt: Date
    var sessionId: Int64

    //INFO: This is needed for compile-time type-safety
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let isVisual = Column(CodingKeys.isVisual)
        static let startCGXPoint = Column(CodingKeys.startCGXPoint)
        static let startCGYPoint = Column(CodingKeys.startCGYPoint)
        static let endCGXPoint = Column(CodingKeys.endCGXPoint)
        static let endCGYPoint = Column(CodingKeys.endCGYPoint)
        static let keysUsed = Column(CodingKeys.keysUsed)
        static let mode = Column(CodingKeys.mode)
        static let createdAt = Column(CodingKeys.createdAt)  // or executedAt
        static let sessionId = Column(CodingKeys.sessionId)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
