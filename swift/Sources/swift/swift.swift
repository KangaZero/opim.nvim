import AppKit
import SwiftUI

//
// struct PendingOperation {
//     var operation: String
//     var pendingGridDivisionIndex: Int?
//     var pendingInnerGridDivisionIndex: Int?
// }

class NeoMouseState: ObservableObject {
    @Published var mode: Mode = .disabled
    // @Published var isNeomouseMode = false
    // @Published var isFindMode = false
    // @Published var isCommandLineMode = false
    @Published var mouseX: CGFloat = 0
    @Published var mouseY: CGFloat = 0
    @Published var gridInset: CGFloat = 10
    @Published var isVisual: Bool = false
    @Published var startingVisualState: VisualState? = nil
    @Published var endingVisualState: VisualState? = nil

    let commands: [String] = ["numbers, relativenumbers"]
    //WARNING: Until a good dynamic solution is found, do not allow these 2 to be mutable, could be a headache as divisionCharacters may
    //need to added in to take in account if gridDivisions increased
    let gridDivisions: Int = 5
    let innerGridDivisions: Int = 3

    let findModeGridDivisionCharacters: [String] = "abcdefghijklmnopqrstuvwxyz".map {
        String($0)
    }
    let findModeInnerGridDivisionCharacters: [String] = "abcdefghijklmnopqrstuvwxyz".map {
        String($0)
    }

    // @Published var pendingOperation = PendingOperation(
    //     operation: "",
    //     pendingGridDivisionIndex: nil,
    //     pendingInnerGridDivisionIndex: nil
    // )
    let rangeX: CGFloat = 20
    let rangeY: CGFloat = 20
    // let isIgnoresSafeArea = true
    let isAlwaysShowInnerGridCharacters = true
    let isClampCursorToScreen = true
}

@main
struct NeoMouse: App {
    private static var keyMonitor: Any?
    private static var mouseMonitor: Any?
    private static let sharedState = NeoMouseState()
    @StateObject private var appState = NeoMouse.sharedState

