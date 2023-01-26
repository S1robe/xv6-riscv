
user/_hello:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char * argv[]){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	89aa                	mv	s3,a0
  12:	892e                	mv	s2,a1
   int i=0;
  
   printf("Hello world, this is Garrett Prentice.\n\n");
  14:	00000517          	auipc	a0,0x0
  18:	7fc50513          	addi	a0,a0,2044 # 810 <malloc+0xee>
  1c:	00000097          	auipc	ra,0x0
  20:	64e080e7          	jalr	1614(ra) # 66a <printf>

   for(i=0; i<argc;i++)
  24:	03305363          	blez	s3,4a <main+0x4a>
  28:	4481                	li	s1,0
     printf("Argument %d: %s\n", i, argv[i]);
  2a:	00001a17          	auipc	s4,0x1
  2e:	816a0a13          	addi	s4,s4,-2026 # 840 <malloc+0x11e>
  32:	00093603          	ld	a2,0(s2)
  36:	85a6                	mv	a1,s1
  38:	8552                	mv	a0,s4
  3a:	00000097          	auipc	ra,0x0
  3e:	630080e7          	jalr	1584(ra) # 66a <printf>
   for(i=0; i<argc;i++)
  42:	2485                	addiw	s1,s1,1
  44:	0921                	addi	s2,s2,8
  46:	fe9996e3          	bne	s3,s1,32 <main+0x32>

   exit(0);
  4a:	4501                	li	a0,0
  4c:	00000097          	auipc	ra,0x0
  50:	28e080e7          	jalr	654(ra) # 2da <exit>

0000000000000054 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  5c:	00000097          	auipc	ra,0x0
  60:	fa4080e7          	jalr	-92(ra) # 0 <main>
  exit(0);
  64:	4501                	li	a0,0
  66:	00000097          	auipc	ra,0x0
  6a:	274080e7          	jalr	628(ra) # 2da <exit>

000000000000006e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  6e:	1141                	addi	sp,sp,-16
  70:	e422                	sd	s0,8(sp)
  72:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  74:	87aa                	mv	a5,a0
  76:	0585                	addi	a1,a1,1
  78:	0785                	addi	a5,a5,1
  7a:	fff5c703          	lbu	a4,-1(a1)
  7e:	fee78fa3          	sb	a4,-1(a5)
  82:	fb75                	bnez	a4,76 <strcpy+0x8>
    ;
  return os;
}
  84:	6422                	ld	s0,8(sp)
  86:	0141                	addi	sp,sp,16
  88:	8082                	ret

000000000000008a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	cb91                	beqz	a5,a8 <strcmp+0x1e>
  96:	0005c703          	lbu	a4,0(a1)
  9a:	00f71763          	bne	a4,a5,a8 <strcmp+0x1e>
    p++, q++;
  9e:	0505                	addi	a0,a0,1
  a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a2:	00054783          	lbu	a5,0(a0)
  a6:	fbe5                	bnez	a5,96 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  a8:	0005c503          	lbu	a0,0(a1)
}
  ac:	40a7853b          	subw	a0,a5,a0
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strlen>:

uint
strlen(const char *s)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cf91                	beqz	a5,dc <strlen+0x26>
  c2:	0505                	addi	a0,a0,1
  c4:	87aa                	mv	a5,a0
  c6:	86be                	mv	a3,a5
  c8:	0785                	addi	a5,a5,1
  ca:	fff7c703          	lbu	a4,-1(a5)
  ce:	ff65                	bnez	a4,c6 <strlen+0x10>
  d0:	40a6853b          	subw	a0,a3,a0
  d4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret
  for(n = 0; s[n]; n++)
  dc:	4501                	li	a0,0
  de:	bfe5                	j	d6 <strlen+0x20>

00000000000000e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e422                	sd	s0,8(sp)
  e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  e6:	ca19                	beqz	a2,fc <memset+0x1c>
  e8:	87aa                	mv	a5,a0
  ea:	1602                	slli	a2,a2,0x20
  ec:	9201                	srli	a2,a2,0x20
  ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f6:	0785                	addi	a5,a5,1
  f8:	fee79de3          	bne	a5,a4,f2 <memset+0x12>
  }
  return dst;
}
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <strchr>:

