
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	4ce080e7          	jalr	1230(ra) # 4ee <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	4c2080e7          	jalr	1218(ra) # 4f6 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	9d058593          	addi	a1,a1,-1584 # a10 <malloc+0xea>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	7f6080e7          	jalr	2038(ra) # 840 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	482080e7          	jalr	1154(ra) # 4d6 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	9ba58593          	addi	a1,a1,-1606 # a28 <malloc+0x102>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	7c8080e7          	jalr	1992(ra) # 840 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	454080e7          	jalr	1108(ra) # 4d6 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  98:	4785                	li	a5,1
  9a:	04a7d763          	bge	a5,a0,e8 <main+0x5e>
  9e:	00858913          	addi	s2,a1,8
  a2:	ffe5099b          	addiw	s3,a0,-2
  a6:	02099793          	slli	a5,s3,0x20
  aa:	01d7d993          	srli	s3,a5,0x1d
  ae:	05c1                	addi	a1,a1,16
  b0:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b2:	4581                	li	a1,0
  b4:	00093503          	ld	a0,0(s2) # 1010 <buf>
  b8:	00000097          	auipc	ra,0x0
  bc:	45e080e7          	jalr	1118(ra) # 516 <open>
  c0:	84aa                	mv	s1,a0
  c2:	02054d63          	bltz	a0,fc <main+0x72>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c6:	00000097          	auipc	ra,0x0
  ca:	f3a080e7          	jalr	-198(ra) # 0 <cat>
    close(fd);
  ce:	8526                	mv	a0,s1
  d0:	00000097          	auipc	ra,0x0
  d4:	42e080e7          	jalr	1070(ra) # 4fe <close>
  for(i = 1; i < argc; i++){
  d8:	0921                	addi	s2,s2,8
  da:	fd391ce3          	bne	s2,s3,b2 <main+0x28>
  }
  exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	3f6080e7          	jalr	1014(ra) # 4d6 <exit>
    cat(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	f16080e7          	jalr	-234(ra) # 0 <cat>
    exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	3e2080e7          	jalr	994(ra) # 4d6 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fc:	00093603          	ld	a2,0(s2)
 100:	00001597          	auipc	a1,0x1
 104:	94058593          	addi	a1,a1,-1728 # a40 <malloc+0x11a>
 108:	4509                	li	a0,2
 10a:	00000097          	auipc	ra,0x0
 10e:	736080e7          	jalr	1846(ra) # 840 <fprintf>
      exit(1);
 112:	4505                	li	a0,1
 114:	00000097          	auipc	ra,0x0
 118:	3c2080e7          	jalr	962(ra) # 4d6 <exit>

000000000000011c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  extern int main();
  main();
 124:	00000097          	auipc	ra,0x0
 128:	f66080e7          	jalr	-154(ra) # 8a <main>
  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	3a8080e7          	jalr	936(ra) # 4d6 <exit>

0000000000000136 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13c:	87aa                	mv	a5,a0
 13e:	0585                	addi	a1,a1,1
 140:	0785                	addi	a5,a5,1
 142:	fff5c703          	lbu	a4,-1(a1)
 146:	fee78fa3          	sb	a4,-1(a5)
 14a:	fb75                	bnez	a4,13e <strcpy+0x8>
    ;
  return os;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb91                	beqz	a5,170 <strcmp+0x1e>
 15e:	0005c703          	lbu	a4,0(a1)
 162:	00f71763          	bne	a4,a5,170 <strcmp+0x1e>
    p++, q++;
 166:	0505                	addi	a0,a0,1
 168:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbe5                	bnez	a5,15e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 170:	0005c503          	lbu	a0,0(a1)
}
 174:	40a7853b          	subw	a0,a5,a0
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strlen>:

uint
strlen(const char *s)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 184:	00054783          	lbu	a5,0(a0)
 188:	cf91                	beqz	a5,1a4 <strlen+0x26>
 18a:	0505                	addi	a0,a0,1
 18c:	87aa                	mv	a5,a0
 18e:	86be                	mv	a3,a5
 190:	0785                	addi	a5,a5,1
 192:	fff7c703          	lbu	a4,-1(a5)
 196:	ff65                	bnez	a4,18e <strlen+0x10>
 198:	40a6853b          	subw	a0,a3,a0
 19c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret
  for(n = 0; s[n]; n++)
 1a4:	4501                	li	a0,0
 1a6:	bfe5                	j	19e <strlen+0x20>

00000000000001a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ae:	ca19                	beqz	a2,1c4 <memset+0x1c>
 1b0:	87aa                	mv	a5,a0
 1b2:	1602                	slli	a2,a2,0x20
 1b4:	9201                	srli	a2,a2,0x20
 1b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1be:	0785                	addi	a5,a5,1
 1c0:	fee79de3          	bne	a5,a4,1ba <memset+0x12>
  }
  return dst;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strchr>:

