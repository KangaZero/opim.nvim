#include "keycode_map.h"
#include <stddef.h>

#include <ApplicationServices/ApplicationServices.h>

const char *keycode_to_digit_as_char(CGKeyCode *keycode) {
  switch (*keycode) {
  case VIM_NUMBER_0:
    return "0";
  case VIM_NUMBER_1:
    return "1";
  case VIM_NUMBER_2:
    return "2";
  case VIM_NUMBER_3:
    return "3";
  case VIM_NUMBER_4:
    return "4";
  case VIM_NUMBER_5:
    return "5";
  case VIM_NUMBER_6:
    return "6";
  case VIM_NUMBER_7:
    return "7";
  case VIM_NUMBER_8:
    return "8";
  case VIM_NUMBER_9:
    return "9";
  default:
    return NULL;
  }
}
