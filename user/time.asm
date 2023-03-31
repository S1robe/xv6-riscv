
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/types.h"

int
main(int argc, char * argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64

  if(argc < 2){
   e:	4785                	li	a5,1
  10:	08a7d263          	bge	a5,a0,94 <main+0x94>
    printf("Usage: time <program to time>\n");
    return 1;
  }


  char * args[argc];
  14:	00351793          	slli	a5,a0,0x3
  18:	07bd                	addi	a5,a5,15
  1a:	9bc1                	andi	a5,a5,-16
  1c:	40f10133          	sub	sp,sp,a5
  20:	848a                	mv	s1,sp
  char * program = argv[1];
  22:	0085b903          	ld	s2,8(a1)

  int i = 1;
  for(; i < argc; i++)
  26:	00858793          	addi	a5,a1,8
  2a:	8726                	mv	a4,s1
  2c:	ffe5061b          	addiw	a2,a0,-2
  30:	02061693          	slli	a3,a2,0x20
  34:	01d6d613          	srli	a2,a3,0x1d
  38:	05c1                	addi	a1,a1,16
  3a:	962e                	add	a2,a2,a1
     args[i-1] = argv[i];                   // collect remaining argv[]
  3c:	6394                	ld	a3,0(a5)
  3e:	e314                	sd	a3,0(a4)
  for(; i < argc; i++)
  40:	07a1                	addi	a5,a5,8
  42:	0721                	addi	a4,a4,8
  44:	fec79ce3          	bne	a5,a2,3c <main+0x3c>

  args[i] = 0;
  48:	050e                	slli	a0,a0,0x3
  4a:	9526                	add	a0,a0,s1
  4c:	00053023          	sd	zero,0(a0)

  int b4 = uptime();
  50:	00000097          	auipc	ra,0x0
  54:	4fe080e7          	jalr	1278(ra) # 54e <uptime>
  58:	89aa                	mv	s3,a0
  int pid = fork();
  5a:	00000097          	auipc	ra,0x0
  5e:	454080e7          	jalr	1108(ra) # 4ae <fork>

  if(pid < 0){
  62:	04054363          	bltz	a0,a8 <main+0xa8>

    printf("Fork Error!\n");
    return 1;

  } else if(pid == 0){ // child
  66:	c939                	beqz	a0,bc <main+0xbc>
    printf("Exec Error!\n");
    return 1;

  } else {

    int status = 0;
  68:	fc042623          	sw	zero,-52(s0)
    wait(&status);
  6c:	fcc40513          	addi	a0,s0,-52
  70:	00000097          	auipc	ra,0x0
  74:	44e080e7          	jalr	1102(ra) # 4be <wait>
    if(status < 0){
  78:	fcc42783          	lw	a5,-52(s0)
      return 1;
  7c:	4505                	li	a0,1
    if(status < 0){
  7e:	0407df63          	bgez	a5,dc <main+0xdc>

    int a4 = uptime() - (b4);
    printf("Real-Time in ticks %d\n", a4);
    return 0;
  }
}
  82:	fc040113          	addi	sp,s0,-64
  86:	70e2                	ld	ra,56(sp)
  88:	7442                	ld	s0,48(sp)
  8a:	74a2                	ld	s1,40(sp)
  8c:	7902                	ld	s2,32(sp)
  8e:	69e2                	ld	s3,24(sp)
  90:	6121                	addi	sp,sp,64
  92:	8082                	ret
    printf("Usage: time <program to time>\n");
  94:	00001517          	auipc	a0,0x1
  98:	95c50513          	addi	a0,a0,-1700 # 9f0 <malloc+0xea>
  9c:	00000097          	auipc	ra,0x0
  a0:	7b2080e7          	jalr	1970(ra) # 84e <printf>
    return 1;
  a4:	4505                	li	a0,1
  a6:	bff1                	j	82 <main+0x82>
    printf("Fork Error!\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	96850513          	addi	a0,a0,-1688 # a10 <malloc+0x10a>
  b0:	00000097          	auipc	ra,0x0
  b4:	79e080e7          	jalr	1950(ra) # 84e <printf>
    return 1;
  b8:	4505                	li	a0,1
  ba:	b7e1                	j	82 <main+0x82>
    exec(program, args);
  bc:	85a6                	mv	a1,s1
  be:	854a                	mv	a0,s2
  c0:	00000097          	auipc	ra,0x0
  c4:	42e080e7          	jalr	1070(ra) # 4ee <exec>
    printf("Exec Error!\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	95850513          	addi	a0,a0,-1704 # a20 <malloc+0x11a>
  d0:	00000097          	auipc	ra,0x0
  d4:	77e080e7          	jalr	1918(ra) # 84e <printf>
    return 1;
  d8:	4505                	li	a0,1
  da:	b765                	j	82 <main+0x82>
    int a4 = uptime() - (b4);
  dc:	00000097          	auipc	ra,0x0
  e0:	472080e7          	jalr	1138(ra) # 54e <uptime>
    printf("Real-Time in ticks %d\n", a4);
  e4:	413505bb          	subw	a1,a0,s3
  e8:	00001517          	auipc	a0,0x1
  ec:	94850513          	addi	a0,a0,-1720 # a30 <malloc+0x12a>
  f0:	00000097          	auipc	ra,0x0
  f4:	75e080e7          	jalr	1886(ra) # 84e <printf>
    return 0;
  f8:	4501                	li	a0,0
  fa:	b761                	j	82 <main+0x82>

00000000000000fc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  extern int main();
  main();
 104:	00000097          	auipc	ra,0x0
 108:	efc080e7          	jalr	-260(ra) # 0 <main>
  exit(0);
 10c:	4501                	li	a0,0
 10e:	00000097          	auipc	ra,0x0
 112:	3a8080e7          	jalr	936(ra) # 4b6 <exit>

0000000000000116 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11c:	87aa                	mv	a5,a0
 11e:	0585                	addi	a1,a1,1
 120:	0785                	addi	a5,a5,1
 122:	fff5c703          	lbu	a4,-1(a1)
 126:	fee78fa3          	sb	a4,-1(a5)
 12a:	fb75                	bnez	a4,11e <strcpy+0x8>
    ;
  return os;
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	cb91                	beqz	a5,150 <strcmp+0x1e>
 13e:	0005c703          	lbu	a4,0(a1)
 142:	00f71763          	bne	a4,a5,150 <strcmp+0x1e>
    p++, q++;
 146:	0505                	addi	a0,a0,1
 148:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbe5                	bnez	a5,13e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 150:	0005c503          	lbu	a0,0(a1)
}
 154:	40a7853b          	subw	a0,a5,a0
 158:	6422                	ld	s0,8(sp)
 15a:	0141                	addi	sp,sp,16
 15c:	8082                	ret

000000000000015e <strlen>:

uint
strlen(const char *s)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 164:	00054783          	lbu	a5,0(a0)
 168:	cf91                	beqz	a5,184 <strlen+0x26>
 16a:	0505                	addi	a0,a0,1
 16c:	87aa                	mv	a5,a0
 16e:	86be                	mv	a3,a5
 170:	0785                	addi	a5,a5,1
 172:	fff7c703          	lbu	a4,-1(a5)
 176:	ff65                	bnez	a4,16e <strlen+0x10>
 178:	40a6853b          	subw	a0,a3,a0
 17c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
  for(n = 0; s[n]; n++)
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strlen+0x20>

0000000000000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18e:	ca19                	beqz	a2,1a4 <memset+0x1c>
 190:	87aa                	mv	a5,a0
 192:	1602                	slli	a2,a2,0x20
 194:	9201                	srli	a2,a2,0x20
 196:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19e:	0785                	addi	a5,a5,1
 1a0:	fee79de3          	bne	a5,a4,19a <memset+0x12>
  }
  return dst;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strchr>:

char*
strchr(const char *s, char c)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cb99                	beqz	a5,1ca <strchr+0x20>
    if(*s == c)
 1b6:	00f58763          	beq	a1,a5,1c4 <strchr+0x1a>
  for(; *s; s++)
 1ba:	0505                	addi	a0,a0,1
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbfd                	bnez	a5,1b6 <strchr+0xc>
      return (char*)s;
  return 0;
 1c2:	4501                	li	a0,0
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  return 0;
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <strchr+0x1a>

00000000000001ce <gets>:

char*
gets(char *buf, int max)
{
 1ce:	711d                	addi	sp,sp,-96
 1d0:	ec86                	sd	ra,88(sp)
 1d2:	e8a2                	sd	s0,80(sp)
 1d4:	e4a6                	sd	s1,72(sp)
 1d6:	e0ca                	sd	s2,64(sp)
 1d8:	fc4e                	sd	s3,56(sp)
 1da:	f852                	sd	s4,48(sp)
 1dc:	f456                	sd	s5,40(sp)
 1de:	f05a                	sd	s6,32(sp)
 1e0:	ec5e                	sd	s7,24(sp)
 1e2:	1080                	addi	s0,sp,96
 1e4:	8baa                	mv	s7,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ec:	4aa9                	li	s5,10
 1ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	2485                	addiw	s1,s1,1
 1f4:	0344d863          	bge	s1,s4,224 <gets+0x56>
    cc = read(0, &c, 1);
 1f8:	4605                	li	a2,1
 1fa:	faf40593          	addi	a1,s0,-81
 1fe:	4501                	li	a0,0
 200:	00000097          	auipc	ra,0x0
 204:	2ce080e7          	jalr	718(ra) # 4ce <read>
    if(cc < 1)
 208:	00a05e63          	blez	a0,224 <gets+0x56>
    buf[i++] = c;
 20c:	faf44783          	lbu	a5,-81(s0)
 210:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 214:	01578763          	beq	a5,s5,222 <gets+0x54>
 218:	0905                	addi	s2,s2,1
 21a:	fd679be3          	bne	a5,s6,1f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 21e:	89a6                	mv	s3,s1
 220:	a011                	j	224 <gets+0x56>
 222:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 224:	99de                	add	s3,s3,s7
 226:	00098023          	sb	zero,0(s3)
  return buf;
}
 22a:	855e                	mv	a0,s7
 22c:	60e6                	ld	ra,88(sp)
 22e:	6446                	ld	s0,80(sp)
 230:	64a6                	ld	s1,72(sp)
 232:	6906                	ld	s2,64(sp)
 234:	79e2                	ld	s3,56(sp)
 236:	7a42                	ld	s4,48(sp)
 238:	7aa2                	ld	s5,40(sp)
 23a:	7b02                	ld	s6,32(sp)
 23c:	6be2                	ld	s7,24(sp)
 23e:	6125                	addi	sp,sp,96
 240:	8082                	ret

0000000000000242 <stat>:

int
stat(const char *n, struct stat *st)
{
 242:	1101                	addi	sp,sp,-32
 244:	ec06                	sd	ra,24(sp)
 246:	e822                	sd	s0,16(sp)
 248:	e426                	sd	s1,8(sp)
 24a:	e04a                	sd	s2,0(sp)
 24c:	1000                	addi	s0,sp,32
 24e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 250:	4581                	li	a1,0
 252:	00000097          	auipc	ra,0x0
 256:	2a4080e7          	jalr	676(ra) # 4f6 <open>
  if(fd < 0)
 25a:	02054563          	bltz	a0,284 <stat+0x42>
 25e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 260:	85ca                	mv	a1,s2
 262:	00000097          	auipc	ra,0x0
 266:	2ac080e7          	jalr	684(ra) # 50e <fstat>
 26a:	892a                	mv	s2,a0
  close(fd);
 26c:	8526                	mv	a0,s1
 26e:	00000097          	auipc	ra,0x0
 272:	270080e7          	jalr	624(ra) # 4de <close>
  return r;
}
 276:	854a                	mv	a0,s2
 278:	60e2                	ld	ra,24(sp)
 27a:	6442                	ld	s0,16(sp)
 27c:	64a2                	ld	s1,8(sp)
 27e:	6902                	ld	s2,0(sp)
 280:	6105                	addi	sp,sp,32
 282:	8082                	ret
    return -1;
 284:	597d                	li	s2,-1
 286:	bfc5                	j	276 <stat+0x34>

0000000000000288 <atoi>:

int
atoi(const char *s)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 28e:	00054683          	lbu	a3,0(a0)
 292:	fd06879b          	addiw	a5,a3,-48
 296:	0ff7f793          	zext.b	a5,a5
 29a:	4625                	li	a2,9
 29c:	02f66863          	bltu	a2,a5,2cc <atoi+0x44>
 2a0:	872a                	mv	a4,a0
  n = 0;
 2a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a4:	0705                	addi	a4,a4,1
 2a6:	0025179b          	slliw	a5,a0,0x2
 2aa:	9fa9                	addw	a5,a5,a0
 2ac:	0017979b          	slliw	a5,a5,0x1
 2b0:	9fb5                	addw	a5,a5,a3
 2b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b6:	00074683          	lbu	a3,0(a4)
 2ba:	fd06879b          	addiw	a5,a3,-48
 2be:	0ff7f793          	zext.b	a5,a5
 2c2:	fef671e3          	bgeu	a2,a5,2a4 <atoi+0x1c>

  return n;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  n = 0;
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <atoi+0x3e>

00000000000002d0 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
 2d6:	8eaa                	mv	t4,a0
    register const char *s = strt;
 2d8:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 2da:	02000693          	li	a3,32
        c = *s++;
 2de:	883e                	mv	a6,a5
 2e0:	0785                	addi	a5,a5,1
 2e2:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 2e6:	fed70ce3          	beq	a4,a3,2de <strtoi+0xe>
        c = *s++;
 2ea:	2701                	sext.w	a4,a4

    if (c == '-') {
 2ec:	02d00693          	li	a3,45
 2f0:	04d70d63          	beq	a4,a3,34a <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 2f4:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 2f8:	4f01                	li	t5,0
    } else if (c == '+')
 2fa:	04d70e63          	beq	a4,a3,356 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 2fe:	fef67693          	andi	a3,a2,-17
 302:	ea99                	bnez	a3,318 <strtoi+0x48>
 304:	03000693          	li	a3,48
 308:	04d70c63          	beq	a4,a3,360 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 30c:	e611                	bnez	a2,318 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 30e:	03000693          	li	a3,48
 312:	0cd70b63          	beq	a4,a3,3e8 <strtoi+0x118>
 316:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 318:	800008b7          	lui	a7,0x80000
 31c:	fff8c893          	not	a7,a7
 320:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 324:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 328:	1882                	slli	a7,a7,0x20
 32a:	0208d893          	srli	a7,a7,0x20
 32e:	02c8d8b3          	divu	a7,a7,a2
 332:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 336:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 33a:	0ac75163          	bge	a4,a2,3dc <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 33e:	4681                	li	a3,0
 340:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 342:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 344:	2881                	sext.w	a7,a7
        else {
            any = 1;
 346:	4f85                	li	t6,1
 348:	a0a9                	j	392 <strtoi+0xc2>
        c = *s++;
 34a:	0007c703          	lbu	a4,0(a5)
 34e:	00280793          	addi	a5,a6,2
        neg = 1;
 352:	4f05                	li	t5,1
 354:	b76d                	j	2fe <strtoi+0x2e>
        c = *s++;
 356:	0007c703          	lbu	a4,0(a5)
 35a:	00280793          	addi	a5,a6,2
 35e:	b745                	j	2fe <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 360:	0007c683          	lbu	a3,0(a5)
 364:	0df6f693          	andi	a3,a3,223
 368:	05800513          	li	a0,88
 36c:	faa690e3          	bne	a3,a0,30c <strtoi+0x3c>
        c = s[1];
 370:	0017c703          	lbu	a4,1(a5)
        s += 2;
 374:	0789                	addi	a5,a5,2
        base = 16;
 376:	4641                	li	a2,16
 378:	b745                	j	318 <strtoi+0x48>
            any = -1;
 37a:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 37c:	00e2c463          	blt	t0,a4,384 <strtoi+0xb4>
 380:	a015                	j	3a4 <strtoi+0xd4>
            any = -1;
 382:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 384:	0785                	addi	a5,a5,1
 386:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 38a:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 38e:	02c75063          	bge	a4,a2,3ae <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 392:	fe06c8e3          	bltz	a3,382 <strtoi+0xb2>
 396:	0005081b          	sext.w	a6,a0
            any = -1;
 39a:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 39c:	ff0e64e3          	bltu	t3,a6,384 <strtoi+0xb4>
 3a0:	fca88de3          	beq	a7,a0,37a <strtoi+0xaa>
            acc *= base;
 3a4:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 3a8:	9d39                	addw	a0,a0,a4
            any = 1;
 3aa:	86fe                	mv	a3,t6
 3ac:	bfe1                	j	384 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 3ae:	0006cd63          	bltz	a3,3c8 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 3b2:	000f0463          	beqz	t5,3ba <strtoi+0xea>
        acc = -acc;
 3b6:	40a0053b          	negw	a0,a0
    if (end != 0)
 3ba:	c581                	beqz	a1,3c2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3bc:	ee89                	bnez	a3,3d6 <strtoi+0x106>
 3be:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 3c8:	000f1d63          	bnez	t5,3e2 <strtoi+0x112>
 3cc:	80000537          	lui	a0,0x80000
 3d0:	fff54513          	not	a0,a0
    if (end != 0)
 3d4:	d5fd                	beqz	a1,3c2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3d6:	fff78e93          	addi	t4,a5,-1
 3da:	b7d5                	j	3be <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 3dc:	4681                	li	a3,0
 3de:	4501                	li	a0,0
 3e0:	bfc9                	j	3b2 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 3e2:	80000537          	lui	a0,0x80000
 3e6:	b7fd                	j	3d4 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 3e8:	80000e37          	lui	t3,0x80000
 3ec:	fffe4e13          	not	t3,t3
 3f0:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 3f4:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 3f8:	003e589b          	srliw	a7,t3,0x3
 3fc:	8e46                	mv	t3,a7
            c -= '0';
 3fe:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 400:	4621                	li	a2,8
 402:	bf35                	j	33e <strtoi+0x6e>

0000000000000404 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 40a:	02b57463          	bgeu	a0,a1,432 <memmove+0x2e>
    while(n-- > 0)
 40e:	00c05f63          	blez	a2,42c <memmove+0x28>
 412:	1602                	slli	a2,a2,0x20
 414:	9201                	srli	a2,a2,0x20
 416:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 41a:	872a                	mv	a4,a0
      *dst++ = *src++;
 41c:	0585                	addi	a1,a1,1
 41e:	0705                	addi	a4,a4,1
 420:	fff5c683          	lbu	a3,-1(a1)
 424:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 428:	fee79ae3          	bne	a5,a4,41c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 42c:	6422                	ld	s0,8(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret
    dst += n;
 432:	00c50733          	add	a4,a0,a2
    src += n;
 436:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 438:	fec05ae3          	blez	a2,42c <memmove+0x28>
 43c:	fff6079b          	addiw	a5,a2,-1
 440:	1782                	slli	a5,a5,0x20
 442:	9381                	srli	a5,a5,0x20
 444:	fff7c793          	not	a5,a5
 448:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 44a:	15fd                	addi	a1,a1,-1
 44c:	177d                	addi	a4,a4,-1
 44e:	0005c683          	lbu	a3,0(a1)
 452:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 456:	fee79ae3          	bne	a5,a4,44a <memmove+0x46>
 45a:	bfc9                	j	42c <memmove+0x28>

000000000000045c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 45c:	1141                	addi	sp,sp,-16
 45e:	e422                	sd	s0,8(sp)
 460:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 462:	ca05                	beqz	a2,492 <memcmp+0x36>
 464:	fff6069b          	addiw	a3,a2,-1
 468:	1682                	slli	a3,a3,0x20
 46a:	9281                	srli	a3,a3,0x20
 46c:	0685                	addi	a3,a3,1
 46e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 470:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 474:	0005c703          	lbu	a4,0(a1)
 478:	00e79863          	bne	a5,a4,488 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 47c:	0505                	addi	a0,a0,1
    p2++;
 47e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 480:	fed518e3          	bne	a0,a3,470 <memcmp+0x14>
  }
  return 0;
 484:	4501                	li	a0,0
 486:	a019                	j	48c <memcmp+0x30>
      return *p1 - *p2;
 488:	40e7853b          	subw	a0,a5,a4
}
 48c:	6422                	ld	s0,8(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret
  return 0;
 492:	4501                	li	a0,0
 494:	bfe5                	j	48c <memcmp+0x30>

0000000000000496 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 496:	1141                	addi	sp,sp,-16
 498:	e406                	sd	ra,8(sp)
 49a:	e022                	sd	s0,0(sp)
 49c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 49e:	00000097          	auipc	ra,0x0
 4a2:	f66080e7          	jalr	-154(ra) # 404 <memmove>
}
 4a6:	60a2                	ld	ra,8(sp)
 4a8:	6402                	ld	s0,0(sp)
 4aa:	0141                	addi	sp,sp,16
 4ac:	8082                	ret

00000000000004ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ae:	4885                	li	a7,1
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b6:	4889                	li	a7,2
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <wait>:
.global wait
wait:
 li a7, SYS_wait
 4be:	488d                	li	a7,3
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c6:	4891                	li	a7,4
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <read>:
.global read
read:
 li a7, SYS_read
 4ce:	4895                	li	a7,5
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <write>:
.global write
write:
 li a7, SYS_write
 4d6:	48c1                	li	a7,16
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <close>:
.global close
close:
 li a7, SYS_close
 4de:	48d5                	li	a7,21
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e6:	4899                	li	a7,6
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ee:	489d                	li	a7,7
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <open>:
.global open
open:
 li a7, SYS_open
 4f6:	48bd                	li	a7,15
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4fe:	48c5                	li	a7,17
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 506:	48c9                	li	a7,18
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 50e:	48a1                	li	a7,8
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <link>:
.global link
link:
 li a7, SYS_link
 516:	48cd                	li	a7,19
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 51e:	48d1                	li	a7,20
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 526:	48a5                	li	a7,9
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <dup>:
.global dup
dup:
 li a7, SYS_dup
 52e:	48a9                	li	a7,10
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 536:	48ad                	li	a7,11
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 53e:	48b1                	li	a7,12
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 546:	48b5                	li	a7,13
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 54e:	48b9                	li	a7,14
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 556:	48d9                	li	a7,22
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 55e:	48dd                	li	a7,23
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 566:	48e1                	li	a7,24
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 56e:	48e5                	li	a7,25
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 576:	48e9                	li	a7,26
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 57e:	48ed                	li	a7,27
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 586:	1101                	addi	sp,sp,-32
 588:	ec06                	sd	ra,24(sp)
 58a:	e822                	sd	s0,16(sp)
 58c:	1000                	addi	s0,sp,32
 58e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 592:	4605                	li	a2,1
 594:	fef40593          	addi	a1,s0,-17
 598:	00000097          	auipc	ra,0x0
 59c:	f3e080e7          	jalr	-194(ra) # 4d6 <write>
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	6105                	addi	sp,sp,32
 5a6:	8082                	ret

00000000000005a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a8:	7139                	addi	sp,sp,-64
 5aa:	fc06                	sd	ra,56(sp)
 5ac:	f822                	sd	s0,48(sp)
 5ae:	f426                	sd	s1,40(sp)
 5b0:	f04a                	sd	s2,32(sp)
 5b2:	ec4e                	sd	s3,24(sp)
 5b4:	0080                	addi	s0,sp,64
 5b6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b8:	c299                	beqz	a3,5be <printint+0x16>
 5ba:	0805c963          	bltz	a1,64c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5be:	2581                	sext.w	a1,a1
  neg = 0;
 5c0:	4881                	li	a7,0
 5c2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5c6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c8:	2601                	sext.w	a2,a2
 5ca:	00000517          	auipc	a0,0x0
 5ce:	4de50513          	addi	a0,a0,1246 # aa8 <digits>
 5d2:	883a                	mv	a6,a4
 5d4:	2705                	addiw	a4,a4,1
 5d6:	02c5f7bb          	remuw	a5,a1,a2
 5da:	1782                	slli	a5,a5,0x20
 5dc:	9381                	srli	a5,a5,0x20
 5de:	97aa                	add	a5,a5,a0
 5e0:	0007c783          	lbu	a5,0(a5)
 5e4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e8:	0005879b          	sext.w	a5,a1
 5ec:	02c5d5bb          	divuw	a1,a1,a2
 5f0:	0685                	addi	a3,a3,1
 5f2:	fec7f0e3          	bgeu	a5,a2,5d2 <printint+0x2a>
  if(neg)
 5f6:	00088c63          	beqz	a7,60e <printint+0x66>
    buf[i++] = '-';
 5fa:	fd070793          	addi	a5,a4,-48
 5fe:	00878733          	add	a4,a5,s0
 602:	02d00793          	li	a5,45
 606:	fef70823          	sb	a5,-16(a4)
 60a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 60e:	02e05863          	blez	a4,63e <printint+0x96>
 612:	fc040793          	addi	a5,s0,-64
 616:	00e78933          	add	s2,a5,a4
 61a:	fff78993          	addi	s3,a5,-1
 61e:	99ba                	add	s3,s3,a4
 620:	377d                	addiw	a4,a4,-1
 622:	1702                	slli	a4,a4,0x20
 624:	9301                	srli	a4,a4,0x20
 626:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 62a:	fff94583          	lbu	a1,-1(s2)
 62e:	8526                	mv	a0,s1
 630:	00000097          	auipc	ra,0x0
 634:	f56080e7          	jalr	-170(ra) # 586 <putc>
  while(--i >= 0)
 638:	197d                	addi	s2,s2,-1
 63a:	ff3918e3          	bne	s2,s3,62a <printint+0x82>
}
 63e:	70e2                	ld	ra,56(sp)
 640:	7442                	ld	s0,48(sp)
 642:	74a2                	ld	s1,40(sp)
 644:	7902                	ld	s2,32(sp)
 646:	69e2                	ld	s3,24(sp)
 648:	6121                	addi	sp,sp,64
 64a:	8082                	ret
    x = -xx;
 64c:	40b005bb          	negw	a1,a1
    neg = 1;
 650:	4885                	li	a7,1
    x = -xx;
 652:	bf85                	j	5c2 <printint+0x1a>

0000000000000654 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 654:	715d                	addi	sp,sp,-80
 656:	e486                	sd	ra,72(sp)
 658:	e0a2                	sd	s0,64(sp)
 65a:	fc26                	sd	s1,56(sp)
 65c:	f84a                	sd	s2,48(sp)
 65e:	f44e                	sd	s3,40(sp)
 660:	f052                	sd	s4,32(sp)
 662:	ec56                	sd	s5,24(sp)
 664:	e85a                	sd	s6,16(sp)
 666:	e45e                	sd	s7,8(sp)
 668:	e062                	sd	s8,0(sp)
 66a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 66c:	0005c903          	lbu	s2,0(a1)
 670:	18090c63          	beqz	s2,808 <vprintf+0x1b4>
 674:	8aaa                	mv	s5,a0
 676:	8bb2                	mv	s7,a2
 678:	00158493          	addi	s1,a1,1
  state = 0;
 67c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 67e:	02500a13          	li	s4,37
 682:	4b55                	li	s6,21
 684:	a839                	j	6a2 <vprintf+0x4e>
        putc(fd, c);
 686:	85ca                	mv	a1,s2
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	efc080e7          	jalr	-260(ra) # 586 <putc>
 692:	a019                	j	698 <vprintf+0x44>
    } else if(state == '%'){
 694:	01498d63          	beq	s3,s4,6ae <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 698:	0485                	addi	s1,s1,1
 69a:	fff4c903          	lbu	s2,-1(s1)
 69e:	16090563          	beqz	s2,808 <vprintf+0x1b4>
    if(state == 0){
 6a2:	fe0999e3          	bnez	s3,694 <vprintf+0x40>
      if(c == '%'){
 6a6:	ff4910e3          	bne	s2,s4,686 <vprintf+0x32>
        state = '%';
 6aa:	89d2                	mv	s3,s4
 6ac:	b7f5                	j	698 <vprintf+0x44>
      if(c == 'd'){
 6ae:	13490263          	beq	s2,s4,7d2 <vprintf+0x17e>
 6b2:	f9d9079b          	addiw	a5,s2,-99
 6b6:	0ff7f793          	zext.b	a5,a5
 6ba:	12fb6563          	bltu	s6,a5,7e4 <vprintf+0x190>
 6be:	f9d9079b          	addiw	a5,s2,-99
 6c2:	0ff7f713          	zext.b	a4,a5
 6c6:	10eb6f63          	bltu	s6,a4,7e4 <vprintf+0x190>
 6ca:	00271793          	slli	a5,a4,0x2
 6ce:	00000717          	auipc	a4,0x0
 6d2:	38270713          	addi	a4,a4,898 # a50 <malloc+0x14a>
 6d6:	97ba                	add	a5,a5,a4
 6d8:	439c                	lw	a5,0(a5)
 6da:	97ba                	add	a5,a5,a4
 6dc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4685                	li	a3,1
 6e4:	4629                	li	a2,10
 6e6:	000ba583          	lw	a1,0(s7)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	ebc080e7          	jalr	-324(ra) # 5a8 <printint>
 6f4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b745                	j	698 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4629                	li	a2,10
 702:	000ba583          	lw	a1,0(s7)
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	ea0080e7          	jalr	-352(ra) # 5a8 <printint>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	b751                	j	698 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 716:	008b8913          	addi	s2,s7,8
 71a:	4681                	li	a3,0
 71c:	4641                	li	a2,16
 71e:	000ba583          	lw	a1,0(s7)
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e84080e7          	jalr	-380(ra) # 5a8 <printint>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	b7a5                	j	698 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 732:	008b8c13          	addi	s8,s7,8
 736:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 73a:	03000593          	li	a1,48
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	e46080e7          	jalr	-442(ra) # 586 <putc>
  putc(fd, 'x');
 748:	07800593          	li	a1,120
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	e38080e7          	jalr	-456(ra) # 586 <putc>
 756:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 758:	00000b97          	auipc	s7,0x0
 75c:	350b8b93          	addi	s7,s7,848 # aa8 <digits>
 760:	03c9d793          	srli	a5,s3,0x3c
 764:	97de                	add	a5,a5,s7
 766:	0007c583          	lbu	a1,0(a5)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e1a080e7          	jalr	-486(ra) # 586 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 774:	0992                	slli	s3,s3,0x4
 776:	397d                	addiw	s2,s2,-1
 778:	fe0914e3          	bnez	s2,760 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 77c:	8be2                	mv	s7,s8
      state = 0;
 77e:	4981                	li	s3,0
 780:	bf21                	j	698 <vprintf+0x44>
        s = va_arg(ap, char*);
 782:	008b8993          	addi	s3,s7,8
 786:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 78a:	02090163          	beqz	s2,7ac <vprintf+0x158>
        while(*s != 0){
 78e:	00094583          	lbu	a1,0(s2)
 792:	c9a5                	beqz	a1,802 <vprintf+0x1ae>
          putc(fd, *s);
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	df0080e7          	jalr	-528(ra) # 586 <putc>
          s++;
 79e:	0905                	addi	s2,s2,1
        while(*s != 0){
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	f9e5                	bnez	a1,794 <vprintf+0x140>
        s = va_arg(ap, char*);
 7a6:	8bce                	mv	s7,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b5fd                	j	698 <vprintf+0x44>
          s = "(null)";
 7ac:	00000917          	auipc	s2,0x0
 7b0:	29c90913          	addi	s2,s2,668 # a48 <malloc+0x142>
        while(*s != 0){
 7b4:	02800593          	li	a1,40
 7b8:	bff1                	j	794 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 7ba:	008b8913          	addi	s2,s7,8
 7be:	000bc583          	lbu	a1,0(s7)
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	dc2080e7          	jalr	-574(ra) # 586 <putc>
 7cc:	8bca                	mv	s7,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b5e1                	j	698 <vprintf+0x44>
        putc(fd, c);
 7d2:	02500593          	li	a1,37
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	dae080e7          	jalr	-594(ra) # 586 <putc>
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	bd5d                	j	698 <vprintf+0x44>
        putc(fd, '%');
 7e4:	02500593          	li	a1,37
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	d9c080e7          	jalr	-612(ra) # 586 <putc>
        putc(fd, c);
 7f2:	85ca                	mv	a1,s2
 7f4:	8556                	mv	a0,s5
 7f6:	00000097          	auipc	ra,0x0
 7fa:	d90080e7          	jalr	-624(ra) # 586 <putc>
      state = 0;
 7fe:	4981                	li	s3,0
 800:	bd61                	j	698 <vprintf+0x44>
        s = va_arg(ap, char*);
 802:	8bce                	mv	s7,s3
      state = 0;
 804:	4981                	li	s3,0
 806:	bd49                	j	698 <vprintf+0x44>
    }
  }
}
 808:	60a6                	ld	ra,72(sp)
 80a:	6406                	ld	s0,64(sp)
 80c:	74e2                	ld	s1,56(sp)
 80e:	7942                	ld	s2,48(sp)
 810:	79a2                	ld	s3,40(sp)
 812:	7a02                	ld	s4,32(sp)
 814:	6ae2                	ld	s5,24(sp)
 816:	6b42                	ld	s6,16(sp)
 818:	6ba2                	ld	s7,8(sp)
 81a:	6c02                	ld	s8,0(sp)
 81c:	6161                	addi	sp,sp,80
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	addi	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	00000097          	auipc	ra,0x0
 842:	e16080e7          	jalr	-490(ra) # 654 <vprintf>
}
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	6161                	addi	sp,sp,80
 84c:	8082                	ret

000000000000084e <printf>:

void
printf(const char *fmt, ...)
{
 84e:	711d                	addi	sp,sp,-96
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	addi	s0,sp,32
 856:	e40c                	sd	a1,8(s0)
 858:	e810                	sd	a2,16(s0)
 85a:	ec14                	sd	a3,24(s0)
 85c:	f018                	sd	a4,32(s0)
 85e:	f41c                	sd	a5,40(s0)
 860:	03043823          	sd	a6,48(s0)
 864:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	00840613          	addi	a2,s0,8
 86c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 870:	85aa                	mv	a1,a0
 872:	4505                	li	a0,1
 874:	00000097          	auipc	ra,0x0
 878:	de0080e7          	jalr	-544(ra) # 654 <vprintf>
}
 87c:	60e2                	ld	ra,24(sp)
 87e:	6442                	ld	s0,16(sp)
 880:	6125                	addi	sp,sp,96
 882:	8082                	ret

0000000000000884 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 884:	1141                	addi	sp,sp,-16
 886:	e422                	sd	s0,8(sp)
 888:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	00000797          	auipc	a5,0x0
 892:	7727b783          	ld	a5,1906(a5) # 1000 <freep>
 896:	a02d                	j	8c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 898:	4618                	lw	a4,8(a2)
 89a:	9f2d                	addw	a4,a4,a1
 89c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	6398                	ld	a4,0(a5)
 8a2:	6310                	ld	a2,0(a4)
 8a4:	a83d                	j	8e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a6:	ff852703          	lw	a4,-8(a0)
 8aa:	9f31                	addw	a4,a4,a2
 8ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ae:	ff053683          	ld	a3,-16(a0)
 8b2:	a091                	j	8f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e7e463          	bltu	a5,a4,8be <free+0x3a>
 8ba:	00e6ea63          	bltu	a3,a4,8ce <free+0x4a>
{
 8be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	fed7fae3          	bgeu	a5,a3,8b4 <free+0x30>
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e6e463          	bltu	a3,a4,8ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	fee7eae3          	bltu	a5,a4,8be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ce:	ff852583          	lw	a1,-8(a0)
 8d2:	6390                	ld	a2,0(a5)
 8d4:	02059813          	slli	a6,a1,0x20
 8d8:	01c85713          	srli	a4,a6,0x1c
 8dc:	9736                	add	a4,a4,a3
 8de:	fae60de3          	beq	a2,a4,898 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e6:	4790                	lw	a2,8(a5)
 8e8:	02061593          	slli	a1,a2,0x20
 8ec:	01c5d713          	srli	a4,a1,0x1c
 8f0:	973e                	add	a4,a4,a5
 8f2:	fae68ae3          	beq	a3,a4,8a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	addi	sp,sp,16
 904:	8082                	ret

0000000000000906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 906:	7139                	addi	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f426                	sd	s1,40(sp)
 90e:	f04a                	sd	s2,32(sp)
 910:	ec4e                	sd	s3,24(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
 918:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91a:	02051493          	slli	s1,a0,0x20
 91e:	9081                	srli	s1,s1,0x20
 920:	04bd                	addi	s1,s1,15
 922:	8091                	srli	s1,s1,0x4
 924:	0014899b          	addiw	s3,s1,1
 928:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 92a:	00000517          	auipc	a0,0x0
 92e:	6d653503          	ld	a0,1750(a0) # 1000 <freep>
 932:	c515                	beqz	a0,95e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	02977f63          	bgeu	a4,s1,976 <malloc+0x70>
  if(nu < 4096)
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bgeu	a4,a3,94a <malloc+0x44>
 948:	6a05                	lui	s4,0x1
 94a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 952:	00000917          	auipc	s2,0x0
 956:	6ae90913          	addi	s2,s2,1710 # 1000 <freep>
  if(p == (char*)-1)
 95a:	5afd                	li	s5,-1
 95c:	a895                	j	9d0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 95e:	00000797          	auipc	a5,0x0
 962:	6b278793          	addi	a5,a5,1714 # 1010 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	68f73d23          	sd	a5,1690(a4) # 1000 <freep>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 974:	b7e1                	j	93c <malloc+0x36>
      if(p->s.size == nunits)
 976:	02e48c63          	beq	s1,a4,9ae <malloc+0xa8>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	02071693          	slli	a3,a4,0x20
 984:	01c6d713          	srli	a4,a3,0x1c
 988:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98e:	00000717          	auipc	a4,0x0
 992:	66a73923          	sd	a0,1650(a4) # 1000 <freep>
      return (void*)(p + 1);
 996:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 99a:	70e2                	ld	ra,56(sp)
 99c:	7442                	ld	s0,48(sp)
 99e:	74a2                	ld	s1,40(sp)
 9a0:	7902                	ld	s2,32(sp)
 9a2:	69e2                	ld	s3,24(sp)
 9a4:	6a42                	ld	s4,16(sp)
 9a6:	6aa2                	ld	s5,8(sp)
 9a8:	6b02                	ld	s6,0(sp)
 9aa:	6121                	addi	sp,sp,64
 9ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ae:	6398                	ld	a4,0(a5)
 9b0:	e118                	sd	a4,0(a0)
 9b2:	bff1                	j	98e <malloc+0x88>
  hp->s.size = nu;
 9b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b8:	0541                	addi	a0,a0,16
 9ba:	00000097          	auipc	ra,0x0
 9be:	eca080e7          	jalr	-310(ra) # 884 <free>
  return freep;
 9c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c6:	d971                	beqz	a0,99a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ca:	4798                	lw	a4,8(a5)
 9cc:	fa9775e3          	bgeu	a4,s1,976 <malloc+0x70>
    if(p == freep)
 9d0:	00093703          	ld	a4,0(s2)
 9d4:	853e                	mv	a0,a5
 9d6:	fef719e3          	bne	a4,a5,9c8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9da:	8552                	mv	a0,s4
 9dc:	00000097          	auipc	ra,0x0
 9e0:	b62080e7          	jalr	-1182(ra) # 53e <sbrk>
  if(p == (char*)-1)
 9e4:	fd5518e3          	bne	a0,s5,9b4 <malloc+0xae>
        return 0;
 9e8:	4501                	li	a0,0
 9ea:	bf45                	j	99a <malloc+0x94>
