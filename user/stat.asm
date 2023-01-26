
user/_stat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"

int main(int argc, char*argv[]){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
 
  printf("Process PID:\t%d\n", getpid());
   8:	00000097          	auipc	ra,0x0
   c:	43e080e7          	jalr	1086(ra) # 446 <getpid>
  10:	85aa                	mv	a1,a0
  12:	00001517          	auipc	a0,0x1
  16:	8ee50513          	addi	a0,a0,-1810 # 900 <malloc+0xf2>
  1a:	00000097          	auipc	ra,0x0
  1e:	73c080e7          	jalr	1852(ra) # 756 <printf>
  printf("Memory Used:\t%d\n", getmem()); 
  22:	00000097          	auipc	ra,0x0
  26:	444080e7          	jalr	1092(ra) # 466 <getmem>
  2a:	85aa                	mv	a1,a0
  2c:	00001517          	auipc	a0,0x1
  30:	8ec50513          	addi	a0,a0,-1812 # 918 <malloc+0x10a>
  34:	00000097          	auipc	ra,0x0
  38:	722080e7          	jalr	1826(ra) # 756 <printf>
  printf("Proc State:\t");
  3c:	00001517          	auipc	a0,0x1
  40:	8f450513          	addi	a0,a0,-1804 # 930 <malloc+0x122>
  44:	00000097          	auipc	ra,0x0
  48:	712080e7          	jalr	1810(ra) # 756 <printf>
  switch(getstate()){
  4c:	00000097          	auipc	ra,0x0
  50:	422080e7          	jalr	1058(ra) # 46e <getstate>
  54:	4795                	li	a5,5
  56:	0ca7ec63          	bltu	a5,a0,12e <main+0x12e>
  5a:	050a                	slli	a0,a0,0x2
  5c:	00001717          	auipc	a4,0x1
  60:	97870713          	addi	a4,a4,-1672 # 9d4 <malloc+0x1c6>
  64:	953a                	add	a0,a0,a4
  66:	411c                	lw	a5,0(a0)
  68:	97ba                	add	a5,a5,a4
  6a:	8782                	jr	a5
  case 0:  printf("UNUSED\n"); break;
  6c:	00001517          	auipc	a0,0x1
  70:	8d450513          	addi	a0,a0,-1836 # 940 <malloc+0x132>
  74:	00000097          	auipc	ra,0x0
  78:	6e2080e7          	jalr	1762(ra) # 756 <printf>
  case 4:  printf("RUNNING\n");break;
  case 5:  printf("ZOMBIE\n");break;
  default: printf("UNKNOWN\n");
  }

  printf("Uptime (ticks):\t%d\n",uptime());
  7c:	00000097          	auipc	ra,0x0
  80:	3e2080e7          	jalr	994(ra) # 45e <uptime>
  84:	85aa                	mv	a1,a0
  86:	00001517          	auipc	a0,0x1
  8a:	91250513          	addi	a0,a0,-1774 # 998 <malloc+0x18a>
  8e:	00000097          	auipc	ra,0x0
  92:	6c8080e7          	jalr	1736(ra) # 756 <printf>
  printf("Parent PID:\t%d\n", getparentpid());
  96:	00000097          	auipc	ra,0x0
  9a:	3e0080e7          	jalr	992(ra) # 476 <getparentpid>
  9e:	85aa                	mv	a1,a0
  a0:	00001517          	auipc	a0,0x1
  a4:	91050513          	addi	a0,a0,-1776 # 9b0 <malloc+0x1a2>
  a8:	00000097          	auipc	ra,0x0
  ac:	6ae080e7          	jalr	1710(ra) # 756 <printf>
  printf("Page Tble Addr:\t%p\n", getkstack());
  b0:	00000097          	auipc	ra,0x0
  b4:	3ce080e7          	jalr	974(ra) # 47e <getkstack>
  b8:	85aa                	mv	a1,a0
  ba:	00001517          	auipc	a0,0x1
  be:	90650513          	addi	a0,a0,-1786 # 9c0 <malloc+0x1b2>
  c2:	00000097          	auipc	ra,0x0
  c6:	694080e7          	jalr	1684(ra) # 756 <printf>

  return 0;

}
  ca:	4501                	li	a0,0
  cc:	60a2                	ld	ra,8(sp)
  ce:	6402                	ld	s0,0(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret
  case 1:  printf("USED\n"); break;
  d4:	00001517          	auipc	a0,0x1
  d8:	87450513          	addi	a0,a0,-1932 # 948 <malloc+0x13a>
  dc:	00000097          	auipc	ra,0x0
  e0:	67a080e7          	jalr	1658(ra) # 756 <printf>
  e4:	bf61                	j	7c <main+0x7c>
  case 2:  printf("SLEEPING\n");break;
  e6:	00001517          	auipc	a0,0x1
  ea:	86a50513          	addi	a0,a0,-1942 # 950 <malloc+0x142>
  ee:	00000097          	auipc	ra,0x0
  f2:	668080e7          	jalr	1640(ra) # 756 <printf>
  f6:	b759                	j	7c <main+0x7c>
  case 3:  printf("RUNNABLE\n");break;
  f8:	00001517          	auipc	a0,0x1
  fc:	86850513          	addi	a0,a0,-1944 # 960 <malloc+0x152>
 100:	00000097          	auipc	ra,0x0
 104:	656080e7          	jalr	1622(ra) # 756 <printf>
 108:	bf95                	j	7c <main+0x7c>
  case 4:  printf("RUNNING\n");break;
 10a:	00001517          	auipc	a0,0x1
 10e:	86650513          	addi	a0,a0,-1946 # 970 <malloc+0x162>
 112:	00000097          	auipc	ra,0x0
 116:	644080e7          	jalr	1604(ra) # 756 <printf>
 11a:	b78d                	j	7c <main+0x7c>
  case 5:  printf("ZOMBIE\n");break;
 11c:	00001517          	auipc	a0,0x1
 120:	86450513          	addi	a0,a0,-1948 # 980 <malloc+0x172>
 124:	00000097          	auipc	ra,0x0
 128:	632080e7          	jalr	1586(ra) # 756 <printf>
 12c:	bf81                	j	7c <main+0x7c>
  default: printf("UNKNOWN\n");
 12e:	00001517          	auipc	a0,0x1
 132:	85a50513          	addi	a0,a0,-1958 # 988 <malloc+0x17a>
 136:	00000097          	auipc	ra,0x0
 13a:	620080e7          	jalr	1568(ra) # 756 <printf>
 13e:	bf3d                	j	7c <main+0x7c>

0000000000000140 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 140:	1141                	addi	sp,sp,-16
 142:	e406                	sd	ra,8(sp)
 144:	e022                	sd	s0,0(sp)
 146:	0800                	addi	s0,sp,16
  extern int main();
  main();
 148:	00000097          	auipc	ra,0x0
 14c:	eb8080e7          	jalr	-328(ra) # 0 <main>
  exit(0);
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	274080e7          	jalr	628(ra) # 3c6 <exit>

000000000000015a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 160:	87aa                	mv	a5,a0
 162:	0585                	addi	a1,a1,1
 164:	0785                	addi	a5,a5,1
 166:	fff5c703          	lbu	a4,-1(a1)
 16a:	fee78fa3          	sb	a4,-1(a5)
 16e:	fb75                	bnez	a4,162 <strcpy+0x8>
    ;
  return os;
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 17c:	00054783          	lbu	a5,0(a0)
 180:	cb91                	beqz	a5,194 <strcmp+0x1e>
 182:	0005c703          	lbu	a4,0(a1)
 186:	00f71763          	bne	a4,a5,194 <strcmp+0x1e>
    p++, q++;
 18a:	0505                	addi	a0,a0,1
 18c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbe5                	bnez	a5,182 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 194:	0005c503          	lbu	a0,0(a1)
}
 198:	40a7853b          	subw	a0,a5,a0
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret

