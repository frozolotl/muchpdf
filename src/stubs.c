#include <errno.h>
#include <setjmp.h>
#include <stdint.h>
#include <stdlib.h>

int setjmp(jmp_buf env) { return 0; }
void longjmp(jmp_buf env, int val) { abort(); }

int __syscall_unlinkat(int fd, const char *path, int flag) {
  errno = EPERM;
  return -1;
}

int __syscall_rmdir(intptr_t path) {
  errno = EPERM;
  return -1;
}

void _tzset_js(long *timezone, int *daylight, char *std_name, char *dst_name) {}
