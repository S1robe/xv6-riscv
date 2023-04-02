#include "user.h"
#define MAX 100000000

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
//Read 0, write 1
int trapC[2];
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
            //Child phase
            whoami = getpid();


            // All processes with whoami > thresh will make a priority increment request.
            // All processes have different pids, in the same order, with the same base means that this is 
            // repeatable for the same results, therefore a good report maker. If ran at the same time!
            //
            // I based this RNG seed off user input because why not?
            // It is skewed intentionally to demonstrate the pri increase, at a base of 10 it will be a 
            
            rand_next = whoami;
            int prepri = getpri();
            int thresh = ((rand(&rand_next) % 100)+n);


            if(random){ 
                if(thresh > 50){
                    thresh = (rand(&rand_next) % 5);   
                    setpri(prio[thresh]); // Request to elevate my priority by 1 level.
                }
            }
            
            if(prepri != getpri()){
                printf("Updated Priority of %d, priority: 0x%x\n", whoami, (prepri=getpri()));
            }
            
            // close(trapC[1]);
            //  // make all children wait here
            // int paused = 1;
            // while(paused)
            //     read(trapC[0], &paused, 1);
            // 
            // close(trapC[0]);
            (*work)();             

            exit(0);

        }
    }
    if(pid == -1)
        exit(1);

    // close(trapC[0]);
    //
    // write(trapC[1], (char *) 0, 1); // release the children
    // close(trapC[1]);
    //
    int status, corpse;
    while((corpse = wait(&status)) > 0)
        printf("Child %d Done with work (priority 0x%x)\n", corpse, status);
}


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
    if(!validate(argc, argv)) return 0;

   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
   whoami = -1; // parent
   pid = getpid();

    pipe(trapC);

   for(int p = 0; p < (sizeof(prio)/sizeof(prio[0])); p++){
        setpri(prio[p]);
        printf("(Basic) Priority Test: 0x%x\n", prio[p]);
        sendChildrenToWork(0, alphabet);

        printf("(Applying Ranomization) Priority Test: 0x%x\n", prio[p]);
        sendChildrenToWork(1, alphabet);
   }
   return 0;
}
