
user/_rm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
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
   e:	02a7d763          	bge	a5,a0,3c <main+0x3c>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: rm files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(unlink(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	458080e7          	jalr	1112(ra) # 480 <unlink>
  30:	02054463          	bltz	a0,58 <main+0x58>
  for(i = 1; i < argc; i++){
  34:	04a1                	addi	s1,s1,8
  36:	ff2498e3          	bne	s1,s2,26 <main+0x26>
  3a:	a80d                	j	6c <main+0x6c>
    fprintf(2, "Usage: rm files...\n");
  3c:	00001597          	auipc	a1,0x1
  40:	93458593          	addi	a1,a1,-1740 # 970 <malloc+0xf0>
  44:	4509                	li	a0,2
  46:	00000097          	auipc	ra,0x0
  4a:	754080e7          	jalr	1876(ra) # 79a <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	00000097          	auipc	ra,0x0
  54:	3e0080e7          	jalr	992(ra) # 430 <exit>
      fprintf(2, "rm: %s failed to delete\n", argv[i]);
  58:	6090                	ld	a2,0(s1)
  5a:	00001597          	auipc	a1,0x1
  5e:	92e58593          	addi	a1,a1,-1746 # 988 <malloc+0x108>
  62:	4509                	li	a0,2
  64:	00000097          	auipc	ra,0x0
  68:	736080e7          	jalr	1846(ra) # 79a <fprintf>
      break;
    }
  }

  exit(0);
  6c:	4501                	li	a0,0
  6e:	00000097          	auipc	ra,0x0
  72:	3c2080e7          	jalr	962(ra) # 430 <exit>

0000000000000076 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  76:	1141                	addi	sp,sp,-16
  78:	e406                	sd	ra,8(sp)
  7a:	e022                	sd	s0,0(sp)
  7c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  7e:	00000097          	auipc	ra,0x0
  82:	f82080e7          	jalr	-126(ra) # 0 <main>
  exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	3a8080e7          	jalr	936(ra) # 430 <exit>

0000000000000090 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  96:	87aa                	mv	a5,a0
  98:	0585                	addi	a1,a1,1
  9a:	0785                	addi	a5,a5,1
  9c:	fff5c703          	lbu	a4,-1(a1)
  a0:	fee78fa3          	sb	a4,-1(a5)
  a4:	fb75                	bnez	a4,98 <strcpy+0x8>
    ;
  return os;
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cb91                	beqz	a5,ca <strcmp+0x1e>
  b8:	0005c703          	lbu	a4,0(a1)
  bc:	00f71763          	bne	a4,a5,ca <strcmp+0x1e>
    p++, q++;
  c0:	0505                	addi	a0,a0,1
  c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	fbe5                	bnez	a5,b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ca:	0005c503          	lbu	a0,0(a1)
}
  ce:	40a7853b          	subw	a0,a5,a0
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strlen>:

uint
strlen(const char *s)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cf91                	beqz	a5,fe <strlen+0x26>
  e4:	0505                	addi	a0,a0,1
  e6:	87aa                	mv	a5,a0
  e8:	86be                	mv	a3,a5
  ea:	0785                	addi	a5,a5,1
  ec:	fff7c703          	lbu	a4,-1(a5)
  f0:	ff65                	bnez	a4,e8 <strlen+0x10>
  f2:	40a6853b          	subw	a0,a3,a0
  f6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret
  for(n = 0; s[n]; n++)
  fe:	4501                	li	a0,0
 100:	bfe5                	j	f8 <strlen+0x20>

0000000000000102 <memset>:

void*
memset(void *dst, int c, uint n)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 108:	ca19                	beqz	a2,11e <memset+0x1c>
 10a:	87aa                	mv	a5,a0
 10c:	1602                	slli	a2,a2,0x20
 10e:	9201                	srli	a2,a2,0x20
 110:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 114:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 118:	0785                	addi	a5,a5,1
 11a:	fee79de3          	bne	a5,a4,114 <memset+0x12>
  }
  return dst;
}
 11e:	6422                	ld	s0,8(sp)
 120:	0141                	addi	sp,sp,16
 122:	8082                	ret

0000000000000124 <strchr>:

char*
strchr(const char *s, char c)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	cb99                	beqz	a5,144 <strchr+0x20>
    if(*s == c)
 130:	00f58763          	beq	a1,a5,13e <strchr+0x1a>
  for(; *s; s++)
 134:	0505                	addi	a0,a0,1
 136:	00054783          	lbu	a5,0(a0)
 13a:	fbfd                	bnez	a5,130 <strchr+0xc>
      return (char*)s;
  return 0;
 13c:	4501                	li	a0,0
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
  return 0;
 144:	4501                	li	a0,0
 146:	bfe5                	j	13e <strchr+0x1a>

