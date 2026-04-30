import GRDB

private struct MarkRecord: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "mark"
    var id: Int64?
    var sessionId: Int64
    var mark: String
    var cgPointX: Double
    var cgPointY: Double
    var visualState: String?
    // mutating func didInsert(_ inserted: InsertionSuccess) { id = inserted.rowID }
}
