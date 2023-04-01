
user/_pass:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"


int main()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

  exit(0);
   8:	4501                	li	a0,0
   a:	00000097          	auipc	ra,0x0
   e:	3c2080e7          	jalr	962(ra) # 3cc <exit>

0000000000000012 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  12:	1141                	addi	sp,sp,-16
  14:	e406                	sd	ra,8(sp)
  16:	e022                	sd	s0,0(sp)
  18:	0800                	addi	s0,sp,16
  extern int main();
  main();
  1a:	00000097          	auipc	ra,0x0
  1e:	fe6080e7          	jalr	-26(ra) # 0 <main>
  exit(0);
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3a8080e7          	jalr	936(ra) # 3cc <exit>

000000000000002c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  2c:	1141                	addi	sp,sp,-16
  2e:	e422                	sd	s0,8(sp)
  30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  32:	87aa                	mv	a5,a0
  34:	0585                	addi	a1,a1,1
  36:	0785                	addi	a5,a5,1
  38:	fff5c703          	lbu	a4,-1(a1)
  3c:	fee78fa3          	sb	a4,-1(a5)
  40:	fb75                	bnez	a4,34 <strcpy+0x8>
    ;
  return os;
}
  42:	6422                	ld	s0,8(sp)
  44:	0141                	addi	sp,sp,16
  46:	8082                	ret

0000000000000048 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e422                	sd	s0,8(sp)
  4c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4e:	00054783          	lbu	a5,0(a0)
  52:	cb91                	beqz	a5,66 <strcmp+0x1e>
  54:	0005c703          	lbu	a4,0(a1)
  58:	00f71763          	bne	a4,a5,66 <strcmp+0x1e>
    p++, q++;
  5c:	0505                	addi	a0,a0,1
  5e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  60:	00054783          	lbu	a5,0(a0)
  64:	fbe5                	bnez	a5,54 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  66:	0005c503          	lbu	a0,0(a1)
}
  6a:	40a7853b          	subw	a0,a5,a0
  6e:	6422                	ld	s0,8(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <strlen>:

uint
strlen(const char *s)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cf91                	beqz	a5,9a <strlen+0x26>
  80:	0505                	addi	a0,a0,1
  82:	87aa                	mv	a5,a0
  84:	86be                	mv	a3,a5
  86:	0785                	addi	a5,a5,1
  88:	fff7c703          	lbu	a4,-1(a5)
  8c:	ff65                	bnez	a4,84 <strlen+0x10>
  8e:	40a6853b          	subw	a0,a3,a0
  92:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret
  for(n = 0; s[n]; n++)
  9a:	4501                	li	a0,0
  9c:	bfe5                	j	94 <strlen+0x20>

000000000000009e <memset>:

void*
memset(void *dst, int c, uint n)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a4:	ca19                	beqz	a2,ba <memset+0x1c>
  a6:	87aa                	mv	a5,a0
  a8:	1602                	slli	a2,a2,0x20
  aa:	9201                	srli	a2,a2,0x20
  ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b4:	0785                	addi	a5,a5,1
  b6:	fee79de3          	bne	a5,a4,b0 <memset+0x12>
  }
  return dst;
}
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strchr>:

