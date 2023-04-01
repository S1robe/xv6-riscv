
user/_stat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <status>:
#include "user.h"


int status(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  
  printf("Process PID:\t%d\n", getpid());
   8:	00000097          	auipc	ra,0x0
   c:	65e080e7          	jalr	1630(ra) # 666 <getpid>
  10:	85aa                	mv	a1,a0
  12:	00001517          	auipc	a0,0x1
  16:	b0e50513          	addi	a0,a0,-1266 # b20 <malloc+0xea>
  1a:	00001097          	auipc	ra,0x1
  1e:	964080e7          	jalr	-1692(ra) # 97e <printf>
  printf("Priority:\t%x\n", getpri());
  22:	00000097          	auipc	ra,0x0
  26:	684080e7          	jalr	1668(ra) # 6a6 <getpri>
  2a:	85aa                	mv	a1,a0
  2c:	00001517          	auipc	a0,0x1
  30:	b0c50513          	addi	a0,a0,-1268 # b38 <malloc+0x102>
  34:	00001097          	auipc	ra,0x1
  38:	94a080e7          	jalr	-1718(ra) # 97e <printf>
  printf("Memory Used:\t%d\n", getmem()); 
  3c:	00000097          	auipc	ra,0x0
  40:	64a080e7          	jalr	1610(ra) # 686 <getmem>
  44:	85aa                	mv	a1,a0
  46:	00001517          	auipc	a0,0x1
  4a:	b0250513          	addi	a0,a0,-1278 # b48 <malloc+0x112>
  4e:	00001097          	auipc	ra,0x1
  52:	930080e7          	jalr	-1744(ra) # 97e <printf>
  printf("Proc State:\t");
  56:	00001517          	auipc	a0,0x1
  5a:	b0a50513          	addi	a0,a0,-1270 # b60 <malloc+0x12a>
  5e:	00001097          	auipc	ra,0x1
  62:	920080e7          	jalr	-1760(ra) # 97e <printf>
  switch(getstate()){
  66:	00000097          	auipc	ra,0x0
  6a:	628080e7          	jalr	1576(ra) # 68e <getstate>
  6e:	4795                	li	a5,5
  70:	0ca7ec63          	bltu	a5,a0,148 <status+0x148>
  74:	050a                	slli	a0,a0,0x2
  76:	00001717          	auipc	a4,0x1
  7a:	bea70713          	addi	a4,a4,-1046 # c60 <malloc+0x22a>
  7e:	953a                	add	a0,a0,a4
  80:	411c                	lw	a5,0(a0)
  82:	97ba                	add	a5,a5,a4
  84:	8782                	jr	a5
  
    case 0:  printf("UNUSED\n"); break;
  86:	00001517          	auipc	a0,0x1
  8a:	aea50513          	addi	a0,a0,-1302 # b70 <malloc+0x13a>
  8e:	00001097          	auipc	ra,0x1
  92:	8f0080e7          	jalr	-1808(ra) # 97e <printf>
    case 4:  printf("RUNNING\n");break;
    case 5:  printf("ZOMBIE\n");break;
    default: printf("UNKNOWN\n");
  }

  printf("Uptime (ticks):\t%d\n",uptime());
  96:	00000097          	auipc	ra,0x0
  9a:	5e8080e7          	jalr	1512(ra) # 67e <uptime>
  9e:	85aa                	mv	a1,a0
  a0:	00001517          	auipc	a0,0x1
  a4:	b2850513          	addi	a0,a0,-1240 # bc8 <malloc+0x192>
  a8:	00001097          	auipc	ra,0x1
  ac:	8d6080e7          	jalr	-1834(ra) # 97e <printf>
  printf("Parent PID:\t%d\n", getparentpid());
  b0:	00000097          	auipc	ra,0x0
  b4:	5e6080e7          	jalr	1510(ra) # 696 <getparentpid>
  b8:	85aa                	mv	a1,a0
  ba:	00001517          	auipc	a0,0x1
  be:	b2650513          	addi	a0,a0,-1242 # be0 <malloc+0x1aa>
  c2:	00001097          	auipc	ra,0x1
  c6:	8bc080e7          	jalr	-1860(ra) # 97e <printf>
  printf("Page Tble Addr:\t%p\n", getkstack());
  ca:	00000097          	auipc	ra,0x0
  ce:	5d4080e7          	jalr	1492(ra) # 69e <getkstack>
  d2:	85aa                	mv	a1,a0
  d4:	00001517          	auipc	a0,0x1
  d8:	b1c50513          	addi	a0,a0,-1252 # bf0 <malloc+0x1ba>
  dc:	00001097          	auipc	ra,0x1
  e0:	8a2080e7          	jalr	-1886(ra) # 97e <printf>

  return 0;
}
  e4:	4501                	li	a0,0
  e6:	60a2                	ld	ra,8(sp)
  e8:	6402                	ld	s0,0(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret
    case 1:  printf("USED\n"); break;
  ee:	00001517          	auipc	a0,0x1
  f2:	a8a50513          	addi	a0,a0,-1398 # b78 <malloc+0x142>
  f6:	00001097          	auipc	ra,0x1
  fa:	888080e7          	jalr	-1912(ra) # 97e <printf>
  fe:	bf61                	j	96 <status+0x96>
    case 2:  printf("SLEEPING\n");break;
 100:	00001517          	auipc	a0,0x1
 104:	a8050513          	addi	a0,a0,-1408 # b80 <malloc+0x14a>
 108:	00001097          	auipc	ra,0x1
 10c:	876080e7          	jalr	-1930(ra) # 97e <printf>
 110:	b759                	j	96 <status+0x96>
    case 3:  printf("RUNNABLE\n");break;
 112:	00001517          	auipc	a0,0x1
 116:	a7e50513          	addi	a0,a0,-1410 # b90 <malloc+0x15a>
 11a:	00001097          	auipc	ra,0x1
 11e:	864080e7          	jalr	-1948(ra) # 97e <printf>
 122:	bf95                	j	96 <status+0x96>
    case 4:  printf("RUNNING\n");break;
 124:	00001517          	auipc	a0,0x1
 128:	a7c50513          	addi	a0,a0,-1412 # ba0 <malloc+0x16a>
 12c:	00001097          	auipc	ra,0x1
 130:	852080e7          	jalr	-1966(ra) # 97e <printf>
 134:	b78d                	j	96 <status+0x96>
    case 5:  printf("ZOMBIE\n");break;
 136:	00001517          	auipc	a0,0x1
 13a:	a7a50513          	addi	a0,a0,-1414 # bb0 <malloc+0x17a>
 13e:	00001097          	auipc	ra,0x1
 142:	840080e7          	jalr	-1984(ra) # 97e <printf>
 146:	bf81                	j	96 <status+0x96>
    default: printf("UNKNOWN\n");
 148:	00001517          	auipc	a0,0x1
 14c:	a7050513          	addi	a0,a0,-1424 # bb8 <malloc+0x182>
 150:	00001097          	auipc	ra,0x1
 154:	82e080e7          	jalr	-2002(ra) # 97e <printf>
 158:	bf3d                	j	96 <status+0x96>

000000000000015a <setPri>:


void setPri(int pri){
 15a:	1101                	addi	sp,sp,-32
 15c:	ec06                	sd	ra,24(sp)
 15e:	e822                	sd	s0,16(sp)
 160:	e426                	sd	s1,8(sp)
 162:	1000                	addi	s0,sp,32
 164:	84aa                	mv	s1,a0
  printf("Attempting to set %d's priority to: 0x%x\n", getpid(), pri);
 166:	00000097          	auipc	ra,0x0
 16a:	500080e7          	jalr	1280(ra) # 666 <getpid>
 16e:	85aa                	mv	a1,a0
 170:	8626                	mv	a2,s1
 172:	00001517          	auipc	a0,0x1
 176:	a9650513          	addi	a0,a0,-1386 # c08 <malloc+0x1d2>
 17a:	00001097          	auipc	ra,0x1
 17e:	804080e7          	jalr	-2044(ra) # 97e <printf>
  if(setpri(pri) == -1){ // invalid request
 182:	8526                	mv	a0,s1
 184:	00000097          	auipc	ra,0x0
 188:	52a080e7          	jalr	1322(ra) # 6ae <setpri>
 18c:	57fd                	li	a5,-1
 18e:	00f50b63          	beq	a0,a5,1a4 <setPri+0x4a>
    printf("Attempted to set invalid priority 0x%x\n", pri);
    return;
  }
  status();
 192:	00000097          	auipc	ra,0x0
 196:	e6e080e7          	jalr	-402(ra) # 0 <status>
}
 19a:	60e2                	ld	ra,24(sp)
 19c:	6442                	ld	s0,16(sp)
 19e:	64a2                	ld	s1,8(sp)
 1a0:	6105                	addi	sp,sp,32
 1a2:	8082                	ret
    printf("Attempted to set invalid priority 0x%x\n", pri);
 1a4:	85a6                	mv	a1,s1
 1a6:	00001517          	auipc	a0,0x1
 1aa:	a9250513          	addi	a0,a0,-1390 # c38 <malloc+0x202>
 1ae:	00000097          	auipc	ra,0x0
 1b2:	7d0080e7          	jalr	2000(ra) # 97e <printf>
    return;
 1b6:	b7d5                	j	19a <setPri+0x40>

00000000000001b8 <main>:

int main(int argc, char*argv[]){
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e406                	sd	ra,8(sp)
 1bc:	e022                	sd	s0,0(sp)
 1be:	0800                	addi	s0,sp,16
   
  status();
 1c0:	00000097          	auipc	ra,0x0
 1c4:	e40080e7          	jalr	-448(ra) # 0 <status>
   setPri(0xA);
 1c8:	4529                	li	a0,10
 1ca:	00000097          	auipc	ra,0x0
 1ce:	f90080e7          	jalr	-112(ra) # 15a <setPri>
   setPri(0xB);
 1d2:	452d                	li	a0,11
 1d4:	00000097          	auipc	ra,0x0
 1d8:	f86080e7          	jalr	-122(ra) # 15a <setPri>
   setPri(0xC);
 1dc:	4531                	li	a0,12
 1de:	00000097          	auipc	ra,0x0
 1e2:	f7c080e7          	jalr	-132(ra) # 15a <setPri>
   setPri(0xD);
 1e6:	4535                	li	a0,13
 1e8:	00000097          	auipc	ra,0x0
 1ec:	f72080e7          	jalr	-142(ra) # 15a <setPri>
   setPri(0xF);
 1f0:	453d                	li	a0,15
 1f2:	00000097          	auipc	ra,0x0
 1f6:	f68080e7          	jalr	-152(ra) # 15a <setPri>
   setPri(0xE);
 1fa:	4539                	li	a0,14
 1fc:	00000097          	auipc	ra,0x0
 200:	f5e080e7          	jalr	-162(ra) # 15a <setPri>
   setPri(0);
 204:	4501                	li	a0,0
 206:	00000097          	auipc	ra,0x0
 20a:	f54080e7          	jalr	-172(ra) # 15a <setPri>
   setPri(-1);
 20e:	557d                	li	a0,-1
 210:	00000097          	auipc	ra,0x0
 214:	f4a080e7          	jalr	-182(ra) # 15a <setPri>
   setPri(0x10);
 218:	4541                	li	a0,16
 21a:	00000097          	auipc	ra,0x0
 21e:	f40080e7          	jalr	-192(ra) # 15a <setPri>
   return 0;

}
 222:	4501                	li	a0,0
 224:	60a2                	ld	ra,8(sp)
 226:	6402                	ld	s0,0(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e406                	sd	ra,8(sp)
 230:	e022                	sd	s0,0(sp)
 232:	0800                	addi	s0,sp,16
  extern int main();
  main();
 234:	00000097          	auipc	ra,0x0
 238:	f84080e7          	jalr	-124(ra) # 1b8 <main>
  exit(0);
 23c:	4501                	li	a0,0
 23e:	00000097          	auipc	ra,0x0
 242:	3a8080e7          	jalr	936(ra) # 5e6 <exit>

0000000000000246 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 24c:	87aa                	mv	a5,a0
 24e:	0585                	addi	a1,a1,1
 250:	0785                	addi	a5,a5,1
 252:	fff5c703          	lbu	a4,-1(a1)
 256:	fee78fa3          	sb	a4,-1(a5)
 25a:	fb75                	bnez	a4,24e <strcpy+0x8>
    ;
  return os;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret

0000000000000262 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 268:	00054783          	lbu	a5,0(a0)
 26c:	cb91                	beqz	a5,280 <strcmp+0x1e>
 26e:	0005c703          	lbu	a4,0(a1)
 272:	00f71763          	bne	a4,a5,280 <strcmp+0x1e>
    p++, q++;
 276:	0505                	addi	a0,a0,1
 278:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	fbe5                	bnez	a5,26e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 280:	0005c503          	lbu	a0,0(a1)
}
 284:	40a7853b          	subw	a0,a5,a0
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strlen>:

uint
strlen(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 294:	00054783          	lbu	a5,0(a0)
 298:	cf91                	beqz	a5,2b4 <strlen+0x26>
 29a:	0505                	addi	a0,a0,1
 29c:	87aa                	mv	a5,a0
 29e:	86be                	mv	a3,a5
 2a0:	0785                	addi	a5,a5,1
 2a2:	fff7c703          	lbu	a4,-1(a5)
 2a6:	ff65                	bnez	a4,29e <strlen+0x10>
 2a8:	40a6853b          	subw	a0,a3,a0
 2ac:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  for(n = 0; s[n]; n++)
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <strlen+0x20>

00000000000002b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2be:	ca19                	beqz	a2,2d4 <memset+0x1c>
 2c0:	87aa                	mv	a5,a0
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2ce:	0785                	addi	a5,a5,1
 2d0:	fee79de3          	bne	a5,a4,2ca <memset+0x12>
  }
  return dst;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <strchr>:

char*
strchr(const char *s, char c)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2e0:	00054783          	lbu	a5,0(a0)
 2e4:	cb99                	beqz	a5,2fa <strchr+0x20>
    if(*s == c)
 2e6:	00f58763          	beq	a1,a5,2f4 <strchr+0x1a>
  for(; *s; s++)
 2ea:	0505                	addi	a0,a0,1
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	fbfd                	bnez	a5,2e6 <strchr+0xc>
      return (char*)s;
  return 0;
 2f2:	4501                	li	a0,0
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfe5                	j	2f4 <strchr+0x1a>

00000000000002fe <gets>:

char*
gets(char *buf, int max)
{
 2fe:	711d                	addi	sp,sp,-96
 300:	ec86                	sd	ra,88(sp)
 302:	e8a2                	sd	s0,80(sp)
 304:	e4a6                	sd	s1,72(sp)
 306:	e0ca                	sd	s2,64(sp)
 308:	fc4e                	sd	s3,56(sp)
 30a:	f852                	sd	s4,48(sp)
 30c:	f456                	sd	s5,40(sp)
 30e:	f05a                	sd	s6,32(sp)
 310:	ec5e                	sd	s7,24(sp)
 312:	1080                	addi	s0,sp,96
 314:	8baa                	mv	s7,a0
 316:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 318:	892a                	mv	s2,a0
 31a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 31c:	4aa9                	li	s5,10
 31e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 320:	89a6                	mv	s3,s1
 322:	2485                	addiw	s1,s1,1
 324:	0344d863          	bge	s1,s4,354 <gets+0x56>
    cc = read(0, &c, 1);
 328:	4605                	li	a2,1
 32a:	faf40593          	addi	a1,s0,-81
 32e:	4501                	li	a0,0
 330:	00000097          	auipc	ra,0x0
 334:	2ce080e7          	jalr	718(ra) # 5fe <read>
    if(cc < 1)
 338:	00a05e63          	blez	a0,354 <gets+0x56>
    buf[i++] = c;
 33c:	faf44783          	lbu	a5,-81(s0)
 340:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 344:	01578763          	beq	a5,s5,352 <gets+0x54>
 348:	0905                	addi	s2,s2,1
 34a:	fd679be3          	bne	a5,s6,320 <gets+0x22>
  for(i=0; i+1 < max; ){
 34e:	89a6                	mv	s3,s1
 350:	a011                	j	354 <gets+0x56>
 352:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 354:	99de                	add	s3,s3,s7
 356:	00098023          	sb	zero,0(s3)
  return buf;
}
 35a:	855e                	mv	a0,s7
 35c:	60e6                	ld	ra,88(sp)
 35e:	6446                	ld	s0,80(sp)
 360:	64a6                	ld	s1,72(sp)
 362:	6906                	ld	s2,64(sp)
 364:	79e2                	ld	s3,56(sp)
 366:	7a42                	ld	s4,48(sp)
 368:	7aa2                	ld	s5,40(sp)
 36a:	7b02                	ld	s6,32(sp)
 36c:	6be2                	ld	s7,24(sp)
 36e:	6125                	addi	sp,sp,96
 370:	8082                	ret

0000000000000372 <stat>:

int
stat(const char *n, struct stat *st)
{
 372:	1101                	addi	sp,sp,-32
 374:	ec06                	sd	ra,24(sp)
 376:	e822                	sd	s0,16(sp)
 378:	e426                	sd	s1,8(sp)
 37a:	e04a                	sd	s2,0(sp)
 37c:	1000                	addi	s0,sp,32
 37e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 380:	4581                	li	a1,0
 382:	00000097          	auipc	ra,0x0
 386:	2a4080e7          	jalr	676(ra) # 626 <open>
  if(fd < 0)
 38a:	02054563          	bltz	a0,3b4 <stat+0x42>
 38e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 390:	85ca                	mv	a1,s2
 392:	00000097          	auipc	ra,0x0
 396:	2ac080e7          	jalr	684(ra) # 63e <fstat>
 39a:	892a                	mv	s2,a0
  close(fd);
 39c:	8526                	mv	a0,s1
 39e:	00000097          	auipc	ra,0x0
 3a2:	270080e7          	jalr	624(ra) # 60e <close>
  return r;
}
 3a6:	854a                	mv	a0,s2
 3a8:	60e2                	ld	ra,24(sp)
 3aa:	6442                	ld	s0,16(sp)
 3ac:	64a2                	ld	s1,8(sp)
 3ae:	6902                	ld	s2,0(sp)
 3b0:	6105                	addi	sp,sp,32
 3b2:	8082                	ret
    return -1;
 3b4:	597d                	li	s2,-1
 3b6:	bfc5                	j	3a6 <stat+0x34>

00000000000003b8 <atoi>:

int
atoi(const char *s)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e422                	sd	s0,8(sp)
 3bc:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 3be:	00054683          	lbu	a3,0(a0)
 3c2:	fd06879b          	addiw	a5,a3,-48
 3c6:	0ff7f793          	zext.b	a5,a5
 3ca:	4625                	li	a2,9
 3cc:	02f66863          	bltu	a2,a5,3fc <atoi+0x44>
 3d0:	872a                	mv	a4,a0
  n = 0;
 3d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3d4:	0705                	addi	a4,a4,1
 3d6:	0025179b          	slliw	a5,a0,0x2
 3da:	9fa9                	addw	a5,a5,a0
 3dc:	0017979b          	slliw	a5,a5,0x1
 3e0:	9fb5                	addw	a5,a5,a3
 3e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3e6:	00074683          	lbu	a3,0(a4)
 3ea:	fd06879b          	addiw	a5,a3,-48
 3ee:	0ff7f793          	zext.b	a5,a5
 3f2:	fef671e3          	bgeu	a2,a5,3d4 <atoi+0x1c>

  return n;
}
 3f6:	6422                	ld	s0,8(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret
  n = 0;
 3fc:	4501                	li	a0,0
 3fe:	bfe5                	j	3f6 <atoi+0x3e>

0000000000000400 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
 406:	8eaa                	mv	t4,a0
    register const char *s = strt;
 408:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 40a:	02000693          	li	a3,32
        c = *s++;
 40e:	883e                	mv	a6,a5
 410:	0785                	addi	a5,a5,1
 412:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 416:	fed70ce3          	beq	a4,a3,40e <strtoi+0xe>
        c = *s++;
 41a:	2701                	sext.w	a4,a4

    if (c == '-') {
 41c:	02d00693          	li	a3,45
 420:	04d70d63          	beq	a4,a3,47a <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 424:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 428:	4f01                	li	t5,0
    } else if (c == '+')
 42a:	04d70e63          	beq	a4,a3,486 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 42e:	fef67693          	andi	a3,a2,-17
 432:	ea99                	bnez	a3,448 <strtoi+0x48>
 434:	03000693          	li	a3,48
 438:	04d70c63          	beq	a4,a3,490 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 43c:	e611                	bnez	a2,448 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 43e:	03000693          	li	a3,48
 442:	0cd70b63          	beq	a4,a3,518 <strtoi+0x118>
 446:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 448:	800008b7          	lui	a7,0x80000
 44c:	fff8c893          	not	a7,a7
 450:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 454:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 458:	1882                	slli	a7,a7,0x20
 45a:	0208d893          	srli	a7,a7,0x20
 45e:	02c8d8b3          	divu	a7,a7,a2
 462:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 466:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 46a:	0ac75163          	bge	a4,a2,50c <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 46e:	4681                	li	a3,0
 470:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 472:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 474:	2881                	sext.w	a7,a7
        else {
            any = 1;
 476:	4f85                	li	t6,1
 478:	a0a9                	j	4c2 <strtoi+0xc2>
        c = *s++;
 47a:	0007c703          	lbu	a4,0(a5)
 47e:	00280793          	addi	a5,a6,2
        neg = 1;
 482:	4f05                	li	t5,1
 484:	b76d                	j	42e <strtoi+0x2e>
        c = *s++;
 486:	0007c703          	lbu	a4,0(a5)
 48a:	00280793          	addi	a5,a6,2
 48e:	b745                	j	42e <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 490:	0007c683          	lbu	a3,0(a5)
 494:	0df6f693          	andi	a3,a3,223
 498:	05800513          	li	a0,88
 49c:	faa690e3          	bne	a3,a0,43c <strtoi+0x3c>
        c = s[1];
 4a0:	0017c703          	lbu	a4,1(a5)
        s += 2;
 4a4:	0789                	addi	a5,a5,2
        base = 16;
 4a6:	4641                	li	a2,16
 4a8:	b745                	j	448 <strtoi+0x48>
            any = -1;
 4aa:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 4ac:	00e2c463          	blt	t0,a4,4b4 <strtoi+0xb4>
 4b0:	a015                	j	4d4 <strtoi+0xd4>
            any = -1;
 4b2:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 4b4:	0785                	addi	a5,a5,1
 4b6:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 4ba:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 4be:	02c75063          	bge	a4,a2,4de <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 4c2:	fe06c8e3          	bltz	a3,4b2 <strtoi+0xb2>
 4c6:	0005081b          	sext.w	a6,a0
            any = -1;
 4ca:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 4cc:	ff0e64e3          	bltu	t3,a6,4b4 <strtoi+0xb4>
 4d0:	fca88de3          	beq	a7,a0,4aa <strtoi+0xaa>
            acc *= base;
 4d4:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 4d8:	9d39                	addw	a0,a0,a4
            any = 1;
 4da:	86fe                	mv	a3,t6
 4dc:	bfe1                	j	4b4 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 4de:	0006cd63          	bltz	a3,4f8 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 4e2:	000f0463          	beqz	t5,4ea <strtoi+0xea>
        acc = -acc;
 4e6:	40a0053b          	negw	a0,a0
    if (end != 0)
 4ea:	c581                	beqz	a1,4f2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 4ec:	ee89                	bnez	a3,506 <strtoi+0x106>
 4ee:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 4f2:	6422                	ld	s0,8(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 4f8:	000f1d63          	bnez	t5,512 <strtoi+0x112>
 4fc:	80000537          	lui	a0,0x80000
 500:	fff54513          	not	a0,a0
    if (end != 0)
 504:	d5fd                	beqz	a1,4f2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 506:	fff78e93          	addi	t4,a5,-1
 50a:	b7d5                	j	4ee <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 50c:	4681                	li	a3,0
 50e:	4501                	li	a0,0
 510:	bfc9                	j	4e2 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 512:	80000537          	lui	a0,0x80000
 516:	b7fd                	j	504 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 518:	80000e37          	lui	t3,0x80000
 51c:	fffe4e13          	not	t3,t3
 520:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 524:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 528:	003e589b          	srliw	a7,t3,0x3
 52c:	8e46                	mv	t3,a7
            c -= '0';
 52e:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 530:	4621                	li	a2,8
 532:	bf35                	j	46e <strtoi+0x6e>

0000000000000534 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 534:	1141                	addi	sp,sp,-16
 536:	e422                	sd	s0,8(sp)
 538:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 53a:	02b57463          	bgeu	a0,a1,562 <memmove+0x2e>
    while(n-- > 0)
 53e:	00c05f63          	blez	a2,55c <memmove+0x28>
 542:	1602                	slli	a2,a2,0x20
 544:	9201                	srli	a2,a2,0x20
 546:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 54a:	872a                	mv	a4,a0
      *dst++ = *src++;
 54c:	0585                	addi	a1,a1,1
 54e:	0705                	addi	a4,a4,1
 550:	fff5c683          	lbu	a3,-1(a1)
 554:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 558:	fee79ae3          	bne	a5,a4,54c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 55c:	6422                	ld	s0,8(sp)
 55e:	0141                	addi	sp,sp,16
 560:	8082                	ret
    dst += n;
 562:	00c50733          	add	a4,a0,a2
    src += n;
 566:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 568:	fec05ae3          	blez	a2,55c <memmove+0x28>
 56c:	fff6079b          	addiw	a5,a2,-1
 570:	1782                	slli	a5,a5,0x20
 572:	9381                	srli	a5,a5,0x20
 574:	fff7c793          	not	a5,a5
 578:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 57a:	15fd                	addi	a1,a1,-1
 57c:	177d                	addi	a4,a4,-1
 57e:	0005c683          	lbu	a3,0(a1)
 582:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 586:	fee79ae3          	bne	a5,a4,57a <memmove+0x46>
 58a:	bfc9                	j	55c <memmove+0x28>

000000000000058c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e422                	sd	s0,8(sp)
 590:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 592:	ca05                	beqz	a2,5c2 <memcmp+0x36>
 594:	fff6069b          	addiw	a3,a2,-1
 598:	1682                	slli	a3,a3,0x20
 59a:	9281                	srli	a3,a3,0x20
 59c:	0685                	addi	a3,a3,1
 59e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5a0:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 5a4:	0005c703          	lbu	a4,0(a1)
 5a8:	00e79863          	bne	a5,a4,5b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5ac:	0505                	addi	a0,a0,1
    p2++;
 5ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5b0:	fed518e3          	bne	a0,a3,5a0 <memcmp+0x14>
  }
  return 0;
 5b4:	4501                	li	a0,0
 5b6:	a019                	j	5bc <memcmp+0x30>
      return *p1 - *p2;
 5b8:	40e7853b          	subw	a0,a5,a4
}
 5bc:	6422                	ld	s0,8(sp)
 5be:	0141                	addi	sp,sp,16
 5c0:	8082                	ret
  return 0;
 5c2:	4501                	li	a0,0
 5c4:	bfe5                	j	5bc <memcmp+0x30>

00000000000005c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5c6:	1141                	addi	sp,sp,-16
 5c8:	e406                	sd	ra,8(sp)
 5ca:	e022                	sd	s0,0(sp)
 5cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5ce:	00000097          	auipc	ra,0x0
 5d2:	f66080e7          	jalr	-154(ra) # 534 <memmove>
}
 5d6:	60a2                	ld	ra,8(sp)
 5d8:	6402                	ld	s0,0(sp)
 5da:	0141                	addi	sp,sp,16
 5dc:	8082                	ret

00000000000005de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5de:	4885                	li	a7,1
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5e6:	4889                	li	a7,2
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 5ee:	488d                	li	a7,3
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5f6:	4891                	li	a7,4
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <read>:
.global read
read:
 li a7, SYS_read
 5fe:	4895                	li	a7,5
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <write>:
.global write
write:
 li a7, SYS_write
 606:	48c1                	li	a7,16
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <close>:
.global close
close:
 li a7, SYS_close
 60e:	48d5                	li	a7,21
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <kill>:
.global kill
kill:
 li a7, SYS_kill
 616:	4899                	li	a7,6
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <exec>:
.global exec
exec:
 li a7, SYS_exec
 61e:	489d                	li	a7,7
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <open>:
.global open
open:
 li a7, SYS_open
 626:	48bd                	li	a7,15
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 62e:	48c5                	li	a7,17
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 636:	48c9                	li	a7,18
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 63e:	48a1                	li	a7,8
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <link>:
.global link
link:
 li a7, SYS_link
 646:	48cd                	li	a7,19
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 64e:	48d1                	li	a7,20
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 656:	48a5                	li	a7,9
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <dup>:
.global dup
dup:
 li a7, SYS_dup
 65e:	48a9                	li	a7,10
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 666:	48ad                	li	a7,11
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 66e:	48b1                	li	a7,12
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 676:	48b5                	li	a7,13
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 67e:	48b9                	li	a7,14
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 686:	48d9                	li	a7,22
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 68e:	48dd                	li	a7,23
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 696:	48e1                	li	a7,24
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 69e:	48e5                	li	a7,25
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 6a6:	48e9                	li	a7,26
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 6ae:	48ed                	li	a7,27
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6b6:	1101                	addi	sp,sp,-32
 6b8:	ec06                	sd	ra,24(sp)
 6ba:	e822                	sd	s0,16(sp)
 6bc:	1000                	addi	s0,sp,32
 6be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6c2:	4605                	li	a2,1
 6c4:	fef40593          	addi	a1,s0,-17
 6c8:	00000097          	auipc	ra,0x0
 6cc:	f3e080e7          	jalr	-194(ra) # 606 <write>
}
 6d0:	60e2                	ld	ra,24(sp)
 6d2:	6442                	ld	s0,16(sp)
 6d4:	6105                	addi	sp,sp,32
 6d6:	8082                	ret