00000000000001a2 <strlen>:

uint
strlen(const char *s)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	cf91                	beqz	a5,1c8 <strlen+0x26>
 1ae:	0505                	addi	a0,a0,1
 1b0:	87aa                	mv	a5,a0
 1b2:	86be                	mv	a3,a5
 1b4:	0785                	addi	a5,a5,1
 1b6:	fff7c703          	lbu	a4,-1(a5)
 1ba:	ff65                	bnez	a4,1b2 <strlen+0x10>
 1bc:	40a6853b          	subw	a0,a3,a0
 1c0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  for(n = 0; s[n]; n++)
 1c8:	4501                	li	a0,0
 1ca:	bfe5                	j	1c2 <strlen+0x20>

00000000000001cc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d2:	ca19                	beqz	a2,1e8 <memset+0x1c>
 1d4:	87aa                	mv	a5,a0
 1d6:	1602                	slli	a2,a2,0x20
 1d8:	9201                	srli	a2,a2,0x20
 1da:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1de:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1e2:	0785                	addi	a5,a5,1
 1e4:	fee79de3          	bne	a5,a4,1de <memset+0x12>
  }
  return dst;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret

00000000000001ee <strchr>:

char*
strchr(const char *s, char c)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f4:	00054783          	lbu	a5,0(a0)
 1f8:	cb99                	beqz	a5,20e <strchr+0x20>
    if(*s == c)
 1fa:	00f58763          	beq	a1,a5,208 <strchr+0x1a>
  for(; *s; s++)
 1fe:	0505                	addi	a0,a0,1
 200:	00054783          	lbu	a5,0(a0)
 204:	fbfd                	bnez	a5,1fa <strchr+0xc>
      return (char*)s;
  return 0;
 206:	4501                	li	a0,0
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  return 0;
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <strchr+0x1a>

