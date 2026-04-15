#include "mouse.h"
#include <ApplicationServices/ApplicationServices.h>

const CGPoint get_current_mouse_position() {
  CGEventRef event = CGEventCreate(NULL);
  CGPoint pos = CGEventGetLocation(event);
  CFRelease(event);

  return pos;
}
