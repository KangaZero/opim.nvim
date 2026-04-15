#include "debug.c"
#include <ApplicationServices/ApplicationServices.h>

#define MAX_DISPLAYS 8

CGDirectDisplayID get_current_display_id() {
  CGEventRef event = CGEventCreate(NULL);
  CGPoint pos = CGEventGetLocation(event);
  CFRelease(event);

  CGDirectDisplayID display_ids[MAX_DISPLAYS];
  uint32_t display_count = 0;

  CGGetDisplaysWithPoint(pos, MAX_DISPLAYS, display_ids, &display_count);
  debug("display count at current mouse position: %u", display_count);

  return display_count > 0 ? display_ids[0] : CGMainDisplayID();
}

CGSize get_current_display_bounds() {
  CGRect bounds = CGDisplayBounds(get_current_display_id());
  return bounds.size;
}
