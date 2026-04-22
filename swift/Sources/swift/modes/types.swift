// MARK: - Supporting Types
struct FindState {
    var pendingGridDivisionIndex: Int? = nil
    var pendingInnerGridDivisionIndex: Int? = nil
}

// MARK: - Mode
enum Mode {
    case disabled
    case normal(
        currentPendingOperation: String?,
        normalOperationsExecuted: [String]?
    )
    case find(
        currentPendingOperation: String?,
        findState: FindState,
        findOperationsExecuted: [FindOperation]?
    )
    case command(
        currentPendingOperation: String?,
        commandOperationsExecuted: [String]?
    )
}
