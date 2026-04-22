import AppKit

func moveMouseByExactCoordinatesOnCurrentScreen(x: CGFloat, y: CGFloat) {
    let current = NSEvent.mouseLocation  // AppKit coords (origin bottom-left)

    guard let currentScreen = NSScreen.screens.first(where: { $0.frame.contains(current) }) else {
        debug("Could not retrieve current screen in moveMouseByExactCoordinates")
        return
    }
    guard let primaryScreen = NSScreen.screens.first else { return }
    let cgX = currentScreen.frame.origin.x + x
    let cgY =
        primaryScreen.frame.height - currentScreen.frame.origin.y - currentScreen.frame.height + y
    CGWarpMouseCursorPosition(CGPoint(x: cgX, y: cgY))
}

func getCurrentMouseLocation() -> CGPoint? {
    return CGEvent(source: nil)?.location
}

func moveMouseRelatively(x: CGFloat, y: CGFloat, enableClamp: Bool) {
    let current = NSEvent.mouseLocation  // AppKit coords (origin bottom-left)

    guard let currentScreen = NSScreen.screens.first(where: { $0.frame.contains(current) }) else {
        debug("Could not retrieve current screen in moveMouseRelatively")
        return
    }
    guard let primaryScreen = NSScreen.screens.first else { return }

    let newX = current.x + x
    let newY = current.y - y  // stay in AppKit space, subtract because Y is flipped

    let clampedX =
        enableClamp ? max(currentScreen.frame.minX, min(newX, currentScreen.frame.maxX)) : newX
    let clampedY =
        enableClamp ? max(currentScreen.frame.minY, min(newY, currentScreen.frame.maxY)) : newY

    // convert AppKit -> CG only at the last moment for CGWarp
    let cgY = primaryScreen.frame.height - clampedY
    CGWarpMouseCursorPosition(CGPoint(x: clampedX, y: cgY))

    debug("moveMouseRelatively to x:\(clampedX), y: \(clampedY)")
}
//
// func moveMouseRelatively(x: CGFloat, y: CGFloat, enableClamp: Bool) {
//     let current = NSEvent.mouseLocation
//     guard let mainScreenHeight = NSScreen.main?.frame.height else {
//         debug(
//             "Could not retrieve current main screen's height in moveMouseRelatively"
//         )
//         return
//     }
//     guard let mainScreenWidth = NSScreen.main?.frame.width else {
//         debug(
//             "Could not retrieve current main screen's width in moveMouseRelatively"
//         )
//         return
//     }
//     let cgX = current.x + x
//     let cgY = mainScreenHeight - current.y + y  // flip AppKit Y to CG Y, then apply
//     let cgXClamped = enableClamp ? max(0, min(cgX, mainScreenWidth)) : cgX
//     let cgYClamped = enableClamp ? max(0, min(cgY, mainScreenHeight)) : cgY
//     // let cgXClamped = enableClamp ? cgX.clamped(to: 0...mainScreenWidth) : cgX
//     // let cgYClamped = enableClamp ? cgY.clamped(to: 0...mainScreenHeight) : cgY
//     CGWarpMouseCursorPosition(CGPoint(x: cgXClamped, y: cgYClamped))
//     debug(
//         "moveMouseRelatively to x:\(cgXClamped), y: \(cgYClamped)"
//     )
// }
// func getCurrentMouseLocation() -> CGPoint? {
//     let current = NSEvent.mouseLocation
//     guard let screenHeight = NSScreen.main?.frame.height else {
//         debug(
//             "Could not retrieve current mouse location for main screen in getCurrentMouseLocation"
//         )
//         return nil
//     }
//     let cgX = current.x
//     let cgY = screenHeight - current.y  // flip AppKit Y to CG Y, then apply
//     return CGPoint(x: cgX, y: cgY)
// }