char*
strchr(const char *s, char c)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  for(; *s; s++)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cb99                	beqz	a5,122 <strchr+0x20>
    if(*s == c)
 10e:	00f58763          	beq	a1,a5,11c <strchr+0x1a>
  for(; *s; s++)
 112:	0505                	addi	a0,a0,1
 114:	00054783          	lbu	a5,0(a0)
 118:	fbfd                	bnez	a5,10e <strchr+0xc>
      return (char*)s;
  return 0;
 11a:	4501                	li	a0,0
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret
  return 0;
 122:	4501                	li	a0,0
 124:	bfe5                	j	11c <strchr+0x1a>

0000000000000126 <gets>:

char*
gets(char *buf, int max)
{
 126:	711d                	addi	sp,sp,-96
 128:	ec86                	sd	ra,88(sp)
 12a:	e8a2                	sd	s0,80(sp)
 12c:	e4a6                	sd	s1,72(sp)
 12e:	e0ca                	sd	s2,64(sp)
 130:	fc4e                	sd	s3,56(sp)
 132:	f852                	sd	s4,48(sp)
 134:	f456                	sd	s5,40(sp)
 136:	f05a                	sd	s6,32(sp)
 138:	ec5e                	sd	s7,24(sp)
 13a:	1080                	addi	s0,sp,96
 13c:	8baa                	mv	s7,a0
 13e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	892a                	mv	s2,a0
 142:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 144:	4aa9                	li	s5,10
 146:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 148:	89a6                	mv	s3,s1
 14a:	2485                	addiw	s1,s1,1
 14c:	0344d863          	bge	s1,s4,17c <gets+0x56>
    cc = read(0, &c, 1);
 150:	4605                	li	a2,1
 152:	faf40593          	addi	a1,s0,-81
 156:	4501                	li	a0,0
 158:	00000097          	auipc	ra,0x0
 15c:	19a080e7          	jalr	410(ra) # 2f2 <read>
    if(cc < 1)
 160:	00a05e63          	blez	a0,17c <gets+0x56>
    buf[i++] = c;
 164:	faf44783          	lbu	a5,-81(s0)
 168:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 16c:	01578763          	beq	a5,s5,17a <gets+0x54>
 170:	0905                	addi	s2,s2,1
 172:	fd679be3          	bne	a5,s6,148 <gets+0x22>
  for(i=0; i+1 < max; ){
 176:	89a6                	mv	s3,s1
 178:	a011                	j	17c <gets+0x56>
 17a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 17c:	99de                	add	s3,s3,s7
 17e:	00098023          	sb	zero,0(s3)
  return buf;
}
 182:	855e                	mv	a0,s7
 184:	60e6                	ld	ra,88(sp)
 186:	6446                	ld	s0,80(sp)
 188:	64a6                	ld	s1,72(sp)
 18a:	6906                	ld	s2,64(sp)
 18c:	79e2                	ld	s3,56(sp)
 18e:	7a42                	ld	s4,48(sp)
 190:	7aa2                	ld	s5,40(sp)
 192:	7b02                	ld	s6,32(sp)
 194:	6be2                	ld	s7,24(sp)
 196:	6125                	addi	sp,sp,96
 198:	8082                	ret

000000000000019a <stat>:

int
stat(const char *n, struct stat *st)
{
 19a:	1101                	addi	sp,sp,-32
 19c:	ec06                	sd	ra,24(sp)
 19e:	e822                	sd	s0,16(sp)
 1a0:	e426                	sd	s1,8(sp)
 1a2:	e04a                	sd	s2,0(sp)
 1a4:	1000                	addi	s0,sp,32
 1a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a8:	4581                	li	a1,0
 1aa:	00000097          	auipc	ra,0x0
 1ae:	170080e7          	jalr	368(ra) # 31a <open>
  if(fd < 0)
 1b2:	02054563          	bltz	a0,1dc <stat+0x42>
 1b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b8:	85ca                	mv	a1,s2
 1ba:	00000097          	auipc	ra,0x0
 1be:	178080e7          	jalr	376(ra) # 332 <fstat>
 1c2:	892a                	mv	s2,a0
  close(fd);
 1c4:	8526                	mv	a0,s1
 1c6:	00000097          	auipc	ra,0x0
 1ca:	13c080e7          	jalr	316(ra) # 302 <close>
  return r;
}
 1ce:	854a                	mv	a0,s2
 1d0:	60e2                	ld	ra,24(sp)
 1d2:	6442                	ld	s0,16(sp)
 1d4:	64a2                	ld	s1,8(sp)
 1d6:	6902                	ld	s2,0(sp)
 1d8:	6105                	addi	sp,sp,32
 1da:	8082                	ret
    return -1;
 1dc:	597d                	li	s2,-1
 1de:	bfc5                	j	1ce <stat+0x34>

00000000000001e0 <atoi>:

int
atoi(const char *s)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e6:	00054683          	lbu	a3,0(a0)
 1ea:	fd06879b          	addiw	a5,a3,-48
 1ee:	0ff7f793          	zext.b	a5,a5
 1f2:	4625                	li	a2,9
 1f4:	02f66863          	bltu	a2,a5,224 <atoi+0x44>
 1f8:	872a                	mv	a4,a0
  n = 0;
 1fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1fc:	0705                	addi	a4,a4,1
 1fe:	0025179b          	slliw	a5,a0,0x2
 202:	9fa9                	addw	a5,a5,a0
 204:	0017979b          	slliw	a5,a5,0x1
 208:	9fb5                	addw	a5,a5,a3
 20a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 20e:	00074683          	lbu	a3,0(a4)
 212:	fd06879b          	addiw	a5,a3,-48
 216:	0ff7f793          	zext.b	a5,a5
 21a:	fef671e3          	bgeu	a2,a5,1fc <atoi+0x1c>
  return n;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
  n = 0;
 224:	4501                	li	a0,0
 226:	bfe5                	j	21e <atoi+0x3e>

0000000000000228 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 22e:	02b57463          	bgeu	a0,a1,256 <memmove+0x2e>
    while(n-- > 0)
 232:	00c05f63          	blez	a2,250 <memmove+0x28>
 236:	1602                	slli	a2,a2,0x20
 238:	9201                	srli	a2,a2,0x20
 23a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 23e:	872a                	mv	a4,a0
      *dst++ = *src++;
 240:	0585                	addi	a1,a1,1
 242:	0705                	addi	a4,a4,1
 244:	fff5c683          	lbu	a3,-1(a1)
 248:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 24c:	fee79ae3          	bne	a5,a4,240 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 250:	6422                	ld	s0,8(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
    dst += n;
 256:	00c50733          	add	a4,a0,a2
    src += n;
 25a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 25c:	fec05ae3          	blez	a2,250 <memmove+0x28>
 260:	fff6079b          	addiw	a5,a2,-1
 264:	1782                	slli	a5,a5,0x20
 266:	9381                	srli	a5,a5,0x20
 268:	fff7c793          	not	a5,a5
 26c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 26e:	15fd                	addi	a1,a1,-1
 270:	177d                	addi	a4,a4,-1
 272:	0005c683          	lbu	a3,0(a1)
 276:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 27a:	fee79ae3          	bne	a5,a4,26e <memmove+0x46>
 27e:	bfc9                	j	250 <memmove+0x28>

0000000000000280 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 286:	ca05                	beqz	a2,2b6 <memcmp+0x36>
 288:	fff6069b          	addiw	a3,a2,-1
 28c:	1682                	slli	a3,a3,0x20
 28e:	9281                	srli	a3,a3,0x20
 290:	0685                	addi	a3,a3,1
 292:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 294:	00054783          	lbu	a5,0(a0)
 298:	0005c703          	lbu	a4,0(a1)
 29c:	00e79863          	bne	a5,a4,2ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a0:	0505                	addi	a0,a0,1
    p2++;
 2a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2a4:	fed518e3          	bne	a0,a3,294 <memcmp+0x14>
  }
  return 0;
 2a8:	4501                	li	a0,0
 2aa:	a019                	j	2b0 <memcmp+0x30>
      return *p1 - *p2;
 2ac:	40e7853b          	subw	a0,a5,a4
}
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
  return 0;
 2b6:	4501                	li	a0,0
 2b8:	bfe5                	j	2b0 <memcmp+0x30>

