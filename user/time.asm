
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/types.h"

int
main(int argc, char * argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32

  if(argc < 2){
   a:	4785                	li	a5,1
   c:	06a7d863          	bge	a5,a0,7c <main+0x7c>
    printf("Usage: time <program to time>\n");
    return 1;
  }

  char * args[ ((sizeof(argv) - 1) / sizeof(char*) ) ];
  char * program = argv[1];
  10:	6584                	ld	s1,8(a1)

  int i = 1;
  for(; i < argc; i++){
  12:	05a1                	addi	a1,a1,8
  14:	fe040793          	addi	a5,s0,-32
  18:	ffe5069b          	addiw	a3,a0,-2
  1c:	02069713          	slli	a4,a3,0x20
  20:	01d75693          	srli	a3,a4,0x1d
  24:	fe840713          	addi	a4,s0,-24
  28:	96ba                	add	a3,a3,a4
     args[i-1] = argv[i];                   // collect remaining argv[]
  2a:	6198                	ld	a4,0(a1)
  2c:	e398                	sd	a4,0(a5)
  for(; i < argc; i++){
  2e:	05a1                	addi	a1,a1,8
  30:	07a1                	addi	a5,a5,8
  32:	fed79ce3          	bne	a5,a3,2a <main+0x2a>
  }
  args[i] = 0;
  36:	050e                	slli	a0,a0,0x3
  38:	fe050793          	addi	a5,a0,-32
  3c:	00878533          	add	a0,a5,s0
  40:	00053023          	sd	zero,0(a0)

  int status = time(program, args);
  44:	fe040593          	addi	a1,s0,-32
  48:	8526                	mv	a0,s1
  4a:	00000097          	auipc	ra,0x0
  4e:	3b6080e7          	jalr	950(ra) # 400 <time>
  52:	85aa                	mv	a1,a0

  if(status == -1){
  54:	57fd                	li	a5,-1
  56:	02f50d63          	beq	a0,a5,90 <main+0x90>
    printf("Fork Failed!\n");
    
  }
  else if(status == -2){
  5a:	57f9                	li	a5,-2
  5c:	04f50463          	beq	a0,a5,a4 <main+0xa4>
    printf("Exec Failed! %s\n", program);
    return 1;
  } else {
    printf("Real-Time in ticks: %d\n", status);
  60:	00001517          	auipc	a0,0x1
  64:	85850513          	addi	a0,a0,-1960 # 8b8 <malloc+0x130>
  68:	00000097          	auipc	ra,0x0
  6c:	668080e7          	jalr	1640(ra) # 6d0 <printf>
  }
  return 0;
  70:	4501                	li	a0,0

}
  72:	60e2                	ld	ra,24(sp)
  74:	6442                	ld	s0,16(sp)
  76:	64a2                	ld	s1,8(sp)
  78:	6105                	addi	sp,sp,32
  7a:	8082                	ret
    printf("Usage: time <program to time>\n");
  7c:	00000517          	auipc	a0,0x0
  80:	7f450513          	addi	a0,a0,2036 # 870 <malloc+0xe8>
  84:	00000097          	auipc	ra,0x0
  88:	64c080e7          	jalr	1612(ra) # 6d0 <printf>
    return 1;
  8c:	4505                	li	a0,1
  8e:	b7d5                	j	72 <main+0x72>
    printf("Fork Failed!\n");
  90:	00001517          	auipc	a0,0x1
  94:	80050513          	addi	a0,a0,-2048 # 890 <malloc+0x108>
  98:	00000097          	auipc	ra,0x0
  9c:	638080e7          	jalr	1592(ra) # 6d0 <printf>
  return 0;
  a0:	4501                	li	a0,0
  a2:	bfc1                	j	72 <main+0x72>
    printf("Exec Failed! %s\n", program);
  a4:	85a6                	mv	a1,s1
  a6:	00000517          	auipc	a0,0x0
  aa:	7fa50513          	addi	a0,a0,2042 # 8a0 <malloc+0x118>
  ae:	00000097          	auipc	ra,0x0
  b2:	622080e7          	jalr	1570(ra) # 6d0 <printf>
    return 1;
  b6:	4505                	li	a0,1
  b8:	bf6d                	j	72 <main+0x72>

00000000000000ba <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e406                	sd	ra,8(sp)
  be:	e022                	sd	s0,0(sp)
  c0:	0800                	addi	s0,sp,16
  extern int main();
  main();
  c2:	00000097          	auipc	ra,0x0
  c6:	f3e080e7          	jalr	-194(ra) # 0 <main>
  exit(0);
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	274080e7          	jalr	628(ra) # 340 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d863          	bge	s1,s4,1e2 <gets+0x56>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	19a080e7          	jalr	410(ra) # 358 <read>
    if(cc < 1)
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x56>
    buf[i++] = c;
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x54>
 1d6:	0905                	addi	s2,s2,1
 1d8:	fd679be3          	bne	a5,s6,1ae <gets+0x22>
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x56>
 1e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	addi	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:

int
stat(const char *n, struct stat *st)
{
 200:	1101                	addi	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	addi	s0,sp,32
 20c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	4581                	li	a1,0
 210:	00000097          	auipc	ra,0x0
 214:	170080e7          	jalr	368(ra) # 380 <open>
  if(fd < 0)
 218:	02054563          	bltz	a0,242 <stat+0x42>
 21c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21e:	85ca                	mv	a1,s2
 220:	00000097          	auipc	ra,0x0
 224:	178080e7          	jalr	376(ra) # 398 <fstat>
 228:	892a                	mv	s2,a0
  close(fd);
 22a:	8526                	mv	a0,s1
 22c:	00000097          	auipc	ra,0x0
 230:	13c080e7          	jalr	316(ra) # 368 <close>
  return r;
}
 234:	854a                	mv	a0,s2
 236:	60e2                	ld	ra,24(sp)
 238:	6442                	ld	s0,16(sp)
 23a:	64a2                	ld	s1,8(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	addi	sp,sp,32
 240:	8082                	ret
    return -1;
 242:	597d                	li	s2,-1
 244:	bfc5                	j	234 <stat+0x34>

0000000000000246 <atoi>:

int
atoi(const char *s)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24c:	00054683          	lbu	a3,0(a0)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	4625                	li	a2,9
 25a:	02f66863          	bltu	a2,a5,28a <atoi+0x44>
 25e:	872a                	mv	a4,a0
  n = 0;
 260:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 262:	0705                	addi	a4,a4,1
 264:	0025179b          	slliw	a5,a0,0x2
 268:	9fa9                	addw	a5,a5,a0
 26a:	0017979b          	slliw	a5,a5,0x1
 26e:	9fb5                	addw	a5,a5,a3
 270:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 274:	00074683          	lbu	a3,0(a4)
 278:	fd06879b          	addiw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	fef671e3          	bgeu	a2,a5,262 <atoi+0x1c>
  return n;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <atoi+0x3e>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57463          	bgeu	a0,a1,2bc <memmove+0x2e>
    while(n-- > 0)
 298:	00c05f63          	blez	a2,2b6 <memmove+0x28>
 29c:	1602                	slli	a2,a2,0x20
 29e:	9201                	srli	a2,a2,0x20
 2a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a6:	0585                	addi	a1,a1,1
 2a8:	0705                	addi	a4,a4,1
 2aa:	fff5c683          	lbu	a3,-1(a1)
 2ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
    dst += n;
 2bc:	00c50733          	add	a4,a0,a2
    src += n;
 2c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c2:	fec05ae3          	blez	a2,2b6 <memmove+0x28>
 2c6:	fff6079b          	addiw	a5,a2,-1
 2ca:	1782                	slli	a5,a5,0x20
 2cc:	9381                	srli	a5,a5,0x20
 2ce:	fff7c793          	not	a5,a5
 2d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d4:	15fd                	addi	a1,a1,-1
 2d6:	177d                	addi	a4,a4,-1
 2d8:	0005c683          	lbu	a3,0(a1)
 2dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x46>
 2e4:	bfc9                	j	2b6 <memmove+0x28>

00000000000002e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ec:	ca05                	beqz	a2,31c <memcmp+0x36>
 2ee:	fff6069b          	addiw	a3,a2,-1
 2f2:	1682                	slli	a3,a3,0x20
 2f4:	9281                	srli	a3,a3,0x20
 2f6:	0685                	addi	a3,a3,1
 2f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00e79863          	bne	a5,a4,312 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 306:	0505                	addi	a0,a0,1
    p2++;
 308:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30a:	fed518e3          	bne	a0,a3,2fa <memcmp+0x14>
  }
  return 0;
 30e:	4501                	li	a0,0
 310:	a019                	j	316 <memcmp+0x30>
      return *p1 - *p2;
 312:	40e7853b          	subw	a0,a5,a4
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  return 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <memcmp+0x30>

0000000000000320 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 328:	00000097          	auipc	ra,0x0
 32c:	f66080e7          	jalr	-154(ra) # 28e <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 3e8:	48dd                	li	a7,23
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 3f0:	48e1                	li	a7,24
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 3f8:	48e5                	li	a7,25
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <time>:
.global time
time:
 li a7, SYS_time
 400:	48e9                	li	a7,26
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	addi	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	addi	a1,s0,-17
 41a:	00000097          	auipc	ra,0x0
 41e:	f46080e7          	jalr	-186(ra) # 360 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	7139                	addi	sp,sp,-64
 42c:	fc06                	sd	ra,56(sp)
 42e:	f822                	sd	s0,48(sp)
 430:	f426                	sd	s1,40(sp)
 432:	f04a                	sd	s2,32(sp)
 434:	ec4e                	sd	s3,24(sp)
 436:	0080                	addi	s0,sp,64
 438:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x16>
 43c:	0805c963          	bltz	a1,4ce <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 440:	2581                	sext.w	a1,a1
  neg = 0;
 442:	4881                	li	a7,0
 444:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 448:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44a:	2601                	sext.w	a2,a2
 44c:	00000517          	auipc	a0,0x0
 450:	4e450513          	addi	a0,a0,1252 # 930 <digits>
 454:	883a                	mv	a6,a4
 456:	2705                	addiw	a4,a4,1
 458:	02c5f7bb          	remuw	a5,a1,a2
 45c:	1782                	slli	a5,a5,0x20
 45e:	9381                	srli	a5,a5,0x20
 460:	97aa                	add	a5,a5,a0
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	0005879b          	sext.w	a5,a1
 46e:	02c5d5bb          	divuw	a1,a1,a2
 472:	0685                	addi	a3,a3,1
 474:	fec7f0e3          	bgeu	a5,a2,454 <printint+0x2a>
  if(neg)
 478:	00088c63          	beqz	a7,490 <printint+0x66>
    buf[i++] = '-';
 47c:	fd070793          	addi	a5,a4,-48
 480:	00878733          	add	a4,a5,s0
 484:	02d00793          	li	a5,45
 488:	fef70823          	sb	a5,-16(a4)
 48c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 490:	02e05863          	blez	a4,4c0 <printint+0x96>
 494:	fc040793          	addi	a5,s0,-64
 498:	00e78933          	add	s2,a5,a4
 49c:	fff78993          	addi	s3,a5,-1
 4a0:	99ba                	add	s3,s3,a4
 4a2:	377d                	addiw	a4,a4,-1
 4a4:	1702                	slli	a4,a4,0x20
 4a6:	9301                	srli	a4,a4,0x20
 4a8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ac:	fff94583          	lbu	a1,-1(s2)
 4b0:	8526                	mv	a0,s1
 4b2:	00000097          	auipc	ra,0x0
 4b6:	f56080e7          	jalr	-170(ra) # 408 <putc>
  while(--i >= 0)
 4ba:	197d                	addi	s2,s2,-1
 4bc:	ff3918e3          	bne	s2,s3,4ac <printint+0x82>
}
 4c0:	70e2                	ld	ra,56(sp)
 4c2:	7442                	ld	s0,48(sp)
 4c4:	74a2                	ld	s1,40(sp)
 4c6:	7902                	ld	s2,32(sp)
 4c8:	69e2                	ld	s3,24(sp)
 4ca:	6121                	addi	sp,sp,64
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005bb          	negw	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	bf85                	j	444 <printint+0x1a>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	715d                	addi	sp,sp,-80
 4d8:	e486                	sd	ra,72(sp)
 4da:	e0a2                	sd	s0,64(sp)
 4dc:	fc26                	sd	s1,56(sp)
 4de:	f84a                	sd	s2,48(sp)
 4e0:	f44e                	sd	s3,40(sp)
 4e2:	f052                	sd	s4,32(sp)
 4e4:	ec56                	sd	s5,24(sp)
 4e6:	e85a                	sd	s6,16(sp)
 4e8:	e45e                	sd	s7,8(sp)
 4ea:	e062                	sd	s8,0(sp)
 4ec:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ee:	0005c903          	lbu	s2,0(a1)
 4f2:	18090c63          	beqz	s2,68a <vprintf+0x1b4>
 4f6:	8aaa                	mv	s5,a0
 4f8:	8bb2                	mv	s7,a2
 4fa:	00158493          	addi	s1,a1,1
  state = 0;
 4fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 500:	02500a13          	li	s4,37
 504:	4b55                	li	s6,21
 506:	a839                	j	524 <vprintf+0x4e>
        putc(fd, c);
 508:	85ca                	mv	a1,s2
 50a:	8556                	mv	a0,s5
 50c:	00000097          	auipc	ra,0x0
 510:	efc080e7          	jalr	-260(ra) # 408 <putc>
 514:	a019                	j	51a <vprintf+0x44>
    } else if(state == '%'){
 516:	01498d63          	beq	s3,s4,530 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 51a:	0485                	addi	s1,s1,1
 51c:	fff4c903          	lbu	s2,-1(s1)
 520:	16090563          	beqz	s2,68a <vprintf+0x1b4>
    if(state == 0){
 524:	fe0999e3          	bnez	s3,516 <vprintf+0x40>
      if(c == '%'){
 528:	ff4910e3          	bne	s2,s4,508 <vprintf+0x32>
        state = '%';
 52c:	89d2                	mv	s3,s4
 52e:	b7f5                	j	51a <vprintf+0x44>
      if(c == 'd'){
 530:	13490263          	beq	s2,s4,654 <vprintf+0x17e>
 534:	f9d9079b          	addiw	a5,s2,-99
 538:	0ff7f793          	zext.b	a5,a5
 53c:	12fb6563          	bltu	s6,a5,666 <vprintf+0x190>
 540:	f9d9079b          	addiw	a5,s2,-99
 544:	0ff7f713          	zext.b	a4,a5
 548:	10eb6f63          	bltu	s6,a4,666 <vprintf+0x190>
 54c:	00271793          	slli	a5,a4,0x2
 550:	00000717          	auipc	a4,0x0
 554:	38870713          	addi	a4,a4,904 # 8d8 <malloc+0x150>
 558:	97ba                	add	a5,a5,a4
 55a:	439c                	lw	a5,0(a5)
 55c:	97ba                	add	a5,a5,a4
 55e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 560:	008b8913          	addi	s2,s7,8
 564:	4685                	li	a3,1
 566:	4629                	li	a2,10
 568:	000ba583          	lw	a1,0(s7)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	ebc080e7          	jalr	-324(ra) # 42a <printint>
 576:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 578:	4981                	li	s3,0
 57a:	b745                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57c:	008b8913          	addi	s2,s7,8
 580:	4681                	li	a3,0
 582:	4629                	li	a2,10
 584:	000ba583          	lw	a1,0(s7)
 588:	8556                	mv	a0,s5
 58a:	00000097          	auipc	ra,0x0
 58e:	ea0080e7          	jalr	-352(ra) # 42a <printint>
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
 596:	b751                	j	51a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 598:	008b8913          	addi	s2,s7,8
 59c:	4681                	li	a3,0
 59e:	4641                	li	a2,16
 5a0:	000ba583          	lw	a1,0(s7)
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	e84080e7          	jalr	-380(ra) # 42a <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b7a5                	j	51a <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5b4:	008b8c13          	addi	s8,s7,8
 5b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5bc:	03000593          	li	a1,48
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e46080e7          	jalr	-442(ra) # 408 <putc>
  putc(fd, 'x');
 5ca:	07800593          	li	a1,120
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e38080e7          	jalr	-456(ra) # 408 <putc>
 5d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5da:	00000b97          	auipc	s7,0x0
 5de:	356b8b93          	addi	s7,s7,854 # 930 <digits>
 5e2:	03c9d793          	srli	a5,s3,0x3c
 5e6:	97de                	add	a5,a5,s7
 5e8:	0007c583          	lbu	a1,0(a5)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e1a080e7          	jalr	-486(ra) # 408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f6:	0992                	slli	s3,s3,0x4
 5f8:	397d                	addiw	s2,s2,-1
 5fa:	fe0914e3          	bnez	s2,5e2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fe:	8be2                	mv	s7,s8
      state = 0;
 600:	4981                	li	s3,0
 602:	bf21                	j	51a <vprintf+0x44>
        s = va_arg(ap, char*);
 604:	008b8993          	addi	s3,s7,8
 608:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60c:	02090163          	beqz	s2,62e <vprintf+0x158>
        while(*s != 0){
 610:	00094583          	lbu	a1,0(s2)
 614:	c9a5                	beqz	a1,684 <vprintf+0x1ae>
          putc(fd, *s);
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	df0080e7          	jalr	-528(ra) # 408 <putc>
          s++;
 620:	0905                	addi	s2,s2,1
        while(*s != 0){
 622:	00094583          	lbu	a1,0(s2)
 626:	f9e5                	bnez	a1,616 <vprintf+0x140>
        s = va_arg(ap, char*);
 628:	8bce                	mv	s7,s3
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b5fd                	j	51a <vprintf+0x44>
          s = "(null)";
 62e:	00000917          	auipc	s2,0x0
 632:	2a290913          	addi	s2,s2,674 # 8d0 <malloc+0x148>
        while(*s != 0){
 636:	02800593          	li	a1,40
 63a:	bff1                	j	616 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 63c:	008b8913          	addi	s2,s7,8
 640:	000bc583          	lbu	a1,0(s7)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	dc2080e7          	jalr	-574(ra) # 408 <putc>
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	b5e1                	j	51a <vprintf+0x44>
        putc(fd, c);
 654:	02500593          	li	a1,37
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	dae080e7          	jalr	-594(ra) # 408 <putc>
      state = 0;
 662:	4981                	li	s3,0
 664:	bd5d                	j	51a <vprintf+0x44>
        putc(fd, '%');
 666:	02500593          	li	a1,37
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	d9c080e7          	jalr	-612(ra) # 408 <putc>
        putc(fd, c);
 674:	85ca                	mv	a1,s2
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	d90080e7          	jalr	-624(ra) # 408 <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	bd61                	j	51a <vprintf+0x44>
        s = va_arg(ap, char*);
 684:	8bce                	mv	s7,s3
      state = 0;
 686:	4981                	li	s3,0
 688:	bd49                	j	51a <vprintf+0x44>
    }
  }
}
 68a:	60a6                	ld	ra,72(sp)
 68c:	6406                	ld	s0,64(sp)
 68e:	74e2                	ld	s1,56(sp)
 690:	7942                	ld	s2,48(sp)
 692:	79a2                	ld	s3,40(sp)
 694:	7a02                	ld	s4,32(sp)
 696:	6ae2                	ld	s5,24(sp)
 698:	6b42                	ld	s6,16(sp)
 69a:	6ba2                	ld	s7,8(sp)
 69c:	6c02                	ld	s8,0(sp)
 69e:	6161                	addi	sp,sp,80
 6a0:	8082                	ret

00000000000006a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a2:	715d                	addi	sp,sp,-80
 6a4:	ec06                	sd	ra,24(sp)
 6a6:	e822                	sd	s0,16(sp)
 6a8:	1000                	addi	s0,sp,32
 6aa:	e010                	sd	a2,0(s0)
 6ac:	e414                	sd	a3,8(s0)
 6ae:	e818                	sd	a4,16(s0)
 6b0:	ec1c                	sd	a5,24(s0)
 6b2:	03043023          	sd	a6,32(s0)
 6b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6be:	8622                	mv	a2,s0
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e16080e7          	jalr	-490(ra) # 4d6 <vprintf>
}
 6c8:	60e2                	ld	ra,24(sp)
 6ca:	6442                	ld	s0,16(sp)
 6cc:	6161                	addi	sp,sp,80
 6ce:	8082                	ret

00000000000006d0 <printf>:

void
printf(const char *fmt, ...)
{
 6d0:	711d                	addi	sp,sp,-96
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e40c                	sd	a1,8(s0)
 6da:	e810                	sd	a2,16(s0)
 6dc:	ec14                	sd	a3,24(s0)
 6de:	f018                	sd	a4,32(s0)
 6e0:	f41c                	sd	a5,40(s0)
 6e2:	03043823          	sd	a6,48(s0)
 6e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ea:	00840613          	addi	a2,s0,8
 6ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f2:	85aa                	mv	a1,a0
 6f4:	4505                	li	a0,1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	de0080e7          	jalr	-544(ra) # 4d6 <vprintf>
}
 6fe:	60e2                	ld	ra,24(sp)
 700:	6442                	ld	s0,16(sp)
 702:	6125                	addi	sp,sp,96
 704:	8082                	ret

0000000000000706 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 706:	1141                	addi	sp,sp,-16
 708:	e422                	sd	s0,8(sp)
 70a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	00001797          	auipc	a5,0x1
 714:	8f07b783          	ld	a5,-1808(a5) # 1000 <freep>
 718:	a02d                	j	742 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71a:	4618                	lw	a4,8(a2)
 71c:	9f2d                	addw	a4,a4,a1
 71e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 722:	6398                	ld	a4,0(a5)
 724:	6310                	ld	a2,0(a4)
 726:	a83d                	j	764 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 728:	ff852703          	lw	a4,-8(a0)
 72c:	9f31                	addw	a4,a4,a2
 72e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 730:	ff053683          	ld	a3,-16(a0)
 734:	a091                	j	778 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	6398                	ld	a4,0(a5)
 738:	00e7e463          	bltu	a5,a4,740 <free+0x3a>
 73c:	00e6ea63          	bltu	a3,a4,750 <free+0x4a>
{
 740:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	fed7fae3          	bgeu	a5,a3,736 <free+0x30>
 746:	6398                	ld	a4,0(a5)
 748:	00e6e463          	bltu	a3,a4,750 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	fee7eae3          	bltu	a5,a4,740 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 750:	ff852583          	lw	a1,-8(a0)
 754:	6390                	ld	a2,0(a5)
 756:	02059813          	slli	a6,a1,0x20
 75a:	01c85713          	srli	a4,a6,0x1c
 75e:	9736                	add	a4,a4,a3
 760:	fae60de3          	beq	a2,a4,71a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 764:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 768:	4790                	lw	a2,8(a5)
 76a:	02061593          	slli	a1,a2,0x20
 76e:	01c5d713          	srli	a4,a1,0x1c
 772:	973e                	add	a4,a4,a5
 774:	fae68ae3          	beq	a3,a4,728 <free+0x22>
    p->s.ptr = bp->s.ptr;
 778:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77a:	00001717          	auipc	a4,0x1
 77e:	88f73323          	sd	a5,-1914(a4) # 1000 <freep>
}
 782:	6422                	ld	s0,8(sp)
 784:	0141                	addi	sp,sp,16
 786:	8082                	ret

0000000000000788 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 788:	7139                	addi	sp,sp,-64
 78a:	fc06                	sd	ra,56(sp)
 78c:	f822                	sd	s0,48(sp)
 78e:	f426                	sd	s1,40(sp)
 790:	f04a                	sd	s2,32(sp)
 792:	ec4e                	sd	s3,24(sp)
 794:	e852                	sd	s4,16(sp)
 796:	e456                	sd	s5,8(sp)
 798:	e05a                	sd	s6,0(sp)
 79a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79c:	02051493          	slli	s1,a0,0x20
 7a0:	9081                	srli	s1,s1,0x20
 7a2:	04bd                	addi	s1,s1,15
 7a4:	8091                	srli	s1,s1,0x4
 7a6:	0014899b          	addiw	s3,s1,1
 7aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ac:	00001517          	auipc	a0,0x1
 7b0:	85453503          	ld	a0,-1964(a0) # 1000 <freep>
 7b4:	c515                	beqz	a0,7e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b8:	4798                	lw	a4,8(a5)
 7ba:	02977f63          	bgeu	a4,s1,7f8 <malloc+0x70>
  if(nu < 4096)
 7be:	8a4e                	mv	s4,s3
 7c0:	0009871b          	sext.w	a4,s3
 7c4:	6685                	lui	a3,0x1
 7c6:	00d77363          	bgeu	a4,a3,7cc <malloc+0x44>
 7ca:	6a05                	lui	s4,0x1
 7cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d4:	00001917          	auipc	s2,0x1
 7d8:	82c90913          	addi	s2,s2,-2004 # 1000 <freep>
  if(p == (char*)-1)
 7dc:	5afd                	li	s5,-1
 7de:	a895                	j	852 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7e0:	00001797          	auipc	a5,0x1
 7e4:	83078793          	addi	a5,a5,-2000 # 1010 <base>
 7e8:	00001717          	auipc	a4,0x1
 7ec:	80f73c23          	sd	a5,-2024(a4) # 1000 <freep>
 7f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f6:	b7e1                	j	7be <malloc+0x36>
      if(p->s.size == nunits)
 7f8:	02e48c63          	beq	s1,a4,830 <malloc+0xa8>
        p->s.size -= nunits;
 7fc:	4137073b          	subw	a4,a4,s3
 800:	c798                	sw	a4,8(a5)
        p += p->s.size;
 802:	02071693          	slli	a3,a4,0x20
 806:	01c6d713          	srli	a4,a3,0x1c
 80a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 810:	00000717          	auipc	a4,0x0
 814:	7ea73823          	sd	a0,2032(a4) # 1000 <freep>
      return (void*)(p + 1);
 818:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81c:	70e2                	ld	ra,56(sp)
 81e:	7442                	ld	s0,48(sp)
 820:	74a2                	ld	s1,40(sp)
 822:	7902                	ld	s2,32(sp)
 824:	69e2                	ld	s3,24(sp)
 826:	6a42                	ld	s4,16(sp)
 828:	6aa2                	ld	s5,8(sp)
 82a:	6b02                	ld	s6,0(sp)
 82c:	6121                	addi	sp,sp,64
 82e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	e118                	sd	a4,0(a0)
 834:	bff1                	j	810 <malloc+0x88>
  hp->s.size = nu;
 836:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 83a:	0541                	addi	a0,a0,16
 83c:	00000097          	auipc	ra,0x0
 840:	eca080e7          	jalr	-310(ra) # 706 <free>
  return freep;
 844:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 848:	d971                	beqz	a0,81c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84c:	4798                	lw	a4,8(a5)
 84e:	fa9775e3          	bgeu	a4,s1,7f8 <malloc+0x70>
    if(p == freep)
 852:	00093703          	ld	a4,0(s2)
 856:	853e                	mv	a0,a5
 858:	fef719e3          	bne	a4,a5,84a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 85c:	8552                	mv	a0,s4
 85e:	00000097          	auipc	ra,0x0
 862:	b6a080e7          	jalr	-1174(ra) # 3c8 <sbrk>
  if(p == (char*)-1)
 866:	fd5518e3          	bne	a0,s5,836 <malloc+0xae>
        return 0;
 86a:	4501                	li	a0,0
 86c:	bf45                	j	81c <malloc+0x94>
