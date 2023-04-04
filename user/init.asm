
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	9e250513          	addi	a0,a0,-1566 # 9f0 <malloc+0xee>
  16:	00000097          	auipc	ra,0x0
  1a:	4dc080e7          	jalr	1244(ra) # 4f2 <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	506080e7          	jalr	1286(ra) # 52a <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	4fc080e7          	jalr	1276(ra) # 52a <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	9c290913          	addi	s2,s2,-1598 # 9f8 <malloc+0xf6>
  3e:	854a                	mv	a0,s2
  40:	00001097          	auipc	ra,0x1
  44:	80a080e7          	jalr	-2038(ra) # 84a <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	462080e7          	jalr	1122(ra) # 4aa <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	460080e7          	jalr	1120(ra) # 4ba <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	9de50513          	addi	a0,a0,-1570 # a48 <malloc+0x146>
  72:	00000097          	auipc	ra,0x0
  76:	7d8080e7          	jalr	2008(ra) # 84a <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	436080e7          	jalr	1078(ra) # 4b2 <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	96850513          	addi	a0,a0,-1688 # 9f0 <malloc+0xee>
  90:	00000097          	auipc	ra,0x0
  94:	46a080e7          	jalr	1130(ra) # 4fa <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00001517          	auipc	a0,0x1
  9e:	95650513          	addi	a0,a0,-1706 # 9f0 <malloc+0xee>
  a2:	00000097          	auipc	ra,0x0
  a6:	450080e7          	jalr	1104(ra) # 4f2 <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	96450513          	addi	a0,a0,-1692 # a10 <malloc+0x10e>
  b4:	00000097          	auipc	ra,0x0
  b8:	796080e7          	jalr	1942(ra) # 84a <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	3f4080e7          	jalr	1012(ra) # 4b2 <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	f3a58593          	addi	a1,a1,-198 # 1000 <argv>
  ce:	00001517          	auipc	a0,0x1
  d2:	95a50513          	addi	a0,a0,-1702 # a28 <malloc+0x126>
  d6:	00000097          	auipc	ra,0x0
  da:	414080e7          	jalr	1044(ra) # 4ea <exec>
      printf("init: exec sh failed\n");
  de:	00001517          	auipc	a0,0x1
  e2:	95250513          	addi	a0,a0,-1710 # a30 <malloc+0x12e>
  e6:	00000097          	auipc	ra,0x0
  ea:	764080e7          	jalr	1892(ra) # 84a <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	3c2080e7          	jalr	962(ra) # 4b2 <exit>

00000000000000f8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  extern int main();
  main();
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	3a8080e7          	jalr	936(ra) # 4b2 <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	addi	a0,a0,1
 144:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	addi	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	86be                	mv	a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	ff65                	bnez	a4,16a <strlen+0x10>
 174:	40a6853b          	subw	a0,a3,a0
 178:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d863          	bge	s1,s4,220 <gets+0x56>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	2ce080e7          	jalr	718(ra) # 4ca <read>
    if(cc < 1)
 204:	00a05e63          	blez	a0,220 <gets+0x56>
    buf[i++] = c;
 208:	faf44783          	lbu	a5,-81(s0)
 20c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 210:	01578763          	beq	a5,s5,21e <gets+0x54>
 214:	0905                	addi	s2,s2,1
 216:	fd679be3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 21a:	89a6                	mv	s3,s1
 21c:	a011                	j	220 <gets+0x56>
 21e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 220:	99de                	add	s3,s3,s7
 222:	00098023          	sb	zero,0(s3)
  return buf;
}
 226:	855e                	mv	a0,s7
 228:	60e6                	ld	ra,88(sp)
 22a:	6446                	ld	s0,80(sp)
 22c:	64a6                	ld	s1,72(sp)
 22e:	6906                	ld	s2,64(sp)
 230:	79e2                	ld	s3,56(sp)
 232:	7a42                	ld	s4,48(sp)
 234:	7aa2                	ld	s5,40(sp)
 236:	7b02                	ld	s6,32(sp)
 238:	6be2                	ld	s7,24(sp)
 23a:	6125                	addi	sp,sp,96
 23c:	8082                	ret

