
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	950a8a93          	addi	s5,s5,-1712 # 980 <malloc+0xe8>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	428080e7          	jalr	1064(ra) # 468 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	09c080e7          	jalr	156(ra) # f0 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	404080e7          	jalr	1028(ra) # 468 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00001597          	auipc	a1,0x1
  76:	91658593          	addi	a1,a1,-1770 # 988 <malloc+0xf0>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	3ec080e7          	jalr	1004(ra) # 468 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	3c2080e7          	jalr	962(ra) # 448 <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	3a8080e7          	jalr	936(ra) # 448 <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	2ce080e7          	jalr	718(ra) # 460 <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e426                	sd	s1,8(sp)
 1dc:	e04a                	sd	s2,0(sp)
 1de:	1000                	addi	s0,sp,32
 1e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e2:	4581                	li	a1,0
 1e4:	00000097          	auipc	ra,0x0
 1e8:	2a4080e7          	jalr	676(ra) # 488 <open>
  if(fd < 0)
 1ec:	02054563          	bltz	a0,216 <stat+0x42>
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	2ac080e7          	jalr	684(ra) # 4a0 <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	270080e7          	jalr	624(ra) # 470 <close>
  return r;
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	64a2                	ld	s1,8(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfc5                	j	208 <stat+0x34>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addiw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66863          	bltu	a2,a5,25e <atoi+0x44>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	addi	a4,a4,1
 238:	0025179b          	slliw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	slliw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1c>

  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  n = 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <atoi+0x3e>

0000000000000262 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
 268:	8eaa                	mv	t4,a0
    register const char *s = strt;
 26a:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 26c:	02000693          	li	a3,32
        c = *s++;
 270:	883e                	mv	a6,a5
 272:	0785                	addi	a5,a5,1
 274:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 278:	fed70ce3          	beq	a4,a3,270 <strtoi+0xe>
        c = *s++;
 27c:	2701                	sext.w	a4,a4

    if (c == '-') {
 27e:	02d00693          	li	a3,45
 282:	04d70d63          	beq	a4,a3,2dc <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 286:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 28a:	4f01                	li	t5,0
    } else if (c == '+')
 28c:	04d70e63          	beq	a4,a3,2e8 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 290:	fef67693          	andi	a3,a2,-17
 294:	ea99                	bnez	a3,2aa <strtoi+0x48>
 296:	03000693          	li	a3,48
 29a:	04d70c63          	beq	a4,a3,2f2 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 29e:	e611                	bnez	a2,2aa <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 2a0:	03000693          	li	a3,48
 2a4:	0cd70b63          	beq	a4,a3,37a <strtoi+0x118>
 2a8:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 2aa:	800008b7          	lui	a7,0x80000
 2ae:	fff8c893          	not	a7,a7
 2b2:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 2b6:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 2ba:	1882                	slli	a7,a7,0x20
 2bc:	0208d893          	srli	a7,a7,0x20
 2c0:	02c8d8b3          	divu	a7,a7,a2
 2c4:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 2c8:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 2cc:	0ac75163          	bge	a4,a2,36e <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 2d0:	4681                	li	a3,0
 2d2:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 2d4:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 2d6:	2881                	sext.w	a7,a7
        else {
            any = 1;
 2d8:	4f85                	li	t6,1
 2da:	a0a9                	j	324 <strtoi+0xc2>
        c = *s++;
 2dc:	0007c703          	lbu	a4,0(a5)
 2e0:	00280793          	addi	a5,a6,2
        neg = 1;
 2e4:	4f05                	li	t5,1
 2e6:	b76d                	j	290 <strtoi+0x2e>
        c = *s++;
 2e8:	0007c703          	lbu	a4,0(a5)
 2ec:	00280793          	addi	a5,a6,2
 2f0:	b745                	j	290 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 2f2:	0007c683          	lbu	a3,0(a5)
 2f6:	0df6f693          	andi	a3,a3,223
 2fa:	05800513          	li	a0,88
 2fe:	faa690e3          	bne	a3,a0,29e <strtoi+0x3c>
        c = s[1];
 302:	0017c703          	lbu	a4,1(a5)
        s += 2;
 306:	0789                	addi	a5,a5,2
        base = 16;
 308:	4641                	li	a2,16
 30a:	b745                	j	2aa <strtoi+0x48>
            any = -1;
 30c:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 30e:	00e2c463          	blt	t0,a4,316 <strtoi+0xb4>
 312:	a015                	j	336 <strtoi+0xd4>
            any = -1;
 314:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 316:	0785                	addi	a5,a5,1
 318:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 31c:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 320:	02c75063          	bge	a4,a2,340 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 324:	fe06c8e3          	bltz	a3,314 <strtoi+0xb2>
 328:	0005081b          	sext.w	a6,a0
            any = -1;
 32c:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 32e:	ff0e64e3          	bltu	t3,a6,316 <strtoi+0xb4>
 332:	fca88de3          	beq	a7,a0,30c <strtoi+0xaa>
            acc *= base;
 336:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 33a:	9d39                	addw	a0,a0,a4
            any = 1;
 33c:	86fe                	mv	a3,t6
 33e:	bfe1                	j	316 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 340:	0006cd63          	bltz	a3,35a <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 344:	000f0463          	beqz	t5,34c <strtoi+0xea>
        acc = -acc;
 348:	40a0053b          	negw	a0,a0
    if (end != 0)
 34c:	c581                	beqz	a1,354 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 34e:	ee89                	bnez	a3,368 <strtoi+0x106>
 350:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 35a:	000f1d63          	bnez	t5,374 <strtoi+0x112>
 35e:	80000537          	lui	a0,0x80000
 362:	fff54513          	not	a0,a0
    if (end != 0)
 366:	d5fd                	beqz	a1,354 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 368:	fff78e93          	addi	t4,a5,-1
 36c:	b7d5                	j	350 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 36e:	4681                	li	a3,0
 370:	4501                	li	a0,0
 372:	bfc9                	j	344 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 374:	80000537          	lui	a0,0x80000
 378:	b7fd                	j	366 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 37a:	80000e37          	lui	t3,0x80000
 37e:	fffe4e13          	not	t3,t3
 382:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 386:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 38a:	003e589b          	srliw	a7,t3,0x3
 38e:	8e46                	mv	t3,a7
            c -= '0';
 390:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 392:	4621                	li	a2,8
 394:	bf35                	j	2d0 <strtoi+0x6e>

0000000000000396 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 396:	1141                	addi	sp,sp,-16
 398:	e422                	sd	s0,8(sp)
 39a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39c:	02b57463          	bgeu	a0,a1,3c4 <memmove+0x2e>
    while(n-- > 0)
 3a0:	00c05f63          	blez	a2,3be <memmove+0x28>
 3a4:	1602                	slli	a2,a2,0x20
 3a6:	9201                	srli	a2,a2,0x20
 3a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ae:	0585                	addi	a1,a1,1
 3b0:	0705                	addi	a4,a4,1
 3b2:	fff5c683          	lbu	a3,-1(a1)
 3b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ba:	fee79ae3          	bne	a5,a4,3ae <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
    dst += n;
 3c4:	00c50733          	add	a4,a0,a2
    src += n;
 3c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ca:	fec05ae3          	blez	a2,3be <memmove+0x28>
 3ce:	fff6079b          	addiw	a5,a2,-1
 3d2:	1782                	slli	a5,a5,0x20
 3d4:	9381                	srli	a5,a5,0x20
 3d6:	fff7c793          	not	a5,a5
 3da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3dc:	15fd                	addi	a1,a1,-1
 3de:	177d                	addi	a4,a4,-1
 3e0:	0005c683          	lbu	a3,0(a1)
 3e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e8:	fee79ae3          	bne	a5,a4,3dc <memmove+0x46>
 3ec:	bfc9                	j	3be <memmove+0x28>

00000000000003ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e422                	sd	s0,8(sp)
 3f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f4:	ca05                	beqz	a2,424 <memcmp+0x36>
 3f6:	fff6069b          	addiw	a3,a2,-1
 3fa:	1682                	slli	a3,a3,0x20
 3fc:	9281                	srli	a3,a3,0x20
 3fe:	0685                	addi	a3,a3,1
 400:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 402:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 406:	0005c703          	lbu	a4,0(a1)
 40a:	00e79863          	bne	a5,a4,41a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40e:	0505                	addi	a0,a0,1
    p2++;
 410:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 412:	fed518e3          	bne	a0,a3,402 <memcmp+0x14>
  }
  return 0;
 416:	4501                	li	a0,0
 418:	a019                	j	41e <memcmp+0x30>
      return *p1 - *p2;
 41a:	40e7853b          	subw	a0,a5,a4
}
 41e:	6422                	ld	s0,8(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
  return 0;
 424:	4501                	li	a0,0
 426:	bfe5                	j	41e <memcmp+0x30>

0000000000000428 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e406                	sd	ra,8(sp)
 42c:	e022                	sd	s0,0(sp)
 42e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 430:	00000097          	auipc	ra,0x0
 434:	f66080e7          	jalr	-154(ra) # 396 <memmove>
}
 438:	60a2                	ld	ra,8(sp)
 43a:	6402                	ld	s0,0(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret

0000000000000440 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 440:	4885                	li	a7,1
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <exit>:
.global exit
exit:
 li a7, SYS_exit
 448:	4889                	li	a7,2
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <wait>:
.global wait
wait:
 li a7, SYS_wait
 450:	488d                	li	a7,3
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 458:	4891                	li	a7,4
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <read>:
.global read
read:
 li a7, SYS_read
 460:	4895                	li	a7,5
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <write>:
.global write
write:
 li a7, SYS_write
 468:	48c1                	li	a7,16
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <close>:
.global close
close:
 li a7, SYS_close
 470:	48d5                	li	a7,21
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <kill>:
.global kill
kill:
 li a7, SYS_kill
 478:	4899                	li	a7,6
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <exec>:
.global exec
exec:
 li a7, SYS_exec
 480:	489d                	li	a7,7
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <open>:
.global open
open:
 li a7, SYS_open
 488:	48bd                	li	a7,15
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 490:	48c5                	li	a7,17
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 498:	48c9                	li	a7,18
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a0:	48a1                	li	a7,8
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <link>:
.global link
link:
 li a7, SYS_link
 4a8:	48cd                	li	a7,19
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b0:	48d1                	li	a7,20
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b8:	48a5                	li	a7,9
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c0:	48a9                	li	a7,10
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c8:	48ad                	li	a7,11
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d0:	48b1                	li	a7,12
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d8:	48b5                	li	a7,13
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e0:	48b9                	li	a7,14
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 4e8:	48d9                	li	a7,22
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 4f0:	48dd                	li	a7,23
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 4f8:	48e1                	li	a7,24
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 500:	48e5                	li	a7,25
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 508:	48e9                	li	a7,26
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 510:	48ed                	li	a7,27
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 518:	1101                	addi	sp,sp,-32
 51a:	ec06                	sd	ra,24(sp)
 51c:	e822                	sd	s0,16(sp)
 51e:	1000                	addi	s0,sp,32
 520:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 524:	4605                	li	a2,1
 526:	fef40593          	addi	a1,s0,-17
 52a:	00000097          	auipc	ra,0x0
 52e:	f3e080e7          	jalr	-194(ra) # 468 <write>
}
 532:	60e2                	ld	ra,24(sp)
 534:	6442                	ld	s0,16(sp)
 536:	6105                	addi	sp,sp,32
 538:	8082                	ret