char*
strchr(const char *s, char c)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cb99                	beqz	a5,1ea <strchr+0x20>
    if(*s == c)
 1d6:	00f58763          	beq	a1,a5,1e4 <strchr+0x1a>
  for(; *s; s++)
 1da:	0505                	addi	a0,a0,1
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	fbfd                	bnez	a5,1d6 <strchr+0xc>
      return (char*)s;
  return 0;
 1e2:	4501                	li	a0,0
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  return 0;
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <strchr+0x1a>

00000000000001ee <gets>:

char*
gets(char *buf, int max)
{
 1ee:	711d                	addi	sp,sp,-96
 1f0:	ec86                	sd	ra,88(sp)
 1f2:	e8a2                	sd	s0,80(sp)
 1f4:	e4a6                	sd	s1,72(sp)
 1f6:	e0ca                	sd	s2,64(sp)
 1f8:	fc4e                	sd	s3,56(sp)
 1fa:	f852                	sd	s4,48(sp)
 1fc:	f456                	sd	s5,40(sp)
 1fe:	f05a                	sd	s6,32(sp)
 200:	ec5e                	sd	s7,24(sp)
 202:	1080                	addi	s0,sp,96
 204:	8baa                	mv	s7,a0
 206:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	892a                	mv	s2,a0
 20a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20c:	4aa9                	li	s5,10
 20e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 210:	89a6                	mv	s3,s1
 212:	2485                	addiw	s1,s1,1
 214:	0344d863          	bge	s1,s4,244 <gets+0x56>
    cc = read(0, &c, 1);
 218:	4605                	li	a2,1
 21a:	faf40593          	addi	a1,s0,-81
 21e:	4501                	li	a0,0
 220:	00000097          	auipc	ra,0x0
 224:	2ce080e7          	jalr	718(ra) # 4ee <read>
    if(cc < 1)
 228:	00a05e63          	blez	a0,244 <gets+0x56>
    buf[i++] = c;
 22c:	faf44783          	lbu	a5,-81(s0)
 230:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 234:	01578763          	beq	a5,s5,242 <gets+0x54>
 238:	0905                	addi	s2,s2,1
 23a:	fd679be3          	bne	a5,s6,210 <gets+0x22>
  for(i=0; i+1 < max; ){
 23e:	89a6                	mv	s3,s1
 240:	a011                	j	244 <gets+0x56>
 242:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 244:	99de                	add	s3,s3,s7
 246:	00098023          	sb	zero,0(s3)
  return buf;
}
 24a:	855e                	mv	a0,s7
 24c:	60e6                	ld	ra,88(sp)
 24e:	6446                	ld	s0,80(sp)
 250:	64a6                	ld	s1,72(sp)
 252:	6906                	ld	s2,64(sp)
 254:	79e2                	ld	s3,56(sp)
 256:	7a42                	ld	s4,48(sp)
 258:	7aa2                	ld	s5,40(sp)
 25a:	7b02                	ld	s6,32(sp)
 25c:	6be2                	ld	s7,24(sp)
 25e:	6125                	addi	sp,sp,96
 260:	8082                	ret

0000000000000262 <stat>:

int
stat(const char *n, struct stat *st)
{
 262:	1101                	addi	sp,sp,-32
 264:	ec06                	sd	ra,24(sp)
 266:	e822                	sd	s0,16(sp)
 268:	e426                	sd	s1,8(sp)
 26a:	e04a                	sd	s2,0(sp)
 26c:	1000                	addi	s0,sp,32
 26e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 270:	4581                	li	a1,0
 272:	00000097          	auipc	ra,0x0
 276:	2a4080e7          	jalr	676(ra) # 516 <open>
  if(fd < 0)
 27a:	02054563          	bltz	a0,2a4 <stat+0x42>
 27e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 280:	85ca                	mv	a1,s2
 282:	00000097          	auipc	ra,0x0
 286:	2ac080e7          	jalr	684(ra) # 52e <fstat>
 28a:	892a                	mv	s2,a0
  close(fd);
 28c:	8526                	mv	a0,s1
 28e:	00000097          	auipc	ra,0x0
 292:	270080e7          	jalr	624(ra) # 4fe <close>
  return r;
}
 296:	854a                	mv	a0,s2
 298:	60e2                	ld	ra,24(sp)
 29a:	6442                	ld	s0,16(sp)
 29c:	64a2                	ld	s1,8(sp)
 29e:	6902                	ld	s2,0(sp)
 2a0:	6105                	addi	sp,sp,32
 2a2:	8082                	ret
    return -1;
 2a4:	597d                	li	s2,-1
 2a6:	bfc5                	j	296 <stat+0x34>

00000000000002a8 <atoi>:

int
atoi(const char *s)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 2ae:	00054683          	lbu	a3,0(a0)
 2b2:	fd06879b          	addiw	a5,a3,-48
 2b6:	0ff7f793          	zext.b	a5,a5
 2ba:	4625                	li	a2,9
 2bc:	02f66863          	bltu	a2,a5,2ec <atoi+0x44>
 2c0:	872a                	mv	a4,a0
  n = 0;
 2c2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c4:	0705                	addi	a4,a4,1
 2c6:	0025179b          	slliw	a5,a0,0x2
 2ca:	9fa9                	addw	a5,a5,a0
 2cc:	0017979b          	slliw	a5,a5,0x1
 2d0:	9fb5                	addw	a5,a5,a3
 2d2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d6:	00074683          	lbu	a3,0(a4)
 2da:	fd06879b          	addiw	a5,a3,-48
 2de:	0ff7f793          	zext.b	a5,a5
 2e2:	fef671e3          	bgeu	a2,a5,2c4 <atoi+0x1c>

  return n;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  n = 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <atoi+0x3e>

00000000000002f0 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
 2f6:	8eaa                	mv	t4,a0
    register const char *s = strt;
 2f8:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 2fa:	02000693          	li	a3,32
        c = *s++;
 2fe:	883e                	mv	a6,a5
 300:	0785                	addi	a5,a5,1
 302:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 306:	fed70ce3          	beq	a4,a3,2fe <strtoi+0xe>
        c = *s++;
 30a:	2701                	sext.w	a4,a4

    if (c == '-') {
 30c:	02d00693          	li	a3,45
 310:	04d70d63          	beq	a4,a3,36a <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 314:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 318:	4f01                	li	t5,0
    } else if (c == '+')
 31a:	04d70e63          	beq	a4,a3,376 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 31e:	fef67693          	andi	a3,a2,-17
 322:	ea99                	bnez	a3,338 <strtoi+0x48>
 324:	03000693          	li	a3,48
 328:	04d70c63          	beq	a4,a3,380 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 32c:	e611                	bnez	a2,338 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 32e:	03000693          	li	a3,48
 332:	0cd70b63          	beq	a4,a3,408 <strtoi+0x118>
 336:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 338:	800008b7          	lui	a7,0x80000
 33c:	fff8c893          	not	a7,a7
 340:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 344:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 348:	1882                	slli	a7,a7,0x20
 34a:	0208d893          	srli	a7,a7,0x20
 34e:	02c8d8b3          	divu	a7,a7,a2
 352:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 356:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 35a:	0ac75163          	bge	a4,a2,3fc <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 35e:	4681                	li	a3,0
 360:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 362:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 364:	2881                	sext.w	a7,a7
        else {
            any = 1;
 366:	4f85                	li	t6,1
 368:	a0a9                	j	3b2 <strtoi+0xc2>
        c = *s++;
 36a:	0007c703          	lbu	a4,0(a5)
 36e:	00280793          	addi	a5,a6,2
        neg = 1;
 372:	4f05                	li	t5,1
 374:	b76d                	j	31e <strtoi+0x2e>
        c = *s++;
 376:	0007c703          	lbu	a4,0(a5)
 37a:	00280793          	addi	a5,a6,2
 37e:	b745                	j	31e <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 380:	0007c683          	lbu	a3,0(a5)
 384:	0df6f693          	andi	a3,a3,223
 388:	05800513          	li	a0,88
 38c:	faa690e3          	bne	a3,a0,32c <strtoi+0x3c>
        c = s[1];
 390:	0017c703          	lbu	a4,1(a5)
        s += 2;
 394:	0789                	addi	a5,a5,2
        base = 16;
 396:	4641                	li	a2,16
 398:	b745                	j	338 <strtoi+0x48>
            any = -1;
 39a:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 39c:	00e2c463          	blt	t0,a4,3a4 <strtoi+0xb4>
 3a0:	a015                	j	3c4 <strtoi+0xd4>
            any = -1;
 3a2:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 3a4:	0785                	addi	a5,a5,1
 3a6:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 3aa:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 3ae:	02c75063          	bge	a4,a2,3ce <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 3b2:	fe06c8e3          	bltz	a3,3a2 <strtoi+0xb2>
 3b6:	0005081b          	sext.w	a6,a0
            any = -1;
 3ba:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 3bc:	ff0e64e3          	bltu	t3,a6,3a4 <strtoi+0xb4>
 3c0:	fca88de3          	beq	a7,a0,39a <strtoi+0xaa>
            acc *= base;
 3c4:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 3c8:	9d39                	addw	a0,a0,a4
            any = 1;
 3ca:	86fe                	mv	a3,t6
 3cc:	bfe1                	j	3a4 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 3ce:	0006cd63          	bltz	a3,3e8 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 3d2:	000f0463          	beqz	t5,3da <strtoi+0xea>
        acc = -acc;
 3d6:	40a0053b          	negw	a0,a0
    if (end != 0)
 3da:	c581                	beqz	a1,3e2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3dc:	ee89                	bnez	a3,3f6 <strtoi+0x106>
 3de:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 3e2:	6422                	ld	s0,8(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 3e8:	000f1d63          	bnez	t5,402 <strtoi+0x112>
 3ec:	80000537          	lui	a0,0x80000
 3f0:	fff54513          	not	a0,a0
    if (end != 0)
 3f4:	d5fd                	beqz	a1,3e2 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 3f6:	fff78e93          	addi	t4,a5,-1
 3fa:	b7d5                	j	3de <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 3fc:	4681                	li	a3,0
 3fe:	4501                	li	a0,0
 400:	bfc9                	j	3d2 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 402:	80000537          	lui	a0,0x80000
 406:	b7fd                	j	3f4 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 408:	80000e37          	lui	t3,0x80000
 40c:	fffe4e13          	not	t3,t3
 410:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 414:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 418:	003e589b          	srliw	a7,t3,0x3
 41c:	8e46                	mv	t3,a7
            c -= '0';
 41e:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 420:	4621                	li	a2,8
 422:	bf35                	j	35e <strtoi+0x6e>

0000000000000424 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e422                	sd	s0,8(sp)
 428:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42a:	02b57463          	bgeu	a0,a1,452 <memmove+0x2e>
    while(n-- > 0)
 42e:	00c05f63          	blez	a2,44c <memmove+0x28>
 432:	1602                	slli	a2,a2,0x20
 434:	9201                	srli	a2,a2,0x20
 436:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43a:	872a                	mv	a4,a0
      *dst++ = *src++;
 43c:	0585                	addi	a1,a1,1
 43e:	0705                	addi	a4,a4,1
 440:	fff5c683          	lbu	a3,-1(a1)
 444:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 448:	fee79ae3          	bne	a5,a4,43c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
    dst += n;
 452:	00c50733          	add	a4,a0,a2
    src += n;
 456:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 458:	fec05ae3          	blez	a2,44c <memmove+0x28>
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	fff7c793          	not	a5,a5
 468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46a:	15fd                	addi	a1,a1,-1
 46c:	177d                	addi	a4,a4,-1
 46e:	0005c683          	lbu	a3,0(a1)
 472:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 476:	fee79ae3          	bne	a5,a4,46a <memmove+0x46>
 47a:	bfc9                	j	44c <memmove+0x28>

000000000000047c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 482:	ca05                	beqz	a2,4b2 <memcmp+0x36>
 484:	fff6069b          	addiw	a3,a2,-1
 488:	1682                	slli	a3,a3,0x20
 48a:	9281                	srli	a3,a3,0x20
 48c:	0685                	addi	a3,a3,1
 48e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 490:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffedf0>
 494:	0005c703          	lbu	a4,0(a1)
 498:	00e79863          	bne	a5,a4,4a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49c:	0505                	addi	a0,a0,1
    p2++;
 49e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a0:	fed518e3          	bne	a0,a3,490 <memcmp+0x14>
  }
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	a019                	j	4ac <memcmp+0x30>
      return *p1 - *p2;
 4a8:	40e7853b          	subw	a0,a5,a4
}
 4ac:	6422                	ld	s0,8(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	bfe5                	j	4ac <memcmp+0x30>

00000000000004b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e406                	sd	ra,8(sp)
 4ba:	e022                	sd	s0,0(sp)
 4bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4be:	00000097          	auipc	ra,0x0
 4c2:	f66080e7          	jalr	-154(ra) # 424 <memmove>
}
 4c6:	60a2                	ld	ra,8(sp)
 4c8:	6402                	ld	s0,0(sp)
 4ca:	0141                	addi	sp,sp,16
 4cc:	8082                	ret

00000000000004ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ce:	4885                	li	a7,1
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d6:	4889                	li	a7,2
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <wait>:
.global wait
wait:
 li a7, SYS_wait
 4de:	488d                	li	a7,3
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e6:	4891                	li	a7,4
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <read>:
.global read
read:
 li a7, SYS_read
 4ee:	4895                	li	a7,5
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <write>:
.global write
write:
 li a7, SYS_write
 4f6:	48c1                	li	a7,16
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <close>:
.global close
close:
 li a7, SYS_close
 4fe:	48d5                	li	a7,21
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <kill>:
.global kill
kill:
 li a7, SYS_kill
 506:	4899                	li	a7,6
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <exec>:
.global exec
exec:
 li a7, SYS_exec
 50e:	489d                	li	a7,7
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <open>:
.global open
open:
 li a7, SYS_open
 516:	48bd                	li	a7,15
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 51e:	48c5                	li	a7,17
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 526:	48c9                	li	a7,18
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 52e:	48a1                	li	a7,8
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <link>:
.global link
link:
 li a7, SYS_link
 536:	48cd                	li	a7,19
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 53e:	48d1                	li	a7,20
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 546:	48a5                	li	a7,9
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <dup>:
.global dup
dup:
 li a7, SYS_dup
 54e:	48a9                	li	a7,10
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 556:	48ad                	li	a7,11
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 55e:	48b1                	li	a7,12
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 566:	48b5                	li	a7,13
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 56e:	48b9                	li	a7,14
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 576:	48d9                	li	a7,22
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 57e:	48dd                	li	a7,23
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 586:	48e1                	li	a7,24
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 58e:	48e5                	li	a7,25
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 596:	48e9                	li	a7,26
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 59e:	48ed                	li	a7,27
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a6:	1101                	addi	sp,sp,-32
 5a8:	ec06                	sd	ra,24(sp)
 5aa:	e822                	sd	s0,16(sp)
 5ac:	1000                	addi	s0,sp,32
 5ae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5b2:	4605                	li	a2,1
 5b4:	fef40593          	addi	a1,s0,-17
 5b8:	00000097          	auipc	ra,0x0
 5bc:	f3e080e7          	jalr	-194(ra) # 4f6 <write>
}
 5c0:	60e2                	ld	ra,24(sp)
 5c2:	6442                	ld	s0,16(sp)
 5c4:	6105                	addi	sp,sp,32
 5c6:	8082                	ret

