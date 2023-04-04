
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	3d4080e7          	jalr	980(ra) # 3dc <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	3ce080e7          	jalr	974(ra) # 3e4 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	454080e7          	jalr	1108(ra) # 474 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  extern int main();
  main();
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	3a8080e7          	jalr	936(ra) # 3e4 <exit>

0000000000000044 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0x8>
    ;
  return os;
}
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	cb91                	beqz	a5,7e <strcmp+0x1e>
  6c:	0005c703          	lbu	a4,0(a1)
  70:	00f71763          	bne	a4,a5,7e <strcmp+0x1e>
    p++, q++;
  74:	0505                	addi	a0,a0,1
  76:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	fbe5                	bnez	a5,6c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7e:	0005c503          	lbu	a0,0(a1)
}
  82:	40a7853b          	subw	a0,a5,a0
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strlen+0x26>
  98:	0505                	addi	a0,a0,1
  9a:	87aa                	mv	a5,a0
  9c:	86be                	mv	a3,a5
  9e:	0785                	addi	a5,a5,1
  a0:	fff7c703          	lbu	a4,-1(a5)
  a4:	ff65                	bnez	a4,9c <strlen+0x10>
  a6:	40a6853b          	subw	a0,a3,a0
  aa:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret
  for(n = 0; s[n]; n++)
  b2:	4501                	li	a0,0
  b4:	bfe5                	j	ac <strlen+0x20>

00000000000000b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  bc:	ca19                	beqz	a2,d2 <memset+0x1c>
  be:	87aa                	mv	a5,a0
  c0:	1602                	slli	a2,a2,0x20
  c2:	9201                	srli	a2,a2,0x20
  c4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x12>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2ce080e7          	jalr	718(ra) # 3fc <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e426                	sd	s1,8(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	00000097          	auipc	ra,0x0
 184:	2a4080e7          	jalr	676(ra) # 424 <open>
  if(fd < 0)
 188:	02054563          	bltz	a0,1b2 <stat+0x42>
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	2ac080e7          	jalr	684(ra) # 43c <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	270080e7          	jalr	624(ra) # 40c <close>
  return r;
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfc5                	j	1a4 <stat+0x34>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054683          	lbu	a3,0(a0)
 1c0:	fd06879b          	addiw	a5,a3,-48
 1c4:	0ff7f793          	zext.b	a5,a5
 1c8:	4625                	li	a2,9
 1ca:	02f66863          	bltu	a2,a5,1fa <atoi+0x44>
 1ce:	872a                	mv	a4,a0
  n = 0;
 1d0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d2:	0705                	addi	a4,a4,1
 1d4:	0025179b          	slliw	a5,a0,0x2
 1d8:	9fa9                	addw	a5,a5,a0
 1da:	0017979b          	slliw	a5,a5,0x1
 1de:	9fb5                	addw	a5,a5,a3
 1e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e4:	00074683          	lbu	a3,0(a4)
 1e8:	fd06879b          	addiw	a5,a3,-48
 1ec:	0ff7f793          	zext.b	a5,a5
 1f0:	fef671e3          	bgeu	a2,a5,1d2 <atoi+0x1c>

  return n;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  n = 0;
 1fa:	4501                	li	a0,0
 1fc:	bfe5                	j	1f4 <atoi+0x3e>

