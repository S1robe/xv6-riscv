
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
  14:	00001517          	auipc	a0,0x1
  18:	93c50513          	addi	a0,a0,-1732 # 950 <malloc+0xf2>
  1c:	00000097          	auipc	ra,0x0
  20:	78a080e7          	jalr	1930(ra) # 7a6 <printf>

   for(i=0; i<argc;i++)
  24:	03305363          	blez	s3,4a <main+0x4a>
  28:	4481                	li	s1,0
     printf("Argument %d: %s\n", i, argv[i]);
  2a:	00001a17          	auipc	s4,0x1
  2e:	956a0a13          	addi	s4,s4,-1706 # 980 <malloc+0x122>
  32:	00093603          	ld	a2,0(s2)
  36:	85a6                	mv	a1,s1
  38:	8552                	mv	a0,s4
  3a:	00000097          	auipc	ra,0x0
  3e:	76c080e7          	jalr	1900(ra) # 7a6 <printf>
   for(i=0; i<argc;i++)
  42:	2485                	addiw	s1,s1,1
  44:	0921                	addi	s2,s2,8
  46:	fe9996e3          	bne	s3,s1,32 <main+0x32>

   exit(0);
  4a:	4501                	li	a0,0
  4c:	00000097          	auipc	ra,0x0
  50:	3c2080e7          	jalr	962(ra) # 40e <exit>

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
  6a:	3a8080e7          	jalr	936(ra) # 40e <exit>

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
 15c:	2ce080e7          	jalr	718(ra) # 426 <read>
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
 1ae:	2a4080e7          	jalr	676(ra) # 44e <open>
  if(fd < 0)
 1b2:	02054563          	bltz	a0,1dc <stat+0x42>
 1b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b8:	85ca                	mv	a1,s2
 1ba:	00000097          	auipc	ra,0x0
 1be:	2ac080e7          	jalr	684(ra) # 466 <fstat>
 1c2:	892a                	mv	s2,a0
  close(fd);
 1c4:	8526                	mv	a0,s1
 1c6:	00000097          	auipc	ra,0x0
 1ca:	270080e7          	jalr	624(ra) # 436 <close>
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