00000000000006d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6d8:	7139                	addi	sp,sp,-64
 6da:	fc06                	sd	ra,56(sp)
 6dc:	f822                	sd	s0,48(sp)
 6de:	f426                	sd	s1,40(sp)
 6e0:	f04a                	sd	s2,32(sp)
 6e2:	ec4e                	sd	s3,24(sp)
 6e4:	0080                	addi	s0,sp,64
 6e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6e8:	c299                	beqz	a3,6ee <printint+0x16>
 6ea:	0805c963          	bltz	a1,77c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6ee:	2581                	sext.w	a1,a1
  neg = 0;
 6f0:	4881                	li	a7,0
 6f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6f8:	2601                	sext.w	a2,a2
 6fa:	00000517          	auipc	a0,0x0
 6fe:	5de50513          	addi	a0,a0,1502 # cd8 <digits>
 702:	883a                	mv	a6,a4
 704:	2705                	addiw	a4,a4,1
 706:	02c5f7bb          	remuw	a5,a1,a2
 70a:	1782                	slli	a5,a5,0x20
 70c:	9381                	srli	a5,a5,0x20
 70e:	97aa                	add	a5,a5,a0
 710:	0007c783          	lbu	a5,0(a5)
 714:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 718:	0005879b          	sext.w	a5,a1
 71c:	02c5d5bb          	divuw	a1,a1,a2
 720:	0685                	addi	a3,a3,1
 722:	fec7f0e3          	bgeu	a5,a2,702 <printint+0x2a>
  if(neg)
 726:	00088c63          	beqz	a7,73e <printint+0x66>
    buf[i++] = '-';
 72a:	fd070793          	addi	a5,a4,-48
 72e:	00878733          	add	a4,a5,s0
 732:	02d00793          	li	a5,45
 736:	fef70823          	sb	a5,-16(a4)
 73a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 73e:	02e05863          	blez	a4,76e <printint+0x96>
 742:	fc040793          	addi	a5,s0,-64
 746:	00e78933          	add	s2,a5,a4
 74a:	fff78993          	addi	s3,a5,-1
 74e:	99ba                	add	s3,s3,a4
 750:	377d                	addiw	a4,a4,-1
 752:	1702                	slli	a4,a4,0x20
 754:	9301                	srli	a4,a4,0x20
 756:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 75a:	fff94583          	lbu	a1,-1(s2)
 75e:	8526                	mv	a0,s1
 760:	00000097          	auipc	ra,0x0
 764:	f56080e7          	jalr	-170(ra) # 6b6 <putc>
  while(--i >= 0)
 768:	197d                	addi	s2,s2,-1
 76a:	ff3918e3          	bne	s2,s3,75a <printint+0x82>
}
 76e:	70e2                	ld	ra,56(sp)
 770:	7442                	ld	s0,48(sp)
 772:	74a2                	ld	s1,40(sp)
 774:	7902                	ld	s2,32(sp)
 776:	69e2                	ld	s3,24(sp)
 778:	6121                	addi	sp,sp,64
 77a:	8082                	ret
    x = -xx;
 77c:	40b005bb          	negw	a1,a1
    neg = 1;
 780:	4885                	li	a7,1
    x = -xx;
 782:	bf85                	j	6f2 <printint+0x1a>

