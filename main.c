#include "main.h"
#include "utils/debug.h"
#include "utils/keycode_map.h"
#include "utils/mouse.h"
#include "utils/move.h"

#include <ApplicationServices/ApplicationServices.h>
#include <stdlib.h>
#include <string.h>

CGEventRef callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event,
                    void *refcon) {
  debug("event triggered: %d", type);
  if (type == kCGEventKeyDown) {
    CGKeyCode keycode =
        (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    debug("keycode: %hu", keycode);

    static char motion_count_as_string[MAX_MOTION_COUNT_LEN] = "";
    CGPoint axis = {0, 0};
    double range = 0;

    if (strlen(motion_count_as_string) < MAX_MOTION_COUNT_LEN &&
        keycode_to_digit_as_char(&keycode)) {
      const char *keycode_char = keycode_to_digit_as_char(&keycode);
      debug("key: digit, action: strcat to %s", motion_count_as_string);
      strcat(motion_count_as_string, keycode_char);
      return event;
    }

    // #ifdef DEBUG
    switch (keycode) {
    case VIM_c:
      get_current_mouse_position();
      break;
    }
    // #endif

    switch (keycode) {
    case VIM_h:
      axis = (CGPoint){1, 0};
      range = -10;
      break;
    case VIM_j:
      axis = (CGPoint){0, 1};
      range = 10;
      break;
    case VIM_k:
      axis = (CGPoint){0, 1};
      range = -10;
      break;
    case VIM_l:
      axis = (CGPoint){1, 0};
      range = 10;
      break;
    default:
      return event;
    }
    double motion_count = (strlen(motion_count_as_string) > 0)
                              ? strtod(motion_count_as_string, NULL)
                              : 1.0;
    move_mouse(proxy, type, event, refcon, &axis, range * motion_count);
    motion_count_as_string[0] = '\0';
    return event;
  }
  return event;
}

int main() {

  CGEventMask keydown_mask = CGEventMaskBit(kCGEventKeyDown);
  CGEventMask mouse_moved_mask = CGEventMaskBit(kCGEventMouseMoved);

  CFMachPortRef keydown_tap = CGEventTapCreate(
      kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
      keydown_mask, callback, NULL); // Event type : 10
  CFMachPortRef mouse_moved_tap = CGEventTapCreate(
      kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
      mouse_moved_mask, callback, NULL); // Event type : 5

  CFRunLoopSourceRef keydown_event_loop_source =
      CFMachPortCreateRunLoopSource(NULL, keydown_tap, 0);
  CFRunLoopSourceRef mouse_moved_event_loop_source =
      CFMachPortCreateRunLoopSource(NULL, mouse_moved_tap, 0);

  CFRunLoopAddSource(CFRunLoopGetCurrent(), keydown_event_loop_source,
                     kCFRunLoopCommonModes);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), mouse_moved_event_loop_source,
                     kCFRunLoopCommonModes);
  CGEventTapEnable(keydown_tap, true);
  CGEventTapEnable(mouse_moved_tap, true);

  CFRunLoopRun();

  return 0;
}