0000000000000212 <gets>:

char*
gets(char *buf, int max)
{
 212:	711d                	addi	sp,sp,-96
 214:	ec86                	sd	ra,88(sp)
 216:	e8a2                	sd	s0,80(sp)
 218:	e4a6                	sd	s1,72(sp)
 21a:	e0ca                	sd	s2,64(sp)
 21c:	fc4e                	sd	s3,56(sp)
 21e:	f852                	sd	s4,48(sp)
 220:	f456                	sd	s5,40(sp)
 222:	f05a                	sd	s6,32(sp)
 224:	ec5e                	sd	s7,24(sp)
 226:	1080                	addi	s0,sp,96
 228:	8baa                	mv	s7,a0
 22a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22c:	892a                	mv	s2,a0
 22e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 230:	4aa9                	li	s5,10
 232:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 234:	89a6                	mv	s3,s1
 236:	2485                	addiw	s1,s1,1
 238:	0344d863          	bge	s1,s4,268 <gets+0x56>
    cc = read(0, &c, 1);
 23c:	4605                	li	a2,1
 23e:	faf40593          	addi	a1,s0,-81
 242:	4501                	li	a0,0
 244:	00000097          	auipc	ra,0x0
 248:	19a080e7          	jalr	410(ra) # 3de <read>
    if(cc < 1)
 24c:	00a05e63          	blez	a0,268 <gets+0x56>
    buf[i++] = c;
 250:	faf44783          	lbu	a5,-81(s0)
 254:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 258:	01578763          	beq	a5,s5,266 <gets+0x54>
 25c:	0905                	addi	s2,s2,1
 25e:	fd679be3          	bne	a5,s6,234 <gets+0x22>
  for(i=0; i+1 < max; ){
 262:	89a6                	mv	s3,s1
 264:	a011                	j	268 <gets+0x56>
 266:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 268:	99de                	add	s3,s3,s7
 26a:	00098023          	sb	zero,0(s3)
  return buf;
}
 26e:	855e                	mv	a0,s7
 270:	60e6                	ld	ra,88(sp)
 272:	6446                	ld	s0,80(sp)
 274:	64a6                	ld	s1,72(sp)
 276:	6906                	ld	s2,64(sp)
 278:	79e2                	ld	s3,56(sp)
 27a:	7a42                	ld	s4,48(sp)
 27c:	7aa2                	ld	s5,40(sp)
 27e:	7b02                	ld	s6,32(sp)
 280:	6be2                	ld	s7,24(sp)
 282:	6125                	addi	sp,sp,96
 284:	8082                	ret

0000000000000286 <stat>:

int
stat(const char *n, struct stat *st)
{
 286:	1101                	addi	sp,sp,-32
 288:	ec06                	sd	ra,24(sp)
 28a:	e822                	sd	s0,16(sp)
 28c:	e426                	sd	s1,8(sp)
 28e:	e04a                	sd	s2,0(sp)
 290:	1000                	addi	s0,sp,32
 292:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 294:	4581                	li	a1,0
 296:	00000097          	auipc	ra,0x0
 29a:	170080e7          	jalr	368(ra) # 406 <open>
  if(fd < 0)
 29e:	02054563          	bltz	a0,2c8 <stat+0x42>
 2a2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a4:	85ca                	mv	a1,s2
 2a6:	00000097          	auipc	ra,0x0
 2aa:	178080e7          	jalr	376(ra) # 41e <fstat>
 2ae:	892a                	mv	s2,a0
  close(fd);
 2b0:	8526                	mv	a0,s1
 2b2:	00000097          	auipc	ra,0x0
 2b6:	13c080e7          	jalr	316(ra) # 3ee <close>
  return r;
}
 2ba:	854a                	mv	a0,s2
 2bc:	60e2                	ld	ra,24(sp)
 2be:	6442                	ld	s0,16(sp)
 2c0:	64a2                	ld	s1,8(sp)
 2c2:	6902                	ld	s2,0(sp)
 2c4:	6105                	addi	sp,sp,32
 2c6:	8082                	ret
    return -1;
 2c8:	597d                	li	s2,-1
 2ca:	bfc5                	j	2ba <stat+0x34>

00000000000002cc <atoi>:

int
atoi(const char *s)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d2:	00054683          	lbu	a3,0(a0)
 2d6:	fd06879b          	addiw	a5,a3,-48
 2da:	0ff7f793          	zext.b	a5,a5
 2de:	4625                	li	a2,9
 2e0:	02f66863          	bltu	a2,a5,310 <atoi+0x44>
 2e4:	872a                	mv	a4,a0
  n = 0;
 2e6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e8:	0705                	addi	a4,a4,1
 2ea:	0025179b          	slliw	a5,a0,0x2
 2ee:	9fa9                	addw	a5,a5,a0
 2f0:	0017979b          	slliw	a5,a5,0x1
 2f4:	9fb5                	addw	a5,a5,a3
 2f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fa:	00074683          	lbu	a3,0(a4)
 2fe:	fd06879b          	addiw	a5,a3,-48
 302:	0ff7f793          	zext.b	a5,a5
 306:	fef671e3          	bgeu	a2,a5,2e8 <atoi+0x1c>
  return n;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  n = 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <atoi+0x3e>

0000000000000314 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31a:	02b57463          	bgeu	a0,a1,342 <memmove+0x2e>
    while(n-- > 0)
 31e:	00c05f63          	blez	a2,33c <memmove+0x28>
 322:	1602                	slli	a2,a2,0x20
 324:	9201                	srli	a2,a2,0x20
 326:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32a:	872a                	mv	a4,a0
      *dst++ = *src++;
 32c:	0585                	addi	a1,a1,1
 32e:	0705                	addi	a4,a4,1
 330:	fff5c683          	lbu	a3,-1(a1)
 334:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 338:	fee79ae3          	bne	a5,a4,32c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
    dst += n;
 342:	00c50733          	add	a4,a0,a2
    src += n;
 346:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 348:	fec05ae3          	blez	a2,33c <memmove+0x28>
 34c:	fff6079b          	addiw	a5,a2,-1
 350:	1782                	slli	a5,a5,0x20
 352:	9381                	srli	a5,a5,0x20
 354:	fff7c793          	not	a5,a5
 358:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35a:	15fd                	addi	a1,a1,-1
 35c:	177d                	addi	a4,a4,-1
 35e:	0005c683          	lbu	a3,0(a1)
 362:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x46>
 36a:	bfc9                	j	33c <memmove+0x28>

000000000000036c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 372:	ca05                	beqz	a2,3a2 <memcmp+0x36>
 374:	fff6069b          	addiw	a3,a2,-1
 378:	1682                	slli	a3,a3,0x20
 37a:	9281                	srli	a3,a3,0x20
 37c:	0685                	addi	a3,a3,1
 37e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 380:	00054783          	lbu	a5,0(a0)
 384:	0005c703          	lbu	a4,0(a1)
 388:	00e79863          	bne	a5,a4,398 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38c:	0505                	addi	a0,a0,1
    p2++;
 38e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 390:	fed518e3          	bne	a0,a3,380 <memcmp+0x14>
  }
  return 0;
 394:	4501                	li	a0,0
 396:	a019                	j	39c <memcmp+0x30>
      return *p1 - *p2;
 398:	40e7853b          	subw	a0,a5,a4
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	bfe5                	j	39c <memcmp+0x30>

