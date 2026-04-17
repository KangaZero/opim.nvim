#include "debug.h"
#include "math.h"
#include "screen.h"
#include <ApplicationServices/ApplicationServices.h>

CGEventRef move_mouse(CGEventTapProxy proxy, CGEventType type, CGEventRef event,
                      void *refcon, const CGPoint *axis, const double range) {
  CGEventRef mouse = CGEventCreate(NULL);
  CGPoint current_mouse_position = CGEventGetLocation(mouse);
  debug("current mouse position:", current_mouse_position);

  CFRelease(mouse);

  if (axis->x)
    current_mouse_position.x += range;
  if (axis->y)
    current_mouse_position.y += range;

  const CGSize current_display_bounds = get_current_display_bounds();
  debug("current_display_bounds: Width=%f, Height=%f",
        current_display_bounds.width, current_display_bounds.height);
  current_mouse_position.x =
      max(current_display_bounds.width, current_mouse_position.x);
  current_mouse_position.x =
      max(current_display_bounds.height, current_mouse_position.x);

  debug("current_mouse_position after applying bounds: x:%f y:%f",
        current_mouse_position.x, current_mouse_position.y);

  CGEventRef move = CGEventCreateMouseEvent(
      NULL, kCGEventMouseMoved, current_mouse_position, kCGMouseButtonLeft);
  CGEventPost(kCGHIDEventTap, move);
  CFRelease(move);
  return NULL;
}

//// CGPoint get_current_mouse_position() {
//   CGEventRef new_event = CGEventCreateMouseEvent(
//       CGEventSourceRef _Nullable source, CGEventType mouseType,
//       CGPoint mouseCursorPosition, CGMouseButton mouseButton)
// }
