#define _GNU_SOURCE
#include <sys/ptrace.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  if (argc == 1) return 1;
  pid_t pid = atoi(argv[1]);
  if (ptrace(PTRACE_SEIZE, pid, NULL, NULL) == -1) return 1;
  siginfo_t sig;
  return waitid(P_PID, pid, &sig, WEXITED|WNOWAIT);
}
