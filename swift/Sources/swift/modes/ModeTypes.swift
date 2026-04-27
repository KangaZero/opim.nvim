import AppKit

// MARK: - Supporting Types
struct FindState {
    var pendingGridDivisionIndex: Int? = nil
    var pendingInnerGridDivisionIndex: Int? = nil
}

struct VisualState {
    var startPos: CGPoint? = nil
    var endPost: CGPoint? = nil
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
    case visual(
        currentPendingOperation: String?,
        findState: FindState,
        visualOperationsExecuted: [FindOperation]?
    )
    // case visualFind
    case command(
        currentPendingOperation: String?,
        commandOperationsExecuted: [String]?
    )
}
