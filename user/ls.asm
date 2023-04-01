
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	324080e7          	jalr	804(ra) # 334 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2f8080e7          	jalr	760(ra) # 334 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2d6080e7          	jalr	726(ra) # 334 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	addi	s3,s3,-86 # 1010 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	564080e7          	jalr	1380(ra) # 5da <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2b4080e7          	jalr	692(ra) # 334 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2a6080e7          	jalr	678(ra) # 334 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2b6080e7          	jalr	694(ra) # 35e <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	5f2080e7          	jalr	1522(ra) # 6cc <open>
  e2:	06054f63          	bltz	a0,160 <ls+0xac>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	5f8080e7          	jalr	1528(ra) # 6e4 <fstat>
  f4:	08054163          	bltz	a0,176 <ls+0xc2>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	4705                	li	a4,1
  fe:	08e78c63          	beq	a5,a4,196 <ls+0xe2>
 102:	37f9                	addiw	a5,a5,-2
 104:	17c2                	slli	a5,a5,0x30
 106:	93c1                	srli	a5,a5,0x30
 108:	02f76663          	bltu	a4,a5,134 <ls+0x80>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 10c:	854a                	mv	a0,s2
 10e:	00000097          	auipc	ra,0x0
 112:	ef2080e7          	jalr	-270(ra) # 0 <fmtname>
 116:	85aa                	mv	a1,a0
 118:	da843703          	ld	a4,-600(s0)
 11c:	d9c42683          	lw	a3,-612(s0)
 120:	da041603          	lh	a2,-608(s0)
 124:	00001517          	auipc	a0,0x1
 128:	adc50513          	addi	a0,a0,-1316 # c00 <malloc+0x124>
 12c:	00001097          	auipc	ra,0x1
 130:	8f8080e7          	jalr	-1800(ra) # a24 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 134:	8526                	mv	a0,s1
 136:	00000097          	auipc	ra,0x0
 13a:	57e080e7          	jalr	1406(ra) # 6b4 <close>
}
 13e:	26813083          	ld	ra,616(sp)
 142:	26013403          	ld	s0,608(sp)
 146:	25813483          	ld	s1,600(sp)
 14a:	25013903          	ld	s2,592(sp)
 14e:	24813983          	ld	s3,584(sp)
 152:	24013a03          	ld	s4,576(sp)
 156:	23813a83          	ld	s5,568(sp)
 15a:	27010113          	addi	sp,sp,624
 15e:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 160:	864a                	mv	a2,s2
 162:	00001597          	auipc	a1,0x1
 166:	a6e58593          	addi	a1,a1,-1426 # bd0 <malloc+0xf4>
 16a:	4509                	li	a0,2
 16c:	00001097          	auipc	ra,0x1
 170:	88a080e7          	jalr	-1910(ra) # 9f6 <fprintf>
    return;
 174:	b7e9                	j	13e <ls+0x8a>
    fprintf(2, "ls: cannot stat %s\n", path);
 176:	864a                	mv	a2,s2
 178:	00001597          	auipc	a1,0x1
 17c:	a7058593          	addi	a1,a1,-1424 # be8 <malloc+0x10c>
 180:	4509                	li	a0,2
 182:	00001097          	auipc	ra,0x1
 186:	874080e7          	jalr	-1932(ra) # 9f6 <fprintf>
    close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	528080e7          	jalr	1320(ra) # 6b4 <close>
    return;
 194:	b76d                	j	13e <ls+0x8a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 196:	854a                	mv	a0,s2
 198:	00000097          	auipc	ra,0x0
 19c:	19c080e7          	jalr	412(ra) # 334 <strlen>
 1a0:	2541                	addiw	a0,a0,16
 1a2:	20000793          	li	a5,512
 1a6:	00a7fb63          	bgeu	a5,a0,1bc <ls+0x108>
      printf("ls: path too long\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	a6650513          	addi	a0,a0,-1434 # c10 <malloc+0x134>
 1b2:	00001097          	auipc	ra,0x1
 1b6:	872080e7          	jalr	-1934(ra) # a24 <printf>
      break;
 1ba:	bfad                	j	134 <ls+0x80>
    strcpy(buf, path);
 1bc:	85ca                	mv	a1,s2
 1be:	dc040513          	addi	a0,s0,-576
 1c2:	00000097          	auipc	ra,0x0
 1c6:	12a080e7          	jalr	298(ra) # 2ec <strcpy>
    p = buf+strlen(buf);
 1ca:	dc040513          	addi	a0,s0,-576
 1ce:	00000097          	auipc	ra,0x0
 1d2:	166080e7          	jalr	358(ra) # 334 <strlen>
 1d6:	1502                	slli	a0,a0,0x20
 1d8:	9101                	srli	a0,a0,0x20
 1da:	dc040793          	addi	a5,s0,-576
 1de:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 1e2:	00190993          	addi	s3,s2,1
 1e6:	02f00793          	li	a5,47
 1ea:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1ee:	00001a17          	auipc	s4,0x1
 1f2:	a3aa0a13          	addi	s4,s4,-1478 # c28 <malloc+0x14c>
        printf("ls: cannot stat %s\n", buf);
 1f6:	00001a97          	auipc	s5,0x1
 1fa:	9f2a8a93          	addi	s5,s5,-1550 # be8 <malloc+0x10c>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1fe:	a801                	j	20e <ls+0x15a>
        printf("ls: cannot stat %s\n", buf);
 200:	dc040593          	addi	a1,s0,-576
 204:	8556                	mv	a0,s5
 206:	00001097          	auipc	ra,0x1
 20a:	81e080e7          	jalr	-2018(ra) # a24 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 20e:	4641                	li	a2,16
 210:	db040593          	addi	a1,s0,-592
 214:	8526                	mv	a0,s1
 216:	00000097          	auipc	ra,0x0
 21a:	48e080e7          	jalr	1166(ra) # 6a4 <read>
 21e:	47c1                	li	a5,16
 220:	f0f51ae3          	bne	a0,a5,134 <ls+0x80>
      if(de.inum == 0)
 224:	db045783          	lhu	a5,-592(s0)
 228:	d3fd                	beqz	a5,20e <ls+0x15a>
      memmove(p, de.name, DIRSIZ);
 22a:	4639                	li	a2,14
 22c:	db240593          	addi	a1,s0,-590
 230:	854e                	mv	a0,s3
 232:	00000097          	auipc	ra,0x0
 236:	3a8080e7          	jalr	936(ra) # 5da <memmove>
      p[DIRSIZ] = 0;
 23a:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 23e:	d9840593          	addi	a1,s0,-616
 242:	dc040513          	addi	a0,s0,-576
 246:	00000097          	auipc	ra,0x0
 24a:	1d2080e7          	jalr	466(ra) # 418 <stat>
 24e:	fa0549e3          	bltz	a0,200 <ls+0x14c>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 252:	dc040513          	addi	a0,s0,-576
 256:	00000097          	auipc	ra,0x0
 25a:	daa080e7          	jalr	-598(ra) # 0 <fmtname>
 25e:	85aa                	mv	a1,a0
 260:	da843703          	ld	a4,-600(s0)
 264:	d9c42683          	lw	a3,-612(s0)
 268:	da041603          	lh	a2,-608(s0)
 26c:	8552                	mv	a0,s4
 26e:	00000097          	auipc	ra,0x0
 272:	7b6080e7          	jalr	1974(ra) # a24 <printf>
 276:	bf61                	j	20e <ls+0x15a>

0000000000000278 <main>:

int
main(int argc, char *argv[])
{
 278:	1101                	addi	sp,sp,-32
 27a:	ec06                	sd	ra,24(sp)
 27c:	e822                	sd	s0,16(sp)
 27e:	e426                	sd	s1,8(sp)
 280:	e04a                	sd	s2,0(sp)
 282:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 284:	4785                	li	a5,1
 286:	02a7d963          	bge	a5,a0,2b8 <main+0x40>
 28a:	00858493          	addi	s1,a1,8
 28e:	ffe5091b          	addiw	s2,a0,-2
 292:	02091793          	slli	a5,s2,0x20
 296:	01d7d913          	srli	s2,a5,0x1d
 29a:	05c1                	addi	a1,a1,16
 29c:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 29e:	6088                	ld	a0,0(s1)
 2a0:	00000097          	auipc	ra,0x0
 2a4:	e14080e7          	jalr	-492(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2a8:	04a1                	addi	s1,s1,8
 2aa:	ff249ae3          	bne	s1,s2,29e <main+0x26>
  exit(0);
 2ae:	4501                	li	a0,0
 2b0:	00000097          	auipc	ra,0x0
 2b4:	3dc080e7          	jalr	988(ra) # 68c <exit>
    ls(".");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	98050513          	addi	a0,a0,-1664 # c38 <malloc+0x15c>
 2c0:	00000097          	auipc	ra,0x0
 2c4:	df4080e7          	jalr	-524(ra) # b4 <ls>
    exit(0);
 2c8:	4501                	li	a0,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	3c2080e7          	jalr	962(ra) # 68c <exit>

00000000000002d2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2da:	00000097          	auipc	ra,0x0
 2de:	f9e080e7          	jalr	-98(ra) # 278 <main>
  exit(0);
 2e2:	4501                	li	a0,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	3a8080e7          	jalr	936(ra) # 68c <exit>

00000000000002ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f2:	87aa                	mv	a5,a0
 2f4:	0585                	addi	a1,a1,1
 2f6:	0785                	addi	a5,a5,1
 2f8:	fff5c703          	lbu	a4,-1(a1)
 2fc:	fee78fa3          	sb	a4,-1(a5)
 300:	fb75                	bnez	a4,2f4 <strcpy+0x8>
    ;
  return os;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 30e:	00054783          	lbu	a5,0(a0)
 312:	cb91                	beqz	a5,326 <strcmp+0x1e>
 314:	0005c703          	lbu	a4,0(a1)
 318:	00f71763          	bne	a4,a5,326 <strcmp+0x1e>
    p++, q++;
 31c:	0505                	addi	a0,a0,1
 31e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 320:	00054783          	lbu	a5,0(a0)
 324:	fbe5                	bnez	a5,314 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 326:	0005c503          	lbu	a0,0(a1)
}
 32a:	40a7853b          	subw	a0,a5,a0
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <strlen>:

uint
strlen(const char *s)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 33a:	00054783          	lbu	a5,0(a0)
 33e:	cf91                	beqz	a5,35a <strlen+0x26>
 340:	0505                	addi	a0,a0,1
 342:	87aa                	mv	a5,a0
 344:	86be                	mv	a3,a5
 346:	0785                	addi	a5,a5,1
 348:	fff7c703          	lbu	a4,-1(a5)
 34c:	ff65                	bnez	a4,344 <strlen+0x10>
 34e:	40a6853b          	subw	a0,a3,a0
 352:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  for(n = 0; s[n]; n++)
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <strlen+0x20>

000000000000035e <memset>:

void*
memset(void *dst, int c, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 364:	ca19                	beqz	a2,37a <memset+0x1c>
 366:	87aa                	mv	a5,a0
 368:	1602                	slli	a2,a2,0x20
 36a:	9201                	srli	a2,a2,0x20
 36c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 370:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 374:	0785                	addi	a5,a5,1
 376:	fee79de3          	bne	a5,a4,370 <memset+0x12>
  }
  return dst;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <strchr>:

char*
strchr(const char *s, char c)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  for(; *s; s++)
 386:	00054783          	lbu	a5,0(a0)
 38a:	cb99                	beqz	a5,3a0 <strchr+0x20>
    if(*s == c)
 38c:	00f58763          	beq	a1,a5,39a <strchr+0x1a>
  for(; *s; s++)
 390:	0505                	addi	a0,a0,1
 392:	00054783          	lbu	a5,0(a0)
 396:	fbfd                	bnez	a5,38c <strchr+0xc>
      return (char*)s;
  return 0;
 398:	4501                	li	a0,0
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <strchr+0x1a>

00000000000003a4 <gets>:

char*
gets(char *buf, int max)
{
 3a4:	711d                	addi	sp,sp,-96
 3a6:	ec86                	sd	ra,88(sp)
 3a8:	e8a2                	sd	s0,80(sp)
 3aa:	e4a6                	sd	s1,72(sp)
 3ac:	e0ca                	sd	s2,64(sp)
 3ae:	fc4e                	sd	s3,56(sp)
 3b0:	f852                	sd	s4,48(sp)
 3b2:	f456                	sd	s5,40(sp)
 3b4:	f05a                	sd	s6,32(sp)
 3b6:	ec5e                	sd	s7,24(sp)
 3b8:	1080                	addi	s0,sp,96
 3ba:	8baa                	mv	s7,a0
 3bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3be:	892a                	mv	s2,a0
 3c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c2:	4aa9                	li	s5,10
 3c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3c6:	89a6                	mv	s3,s1
 3c8:	2485                	addiw	s1,s1,1
 3ca:	0344d863          	bge	s1,s4,3fa <gets+0x56>
    cc = read(0, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	faf40593          	addi	a1,s0,-81
 3d4:	4501                	li	a0,0
 3d6:	00000097          	auipc	ra,0x0
 3da:	2ce080e7          	jalr	718(ra) # 6a4 <read>
    if(cc < 1)
 3de:	00a05e63          	blez	a0,3fa <gets+0x56>
    buf[i++] = c;
 3e2:	faf44783          	lbu	a5,-81(s0)
 3e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3ea:	01578763          	beq	a5,s5,3f8 <gets+0x54>
 3ee:	0905                	addi	s2,s2,1
 3f0:	fd679be3          	bne	a5,s6,3c6 <gets+0x22>
  for(i=0; i+1 < max; ){
 3f4:	89a6                	mv	s3,s1
 3f6:	a011                	j	3fa <gets+0x56>
 3f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3fa:	99de                	add	s3,s3,s7
 3fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 400:	855e                	mv	a0,s7
 402:	60e6                	ld	ra,88(sp)
 404:	6446                	ld	s0,80(sp)
 406:	64a6                	ld	s1,72(sp)
 408:	6906                	ld	s2,64(sp)
 40a:	79e2                	ld	s3,56(sp)
 40c:	7a42                	ld	s4,48(sp)
 40e:	7aa2                	ld	s5,40(sp)
 410:	7b02                	ld	s6,32(sp)
 412:	6be2                	ld	s7,24(sp)
 414:	6125                	addi	sp,sp,96
 416:	8082                	ret

0000000000000418 <stat>:

int
stat(const char *n, struct stat *st)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	e426                	sd	s1,8(sp)
 420:	e04a                	sd	s2,0(sp)
 422:	1000                	addi	s0,sp,32
 424:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 426:	4581                	li	a1,0
 428:	00000097          	auipc	ra,0x0
 42c:	2a4080e7          	jalr	676(ra) # 6cc <open>
  if(fd < 0)
 430:	02054563          	bltz	a0,45a <stat+0x42>
 434:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 436:	85ca                	mv	a1,s2
 438:	00000097          	auipc	ra,0x0
 43c:	2ac080e7          	jalr	684(ra) # 6e4 <fstat>
 440:	892a                	mv	s2,a0
  close(fd);
 442:	8526                	mv	a0,s1
 444:	00000097          	auipc	ra,0x0
 448:	270080e7          	jalr	624(ra) # 6b4 <close>
  return r;
}
 44c:	854a                	mv	a0,s2
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	64a2                	ld	s1,8(sp)
 454:	6902                	ld	s2,0(sp)
 456:	6105                	addi	sp,sp,32
 458:	8082                	ret
    return -1;
 45a:	597d                	li	s2,-1
 45c:	bfc5                	j	44c <stat+0x34>

000000000000045e <atoi>:

int
atoi(const char *s)
{
 45e:	1141                	addi	sp,sp,-16
 460:	e422                	sd	s0,8(sp)
 462:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 464:	00054683          	lbu	a3,0(a0)
 468:	fd06879b          	addiw	a5,a3,-48
 46c:	0ff7f793          	zext.b	a5,a5
 470:	4625                	li	a2,9
 472:	02f66863          	bltu	a2,a5,4a2 <atoi+0x44>
 476:	872a                	mv	a4,a0
  n = 0;
 478:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 47a:	0705                	addi	a4,a4,1
 47c:	0025179b          	slliw	a5,a0,0x2
 480:	9fa9                	addw	a5,a5,a0
 482:	0017979b          	slliw	a5,a5,0x1
 486:	9fb5                	addw	a5,a5,a3
 488:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 48c:	00074683          	lbu	a3,0(a4)
 490:	fd06879b          	addiw	a5,a3,-48
 494:	0ff7f793          	zext.b	a5,a5
 498:	fef671e3          	bgeu	a2,a5,47a <atoi+0x1c>

  return n;
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  n = 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <atoi+0x3e>

00000000000004a6 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e422                	sd	s0,8(sp)
 4aa:	0800                	addi	s0,sp,16
 4ac:	8eaa                	mv	t4,a0
    register const char *s = strt;
 4ae:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 4b0:	02000693          	li	a3,32
        c = *s++;
 4b4:	883e                	mv	a6,a5
 4b6:	0785                	addi	a5,a5,1
 4b8:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 4bc:	fed70ce3          	beq	a4,a3,4b4 <strtoi+0xe>
        c = *s++;
 4c0:	2701                	sext.w	a4,a4

    if (c == '-') {
 4c2:	02d00693          	li	a3,45
 4c6:	04d70d63          	beq	a4,a3,520 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 4ca:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 4ce:	4f01                	li	t5,0
    } else if (c == '+')
 4d0:	04d70e63          	beq	a4,a3,52c <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 4d4:	fef67693          	andi	a3,a2,-17
 4d8:	ea99                	bnez	a3,4ee <strtoi+0x48>
 4da:	03000693          	li	a3,48
 4de:	04d70c63          	beq	a4,a3,536 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 4e2:	e611                	bnez	a2,4ee <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 4e4:	03000693          	li	a3,48
 4e8:	0cd70b63          	beq	a4,a3,5be <strtoi+0x118>
 4ec:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 4ee:	800008b7          	lui	a7,0x80000
 4f2:	fff8c893          	not	a7,a7
 4f6:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 4fa:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 4fe:	1882                	slli	a7,a7,0x20
 500:	0208d893          	srli	a7,a7,0x20
 504:	02c8d8b3          	divu	a7,a7,a2
 508:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 50c:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 510:	0ac75163          	bge	a4,a2,5b2 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 514:	4681                	li	a3,0
 516:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 518:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 51a:	2881                	sext.w	a7,a7
        else {
            any = 1;
 51c:	4f85                	li	t6,1
 51e:	a0a9                	j	568 <strtoi+0xc2>
        c = *s++;
 520:	0007c703          	lbu	a4,0(a5)
 524:	00280793          	addi	a5,a6,2
        neg = 1;
 528:	4f05                	li	t5,1
 52a:	b76d                	j	4d4 <strtoi+0x2e>
        c = *s++;
 52c:	0007c703          	lbu	a4,0(a5)
 530:	00280793          	addi	a5,a6,2
 534:	b745                	j	4d4 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 536:	0007c683          	lbu	a3,0(a5)
 53a:	0df6f693          	andi	a3,a3,223
 53e:	05800513          	li	a0,88
 542:	faa690e3          	bne	a3,a0,4e2 <strtoi+0x3c>
        c = s[1];
 546:	0017c703          	lbu	a4,1(a5)
        s += 2;
 54a:	0789                	addi	a5,a5,2
        base = 16;
 54c:	4641                	li	a2,16
 54e:	b745                	j	4ee <strtoi+0x48>
            any = -1;
 550:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 552:	00e2c463          	blt	t0,a4,55a <strtoi+0xb4>
 556:	a015                	j	57a <strtoi+0xd4>
            any = -1;
 558:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 55a:	0785                	addi	a5,a5,1
 55c:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 560:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 564:	02c75063          	bge	a4,a2,584 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 568:	fe06c8e3          	bltz	a3,558 <strtoi+0xb2>
 56c:	0005081b          	sext.w	a6,a0
            any = -1;
 570:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 572:	ff0e64e3          	bltu	t3,a6,55a <strtoi+0xb4>
 576:	fca88de3          	beq	a7,a0,550 <strtoi+0xaa>
            acc *= base;
 57a:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 57e:	9d39                	addw	a0,a0,a4
            any = 1;
 580:	86fe                	mv	a3,t6
 582:	bfe1                	j	55a <strtoi+0xb4>
        }
    }
    if (any < 0) {
 584:	0006cd63          	bltz	a3,59e <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 588:	000f0463          	beqz	t5,590 <strtoi+0xea>
        acc = -acc;
 58c:	40a0053b          	negw	a0,a0
    if (end != 0)
 590:	c581                	beqz	a1,598 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 592:	ee89                	bnez	a3,5ac <strtoi+0x106>
 594:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 598:	6422                	ld	s0,8(sp)
 59a:	0141                	addi	sp,sp,16
 59c:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 59e:	000f1d63          	bnez	t5,5b8 <strtoi+0x112>
 5a2:	80000537          	lui	a0,0x80000
 5a6:	fff54513          	not	a0,a0
    if (end != 0)
 5aa:	d5fd                	beqz	a1,598 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 5ac:	fff78e93          	addi	t4,a5,-1
 5b0:	b7d5                	j	594 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 5b2:	4681                	li	a3,0
 5b4:	4501                	li	a0,0
 5b6:	bfc9                	j	588 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 5b8:	80000537          	lui	a0,0x80000
 5bc:	b7fd                	j	5aa <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 5be:	80000e37          	lui	t3,0x80000
 5c2:	fffe4e13          	not	t3,t3
 5c6:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 5ca:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 5ce:	003e589b          	srliw	a7,t3,0x3
 5d2:	8e46                	mv	t3,a7
            c -= '0';
 5d4:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 5d6:	4621                	li	a2,8
 5d8:	bf35                	j	514 <strtoi+0x6e>

00000000000005da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5da:	1141                	addi	sp,sp,-16
 5dc:	e422                	sd	s0,8(sp)
 5de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5e0:	02b57463          	bgeu	a0,a1,608 <memmove+0x2e>
    while(n-- > 0)
 5e4:	00c05f63          	blez	a2,602 <memmove+0x28>
 5e8:	1602                	slli	a2,a2,0x20
 5ea:	9201                	srli	a2,a2,0x20
 5ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 5f2:	0585                	addi	a1,a1,1
 5f4:	0705                	addi	a4,a4,1
 5f6:	fff5c683          	lbu	a3,-1(a1)
 5fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5fe:	fee79ae3          	bne	a5,a4,5f2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 602:	6422                	ld	s0,8(sp)
 604:	0141                	addi	sp,sp,16
 606:	8082                	ret
    dst += n;
 608:	00c50733          	add	a4,a0,a2
    src += n;
 60c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 60e:	fec05ae3          	blez	a2,602 <memmove+0x28>
 612:	fff6079b          	addiw	a5,a2,-1
 616:	1782                	slli	a5,a5,0x20
 618:	9381                	srli	a5,a5,0x20
 61a:	fff7c793          	not	a5,a5
 61e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 620:	15fd                	addi	a1,a1,-1
 622:	177d                	addi	a4,a4,-1
 624:	0005c683          	lbu	a3,0(a1)
 628:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 62c:	fee79ae3          	bne	a5,a4,620 <memmove+0x46>
 630:	bfc9                	j	602 <memmove+0x28>

0000000000000632 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 632:	1141                	addi	sp,sp,-16
 634:	e422                	sd	s0,8(sp)
 636:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 638:	ca05                	beqz	a2,668 <memcmp+0x36>
 63a:	fff6069b          	addiw	a3,a2,-1
 63e:	1682                	slli	a3,a3,0x20
 640:	9281                	srli	a3,a3,0x20
 642:	0685                	addi	a3,a3,1
 644:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 646:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffefe0>
 64a:	0005c703          	lbu	a4,0(a1)
 64e:	00e79863          	bne	a5,a4,65e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 652:	0505                	addi	a0,a0,1
    p2++;
 654:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 656:	fed518e3          	bne	a0,a3,646 <memcmp+0x14>
  }
  return 0;
 65a:	4501                	li	a0,0
 65c:	a019                	j	662 <memcmp+0x30>
      return *p1 - *p2;
 65e:	40e7853b          	subw	a0,a5,a4
}
 662:	6422                	ld	s0,8(sp)
 664:	0141                	addi	sp,sp,16
 666:	8082                	ret
  return 0;
 668:	4501                	li	a0,0
 66a:	bfe5                	j	662 <memcmp+0x30>

000000000000066c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 66c:	1141                	addi	sp,sp,-16
 66e:	e406                	sd	ra,8(sp)
 670:	e022                	sd	s0,0(sp)
 672:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 674:	00000097          	auipc	ra,0x0
 678:	f66080e7          	jalr	-154(ra) # 5da <memmove>
}
 67c:	60a2                	ld	ra,8(sp)
 67e:	6402                	ld	s0,0(sp)
 680:	0141                	addi	sp,sp,16
 682:	8082                	ret

0000000000000684 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 684:	4885                	li	a7,1
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <exit>:
.global exit
exit:
 li a7, SYS_exit
 68c:	4889                	li	a7,2
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <wait>:
.global wait
wait:
 li a7, SYS_wait
 694:	488d                	li	a7,3
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 69c:	4891                	li	a7,4
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <read>:
.global read
read:
 li a7, SYS_read
 6a4:	4895                	li	a7,5
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <write>:
.global write
write:
 li a7, SYS_write
 6ac:	48c1                	li	a7,16
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <close>:
.global close
close:
 li a7, SYS_close
 6b4:	48d5                	li	a7,21
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 6bc:	4899                	li	a7,6
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6c4:	489d                	li	a7,7
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <open>:
.global open
open:
 li a7, SYS_open
 6cc:	48bd                	li	a7,15
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6d4:	48c5                	li	a7,17
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6dc:	48c9                	li	a7,18
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6e4:	48a1                	li	a7,8
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <link>:
.global link
link:
 li a7, SYS_link
 6ec:	48cd                	li	a7,19
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6f4:	48d1                	li	a7,20
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6fc:	48a5                	li	a7,9
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <dup>:
.global dup
dup:
 li a7, SYS_dup
 704:	48a9                	li	a7,10
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 70c:	48ad                	li	a7,11
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 714:	48b1                	li	a7,12
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 71c:	48b5                	li	a7,13
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 724:	48b9                	li	a7,14
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 72c:	48d9                	li	a7,22
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 734:	48dd                	li	a7,23
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 73c:	48e1                	li	a7,24
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 744:	48e5                	li	a7,25
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 74c:	48e9                	li	a7,26
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 754:	48ed                	li	a7,27
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 75c:	1101                	addi	sp,sp,-32
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 768:	4605                	li	a2,1
 76a:	fef40593          	addi	a1,s0,-17
 76e:	00000097          	auipc	ra,0x0
 772:	f3e080e7          	jalr	-194(ra) # 6ac <write>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6105                	addi	sp,sp,32
 77c:	8082                	ret

000000000000077e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 77e:	7139                	addi	sp,sp,-64
 780:	fc06                	sd	ra,56(sp)
 782:	f822                	sd	s0,48(sp)
 784:	f426                	sd	s1,40(sp)
 786:	f04a                	sd	s2,32(sp)
 788:	ec4e                	sd	s3,24(sp)
 78a:	0080                	addi	s0,sp,64
 78c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 78e:	c299                	beqz	a3,794 <printint+0x16>
 790:	0805c963          	bltz	a1,822 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 794:	2581                	sext.w	a1,a1
  neg = 0;
 796:	4881                	li	a7,0
 798:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 79c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 79e:	2601                	sext.w	a2,a2
 7a0:	00000517          	auipc	a0,0x0
 7a4:	50050513          	addi	a0,a0,1280 # ca0 <digits>
 7a8:	883a                	mv	a6,a4
 7aa:	2705                	addiw	a4,a4,1
 7ac:	02c5f7bb          	remuw	a5,a1,a2
 7b0:	1782                	slli	a5,a5,0x20
 7b2:	9381                	srli	a5,a5,0x20
 7b4:	97aa                	add	a5,a5,a0
 7b6:	0007c783          	lbu	a5,0(a5)
 7ba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7be:	0005879b          	sext.w	a5,a1
 7c2:	02c5d5bb          	divuw	a1,a1,a2
 7c6:	0685                	addi	a3,a3,1
 7c8:	fec7f0e3          	bgeu	a5,a2,7a8 <printint+0x2a>
  if(neg)
 7cc:	00088c63          	beqz	a7,7e4 <printint+0x66>
    buf[i++] = '-';
 7d0:	fd070793          	addi	a5,a4,-48
 7d4:	00878733          	add	a4,a5,s0
 7d8:	02d00793          	li	a5,45
 7dc:	fef70823          	sb	a5,-16(a4)
 7e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7e4:	02e05863          	blez	a4,814 <printint+0x96>
 7e8:	fc040793          	addi	a5,s0,-64
 7ec:	00e78933          	add	s2,a5,a4
 7f0:	fff78993          	addi	s3,a5,-1
 7f4:	99ba                	add	s3,s3,a4
 7f6:	377d                	addiw	a4,a4,-1
 7f8:	1702                	slli	a4,a4,0x20
 7fa:	9301                	srli	a4,a4,0x20
 7fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 800:	fff94583          	lbu	a1,-1(s2)
 804:	8526                	mv	a0,s1
 806:	00000097          	auipc	ra,0x0
 80a:	f56080e7          	jalr	-170(ra) # 75c <putc>
  while(--i >= 0)
 80e:	197d                	addi	s2,s2,-1
 810:	ff3918e3          	bne	s2,s3,800 <printint+0x82>
}
 814:	70e2                	ld	ra,56(sp)
 816:	7442                	ld	s0,48(sp)
 818:	74a2                	ld	s1,40(sp)
 81a:	7902                	ld	s2,32(sp)
 81c:	69e2                	ld	s3,24(sp)
 81e:	6121                	addi	sp,sp,64
 820:	8082                	ret
    x = -xx;
 822:	40b005bb          	negw	a1,a1
    neg = 1;
 826:	4885                	li	a7,1
    x = -xx;
 828:	bf85                	j	798 <printint+0x1a>

000000000000082a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 82a:	715d                	addi	sp,sp,-80
 82c:	e486                	sd	ra,72(sp)
 82e:	e0a2                	sd	s0,64(sp)
 830:	fc26                	sd	s1,56(sp)
 832:	f84a                	sd	s2,48(sp)
 834:	f44e                	sd	s3,40(sp)
 836:	f052                	sd	s4,32(sp)
 838:	ec56                	sd	s5,24(sp)
 83a:	e85a                	sd	s6,16(sp)
 83c:	e45e                	sd	s7,8(sp)
 83e:	e062                	sd	s8,0(sp)
 840:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 842:	0005c903          	lbu	s2,0(a1)
 846:	18090c63          	beqz	s2,9de <vprintf+0x1b4>
 84a:	8aaa                	mv	s5,a0
 84c:	8bb2                	mv	s7,a2
 84e:	00158493          	addi	s1,a1,1
  state = 0;
 852:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 854:	02500a13          	li	s4,37
 858:	4b55                	li	s6,21
 85a:	a839                	j	878 <vprintf+0x4e>
        putc(fd, c);
 85c:	85ca                	mv	a1,s2
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	efc080e7          	jalr	-260(ra) # 75c <putc>
 868:	a019                	j	86e <vprintf+0x44>
    } else if(state == '%'){
 86a:	01498d63          	beq	s3,s4,884 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 86e:	0485                	addi	s1,s1,1
 870:	fff4c903          	lbu	s2,-1(s1)
 874:	16090563          	beqz	s2,9de <vprintf+0x1b4>
    if(state == 0){
 878:	fe0999e3          	bnez	s3,86a <vprintf+0x40>
      if(c == '%'){
 87c:	ff4910e3          	bne	s2,s4,85c <vprintf+0x32>
        state = '%';
 880:	89d2                	mv	s3,s4
 882:	b7f5                	j	86e <vprintf+0x44>
      if(c == 'd'){
 884:	13490263          	beq	s2,s4,9a8 <vprintf+0x17e>
 888:	f9d9079b          	addiw	a5,s2,-99
 88c:	0ff7f793          	zext.b	a5,a5
 890:	12fb6563          	bltu	s6,a5,9ba <vprintf+0x190>
 894:	f9d9079b          	addiw	a5,s2,-99
 898:	0ff7f713          	zext.b	a4,a5
 89c:	10eb6f63          	bltu	s6,a4,9ba <vprintf+0x190>
 8a0:	00271793          	slli	a5,a4,0x2
 8a4:	00000717          	auipc	a4,0x0
 8a8:	3a470713          	addi	a4,a4,932 # c48 <malloc+0x16c>
 8ac:	97ba                	add	a5,a5,a4
 8ae:	439c                	lw	a5,0(a5)
 8b0:	97ba                	add	a5,a5,a4
 8b2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 8b4:	008b8913          	addi	s2,s7,8
 8b8:	4685                	li	a3,1
 8ba:	4629                	li	a2,10
 8bc:	000ba583          	lw	a1,0(s7)
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	ebc080e7          	jalr	-324(ra) # 77e <printint>
 8ca:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	b745                	j	86e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d0:	008b8913          	addi	s2,s7,8
 8d4:	4681                	li	a3,0
 8d6:	4629                	li	a2,10
 8d8:	000ba583          	lw	a1,0(s7)
 8dc:	8556                	mv	a0,s5
 8de:	00000097          	auipc	ra,0x0
 8e2:	ea0080e7          	jalr	-352(ra) # 77e <printint>
 8e6:	8bca                	mv	s7,s2
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	b751                	j	86e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 8ec:	008b8913          	addi	s2,s7,8
 8f0:	4681                	li	a3,0
 8f2:	4641                	li	a2,16
 8f4:	000ba583          	lw	a1,0(s7)
 8f8:	8556                	mv	a0,s5
 8fa:	00000097          	auipc	ra,0x0
 8fe:	e84080e7          	jalr	-380(ra) # 77e <printint>
 902:	8bca                	mv	s7,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	b7a5                	j	86e <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 908:	008b8c13          	addi	s8,s7,8
 90c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 910:	03000593          	li	a1,48
 914:	8556                	mv	a0,s5
 916:	00000097          	auipc	ra,0x0
 91a:	e46080e7          	jalr	-442(ra) # 75c <putc>
  putc(fd, 'x');
 91e:	07800593          	li	a1,120
 922:	8556                	mv	a0,s5
 924:	00000097          	auipc	ra,0x0
 928:	e38080e7          	jalr	-456(ra) # 75c <putc>
 92c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92e:	00000b97          	auipc	s7,0x0
 932:	372b8b93          	addi	s7,s7,882 # ca0 <digits>
 936:	03c9d793          	srli	a5,s3,0x3c
 93a:	97de                	add	a5,a5,s7
 93c:	0007c583          	lbu	a1,0(a5)
 940:	8556                	mv	a0,s5
 942:	00000097          	auipc	ra,0x0
 946:	e1a080e7          	jalr	-486(ra) # 75c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 94a:	0992                	slli	s3,s3,0x4
 94c:	397d                	addiw	s2,s2,-1
 94e:	fe0914e3          	bnez	s2,936 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 952:	8be2                	mv	s7,s8
      state = 0;
 954:	4981                	li	s3,0
 956:	bf21                	j	86e <vprintf+0x44>
        s = va_arg(ap, char*);
 958:	008b8993          	addi	s3,s7,8
 95c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 960:	02090163          	beqz	s2,982 <vprintf+0x158>
        while(*s != 0){
 964:	00094583          	lbu	a1,0(s2)
 968:	c9a5                	beqz	a1,9d8 <vprintf+0x1ae>
          putc(fd, *s);
 96a:	8556                	mv	a0,s5
 96c:	00000097          	auipc	ra,0x0
 970:	df0080e7          	jalr	-528(ra) # 75c <putc>
          s++;
 974:	0905                	addi	s2,s2,1
        while(*s != 0){
 976:	00094583          	lbu	a1,0(s2)
 97a:	f9e5                	bnez	a1,96a <vprintf+0x140>
        s = va_arg(ap, char*);
 97c:	8bce                	mv	s7,s3
      state = 0;
 97e:	4981                	li	s3,0
 980:	b5fd                	j	86e <vprintf+0x44>
          s = "(null)";
 982:	00000917          	auipc	s2,0x0
 986:	2be90913          	addi	s2,s2,702 # c40 <malloc+0x164>
        while(*s != 0){
 98a:	02800593          	li	a1,40
 98e:	bff1                	j	96a <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 990:	008b8913          	addi	s2,s7,8
 994:	000bc583          	lbu	a1,0(s7)
 998:	8556                	mv	a0,s5
 99a:	00000097          	auipc	ra,0x0
 99e:	dc2080e7          	jalr	-574(ra) # 75c <putc>
 9a2:	8bca                	mv	s7,s2
      state = 0;
 9a4:	4981                	li	s3,0
 9a6:	b5e1                	j	86e <vprintf+0x44>
        putc(fd, c);
 9a8:	02500593          	li	a1,37
 9ac:	8556                	mv	a0,s5
 9ae:	00000097          	auipc	ra,0x0
 9b2:	dae080e7          	jalr	-594(ra) # 75c <putc>
      state = 0;
 9b6:	4981                	li	s3,0
 9b8:	bd5d                	j	86e <vprintf+0x44>
        putc(fd, '%');
 9ba:	02500593          	li	a1,37
 9be:	8556                	mv	a0,s5
 9c0:	00000097          	auipc	ra,0x0
 9c4:	d9c080e7          	jalr	-612(ra) # 75c <putc>
        putc(fd, c);
 9c8:	85ca                	mv	a1,s2
 9ca:	8556                	mv	a0,s5
 9cc:	00000097          	auipc	ra,0x0
 9d0:	d90080e7          	jalr	-624(ra) # 75c <putc>
      state = 0;
 9d4:	4981                	li	s3,0
 9d6:	bd61                	j	86e <vprintf+0x44>
        s = va_arg(ap, char*);
 9d8:	8bce                	mv	s7,s3
      state = 0;
 9da:	4981                	li	s3,0
 9dc:	bd49                	j	86e <vprintf+0x44>
    }
  }
}
 9de:	60a6                	ld	ra,72(sp)
 9e0:	6406                	ld	s0,64(sp)
 9e2:	74e2                	ld	s1,56(sp)
 9e4:	7942                	ld	s2,48(sp)
 9e6:	79a2                	ld	s3,40(sp)
 9e8:	7a02                	ld	s4,32(sp)
 9ea:	6ae2                	ld	s5,24(sp)
 9ec:	6b42                	ld	s6,16(sp)
 9ee:	6ba2                	ld	s7,8(sp)
 9f0:	6c02                	ld	s8,0(sp)
 9f2:	6161                	addi	sp,sp,80
 9f4:	8082                	ret

00000000000009f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9f6:	715d                	addi	sp,sp,-80
 9f8:	ec06                	sd	ra,24(sp)
 9fa:	e822                	sd	s0,16(sp)
 9fc:	1000                	addi	s0,sp,32
 9fe:	e010                	sd	a2,0(s0)
 a00:	e414                	sd	a3,8(s0)
 a02:	e818                	sd	a4,16(s0)
 a04:	ec1c                	sd	a5,24(s0)
 a06:	03043023          	sd	a6,32(s0)
 a0a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a0e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a12:	8622                	mv	a2,s0
 a14:	00000097          	auipc	ra,0x0
 a18:	e16080e7          	jalr	-490(ra) # 82a <vprintf>
}
 a1c:	60e2                	ld	ra,24(sp)
 a1e:	6442                	ld	s0,16(sp)
 a20:	6161                	addi	sp,sp,80
 a22:	8082                	ret

0000000000000a24 <printf>:

void
printf(const char *fmt, ...)
{
 a24:	711d                	addi	sp,sp,-96
 a26:	ec06                	sd	ra,24(sp)
 a28:	e822                	sd	s0,16(sp)
 a2a:	1000                	addi	s0,sp,32
 a2c:	e40c                	sd	a1,8(s0)
 a2e:	e810                	sd	a2,16(s0)
 a30:	ec14                	sd	a3,24(s0)
 a32:	f018                	sd	a4,32(s0)
 a34:	f41c                	sd	a5,40(s0)
 a36:	03043823          	sd	a6,48(s0)
 a3a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a3e:	00840613          	addi	a2,s0,8
 a42:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a46:	85aa                	mv	a1,a0
 a48:	4505                	li	a0,1
 a4a:	00000097          	auipc	ra,0x0
 a4e:	de0080e7          	jalr	-544(ra) # 82a <vprintf>
}
 a52:	60e2                	ld	ra,24(sp)
 a54:	6442                	ld	s0,16(sp)
 a56:	6125                	addi	sp,sp,96
 a58:	8082                	ret

0000000000000a5a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a5a:	1141                	addi	sp,sp,-16
 a5c:	e422                	sd	s0,8(sp)
 a5e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a60:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a64:	00000797          	auipc	a5,0x0
 a68:	59c7b783          	ld	a5,1436(a5) # 1000 <freep>
 a6c:	a02d                	j	a96 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a6e:	4618                	lw	a4,8(a2)
 a70:	9f2d                	addw	a4,a4,a1
 a72:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a76:	6398                	ld	a4,0(a5)
 a78:	6310                	ld	a2,0(a4)
 a7a:	a83d                	j	ab8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a7c:	ff852703          	lw	a4,-8(a0)
 a80:	9f31                	addw	a4,a4,a2
 a82:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a84:	ff053683          	ld	a3,-16(a0)
 a88:	a091                	j	acc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a8a:	6398                	ld	a4,0(a5)
 a8c:	00e7e463          	bltu	a5,a4,a94 <free+0x3a>
 a90:	00e6ea63          	bltu	a3,a4,aa4 <free+0x4a>
{
 a94:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a96:	fed7fae3          	bgeu	a5,a3,a8a <free+0x30>
 a9a:	6398                	ld	a4,0(a5)
 a9c:	00e6e463          	bltu	a3,a4,aa4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa0:	fee7eae3          	bltu	a5,a4,a94 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 aa4:	ff852583          	lw	a1,-8(a0)
 aa8:	6390                	ld	a2,0(a5)
 aaa:	02059813          	slli	a6,a1,0x20
 aae:	01c85713          	srli	a4,a6,0x1c
 ab2:	9736                	add	a4,a4,a3
 ab4:	fae60de3          	beq	a2,a4,a6e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 ab8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 abc:	4790                	lw	a2,8(a5)
 abe:	02061593          	slli	a1,a2,0x20
 ac2:	01c5d713          	srli	a4,a1,0x1c
 ac6:	973e                	add	a4,a4,a5
 ac8:	fae68ae3          	beq	a3,a4,a7c <free+0x22>
    p->s.ptr = bp->s.ptr;
 acc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ace:	00000717          	auipc	a4,0x0
 ad2:	52f73923          	sd	a5,1330(a4) # 1000 <freep>
}
 ad6:	6422                	ld	s0,8(sp)
 ad8:	0141                	addi	sp,sp,16
 ada:	8082                	ret

0000000000000adc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 adc:	7139                	addi	sp,sp,-64
 ade:	fc06                	sd	ra,56(sp)
 ae0:	f822                	sd	s0,48(sp)
 ae2:	f426                	sd	s1,40(sp)
 ae4:	f04a                	sd	s2,32(sp)
 ae6:	ec4e                	sd	s3,24(sp)
 ae8:	e852                	sd	s4,16(sp)
 aea:	e456                	sd	s5,8(sp)
 aec:	e05a                	sd	s6,0(sp)
 aee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 af0:	02051493          	slli	s1,a0,0x20
 af4:	9081                	srli	s1,s1,0x20
 af6:	04bd                	addi	s1,s1,15
 af8:	8091                	srli	s1,s1,0x4
 afa:	0014899b          	addiw	s3,s1,1
 afe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b00:	00000517          	auipc	a0,0x0
 b04:	50053503          	ld	a0,1280(a0) # 1000 <freep>
 b08:	c515                	beqz	a0,b34 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b0c:	4798                	lw	a4,8(a5)
 b0e:	02977f63          	bgeu	a4,s1,b4c <malloc+0x70>
  if(nu < 4096)
 b12:	8a4e                	mv	s4,s3
 b14:	0009871b          	sext.w	a4,s3
 b18:	6685                	lui	a3,0x1
 b1a:	00d77363          	bgeu	a4,a3,b20 <malloc+0x44>
 b1e:	6a05                	lui	s4,0x1
 b20:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b24:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b28:	00000917          	auipc	s2,0x0
 b2c:	4d890913          	addi	s2,s2,1240 # 1000 <freep>
  if(p == (char*)-1)
 b30:	5afd                	li	s5,-1
 b32:	a895                	j	ba6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b34:	00000797          	auipc	a5,0x0
 b38:	4ec78793          	addi	a5,a5,1260 # 1020 <base>
 b3c:	00000717          	auipc	a4,0x0
 b40:	4cf73223          	sd	a5,1220(a4) # 1000 <freep>
 b44:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b46:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b4a:	b7e1                	j	b12 <malloc+0x36>
      if(p->s.size == nunits)
 b4c:	02e48c63          	beq	s1,a4,b84 <malloc+0xa8>
        p->s.size -= nunits;
 b50:	4137073b          	subw	a4,a4,s3
 b54:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b56:	02071693          	slli	a3,a4,0x20
 b5a:	01c6d713          	srli	a4,a3,0x1c
 b5e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b60:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b64:	00000717          	auipc	a4,0x0
 b68:	48a73e23          	sd	a0,1180(a4) # 1000 <freep>
      return (void*)(p + 1);
 b6c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b70:	70e2                	ld	ra,56(sp)
 b72:	7442                	ld	s0,48(sp)
 b74:	74a2                	ld	s1,40(sp)
 b76:	7902                	ld	s2,32(sp)
 b78:	69e2                	ld	s3,24(sp)
 b7a:	6a42                	ld	s4,16(sp)
 b7c:	6aa2                	ld	s5,8(sp)
 b7e:	6b02                	ld	s6,0(sp)
 b80:	6121                	addi	sp,sp,64
 b82:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b84:	6398                	ld	a4,0(a5)
 b86:	e118                	sd	a4,0(a0)
 b88:	bff1                	j	b64 <malloc+0x88>
  hp->s.size = nu;
 b8a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b8e:	0541                	addi	a0,a0,16
 b90:	00000097          	auipc	ra,0x0
 b94:	eca080e7          	jalr	-310(ra) # a5a <free>
  return freep;
 b98:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b9c:	d971                	beqz	a0,b70 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b9e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ba0:	4798                	lw	a4,8(a5)
 ba2:	fa9775e3          	bgeu	a4,s1,b4c <malloc+0x70>
    if(p == freep)
 ba6:	00093703          	ld	a4,0(s2)
 baa:	853e                	mv	a0,a5
 bac:	fef719e3          	bne	a4,a5,b9e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 bb0:	8552                	mv	a0,s4
 bb2:	00000097          	auipc	ra,0x0
 bb6:	b62080e7          	jalr	-1182(ra) # 714 <sbrk>
  if(p == (char*)-1)
 bba:	fd5518e3          	bne	a0,s5,b8a <malloc+0xae>
        return 0;
 bbe:	4501                	li	a0,0
 bc0:	bf45                	j	b70 <malloc+0x94>