000000000000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	1101                	addi	sp,sp,-32
 240:	ec06                	sd	ra,24(sp)
 242:	e822                	sd	s0,16(sp)
 244:	e426                	sd	s1,8(sp)
 246:	e04a                	sd	s2,0(sp)
 248:	1000                	addi	s0,sp,32
 24a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24c:	4581                	li	a1,0
 24e:	00000097          	auipc	ra,0x0
 252:	2a4080e7          	jalr	676(ra) # 4f2 <open>
  if(fd < 0)
 256:	02054563          	bltz	a0,280 <stat+0x42>
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	00000097          	auipc	ra,0x0
 262:	2ac080e7          	jalr	684(ra) # 50a <fstat>
 266:	892a                	mv	s2,a0
  close(fd);
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	270080e7          	jalr	624(ra) # 4da <close>
  return r;
}
 272:	854a                	mv	a0,s2
 274:	60e2                	ld	ra,24(sp)
 276:	6442                	ld	s0,16(sp)
 278:	64a2                	ld	s1,8(sp)
 27a:	6902                	ld	s2,0(sp)
 27c:	6105                	addi	sp,sp,32
 27e:	8082                	ret
    return -1;
 280:	597d                	li	s2,-1
 282:	bfc5                	j	272 <stat+0x34>

0000000000000284 <atoi>:

int
atoi(const char *s)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 28a:	00054683          	lbu	a3,0(a0)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	4625                	li	a2,9
 298:	02f66863          	bltu	a2,a5,2c8 <atoi+0x44>
 29c:	872a                	mv	a4,a0
  n = 0;
 29e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a0:	0705                	addi	a4,a4,1
 2a2:	0025179b          	slliw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	slliw	a5,a5,0x1
 2ac:	9fb5                	addw	a5,a5,a3
 2ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	00074683          	lbu	a3,0(a4)
 2b6:	fd06879b          	addiw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	fef671e3          	bgeu	a2,a5,2a0 <atoi+0x1c>

  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  n = 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <atoi+0x3e>