00000000000001fe <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
 204:	8eaa                	mv	t4,a0
    register const char *s = strt;
 206:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 208:	02000693          	li	a3,32
        c = *s++;
 20c:	883e                	mv	a6,a5
 20e:	0785                	addi	a5,a5,1
 210:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 214:	fed70ce3          	beq	a4,a3,20c <strtoi+0xe>
        c = *s++;
 218:	2701                	sext.w	a4,a4

    if (c == '-') {
 21a:	02d00693          	li	a3,45
 21e:	04d70d63          	beq	a4,a3,278 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 222:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 226:	4f01                	li	t5,0
    } else if (c == '+')
 228:	04d70e63          	beq	a4,a3,284 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 22c:	fef67693          	andi	a3,a2,-17
 230:	ea99                	bnez	a3,246 <strtoi+0x48>
 232:	03000693          	li	a3,48
 236:	04d70c63          	beq	a4,a3,28e <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 23a:	e611                	bnez	a2,246 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 23c:	03000693          	li	a3,48
 240:	0cd70b63          	beq	a4,a3,316 <strtoi+0x118>
 244:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 246:	800008b7          	lui	a7,0x80000
 24a:	fff8c893          	not	a7,a7
 24e:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 252:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 256:	1882                	slli	a7,a7,0x20
 258:	0208d893          	srli	a7,a7,0x20
 25c:	02c8d8b3          	divu	a7,a7,a2
 260:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 264:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 268:	0ac75163          	bge	a4,a2,30a <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 26c:	4681                	li	a3,0
 26e:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 270:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 272:	2881                	sext.w	a7,a7
        else {
            any = 1;
 274:	4f85                	li	t6,1
 276:	a0a9                	j	2c0 <strtoi+0xc2>
        c = *s++;
 278:	0007c703          	lbu	a4,0(a5)
 27c:	00280793          	addi	a5,a6,2
        neg = 1;
 280:	4f05                	li	t5,1
 282:	b76d                	j	22c <strtoi+0x2e>
        c = *s++;
 284:	0007c703          	lbu	a4,0(a5)
 288:	00280793          	addi	a5,a6,2
 28c:	b745                	j	22c <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 28e:	0007c683          	lbu	a3,0(a5)
 292:	0df6f693          	andi	a3,a3,223
 296:	05800513          	li	a0,88
 29a:	faa690e3          	bne	a3,a0,23a <strtoi+0x3c>
        c = s[1];
 29e:	0017c703          	lbu	a4,1(a5)
        s += 2;
 2a2:	0789                	addi	a5,a5,2
        base = 16;
 2a4:	4641                	li	a2,16
 2a6:	b745                	j	246 <strtoi+0x48>
            any = -1;
 2a8:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2aa:	00e2c463          	blt	t0,a4,2b2 <strtoi+0xb4>
 2ae:	a015                	j	2d2 <strtoi+0xd4>
            any = -1;
 2b0:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 2b2:	0785                	addi	a5,a5,1
 2b4:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 2b8:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 2bc:	02c75063          	bge	a4,a2,2dc <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2c0:	fe06c8e3          	bltz	a3,2b0 <strtoi+0xb2>
 2c4:	0005081b          	sext.w	a6,a0
            any = -1;
 2c8:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2ca:	ff0e64e3          	bltu	t3,a6,2b2 <strtoi+0xb4>
 2ce:	fca88de3          	beq	a7,a0,2a8 <strtoi+0xaa>
            acc *= base;
 2d2:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 2d6:	9d39                	addw	a0,a0,a4
            any = 1;
 2d8:	86fe                	mv	a3,t6
 2da:	bfe1                	j	2b2 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 2dc:	0006cd63          	bltz	a3,2f6 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 2e0:	000f0463          	beqz	t5,2e8 <strtoi+0xea>
        acc = -acc;
 2e4:	40a0053b          	negw	a0,a0
    if (end != 0)
 2e8:	c581                	beqz	a1,2f0 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 2ea:	ee89                	bnez	a3,304 <strtoi+0x106>
 2ec:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 2f6:	000f1d63          	bnez	t5,310 <strtoi+0x112>
 2fa:	80000537          	lui	a0,0x80000
 2fe:	fff54513          	not	a0,a0
    if (end != 0)
 302:	d5fd                	beqz	a1,2f0 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 304:	fff78e93          	addi	t4,a5,-1
 308:	b7d5                	j	2ec <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 30a:	4681                	li	a3,0
 30c:	4501                	li	a0,0
 30e:	bfc9                	j	2e0 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 310:	80000537          	lui	a0,0x80000
 314:	b7fd                	j	302 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 316:	80000e37          	lui	t3,0x80000
 31a:	fffe4e13          	not	t3,t3
 31e:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 322:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 326:	003e589b          	srliw	a7,t3,0x3
 32a:	8e46                	mv	t3,a7
            c -= '0';
 32c:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 32e:	4621                	li	a2,8
 330:	bf35                	j	26c <strtoi+0x6e>

0000000000000332 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 338:	02b57463          	bgeu	a0,a1,360 <memmove+0x2e>
    while(n-- > 0)
 33c:	00c05f63          	blez	a2,35a <memmove+0x28>
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 348:	872a                	mv	a4,a0
      *dst++ = *src++;
 34a:	0585                	addi	a1,a1,1
 34c:	0705                	addi	a4,a4,1
 34e:	fff5c683          	lbu	a3,-1(a1)
 352:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 356:	fee79ae3          	bne	a5,a4,34a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
    dst += n;
 360:	00c50733          	add	a4,a0,a2
    src += n;
 364:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 366:	fec05ae3          	blez	a2,35a <memmove+0x28>
 36a:	fff6079b          	addiw	a5,a2,-1
 36e:	1782                	slli	a5,a5,0x20
 370:	9381                	srli	a5,a5,0x20
 372:	fff7c793          	not	a5,a5
 376:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 378:	15fd                	addi	a1,a1,-1
 37a:	177d                	addi	a4,a4,-1
 37c:	0005c683          	lbu	a3,0(a1)
 380:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 384:	fee79ae3          	bne	a5,a4,378 <memmove+0x46>
 388:	bfc9                	j	35a <memmove+0x28>

000000000000038a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 390:	ca05                	beqz	a2,3c0 <memcmp+0x36>
 392:	fff6069b          	addiw	a3,a2,-1
 396:	1682                	slli	a3,a3,0x20
 398:	9281                	srli	a3,a3,0x20
 39a:	0685                	addi	a3,a3,1
 39c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39e:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 3a2:	0005c703          	lbu	a4,0(a1)
 3a6:	00e79863          	bne	a5,a4,3b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3aa:	0505                	addi	a0,a0,1
    p2++;
 3ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ae:	fed518e3          	bne	a0,a3,39e <memcmp+0x14>
  }
  return 0;
 3b2:	4501                	li	a0,0
 3b4:	a019                	j	3ba <memcmp+0x30>
      return *p1 - *p2;
 3b6:	40e7853b          	subw	a0,a5,a4
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
  return 0;
 3c0:	4501                	li	a0,0
 3c2:	bfe5                	j	3ba <memcmp+0x30>

