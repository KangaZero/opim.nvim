#pragma once
#include <ApplicationServices/ApplicationServices.h>

CGEventRef move_mouse(CGEventTapProxy proxy, CGEventType type, CGEventRef event,
                      void *refcon, const CGPoint *axis, double range);
