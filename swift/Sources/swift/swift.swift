import AppKit
import SwiftUI

struct PendingOperation {
    var operation: String
    var pendingGridDivisionIndex: Int?
    var pendingInnerGridDivisionIndex: Int?
}

class NeoMouseState: ObservableObject {
    @Published var isNeomouseMode = false
    @Published var isFindMode = false
    @Published var mouseX: CGFloat = 0
    @Published var mouseY: CGFloat = 0
    @Published var gridInset: CGFloat = 10
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

    @Published var pendingOperation = PendingOperation(
        operation: "",
        pendingGridDivisionIndex: nil,
        pendingInnerGridDivisionIndex: nil
    )
    let rangeX: CGFloat = 10
    let rangeY: CGFloat = 10
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
                //INFO: 256 means no modifier is pressed, do not use .isEmpty method
                if event.modifierFlags.rawValue == 256 && appState.isNeomouseMode
                    && !appState.isFindMode
                {
                    switch event.keyCode {
                    //TODO: Add "$", "^ : where it will go to the most left/right of the current
                    //focused window", "g$" for most right, hjkl, counters,
                    case keyCodeToCharMap["f"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:f, keyCode:\(event.keyCode)"
                        )
                        appState.isFindMode = true
                        GridOverlay.shared.passAppState(state: appState)
                        GridOverlay.shared.showGrid()
                        ToastManager.shared.show(
                            "Find Mode On")
                    // INFO: Here starts VIM-like motions on the cursor
                    case keyCodeToCharMap["h"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:h, keyCode:\(event.keyCode)"
                        )
                        //TODO check that if the operation except the lastIndex are only nums
                        let operationCount: CGFloat = 1
                        appState.pendingOperation.operation.append("h")
                        moveMouseRelatively(
                            x: -appState.rangeX * operationCount, y: 0,
                            enableClamp:
                                appState.isClampCursorToScreen)
                        appState.pendingOperation.operation = ""
                    //TODO check that if the operation except the lastIndex are only nums
                    case keyCodeToCharMap["j"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:j, keyCode:\(event.keyCode)"
                        )
                        appState.pendingOperation.operation.append("j")
                    case keyCodeToCharMap["k"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:k, keyCode:\(event.keyCode)"
                        )
                        appState.pendingOperation.operation.append("k")
                    case keyCodeToCharMap["l"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:l, keyCode:\(event.keyCode)"
                        )
                        appState.pendingOperation.operation.append("l")
                    case keyCodeToCharMap["0"]:
                        debug(
                            "modifierFlags:false, isNeomouseMode:true, key:0, keyCode:\(event.keyCode)"
                        )
                        appState.pendingOperation.operation.append("0")
                        //Not a count-based operation, so execute "go to start of current
                        //x-axis-line (Similar to Vim's go to start of line)
                        guard appState.pendingOperation.operation.count == 1 else {
                            debug(
                                "operation count != 1, count: \(appState.pendingOperation.operation.count)"
                            )
                            break
                        }
                        guard let currentCGPoint = getCurrentMouseLocation() else {
                            debug("Could not retrieve current mouse location for operation '0")
                            break
                        }
                        moveMouseByExactCoordinates(
                            x: 0 + appState.gridInset, y: currentCGPoint.y)
                        appState.pendingOperation.operation = ""
                    default: break
                    }

                } else {
                    switch event.keyCode {
                    case keyCodeToCharMap["e"]:
                        guard event.modifierFlags.contains(.command) else {
                            //Possibly in isFindMode, if command modifier is not pressed.
                            //Guard clause included in the fn itself if !isFindMode or some other
                            //modifier is being used
                            return NeoMouse.executeFindModeOperation(
                                event: event, appState: appState)
                        }
                        debug(
                            "modifierFlags:true, modifier: \(event.modifierFlags), isNeomouseMode:\(appState.isNeomouseMode), key:e, keyCode:\(event.keyCode)"
                        )
                        appState.isNeomouseMode.toggle()
                        ToastManager.shared.show(
                            "NeoMouse Mode \(appState.isNeomouseMode ? "On" : "Off")")
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
                }
            }
        }
        // }
        NeoMouse.mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
            MainActor.assumeIsolated {
                appState.mouseX = NSEvent.mouseLocation.x
                appState.mouseY = NSEvent.mouseLocation.y
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("neomouse", systemImage: "bell") {
            CustomMenuBarView(state: appState)
        }
        .menuBarExtraStyle(.window)
    }
    private static func exitFindMode(appState: NeoMouseState) {
        appState.isFindMode = false
        appState.pendingOperation.pendingGridDivisionIndex = nil
        appState.pendingOperation.pendingInnerGridDivisionIndex = nil
        appState.pendingOperation.operation = ""
        GridOverlay.shared.hideGrid()
        ToastManager.shared.show(
            "Find Mode Off")
    }
    private static func executeFindModeOperation(event: NSEvent, appState: NeoMouseState) {
        debug(
            "isModifiedFlagEmpty: \(event.modifierFlags.isEmpty) modifier: \(event.modifierFlags), isFindMode: \(appState.isFindMode), isNeomouseMode:\(appState.isNeomouseMode), keyCode:\(event.keyCode)"
        )
        guard appState.isFindMode && event.modifierFlags.rawValue == 256 else {
            return
                debug(
                    "Cannot executeFindModeOperation as isFindMode is \(appState.isFindMode) == false or \(event.modifierFlags.rawValue) != 256"
                )
        }
        //First get the convert of the keyCode to its equivalent character (as String)
        let keyCodeAsChar: String? = keyCodeToCharMap.first(where: {
            $0.value == event.keyCode
        })?.key
        guard let keyCodeAsChar = keyCodeAsChar else {
            debug("Not a recognized keyCode, cannot find character (key)")
            return
        }

        //TODO: check if this is the best place to put this
        appState.pendingOperation.operation.append(keyCodeAsChar)
        // First keypress
        if appState.pendingOperation.pendingGridDivisionIndex == nil {
            //If there is a first index match for the character in
            //findModeGridDivisionCharacters, we set the pendingGridDivisionIndex to the
            //matching index
            guard
                let gridDivisionCharactersIndex = appState
                    .findModeGridDivisionCharacters.firstIndex(of: keyCodeAsChar)
            else {
                return debug(
                    "\(keyCodeAsChar) is not part of findModeGridDivisionCharacters"
                )
            }
            appState.pendingOperation.pendingGridDivisionIndex =
                gridDivisionCharactersIndex
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
            appState.pendingOperation.pendingInnerGridDivisionIndex =
                innerGridDivisionCharactersIndex
            appState.pendingOperation.operation.append(keyCodeAsChar)
            let col =
                appState.pendingOperation.pendingGridDivisionIndex!
                % appState.gridDivisions
            let row =
                appState.pendingOperation.pendingGridDivisionIndex!
                / appState.gridDivisions
            let innerCol =
                appState.pendingOperation.pendingInnerGridDivisionIndex!
                % appState.innerGridDivisions
            let innerRow =
                appState.pendingOperation.pendingInnerGridDivisionIndex!
                / appState.innerGridDivisions
            let cellWidth =
                (NSScreen.main!.frame.width - 2 * appState.gridInset)
                / CGFloat(appState.gridDivisions)
            let cellHeight =
                (NSScreen.main!.frame.height - 2 * appState.gridInset)
                / CGFloat(appState.gridDivisions)
            let innerCellWidth = cellWidth / CGFloat(appState.innerGridDivisions)
            let innerCellHeight = cellHeight / CGFloat(appState.innerGridDivisions)
            let targetX =
                appState.gridInset + CGFloat(col) * cellWidth + CGFloat(innerCol)
                * innerCellWidth + innerCellWidth / 2
            let targetY =
                appState.gridInset + CGFloat(row) * cellHeight + CGFloat(innerRow)
                * innerCellHeight + innerCellHeight / 2
            moveMouseByExactCoordinates(x: targetX, y: targetY)
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

        if let screen = NSScreen.main {
            let x = screen.visibleFrame.maxX - 320
            let y = screen.visibleFrame.minY + 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

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
        guard let screen = NSScreen.main, let appState else { return }
        if window == nil {
            let win = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.level = .screenSaver
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

                    if let outerIndex = state.pendingOperation.pendingGridDivisionIndex {
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
                                .font(.system(size: 16, weight: .bold))
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
        .ignoresSafeArea()
    }
}

// MARK: - Menu Bar View

struct CustomMenuBarView: View {
    @ObservedObject var state: NeoMouseState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cursorarrow.motionlines")
                    .font(.title2)
                Text("NeoMouse")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(state.isNeomouseMode ? .green : .red)
                    .frame(width: 8, height: 8)
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Mouse position
            VStack(alignment: .leading, spacing: 4) {
                Label("x: \(Int(state.mouseX))", systemImage: "arrow.left.and.right")
                Label("y: \(Int(state.mouseY))", systemImage: "arrow.up.and.down")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Divider()

            // Toggle
            Toggle("NeoMouse Mode", isOn: $state.isNeomouseMode)
                .padding()
                .toggleStyle(.switch)

            Divider()

            Button("Send Notification") {
                ToastManager.shared.show("Hello from NeoMouse!")
            }
            .buttonStyle(.borderless)
            .padding(.vertical, 6)

            Divider()

            Button("Quit") { NSApp.terminate(nil) }
                .foregroundColor(.red)
                .buttonStyle(.borderless)
                .padding(.vertical, 6)
        }
        .frame(width: 220)
    }
}
