#include "mouse.h"
#include <ApplicationServices/ApplicationServices.h>

CGEventRef move_mouse(CGEventTapProxy proxy, CGEventType type, CGEventRef event,
                      void *refcon, Axis *axis, double range) {
  CGEventRef mouse = CGEventCreate(NULL);
  CGPoint pos = CGEventGetLocation(mouse);
  CFRelease(mouse);

  if (axis->x)
    pos.x += range;
  if (axis->y)
    pos.y += range;

  CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, pos,
                                            kCGMouseButtonLeft);
  CGEventPost(kCGHIDEventTap, move);
  CFRelease(move);
  return NULL;
}
