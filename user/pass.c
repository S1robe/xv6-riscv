#include "user/user.h"


int main()
{

  exit(0);
  char ptc[1];
  // char ctp[1];
  int p1[2];  // parent to child
  // int p2[2];  // child to parent

  int x = 10;
  pipe(p1);

  if(fork() == 0){
    while(x > 0){

      printf("ptc %d\n", read(p1[0], ptc, 1));
      close(p1[0]);
    }
  } else {
    // while(x > 0){
      write(p1[1], "", 1);
      close(p1[1]);
      // x--;
    // }
  }
  return 0;

}








/*
int main(int argc, char * argv[]){

  if(argc > 2 || argc < 2){
    printf("Usage: pass <# passes>\n");
    exit(1);
  }

  char buf[512];
  int p[2];
  int passes = atoi(argv[1]);
  int wait = 0; // jail key
  fork();

  do{
   
    wait = 1; // jail key locked
   pipe(p);  // remake pipe?


   if(getpid() == 0){
     if(write(p[1], "5", 2) == -1){ // err handling
        printf("Write failed!");
        exit(1);
     }

     close(p[0]);  // child side pipe gone?
     close(p[1]);

     while(wait); // toddler jail

   } else {
     if(read(p[0], buf, sizeof(buf)) == -1){ // err handling
       printf("Read failed!");
       exit(1);
     }

     close(p[0]);
     close(p[1]);

     //pipe destroyed?

     printf("%s\n", buf);
     passes--;

     wait = 0;

   }
  } while(passes);

   return 0;
}*/

