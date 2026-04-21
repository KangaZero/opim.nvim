import AppKit

func moveMouseByExactCoordinates(x: CGFloat, y: CGFloat) {
    CGWarpMouseCursorPosition(CGPoint(x: x, y: y))
}

func moveMouseRelatively(x: CGFloat, y: CGFloat, enableClamp: Bool) {
    let current = NSEvent.mouseLocation
    guard let mainScreenHeight = NSScreen.main?.frame.height else {
        debug(
            "Could not retrieve current main screen's height in moveMouseRelatively"
        )
        return
    }
    guard let mainScreenWidth = NSScreen.main?.frame.width else {
        debug(
            "Could not retrieve current main screen's width in moveMouseRelatively"
        )
        return
    }
    let cgX = current.x + x
    let cgY = mainScreenHeight - current.y + y  // flip AppKit Y to CG Y, then apply
    let cgXClamped = enableClamp ? max(0, min(cgX, mainScreenWidth)) : cgX
    let cgYClamped = enableClamp ? max(0, min(cgY, mainScreenHeight)) : cgY
    // let cgXClamped = enableClamp ? cgX.clamped(to: 0...mainScreenWidth) : cgX
    // let cgYClamped = enableClamp ? cgY.clamped(to: 0...mainScreenHeight) : cgY
    CGWarpMouseCursorPosition(CGPoint(x: cgXClamped, y: cgYClamped))
    debug(
        "moveMouseRelatively to x:\(cgXClamped), y: \(cgYClamped)"
    )
}

func getCurrentMouseLocation() -> CGPoint? {
    let current = NSEvent.mouseLocation
    guard let screenHeight = NSScreen.main?.frame.height else {
        debug(
            "Could not retrieve current mouse location for main screen in getCurrentMouseLocation"
        )
        return nil
    }
    let cgX = current.x
    let cgY = screenHeight - current.y  // flip AppKit Y to CG Y, then apply
    return CGPoint(x: cgX, y: cgY)
}