00000000000003c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3cc:	00000097          	auipc	ra,0x0
 3d0:	f66080e7          	jalr	-154(ra) # 332 <memmove>
}
 3d4:	60a2                	ld	ra,8(sp)
 3d6:	6402                	ld	s0,0(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret

00000000000003dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3dc:	4885                	li	a7,1
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e4:	4889                	li	a7,2
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ec:	488d                	li	a7,3
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f4:	4891                	li	a7,4
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <read>:
.global read
read:
 li a7, SYS_read
 3fc:	4895                	li	a7,5
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <write>:
.global write
write:
 li a7, SYS_write
 404:	48c1                	li	a7,16
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <close>:
.global close
close:
 li a7, SYS_close
 40c:	48d5                	li	a7,21
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <kill>:
.global kill
kill:
 li a7, SYS_kill
 414:	4899                	li	a7,6
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <exec>:
.global exec
exec:
 li a7, SYS_exec
 41c:	489d                	li	a7,7
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <open>:
.global open
open:
 li a7, SYS_open
 424:	48bd                	li	a7,15
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42c:	48c5                	li	a7,17
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 434:	48c9                	li	a7,18
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43c:	48a1                	li	a7,8
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <link>:
.global link
link:
 li a7, SYS_link
 444:	48cd                	li	a7,19
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44c:	48d1                	li	a7,20
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 454:	48a5                	li	a7,9
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <dup>:
.global dup
dup:
 li a7, SYS_dup
 45c:	48a9                	li	a7,10
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 464:	48ad                	li	a7,11
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 46c:	48b1                	li	a7,12
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 474:	48b5                	li	a7,13
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47c:	48b9                	li	a7,14
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 484:	48d9                	li	a7,22
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 48c:	48dd                	li	a7,23
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 494:	48e1                	li	a7,24
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 49c:	48e5                	li	a7,25
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 4a4:	48e9                	li	a7,26
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 4ac:	48ed                	li	a7,27
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b4:	1101                	addi	sp,sp,-32
 4b6:	ec06                	sd	ra,24(sp)
 4b8:	e822                	sd	s0,16(sp)
 4ba:	1000                	addi	s0,sp,32
 4bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c0:	4605                	li	a2,1
 4c2:	fef40593          	addi	a1,s0,-17
 4c6:	00000097          	auipc	ra,0x0
 4ca:	f3e080e7          	jalr	-194(ra) # 404 <write>
}
 4ce:	60e2                	ld	ra,24(sp)
 4d0:	6442                	ld	s0,16(sp)
 4d2:	6105                	addi	sp,sp,32
 4d4:	8082                	ret

