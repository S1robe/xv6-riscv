
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	e062                	sd	s8,0(sp)
 130:	0880                	addi	s0,sp,80
 132:	89aa                	mv	s3,a0
 134:	8b2e                	mv	s6,a1
  m = 0;
 136:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 138:	3ff00b93          	li	s7,1023
 13c:	00001a97          	auipc	s5,0x1
 140:	ed4a8a93          	addi	s5,s5,-300 # 1010 <buf>
 144:	a0a1                	j	18c <grep+0x72>
      p = q+1;
 146:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 14a:	45a9                	li	a1,10
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	20a080e7          	jalr	522(ra) # 358 <strchr>
 156:	84aa                	mv	s1,a0
 158:	c905                	beqz	a0,188 <grep+0x6e>
      *q = 0;
 15a:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15e:	85ca                	mv	a1,s2
 160:	854e                	mv	a0,s3
 162:	00000097          	auipc	ra,0x0
 166:	f6a080e7          	jalr	-150(ra) # cc <match>
 16a:	dd71                	beqz	a0,146 <grep+0x2c>
        *q = '\n';
 16c:	47a9                	li	a5,10
 16e:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 172:	00148613          	addi	a2,s1,1
 176:	4126063b          	subw	a2,a2,s2
 17a:	85ca                	mv	a1,s2
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	506080e7          	jalr	1286(ra) # 684 <write>
 186:	b7c1                	j	146 <grep+0x2c>
    if(m > 0){
 188:	03404763          	bgtz	s4,1b6 <grep+0x9c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18c:	414b863b          	subw	a2,s7,s4
 190:	014a85b3          	add	a1,s5,s4
 194:	855a                	mv	a0,s6
 196:	00000097          	auipc	ra,0x0
 19a:	4e6080e7          	jalr	1254(ra) # 67c <read>
 19e:	02a05b63          	blez	a0,1d4 <grep+0xba>
    m += n;
 1a2:	00aa0c3b          	addw	s8,s4,a0
 1a6:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 1aa:	014a87b3          	add	a5,s5,s4
 1ae:	00078023          	sb	zero,0(a5)
    p = buf;
 1b2:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1b4:	bf59                	j	14a <grep+0x30>
      m -= p - buf;
 1b6:	00001517          	auipc	a0,0x1
 1ba:	e5a50513          	addi	a0,a0,-422 # 1010 <buf>
 1be:	40a90a33          	sub	s4,s2,a0
 1c2:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1c6:	8652                	mv	a2,s4
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	3e8080e7          	jalr	1000(ra) # 5b2 <memmove>
 1d2:	bf6d                	j	18c <grep+0x72>
}
 1d4:	60a6                	ld	ra,72(sp)
 1d6:	6406                	ld	s0,64(sp)
 1d8:	74e2                	ld	s1,56(sp)
 1da:	7942                	ld	s2,48(sp)
 1dc:	79a2                	ld	s3,40(sp)
 1de:	7a02                	ld	s4,32(sp)
 1e0:	6ae2                	ld	s5,24(sp)
 1e2:	6b42                	ld	s6,16(sp)
 1e4:	6ba2                	ld	s7,8(sp)
 1e6:	6c02                	ld	s8,0(sp)
 1e8:	6161                	addi	sp,sp,80
 1ea:	8082                	ret

