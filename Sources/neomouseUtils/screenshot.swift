// import ScreenCaptureKit
// import AppKit
//
// class SCScreenshotManager : NSObject {
//
// class func captureSampleBuffer(contentFilter: SCContentFilter,
//                                configuration: SCStreamConfiguration)
//   															async throws -> CMSampleBuffer
//
// class func captureImage(contentFilter: SCContentFilter,
//                         configuration: SCStreamConfiguration)
//   											async throws -> GImage
// // Don't forget to customize the content you want in your screenshot
// // Use SCShareableContent or SCContentSharingPicker to pick your content
// let display = nil;
//
// // Create your SCContentFilter and SCStreamConfiguration
// // Customize these lines to use the content you want and desired config options
// let myContentFilter = SCContentFilter(display: display,
//                              excludingApplications: [],
//                              exceptingWindows: []);
// let myConfiguration = SCStreamConfiguration();
//
// // Call the screenshot API and get your screenshot image
// if let screenshot = try? await SCScreenshotManager.captureSampleBuffer(contentFilter: myContentFilter, configuration:
//                                                        myConfiguration) {
//     print("Fetched screenshot.")
// } else {
//     print("Failed to fetch screenshot.")
// }
// }
//
import ScreenCaptureKit
import CoreGraphics

public func screenshot(rect: CGRect, excluding ids: [CGWindowID] = []) async throws -> CGImage? {
    let content = try await SCShareableContent.current
    guard let display = content.displays.first else { return nil }
    let excluded = ids.isEmpty ? [] : content.windows.filter { ids.contains($0.windowID) }
    let filter = SCContentFilter(display: display, excludingWindows: excluded)
    let config = SCStreamConfiguration()
    config.sourceRect = rect
    config.width = Int(rect.width)
    config.height = Int(rect.height)
    config.showsCursor = false

    // 4. Take the screenshot
    // INFO: Check if we want to really use macOS 14, since currently on this requires it
    let image = try await SCScreenshotManager.captureImage(
        contentFilter: filter,
        configuration: config
    )

    return image
}
