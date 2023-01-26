#include "user/user.h"
#include "kernel/types.h"

int
main(int argc, char * argv[])
{

  if(argc < 2){
    printf("Usage: time <program to time>\n");
    return 1;
  }

  char * args[ ((sizeof(argv) - 1) / sizeof(char*) ) ];
  char * program = argv[1];

  int i = 1;
  for(; i < argc; i++){
     args[i-1] = argv[i];                   // collect remaining argv[]
  }
  args[i] = 0;

  uint64 * b4 = 0;
  int pid = fork();

  if(pid < 0){
    printf("Fork Error!\n");
    return 1;
  } else if(pid == 0){ // child
    (*b4) = uptime();
    exec(program, args); 
    printf("Exec Error!\n");
    exit(-1);
    return -1;

  } else {
    int status = 0;
    wait(&status);
    if(status < 0){
      return 1; 
    }
    
    uint64 a4 = uptime() - (*b4);
    printf("Real-Time in tickets %d\n", a4);
    return 0;
  }
}
