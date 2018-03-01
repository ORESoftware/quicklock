#include <sys/types.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sys/ptrace.h>
#include <sys/dtrace.h>


int main(int argc, char *argv[]) {
    pid_t pid = atoi(argv[1]);
    printf("pid = %jd\n", (intmax_t) pid);
//    ptrace(PT_ATTACHEXC, pid, (caddr_t)1, 0);

//    wait(NULL);
//    return ptrace(PT_ATTACHEXC, pid, 0, 0);
}

// https://unix.stackexchange.com/a/58601/113238
// https://github.com/izabera/pm-tools/blob/master/waiter.c

//int main(int argc, char *argv[]) {
//    pid_t pid = atoi(argv[1]);
////    pid_t pid = 1244;
////    printf("pid",pid);
//    printf("pid = %jd\n", (intmax_t) pid);
////    int pid_status;
////    if (ptrace(PTRACE_SEIZE, pid) == -1) return 1;
//
//    return ptrace(PT_ATTACHEXC, pid, 0, 0);
////    if(ptrace (PT_ATTACH, target_pid, NULL, 0) == -1) return 1;
////    siginfo_t sig;
////    return waitid(P_PID, pid, &sig, WEXITED | WNOWAIT | WSTOPPED | WCONTINUED | WNOHANG );
//}

//#include <sys/ptrace.h>
//#include <stdlib.h>
//#include <sys/types.h>
//#include <sys/wait.h>
//
//int main(int argc, char *argv[]) {
//  if (argc == 1) return 1;
//  pid_t pid = atoi(argv[1]);
////  if (ptrace(PTRACE_SEIZE, pid, NULL, NULL) == -1) return 1;
//  siginfo_t sig;
//  return waitid(P_PID, pid, &sig, WEXITED|WNOWAIT);
//}