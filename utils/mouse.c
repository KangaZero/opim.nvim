#include "mouse.h"
#include "debug.h"
#include <ApplicationServices/ApplicationServices.h>

CGPoint get_current_mouse_position() {
  CGEventRef event = CGEventCreate(NULL);
  CGPoint pos = CGEventGetLocation(event);
  CFRelease(event);
  debug("current mouse position: (%f, %f)", pos.x, pos.y);
  return pos;
}
