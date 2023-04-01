
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	41e080e7          	jalr	1054(ra) # 44e <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	3de080e7          	jalr	990(ra) # 41e <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	91858593          	addi	a1,a1,-1768 # 960 <malloc+0xf2>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	736080e7          	jalr	1846(ra) # 788 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	3c2080e7          	jalr	962(ra) # 41e <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	3a8080e7          	jalr	936(ra) # 41e <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	86be                	mv	a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	ff65                	bnez	a4,d6 <strlen+0x10>
  e0:	40a6853b          	subw	a0,a3,a0
  e4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	2ce080e7          	jalr	718(ra) # 436 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	2a4080e7          	jalr	676(ra) # 45e <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2ac080e7          	jalr	684(ra) # 476 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	270080e7          	jalr	624(ra) # 446 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054683          	lbu	a3,0(a0)
 1fa:	fd06879b          	addiw	a5,a3,-48
 1fe:	0ff7f793          	zext.b	a5,a5
 202:	4625                	li	a2,9
 204:	02f66863          	bltu	a2,a5,234 <atoi+0x44>
 208:	872a                	mv	a4,a0
  n = 0;
 20a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 20c:	0705                	addi	a4,a4,1
 20e:	0025179b          	slliw	a5,a0,0x2
 212:	9fa9                	addw	a5,a5,a0
 214:	0017979b          	slliw	a5,a5,0x1
 218:	9fb5                	addw	a5,a5,a3
 21a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21e:	00074683          	lbu	a3,0(a4)
 222:	fd06879b          	addiw	a5,a3,-48
 226:	0ff7f793          	zext.b	a5,a5
 22a:	fef671e3          	bgeu	a2,a5,20c <atoi+0x1c>

  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  n = 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <atoi+0x3e>