00000000000002ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2c2:	00000097          	auipc	ra,0x0
 2c6:	f66080e7          	jalr	-154(ra) # 228 <memmove>
}
 2ca:	60a2                	ld	ra,8(sp)
 2cc:	6402                	ld	s0,0(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d2:	4885                	li	a7,1
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <exit>:
.global exit
exit:
 li a7, SYS_exit
 2da:	4889                	li	a7,2
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e2:	488d                	li	a7,3
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ea:	4891                	li	a7,4
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <read>:
.global read
read:
 li a7, SYS_read
 2f2:	4895                	li	a7,5
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <write>:
.global write
write:
 li a7, SYS_write
 2fa:	48c1                	li	a7,16
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <close>:
.global close
close:
 li a7, SYS_close
 302:	48d5                	li	a7,21
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <kill>:
.global kill
kill:
 li a7, SYS_kill
 30a:	4899                	li	a7,6
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <exec>:
.global exec
exec:
 li a7, SYS_exec
 312:	489d                	li	a7,7
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <open>:
.global open
open:
 li a7, SYS_open
 31a:	48bd                	li	a7,15
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 322:	48c5                	li	a7,17
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 32a:	48c9                	li	a7,18
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 332:	48a1                	li	a7,8
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <link>:
.global link
link:
 li a7, SYS_link
 33a:	48cd                	li	a7,19
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 342:	48d1                	li	a7,20
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 34a:	48a5                	li	a7,9
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <dup>:
.global dup
dup:
 li a7, SYS_dup
 352:	48a9                	li	a7,10
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 35a:	48ad                	li	a7,11
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 362:	48b1                	li	a7,12
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 36a:	48b5                	li	a7,13
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 372:	48b9                	li	a7,14
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 37a:	48d9                	li	a7,22
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 382:	48dd                	li	a7,23
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 38a:	48e1                	li	a7,24
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 392:	48e5                	li	a7,25
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <time>:
.global time
time:
 li a7, SYS_time
 39a:	48e9                	li	a7,26
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a2:	1101                	addi	sp,sp,-32
 3a4:	ec06                	sd	ra,24(sp)
 3a6:	e822                	sd	s0,16(sp)
 3a8:	1000                	addi	s0,sp,32
 3aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ae:	4605                	li	a2,1
 3b0:	fef40593          	addi	a1,s0,-17
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f46080e7          	jalr	-186(ra) # 2fa <write>
}
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret

00000000000003c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c4:	7139                	addi	sp,sp,-64
 3c6:	fc06                	sd	ra,56(sp)
 3c8:	f822                	sd	s0,48(sp)
 3ca:	f426                	sd	s1,40(sp)
 3cc:	f04a                	sd	s2,32(sp)
 3ce:	ec4e                	sd	s3,24(sp)
 3d0:	0080                	addi	s0,sp,64
 3d2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d4:	c299                	beqz	a3,3da <printint+0x16>
 3d6:	0805c963          	bltz	a1,468 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3da:	2581                	sext.w	a1,a1
  neg = 0;
 3dc:	4881                	li	a7,0
 3de:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e4:	2601                	sext.w	a2,a2
 3e6:	00000517          	auipc	a0,0x0
 3ea:	4d250513          	addi	a0,a0,1234 # 8b8 <digits>
 3ee:	883a                	mv	a6,a4
 3f0:	2705                	addiw	a4,a4,1
 3f2:	02c5f7bb          	remuw	a5,a1,a2
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	97aa                	add	a5,a5,a0
 3fc:	0007c783          	lbu	a5,0(a5)
 400:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 404:	0005879b          	sext.w	a5,a1
 408:	02c5d5bb          	divuw	a1,a1,a2
 40c:	0685                	addi	a3,a3,1
 40e:	fec7f0e3          	bgeu	a5,a2,3ee <printint+0x2a>
  if(neg)
 412:	00088c63          	beqz	a7,42a <printint+0x66>
    buf[i++] = '-';
 416:	fd070793          	addi	a5,a4,-48
 41a:	00878733          	add	a4,a5,s0
 41e:	02d00793          	li	a5,45
 422:	fef70823          	sb	a5,-16(a4)
 426:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 42a:	02e05863          	blez	a4,45a <printint+0x96>
 42e:	fc040793          	addi	a5,s0,-64
 432:	00e78933          	add	s2,a5,a4
 436:	fff78993          	addi	s3,a5,-1
 43a:	99ba                	add	s3,s3,a4
 43c:	377d                	addiw	a4,a4,-1
 43e:	1702                	slli	a4,a4,0x20
 440:	9301                	srli	a4,a4,0x20
 442:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 446:	fff94583          	lbu	a1,-1(s2)
 44a:	8526                	mv	a0,s1
 44c:	00000097          	auipc	ra,0x0
 450:	f56080e7          	jalr	-170(ra) # 3a2 <putc>
  while(--i >= 0)
 454:	197d                	addi	s2,s2,-1
 456:	ff3918e3          	bne	s2,s3,446 <printint+0x82>
}
 45a:	70e2                	ld	ra,56(sp)
 45c:	7442                	ld	s0,48(sp)
 45e:	74a2                	ld	s1,40(sp)
 460:	7902                	ld	s2,32(sp)
 462:	69e2                	ld	s3,24(sp)
 464:	6121                	addi	sp,sp,64
 466:	8082                	ret
    x = -xx;
 468:	40b005bb          	negw	a1,a1
    neg = 1;
 46c:	4885                	li	a7,1
    x = -xx;
 46e:	bf85                	j	3de <printint+0x1a>

