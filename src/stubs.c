#include <time.h>

int __clock_gettime(clockid_t clk, struct timespec *ts) {
  ts->tv_sec = 0;
  ts->tv_nsec = 0;
  return 0;
}

