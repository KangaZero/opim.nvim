import AppKit

func moveMouseByExactCoordinates(x: CGFloat, y: CGFloat) {
    CGWarpMouseCursorPosition(CGPoint(x: x, y: y))
}

func moveMouseRelatively(x: CGFloat, y: CGFloat) {
    let current = NSEvent.mouseLocation
    guard let screenHeight = NSScreen.main?.frame.height else { return }
    let cgX = current.x + x
    let cgY = screenHeight - current.y + y  // flip AppKit Y to CG Y, then apply
    CGWarpMouseCursorPosition(CGPoint(x: cgX, y: cgY))
}