0000000000000228 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
 22e:	8eaa                	mv	t4,a0
    register const char *s = strt;
 230:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 232:	02000693          	li	a3,32
        c = *s++;
 236:	883e                	mv	a6,a5
 238:	0785                	addi	a5,a5,1
 23a:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 23e:	fed70ce3          	beq	a4,a3,236 <strtoi+0xe>
        c = *s++;
 242:	2701                	sext.w	a4,a4

    if (c == '-') {
 244:	02d00693          	li	a3,45
 248:	04d70d63          	beq	a4,a3,2a2 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 24c:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 250:	4f01                	li	t5,0
    } else if (c == '+')
 252:	04d70e63          	beq	a4,a3,2ae <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 256:	fef67693          	andi	a3,a2,-17
 25a:	ea99                	bnez	a3,270 <strtoi+0x48>
 25c:	03000693          	li	a3,48
 260:	04d70c63          	beq	a4,a3,2b8 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 264:	e611                	bnez	a2,270 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 266:	03000693          	li	a3,48
 26a:	0cd70b63          	beq	a4,a3,340 <strtoi+0x118>
 26e:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 270:	800008b7          	lui	a7,0x80000
 274:	fff8c893          	not	a7,a7
 278:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 27c:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 280:	1882                	slli	a7,a7,0x20
 282:	0208d893          	srli	a7,a7,0x20
 286:	02c8d8b3          	divu	a7,a7,a2
 28a:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 28e:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 292:	0ac75163          	bge	a4,a2,334 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 296:	4681                	li	a3,0
 298:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 29a:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 29c:	2881                	sext.w	a7,a7
        else {
            any = 1;
 29e:	4f85                	li	t6,1
 2a0:	a0a9                	j	2ea <strtoi+0xc2>
        c = *s++;
 2a2:	0007c703          	lbu	a4,0(a5)
 2a6:	00280793          	addi	a5,a6,2
        neg = 1;
 2aa:	4f05                	li	t5,1
 2ac:	b76d                	j	256 <strtoi+0x2e>
        c = *s++;
 2ae:	0007c703          	lbu	a4,0(a5)
 2b2:	00280793          	addi	a5,a6,2
 2b6:	b745                	j	256 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 2b8:	0007c683          	lbu	a3,0(a5)
 2bc:	0df6f693          	andi	a3,a3,223
 2c0:	05800513          	li	a0,88
 2c4:	faa690e3          	bne	a3,a0,264 <strtoi+0x3c>
        c = s[1];
 2c8:	0017c703          	lbu	a4,1(a5)
        s += 2;
 2cc:	0789                	addi	a5,a5,2
        base = 16;
 2ce:	4641                	li	a2,16
 2d0:	b745                	j	270 <strtoi+0x48>
            any = -1;
 2d2:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2d4:	00e2c463          	blt	t0,a4,2dc <strtoi+0xb4>
 2d8:	a015                	j	2fc <strtoi+0xd4>
            any = -1;
 2da:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 2dc:	0785                	addi	a5,a5,1
 2de:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 2e2:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 2e6:	02c75063          	bge	a4,a2,306 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2ea:	fe06c8e3          	bltz	a3,2da <strtoi+0xb2>
 2ee:	0005081b          	sext.w	a6,a0
            any = -1;
 2f2:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2f4:	ff0e64e3          	bltu	t3,a6,2dc <strtoi+0xb4>
 2f8:	fca88de3          	beq	a7,a0,2d2 <strtoi+0xaa>
            acc *= base;
 2fc:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 300:	9d39                	addw	a0,a0,a4
            any = 1;
 302:	86fe                	mv	a3,t6
 304:	bfe1                	j	2dc <strtoi+0xb4>
        }
    }
    if (any < 0) {
 306:	0006cd63          	bltz	a3,320 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 30a:	000f0463          	beqz	t5,312 <strtoi+0xea>
        acc = -acc;
 30e:	40a0053b          	negw	a0,a0
    if (end != 0)
 312:	c581                	beqz	a1,31a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 314:	ee89                	bnez	a3,32e <strtoi+0x106>
 316:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 320:	000f1d63          	bnez	t5,33a <strtoi+0x112>
 324:	80000537          	lui	a0,0x80000
 328:	fff54513          	not	a0,a0
    if (end != 0)
 32c:	d5fd                	beqz	a1,31a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 32e:	fff78e93          	addi	t4,a5,-1
 332:	b7d5                	j	316 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 334:	4681                	li	a3,0
 336:	4501                	li	a0,0
 338:	bfc9                	j	30a <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 33a:	80000537          	lui	a0,0x80000
 33e:	b7fd                	j	32c <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 340:	80000e37          	lui	t3,0x80000
 344:	fffe4e13          	not	t3,t3
 348:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 34c:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 350:	003e589b          	srliw	a7,t3,0x3
 354:	8e46                	mv	t3,a7
            c -= '0';
 356:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 358:	4621                	li	a2,8
 35a:	bf35                	j	296 <strtoi+0x6e>

000000000000035c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 362:	02b57463          	bgeu	a0,a1,38a <memmove+0x2e>
    while(n-- > 0)
 366:	00c05f63          	blez	a2,384 <memmove+0x28>
 36a:	1602                	slli	a2,a2,0x20
 36c:	9201                	srli	a2,a2,0x20
 36e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 372:	872a                	mv	a4,a0
      *dst++ = *src++;
 374:	0585                	addi	a1,a1,1
 376:	0705                	addi	a4,a4,1
 378:	fff5c683          	lbu	a3,-1(a1)
 37c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
    dst += n;
 38a:	00c50733          	add	a4,a0,a2
    src += n;
 38e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 390:	fec05ae3          	blez	a2,384 <memmove+0x28>
 394:	fff6079b          	addiw	a5,a2,-1
 398:	1782                	slli	a5,a5,0x20
 39a:	9381                	srli	a5,a5,0x20
 39c:	fff7c793          	not	a5,a5
 3a0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a2:	15fd                	addi	a1,a1,-1
 3a4:	177d                	addi	a4,a4,-1
 3a6:	0005c683          	lbu	a3,0(a1)
 3aa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ae:	fee79ae3          	bne	a5,a4,3a2 <memmove+0x46>
 3b2:	bfc9                	j	384 <memmove+0x28>

00000000000003b4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ba:	ca05                	beqz	a2,3ea <memcmp+0x36>
 3bc:	fff6069b          	addiw	a3,a2,-1
 3c0:	1682                	slli	a3,a3,0x20
 3c2:	9281                	srli	a3,a3,0x20
 3c4:	0685                	addi	a3,a3,1
 3c6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c8:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 3cc:	0005c703          	lbu	a4,0(a1)
 3d0:	00e79863          	bne	a5,a4,3e0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d4:	0505                	addi	a0,a0,1
    p2++;
 3d6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d8:	fed518e3          	bne	a0,a3,3c8 <memcmp+0x14>
  }
  return 0;
 3dc:	4501                	li	a0,0
 3de:	a019                	j	3e4 <memcmp+0x30>
      return *p1 - *p2;
 3e0:	40e7853b          	subw	a0,a5,a4
}
 3e4:	6422                	ld	s0,8(sp)
 3e6:	0141                	addi	sp,sp,16
 3e8:	8082                	ret
  return 0;
 3ea:	4501                	li	a0,0
 3ec:	bfe5                	j	3e4 <memcmp+0x30>