00000000000002cc <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
 2d2:	8eaa                	mv	t4,a0
    register const char *s = strt;
 2d4:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 2d6:	02000693          	li	a3,32
        c = *s++;
 2da:	883e                	mv	a6,a5
 2dc:	0785                	addi	a5,a5,1
 2de:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 2e2:	fed70ce3          	beq	a4,a3,2da <strtoi+0xe>
        c = *s++;
 2e6:	2701                	sext.w	a4,a4

    if (c == '-') {
 2e8:	02d00693          	li	a3,45
 2ec:	04d70d63          	beq	a4,a3,346 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 2f0:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 2f4:	4f01                	li	t5,0
    } else if (c == '+')
 2f6:	04d70e63          	beq	a4,a3,352 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 2fa:	fef67693          	andi	a3,a2,-17
 2fe:	ea99                	bnez	a3,314 <strtoi+0x48>
 300:	03000693          	li	a3,48
 304:	04d70c63          	beq	a4,a3,35c <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 308:	e611                	bnez	a2,314 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 30a:	03000693          	li	a3,48
 30e:	0cd70b63          	beq	a4,a3,3e4 <strtoi+0x118>
 312:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 314:	800008b7          	lui	a7,0x80000
 318:	fff8c893          	not	a7,a7
 31c:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 320:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 324:	1882                	slli	a7,a7,0x20
 326:	0208d893          	srli	a7,a7,0x20
 32a:	02c8d8b3          	divu	a7,a7,a2
 32e:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 332:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 336:	0ac75163          	bge	a4,a2,3d8 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 33a:	4681                	li	a3,0
 33c:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 33e:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 340:	2881                	sext.w	a7,a7
        else {
            any = 1;
 342:	4f85                	li	t6,1
 344:	a0a9                	j	38e <strtoi+0xc2>
        c = *s++;
 346:	0007c703          	lbu	a4,0(a5)
 34a:	00280793          	addi	a5,a6,2
        neg = 1;
 34e:	4f05                	li	t5,1
 350:	b76d                	j	2fa <strtoi+0x2e>
        c = *s++;
 352:	0007c703          	lbu	a4,0(a5)
 356:	00280793          	addi	a5,a6,2
 35a:	b745                	j	2fa <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 35c:	0007c683          	lbu	a3,0(a5)
 360:	0df6f693          	andi	a3,a3,223
 364:	05800513          	li	a0,88
 368:	faa690e3          	bne	a3,a0,308 <strtoi+0x3c>
        c = s[1];
 36c:	0017c703          	lbu	a4,1(a5)
        s += 2;
 370:	0789                	addi	a5,a5,2
        base = 16;
 372:	4641                	li	a2,16
 374:	b745                	j	314 <strtoi+0x48>
            any = -1;
 376:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 378:	00e2c463          	blt	t0,a4,380 <strtoi+0xb4>
 37c:	a015                	j	3a0 <strtoi+0xd4>
            any = -1;
 37e:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 380:	0785                	addi	a5,a5,1
 382:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 386:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 38a:	02c75063          	bge	a4,a2,3aa <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 38e:	fe06c8e3          	bltz	a3,37e <strtoi+0xb2>
 392:	0005081b          	sext.w	a6,a0
            any = -1;
 396:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 398:	ff0e64e3          	bltu	t3,a6,380 <strtoi+0xb4>
 39c:	fca88de3          	beq	a7,a0,376 <strtoi+0xaa>
            acc *= base;
 3a0:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 3a4:	9d39                	addw	a0,a0,a4
            any = 1;
 3a6:	86fe                	mv	a3,t6
 3a8:	bfe1                	j	380 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 3aa:	0006cd63          	bltz	a3,3c4 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 3ae:	000f0463          	beqz	t5,3b6 <strtoi+0xea>
        acc = -acc;
 3b2:	40a0053b          	negw	a0,a0
    if (end != 0)
 3b6:	c581                	beqz	a1,3be <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3b8:	ee89                	bnez	a3,3d2 <strtoi+0x106>
 3ba:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 3c4:	000f1d63          	bnez	t5,3de <strtoi+0x112>
 3c8:	80000537          	lui	a0,0x80000
 3cc:	fff54513          	not	a0,a0
    if (end != 0)
 3d0:	d5fd                	beqz	a1,3be <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3d2:	fff78e93          	addi	t4,a5,-1
 3d6:	b7d5                	j	3ba <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 3d8:	4681                	li	a3,0
 3da:	4501                	li	a0,0
 3dc:	bfc9                	j	3ae <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 3de:	80000537          	lui	a0,0x80000
 3e2:	b7fd                	j	3d0 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 3e4:	80000e37          	lui	t3,0x80000
 3e8:	fffe4e13          	not	t3,t3
 3ec:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 3f0:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 3f4:	003e589b          	srliw	a7,t3,0x3
 3f8:	8e46                	mv	t3,a7
            c -= '0';
 3fa:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 3fc:	4621                	li	a2,8
 3fe:	bf35                	j	33a <strtoi+0x6e>

0000000000000400 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 400:	1141                	addi	sp,sp,-16
 402:	e422                	sd	s0,8(sp)
 404:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 406:	02b57463          	bgeu	a0,a1,42e <memmove+0x2e>
    while(n-- > 0)
 40a:	00c05f63          	blez	a2,428 <memmove+0x28>
 40e:	1602                	slli	a2,a2,0x20
 410:	9201                	srli	a2,a2,0x20
 412:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 416:	872a                	mv	a4,a0
      *dst++ = *src++;
 418:	0585                	addi	a1,a1,1
 41a:	0705                	addi	a4,a4,1
 41c:	fff5c683          	lbu	a3,-1(a1)
 420:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 424:	fee79ae3          	bne	a5,a4,418 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 428:	6422                	ld	s0,8(sp)
 42a:	0141                	addi	sp,sp,16
 42c:	8082                	ret
    dst += n;
 42e:	00c50733          	add	a4,a0,a2
    src += n;
 432:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 434:	fec05ae3          	blez	a2,428 <memmove+0x28>
 438:	fff6079b          	addiw	a5,a2,-1
 43c:	1782                	slli	a5,a5,0x20
 43e:	9381                	srli	a5,a5,0x20
 440:	fff7c793          	not	a5,a5
 444:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 446:	15fd                	addi	a1,a1,-1
 448:	177d                	addi	a4,a4,-1
 44a:	0005c683          	lbu	a3,0(a1)
 44e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 452:	fee79ae3          	bne	a5,a4,446 <memmove+0x46>
 456:	bfc9                	j	428 <memmove+0x28>

0000000000000458 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 458:	1141                	addi	sp,sp,-16
 45a:	e422                	sd	s0,8(sp)
 45c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 45e:	ca05                	beqz	a2,48e <memcmp+0x36>
 460:	fff6069b          	addiw	a3,a2,-1
 464:	1682                	slli	a3,a3,0x20
 466:	9281                	srli	a3,a3,0x20
 468:	0685                	addi	a3,a3,1
 46a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 46c:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffefe0>
 470:	0005c703          	lbu	a4,0(a1)
 474:	00e79863          	bne	a5,a4,484 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 478:	0505                	addi	a0,a0,1
    p2++;
 47a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 47c:	fed518e3          	bne	a0,a3,46c <memcmp+0x14>
  }
  return 0;
 480:	4501                	li	a0,0
 482:	a019                	j	488 <memcmp+0x30>
      return *p1 - *p2;
 484:	40e7853b          	subw	a0,a5,a4
}
 488:	6422                	ld	s0,8(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret
  return 0;
 48e:	4501                	li	a0,0
 490:	bfe5                	j	488 <memcmp+0x30>

0000000000000492 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 492:	1141                	addi	sp,sp,-16
 494:	e406                	sd	ra,8(sp)
 496:	e022                	sd	s0,0(sp)
 498:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 49a:	00000097          	auipc	ra,0x0
 49e:	f66080e7          	jalr	-154(ra) # 400 <memmove>
}
 4a2:	60a2                	ld	ra,8(sp)
 4a4:	6402                	ld	s0,0(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret

00000000000004aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4aa:	4885                	li	a7,1
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b2:	4889                	li	a7,2
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ba:	488d                	li	a7,3
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c2:	4891                	li	a7,4
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <read>:
.global read
read:
 li a7, SYS_read
 4ca:	4895                	li	a7,5
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <write>:
.global write
write:
 li a7, SYS_write
 4d2:	48c1                	li	a7,16
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <close>:
.global close
close:
 li a7, SYS_close
 4da:	48d5                	li	a7,21
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e2:	4899                	li	a7,6
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ea:	489d                	li	a7,7
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <open>:
.global open
open:
 li a7, SYS_open
 4f2:	48bd                	li	a7,15
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4fa:	48c5                	li	a7,17
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 502:	48c9                	li	a7,18
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 50a:	48a1                	li	a7,8
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <link>:
.global link
link:
 li a7, SYS_link
 512:	48cd                	li	a7,19
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 51a:	48d1                	li	a7,20
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 522:	48a5                	li	a7,9
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <dup>:
.global dup
dup:
 li a7, SYS_dup
 52a:	48a9                	li	a7,10
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 532:	48ad                	li	a7,11
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 53a:	48b1                	li	a7,12
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 542:	48b5                	li	a7,13
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 54a:	48b9                	li	a7,14
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 552:	48d9                	li	a7,22
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 55a:	48dd                	li	a7,23
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 562:	48e1                	li	a7,24
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 56a:	48e5                	li	a7,25
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 572:	48e9                	li	a7,26
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 57a:	48ed                	li	a7,27
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 582:	1101                	addi	sp,sp,-32
 584:	ec06                	sd	ra,24(sp)
 586:	e822                	sd	s0,16(sp)
 588:	1000                	addi	s0,sp,32
 58a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58e:	4605                	li	a2,1
 590:	fef40593          	addi	a1,s0,-17
 594:	00000097          	auipc	ra,0x0
 598:	f3e080e7          	jalr	-194(ra) # 4d2 <write>
}
 59c:	60e2                	ld	ra,24(sp)
 59e:	6442                	ld	s0,16(sp)
 5a0:	6105                	addi	sp,sp,32
 5a2:	8082                	ret