000000000000053a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 53a:	7139                	addi	sp,sp,-64
 53c:	fc06                	sd	ra,56(sp)
 53e:	f822                	sd	s0,48(sp)
 540:	f426                	sd	s1,40(sp)
 542:	f04a                	sd	s2,32(sp)
 544:	ec4e                	sd	s3,24(sp)
 546:	0080                	addi	s0,sp,64
 548:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54a:	c299                	beqz	a3,550 <printint+0x16>
 54c:	0805c963          	bltz	a1,5de <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 550:	2581                	sext.w	a1,a1
  neg = 0;
 552:	4881                	li	a7,0
 554:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 558:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 55a:	2601                	sext.w	a2,a2
 55c:	00000517          	auipc	a0,0x0
 560:	49450513          	addi	a0,a0,1172 # 9f0 <digits>
 564:	883a                	mv	a6,a4
 566:	2705                	addiw	a4,a4,1
 568:	02c5f7bb          	remuw	a5,a1,a2
 56c:	1782                	slli	a5,a5,0x20
 56e:	9381                	srli	a5,a5,0x20
 570:	97aa                	add	a5,a5,a0
 572:	0007c783          	lbu	a5,0(a5)
 576:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 57a:	0005879b          	sext.w	a5,a1
 57e:	02c5d5bb          	divuw	a1,a1,a2
 582:	0685                	addi	a3,a3,1
 584:	fec7f0e3          	bgeu	a5,a2,564 <printint+0x2a>
  if(neg)
 588:	00088c63          	beqz	a7,5a0 <printint+0x66>
    buf[i++] = '-';
 58c:	fd070793          	addi	a5,a4,-48
 590:	00878733          	add	a4,a5,s0
 594:	02d00793          	li	a5,45
 598:	fef70823          	sb	a5,-16(a4)
 59c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a0:	02e05863          	blez	a4,5d0 <printint+0x96>
 5a4:	fc040793          	addi	a5,s0,-64
 5a8:	00e78933          	add	s2,a5,a4
 5ac:	fff78993          	addi	s3,a5,-1
 5b0:	99ba                	add	s3,s3,a4
 5b2:	377d                	addiw	a4,a4,-1
 5b4:	1702                	slli	a4,a4,0x20
 5b6:	9301                	srli	a4,a4,0x20
 5b8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5bc:	fff94583          	lbu	a1,-1(s2)
 5c0:	8526                	mv	a0,s1
 5c2:	00000097          	auipc	ra,0x0
 5c6:	f56080e7          	jalr	-170(ra) # 518 <putc>
  while(--i >= 0)
 5ca:	197d                	addi	s2,s2,-1
 5cc:	ff3918e3          	bne	s2,s3,5bc <printint+0x82>
}
 5d0:	70e2                	ld	ra,56(sp)
 5d2:	7442                	ld	s0,48(sp)
 5d4:	74a2                	ld	s1,40(sp)
 5d6:	7902                	ld	s2,32(sp)
 5d8:	69e2                	ld	s3,24(sp)
 5da:	6121                	addi	sp,sp,64
 5dc:	8082                	ret
    x = -xx;
 5de:	40b005bb          	negw	a1,a1
    neg = 1;
 5e2:	4885                	li	a7,1
    x = -xx;
 5e4:	bf85                	j	554 <printint+0x1a>