00000000000004d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d6:	7139                	addi	sp,sp,-64
 4d8:	fc06                	sd	ra,56(sp)
 4da:	f822                	sd	s0,48(sp)
 4dc:	f426                	sd	s1,40(sp)
 4de:	f04a                	sd	s2,32(sp)
 4e0:	ec4e                	sd	s3,24(sp)
 4e2:	0080                	addi	s0,sp,64
 4e4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e6:	c299                	beqz	a3,4ec <printint+0x16>
 4e8:	0805c963          	bltz	a1,57a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ec:	2581                	sext.w	a1,a1
  neg = 0;
 4ee:	4881                	li	a7,0
 4f0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f6:	2601                	sext.w	a2,a2
 4f8:	00000517          	auipc	a0,0x0
 4fc:	48850513          	addi	a0,a0,1160 # 980 <digits>
 500:	883a                	mv	a6,a4
 502:	2705                	addiw	a4,a4,1
 504:	02c5f7bb          	remuw	a5,a1,a2
 508:	1782                	slli	a5,a5,0x20
 50a:	9381                	srli	a5,a5,0x20
 50c:	97aa                	add	a5,a5,a0
 50e:	0007c783          	lbu	a5,0(a5)
 512:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 516:	0005879b          	sext.w	a5,a1
 51a:	02c5d5bb          	divuw	a1,a1,a2
 51e:	0685                	addi	a3,a3,1
 520:	fec7f0e3          	bgeu	a5,a2,500 <printint+0x2a>
  if(neg)
 524:	00088c63          	beqz	a7,53c <printint+0x66>
    buf[i++] = '-';
 528:	fd070793          	addi	a5,a4,-48
 52c:	00878733          	add	a4,a5,s0
 530:	02d00793          	li	a5,45
 534:	fef70823          	sb	a5,-16(a4)
 538:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 53c:	02e05863          	blez	a4,56c <printint+0x96>
 540:	fc040793          	addi	a5,s0,-64
 544:	00e78933          	add	s2,a5,a4
 548:	fff78993          	addi	s3,a5,-1
 54c:	99ba                	add	s3,s3,a4
 54e:	377d                	addiw	a4,a4,-1
 550:	1702                	slli	a4,a4,0x20
 552:	9301                	srli	a4,a4,0x20
 554:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 558:	fff94583          	lbu	a1,-1(s2)
 55c:	8526                	mv	a0,s1
 55e:	00000097          	auipc	ra,0x0
 562:	f56080e7          	jalr	-170(ra) # 4b4 <putc>
  while(--i >= 0)
 566:	197d                	addi	s2,s2,-1
 568:	ff3918e3          	bne	s2,s3,558 <printint+0x82>
}
 56c:	70e2                	ld	ra,56(sp)
 56e:	7442                	ld	s0,48(sp)
 570:	74a2                	ld	s1,40(sp)
 572:	7902                	ld	s2,32(sp)
 574:	69e2                	ld	s3,24(sp)
 576:	6121                	addi	sp,sp,64
 578:	8082                	ret
    x = -xx;
 57a:	40b005bb          	negw	a1,a1
    neg = 1;
 57e:	4885                	li	a7,1
    x = -xx;
 580:	bf85                	j	4f0 <printint+0x1a>

