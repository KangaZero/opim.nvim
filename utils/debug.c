#include <stdarg.h>
#include <stdio.h>
#include <time.h>

void debug(const char *fmt, ...) {
#ifndef DEBUG
  return;
#endif
  time_t current_time;
  struct tm *local_time;
  time(&current_time);
  local_time = localtime(&current_time);

  printf("%02d:%02d:%02d | ", local_time->tm_hour, local_time->tm_min,
         local_time->tm_sec);

  va_list args;
  va_start(args, fmt);
  vprintf(fmt, args);
  va_end(args);

  printf("\n");
  fflush(stdout);
}
