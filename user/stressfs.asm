
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	a1a78793          	addi	a5,a5,-1510 # a30 <malloc+0x11a>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	9d450513          	addi	a0,a0,-1580 # a00 <malloc+0xea>
  34:	00001097          	auipc	ra,0x1
  38:	82a080e7          	jalr	-2006(ra) # 85e <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	46a080e7          	jalr	1130(ra) # 4be <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	9b050513          	addi	a0,a0,-1616 # a18 <malloc+0x102>
  70:	00000097          	auipc	ra,0x0
  74:	7ee080e7          	jalr	2030(ra) # 85e <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9fa5                	addw	a5,a5,s1
  7e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	47c080e7          	jalr	1148(ra) # 506 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	446080e7          	jalr	1094(ra) # 4e6 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	440080e7          	jalr	1088(ra) # 4ee <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	97250513          	addi	a0,a0,-1678 # a28 <malloc+0x112>
  be:	00000097          	auipc	ra,0x0
  c2:	7a0080e7          	jalr	1952(ra) # 85e <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	43a080e7          	jalr	1082(ra) # 506 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	3fc080e7          	jalr	1020(ra) # 4de <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	3fe080e7          	jalr	1022(ra) # 4ee <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	3d4080e7          	jalr	980(ra) # 4ce <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	3c2080e7          	jalr	962(ra) # 4c6 <exit>

000000000000010c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  extern int main();
  main();
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	3a8080e7          	jalr	936(ra) # 4c6 <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12c:	87aa                	mv	a5,a0
 12e:	0585                	addi	a1,a1,1
 130:	0785                	addi	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
    ;
  return os;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
    p++, q++;
 156:	0505                	addi	a0,a0,1
 158:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 160:	0005c503          	lbu	a0,0(a1)
}
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:

