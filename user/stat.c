#include "user.h"

int main(int argc, char*argv[]){
 
  printf("Process PID:\t%d\n", getpid());
  printf("Priority:\t%d\n", getpri());
  printf("Memory Used:\t%d\n", getmem()); 
  printf("Proc State:\t");
  switch(getstate()){
  case 0:  printf("UNUSED\n"); break;
  case 1:  printf("USED\n"); break;
  case 2:  printf("SLEEPING\n");break;
  case 3:  printf("RUNNABLE\n");break;
  case 4:  printf("RUNNING\n");break;
  case 5:  printf("ZOMBIE\n");break;
  default: printf("UNKNOWN\n");
  }

  printf("Uptime (ticks):\t%d\n",uptime());
  printf("Parent PID:\t%d\n", getparentpid());
  printf("Page Tble Addr:\t%p\n", getkstack());

  return 0;

}
