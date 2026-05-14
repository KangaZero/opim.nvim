import Foundation
import GRDB

import neomouseUtils

let dbPath = FileManager.default.temporaryDirectory.appendingPathComponent("neomouse.sqlite").path
let dbQueue: DatabaseQueue = {
    do {
        debug("dbPath: \(dbPath)")
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

public func initializeDB(forceReSeed: Bool = false) {
    do {
        try dbQueue.write { db in
            let isTablesExist =
                try db.tableExists("session") && db.tableExists("mark")
                && db.tableExists("operation")
            if isTablesExist && !forceReSeed {
                debug("Tables already exist, skipping initialization.")
                return
            }
            let tables = ["executed_operation", "mark", "session"]
            for table in tables {
                try db.execute(sql: "DROP TABLE IF EXISTS \(table)")
                debug("Dropped table \(table) if it existed")
            }
            // try db.execute(sql: "DROP TABLE IF EXISTS executed_operation")
            // debug("Dropped table 'operation' if it existed.")
            // try db.execute(sql: "DROP TABLE IF EXISTS mark")
            // debug("Dropped table 'mark' if it existed.")
            // try db.execute(sql: "DROP TABLE IF EXISTS session")
            // debug("Dropped table 'session' if it existed.")
            //
            try db.create(table: "session") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("updatedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }
            debug("Created 'session' table")
            var session = Session(id: 1, name: "Cookiezi", createdAt: .now, updatedAt: .now)
            try session.insert(db)
            debug("Created new session: \(session)")

            try db.create(table: "mark") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("mark", .text).notNull()
                t.column("isVisual", .boolean).notNull()
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
            debug("Created 'mark' table")

            try db.create(table: "executed_operation") { t in
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
            debug("Created 'executed_operation' table")
        }
    } catch {
        debug("Initialize DB error: ", error)

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