00000000000001ec <main>:
{
 1ec:	7179                	addi	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1fc:	4785                	li	a5,1
 1fe:	04a7de63          	bge	a5,a0,25a <main+0x6e>
  pattern = argv[1];
 202:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 206:	4789                	li	a5,2
 208:	06a7d763          	bge	a5,a0,276 <main+0x8a>
 20c:	01058913          	addi	s2,a1,16
 210:	ffd5099b          	addiw	s3,a0,-3
 214:	02099793          	slli	a5,s3,0x20
 218:	01d7d993          	srli	s3,a5,0x1d
 21c:	05e1                	addi	a1,a1,24
 21e:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 220:	4581                	li	a1,0
 222:	00093503          	ld	a0,0(s2)
 226:	00000097          	auipc	ra,0x0
 22a:	47e080e7          	jalr	1150(ra) # 6a4 <open>
 22e:	84aa                	mv	s1,a0
 230:	04054e63          	bltz	a0,28c <main+0xa0>
    grep(pattern, fd);
 234:	85aa                	mv	a1,a0
 236:	8552                	mv	a0,s4
 238:	00000097          	auipc	ra,0x0
 23c:	ee2080e7          	jalr	-286(ra) # 11a <grep>
    close(fd);
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	44a080e7          	jalr	1098(ra) # 68c <close>
  for(i = 2; i < argc; i++){
 24a:	0921                	addi	s2,s2,8
 24c:	fd391ae3          	bne	s2,s3,220 <main+0x34>
  exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	412080e7          	jalr	1042(ra) # 664 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25a:	00001597          	auipc	a1,0x1
 25e:	94658593          	addi	a1,a1,-1722 # ba0 <malloc+0xec>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	76a080e7          	jalr	1898(ra) # 9ce <fprintf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	3f6080e7          	jalr	1014(ra) # 664 <exit>
    grep(pattern, 0);
 276:	4581                	li	a1,0
 278:	8552                	mv	a0,s4
 27a:	00000097          	auipc	ra,0x0
 27e:	ea0080e7          	jalr	-352(ra) # 11a <grep>
    exit(0);
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	3e0080e7          	jalr	992(ra) # 664 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 28c:	00093583          	ld	a1,0(s2)
 290:	00001517          	auipc	a0,0x1
 294:	93050513          	addi	a0,a0,-1744 # bc0 <malloc+0x10c>
 298:	00000097          	auipc	ra,0x0
 29c:	764080e7          	jalr	1892(ra) # 9fc <printf>
      exit(1);
 2a0:	4505                	li	a0,1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	3c2080e7          	jalr	962(ra) # 664 <exit>

00000000000002aa <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2b2:	00000097          	auipc	ra,0x0
 2b6:	f3a080e7          	jalr	-198(ra) # 1ec <main>
  exit(0);
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	3a8080e7          	jalr	936(ra) # 664 <exit>

00000000000002c4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2ca:	87aa                	mv	a5,a0
 2cc:	0585                	addi	a1,a1,1
 2ce:	0785                	addi	a5,a5,1
 2d0:	fff5c703          	lbu	a4,-1(a1)
 2d4:	fee78fa3          	sb	a4,-1(a5)
 2d8:	fb75                	bnez	a4,2cc <strcpy+0x8>
    ;
  return os;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	cb91                	beqz	a5,2fe <strcmp+0x1e>
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00f71763          	bne	a4,a5,2fe <strcmp+0x1e>
    p++, q++;
 2f4:	0505                	addi	a0,a0,1
 2f6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	fbe5                	bnez	a5,2ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2fe:	0005c503          	lbu	a0,0(a1)
}
 302:	40a7853b          	subw	a0,a5,a0
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strlen>:

uint
strlen(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cf91                	beqz	a5,332 <strlen+0x26>
 318:	0505                	addi	a0,a0,1
 31a:	87aa                	mv	a5,a0
 31c:	86be                	mv	a3,a5
 31e:	0785                	addi	a5,a5,1
 320:	fff7c703          	lbu	a4,-1(a5)
 324:	ff65                	bnez	a4,31c <strlen+0x10>
 326:	40a6853b          	subw	a0,a3,a0
 32a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  for(n = 0; s[n]; n++)
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <strlen+0x20>

0000000000000336 <memset>:

void*
memset(void *dst, int c, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33c:	ca19                	beqz	a2,352 <memset+0x1c>
 33e:	87aa                	mv	a5,a0
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 348:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 34c:	0785                	addi	a5,a5,1
 34e:	fee79de3          	bne	a5,a4,348 <memset+0x12>
  }
  return dst;
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <strchr>:

char*
strchr(const char *s, char c)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 35e:	00054783          	lbu	a5,0(a0)
 362:	cb99                	beqz	a5,378 <strchr+0x20>
    if(*s == c)
 364:	00f58763          	beq	a1,a5,372 <strchr+0x1a>
  for(; *s; s++)
 368:	0505                	addi	a0,a0,1
 36a:	00054783          	lbu	a5,0(a0)
 36e:	fbfd                	bnez	a5,364 <strchr+0xc>
      return (char*)s;
  return 0;
 370:	4501                	li	a0,0
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  return 0;
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <strchr+0x1a>

000000000000037c <gets>:

char*
gets(char *buf, int max)
{
 37c:	711d                	addi	sp,sp,-96
 37e:	ec86                	sd	ra,88(sp)
 380:	e8a2                	sd	s0,80(sp)
 382:	e4a6                	sd	s1,72(sp)
 384:	e0ca                	sd	s2,64(sp)
 386:	fc4e                	sd	s3,56(sp)
 388:	f852                	sd	s4,48(sp)
 38a:	f456                	sd	s5,40(sp)
 38c:	f05a                	sd	s6,32(sp)
 38e:	ec5e                	sd	s7,24(sp)
 390:	1080                	addi	s0,sp,96
 392:	8baa                	mv	s7,a0
 394:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 396:	892a                	mv	s2,a0
 398:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 39a:	4aa9                	li	s5,10
 39c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 39e:	89a6                	mv	s3,s1
 3a0:	2485                	addiw	s1,s1,1
 3a2:	0344d863          	bge	s1,s4,3d2 <gets+0x56>
    cc = read(0, &c, 1);
 3a6:	4605                	li	a2,1
 3a8:	faf40593          	addi	a1,s0,-81
 3ac:	4501                	li	a0,0
 3ae:	00000097          	auipc	ra,0x0
 3b2:	2ce080e7          	jalr	718(ra) # 67c <read>
    if(cc < 1)
 3b6:	00a05e63          	blez	a0,3d2 <gets+0x56>
    buf[i++] = c;
 3ba:	faf44783          	lbu	a5,-81(s0)
 3be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c2:	01578763          	beq	a5,s5,3d0 <gets+0x54>
 3c6:	0905                	addi	s2,s2,1
 3c8:	fd679be3          	bne	a5,s6,39e <gets+0x22>
  for(i=0; i+1 < max; ){
 3cc:	89a6                	mv	s3,s1
 3ce:	a011                	j	3d2 <gets+0x56>
 3d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d2:	99de                	add	s3,s3,s7
 3d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d8:	855e                	mv	a0,s7
 3da:	60e6                	ld	ra,88(sp)
 3dc:	6446                	ld	s0,80(sp)
 3de:	64a6                	ld	s1,72(sp)
 3e0:	6906                	ld	s2,64(sp)
 3e2:	79e2                	ld	s3,56(sp)
 3e4:	7a42                	ld	s4,48(sp)
 3e6:	7aa2                	ld	s5,40(sp)
 3e8:	7b02                	ld	s6,32(sp)
 3ea:	6be2                	ld	s7,24(sp)
 3ec:	6125                	addi	sp,sp,96
 3ee:	8082                	ret

00000000000003f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	e426                	sd	s1,8(sp)
 3f8:	e04a                	sd	s2,0(sp)
 3fa:	1000                	addi	s0,sp,32
 3fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fe:	4581                	li	a1,0
 400:	00000097          	auipc	ra,0x0
 404:	2a4080e7          	jalr	676(ra) # 6a4 <open>
  if(fd < 0)
 408:	02054563          	bltz	a0,432 <stat+0x42>
 40c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 40e:	85ca                	mv	a1,s2
 410:	00000097          	auipc	ra,0x0
 414:	2ac080e7          	jalr	684(ra) # 6bc <fstat>
 418:	892a                	mv	s2,a0
  close(fd);
 41a:	8526                	mv	a0,s1
 41c:	00000097          	auipc	ra,0x0
 420:	270080e7          	jalr	624(ra) # 68c <close>
  return r;
}
 424:	854a                	mv	a0,s2
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	64a2                	ld	s1,8(sp)
 42c:	6902                	ld	s2,0(sp)
 42e:	6105                	addi	sp,sp,32
 430:	8082                	ret
    return -1;
 432:	597d                	li	s2,-1
 434:	bfc5                	j	424 <stat+0x34>

0000000000000436 <atoi>:

int
atoi(const char *s)
{
 436:	1141                	addi	sp,sp,-16
 438:	e422                	sd	s0,8(sp)
 43a:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 43c:	00054683          	lbu	a3,0(a0)
 440:	fd06879b          	addiw	a5,a3,-48
 444:	0ff7f793          	zext.b	a5,a5
 448:	4625                	li	a2,9
 44a:	02f66863          	bltu	a2,a5,47a <atoi+0x44>
 44e:	872a                	mv	a4,a0
  n = 0;
 450:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 452:	0705                	addi	a4,a4,1
 454:	0025179b          	slliw	a5,a0,0x2
 458:	9fa9                	addw	a5,a5,a0
 45a:	0017979b          	slliw	a5,a5,0x1
 45e:	9fb5                	addw	a5,a5,a3
 460:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 464:	00074683          	lbu	a3,0(a4)
 468:	fd06879b          	addiw	a5,a3,-48
 46c:	0ff7f793          	zext.b	a5,a5
 470:	fef671e3          	bgeu	a2,a5,452 <atoi+0x1c>

  return n;
}
 474:	6422                	ld	s0,8(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret
  n = 0;
 47a:	4501                	li	a0,0
 47c:	bfe5                	j	474 <atoi+0x3e>

000000000000047e <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
 484:	8eaa                	mv	t4,a0
    register const char *s = strt;
 486:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 488:	02000693          	li	a3,32
        c = *s++;
 48c:	883e                	mv	a6,a5
 48e:	0785                	addi	a5,a5,1
 490:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 494:	fed70ce3          	beq	a4,a3,48c <strtoi+0xe>
        c = *s++;
 498:	2701                	sext.w	a4,a4

    if (c == '-') {
 49a:	02d00693          	li	a3,45
 49e:	04d70d63          	beq	a4,a3,4f8 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 4a2:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 4a6:	4f01                	li	t5,0
    } else if (c == '+')
 4a8:	04d70e63          	beq	a4,a3,504 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 4ac:	fef67693          	andi	a3,a2,-17
 4b0:	ea99                	bnez	a3,4c6 <strtoi+0x48>
 4b2:	03000693          	li	a3,48
 4b6:	04d70c63          	beq	a4,a3,50e <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 4ba:	e611                	bnez	a2,4c6 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 4bc:	03000693          	li	a3,48
 4c0:	0cd70b63          	beq	a4,a3,596 <strtoi+0x118>
 4c4:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 4c6:	800008b7          	lui	a7,0x80000
 4ca:	fff8c893          	not	a7,a7
 4ce:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 4d2:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 4d6:	1882                	slli	a7,a7,0x20
 4d8:	0208d893          	srli	a7,a7,0x20
 4dc:	02c8d8b3          	divu	a7,a7,a2
 4e0:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 4e4:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 4e8:	0ac75163          	bge	a4,a2,58a <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 4ec:	4681                	li	a3,0
 4ee:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 4f0:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 4f2:	2881                	sext.w	a7,a7
        else {
            any = 1;
 4f4:	4f85                	li	t6,1
 4f6:	a0a9                	j	540 <strtoi+0xc2>
        c = *s++;
 4f8:	0007c703          	lbu	a4,0(a5)
 4fc:	00280793          	addi	a5,a6,2
        neg = 1;
 500:	4f05                	li	t5,1
 502:	b76d                	j	4ac <strtoi+0x2e>
        c = *s++;
 504:	0007c703          	lbu	a4,0(a5)
 508:	00280793          	addi	a5,a6,2
 50c:	b745                	j	4ac <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 50e:	0007c683          	lbu	a3,0(a5)
 512:	0df6f693          	andi	a3,a3,223
 516:	05800513          	li	a0,88
 51a:	faa690e3          	bne	a3,a0,4ba <strtoi+0x3c>
        c = s[1];
 51e:	0017c703          	lbu	a4,1(a5)
        s += 2;
 522:	0789                	addi	a5,a5,2
        base = 16;
 524:	4641                	li	a2,16
 526:	b745                	j	4c6 <strtoi+0x48>
            any = -1;
 528:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 52a:	00e2c463          	blt	t0,a4,532 <strtoi+0xb4>
 52e:	a015                	j	552 <strtoi+0xd4>
            any = -1;
 530:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 532:	0785                	addi	a5,a5,1
 534:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 538:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 53c:	02c75063          	bge	a4,a2,55c <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 540:	fe06c8e3          	bltz	a3,530 <strtoi+0xb2>
 544:	0005081b          	sext.w	a6,a0
            any = -1;
 548:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 54a:	ff0e64e3          	bltu	t3,a6,532 <strtoi+0xb4>
 54e:	fca88de3          	beq	a7,a0,528 <strtoi+0xaa>
            acc *= base;
 552:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 556:	9d39                	addw	a0,a0,a4
            any = 1;
 558:	86fe                	mv	a3,t6
 55a:	bfe1                	j	532 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 55c:	0006cd63          	bltz	a3,576 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 560:	000f0463          	beqz	t5,568 <strtoi+0xea>
        acc = -acc;
 564:	40a0053b          	negw	a0,a0
    if (end != 0)
 568:	c581                	beqz	a1,570 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 56a:	ee89                	bnez	a3,584 <strtoi+0x106>
 56c:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 570:	6422                	ld	s0,8(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 576:	000f1d63          	bnez	t5,590 <strtoi+0x112>
 57a:	80000537          	lui	a0,0x80000
 57e:	fff54513          	not	a0,a0
    if (end != 0)
 582:	d5fd                	beqz	a1,570 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 584:	fff78e93          	addi	t4,a5,-1
 588:	b7d5                	j	56c <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 58a:	4681                	li	a3,0
 58c:	4501                	li	a0,0
 58e:	bfc9                	j	560 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 590:	80000537          	lui	a0,0x80000
 594:	b7fd                	j	582 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 596:	80000e37          	lui	t3,0x80000
 59a:	fffe4e13          	not	t3,t3
 59e:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 5a2:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 5a6:	003e589b          	srliw	a7,t3,0x3
 5aa:	8e46                	mv	t3,a7
            c -= '0';
 5ac:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 5ae:	4621                	li	a2,8
 5b0:	bf35                	j	4ec <strtoi+0x6e>

00000000000005b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5b2:	1141                	addi	sp,sp,-16
 5b4:	e422                	sd	s0,8(sp)
 5b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5b8:	02b57463          	bgeu	a0,a1,5e0 <memmove+0x2e>
    while(n-- > 0)
 5bc:	00c05f63          	blez	a2,5da <memmove+0x28>
 5c0:	1602                	slli	a2,a2,0x20
 5c2:	9201                	srli	a2,a2,0x20
 5c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 5ca:	0585                	addi	a1,a1,1
 5cc:	0705                	addi	a4,a4,1
 5ce:	fff5c683          	lbu	a3,-1(a1)
 5d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5d6:	fee79ae3          	bne	a5,a4,5ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5da:	6422                	ld	s0,8(sp)
 5dc:	0141                	addi	sp,sp,16
 5de:	8082                	ret
    dst += n;
 5e0:	00c50733          	add	a4,a0,a2
    src += n;
 5e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5e6:	fec05ae3          	blez	a2,5da <memmove+0x28>
 5ea:	fff6079b          	addiw	a5,a2,-1
 5ee:	1782                	slli	a5,a5,0x20
 5f0:	9381                	srli	a5,a5,0x20
 5f2:	fff7c793          	not	a5,a5
 5f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5f8:	15fd                	addi	a1,a1,-1
 5fa:	177d                	addi	a4,a4,-1
 5fc:	0005c683          	lbu	a3,0(a1)
 600:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 604:	fee79ae3          	bne	a5,a4,5f8 <memmove+0x46>
 608:	bfc9                	j	5da <memmove+0x28>

000000000000060a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 60a:	1141                	addi	sp,sp,-16
 60c:	e422                	sd	s0,8(sp)
 60e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 610:	ca05                	beqz	a2,640 <memcmp+0x36>
 612:	fff6069b          	addiw	a3,a2,-1
 616:	1682                	slli	a3,a3,0x20
 618:	9281                	srli	a3,a3,0x20
 61a:	0685                	addi	a3,a3,1
 61c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 61e:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffebf0>
 622:	0005c703          	lbu	a4,0(a1)
 626:	00e79863          	bne	a5,a4,636 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 62a:	0505                	addi	a0,a0,1
    p2++;
 62c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 62e:	fed518e3          	bne	a0,a3,61e <memcmp+0x14>
  }
  return 0;
 632:	4501                	li	a0,0
 634:	a019                	j	63a <memcmp+0x30>
      return *p1 - *p2;
 636:	40e7853b          	subw	a0,a5,a4
}
 63a:	6422                	ld	s0,8(sp)
 63c:	0141                	addi	sp,sp,16
 63e:	8082                	ret
  return 0;
 640:	4501                	li	a0,0
 642:	bfe5                	j	63a <memcmp+0x30>

0000000000000644 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 644:	1141                	addi	sp,sp,-16
 646:	e406                	sd	ra,8(sp)
 648:	e022                	sd	s0,0(sp)
 64a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 64c:	00000097          	auipc	ra,0x0
 650:	f66080e7          	jalr	-154(ra) # 5b2 <memmove>
}
 654:	60a2                	ld	ra,8(sp)
 656:	6402                	ld	s0,0(sp)
 658:	0141                	addi	sp,sp,16
 65a:	8082                	ret

000000000000065c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 65c:	4885                	li	a7,1
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <exit>:
.global exit
exit:
 li a7, SYS_exit
 664:	4889                	li	a7,2
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <wait>:
.global wait
wait:
 li a7, SYS_wait
 66c:	488d                	li	a7,3
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 674:	4891                	li	a7,4
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <read>:
.global read
read:
 li a7, SYS_read
 67c:	4895                	li	a7,5
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <write>:
.global write
write:
 li a7, SYS_write
 684:	48c1                	li	a7,16
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <close>:
.global close
close:
 li a7, SYS_close
 68c:	48d5                	li	a7,21
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <kill>:
.global kill
kill:
 li a7, SYS_kill
 694:	4899                	li	a7,6
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <exec>:
.global exec
exec:
 li a7, SYS_exec
 69c:	489d                	li	a7,7
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <open>:
.global open
open:
 li a7, SYS_open
 6a4:	48bd                	li	a7,15
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6ac:	48c5                	li	a7,17
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6b4:	48c9                	li	a7,18
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6bc:	48a1                	li	a7,8
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <link>:
.global link
link:
 li a7, SYS_link
 6c4:	48cd                	li	a7,19
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6cc:	48d1                	li	a7,20
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6d4:	48a5                	li	a7,9
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 6dc:	48a9                	li	a7,10
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6e4:	48ad                	li	a7,11
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6ec:	48b1                	li	a7,12
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6f4:	48b5                	li	a7,13
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6fc:	48b9                	li	a7,14
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 704:	48d9                	li	a7,22
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 70c:	48dd                	li	a7,23
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 714:	48e1                	li	a7,24
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 71c:	48e5                	li	a7,25
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 724:	48e9                	li	a7,26
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 72c:	48ed                	li	a7,27
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 734:	1101                	addi	sp,sp,-32
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 740:	4605                	li	a2,1
 742:	fef40593          	addi	a1,s0,-17
 746:	00000097          	auipc	ra,0x0
 74a:	f3e080e7          	jalr	-194(ra) # 684 <write>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6105                	addi	sp,sp,32
 754:	8082                	ret

0000000000000756 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 756:	7139                	addi	sp,sp,-64
 758:	fc06                	sd	ra,56(sp)
 75a:	f822                	sd	s0,48(sp)
 75c:	f426                	sd	s1,40(sp)
 75e:	f04a                	sd	s2,32(sp)
 760:	ec4e                	sd	s3,24(sp)
 762:	0080                	addi	s0,sp,64
 764:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 766:	c299                	beqz	a3,76c <printint+0x16>
 768:	0805c963          	bltz	a1,7fa <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 76c:	2581                	sext.w	a1,a1
  neg = 0;
 76e:	4881                	li	a7,0
 770:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 774:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 776:	2601                	sext.w	a2,a2
 778:	00000517          	auipc	a0,0x0
 77c:	4c050513          	addi	a0,a0,1216 # c38 <digits>
 780:	883a                	mv	a6,a4
 782:	2705                	addiw	a4,a4,1
 784:	02c5f7bb          	remuw	a5,a1,a2
 788:	1782                	slli	a5,a5,0x20
 78a:	9381                	srli	a5,a5,0x20
 78c:	97aa                	add	a5,a5,a0
 78e:	0007c783          	lbu	a5,0(a5)
 792:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 796:	0005879b          	sext.w	a5,a1
 79a:	02c5d5bb          	divuw	a1,a1,a2
 79e:	0685                	addi	a3,a3,1
 7a0:	fec7f0e3          	bgeu	a5,a2,780 <printint+0x2a>
  if(neg)
 7a4:	00088c63          	beqz	a7,7bc <printint+0x66>
    buf[i++] = '-';
 7a8:	fd070793          	addi	a5,a4,-48
 7ac:	00878733          	add	a4,a5,s0
 7b0:	02d00793          	li	a5,45
 7b4:	fef70823          	sb	a5,-16(a4)
 7b8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7bc:	02e05863          	blez	a4,7ec <printint+0x96>
 7c0:	fc040793          	addi	a5,s0,-64
 7c4:	00e78933          	add	s2,a5,a4
 7c8:	fff78993          	addi	s3,a5,-1
 7cc:	99ba                	add	s3,s3,a4
 7ce:	377d                	addiw	a4,a4,-1
 7d0:	1702                	slli	a4,a4,0x20
 7d2:	9301                	srli	a4,a4,0x20
 7d4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7d8:	fff94583          	lbu	a1,-1(s2)
 7dc:	8526                	mv	a0,s1
 7de:	00000097          	auipc	ra,0x0
 7e2:	f56080e7          	jalr	-170(ra) # 734 <putc>
  while(--i >= 0)
 7e6:	197d                	addi	s2,s2,-1
 7e8:	ff3918e3          	bne	s2,s3,7d8 <printint+0x82>
}
 7ec:	70e2                	ld	ra,56(sp)
 7ee:	7442                	ld	s0,48(sp)
 7f0:	74a2                	ld	s1,40(sp)
 7f2:	7902                	ld	s2,32(sp)
 7f4:	69e2                	ld	s3,24(sp)
 7f6:	6121                	addi	sp,sp,64
 7f8:	8082                	ret
    x = -xx;
 7fa:	40b005bb          	negw	a1,a1
    neg = 1;
 7fe:	4885                	li	a7,1
    x = -xx;
 800:	bf85                	j	770 <printint+0x1a>

0000000000000802 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 802:	715d                	addi	sp,sp,-80
 804:	e486                	sd	ra,72(sp)
 806:	e0a2                	sd	s0,64(sp)
 808:	fc26                	sd	s1,56(sp)
 80a:	f84a                	sd	s2,48(sp)
 80c:	f44e                	sd	s3,40(sp)
 80e:	f052                	sd	s4,32(sp)
 810:	ec56                	sd	s5,24(sp)
 812:	e85a                	sd	s6,16(sp)
 814:	e45e                	sd	s7,8(sp)
 816:	e062                	sd	s8,0(sp)
 818:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 81a:	0005c903          	lbu	s2,0(a1)
 81e:	18090c63          	beqz	s2,9b6 <vprintf+0x1b4>
 822:	8aaa                	mv	s5,a0
 824:	8bb2                	mv	s7,a2
 826:	00158493          	addi	s1,a1,1
  state = 0;
 82a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 82c:	02500a13          	li	s4,37
 830:	4b55                	li	s6,21
 832:	a839                	j	850 <vprintf+0x4e>
        putc(fd, c);
 834:	85ca                	mv	a1,s2
 836:	8556                	mv	a0,s5
 838:	00000097          	auipc	ra,0x0
 83c:	efc080e7          	jalr	-260(ra) # 734 <putc>
 840:	a019                	j	846 <vprintf+0x44>
    } else if(state == '%'){
 842:	01498d63          	beq	s3,s4,85c <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 846:	0485                	addi	s1,s1,1
 848:	fff4c903          	lbu	s2,-1(s1)
 84c:	16090563          	beqz	s2,9b6 <vprintf+0x1b4>
    if(state == 0){
 850:	fe0999e3          	bnez	s3,842 <vprintf+0x40>
      if(c == '%'){
 854:	ff4910e3          	bne	s2,s4,834 <vprintf+0x32>
        state = '%';
 858:	89d2                	mv	s3,s4
 85a:	b7f5                	j	846 <vprintf+0x44>
      if(c == 'd'){
 85c:	13490263          	beq	s2,s4,980 <vprintf+0x17e>
 860:	f9d9079b          	addiw	a5,s2,-99
 864:	0ff7f793          	zext.b	a5,a5
 868:	12fb6563          	bltu	s6,a5,992 <vprintf+0x190>
 86c:	f9d9079b          	addiw	a5,s2,-99
 870:	0ff7f713          	zext.b	a4,a5
 874:	10eb6f63          	bltu	s6,a4,992 <vprintf+0x190>
 878:	00271793          	slli	a5,a4,0x2
 87c:	00000717          	auipc	a4,0x0
 880:	36470713          	addi	a4,a4,868 # be0 <malloc+0x12c>
 884:	97ba                	add	a5,a5,a4
 886:	439c                	lw	a5,0(a5)
 888:	97ba                	add	a5,a5,a4
 88a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 88c:	008b8913          	addi	s2,s7,8
 890:	4685                	li	a3,1
 892:	4629                	li	a2,10
 894:	000ba583          	lw	a1,0(s7)
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	ebc080e7          	jalr	-324(ra) # 756 <printint>
 8a2:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b745                	j	846 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a8:	008b8913          	addi	s2,s7,8
 8ac:	4681                	li	a3,0
 8ae:	4629                	li	a2,10
 8b0:	000ba583          	lw	a1,0(s7)
 8b4:	8556                	mv	a0,s5
 8b6:	00000097          	auipc	ra,0x0
 8ba:	ea0080e7          	jalr	-352(ra) # 756 <printint>
 8be:	8bca                	mv	s7,s2
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	b751                	j	846 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 8c4:	008b8913          	addi	s2,s7,8
 8c8:	4681                	li	a3,0
 8ca:	4641                	li	a2,16
 8cc:	000ba583          	lw	a1,0(s7)
 8d0:	8556                	mv	a0,s5
 8d2:	00000097          	auipc	ra,0x0
 8d6:	e84080e7          	jalr	-380(ra) # 756 <printint>
 8da:	8bca                	mv	s7,s2
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	b7a5                	j	846 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 8e0:	008b8c13          	addi	s8,s7,8
 8e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8e8:	03000593          	li	a1,48
 8ec:	8556                	mv	a0,s5
 8ee:	00000097          	auipc	ra,0x0
 8f2:	e46080e7          	jalr	-442(ra) # 734 <putc>
  putc(fd, 'x');
 8f6:	07800593          	li	a1,120
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	e38080e7          	jalr	-456(ra) # 734 <putc>
 904:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 906:	00000b97          	auipc	s7,0x0
 90a:	332b8b93          	addi	s7,s7,818 # c38 <digits>
 90e:	03c9d793          	srli	a5,s3,0x3c
 912:	97de                	add	a5,a5,s7
 914:	0007c583          	lbu	a1,0(a5)
 918:	8556                	mv	a0,s5
 91a:	00000097          	auipc	ra,0x0
 91e:	e1a080e7          	jalr	-486(ra) # 734 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 922:	0992                	slli	s3,s3,0x4
 924:	397d                	addiw	s2,s2,-1
 926:	fe0914e3          	bnez	s2,90e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 92a:	8be2                	mv	s7,s8
      state = 0;
 92c:	4981                	li	s3,0
 92e:	bf21                	j	846 <vprintf+0x44>
        s = va_arg(ap, char*);
 930:	008b8993          	addi	s3,s7,8
 934:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 938:	02090163          	beqz	s2,95a <vprintf+0x158>
        while(*s != 0){
 93c:	00094583          	lbu	a1,0(s2)
 940:	c9a5                	beqz	a1,9b0 <vprintf+0x1ae>
          putc(fd, *s);
 942:	8556                	mv	a0,s5
 944:	00000097          	auipc	ra,0x0
 948:	df0080e7          	jalr	-528(ra) # 734 <putc>
          s++;
 94c:	0905                	addi	s2,s2,1
        while(*s != 0){
 94e:	00094583          	lbu	a1,0(s2)
 952:	f9e5                	bnez	a1,942 <vprintf+0x140>
        s = va_arg(ap, char*);
 954:	8bce                	mv	s7,s3
      state = 0;
 956:	4981                	li	s3,0
 958:	b5fd                	j	846 <vprintf+0x44>
          s = "(null)";
 95a:	00000917          	auipc	s2,0x0
 95e:	27e90913          	addi	s2,s2,638 # bd8 <malloc+0x124>
        while(*s != 0){
 962:	02800593          	li	a1,40
 966:	bff1                	j	942 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 968:	008b8913          	addi	s2,s7,8
 96c:	000bc583          	lbu	a1,0(s7)
 970:	8556                	mv	a0,s5
 972:	00000097          	auipc	ra,0x0
 976:	dc2080e7          	jalr	-574(ra) # 734 <putc>
 97a:	8bca                	mv	s7,s2
      state = 0;
 97c:	4981                	li	s3,0
 97e:	b5e1                	j	846 <vprintf+0x44>
        putc(fd, c);
 980:	02500593          	li	a1,37
 984:	8556                	mv	a0,s5
 986:	00000097          	auipc	ra,0x0
 98a:	dae080e7          	jalr	-594(ra) # 734 <putc>
      state = 0;
 98e:	4981                	li	s3,0
 990:	bd5d                	j	846 <vprintf+0x44>
        putc(fd, '%');
 992:	02500593          	li	a1,37
 996:	8556                	mv	a0,s5
 998:	00000097          	auipc	ra,0x0
 99c:	d9c080e7          	jalr	-612(ra) # 734 <putc>
        putc(fd, c);
 9a0:	85ca                	mv	a1,s2
 9a2:	8556                	mv	a0,s5
 9a4:	00000097          	auipc	ra,0x0
 9a8:	d90080e7          	jalr	-624(ra) # 734 <putc>
      state = 0;
 9ac:	4981                	li	s3,0
 9ae:	bd61                	j	846 <vprintf+0x44>
        s = va_arg(ap, char*);
 9b0:	8bce                	mv	s7,s3
      state = 0;
 9b2:	4981                	li	s3,0
 9b4:	bd49                	j	846 <vprintf+0x44>
    }
  }
}
 9b6:	60a6                	ld	ra,72(sp)
 9b8:	6406                	ld	s0,64(sp)
 9ba:	74e2                	ld	s1,56(sp)
 9bc:	7942                	ld	s2,48(sp)
 9be:	79a2                	ld	s3,40(sp)
 9c0:	7a02                	ld	s4,32(sp)
 9c2:	6ae2                	ld	s5,24(sp)
 9c4:	6b42                	ld	s6,16(sp)
 9c6:	6ba2                	ld	s7,8(sp)
 9c8:	6c02                	ld	s8,0(sp)
 9ca:	6161                	addi	sp,sp,80
 9cc:	8082                	ret

00000000000009ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9ce:	715d                	addi	sp,sp,-80
 9d0:	ec06                	sd	ra,24(sp)
 9d2:	e822                	sd	s0,16(sp)
 9d4:	1000                	addi	s0,sp,32
 9d6:	e010                	sd	a2,0(s0)
 9d8:	e414                	sd	a3,8(s0)
 9da:	e818                	sd	a4,16(s0)
 9dc:	ec1c                	sd	a5,24(s0)
 9de:	03043023          	sd	a6,32(s0)
 9e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ea:	8622                	mv	a2,s0
 9ec:	00000097          	auipc	ra,0x0
 9f0:	e16080e7          	jalr	-490(ra) # 802 <vprintf>
}
 9f4:	60e2                	ld	ra,24(sp)
 9f6:	6442                	ld	s0,16(sp)
 9f8:	6161                	addi	sp,sp,80
 9fa:	8082                	ret

00000000000009fc <printf>:

void
printf(const char *fmt, ...)
{
 9fc:	711d                	addi	sp,sp,-96
 9fe:	ec06                	sd	ra,24(sp)
 a00:	e822                	sd	s0,16(sp)
 a02:	1000                	addi	s0,sp,32
 a04:	e40c                	sd	a1,8(s0)
 a06:	e810                	sd	a2,16(s0)
 a08:	ec14                	sd	a3,24(s0)
 a0a:	f018                	sd	a4,32(s0)
 a0c:	f41c                	sd	a5,40(s0)
 a0e:	03043823          	sd	a6,48(s0)
 a12:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a16:	00840613          	addi	a2,s0,8
 a1a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a1e:	85aa                	mv	a1,a0
 a20:	4505                	li	a0,1
 a22:	00000097          	auipc	ra,0x0
 a26:	de0080e7          	jalr	-544(ra) # 802 <vprintf>
}
 a2a:	60e2                	ld	ra,24(sp)
 a2c:	6442                	ld	s0,16(sp)
 a2e:	6125                	addi	sp,sp,96
 a30:	8082                	ret

0000000000000a32 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a32:	1141                	addi	sp,sp,-16
 a34:	e422                	sd	s0,8(sp)
 a36:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a38:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a3c:	00000797          	auipc	a5,0x0
 a40:	5c47b783          	ld	a5,1476(a5) # 1000 <freep>
 a44:	a02d                	j	a6e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a46:	4618                	lw	a4,8(a2)
 a48:	9f2d                	addw	a4,a4,a1
 a4a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a4e:	6398                	ld	a4,0(a5)
 a50:	6310                	ld	a2,0(a4)
 a52:	a83d                	j	a90 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a54:	ff852703          	lw	a4,-8(a0)
 a58:	9f31                	addw	a4,a4,a2
 a5a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a5c:	ff053683          	ld	a3,-16(a0)
 a60:	a091                	j	aa4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a62:	6398                	ld	a4,0(a5)
 a64:	00e7e463          	bltu	a5,a4,a6c <free+0x3a>
 a68:	00e6ea63          	bltu	a3,a4,a7c <free+0x4a>
{
 a6c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a6e:	fed7fae3          	bgeu	a5,a3,a62 <free+0x30>
 a72:	6398                	ld	a4,0(a5)
 a74:	00e6e463          	bltu	a3,a4,a7c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a78:	fee7eae3          	bltu	a5,a4,a6c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a7c:	ff852583          	lw	a1,-8(a0)
 a80:	6390                	ld	a2,0(a5)
 a82:	02059813          	slli	a6,a1,0x20
 a86:	01c85713          	srli	a4,a6,0x1c
 a8a:	9736                	add	a4,a4,a3
 a8c:	fae60de3          	beq	a2,a4,a46 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a90:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a94:	4790                	lw	a2,8(a5)
 a96:	02061593          	slli	a1,a2,0x20
 a9a:	01c5d713          	srli	a4,a1,0x1c
 a9e:	973e                	add	a4,a4,a5
 aa0:	fae68ae3          	beq	a3,a4,a54 <free+0x22>
    p->s.ptr = bp->s.ptr;
 aa4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 aa6:	00000717          	auipc	a4,0x0
 aaa:	54f73d23          	sd	a5,1370(a4) # 1000 <freep>
}
 aae:	6422                	ld	s0,8(sp)
 ab0:	0141                	addi	sp,sp,16
 ab2:	8082                	ret

0000000000000ab4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ab4:	7139                	addi	sp,sp,-64
 ab6:	fc06                	sd	ra,56(sp)
 ab8:	f822                	sd	s0,48(sp)
 aba:	f426                	sd	s1,40(sp)
 abc:	f04a                	sd	s2,32(sp)
 abe:	ec4e                	sd	s3,24(sp)
 ac0:	e852                	sd	s4,16(sp)
 ac2:	e456                	sd	s5,8(sp)
 ac4:	e05a                	sd	s6,0(sp)
 ac6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ac8:	02051493          	slli	s1,a0,0x20
 acc:	9081                	srli	s1,s1,0x20
 ace:	04bd                	addi	s1,s1,15
 ad0:	8091                	srli	s1,s1,0x4
 ad2:	0014899b          	addiw	s3,s1,1
 ad6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ad8:	00000517          	auipc	a0,0x0
 adc:	52853503          	ld	a0,1320(a0) # 1000 <freep>
 ae0:	c515                	beqz	a0,b0c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae4:	4798                	lw	a4,8(a5)
 ae6:	02977f63          	bgeu	a4,s1,b24 <malloc+0x70>
  if(nu < 4096)
 aea:	8a4e                	mv	s4,s3
 aec:	0009871b          	sext.w	a4,s3
 af0:	6685                	lui	a3,0x1
 af2:	00d77363          	bgeu	a4,a3,af8 <malloc+0x44>
 af6:	6a05                	lui	s4,0x1
 af8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 afc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b00:	00000917          	auipc	s2,0x0
 b04:	50090913          	addi	s2,s2,1280 # 1000 <freep>
  if(p == (char*)-1)
 b08:	5afd                	li	s5,-1
 b0a:	a895                	j	b7e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b0c:	00001797          	auipc	a5,0x1
 b10:	90478793          	addi	a5,a5,-1788 # 1410 <base>
 b14:	00000717          	auipc	a4,0x0
 b18:	4ef73623          	sd	a5,1260(a4) # 1000 <freep>
 b1c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b1e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b22:	b7e1                	j	aea <malloc+0x36>
      if(p->s.size == nunits)
 b24:	02e48c63          	beq	s1,a4,b5c <malloc+0xa8>
        p->s.size -= nunits;
 b28:	4137073b          	subw	a4,a4,s3
 b2c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b2e:	02071693          	slli	a3,a4,0x20
 b32:	01c6d713          	srli	a4,a3,0x1c
 b36:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b38:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b3c:	00000717          	auipc	a4,0x0
 b40:	4ca73223          	sd	a0,1220(a4) # 1000 <freep>
      return (void*)(p + 1);
 b44:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b48:	70e2                	ld	ra,56(sp)
 b4a:	7442                	ld	s0,48(sp)
 b4c:	74a2                	ld	s1,40(sp)
 b4e:	7902                	ld	s2,32(sp)
 b50:	69e2                	ld	s3,24(sp)
 b52:	6a42                	ld	s4,16(sp)
 b54:	6aa2                	ld	s5,8(sp)
 b56:	6b02                	ld	s6,0(sp)
 b58:	6121                	addi	sp,sp,64
 b5a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b5c:	6398                	ld	a4,0(a5)
 b5e:	e118                	sd	a4,0(a0)
 b60:	bff1                	j	b3c <malloc+0x88>
  hp->s.size = nu;
 b62:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b66:	0541                	addi	a0,a0,16
 b68:	00000097          	auipc	ra,0x0
 b6c:	eca080e7          	jalr	-310(ra) # a32 <free>
  return freep;
 b70:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b74:	d971                	beqz	a0,b48 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b78:	4798                	lw	a4,8(a5)
 b7a:	fa9775e3          	bgeu	a4,s1,b24 <malloc+0x70>
    if(p == freep)
 b7e:	00093703          	ld	a4,0(s2)
 b82:	853e                	mv	a0,a5
 b84:	fef719e3          	bne	a4,a5,b76 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 b88:	8552                	mv	a0,s4
 b8a:	00000097          	auipc	ra,0x0
 b8e:	b62080e7          	jalr	-1182(ra) # 6ec <sbrk>
  if(p == (char*)-1)
 b92:	fd5518e3          	bne	a0,s5,b62 <malloc+0xae>
        return 0;
 b96:	4501                	li	a0,0
 b98:	bf45                	j	b48 <malloc+0x94>