00000000000005a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a4:	7139                	addi	sp,sp,-64
 5a6:	fc06                	sd	ra,56(sp)
 5a8:	f822                	sd	s0,48(sp)
 5aa:	f426                	sd	s1,40(sp)
 5ac:	f04a                	sd	s2,32(sp)
 5ae:	ec4e                	sd	s3,24(sp)
 5b0:	0080                	addi	s0,sp,64
 5b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b4:	c299                	beqz	a3,5ba <printint+0x16>
 5b6:	0805c963          	bltz	a1,648 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ba:	2581                	sext.w	a1,a1
  neg = 0;
 5bc:	4881                	li	a7,0
 5be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c4:	2601                	sext.w	a2,a2
 5c6:	00000517          	auipc	a0,0x0
 5ca:	50250513          	addi	a0,a0,1282 # ac8 <digits>
 5ce:	883a                	mv	a6,a4
 5d0:	2705                	addiw	a4,a4,1
 5d2:	02c5f7bb          	remuw	a5,a1,a2
 5d6:	1782                	slli	a5,a5,0x20
 5d8:	9381                	srli	a5,a5,0x20
 5da:	97aa                	add	a5,a5,a0
 5dc:	0007c783          	lbu	a5,0(a5)
 5e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e4:	0005879b          	sext.w	a5,a1
 5e8:	02c5d5bb          	divuw	a1,a1,a2
 5ec:	0685                	addi	a3,a3,1
 5ee:	fec7f0e3          	bgeu	a5,a2,5ce <printint+0x2a>
  if(neg)
 5f2:	00088c63          	beqz	a7,60a <printint+0x66>
    buf[i++] = '-';
 5f6:	fd070793          	addi	a5,a4,-48
 5fa:	00878733          	add	a4,a5,s0
 5fe:	02d00793          	li	a5,45
 602:	fef70823          	sb	a5,-16(a4)
 606:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 60a:	02e05863          	blez	a4,63a <printint+0x96>
 60e:	fc040793          	addi	a5,s0,-64
 612:	00e78933          	add	s2,a5,a4
 616:	fff78993          	addi	s3,a5,-1
 61a:	99ba                	add	s3,s3,a4
 61c:	377d                	addiw	a4,a4,-1
 61e:	1702                	slli	a4,a4,0x20
 620:	9301                	srli	a4,a4,0x20
 622:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 626:	fff94583          	lbu	a1,-1(s2)
 62a:	8526                	mv	a0,s1
 62c:	00000097          	auipc	ra,0x0
 630:	f56080e7          	jalr	-170(ra) # 582 <putc>
  while(--i >= 0)
 634:	197d                	addi	s2,s2,-1
 636:	ff3918e3          	bne	s2,s3,626 <printint+0x82>
}
 63a:	70e2                	ld	ra,56(sp)
 63c:	7442                	ld	s0,48(sp)
 63e:	74a2                	ld	s1,40(sp)
 640:	7902                	ld	s2,32(sp)
 642:	69e2                	ld	s3,24(sp)
 644:	6121                	addi	sp,sp,64
 646:	8082                	ret
    x = -xx;
 648:	40b005bb          	negw	a1,a1
    neg = 1;
 64c:	4885                	li	a7,1
    x = -xx;
 64e:	bf85                	j	5be <printint+0x1a>

