#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/event.h>

int main(int argc, const char * argv[]) {

    pid_t pid;
    if(argc!=2 || (pid=atoi(argv[1]))<=0)
    {
    	fprintf(stderr,"USAGE\nwaiter pid\n");
    	return 1;
    }

    int kq=kqueue();
    if (kq == -1) {
    	fprintf(stderr,"kqueue returned -1.");
		return 1;
    }

    struct kevent ke;
    EV_SET(&ke, pid, EVFILT_PROC, EV_ADD, NOTE_EXIT, 0, NULL);

    if (kevent(kq, &ke, 1, NULL, 0, NULL)<0) {
        fprintf(stderr,"kevent failed.");
		return 1;
    }


while(true)
    for(;;) {
        memset(&ke,0,sizeof(struct kevent));
        if(kevent(kq, NULL, 0, &ke, 1, NULL)<0){
	        fprintf(stderr,"kevent failed.");
			return 1;
        }

        if (ke.fflags & NOTE_EXIT)
			break;
    }
    return 0;
}