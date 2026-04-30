import GRDB

private struct Session: Equatable {
    static let databaseTableName = "session"
    /// Int64 is the recommended type for auto-incremented database ids.
    /// Use nil for those that are not inserted yet in the database.
    var id: Int64?
    var name: String
    // static let marks = hasMany(MarkRecord.self)
    // static let operations = hasMany(OperationRecord.self)
}

extension Session {
    private static let names = [
        "jolly", "Anita", "Barbara", "Bernard", "Craig", "Chiara", "David",
        "Dean", "Éric", "Elena", "Fatima", "Frederik", "Gilbert", "Georgette",
        "Henriette", "Hassan", "Ignacio", "Irene", "Julie", "Jack", "Karl",
        "Kristel", "Louis", "Liz", "Masashi", "Mary", "Noam", "Nicole",
        "Ophelie", "Oleg", "Pascal", "Patricia", "Quentin", "Quinn", "Raoul",
        "Rachel", "Stephan", "Susie", "Tristan", "Tatiana", "Ursule", "Urbain",
        "Victor", "Violette", "Wilfried", "Wilhelmina", "Yvon", "Yann",
        "Zazie", "Zoé",
    ]

    static func new() -> Session {
        Session(id: nil, name: "")
    }

    static func makeRandom() -> Session {
        Session(id: nil, name: randomName())
    }

    /// Returns a random name
    static func randomName() -> String {
        names.randomElement()!
    }
}

// MARK: - Database

/// Make Session a Codable Record.
///
/// See <https://github.com/groue/GRDB.swift/blob/master/README.md#records>
extension Session: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    enum Columns {
        static let name = Column(CodingKeys.name)
    }

    /// Updates a session id after it has been inserted in the database.
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