00000000000003ee <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e406                	sd	ra,8(sp)
 3f2:	e022                	sd	s0,0(sp)
 3f4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f6:	00000097          	auipc	ra,0x0
 3fa:	f66080e7          	jalr	-154(ra) # 35c <memmove>
}
 3fe:	60a2                	ld	ra,8(sp)
 400:	6402                	ld	s0,0(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret

0000000000000406 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 406:	4885                	li	a7,1
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exit>:
.global exit
exit:
 li a7, SYS_exit
 40e:	4889                	li	a7,2
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <wait>:
.global wait
wait:
 li a7, SYS_wait
 416:	488d                	li	a7,3
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 41e:	4891                	li	a7,4
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <read>:
.global read
read:
 li a7, SYS_read
 426:	4895                	li	a7,5
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <write>:
.global write
write:
 li a7, SYS_write
 42e:	48c1                	li	a7,16
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <close>:
.global close
close:
 li a7, SYS_close
 436:	48d5                	li	a7,21
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <kill>:
.global kill
kill:
 li a7, SYS_kill
 43e:	4899                	li	a7,6
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exec>:
.global exec
exec:
 li a7, SYS_exec
 446:	489d                	li	a7,7
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <open>:
.global open
open:
 li a7, SYS_open
 44e:	48bd                	li	a7,15
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 456:	48c5                	li	a7,17
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 45e:	48c9                	li	a7,18
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 466:	48a1                	li	a7,8
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <link>:
.global link
link:
 li a7, SYS_link
 46e:	48cd                	li	a7,19
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 476:	48d1                	li	a7,20
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 47e:	48a5                	li	a7,9
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <dup>:
.global dup
dup:
 li a7, SYS_dup
 486:	48a9                	li	a7,10
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 48e:	48ad                	li	a7,11
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 496:	48b1                	li	a7,12
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 49e:	48b5                	li	a7,13
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a6:	48b9                	li	a7,14
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 4ae:	48d9                	li	a7,22
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 4b6:	48dd                	li	a7,23
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 4be:	48e1                	li	a7,24
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 4c6:	48e5                	li	a7,25
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 4ce:	48e9                	li	a7,26
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 4d6:	48ed                	li	a7,27
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4de:	1101                	addi	sp,sp,-32
 4e0:	ec06                	sd	ra,24(sp)
 4e2:	e822                	sd	s0,16(sp)
 4e4:	1000                	addi	s0,sp,32
 4e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ea:	4605                	li	a2,1
 4ec:	fef40593          	addi	a1,s0,-17
 4f0:	00000097          	auipc	ra,0x0
 4f4:	f3e080e7          	jalr	-194(ra) # 42e <write>
}
 4f8:	60e2                	ld	ra,24(sp)
 4fa:	6442                	ld	s0,16(sp)
 4fc:	6105                	addi	sp,sp,32
 4fe:	8082                	ret