00000000000003a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f66080e7          	jalr	-154(ra) # 314 <memmove>
}
 3b6:	60a2                	ld	ra,8(sp)
 3b8:	6402                	ld	s0,0(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3be:	4885                	li	a7,1
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c6:	4889                	li	a7,2
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ce:	488d                	li	a7,3
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d6:	4891                	li	a7,4
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <read>:
.global read
read:
 li a7, SYS_read
 3de:	4895                	li	a7,5
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <write>:
.global write
write:
 li a7, SYS_write
 3e6:	48c1                	li	a7,16
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <close>:
.global close
close:
 li a7, SYS_close
 3ee:	48d5                	li	a7,21
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f6:	4899                	li	a7,6
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fe:	489d                	li	a7,7
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <open>:
.global open
open:
 li a7, SYS_open
 406:	48bd                	li	a7,15
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40e:	48c5                	li	a7,17
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 416:	48c9                	li	a7,18
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41e:	48a1                	li	a7,8
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <link>:
.global link
link:
 li a7, SYS_link
 426:	48cd                	li	a7,19
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42e:	48d1                	li	a7,20
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 436:	48a5                	li	a7,9
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <dup>:
.global dup
dup:
 li a7, SYS_dup
 43e:	48a9                	li	a7,10
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 446:	48ad                	li	a7,11
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44e:	48b1                	li	a7,12
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 456:	48b5                	li	a7,13
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45e:	48b9                	li	a7,14
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 466:	48d9                	li	a7,22
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 46e:	48dd                	li	a7,23
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 476:	48e1                	li	a7,24
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 47e:	48e5                	li	a7,25
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <time>:
.global time
time:
 li a7, SYS_time
 486:	48e9                	li	a7,26
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48e:	1101                	addi	sp,sp,-32
 490:	ec06                	sd	ra,24(sp)
 492:	e822                	sd	s0,16(sp)
 494:	1000                	addi	s0,sp,32
 496:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49a:	4605                	li	a2,1
 49c:	fef40593          	addi	a1,s0,-17
 4a0:	00000097          	auipc	ra,0x0
 4a4:	f46080e7          	jalr	-186(ra) # 3e6 <write>
}
 4a8:	60e2                	ld	ra,24(sp)
 4aa:	6442                	ld	s0,16(sp)
 4ac:	6105                	addi	sp,sp,32
 4ae:	8082                	ret

