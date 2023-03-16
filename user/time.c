#include "user/user.h"
#include "kernel/types.h"

int
main(int argc, char * argv[])
{

  if(argc < 2){
    printf("Usage: time <program to time>\n");
    return 1;
  }


  char * args[argc];
  char * program = argv[1];

  int i = 1;
  for(; i < argc; i++)
     args[i-1] = argv[i];                   // collect remaining argv[]

  args[i] = 0;

  int b4 = uptime();
  int pid = fork();

  if(pid < 0){

    printf("Fork Error!\n");
    return 1;

  } else if(pid == 0){ // child

    exec(program, args);
    printf("Exec Error!\n");
    return 1;

  } else {

    int status = 0;
    wait(&status);
    if(status < 0){
      return 1;
    }

    int a4 = uptime() - (b4);
    printf("Real-Time in ticks %d\n", a4);
    return 0;
  }
}