00000000000005e6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e6:	715d                	addi	sp,sp,-80
 5e8:	e486                	sd	ra,72(sp)
 5ea:	e0a2                	sd	s0,64(sp)
 5ec:	fc26                	sd	s1,56(sp)
 5ee:	f84a                	sd	s2,48(sp)
 5f0:	f44e                	sd	s3,40(sp)
 5f2:	f052                	sd	s4,32(sp)
 5f4:	ec56                	sd	s5,24(sp)
 5f6:	e85a                	sd	s6,16(sp)
 5f8:	e45e                	sd	s7,8(sp)
 5fa:	e062                	sd	s8,0(sp)
 5fc:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fe:	0005c903          	lbu	s2,0(a1)
 602:	18090c63          	beqz	s2,79a <vprintf+0x1b4>
 606:	8aaa                	mv	s5,a0
 608:	8bb2                	mv	s7,a2
 60a:	00158493          	addi	s1,a1,1
  state = 0;
 60e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 610:	02500a13          	li	s4,37
 614:	4b55                	li	s6,21
 616:	a839                	j	634 <vprintf+0x4e>
        putc(fd, c);
 618:	85ca                	mv	a1,s2
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	efc080e7          	jalr	-260(ra) # 518 <putc>
 624:	a019                	j	62a <vprintf+0x44>
    } else if(state == '%'){
 626:	01498d63          	beq	s3,s4,640 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 62a:	0485                	addi	s1,s1,1
 62c:	fff4c903          	lbu	s2,-1(s1)
 630:	16090563          	beqz	s2,79a <vprintf+0x1b4>
    if(state == 0){
 634:	fe0999e3          	bnez	s3,626 <vprintf+0x40>
      if(c == '%'){
 638:	ff4910e3          	bne	s2,s4,618 <vprintf+0x32>
        state = '%';
 63c:	89d2                	mv	s3,s4
 63e:	b7f5                	j	62a <vprintf+0x44>
      if(c == 'd'){
 640:	13490263          	beq	s2,s4,764 <vprintf+0x17e>
 644:	f9d9079b          	addiw	a5,s2,-99
 648:	0ff7f793          	zext.b	a5,a5
 64c:	12fb6563          	bltu	s6,a5,776 <vprintf+0x190>
 650:	f9d9079b          	addiw	a5,s2,-99
 654:	0ff7f713          	zext.b	a4,a5
 658:	10eb6f63          	bltu	s6,a4,776 <vprintf+0x190>
 65c:	00271793          	slli	a5,a4,0x2
 660:	00000717          	auipc	a4,0x0
 664:	33870713          	addi	a4,a4,824 # 998 <malloc+0x100>
 668:	97ba                	add	a5,a5,a4
 66a:	439c                	lw	a5,0(a5)
 66c:	97ba                	add	a5,a5,a4
 66e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 670:	008b8913          	addi	s2,s7,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000ba583          	lw	a1,0(s7)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	ebc080e7          	jalr	-324(ra) # 53a <printint>
 686:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 688:	4981                	li	s3,0
 68a:	b745                	j	62a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000ba583          	lw	a1,0(s7)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	ea0080e7          	jalr	-352(ra) # 53a <printint>
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	b751                	j	62a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000ba583          	lw	a1,0(s7)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e84080e7          	jalr	-380(ra) # 53a <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b7a5                	j	62a <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 6c4:	008b8c13          	addi	s8,s7,8
 6c8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6cc:	03000593          	li	a1,48
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e46080e7          	jalr	-442(ra) # 518 <putc>
  putc(fd, 'x');
 6da:	07800593          	li	a1,120
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	e38080e7          	jalr	-456(ra) # 518 <putc>
 6e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ea:	00000b97          	auipc	s7,0x0
 6ee:	306b8b93          	addi	s7,s7,774 # 9f0 <digits>
 6f2:	03c9d793          	srli	a5,s3,0x3c
 6f6:	97de                	add	a5,a5,s7
 6f8:	0007c583          	lbu	a1,0(a5)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e1a080e7          	jalr	-486(ra) # 518 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 706:	0992                	slli	s3,s3,0x4
 708:	397d                	addiw	s2,s2,-1
 70a:	fe0914e3          	bnez	s2,6f2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 70e:	8be2                	mv	s7,s8
      state = 0;
 710:	4981                	li	s3,0
 712:	bf21                	j	62a <vprintf+0x44>
        s = va_arg(ap, char*);
 714:	008b8993          	addi	s3,s7,8
 718:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 71c:	02090163          	beqz	s2,73e <vprintf+0x158>
        while(*s != 0){
 720:	00094583          	lbu	a1,0(s2)
 724:	c9a5                	beqz	a1,794 <vprintf+0x1ae>
          putc(fd, *s);
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	df0080e7          	jalr	-528(ra) # 518 <putc>
          s++;
 730:	0905                	addi	s2,s2,1
        while(*s != 0){
 732:	00094583          	lbu	a1,0(s2)
 736:	f9e5                	bnez	a1,726 <vprintf+0x140>
        s = va_arg(ap, char*);
 738:	8bce                	mv	s7,s3
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b5fd                	j	62a <vprintf+0x44>
          s = "(null)";
 73e:	00000917          	auipc	s2,0x0
 742:	25290913          	addi	s2,s2,594 # 990 <malloc+0xf8>
        while(*s != 0){
 746:	02800593          	li	a1,40
 74a:	bff1                	j	726 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 74c:	008b8913          	addi	s2,s7,8
 750:	000bc583          	lbu	a1,0(s7)
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	dc2080e7          	jalr	-574(ra) # 518 <putc>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	b5e1                	j	62a <vprintf+0x44>
        putc(fd, c);
 764:	02500593          	li	a1,37
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	dae080e7          	jalr	-594(ra) # 518 <putc>
      state = 0;
 772:	4981                	li	s3,0
 774:	bd5d                	j	62a <vprintf+0x44>
        putc(fd, '%');
 776:	02500593          	li	a1,37
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	d9c080e7          	jalr	-612(ra) # 518 <putc>
        putc(fd, c);
 784:	85ca                	mv	a1,s2
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	d90080e7          	jalr	-624(ra) # 518 <putc>
      state = 0;
 790:	4981                	li	s3,0
 792:	bd61                	j	62a <vprintf+0x44>
        s = va_arg(ap, char*);
 794:	8bce                	mv	s7,s3
      state = 0;
 796:	4981                	li	s3,0
 798:	bd49                	j	62a <vprintf+0x44>
    }
  }
}
 79a:	60a6                	ld	ra,72(sp)
 79c:	6406                	ld	s0,64(sp)
 79e:	74e2                	ld	s1,56(sp)
 7a0:	7942                	ld	s2,48(sp)
 7a2:	79a2                	ld	s3,40(sp)
 7a4:	7a02                	ld	s4,32(sp)
 7a6:	6ae2                	ld	s5,24(sp)
 7a8:	6b42                	ld	s6,16(sp)
 7aa:	6ba2                	ld	s7,8(sp)
 7ac:	6c02                	ld	s8,0(sp)
 7ae:	6161                	addi	sp,sp,80
 7b0:	8082                	ret

00000000000007b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b2:	715d                	addi	sp,sp,-80
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e010                	sd	a2,0(s0)
 7bc:	e414                	sd	a3,8(s0)
 7be:	e818                	sd	a4,16(s0)
 7c0:	ec1c                	sd	a5,24(s0)
 7c2:	03043023          	sd	a6,32(s0)
 7c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ce:	8622                	mv	a2,s0
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e16080e7          	jalr	-490(ra) # 5e6 <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6161                	addi	sp,sp,80
 7de:	8082                	ret

00000000000007e0 <printf>:

void
printf(const char *fmt, ...)
{
 7e0:	711d                	addi	sp,sp,-96
 7e2:	ec06                	sd	ra,24(sp)
 7e4:	e822                	sd	s0,16(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	e40c                	sd	a1,8(s0)
 7ea:	e810                	sd	a2,16(s0)
 7ec:	ec14                	sd	a3,24(s0)
 7ee:	f018                	sd	a4,32(s0)
 7f0:	f41c                	sd	a5,40(s0)
 7f2:	03043823          	sd	a6,48(s0)
 7f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	00840613          	addi	a2,s0,8
 7fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 802:	85aa                	mv	a1,a0
 804:	4505                	li	a0,1
 806:	00000097          	auipc	ra,0x0
 80a:	de0080e7          	jalr	-544(ra) # 5e6 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	7e07b783          	ld	a5,2016(a5) # 1000 <freep>
 828:	a02d                	j	852 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9f2d                	addw	a4,a4,a1
 82e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6310                	ld	a2,0(a4)
 836:	a83d                	j	874 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9f31                	addw	a4,a4,a2
 83e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053683          	ld	a3,-16(a0)
 844:	a091                	j	888 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	6398                	ld	a4,0(a5)
 848:	00e7e463          	bltu	a5,a4,850 <free+0x3a>
 84c:	00e6ea63          	bltu	a3,a4,860 <free+0x4a>
{
 850:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 852:	fed7fae3          	bgeu	a5,a3,846 <free+0x30>
 856:	6398                	ld	a4,0(a5)
 858:	00e6e463          	bltu	a3,a4,860 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	fee7eae3          	bltu	a5,a4,850 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 860:	ff852583          	lw	a1,-8(a0)
 864:	6390                	ld	a2,0(a5)
 866:	02059813          	slli	a6,a1,0x20
 86a:	01c85713          	srli	a4,a6,0x1c
 86e:	9736                	add	a4,a4,a3
 870:	fae60de3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 878:	4790                	lw	a2,8(a5)
 87a:	02061593          	slli	a1,a2,0x20
 87e:	01c5d713          	srli	a4,a1,0x1c
 882:	973e                	add	a4,a4,a5
 884:	fae68ae3          	beq	a3,a4,838 <free+0x22>
    p->s.ptr = bp->s.ptr;
 888:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 88a:	00000717          	auipc	a4,0x0
 88e:	76f73b23          	sd	a5,1910(a4) # 1000 <freep>
}
 892:	6422                	ld	s0,8(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret

0000000000000898 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 898:	7139                	addi	sp,sp,-64
 89a:	fc06                	sd	ra,56(sp)
 89c:	f822                	sd	s0,48(sp)
 89e:	f426                	sd	s1,40(sp)
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	ec4e                	sd	s3,24(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051493          	slli	s1,a0,0x20
 8b0:	9081                	srli	s1,s1,0x20
 8b2:	04bd                	addi	s1,s1,15
 8b4:	8091                	srli	s1,s1,0x4
 8b6:	0014899b          	addiw	s3,s1,1
 8ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8bc:	00000517          	auipc	a0,0x0
 8c0:	74453503          	ld	a0,1860(a0) # 1000 <freep>
 8c4:	c515                	beqz	a0,8f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	02977f63          	bgeu	a4,s1,908 <malloc+0x70>
  if(nu < 4096)
 8ce:	8a4e                	mv	s4,s3
 8d0:	0009871b          	sext.w	a4,s3
 8d4:	6685                	lui	a3,0x1
 8d6:	00d77363          	bgeu	a4,a3,8dc <malloc+0x44>
 8da:	6a05                	lui	s4,0x1
 8dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e4:	00000917          	auipc	s2,0x0
 8e8:	71c90913          	addi	s2,s2,1820 # 1000 <freep>
  if(p == (char*)-1)
 8ec:	5afd                	li	s5,-1
 8ee:	a895                	j	962 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8f0:	00000797          	auipc	a5,0x0
 8f4:	72078793          	addi	a5,a5,1824 # 1010 <base>
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
 900:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 902:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 906:	b7e1                	j	8ce <malloc+0x36>
      if(p->s.size == nunits)
 908:	02e48c63          	beq	s1,a4,940 <malloc+0xa8>
        p->s.size -= nunits;
 90c:	4137073b          	subw	a4,a4,s3
 910:	c798                	sw	a4,8(a5)
        p += p->s.size;
 912:	02071693          	slli	a3,a4,0x20
 916:	01c6d713          	srli	a4,a3,0x1c
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	6ea73023          	sd	a0,1760(a4) # 1000 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	74a2                	ld	s1,40(sp)
 932:	7902                	ld	s2,32(sp)
 934:	69e2                	ld	s3,24(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	e118                	sd	a4,0(a0)
 944:	bff1                	j	920 <malloc+0x88>
  hp->s.size = nu;
 946:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94a:	0541                	addi	a0,a0,16
 94c:	00000097          	auipc	ra,0x0
 950:	eca080e7          	jalr	-310(ra) # 816 <free>
  return freep;
 954:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 958:	d971                	beqz	a0,92c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95c:	4798                	lw	a4,8(a5)
 95e:	fa9775e3          	bgeu	a4,s1,908 <malloc+0x70>
    if(p == freep)
 962:	00093703          	ld	a4,0(s2)
 966:	853e                	mv	a0,a5
 968:	fef719e3          	bne	a4,a5,95a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 96c:	8552                	mv	a0,s4
 96e:	00000097          	auipc	ra,0x0
 972:	b62080e7          	jalr	-1182(ra) # 4d0 <sbrk>
  if(p == (char*)-1)
 976:	fd5518e3          	bne	a0,s5,946 <malloc+0xae>
        return 0;
 97a:	4501                	li	a0,0
 97c:	bf45                	j	92c <malloc+0x94>