    init() {
        //TODO add checks to make sure no unintended behavior of out of bounds access happens
        // eg.. gridDivisions * gridDivisions <=findModeGridDivisionCharacters.count, and similar for
        // innerGridDivisions

        let appState = NeoMouse.sharedState
        NeoMouse.keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                // //Need this as to allow other program shortcuts to work
                switch appState.mode {
                case .disabled:
                    switch event.keyCode {
                    case keyCodeToCharMap["e"]:
                        guard event.modifierFlags.contains(.command) else { return }
                        debug(
                            "modifierFlags:true, modifier: \(event.modifierFlags), mode:\(appState.mode), key:e, keyCode:\(event.keyCode)"
                        )
                        appState.mode = .normal(
                            currentPendingOperation: nil,
                        )
                        ToastManager.shared.show(
                            "Neomouse Activated - Normal Mode")
                        return
                    default:
                        return
                    }
                case .normal(let currentPendingNormalOperation):
                    switch event.keyCode {
                    case keyCodeToCharMap["e"]:
                        guard event.modifierFlags.contains(.command) else { return }
                        debug(
                            "modifierFlags:true, modifier: \(event.modifierFlags), mode:\(appState.mode), key:e, keyCode:\(event.keyCode)"
                        )
                        appState.mode = .disabled
                        ToastManager.shared.show(
                            "Neomouse Deactivated")
                        return
                    //TODO: Add "$", "^ : where it will go to the most left/right of the current
                    //focused window", "g$" for most right, hjkl, counters,
                    case keyCodeToCharMap["f"]:
                        //INFO: 256 means no modifier is pressed, do not use .isEmpty method
                        guard event.modifierFlags.rawValue == 256 else {
                            return
                                debug(
                                    "modifierFlags:\(event.modifierFlags), isNeomouseMode:true, key:f, keyCode:\(event.keyCode) - not activating find mode because modifier is pressed"
                                )
                        }
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:f, keyCode:\(event.keyCode)"
                        )
                        appState.mode = .find(
                            currentPendingOperation: nil,
                            findState: FindState()
                        )
                        GridOverlay.shared.passAppState(state: appState)
                        GridOverlay.shared.showGrid()
                        ToastManager.shared.show(
                            "Find Mode")
                    // INFO: Here starts VIM-like motions on the cursor
                    case keyCodeToCharMap["h"]:
                        guard event.modifierFlags.rawValue == 256 else { return }
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:h, keyCode:\(event.keyCode)"
                        )
                        //TODO check that if the operation except the lastIndex are only nums
                        let operationCount: CGFloat = 1
                        appState.mode = .normal(
                            currentPendingOperation: "\(operationCount)h",
                        )
                        moveMouseRelatively(
                            x: -appState.rangeX * operationCount, y: 0,
                            enableClamp:
                                appState.isClampCursorToScreen)
                    //TODO check that if the operation except the lastIndex are only nums
                    case keyCodeToCharMap["j"]:
                        guard event.modifierFlags.rawValue == 256 else { return }
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:j, keyCode:\(event.keyCode)"
                        )
                        let operationCount: CGFloat = 1
                        moveMouseRelatively(
                            x: 0, y: appState.rangeY * operationCount,
                            enableClamp:
                                appState.isClampCursorToScreen)
                    case keyCodeToCharMap["k"]:
                        guard event.modifierFlags.rawValue == 256 else { return }
                        let operationCount: CGFloat = 1
                        moveMouseRelatively(
                            x: 0, y: -appState.rangeY * operationCount,
                            enableClamp:
                                appState.isClampCursorToScreen)

                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:k, keyCode:\(event.keyCode)"
                        )
                    // appState.pendingOperation.operation.append("k")
                    // appState.pendingOperation.operation = ""
                    case keyCodeToCharMap["l"]:
                        guard event.modifierFlags.rawValue == 256 else { return }
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:l, keyCode:\(event.keyCode)"
                        )
                        //TODO check that if the operation except the lastIndex are only nums
                        let operationCount: CGFloat = 1
                        appState.mode = .normal(
                            currentPendingOperation: "\(operationCount)h",
                        )
                        moveMouseRelatively(
                            x: appState.rangeX * operationCount, y: 0,
                            enableClamp:
                                appState.isClampCursorToScreen)

                    case keyCodeToCharMap["g"]:
                        debug(
                            "modifierFlags:\(event.modifierFlags.rawValue), isNeomouseMode:true, key:g, keyCode:\(event.keyCode)"
                        )
                        if event.modifierFlags.contains(.shift)
                            || event.modifierFlags.contains(.capsLock)
                        {
                            guard let currentCGPoint = getCurrentMouseLocation(),
                                let
                                    currentScreenSize = getCurrentScreenSize()
                            else {
                                debug(
                                    "Could not getCurrentMouseLocation and/or getCurrentScreenSize for operation 'G"
                                )
                                return
                            }
                            moveMouseByExactCoordinatesOnCurrentScreen(
                                x: currentCGPoint.x,
                                y: currentScreenSize.height - appState.gridInset)
                            break
                        }
                        guard event.modifierFlags.rawValue == 256 else { return }

                        appState.mode = .normal(
                            currentPendingOperation: (currentPendingNormalOperation ?? "") + "g",
                        )
                        // "g" instead of "gg" as the following "g" is only appended after current MainActor event
                        if currentPendingNormalOperation == "g" {
                            guard let currentCGPoint = getCurrentMouseLocation() else {
                                debug("Could not retrieve current mouse location for operation 'gg")
                                return
                            }
                            moveMouseByExactCoordinatesOnCurrentScreen(
                                x: currentCGPoint.x, y: 0 + appState.gridInset)
                            appState.mode = .normal(
                                currentPendingOperation: nil
                            )
                            break
                        }

                    case keyCodeToCharMap["0"]:
                        guard event.modifierFlags.rawValue == 256 else { return }
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:0, keyCode:\(event.keyCode)"
                        )
                        // appState.pendingOperation.operation.append("0")
                        //Not a count-based operation, so execute "go to start of current
                        //x-axis-line (Similar to Vim's go to start of line)
                        let currentPendingOperationCount = currentPendingNormalOperation?.count
                        guard
                            currentPendingOperationCount == nil || currentPendingOperationCount == 1
                        else {
                            debug(
                                "operation count != 1, count: \(currentPendingOperationCount ?? -1)"
                            )
                            //TODO: Add to counter operation
                            break
                        }
                        guard let currentCGPoint = getCurrentMouseLocation() else {
                            debug("Could not retrieve current mouse location for operation '0")
                            break
                        }
                        moveMouseByExactCoordinatesOnCurrentScreen(
                            x: 0 + appState.gridInset, y: currentCGPoint.y)
                    // appState.pendingOperation.operation = ""
                    case keyCodeToCharMap["4"]:
                        // appState.pendingOperation.operation.append("4")
                        guard event.modifierFlags.contains(.shift) else {
                            //TODO: Add to counter operation
                            return
                        }
                        //"$" operator
                        guard let currentCGPoint = getCurrentMouseLocation() else {
                            debug("Could not retrieve current mouse location for operation '4")
                            break
                        }
                        guard let currentScreenSize = getCurrentScreenSize() else {
                            debug("Could not retrieve current screen size for operation '4")
                            break
                        }
                        moveMouseByExactCoordinatesOnCurrentScreen(
                            x: currentScreenSize.width - appState.gridInset, y: currentCGPoint.y)
                    // appState.pendingOperation.operation = ""
                    default: break
                    }
                case .find:
                    switch event.keyCode {
                    case keyCodeToCharMap["e"]:
                        guard event.modifierFlags.contains(.command) else {
                            return NeoMouse.executeFindModeOperation(
                                event: event, appState: appState)
                        }
                        debug(
                            "modifierFlags:true, modifier: \(event.modifierFlags), mode:\(appState.mode), key:e, keyCode:\(event.keyCode)"
                        )
                        appState.mode = .disabled
                        GridOverlay.shared.hideGrid()
                        ToastManager.shared.show("NeoMouse Deactivated")
                        return

                    // case keyCodeToCharMap["f"]:
                    //     guard event.modifierFlags.isEmpty else { return }
                    //     debug(
                    //         "modifierFlags:false, modifier: \(event.modifierFlags), isNeomouseMode:\(appState.isNeomouseMode), key:f, keyCode:\(event.keyCode)"
                    //     )
                    //     if !appState.isFindMode {
                    //         appState.isFindMode.toggle()
                    //         GridOverlay.shared.passAppState(state: appState)
                    //         GridOverlay.shared.toggle()
                    //         ToastManager.shared.show(
                    //             "Find Mode \(appState.isFindMode ? "On" : "Off")")
                    //     } else {
                    //         NeoMouse.executeFindModeOperation(event: event, appState: appState)
                    //     }
                    //
                    case keyCodeToCharMap["Esc"]:
                        NeoMouse.exitFindMode(appState: appState)
                    default:
                        NeoMouse.executeFindModeOperation(event: event, appState: appState)
                        break
                    }
                default:
                    debug(
                        "Reached default case in keyMonitor with mode:\(appState.mode) and keyCode:\(event.keyCode), should not happen"
                    )
                    break
                }
            }
        }
        NeoMouse.mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            MainActor.assumeIsolated {
                appState.mouseX = NSEvent.mouseLocation.x
                appState.mouseY = NSEvent.mouseLocation.y
            }
        }
    }

    var body: some Scene {
        Settings { EmptyView() }
    }
    private static func exitFindMode(appState: NeoMouseState) {
        //TODO: NICE TO HAVE use previous session's
        appState.mode = .normal(currentPendingOperation: nil)
        GridOverlay.shared.hideGrid()
        ToastManager.shared.show(
            "Normal Mode")
    }
    private static func executeFindModeOperation(event: NSEvent, appState: NeoMouseState) {
        debug(
            "isModifiedFlagEmpty: \(event.modifierFlags.isEmpty) modifier: \(event.modifierFlags), mode:\(appState.mode), keyCode:\(event.keyCode)"
        )
        guard case .find = appState.mode, event.modifierFlags.rawValue == 256 else {
            return
                debug(
                    "Cannot executeFindModeOperation as mode is \(appState.mode) or \(event.modifierFlags.rawValue) != 256"
                )
        }
        //First get the convert of the keyCode to its equivalent character (as String)
        let keyCodeAsChar: String? = keyCodeToCharMap.first(where: {
            $0.value == event.keyCode
        })?.key
        // debug(
        //     "executeFindModeOperation: keyCode: \(event.keyCode), keyCodeAsChar: \(keyCodeAsChar)")
        guard let keyCodeAsChar = keyCodeAsChar else {
            debug("Not a recognized keyCode, cannot find character for keyCode:\(event.keyCode)")
            return
        }

        guard
            case .find(let currentPendingOperation, let findState) =
                appState.mode
        else {
            return
        }
        //TODO: check if this is the best place to put this
        // appState.mode = .find(
        //     currentPendingOperation: (currentPendingOperation ?? "") + keyCodeAsChar,
        //     findState: findState,
        // )
        // First keypress
        if findState.pendingGridDivisionIndex == nil {
            //If there is a first index match for the character in
            //findModeGridDivisionCharacters, we set the pendingGridDivisionIndex to the
            //matching index
            // guard appState.findModeGridDivisionCharacters.contains(keyCodeAsChar) else {
            //     return ToastManager.shared.show(
            //         "Key: \(keyCodeAsChar) is not part of findModeGridDivisionCharacters:\(appState.findModeGridDivisionCharacters)"
            //     )
            // }
            guard
                let gridDivisionCharactersIndex = appState
                    .findModeGridDivisionCharacters.firstIndex(of: keyCodeAsChar)
            else {
                return debug(
                    "\(keyCodeAsChar) is not part of findModeGridDivisionCharacters"
                )
            }
            guard gridDivisionCharactersIndex < (appState.gridDivisions * appState.gridDivisions)
            else {
                return debug(
                    "\(keyCodeAsChar)'s gridDivisionCharactersIndex: \(gridDivisionCharactersIndex) is greater/equal \((appState.gridDivisions * appState.gridDivisions))"
                )
            }
            debug(
                "\(keyCodeAsChar) is in gridDivisionCharactersIndex: \(gridDivisionCharactersIndex)"
            )
            let updatedFindState = FindState(
                pendingGridDivisionIndex: gridDivisionCharactersIndex,
                pendingInnerGridDivisionIndex: nil
            )
            appState.mode = .find(
                currentPendingOperation: (currentPendingOperation ?? "") + keyCodeAsChar,
                findState: updatedFindState,
            )
            // findState.pendingGridDivisionIndex =
            // gridDivisionCharactersIndex
            GridOverlay.shared.passAppState(state: appState)
            GridOverlay.shared.highlightCurrentGridDivision()
            // Second keypress
        } else {
            guard
                let innerGridDivisionCharactersIndex =
                    appState.findModeInnerGridDivisionCharacters.firstIndex(
                        of: keyCodeAsChar)
            else {
                return debug(
                    "\(keyCodeAsChar) is not part of findModeInnerGridDivisionCharacters"
                )
            }
            guard
                innerGridDivisionCharactersIndex
                    < (appState.innerGridDivisions * appState.innerGridDivisions)
            else {
                return debug(
                    "\(keyCodeAsChar)'s innerGridDivisionCharactersIndex: \(innerGridDivisionCharactersIndex) is greater/equal to \((appState.innerGridDivisions * appState.innerGridDivisions))"
                )
            }
            debug(
                "\(keyCodeAsChar) is in innerGridDivisionCharactersIndex: \(innerGridDivisionCharactersIndex)"
            )

            guard let currentScreenSize = getCurrentScreenSize() else {
                return
                    debug(
                        "Unable to getCurrentScreenSize within innerGridDivisionCharactersIndex operation"
                    )
            }
            let updatedFindState = FindState(
                pendingGridDivisionIndex: findState.pendingGridDivisionIndex,
                pendingInnerGridDivisionIndex: innerGridDivisionCharactersIndex
            )

            appState.mode = .find(
                currentPendingOperation: (currentPendingOperation ?? "") + keyCodeAsChar,
                findState: updatedFindState,
            )
            // findState.pendingInnerGridDivisionIndex =
            //     innerGridDivisionCharactersIndex
            // currentPendingOperation.append(keyCodeAsChar)

            let col =
                findState.pendingGridDivisionIndex!
                % appState.gridDivisions
            let row =
                findState.pendingGridDivisionIndex!
                / appState.gridDivisions
            let innerCol =
                innerGridDivisionCharactersIndex
                // findState.pendingInnerGridDivisionIndex!
                % appState.innerGridDivisions
            let innerRow =
                innerGridDivisionCharactersIndex
                // findState.pendingInnerGridDivisionIndex!
                / appState.innerGridDivisions
            let cellWidth =
                (currentScreenSize.width - 2 * appState.gridInset)
                / CGFloat(appState.gridDivisions)
            let cellHeight =
                (currentScreenSize.height - 2 * appState.gridInset)
                / CGFloat(appState.gridDivisions)
            let innerCellWidth = cellWidth / CGFloat(appState.innerGridDivisions)
            let innerCellHeight = cellHeight / CGFloat(appState.innerGridDivisions)
            let targetX =
                appState.gridInset + CGFloat(col) * cellWidth + CGFloat(innerCol)
                * innerCellWidth + innerCellWidth / 2
            let targetY =
                appState.gridInset + CGFloat(row) * cellHeight + CGFloat(innerRow)
                * innerCellHeight + innerCellHeight / 2
            moveMouseByExactCoordinatesOnCurrentScreen(x: targetX, y: targetY)
            NeoMouse.exitFindMode(appState: appState)

        }
    }
}