0000000000000238 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
 23e:	8eaa                	mv	t4,a0
    register const char *s = strt;
 240:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 242:	02000693          	li	a3,32
        c = *s++;
 246:	883e                	mv	a6,a5
 248:	0785                	addi	a5,a5,1
 24a:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 24e:	fed70ce3          	beq	a4,a3,246 <strtoi+0xe>
        c = *s++;
 252:	2701                	sext.w	a4,a4

    if (c == '-') {
 254:	02d00693          	li	a3,45
 258:	04d70d63          	beq	a4,a3,2b2 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 25c:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 260:	4f01                	li	t5,0
    } else if (c == '+')
 262:	04d70e63          	beq	a4,a3,2be <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 266:	fef67693          	andi	a3,a2,-17
 26a:	ea99                	bnez	a3,280 <strtoi+0x48>
 26c:	03000693          	li	a3,48
 270:	04d70c63          	beq	a4,a3,2c8 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 274:	e611                	bnez	a2,280 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 276:	03000693          	li	a3,48
 27a:	0cd70b63          	beq	a4,a3,350 <strtoi+0x118>
 27e:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 280:	800008b7          	lui	a7,0x80000
 284:	fff8c893          	not	a7,a7
 288:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 28c:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 290:	1882                	slli	a7,a7,0x20
 292:	0208d893          	srli	a7,a7,0x20
 296:	02c8d8b3          	divu	a7,a7,a2
 29a:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 29e:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 2a2:	0ac75163          	bge	a4,a2,344 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 2a6:	4681                	li	a3,0
 2a8:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 2aa:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2ac:	2881                	sext.w	a7,a7
        else {
            any = 1;
 2ae:	4f85                	li	t6,1
 2b0:	a0a9                	j	2fa <strtoi+0xc2>
        c = *s++;
 2b2:	0007c703          	lbu	a4,0(a5)
 2b6:	00280793          	addi	a5,a6,2
        neg = 1;
 2ba:	4f05                	li	t5,1
 2bc:	b76d                	j	266 <strtoi+0x2e>
        c = *s++;
 2be:	0007c703          	lbu	a4,0(a5)
 2c2:	00280793          	addi	a5,a6,2
 2c6:	b745                	j	266 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 2c8:	0007c683          	lbu	a3,0(a5)
 2cc:	0df6f693          	andi	a3,a3,223
 2d0:	05800513          	li	a0,88
 2d4:	faa690e3          	bne	a3,a0,274 <strtoi+0x3c>
        c = s[1];
 2d8:	0017c703          	lbu	a4,1(a5)
        s += 2;
 2dc:	0789                	addi	a5,a5,2
        base = 16;
 2de:	4641                	li	a2,16
 2e0:	b745                	j	280 <strtoi+0x48>
            any = -1;
 2e2:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2e4:	00e2c463          	blt	t0,a4,2ec <strtoi+0xb4>
 2e8:	a015                	j	30c <strtoi+0xd4>
            any = -1;
 2ea:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 2ec:	0785                	addi	a5,a5,1
 2ee:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 2f2:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 2f6:	02c75063          	bge	a4,a2,316 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2fa:	fe06c8e3          	bltz	a3,2ea <strtoi+0xb2>
 2fe:	0005081b          	sext.w	a6,a0
            any = -1;
 302:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 304:	ff0e64e3          	bltu	t3,a6,2ec <strtoi+0xb4>
 308:	fca88de3          	beq	a7,a0,2e2 <strtoi+0xaa>
            acc *= base;
 30c:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 310:	9d39                	addw	a0,a0,a4
            any = 1;
 312:	86fe                	mv	a3,t6
 314:	bfe1                	j	2ec <strtoi+0xb4>
        }
    }
    if (any < 0) {
 316:	0006cd63          	bltz	a3,330 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 31a:	000f0463          	beqz	t5,322 <strtoi+0xea>
        acc = -acc;
 31e:	40a0053b          	negw	a0,a0
    if (end != 0)
 322:	c581                	beqz	a1,32a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 324:	ee89                	bnez	a3,33e <strtoi+0x106>
 326:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 330:	000f1d63          	bnez	t5,34a <strtoi+0x112>
 334:	80000537          	lui	a0,0x80000
 338:	fff54513          	not	a0,a0
    if (end != 0)
 33c:	d5fd                	beqz	a1,32a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 33e:	fff78e93          	addi	t4,a5,-1
 342:	b7d5                	j	326 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 344:	4681                	li	a3,0
 346:	4501                	li	a0,0
 348:	bfc9                	j	31a <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 34a:	80000537          	lui	a0,0x80000
 34e:	b7fd                	j	33c <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 350:	80000e37          	lui	t3,0x80000
 354:	fffe4e13          	not	t3,t3
 358:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 35c:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 360:	003e589b          	srliw	a7,t3,0x3
 364:	8e46                	mv	t3,a7
            c -= '0';
 366:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 368:	4621                	li	a2,8
 36a:	bf35                	j	2a6 <strtoi+0x6e>

000000000000036c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 372:	02b57463          	bgeu	a0,a1,39a <memmove+0x2e>
    while(n-- > 0)
 376:	00c05f63          	blez	a2,394 <memmove+0x28>
 37a:	1602                	slli	a2,a2,0x20
 37c:	9201                	srli	a2,a2,0x20
 37e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 382:	872a                	mv	a4,a0
      *dst++ = *src++;
 384:	0585                	addi	a1,a1,1
 386:	0705                	addi	a4,a4,1
 388:	fff5c683          	lbu	a3,-1(a1)
 38c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 390:	fee79ae3          	bne	a5,a4,384 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 394:	6422                	ld	s0,8(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
    dst += n;
 39a:	00c50733          	add	a4,a0,a2
    src += n;
 39e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3a0:	fec05ae3          	blez	a2,394 <memmove+0x28>
 3a4:	fff6079b          	addiw	a5,a2,-1
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	fff7c793          	not	a5,a5
 3b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b2:	15fd                	addi	a1,a1,-1
 3b4:	177d                	addi	a4,a4,-1
 3b6:	0005c683          	lbu	a3,0(a1)
 3ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3be:	fee79ae3          	bne	a5,a4,3b2 <memmove+0x46>
 3c2:	bfc9                	j	394 <memmove+0x28>

00000000000003c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e422                	sd	s0,8(sp)
 3c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ca:	ca05                	beqz	a2,3fa <memcmp+0x36>
 3cc:	fff6069b          	addiw	a3,a2,-1
 3d0:	1682                	slli	a3,a3,0x20
 3d2:	9281                	srli	a3,a3,0x20
 3d4:	0685                	addi	a3,a3,1
 3d6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d8:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 3dc:	0005c703          	lbu	a4,0(a1)
 3e0:	00e79863          	bne	a5,a4,3f0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3e4:	0505                	addi	a0,a0,1
    p2++;
 3e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e8:	fed518e3          	bne	a0,a3,3d8 <memcmp+0x14>
  }
  return 0;
 3ec:	4501                	li	a0,0
 3ee:	a019                	j	3f4 <memcmp+0x30>
      return *p1 - *p2;
 3f0:	40e7853b          	subw	a0,a5,a4
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
  return 0;
 3fa:	4501                	li	a0,0
 3fc:	bfe5                	j	3f4 <memcmp+0x30>

00000000000003fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 406:	00000097          	auipc	ra,0x0
 40a:	f66080e7          	jalr	-154(ra) # 36c <memmove>
}
 40e:	60a2                	ld	ra,8(sp)
 410:	6402                	ld	s0,0(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret

0000000000000416 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 416:	4885                	li	a7,1
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <exit>:
.global exit
exit:
 li a7, SYS_exit
 41e:	4889                	li	a7,2
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <wait>:
.global wait
wait:
 li a7, SYS_wait
 426:	488d                	li	a7,3
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42e:	4891                	li	a7,4
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <read>:
.global read
read:
 li a7, SYS_read
 436:	4895                	li	a7,5
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <write>:
.global write
write:
 li a7, SYS_write
 43e:	48c1                	li	a7,16
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <close>:
.global close
close:
 li a7, SYS_close
 446:	48d5                	li	a7,21
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <kill>:
.global kill
kill:
 li a7, SYS_kill
 44e:	4899                	li	a7,6
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <exec>:
.global exec
exec:
 li a7, SYS_exec
 456:	489d                	li	a7,7
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <open>:
.global open
open:
 li a7, SYS_open
 45e:	48bd                	li	a7,15
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 466:	48c5                	li	a7,17
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46e:	48c9                	li	a7,18
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 476:	48a1                	li	a7,8
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <link>:
.global link
link:
 li a7, SYS_link
 47e:	48cd                	li	a7,19
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 486:	48d1                	li	a7,20
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48e:	48a5                	li	a7,9
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <dup>:
.global dup
dup:
 li a7, SYS_dup
 496:	48a9                	li	a7,10
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49e:	48ad                	li	a7,11
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4a6:	48b1                	li	a7,12
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ae:	48b5                	li	a7,13
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b6:	48b9                	li	a7,14
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 4be:	48d9                	li	a7,22
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 4c6:	48dd                	li	a7,23
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 4ce:	48e1                	li	a7,24
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 4d6:	48e5                	li	a7,25
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 4de:	48e9                	li	a7,26
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 4e6:	48ed                	li	a7,27
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ee:	1101                	addi	sp,sp,-32
 4f0:	ec06                	sd	ra,24(sp)
 4f2:	e822                	sd	s0,16(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fa:	4605                	li	a2,1
 4fc:	fef40593          	addi	a1,s0,-17
 500:	00000097          	auipc	ra,0x0
 504:	f3e080e7          	jalr	-194(ra) # 43e <write>
}
 508:	60e2                	ld	ra,24(sp)
 50a:	6442                	ld	s0,16(sp)
 50c:	6105                	addi	sp,sp,32
 50e:	8082                	ret

0000000000000510 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 510:	7139                	addi	sp,sp,-64
 512:	fc06                	sd	ra,56(sp)
 514:	f822                	sd	s0,48(sp)
 516:	f426                	sd	s1,40(sp)
 518:	f04a                	sd	s2,32(sp)
 51a:	ec4e                	sd	s3,24(sp)
 51c:	0080                	addi	s0,sp,64
 51e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 520:	c299                	beqz	a3,526 <printint+0x16>
 522:	0805c963          	bltz	a1,5b4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 526:	2581                	sext.w	a1,a1
  neg = 0;
 528:	4881                	li	a7,0
 52a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	2601                	sext.w	a2,a2
 532:	00000517          	auipc	a0,0x0
 536:	4a650513          	addi	a0,a0,1190 # 9d8 <digits>
 53a:	883a                	mv	a6,a4
 53c:	2705                	addiw	a4,a4,1
 53e:	02c5f7bb          	remuw	a5,a1,a2
 542:	1782                	slli	a5,a5,0x20
 544:	9381                	srli	a5,a5,0x20
 546:	97aa                	add	a5,a5,a0
 548:	0007c783          	lbu	a5,0(a5)
 54c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 550:	0005879b          	sext.w	a5,a1
 554:	02c5d5bb          	divuw	a1,a1,a2
 558:	0685                	addi	a3,a3,1
 55a:	fec7f0e3          	bgeu	a5,a2,53a <printint+0x2a>
  if(neg)
 55e:	00088c63          	beqz	a7,576 <printint+0x66>
    buf[i++] = '-';
 562:	fd070793          	addi	a5,a4,-48
 566:	00878733          	add	a4,a5,s0
 56a:	02d00793          	li	a5,45
 56e:	fef70823          	sb	a5,-16(a4)
 572:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 576:	02e05863          	blez	a4,5a6 <printint+0x96>
 57a:	fc040793          	addi	a5,s0,-64
 57e:	00e78933          	add	s2,a5,a4
 582:	fff78993          	addi	s3,a5,-1
 586:	99ba                	add	s3,s3,a4
 588:	377d                	addiw	a4,a4,-1
 58a:	1702                	slli	a4,a4,0x20
 58c:	9301                	srli	a4,a4,0x20
 58e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 592:	fff94583          	lbu	a1,-1(s2)
 596:	8526                	mv	a0,s1
 598:	00000097          	auipc	ra,0x0
 59c:	f56080e7          	jalr	-170(ra) # 4ee <putc>
  while(--i >= 0)
 5a0:	197d                	addi	s2,s2,-1
 5a2:	ff3918e3          	bne	s2,s3,592 <printint+0x82>
}
 5a6:	70e2                	ld	ra,56(sp)
 5a8:	7442                	ld	s0,48(sp)
 5aa:	74a2                	ld	s1,40(sp)
 5ac:	7902                	ld	s2,32(sp)
 5ae:	69e2                	ld	s3,24(sp)
 5b0:	6121                	addi	sp,sp,64
 5b2:	8082                	ret
    x = -xx;
 5b4:	40b005bb          	negw	a1,a1
    neg = 1;
 5b8:	4885                	li	a7,1
    x = -xx;
 5ba:	bf85                	j	52a <printint+0x1a>