0000000000000148 <gets>:

char*
gets(char *buf, int max)
{
 148:	711d                	addi	sp,sp,-96
 14a:	ec86                	sd	ra,88(sp)
 14c:	e8a2                	sd	s0,80(sp)
 14e:	e4a6                	sd	s1,72(sp)
 150:	e0ca                	sd	s2,64(sp)
 152:	fc4e                	sd	s3,56(sp)
 154:	f852                	sd	s4,48(sp)
 156:	f456                	sd	s5,40(sp)
 158:	f05a                	sd	s6,32(sp)
 15a:	ec5e                	sd	s7,24(sp)
 15c:	1080                	addi	s0,sp,96
 15e:	8baa                	mv	s7,a0
 160:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 162:	892a                	mv	s2,a0
 164:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 166:	4aa9                	li	s5,10
 168:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 16a:	89a6                	mv	s3,s1
 16c:	2485                	addiw	s1,s1,1
 16e:	0344d863          	bge	s1,s4,19e <gets+0x56>
    cc = read(0, &c, 1);
 172:	4605                	li	a2,1
 174:	faf40593          	addi	a1,s0,-81
 178:	4501                	li	a0,0
 17a:	00000097          	auipc	ra,0x0
 17e:	2ce080e7          	jalr	718(ra) # 448 <read>
    if(cc < 1)
 182:	00a05e63          	blez	a0,19e <gets+0x56>
    buf[i++] = c;
 186:	faf44783          	lbu	a5,-81(s0)
 18a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18e:	01578763          	beq	a5,s5,19c <gets+0x54>
 192:	0905                	addi	s2,s2,1
 194:	fd679be3          	bne	a5,s6,16a <gets+0x22>
  for(i=0; i+1 < max; ){
 198:	89a6                	mv	s3,s1
 19a:	a011                	j	19e <gets+0x56>
 19c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19e:	99de                	add	s3,s3,s7
 1a0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a4:	855e                	mv	a0,s7
 1a6:	60e6                	ld	ra,88(sp)
 1a8:	6446                	ld	s0,80(sp)
 1aa:	64a6                	ld	s1,72(sp)
 1ac:	6906                	ld	s2,64(sp)
 1ae:	79e2                	ld	s3,56(sp)
 1b0:	7a42                	ld	s4,48(sp)
 1b2:	7aa2                	ld	s5,40(sp)
 1b4:	7b02                	ld	s6,32(sp)
 1b6:	6be2                	ld	s7,24(sp)
 1b8:	6125                	addi	sp,sp,96
 1ba:	8082                	ret

00000000000001bc <stat>:

int
stat(const char *n, struct stat *st)
{
 1bc:	1101                	addi	sp,sp,-32
 1be:	ec06                	sd	ra,24(sp)
 1c0:	e822                	sd	s0,16(sp)
 1c2:	e426                	sd	s1,8(sp)
 1c4:	e04a                	sd	s2,0(sp)
 1c6:	1000                	addi	s0,sp,32
 1c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ca:	4581                	li	a1,0
 1cc:	00000097          	auipc	ra,0x0
 1d0:	2a4080e7          	jalr	676(ra) # 470 <open>
  if(fd < 0)
 1d4:	02054563          	bltz	a0,1fe <stat+0x42>
 1d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1da:	85ca                	mv	a1,s2
 1dc:	00000097          	auipc	ra,0x0
 1e0:	2ac080e7          	jalr	684(ra) # 488 <fstat>
 1e4:	892a                	mv	s2,a0
  close(fd);
 1e6:	8526                	mv	a0,s1
 1e8:	00000097          	auipc	ra,0x0
 1ec:	270080e7          	jalr	624(ra) # 458 <close>
  return r;
}
 1f0:	854a                	mv	a0,s2
 1f2:	60e2                	ld	ra,24(sp)
 1f4:	6442                	ld	s0,16(sp)
 1f6:	64a2                	ld	s1,8(sp)
 1f8:	6902                	ld	s2,0(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    return -1;
 1fe:	597d                	li	s2,-1
 200:	bfc5                	j	1f0 <stat+0x34>

0000000000000202 <atoi>:

int
atoi(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 208:	00054683          	lbu	a3,0(a0)
 20c:	fd06879b          	addiw	a5,a3,-48
 210:	0ff7f793          	zext.b	a5,a5
 214:	4625                	li	a2,9
 216:	02f66863          	bltu	a2,a5,246 <atoi+0x44>
 21a:	872a                	mv	a4,a0
  n = 0;
 21c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21e:	0705                	addi	a4,a4,1
 220:	0025179b          	slliw	a5,a0,0x2
 224:	9fa9                	addw	a5,a5,a0
 226:	0017979b          	slliw	a5,a5,0x1
 22a:	9fb5                	addw	a5,a5,a3
 22c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 230:	00074683          	lbu	a3,0(a4)
 234:	fd06879b          	addiw	a5,a3,-48
 238:	0ff7f793          	zext.b	a5,a5
 23c:	fef671e3          	bgeu	a2,a5,21e <atoi+0x1c>

  return n;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  n = 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <atoi+0x3e>

000000000000024a <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
 250:	8eaa                	mv	t4,a0
    register const char *s = strt;
 252:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 254:	02000693          	li	a3,32
        c = *s++;
 258:	883e                	mv	a6,a5
 25a:	0785                	addi	a5,a5,1
 25c:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 260:	fed70ce3          	beq	a4,a3,258 <strtoi+0xe>
        c = *s++;
 264:	2701                	sext.w	a4,a4

    if (c == '-') {
 266:	02d00693          	li	a3,45
 26a:	04d70d63          	beq	a4,a3,2c4 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 26e:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 272:	4f01                	li	t5,0
    } else if (c == '+')
 274:	04d70e63          	beq	a4,a3,2d0 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 278:	fef67693          	andi	a3,a2,-17
 27c:	ea99                	bnez	a3,292 <strtoi+0x48>
 27e:	03000693          	li	a3,48
 282:	04d70c63          	beq	a4,a3,2da <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 286:	e611                	bnez	a2,292 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 288:	03000693          	li	a3,48
 28c:	0cd70b63          	beq	a4,a3,362 <strtoi+0x118>
 290:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 292:	800008b7          	lui	a7,0x80000
 296:	fff8c893          	not	a7,a7
 29a:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 29e:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 2a2:	1882                	slli	a7,a7,0x20
 2a4:	0208d893          	srli	a7,a7,0x20
 2a8:	02c8d8b3          	divu	a7,a7,a2
 2ac:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 2b0:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 2b4:	0ac75163          	bge	a4,a2,356 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 2b8:	4681                	li	a3,0
 2ba:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 2bc:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2be:	2881                	sext.w	a7,a7
        else {
            any = 1;
 2c0:	4f85                	li	t6,1
 2c2:	a0a9                	j	30c <strtoi+0xc2>
        c = *s++;
 2c4:	0007c703          	lbu	a4,0(a5)
 2c8:	00280793          	addi	a5,a6,2
        neg = 1;
 2cc:	4f05                	li	t5,1
 2ce:	b76d                	j	278 <strtoi+0x2e>
        c = *s++;
 2d0:	0007c703          	lbu	a4,0(a5)
 2d4:	00280793          	addi	a5,a6,2
 2d8:	b745                	j	278 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 2da:	0007c683          	lbu	a3,0(a5)
 2de:	0df6f693          	andi	a3,a3,223
 2e2:	05800513          	li	a0,88
 2e6:	faa690e3          	bne	a3,a0,286 <strtoi+0x3c>
        c = s[1];
 2ea:	0017c703          	lbu	a4,1(a5)
        s += 2;
 2ee:	0789                	addi	a5,a5,2
        base = 16;
 2f0:	4641                	li	a2,16
 2f2:	b745                	j	292 <strtoi+0x48>
            any = -1;
 2f4:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2f6:	00e2c463          	blt	t0,a4,2fe <strtoi+0xb4>
 2fa:	a015                	j	31e <strtoi+0xd4>
            any = -1;
 2fc:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 2fe:	0785                	addi	a5,a5,1
 300:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 304:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 308:	02c75063          	bge	a4,a2,328 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 30c:	fe06c8e3          	bltz	a3,2fc <strtoi+0xb2>
 310:	0005081b          	sext.w	a6,a0
            any = -1;
 314:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 316:	ff0e64e3          	bltu	t3,a6,2fe <strtoi+0xb4>
 31a:	fca88de3          	beq	a7,a0,2f4 <strtoi+0xaa>
            acc *= base;
 31e:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 322:	9d39                	addw	a0,a0,a4
            any = 1;
 324:	86fe                	mv	a3,t6
 326:	bfe1                	j	2fe <strtoi+0xb4>
        }
    }
    if (any < 0) {
 328:	0006cd63          	bltz	a3,342 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 32c:	000f0463          	beqz	t5,334 <strtoi+0xea>
        acc = -acc;
 330:	40a0053b          	negw	a0,a0
    if (end != 0)
 334:	c581                	beqz	a1,33c <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 336:	ee89                	bnez	a3,350 <strtoi+0x106>
 338:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 342:	000f1d63          	bnez	t5,35c <strtoi+0x112>
 346:	80000537          	lui	a0,0x80000
 34a:	fff54513          	not	a0,a0
    if (end != 0)
 34e:	d5fd                	beqz	a1,33c <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 350:	fff78e93          	addi	t4,a5,-1
 354:	b7d5                	j	338 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 356:	4681                	li	a3,0
 358:	4501                	li	a0,0
 35a:	bfc9                	j	32c <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 35c:	80000537          	lui	a0,0x80000
 360:	b7fd                	j	34e <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 362:	80000e37          	lui	t3,0x80000
 366:	fffe4e13          	not	t3,t3
 36a:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 36e:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 372:	003e589b          	srliw	a7,t3,0x3
 376:	8e46                	mv	t3,a7
            c -= '0';
 378:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 37a:	4621                	li	a2,8
 37c:	bf35                	j	2b8 <strtoi+0x6e>

000000000000037e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37e:	1141                	addi	sp,sp,-16
 380:	e422                	sd	s0,8(sp)
 382:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 384:	02b57463          	bgeu	a0,a1,3ac <memmove+0x2e>
    while(n-- > 0)
 388:	00c05f63          	blez	a2,3a6 <memmove+0x28>
 38c:	1602                	slli	a2,a2,0x20
 38e:	9201                	srli	a2,a2,0x20
 390:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 394:	872a                	mv	a4,a0
      *dst++ = *src++;
 396:	0585                	addi	a1,a1,1
 398:	0705                	addi	a4,a4,1
 39a:	fff5c683          	lbu	a3,-1(a1)
 39e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a2:	fee79ae3          	bne	a5,a4,396 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
    dst += n;
 3ac:	00c50733          	add	a4,a0,a2
    src += n;
 3b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b2:	fec05ae3          	blez	a2,3a6 <memmove+0x28>
 3b6:	fff6079b          	addiw	a5,a2,-1
 3ba:	1782                	slli	a5,a5,0x20
 3bc:	9381                	srli	a5,a5,0x20
 3be:	fff7c793          	not	a5,a5
 3c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c4:	15fd                	addi	a1,a1,-1
 3c6:	177d                	addi	a4,a4,-1
 3c8:	0005c683          	lbu	a3,0(a1)
 3cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d0:	fee79ae3          	bne	a5,a4,3c4 <memmove+0x46>
 3d4:	bfc9                	j	3a6 <memmove+0x28>

00000000000003d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3dc:	ca05                	beqz	a2,40c <memcmp+0x36>
 3de:	fff6069b          	addiw	a3,a2,-1
 3e2:	1682                	slli	a3,a3,0x20
 3e4:	9281                	srli	a3,a3,0x20
 3e6:	0685                	addi	a3,a3,1
 3e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ea:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 3ee:	0005c703          	lbu	a4,0(a1)
 3f2:	00e79863          	bne	a5,a4,402 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3f6:	0505                	addi	a0,a0,1
    p2++;
 3f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fa:	fed518e3          	bne	a0,a3,3ea <memcmp+0x14>
  }
  return 0;
 3fe:	4501                	li	a0,0
 400:	a019                	j	406 <memcmp+0x30>
      return *p1 - *p2;
 402:	40e7853b          	subw	a0,a5,a4
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  return 0;
 40c:	4501                	li	a0,0
 40e:	bfe5                	j	406 <memcmp+0x30>

0000000000000410 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 418:	00000097          	auipc	ra,0x0
 41c:	f66080e7          	jalr	-154(ra) # 37e <memmove>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 428:	4885                	li	a7,1
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exit>:
.global exit
exit:
 li a7, SYS_exit
 430:	4889                	li	a7,2
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <wait>:
.global wait
wait:
 li a7, SYS_wait
 438:	488d                	li	a7,3
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 440:	4891                	li	a7,4
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <read>:
.global read
read:
 li a7, SYS_read
 448:	4895                	li	a7,5
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <write>:
.global write
write:
 li a7, SYS_write
 450:	48c1                	li	a7,16
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <close>:
.global close
close:
 li a7, SYS_close
 458:	48d5                	li	a7,21
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <kill>:
.global kill
kill:
 li a7, SYS_kill
 460:	4899                	li	a7,6
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exec>:
.global exec
exec:
 li a7, SYS_exec
 468:	489d                	li	a7,7
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <open>:
.global open
open:
 li a7, SYS_open
 470:	48bd                	li	a7,15
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 478:	48c5                	li	a7,17
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 480:	48c9                	li	a7,18
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 488:	48a1                	li	a7,8
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <link>:
.global link
link:
 li a7, SYS_link
 490:	48cd                	li	a7,19
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 498:	48d1                	li	a7,20
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a0:	48a5                	li	a7,9
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a8:	48a9                	li	a7,10
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b0:	48ad                	li	a7,11
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4b8:	48b1                	li	a7,12
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c0:	48b5                	li	a7,13
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c8:	48b9                	li	a7,14
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 4d0:	48d9                	li	a7,22
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 4d8:	48dd                	li	a7,23
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 4e0:	48e1                	li	a7,24
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 4e8:	48e5                	li	a7,25
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 4f0:	48e9                	li	a7,26
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 4f8:	48ed                	li	a7,27
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 500:	1101                	addi	sp,sp,-32
 502:	ec06                	sd	ra,24(sp)
 504:	e822                	sd	s0,16(sp)
 506:	1000                	addi	s0,sp,32
 508:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 50c:	4605                	li	a2,1
 50e:	fef40593          	addi	a1,s0,-17
 512:	00000097          	auipc	ra,0x0
 516:	f3e080e7          	jalr	-194(ra) # 450 <write>
}
 51a:	60e2                	ld	ra,24(sp)
 51c:	6442                	ld	s0,16(sp)
 51e:	6105                	addi	sp,sp,32
 520:	8082                	ret

0000000000000522 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 522:	7139                	addi	sp,sp,-64
 524:	fc06                	sd	ra,56(sp)
 526:	f822                	sd	s0,48(sp)
 528:	f426                	sd	s1,40(sp)
 52a:	f04a                	sd	s2,32(sp)
 52c:	ec4e                	sd	s3,24(sp)
 52e:	0080                	addi	s0,sp,64
 530:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 532:	c299                	beqz	a3,538 <printint+0x16>
 534:	0805c963          	bltz	a1,5c6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 538:	2581                	sext.w	a1,a1
  neg = 0;
 53a:	4881                	li	a7,0
 53c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 540:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 542:	2601                	sext.w	a2,a2
 544:	00000517          	auipc	a0,0x0
 548:	4c450513          	addi	a0,a0,1220 # a08 <digits>
 54c:	883a                	mv	a6,a4
 54e:	2705                	addiw	a4,a4,1
 550:	02c5f7bb          	remuw	a5,a1,a2
 554:	1782                	slli	a5,a5,0x20
 556:	9381                	srli	a5,a5,0x20
 558:	97aa                	add	a5,a5,a0
 55a:	0007c783          	lbu	a5,0(a5)
 55e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 562:	0005879b          	sext.w	a5,a1
 566:	02c5d5bb          	divuw	a1,a1,a2
 56a:	0685                	addi	a3,a3,1
 56c:	fec7f0e3          	bgeu	a5,a2,54c <printint+0x2a>
  if(neg)
 570:	00088c63          	beqz	a7,588 <printint+0x66>
    buf[i++] = '-';
 574:	fd070793          	addi	a5,a4,-48
 578:	00878733          	add	a4,a5,s0
 57c:	02d00793          	li	a5,45
 580:	fef70823          	sb	a5,-16(a4)
 584:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 588:	02e05863          	blez	a4,5b8 <printint+0x96>
 58c:	fc040793          	addi	a5,s0,-64
 590:	00e78933          	add	s2,a5,a4
 594:	fff78993          	addi	s3,a5,-1
 598:	99ba                	add	s3,s3,a4
 59a:	377d                	addiw	a4,a4,-1
 59c:	1702                	slli	a4,a4,0x20
 59e:	9301                	srli	a4,a4,0x20
 5a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a4:	fff94583          	lbu	a1,-1(s2)
 5a8:	8526                	mv	a0,s1
 5aa:	00000097          	auipc	ra,0x0
 5ae:	f56080e7          	jalr	-170(ra) # 500 <putc>
  while(--i >= 0)
 5b2:	197d                	addi	s2,s2,-1
 5b4:	ff3918e3          	bne	s2,s3,5a4 <printint+0x82>
}
 5b8:	70e2                	ld	ra,56(sp)
 5ba:	7442                	ld	s0,48(sp)
 5bc:	74a2                	ld	s1,40(sp)
 5be:	7902                	ld	s2,32(sp)
 5c0:	69e2                	ld	s3,24(sp)
 5c2:	6121                	addi	sp,sp,64
 5c4:	8082                	ret
    x = -xx;
 5c6:	40b005bb          	negw	a1,a1
    neg = 1;
 5ca:	4885                	li	a7,1
    x = -xx;
 5cc:	bf85                	j	53c <printint+0x1a>

00000000000005ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ce:	715d                	addi	sp,sp,-80
 5d0:	e486                	sd	ra,72(sp)
 5d2:	e0a2                	sd	s0,64(sp)
 5d4:	fc26                	sd	s1,56(sp)
 5d6:	f84a                	sd	s2,48(sp)
 5d8:	f44e                	sd	s3,40(sp)
 5da:	f052                	sd	s4,32(sp)
 5dc:	ec56                	sd	s5,24(sp)
 5de:	e85a                	sd	s6,16(sp)
 5e0:	e45e                	sd	s7,8(sp)
 5e2:	e062                	sd	s8,0(sp)
 5e4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e6:	0005c903          	lbu	s2,0(a1)
 5ea:	18090c63          	beqz	s2,782 <vprintf+0x1b4>
 5ee:	8aaa                	mv	s5,a0
 5f0:	8bb2                	mv	s7,a2
 5f2:	00158493          	addi	s1,a1,1
  state = 0;
 5f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f8:	02500a13          	li	s4,37
 5fc:	4b55                	li	s6,21
 5fe:	a839                	j	61c <vprintf+0x4e>
        putc(fd, c);
 600:	85ca                	mv	a1,s2
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	efc080e7          	jalr	-260(ra) # 500 <putc>
 60c:	a019                	j	612 <vprintf+0x44>
    } else if(state == '%'){
 60e:	01498d63          	beq	s3,s4,628 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 612:	0485                	addi	s1,s1,1
 614:	fff4c903          	lbu	s2,-1(s1)
 618:	16090563          	beqz	s2,782 <vprintf+0x1b4>
    if(state == 0){
 61c:	fe0999e3          	bnez	s3,60e <vprintf+0x40>
      if(c == '%'){
 620:	ff4910e3          	bne	s2,s4,600 <vprintf+0x32>
        state = '%';
 624:	89d2                	mv	s3,s4
 626:	b7f5                	j	612 <vprintf+0x44>
      if(c == 'd'){
 628:	13490263          	beq	s2,s4,74c <vprintf+0x17e>
 62c:	f9d9079b          	addiw	a5,s2,-99
 630:	0ff7f793          	zext.b	a5,a5
 634:	12fb6563          	bltu	s6,a5,75e <vprintf+0x190>
 638:	f9d9079b          	addiw	a5,s2,-99
 63c:	0ff7f713          	zext.b	a4,a5
 640:	10eb6f63          	bltu	s6,a4,75e <vprintf+0x190>
 644:	00271793          	slli	a5,a4,0x2
 648:	00000717          	auipc	a4,0x0
 64c:	36870713          	addi	a4,a4,872 # 9b0 <malloc+0x130>
 650:	97ba                	add	a5,a5,a4
 652:	439c                	lw	a5,0(a5)
 654:	97ba                	add	a5,a5,a4
 656:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 658:	008b8913          	addi	s2,s7,8
 65c:	4685                	li	a3,1
 65e:	4629                	li	a2,10
 660:	000ba583          	lw	a1,0(s7)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	ebc080e7          	jalr	-324(ra) # 522 <printint>
 66e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 670:	4981                	li	s3,0
 672:	b745                	j	612 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000ba583          	lw	a1,0(s7)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	ea0080e7          	jalr	-352(ra) # 522 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b751                	j	612 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000ba583          	lw	a1,0(s7)
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	e84080e7          	jalr	-380(ra) # 522 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b7a5                	j	612 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 6ac:	008b8c13          	addi	s8,s7,8
 6b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6b4:	03000593          	li	a1,48
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e46080e7          	jalr	-442(ra) # 500 <putc>
  putc(fd, 'x');
 6c2:	07800593          	li	a1,120
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e38080e7          	jalr	-456(ra) # 500 <putc>
 6d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d2:	00000b97          	auipc	s7,0x0
 6d6:	336b8b93          	addi	s7,s7,822 # a08 <digits>
 6da:	03c9d793          	srli	a5,s3,0x3c
 6de:	97de                	add	a5,a5,s7
 6e0:	0007c583          	lbu	a1,0(a5)
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e1a080e7          	jalr	-486(ra) # 500 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ee:	0992                	slli	s3,s3,0x4
 6f0:	397d                	addiw	s2,s2,-1
 6f2:	fe0914e3          	bnez	s2,6da <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6f6:	8be2                	mv	s7,s8
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bf21                	j	612 <vprintf+0x44>
        s = va_arg(ap, char*);
 6fc:	008b8993          	addi	s3,s7,8
 700:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 704:	02090163          	beqz	s2,726 <vprintf+0x158>
        while(*s != 0){
 708:	00094583          	lbu	a1,0(s2)
 70c:	c9a5                	beqz	a1,77c <vprintf+0x1ae>
          putc(fd, *s);
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	df0080e7          	jalr	-528(ra) # 500 <putc>
          s++;
 718:	0905                	addi	s2,s2,1
        while(*s != 0){
 71a:	00094583          	lbu	a1,0(s2)
 71e:	f9e5                	bnez	a1,70e <vprintf+0x140>
        s = va_arg(ap, char*);
 720:	8bce                	mv	s7,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	b5fd                	j	612 <vprintf+0x44>
          s = "(null)";
 726:	00000917          	auipc	s2,0x0
 72a:	28290913          	addi	s2,s2,642 # 9a8 <malloc+0x128>
        while(*s != 0){
 72e:	02800593          	li	a1,40
 732:	bff1                	j	70e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 734:	008b8913          	addi	s2,s7,8
 738:	000bc583          	lbu	a1,0(s7)
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	dc2080e7          	jalr	-574(ra) # 500 <putc>
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
 74a:	b5e1                	j	612 <vprintf+0x44>
        putc(fd, c);
 74c:	02500593          	li	a1,37
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	dae080e7          	jalr	-594(ra) # 500 <putc>
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bd5d                	j	612 <vprintf+0x44>
        putc(fd, '%');
 75e:	02500593          	li	a1,37
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	d9c080e7          	jalr	-612(ra) # 500 <putc>
        putc(fd, c);
 76c:	85ca                	mv	a1,s2
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	d90080e7          	jalr	-624(ra) # 500 <putc>
      state = 0;
 778:	4981                	li	s3,0
 77a:	bd61                	j	612 <vprintf+0x44>
        s = va_arg(ap, char*);
 77c:	8bce                	mv	s7,s3
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd49                	j	612 <vprintf+0x44>
    }
  }
}
 782:	60a6                	ld	ra,72(sp)
 784:	6406                	ld	s0,64(sp)
 786:	74e2                	ld	s1,56(sp)
 788:	7942                	ld	s2,48(sp)
 78a:	79a2                	ld	s3,40(sp)
 78c:	7a02                	ld	s4,32(sp)
 78e:	6ae2                	ld	s5,24(sp)
 790:	6b42                	ld	s6,16(sp)
 792:	6ba2                	ld	s7,8(sp)
 794:	6c02                	ld	s8,0(sp)
 796:	6161                	addi	sp,sp,80
 798:	8082                	ret

000000000000079a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 79a:	715d                	addi	sp,sp,-80
 79c:	ec06                	sd	ra,24(sp)
 79e:	e822                	sd	s0,16(sp)
 7a0:	1000                	addi	s0,sp,32
 7a2:	e010                	sd	a2,0(s0)
 7a4:	e414                	sd	a3,8(s0)
 7a6:	e818                	sd	a4,16(s0)
 7a8:	ec1c                	sd	a5,24(s0)
 7aa:	03043023          	sd	a6,32(s0)
 7ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b6:	8622                	mv	a2,s0
 7b8:	00000097          	auipc	ra,0x0
 7bc:	e16080e7          	jalr	-490(ra) # 5ce <vprintf>
}
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6161                	addi	sp,sp,80
 7c6:	8082                	ret

00000000000007c8 <printf>:

void
printf(const char *fmt, ...)
{
 7c8:	711d                	addi	sp,sp,-96
 7ca:	ec06                	sd	ra,24(sp)
 7cc:	e822                	sd	s0,16(sp)
 7ce:	1000                	addi	s0,sp,32
 7d0:	e40c                	sd	a1,8(s0)
 7d2:	e810                	sd	a2,16(s0)
 7d4:	ec14                	sd	a3,24(s0)
 7d6:	f018                	sd	a4,32(s0)
 7d8:	f41c                	sd	a5,40(s0)
 7da:	03043823          	sd	a6,48(s0)
 7de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e2:	00840613          	addi	a2,s0,8
 7e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ea:	85aa                	mv	a1,a0
 7ec:	4505                	li	a0,1
 7ee:	00000097          	auipc	ra,0x0
 7f2:	de0080e7          	jalr	-544(ra) # 5ce <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6125                	addi	sp,sp,96
 7fc:	8082                	ret

00000000000007fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fe:	1141                	addi	sp,sp,-16
 800:	e422                	sd	s0,8(sp)
 802:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 804:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 808:	00000797          	auipc	a5,0x0
 80c:	7f87b783          	ld	a5,2040(a5) # 1000 <freep>
 810:	a02d                	j	83a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 812:	4618                	lw	a4,8(a2)
 814:	9f2d                	addw	a4,a4,a1
 816:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	6310                	ld	a2,0(a4)
 81e:	a83d                	j	85c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 820:	ff852703          	lw	a4,-8(a0)
 824:	9f31                	addw	a4,a4,a2
 826:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 828:	ff053683          	ld	a3,-16(a0)
 82c:	a091                	j	870 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	6398                	ld	a4,0(a5)
 830:	00e7e463          	bltu	a5,a4,838 <free+0x3a>
 834:	00e6ea63          	bltu	a3,a4,848 <free+0x4a>
{
 838:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	fed7fae3          	bgeu	a5,a3,82e <free+0x30>
 83e:	6398                	ld	a4,0(a5)
 840:	00e6e463          	bltu	a3,a4,848 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	fee7eae3          	bltu	a5,a4,838 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 848:	ff852583          	lw	a1,-8(a0)
 84c:	6390                	ld	a2,0(a5)
 84e:	02059813          	slli	a6,a1,0x20
 852:	01c85713          	srli	a4,a6,0x1c
 856:	9736                	add	a4,a4,a3
 858:	fae60de3          	beq	a2,a4,812 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 85c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 860:	4790                	lw	a2,8(a5)
 862:	02061593          	slli	a1,a2,0x20
 866:	01c5d713          	srli	a4,a1,0x1c
 86a:	973e                	add	a4,a4,a5
 86c:	fae68ae3          	beq	a3,a4,820 <free+0x22>
    p->s.ptr = bp->s.ptr;
 870:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 872:	00000717          	auipc	a4,0x0
 876:	78f73723          	sd	a5,1934(a4) # 1000 <freep>
}
 87a:	6422                	ld	s0,8(sp)
 87c:	0141                	addi	sp,sp,16
 87e:	8082                	ret

0000000000000880 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 880:	7139                	addi	sp,sp,-64
 882:	fc06                	sd	ra,56(sp)
 884:	f822                	sd	s0,48(sp)
 886:	f426                	sd	s1,40(sp)
 888:	f04a                	sd	s2,32(sp)
 88a:	ec4e                	sd	s3,24(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
 892:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 894:	02051493          	slli	s1,a0,0x20
 898:	9081                	srli	s1,s1,0x20
 89a:	04bd                	addi	s1,s1,15
 89c:	8091                	srli	s1,s1,0x4
 89e:	0014899b          	addiw	s3,s1,1
 8a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a4:	00000517          	auipc	a0,0x0
 8a8:	75c53503          	ld	a0,1884(a0) # 1000 <freep>
 8ac:	c515                	beqz	a0,8d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	02977f63          	bgeu	a4,s1,8f0 <malloc+0x70>
  if(nu < 4096)
 8b6:	8a4e                	mv	s4,s3
 8b8:	0009871b          	sext.w	a4,s3
 8bc:	6685                	lui	a3,0x1
 8be:	00d77363          	bgeu	a4,a3,8c4 <malloc+0x44>
 8c2:	6a05                	lui	s4,0x1
 8c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8cc:	00000917          	auipc	s2,0x0
 8d0:	73490913          	addi	s2,s2,1844 # 1000 <freep>
  if(p == (char*)-1)
 8d4:	5afd                	li	s5,-1
 8d6:	a895                	j	94a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8d8:	00000797          	auipc	a5,0x0
 8dc:	73878793          	addi	a5,a5,1848 # 1010 <base>
 8e0:	00000717          	auipc	a4,0x0
 8e4:	72f73023          	sd	a5,1824(a4) # 1000 <freep>
 8e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ee:	b7e1                	j	8b6 <malloc+0x36>
      if(p->s.size == nunits)
 8f0:	02e48c63          	beq	s1,a4,928 <malloc+0xa8>
        p->s.size -= nunits;
 8f4:	4137073b          	subw	a4,a4,s3
 8f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fa:	02071693          	slli	a3,a4,0x20
 8fe:	01c6d713          	srli	a4,a3,0x1c
 902:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 904:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 908:	00000717          	auipc	a4,0x0
 90c:	6ea73c23          	sd	a0,1784(a4) # 1000 <freep>
      return (void*)(p + 1);
 910:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 914:	70e2                	ld	ra,56(sp)
 916:	7442                	ld	s0,48(sp)
 918:	74a2                	ld	s1,40(sp)
 91a:	7902                	ld	s2,32(sp)
 91c:	69e2                	ld	s3,24(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
 924:	6121                	addi	sp,sp,64
 926:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 928:	6398                	ld	a4,0(a5)
 92a:	e118                	sd	a4,0(a0)
 92c:	bff1                	j	908 <malloc+0x88>
  hp->s.size = nu;
 92e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 932:	0541                	addi	a0,a0,16
 934:	00000097          	auipc	ra,0x0
 938:	eca080e7          	jalr	-310(ra) # 7fe <free>
  return freep;
 93c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 940:	d971                	beqz	a0,914 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 944:	4798                	lw	a4,8(a5)
 946:	fa9775e3          	bgeu	a4,s1,8f0 <malloc+0x70>
    if(p == freep)
 94a:	00093703          	ld	a4,0(s2)
 94e:	853e                	mv	a0,a5
 950:	fef719e3          	bne	a4,a5,942 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 954:	8552                	mv	a0,s4
 956:	00000097          	auipc	ra,0x0
 95a:	b62080e7          	jalr	-1182(ra) # 4b8 <sbrk>
  if(p == (char*)-1)
 95e:	fd5518e3          	bne	a0,s5,92e <malloc+0xae>
        return 0;
 962:	4501                	li	a0,0
 964:	bf45                	j	914 <malloc+0x94>
