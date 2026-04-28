import AppKit

//
// func getMainScreenSize() -> (width: CGFloat, height: CGFloat)? {
//     guard let mainScreen = NSScreen.main else {
//         debug("Could not retrieve main screen in getMainScreenSize")
//         return nil
//     }
//     let width = mainScreen.frame.width
//     let height = mainScreen.frame.height
//     return (width, height)
// }

func getCurrentScreenSize() -> CGSize? {
    return NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) }?.frame.size
}

//CGRect(x: -1920, y: 0, width: 3840, height: 1080) for side by side
func getAllScreensBoundingRect() -> CGRect {
    return NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
}

func screenLayouts() {
    let main = NSScreen.main!.frame

    for screen in NSScreen.screens {
        let frame = screen.frame
        let position: String

        if frame.minX >= main.maxX {
            position = "right"
        } else if frame.maxX <= main.minX {
            position = "left"
        } else if frame.minY >= main.maxY {
            position = "above"
        } else if frame.maxY <= main.minY {
            position = "below"
        } else {
            position = "main"
        }

        print("\(screen.localizedName): \(position) — \(frame)")
    }
}