00000000000004b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b0:	7139                	addi	sp,sp,-64
 4b2:	fc06                	sd	ra,56(sp)
 4b4:	f822                	sd	s0,48(sp)
 4b6:	f426                	sd	s1,40(sp)
 4b8:	f04a                	sd	s2,32(sp)
 4ba:	ec4e                	sd	s3,24(sp)
 4bc:	0080                	addi	s0,sp,64
 4be:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c0:	c299                	beqz	a3,4c6 <printint+0x16>
 4c2:	0805c963          	bltz	a1,554 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c6:	2581                	sext.w	a1,a1
  neg = 0;
 4c8:	4881                	li	a7,0
 4ca:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ce:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d0:	2601                	sext.w	a2,a2
 4d2:	00000517          	auipc	a0,0x0
 4d6:	57e50513          	addi	a0,a0,1406 # a50 <digits>
 4da:	883a                	mv	a6,a4
 4dc:	2705                	addiw	a4,a4,1
 4de:	02c5f7bb          	remuw	a5,a1,a2
 4e2:	1782                	slli	a5,a5,0x20
 4e4:	9381                	srli	a5,a5,0x20
 4e6:	97aa                	add	a5,a5,a0
 4e8:	0007c783          	lbu	a5,0(a5)
 4ec:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f0:	0005879b          	sext.w	a5,a1
 4f4:	02c5d5bb          	divuw	a1,a1,a2
 4f8:	0685                	addi	a3,a3,1
 4fa:	fec7f0e3          	bgeu	a5,a2,4da <printint+0x2a>
  if(neg)
 4fe:	00088c63          	beqz	a7,516 <printint+0x66>
    buf[i++] = '-';
 502:	fd070793          	addi	a5,a4,-48
 506:	00878733          	add	a4,a5,s0
 50a:	02d00793          	li	a5,45
 50e:	fef70823          	sb	a5,-16(a4)
 512:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 516:	02e05863          	blez	a4,546 <printint+0x96>
 51a:	fc040793          	addi	a5,s0,-64
 51e:	00e78933          	add	s2,a5,a4
 522:	fff78993          	addi	s3,a5,-1
 526:	99ba                	add	s3,s3,a4
 528:	377d                	addiw	a4,a4,-1
 52a:	1702                	slli	a4,a4,0x20
 52c:	9301                	srli	a4,a4,0x20
 52e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 532:	fff94583          	lbu	a1,-1(s2)
 536:	8526                	mv	a0,s1
 538:	00000097          	auipc	ra,0x0
 53c:	f56080e7          	jalr	-170(ra) # 48e <putc>
  while(--i >= 0)
 540:	197d                	addi	s2,s2,-1
 542:	ff3918e3          	bne	s2,s3,532 <printint+0x82>
}
 546:	70e2                	ld	ra,56(sp)
 548:	7442                	ld	s0,48(sp)
 54a:	74a2                	ld	s1,40(sp)
 54c:	7902                	ld	s2,32(sp)
 54e:	69e2                	ld	s3,24(sp)
 550:	6121                	addi	sp,sp,64
 552:	8082                	ret
    x = -xx;
 554:	40b005bb          	negw	a1,a1
    neg = 1;
 558:	4885                	li	a7,1
    x = -xx;
 55a:	bf85                	j	4ca <printint+0x1a>