char*
strchr(const char *s, char c)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cb99                	beqz	a5,e0 <strchr+0x20>
    if(*s == c)
  cc:	00f58763          	beq	a1,a5,da <strchr+0x1a>
  for(; *s; s++)
  d0:	0505                	addi	a0,a0,1
  d2:	00054783          	lbu	a5,0(a0)
  d6:	fbfd                	bnez	a5,cc <strchr+0xc>
      return (char*)s;
  return 0;
  d8:	4501                	li	a0,0
}
  da:	6422                	ld	s0,8(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret
  return 0;
  e0:	4501                	li	a0,0
  e2:	bfe5                	j	da <strchr+0x1a>

00000000000000e4 <gets>:

char*
gets(char *buf, int max)
{
  e4:	711d                	addi	sp,sp,-96
  e6:	ec86                	sd	ra,88(sp)
  e8:	e8a2                	sd	s0,80(sp)
  ea:	e4a6                	sd	s1,72(sp)
  ec:	e0ca                	sd	s2,64(sp)
  ee:	fc4e                	sd	s3,56(sp)
  f0:	f852                	sd	s4,48(sp)
  f2:	f456                	sd	s5,40(sp)
  f4:	f05a                	sd	s6,32(sp)
  f6:	ec5e                	sd	s7,24(sp)
  f8:	1080                	addi	s0,sp,96
  fa:	8baa                	mv	s7,a0
  fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fe:	892a                	mv	s2,a0
 100:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 102:	4aa9                	li	s5,10
 104:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 106:	89a6                	mv	s3,s1
 108:	2485                	addiw	s1,s1,1
 10a:	0344d863          	bge	s1,s4,13a <gets+0x56>
    cc = read(0, &c, 1);
 10e:	4605                	li	a2,1
 110:	faf40593          	addi	a1,s0,-81
 114:	4501                	li	a0,0
 116:	00000097          	auipc	ra,0x0
 11a:	2ce080e7          	jalr	718(ra) # 3e4 <read>
    if(cc < 1)
 11e:	00a05e63          	blez	a0,13a <gets+0x56>
    buf[i++] = c;
 122:	faf44783          	lbu	a5,-81(s0)
 126:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12a:	01578763          	beq	a5,s5,138 <gets+0x54>
 12e:	0905                	addi	s2,s2,1
 130:	fd679be3          	bne	a5,s6,106 <gets+0x22>
  for(i=0; i+1 < max; ){
 134:	89a6                	mv	s3,s1
 136:	a011                	j	13a <gets+0x56>
 138:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13a:	99de                	add	s3,s3,s7
 13c:	00098023          	sb	zero,0(s3)
  return buf;
}
 140:	855e                	mv	a0,s7
 142:	60e6                	ld	ra,88(sp)
 144:	6446                	ld	s0,80(sp)
 146:	64a6                	ld	s1,72(sp)
 148:	6906                	ld	s2,64(sp)
 14a:	79e2                	ld	s3,56(sp)
 14c:	7a42                	ld	s4,48(sp)
 14e:	7aa2                	ld	s5,40(sp)
 150:	7b02                	ld	s6,32(sp)
 152:	6be2                	ld	s7,24(sp)
 154:	6125                	addi	sp,sp,96
 156:	8082                	ret

0000000000000158 <stat>:

int
stat(const char *n, struct stat *st)
{
 158:	1101                	addi	sp,sp,-32
 15a:	ec06                	sd	ra,24(sp)
 15c:	e822                	sd	s0,16(sp)
 15e:	e426                	sd	s1,8(sp)
 160:	e04a                	sd	s2,0(sp)
 162:	1000                	addi	s0,sp,32
 164:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 166:	4581                	li	a1,0
 168:	00000097          	auipc	ra,0x0
 16c:	2a4080e7          	jalr	676(ra) # 40c <open>
  if(fd < 0)
 170:	02054563          	bltz	a0,19a <stat+0x42>
 174:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 176:	85ca                	mv	a1,s2
 178:	00000097          	auipc	ra,0x0
 17c:	2ac080e7          	jalr	684(ra) # 424 <fstat>
 180:	892a                	mv	s2,a0
  close(fd);
 182:	8526                	mv	a0,s1
 184:	00000097          	auipc	ra,0x0
 188:	270080e7          	jalr	624(ra) # 3f4 <close>
  return r;
}
 18c:	854a                	mv	a0,s2
 18e:	60e2                	ld	ra,24(sp)
 190:	6442                	ld	s0,16(sp)
 192:	64a2                	ld	s1,8(sp)
 194:	6902                	ld	s2,0(sp)
 196:	6105                	addi	sp,sp,32
 198:	8082                	ret
    return -1;
 19a:	597d                	li	s2,-1
 19c:	bfc5                	j	18c <stat+0x34>

000000000000019e <atoi>:

int
atoi(const char *s)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 1a4:	00054683          	lbu	a3,0(a0)
 1a8:	fd06879b          	addiw	a5,a3,-48
 1ac:	0ff7f793          	zext.b	a5,a5
 1b0:	4625                	li	a2,9
 1b2:	02f66863          	bltu	a2,a5,1e2 <atoi+0x44>
 1b6:	872a                	mv	a4,a0
  n = 0;
 1b8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ba:	0705                	addi	a4,a4,1
 1bc:	0025179b          	slliw	a5,a0,0x2
 1c0:	9fa9                	addw	a5,a5,a0
 1c2:	0017979b          	slliw	a5,a5,0x1
 1c6:	9fb5                	addw	a5,a5,a3
 1c8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1cc:	00074683          	lbu	a3,0(a4)
 1d0:	fd06879b          	addiw	a5,a3,-48
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	fef671e3          	bgeu	a2,a5,1ba <atoi+0x1c>

  return n;
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  n = 0;
 1e2:	4501                	li	a0,0
 1e4:	bfe5                	j	1dc <atoi+0x3e>

00000000000001e6 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
 1ec:	8eaa                	mv	t4,a0
    register const char *s = strt;
 1ee:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 1f0:	02000693          	li	a3,32
        c = *s++;
 1f4:	883e                	mv	a6,a5
 1f6:	0785                	addi	a5,a5,1
 1f8:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 1fc:	fed70ce3          	beq	a4,a3,1f4 <strtoi+0xe>
        c = *s++;
 200:	2701                	sext.w	a4,a4

    if (c == '-') {
 202:	02d00693          	li	a3,45
 206:	04d70d63          	beq	a4,a3,260 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 20a:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 20e:	4f01                	li	t5,0
    } else if (c == '+')
 210:	04d70e63          	beq	a4,a3,26c <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 214:	fef67693          	andi	a3,a2,-17
 218:	ea99                	bnez	a3,22e <strtoi+0x48>
 21a:	03000693          	li	a3,48
 21e:	04d70c63          	beq	a4,a3,276 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 222:	e611                	bnez	a2,22e <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 224:	03000693          	li	a3,48
 228:	0cd70b63          	beq	a4,a3,2fe <strtoi+0x118>
 22c:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 22e:	800008b7          	lui	a7,0x80000
 232:	fff8c893          	not	a7,a7
 236:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 23a:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 23e:	1882                	slli	a7,a7,0x20
 240:	0208d893          	srli	a7,a7,0x20
 244:	02c8d8b3          	divu	a7,a7,a2
 248:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 24c:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 250:	0ac75163          	bge	a4,a2,2f2 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 254:	4681                	li	a3,0
 256:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 258:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 25a:	2881                	sext.w	a7,a7
        else {
            any = 1;
 25c:	4f85                	li	t6,1
 25e:	a0a9                	j	2a8 <strtoi+0xc2>
        c = *s++;
 260:	0007c703          	lbu	a4,0(a5)
 264:	00280793          	addi	a5,a6,2
        neg = 1;
 268:	4f05                	li	t5,1
 26a:	b76d                	j	214 <strtoi+0x2e>
        c = *s++;
 26c:	0007c703          	lbu	a4,0(a5)
 270:	00280793          	addi	a5,a6,2
 274:	b745                	j	214 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 276:	0007c683          	lbu	a3,0(a5)
 27a:	0df6f693          	andi	a3,a3,223
 27e:	05800513          	li	a0,88
 282:	faa690e3          	bne	a3,a0,222 <strtoi+0x3c>
        c = s[1];
 286:	0017c703          	lbu	a4,1(a5)
        s += 2;
 28a:	0789                	addi	a5,a5,2
        base = 16;
 28c:	4641                	li	a2,16
 28e:	b745                	j	22e <strtoi+0x48>
            any = -1;
 290:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 292:	00e2c463          	blt	t0,a4,29a <strtoi+0xb4>
 296:	a015                	j	2ba <strtoi+0xd4>
            any = -1;
 298:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 29a:	0785                	addi	a5,a5,1
 29c:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 2a0:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 2a4:	02c75063          	bge	a4,a2,2c4 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2a8:	fe06c8e3          	bltz	a3,298 <strtoi+0xb2>
 2ac:	0005081b          	sext.w	a6,a0
            any = -1;
 2b0:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2b2:	ff0e64e3          	bltu	t3,a6,29a <strtoi+0xb4>
 2b6:	fca88de3          	beq	a7,a0,290 <strtoi+0xaa>
            acc *= base;
 2ba:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 2be:	9d39                	addw	a0,a0,a4
            any = 1;
 2c0:	86fe                	mv	a3,t6
 2c2:	bfe1                	j	29a <strtoi+0xb4>
        }
    }
    if (any < 0) {
 2c4:	0006cd63          	bltz	a3,2de <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 2c8:	000f0463          	beqz	t5,2d0 <strtoi+0xea>
        acc = -acc;
 2cc:	40a0053b          	negw	a0,a0
    if (end != 0)
 2d0:	c581                	beqz	a1,2d8 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 2d2:	ee89                	bnez	a3,2ec <strtoi+0x106>
 2d4:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 2d8:	6422                	ld	s0,8(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 2de:	000f1d63          	bnez	t5,2f8 <strtoi+0x112>
 2e2:	80000537          	lui	a0,0x80000
 2e6:	fff54513          	not	a0,a0
    if (end != 0)
 2ea:	d5fd                	beqz	a1,2d8 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 2ec:	fff78e93          	addi	t4,a5,-1
 2f0:	b7d5                	j	2d4 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 2f2:	4681                	li	a3,0
 2f4:	4501                	li	a0,0
 2f6:	bfc9                	j	2c8 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 2f8:	80000537          	lui	a0,0x80000
 2fc:	b7fd                	j	2ea <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 2fe:	80000e37          	lui	t3,0x80000
 302:	fffe4e13          	not	t3,t3
 306:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 30a:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 30e:	003e589b          	srliw	a7,t3,0x3
 312:	8e46                	mv	t3,a7
            c -= '0';
 314:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 316:	4621                	li	a2,8
 318:	bf35                	j	254 <strtoi+0x6e>

000000000000031a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 320:	02b57463          	bgeu	a0,a1,348 <memmove+0x2e>
    while(n-- > 0)
 324:	00c05f63          	blez	a2,342 <memmove+0x28>
 328:	1602                	slli	a2,a2,0x20
 32a:	9201                	srli	a2,a2,0x20
 32c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 330:	872a                	mv	a4,a0
      *dst++ = *src++;
 332:	0585                	addi	a1,a1,1
 334:	0705                	addi	a4,a4,1
 336:	fff5c683          	lbu	a3,-1(a1)
 33a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33e:	fee79ae3          	bne	a5,a4,332 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
    dst += n;
 348:	00c50733          	add	a4,a0,a2
    src += n;
 34c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34e:	fec05ae3          	blez	a2,342 <memmove+0x28>
 352:	fff6079b          	addiw	a5,a2,-1
 356:	1782                	slli	a5,a5,0x20
 358:	9381                	srli	a5,a5,0x20
 35a:	fff7c793          	not	a5,a5
 35e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 360:	15fd                	addi	a1,a1,-1
 362:	177d                	addi	a4,a4,-1
 364:	0005c683          	lbu	a3,0(a1)
 368:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36c:	fee79ae3          	bne	a5,a4,360 <memmove+0x46>
 370:	bfc9                	j	342 <memmove+0x28>

0000000000000372 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 378:	ca05                	beqz	a2,3a8 <memcmp+0x36>
 37a:	fff6069b          	addiw	a3,a2,-1
 37e:	1682                	slli	a3,a3,0x20
 380:	9281                	srli	a3,a3,0x20
 382:	0685                	addi	a3,a3,1
 384:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 386:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 38a:	0005c703          	lbu	a4,0(a1)
 38e:	00e79863          	bne	a5,a4,39e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 392:	0505                	addi	a0,a0,1
    p2++;
 394:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 396:	fed518e3          	bne	a0,a3,386 <memcmp+0x14>
  }
  return 0;
 39a:	4501                	li	a0,0
 39c:	a019                	j	3a2 <memcmp+0x30>
      return *p1 - *p2;
 39e:	40e7853b          	subw	a0,a5,a4
}
 3a2:	6422                	ld	s0,8(sp)
 3a4:	0141                	addi	sp,sp,16
 3a6:	8082                	ret
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	bfe5                	j	3a2 <memcmp+0x30>

00000000000003ac <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e406                	sd	ra,8(sp)
 3b0:	e022                	sd	s0,0(sp)
 3b2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f66080e7          	jalr	-154(ra) # 31a <memmove>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c4:	4885                	li	a7,1
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3cc:	4889                	li	a7,2
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d4:	488d                	li	a7,3
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3dc:	4891                	li	a7,4
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <read>:
.global read
read:
 li a7, SYS_read
 3e4:	4895                	li	a7,5
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <write>:
.global write
write:
 li a7, SYS_write
 3ec:	48c1                	li	a7,16
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <close>:
.global close
close:
 li a7, SYS_close
 3f4:	48d5                	li	a7,21
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fc:	4899                	li	a7,6
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exec>:
.global exec
exec:
 li a7, SYS_exec
 404:	489d                	li	a7,7
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <open>:
.global open
open:
 li a7, SYS_open
 40c:	48bd                	li	a7,15
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 414:	48c5                	li	a7,17
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41c:	48c9                	li	a7,18
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 424:	48a1                	li	a7,8
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <link>:
.global link
link:
 li a7, SYS_link
 42c:	48cd                	li	a7,19
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 434:	48d1                	li	a7,20
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43c:	48a5                	li	a7,9
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <dup>:
.global dup
dup:
 li a7, SYS_dup
 444:	48a9                	li	a7,10
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44c:	48ad                	li	a7,11
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 454:	48b1                	li	a7,12
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 45c:	48b5                	li	a7,13
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 464:	48b9                	li	a7,14
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 46c:	48d9                	li	a7,22
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 474:	48dd                	li	a7,23
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 47c:	48e1                	li	a7,24
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 484:	48e5                	li	a7,25
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 48c:	48e9                	li	a7,26
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 494:	48ed                	li	a7,27
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49c:	1101                	addi	sp,sp,-32
 49e:	ec06                	sd	ra,24(sp)
 4a0:	e822                	sd	s0,16(sp)
 4a2:	1000                	addi	s0,sp,32
 4a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a8:	4605                	li	a2,1
 4aa:	fef40593          	addi	a1,s0,-17
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f3e080e7          	jalr	-194(ra) # 3ec <write>
}
 4b6:	60e2                	ld	ra,24(sp)
 4b8:	6442                	ld	s0,16(sp)
 4ba:	6105                	addi	sp,sp,32
 4bc:	8082                	ret

