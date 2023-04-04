
user/_schedtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <alphabet>:
    }
    return 1;
}

void alphabet()
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
   6:	009507b7          	lui	a5,0x950
   a:	2f978793          	addi	a5,a5,761 # 9502f9 <base+0x94f2c9>
   e:	07aa                	slli	a5,a5,0xa
    for(unsigned long i = 0; i < MAX ; i++);
  10:	17fd                	addi	a5,a5,-1
  12:	fffd                	bnez	a5,10 <alphabet+0x10>
}
  14:	6422                	ld	s0,8(sp)
  16:	0141                	addi	sp,sp,16
  18:	8082                	ret

000000000000001a <validate>:
{
  1a:	1141                	addi	sp,sp,-16
  1c:	e406                	sd	ra,8(sp)
  1e:	e022                	sd	s0,0(sp)
  20:	0800                	addi	s0,sp,16
    if(argc != 2){
  22:	4789                	li	a5,2
  24:	00f50f63          	beq	a0,a5,42 <validate+0x28>
        printf("Usage: ./schedtest <# Num Children>\n");
  28:	00001517          	auipc	a0,0x1
  2c:	c2850513          	addi	a0,a0,-984 # c50 <malloc+0xe8>
  30:	00001097          	auipc	ra,0x1
  34:	a80080e7          	jalr	-1408(ra) # ab0 <printf>
        return 0;
  38:	4501                	li	a0,0
}
  3a:	60a2                	ld	ra,8(sp)
  3c:	6402                	ld	s0,0(sp)
  3e:	0141                	addi	sp,sp,16
  40:	8082                	ret
    n = atoi(argv[1]);
  42:	6588                	ld	a0,8(a1)
  44:	00000097          	auipc	ra,0x0
  48:	4a6080e7          	jalr	1190(ra) # 4ea <atoi>
  4c:	87aa                	mv	a5,a0
  4e:	00001717          	auipc	a4,0x1
  52:	fca72923          	sw	a0,-46(a4) # 1020 <n>
    if(n < 10) {
  56:	4725                	li	a4,9
    return 1;
  58:	4505                	li	a0,1
    if(n < 10) {
  5a:	fef740e3          	blt	a4,a5,3a <validate+0x20>
        printf("Must have at least 10 children spawned. Canceling...\n");
  5e:	00001517          	auipc	a0,0x1
  62:	c1a50513          	addi	a0,a0,-998 # c78 <malloc+0x110>
  66:	00001097          	auipc	ra,0x1
  6a:	a4a080e7          	jalr	-1462(ra) # ab0 <printf>
        return 0;
  6e:	4501                	li	a0,0
  70:	b7e9                	j	3a <validate+0x20>

0000000000000072 <do_rand>:

// from FreeBSD.
int do_rand(unsigned long *ctx)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
  78:	611c                	ld	a5,0(a0)
  7a:	80000737          	lui	a4,0x80000
  7e:	ffe74713          	xori	a4,a4,-2
  82:	02e7f7b3          	remu	a5,a5,a4
  86:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
  88:	66fd                	lui	a3,0x1f
  8a:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1e2ed>
  8e:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
  92:	6611                	lui	a2,0x4
  94:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x3177>
  98:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
  9c:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
  a0:	76fd                	lui	a3,0xfffff
  a2:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffe4bc>
  a6:	02d787b3          	mul	a5,a5,a3
  aa:	97ba                	add	a5,a5,a4
    if (x < 0)
  ac:	0007c963          	bltz	a5,be <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
  b0:	17fd                	addi	a5,a5,-1
    *ctx = x;
  b2:	e11c                	sd	a5,0(a0)
    return (x);
}
  b4:	0007851b          	sext.w	a0,a5
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret
        x += 0x7fffffff;
  be:	80000737          	lui	a4,0x80000
  c2:	fff74713          	not	a4,a4
  c6:	97ba                	add	a5,a5,a4
  c8:	b7e5                	j	b0 <do_rand+0x3e>

00000000000000ca <sendChildrenToWork>:

#define rand(next) do_rand(next)

void sendChildrenToWork(int random, void work(void))
{
  ca:	715d                	addi	sp,sp,-80
  cc:	e486                	sd	ra,72(sp)
  ce:	e0a2                	sd	s0,64(sp)
  d0:	fc26                	sd	s1,56(sp)
  d2:	f84a                	sd	s2,48(sp)
  d4:	f44e                	sd	s3,40(sp)
  d6:	f052                	sd	s4,32(sp)
  d8:	ec56                	sd	s5,24(sp)
  da:	e85a                	sd	s6,16(sp)
  dc:	0880                	addi	s0,sp,80
    for(int i = 0; i < n; i++){
  de:	00001797          	auipc	a5,0x1
  e2:	f427a783          	lw	a5,-190(a5) # 1020 <n>
  e6:	04f05563          	blez	a5,130 <sendChildrenToWork+0x66>
  ea:	8b2a                	mv	s6,a0
  ec:	8aae                	mv	s5,a1
  ee:	4481                	li	s1,0
        
        if(-1 == (pid = fork())){ // parent create child
  f0:	00001997          	auipc	s3,0x1
  f4:	f2898993          	addi	s3,s3,-216 # 1018 <pid>
  f8:	597d                	li	s2,-1
    for(int i = 0; i < n; i++){
  fa:	00001a17          	auipc	s4,0x1
  fe:	f26a0a13          	addi	s4,s4,-218 # 1020 <n>
        if(-1 == (pid = fork())){ // parent create child
 102:	00000097          	auipc	ra,0x0
 106:	60e080e7          	jalr	1550(ra) # 710 <fork>
 10a:	00a9a023          	sw	a0,0(s3)
 10e:	01250963          	beq	a0,s2,120 <sendChildrenToWork+0x56>
            printf("\nFork Error!\n");
            break;
        } else if(pid == 0){
 112:	c529                	beqz	a0,15c <sendChildrenToWork+0x92>
    for(int i = 0; i < n; i++){
 114:	2485                	addiw	s1,s1,1
 116:	000a2783          	lw	a5,0(s4)
 11a:	fef4c4e3          	blt	s1,a5,102 <sendChildrenToWork+0x38>
 11e:	a005                	j	13e <sendChildrenToWork+0x74>
            printf("\nFork Error!\n");
 120:	00001517          	auipc	a0,0x1
 124:	b9050513          	addi	a0,a0,-1136 # cb0 <malloc+0x148>
 128:	00001097          	auipc	ra,0x1
 12c:	988080e7          	jalr	-1656(ra) # ab0 <printf>

            exit(prepri);

        }
    }
    if(pid == -1)
 130:	00001717          	auipc	a4,0x1
 134:	ee872703          	lw	a4,-280(a4) # 1018 <pid>
 138:	57fd                	li	a5,-1
 13a:	10f70563          	beq	a4,a5,244 <sendChildrenToWork+0x17a>
        exit(1);

    write(trapC[1], (char *) 0, 1); // release the children
 13e:	4605                	li	a2,1
 140:	4581                	li	a1,0
 142:	00001517          	auipc	a0,0x1
 146:	ed252503          	lw	a0,-302(a0) # 1014 <trapC+0x4>
 14a:	00000097          	auipc	ra,0x0
 14e:	5ee080e7          	jalr	1518(ra) # 738 <write>

    int status, corpse;
    while((corpse = wait(&status)) > 0)
        printf("Child %d Done with work (priority 0x%x)\n", corpse, status);
 152:	00001497          	auipc	s1,0x1
 156:	b9648493          	addi	s1,s1,-1130 # ce8 <malloc+0x180>
    while((corpse = wait(&status)) > 0)
 15a:	a209                	j	25c <sendChildrenToWork+0x192>
            whoami = getpid();
 15c:	00000097          	auipc	ra,0x0
 160:	63c080e7          	jalr	1596(ra) # 798 <getpid>
 164:	00001717          	auipc	a4,0x1
 168:	eaa72c23          	sw	a0,-328(a4) # 101c <whoami>
            rand_next = whoami;
 16c:	00001917          	auipc	s2,0x1
 170:	e9490913          	addi	s2,s2,-364 # 1000 <rand_next>
 174:	00a93023          	sd	a0,0(s2)
            int prepri = getpri();
 178:	00000097          	auipc	ra,0x0
 17c:	660080e7          	jalr	1632(ra) # 7d8 <getpri>
 180:	84aa                	mv	s1,a0
            int thresh = ((rand(&rand_next) % 100)+n);
 182:	854a                	mv	a0,s2
 184:	00000097          	auipc	ra,0x0
 188:	eee080e7          	jalr	-274(ra) # 72 <do_rand>
            if(random){ 
 18c:	000b0f63          	beqz	s6,1aa <sendChildrenToWork+0xe0>
            int thresh = ((rand(&rand_next) % 100)+n);
 190:	06400713          	li	a4,100
 194:	02e567bb          	remw	a5,a0,a4
 198:	00001717          	auipc	a4,0x1
 19c:	e8872703          	lw	a4,-376(a4) # 1020 <n>
                if(thresh > 50){
 1a0:	9fb9                	addw	a5,a5,a4
 1a2:	03200713          	li	a4,50
 1a6:	04f74863          	blt	a4,a5,1f6 <sendChildrenToWork+0x12c>
            read(trapC[0], 0, 1);
 1aa:	00001917          	auipc	s2,0x1
 1ae:	e6690913          	addi	s2,s2,-410 # 1010 <trapC>
 1b2:	4605                	li	a2,1
 1b4:	4581                	li	a1,0
 1b6:	00092503          	lw	a0,0(s2)
 1ba:	00000097          	auipc	ra,0x0
 1be:	576080e7          	jalr	1398(ra) # 730 <read>
            write(trapC[1], 0, 1);
 1c2:	4605                	li	a2,1
 1c4:	4581                	li	a1,0
 1c6:	00492503          	lw	a0,4(s2)
 1ca:	00000097          	auipc	ra,0x0
 1ce:	56e080e7          	jalr	1390(ra) # 738 <write>
            close(trapC[0]);
 1d2:	00092503          	lw	a0,0(s2)
 1d6:	00000097          	auipc	ra,0x0
 1da:	56a080e7          	jalr	1386(ra) # 740 <close>
            close(trapC[1]);
 1de:	00492503          	lw	a0,4(s2)
 1e2:	00000097          	auipc	ra,0x0
 1e6:	55e080e7          	jalr	1374(ra) # 740 <close>
            (*work)();             
 1ea:	9a82                	jalr	s5
            exit(prepri);
 1ec:	8526                	mv	a0,s1
 1ee:	00000097          	auipc	ra,0x0
 1f2:	52a080e7          	jalr	1322(ra) # 718 <exit>
                    thresh = (rand(&rand_next) % 5);   
 1f6:	854a                	mv	a0,s2
 1f8:	00000097          	auipc	ra,0x0
 1fc:	e7a080e7          	jalr	-390(ra) # 72 <do_rand>
                    setpri(prio[thresh]); // Request to change my priority.
 200:	4715                	li	a4,5
 202:	02e567bb          	remw	a5,a0,a4
 206:	078a                	slli	a5,a5,0x2
 208:	00001717          	auipc	a4,0x1
 20c:	bb870713          	addi	a4,a4,-1096 # dc0 <prio>
 210:	97ba                	add	a5,a5,a4
 212:	4388                	lw	a0,0(a5)
 214:	00000097          	auipc	ra,0x0
 218:	5cc080e7          	jalr	1484(ra) # 7e0 <setpri>
                        printf("Updated Priority of %d, priority: 0x%x\n", whoami, (prepri=getpri()));
 21c:	00001917          	auipc	s2,0x1
 220:	e0092903          	lw	s2,-512(s2) # 101c <whoami>
 224:	00000097          	auipc	ra,0x0
 228:	5b4080e7          	jalr	1460(ra) # 7d8 <getpri>
 22c:	84aa                	mv	s1,a0
 22e:	862a                	mv	a2,a0
 230:	85ca                	mv	a1,s2
 232:	00001517          	auipc	a0,0x1
 236:	a8e50513          	addi	a0,a0,-1394 # cc0 <malloc+0x158>
 23a:	00001097          	auipc	ra,0x1
 23e:	876080e7          	jalr	-1930(ra) # ab0 <printf>
 242:	b7a5                	j	1aa <sendChildrenToWork+0xe0>
        exit(1);
 244:	4505                	li	a0,1
 246:	00000097          	auipc	ra,0x0
 24a:	4d2080e7          	jalr	1234(ra) # 718 <exit>
        printf("Child %d Done with work (priority 0x%x)\n", corpse, status);
 24e:	fbc42603          	lw	a2,-68(s0)
 252:	8526                	mv	a0,s1
 254:	00001097          	auipc	ra,0x1
 258:	85c080e7          	jalr	-1956(ra) # ab0 <printf>
    while((corpse = wait(&status)) > 0)
 25c:	fbc40513          	addi	a0,s0,-68
 260:	00000097          	auipc	ra,0x0
 264:	4c0080e7          	jalr	1216(ra) # 720 <wait>
 268:	85aa                	mv	a1,a0
 26a:	fea042e3          	bgtz	a0,24e <sendChildrenToWork+0x184>
}
 26e:	60a6                	ld	ra,72(sp)
 270:	6406                	ld	s0,64(sp)
 272:	74e2                	ld	s1,56(sp)
 274:	7942                	ld	s2,48(sp)
 276:	79a2                	ld	s3,40(sp)
 278:	7a02                	ld	s4,32(sp)
 27a:	6ae2                	ld	s5,24(sp)
 27c:	6b42                	ld	s6,16(sp)
 27e:	6161                	addi	sp,sp,80
 280:	8082                	ret

0000000000000282 <main>:


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
 282:	7139                	addi	sp,sp,-64
 284:	fc06                	sd	ra,56(sp)
 286:	f822                	sd	s0,48(sp)
 288:	f426                	sd	s1,40(sp)
 28a:	f04a                	sd	s2,32(sp)
 28c:	ec4e                	sd	s3,24(sp)
 28e:	e852                	sd	s4,16(sp)
 290:	e456                	sd	s5,8(sp)
 292:	e05a                	sd	s6,0(sp)
 294:	0080                	addi	s0,sp,64
    if(!validate(argc, argv)) return 0;
 296:	00000097          	auipc	ra,0x0
 29a:	d84080e7          	jalr	-636(ra) # 1a <validate>
 29e:	ed01                	bnez	a0,2b6 <main+0x34>

        printf("(Applying Ranomization) Priority Test: 0x%x\n", prio[p]);
        sendChildrenToWork(1, alphabet);
   }
   return 0;
}
 2a0:	4501                	li	a0,0
 2a2:	70e2                	ld	ra,56(sp)
 2a4:	7442                	ld	s0,48(sp)
 2a6:	74a2                	ld	s1,40(sp)
 2a8:	7902                	ld	s2,32(sp)
 2aa:	69e2                	ld	s3,24(sp)
 2ac:	6a42                	ld	s4,16(sp)
 2ae:	6aa2                	ld	s5,8(sp)
 2b0:	6b02                	ld	s6,0(sp)
 2b2:	6121                	addi	sp,sp,64
 2b4:	8082                	ret
   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
 2b6:	00001517          	auipc	a0,0x1
 2ba:	a6250513          	addi	a0,a0,-1438 # d18 <malloc+0x1b0>
 2be:	00000097          	auipc	ra,0x0
 2c2:	7f2080e7          	jalr	2034(ra) # ab0 <printf>
   whoami = -1; // parent
 2c6:	57fd                	li	a5,-1
 2c8:	00001717          	auipc	a4,0x1
 2cc:	d4f72a23          	sw	a5,-684(a4) # 101c <whoami>
   pid = getpid();
 2d0:	00000097          	auipc	ra,0x0
 2d4:	4c8080e7          	jalr	1224(ra) # 798 <getpid>
 2d8:	00001797          	auipc	a5,0x1
 2dc:	d4a7a023          	sw	a0,-704(a5) # 1018 <pid>
    pipe(trapC);
 2e0:	00001517          	auipc	a0,0x1
 2e4:	d3050513          	addi	a0,a0,-720 # 1010 <trapC>
 2e8:	00000097          	auipc	ra,0x0
 2ec:	440080e7          	jalr	1088(ra) # 728 <pipe>
   for(int p = 0; p < (sizeof(prio)/sizeof(prio[0])); p++){
 2f0:	00001497          	auipc	s1,0x1
 2f4:	ad048493          	addi	s1,s1,-1328 # dc0 <prio>
 2f8:	00001b17          	auipc	s6,0x1
 2fc:	adcb0b13          	addi	s6,s6,-1316 # dd4 <prio+0x14>
        printf("(Basic) Priority Test: 0x%x\n", prio[p]);
 300:	00001a97          	auipc	s5,0x1
 304:	a70a8a93          	addi	s5,s5,-1424 # d70 <malloc+0x208>
        sendChildrenToWork(0, alphabet);
 308:	00000997          	auipc	s3,0x0
 30c:	cf898993          	addi	s3,s3,-776 # 0 <alphabet>
        printf("(Applying Ranomization) Priority Test: 0x%x\n", prio[p]);
 310:	00001a17          	auipc	s4,0x1
 314:	a80a0a13          	addi	s4,s4,-1408 # d90 <malloc+0x228>
        setpri(prio[p]);
 318:	0004a903          	lw	s2,0(s1)
 31c:	854a                	mv	a0,s2
 31e:	00000097          	auipc	ra,0x0
 322:	4c2080e7          	jalr	1218(ra) # 7e0 <setpri>
        printf("(Basic) Priority Test: 0x%x\n", prio[p]);
 326:	85ca                	mv	a1,s2
 328:	8556                	mv	a0,s5
 32a:	00000097          	auipc	ra,0x0
 32e:	786080e7          	jalr	1926(ra) # ab0 <printf>
        sendChildrenToWork(0, alphabet);
 332:	85ce                	mv	a1,s3
 334:	4501                	li	a0,0
 336:	00000097          	auipc	ra,0x0
 33a:	d94080e7          	jalr	-620(ra) # ca <sendChildrenToWork>
        printf("(Applying Ranomization) Priority Test: 0x%x\n", prio[p]);
 33e:	85ca                	mv	a1,s2
 340:	8552                	mv	a0,s4
 342:	00000097          	auipc	ra,0x0
 346:	76e080e7          	jalr	1902(ra) # ab0 <printf>
        sendChildrenToWork(1, alphabet);
 34a:	85ce                	mv	a1,s3
 34c:	4505                	li	a0,1
 34e:	00000097          	auipc	ra,0x0
 352:	d7c080e7          	jalr	-644(ra) # ca <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(prio[0])); p++){
 356:	0491                	addi	s1,s1,4
 358:	fd6490e3          	bne	s1,s6,318 <main+0x96>
 35c:	b791                	j	2a0 <main+0x1e>

000000000000035e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  extern int main();
  main();
 366:	00000097          	auipc	ra,0x0
 36a:	f1c080e7          	jalr	-228(ra) # 282 <main>
  exit(0);
 36e:	4501                	li	a0,0
 370:	00000097          	auipc	ra,0x0
 374:	3a8080e7          	jalr	936(ra) # 718 <exit>

0000000000000378 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 37e:	87aa                	mv	a5,a0
 380:	0585                	addi	a1,a1,1
 382:	0785                	addi	a5,a5,1
 384:	fff5c703          	lbu	a4,-1(a1)
 388:	fee78fa3          	sb	a4,-1(a5)
 38c:	fb75                	bnez	a4,380 <strcpy+0x8>
    ;
  return os;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 39a:	00054783          	lbu	a5,0(a0)
 39e:	cb91                	beqz	a5,3b2 <strcmp+0x1e>
 3a0:	0005c703          	lbu	a4,0(a1)
 3a4:	00f71763          	bne	a4,a5,3b2 <strcmp+0x1e>
    p++, q++;
 3a8:	0505                	addi	a0,a0,1
 3aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	fbe5                	bnez	a5,3a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3b2:	0005c503          	lbu	a0,0(a1)
}
 3b6:	40a7853b          	subw	a0,a5,a0
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <strlen>:

uint
strlen(const char *s)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3c6:	00054783          	lbu	a5,0(a0)
 3ca:	cf91                	beqz	a5,3e6 <strlen+0x26>
 3cc:	0505                	addi	a0,a0,1
 3ce:	87aa                	mv	a5,a0
 3d0:	86be                	mv	a3,a5
 3d2:	0785                	addi	a5,a5,1
 3d4:	fff7c703          	lbu	a4,-1(a5)
 3d8:	ff65                	bnez	a4,3d0 <strlen+0x10>
 3da:	40a6853b          	subw	a0,a3,a0
 3de:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
  for(n = 0; s[n]; n++)
 3e6:	4501                	li	a0,0
 3e8:	bfe5                	j	3e0 <strlen+0x20>

00000000000003ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3f0:	ca19                	beqz	a2,406 <memset+0x1c>
 3f2:	87aa                	mv	a5,a0
 3f4:	1602                	slli	a2,a2,0x20
 3f6:	9201                	srli	a2,a2,0x20
 3f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 400:	0785                	addi	a5,a5,1
 402:	fee79de3          	bne	a5,a4,3fc <memset+0x12>
  }
  return dst;
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret

000000000000040c <strchr>:

char*
strchr(const char *s, char c)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  for(; *s; s++)
 412:	00054783          	lbu	a5,0(a0)
 416:	cb99                	beqz	a5,42c <strchr+0x20>
    if(*s == c)
 418:	00f58763          	beq	a1,a5,426 <strchr+0x1a>
  for(; *s; s++)
 41c:	0505                	addi	a0,a0,1
 41e:	00054783          	lbu	a5,0(a0)
 422:	fbfd                	bnez	a5,418 <strchr+0xc>
      return (char*)s;
  return 0;
 424:	4501                	li	a0,0
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  return 0;
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <strchr+0x1a>

0000000000000430 <gets>:

char*
gets(char *buf, int max)
{
 430:	711d                	addi	sp,sp,-96
 432:	ec86                	sd	ra,88(sp)
 434:	e8a2                	sd	s0,80(sp)
 436:	e4a6                	sd	s1,72(sp)
 438:	e0ca                	sd	s2,64(sp)
 43a:	fc4e                	sd	s3,56(sp)
 43c:	f852                	sd	s4,48(sp)
 43e:	f456                	sd	s5,40(sp)
 440:	f05a                	sd	s6,32(sp)
 442:	ec5e                	sd	s7,24(sp)
 444:	1080                	addi	s0,sp,96
 446:	8baa                	mv	s7,a0
 448:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 44a:	892a                	mv	s2,a0
 44c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 44e:	4aa9                	li	s5,10
 450:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 452:	89a6                	mv	s3,s1
 454:	2485                	addiw	s1,s1,1
 456:	0344d863          	bge	s1,s4,486 <gets+0x56>
    cc = read(0, &c, 1);
 45a:	4605                	li	a2,1
 45c:	faf40593          	addi	a1,s0,-81
 460:	4501                	li	a0,0
 462:	00000097          	auipc	ra,0x0
 466:	2ce080e7          	jalr	718(ra) # 730 <read>
    if(cc < 1)
 46a:	00a05e63          	blez	a0,486 <gets+0x56>
    buf[i++] = c;
 46e:	faf44783          	lbu	a5,-81(s0)
 472:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 476:	01578763          	beq	a5,s5,484 <gets+0x54>
 47a:	0905                	addi	s2,s2,1
 47c:	fd679be3          	bne	a5,s6,452 <gets+0x22>
  for(i=0; i+1 < max; ){
 480:	89a6                	mv	s3,s1
 482:	a011                	j	486 <gets+0x56>
 484:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 486:	99de                	add	s3,s3,s7
 488:	00098023          	sb	zero,0(s3)
  return buf;
}
 48c:	855e                	mv	a0,s7
 48e:	60e6                	ld	ra,88(sp)
 490:	6446                	ld	s0,80(sp)
 492:	64a6                	ld	s1,72(sp)
 494:	6906                	ld	s2,64(sp)
 496:	79e2                	ld	s3,56(sp)
 498:	7a42                	ld	s4,48(sp)
 49a:	7aa2                	ld	s5,40(sp)
 49c:	7b02                	ld	s6,32(sp)
 49e:	6be2                	ld	s7,24(sp)
 4a0:	6125                	addi	sp,sp,96
 4a2:	8082                	ret

00000000000004a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 4a4:	1101                	addi	sp,sp,-32
 4a6:	ec06                	sd	ra,24(sp)
 4a8:	e822                	sd	s0,16(sp)
 4aa:	e426                	sd	s1,8(sp)
 4ac:	e04a                	sd	s2,0(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4b2:	4581                	li	a1,0
 4b4:	00000097          	auipc	ra,0x0
 4b8:	2a4080e7          	jalr	676(ra) # 758 <open>
  if(fd < 0)
 4bc:	02054563          	bltz	a0,4e6 <stat+0x42>
 4c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4c2:	85ca                	mv	a1,s2
 4c4:	00000097          	auipc	ra,0x0
 4c8:	2ac080e7          	jalr	684(ra) # 770 <fstat>
 4cc:	892a                	mv	s2,a0
  close(fd);
 4ce:	8526                	mv	a0,s1
 4d0:	00000097          	auipc	ra,0x0
 4d4:	270080e7          	jalr	624(ra) # 740 <close>
  return r;
}
 4d8:	854a                	mv	a0,s2
 4da:	60e2                	ld	ra,24(sp)
 4dc:	6442                	ld	s0,16(sp)
 4de:	64a2                	ld	s1,8(sp)
 4e0:	6902                	ld	s2,0(sp)
 4e2:	6105                	addi	sp,sp,32
 4e4:	8082                	ret
    return -1;
 4e6:	597d                	li	s2,-1
 4e8:	bfc5                	j	4d8 <stat+0x34>

00000000000004ea <atoi>:

int
atoi(const char *s)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e422                	sd	s0,8(sp)
 4ee:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 4f0:	00054683          	lbu	a3,0(a0)
 4f4:	fd06879b          	addiw	a5,a3,-48
 4f8:	0ff7f793          	zext.b	a5,a5
 4fc:	4625                	li	a2,9
 4fe:	02f66863          	bltu	a2,a5,52e <atoi+0x44>
 502:	872a                	mv	a4,a0
  n = 0;
 504:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 506:	0705                	addi	a4,a4,1
 508:	0025179b          	slliw	a5,a0,0x2
 50c:	9fa9                	addw	a5,a5,a0
 50e:	0017979b          	slliw	a5,a5,0x1
 512:	9fb5                	addw	a5,a5,a3
 514:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 518:	00074683          	lbu	a3,0(a4)
 51c:	fd06879b          	addiw	a5,a3,-48
 520:	0ff7f793          	zext.b	a5,a5
 524:	fef671e3          	bgeu	a2,a5,506 <atoi+0x1c>

  return n;
}
 528:	6422                	ld	s0,8(sp)
 52a:	0141                	addi	sp,sp,16
 52c:	8082                	ret
  n = 0;
 52e:	4501                	li	a0,0
 530:	bfe5                	j	528 <atoi+0x3e>

0000000000000532 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
 538:	8eaa                	mv	t4,a0
    register const char *s = strt;
 53a:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 53c:	02000693          	li	a3,32
        c = *s++;
 540:	883e                	mv	a6,a5
 542:	0785                	addi	a5,a5,1
 544:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 548:	fed70ce3          	beq	a4,a3,540 <strtoi+0xe>
        c = *s++;
 54c:	2701                	sext.w	a4,a4

    if (c == '-') {
 54e:	02d00693          	li	a3,45
 552:	04d70d63          	beq	a4,a3,5ac <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 556:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 55a:	4f01                	li	t5,0
    } else if (c == '+')
 55c:	04d70e63          	beq	a4,a3,5b8 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 560:	fef67693          	andi	a3,a2,-17
 564:	ea99                	bnez	a3,57a <strtoi+0x48>
 566:	03000693          	li	a3,48
 56a:	04d70c63          	beq	a4,a3,5c2 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 56e:	e611                	bnez	a2,57a <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 570:	03000693          	li	a3,48
 574:	0cd70b63          	beq	a4,a3,64a <strtoi+0x118>
 578:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 57a:	800008b7          	lui	a7,0x80000
 57e:	fff8c893          	not	a7,a7
 582:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 586:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 58a:	1882                	slli	a7,a7,0x20
 58c:	0208d893          	srli	a7,a7,0x20
 590:	02c8d8b3          	divu	a7,a7,a2
 594:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 598:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 59c:	0ac75163          	bge	a4,a2,63e <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 5a0:	4681                	li	a3,0
 5a2:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 5a4:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 5a6:	2881                	sext.w	a7,a7
        else {
            any = 1;
 5a8:	4f85                	li	t6,1
 5aa:	a0a9                	j	5f4 <strtoi+0xc2>
        c = *s++;
 5ac:	0007c703          	lbu	a4,0(a5)
 5b0:	00280793          	addi	a5,a6,2
        neg = 1;
 5b4:	4f05                	li	t5,1
 5b6:	b76d                	j	560 <strtoi+0x2e>
        c = *s++;
 5b8:	0007c703          	lbu	a4,0(a5)
 5bc:	00280793          	addi	a5,a6,2
 5c0:	b745                	j	560 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 5c2:	0007c683          	lbu	a3,0(a5)
 5c6:	0df6f693          	andi	a3,a3,223
 5ca:	05800513          	li	a0,88
 5ce:	faa690e3          	bne	a3,a0,56e <strtoi+0x3c>
        c = s[1];
 5d2:	0017c703          	lbu	a4,1(a5)
        s += 2;
 5d6:	0789                	addi	a5,a5,2
        base = 16;
 5d8:	4641                	li	a2,16
 5da:	b745                	j	57a <strtoi+0x48>
            any = -1;
 5dc:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 5de:	00e2c463          	blt	t0,a4,5e6 <strtoi+0xb4>
 5e2:	a015                	j	606 <strtoi+0xd4>
            any = -1;
 5e4:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 5e6:	0785                	addi	a5,a5,1
 5e8:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 5ec:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 5f0:	02c75063          	bge	a4,a2,610 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 5f4:	fe06c8e3          	bltz	a3,5e4 <strtoi+0xb2>
 5f8:	0005081b          	sext.w	a6,a0
            any = -1;
 5fc:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 5fe:	ff0e64e3          	bltu	t3,a6,5e6 <strtoi+0xb4>
 602:	fca88de3          	beq	a7,a0,5dc <strtoi+0xaa>
            acc *= base;
 606:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 60a:	9d39                	addw	a0,a0,a4
            any = 1;
 60c:	86fe                	mv	a3,t6
 60e:	bfe1                	j	5e6 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 610:	0006cd63          	bltz	a3,62a <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 614:	000f0463          	beqz	t5,61c <strtoi+0xea>
        acc = -acc;
 618:	40a0053b          	negw	a0,a0
    if (end != 0)
 61c:	c581                	beqz	a1,624 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 61e:	ee89                	bnez	a3,638 <strtoi+0x106>
 620:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 624:	6422                	ld	s0,8(sp)
 626:	0141                	addi	sp,sp,16
 628:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 62a:	000f1d63          	bnez	t5,644 <strtoi+0x112>
 62e:	80000537          	lui	a0,0x80000
 632:	fff54513          	not	a0,a0
    if (end != 0)
 636:	d5fd                	beqz	a1,624 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 638:	fff78e93          	addi	t4,a5,-1
 63c:	b7d5                	j	620 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 63e:	4681                	li	a3,0
 640:	4501                	li	a0,0
 642:	bfc9                	j	614 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 644:	80000537          	lui	a0,0x80000
 648:	b7fd                	j	636 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 64a:	80000e37          	lui	t3,0x80000
 64e:	fffe4e13          	not	t3,t3
 652:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 656:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 65a:	003e589b          	srliw	a7,t3,0x3
 65e:	8e46                	mv	t3,a7
            c -= '0';
 660:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 662:	4621                	li	a2,8
 664:	bf35                	j	5a0 <strtoi+0x6e>

0000000000000666 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 666:	1141                	addi	sp,sp,-16
 668:	e422                	sd	s0,8(sp)
 66a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 66c:	02b57463          	bgeu	a0,a1,694 <memmove+0x2e>
    while(n-- > 0)
 670:	00c05f63          	blez	a2,68e <memmove+0x28>
 674:	1602                	slli	a2,a2,0x20
 676:	9201                	srli	a2,a2,0x20
 678:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 67c:	872a                	mv	a4,a0
      *dst++ = *src++;
 67e:	0585                	addi	a1,a1,1
 680:	0705                	addi	a4,a4,1
 682:	fff5c683          	lbu	a3,-1(a1)
 686:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 68a:	fee79ae3          	bne	a5,a4,67e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 68e:	6422                	ld	s0,8(sp)
 690:	0141                	addi	sp,sp,16
 692:	8082                	ret
    dst += n;
 694:	00c50733          	add	a4,a0,a2
    src += n;
 698:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 69a:	fec05ae3          	blez	a2,68e <memmove+0x28>
 69e:	fff6079b          	addiw	a5,a2,-1
 6a2:	1782                	slli	a5,a5,0x20
 6a4:	9381                	srli	a5,a5,0x20
 6a6:	fff7c793          	not	a5,a5
 6aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6ac:	15fd                	addi	a1,a1,-1
 6ae:	177d                	addi	a4,a4,-1
 6b0:	0005c683          	lbu	a3,0(a1)
 6b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6b8:	fee79ae3          	bne	a5,a4,6ac <memmove+0x46>
 6bc:	bfc9                	j	68e <memmove+0x28>

00000000000006be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6be:	1141                	addi	sp,sp,-16
 6c0:	e422                	sd	s0,8(sp)
 6c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6c4:	ca05                	beqz	a2,6f4 <memcmp+0x36>
 6c6:	fff6069b          	addiw	a3,a2,-1
 6ca:	1682                	slli	a3,a3,0x20
 6cc:	9281                	srli	a3,a3,0x20
 6ce:	0685                	addi	a3,a3,1
 6d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6d2:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffefd0>
 6d6:	0005c703          	lbu	a4,0(a1)
 6da:	00e79863          	bne	a5,a4,6ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6de:	0505                	addi	a0,a0,1
    p2++;
 6e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6e2:	fed518e3          	bne	a0,a3,6d2 <memcmp+0x14>
  }
  return 0;
 6e6:	4501                	li	a0,0
 6e8:	a019                	j	6ee <memcmp+0x30>
      return *p1 - *p2;
 6ea:	40e7853b          	subw	a0,a5,a4
}
 6ee:	6422                	ld	s0,8(sp)
 6f0:	0141                	addi	sp,sp,16
 6f2:	8082                	ret
  return 0;
 6f4:	4501                	li	a0,0
 6f6:	bfe5                	j	6ee <memcmp+0x30>

00000000000006f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6f8:	1141                	addi	sp,sp,-16
 6fa:	e406                	sd	ra,8(sp)
 6fc:	e022                	sd	s0,0(sp)
 6fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 700:	00000097          	auipc	ra,0x0
 704:	f66080e7          	jalr	-154(ra) # 666 <memmove>
}
 708:	60a2                	ld	ra,8(sp)
 70a:	6402                	ld	s0,0(sp)
 70c:	0141                	addi	sp,sp,16
 70e:	8082                	ret

0000000000000710 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 710:	4885                	li	a7,1
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <exit>:
.global exit
exit:
 li a7, SYS_exit
 718:	4889                	li	a7,2
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <wait>:
.global wait
wait:
 li a7, SYS_wait
 720:	488d                	li	a7,3
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 728:	4891                	li	a7,4
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <read>:
.global read
read:
 li a7, SYS_read
 730:	4895                	li	a7,5
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <write>:
.global write
write:
 li a7, SYS_write
 738:	48c1                	li	a7,16
 ecall
 73a:	00000073          	ecall
 ret
 73e:	8082                	ret

0000000000000740 <close>:
.global close
close:
 li a7, SYS_close
 740:	48d5                	li	a7,21
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <kill>:
.global kill
kill:
 li a7, SYS_kill
 748:	4899                	li	a7,6
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <exec>:
.global exec
exec:
 li a7, SYS_exec
 750:	489d                	li	a7,7
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <open>:
.global open
open:
 li a7, SYS_open
 758:	48bd                	li	a7,15
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 760:	48c5                	li	a7,17
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 768:	48c9                	li	a7,18
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 770:	48a1                	li	a7,8
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <link>:
.global link
link:
 li a7, SYS_link
 778:	48cd                	li	a7,19
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 780:	48d1                	li	a7,20
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 788:	48a5                	li	a7,9
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <dup>:
.global dup
dup:
 li a7, SYS_dup
 790:	48a9                	li	a7,10
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 798:	48ad                	li	a7,11
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7a0:	48b1                	li	a7,12
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7a8:	48b5                	li	a7,13
 ecall
 7aa:	00000073          	ecall
 ret
 7ae:	8082                	ret

00000000000007b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7b0:	48b9                	li	a7,14
 ecall
 7b2:	00000073          	ecall
 ret
 7b6:	8082                	ret

00000000000007b8 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 7b8:	48d9                	li	a7,22
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 7c0:	48dd                	li	a7,23
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 7c8:	48e1                	li	a7,24
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 7d0:	48e5                	li	a7,25
 ecall
 7d2:	00000073          	ecall
 ret
 7d6:	8082                	ret

00000000000007d8 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 7d8:	48e9                	li	a7,26
 ecall
 7da:	00000073          	ecall
 ret
 7de:	8082                	ret

00000000000007e0 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 7e0:	48ed                	li	a7,27
 ecall
 7e2:	00000073          	ecall
 ret
 7e6:	8082                	ret

00000000000007e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7e8:	1101                	addi	sp,sp,-32
 7ea:	ec06                	sd	ra,24(sp)
 7ec:	e822                	sd	s0,16(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7f4:	4605                	li	a2,1
 7f6:	fef40593          	addi	a1,s0,-17
 7fa:	00000097          	auipc	ra,0x0
 7fe:	f3e080e7          	jalr	-194(ra) # 738 <write>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6105                	addi	sp,sp,32
 808:	8082                	ret

000000000000080a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 80a:	7139                	addi	sp,sp,-64
 80c:	fc06                	sd	ra,56(sp)
 80e:	f822                	sd	s0,48(sp)
 810:	f426                	sd	s1,40(sp)
 812:	f04a                	sd	s2,32(sp)
 814:	ec4e                	sd	s3,24(sp)
 816:	0080                	addi	s0,sp,64
 818:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 81a:	c299                	beqz	a3,820 <printint+0x16>
 81c:	0805c963          	bltz	a1,8ae <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 820:	2581                	sext.w	a1,a1
  neg = 0;
 822:	4881                	li	a7,0
 824:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 828:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 82a:	2601                	sext.w	a2,a2
 82c:	00000517          	auipc	a0,0x0
 830:	60c50513          	addi	a0,a0,1548 # e38 <digits>
 834:	883a                	mv	a6,a4
 836:	2705                	addiw	a4,a4,1
 838:	02c5f7bb          	remuw	a5,a1,a2
 83c:	1782                	slli	a5,a5,0x20
 83e:	9381                	srli	a5,a5,0x20
 840:	97aa                	add	a5,a5,a0
 842:	0007c783          	lbu	a5,0(a5)
 846:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 84a:	0005879b          	sext.w	a5,a1
 84e:	02c5d5bb          	divuw	a1,a1,a2
 852:	0685                	addi	a3,a3,1
 854:	fec7f0e3          	bgeu	a5,a2,834 <printint+0x2a>
  if(neg)
 858:	00088c63          	beqz	a7,870 <printint+0x66>
    buf[i++] = '-';
 85c:	fd070793          	addi	a5,a4,-48
 860:	00878733          	add	a4,a5,s0
 864:	02d00793          	li	a5,45
 868:	fef70823          	sb	a5,-16(a4)
 86c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 870:	02e05863          	blez	a4,8a0 <printint+0x96>
 874:	fc040793          	addi	a5,s0,-64
 878:	00e78933          	add	s2,a5,a4
 87c:	fff78993          	addi	s3,a5,-1
 880:	99ba                	add	s3,s3,a4
 882:	377d                	addiw	a4,a4,-1
 884:	1702                	slli	a4,a4,0x20
 886:	9301                	srli	a4,a4,0x20
 888:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 88c:	fff94583          	lbu	a1,-1(s2)
 890:	8526                	mv	a0,s1
 892:	00000097          	auipc	ra,0x0
 896:	f56080e7          	jalr	-170(ra) # 7e8 <putc>
  while(--i >= 0)
 89a:	197d                	addi	s2,s2,-1
 89c:	ff3918e3          	bne	s2,s3,88c <printint+0x82>
}
 8a0:	70e2                	ld	ra,56(sp)
 8a2:	7442                	ld	s0,48(sp)
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	7902                	ld	s2,32(sp)
 8a8:	69e2                	ld	s3,24(sp)
 8aa:	6121                	addi	sp,sp,64
 8ac:	8082                	ret
    x = -xx;
 8ae:	40b005bb          	negw	a1,a1
    neg = 1;
 8b2:	4885                	li	a7,1
    x = -xx;
 8b4:	bf85                	j	824 <printint+0x1a>

00000000000008b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	e486                	sd	ra,72(sp)
 8ba:	e0a2                	sd	s0,64(sp)
 8bc:	fc26                	sd	s1,56(sp)
 8be:	f84a                	sd	s2,48(sp)
 8c0:	f44e                	sd	s3,40(sp)
 8c2:	f052                	sd	s4,32(sp)
 8c4:	ec56                	sd	s5,24(sp)
 8c6:	e85a                	sd	s6,16(sp)
 8c8:	e45e                	sd	s7,8(sp)
 8ca:	e062                	sd	s8,0(sp)
 8cc:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8ce:	0005c903          	lbu	s2,0(a1)
 8d2:	18090c63          	beqz	s2,a6a <vprintf+0x1b4>
 8d6:	8aaa                	mv	s5,a0
 8d8:	8bb2                	mv	s7,a2
 8da:	00158493          	addi	s1,a1,1
  state = 0;
 8de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8e0:	02500a13          	li	s4,37
 8e4:	4b55                	li	s6,21
 8e6:	a839                	j	904 <vprintf+0x4e>
        putc(fd, c);
 8e8:	85ca                	mv	a1,s2
 8ea:	8556                	mv	a0,s5
 8ec:	00000097          	auipc	ra,0x0
 8f0:	efc080e7          	jalr	-260(ra) # 7e8 <putc>
 8f4:	a019                	j	8fa <vprintf+0x44>
    } else if(state == '%'){
 8f6:	01498d63          	beq	s3,s4,910 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 8fa:	0485                	addi	s1,s1,1
 8fc:	fff4c903          	lbu	s2,-1(s1)
 900:	16090563          	beqz	s2,a6a <vprintf+0x1b4>
    if(state == 0){
 904:	fe0999e3          	bnez	s3,8f6 <vprintf+0x40>
      if(c == '%'){
 908:	ff4910e3          	bne	s2,s4,8e8 <vprintf+0x32>
        state = '%';
 90c:	89d2                	mv	s3,s4
 90e:	b7f5                	j	8fa <vprintf+0x44>
      if(c == 'd'){
 910:	13490263          	beq	s2,s4,a34 <vprintf+0x17e>
 914:	f9d9079b          	addiw	a5,s2,-99
 918:	0ff7f793          	zext.b	a5,a5
 91c:	12fb6563          	bltu	s6,a5,a46 <vprintf+0x190>
 920:	f9d9079b          	addiw	a5,s2,-99
 924:	0ff7f713          	zext.b	a4,a5
 928:	10eb6f63          	bltu	s6,a4,a46 <vprintf+0x190>
 92c:	00271793          	slli	a5,a4,0x2
 930:	00000717          	auipc	a4,0x0
 934:	4b070713          	addi	a4,a4,1200 # de0 <prio+0x20>
 938:	97ba                	add	a5,a5,a4
 93a:	439c                	lw	a5,0(a5)
 93c:	97ba                	add	a5,a5,a4
 93e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 940:	008b8913          	addi	s2,s7,8
 944:	4685                	li	a3,1
 946:	4629                	li	a2,10
 948:	000ba583          	lw	a1,0(s7)
 94c:	8556                	mv	a0,s5
 94e:	00000097          	auipc	ra,0x0
 952:	ebc080e7          	jalr	-324(ra) # 80a <printint>
 956:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 958:	4981                	li	s3,0
 95a:	b745                	j	8fa <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 95c:	008b8913          	addi	s2,s7,8
 960:	4681                	li	a3,0
 962:	4629                	li	a2,10
 964:	000ba583          	lw	a1,0(s7)
 968:	8556                	mv	a0,s5
 96a:	00000097          	auipc	ra,0x0
 96e:	ea0080e7          	jalr	-352(ra) # 80a <printint>
 972:	8bca                	mv	s7,s2
      state = 0;
 974:	4981                	li	s3,0
 976:	b751                	j	8fa <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 978:	008b8913          	addi	s2,s7,8
 97c:	4681                	li	a3,0
 97e:	4641                	li	a2,16
 980:	000ba583          	lw	a1,0(s7)
 984:	8556                	mv	a0,s5
 986:	00000097          	auipc	ra,0x0
 98a:	e84080e7          	jalr	-380(ra) # 80a <printint>
 98e:	8bca                	mv	s7,s2
      state = 0;
 990:	4981                	li	s3,0
 992:	b7a5                	j	8fa <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 994:	008b8c13          	addi	s8,s7,8
 998:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 99c:	03000593          	li	a1,48
 9a0:	8556                	mv	a0,s5
 9a2:	00000097          	auipc	ra,0x0
 9a6:	e46080e7          	jalr	-442(ra) # 7e8 <putc>
  putc(fd, 'x');
 9aa:	07800593          	li	a1,120
 9ae:	8556                	mv	a0,s5
 9b0:	00000097          	auipc	ra,0x0
 9b4:	e38080e7          	jalr	-456(ra) # 7e8 <putc>
 9b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9ba:	00000b97          	auipc	s7,0x0
 9be:	47eb8b93          	addi	s7,s7,1150 # e38 <digits>
 9c2:	03c9d793          	srli	a5,s3,0x3c
 9c6:	97de                	add	a5,a5,s7
 9c8:	0007c583          	lbu	a1,0(a5)
 9cc:	8556                	mv	a0,s5
 9ce:	00000097          	auipc	ra,0x0
 9d2:	e1a080e7          	jalr	-486(ra) # 7e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9d6:	0992                	slli	s3,s3,0x4
 9d8:	397d                	addiw	s2,s2,-1
 9da:	fe0914e3          	bnez	s2,9c2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 9de:	8be2                	mv	s7,s8
      state = 0;
 9e0:	4981                	li	s3,0
 9e2:	bf21                	j	8fa <vprintf+0x44>
        s = va_arg(ap, char*);
 9e4:	008b8993          	addi	s3,s7,8
 9e8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 9ec:	02090163          	beqz	s2,a0e <vprintf+0x158>
        while(*s != 0){
 9f0:	00094583          	lbu	a1,0(s2)
 9f4:	c9a5                	beqz	a1,a64 <vprintf+0x1ae>
          putc(fd, *s);
 9f6:	8556                	mv	a0,s5
 9f8:	00000097          	auipc	ra,0x0
 9fc:	df0080e7          	jalr	-528(ra) # 7e8 <putc>
          s++;
 a00:	0905                	addi	s2,s2,1
        while(*s != 0){
 a02:	00094583          	lbu	a1,0(s2)
 a06:	f9e5                	bnez	a1,9f6 <vprintf+0x140>
        s = va_arg(ap, char*);
 a08:	8bce                	mv	s7,s3
      state = 0;
 a0a:	4981                	li	s3,0
 a0c:	b5fd                	j	8fa <vprintf+0x44>
          s = "(null)";
 a0e:	00000917          	auipc	s2,0x0
 a12:	3ca90913          	addi	s2,s2,970 # dd8 <prio+0x18>
        while(*s != 0){
 a16:	02800593          	li	a1,40
 a1a:	bff1                	j	9f6 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 a1c:	008b8913          	addi	s2,s7,8
 a20:	000bc583          	lbu	a1,0(s7)
 a24:	8556                	mv	a0,s5
 a26:	00000097          	auipc	ra,0x0
 a2a:	dc2080e7          	jalr	-574(ra) # 7e8 <putc>
 a2e:	8bca                	mv	s7,s2
      state = 0;
 a30:	4981                	li	s3,0
 a32:	b5e1                	j	8fa <vprintf+0x44>
        putc(fd, c);
 a34:	02500593          	li	a1,37
 a38:	8556                	mv	a0,s5
 a3a:	00000097          	auipc	ra,0x0
 a3e:	dae080e7          	jalr	-594(ra) # 7e8 <putc>
      state = 0;
 a42:	4981                	li	s3,0
 a44:	bd5d                	j	8fa <vprintf+0x44>
        putc(fd, '%');
 a46:	02500593          	li	a1,37
 a4a:	8556                	mv	a0,s5
 a4c:	00000097          	auipc	ra,0x0
 a50:	d9c080e7          	jalr	-612(ra) # 7e8 <putc>
        putc(fd, c);
 a54:	85ca                	mv	a1,s2
 a56:	8556                	mv	a0,s5
 a58:	00000097          	auipc	ra,0x0
 a5c:	d90080e7          	jalr	-624(ra) # 7e8 <putc>
      state = 0;
 a60:	4981                	li	s3,0
 a62:	bd61                	j	8fa <vprintf+0x44>
        s = va_arg(ap, char*);
 a64:	8bce                	mv	s7,s3
      state = 0;
 a66:	4981                	li	s3,0
 a68:	bd49                	j	8fa <vprintf+0x44>
    }
  }
}
 a6a:	60a6                	ld	ra,72(sp)
 a6c:	6406                	ld	s0,64(sp)
 a6e:	74e2                	ld	s1,56(sp)
 a70:	7942                	ld	s2,48(sp)
 a72:	79a2                	ld	s3,40(sp)
 a74:	7a02                	ld	s4,32(sp)
 a76:	6ae2                	ld	s5,24(sp)
 a78:	6b42                	ld	s6,16(sp)
 a7a:	6ba2                	ld	s7,8(sp)
 a7c:	6c02                	ld	s8,0(sp)
 a7e:	6161                	addi	sp,sp,80
 a80:	8082                	ret

0000000000000a82 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a82:	715d                	addi	sp,sp,-80
 a84:	ec06                	sd	ra,24(sp)
 a86:	e822                	sd	s0,16(sp)
 a88:	1000                	addi	s0,sp,32
 a8a:	e010                	sd	a2,0(s0)
 a8c:	e414                	sd	a3,8(s0)
 a8e:	e818                	sd	a4,16(s0)
 a90:	ec1c                	sd	a5,24(s0)
 a92:	03043023          	sd	a6,32(s0)
 a96:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a9a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a9e:	8622                	mv	a2,s0
 aa0:	00000097          	auipc	ra,0x0
 aa4:	e16080e7          	jalr	-490(ra) # 8b6 <vprintf>
}
 aa8:	60e2                	ld	ra,24(sp)
 aaa:	6442                	ld	s0,16(sp)
 aac:	6161                	addi	sp,sp,80
 aae:	8082                	ret

0000000000000ab0 <printf>:

void
printf(const char *fmt, ...)
{
 ab0:	711d                	addi	sp,sp,-96
 ab2:	ec06                	sd	ra,24(sp)
 ab4:	e822                	sd	s0,16(sp)
 ab6:	1000                	addi	s0,sp,32
 ab8:	e40c                	sd	a1,8(s0)
 aba:	e810                	sd	a2,16(s0)
 abc:	ec14                	sd	a3,24(s0)
 abe:	f018                	sd	a4,32(s0)
 ac0:	f41c                	sd	a5,40(s0)
 ac2:	03043823          	sd	a6,48(s0)
 ac6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aca:	00840613          	addi	a2,s0,8
 ace:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ad2:	85aa                	mv	a1,a0
 ad4:	4505                	li	a0,1
 ad6:	00000097          	auipc	ra,0x0
 ada:	de0080e7          	jalr	-544(ra) # 8b6 <vprintf>
}
 ade:	60e2                	ld	ra,24(sp)
 ae0:	6442                	ld	s0,16(sp)
 ae2:	6125                	addi	sp,sp,96
 ae4:	8082                	ret

0000000000000ae6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ae6:	1141                	addi	sp,sp,-16
 ae8:	e422                	sd	s0,8(sp)
 aea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 af0:	00000797          	auipc	a5,0x0
 af4:	5387b783          	ld	a5,1336(a5) # 1028 <freep>
 af8:	a02d                	j	b22 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 afa:	4618                	lw	a4,8(a2)
 afc:	9f2d                	addw	a4,a4,a1
 afe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b02:	6398                	ld	a4,0(a5)
 b04:	6310                	ld	a2,0(a4)
 b06:	a83d                	j	b44 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b08:	ff852703          	lw	a4,-8(a0)
 b0c:	9f31                	addw	a4,a4,a2
 b0e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b10:	ff053683          	ld	a3,-16(a0)
 b14:	a091                	j	b58 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b16:	6398                	ld	a4,0(a5)
 b18:	00e7e463          	bltu	a5,a4,b20 <free+0x3a>
 b1c:	00e6ea63          	bltu	a3,a4,b30 <free+0x4a>
{
 b20:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b22:	fed7fae3          	bgeu	a5,a3,b16 <free+0x30>
 b26:	6398                	ld	a4,0(a5)
 b28:	00e6e463          	bltu	a3,a4,b30 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b2c:	fee7eae3          	bltu	a5,a4,b20 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 b30:	ff852583          	lw	a1,-8(a0)
 b34:	6390                	ld	a2,0(a5)
 b36:	02059813          	slli	a6,a1,0x20
 b3a:	01c85713          	srli	a4,a6,0x1c
 b3e:	9736                	add	a4,a4,a3
 b40:	fae60de3          	beq	a2,a4,afa <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b44:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b48:	4790                	lw	a2,8(a5)
 b4a:	02061593          	slli	a1,a2,0x20
 b4e:	01c5d713          	srli	a4,a1,0x1c
 b52:	973e                	add	a4,a4,a5
 b54:	fae68ae3          	beq	a3,a4,b08 <free+0x22>
    p->s.ptr = bp->s.ptr;
 b58:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b5a:	00000717          	auipc	a4,0x0
 b5e:	4cf73723          	sd	a5,1230(a4) # 1028 <freep>
}
 b62:	6422                	ld	s0,8(sp)
 b64:	0141                	addi	sp,sp,16
 b66:	8082                	ret

0000000000000b68 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b68:	7139                	addi	sp,sp,-64
 b6a:	fc06                	sd	ra,56(sp)
 b6c:	f822                	sd	s0,48(sp)
 b6e:	f426                	sd	s1,40(sp)
 b70:	f04a                	sd	s2,32(sp)
 b72:	ec4e                	sd	s3,24(sp)
 b74:	e852                	sd	s4,16(sp)
 b76:	e456                	sd	s5,8(sp)
 b78:	e05a                	sd	s6,0(sp)
 b7a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b7c:	02051493          	slli	s1,a0,0x20
 b80:	9081                	srli	s1,s1,0x20
 b82:	04bd                	addi	s1,s1,15
 b84:	8091                	srli	s1,s1,0x4
 b86:	0014899b          	addiw	s3,s1,1
 b8a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b8c:	00000517          	auipc	a0,0x0
 b90:	49c53503          	ld	a0,1180(a0) # 1028 <freep>
 b94:	c515                	beqz	a0,bc0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b96:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b98:	4798                	lw	a4,8(a5)
 b9a:	02977f63          	bgeu	a4,s1,bd8 <malloc+0x70>
  if(nu < 4096)
 b9e:	8a4e                	mv	s4,s3
 ba0:	0009871b          	sext.w	a4,s3
 ba4:	6685                	lui	a3,0x1
 ba6:	00d77363          	bgeu	a4,a3,bac <malloc+0x44>
 baa:	6a05                	lui	s4,0x1
 bac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bb0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bb4:	00000917          	auipc	s2,0x0
 bb8:	47490913          	addi	s2,s2,1140 # 1028 <freep>
  if(p == (char*)-1)
 bbc:	5afd                	li	s5,-1
 bbe:	a895                	j	c32 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 bc0:	00000797          	auipc	a5,0x0
 bc4:	47078793          	addi	a5,a5,1136 # 1030 <base>
 bc8:	00000717          	auipc	a4,0x0
 bcc:	46f73023          	sd	a5,1120(a4) # 1028 <freep>
 bd0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bd2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bd6:	b7e1                	j	b9e <malloc+0x36>
      if(p->s.size == nunits)
 bd8:	02e48c63          	beq	s1,a4,c10 <malloc+0xa8>
        p->s.size -= nunits;
 bdc:	4137073b          	subw	a4,a4,s3
 be0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 be2:	02071693          	slli	a3,a4,0x20
 be6:	01c6d713          	srli	a4,a3,0x1c
 bea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bf0:	00000717          	auipc	a4,0x0
 bf4:	42a73c23          	sd	a0,1080(a4) # 1028 <freep>
      return (void*)(p + 1);
 bf8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bfc:	70e2                	ld	ra,56(sp)
 bfe:	7442                	ld	s0,48(sp)
 c00:	74a2                	ld	s1,40(sp)
 c02:	7902                	ld	s2,32(sp)
 c04:	69e2                	ld	s3,24(sp)
 c06:	6a42                	ld	s4,16(sp)
 c08:	6aa2                	ld	s5,8(sp)
 c0a:	6b02                	ld	s6,0(sp)
 c0c:	6121                	addi	sp,sp,64
 c0e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c10:	6398                	ld	a4,0(a5)
 c12:	e118                	sd	a4,0(a0)
 c14:	bff1                	j	bf0 <malloc+0x88>
  hp->s.size = nu;
 c16:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c1a:	0541                	addi	a0,a0,16
 c1c:	00000097          	auipc	ra,0x0
 c20:	eca080e7          	jalr	-310(ra) # ae6 <free>
  return freep;
 c24:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c28:	d971                	beqz	a0,bfc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c2a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c2c:	4798                	lw	a4,8(a5)
 c2e:	fa9775e3          	bgeu	a4,s1,bd8 <malloc+0x70>
    if(p == freep)
 c32:	00093703          	ld	a4,0(s2)
 c36:	853e                	mv	a0,a5
 c38:	fef719e3          	bne	a4,a5,c2a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c3c:	8552                	mv	a0,s4
 c3e:	00000097          	auipc	ra,0x0
 c42:	b62080e7          	jalr	-1182(ra) # 7a0 <sbrk>
  if(p == (char*)-1)
 c46:	fd5518e3          	bne	a0,s5,c16 <malloc+0xae>
        return 0;
 c4a:	4501                	li	a0,0
 c4c:	bf45                	j	bfc <malloc+0x94>