00000000000005c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c8:	7139                	addi	sp,sp,-64
 5ca:	fc06                	sd	ra,56(sp)
 5cc:	f822                	sd	s0,48(sp)
 5ce:	f426                	sd	s1,40(sp)
 5d0:	f04a                	sd	s2,32(sp)
 5d2:	ec4e                	sd	s3,24(sp)
 5d4:	0080                	addi	s0,sp,64
 5d6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5d8:	c299                	beqz	a3,5de <printint+0x16>
 5da:	0805c963          	bltz	a1,66c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5de:	2581                	sext.w	a1,a1
  neg = 0;
 5e0:	4881                	li	a7,0
 5e2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5e6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5e8:	2601                	sext.w	a2,a2
 5ea:	00000517          	auipc	a0,0x0
 5ee:	4ce50513          	addi	a0,a0,1230 # ab8 <digits>
 5f2:	883a                	mv	a6,a4
 5f4:	2705                	addiw	a4,a4,1
 5f6:	02c5f7bb          	remuw	a5,a1,a2
 5fa:	1782                	slli	a5,a5,0x20
 5fc:	9381                	srli	a5,a5,0x20
 5fe:	97aa                	add	a5,a5,a0
 600:	0007c783          	lbu	a5,0(a5)
 604:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 608:	0005879b          	sext.w	a5,a1
 60c:	02c5d5bb          	divuw	a1,a1,a2
 610:	0685                	addi	a3,a3,1
 612:	fec7f0e3          	bgeu	a5,a2,5f2 <printint+0x2a>
  if(neg)
 616:	00088c63          	beqz	a7,62e <printint+0x66>
    buf[i++] = '-';
 61a:	fd070793          	addi	a5,a4,-48
 61e:	00878733          	add	a4,a5,s0
 622:	02d00793          	li	a5,45
 626:	fef70823          	sb	a5,-16(a4)
 62a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 62e:	02e05863          	blez	a4,65e <printint+0x96>
 632:	fc040793          	addi	a5,s0,-64
 636:	00e78933          	add	s2,a5,a4
 63a:	fff78993          	addi	s3,a5,-1
 63e:	99ba                	add	s3,s3,a4
 640:	377d                	addiw	a4,a4,-1
 642:	1702                	slli	a4,a4,0x20
 644:	9301                	srli	a4,a4,0x20
 646:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 64a:	fff94583          	lbu	a1,-1(s2)
 64e:	8526                	mv	a0,s1
 650:	00000097          	auipc	ra,0x0
 654:	f56080e7          	jalr	-170(ra) # 5a6 <putc>
  while(--i >= 0)
 658:	197d                	addi	s2,s2,-1
 65a:	ff3918e3          	bne	s2,s3,64a <printint+0x82>
}
 65e:	70e2                	ld	ra,56(sp)
 660:	7442                	ld	s0,48(sp)
 662:	74a2                	ld	s1,40(sp)
 664:	7902                	ld	s2,32(sp)
 666:	69e2                	ld	s3,24(sp)
 668:	6121                	addi	sp,sp,64
 66a:	8082                	ret
    x = -xx;
 66c:	40b005bb          	negw	a1,a1
    neg = 1;
 670:	4885                	li	a7,1
    x = -xx;
 672:	bf85                	j	5e2 <printint+0x1a>

