#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

//Project 2 syscalls:
uint64
sys_getmem(void)
{
   return myproc()->sz; // return the size of this process
}

uint64
sys_getstate(void)
{
  return myproc()->state;
}

uint64
sys_getparentpid(void)
{
  return myproc()->parent->pid; // reutrn the parent's pid
}

uint64
sys_getkstack(void)
{
  return myproc()->kstack; // return 64bit address (Base) of kstack
}

uint64
sys_getpri(void)
{
  int mypri;
  acquire(&myproc()->lock);
  mypri = myproc()->prio;
  release(&myproc()->lock);
  switch(mypri){
    case HIGHEST:
      return 0xC;
    case HIGH:
      return 0xA;
    case MIDDLE:
      return 0xB;
    case LOW:
      return 0xD;
    case LOWEST:
      return 0xF;
  }
  return -1;
}

uint64
sys_setpri(void)
{
  int reqpri;
  struct proc *p;
  argint(0, &reqpri); // get the requested priority
  p = myproc();
  acquire(&p->lock);
  
  switch(reqpri){
      case 0xC:
        p->prio = HIGHEST;
        break;
      case 0xA:
        p->prio = HIGH;
        break;
      case 0xB:
        p->prio = MIDDLE;
        break;
      case 0xD:
        p->prio = LOW;
        break;
      case 0xF:
        p->prio = LOWEST;
        break;
      default:
        release(&p->lock);
        return -1;
    }

  release(&p->lock);
  return 0;
}
