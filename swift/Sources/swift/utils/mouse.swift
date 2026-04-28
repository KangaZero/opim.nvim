import AppKit

func moveMouseByExactGlobalCGPoint(x: CGFloat, y: CGFloat) {
    CGWarpMouseCursorPosition(CGPoint(x: x, y: y))
}

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

func moveMouseRelatively(x: CGFloat, y: CGFloat, enableClampToCurrentScreen: Bool) {
    let current = NSEvent.mouseLocation  // AppKit coords (origin bottom-left)

    guard let currentScreen = NSScreen.screens.first(where: { $0.frame.contains(current) }) else {
        debug("Could not retrieve current screen in moveMouseRelatively")
        return
    }
    guard let primaryScreen = NSScreen.screens.first else { return }

    let newX = current.x + x
    let newY = current.y - y  // stay in AppKit space, subtract because Y is flipped

    let allScreensRect = getAllScreensBoundingRect()
    let clampedX =
        enableClampToCurrentScreen
        ? max(currentScreen.frame.minX, min(newX, currentScreen.frame.maxX))
        : max(allScreensRect.minX, min(newX, allScreensRect.maxX))
    let clampedY =
        enableClampToCurrentScreen
        ? max(currentScreen.frame.minY, min(newY, currentScreen.frame.maxY))
        : max(allScreensRect.minY, min(newY, allScreensRect.maxY))

    // convert AppKit -> CG only at the last moment for CGWarp
    let cgY = primaryScreen.frame.height - clampedY
    CGWarpMouseCursorPosition(CGPoint(x: clampedX, y: cgY))

    debug("moveMouseRelatively to x:\(clampedX), y: \(clampedY)")
}

func getAppUnderMouse() -> NSRunningApplication? {
    let mouseLocation = NSEvent.mouseLocation

    return NSWorkspace.shared.runningApplications.first { app in
        guard let pid = Optional(app.processIdentifier) else { return false }
        let axApp = AXUIElementCreateApplication(pid)

        var windowsRef: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)
                == .success,
            let windows = windowsRef as? [AXUIElement]
        else { return false }

        return windows.contains { window in
            var posRef: CFTypeRef?
            var sizeRef: CFTypeRef?
            guard
                AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posRef)
                    == .success,
                AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
                    == .success,
                let pv = posRef, let sv = sizeRef
            else { return false }

            var pos = CGPoint.zero
            var size = CGSize.zero
            AXValueGetValue(pv as! AXValue, .cgPoint, &pos)
            AXValueGetValue(sv as! AXValue, .cgSize, &size)

            // flip Y since NSEvent uses flipped coords vs CGPoint
            let screenHeight = NSScreen.main?.frame.height ?? 0
            let flippedY = screenHeight - pos.y - size.height
            let windowRect = CGRect(x: pos.x, y: flippedY, width: size.width, height: size.height)

            return windowRect.contains(mouseLocation)
        }
    }
}
