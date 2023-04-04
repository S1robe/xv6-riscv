
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	a48a0a13          	addi	s4,s4,-1464 # a80 <malloc+0xec>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1f2080e7          	jalr	498(ra) # 238 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	00998d63          	beq	s3,s1,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addiw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0917e3          	bnez	s2,52 <wc+0x52>
        w++;
  68:	2c85                	addiw	s9,s9,1
        inword = 1;
  6a:	4905                	li	s2,1
  6c:	b7dd                	j	52 <wc+0x52>
      c++;
  6e:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	4e0080e7          	jalr	1248(ra) # 55c <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
    for(i=0; i<n; i++){
  8a:	00001497          	auipc	s1,0x1
  8e:	f8648493          	addi	s1,s1,-122 # 1010 <buf>
  92:	009509b3          	add	s3,a0,s1
  96:	b7c9                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86ea                	mv	a3,s10
  a2:	8666                	mv	a2,s9
  a4:	85e2                	mv	a1,s8
  a6:	00001517          	auipc	a0,0x1
  aa:	9f250513          	addi	a0,a0,-1550 # a98 <malloc+0x104>
  ae:	00001097          	auipc	ra,0x1
  b2:	82e080e7          	jalr	-2002(ra) # 8dc <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	addi	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	9b450513          	addi	a0,a0,-1612 # a88 <malloc+0xf4>
  dc:	00001097          	auipc	ra,0x1
  e0:	800080e7          	jalr	-2048(ra) # 8dc <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	45e080e7          	jalr	1118(ra) # 544 <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	ec26                	sd	s1,24(sp)
  f6:	e84a                	sd	s2,16(sp)
  f8:	e44e                	sd	s3,8(sp)
  fa:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  fc:	4785                	li	a5,1
  fe:	04a7d963          	bge	a5,a0,150 <main+0x62>
 102:	00858913          	addi	s2,a1,8
 106:	ffe5099b          	addiw	s3,a0,-2
 10a:	02099793          	slli	a5,s3,0x20
 10e:	01d7d993          	srli	s3,a5,0x1d
 112:	05c1                	addi	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	468080e7          	jalr	1128(ra) # 584 <open>
 124:	84aa                	mv	s1,a0
 126:	04054363          	bltz	a0,16c <main+0x7e>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	434080e7          	jalr	1076(ra) # 56c <close>
  for(i = 1; i < argc; i++){
 140:	0921                	addi	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	3fc080e7          	jalr	1020(ra) # 544 <exit>
    wc(0, "");
 150:	00001597          	auipc	a1,0x1
 154:	95858593          	addi	a1,a1,-1704 # aa8 <malloc+0x114>
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	ea6080e7          	jalr	-346(ra) # 0 <wc>
    exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	3e0080e7          	jalr	992(ra) # 544 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 16c:	00093583          	ld	a1,0(s2)
 170:	00001517          	auipc	a0,0x1
 174:	94050513          	addi	a0,a0,-1728 # ab0 <malloc+0x11c>
 178:	00000097          	auipc	ra,0x0
 17c:	764080e7          	jalr	1892(ra) # 8dc <printf>
      exit(1);
 180:	4505                	li	a0,1
 182:	00000097          	auipc	ra,0x0
 186:	3c2080e7          	jalr	962(ra) # 544 <exit>

000000000000018a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  extern int main();
  main();
 192:	00000097          	auipc	ra,0x0
 196:	f5c080e7          	jalr	-164(ra) # ee <main>
  exit(0);
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	3a8080e7          	jalr	936(ra) # 544 <exit>

00000000000001a4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1aa:	87aa                	mv	a5,a0
 1ac:	0585                	addi	a1,a1,1
 1ae:	0785                	addi	a5,a5,1
 1b0:	fff5c703          	lbu	a4,-1(a1)
 1b4:	fee78fa3          	sb	a4,-1(a5)
 1b8:	fb75                	bnez	a4,1ac <strcpy+0x8>
    ;
  return os;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb91                	beqz	a5,1de <strcmp+0x1e>
 1cc:	0005c703          	lbu	a4,0(a1)
 1d0:	00f71763          	bne	a4,a5,1de <strcmp+0x1e>
    p++, q++;
 1d4:	0505                	addi	a0,a0,1
 1d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	fbe5                	bnez	a5,1cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1de:	0005c503          	lbu	a0,0(a1)
}
 1e2:	40a7853b          	subw	a0,a5,a0
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret

00000000000001ec <strlen>:

uint
strlen(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf91                	beqz	a5,212 <strlen+0x26>
 1f8:	0505                	addi	a0,a0,1
 1fa:	87aa                	mv	a5,a0
 1fc:	86be                	mv	a3,a5
 1fe:	0785                	addi	a5,a5,1
 200:	fff7c703          	lbu	a4,-1(a5)
 204:	ff65                	bnez	a4,1fc <strlen+0x10>
 206:	40a6853b          	subw	a0,a3,a0
 20a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  for(n = 0; s[n]; n++)
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <strlen+0x20>

0000000000000216 <memset>:

void*
memset(void *dst, int c, uint n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21c:	ca19                	beqz	a2,232 <memset+0x1c>
 21e:	87aa                	mv	a5,a0
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 228:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22c:	0785                	addi	a5,a5,1
 22e:	fee79de3          	bne	a5,a4,228 <memset+0x12>
  }
  return dst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strchr>:

char*
strchr(const char *s, char c)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cb99                	beqz	a5,258 <strchr+0x20>
    if(*s == c)
 244:	00f58763          	beq	a1,a5,252 <strchr+0x1a>
  for(; *s; s++)
 248:	0505                	addi	a0,a0,1
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbfd                	bnez	a5,244 <strchr+0xc>
      return (char*)s;
  return 0;
 250:	4501                	li	a0,0
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  return 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strchr+0x1a>

000000000000025c <gets>:

char*
gets(char *buf, int max)
{
 25c:	711d                	addi	sp,sp,-96
 25e:	ec86                	sd	ra,88(sp)
 260:	e8a2                	sd	s0,80(sp)
 262:	e4a6                	sd	s1,72(sp)
 264:	e0ca                	sd	s2,64(sp)
 266:	fc4e                	sd	s3,56(sp)
 268:	f852                	sd	s4,48(sp)
 26a:	f456                	sd	s5,40(sp)
 26c:	f05a                	sd	s6,32(sp)
 26e:	ec5e                	sd	s7,24(sp)
 270:	1080                	addi	s0,sp,96
 272:	8baa                	mv	s7,a0
 274:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	892a                	mv	s2,a0
 278:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27a:	4aa9                	li	s5,10
 27c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 27e:	89a6                	mv	s3,s1
 280:	2485                	addiw	s1,s1,1
 282:	0344d863          	bge	s1,s4,2b2 <gets+0x56>
    cc = read(0, &c, 1);
 286:	4605                	li	a2,1
 288:	faf40593          	addi	a1,s0,-81
 28c:	4501                	li	a0,0
 28e:	00000097          	auipc	ra,0x0
 292:	2ce080e7          	jalr	718(ra) # 55c <read>
    if(cc < 1)
 296:	00a05e63          	blez	a0,2b2 <gets+0x56>
    buf[i++] = c;
 29a:	faf44783          	lbu	a5,-81(s0)
 29e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a2:	01578763          	beq	a5,s5,2b0 <gets+0x54>
 2a6:	0905                	addi	s2,s2,1
 2a8:	fd679be3          	bne	a5,s6,27e <gets+0x22>
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
 2ae:	a011                	j	2b2 <gets+0x56>
 2b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b2:	99de                	add	s3,s3,s7
 2b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b8:	855e                	mv	a0,s7
 2ba:	60e6                	ld	ra,88(sp)
 2bc:	6446                	ld	s0,80(sp)
 2be:	64a6                	ld	s1,72(sp)
 2c0:	6906                	ld	s2,64(sp)
 2c2:	79e2                	ld	s3,56(sp)
 2c4:	7a42                	ld	s4,48(sp)
 2c6:	7aa2                	ld	s5,40(sp)
 2c8:	7b02                	ld	s6,32(sp)
 2ca:	6be2                	ld	s7,24(sp)
 2cc:	6125                	addi	sp,sp,96
 2ce:	8082                	ret

00000000000002d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	e426                	sd	s1,8(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	2a4080e7          	jalr	676(ra) # 584 <open>
  if(fd < 0)
 2e8:	02054563          	bltz	a0,312 <stat+0x42>
 2ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	00000097          	auipc	ra,0x0
 2f4:	2ac080e7          	jalr	684(ra) # 59c <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	00000097          	auipc	ra,0x0
 300:	270080e7          	jalr	624(ra) # 56c <close>
  return r;
}
 304:	854a                	mv	a0,s2
 306:	60e2                	ld	ra,24(sp)
 308:	6442                	ld	s0,16(sp)
 30a:	64a2                	ld	s1,8(sp)
 30c:	6902                	ld	s2,0(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret
    return -1;
 312:	597d                	li	s2,-1
 314:	bfc5                	j	304 <stat+0x34>

0000000000000316 <atoi>:

int
atoi(const char *s)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 31c:	00054683          	lbu	a3,0(a0)
 320:	fd06879b          	addiw	a5,a3,-48
 324:	0ff7f793          	zext.b	a5,a5
 328:	4625                	li	a2,9
 32a:	02f66863          	bltu	a2,a5,35a <atoi+0x44>
 32e:	872a                	mv	a4,a0
  n = 0;
 330:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 332:	0705                	addi	a4,a4,1
 334:	0025179b          	slliw	a5,a0,0x2
 338:	9fa9                	addw	a5,a5,a0
 33a:	0017979b          	slliw	a5,a5,0x1
 33e:	9fb5                	addw	a5,a5,a3
 340:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 344:	00074683          	lbu	a3,0(a4)
 348:	fd06879b          	addiw	a5,a3,-48
 34c:	0ff7f793          	zext.b	a5,a5
 350:	fef671e3          	bgeu	a2,a5,332 <atoi+0x1c>

  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  n = 0;
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <atoi+0x3e>

000000000000035e <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
 364:	8eaa                	mv	t4,a0
    register const char *s = strt;
 366:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 368:	02000693          	li	a3,32
        c = *s++;
 36c:	883e                	mv	a6,a5
 36e:	0785                	addi	a5,a5,1
 370:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 374:	fed70ce3          	beq	a4,a3,36c <strtoi+0xe>
        c = *s++;
 378:	2701                	sext.w	a4,a4

    if (c == '-') {
 37a:	02d00693          	li	a3,45
 37e:	04d70d63          	beq	a4,a3,3d8 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 382:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 386:	4f01                	li	t5,0
    } else if (c == '+')
 388:	04d70e63          	beq	a4,a3,3e4 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 38c:	fef67693          	andi	a3,a2,-17
 390:	ea99                	bnez	a3,3a6 <strtoi+0x48>
 392:	03000693          	li	a3,48
 396:	04d70c63          	beq	a4,a3,3ee <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 39a:	e611                	bnez	a2,3a6 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 39c:	03000693          	li	a3,48
 3a0:	0cd70b63          	beq	a4,a3,476 <strtoi+0x118>
 3a4:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 3a6:	800008b7          	lui	a7,0x80000
 3aa:	fff8c893          	not	a7,a7
 3ae:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 3b2:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 3b6:	1882                	slli	a7,a7,0x20
 3b8:	0208d893          	srli	a7,a7,0x20
 3bc:	02c8d8b3          	divu	a7,a7,a2
 3c0:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 3c4:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 3c8:	0ac75163          	bge	a4,a2,46a <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 3cc:	4681                	li	a3,0
 3ce:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 3d0:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 3d2:	2881                	sext.w	a7,a7
        else {
            any = 1;
 3d4:	4f85                	li	t6,1
 3d6:	a0a9                	j	420 <strtoi+0xc2>
        c = *s++;
 3d8:	0007c703          	lbu	a4,0(a5)
 3dc:	00280793          	addi	a5,a6,2
        neg = 1;
 3e0:	4f05                	li	t5,1
 3e2:	b76d                	j	38c <strtoi+0x2e>
        c = *s++;
 3e4:	0007c703          	lbu	a4,0(a5)
 3e8:	00280793          	addi	a5,a6,2
 3ec:	b745                	j	38c <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 3ee:	0007c683          	lbu	a3,0(a5)
 3f2:	0df6f693          	andi	a3,a3,223
 3f6:	05800513          	li	a0,88
 3fa:	faa690e3          	bne	a3,a0,39a <strtoi+0x3c>
        c = s[1];
 3fe:	0017c703          	lbu	a4,1(a5)
        s += 2;
 402:	0789                	addi	a5,a5,2
        base = 16;
 404:	4641                	li	a2,16
 406:	b745                	j	3a6 <strtoi+0x48>
            any = -1;
 408:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 40a:	00e2c463          	blt	t0,a4,412 <strtoi+0xb4>
 40e:	a015                	j	432 <strtoi+0xd4>
            any = -1;
 410:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 412:	0785                	addi	a5,a5,1
 414:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 418:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 41c:	02c75063          	bge	a4,a2,43c <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 420:	fe06c8e3          	bltz	a3,410 <strtoi+0xb2>
 424:	0005081b          	sext.w	a6,a0
            any = -1;
 428:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 42a:	ff0e64e3          	bltu	t3,a6,412 <strtoi+0xb4>
 42e:	fca88de3          	beq	a7,a0,408 <strtoi+0xaa>
            acc *= base;
 432:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 436:	9d39                	addw	a0,a0,a4
            any = 1;
 438:	86fe                	mv	a3,t6
 43a:	bfe1                	j	412 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 43c:	0006cd63          	bltz	a3,456 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 440:	000f0463          	beqz	t5,448 <strtoi+0xea>
        acc = -acc;
 444:	40a0053b          	negw	a0,a0
    if (end != 0)
 448:	c581                	beqz	a1,450 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 44a:	ee89                	bnez	a3,464 <strtoi+0x106>
 44c:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 450:	6422                	ld	s0,8(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 456:	000f1d63          	bnez	t5,470 <strtoi+0x112>
 45a:	80000537          	lui	a0,0x80000
 45e:	fff54513          	not	a0,a0
    if (end != 0)
 462:	d5fd                	beqz	a1,450 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 464:	fff78e93          	addi	t4,a5,-1
 468:	b7d5                	j	44c <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 46a:	4681                	li	a3,0
 46c:	4501                	li	a0,0
 46e:	bfc9                	j	440 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 470:	80000537          	lui	a0,0x80000
 474:	b7fd                	j	462 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 476:	80000e37          	lui	t3,0x80000
 47a:	fffe4e13          	not	t3,t3
 47e:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 482:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 486:	003e589b          	srliw	a7,t3,0x3
 48a:	8e46                	mv	t3,a7
            c -= '0';
 48c:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 48e:	4621                	li	a2,8
 490:	bf35                	j	3cc <strtoi+0x6e>

0000000000000492 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 492:	1141                	addi	sp,sp,-16
 494:	e422                	sd	s0,8(sp)
 496:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 498:	02b57463          	bgeu	a0,a1,4c0 <memmove+0x2e>
    while(n-- > 0)
 49c:	00c05f63          	blez	a2,4ba <memmove+0x28>
 4a0:	1602                	slli	a2,a2,0x20
 4a2:	9201                	srli	a2,a2,0x20
 4a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 4aa:	0585                	addi	a1,a1,1
 4ac:	0705                	addi	a4,a4,1
 4ae:	fff5c683          	lbu	a3,-1(a1)
 4b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4b6:	fee79ae3          	bne	a5,a4,4aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ba:	6422                	ld	s0,8(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret
    dst += n;
 4c0:	00c50733          	add	a4,a0,a2
    src += n;
 4c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4c6:	fec05ae3          	blez	a2,4ba <memmove+0x28>
 4ca:	fff6079b          	addiw	a5,a2,-1
 4ce:	1782                	slli	a5,a5,0x20
 4d0:	9381                	srli	a5,a5,0x20
 4d2:	fff7c793          	not	a5,a5
 4d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4d8:	15fd                	addi	a1,a1,-1
 4da:	177d                	addi	a4,a4,-1
 4dc:	0005c683          	lbu	a3,0(a1)
 4e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4e4:	fee79ae3          	bne	a5,a4,4d8 <memmove+0x46>
 4e8:	bfc9                	j	4ba <memmove+0x28>

00000000000004ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e422                	sd	s0,8(sp)
 4ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f0:	ca05                	beqz	a2,520 <memcmp+0x36>
 4f2:	fff6069b          	addiw	a3,a2,-1
 4f6:	1682                	slli	a3,a3,0x20
 4f8:	9281                	srli	a3,a3,0x20
 4fa:	0685                	addi	a3,a3,1
 4fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4fe:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffedf0>
 502:	0005c703          	lbu	a4,0(a1)
 506:	00e79863          	bne	a5,a4,516 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 50a:	0505                	addi	a0,a0,1
    p2++;
 50c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 50e:	fed518e3          	bne	a0,a3,4fe <memcmp+0x14>
  }
  return 0;
 512:	4501                	li	a0,0
 514:	a019                	j	51a <memcmp+0x30>
      return *p1 - *p2;
 516:	40e7853b          	subw	a0,a5,a4
}
 51a:	6422                	ld	s0,8(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret
  return 0;
 520:	4501                	li	a0,0
 522:	bfe5                	j	51a <memcmp+0x30>

0000000000000524 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 524:	1141                	addi	sp,sp,-16
 526:	e406                	sd	ra,8(sp)
 528:	e022                	sd	s0,0(sp)
 52a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 52c:	00000097          	auipc	ra,0x0
 530:	f66080e7          	jalr	-154(ra) # 492 <memmove>
}
 534:	60a2                	ld	ra,8(sp)
 536:	6402                	ld	s0,0(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret

000000000000053c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 53c:	4885                	li	a7,1
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <exit>:
.global exit
exit:
 li a7, SYS_exit
 544:	4889                	li	a7,2
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <wait>:
.global wait
wait:
 li a7, SYS_wait
 54c:	488d                	li	a7,3
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 554:	4891                	li	a7,4
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <read>:
.global read
read:
 li a7, SYS_read
 55c:	4895                	li	a7,5
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <write>:
.global write
write:
 li a7, SYS_write
 564:	48c1                	li	a7,16
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <close>:
.global close
close:
 li a7, SYS_close
 56c:	48d5                	li	a7,21
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <kill>:
.global kill
kill:
 li a7, SYS_kill
 574:	4899                	li	a7,6
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <exec>:
.global exec
exec:
 li a7, SYS_exec
 57c:	489d                	li	a7,7
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <open>:
.global open
open:
 li a7, SYS_open
 584:	48bd                	li	a7,15
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 58c:	48c5                	li	a7,17
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 594:	48c9                	li	a7,18
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 59c:	48a1                	li	a7,8
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <link>:
.global link
link:
 li a7, SYS_link
 5a4:	48cd                	li	a7,19
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ac:	48d1                	li	a7,20
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b4:	48a5                	li	a7,9
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 5bc:	48a9                	li	a7,10
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c4:	48ad                	li	a7,11
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5cc:	48b1                	li	a7,12
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5d4:	48b5                	li	a7,13
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5dc:	48b9                	li	a7,14
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 5e4:	48d9                	li	a7,22
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 5ec:	48dd                	li	a7,23
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 5f4:	48e1                	li	a7,24
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 5fc:	48e5                	li	a7,25
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 604:	48e9                	li	a7,26
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 60c:	48ed                	li	a7,27
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 614:	1101                	addi	sp,sp,-32
 616:	ec06                	sd	ra,24(sp)
 618:	e822                	sd	s0,16(sp)
 61a:	1000                	addi	s0,sp,32
 61c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 620:	4605                	li	a2,1
 622:	fef40593          	addi	a1,s0,-17
 626:	00000097          	auipc	ra,0x0
 62a:	f3e080e7          	jalr	-194(ra) # 564 <write>
}
 62e:	60e2                	ld	ra,24(sp)
 630:	6442                	ld	s0,16(sp)
 632:	6105                	addi	sp,sp,32
 634:	8082                	ret

0000000000000636 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 636:	7139                	addi	sp,sp,-64
 638:	fc06                	sd	ra,56(sp)
 63a:	f822                	sd	s0,48(sp)
 63c:	f426                	sd	s1,40(sp)
 63e:	f04a                	sd	s2,32(sp)
 640:	ec4e                	sd	s3,24(sp)
 642:	0080                	addi	s0,sp,64
 644:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 646:	c299                	beqz	a3,64c <printint+0x16>
 648:	0805c963          	bltz	a1,6da <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 64c:	2581                	sext.w	a1,a1
  neg = 0;
 64e:	4881                	li	a7,0
 650:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 654:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 656:	2601                	sext.w	a2,a2
 658:	00000517          	auipc	a0,0x0
 65c:	4d050513          	addi	a0,a0,1232 # b28 <digits>
 660:	883a                	mv	a6,a4
 662:	2705                	addiw	a4,a4,1
 664:	02c5f7bb          	remuw	a5,a1,a2
 668:	1782                	slli	a5,a5,0x20
 66a:	9381                	srli	a5,a5,0x20
 66c:	97aa                	add	a5,a5,a0
 66e:	0007c783          	lbu	a5,0(a5)
 672:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 676:	0005879b          	sext.w	a5,a1
 67a:	02c5d5bb          	divuw	a1,a1,a2
 67e:	0685                	addi	a3,a3,1
 680:	fec7f0e3          	bgeu	a5,a2,660 <printint+0x2a>
  if(neg)
 684:	00088c63          	beqz	a7,69c <printint+0x66>
    buf[i++] = '-';
 688:	fd070793          	addi	a5,a4,-48
 68c:	00878733          	add	a4,a5,s0
 690:	02d00793          	li	a5,45
 694:	fef70823          	sb	a5,-16(a4)
 698:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 69c:	02e05863          	blez	a4,6cc <printint+0x96>
 6a0:	fc040793          	addi	a5,s0,-64
 6a4:	00e78933          	add	s2,a5,a4
 6a8:	fff78993          	addi	s3,a5,-1
 6ac:	99ba                	add	s3,s3,a4
 6ae:	377d                	addiw	a4,a4,-1
 6b0:	1702                	slli	a4,a4,0x20
 6b2:	9301                	srli	a4,a4,0x20
 6b4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6b8:	fff94583          	lbu	a1,-1(s2)
 6bc:	8526                	mv	a0,s1
 6be:	00000097          	auipc	ra,0x0
 6c2:	f56080e7          	jalr	-170(ra) # 614 <putc>
  while(--i >= 0)
 6c6:	197d                	addi	s2,s2,-1
 6c8:	ff3918e3          	bne	s2,s3,6b8 <printint+0x82>
}
 6cc:	70e2                	ld	ra,56(sp)
 6ce:	7442                	ld	s0,48(sp)
 6d0:	74a2                	ld	s1,40(sp)
 6d2:	7902                	ld	s2,32(sp)
 6d4:	69e2                	ld	s3,24(sp)
 6d6:	6121                	addi	sp,sp,64
 6d8:	8082                	ret
    x = -xx;
 6da:	40b005bb          	negw	a1,a1
    neg = 1;
 6de:	4885                	li	a7,1
    x = -xx;
 6e0:	bf85                	j	650 <printint+0x1a>

00000000000006e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6e2:	715d                	addi	sp,sp,-80
 6e4:	e486                	sd	ra,72(sp)
 6e6:	e0a2                	sd	s0,64(sp)
 6e8:	fc26                	sd	s1,56(sp)
 6ea:	f84a                	sd	s2,48(sp)
 6ec:	f44e                	sd	s3,40(sp)
 6ee:	f052                	sd	s4,32(sp)
 6f0:	ec56                	sd	s5,24(sp)
 6f2:	e85a                	sd	s6,16(sp)
 6f4:	e45e                	sd	s7,8(sp)
 6f6:	e062                	sd	s8,0(sp)
 6f8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6fa:	0005c903          	lbu	s2,0(a1)
 6fe:	18090c63          	beqz	s2,896 <vprintf+0x1b4>
 702:	8aaa                	mv	s5,a0
 704:	8bb2                	mv	s7,a2
 706:	00158493          	addi	s1,a1,1
  state = 0;
 70a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 70c:	02500a13          	li	s4,37
 710:	4b55                	li	s6,21
 712:	a839                	j	730 <vprintf+0x4e>
        putc(fd, c);
 714:	85ca                	mv	a1,s2
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	efc080e7          	jalr	-260(ra) # 614 <putc>
 720:	a019                	j	726 <vprintf+0x44>
    } else if(state == '%'){
 722:	01498d63          	beq	s3,s4,73c <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 726:	0485                	addi	s1,s1,1
 728:	fff4c903          	lbu	s2,-1(s1)
 72c:	16090563          	beqz	s2,896 <vprintf+0x1b4>
    if(state == 0){
 730:	fe0999e3          	bnez	s3,722 <vprintf+0x40>
      if(c == '%'){
 734:	ff4910e3          	bne	s2,s4,714 <vprintf+0x32>
        state = '%';
 738:	89d2                	mv	s3,s4
 73a:	b7f5                	j	726 <vprintf+0x44>
      if(c == 'd'){
 73c:	13490263          	beq	s2,s4,860 <vprintf+0x17e>
 740:	f9d9079b          	addiw	a5,s2,-99
 744:	0ff7f793          	zext.b	a5,a5
 748:	12fb6563          	bltu	s6,a5,872 <vprintf+0x190>
 74c:	f9d9079b          	addiw	a5,s2,-99
 750:	0ff7f713          	zext.b	a4,a5
 754:	10eb6f63          	bltu	s6,a4,872 <vprintf+0x190>
 758:	00271793          	slli	a5,a4,0x2
 75c:	00000717          	auipc	a4,0x0
 760:	37470713          	addi	a4,a4,884 # ad0 <malloc+0x13c>
 764:	97ba                	add	a5,a5,a4
 766:	439c                	lw	a5,0(a5)
 768:	97ba                	add	a5,a5,a4
 76a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 76c:	008b8913          	addi	s2,s7,8
 770:	4685                	li	a3,1
 772:	4629                	li	a2,10
 774:	000ba583          	lw	a1,0(s7)
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	ebc080e7          	jalr	-324(ra) # 636 <printint>
 782:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 784:	4981                	li	s3,0
 786:	b745                	j	726 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 788:	008b8913          	addi	s2,s7,8
 78c:	4681                	li	a3,0
 78e:	4629                	li	a2,10
 790:	000ba583          	lw	a1,0(s7)
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	ea0080e7          	jalr	-352(ra) # 636 <printint>
 79e:	8bca                	mv	s7,s2
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b751                	j	726 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 7a4:	008b8913          	addi	s2,s7,8
 7a8:	4681                	li	a3,0
 7aa:	4641                	li	a2,16
 7ac:	000ba583          	lw	a1,0(s7)
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	e84080e7          	jalr	-380(ra) # 636 <printint>
 7ba:	8bca                	mv	s7,s2
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b7a5                	j	726 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 7c0:	008b8c13          	addi	s8,s7,8
 7c4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c8:	03000593          	li	a1,48
 7cc:	8556                	mv	a0,s5
 7ce:	00000097          	auipc	ra,0x0
 7d2:	e46080e7          	jalr	-442(ra) # 614 <putc>
  putc(fd, 'x');
 7d6:	07800593          	li	a1,120
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e38080e7          	jalr	-456(ra) # 614 <putc>
 7e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7e6:	00000b97          	auipc	s7,0x0
 7ea:	342b8b93          	addi	s7,s7,834 # b28 <digits>
 7ee:	03c9d793          	srli	a5,s3,0x3c
 7f2:	97de                	add	a5,a5,s7
 7f4:	0007c583          	lbu	a1,0(a5)
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	e1a080e7          	jalr	-486(ra) # 614 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 802:	0992                	slli	s3,s3,0x4
 804:	397d                	addiw	s2,s2,-1
 806:	fe0914e3          	bnez	s2,7ee <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 80a:	8be2                	mv	s7,s8
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bf21                	j	726 <vprintf+0x44>
        s = va_arg(ap, char*);
 810:	008b8993          	addi	s3,s7,8
 814:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 818:	02090163          	beqz	s2,83a <vprintf+0x158>
        while(*s != 0){
 81c:	00094583          	lbu	a1,0(s2)
 820:	c9a5                	beqz	a1,890 <vprintf+0x1ae>
          putc(fd, *s);
 822:	8556                	mv	a0,s5
 824:	00000097          	auipc	ra,0x0
 828:	df0080e7          	jalr	-528(ra) # 614 <putc>
          s++;
 82c:	0905                	addi	s2,s2,1
        while(*s != 0){
 82e:	00094583          	lbu	a1,0(s2)
 832:	f9e5                	bnez	a1,822 <vprintf+0x140>
        s = va_arg(ap, char*);
 834:	8bce                	mv	s7,s3
      state = 0;
 836:	4981                	li	s3,0
 838:	b5fd                	j	726 <vprintf+0x44>
          s = "(null)";
 83a:	00000917          	auipc	s2,0x0
 83e:	28e90913          	addi	s2,s2,654 # ac8 <malloc+0x134>
        while(*s != 0){
 842:	02800593          	li	a1,40
 846:	bff1                	j	822 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 848:	008b8913          	addi	s2,s7,8
 84c:	000bc583          	lbu	a1,0(s7)
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	dc2080e7          	jalr	-574(ra) # 614 <putc>
 85a:	8bca                	mv	s7,s2
      state = 0;
 85c:	4981                	li	s3,0
 85e:	b5e1                	j	726 <vprintf+0x44>
        putc(fd, c);
 860:	02500593          	li	a1,37
 864:	8556                	mv	a0,s5
 866:	00000097          	auipc	ra,0x0
 86a:	dae080e7          	jalr	-594(ra) # 614 <putc>
      state = 0;
 86e:	4981                	li	s3,0
 870:	bd5d                	j	726 <vprintf+0x44>
        putc(fd, '%');
 872:	02500593          	li	a1,37
 876:	8556                	mv	a0,s5
 878:	00000097          	auipc	ra,0x0
 87c:	d9c080e7          	jalr	-612(ra) # 614 <putc>
        putc(fd, c);
 880:	85ca                	mv	a1,s2
 882:	8556                	mv	a0,s5
 884:	00000097          	auipc	ra,0x0
 888:	d90080e7          	jalr	-624(ra) # 614 <putc>
      state = 0;
 88c:	4981                	li	s3,0
 88e:	bd61                	j	726 <vprintf+0x44>
        s = va_arg(ap, char*);
 890:	8bce                	mv	s7,s3
      state = 0;
 892:	4981                	li	s3,0
 894:	bd49                	j	726 <vprintf+0x44>
    }
  }
}
 896:	60a6                	ld	ra,72(sp)
 898:	6406                	ld	s0,64(sp)
 89a:	74e2                	ld	s1,56(sp)
 89c:	7942                	ld	s2,48(sp)
 89e:	79a2                	ld	s3,40(sp)
 8a0:	7a02                	ld	s4,32(sp)
 8a2:	6ae2                	ld	s5,24(sp)
 8a4:	6b42                	ld	s6,16(sp)
 8a6:	6ba2                	ld	s7,8(sp)
 8a8:	6c02                	ld	s8,0(sp)
 8aa:	6161                	addi	sp,sp,80
 8ac:	8082                	ret

00000000000008ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ae:	715d                	addi	sp,sp,-80
 8b0:	ec06                	sd	ra,24(sp)
 8b2:	e822                	sd	s0,16(sp)
 8b4:	1000                	addi	s0,sp,32
 8b6:	e010                	sd	a2,0(s0)
 8b8:	e414                	sd	a3,8(s0)
 8ba:	e818                	sd	a4,16(s0)
 8bc:	ec1c                	sd	a5,24(s0)
 8be:	03043023          	sd	a6,32(s0)
 8c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ca:	8622                	mv	a2,s0
 8cc:	00000097          	auipc	ra,0x0
 8d0:	e16080e7          	jalr	-490(ra) # 6e2 <vprintf>
}
 8d4:	60e2                	ld	ra,24(sp)
 8d6:	6442                	ld	s0,16(sp)
 8d8:	6161                	addi	sp,sp,80
 8da:	8082                	ret

00000000000008dc <printf>:

void
printf(const char *fmt, ...)
{
 8dc:	711d                	addi	sp,sp,-96
 8de:	ec06                	sd	ra,24(sp)
 8e0:	e822                	sd	s0,16(sp)
 8e2:	1000                	addi	s0,sp,32
 8e4:	e40c                	sd	a1,8(s0)
 8e6:	e810                	sd	a2,16(s0)
 8e8:	ec14                	sd	a3,24(s0)
 8ea:	f018                	sd	a4,32(s0)
 8ec:	f41c                	sd	a5,40(s0)
 8ee:	03043823          	sd	a6,48(s0)
 8f2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8f6:	00840613          	addi	a2,s0,8
 8fa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8fe:	85aa                	mv	a1,a0
 900:	4505                	li	a0,1
 902:	00000097          	auipc	ra,0x0
 906:	de0080e7          	jalr	-544(ra) # 6e2 <vprintf>
}
 90a:	60e2                	ld	ra,24(sp)
 90c:	6442                	ld	s0,16(sp)
 90e:	6125                	addi	sp,sp,96
 910:	8082                	ret

0000000000000912 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 912:	1141                	addi	sp,sp,-16
 914:	e422                	sd	s0,8(sp)
 916:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 918:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91c:	00000797          	auipc	a5,0x0
 920:	6e47b783          	ld	a5,1764(a5) # 1000 <freep>
 924:	a02d                	j	94e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 926:	4618                	lw	a4,8(a2)
 928:	9f2d                	addw	a4,a4,a1
 92a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	6310                	ld	a2,0(a4)
 932:	a83d                	j	970 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 934:	ff852703          	lw	a4,-8(a0)
 938:	9f31                	addw	a4,a4,a2
 93a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 93c:	ff053683          	ld	a3,-16(a0)
 940:	a091                	j	984 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 942:	6398                	ld	a4,0(a5)
 944:	00e7e463          	bltu	a5,a4,94c <free+0x3a>
 948:	00e6ea63          	bltu	a3,a4,95c <free+0x4a>
{
 94c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94e:	fed7fae3          	bgeu	a5,a3,942 <free+0x30>
 952:	6398                	ld	a4,0(a5)
 954:	00e6e463          	bltu	a3,a4,95c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 958:	fee7eae3          	bltu	a5,a4,94c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 95c:	ff852583          	lw	a1,-8(a0)
 960:	6390                	ld	a2,0(a5)
 962:	02059813          	slli	a6,a1,0x20
 966:	01c85713          	srli	a4,a6,0x1c
 96a:	9736                	add	a4,a4,a3
 96c:	fae60de3          	beq	a2,a4,926 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 970:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 974:	4790                	lw	a2,8(a5)
 976:	02061593          	slli	a1,a2,0x20
 97a:	01c5d713          	srli	a4,a1,0x1c
 97e:	973e                	add	a4,a4,a5
 980:	fae68ae3          	beq	a3,a4,934 <free+0x22>
    p->s.ptr = bp->s.ptr;
 984:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 986:	00000717          	auipc	a4,0x0
 98a:	66f73d23          	sd	a5,1658(a4) # 1000 <freep>
}
 98e:	6422                	ld	s0,8(sp)
 990:	0141                	addi	sp,sp,16
 992:	8082                	ret

0000000000000994 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 994:	7139                	addi	sp,sp,-64
 996:	fc06                	sd	ra,56(sp)
 998:	f822                	sd	s0,48(sp)
 99a:	f426                	sd	s1,40(sp)
 99c:	f04a                	sd	s2,32(sp)
 99e:	ec4e                	sd	s3,24(sp)
 9a0:	e852                	sd	s4,16(sp)
 9a2:	e456                	sd	s5,8(sp)
 9a4:	e05a                	sd	s6,0(sp)
 9a6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9a8:	02051493          	slli	s1,a0,0x20
 9ac:	9081                	srli	s1,s1,0x20
 9ae:	04bd                	addi	s1,s1,15
 9b0:	8091                	srli	s1,s1,0x4
 9b2:	0014899b          	addiw	s3,s1,1
 9b6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9b8:	00000517          	auipc	a0,0x0
 9bc:	64853503          	ld	a0,1608(a0) # 1000 <freep>
 9c0:	c515                	beqz	a0,9ec <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c4:	4798                	lw	a4,8(a5)
 9c6:	02977f63          	bgeu	a4,s1,a04 <malloc+0x70>
  if(nu < 4096)
 9ca:	8a4e                	mv	s4,s3
 9cc:	0009871b          	sext.w	a4,s3
 9d0:	6685                	lui	a3,0x1
 9d2:	00d77363          	bgeu	a4,a3,9d8 <malloc+0x44>
 9d6:	6a05                	lui	s4,0x1
 9d8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9dc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e0:	00000917          	auipc	s2,0x0
 9e4:	62090913          	addi	s2,s2,1568 # 1000 <freep>
  if(p == (char*)-1)
 9e8:	5afd                	li	s5,-1
 9ea:	a895                	j	a5e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9ec:	00001797          	auipc	a5,0x1
 9f0:	82478793          	addi	a5,a5,-2012 # 1210 <base>
 9f4:	00000717          	auipc	a4,0x0
 9f8:	60f73623          	sd	a5,1548(a4) # 1000 <freep>
 9fc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9fe:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a02:	b7e1                	j	9ca <malloc+0x36>
      if(p->s.size == nunits)
 a04:	02e48c63          	beq	s1,a4,a3c <malloc+0xa8>
        p->s.size -= nunits;
 a08:	4137073b          	subw	a4,a4,s3
 a0c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a0e:	02071693          	slli	a3,a4,0x20
 a12:	01c6d713          	srli	a4,a3,0x1c
 a16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1c:	00000717          	auipc	a4,0x0
 a20:	5ea73223          	sd	a0,1508(a4) # 1000 <freep>
      return (void*)(p + 1);
 a24:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a28:	70e2                	ld	ra,56(sp)
 a2a:	7442                	ld	s0,48(sp)
 a2c:	74a2                	ld	s1,40(sp)
 a2e:	7902                	ld	s2,32(sp)
 a30:	69e2                	ld	s3,24(sp)
 a32:	6a42                	ld	s4,16(sp)
 a34:	6aa2                	ld	s5,8(sp)
 a36:	6b02                	ld	s6,0(sp)
 a38:	6121                	addi	sp,sp,64
 a3a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a3c:	6398                	ld	a4,0(a5)
 a3e:	e118                	sd	a4,0(a0)
 a40:	bff1                	j	a1c <malloc+0x88>
  hp->s.size = nu;
 a42:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a46:	0541                	addi	a0,a0,16
 a48:	00000097          	auipc	ra,0x0
 a4c:	eca080e7          	jalr	-310(ra) # 912 <free>
  return freep;
 a50:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a54:	d971                	beqz	a0,a28 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a58:	4798                	lw	a4,8(a5)
 a5a:	fa9775e3          	bgeu	a4,s1,a04 <malloc+0x70>
    if(p == freep)
 a5e:	00093703          	ld	a4,0(s2)
 a62:	853e                	mv	a0,a5
 a64:	fef719e3          	bne	a4,a5,a56 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a68:	8552                	mv	a0,s4
 a6a:	00000097          	auipc	ra,0x0
 a6e:	b62080e7          	jalr	-1182(ra) # 5cc <sbrk>
  if(p == (char*)-1)
 a72:	fd5518e3          	bne	a0,s5,a42 <malloc+0xae>
        return 0;
 a76:	4501                	li	a0,0
 a78:	bf45                	j	a28 <malloc+0x94>