// MARK: - Toast

@MainActor
final class ToastManager {
    static let shared = ToastManager()
    private var window: NSPanel?

    func show(_ message: String) {

        guard
            let currentScreen =
                (NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) })
        else {
            return debug("Could not retrieve current screen in ToastManager.show")
        }
        window?.close()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 60),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentView = NSHostingView(rootView: ToastView(message: message))

        let x = currentScreen.visibleFrame.maxX - 320
        let y = currentScreen.visibleFrame.minY + 20
        panel.setFrameOrigin(NSPoint(x: x, y: y))

        panel.orderFront(nil)
        window = panel

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.window?.close()
            self?.window = nil
        }
    }
}

struct ToastView: View {
    let message: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(10)
    }
}

// MARK: - Grid Overlay

@MainActor
final class GridOverlay {
    static let shared = GridOverlay()
    private var window: NSWindow?
    private var isVisible = false
    private weak var appState: NeoMouseState?

    func toggle() {
        // appState = state
        isVisible ? hide() : show()
        isVisible.toggle()
    }

    func passAppState(state: NeoMouseState) {
        appState = state
    }

    func showGrid() {
        isVisible = true
        show()
    }

    func hideGrid() {
        isVisible = false
        hide()
    }

    func highlightCurrentGridDivision() {

    }

