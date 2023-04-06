#include "user.h"

#define MAX 10000000000

const int prio[5] = {
   0x0C,
   0x0A,
   0x0B,
   0x0D,
   0x0F
};

int n;
int whoami;
int pid;
int key = 0;
int * buff;
int bufffd;
//Read 0, write 1
int trapC[2], trapP[2];
unsigned long rand_next = 1;

//Treated as boolean
int validate(int argc, char * argv[])
{
    if(argc != 2){
        printf("Usage: ./schedtest <# Num Children>\n");
        return 0;
    }
    n = atoi(argv[1]);

    if(n < 10) {
        printf("Must have at least 10 children spawned. Canceling...\n");
        return 0;
    }
    return 1;
}

void alphabet()
{
    for(unsigned long i = 0; i < MAX ; i++);
}

// from FreeBSD.
int do_rand(unsigned long *ctx)
{
/*
 * Compute x = (7^5 * x) mod (2^31 - 1)
 * without overflowing 31 bits:
 *      (2^31 - 1) = 127773 * (7^5) + 2836
 * From "Random number generators: good ones are hard to find",
 * Park and Miller, Communications of the ACM, vol. 31, no. 10,
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
    hi = x / 127773;
    lo = x % 127773;
    x = 16807 * lo - 2836 * hi;
    if (x < 0)
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
    *ctx = x;
    return (x);
}

#define rand(next) do_rand(next)

void sendChildrenToWork(int random, void work(void))
{
    for(int i = 0; i < n; i++){
        
        if(-1 == (pid = fork())){ // parent create child
            printf("\nFork Error!\n");
            break;
        } else if(pid == 0){
            if(i == n-1){
                key = 1;
            }
            

            switch(i){
              case 0:
                setpri(0xF);
                break;
              case 1:
                setpri(0xD);
                break;
              case 2:
                setpri(0xB);
                break;
              case 3:
                setpri(0xA);
                break;
              case 4:
                setpri(0xC);
                break;
                default:
                break;
             }

            whoami = getpid();
            int prepri = getpri();
            
            if(key){
                write(trapP[1], "\1", 1); // only one process will get this, and it will be the last one, to wake the parent.
            }


            read(trapC[0], 0, 1);
            write(trapC[1], (char* )0, 1);

            close(trapC[0]);
            close(trapC[1]);
            (*work)();             

            exit(prepri);

        }
    }
    if(pid == -1)
        exit(1);

    setpri(0xC); // Do this to ensure that main always gets to print first!
    read(trapP[0], 0, 1); // parent will get stuck here and wait to be released.

    write(trapC[1], (char *) 0, 1); // release the children
    
    int status, corpse;
    while((corpse = wait(&status)) > 0)
        printf("Child %d Done with work (priority 0x%x)\n", corpse, status);

    close(trapC[0]);
    close(trapC[1]);
    close(trapP[0]);
    close(trapP[1]);
}


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
    if(!validate(argc, argv)) return 0;

   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
   whoami = -1; // parent
   pid = getpid();

    buff = (int*)malloc(sizeof(int)*n);
   bufffd = dup(*buff);

   for(int p = 0; p < (sizeof(prio)/sizeof(prio[0])); p++){
        
    pipe(trapC);
    pipe(trapP);
        setpri(prio[p]);
        printf("(Basic) Priority Test: 0x%x\n", prio[p]);
        sendChildrenToWork(0, alphabet);

        // printf("(Applying Ranomization) Priority Test: 0x%x\n", prio[p]);
        // sendChildrenToWork(1, alphabet);
   }
   return 0;
}