00000000000004be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4be:	7139                	addi	sp,sp,-64
 4c0:	fc06                	sd	ra,56(sp)
 4c2:	f822                	sd	s0,48(sp)
 4c4:	f426                	sd	s1,40(sp)
 4c6:	f04a                	sd	s2,32(sp)
 4c8:	ec4e                	sd	s3,24(sp)
 4ca:	0080                	addi	s0,sp,64
 4cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ce:	c299                	beqz	a3,4d4 <printint+0x16>
 4d0:	0805c963          	bltz	a1,562 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d4:	2581                	sext.w	a1,a1
  neg = 0;
 4d6:	4881                	li	a7,0
 4d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4de:	2601                	sext.w	a2,a2
 4e0:	00000517          	auipc	a0,0x0
 4e4:	49050513          	addi	a0,a0,1168 # 970 <digits>
 4e8:	883a                	mv	a6,a4
 4ea:	2705                	addiw	a4,a4,1
 4ec:	02c5f7bb          	remuw	a5,a1,a2
 4f0:	1782                	slli	a5,a5,0x20
 4f2:	9381                	srli	a5,a5,0x20
 4f4:	97aa                	add	a5,a5,a0
 4f6:	0007c783          	lbu	a5,0(a5)
 4fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fe:	0005879b          	sext.w	a5,a1
 502:	02c5d5bb          	divuw	a1,a1,a2
 506:	0685                	addi	a3,a3,1
 508:	fec7f0e3          	bgeu	a5,a2,4e8 <printint+0x2a>
  if(neg)
 50c:	00088c63          	beqz	a7,524 <printint+0x66>
    buf[i++] = '-';
 510:	fd070793          	addi	a5,a4,-48
 514:	00878733          	add	a4,a5,s0
 518:	02d00793          	li	a5,45
 51c:	fef70823          	sb	a5,-16(a4)
 520:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 524:	02e05863          	blez	a4,554 <printint+0x96>
 528:	fc040793          	addi	a5,s0,-64
 52c:	00e78933          	add	s2,a5,a4
 530:	fff78993          	addi	s3,a5,-1
 534:	99ba                	add	s3,s3,a4
 536:	377d                	addiw	a4,a4,-1
 538:	1702                	slli	a4,a4,0x20
 53a:	9301                	srli	a4,a4,0x20
 53c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 540:	fff94583          	lbu	a1,-1(s2)
 544:	8526                	mv	a0,s1
 546:	00000097          	auipc	ra,0x0
 54a:	f56080e7          	jalr	-170(ra) # 49c <putc>
  while(--i >= 0)
 54e:	197d                	addi	s2,s2,-1
 550:	ff3918e3          	bne	s2,s3,540 <printint+0x82>
}
 554:	70e2                	ld	ra,56(sp)
 556:	7442                	ld	s0,48(sp)
 558:	74a2                	ld	s1,40(sp)
 55a:	7902                	ld	s2,32(sp)
 55c:	69e2                	ld	s3,24(sp)
 55e:	6121                	addi	sp,sp,64
 560:	8082                	ret
    x = -xx;
 562:	40b005bb          	negw	a1,a1
    neg = 1;
 566:	4885                	li	a7,1
    x = -xx;
 568:	bf85                	j	4d8 <printint+0x1a>

