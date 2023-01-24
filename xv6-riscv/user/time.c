#include "user/user.h"
#include "kernel/types.h"

int
main(int argc, char * argv[])
{
  if(argc < 2){
    printf("Usage: time <program to time>\n");
    exit(1);
  }

  int w8 = 1;

// dont need argv[0]

  char * args[ ((sizeof(argv) - 1) / sizeof(char*) ) ];
  //collecting cla to pass
  char path[] = {'/','b','i','n','/'};
  
  char * program = malloc(sizeof(argv[1])+5);

  memcpy(program, path, 5); // make /bin/ not null-term
  
  memcpy(program,argv[1], sizeof(argv[1])); // append the program name
                                            //
  for(int i = 1; i < argc; i++){
     args[i-1] = argv[i];                   // collect remaining argv[]
  }

  if(fork() == 0){
    while(w8); // toddler jail

    exit( exec(program, args) < 0); // program set appropriately with extra cla if necessary

  } else {

    w8 = 0; // disengage lock

    uint64 b4 = uptime();

    if( wait((int *) 0) < 0 ){
      printf("Exec was unable to run %s", argv[1]);
      exit(1);
    }
    
    uint64 a4 = uptime();
    a4 -= b4;
    printf("Real-time in ticks: %d\n", (int)a4);

    return 0;
  }
}
