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