0000000000000500 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 500:	7139                	addi	sp,sp,-64
 502:	fc06                	sd	ra,56(sp)
 504:	f822                	sd	s0,48(sp)
 506:	f426                	sd	s1,40(sp)
 508:	f04a                	sd	s2,32(sp)
 50a:	ec4e                	sd	s3,24(sp)
 50c:	0080                	addi	s0,sp,64
 50e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 510:	c299                	beqz	a3,516 <printint+0x16>
 512:	0805c963          	bltz	a1,5a4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 516:	2581                	sext.w	a1,a1
  neg = 0;
 518:	4881                	li	a7,0
 51a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 51e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 520:	2601                	sext.w	a2,a2
 522:	00000517          	auipc	a0,0x0
 526:	4d650513          	addi	a0,a0,1238 # 9f8 <digits>
 52a:	883a                	mv	a6,a4
 52c:	2705                	addiw	a4,a4,1
 52e:	02c5f7bb          	remuw	a5,a1,a2
 532:	1782                	slli	a5,a5,0x20
 534:	9381                	srli	a5,a5,0x20
 536:	97aa                	add	a5,a5,a0
 538:	0007c783          	lbu	a5,0(a5)
 53c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 540:	0005879b          	sext.w	a5,a1
 544:	02c5d5bb          	divuw	a1,a1,a2
 548:	0685                	addi	a3,a3,1
 54a:	fec7f0e3          	bgeu	a5,a2,52a <printint+0x2a>
  if(neg)
 54e:	00088c63          	beqz	a7,566 <printint+0x66>
    buf[i++] = '-';
 552:	fd070793          	addi	a5,a4,-48
 556:	00878733          	add	a4,a5,s0
 55a:	02d00793          	li	a5,45
 55e:	fef70823          	sb	a5,-16(a4)
 562:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 566:	02e05863          	blez	a4,596 <printint+0x96>
 56a:	fc040793          	addi	a5,s0,-64
 56e:	00e78933          	add	s2,a5,a4
 572:	fff78993          	addi	s3,a5,-1
 576:	99ba                	add	s3,s3,a4
 578:	377d                	addiw	a4,a4,-1
 57a:	1702                	slli	a4,a4,0x20
 57c:	9301                	srli	a4,a4,0x20
 57e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 582:	fff94583          	lbu	a1,-1(s2)
 586:	8526                	mv	a0,s1
 588:	00000097          	auipc	ra,0x0
 58c:	f56080e7          	jalr	-170(ra) # 4de <putc>
  while(--i >= 0)
 590:	197d                	addi	s2,s2,-1
 592:	ff3918e3          	bne	s2,s3,582 <printint+0x82>
}
 596:	70e2                	ld	ra,56(sp)
 598:	7442                	ld	s0,48(sp)
 59a:	74a2                	ld	s1,40(sp)
 59c:	7902                	ld	s2,32(sp)
 59e:	69e2                	ld	s3,24(sp)
 5a0:	6121                	addi	sp,sp,64
 5a2:	8082                	ret
    x = -xx;
 5a4:	40b005bb          	negw	a1,a1
    neg = 1;
 5a8:	4885                	li	a7,1
    x = -xx;
 5aa:	bf85                	j	51a <printint+0x1a>

