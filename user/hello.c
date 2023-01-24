#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char * argv[]){
   int i=0;
  
   printf("Hello world, this is Garrett Prentice.\n\n");

   for(i=0; i<argc;i++)
     printf("Argument %d: %s\n", i, argv[i]);

   exit(0);
}