    private func show() {
        guard let screen = (NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) }),
            let appState
        else { return }
        if window == nil {
            let win = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.level = .screenSaver  // 101
            win.ignoresMouseEvents = true
            win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            win.contentView = NSHostingView(rootView: GridOverlayView(state: appState))
            window = win
        }
        window?.setFrame(screen.frame, display: true)
        window?.orderFrontRegardless()
    }

    private func hide() {
        window?.orderOut(nil)
    }
}

// MARK: - Grid View

struct GridOverlayView: View {
    @ObservedObject var state: NeoMouseState
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.15)
                Canvas { ctx, _ in
                    let inset = state.gridInset
                    let startX = inset
                    let endX = geo.size.width - inset
                    let startY = inset
                    let endY = geo.size.height - inset
                    let cellWidth = (endX - startX) / CGFloat(state.gridDivisions)
                    let cellHeight = (endY - startY) / CGFloat(state.gridDivisions)
                    let innerCellWidth = cellWidth / CGFloat(state.innerGridDivisions)
                    let innerCellHeight = cellHeight / CGFloat(state.innerGridDivisions)
                    guard case .find(_, let findState) = state.mode else {
                        return
                            debug("Should not happen: not in find mode within GridOverlayView")
                    }
                    if let outerIndex = findState.pendingGridDivisionIndex {
                        // Narrow to selected outer cell after first keypress
                        let selectedCol = outerIndex % state.gridDivisions
                        let selectedRow = outerIndex / state.gridDivisions
                        let cellOriginX = startX + cellWidth * CGFloat(selectedCol)
                        let cellOriginY = startY + cellHeight * CGFloat(selectedRow)

                        var focusedPath = Path()
                        for i in 0...state.innerGridDivisions {
                            let x = cellOriginX + innerCellWidth * CGFloat(i)
                            focusedPath.move(to: CGPoint(x: x, y: cellOriginY))
                            focusedPath.addLine(to: CGPoint(x: x, y: cellOriginY + cellHeight))
                            let y = cellOriginY + innerCellHeight * CGFloat(i)
                            focusedPath.move(to: CGPoint(x: cellOriginX, y: y))
                            focusedPath.addLine(to: CGPoint(x: cellOriginX + cellWidth, y: y))
                        }
                        ctx.stroke(focusedPath, with: .color(.white.opacity(0.6)), lineWidth: 1)

                        for innerCol in 0..<state.innerGridDivisions {
                            for innerRow in 0..<state.innerGridDivisions {
                                let innerIndex = innerRow * state.innerGridDivisions + innerCol
                                let innerMiddleX =
                                    cellOriginX + innerCellWidth * CGFloat(innerCol)
                                    + innerCellWidth / 2
                                let innerMiddleY =
                                    cellOriginY + innerCellHeight * CGFloat(innerRow)
                                    + innerCellHeight / 2
                                let label = Text(
                                    "\(state.findModeInnerGridDivisionCharacters[innerIndex])"
                                )
                                .accessibilityLabel(
                                    "Inner Row \(innerRow) Inner Col \(innerCol) \(state.findModeInnerGridDivisionCharacters[innerIndex])"
                                )
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                ctx.draw(
                                    label, at: CGPoint(x: innerMiddleX, y: innerMiddleY),
                                    anchor: .center)
                            }
                        }
                    } else {
                        // Default: outer grid + faint inner grid
                        let totalInner = state.gridDivisions * state.innerGridDivisions
                        var innerPath = Path()
                        for i in 1..<totalInner {
                            guard i % state.innerGridDivisions != 0 else { continue }
                            let x = startX + innerCellWidth * CGFloat(i)
                            innerPath.move(to: CGPoint(x: x, y: startY))
                            innerPath.addLine(to: CGPoint(x: x, y: endY))
                            let y = startY + innerCellHeight * CGFloat(i)
                            innerPath.move(to: CGPoint(x: startX, y: y))
                            innerPath.addLine(to: CGPoint(x: endX, y: y))
                        }
                        ctx.stroke(innerPath, with: .color(.white.opacity(0.3)), lineWidth: 0.5)

                        var outerPath = Path()
                        for i in 0...state.gridDivisions {
                            let x = startX + cellWidth * CGFloat(i)
                            outerPath.move(to: CGPoint(x: x, y: startY))
                            outerPath.addLine(to: CGPoint(x: x, y: endY))
                            let y = startY + cellHeight * CGFloat(i)
                            outerPath.move(to: CGPoint(x: startX, y: y))
                            outerPath.addLine(to: CGPoint(x: endX, y: y))
                        }
                        ctx.stroke(outerPath, with: .color(.white.opacity(0.6)), lineWidth: 1)

                        for col in 0..<state.gridDivisions {
                            for row in 0..<state.gridDivisions {
                                let x = startX + cellWidth * CGFloat(col)
                                let y = startY + cellHeight * CGFloat(row)
                                let index = row * state.gridDivisions + col
                                let charLabel = Text(
                                    "\(state.findModeGridDivisionCharacters[index])"
                                )
                                .accessibilityLabel(
                                    "Row \(row) Col \(col) \(state.findModeGridDivisionCharacters[index])"
                                )
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.blue)

                                ctx.draw(
                                    charLabel,
                                    at: CGPoint(x: x + cellWidth / 2, y: y + cellHeight / 2),
                                    anchor: .center)
                                if state.isAlwaysShowInnerGridCharacters {
                                    for innerCol in 0..<state.innerGridDivisions {
                                        for innerRow in 0..<state.innerGridDivisions {
                                            let innerX = x + innerCellWidth * CGFloat(innerCol)
                                            let innerY = y + innerCellHeight * CGFloat(innerRow)
                                            let middleInnerX = innerX + (innerCellWidth / 2)
                                            let middleInnerY = innerY + (innerCellHeight / 2)
                                            let innerIndex =
                                                innerRow * state.innerGridDivisions + innerCol
                                            let findCharInnerGridDivisionText = Text(
                                                "\(state.findModeInnerGridDivisionCharacters[innerIndex])"
                                            )
                                            .font(.system(size: 12))
                                            .foregroundColor(.white)
                                            ctx.draw(
                                                findCharInnerGridDivisionText,
                                                at: CGPoint(
                                                    x: middleInnerX,
                                                    y: middleInnerY),
                                                anchor: .topLeading)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - Menu Bar View

// struct CustomMenuBarView: View {
//     @ObservedObject var state: NeoMouseState
//
//     var body: some View {
//         VStack(spacing: 0) {
//             // Header
//             HStack {
//                 Image(systemName: "cursorarrow.motionlines")
//                     .font(.title2)
//                 Text("NeoMouse")
//                     .font(.headline)
//                 Spacer()
//                 Circle()
//                     .fill(case state.mod = .normal ? .green : .red)
//                     .frame(width: 8, height: 8)
//             }
//             .padding()
//             .background(.ultraThinMaterial)
//
//             Divider()
//
//             // Mouse position
//             VStack(alignment: .leading, spacing: 4) {
//                 Label("x: \(Int(state.mouseX))", systemImage: "arrow.left.and.right")
//                 Label("y: \(Int(state.mouseY))", systemImage: "arrow.up.and.down")
//             }
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .padding()
//
//             Divider()
//
//             // Toggle
//             Toggle("NeoMouse Mode", isOn: $state.isNeomouseMode)
//                 .padding()
//                 .toggleStyle(.switch)
//
//             Divider()
//
//             Button("Send Notification") {
//                 ToastManager.shared.show("Hello from NeoMouse!")
//             }
//             .buttonStyle(.borderless)
//             .padding(.vertical, 6)
//
//             Divider()
//
//             Button("Quit") { NSApp.terminate(nil) }
//                 .foregroundColor(.red)
//                 .buttonStyle(.borderless)
//                 .padding(.vertical, 6)
//         }
//         .frame(width: 220)
//     }
// }