00000000000005ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ac:	715d                	addi	sp,sp,-80
 5ae:	e486                	sd	ra,72(sp)
 5b0:	e0a2                	sd	s0,64(sp)
 5b2:	fc26                	sd	s1,56(sp)
 5b4:	f84a                	sd	s2,48(sp)
 5b6:	f44e                	sd	s3,40(sp)
 5b8:	f052                	sd	s4,32(sp)
 5ba:	ec56                	sd	s5,24(sp)
 5bc:	e85a                	sd	s6,16(sp)
 5be:	e45e                	sd	s7,8(sp)
 5c0:	e062                	sd	s8,0(sp)
 5c2:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c4:	0005c903          	lbu	s2,0(a1)
 5c8:	18090c63          	beqz	s2,760 <vprintf+0x1b4>
 5cc:	8aaa                	mv	s5,a0
 5ce:	8bb2                	mv	s7,a2
 5d0:	00158493          	addi	s1,a1,1
  state = 0;
 5d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d6:	02500a13          	li	s4,37
 5da:	4b55                	li	s6,21
 5dc:	a839                	j	5fa <vprintf+0x4e>
        putc(fd, c);
 5de:	85ca                	mv	a1,s2
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	efc080e7          	jalr	-260(ra) # 4de <putc>
 5ea:	a019                	j	5f0 <vprintf+0x44>
    } else if(state == '%'){
 5ec:	01498d63          	beq	s3,s4,606 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5f0:	0485                	addi	s1,s1,1
 5f2:	fff4c903          	lbu	s2,-1(s1)
 5f6:	16090563          	beqz	s2,760 <vprintf+0x1b4>
    if(state == 0){
 5fa:	fe0999e3          	bnez	s3,5ec <vprintf+0x40>
      if(c == '%'){
 5fe:	ff4910e3          	bne	s2,s4,5de <vprintf+0x32>
        state = '%';
 602:	89d2                	mv	s3,s4
 604:	b7f5                	j	5f0 <vprintf+0x44>
      if(c == 'd'){
 606:	13490263          	beq	s2,s4,72a <vprintf+0x17e>
 60a:	f9d9079b          	addiw	a5,s2,-99
 60e:	0ff7f793          	zext.b	a5,a5
 612:	12fb6563          	bltu	s6,a5,73c <vprintf+0x190>
 616:	f9d9079b          	addiw	a5,s2,-99
 61a:	0ff7f713          	zext.b	a4,a5
 61e:	10eb6f63          	bltu	s6,a4,73c <vprintf+0x190>
 622:	00271793          	slli	a5,a4,0x2
 626:	00000717          	auipc	a4,0x0
 62a:	37a70713          	addi	a4,a4,890 # 9a0 <malloc+0x142>
 62e:	97ba                	add	a5,a5,a4
 630:	439c                	lw	a5,0(a5)
 632:	97ba                	add	a5,a5,a4
 634:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 636:	008b8913          	addi	s2,s7,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000ba583          	lw	a1,0(s7)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	ebc080e7          	jalr	-324(ra) # 500 <printint>
 64c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 64e:	4981                	li	s3,0
 650:	b745                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	ea0080e7          	jalr	-352(ra) # 500 <printint>
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b751                	j	5f0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4641                	li	a2,16
 676:	000ba583          	lw	a1,0(s7)
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e84080e7          	jalr	-380(ra) # 500 <printint>
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
 688:	b7a5                	j	5f0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 68a:	008b8c13          	addi	s8,s7,8
 68e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 692:	03000593          	li	a1,48
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e46080e7          	jalr	-442(ra) # 4de <putc>
  putc(fd, 'x');
 6a0:	07800593          	li	a1,120
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e38080e7          	jalr	-456(ra) # 4de <putc>
 6ae:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	00000b97          	auipc	s7,0x0
 6b4:	348b8b93          	addi	s7,s7,840 # 9f8 <digits>
 6b8:	03c9d793          	srli	a5,s3,0x3c
 6bc:	97de                	add	a5,a5,s7
 6be:	0007c583          	lbu	a1,0(a5)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e1a080e7          	jalr	-486(ra) # 4de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6cc:	0992                	slli	s3,s3,0x4
 6ce:	397d                	addiw	s2,s2,-1
 6d0:	fe0914e3          	bnez	s2,6b8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6d4:	8be2                	mv	s7,s8
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bf21                	j	5f0 <vprintf+0x44>
        s = va_arg(ap, char*);
 6da:	008b8993          	addi	s3,s7,8
 6de:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6e2:	02090163          	beqz	s2,704 <vprintf+0x158>
        while(*s != 0){
 6e6:	00094583          	lbu	a1,0(s2)
 6ea:	c9a5                	beqz	a1,75a <vprintf+0x1ae>
          putc(fd, *s);
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	df0080e7          	jalr	-528(ra) # 4de <putc>
          s++;
 6f6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f8:	00094583          	lbu	a1,0(s2)
 6fc:	f9e5                	bnez	a1,6ec <vprintf+0x140>
        s = va_arg(ap, char*);
 6fe:	8bce                	mv	s7,s3
      state = 0;
 700:	4981                	li	s3,0
 702:	b5fd                	j	5f0 <vprintf+0x44>
          s = "(null)";
 704:	00000917          	auipc	s2,0x0
 708:	29490913          	addi	s2,s2,660 # 998 <malloc+0x13a>
        while(*s != 0){
 70c:	02800593          	li	a1,40
 710:	bff1                	j	6ec <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 712:	008b8913          	addi	s2,s7,8
 716:	000bc583          	lbu	a1,0(s7)
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	dc2080e7          	jalr	-574(ra) # 4de <putc>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	b5e1                	j	5f0 <vprintf+0x44>
        putc(fd, c);
 72a:	02500593          	li	a1,37
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	dae080e7          	jalr	-594(ra) # 4de <putc>
      state = 0;
 738:	4981                	li	s3,0
 73a:	bd5d                	j	5f0 <vprintf+0x44>
        putc(fd, '%');
 73c:	02500593          	li	a1,37
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	d9c080e7          	jalr	-612(ra) # 4de <putc>
        putc(fd, c);
 74a:	85ca                	mv	a1,s2
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	d90080e7          	jalr	-624(ra) # 4de <putc>
      state = 0;
 756:	4981                	li	s3,0
 758:	bd61                	j	5f0 <vprintf+0x44>
        s = va_arg(ap, char*);
 75a:	8bce                	mv	s7,s3
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bd49                	j	5f0 <vprintf+0x44>
    }
  }
}
 760:	60a6                	ld	ra,72(sp)
 762:	6406                	ld	s0,64(sp)
 764:	74e2                	ld	s1,56(sp)
 766:	7942                	ld	s2,48(sp)
 768:	79a2                	ld	s3,40(sp)
 76a:	7a02                	ld	s4,32(sp)
 76c:	6ae2                	ld	s5,24(sp)
 76e:	6b42                	ld	s6,16(sp)
 770:	6ba2                	ld	s7,8(sp)
 772:	6c02                	ld	s8,0(sp)
 774:	6161                	addi	sp,sp,80
 776:	8082                	ret

0000000000000778 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 778:	715d                	addi	sp,sp,-80
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e010                	sd	a2,0(s0)
 782:	e414                	sd	a3,8(s0)
 784:	e818                	sd	a4,16(s0)
 786:	ec1c                	sd	a5,24(s0)
 788:	03043023          	sd	a6,32(s0)
 78c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 794:	8622                	mv	a2,s0
 796:	00000097          	auipc	ra,0x0
 79a:	e16080e7          	jalr	-490(ra) # 5ac <vprintf>
}
 79e:	60e2                	ld	ra,24(sp)
 7a0:	6442                	ld	s0,16(sp)
 7a2:	6161                	addi	sp,sp,80
 7a4:	8082                	ret

00000000000007a6 <printf>:

void
printf(const char *fmt, ...)
{
 7a6:	711d                	addi	sp,sp,-96
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e40c                	sd	a1,8(s0)
 7b0:	e810                	sd	a2,16(s0)
 7b2:	ec14                	sd	a3,24(s0)
 7b4:	f018                	sd	a4,32(s0)
 7b6:	f41c                	sd	a5,40(s0)
 7b8:	03043823          	sd	a6,48(s0)
 7bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c0:	00840613          	addi	a2,s0,8
 7c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c8:	85aa                	mv	a1,a0
 7ca:	4505                	li	a0,1
 7cc:	00000097          	auipc	ra,0x0
 7d0:	de0080e7          	jalr	-544(ra) # 5ac <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6125                	addi	sp,sp,96
 7da:	8082                	ret

00000000000007dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7dc:	1141                	addi	sp,sp,-16
 7de:	e422                	sd	s0,8(sp)
 7e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	00001797          	auipc	a5,0x1
 7ea:	81a7b783          	ld	a5,-2022(a5) # 1000 <freep>
 7ee:	a02d                	j	818 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f0:	4618                	lw	a4,8(a2)
 7f2:	9f2d                	addw	a4,a4,a1
 7f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	6398                	ld	a4,0(a5)
 7fa:	6310                	ld	a2,0(a4)
 7fc:	a83d                	j	83a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9f31                	addw	a4,a4,a2
 804:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053683          	ld	a3,-16(a0)
 80a:	a091                	j	84e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	6398                	ld	a4,0(a5)
 80e:	00e7e463          	bltu	a5,a4,816 <free+0x3a>
 812:	00e6ea63          	bltu	a3,a4,826 <free+0x4a>
{
 816:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	fed7fae3          	bgeu	a5,a3,80c <free+0x30>
 81c:	6398                	ld	a4,0(a5)
 81e:	00e6e463          	bltu	a3,a4,826 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	fee7eae3          	bltu	a5,a4,816 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 826:	ff852583          	lw	a1,-8(a0)
 82a:	6390                	ld	a2,0(a5)
 82c:	02059813          	slli	a6,a1,0x20
 830:	01c85713          	srli	a4,a6,0x1c
 834:	9736                	add	a4,a4,a3
 836:	fae60de3          	beq	a2,a4,7f0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83e:	4790                	lw	a2,8(a5)
 840:	02061593          	slli	a1,a2,0x20
 844:	01c5d713          	srli	a4,a1,0x1c
 848:	973e                	add	a4,a4,a5
 84a:	fae68ae3          	beq	a3,a4,7fe <free+0x22>
    p->s.ptr = bp->s.ptr;
 84e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 850:	00000717          	auipc	a4,0x0
 854:	7af73823          	sd	a5,1968(a4) # 1000 <freep>
}
 858:	6422                	ld	s0,8(sp)
 85a:	0141                	addi	sp,sp,16
 85c:	8082                	ret

000000000000085e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85e:	7139                	addi	sp,sp,-64
 860:	fc06                	sd	ra,56(sp)
 862:	f822                	sd	s0,48(sp)
 864:	f426                	sd	s1,40(sp)
 866:	f04a                	sd	s2,32(sp)
 868:	ec4e                	sd	s3,24(sp)
 86a:	e852                	sd	s4,16(sp)
 86c:	e456                	sd	s5,8(sp)
 86e:	e05a                	sd	s6,0(sp)
 870:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 872:	02051493          	slli	s1,a0,0x20
 876:	9081                	srli	s1,s1,0x20
 878:	04bd                	addi	s1,s1,15
 87a:	8091                	srli	s1,s1,0x4
 87c:	0014899b          	addiw	s3,s1,1
 880:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 882:	00000517          	auipc	a0,0x0
 886:	77e53503          	ld	a0,1918(a0) # 1000 <freep>
 88a:	c515                	beqz	a0,8b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	02977f63          	bgeu	a4,s1,8ce <malloc+0x70>
  if(nu < 4096)
 894:	8a4e                	mv	s4,s3
 896:	0009871b          	sext.w	a4,s3
 89a:	6685                	lui	a3,0x1
 89c:	00d77363          	bgeu	a4,a3,8a2 <malloc+0x44>
 8a0:	6a05                	lui	s4,0x1
 8a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8aa:	00000917          	auipc	s2,0x0
 8ae:	75690913          	addi	s2,s2,1878 # 1000 <freep>
  if(p == (char*)-1)
 8b2:	5afd                	li	s5,-1
 8b4:	a895                	j	928 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8b6:	00000797          	auipc	a5,0x0
 8ba:	75a78793          	addi	a5,a5,1882 # 1010 <base>
 8be:	00000717          	auipc	a4,0x0
 8c2:	74f73123          	sd	a5,1858(a4) # 1000 <freep>
 8c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8cc:	b7e1                	j	894 <malloc+0x36>
      if(p->s.size == nunits)
 8ce:	02e48c63          	beq	s1,a4,906 <malloc+0xa8>
        p->s.size -= nunits;
 8d2:	4137073b          	subw	a4,a4,s3
 8d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d8:	02071693          	slli	a3,a4,0x20
 8dc:	01c6d713          	srli	a4,a3,0x1c
 8e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70a73d23          	sd	a0,1818(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ee:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f2:	70e2                	ld	ra,56(sp)
 8f4:	7442                	ld	s0,48(sp)
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	7902                	ld	s2,32(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	bff1                	j	8e6 <malloc+0x88>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	00000097          	auipc	ra,0x0
 916:	eca080e7          	jalr	-310(ra) # 7dc <free>
  return freep;
 91a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91e:	d971                	beqz	a0,8f2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	fa9775e3          	bgeu	a4,s1,8ce <malloc+0x70>
    if(p == freep)
 928:	00093703          	ld	a4,0(s2)
 92c:	853e                	mv	a0,a5
 92e:	fef719e3          	bne	a4,a5,920 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 932:	8552                	mv	a0,s4
 934:	00000097          	auipc	ra,0x0
 938:	b62080e7          	jalr	-1182(ra) # 496 <sbrk>
  if(p == (char*)-1)
 93c:	fd5518e3          	bne	a0,s5,90c <malloc+0xae>
        return 0;
 940:	4501                	li	a0,0
 942:	bf45                	j	8f2 <malloc+0x94>
