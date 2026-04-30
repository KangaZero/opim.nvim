import Foundation
import GRDB

let dbPath = FileManager.default.currentDirectoryPath + "/database.sqlite"
let dbQueue = try DatabaseQueue(path: dbPath)

func intialize(forceReSeed: Bool) {
    do {
        try dbQueue.write { db in
            let isTablesExist = try db.tableExists("player") && db.tableExists("item")
            if isTablesExist && !forceReSeed {
                return
                    print("Tables already exist, skipping initialization.")
            }
            try db.execute(sql: "DROP TABLE IF EXISTS item")
            print("Dropped table item if it existed.")
            try db.execute(sql: "DROP TABLE IF EXISTS player")
            print("Dropped table player if it existed.")

            try db.create(table: "player") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("score", .integer).notNull()
            }

            try db.create(table: "item") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.belongsTo("player", onDelete: .cascade).notNull()
            }
        }
    } catch {
        print("Initialize DB error: ", error)

    }
}

struct Player: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "player"
    var id: Int64?
    var name: String
    var score: Int

    static let items = hasMany(Item.self)

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension Player {
    public static func insert(player: inout Player) {
        do {
            try dbQueue.write { db in try player.insert(db) }
        } catch {
            print("Player.insert error:", error)
        }
    }
    public static func update(player: Player) {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: "UPDATE player SET name = :name, score = :score WHERE id = :id",
                    arguments: ["name": player.name, "score": player.score, "id": player.id])
            }
        } catch {
            print("Player.update error:", error)
        }
    }
    public static func delete(id: Int64) {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: "DELETE FROM player WHERE id = :id",
                    arguments: ["id": id])
            }
        } catch {
            print("Player.delete error:", error)
        }
    }
    public static func fetchByName(name: String) -> Player? {
        do {
            return try dbQueue.read { db in
                try Player.fetchOne(
                    db, sql: "SELECT * FROM player WHERE name = :name", arguments: ["name": name])
            }
        } catch {
            print("Player.fetchByName error:", error)
            return nil
        }
    }
    public static func fetchAll() -> [Player] {
        do {
            return try dbQueue.read { db in try Player.fetchAll(db) }
        } catch {
            print("Player.fetchAll error:", error)
            return []
        }
    }
    public static func fetchById(id: Int64) -> Player? {
        do {
            return try dbQueue.read { db in try Player.fetchOne(db, key: id) }
        } catch {
            print("Player.fetchById error:", error)
            return nil
        }
    }

    enum ScoreOrder {
        case high, low

        var sql: String {
            switch self {
            case .high: return "DESC"
            case .low: return "ASC"
            }
        }
    }

    public static func fetchHighestOrLowestScore(order: ScoreOrder) -> Player? {
        do {
            return try dbQueue.read { db in
                try Player.fetchOne(
                    db, sql: "SELECT * FROM player ORDER BY score \(order.sql) LIMIT 1")
            }
        } catch {
            print("Player.fetchHighestOrLowestScore error:", error)
            return nil
        }
    }
    public static func fetchPlayerItems(id: Int64) -> [Item] {
        do {
            return try dbQueue.read { db in
                let player = try Player.fetchOne(db, key: id)
                return try player?.request(for: Player.items).fetchAll(db) ?? []
            }
        } catch {
            print("Player.fetchPlayerItems error:", error)
            return []
        }
    }
}

struct Item: Codable, FetchableRecord, MutablePersistableRecord {
    var id: Int64?
    var name: String
    var playerId: Int64

    static let player = belongsTo(Player.self)

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

do {
    try dbQueue.write { db in
        var arthur = Player(id: nil, name: "Arthur", score: 100)
        try arthur.insert(db)

        var barbara = Player(id: nil, name: "Barbara", score: 1000)
        try barbara.insert(db)

        var sword = Item(id: nil, name: "Sword", playerId: arthur.id!)
        try sword.insert(db)

        var shield = Item(id: nil, name: "Shield", playerId: arthur.id!)
        try shield.insert(db)

        var bow = Item(id: nil, name: "Bow", playerId: barbara.id!)
        try bow.insert(db)
    }
} catch {
    print("seed error:", error)
}

intialize(forceReSeed: true)
print(Player.fetchAll())
print(Player.fetchHighestOrLowestScore(order: .high) ?? "Player not found")
print(Player.fetchHighestOrLowestScore(order: .low) ?? "Player not found")

Player.update(player: Player(id: 1, name: "Arthur Updated", score: 150))
print("updated:", Player.fetchById(id: 1) ?? "Player not found")

print("getByName:", Player.fetchByName(name: "Barbara") ?? "Player not found")
print("items:", Player.fetchPlayerItems(id: 1))

Player.delete(id: 1)
print("deleted:", Player.fetchById(id: 1) ?? "Player not found")