uint
strlen(const char *s)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	addi	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x10>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19e:	ca19                	beqz	a2,1b4 <memset+0x1c>
 1a0:	87aa                	mv	a5,a0
 1a2:	1602                	slli	a2,a2,0x20
 1a4:	9201                	srli	a2,a2,0x20
 1a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ae:	0785                	addi	a5,a5,1
 1b0:	fee79de3          	bne	a5,a4,1aa <memset+0x12>
  }
  return dst;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb99                	beqz	a5,1da <strchr+0x20>
    if(*s == c)
 1c6:	00f58763          	beq	a1,a5,1d4 <strchr+0x1a>
  for(; *s; s++)
 1ca:	0505                	addi	a0,a0,1
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbfd                	bnez	a5,1c6 <strchr+0xc>
      return (char*)s;
  return 0;
 1d2:	4501                	li	a0,0
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strchr+0x1a>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	711d                	addi	sp,sp,-96
 1e0:	ec86                	sd	ra,88(sp)
 1e2:	e8a2                	sd	s0,80(sp)
 1e4:	e4a6                	sd	s1,72(sp)
 1e6:	e0ca                	sd	s2,64(sp)
 1e8:	fc4e                	sd	s3,56(sp)
 1ea:	f852                	sd	s4,48(sp)
 1ec:	f456                	sd	s5,40(sp)
 1ee:	f05a                	sd	s6,32(sp)
 1f0:	ec5e                	sd	s7,24(sp)
 1f2:	1080                	addi	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fc:	4aa9                	li	s5,10
 1fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	2485                	addiw	s1,s1,1
 204:	0344d863          	bge	s1,s4,234 <gets+0x56>
    cc = read(0, &c, 1);
 208:	4605                	li	a2,1
 20a:	faf40593          	addi	a1,s0,-81
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	2ce080e7          	jalr	718(ra) # 4de <read>
    if(cc < 1)
 218:	00a05e63          	blez	a0,234 <gets+0x56>
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	01578763          	beq	a5,s5,232 <gets+0x54>
 228:	0905                	addi	s2,s2,1
 22a:	fd679be3          	bne	a5,s6,200 <gets+0x22>
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	a011                	j	234 <gets+0x56>
 232:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 234:	99de                	add	s3,s3,s7
 236:	00098023          	sb	zero,0(s3)
  return buf;
}
 23a:	855e                	mv	a0,s7
 23c:	60e6                	ld	ra,88(sp)
 23e:	6446                	ld	s0,80(sp)
 240:	64a6                	ld	s1,72(sp)
 242:	6906                	ld	s2,64(sp)
 244:	79e2                	ld	s3,56(sp)
 246:	7a42                	ld	s4,48(sp)
 248:	7aa2                	ld	s5,40(sp)
 24a:	7b02                	ld	s6,32(sp)
 24c:	6be2                	ld	s7,24(sp)
 24e:	6125                	addi	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	addi	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e426                	sd	s1,8(sp)
 25a:	e04a                	sd	s2,0(sp)
 25c:	1000                	addi	s0,sp,32
 25e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 260:	4581                	li	a1,0
 262:	00000097          	auipc	ra,0x0
 266:	2a4080e7          	jalr	676(ra) # 506 <open>
  if(fd < 0)
 26a:	02054563          	bltz	a0,294 <stat+0x42>
 26e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 270:	85ca                	mv	a1,s2
 272:	00000097          	auipc	ra,0x0
 276:	2ac080e7          	jalr	684(ra) # 51e <fstat>
 27a:	892a                	mv	s2,a0
  close(fd);
 27c:	8526                	mv	a0,s1
 27e:	00000097          	auipc	ra,0x0
 282:	270080e7          	jalr	624(ra) # 4ee <close>
  return r;
}
 286:	854a                	mv	a0,s2
 288:	60e2                	ld	ra,24(sp)
 28a:	6442                	ld	s0,16(sp)
 28c:	64a2                	ld	s1,8(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	addi	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfc5                	j	286 <stat+0x34>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	addi	a4,a4,1
 2b6:	0025179b          	slliw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	slliw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addiw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>

  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
 2e6:	8eaa                	mv	t4,a0
    register const char *s = strt;
 2e8:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 2ea:	02000693          	li	a3,32
        c = *s++;
 2ee:	883e                	mv	a6,a5
 2f0:	0785                	addi	a5,a5,1
 2f2:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 2f6:	fed70ce3          	beq	a4,a3,2ee <strtoi+0xe>
        c = *s++;
 2fa:	2701                	sext.w	a4,a4

    if (c == '-') {
 2fc:	02d00693          	li	a3,45
 300:	04d70d63          	beq	a4,a3,35a <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 304:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 308:	4f01                	li	t5,0
    } else if (c == '+')
 30a:	04d70e63          	beq	a4,a3,366 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 30e:	fef67693          	andi	a3,a2,-17
 312:	ea99                	bnez	a3,328 <strtoi+0x48>
 314:	03000693          	li	a3,48
 318:	04d70c63          	beq	a4,a3,370 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 31c:	e611                	bnez	a2,328 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 31e:	03000693          	li	a3,48
 322:	0cd70b63          	beq	a4,a3,3f8 <strtoi+0x118>
 326:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 328:	800008b7          	lui	a7,0x80000
 32c:	fff8c893          	not	a7,a7
 330:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 334:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 338:	1882                	slli	a7,a7,0x20
 33a:	0208d893          	srli	a7,a7,0x20
 33e:	02c8d8b3          	divu	a7,a7,a2
 342:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 346:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 34a:	0ac75163          	bge	a4,a2,3ec <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 34e:	4681                	li	a3,0
 350:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 352:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 354:	2881                	sext.w	a7,a7
        else {
            any = 1;
 356:	4f85                	li	t6,1
 358:	a0a9                	j	3a2 <strtoi+0xc2>
        c = *s++;
 35a:	0007c703          	lbu	a4,0(a5)
 35e:	00280793          	addi	a5,a6,2
        neg = 1;
 362:	4f05                	li	t5,1
 364:	b76d                	j	30e <strtoi+0x2e>
        c = *s++;
 366:	0007c703          	lbu	a4,0(a5)
 36a:	00280793          	addi	a5,a6,2
 36e:	b745                	j	30e <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 370:	0007c683          	lbu	a3,0(a5)
 374:	0df6f693          	andi	a3,a3,223
 378:	05800513          	li	a0,88
 37c:	faa690e3          	bne	a3,a0,31c <strtoi+0x3c>
        c = s[1];
 380:	0017c703          	lbu	a4,1(a5)
        s += 2;
 384:	0789                	addi	a5,a5,2
        base = 16;
 386:	4641                	li	a2,16
 388:	b745                	j	328 <strtoi+0x48>
            any = -1;
 38a:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 38c:	00e2c463          	blt	t0,a4,394 <strtoi+0xb4>
 390:	a015                	j	3b4 <strtoi+0xd4>
            any = -1;
 392:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 394:	0785                	addi	a5,a5,1
 396:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 39a:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 39e:	02c75063          	bge	a4,a2,3be <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 3a2:	fe06c8e3          	bltz	a3,392 <strtoi+0xb2>
 3a6:	0005081b          	sext.w	a6,a0
            any = -1;
 3aa:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 3ac:	ff0e64e3          	bltu	t3,a6,394 <strtoi+0xb4>
 3b0:	fca88de3          	beq	a7,a0,38a <strtoi+0xaa>
            acc *= base;
 3b4:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 3b8:	9d39                	addw	a0,a0,a4
            any = 1;
 3ba:	86fe                	mv	a3,t6
 3bc:	bfe1                	j	394 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 3be:	0006cd63          	bltz	a3,3d8 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 3c2:	000f0463          	beqz	t5,3ca <strtoi+0xea>
        acc = -acc;
 3c6:	40a0053b          	negw	a0,a0
    if (end != 0)
 3ca:	c581                	beqz	a1,3d2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3cc:	ee89                	bnez	a3,3e6 <strtoi+0x106>
 3ce:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 3d2:	6422                	ld	s0,8(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 3d8:	000f1d63          	bnez	t5,3f2 <strtoi+0x112>
 3dc:	80000537          	lui	a0,0x80000
 3e0:	fff54513          	not	a0,a0
    if (end != 0)
 3e4:	d5fd                	beqz	a1,3d2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3e6:	fff78e93          	addi	t4,a5,-1
 3ea:	b7d5                	j	3ce <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 3ec:	4681                	li	a3,0
 3ee:	4501                	li	a0,0
 3f0:	bfc9                	j	3c2 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 3f2:	80000537          	lui	a0,0x80000
 3f6:	b7fd                	j	3e4 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 3f8:	80000e37          	lui	t3,0x80000
 3fc:	fffe4e13          	not	t3,t3
 400:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 404:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 408:	003e589b          	srliw	a7,t3,0x3
 40c:	8e46                	mv	t3,a7
            c -= '0';
 40e:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 410:	4621                	li	a2,8
 412:	bf35                	j	34e <strtoi+0x6e>

0000000000000414 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 414:	1141                	addi	sp,sp,-16
 416:	e422                	sd	s0,8(sp)
 418:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41a:	02b57463          	bgeu	a0,a1,442 <memmove+0x2e>
    while(n-- > 0)
 41e:	00c05f63          	blez	a2,43c <memmove+0x28>
 422:	1602                	slli	a2,a2,0x20
 424:	9201                	srli	a2,a2,0x20
 426:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42a:	872a                	mv	a4,a0
      *dst++ = *src++;
 42c:	0585                	addi	a1,a1,1
 42e:	0705                	addi	a4,a4,1
 430:	fff5c683          	lbu	a3,-1(a1)
 434:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 438:	fee79ae3          	bne	a5,a4,42c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
    dst += n;
 442:	00c50733          	add	a4,a0,a2
    src += n;
 446:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 448:	fec05ae3          	blez	a2,43c <memmove+0x28>
 44c:	fff6079b          	addiw	a5,a2,-1
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	fff7c793          	not	a5,a5
 458:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45a:	15fd                	addi	a1,a1,-1
 45c:	177d                	addi	a4,a4,-1
 45e:	0005c683          	lbu	a3,0(a1)
 462:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 466:	fee79ae3          	bne	a5,a4,45a <memmove+0x46>
 46a:	bfc9                	j	43c <memmove+0x28>

000000000000046c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e422                	sd	s0,8(sp)
 470:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 472:	ca05                	beqz	a2,4a2 <memcmp+0x36>
 474:	fff6069b          	addiw	a3,a2,-1
 478:	1682                	slli	a3,a3,0x20
 47a:	9281                	srli	a3,a3,0x20
 47c:	0685                	addi	a3,a3,1
 47e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 480:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffeff0>
 484:	0005c703          	lbu	a4,0(a1)
 488:	00e79863          	bne	a5,a4,498 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48c:	0505                	addi	a0,a0,1
    p2++;
 48e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 490:	fed518e3          	bne	a0,a3,480 <memcmp+0x14>
  }
  return 0;
 494:	4501                	li	a0,0
 496:	a019                	j	49c <memcmp+0x30>
      return *p1 - *p2;
 498:	40e7853b          	subw	a0,a5,a4
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  return 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <memcmp+0x30>

00000000000004a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f66080e7          	jalr	-154(ra) # 414 <memmove>
}
 4b6:	60a2                	ld	ra,8(sp)
 4b8:	6402                	ld	s0,0(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret

00000000000004be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4be:	4885                	li	a7,1
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c6:	4889                	li	a7,2
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ce:	488d                	li	a7,3
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d6:	4891                	li	a7,4
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <read>:
.global read
read:
 li a7, SYS_read
 4de:	4895                	li	a7,5
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <write>:
.global write
write:
 li a7, SYS_write
 4e6:	48c1                	li	a7,16
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <close>:
.global close
close:
 li a7, SYS_close
 4ee:	48d5                	li	a7,21
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f6:	4899                	li	a7,6
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fe:	489d                	li	a7,7
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <open>:
.global open
open:
 li a7, SYS_open
 506:	48bd                	li	a7,15
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50e:	48c5                	li	a7,17
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 516:	48c9                	li	a7,18
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51e:	48a1                	li	a7,8
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <link>:
.global link
link:
 li a7, SYS_link
 526:	48cd                	li	a7,19
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52e:	48d1                	li	a7,20
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 536:	48a5                	li	a7,9
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <dup>:
.global dup
dup:
 li a7, SYS_dup
 53e:	48a9                	li	a7,10
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 546:	48ad                	li	a7,11
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 54e:	48b1                	li	a7,12
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 556:	48b5                	li	a7,13
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55e:	48b9                	li	a7,14
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 566:	48d9                	li	a7,22
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 56e:	48dd                	li	a7,23
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 576:	48e1                	li	a7,24
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 57e:	48e5                	li	a7,25
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 586:	48e9                	li	a7,26
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 58e:	48ed                	li	a7,27
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a2:	4605                	li	a2,1
 5a4:	fef40593          	addi	a1,s0,-17
 5a8:	00000097          	auipc	ra,0x0
 5ac:	f3e080e7          	jalr	-194(ra) # 4e6 <write>
}
 5b0:	60e2                	ld	ra,24(sp)
 5b2:	6442                	ld	s0,16(sp)
 5b4:	6105                	addi	sp,sp,32
 5b6:	8082                	ret

00000000000005b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b8:	7139                	addi	sp,sp,-64
 5ba:	fc06                	sd	ra,56(sp)
 5bc:	f822                	sd	s0,48(sp)
 5be:	f426                	sd	s1,40(sp)
 5c0:	f04a                	sd	s2,32(sp)
 5c2:	ec4e                	sd	s3,24(sp)
 5c4:	0080                	addi	s0,sp,64
 5c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5c8:	c299                	beqz	a3,5ce <printint+0x16>
 5ca:	0805c963          	bltz	a1,65c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ce:	2581                	sext.w	a1,a1
  neg = 0;
 5d0:	4881                	li	a7,0
 5d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5d8:	2601                	sext.w	a2,a2
 5da:	00000517          	auipc	a0,0x0
 5de:	4c650513          	addi	a0,a0,1222 # aa0 <digits>
 5e2:	883a                	mv	a6,a4
 5e4:	2705                	addiw	a4,a4,1
 5e6:	02c5f7bb          	remuw	a5,a1,a2
 5ea:	1782                	slli	a5,a5,0x20
 5ec:	9381                	srli	a5,a5,0x20
 5ee:	97aa                	add	a5,a5,a0
 5f0:	0007c783          	lbu	a5,0(a5)
 5f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5f8:	0005879b          	sext.w	a5,a1
 5fc:	02c5d5bb          	divuw	a1,a1,a2
 600:	0685                	addi	a3,a3,1
 602:	fec7f0e3          	bgeu	a5,a2,5e2 <printint+0x2a>
  if(neg)
 606:	00088c63          	beqz	a7,61e <printint+0x66>
    buf[i++] = '-';
 60a:	fd070793          	addi	a5,a4,-48
 60e:	00878733          	add	a4,a5,s0
 612:	02d00793          	li	a5,45
 616:	fef70823          	sb	a5,-16(a4)
 61a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 61e:	02e05863          	blez	a4,64e <printint+0x96>
 622:	fc040793          	addi	a5,s0,-64
 626:	00e78933          	add	s2,a5,a4
 62a:	fff78993          	addi	s3,a5,-1
 62e:	99ba                	add	s3,s3,a4
 630:	377d                	addiw	a4,a4,-1
 632:	1702                	slli	a4,a4,0x20
 634:	9301                	srli	a4,a4,0x20
 636:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 63a:	fff94583          	lbu	a1,-1(s2)
 63e:	8526                	mv	a0,s1
 640:	00000097          	auipc	ra,0x0
 644:	f56080e7          	jalr	-170(ra) # 596 <putc>
  while(--i >= 0)
 648:	197d                	addi	s2,s2,-1
 64a:	ff3918e3          	bne	s2,s3,63a <printint+0x82>
}
 64e:	70e2                	ld	ra,56(sp)
 650:	7442                	ld	s0,48(sp)
 652:	74a2                	ld	s1,40(sp)
 654:	7902                	ld	s2,32(sp)
 656:	69e2                	ld	s3,24(sp)
 658:	6121                	addi	sp,sp,64
 65a:	8082                	ret
    x = -xx;
 65c:	40b005bb          	negw	a1,a1
    neg = 1;
 660:	4885                	li	a7,1
    x = -xx;
 662:	bf85                	j	5d2 <printint+0x1a>