00000000000005bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5bc:	715d                	addi	sp,sp,-80
 5be:	e486                	sd	ra,72(sp)
 5c0:	e0a2                	sd	s0,64(sp)
 5c2:	fc26                	sd	s1,56(sp)
 5c4:	f84a                	sd	s2,48(sp)
 5c6:	f44e                	sd	s3,40(sp)
 5c8:	f052                	sd	s4,32(sp)
 5ca:	ec56                	sd	s5,24(sp)
 5cc:	e85a                	sd	s6,16(sp)
 5ce:	e45e                	sd	s7,8(sp)
 5d0:	e062                	sd	s8,0(sp)
 5d2:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d4:	0005c903          	lbu	s2,0(a1)
 5d8:	18090c63          	beqz	s2,770 <vprintf+0x1b4>
 5dc:	8aaa                	mv	s5,a0
 5de:	8bb2                	mv	s7,a2
 5e0:	00158493          	addi	s1,a1,1
  state = 0;
 5e4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e6:	02500a13          	li	s4,37
 5ea:	4b55                	li	s6,21
 5ec:	a839                	j	60a <vprintf+0x4e>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	efc080e7          	jalr	-260(ra) # 4ee <putc>
 5fa:	a019                	j	600 <vprintf+0x44>
    } else if(state == '%'){
 5fc:	01498d63          	beq	s3,s4,616 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 600:	0485                	addi	s1,s1,1
 602:	fff4c903          	lbu	s2,-1(s1)
 606:	16090563          	beqz	s2,770 <vprintf+0x1b4>
    if(state == 0){
 60a:	fe0999e3          	bnez	s3,5fc <vprintf+0x40>
      if(c == '%'){
 60e:	ff4910e3          	bne	s2,s4,5ee <vprintf+0x32>
        state = '%';
 612:	89d2                	mv	s3,s4
 614:	b7f5                	j	600 <vprintf+0x44>
      if(c == 'd'){
 616:	13490263          	beq	s2,s4,73a <vprintf+0x17e>
 61a:	f9d9079b          	addiw	a5,s2,-99
 61e:	0ff7f793          	zext.b	a5,a5
 622:	12fb6563          	bltu	s6,a5,74c <vprintf+0x190>
 626:	f9d9079b          	addiw	a5,s2,-99
 62a:	0ff7f713          	zext.b	a4,a5
 62e:	10eb6f63          	bltu	s6,a4,74c <vprintf+0x190>
 632:	00271793          	slli	a5,a4,0x2
 636:	00000717          	auipc	a4,0x0
 63a:	34a70713          	addi	a4,a4,842 # 980 <malloc+0x112>
 63e:	97ba                	add	a5,a5,a4
 640:	439c                	lw	a5,0(a5)
 642:	97ba                	add	a5,a5,a4
 644:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000ba583          	lw	a1,0(s7)
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	ebc080e7          	jalr	-324(ra) # 510 <printint>
 65c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 65e:	4981                	li	s3,0
 660:	b745                	j	600 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000ba583          	lw	a1,0(s7)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	ea0080e7          	jalr	-352(ra) # 510 <printint>
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b751                	j	600 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000ba583          	lw	a1,0(s7)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e84080e7          	jalr	-380(ra) # 510 <printint>
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	b7a5                	j	600 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 69a:	008b8c13          	addi	s8,s7,8
 69e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a2:	03000593          	li	a1,48
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e46080e7          	jalr	-442(ra) # 4ee <putc>
  putc(fd, 'x');
 6b0:	07800593          	li	a1,120
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e38080e7          	jalr	-456(ra) # 4ee <putc>
 6be:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c0:	00000b97          	auipc	s7,0x0
 6c4:	318b8b93          	addi	s7,s7,792 # 9d8 <digits>
 6c8:	03c9d793          	srli	a5,s3,0x3c
 6cc:	97de                	add	a5,a5,s7
 6ce:	0007c583          	lbu	a1,0(a5)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e1a080e7          	jalr	-486(ra) # 4ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6dc:	0992                	slli	s3,s3,0x4
 6de:	397d                	addiw	s2,s2,-1
 6e0:	fe0914e3          	bnez	s2,6c8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6e4:	8be2                	mv	s7,s8
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bf21                	j	600 <vprintf+0x44>
        s = va_arg(ap, char*);
 6ea:	008b8993          	addi	s3,s7,8
 6ee:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6f2:	02090163          	beqz	s2,714 <vprintf+0x158>
        while(*s != 0){
 6f6:	00094583          	lbu	a1,0(s2)
 6fa:	c9a5                	beqz	a1,76a <vprintf+0x1ae>
          putc(fd, *s);
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	df0080e7          	jalr	-528(ra) # 4ee <putc>
          s++;
 706:	0905                	addi	s2,s2,1
        while(*s != 0){
 708:	00094583          	lbu	a1,0(s2)
 70c:	f9e5                	bnez	a1,6fc <vprintf+0x140>
        s = va_arg(ap, char*);
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	b5fd                	j	600 <vprintf+0x44>
          s = "(null)";
 714:	00000917          	auipc	s2,0x0
 718:	26490913          	addi	s2,s2,612 # 978 <malloc+0x10a>
        while(*s != 0){
 71c:	02800593          	li	a1,40
 720:	bff1                	j	6fc <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 722:	008b8913          	addi	s2,s7,8
 726:	000bc583          	lbu	a1,0(s7)
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	dc2080e7          	jalr	-574(ra) # 4ee <putc>
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	b5e1                	j	600 <vprintf+0x44>
        putc(fd, c);
 73a:	02500593          	li	a1,37
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	dae080e7          	jalr	-594(ra) # 4ee <putc>
      state = 0;
 748:	4981                	li	s3,0
 74a:	bd5d                	j	600 <vprintf+0x44>
        putc(fd, '%');
 74c:	02500593          	li	a1,37
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	d9c080e7          	jalr	-612(ra) # 4ee <putc>
        putc(fd, c);
 75a:	85ca                	mv	a1,s2
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	d90080e7          	jalr	-624(ra) # 4ee <putc>
      state = 0;
 766:	4981                	li	s3,0
 768:	bd61                	j	600 <vprintf+0x44>
        s = va_arg(ap, char*);
 76a:	8bce                	mv	s7,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bd49                	j	600 <vprintf+0x44>
    }
  }
}
 770:	60a6                	ld	ra,72(sp)
 772:	6406                	ld	s0,64(sp)
 774:	74e2                	ld	s1,56(sp)
 776:	7942                	ld	s2,48(sp)
 778:	79a2                	ld	s3,40(sp)
 77a:	7a02                	ld	s4,32(sp)
 77c:	6ae2                	ld	s5,24(sp)
 77e:	6b42                	ld	s6,16(sp)
 780:	6ba2                	ld	s7,8(sp)
 782:	6c02                	ld	s8,0(sp)
 784:	6161                	addi	sp,sp,80
 786:	8082                	ret

0000000000000788 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 788:	715d                	addi	sp,sp,-80
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e010                	sd	a2,0(s0)
 792:	e414                	sd	a3,8(s0)
 794:	e818                	sd	a4,16(s0)
 796:	ec1c                	sd	a5,24(s0)
 798:	03043023          	sd	a6,32(s0)
 79c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a4:	8622                	mv	a2,s0
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e16080e7          	jalr	-490(ra) # 5bc <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6161                	addi	sp,sp,80
 7b4:	8082                	ret

00000000000007b6 <printf>:

void
printf(const char *fmt, ...)
{
 7b6:	711d                	addi	sp,sp,-96
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	1000                	addi	s0,sp,32
 7be:	e40c                	sd	a1,8(s0)
 7c0:	e810                	sd	a2,16(s0)
 7c2:	ec14                	sd	a3,24(s0)
 7c4:	f018                	sd	a4,32(s0)
 7c6:	f41c                	sd	a5,40(s0)
 7c8:	03043823          	sd	a6,48(s0)
 7cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	00840613          	addi	a2,s0,8
 7d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d8:	85aa                	mv	a1,a0
 7da:	4505                	li	a0,1
 7dc:	00000097          	auipc	ra,0x0
 7e0:	de0080e7          	jalr	-544(ra) # 5bc <vprintf>
}
 7e4:	60e2                	ld	ra,24(sp)
 7e6:	6442                	ld	s0,16(sp)
 7e8:	6125                	addi	sp,sp,96
 7ea:	8082                	ret

00000000000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f6:	00001797          	auipc	a5,0x1
 7fa:	80a7b783          	ld	a5,-2038(a5) # 1000 <freep>
 7fe:	a02d                	j	828 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 800:	4618                	lw	a4,8(a2)
 802:	9f2d                	addw	a4,a4,a1
 804:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	6310                	ld	a2,0(a4)
 80c:	a83d                	j	84a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80e:	ff852703          	lw	a4,-8(a0)
 812:	9f31                	addw	a4,a4,a2
 814:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 816:	ff053683          	ld	a3,-16(a0)
 81a:	a091                	j	85e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x3a>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x4a>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x30>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059813          	slli	a6,a1,0x20
 840:	01c85713          	srli	a4,a6,0x1c
 844:	9736                	add	a4,a4,a3
 846:	fae60de3          	beq	a2,a4,800 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061593          	slli	a1,a2,0x20
 854:	01c5d713          	srli	a4,a1,0x1c
 858:	973e                	add	a4,a4,a5
 85a:	fae68ae3          	beq	a3,a4,80e <free+0x22>
    p->s.ptr = bp->s.ptr;
 85e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86e:	7139                	addi	sp,sp,-64
 870:	fc06                	sd	ra,56(sp)
 872:	f822                	sd	s0,48(sp)
 874:	f426                	sd	s1,40(sp)
 876:	f04a                	sd	s2,32(sp)
 878:	ec4e                	sd	s3,24(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
 880:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 882:	02051493          	slli	s1,a0,0x20
 886:	9081                	srli	s1,s1,0x20
 888:	04bd                	addi	s1,s1,15
 88a:	8091                	srli	s1,s1,0x4
 88c:	0014899b          	addiw	s3,s1,1
 890:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 892:	00000517          	auipc	a0,0x0
 896:	76e53503          	ld	a0,1902(a0) # 1000 <freep>
 89a:	c515                	beqz	a0,8c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977f63          	bgeu	a4,s1,8de <malloc+0x70>
  if(nu < 4096)
 8a4:	8a4e                	mv	s4,s3
 8a6:	0009871b          	sext.w	a4,s3
 8aa:	6685                	lui	a3,0x1
 8ac:	00d77363          	bgeu	a4,a3,8b2 <malloc+0x44>
 8b0:	6a05                	lui	s4,0x1
 8b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ba:	00000917          	auipc	s2,0x0
 8be:	74690913          	addi	s2,s2,1862 # 1000 <freep>
  if(p == (char*)-1)
 8c2:	5afd                	li	s5,-1
 8c4:	a895                	j	938 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8c6:	00000797          	auipc	a5,0x0
 8ca:	74a78793          	addi	a5,a5,1866 # 1010 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8dc:	b7e1                	j	8a4 <malloc+0x36>
      if(p->s.size == nunits)
 8de:	02e48c63          	beq	s1,a4,916 <malloc+0xa8>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	02071693          	slli	a3,a4,0x20
 8ec:	01c6d713          	srli	a4,a3,0x1c
 8f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70a73523          	sd	a0,1802(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fe:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 902:	70e2                	ld	ra,56(sp)
 904:	7442                	ld	s0,48(sp)
 906:	74a2                	ld	s1,40(sp)
 908:	7902                	ld	s2,32(sp)
 90a:	69e2                	ld	s3,24(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
 912:	6121                	addi	sp,sp,64
 914:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	bff1                	j	8f6 <malloc+0x88>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	00000097          	auipc	ra,0x0
 926:	eca080e7          	jalr	-310(ra) # 7ec <free>
  return freep;
 92a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92e:	d971                	beqz	a0,902 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	fa9775e3          	bgeu	a4,s1,8de <malloc+0x70>
    if(p == freep)
 938:	00093703          	ld	a4,0(s2)
 93c:	853e                	mv	a0,a5
 93e:	fef719e3          	bne	a4,a5,930 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	00000097          	auipc	ra,0x0
 948:	b62080e7          	jalr	-1182(ra) # 4a6 <sbrk>
  if(p == (char*)-1)
 94c:	fd5518e3          	bne	a0,s5,91c <malloc+0xae>
        return 0;
 950:	4501                	li	a0,0
 952:	bf45                	j	902 <malloc+0x94>