0000000000000674 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 674:	715d                	addi	sp,sp,-80
 676:	e486                	sd	ra,72(sp)
 678:	e0a2                	sd	s0,64(sp)
 67a:	fc26                	sd	s1,56(sp)
 67c:	f84a                	sd	s2,48(sp)
 67e:	f44e                	sd	s3,40(sp)
 680:	f052                	sd	s4,32(sp)
 682:	ec56                	sd	s5,24(sp)
 684:	e85a                	sd	s6,16(sp)
 686:	e45e                	sd	s7,8(sp)
 688:	e062                	sd	s8,0(sp)
 68a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 68c:	0005c903          	lbu	s2,0(a1)
 690:	18090c63          	beqz	s2,828 <vprintf+0x1b4>
 694:	8aaa                	mv	s5,a0
 696:	8bb2                	mv	s7,a2
 698:	00158493          	addi	s1,a1,1
  state = 0;
 69c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 69e:	02500a13          	li	s4,37
 6a2:	4b55                	li	s6,21
 6a4:	a839                	j	6c2 <vprintf+0x4e>
        putc(fd, c);
 6a6:	85ca                	mv	a1,s2
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	efc080e7          	jalr	-260(ra) # 5a6 <putc>
 6b2:	a019                	j	6b8 <vprintf+0x44>
    } else if(state == '%'){
 6b4:	01498d63          	beq	s3,s4,6ce <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 6b8:	0485                	addi	s1,s1,1
 6ba:	fff4c903          	lbu	s2,-1(s1)
 6be:	16090563          	beqz	s2,828 <vprintf+0x1b4>
    if(state == 0){
 6c2:	fe0999e3          	bnez	s3,6b4 <vprintf+0x40>
      if(c == '%'){
 6c6:	ff4910e3          	bne	s2,s4,6a6 <vprintf+0x32>
        state = '%';
 6ca:	89d2                	mv	s3,s4
 6cc:	b7f5                	j	6b8 <vprintf+0x44>
      if(c == 'd'){
 6ce:	13490263          	beq	s2,s4,7f2 <vprintf+0x17e>
 6d2:	f9d9079b          	addiw	a5,s2,-99
 6d6:	0ff7f793          	zext.b	a5,a5
 6da:	12fb6563          	bltu	s6,a5,804 <vprintf+0x190>
 6de:	f9d9079b          	addiw	a5,s2,-99
 6e2:	0ff7f713          	zext.b	a4,a5
 6e6:	10eb6f63          	bltu	s6,a4,804 <vprintf+0x190>
 6ea:	00271793          	slli	a5,a4,0x2
 6ee:	00000717          	auipc	a4,0x0
 6f2:	37270713          	addi	a4,a4,882 # a60 <malloc+0x13a>
 6f6:	97ba                	add	a5,a5,a4
 6f8:	439c                	lw	a5,0(a5)
 6fa:	97ba                	add	a5,a5,a4
 6fc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4685                	li	a3,1
 704:	4629                	li	a2,10
 706:	000ba583          	lw	a1,0(s7)
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	ebc080e7          	jalr	-324(ra) # 5c8 <printint>
 714:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 716:	4981                	li	s3,0
 718:	b745                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4629                	li	a2,10
 722:	000ba583          	lw	a1,0(s7)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	ea0080e7          	jalr	-352(ra) # 5c8 <printint>
 730:	8bca                	mv	s7,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	b751                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 736:	008b8913          	addi	s2,s7,8
 73a:	4681                	li	a3,0
 73c:	4641                	li	a2,16
 73e:	000ba583          	lw	a1,0(s7)
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	e84080e7          	jalr	-380(ra) # 5c8 <printint>
 74c:	8bca                	mv	s7,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	b7a5                	j	6b8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 752:	008b8c13          	addi	s8,s7,8
 756:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 75a:	03000593          	li	a1,48
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	e46080e7          	jalr	-442(ra) # 5a6 <putc>
  putc(fd, 'x');
 768:	07800593          	li	a1,120
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	e38080e7          	jalr	-456(ra) # 5a6 <putc>
 776:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 778:	00000b97          	auipc	s7,0x0
 77c:	340b8b93          	addi	s7,s7,832 # ab8 <digits>
 780:	03c9d793          	srli	a5,s3,0x3c
 784:	97de                	add	a5,a5,s7
 786:	0007c583          	lbu	a1,0(a5)
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	e1a080e7          	jalr	-486(ra) # 5a6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 794:	0992                	slli	s3,s3,0x4
 796:	397d                	addiw	s2,s2,-1
 798:	fe0914e3          	bnez	s2,780 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 79c:	8be2                	mv	s7,s8
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bf21                	j	6b8 <vprintf+0x44>
        s = va_arg(ap, char*);
 7a2:	008b8993          	addi	s3,s7,8
 7a6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7aa:	02090163          	beqz	s2,7cc <vprintf+0x158>
        while(*s != 0){
 7ae:	00094583          	lbu	a1,0(s2)
 7b2:	c9a5                	beqz	a1,822 <vprintf+0x1ae>
          putc(fd, *s);
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	df0080e7          	jalr	-528(ra) # 5a6 <putc>
          s++;
 7be:	0905                	addi	s2,s2,1
        while(*s != 0){
 7c0:	00094583          	lbu	a1,0(s2)
 7c4:	f9e5                	bnez	a1,7b4 <vprintf+0x140>
        s = va_arg(ap, char*);
 7c6:	8bce                	mv	s7,s3
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	b5fd                	j	6b8 <vprintf+0x44>
          s = "(null)";
 7cc:	00000917          	auipc	s2,0x0
 7d0:	28c90913          	addi	s2,s2,652 # a58 <malloc+0x132>
        while(*s != 0){
 7d4:	02800593          	li	a1,40
 7d8:	bff1                	j	7b4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 7da:	008b8913          	addi	s2,s7,8
 7de:	000bc583          	lbu	a1,0(s7)
 7e2:	8556                	mv	a0,s5
 7e4:	00000097          	auipc	ra,0x0
 7e8:	dc2080e7          	jalr	-574(ra) # 5a6 <putc>
 7ec:	8bca                	mv	s7,s2
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	b5e1                	j	6b8 <vprintf+0x44>
        putc(fd, c);
 7f2:	02500593          	li	a1,37
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	dae080e7          	jalr	-594(ra) # 5a6 <putc>
      state = 0;
 800:	4981                	li	s3,0
 802:	bd5d                	j	6b8 <vprintf+0x44>
        putc(fd, '%');
 804:	02500593          	li	a1,37
 808:	8556                	mv	a0,s5
 80a:	00000097          	auipc	ra,0x0
 80e:	d9c080e7          	jalr	-612(ra) # 5a6 <putc>
        putc(fd, c);
 812:	85ca                	mv	a1,s2
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	d90080e7          	jalr	-624(ra) # 5a6 <putc>
      state = 0;
 81e:	4981                	li	s3,0
 820:	bd61                	j	6b8 <vprintf+0x44>
        s = va_arg(ap, char*);
 822:	8bce                	mv	s7,s3
      state = 0;
 824:	4981                	li	s3,0
 826:	bd49                	j	6b8 <vprintf+0x44>
    }
  }
}
 828:	60a6                	ld	ra,72(sp)
 82a:	6406                	ld	s0,64(sp)
 82c:	74e2                	ld	s1,56(sp)
 82e:	7942                	ld	s2,48(sp)
 830:	79a2                	ld	s3,40(sp)
 832:	7a02                	ld	s4,32(sp)
 834:	6ae2                	ld	s5,24(sp)
 836:	6b42                	ld	s6,16(sp)
 838:	6ba2                	ld	s7,8(sp)
 83a:	6c02                	ld	s8,0(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 840:	715d                	addi	sp,sp,-80
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e010                	sd	a2,0(s0)
 84a:	e414                	sd	a3,8(s0)
 84c:	e818                	sd	a4,16(s0)
 84e:	ec1c                	sd	a5,24(s0)
 850:	03043023          	sd	a6,32(s0)
 854:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 858:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 85c:	8622                	mv	a2,s0
 85e:	00000097          	auipc	ra,0x0
 862:	e16080e7          	jalr	-490(ra) # 674 <vprintf>
}
 866:	60e2                	ld	ra,24(sp)
 868:	6442                	ld	s0,16(sp)
 86a:	6161                	addi	sp,sp,80
 86c:	8082                	ret

000000000000086e <printf>:

void
printf(const char *fmt, ...)
{
 86e:	711d                	addi	sp,sp,-96
 870:	ec06                	sd	ra,24(sp)
 872:	e822                	sd	s0,16(sp)
 874:	1000                	addi	s0,sp,32
 876:	e40c                	sd	a1,8(s0)
 878:	e810                	sd	a2,16(s0)
 87a:	ec14                	sd	a3,24(s0)
 87c:	f018                	sd	a4,32(s0)
 87e:	f41c                	sd	a5,40(s0)
 880:	03043823          	sd	a6,48(s0)
 884:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 888:	00840613          	addi	a2,s0,8
 88c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 890:	85aa                	mv	a1,a0
 892:	4505                	li	a0,1
 894:	00000097          	auipc	ra,0x0
 898:	de0080e7          	jalr	-544(ra) # 674 <vprintf>
}
 89c:	60e2                	ld	ra,24(sp)
 89e:	6442                	ld	s0,16(sp)
 8a0:	6125                	addi	sp,sp,96
 8a2:	8082                	ret

00000000000008a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a4:	1141                	addi	sp,sp,-16
 8a6:	e422                	sd	s0,8(sp)
 8a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ae:	00000797          	auipc	a5,0x0
 8b2:	7527b783          	ld	a5,1874(a5) # 1000 <freep>
 8b6:	a02d                	j	8e0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b8:	4618                	lw	a4,8(a2)
 8ba:	9f2d                	addw	a4,a4,a1
 8bc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	6310                	ld	a2,0(a4)
 8c4:	a83d                	j	902 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8c6:	ff852703          	lw	a4,-8(a0)
 8ca:	9f31                	addw	a4,a4,a2
 8cc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ce:	ff053683          	ld	a3,-16(a0)
 8d2:	a091                	j	916 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d4:	6398                	ld	a4,0(a5)
 8d6:	00e7e463          	bltu	a5,a4,8de <free+0x3a>
 8da:	00e6ea63          	bltu	a3,a4,8ee <free+0x4a>
{
 8de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e0:	fed7fae3          	bgeu	a5,a3,8d4 <free+0x30>
 8e4:	6398                	ld	a4,0(a5)
 8e6:	00e6e463          	bltu	a3,a4,8ee <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ea:	fee7eae3          	bltu	a5,a4,8de <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ee:	ff852583          	lw	a1,-8(a0)
 8f2:	6390                	ld	a2,0(a5)
 8f4:	02059813          	slli	a6,a1,0x20
 8f8:	01c85713          	srli	a4,a6,0x1c
 8fc:	9736                	add	a4,a4,a3
 8fe:	fae60de3          	beq	a2,a4,8b8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 902:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 906:	4790                	lw	a2,8(a5)
 908:	02061593          	slli	a1,a2,0x20
 90c:	01c5d713          	srli	a4,a1,0x1c
 910:	973e                	add	a4,a4,a5
 912:	fae68ae3          	beq	a3,a4,8c6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 916:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 918:	00000717          	auipc	a4,0x0
 91c:	6ef73423          	sd	a5,1768(a4) # 1000 <freep>
}
 920:	6422                	ld	s0,8(sp)
 922:	0141                	addi	sp,sp,16
 924:	8082                	ret

0000000000000926 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 926:	7139                	addi	sp,sp,-64
 928:	fc06                	sd	ra,56(sp)
 92a:	f822                	sd	s0,48(sp)
 92c:	f426                	sd	s1,40(sp)
 92e:	f04a                	sd	s2,32(sp)
 930:	ec4e                	sd	s3,24(sp)
 932:	e852                	sd	s4,16(sp)
 934:	e456                	sd	s5,8(sp)
 936:	e05a                	sd	s6,0(sp)
 938:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93a:	02051493          	slli	s1,a0,0x20
 93e:	9081                	srli	s1,s1,0x20
 940:	04bd                	addi	s1,s1,15
 942:	8091                	srli	s1,s1,0x4
 944:	0014899b          	addiw	s3,s1,1
 948:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 94a:	00000517          	auipc	a0,0x0
 94e:	6b653503          	ld	a0,1718(a0) # 1000 <freep>
 952:	c515                	beqz	a0,97e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 954:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 956:	4798                	lw	a4,8(a5)
 958:	02977f63          	bgeu	a4,s1,996 <malloc+0x70>
  if(nu < 4096)
 95c:	8a4e                	mv	s4,s3
 95e:	0009871b          	sext.w	a4,s3
 962:	6685                	lui	a3,0x1
 964:	00d77363          	bgeu	a4,a3,96a <malloc+0x44>
 968:	6a05                	lui	s4,0x1
 96a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 96e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 972:	00000917          	auipc	s2,0x0
 976:	68e90913          	addi	s2,s2,1678 # 1000 <freep>
  if(p == (char*)-1)
 97a:	5afd                	li	s5,-1
 97c:	a895                	j	9f0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 97e:	00001797          	auipc	a5,0x1
 982:	89278793          	addi	a5,a5,-1902 # 1210 <base>
 986:	00000717          	auipc	a4,0x0
 98a:	66f73d23          	sd	a5,1658(a4) # 1000 <freep>
 98e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 990:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 994:	b7e1                	j	95c <malloc+0x36>
      if(p->s.size == nunits)
 996:	02e48c63          	beq	s1,a4,9ce <malloc+0xa8>
        p->s.size -= nunits;
 99a:	4137073b          	subw	a4,a4,s3
 99e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a0:	02071693          	slli	a3,a4,0x20
 9a4:	01c6d713          	srli	a4,a3,0x1c
 9a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ae:	00000717          	auipc	a4,0x0
 9b2:	64a73923          	sd	a0,1618(a4) # 1000 <freep>
      return (void*)(p + 1);
 9b6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9ba:	70e2                	ld	ra,56(sp)
 9bc:	7442                	ld	s0,48(sp)
 9be:	74a2                	ld	s1,40(sp)
 9c0:	7902                	ld	s2,32(sp)
 9c2:	69e2                	ld	s3,24(sp)
 9c4:	6a42                	ld	s4,16(sp)
 9c6:	6aa2                	ld	s5,8(sp)
 9c8:	6b02                	ld	s6,0(sp)
 9ca:	6121                	addi	sp,sp,64
 9cc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ce:	6398                	ld	a4,0(a5)
 9d0:	e118                	sd	a4,0(a0)
 9d2:	bff1                	j	9ae <malloc+0x88>
  hp->s.size = nu;
 9d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d8:	0541                	addi	a0,a0,16
 9da:	00000097          	auipc	ra,0x0
 9de:	eca080e7          	jalr	-310(ra) # 8a4 <free>
  return freep;
 9e2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9e6:	d971                	beqz	a0,9ba <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ea:	4798                	lw	a4,8(a5)
 9ec:	fa9775e3          	bgeu	a4,s1,996 <malloc+0x70>
    if(p == freep)
 9f0:	00093703          	ld	a4,0(s2)
 9f4:	853e                	mv	a0,a5
 9f6:	fef719e3          	bne	a4,a5,9e8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9fa:	8552                	mv	a0,s4
 9fc:	00000097          	auipc	ra,0x0
 a00:	b62080e7          	jalr	-1182(ra) # 55e <sbrk>
  if(p == (char*)-1)
 a04:	fd5518e3          	bne	a0,s5,9d4 <malloc+0xae>
        return 0;
 a08:	4501                	li	a0,0
 a0a:	bf45                	j	9ba <malloc+0x94>