0000000000000582 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 582:	715d                	addi	sp,sp,-80
 584:	e486                	sd	ra,72(sp)
 586:	e0a2                	sd	s0,64(sp)
 588:	fc26                	sd	s1,56(sp)
 58a:	f84a                	sd	s2,48(sp)
 58c:	f44e                	sd	s3,40(sp)
 58e:	f052                	sd	s4,32(sp)
 590:	ec56                	sd	s5,24(sp)
 592:	e85a                	sd	s6,16(sp)
 594:	e45e                	sd	s7,8(sp)
 596:	e062                	sd	s8,0(sp)
 598:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59a:	0005c903          	lbu	s2,0(a1)
 59e:	18090c63          	beqz	s2,736 <vprintf+0x1b4>
 5a2:	8aaa                	mv	s5,a0
 5a4:	8bb2                	mv	s7,a2
 5a6:	00158493          	addi	s1,a1,1
  state = 0;
 5aa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ac:	02500a13          	li	s4,37
 5b0:	4b55                	li	s6,21
 5b2:	a839                	j	5d0 <vprintf+0x4e>
        putc(fd, c);
 5b4:	85ca                	mv	a1,s2
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	efc080e7          	jalr	-260(ra) # 4b4 <putc>
 5c0:	a019                	j	5c6 <vprintf+0x44>
    } else if(state == '%'){
 5c2:	01498d63          	beq	s3,s4,5dc <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5c6:	0485                	addi	s1,s1,1
 5c8:	fff4c903          	lbu	s2,-1(s1)
 5cc:	16090563          	beqz	s2,736 <vprintf+0x1b4>
    if(state == 0){
 5d0:	fe0999e3          	bnez	s3,5c2 <vprintf+0x40>
      if(c == '%'){
 5d4:	ff4910e3          	bne	s2,s4,5b4 <vprintf+0x32>
        state = '%';
 5d8:	89d2                	mv	s3,s4
 5da:	b7f5                	j	5c6 <vprintf+0x44>
      if(c == 'd'){
 5dc:	13490263          	beq	s2,s4,700 <vprintf+0x17e>
 5e0:	f9d9079b          	addiw	a5,s2,-99
 5e4:	0ff7f793          	zext.b	a5,a5
 5e8:	12fb6563          	bltu	s6,a5,712 <vprintf+0x190>
 5ec:	f9d9079b          	addiw	a5,s2,-99
 5f0:	0ff7f713          	zext.b	a4,a5
 5f4:	10eb6f63          	bltu	s6,a4,712 <vprintf+0x190>
 5f8:	00271793          	slli	a5,a4,0x2
 5fc:	00000717          	auipc	a4,0x0
 600:	32c70713          	addi	a4,a4,812 # 928 <malloc+0xf4>
 604:	97ba                	add	a5,a5,a4
 606:	439c                	lw	a5,0(a5)
 608:	97ba                	add	a5,a5,a4
 60a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 60c:	008b8913          	addi	s2,s7,8
 610:	4685                	li	a3,1
 612:	4629                	li	a2,10
 614:	000ba583          	lw	a1,0(s7)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	ebc080e7          	jalr	-324(ra) # 4d6 <printint>
 622:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 624:	4981                	li	s3,0
 626:	b745                	j	5c6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	008b8913          	addi	s2,s7,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000ba583          	lw	a1,0(s7)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	ea0080e7          	jalr	-352(ra) # 4d6 <printint>
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	b751                	j	5c6 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4641                	li	a2,16
 64c:	000ba583          	lw	a1,0(s7)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e84080e7          	jalr	-380(ra) # 4d6 <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b7a5                	j	5c6 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 660:	008b8c13          	addi	s8,s7,8
 664:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 668:	03000593          	li	a1,48
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e46080e7          	jalr	-442(ra) # 4b4 <putc>
  putc(fd, 'x');
 676:	07800593          	li	a1,120
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e38080e7          	jalr	-456(ra) # 4b4 <putc>
 684:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 686:	00000b97          	auipc	s7,0x0
 68a:	2fab8b93          	addi	s7,s7,762 # 980 <digits>
 68e:	03c9d793          	srli	a5,s3,0x3c
 692:	97de                	add	a5,a5,s7
 694:	0007c583          	lbu	a1,0(a5)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e1a080e7          	jalr	-486(ra) # 4b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a2:	0992                	slli	s3,s3,0x4
 6a4:	397d                	addiw	s2,s2,-1
 6a6:	fe0914e3          	bnez	s2,68e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6aa:	8be2                	mv	s7,s8
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bf21                	j	5c6 <vprintf+0x44>
        s = va_arg(ap, char*);
 6b0:	008b8993          	addi	s3,s7,8
 6b4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6b8:	02090163          	beqz	s2,6da <vprintf+0x158>
        while(*s != 0){
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	c9a5                	beqz	a1,730 <vprintf+0x1ae>
          putc(fd, *s);
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	df0080e7          	jalr	-528(ra) # 4b4 <putc>
          s++;
 6cc:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ce:	00094583          	lbu	a1,0(s2)
 6d2:	f9e5                	bnez	a1,6c2 <vprintf+0x140>
        s = va_arg(ap, char*);
 6d4:	8bce                	mv	s7,s3
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b5fd                	j	5c6 <vprintf+0x44>
          s = "(null)";
 6da:	00000917          	auipc	s2,0x0
 6de:	24690913          	addi	s2,s2,582 # 920 <malloc+0xec>
        while(*s != 0){
 6e2:	02800593          	li	a1,40
 6e6:	bff1                	j	6c2 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6e8:	008b8913          	addi	s2,s7,8
 6ec:	000bc583          	lbu	a1,0(s7)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	dc2080e7          	jalr	-574(ra) # 4b4 <putc>
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b5e1                	j	5c6 <vprintf+0x44>
        putc(fd, c);
 700:	02500593          	li	a1,37
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	dae080e7          	jalr	-594(ra) # 4b4 <putc>
      state = 0;
 70e:	4981                	li	s3,0
 710:	bd5d                	j	5c6 <vprintf+0x44>
        putc(fd, '%');
 712:	02500593          	li	a1,37
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	d9c080e7          	jalr	-612(ra) # 4b4 <putc>
        putc(fd, c);
 720:	85ca                	mv	a1,s2
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	d90080e7          	jalr	-624(ra) # 4b4 <putc>
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bd61                	j	5c6 <vprintf+0x44>
        s = va_arg(ap, char*);
 730:	8bce                	mv	s7,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	bd49                	j	5c6 <vprintf+0x44>
    }
  }
}
 736:	60a6                	ld	ra,72(sp)
 738:	6406                	ld	s0,64(sp)
 73a:	74e2                	ld	s1,56(sp)
 73c:	7942                	ld	s2,48(sp)
 73e:	79a2                	ld	s3,40(sp)
 740:	7a02                	ld	s4,32(sp)
 742:	6ae2                	ld	s5,24(sp)
 744:	6b42                	ld	s6,16(sp)
 746:	6ba2                	ld	s7,8(sp)
 748:	6c02                	ld	s8,0(sp)
 74a:	6161                	addi	sp,sp,80
 74c:	8082                	ret

000000000000074e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74e:	715d                	addi	sp,sp,-80
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	addi	s0,sp,32
 756:	e010                	sd	a2,0(s0)
 758:	e414                	sd	a3,8(s0)
 75a:	e818                	sd	a4,16(s0)
 75c:	ec1c                	sd	a5,24(s0)
 75e:	03043023          	sd	a6,32(s0)
 762:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76a:	8622                	mv	a2,s0
 76c:	00000097          	auipc	ra,0x0
 770:	e16080e7          	jalr	-490(ra) # 582 <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6161                	addi	sp,sp,80
 77a:	8082                	ret

000000000000077c <printf>:

void
printf(const char *fmt, ...)
{
 77c:	711d                	addi	sp,sp,-96
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	addi	s0,sp,32
 784:	e40c                	sd	a1,8(s0)
 786:	e810                	sd	a2,16(s0)
 788:	ec14                	sd	a3,24(s0)
 78a:	f018                	sd	a4,32(s0)
 78c:	f41c                	sd	a5,40(s0)
 78e:	03043823          	sd	a6,48(s0)
 792:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	00840613          	addi	a2,s0,8
 79a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79e:	85aa                	mv	a1,a0
 7a0:	4505                	li	a0,1
 7a2:	00000097          	auipc	ra,0x0
 7a6:	de0080e7          	jalr	-544(ra) # 582 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6125                	addi	sp,sp,96
 7b0:	8082                	ret

00000000000007b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b2:	1141                	addi	sp,sp,-16
 7b4:	e422                	sd	s0,8(sp)
 7b6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	00001797          	auipc	a5,0x1
 7c0:	8447b783          	ld	a5,-1980(a5) # 1000 <freep>
 7c4:	a02d                	j	7ee <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c6:	4618                	lw	a4,8(a2)
 7c8:	9f2d                	addw	a4,a4,a1
 7ca:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ce:	6398                	ld	a4,0(a5)
 7d0:	6310                	ld	a2,0(a4)
 7d2:	a83d                	j	810 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d4:	ff852703          	lw	a4,-8(a0)
 7d8:	9f31                	addw	a4,a4,a2
 7da:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7dc:	ff053683          	ld	a3,-16(a0)
 7e0:	a091                	j	824 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e2:	6398                	ld	a4,0(a5)
 7e4:	00e7e463          	bltu	a5,a4,7ec <free+0x3a>
 7e8:	00e6ea63          	bltu	a3,a4,7fc <free+0x4a>
{
 7ec:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ee:	fed7fae3          	bgeu	a5,a3,7e2 <free+0x30>
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e6e463          	bltu	a3,a4,7fc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f8:	fee7eae3          	bltu	a5,a4,7ec <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7fc:	ff852583          	lw	a1,-8(a0)
 800:	6390                	ld	a2,0(a5)
 802:	02059813          	slli	a6,a1,0x20
 806:	01c85713          	srli	a4,a6,0x1c
 80a:	9736                	add	a4,a4,a3
 80c:	fae60de3          	beq	a2,a4,7c6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 814:	4790                	lw	a2,8(a5)
 816:	02061593          	slli	a1,a2,0x20
 81a:	01c5d713          	srli	a4,a1,0x1c
 81e:	973e                	add	a4,a4,a5
 820:	fae68ae3          	beq	a3,a4,7d4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 824:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 826:	00000717          	auipc	a4,0x0
 82a:	7cf73d23          	sd	a5,2010(a4) # 1000 <freep>
}
 82e:	6422                	ld	s0,8(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret

0000000000000834 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 834:	7139                	addi	sp,sp,-64
 836:	fc06                	sd	ra,56(sp)
 838:	f822                	sd	s0,48(sp)
 83a:	f426                	sd	s1,40(sp)
 83c:	f04a                	sd	s2,32(sp)
 83e:	ec4e                	sd	s3,24(sp)
 840:	e852                	sd	s4,16(sp)
 842:	e456                	sd	s5,8(sp)
 844:	e05a                	sd	s6,0(sp)
 846:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 848:	02051493          	slli	s1,a0,0x20
 84c:	9081                	srli	s1,s1,0x20
 84e:	04bd                	addi	s1,s1,15
 850:	8091                	srli	s1,s1,0x4
 852:	0014899b          	addiw	s3,s1,1
 856:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 858:	00000517          	auipc	a0,0x0
 85c:	7a853503          	ld	a0,1960(a0) # 1000 <freep>
 860:	c515                	beqz	a0,88c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 862:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 864:	4798                	lw	a4,8(a5)
 866:	02977f63          	bgeu	a4,s1,8a4 <malloc+0x70>
  if(nu < 4096)
 86a:	8a4e                	mv	s4,s3
 86c:	0009871b          	sext.w	a4,s3
 870:	6685                	lui	a3,0x1
 872:	00d77363          	bgeu	a4,a3,878 <malloc+0x44>
 876:	6a05                	lui	s4,0x1
 878:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 880:	00000917          	auipc	s2,0x0
 884:	78090913          	addi	s2,s2,1920 # 1000 <freep>
  if(p == (char*)-1)
 888:	5afd                	li	s5,-1
 88a:	a895                	j	8fe <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 88c:	00000797          	auipc	a5,0x0
 890:	78478793          	addi	a5,a5,1924 # 1010 <base>
 894:	00000717          	auipc	a4,0x0
 898:	76f73623          	sd	a5,1900(a4) # 1000 <freep>
 89c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 89e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a2:	b7e1                	j	86a <malloc+0x36>
      if(p->s.size == nunits)
 8a4:	02e48c63          	beq	s1,a4,8dc <malloc+0xa8>
        p->s.size -= nunits;
 8a8:	4137073b          	subw	a4,a4,s3
 8ac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ae:	02071693          	slli	a3,a4,0x20
 8b2:	01c6d713          	srli	a4,a3,0x1c
 8b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74a73223          	sd	a0,1860(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c8:	70e2                	ld	ra,56(sp)
 8ca:	7442                	ld	s0,48(sp)
 8cc:	74a2                	ld	s1,40(sp)
 8ce:	7902                	ld	s2,32(sp)
 8d0:	69e2                	ld	s3,24(sp)
 8d2:	6a42                	ld	s4,16(sp)
 8d4:	6aa2                	ld	s5,8(sp)
 8d6:	6b02                	ld	s6,0(sp)
 8d8:	6121                	addi	sp,sp,64
 8da:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8dc:	6398                	ld	a4,0(a5)
 8de:	e118                	sd	a4,0(a0)
 8e0:	bff1                	j	8bc <malloc+0x88>
  hp->s.size = nu;
 8e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e6:	0541                	addi	a0,a0,16
 8e8:	00000097          	auipc	ra,0x0
 8ec:	eca080e7          	jalr	-310(ra) # 7b2 <free>
  return freep;
 8f0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f4:	d971                	beqz	a0,8c8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f8:	4798                	lw	a4,8(a5)
 8fa:	fa9775e3          	bgeu	a4,s1,8a4 <malloc+0x70>
    if(p == freep)
 8fe:	00093703          	ld	a4,0(s2)
 902:	853e                	mv	a0,a5
 904:	fef719e3          	bne	a4,a5,8f6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 908:	8552                	mv	a0,s4
 90a:	00000097          	auipc	ra,0x0
 90e:	b62080e7          	jalr	-1182(ra) # 46c <sbrk>
  if(p == (char*)-1)
 912:	fd5518e3          	bne	a0,s5,8e2 <malloc+0xae>
        return 0;
 916:	4501                	li	a0,0
 918:	bf45                	j	8c8 <malloc+0x94>