000000000000055c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55c:	715d                	addi	sp,sp,-80
 55e:	e486                	sd	ra,72(sp)
 560:	e0a2                	sd	s0,64(sp)
 562:	fc26                	sd	s1,56(sp)
 564:	f84a                	sd	s2,48(sp)
 566:	f44e                	sd	s3,40(sp)
 568:	f052                	sd	s4,32(sp)
 56a:	ec56                	sd	s5,24(sp)
 56c:	e85a                	sd	s6,16(sp)
 56e:	e45e                	sd	s7,8(sp)
 570:	e062                	sd	s8,0(sp)
 572:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 574:	0005c903          	lbu	s2,0(a1)
 578:	18090c63          	beqz	s2,710 <vprintf+0x1b4>
 57c:	8aaa                	mv	s5,a0
 57e:	8bb2                	mv	s7,a2
 580:	00158493          	addi	s1,a1,1
  state = 0;
 584:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 586:	02500a13          	li	s4,37
 58a:	4b55                	li	s6,21
 58c:	a839                	j	5aa <vprintf+0x4e>
        putc(fd, c);
 58e:	85ca                	mv	a1,s2
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	efc080e7          	jalr	-260(ra) # 48e <putc>
 59a:	a019                	j	5a0 <vprintf+0x44>
    } else if(state == '%'){
 59c:	01498d63          	beq	s3,s4,5b6 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5a0:	0485                	addi	s1,s1,1
 5a2:	fff4c903          	lbu	s2,-1(s1)
 5a6:	16090563          	beqz	s2,710 <vprintf+0x1b4>
    if(state == 0){
 5aa:	fe0999e3          	bnez	s3,59c <vprintf+0x40>
      if(c == '%'){
 5ae:	ff4910e3          	bne	s2,s4,58e <vprintf+0x32>
        state = '%';
 5b2:	89d2                	mv	s3,s4
 5b4:	b7f5                	j	5a0 <vprintf+0x44>
      if(c == 'd'){
 5b6:	13490263          	beq	s2,s4,6da <vprintf+0x17e>
 5ba:	f9d9079b          	addiw	a5,s2,-99
 5be:	0ff7f793          	zext.b	a5,a5
 5c2:	12fb6563          	bltu	s6,a5,6ec <vprintf+0x190>
 5c6:	f9d9079b          	addiw	a5,s2,-99
 5ca:	0ff7f713          	zext.b	a4,a5
 5ce:	10eb6f63          	bltu	s6,a4,6ec <vprintf+0x190>
 5d2:	00271793          	slli	a5,a4,0x2
 5d6:	00000717          	auipc	a4,0x0
 5da:	42270713          	addi	a4,a4,1058 # 9f8 <malloc+0x1ea>
 5de:	97ba                	add	a5,a5,a4
 5e0:	439c                	lw	a5,0(a5)
 5e2:	97ba                	add	a5,a5,a4
 5e4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4685                	li	a3,1
 5ec:	4629                	li	a2,10
 5ee:	000ba583          	lw	a1,0(s7)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	ebc080e7          	jalr	-324(ra) # 4b0 <printint>
 5fc:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b745                	j	5a0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 602:	008b8913          	addi	s2,s7,8
 606:	4681                	li	a3,0
 608:	4629                	li	a2,10
 60a:	000ba583          	lw	a1,0(s7)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	ea0080e7          	jalr	-352(ra) # 4b0 <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b751                	j	5a0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4641                	li	a2,16
 626:	000ba583          	lw	a1,0(s7)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e84080e7          	jalr	-380(ra) # 4b0 <printint>
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	b7a5                	j	5a0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 63a:	008b8c13          	addi	s8,s7,8
 63e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 642:	03000593          	li	a1,48
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e46080e7          	jalr	-442(ra) # 48e <putc>
  putc(fd, 'x');
 650:	07800593          	li	a1,120
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e38080e7          	jalr	-456(ra) # 48e <putc>
 65e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	00000b97          	auipc	s7,0x0
 664:	3f0b8b93          	addi	s7,s7,1008 # a50 <digits>
 668:	03c9d793          	srli	a5,s3,0x3c
 66c:	97de                	add	a5,a5,s7
 66e:	0007c583          	lbu	a1,0(a5)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e1a080e7          	jalr	-486(ra) # 48e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67c:	0992                	slli	s3,s3,0x4
 67e:	397d                	addiw	s2,s2,-1
 680:	fe0914e3          	bnez	s2,668 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 684:	8be2                	mv	s7,s8
      state = 0;
 686:	4981                	li	s3,0
 688:	bf21                	j	5a0 <vprintf+0x44>
        s = va_arg(ap, char*);
 68a:	008b8993          	addi	s3,s7,8
 68e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 692:	02090163          	beqz	s2,6b4 <vprintf+0x158>
        while(*s != 0){
 696:	00094583          	lbu	a1,0(s2)
 69a:	c9a5                	beqz	a1,70a <vprintf+0x1ae>
          putc(fd, *s);
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	df0080e7          	jalr	-528(ra) # 48e <putc>
          s++;
 6a6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6a8:	00094583          	lbu	a1,0(s2)
 6ac:	f9e5                	bnez	a1,69c <vprintf+0x140>
        s = va_arg(ap, char*);
 6ae:	8bce                	mv	s7,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b5fd                	j	5a0 <vprintf+0x44>
          s = "(null)";
 6b4:	00000917          	auipc	s2,0x0
 6b8:	33c90913          	addi	s2,s2,828 # 9f0 <malloc+0x1e2>
        while(*s != 0){
 6bc:	02800593          	li	a1,40
 6c0:	bff1                	j	69c <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	000bc583          	lbu	a1,0(s7)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dc2080e7          	jalr	-574(ra) # 48e <putc>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b5e1                	j	5a0 <vprintf+0x44>
        putc(fd, c);
 6da:	02500593          	li	a1,37
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	dae080e7          	jalr	-594(ra) # 48e <putc>
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bd5d                	j	5a0 <vprintf+0x44>
        putc(fd, '%');
 6ec:	02500593          	li	a1,37
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d9c080e7          	jalr	-612(ra) # 48e <putc>
        putc(fd, c);
 6fa:	85ca                	mv	a1,s2
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	d90080e7          	jalr	-624(ra) # 48e <putc>
      state = 0;
 706:	4981                	li	s3,0
 708:	bd61                	j	5a0 <vprintf+0x44>
        s = va_arg(ap, char*);
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd49                	j	5a0 <vprintf+0x44>
    }
  }
}
 710:	60a6                	ld	ra,72(sp)
 712:	6406                	ld	s0,64(sp)
 714:	74e2                	ld	s1,56(sp)
 716:	7942                	ld	s2,48(sp)
 718:	79a2                	ld	s3,40(sp)
 71a:	7a02                	ld	s4,32(sp)
 71c:	6ae2                	ld	s5,24(sp)
 71e:	6b42                	ld	s6,16(sp)
 720:	6ba2                	ld	s7,8(sp)
 722:	6c02                	ld	s8,0(sp)
 724:	6161                	addi	sp,sp,80
 726:	8082                	ret

0000000000000728 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 728:	715d                	addi	sp,sp,-80
 72a:	ec06                	sd	ra,24(sp)
 72c:	e822                	sd	s0,16(sp)
 72e:	1000                	addi	s0,sp,32
 730:	e010                	sd	a2,0(s0)
 732:	e414                	sd	a3,8(s0)
 734:	e818                	sd	a4,16(s0)
 736:	ec1c                	sd	a5,24(s0)
 738:	03043023          	sd	a6,32(s0)
 73c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 740:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 744:	8622                	mv	a2,s0
 746:	00000097          	auipc	ra,0x0
 74a:	e16080e7          	jalr	-490(ra) # 55c <vprintf>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6161                	addi	sp,sp,80
 754:	8082                	ret

0000000000000756 <printf>:

void
printf(const char *fmt, ...)
{
 756:	711d                	addi	sp,sp,-96
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e40c                	sd	a1,8(s0)
 760:	e810                	sd	a2,16(s0)
 762:	ec14                	sd	a3,24(s0)
 764:	f018                	sd	a4,32(s0)
 766:	f41c                	sd	a5,40(s0)
 768:	03043823          	sd	a6,48(s0)
 76c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	00840613          	addi	a2,s0,8
 774:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 778:	85aa                	mv	a1,a0
 77a:	4505                	li	a0,1
 77c:	00000097          	auipc	ra,0x0
 780:	de0080e7          	jalr	-544(ra) # 55c <vprintf>
}
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6125                	addi	sp,sp,96
 78a:	8082                	ret

000000000000078c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78c:	1141                	addi	sp,sp,-16
 78e:	e422                	sd	s0,8(sp)
 790:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 792:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 796:	00001797          	auipc	a5,0x1
 79a:	86a7b783          	ld	a5,-1942(a5) # 1000 <freep>
 79e:	a02d                	j	7c8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a0:	4618                	lw	a4,8(a2)
 7a2:	9f2d                	addw	a4,a4,a1
 7a4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a8:	6398                	ld	a4,0(a5)
 7aa:	6310                	ld	a2,0(a4)
 7ac:	a83d                	j	7ea <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ae:	ff852703          	lw	a4,-8(a0)
 7b2:	9f31                	addw	a4,a4,a2
 7b4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b6:	ff053683          	ld	a3,-16(a0)
 7ba:	a091                	j	7fe <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e7e463          	bltu	a5,a4,7c6 <free+0x3a>
 7c2:	00e6ea63          	bltu	a3,a4,7d6 <free+0x4a>
{
 7c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	fed7fae3          	bgeu	a5,a3,7bc <free+0x30>
 7cc:	6398                	ld	a4,0(a5)
 7ce:	00e6e463          	bltu	a3,a4,7d6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	fee7eae3          	bltu	a5,a4,7c6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d6:	ff852583          	lw	a1,-8(a0)
 7da:	6390                	ld	a2,0(a5)
 7dc:	02059813          	slli	a6,a1,0x20
 7e0:	01c85713          	srli	a4,a6,0x1c
 7e4:	9736                	add	a4,a4,a3
 7e6:	fae60de3          	beq	a2,a4,7a0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ee:	4790                	lw	a2,8(a5)
 7f0:	02061593          	slli	a1,a2,0x20
 7f4:	01c5d713          	srli	a4,a1,0x1c
 7f8:	973e                	add	a4,a4,a5
 7fa:	fae68ae3          	beq	a3,a4,7ae <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 800:	00001717          	auipc	a4,0x1
 804:	80f73023          	sd	a5,-2048(a4) # 1000 <freep>
}
 808:	6422                	ld	s0,8(sp)
 80a:	0141                	addi	sp,sp,16
 80c:	8082                	ret

000000000000080e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80e:	7139                	addi	sp,sp,-64
 810:	fc06                	sd	ra,56(sp)
 812:	f822                	sd	s0,48(sp)
 814:	f426                	sd	s1,40(sp)
 816:	f04a                	sd	s2,32(sp)
 818:	ec4e                	sd	s3,24(sp)
 81a:	e852                	sd	s4,16(sp)
 81c:	e456                	sd	s5,8(sp)
 81e:	e05a                	sd	s6,0(sp)
 820:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 822:	02051493          	slli	s1,a0,0x20
 826:	9081                	srli	s1,s1,0x20
 828:	04bd                	addi	s1,s1,15
 82a:	8091                	srli	s1,s1,0x4
 82c:	0014899b          	addiw	s3,s1,1
 830:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 832:	00000517          	auipc	a0,0x0
 836:	7ce53503          	ld	a0,1998(a0) # 1000 <freep>
 83a:	c515                	beqz	a0,866 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	02977f63          	bgeu	a4,s1,87e <malloc+0x70>
  if(nu < 4096)
 844:	8a4e                	mv	s4,s3
 846:	0009871b          	sext.w	a4,s3
 84a:	6685                	lui	a3,0x1
 84c:	00d77363          	bgeu	a4,a3,852 <malloc+0x44>
 850:	6a05                	lui	s4,0x1
 852:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 856:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85a:	00000917          	auipc	s2,0x0
 85e:	7a690913          	addi	s2,s2,1958 # 1000 <freep>
  if(p == (char*)-1)
 862:	5afd                	li	s5,-1
 864:	a895                	j	8d8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 866:	00000797          	auipc	a5,0x0
 86a:	7aa78793          	addi	a5,a5,1962 # 1010 <base>
 86e:	00000717          	auipc	a4,0x0
 872:	78f73923          	sd	a5,1938(a4) # 1000 <freep>
 876:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 878:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87c:	b7e1                	j	844 <malloc+0x36>
      if(p->s.size == nunits)
 87e:	02e48c63          	beq	s1,a4,8b6 <malloc+0xa8>
        p->s.size -= nunits;
 882:	4137073b          	subw	a4,a4,s3
 886:	c798                	sw	a4,8(a5)
        p += p->s.size;
 888:	02071693          	slli	a3,a4,0x20
 88c:	01c6d713          	srli	a4,a3,0x1c
 890:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 892:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 896:	00000717          	auipc	a4,0x0
 89a:	76a73523          	sd	a0,1898(a4) # 1000 <freep>
      return (void*)(p + 1);
 89e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a2:	70e2                	ld	ra,56(sp)
 8a4:	7442                	ld	s0,48(sp)
 8a6:	74a2                	ld	s1,40(sp)
 8a8:	7902                	ld	s2,32(sp)
 8aa:	69e2                	ld	s3,24(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
 8b2:	6121                	addi	sp,sp,64
 8b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b6:	6398                	ld	a4,0(a5)
 8b8:	e118                	sd	a4,0(a0)
 8ba:	bff1                	j	896 <malloc+0x88>
  hp->s.size = nu;
 8bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c0:	0541                	addi	a0,a0,16
 8c2:	00000097          	auipc	ra,0x0
 8c6:	eca080e7          	jalr	-310(ra) # 78c <free>
  return freep;
 8ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ce:	d971                	beqz	a0,8a2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	fa9775e3          	bgeu	a4,s1,87e <malloc+0x70>
    if(p == freep)
 8d8:	00093703          	ld	a4,0(s2)
 8dc:	853e                	mv	a0,a5
 8de:	fef719e3          	bne	a4,a5,8d0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8e2:	8552                	mv	a0,s4
 8e4:	00000097          	auipc	ra,0x0
 8e8:	b6a080e7          	jalr	-1174(ra) # 44e <sbrk>
  if(p == (char*)-1)
 8ec:	fd5518e3          	bne	a0,s5,8bc <malloc+0xae>
        return 0;
 8f0:	4501                	li	a0,0
 8f2:	bf45                	j	8a2 <malloc+0x94>
