import CoreGraphics

// MARK: - Supporting Types
struct FindState {
    var pendingGridDivisionIndex: Int? = nil
    var pendingInnerGridDivisionIndex: Int? = nil
}

struct Operation {
    var operation: String
    var point: CGPoint
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
        findOperationsExecuted: [Operation]?
    )
    case command(
        currentPendingOperation: String?,
        commandOperationsExecuted: [String]?
    )
}
