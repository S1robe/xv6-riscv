#include "user.h"


int status(){
  
  printf("Process PID:\t%d\n", getpid());
  printf("Priority:\t%x\n", getpri());
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


void setPri(int pri){
  printf("Attempting to set %d's priority to: 0x%x\n", getpid(), pri);
  if(setpri(pri) == -1){ // invalid request
    printf("Attempted to set invalid priority 0x%x\n", pri);
    return;
  }
  status();
}

int main(int argc, char*argv[]){
   
  status();
   setPri(0xA);
   setPri(0xB);
   setPri(0xC);
   setPri(0xD);
   setPri(0xF);
   setPri(0xE);
   setPri(0);
   setPri(-1);
   setPri(0x10);
   return 0;

}