0000000000000664 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 664:	715d                	addi	sp,sp,-80
 666:	e486                	sd	ra,72(sp)
 668:	e0a2                	sd	s0,64(sp)
 66a:	fc26                	sd	s1,56(sp)
 66c:	f84a                	sd	s2,48(sp)
 66e:	f44e                	sd	s3,40(sp)
 670:	f052                	sd	s4,32(sp)
 672:	ec56                	sd	s5,24(sp)
 674:	e85a                	sd	s6,16(sp)
 676:	e45e                	sd	s7,8(sp)
 678:	e062                	sd	s8,0(sp)
 67a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 67c:	0005c903          	lbu	s2,0(a1)
 680:	18090c63          	beqz	s2,818 <vprintf+0x1b4>
 684:	8aaa                	mv	s5,a0
 686:	8bb2                	mv	s7,a2
 688:	00158493          	addi	s1,a1,1
  state = 0;
 68c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 68e:	02500a13          	li	s4,37
 692:	4b55                	li	s6,21
 694:	a839                	j	6b2 <vprintf+0x4e>
        putc(fd, c);
 696:	85ca                	mv	a1,s2
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	efc080e7          	jalr	-260(ra) # 596 <putc>
 6a2:	a019                	j	6a8 <vprintf+0x44>
    } else if(state == '%'){
 6a4:	01498d63          	beq	s3,s4,6be <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 6a8:	0485                	addi	s1,s1,1
 6aa:	fff4c903          	lbu	s2,-1(s1)
 6ae:	16090563          	beqz	s2,818 <vprintf+0x1b4>
    if(state == 0){
 6b2:	fe0999e3          	bnez	s3,6a4 <vprintf+0x40>
      if(c == '%'){
 6b6:	ff4910e3          	bne	s2,s4,696 <vprintf+0x32>
        state = '%';
 6ba:	89d2                	mv	s3,s4
 6bc:	b7f5                	j	6a8 <vprintf+0x44>
      if(c == 'd'){
 6be:	13490263          	beq	s2,s4,7e2 <vprintf+0x17e>
 6c2:	f9d9079b          	addiw	a5,s2,-99
 6c6:	0ff7f793          	zext.b	a5,a5
 6ca:	12fb6563          	bltu	s6,a5,7f4 <vprintf+0x190>
 6ce:	f9d9079b          	addiw	a5,s2,-99
 6d2:	0ff7f713          	zext.b	a4,a5
 6d6:	10eb6f63          	bltu	s6,a4,7f4 <vprintf+0x190>
 6da:	00271793          	slli	a5,a4,0x2
 6de:	00000717          	auipc	a4,0x0
 6e2:	36a70713          	addi	a4,a4,874 # a48 <malloc+0x132>
 6e6:	97ba                	add	a5,a5,a4
 6e8:	439c                	lw	a5,0(a5)
 6ea:	97ba                	add	a5,a5,a4
 6ec:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4685                	li	a3,1
 6f4:	4629                	li	a2,10
 6f6:	000ba583          	lw	a1,0(s7)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	ebc080e7          	jalr	-324(ra) # 5b8 <printint>
 704:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 706:	4981                	li	s3,0
 708:	b745                	j	6a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000ba583          	lw	a1,0(s7)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	ea0080e7          	jalr	-352(ra) # 5b8 <printint>
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	b751                	j	6a8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000ba583          	lw	a1,0(s7)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e84080e7          	jalr	-380(ra) # 5b8 <printint>
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	b7a5                	j	6a8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 742:	008b8c13          	addi	s8,s7,8
 746:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 74a:	03000593          	li	a1,48
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	e46080e7          	jalr	-442(ra) # 596 <putc>
  putc(fd, 'x');
 758:	07800593          	li	a1,120
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	e38080e7          	jalr	-456(ra) # 596 <putc>
 766:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 768:	00000b97          	auipc	s7,0x0
 76c:	338b8b93          	addi	s7,s7,824 # aa0 <digits>
 770:	03c9d793          	srli	a5,s3,0x3c
 774:	97de                	add	a5,a5,s7
 776:	0007c583          	lbu	a1,0(a5)
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	e1a080e7          	jalr	-486(ra) # 596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 784:	0992                	slli	s3,s3,0x4
 786:	397d                	addiw	s2,s2,-1
 788:	fe0914e3          	bnez	s2,770 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 78c:	8be2                	mv	s7,s8
      state = 0;
 78e:	4981                	li	s3,0
 790:	bf21                	j	6a8 <vprintf+0x44>
        s = va_arg(ap, char*);
 792:	008b8993          	addi	s3,s7,8
 796:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 79a:	02090163          	beqz	s2,7bc <vprintf+0x158>
        while(*s != 0){
 79e:	00094583          	lbu	a1,0(s2)
 7a2:	c9a5                	beqz	a1,812 <vprintf+0x1ae>
          putc(fd, *s);
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	df0080e7          	jalr	-528(ra) # 596 <putc>
          s++;
 7ae:	0905                	addi	s2,s2,1
        while(*s != 0){
 7b0:	00094583          	lbu	a1,0(s2)
 7b4:	f9e5                	bnez	a1,7a4 <vprintf+0x140>
        s = va_arg(ap, char*);
 7b6:	8bce                	mv	s7,s3
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b5fd                	j	6a8 <vprintf+0x44>
          s = "(null)";
 7bc:	00000917          	auipc	s2,0x0
 7c0:	28490913          	addi	s2,s2,644 # a40 <malloc+0x12a>
        while(*s != 0){
 7c4:	02800593          	li	a1,40
 7c8:	bff1                	j	7a4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 7ca:	008b8913          	addi	s2,s7,8
 7ce:	000bc583          	lbu	a1,0(s7)
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	dc2080e7          	jalr	-574(ra) # 596 <putc>
 7dc:	8bca                	mv	s7,s2
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b5e1                	j	6a8 <vprintf+0x44>
        putc(fd, c);
 7e2:	02500593          	li	a1,37
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	dae080e7          	jalr	-594(ra) # 596 <putc>
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	bd5d                	j	6a8 <vprintf+0x44>
        putc(fd, '%');
 7f4:	02500593          	li	a1,37
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	d9c080e7          	jalr	-612(ra) # 596 <putc>
        putc(fd, c);
 802:	85ca                	mv	a1,s2
 804:	8556                	mv	a0,s5
 806:	00000097          	auipc	ra,0x0
 80a:	d90080e7          	jalr	-624(ra) # 596 <putc>
      state = 0;
 80e:	4981                	li	s3,0
 810:	bd61                	j	6a8 <vprintf+0x44>
        s = va_arg(ap, char*);
 812:	8bce                	mv	s7,s3
      state = 0;
 814:	4981                	li	s3,0
 816:	bd49                	j	6a8 <vprintf+0x44>
    }
  }
}
 818:	60a6                	ld	ra,72(sp)
 81a:	6406                	ld	s0,64(sp)
 81c:	74e2                	ld	s1,56(sp)
 81e:	7942                	ld	s2,48(sp)
 820:	79a2                	ld	s3,40(sp)
 822:	7a02                	ld	s4,32(sp)
 824:	6ae2                	ld	s5,24(sp)
 826:	6b42                	ld	s6,16(sp)
 828:	6ba2                	ld	s7,8(sp)
 82a:	6c02                	ld	s8,0(sp)
 82c:	6161                	addi	sp,sp,80
 82e:	8082                	ret

0000000000000830 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 830:	715d                	addi	sp,sp,-80
 832:	ec06                	sd	ra,24(sp)
 834:	e822                	sd	s0,16(sp)
 836:	1000                	addi	s0,sp,32
 838:	e010                	sd	a2,0(s0)
 83a:	e414                	sd	a3,8(s0)
 83c:	e818                	sd	a4,16(s0)
 83e:	ec1c                	sd	a5,24(s0)
 840:	03043023          	sd	a6,32(s0)
 844:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 848:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84c:	8622                	mv	a2,s0
 84e:	00000097          	auipc	ra,0x0
 852:	e16080e7          	jalr	-490(ra) # 664 <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6161                	addi	sp,sp,80
 85c:	8082                	ret

000000000000085e <printf>:

void
printf(const char *fmt, ...)
{
 85e:	711d                	addi	sp,sp,-96
 860:	ec06                	sd	ra,24(sp)
 862:	e822                	sd	s0,16(sp)
 864:	1000                	addi	s0,sp,32
 866:	e40c                	sd	a1,8(s0)
 868:	e810                	sd	a2,16(s0)
 86a:	ec14                	sd	a3,24(s0)
 86c:	f018                	sd	a4,32(s0)
 86e:	f41c                	sd	a5,40(s0)
 870:	03043823          	sd	a6,48(s0)
 874:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 878:	00840613          	addi	a2,s0,8
 87c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 880:	85aa                	mv	a1,a0
 882:	4505                	li	a0,1
 884:	00000097          	auipc	ra,0x0
 888:	de0080e7          	jalr	-544(ra) # 664 <vprintf>
}
 88c:	60e2                	ld	ra,24(sp)
 88e:	6442                	ld	s0,16(sp)
 890:	6125                	addi	sp,sp,96
 892:	8082                	ret

0000000000000894 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 894:	1141                	addi	sp,sp,-16
 896:	e422                	sd	s0,8(sp)
 898:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	00000797          	auipc	a5,0x0
 8a2:	7627b783          	ld	a5,1890(a5) # 1000 <freep>
 8a6:	a02d                	j	8d0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a8:	4618                	lw	a4,8(a2)
 8aa:	9f2d                	addw	a4,a4,a1
 8ac:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b0:	6398                	ld	a4,0(a5)
 8b2:	6310                	ld	a2,0(a4)
 8b4:	a83d                	j	8f2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b6:	ff852703          	lw	a4,-8(a0)
 8ba:	9f31                	addw	a4,a4,a2
 8bc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8be:	ff053683          	ld	a3,-16(a0)
 8c2:	a091                	j	906 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e7e463          	bltu	a5,a4,8ce <free+0x3a>
 8ca:	00e6ea63          	bltu	a3,a4,8de <free+0x4a>
{
 8ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	fed7fae3          	bgeu	a5,a3,8c4 <free+0x30>
 8d4:	6398                	ld	a4,0(a5)
 8d6:	00e6e463          	bltu	a3,a4,8de <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8da:	fee7eae3          	bltu	a5,a4,8ce <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8de:	ff852583          	lw	a1,-8(a0)
 8e2:	6390                	ld	a2,0(a5)
 8e4:	02059813          	slli	a6,a1,0x20
 8e8:	01c85713          	srli	a4,a6,0x1c
 8ec:	9736                	add	a4,a4,a3
 8ee:	fae60de3          	beq	a2,a4,8a8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8f6:	4790                	lw	a2,8(a5)
 8f8:	02061593          	slli	a1,a2,0x20
 8fc:	01c5d713          	srli	a4,a1,0x1c
 900:	973e                	add	a4,a4,a5
 902:	fae68ae3          	beq	a3,a4,8b6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 906:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 908:	00000717          	auipc	a4,0x0
 90c:	6ef73c23          	sd	a5,1784(a4) # 1000 <freep>
}
 910:	6422                	ld	s0,8(sp)
 912:	0141                	addi	sp,sp,16
 914:	8082                	ret

0000000000000916 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 916:	7139                	addi	sp,sp,-64
 918:	fc06                	sd	ra,56(sp)
 91a:	f822                	sd	s0,48(sp)
 91c:	f426                	sd	s1,40(sp)
 91e:	f04a                	sd	s2,32(sp)
 920:	ec4e                	sd	s3,24(sp)
 922:	e852                	sd	s4,16(sp)
 924:	e456                	sd	s5,8(sp)
 926:	e05a                	sd	s6,0(sp)
 928:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92a:	02051493          	slli	s1,a0,0x20
 92e:	9081                	srli	s1,s1,0x20
 930:	04bd                	addi	s1,s1,15
 932:	8091                	srli	s1,s1,0x4
 934:	0014899b          	addiw	s3,s1,1
 938:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 93a:	00000517          	auipc	a0,0x0
 93e:	6c653503          	ld	a0,1734(a0) # 1000 <freep>
 942:	c515                	beqz	a0,96e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	02977f63          	bgeu	a4,s1,986 <malloc+0x70>
  if(nu < 4096)
 94c:	8a4e                	mv	s4,s3
 94e:	0009871b          	sext.w	a4,s3
 952:	6685                	lui	a3,0x1
 954:	00d77363          	bgeu	a4,a3,95a <malloc+0x44>
 958:	6a05                	lui	s4,0x1
 95a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 962:	00000917          	auipc	s2,0x0
 966:	69e90913          	addi	s2,s2,1694 # 1000 <freep>
  if(p == (char*)-1)
 96a:	5afd                	li	s5,-1
 96c:	a895                	j	9e0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 96e:	00000797          	auipc	a5,0x0
 972:	6a278793          	addi	a5,a5,1698 # 1010 <base>
 976:	00000717          	auipc	a4,0x0
 97a:	68f73523          	sd	a5,1674(a4) # 1000 <freep>
 97e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 980:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 984:	b7e1                	j	94c <malloc+0x36>
      if(p->s.size == nunits)
 986:	02e48c63          	beq	s1,a4,9be <malloc+0xa8>
        p->s.size -= nunits;
 98a:	4137073b          	subw	a4,a4,s3
 98e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 990:	02071693          	slli	a3,a4,0x20
 994:	01c6d713          	srli	a4,a3,0x1c
 998:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 99a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99e:	00000717          	auipc	a4,0x0
 9a2:	66a73123          	sd	a0,1634(a4) # 1000 <freep>
      return (void*)(p + 1);
 9a6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9aa:	70e2                	ld	ra,56(sp)
 9ac:	7442                	ld	s0,48(sp)
 9ae:	74a2                	ld	s1,40(sp)
 9b0:	7902                	ld	s2,32(sp)
 9b2:	69e2                	ld	s3,24(sp)
 9b4:	6a42                	ld	s4,16(sp)
 9b6:	6aa2                	ld	s5,8(sp)
 9b8:	6b02                	ld	s6,0(sp)
 9ba:	6121                	addi	sp,sp,64
 9bc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9be:	6398                	ld	a4,0(a5)
 9c0:	e118                	sd	a4,0(a0)
 9c2:	bff1                	j	99e <malloc+0x88>
  hp->s.size = nu;
 9c4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c8:	0541                	addi	a0,a0,16
 9ca:	00000097          	auipc	ra,0x0
 9ce:	eca080e7          	jalr	-310(ra) # 894 <free>
  return freep;
 9d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d6:	d971                	beqz	a0,9aa <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9da:	4798                	lw	a4,8(a5)
 9dc:	fa9775e3          	bgeu	a4,s1,986 <malloc+0x70>
    if(p == freep)
 9e0:	00093703          	ld	a4,0(s2)
 9e4:	853e                	mv	a0,a5
 9e6:	fef719e3          	bne	a4,a5,9d8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9ea:	8552                	mv	a0,s4
 9ec:	00000097          	auipc	ra,0x0
 9f0:	b62080e7          	jalr	-1182(ra) # 54e <sbrk>
  if(p == (char*)-1)
 9f4:	fd5518e3          	bne	a0,s5,9c4 <malloc+0xae>
        return 0;
 9f8:	4501                	li	a0,0
 9fa:	bf45                	j	9aa <malloc+0x94>
