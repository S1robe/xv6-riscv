#include "user.h"



int main(){

  int b4, aftr;
  int pid = -2;
  int trapC[2];
  pipe(trapC);
  printf("This is a tie break tester for the scheduler\n");

  for(int i = 0; i < 4; i++){
    if((pid = fork()) == -1){
      printf("\nFork Error in child # %d\n", i);
      exit(1);
    }
    
    if(pid != -2){
      read(trapC[0], 0, 1); // trap children here till main is ready.



      exit(pid);
    }
  }
  
  

  

}