0000000000000650 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 650:	715d                	addi	sp,sp,-80
 652:	e486                	sd	ra,72(sp)
 654:	e0a2                	sd	s0,64(sp)
 656:	fc26                	sd	s1,56(sp)
 658:	f84a                	sd	s2,48(sp)
 65a:	f44e                	sd	s3,40(sp)
 65c:	f052                	sd	s4,32(sp)
 65e:	ec56                	sd	s5,24(sp)
 660:	e85a                	sd	s6,16(sp)
 662:	e45e                	sd	s7,8(sp)
 664:	e062                	sd	s8,0(sp)
 666:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 668:	0005c903          	lbu	s2,0(a1)
 66c:	18090c63          	beqz	s2,804 <vprintf+0x1b4>
 670:	8aaa                	mv	s5,a0
 672:	8bb2                	mv	s7,a2
 674:	00158493          	addi	s1,a1,1
  state = 0;
 678:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 67a:	02500a13          	li	s4,37
 67e:	4b55                	li	s6,21
 680:	a839                	j	69e <vprintf+0x4e>
        putc(fd, c);
 682:	85ca                	mv	a1,s2
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	efc080e7          	jalr	-260(ra) # 582 <putc>
 68e:	a019                	j	694 <vprintf+0x44>
    } else if(state == '%'){
 690:	01498d63          	beq	s3,s4,6aa <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 694:	0485                	addi	s1,s1,1
 696:	fff4c903          	lbu	s2,-1(s1)
 69a:	16090563          	beqz	s2,804 <vprintf+0x1b4>
    if(state == 0){
 69e:	fe0999e3          	bnez	s3,690 <vprintf+0x40>
      if(c == '%'){
 6a2:	ff4910e3          	bne	s2,s4,682 <vprintf+0x32>
        state = '%';
 6a6:	89d2                	mv	s3,s4
 6a8:	b7f5                	j	694 <vprintf+0x44>
      if(c == 'd'){
 6aa:	13490263          	beq	s2,s4,7ce <vprintf+0x17e>
 6ae:	f9d9079b          	addiw	a5,s2,-99
 6b2:	0ff7f793          	zext.b	a5,a5
 6b6:	12fb6563          	bltu	s6,a5,7e0 <vprintf+0x190>
 6ba:	f9d9079b          	addiw	a5,s2,-99
 6be:	0ff7f713          	zext.b	a4,a5
 6c2:	10eb6f63          	bltu	s6,a4,7e0 <vprintf+0x190>
 6c6:	00271793          	slli	a5,a4,0x2
 6ca:	00000717          	auipc	a4,0x0
 6ce:	3a670713          	addi	a4,a4,934 # a70 <malloc+0x16e>
 6d2:	97ba                	add	a5,a5,a4
 6d4:	439c                	lw	a5,0(a5)
 6d6:	97ba                	add	a5,a5,a4
 6d8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000ba583          	lw	a1,0(s7)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	ebc080e7          	jalr	-324(ra) # 5a4 <printint>
 6f0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b745                	j	694 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4629                	li	a2,10
 6fe:	000ba583          	lw	a1,0(s7)
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	ea0080e7          	jalr	-352(ra) # 5a4 <printint>
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	b751                	j	694 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 712:	008b8913          	addi	s2,s7,8
 716:	4681                	li	a3,0
 718:	4641                	li	a2,16
 71a:	000ba583          	lw	a1,0(s7)
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	e84080e7          	jalr	-380(ra) # 5a4 <printint>
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b7a5                	j	694 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 72e:	008b8c13          	addi	s8,s7,8
 732:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 736:	03000593          	li	a1,48
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	e46080e7          	jalr	-442(ra) # 582 <putc>
  putc(fd, 'x');
 744:	07800593          	li	a1,120
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e38080e7          	jalr	-456(ra) # 582 <putc>
 752:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 754:	00000b97          	auipc	s7,0x0
 758:	374b8b93          	addi	s7,s7,884 # ac8 <digits>
 75c:	03c9d793          	srli	a5,s3,0x3c
 760:	97de                	add	a5,a5,s7
 762:	0007c583          	lbu	a1,0(a5)
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	e1a080e7          	jalr	-486(ra) # 582 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 770:	0992                	slli	s3,s3,0x4
 772:	397d                	addiw	s2,s2,-1
 774:	fe0914e3          	bnez	s2,75c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 778:	8be2                	mv	s7,s8
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bf21                	j	694 <vprintf+0x44>
        s = va_arg(ap, char*);
 77e:	008b8993          	addi	s3,s7,8
 782:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 786:	02090163          	beqz	s2,7a8 <vprintf+0x158>
        while(*s != 0){
 78a:	00094583          	lbu	a1,0(s2)
 78e:	c9a5                	beqz	a1,7fe <vprintf+0x1ae>
          putc(fd, *s);
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	df0080e7          	jalr	-528(ra) # 582 <putc>
          s++;
 79a:	0905                	addi	s2,s2,1
        while(*s != 0){
 79c:	00094583          	lbu	a1,0(s2)
 7a0:	f9e5                	bnez	a1,790 <vprintf+0x140>
        s = va_arg(ap, char*);
 7a2:	8bce                	mv	s7,s3
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b5fd                	j	694 <vprintf+0x44>
          s = "(null)";
 7a8:	00000917          	auipc	s2,0x0
 7ac:	2c090913          	addi	s2,s2,704 # a68 <malloc+0x166>
        while(*s != 0){
 7b0:	02800593          	li	a1,40
 7b4:	bff1                	j	790 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 7b6:	008b8913          	addi	s2,s7,8
 7ba:	000bc583          	lbu	a1,0(s7)
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	dc2080e7          	jalr	-574(ra) # 582 <putc>
 7c8:	8bca                	mv	s7,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b5e1                	j	694 <vprintf+0x44>
        putc(fd, c);
 7ce:	02500593          	li	a1,37
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	dae080e7          	jalr	-594(ra) # 582 <putc>
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bd5d                	j	694 <vprintf+0x44>
        putc(fd, '%');
 7e0:	02500593          	li	a1,37
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	d9c080e7          	jalr	-612(ra) # 582 <putc>
        putc(fd, c);
 7ee:	85ca                	mv	a1,s2
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	d90080e7          	jalr	-624(ra) # 582 <putc>
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bd61                	j	694 <vprintf+0x44>
        s = va_arg(ap, char*);
 7fe:	8bce                	mv	s7,s3
      state = 0;
 800:	4981                	li	s3,0
 802:	bd49                	j	694 <vprintf+0x44>
    }
  }
}
 804:	60a6                	ld	ra,72(sp)
 806:	6406                	ld	s0,64(sp)
 808:	74e2                	ld	s1,56(sp)
 80a:	7942                	ld	s2,48(sp)
 80c:	79a2                	ld	s3,40(sp)
 80e:	7a02                	ld	s4,32(sp)
 810:	6ae2                	ld	s5,24(sp)
 812:	6b42                	ld	s6,16(sp)
 814:	6ba2                	ld	s7,8(sp)
 816:	6c02                	ld	s8,0(sp)
 818:	6161                	addi	sp,sp,80
 81a:	8082                	ret

000000000000081c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 81c:	715d                	addi	sp,sp,-80
 81e:	ec06                	sd	ra,24(sp)
 820:	e822                	sd	s0,16(sp)
 822:	1000                	addi	s0,sp,32
 824:	e010                	sd	a2,0(s0)
 826:	e414                	sd	a3,8(s0)
 828:	e818                	sd	a4,16(s0)
 82a:	ec1c                	sd	a5,24(s0)
 82c:	03043023          	sd	a6,32(s0)
 830:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 834:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 838:	8622                	mv	a2,s0
 83a:	00000097          	auipc	ra,0x0
 83e:	e16080e7          	jalr	-490(ra) # 650 <vprintf>
}
 842:	60e2                	ld	ra,24(sp)
 844:	6442                	ld	s0,16(sp)
 846:	6161                	addi	sp,sp,80
 848:	8082                	ret

000000000000084a <printf>:

void
printf(const char *fmt, ...)
{
 84a:	711d                	addi	sp,sp,-96
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e40c                	sd	a1,8(s0)
 854:	e810                	sd	a2,16(s0)
 856:	ec14                	sd	a3,24(s0)
 858:	f018                	sd	a4,32(s0)
 85a:	f41c                	sd	a5,40(s0)
 85c:	03043823          	sd	a6,48(s0)
 860:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 864:	00840613          	addi	a2,s0,8
 868:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86c:	85aa                	mv	a1,a0
 86e:	4505                	li	a0,1
 870:	00000097          	auipc	ra,0x0
 874:	de0080e7          	jalr	-544(ra) # 650 <vprintf>
}
 878:	60e2                	ld	ra,24(sp)
 87a:	6442                	ld	s0,16(sp)
 87c:	6125                	addi	sp,sp,96
 87e:	8082                	ret

0000000000000880 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 880:	1141                	addi	sp,sp,-16
 882:	e422                	sd	s0,8(sp)
 884:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 886:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88a:	00000797          	auipc	a5,0x0
 88e:	7867b783          	ld	a5,1926(a5) # 1010 <freep>
 892:	a02d                	j	8bc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 894:	4618                	lw	a4,8(a2)
 896:	9f2d                	addw	a4,a4,a1
 898:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 89c:	6398                	ld	a4,0(a5)
 89e:	6310                	ld	a2,0(a4)
 8a0:	a83d                	j	8de <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a2:	ff852703          	lw	a4,-8(a0)
 8a6:	9f31                	addw	a4,a4,a2
 8a8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8aa:	ff053683          	ld	a3,-16(a0)
 8ae:	a091                	j	8f2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b0:	6398                	ld	a4,0(a5)
 8b2:	00e7e463          	bltu	a5,a4,8ba <free+0x3a>
 8b6:	00e6ea63          	bltu	a3,a4,8ca <free+0x4a>
{
 8ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bc:	fed7fae3          	bgeu	a5,a3,8b0 <free+0x30>
 8c0:	6398                	ld	a4,0(a5)
 8c2:	00e6e463          	bltu	a3,a4,8ca <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c6:	fee7eae3          	bltu	a5,a4,8ba <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ca:	ff852583          	lw	a1,-8(a0)
 8ce:	6390                	ld	a2,0(a5)
 8d0:	02059813          	slli	a6,a1,0x20
 8d4:	01c85713          	srli	a4,a6,0x1c
 8d8:	9736                	add	a4,a4,a3
 8da:	fae60de3          	beq	a2,a4,894 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e2:	4790                	lw	a2,8(a5)
 8e4:	02061593          	slli	a1,a2,0x20
 8e8:	01c5d713          	srli	a4,a1,0x1c
 8ec:	973e                	add	a4,a4,a5
 8ee:	fae68ae3          	beq	a3,a4,8a2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f4:	00000717          	auipc	a4,0x0
 8f8:	70f73e23          	sd	a5,1820(a4) # 1010 <freep>
}
 8fc:	6422                	ld	s0,8(sp)
 8fe:	0141                	addi	sp,sp,16
 900:	8082                	ret

0000000000000902 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 902:	7139                	addi	sp,sp,-64
 904:	fc06                	sd	ra,56(sp)
 906:	f822                	sd	s0,48(sp)
 908:	f426                	sd	s1,40(sp)
 90a:	f04a                	sd	s2,32(sp)
 90c:	ec4e                	sd	s3,24(sp)
 90e:	e852                	sd	s4,16(sp)
 910:	e456                	sd	s5,8(sp)
 912:	e05a                	sd	s6,0(sp)
 914:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 916:	02051493          	slli	s1,a0,0x20
 91a:	9081                	srli	s1,s1,0x20
 91c:	04bd                	addi	s1,s1,15
 91e:	8091                	srli	s1,s1,0x4
 920:	0014899b          	addiw	s3,s1,1
 924:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 926:	00000517          	auipc	a0,0x0
 92a:	6ea53503          	ld	a0,1770(a0) # 1010 <freep>
 92e:	c515                	beqz	a0,95a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	02977f63          	bgeu	a4,s1,972 <malloc+0x70>
  if(nu < 4096)
 938:	8a4e                	mv	s4,s3
 93a:	0009871b          	sext.w	a4,s3
 93e:	6685                	lui	a3,0x1
 940:	00d77363          	bgeu	a4,a3,946 <malloc+0x44>
 944:	6a05                	lui	s4,0x1
 946:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94e:	00000917          	auipc	s2,0x0
 952:	6c290913          	addi	s2,s2,1730 # 1010 <freep>
  if(p == (char*)-1)
 956:	5afd                	li	s5,-1
 958:	a895                	j	9cc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 95a:	00000797          	auipc	a5,0x0
 95e:	6c678793          	addi	a5,a5,1734 # 1020 <base>
 962:	00000717          	auipc	a4,0x0
 966:	6af73723          	sd	a5,1710(a4) # 1010 <freep>
 96a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 96c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 970:	b7e1                	j	938 <malloc+0x36>
      if(p->s.size == nunits)
 972:	02e48c63          	beq	s1,a4,9aa <malloc+0xa8>
        p->s.size -= nunits;
 976:	4137073b          	subw	a4,a4,s3
 97a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97c:	02071693          	slli	a3,a4,0x20
 980:	01c6d713          	srli	a4,a3,0x1c
 984:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 986:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98a:	00000717          	auipc	a4,0x0
 98e:	68a73323          	sd	a0,1670(a4) # 1010 <freep>
      return (void*)(p + 1);
 992:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 996:	70e2                	ld	ra,56(sp)
 998:	7442                	ld	s0,48(sp)
 99a:	74a2                	ld	s1,40(sp)
 99c:	7902                	ld	s2,32(sp)
 99e:	69e2                	ld	s3,24(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
 9a6:	6121                	addi	sp,sp,64
 9a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9aa:	6398                	ld	a4,0(a5)
 9ac:	e118                	sd	a4,0(a0)
 9ae:	bff1                	j	98a <malloc+0x88>
  hp->s.size = nu;
 9b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b4:	0541                	addi	a0,a0,16
 9b6:	00000097          	auipc	ra,0x0
 9ba:	eca080e7          	jalr	-310(ra) # 880 <free>
  return freep;
 9be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c2:	d971                	beqz	a0,996 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c6:	4798                	lw	a4,8(a5)
 9c8:	fa9775e3          	bgeu	a4,s1,972 <malloc+0x70>
    if(p == freep)
 9cc:	00093703          	ld	a4,0(s2)
 9d0:	853e                	mv	a0,a5
 9d2:	fef719e3          	bne	a4,a5,9c4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9d6:	8552                	mv	a0,s4
 9d8:	00000097          	auipc	ra,0x0
 9dc:	b62080e7          	jalr	-1182(ra) # 53a <sbrk>
  if(p == (char*)-1)
 9e0:	fd5518e3          	bne	a0,s5,9b0 <malloc+0xae>
        return 0;
 9e4:	4501                	li	a0,0
 9e6:	bf45                	j	996 <malloc+0x94>