0000000000000470 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 470:	715d                	addi	sp,sp,-80
 472:	e486                	sd	ra,72(sp)
 474:	e0a2                	sd	s0,64(sp)
 476:	fc26                	sd	s1,56(sp)
 478:	f84a                	sd	s2,48(sp)
 47a:	f44e                	sd	s3,40(sp)
 47c:	f052                	sd	s4,32(sp)
 47e:	ec56                	sd	s5,24(sp)
 480:	e85a                	sd	s6,16(sp)
 482:	e45e                	sd	s7,8(sp)
 484:	e062                	sd	s8,0(sp)
 486:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 488:	0005c903          	lbu	s2,0(a1)
 48c:	18090c63          	beqz	s2,624 <vprintf+0x1b4>
 490:	8aaa                	mv	s5,a0
 492:	8bb2                	mv	s7,a2
 494:	00158493          	addi	s1,a1,1
  state = 0;
 498:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 49a:	02500a13          	li	s4,37
 49e:	4b55                	li	s6,21
 4a0:	a839                	j	4be <vprintf+0x4e>
        putc(fd, c);
 4a2:	85ca                	mv	a1,s2
 4a4:	8556                	mv	a0,s5
 4a6:	00000097          	auipc	ra,0x0
 4aa:	efc080e7          	jalr	-260(ra) # 3a2 <putc>
 4ae:	a019                	j	4b4 <vprintf+0x44>
    } else if(state == '%'){
 4b0:	01498d63          	beq	s3,s4,4ca <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4b4:	0485                	addi	s1,s1,1
 4b6:	fff4c903          	lbu	s2,-1(s1)
 4ba:	16090563          	beqz	s2,624 <vprintf+0x1b4>
    if(state == 0){
 4be:	fe0999e3          	bnez	s3,4b0 <vprintf+0x40>
      if(c == '%'){
 4c2:	ff4910e3          	bne	s2,s4,4a2 <vprintf+0x32>
        state = '%';
 4c6:	89d2                	mv	s3,s4
 4c8:	b7f5                	j	4b4 <vprintf+0x44>
      if(c == 'd'){
 4ca:	13490263          	beq	s2,s4,5ee <vprintf+0x17e>
 4ce:	f9d9079b          	addiw	a5,s2,-99
 4d2:	0ff7f793          	zext.b	a5,a5
 4d6:	12fb6563          	bltu	s6,a5,600 <vprintf+0x190>
 4da:	f9d9079b          	addiw	a5,s2,-99
 4de:	0ff7f713          	zext.b	a4,a5
 4e2:	10eb6f63          	bltu	s6,a4,600 <vprintf+0x190>
 4e6:	00271793          	slli	a5,a4,0x2
 4ea:	00000717          	auipc	a4,0x0
 4ee:	37670713          	addi	a4,a4,886 # 860 <malloc+0x13e>
 4f2:	97ba                	add	a5,a5,a4
 4f4:	439c                	lw	a5,0(a5)
 4f6:	97ba                	add	a5,a5,a4
 4f8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4fa:	008b8913          	addi	s2,s7,8
 4fe:	4685                	li	a3,1
 500:	4629                	li	a2,10
 502:	000ba583          	lw	a1,0(s7)
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	ebc080e7          	jalr	-324(ra) # 3c4 <printint>
 510:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 512:	4981                	li	s3,0
 514:	b745                	j	4b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 516:	008b8913          	addi	s2,s7,8
 51a:	4681                	li	a3,0
 51c:	4629                	li	a2,10
 51e:	000ba583          	lw	a1,0(s7)
 522:	8556                	mv	a0,s5
 524:	00000097          	auipc	ra,0x0
 528:	ea0080e7          	jalr	-352(ra) # 3c4 <printint>
 52c:	8bca                	mv	s7,s2
      state = 0;
 52e:	4981                	li	s3,0
 530:	b751                	j	4b4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 532:	008b8913          	addi	s2,s7,8
 536:	4681                	li	a3,0
 538:	4641                	li	a2,16
 53a:	000ba583          	lw	a1,0(s7)
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e84080e7          	jalr	-380(ra) # 3c4 <printint>
 548:	8bca                	mv	s7,s2
      state = 0;
 54a:	4981                	li	s3,0
 54c:	b7a5                	j	4b4 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 54e:	008b8c13          	addi	s8,s7,8
 552:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 556:	03000593          	li	a1,48
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e46080e7          	jalr	-442(ra) # 3a2 <putc>
  putc(fd, 'x');
 564:	07800593          	li	a1,120
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e38080e7          	jalr	-456(ra) # 3a2 <putc>
 572:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	00000b97          	auipc	s7,0x0
 578:	344b8b93          	addi	s7,s7,836 # 8b8 <digits>
 57c:	03c9d793          	srli	a5,s3,0x3c
 580:	97de                	add	a5,a5,s7
 582:	0007c583          	lbu	a1,0(a5)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e1a080e7          	jalr	-486(ra) # 3a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 590:	0992                	slli	s3,s3,0x4
 592:	397d                	addiw	s2,s2,-1
 594:	fe0914e3          	bnez	s2,57c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 598:	8be2                	mv	s7,s8
      state = 0;
 59a:	4981                	li	s3,0
 59c:	bf21                	j	4b4 <vprintf+0x44>
        s = va_arg(ap, char*);
 59e:	008b8993          	addi	s3,s7,8
 5a2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5a6:	02090163          	beqz	s2,5c8 <vprintf+0x158>
        while(*s != 0){
 5aa:	00094583          	lbu	a1,0(s2)
 5ae:	c9a5                	beqz	a1,61e <vprintf+0x1ae>
          putc(fd, *s);
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	df0080e7          	jalr	-528(ra) # 3a2 <putc>
          s++;
 5ba:	0905                	addi	s2,s2,1
        while(*s != 0){
 5bc:	00094583          	lbu	a1,0(s2)
 5c0:	f9e5                	bnez	a1,5b0 <vprintf+0x140>
        s = va_arg(ap, char*);
 5c2:	8bce                	mv	s7,s3
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b5fd                	j	4b4 <vprintf+0x44>
          s = "(null)";
 5c8:	00000917          	auipc	s2,0x0
 5cc:	29090913          	addi	s2,s2,656 # 858 <malloc+0x136>
        while(*s != 0){
 5d0:	02800593          	li	a1,40
 5d4:	bff1                	j	5b0 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5d6:	008b8913          	addi	s2,s7,8
 5da:	000bc583          	lbu	a1,0(s7)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	dc2080e7          	jalr	-574(ra) # 3a2 <putc>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b5e1                	j	4b4 <vprintf+0x44>
        putc(fd, c);
 5ee:	02500593          	li	a1,37
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	dae080e7          	jalr	-594(ra) # 3a2 <putc>
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bd5d                	j	4b4 <vprintf+0x44>
        putc(fd, '%');
 600:	02500593          	li	a1,37
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	d9c080e7          	jalr	-612(ra) # 3a2 <putc>
        putc(fd, c);
 60e:	85ca                	mv	a1,s2
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	d90080e7          	jalr	-624(ra) # 3a2 <putc>
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bd61                	j	4b4 <vprintf+0x44>
        s = va_arg(ap, char*);
 61e:	8bce                	mv	s7,s3
      state = 0;
 620:	4981                	li	s3,0
 622:	bd49                	j	4b4 <vprintf+0x44>
    }
  }
}
 624:	60a6                	ld	ra,72(sp)
 626:	6406                	ld	s0,64(sp)
 628:	74e2                	ld	s1,56(sp)
 62a:	7942                	ld	s2,48(sp)
 62c:	79a2                	ld	s3,40(sp)
 62e:	7a02                	ld	s4,32(sp)
 630:	6ae2                	ld	s5,24(sp)
 632:	6b42                	ld	s6,16(sp)
 634:	6ba2                	ld	s7,8(sp)
 636:	6c02                	ld	s8,0(sp)
 638:	6161                	addi	sp,sp,80
 63a:	8082                	ret

000000000000063c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 63c:	715d                	addi	sp,sp,-80
 63e:	ec06                	sd	ra,24(sp)
 640:	e822                	sd	s0,16(sp)
 642:	1000                	addi	s0,sp,32
 644:	e010                	sd	a2,0(s0)
 646:	e414                	sd	a3,8(s0)
 648:	e818                	sd	a4,16(s0)
 64a:	ec1c                	sd	a5,24(s0)
 64c:	03043023          	sd	a6,32(s0)
 650:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 654:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 658:	8622                	mv	a2,s0
 65a:	00000097          	auipc	ra,0x0
 65e:	e16080e7          	jalr	-490(ra) # 470 <vprintf>
}
 662:	60e2                	ld	ra,24(sp)
 664:	6442                	ld	s0,16(sp)
 666:	6161                	addi	sp,sp,80
 668:	8082                	ret

000000000000066a <printf>:

void
printf(const char *fmt, ...)
{
 66a:	711d                	addi	sp,sp,-96
 66c:	ec06                	sd	ra,24(sp)
 66e:	e822                	sd	s0,16(sp)
 670:	1000                	addi	s0,sp,32
 672:	e40c                	sd	a1,8(s0)
 674:	e810                	sd	a2,16(s0)
 676:	ec14                	sd	a3,24(s0)
 678:	f018                	sd	a4,32(s0)
 67a:	f41c                	sd	a5,40(s0)
 67c:	03043823          	sd	a6,48(s0)
 680:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 684:	00840613          	addi	a2,s0,8
 688:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 68c:	85aa                	mv	a1,a0
 68e:	4505                	li	a0,1
 690:	00000097          	auipc	ra,0x0
 694:	de0080e7          	jalr	-544(ra) # 470 <vprintf>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6125                	addi	sp,sp,96
 69e:	8082                	ret

00000000000006a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a0:	1141                	addi	sp,sp,-16
 6a2:	e422                	sd	s0,8(sp)
 6a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6aa:	00001797          	auipc	a5,0x1
 6ae:	9567b783          	ld	a5,-1706(a5) # 1000 <freep>
 6b2:	a02d                	j	6dc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b4:	4618                	lw	a4,8(a2)
 6b6:	9f2d                	addw	a4,a4,a1
 6b8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bc:	6398                	ld	a4,0(a5)
 6be:	6310                	ld	a2,0(a4)
 6c0:	a83d                	j	6fe <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6c2:	ff852703          	lw	a4,-8(a0)
 6c6:	9f31                	addw	a4,a4,a2
 6c8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ca:	ff053683          	ld	a3,-16(a0)
 6ce:	a091                	j	712 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	6398                	ld	a4,0(a5)
 6d2:	00e7e463          	bltu	a5,a4,6da <free+0x3a>
 6d6:	00e6ea63          	bltu	a3,a4,6ea <free+0x4a>
{
 6da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	fed7fae3          	bgeu	a5,a3,6d0 <free+0x30>
 6e0:	6398                	ld	a4,0(a5)
 6e2:	00e6e463          	bltu	a3,a4,6ea <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	fee7eae3          	bltu	a5,a4,6da <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ea:	ff852583          	lw	a1,-8(a0)
 6ee:	6390                	ld	a2,0(a5)
 6f0:	02059813          	slli	a6,a1,0x20
 6f4:	01c85713          	srli	a4,a6,0x1c
 6f8:	9736                	add	a4,a4,a3
 6fa:	fae60de3          	beq	a2,a4,6b4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6fe:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 702:	4790                	lw	a2,8(a5)
 704:	02061593          	slli	a1,a2,0x20
 708:	01c5d713          	srli	a4,a1,0x1c
 70c:	973e                	add	a4,a4,a5
 70e:	fae68ae3          	beq	a3,a4,6c2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 712:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 714:	00001717          	auipc	a4,0x1
 718:	8ef73623          	sd	a5,-1812(a4) # 1000 <freep>
}
 71c:	6422                	ld	s0,8(sp)
 71e:	0141                	addi	sp,sp,16
 720:	8082                	ret

0000000000000722 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 722:	7139                	addi	sp,sp,-64
 724:	fc06                	sd	ra,56(sp)
 726:	f822                	sd	s0,48(sp)
 728:	f426                	sd	s1,40(sp)
 72a:	f04a                	sd	s2,32(sp)
 72c:	ec4e                	sd	s3,24(sp)
 72e:	e852                	sd	s4,16(sp)
 730:	e456                	sd	s5,8(sp)
 732:	e05a                	sd	s6,0(sp)
 734:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 736:	02051493          	slli	s1,a0,0x20
 73a:	9081                	srli	s1,s1,0x20
 73c:	04bd                	addi	s1,s1,15
 73e:	8091                	srli	s1,s1,0x4
 740:	0014899b          	addiw	s3,s1,1
 744:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 746:	00001517          	auipc	a0,0x1
 74a:	8ba53503          	ld	a0,-1862(a0) # 1000 <freep>
 74e:	c515                	beqz	a0,77a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 750:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 752:	4798                	lw	a4,8(a5)
 754:	02977f63          	bgeu	a4,s1,792 <malloc+0x70>
  if(nu < 4096)
 758:	8a4e                	mv	s4,s3
 75a:	0009871b          	sext.w	a4,s3
 75e:	6685                	lui	a3,0x1
 760:	00d77363          	bgeu	a4,a3,766 <malloc+0x44>
 764:	6a05                	lui	s4,0x1
 766:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 76a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76e:	00001917          	auipc	s2,0x1
 772:	89290913          	addi	s2,s2,-1902 # 1000 <freep>
  if(p == (char*)-1)
 776:	5afd                	li	s5,-1
 778:	a895                	j	7ec <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 77a:	00001797          	auipc	a5,0x1
 77e:	89678793          	addi	a5,a5,-1898 # 1010 <base>
 782:	00001717          	auipc	a4,0x1
 786:	86f73f23          	sd	a5,-1922(a4) # 1000 <freep>
 78a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 78c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 790:	b7e1                	j	758 <malloc+0x36>
      if(p->s.size == nunits)
 792:	02e48c63          	beq	s1,a4,7ca <malloc+0xa8>
        p->s.size -= nunits;
 796:	4137073b          	subw	a4,a4,s3
 79a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 79c:	02071693          	slli	a3,a4,0x20
 7a0:	01c6d713          	srli	a4,a3,0x1c
 7a4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7aa:	00001717          	auipc	a4,0x1
 7ae:	84a73b23          	sd	a0,-1962(a4) # 1000 <freep>
      return (void*)(p + 1);
 7b2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7b6:	70e2                	ld	ra,56(sp)
 7b8:	7442                	ld	s0,48(sp)
 7ba:	74a2                	ld	s1,40(sp)
 7bc:	7902                	ld	s2,32(sp)
 7be:	69e2                	ld	s3,24(sp)
 7c0:	6a42                	ld	s4,16(sp)
 7c2:	6aa2                	ld	s5,8(sp)
 7c4:	6b02                	ld	s6,0(sp)
 7c6:	6121                	addi	sp,sp,64
 7c8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ca:	6398                	ld	a4,0(a5)
 7cc:	e118                	sd	a4,0(a0)
 7ce:	bff1                	j	7aa <malloc+0x88>
  hp->s.size = nu;
 7d0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d4:	0541                	addi	a0,a0,16
 7d6:	00000097          	auipc	ra,0x0
 7da:	eca080e7          	jalr	-310(ra) # 6a0 <free>
  return freep;
 7de:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e2:	d971                	beqz	a0,7b6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e6:	4798                	lw	a4,8(a5)
 7e8:	fa9775e3          	bgeu	a4,s1,792 <malloc+0x70>
    if(p == freep)
 7ec:	00093703          	ld	a4,0(s2)
 7f0:	853e                	mv	a0,a5
 7f2:	fef719e3          	bne	a4,a5,7e4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7f6:	8552                	mv	a0,s4
 7f8:	00000097          	auipc	ra,0x0
 7fc:	b6a080e7          	jalr	-1174(ra) # 362 <sbrk>
  if(p == (char*)-1)
 800:	fd5518e3          	bne	a0,s5,7d0 <malloc+0xae>
        return 0;
 804:	4501                	li	a0,0
 806:	bf45                	j	7b6 <malloc+0x94>
