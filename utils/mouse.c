#include "mouse.h"
#include <ApplicationServices/ApplicationServices.h>

Axis get_current_mouse_position() {
  CGEventRef event = CGEventCreate(NULL);
  CGPoint pos = CGEventGetLocation(event);
  CFRelease(event);

  Axis axis = {pos.x, pos.y};
  return axis;
}
