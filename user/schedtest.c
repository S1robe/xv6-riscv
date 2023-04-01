#include "user.h"

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
int trap[2];
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
    printf("%d Doing busy work...\n", whoami);
    for(int i = 0; i < 50; i++) {
        for (char a = 'a'; a <= 'z'; a++);
        for (char z = 'z'; z >= 'a'; z--);
    }
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

void sendChildrenToWork(int escalate, int thresh, void work(void))
{
    for(int i = 0; i < n; i++){
        
        if(-1 == (pid = fork())){ // parent create child
            printf("\nFork Error!\n");
            break;
        } else if(pid == 0){
            //Child phase
            whoami = getpid();
            int prepri = getpri();
            printf("I am %d, priority: 0x%x\n", whoami, prepri);
            if(escalate == 1 && whoami >= thresh){
                 setpri(getpri() + 1); // Request to elevate my priority by 1 level.
            }
            else if(escalate == -1 && whoami <= thresh){
                 setpri(getpri() - 1);
            }
            
            if(prepri != getpri())
                printf("Updated Priority of %d, priority: 0x%x\n", whoami, getpri());

            close(trap[1]); // close write, wont be writing
            int pause = 1;
          
            while(pause)
                read(trap[0], &pause, 1); // read from the buffer till no longer paused
        
            (*work)();
            exit(0);

        } else {
            write(trap[1], "\0", 1); // release the baby!
            wait(0);
        }
    }
    if(pid == -1)
        exit(1);
}


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
    if(!validate(argc, argv)) return 0;

   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
   whoami = -1; // parent
   pid = getpid();

   pipe(trap);

   // All processes with whoami > thresh will make a priority increment request.
   int thresh = ((rand(&rand_next) % n)/2);
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
       printf("(No Escalation) Priority Test: 0x%x\n", prio[p]);
       sendChildrenToWork(0, thresh, alphabet);
   }

   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
       printf("(Applying Escalation) Priority Test: 0x%x\n", prio[p]);
       sendChildrenToWork(1, thresh, alphabet);
   }
    
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
       printf("(Applying Deescalation) Priority Test: 0x%x\n", prio[p]);
       sendChildrenToWork(-1, thresh, alphabet);
   }


   return 0;



}