0000000000000784 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 784:	715d                	addi	sp,sp,-80
 786:	e486                	sd	ra,72(sp)
 788:	e0a2                	sd	s0,64(sp)
 78a:	fc26                	sd	s1,56(sp)
 78c:	f84a                	sd	s2,48(sp)
 78e:	f44e                	sd	s3,40(sp)
 790:	f052                	sd	s4,32(sp)
 792:	ec56                	sd	s5,24(sp)
 794:	e85a                	sd	s6,16(sp)
 796:	e45e                	sd	s7,8(sp)
 798:	e062                	sd	s8,0(sp)
 79a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 79c:	0005c903          	lbu	s2,0(a1)
 7a0:	18090c63          	beqz	s2,938 <vprintf+0x1b4>
 7a4:	8aaa                	mv	s5,a0
 7a6:	8bb2                	mv	s7,a2
 7a8:	00158493          	addi	s1,a1,1
  state = 0;
 7ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7ae:	02500a13          	li	s4,37
 7b2:	4b55                	li	s6,21
 7b4:	a839                	j	7d2 <vprintf+0x4e>
        putc(fd, c);
 7b6:	85ca                	mv	a1,s2
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	efc080e7          	jalr	-260(ra) # 6b6 <putc>
 7c2:	a019                	j	7c8 <vprintf+0x44>
    } else if(state == '%'){
 7c4:	01498d63          	beq	s3,s4,7de <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 7c8:	0485                	addi	s1,s1,1
 7ca:	fff4c903          	lbu	s2,-1(s1)
 7ce:	16090563          	beqz	s2,938 <vprintf+0x1b4>
    if(state == 0){
 7d2:	fe0999e3          	bnez	s3,7c4 <vprintf+0x40>
      if(c == '%'){
 7d6:	ff4910e3          	bne	s2,s4,7b6 <vprintf+0x32>
        state = '%';
 7da:	89d2                	mv	s3,s4
 7dc:	b7f5                	j	7c8 <vprintf+0x44>
      if(c == 'd'){
 7de:	13490263          	beq	s2,s4,902 <vprintf+0x17e>
 7e2:	f9d9079b          	addiw	a5,s2,-99
 7e6:	0ff7f793          	zext.b	a5,a5
 7ea:	12fb6563          	bltu	s6,a5,914 <vprintf+0x190>
 7ee:	f9d9079b          	addiw	a5,s2,-99
 7f2:	0ff7f713          	zext.b	a4,a5
 7f6:	10eb6f63          	bltu	s6,a4,914 <vprintf+0x190>
 7fa:	00271793          	slli	a5,a4,0x2
 7fe:	00000717          	auipc	a4,0x0
 802:	48270713          	addi	a4,a4,1154 # c80 <malloc+0x24a>
 806:	97ba                	add	a5,a5,a4
 808:	439c                	lw	a5,0(a5)
 80a:	97ba                	add	a5,a5,a4
 80c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 80e:	008b8913          	addi	s2,s7,8
 812:	4685                	li	a3,1
 814:	4629                	li	a2,10
 816:	000ba583          	lw	a1,0(s7)
 81a:	8556                	mv	a0,s5
 81c:	00000097          	auipc	ra,0x0
 820:	ebc080e7          	jalr	-324(ra) # 6d8 <printint>
 824:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 826:	4981                	li	s3,0
 828:	b745                	j	7c8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 82a:	008b8913          	addi	s2,s7,8
 82e:	4681                	li	a3,0
 830:	4629                	li	a2,10
 832:	000ba583          	lw	a1,0(s7)
 836:	8556                	mv	a0,s5
 838:	00000097          	auipc	ra,0x0
 83c:	ea0080e7          	jalr	-352(ra) # 6d8 <printint>
 840:	8bca                	mv	s7,s2
      state = 0;
 842:	4981                	li	s3,0
 844:	b751                	j	7c8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 846:	008b8913          	addi	s2,s7,8
 84a:	4681                	li	a3,0
 84c:	4641                	li	a2,16
 84e:	000ba583          	lw	a1,0(s7)
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e84080e7          	jalr	-380(ra) # 6d8 <printint>
 85c:	8bca                	mv	s7,s2
      state = 0;
 85e:	4981                	li	s3,0
 860:	b7a5                	j	7c8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 862:	008b8c13          	addi	s8,s7,8
 866:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 86a:	03000593          	li	a1,48
 86e:	8556                	mv	a0,s5
 870:	00000097          	auipc	ra,0x0
 874:	e46080e7          	jalr	-442(ra) # 6b6 <putc>
  putc(fd, 'x');
 878:	07800593          	li	a1,120
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	e38080e7          	jalr	-456(ra) # 6b6 <putc>
 886:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 888:	00000b97          	auipc	s7,0x0
 88c:	450b8b93          	addi	s7,s7,1104 # cd8 <digits>
 890:	03c9d793          	srli	a5,s3,0x3c
 894:	97de                	add	a5,a5,s7
 896:	0007c583          	lbu	a1,0(a5)
 89a:	8556                	mv	a0,s5
 89c:	00000097          	auipc	ra,0x0
 8a0:	e1a080e7          	jalr	-486(ra) # 6b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8a4:	0992                	slli	s3,s3,0x4
 8a6:	397d                	addiw	s2,s2,-1
 8a8:	fe0914e3          	bnez	s2,890 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 8ac:	8be2                	mv	s7,s8
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bf21                	j	7c8 <vprintf+0x44>
        s = va_arg(ap, char*);
 8b2:	008b8993          	addi	s3,s7,8
 8b6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 8ba:	02090163          	beqz	s2,8dc <vprintf+0x158>
        while(*s != 0){
 8be:	00094583          	lbu	a1,0(s2)
 8c2:	c9a5                	beqz	a1,932 <vprintf+0x1ae>
          putc(fd, *s);
 8c4:	8556                	mv	a0,s5
 8c6:	00000097          	auipc	ra,0x0
 8ca:	df0080e7          	jalr	-528(ra) # 6b6 <putc>
          s++;
 8ce:	0905                	addi	s2,s2,1
        while(*s != 0){
 8d0:	00094583          	lbu	a1,0(s2)
 8d4:	f9e5                	bnez	a1,8c4 <vprintf+0x140>
        s = va_arg(ap, char*);
 8d6:	8bce                	mv	s7,s3
      state = 0;
 8d8:	4981                	li	s3,0
 8da:	b5fd                	j	7c8 <vprintf+0x44>
          s = "(null)";
 8dc:	00000917          	auipc	s2,0x0
 8e0:	39c90913          	addi	s2,s2,924 # c78 <malloc+0x242>
        while(*s != 0){
 8e4:	02800593          	li	a1,40
 8e8:	bff1                	j	8c4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 8ea:	008b8913          	addi	s2,s7,8
 8ee:	000bc583          	lbu	a1,0(s7)
 8f2:	8556                	mv	a0,s5
 8f4:	00000097          	auipc	ra,0x0
 8f8:	dc2080e7          	jalr	-574(ra) # 6b6 <putc>
 8fc:	8bca                	mv	s7,s2
      state = 0;
 8fe:	4981                	li	s3,0
 900:	b5e1                	j	7c8 <vprintf+0x44>
        putc(fd, c);
 902:	02500593          	li	a1,37
 906:	8556                	mv	a0,s5
 908:	00000097          	auipc	ra,0x0
 90c:	dae080e7          	jalr	-594(ra) # 6b6 <putc>
      state = 0;
 910:	4981                	li	s3,0
 912:	bd5d                	j	7c8 <vprintf+0x44>
        putc(fd, '%');
 914:	02500593          	li	a1,37
 918:	8556                	mv	a0,s5
 91a:	00000097          	auipc	ra,0x0
 91e:	d9c080e7          	jalr	-612(ra) # 6b6 <putc>
        putc(fd, c);
 922:	85ca                	mv	a1,s2
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	d90080e7          	jalr	-624(ra) # 6b6 <putc>
      state = 0;
 92e:	4981                	li	s3,0
 930:	bd61                	j	7c8 <vprintf+0x44>
        s = va_arg(ap, char*);
 932:	8bce                	mv	s7,s3
      state = 0;
 934:	4981                	li	s3,0
 936:	bd49                	j	7c8 <vprintf+0x44>
    }
  }
}
 938:	60a6                	ld	ra,72(sp)
 93a:	6406                	ld	s0,64(sp)
 93c:	74e2                	ld	s1,56(sp)
 93e:	7942                	ld	s2,48(sp)
 940:	79a2                	ld	s3,40(sp)
 942:	7a02                	ld	s4,32(sp)
 944:	6ae2                	ld	s5,24(sp)
 946:	6b42                	ld	s6,16(sp)
 948:	6ba2                	ld	s7,8(sp)
 94a:	6c02                	ld	s8,0(sp)
 94c:	6161                	addi	sp,sp,80
 94e:	8082                	ret

0000000000000950 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 950:	715d                	addi	sp,sp,-80
 952:	ec06                	sd	ra,24(sp)
 954:	e822                	sd	s0,16(sp)
 956:	1000                	addi	s0,sp,32
 958:	e010                	sd	a2,0(s0)
 95a:	e414                	sd	a3,8(s0)
 95c:	e818                	sd	a4,16(s0)
 95e:	ec1c                	sd	a5,24(s0)
 960:	03043023          	sd	a6,32(s0)
 964:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 968:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 96c:	8622                	mv	a2,s0
 96e:	00000097          	auipc	ra,0x0
 972:	e16080e7          	jalr	-490(ra) # 784 <vprintf>
}
 976:	60e2                	ld	ra,24(sp)
 978:	6442                	ld	s0,16(sp)
 97a:	6161                	addi	sp,sp,80
 97c:	8082                	ret

000000000000097e <printf>:

void
printf(const char *fmt, ...)
{
 97e:	711d                	addi	sp,sp,-96
 980:	ec06                	sd	ra,24(sp)
 982:	e822                	sd	s0,16(sp)
 984:	1000                	addi	s0,sp,32
 986:	e40c                	sd	a1,8(s0)
 988:	e810                	sd	a2,16(s0)
 98a:	ec14                	sd	a3,24(s0)
 98c:	f018                	sd	a4,32(s0)
 98e:	f41c                	sd	a5,40(s0)
 990:	03043823          	sd	a6,48(s0)
 994:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 998:	00840613          	addi	a2,s0,8
 99c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9a0:	85aa                	mv	a1,a0
 9a2:	4505                	li	a0,1
 9a4:	00000097          	auipc	ra,0x0
 9a8:	de0080e7          	jalr	-544(ra) # 784 <vprintf>
}
 9ac:	60e2                	ld	ra,24(sp)
 9ae:	6442                	ld	s0,16(sp)
 9b0:	6125                	addi	sp,sp,96
 9b2:	8082                	ret

00000000000009b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9b4:	1141                	addi	sp,sp,-16
 9b6:	e422                	sd	s0,8(sp)
 9b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9be:	00000797          	auipc	a5,0x0
 9c2:	6427b783          	ld	a5,1602(a5) # 1000 <freep>
 9c6:	a02d                	j	9f0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9c8:	4618                	lw	a4,8(a2)
 9ca:	9f2d                	addw	a4,a4,a1
 9cc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9d0:	6398                	ld	a4,0(a5)
 9d2:	6310                	ld	a2,0(a4)
 9d4:	a83d                	j	a12 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9d6:	ff852703          	lw	a4,-8(a0)
 9da:	9f31                	addw	a4,a4,a2
 9dc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9de:	ff053683          	ld	a3,-16(a0)
 9e2:	a091                	j	a26 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e4:	6398                	ld	a4,0(a5)
 9e6:	00e7e463          	bltu	a5,a4,9ee <free+0x3a>
 9ea:	00e6ea63          	bltu	a3,a4,9fe <free+0x4a>
{
 9ee:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9f0:	fed7fae3          	bgeu	a5,a3,9e4 <free+0x30>
 9f4:	6398                	ld	a4,0(a5)
 9f6:	00e6e463          	bltu	a3,a4,9fe <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9fa:	fee7eae3          	bltu	a5,a4,9ee <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9fe:	ff852583          	lw	a1,-8(a0)
 a02:	6390                	ld	a2,0(a5)
 a04:	02059813          	slli	a6,a1,0x20
 a08:	01c85713          	srli	a4,a6,0x1c
 a0c:	9736                	add	a4,a4,a3
 a0e:	fae60de3          	beq	a2,a4,9c8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a12:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a16:	4790                	lw	a2,8(a5)
 a18:	02061593          	slli	a1,a2,0x20
 a1c:	01c5d713          	srli	a4,a1,0x1c
 a20:	973e                	add	a4,a4,a5
 a22:	fae68ae3          	beq	a3,a4,9d6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a26:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a28:	00000717          	auipc	a4,0x0
 a2c:	5cf73c23          	sd	a5,1496(a4) # 1000 <freep>
}
 a30:	6422                	ld	s0,8(sp)
 a32:	0141                	addi	sp,sp,16
 a34:	8082                	ret

0000000000000a36 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a36:	7139                	addi	sp,sp,-64
 a38:	fc06                	sd	ra,56(sp)
 a3a:	f822                	sd	s0,48(sp)
 a3c:	f426                	sd	s1,40(sp)
 a3e:	f04a                	sd	s2,32(sp)
 a40:	ec4e                	sd	s3,24(sp)
 a42:	e852                	sd	s4,16(sp)
 a44:	e456                	sd	s5,8(sp)
 a46:	e05a                	sd	s6,0(sp)
 a48:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4a:	02051493          	slli	s1,a0,0x20
 a4e:	9081                	srli	s1,s1,0x20
 a50:	04bd                	addi	s1,s1,15
 a52:	8091                	srli	s1,s1,0x4
 a54:	0014899b          	addiw	s3,s1,1
 a58:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a5a:	00000517          	auipc	a0,0x0
 a5e:	5a653503          	ld	a0,1446(a0) # 1000 <freep>
 a62:	c515                	beqz	a0,a8e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a64:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a66:	4798                	lw	a4,8(a5)
 a68:	02977f63          	bgeu	a4,s1,aa6 <malloc+0x70>
  if(nu < 4096)
 a6c:	8a4e                	mv	s4,s3
 a6e:	0009871b          	sext.w	a4,s3
 a72:	6685                	lui	a3,0x1
 a74:	00d77363          	bgeu	a4,a3,a7a <malloc+0x44>
 a78:	6a05                	lui	s4,0x1
 a7a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a7e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a82:	00000917          	auipc	s2,0x0
 a86:	57e90913          	addi	s2,s2,1406 # 1000 <freep>
  if(p == (char*)-1)
 a8a:	5afd                	li	s5,-1
 a8c:	a895                	j	b00 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a8e:	00000797          	auipc	a5,0x0
 a92:	58278793          	addi	a5,a5,1410 # 1010 <base>
 a96:	00000717          	auipc	a4,0x0
 a9a:	56f73523          	sd	a5,1386(a4) # 1000 <freep>
 a9e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 aa0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aa4:	b7e1                	j	a6c <malloc+0x36>
      if(p->s.size == nunits)
 aa6:	02e48c63          	beq	s1,a4,ade <malloc+0xa8>
        p->s.size -= nunits;
 aaa:	4137073b          	subw	a4,a4,s3
 aae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab0:	02071693          	slli	a3,a4,0x20
 ab4:	01c6d713          	srli	a4,a3,0x1c
 ab8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 abe:	00000717          	auipc	a4,0x0
 ac2:	54a73123          	sd	a0,1346(a4) # 1000 <freep>
      return (void*)(p + 1);
 ac6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aca:	70e2                	ld	ra,56(sp)
 acc:	7442                	ld	s0,48(sp)
 ace:	74a2                	ld	s1,40(sp)
 ad0:	7902                	ld	s2,32(sp)
 ad2:	69e2                	ld	s3,24(sp)
 ad4:	6a42                	ld	s4,16(sp)
 ad6:	6aa2                	ld	s5,8(sp)
 ad8:	6b02                	ld	s6,0(sp)
 ada:	6121                	addi	sp,sp,64
 adc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ade:	6398                	ld	a4,0(a5)
 ae0:	e118                	sd	a4,0(a0)
 ae2:	bff1                	j	abe <malloc+0x88>
  hp->s.size = nu;
 ae4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ae8:	0541                	addi	a0,a0,16
 aea:	00000097          	auipc	ra,0x0
 aee:	eca080e7          	jalr	-310(ra) # 9b4 <free>
  return freep;
 af2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 af6:	d971                	beqz	a0,aca <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 afa:	4798                	lw	a4,8(a5)
 afc:	fa9775e3          	bgeu	a4,s1,aa6 <malloc+0x70>
    if(p == freep)
 b00:	00093703          	ld	a4,0(s2)
 b04:	853e                	mv	a0,a5
 b06:	fef719e3          	bne	a4,a5,af8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 b0a:	8552                	mv	a0,s4
 b0c:	00000097          	auipc	ra,0x0
 b10:	b62080e7          	jalr	-1182(ra) # 66e <sbrk>
  if(p == (char*)-1)
 b14:	fd5518e3          	bne	a0,s5,ae4 <malloc+0xae>
        return 0;
 b18:	4501                	li	a0,0
 b1a:	bf45                	j	aca <malloc+0x94>