000000000000056a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56a:	715d                	addi	sp,sp,-80
 56c:	e486                	sd	ra,72(sp)
 56e:	e0a2                	sd	s0,64(sp)
 570:	fc26                	sd	s1,56(sp)
 572:	f84a                	sd	s2,48(sp)
 574:	f44e                	sd	s3,40(sp)
 576:	f052                	sd	s4,32(sp)
 578:	ec56                	sd	s5,24(sp)
 57a:	e85a                	sd	s6,16(sp)
 57c:	e45e                	sd	s7,8(sp)
 57e:	e062                	sd	s8,0(sp)
 580:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 582:	0005c903          	lbu	s2,0(a1)
 586:	18090c63          	beqz	s2,71e <vprintf+0x1b4>
 58a:	8aaa                	mv	s5,a0
 58c:	8bb2                	mv	s7,a2
 58e:	00158493          	addi	s1,a1,1
  state = 0;
 592:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 594:	02500a13          	li	s4,37
 598:	4b55                	li	s6,21
 59a:	a839                	j	5b8 <vprintf+0x4e>
        putc(fd, c);
 59c:	85ca                	mv	a1,s2
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	efc080e7          	jalr	-260(ra) # 49c <putc>
 5a8:	a019                	j	5ae <vprintf+0x44>
    } else if(state == '%'){
 5aa:	01498d63          	beq	s3,s4,5c4 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5ae:	0485                	addi	s1,s1,1
 5b0:	fff4c903          	lbu	s2,-1(s1)
 5b4:	16090563          	beqz	s2,71e <vprintf+0x1b4>
    if(state == 0){
 5b8:	fe0999e3          	bnez	s3,5aa <vprintf+0x40>
      if(c == '%'){
 5bc:	ff4910e3          	bne	s2,s4,59c <vprintf+0x32>
        state = '%';
 5c0:	89d2                	mv	s3,s4
 5c2:	b7f5                	j	5ae <vprintf+0x44>
      if(c == 'd'){
 5c4:	13490263          	beq	s2,s4,6e8 <vprintf+0x17e>
 5c8:	f9d9079b          	addiw	a5,s2,-99
 5cc:	0ff7f793          	zext.b	a5,a5
 5d0:	12fb6563          	bltu	s6,a5,6fa <vprintf+0x190>
 5d4:	f9d9079b          	addiw	a5,s2,-99
 5d8:	0ff7f713          	zext.b	a4,a5
 5dc:	10eb6f63          	bltu	s6,a4,6fa <vprintf+0x190>
 5e0:	00271793          	slli	a5,a4,0x2
 5e4:	00000717          	auipc	a4,0x0
 5e8:	33470713          	addi	a4,a4,820 # 918 <malloc+0xfc>
 5ec:	97ba                	add	a5,a5,a4
 5ee:	439c                	lw	a5,0(a5)
 5f0:	97ba                	add	a5,a5,a4
 5f2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4685                	li	a3,1
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ebc080e7          	jalr	-324(ra) # 4be <printint>
 60a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b745                	j	5ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000ba583          	lw	a1,0(s7)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	ea0080e7          	jalr	-352(ra) # 4be <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b751                	j	5ae <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4641                	li	a2,16
 634:	000ba583          	lw	a1,0(s7)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e84080e7          	jalr	-380(ra) # 4be <printint>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b7a5                	j	5ae <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 648:	008b8c13          	addi	s8,s7,8
 64c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 650:	03000593          	li	a1,48
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e46080e7          	jalr	-442(ra) # 49c <putc>
  putc(fd, 'x');
 65e:	07800593          	li	a1,120
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e38080e7          	jalr	-456(ra) # 49c <putc>
 66c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66e:	00000b97          	auipc	s7,0x0
 672:	302b8b93          	addi	s7,s7,770 # 970 <digits>
 676:	03c9d793          	srli	a5,s3,0x3c
 67a:	97de                	add	a5,a5,s7
 67c:	0007c583          	lbu	a1,0(a5)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e1a080e7          	jalr	-486(ra) # 49c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68a:	0992                	slli	s3,s3,0x4
 68c:	397d                	addiw	s2,s2,-1
 68e:	fe0914e3          	bnez	s2,676 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 692:	8be2                	mv	s7,s8
      state = 0;
 694:	4981                	li	s3,0
 696:	bf21                	j	5ae <vprintf+0x44>
        s = va_arg(ap, char*);
 698:	008b8993          	addi	s3,s7,8
 69c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6a0:	02090163          	beqz	s2,6c2 <vprintf+0x158>
        while(*s != 0){
 6a4:	00094583          	lbu	a1,0(s2)
 6a8:	c9a5                	beqz	a1,718 <vprintf+0x1ae>
          putc(fd, *s);
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	df0080e7          	jalr	-528(ra) # 49c <putc>
          s++;
 6b4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6b6:	00094583          	lbu	a1,0(s2)
 6ba:	f9e5                	bnez	a1,6aa <vprintf+0x140>
        s = va_arg(ap, char*);
 6bc:	8bce                	mv	s7,s3
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b5fd                	j	5ae <vprintf+0x44>
          s = "(null)";
 6c2:	00000917          	auipc	s2,0x0
 6c6:	24e90913          	addi	s2,s2,590 # 910 <malloc+0xf4>
        while(*s != 0){
 6ca:	02800593          	li	a1,40
 6ce:	bff1                	j	6aa <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	000bc583          	lbu	a1,0(s7)
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	dc2080e7          	jalr	-574(ra) # 49c <putc>
 6e2:	8bca                	mv	s7,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b5e1                	j	5ae <vprintf+0x44>
        putc(fd, c);
 6e8:	02500593          	li	a1,37
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	dae080e7          	jalr	-594(ra) # 49c <putc>
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bd5d                	j	5ae <vprintf+0x44>
        putc(fd, '%');
 6fa:	02500593          	li	a1,37
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	d9c080e7          	jalr	-612(ra) # 49c <putc>
        putc(fd, c);
 708:	85ca                	mv	a1,s2
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d90080e7          	jalr	-624(ra) # 49c <putc>
      state = 0;
 714:	4981                	li	s3,0
 716:	bd61                	j	5ae <vprintf+0x44>
        s = va_arg(ap, char*);
 718:	8bce                	mv	s7,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd49                	j	5ae <vprintf+0x44>
    }
  }
}
 71e:	60a6                	ld	ra,72(sp)
 720:	6406                	ld	s0,64(sp)
 722:	74e2                	ld	s1,56(sp)
 724:	7942                	ld	s2,48(sp)
 726:	79a2                	ld	s3,40(sp)
 728:	7a02                	ld	s4,32(sp)
 72a:	6ae2                	ld	s5,24(sp)
 72c:	6b42                	ld	s6,16(sp)
 72e:	6ba2                	ld	s7,8(sp)
 730:	6c02                	ld	s8,0(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 736:	715d                	addi	sp,sp,-80
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e010                	sd	a2,0(s0)
 740:	e414                	sd	a3,8(s0)
 742:	e818                	sd	a4,16(s0)
 744:	ec1c                	sd	a5,24(s0)
 746:	03043023          	sd	a6,32(s0)
 74a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 752:	8622                	mv	a2,s0
 754:	00000097          	auipc	ra,0x0
 758:	e16080e7          	jalr	-490(ra) # 56a <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6161                	addi	sp,sp,80
 762:	8082                	ret

0000000000000764 <printf>:

void
printf(const char *fmt, ...)
{
 764:	711d                	addi	sp,sp,-96
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e40c                	sd	a1,8(s0)
 76e:	e810                	sd	a2,16(s0)
 770:	ec14                	sd	a3,24(s0)
 772:	f018                	sd	a4,32(s0)
 774:	f41c                	sd	a5,40(s0)
 776:	03043823          	sd	a6,48(s0)
 77a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	00840613          	addi	a2,s0,8
 782:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 786:	85aa                	mv	a1,a0
 788:	4505                	li	a0,1
 78a:	00000097          	auipc	ra,0x0
 78e:	de0080e7          	jalr	-544(ra) # 56a <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6125                	addi	sp,sp,96
 798:	8082                	ret

000000000000079a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e422                	sd	s0,8(sp)
 79e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	00001797          	auipc	a5,0x1
 7a8:	85c7b783          	ld	a5,-1956(a5) # 1000 <freep>
 7ac:	a02d                	j	7d6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ae:	4618                	lw	a4,8(a2)
 7b0:	9f2d                	addw	a4,a4,a1
 7b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	6310                	ld	a2,0(a4)
 7ba:	a83d                	j	7f8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7bc:	ff852703          	lw	a4,-8(a0)
 7c0:	9f31                	addw	a4,a4,a2
 7c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c4:	ff053683          	ld	a3,-16(a0)
 7c8:	a091                	j	80c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x3a>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x4a>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x30>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059813          	slli	a6,a1,0x20
 7ee:	01c85713          	srli	a4,a6,0x1c
 7f2:	9736                	add	a4,a4,a3
 7f4:	fae60de3          	beq	a2,a4,7ae <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061593          	slli	a1,a2,0x20
 802:	01c5d713          	srli	a4,a1,0x1c
 806:	973e                	add	a4,a4,a5
 808:	fae68ae3          	beq	a3,a4,7bc <free+0x22>
    p->s.ptr = bp->s.ptr;
 80c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80e:	00000717          	auipc	a4,0x0
 812:	7ef73923          	sd	a5,2034(a4) # 1000 <freep>
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret

000000000000081c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
 82e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 830:	02051493          	slli	s1,a0,0x20
 834:	9081                	srli	s1,s1,0x20
 836:	04bd                	addi	s1,s1,15
 838:	8091                	srli	s1,s1,0x4
 83a:	0014899b          	addiw	s3,s1,1
 83e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 840:	00000517          	auipc	a0,0x0
 844:	7c053503          	ld	a0,1984(a0) # 1000 <freep>
 848:	c515                	beqz	a0,874 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84c:	4798                	lw	a4,8(a5)
 84e:	02977f63          	bgeu	a4,s1,88c <malloc+0x70>
  if(nu < 4096)
 852:	8a4e                	mv	s4,s3
 854:	0009871b          	sext.w	a4,s3
 858:	6685                	lui	a3,0x1
 85a:	00d77363          	bgeu	a4,a3,860 <malloc+0x44>
 85e:	6a05                	lui	s4,0x1
 860:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 864:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 868:	00000917          	auipc	s2,0x0
 86c:	79890913          	addi	s2,s2,1944 # 1000 <freep>
  if(p == (char*)-1)
 870:	5afd                	li	s5,-1
 872:	a895                	j	8e6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 874:	00000797          	auipc	a5,0x0
 878:	79c78793          	addi	a5,a5,1948 # 1010 <base>
 87c:	00000717          	auipc	a4,0x0
 880:	78f73223          	sd	a5,1924(a4) # 1000 <freep>
 884:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 886:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88a:	b7e1                	j	852 <malloc+0x36>
      if(p->s.size == nunits)
 88c:	02e48c63          	beq	s1,a4,8c4 <malloc+0xa8>
        p->s.size -= nunits;
 890:	4137073b          	subw	a4,a4,s3
 894:	c798                	sw	a4,8(a5)
        p += p->s.size;
 896:	02071693          	slli	a3,a4,0x20
 89a:	01c6d713          	srli	a4,a3,0x1c
 89e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a4:	00000717          	auipc	a4,0x0
 8a8:	74a73e23          	sd	a0,1884(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b0:	70e2                	ld	ra,56(sp)
 8b2:	7442                	ld	s0,48(sp)
 8b4:	74a2                	ld	s1,40(sp)
 8b6:	7902                	ld	s2,32(sp)
 8b8:	69e2                	ld	s3,24(sp)
 8ba:	6a42                	ld	s4,16(sp)
 8bc:	6aa2                	ld	s5,8(sp)
 8be:	6b02                	ld	s6,0(sp)
 8c0:	6121                	addi	sp,sp,64
 8c2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	e118                	sd	a4,0(a0)
 8c8:	bff1                	j	8a4 <malloc+0x88>
  hp->s.size = nu;
 8ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ce:	0541                	addi	a0,a0,16
 8d0:	00000097          	auipc	ra,0x0
 8d4:	eca080e7          	jalr	-310(ra) # 79a <free>
  return freep;
 8d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8dc:	d971                	beqz	a0,8b0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	fa9775e3          	bgeu	a4,s1,88c <malloc+0x70>
    if(p == freep)
 8e6:	00093703          	ld	a4,0(s2)
 8ea:	853e                	mv	a0,a5
 8ec:	fef719e3          	bne	a4,a5,8de <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8f0:	8552                	mv	a0,s4
 8f2:	00000097          	auipc	ra,0x0
 8f6:	b62080e7          	jalr	-1182(ra) # 454 <sbrk>
  if(p == (char*)-1)
 8fa:	fd5518e3          	bne	a0,s5,8ca <malloc+0xae>
        return 0;
 8fe:	4501                	li	a0,0
 900:	bf45                	j	8b0 <malloc+0x94>
