
user/_schedtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <alphabet>:
    }
    return 1;
}

void alphabet()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("%d Doing busy work...\n", whoami);
   8:	00001597          	auipc	a1,0x1
   c:	0145a583          	lw	a1,20(a1) # 101c <whoami>
  10:	00001517          	auipc	a0,0x1
  14:	cd050513          	addi	a0,a0,-816 # ce0 <malloc+0xe6>
  18:	00001097          	auipc	ra,0x1
  1c:	b2a080e7          	jalr	-1238(ra) # b42 <printf>
  20:	03200713          	li	a4,50
{
  24:	46e9                	li	a3,26
  26:	a019                	j	2c <alphabet+0x2c>
    for(int i = 0; i < 50; i++) {
  28:	377d                	addiw	a4,a4,-1
  2a:	cf01                	beqz	a4,42 <alphabet+0x42>
{
  2c:	87b6                	mv	a5,a3
        for (char a = 'a'; a <= 'z'; a++);
  2e:	37fd                	addiw	a5,a5,-1
  30:	0ff7f793          	zext.b	a5,a5
  34:	ffed                	bnez	a5,2e <alphabet+0x2e>
  36:	87b6                	mv	a5,a3
        for (char z = 'z'; z >= 'a'; z--);
  38:	37fd                	addiw	a5,a5,-1
  3a:	0ff7f793          	zext.b	a5,a5
  3e:	ffed                	bnez	a5,38 <alphabet+0x38>
  40:	b7e5                	j	28 <alphabet+0x28>
    }
}
  42:	60a2                	ld	ra,8(sp)
  44:	6402                	ld	s0,0(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <validate>:
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e406                	sd	ra,8(sp)
  4e:	e022                	sd	s0,0(sp)
  50:	0800                	addi	s0,sp,16
    if(argc != 2){
  52:	4789                	li	a5,2
  54:	00f50f63          	beq	a0,a5,72 <validate+0x28>
        printf("Usage: ./schedtest <# Num Children>\n");
  58:	00001517          	auipc	a0,0x1
  5c:	ca050513          	addi	a0,a0,-864 # cf8 <malloc+0xfe>
  60:	00001097          	auipc	ra,0x1
  64:	ae2080e7          	jalr	-1310(ra) # b42 <printf>
        return 0;
  68:	4501                	li	a0,0
}
  6a:	60a2                	ld	ra,8(sp)
  6c:	6402                	ld	s0,0(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret
    n = atoi(argv[1]);
  72:	6588                	ld	a0,8(a1)
  74:	00000097          	auipc	ra,0x0
  78:	508080e7          	jalr	1288(ra) # 57c <atoi>
  7c:	87aa                	mv	a5,a0
  7e:	00001717          	auipc	a4,0x1
  82:	faa72123          	sw	a0,-94(a4) # 1020 <n>
    if(n < 10) {
  86:	4725                	li	a4,9
    return 1;
  88:	4505                	li	a0,1
    if(n < 10) {
  8a:	fef740e3          	blt	a4,a5,6a <validate+0x20>
        printf("Must have at least 10 children spawned. Canceling...\n");
  8e:	00001517          	auipc	a0,0x1
  92:	c9250513          	addi	a0,a0,-878 # d20 <malloc+0x126>
  96:	00001097          	auipc	ra,0x1
  9a:	aac080e7          	jalr	-1364(ra) # b42 <printf>
        return 0;
  9e:	4501                	li	a0,0
  a0:	b7e9                	j	6a <validate+0x20>

00000000000000a2 <do_rand>:

// from FreeBSD.
int do_rand(unsigned long *ctx)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
  a8:	611c                	ld	a5,0(a0)
  aa:	80000737          	lui	a4,0x80000
  ae:	ffe74713          	xori	a4,a4,-2
  b2:	02e7f7b3          	remu	a5,a5,a4
  b6:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
  b8:	66fd                	lui	a3,0x1f
  ba:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1e2ed>
  be:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
  c2:	6611                	lui	a2,0x4
  c4:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x3177>
  c8:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
  cc:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
  d0:	76fd                	lui	a3,0xfffff
  d2:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffe4bc>
  d6:	02d787b3          	mul	a5,a5,a3
  da:	97ba                	add	a5,a5,a4
    if (x < 0)
  dc:	0007c963          	bltz	a5,ee <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
  e0:	17fd                	addi	a5,a5,-1
    *ctx = x;
  e2:	e11c                	sd	a5,0(a0)
    return (x);
}
  e4:	0007851b          	sext.w	a0,a5
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret
        x += 0x7fffffff;
  ee:	80000737          	lui	a4,0x80000
  f2:	fff74713          	not	a4,a4
  f6:	97ba                	add	a5,a5,a4
  f8:	b7e5                	j	e0 <do_rand+0x3e>

00000000000000fa <sendChildrenToWork>:

#define rand(next) do_rand(next)

void sendChildrenToWork(int escalate, int thresh, void work(void))
{
  fa:	7159                	addi	sp,sp,-112
  fc:	f486                	sd	ra,104(sp)
  fe:	f0a2                	sd	s0,96(sp)
 100:	eca6                	sd	s1,88(sp)
 102:	e8ca                	sd	s2,80(sp)
 104:	e4ce                	sd	s3,72(sp)
 106:	e0d2                	sd	s4,64(sp)
 108:	fc56                	sd	s5,56(sp)
 10a:	f85a                	sd	s6,48(sp)
 10c:	f45e                	sd	s7,40(sp)
 10e:	f062                	sd	s8,32(sp)
 110:	ec66                	sd	s9,24(sp)
 112:	1880                	addi	s0,sp,112
    for(int i = 0; i < n; i++){
 114:	00001797          	auipc	a5,0x1
 118:	f0c7a783          	lw	a5,-244(a5) # 1020 <n>
 11c:	06f05b63          	blez	a5,192 <sendChildrenToWork+0x98>
 120:	8c2a                	mv	s8,a0
 122:	8bae                	mv	s7,a1
 124:	8cb2                	mv	s9,a2
 126:	4481                	li	s1,0
        
        if(-1 == (pid = fork())){ // parent create child
 128:	00001997          	auipc	s3,0x1
 12c:	ef098993          	addi	s3,s3,-272 # 1018 <pid>
 130:	597d                	li	s2,-1
        
            (*work)();
            exit(0);

        } else {
            write(trap[1], "\0", 1); // release the baby!
 132:	00001b17          	auipc	s6,0x1
 136:	edeb0b13          	addi	s6,s6,-290 # 1010 <trap>
 13a:	00001a97          	auipc	s5,0x1
 13e:	d56a8a93          	addi	s5,s5,-682 # e90 <malloc+0x296>
    for(int i = 0; i < n; i++){
 142:	00001a17          	auipc	s4,0x1
 146:	edea0a13          	addi	s4,s4,-290 # 1020 <n>
        if(-1 == (pid = fork())){ // parent create child
 14a:	00000097          	auipc	ra,0x0
 14e:	658080e7          	jalr	1624(ra) # 7a2 <fork>
 152:	00a9a023          	sw	a0,0(s3)
 156:	03250663          	beq	a0,s2,182 <sendChildrenToWork+0x88>
        } else if(pid == 0){
 15a:	c125                	beqz	a0,1ba <sendChildrenToWork+0xc0>
            write(trap[1], "\0", 1); // release the baby!
 15c:	4605                	li	a2,1
 15e:	85d6                	mv	a1,s5
 160:	004b2503          	lw	a0,4(s6)
 164:	00000097          	auipc	ra,0x0
 168:	666080e7          	jalr	1638(ra) # 7ca <write>
            wait(0);
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	644080e7          	jalr	1604(ra) # 7b2 <wait>
    for(int i = 0; i < n; i++){
 176:	2485                	addiw	s1,s1,1
 178:	000a2783          	lw	a5,0(s4)
 17c:	fcf4c7e3          	blt	s1,a5,14a <sendChildrenToWork+0x50>
 180:	a809                	j	192 <sendChildrenToWork+0x98>
            printf("\nFork Error!\n");
 182:	00001517          	auipc	a0,0x1
 186:	bd650513          	addi	a0,a0,-1066 # d58 <malloc+0x15e>
 18a:	00001097          	auipc	ra,0x1
 18e:	9b8080e7          	jalr	-1608(ra) # b42 <printf>
        }
    }
    if(pid == -1)
 192:	00001717          	auipc	a4,0x1
 196:	e8672703          	lw	a4,-378(a4) # 1018 <pid>
 19a:	57fd                	li	a5,-1
 19c:	10f70863          	beq	a4,a5,2ac <sendChildrenToWork+0x1b2>
        exit(1);
}
 1a0:	70a6                	ld	ra,104(sp)
 1a2:	7406                	ld	s0,96(sp)
 1a4:	64e6                	ld	s1,88(sp)
 1a6:	6946                	ld	s2,80(sp)
 1a8:	69a6                	ld	s3,72(sp)
 1aa:	6a06                	ld	s4,64(sp)
 1ac:	7ae2                	ld	s5,56(sp)
 1ae:	7b42                	ld	s6,48(sp)
 1b0:	7ba2                	ld	s7,40(sp)
 1b2:	7c02                	ld	s8,32(sp)
 1b4:	6ce2                	ld	s9,24(sp)
 1b6:	6165                	addi	sp,sp,112
 1b8:	8082                	ret
            whoami = getpid();
 1ba:	00000097          	auipc	ra,0x0
 1be:	670080e7          	jalr	1648(ra) # 82a <getpid>
 1c2:	00001917          	auipc	s2,0x1
 1c6:	e5a90913          	addi	s2,s2,-422 # 101c <whoami>
 1ca:	00a92023          	sw	a0,0(s2)
            int prepri = getpri();
 1ce:	00000097          	auipc	ra,0x0
 1d2:	69c080e7          	jalr	1692(ra) # 86a <getpri>
 1d6:	84aa                	mv	s1,a0
            printf("I am %d, priority: 0x%x\n", whoami, prepri);
 1d8:	862a                	mv	a2,a0
 1da:	00092583          	lw	a1,0(s2)
 1de:	00001517          	auipc	a0,0x1
 1e2:	b8a50513          	addi	a0,a0,-1142 # d68 <malloc+0x16e>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	95c080e7          	jalr	-1700(ra) # b42 <printf>
            if(escalate == 1 && whoami >= thresh){
 1ee:	4785                	li	a5,1
 1f0:	04fc0b63          	beq	s8,a5,246 <sendChildrenToWork+0x14c>
            else if(escalate == -1 && whoami <= thresh){
 1f4:	57fd                	li	a5,-1
 1f6:	06fc0863          	beq	s8,a5,266 <sendChildrenToWork+0x16c>
            if(prepri != getpri())
 1fa:	00000097          	auipc	ra,0x0
 1fe:	670080e7          	jalr	1648(ra) # 86a <getpri>
 202:	08951263          	bne	a0,s1,286 <sendChildrenToWork+0x18c>
            close(trap[1]); // close write, wont be writing
 206:	00001517          	auipc	a0,0x1
 20a:	e0e52503          	lw	a0,-498(a0) # 1014 <trap+0x4>
 20e:	00000097          	auipc	ra,0x0
 212:	5c4080e7          	jalr	1476(ra) # 7d2 <close>
            int pause = 1;
 216:	4785                	li	a5,1
 218:	f8f42e23          	sw	a5,-100(s0)
                read(trap[0], &pause, 1); // read from the buffer till no longer paused
 21c:	00001497          	auipc	s1,0x1
 220:	df448493          	addi	s1,s1,-524 # 1010 <trap>
 224:	4605                	li	a2,1
 226:	f9c40593          	addi	a1,s0,-100
 22a:	4088                	lw	a0,0(s1)
 22c:	00000097          	auipc	ra,0x0
 230:	596080e7          	jalr	1430(ra) # 7c2 <read>
            while(pause)
 234:	f9c42783          	lw	a5,-100(s0)
 238:	f7f5                	bnez	a5,224 <sendChildrenToWork+0x12a>
            (*work)();
 23a:	9c82                	jalr	s9
            exit(0);
 23c:	4501                	li	a0,0
 23e:	00000097          	auipc	ra,0x0
 242:	56c080e7          	jalr	1388(ra) # 7aa <exit>
            if(escalate == 1 && whoami >= thresh){
 246:	00001797          	auipc	a5,0x1
 24a:	dd67a783          	lw	a5,-554(a5) # 101c <whoami>
 24e:	fb77c6e3          	blt	a5,s7,1fa <sendChildrenToWork+0x100>
                 setpri(getpri() + 1); // Request to elevate my priority by 1 level.
 252:	00000097          	auipc	ra,0x0
 256:	618080e7          	jalr	1560(ra) # 86a <getpri>
 25a:	2505                	addiw	a0,a0,1
 25c:	00000097          	auipc	ra,0x0
 260:	616080e7          	jalr	1558(ra) # 872 <setpri>
 264:	bf59                	j	1fa <sendChildrenToWork+0x100>
            else if(escalate == -1 && whoami <= thresh){
 266:	00001797          	auipc	a5,0x1
 26a:	db67a783          	lw	a5,-586(a5) # 101c <whoami>
 26e:	f8fbc6e3          	blt	s7,a5,1fa <sendChildrenToWork+0x100>
                 setpri(getpri() - 1);
 272:	00000097          	auipc	ra,0x0
 276:	5f8080e7          	jalr	1528(ra) # 86a <getpri>
 27a:	357d                	addiw	a0,a0,-1
 27c:	00000097          	auipc	ra,0x0
 280:	5f6080e7          	jalr	1526(ra) # 872 <setpri>
 284:	bf9d                	j	1fa <sendChildrenToWork+0x100>
                printf("Updated Priority of %d, priority: 0x%x\n", whoami, getpri());
 286:	00001497          	auipc	s1,0x1
 28a:	d964a483          	lw	s1,-618(s1) # 101c <whoami>
 28e:	00000097          	auipc	ra,0x0
 292:	5dc080e7          	jalr	1500(ra) # 86a <getpri>
 296:	862a                	mv	a2,a0
 298:	85a6                	mv	a1,s1
 29a:	00001517          	auipc	a0,0x1
 29e:	aee50513          	addi	a0,a0,-1298 # d88 <malloc+0x18e>
 2a2:	00001097          	auipc	ra,0x1
 2a6:	8a0080e7          	jalr	-1888(ra) # b42 <printf>
 2aa:	bfb1                	j	206 <sendChildrenToWork+0x10c>
        exit(1);
 2ac:	4505                	li	a0,1
 2ae:	00000097          	auipc	ra,0x0
 2b2:	4fc080e7          	jalr	1276(ra) # 7aa <exit>

00000000000002b6 <main>:


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
 2b6:	7139                	addi	sp,sp,-64
 2b8:	fc06                	sd	ra,56(sp)
 2ba:	f822                	sd	s0,48(sp)
 2bc:	f426                	sd	s1,40(sp)
 2be:	f04a                	sd	s2,32(sp)
 2c0:	ec4e                	sd	s3,24(sp)
 2c2:	e852                	sd	s4,16(sp)
 2c4:	e456                	sd	s5,8(sp)
 2c6:	e05a                	sd	s6,0(sp)
 2c8:	0080                	addi	s0,sp,64
    if(!validate(argc, argv)) return 0;
 2ca:	00000097          	auipc	ra,0x0
 2ce:	d80080e7          	jalr	-640(ra) # 4a <validate>
 2d2:	ed01                	bnez	a0,2ea <main+0x34>
   }
   return 0;



}
 2d4:	4501                	li	a0,0
 2d6:	70e2                	ld	ra,56(sp)
 2d8:	7442                	ld	s0,48(sp)
 2da:	74a2                	ld	s1,40(sp)
 2dc:	7902                	ld	s2,32(sp)
 2de:	69e2                	ld	s3,24(sp)
 2e0:	6a42                	ld	s4,16(sp)
 2e2:	6aa2                	ld	s5,8(sp)
 2e4:	6b02                	ld	s6,0(sp)
 2e6:	6121                	addi	sp,sp,64
 2e8:	8082                	ret
   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
 2ea:	00001517          	auipc	a0,0x1
 2ee:	ac650513          	addi	a0,a0,-1338 # db0 <malloc+0x1b6>
 2f2:	00001097          	auipc	ra,0x1
 2f6:	850080e7          	jalr	-1968(ra) # b42 <printf>
   whoami = -1; // parent
 2fa:	57fd                	li	a5,-1
 2fc:	00001717          	auipc	a4,0x1
 300:	d2f72023          	sw	a5,-736(a4) # 101c <whoami>
   pid = getpid();
 304:	00000097          	auipc	ra,0x0
 308:	526080e7          	jalr	1318(ra) # 82a <getpid>
 30c:	00001797          	auipc	a5,0x1
 310:	d0a7a623          	sw	a0,-756(a5) # 1018 <pid>
   pipe(trap);
 314:	00001517          	auipc	a0,0x1
 318:	cfc50513          	addi	a0,a0,-772 # 1010 <trap>
 31c:	00000097          	auipc	ra,0x0
 320:	49e080e7          	jalr	1182(ra) # 7ba <pipe>
   int thresh = ((rand(&rand_next) % n)/2);
 324:	00001517          	auipc	a0,0x1
 328:	cdc50513          	addi	a0,a0,-804 # 1000 <rand_next>
 32c:	00000097          	auipc	ra,0x0
 330:	d76080e7          	jalr	-650(ra) # a2 <do_rand>
 334:	00001797          	auipc	a5,0x1
 338:	cec7a783          	lw	a5,-788(a5) # 1020 <n>
 33c:	02f569bb          	remw	s3,a0,a5
 340:	4789                	li	a5,2
 342:	02f9c9bb          	divw	s3,s3,a5
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 346:	00001497          	auipc	s1,0x1
 34a:	b5248493          	addi	s1,s1,-1198 # e98 <prio>
 34e:	00001a17          	auipc	s4,0x1
 352:	b5ea0a13          	addi	s4,s4,-1186 # eac <prio+0x14>
   int thresh = ((rand(&rand_next) % n)/2);
 356:	8926                	mv	s2,s1
       printf("(No Escalation) Priority Test: 0x%x\n", prio[p]);
 358:	00001b17          	auipc	s6,0x1
 35c:	ab0b0b13          	addi	s6,s6,-1360 # e08 <malloc+0x20e>
       sendChildrenToWork(0, thresh, alphabet);
 360:	00000a97          	auipc	s5,0x0
 364:	ca0a8a93          	addi	s5,s5,-864 # 0 <alphabet>
       printf("(No Escalation) Priority Test: 0x%x\n", prio[p]);
 368:	00092583          	lw	a1,0(s2)
 36c:	855a                	mv	a0,s6
 36e:	00000097          	auipc	ra,0x0
 372:	7d4080e7          	jalr	2004(ra) # b42 <printf>
       sendChildrenToWork(0, thresh, alphabet);
 376:	8656                	mv	a2,s5
 378:	85ce                	mv	a1,s3
 37a:	4501                	li	a0,0
 37c:	00000097          	auipc	ra,0x0
 380:	d7e080e7          	jalr	-642(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 384:	0911                	addi	s2,s2,4
 386:	ff4911e3          	bne	s2,s4,368 <main+0xb2>
 38a:	8926                	mv	s2,s1
       printf("(Applying Escalation) Priority Test: 0x%x\n", prio[p]);
 38c:	00001b17          	auipc	s6,0x1
 390:	aa4b0b13          	addi	s6,s6,-1372 # e30 <malloc+0x236>
       sendChildrenToWork(1, thresh, alphabet);
 394:	00000a97          	auipc	s5,0x0
 398:	c6ca8a93          	addi	s5,s5,-916 # 0 <alphabet>
       printf("(Applying Escalation) Priority Test: 0x%x\n", prio[p]);
 39c:	00092583          	lw	a1,0(s2)
 3a0:	855a                	mv	a0,s6
 3a2:	00000097          	auipc	ra,0x0
 3a6:	7a0080e7          	jalr	1952(ra) # b42 <printf>
       sendChildrenToWork(1, thresh, alphabet);
 3aa:	8656                	mv	a2,s5
 3ac:	85ce                	mv	a1,s3
 3ae:	4505                	li	a0,1
 3b0:	00000097          	auipc	ra,0x0
 3b4:	d4a080e7          	jalr	-694(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 3b8:	0911                	addi	s2,s2,4
 3ba:	ff4911e3          	bne	s2,s4,39c <main+0xe6>
       printf("(Applying Deescalation) Priority Test: 0x%x\n", prio[p]);
 3be:	00001a97          	auipc	s5,0x1
 3c2:	aa2a8a93          	addi	s5,s5,-1374 # e60 <malloc+0x266>
       sendChildrenToWork(-1, thresh, alphabet);
 3c6:	00000917          	auipc	s2,0x0
 3ca:	c3a90913          	addi	s2,s2,-966 # 0 <alphabet>
       printf("(Applying Deescalation) Priority Test: 0x%x\n", prio[p]);
 3ce:	408c                	lw	a1,0(s1)
 3d0:	8556                	mv	a0,s5
 3d2:	00000097          	auipc	ra,0x0
 3d6:	770080e7          	jalr	1904(ra) # b42 <printf>
       sendChildrenToWork(-1, thresh, alphabet);
 3da:	864a                	mv	a2,s2
 3dc:	85ce                	mv	a1,s3
 3de:	557d                	li	a0,-1
 3e0:	00000097          	auipc	ra,0x0
 3e4:	d1a080e7          	jalr	-742(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 3e8:	0491                	addi	s1,s1,4
 3ea:	ff4492e3          	bne	s1,s4,3ce <main+0x118>
 3ee:	b5dd                	j	2d4 <main+0x1e>

00000000000003f0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 3f8:	00000097          	auipc	ra,0x0
 3fc:	ebe080e7          	jalr	-322(ra) # 2b6 <main>
  exit(0);
 400:	4501                	li	a0,0
 402:	00000097          	auipc	ra,0x0
 406:	3a8080e7          	jalr	936(ra) # 7aa <exit>

000000000000040a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 410:	87aa                	mv	a5,a0
 412:	0585                	addi	a1,a1,1
 414:	0785                	addi	a5,a5,1
 416:	fff5c703          	lbu	a4,-1(a1)
 41a:	fee78fa3          	sb	a4,-1(a5)
 41e:	fb75                	bnez	a4,412 <strcpy+0x8>
    ;
  return os;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 42c:	00054783          	lbu	a5,0(a0)
 430:	cb91                	beqz	a5,444 <strcmp+0x1e>
 432:	0005c703          	lbu	a4,0(a1)
 436:	00f71763          	bne	a4,a5,444 <strcmp+0x1e>
    p++, q++;
 43a:	0505                	addi	a0,a0,1
 43c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 43e:	00054783          	lbu	a5,0(a0)
 442:	fbe5                	bnez	a5,432 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 444:	0005c503          	lbu	a0,0(a1)
}
 448:	40a7853b          	subw	a0,a5,a0
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <strlen>:

uint
strlen(const char *s)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 458:	00054783          	lbu	a5,0(a0)
 45c:	cf91                	beqz	a5,478 <strlen+0x26>
 45e:	0505                	addi	a0,a0,1
 460:	87aa                	mv	a5,a0
 462:	86be                	mv	a3,a5
 464:	0785                	addi	a5,a5,1
 466:	fff7c703          	lbu	a4,-1(a5)
 46a:	ff65                	bnez	a4,462 <strlen+0x10>
 46c:	40a6853b          	subw	a0,a3,a0
 470:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 472:	6422                	ld	s0,8(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret
  for(n = 0; s[n]; n++)
 478:	4501                	li	a0,0
 47a:	bfe5                	j	472 <strlen+0x20>

000000000000047c <memset>:

void*
memset(void *dst, int c, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 482:	ca19                	beqz	a2,498 <memset+0x1c>
 484:	87aa                	mv	a5,a0
 486:	1602                	slli	a2,a2,0x20
 488:	9201                	srli	a2,a2,0x20
 48a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 48e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 492:	0785                	addi	a5,a5,1
 494:	fee79de3          	bne	a5,a4,48e <memset+0x12>
  }
  return dst;
}
 498:	6422                	ld	s0,8(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret

000000000000049e <strchr>:

char*
strchr(const char *s, char c)
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e422                	sd	s0,8(sp)
 4a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4a4:	00054783          	lbu	a5,0(a0)
 4a8:	cb99                	beqz	a5,4be <strchr+0x20>
    if(*s == c)
 4aa:	00f58763          	beq	a1,a5,4b8 <strchr+0x1a>
  for(; *s; s++)
 4ae:	0505                	addi	a0,a0,1
 4b0:	00054783          	lbu	a5,0(a0)
 4b4:	fbfd                	bnez	a5,4aa <strchr+0xc>
      return (char*)s;
  return 0;
 4b6:	4501                	li	a0,0
}
 4b8:	6422                	ld	s0,8(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret
  return 0;
 4be:	4501                	li	a0,0
 4c0:	bfe5                	j	4b8 <strchr+0x1a>

00000000000004c2 <gets>:

char*
gets(char *buf, int max)
{
 4c2:	711d                	addi	sp,sp,-96
 4c4:	ec86                	sd	ra,88(sp)
 4c6:	e8a2                	sd	s0,80(sp)
 4c8:	e4a6                	sd	s1,72(sp)
 4ca:	e0ca                	sd	s2,64(sp)
 4cc:	fc4e                	sd	s3,56(sp)
 4ce:	f852                	sd	s4,48(sp)
 4d0:	f456                	sd	s5,40(sp)
 4d2:	f05a                	sd	s6,32(sp)
 4d4:	ec5e                	sd	s7,24(sp)
 4d6:	1080                	addi	s0,sp,96
 4d8:	8baa                	mv	s7,a0
 4da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4dc:	892a                	mv	s2,a0
 4de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4e0:	4aa9                	li	s5,10
 4e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4e4:	89a6                	mv	s3,s1
 4e6:	2485                	addiw	s1,s1,1
 4e8:	0344d863          	bge	s1,s4,518 <gets+0x56>
    cc = read(0, &c, 1);
 4ec:	4605                	li	a2,1
 4ee:	faf40593          	addi	a1,s0,-81
 4f2:	4501                	li	a0,0
 4f4:	00000097          	auipc	ra,0x0
 4f8:	2ce080e7          	jalr	718(ra) # 7c2 <read>
    if(cc < 1)
 4fc:	00a05e63          	blez	a0,518 <gets+0x56>
    buf[i++] = c;
 500:	faf44783          	lbu	a5,-81(s0)
 504:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 508:	01578763          	beq	a5,s5,516 <gets+0x54>
 50c:	0905                	addi	s2,s2,1
 50e:	fd679be3          	bne	a5,s6,4e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 512:	89a6                	mv	s3,s1
 514:	a011                	j	518 <gets+0x56>
 516:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 518:	99de                	add	s3,s3,s7
 51a:	00098023          	sb	zero,0(s3)
  return buf;
}
 51e:	855e                	mv	a0,s7
 520:	60e6                	ld	ra,88(sp)
 522:	6446                	ld	s0,80(sp)
 524:	64a6                	ld	s1,72(sp)
 526:	6906                	ld	s2,64(sp)
 528:	79e2                	ld	s3,56(sp)
 52a:	7a42                	ld	s4,48(sp)
 52c:	7aa2                	ld	s5,40(sp)
 52e:	7b02                	ld	s6,32(sp)
 530:	6be2                	ld	s7,24(sp)
 532:	6125                	addi	sp,sp,96
 534:	8082                	ret

0000000000000536 <stat>:

int
stat(const char *n, struct stat *st)
{
 536:	1101                	addi	sp,sp,-32
 538:	ec06                	sd	ra,24(sp)
 53a:	e822                	sd	s0,16(sp)
 53c:	e426                	sd	s1,8(sp)
 53e:	e04a                	sd	s2,0(sp)
 540:	1000                	addi	s0,sp,32
 542:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 544:	4581                	li	a1,0
 546:	00000097          	auipc	ra,0x0
 54a:	2a4080e7          	jalr	676(ra) # 7ea <open>
  if(fd < 0)
 54e:	02054563          	bltz	a0,578 <stat+0x42>
 552:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 554:	85ca                	mv	a1,s2
 556:	00000097          	auipc	ra,0x0
 55a:	2ac080e7          	jalr	684(ra) # 802 <fstat>
 55e:	892a                	mv	s2,a0
  close(fd);
 560:	8526                	mv	a0,s1
 562:	00000097          	auipc	ra,0x0
 566:	270080e7          	jalr	624(ra) # 7d2 <close>
  return r;
}
 56a:	854a                	mv	a0,s2
 56c:	60e2                	ld	ra,24(sp)
 56e:	6442                	ld	s0,16(sp)
 570:	64a2                	ld	s1,8(sp)
 572:	6902                	ld	s2,0(sp)
 574:	6105                	addi	sp,sp,32
 576:	8082                	ret
    return -1;
 578:	597d                	li	s2,-1
 57a:	bfc5                	j	56a <stat+0x34>

000000000000057c <atoi>:

int
atoi(const char *s)
{
 57c:	1141                	addi	sp,sp,-16
 57e:	e422                	sd	s0,8(sp)
 580:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 582:	00054683          	lbu	a3,0(a0)
 586:	fd06879b          	addiw	a5,a3,-48
 58a:	0ff7f793          	zext.b	a5,a5
 58e:	4625                	li	a2,9
 590:	02f66863          	bltu	a2,a5,5c0 <atoi+0x44>
 594:	872a                	mv	a4,a0
  n = 0;
 596:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 598:	0705                	addi	a4,a4,1
 59a:	0025179b          	slliw	a5,a0,0x2
 59e:	9fa9                	addw	a5,a5,a0
 5a0:	0017979b          	slliw	a5,a5,0x1
 5a4:	9fb5                	addw	a5,a5,a3
 5a6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5aa:	00074683          	lbu	a3,0(a4)
 5ae:	fd06879b          	addiw	a5,a3,-48
 5b2:	0ff7f793          	zext.b	a5,a5
 5b6:	fef671e3          	bgeu	a2,a5,598 <atoi+0x1c>

  return n;
}
 5ba:	6422                	ld	s0,8(sp)
 5bc:	0141                	addi	sp,sp,16
 5be:	8082                	ret
  n = 0;
 5c0:	4501                	li	a0,0
 5c2:	bfe5                	j	5ba <atoi+0x3e>

00000000000005c4 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 5c4:	1141                	addi	sp,sp,-16
 5c6:	e422                	sd	s0,8(sp)
 5c8:	0800                	addi	s0,sp,16
 5ca:	8eaa                	mv	t4,a0
    register const char *s = strt;
 5cc:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 5ce:	02000693          	li	a3,32
        c = *s++;
 5d2:	883e                	mv	a6,a5
 5d4:	0785                	addi	a5,a5,1
 5d6:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 5da:	fed70ce3          	beq	a4,a3,5d2 <strtoi+0xe>
        c = *s++;
 5de:	2701                	sext.w	a4,a4

    if (c == '-') {
 5e0:	02d00693          	li	a3,45
 5e4:	04d70d63          	beq	a4,a3,63e <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 5e8:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 5ec:	4f01                	li	t5,0
    } else if (c == '+')
 5ee:	04d70e63          	beq	a4,a3,64a <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 5f2:	fef67693          	andi	a3,a2,-17
 5f6:	ea99                	bnez	a3,60c <strtoi+0x48>
 5f8:	03000693          	li	a3,48
 5fc:	04d70c63          	beq	a4,a3,654 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 600:	e611                	bnez	a2,60c <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 602:	03000693          	li	a3,48
 606:	0cd70b63          	beq	a4,a3,6dc <strtoi+0x118>
 60a:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 60c:	800008b7          	lui	a7,0x80000
 610:	fff8c893          	not	a7,a7
 614:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 618:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 61c:	1882                	slli	a7,a7,0x20
 61e:	0208d893          	srli	a7,a7,0x20
 622:	02c8d8b3          	divu	a7,a7,a2
 626:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 62a:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 62e:	0ac75163          	bge	a4,a2,6d0 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 632:	4681                	li	a3,0
 634:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 636:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 638:	2881                	sext.w	a7,a7
        else {
            any = 1;
 63a:	4f85                	li	t6,1
 63c:	a0a9                	j	686 <strtoi+0xc2>
        c = *s++;
 63e:	0007c703          	lbu	a4,0(a5)
 642:	00280793          	addi	a5,a6,2
        neg = 1;
 646:	4f05                	li	t5,1
 648:	b76d                	j	5f2 <strtoi+0x2e>
        c = *s++;
 64a:	0007c703          	lbu	a4,0(a5)
 64e:	00280793          	addi	a5,a6,2
 652:	b745                	j	5f2 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 654:	0007c683          	lbu	a3,0(a5)
 658:	0df6f693          	andi	a3,a3,223
 65c:	05800513          	li	a0,88
 660:	faa690e3          	bne	a3,a0,600 <strtoi+0x3c>
        c = s[1];
 664:	0017c703          	lbu	a4,1(a5)
        s += 2;
 668:	0789                	addi	a5,a5,2
        base = 16;
 66a:	4641                	li	a2,16
 66c:	b745                	j	60c <strtoi+0x48>
            any = -1;
 66e:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 670:	00e2c463          	blt	t0,a4,678 <strtoi+0xb4>
 674:	a015                	j	698 <strtoi+0xd4>
            any = -1;
 676:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 678:	0785                	addi	a5,a5,1
 67a:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 67e:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 682:	02c75063          	bge	a4,a2,6a2 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 686:	fe06c8e3          	bltz	a3,676 <strtoi+0xb2>
 68a:	0005081b          	sext.w	a6,a0
            any = -1;
 68e:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 690:	ff0e64e3          	bltu	t3,a6,678 <strtoi+0xb4>
 694:	fca88de3          	beq	a7,a0,66e <strtoi+0xaa>
            acc *= base;
 698:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 69c:	9d39                	addw	a0,a0,a4
            any = 1;
 69e:	86fe                	mv	a3,t6
 6a0:	bfe1                	j	678 <strtoi+0xb4>
        }
    }
    if (any < 0) {
 6a2:	0006cd63          	bltz	a3,6bc <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 6a6:	000f0463          	beqz	t5,6ae <strtoi+0xea>
        acc = -acc;
 6aa:	40a0053b          	negw	a0,a0
    if (end != 0)
 6ae:	c581                	beqz	a1,6b6 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 6b0:	ee89                	bnez	a3,6ca <strtoi+0x106>
 6b2:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 6b6:	6422                	ld	s0,8(sp)
 6b8:	0141                	addi	sp,sp,16
 6ba:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 6bc:	000f1d63          	bnez	t5,6d6 <strtoi+0x112>
 6c0:	80000537          	lui	a0,0x80000
 6c4:	fff54513          	not	a0,a0
    if (end != 0)
 6c8:	d5fd                	beqz	a1,6b6 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 6ca:	fff78e93          	addi	t4,a5,-1
 6ce:	b7d5                	j	6b2 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 6d0:	4681                	li	a3,0
 6d2:	4501                	li	a0,0
 6d4:	bfc9                	j	6a6 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 6d6:	80000537          	lui	a0,0x80000
 6da:	b7fd                	j	6c8 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 6dc:	80000e37          	lui	t3,0x80000
 6e0:	fffe4e13          	not	t3,t3
 6e4:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 6e8:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 6ec:	003e589b          	srliw	a7,t3,0x3
 6f0:	8e46                	mv	t3,a7
            c -= '0';
 6f2:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 6f4:	4621                	li	a2,8
 6f6:	bf35                	j	632 <strtoi+0x6e>

00000000000006f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6f8:	1141                	addi	sp,sp,-16
 6fa:	e422                	sd	s0,8(sp)
 6fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6fe:	02b57463          	bgeu	a0,a1,726 <memmove+0x2e>
    while(n-- > 0)
 702:	00c05f63          	blez	a2,720 <memmove+0x28>
 706:	1602                	slli	a2,a2,0x20
 708:	9201                	srli	a2,a2,0x20
 70a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 70e:	872a                	mv	a4,a0
      *dst++ = *src++;
 710:	0585                	addi	a1,a1,1
 712:	0705                	addi	a4,a4,1
 714:	fff5c683          	lbu	a3,-1(a1)
 718:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 71c:	fee79ae3          	bne	a5,a4,710 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 720:	6422                	ld	s0,8(sp)
 722:	0141                	addi	sp,sp,16
 724:	8082                	ret
    dst += n;
 726:	00c50733          	add	a4,a0,a2
    src += n;
 72a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 72c:	fec05ae3          	blez	a2,720 <memmove+0x28>
 730:	fff6079b          	addiw	a5,a2,-1
 734:	1782                	slli	a5,a5,0x20
 736:	9381                	srli	a5,a5,0x20
 738:	fff7c793          	not	a5,a5
 73c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 73e:	15fd                	addi	a1,a1,-1
 740:	177d                	addi	a4,a4,-1
 742:	0005c683          	lbu	a3,0(a1)
 746:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 74a:	fee79ae3          	bne	a5,a4,73e <memmove+0x46>
 74e:	bfc9                	j	720 <memmove+0x28>

0000000000000750 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 750:	1141                	addi	sp,sp,-16
 752:	e422                	sd	s0,8(sp)
 754:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 756:	ca05                	beqz	a2,786 <memcmp+0x36>
 758:	fff6069b          	addiw	a3,a2,-1
 75c:	1682                	slli	a3,a3,0x20
 75e:	9281                	srli	a3,a3,0x20
 760:	0685                	addi	a3,a3,1
 762:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 764:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffefd0>
 768:	0005c703          	lbu	a4,0(a1)
 76c:	00e79863          	bne	a5,a4,77c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 770:	0505                	addi	a0,a0,1
    p2++;
 772:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 774:	fed518e3          	bne	a0,a3,764 <memcmp+0x14>
  }
  return 0;
 778:	4501                	li	a0,0
 77a:	a019                	j	780 <memcmp+0x30>
      return *p1 - *p2;
 77c:	40e7853b          	subw	a0,a5,a4
}
 780:	6422                	ld	s0,8(sp)
 782:	0141                	addi	sp,sp,16
 784:	8082                	ret
  return 0;
 786:	4501                	li	a0,0
 788:	bfe5                	j	780 <memcmp+0x30>

000000000000078a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 78a:	1141                	addi	sp,sp,-16
 78c:	e406                	sd	ra,8(sp)
 78e:	e022                	sd	s0,0(sp)
 790:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 792:	00000097          	auipc	ra,0x0
 796:	f66080e7          	jalr	-154(ra) # 6f8 <memmove>
}
 79a:	60a2                	ld	ra,8(sp)
 79c:	6402                	ld	s0,0(sp)
 79e:	0141                	addi	sp,sp,16
 7a0:	8082                	ret

00000000000007a2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7a2:	4885                	li	a7,1
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <exit>:
.global exit
exit:
 li a7, SYS_exit
 7aa:	4889                	li	a7,2
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 7b2:	488d                	li	a7,3
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7ba:	4891                	li	a7,4
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <read>:
.global read
read:
 li a7, SYS_read
 7c2:	4895                	li	a7,5
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <write>:
.global write
write:
 li a7, SYS_write
 7ca:	48c1                	li	a7,16
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <close>:
.global close
close:
 li a7, SYS_close
 7d2:	48d5                	li	a7,21
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <kill>:
.global kill
kill:
 li a7, SYS_kill
 7da:	4899                	li	a7,6
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 7e2:	489d                	li	a7,7
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <open>:
.global open
open:
 li a7, SYS_open
 7ea:	48bd                	li	a7,15
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7f2:	48c5                	li	a7,17
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7fa:	48c9                	li	a7,18
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 802:	48a1                	li	a7,8
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <link>:
.global link
link:
 li a7, SYS_link
 80a:	48cd                	li	a7,19
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 812:	48d1                	li	a7,20
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 81a:	48a5                	li	a7,9
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <dup>:
.global dup
dup:
 li a7, SYS_dup
 822:	48a9                	li	a7,10
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 82a:	48ad                	li	a7,11
 ecall
 82c:	00000073          	ecall
 ret
 830:	8082                	ret

0000000000000832 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 832:	48b1                	li	a7,12
 ecall
 834:	00000073          	ecall
 ret
 838:	8082                	ret

000000000000083a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 83a:	48b5                	li	a7,13
 ecall
 83c:	00000073          	ecall
 ret
 840:	8082                	ret

0000000000000842 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 842:	48b9                	li	a7,14
 ecall
 844:	00000073          	ecall
 ret
 848:	8082                	ret

000000000000084a <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 84a:	48d9                	li	a7,22
 ecall
 84c:	00000073          	ecall
 ret
 850:	8082                	ret

0000000000000852 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 852:	48dd                	li	a7,23
 ecall
 854:	00000073          	ecall
 ret
 858:	8082                	ret

000000000000085a <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 85a:	48e1                	li	a7,24
 ecall
 85c:	00000073          	ecall
 ret
 860:	8082                	ret

0000000000000862 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 862:	48e5                	li	a7,25
 ecall
 864:	00000073          	ecall
 ret
 868:	8082                	ret

000000000000086a <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 86a:	48e9                	li	a7,26
 ecall
 86c:	00000073          	ecall
 ret
 870:	8082                	ret

0000000000000872 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 872:	48ed                	li	a7,27
 ecall
 874:	00000073          	ecall
 ret
 878:	8082                	ret

000000000000087a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 87a:	1101                	addi	sp,sp,-32
 87c:	ec06                	sd	ra,24(sp)
 87e:	e822                	sd	s0,16(sp)
 880:	1000                	addi	s0,sp,32
 882:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 886:	4605                	li	a2,1
 888:	fef40593          	addi	a1,s0,-17
 88c:	00000097          	auipc	ra,0x0
 890:	f3e080e7          	jalr	-194(ra) # 7ca <write>
}
 894:	60e2                	ld	ra,24(sp)
 896:	6442                	ld	s0,16(sp)
 898:	6105                	addi	sp,sp,32
 89a:	8082                	ret

000000000000089c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 89c:	7139                	addi	sp,sp,-64
 89e:	fc06                	sd	ra,56(sp)
 8a0:	f822                	sd	s0,48(sp)
 8a2:	f426                	sd	s1,40(sp)
 8a4:	f04a                	sd	s2,32(sp)
 8a6:	ec4e                	sd	s3,24(sp)
 8a8:	0080                	addi	s0,sp,64
 8aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 8ac:	c299                	beqz	a3,8b2 <printint+0x16>
 8ae:	0805c963          	bltz	a1,940 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 8b2:	2581                	sext.w	a1,a1
  neg = 0;
 8b4:	4881                	li	a7,0
 8b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 8ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 8bc:	2601                	sext.w	a2,a2
 8be:	00000517          	auipc	a0,0x0
 8c2:	65250513          	addi	a0,a0,1618 # f10 <digits>
 8c6:	883a                	mv	a6,a4
 8c8:	2705                	addiw	a4,a4,1
 8ca:	02c5f7bb          	remuw	a5,a1,a2
 8ce:	1782                	slli	a5,a5,0x20
 8d0:	9381                	srli	a5,a5,0x20
 8d2:	97aa                	add	a5,a5,a0
 8d4:	0007c783          	lbu	a5,0(a5)
 8d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 8dc:	0005879b          	sext.w	a5,a1
 8e0:	02c5d5bb          	divuw	a1,a1,a2
 8e4:	0685                	addi	a3,a3,1
 8e6:	fec7f0e3          	bgeu	a5,a2,8c6 <printint+0x2a>
  if(neg)
 8ea:	00088c63          	beqz	a7,902 <printint+0x66>
    buf[i++] = '-';
 8ee:	fd070793          	addi	a5,a4,-48
 8f2:	00878733          	add	a4,a5,s0
 8f6:	02d00793          	li	a5,45
 8fa:	fef70823          	sb	a5,-16(a4)
 8fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 902:	02e05863          	blez	a4,932 <printint+0x96>
 906:	fc040793          	addi	a5,s0,-64
 90a:	00e78933          	add	s2,a5,a4
 90e:	fff78993          	addi	s3,a5,-1
 912:	99ba                	add	s3,s3,a4
 914:	377d                	addiw	a4,a4,-1
 916:	1702                	slli	a4,a4,0x20
 918:	9301                	srli	a4,a4,0x20
 91a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 91e:	fff94583          	lbu	a1,-1(s2)
 922:	8526                	mv	a0,s1
 924:	00000097          	auipc	ra,0x0
 928:	f56080e7          	jalr	-170(ra) # 87a <putc>
  while(--i >= 0)
 92c:	197d                	addi	s2,s2,-1
 92e:	ff3918e3          	bne	s2,s3,91e <printint+0x82>
}
 932:	70e2                	ld	ra,56(sp)
 934:	7442                	ld	s0,48(sp)
 936:	74a2                	ld	s1,40(sp)
 938:	7902                	ld	s2,32(sp)
 93a:	69e2                	ld	s3,24(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
    x = -xx;
 940:	40b005bb          	negw	a1,a1
    neg = 1;
 944:	4885                	li	a7,1
    x = -xx;
 946:	bf85                	j	8b6 <printint+0x1a>

0000000000000948 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 948:	715d                	addi	sp,sp,-80
 94a:	e486                	sd	ra,72(sp)
 94c:	e0a2                	sd	s0,64(sp)
 94e:	fc26                	sd	s1,56(sp)
 950:	f84a                	sd	s2,48(sp)
 952:	f44e                	sd	s3,40(sp)
 954:	f052                	sd	s4,32(sp)
 956:	ec56                	sd	s5,24(sp)
 958:	e85a                	sd	s6,16(sp)
 95a:	e45e                	sd	s7,8(sp)
 95c:	e062                	sd	s8,0(sp)
 95e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 960:	0005c903          	lbu	s2,0(a1)
 964:	18090c63          	beqz	s2,afc <vprintf+0x1b4>
 968:	8aaa                	mv	s5,a0
 96a:	8bb2                	mv	s7,a2
 96c:	00158493          	addi	s1,a1,1
  state = 0;
 970:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 972:	02500a13          	li	s4,37
 976:	4b55                	li	s6,21
 978:	a839                	j	996 <vprintf+0x4e>
        putc(fd, c);
 97a:	85ca                	mv	a1,s2
 97c:	8556                	mv	a0,s5
 97e:	00000097          	auipc	ra,0x0
 982:	efc080e7          	jalr	-260(ra) # 87a <putc>
 986:	a019                	j	98c <vprintf+0x44>
    } else if(state == '%'){
 988:	01498d63          	beq	s3,s4,9a2 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 98c:	0485                	addi	s1,s1,1
 98e:	fff4c903          	lbu	s2,-1(s1)
 992:	16090563          	beqz	s2,afc <vprintf+0x1b4>
    if(state == 0){
 996:	fe0999e3          	bnez	s3,988 <vprintf+0x40>
      if(c == '%'){
 99a:	ff4910e3          	bne	s2,s4,97a <vprintf+0x32>
        state = '%';
 99e:	89d2                	mv	s3,s4
 9a0:	b7f5                	j	98c <vprintf+0x44>
      if(c == 'd'){
 9a2:	13490263          	beq	s2,s4,ac6 <vprintf+0x17e>
 9a6:	f9d9079b          	addiw	a5,s2,-99
 9aa:	0ff7f793          	zext.b	a5,a5
 9ae:	12fb6563          	bltu	s6,a5,ad8 <vprintf+0x190>
 9b2:	f9d9079b          	addiw	a5,s2,-99
 9b6:	0ff7f713          	zext.b	a4,a5
 9ba:	10eb6f63          	bltu	s6,a4,ad8 <vprintf+0x190>
 9be:	00271793          	slli	a5,a4,0x2
 9c2:	00000717          	auipc	a4,0x0
 9c6:	4f670713          	addi	a4,a4,1270 # eb8 <prio+0x20>
 9ca:	97ba                	add	a5,a5,a4
 9cc:	439c                	lw	a5,0(a5)
 9ce:	97ba                	add	a5,a5,a4
 9d0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 9d2:	008b8913          	addi	s2,s7,8
 9d6:	4685                	li	a3,1
 9d8:	4629                	li	a2,10
 9da:	000ba583          	lw	a1,0(s7)
 9de:	8556                	mv	a0,s5
 9e0:	00000097          	auipc	ra,0x0
 9e4:	ebc080e7          	jalr	-324(ra) # 89c <printint>
 9e8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 9ea:	4981                	li	s3,0
 9ec:	b745                	j	98c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ee:	008b8913          	addi	s2,s7,8
 9f2:	4681                	li	a3,0
 9f4:	4629                	li	a2,10
 9f6:	000ba583          	lw	a1,0(s7)
 9fa:	8556                	mv	a0,s5
 9fc:	00000097          	auipc	ra,0x0
 a00:	ea0080e7          	jalr	-352(ra) # 89c <printint>
 a04:	8bca                	mv	s7,s2
      state = 0;
 a06:	4981                	li	s3,0
 a08:	b751                	j	98c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 a0a:	008b8913          	addi	s2,s7,8
 a0e:	4681                	li	a3,0
 a10:	4641                	li	a2,16
 a12:	000ba583          	lw	a1,0(s7)
 a16:	8556                	mv	a0,s5
 a18:	00000097          	auipc	ra,0x0
 a1c:	e84080e7          	jalr	-380(ra) # 89c <printint>
 a20:	8bca                	mv	s7,s2
      state = 0;
 a22:	4981                	li	s3,0
 a24:	b7a5                	j	98c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 a26:	008b8c13          	addi	s8,s7,8
 a2a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a2e:	03000593          	li	a1,48
 a32:	8556                	mv	a0,s5
 a34:	00000097          	auipc	ra,0x0
 a38:	e46080e7          	jalr	-442(ra) # 87a <putc>
  putc(fd, 'x');
 a3c:	07800593          	li	a1,120
 a40:	8556                	mv	a0,s5
 a42:	00000097          	auipc	ra,0x0
 a46:	e38080e7          	jalr	-456(ra) # 87a <putc>
 a4a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a4c:	00000b97          	auipc	s7,0x0
 a50:	4c4b8b93          	addi	s7,s7,1220 # f10 <digits>
 a54:	03c9d793          	srli	a5,s3,0x3c
 a58:	97de                	add	a5,a5,s7
 a5a:	0007c583          	lbu	a1,0(a5)
 a5e:	8556                	mv	a0,s5
 a60:	00000097          	auipc	ra,0x0
 a64:	e1a080e7          	jalr	-486(ra) # 87a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a68:	0992                	slli	s3,s3,0x4
 a6a:	397d                	addiw	s2,s2,-1
 a6c:	fe0914e3          	bnez	s2,a54 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 a70:	8be2                	mv	s7,s8
      state = 0;
 a72:	4981                	li	s3,0
 a74:	bf21                	j	98c <vprintf+0x44>
        s = va_arg(ap, char*);
 a76:	008b8993          	addi	s3,s7,8
 a7a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 a7e:	02090163          	beqz	s2,aa0 <vprintf+0x158>
        while(*s != 0){
 a82:	00094583          	lbu	a1,0(s2)
 a86:	c9a5                	beqz	a1,af6 <vprintf+0x1ae>
          putc(fd, *s);
 a88:	8556                	mv	a0,s5
 a8a:	00000097          	auipc	ra,0x0
 a8e:	df0080e7          	jalr	-528(ra) # 87a <putc>
          s++;
 a92:	0905                	addi	s2,s2,1
        while(*s != 0){
 a94:	00094583          	lbu	a1,0(s2)
 a98:	f9e5                	bnez	a1,a88 <vprintf+0x140>
        s = va_arg(ap, char*);
 a9a:	8bce                	mv	s7,s3
      state = 0;
 a9c:	4981                	li	s3,0
 a9e:	b5fd                	j	98c <vprintf+0x44>
          s = "(null)";
 aa0:	00000917          	auipc	s2,0x0
 aa4:	41090913          	addi	s2,s2,1040 # eb0 <prio+0x18>
        while(*s != 0){
 aa8:	02800593          	li	a1,40
 aac:	bff1                	j	a88 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 aae:	008b8913          	addi	s2,s7,8
 ab2:	000bc583          	lbu	a1,0(s7)
 ab6:	8556                	mv	a0,s5
 ab8:	00000097          	auipc	ra,0x0
 abc:	dc2080e7          	jalr	-574(ra) # 87a <putc>
 ac0:	8bca                	mv	s7,s2
      state = 0;
 ac2:	4981                	li	s3,0
 ac4:	b5e1                	j	98c <vprintf+0x44>
        putc(fd, c);
 ac6:	02500593          	li	a1,37
 aca:	8556                	mv	a0,s5
 acc:	00000097          	auipc	ra,0x0
 ad0:	dae080e7          	jalr	-594(ra) # 87a <putc>
      state = 0;
 ad4:	4981                	li	s3,0
 ad6:	bd5d                	j	98c <vprintf+0x44>
        putc(fd, '%');
 ad8:	02500593          	li	a1,37
 adc:	8556                	mv	a0,s5
 ade:	00000097          	auipc	ra,0x0
 ae2:	d9c080e7          	jalr	-612(ra) # 87a <putc>
        putc(fd, c);
 ae6:	85ca                	mv	a1,s2
 ae8:	8556                	mv	a0,s5
 aea:	00000097          	auipc	ra,0x0
 aee:	d90080e7          	jalr	-624(ra) # 87a <putc>
      state = 0;
 af2:	4981                	li	s3,0
 af4:	bd61                	j	98c <vprintf+0x44>
        s = va_arg(ap, char*);
 af6:	8bce                	mv	s7,s3
      state = 0;
 af8:	4981                	li	s3,0
 afa:	bd49                	j	98c <vprintf+0x44>
    }
  }
}
 afc:	60a6                	ld	ra,72(sp)
 afe:	6406                	ld	s0,64(sp)
 b00:	74e2                	ld	s1,56(sp)
 b02:	7942                	ld	s2,48(sp)
 b04:	79a2                	ld	s3,40(sp)
 b06:	7a02                	ld	s4,32(sp)
 b08:	6ae2                	ld	s5,24(sp)
 b0a:	6b42                	ld	s6,16(sp)
 b0c:	6ba2                	ld	s7,8(sp)
 b0e:	6c02                	ld	s8,0(sp)
 b10:	6161                	addi	sp,sp,80
 b12:	8082                	ret

0000000000000b14 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b14:	715d                	addi	sp,sp,-80
 b16:	ec06                	sd	ra,24(sp)
 b18:	e822                	sd	s0,16(sp)
 b1a:	1000                	addi	s0,sp,32
 b1c:	e010                	sd	a2,0(s0)
 b1e:	e414                	sd	a3,8(s0)
 b20:	e818                	sd	a4,16(s0)
 b22:	ec1c                	sd	a5,24(s0)
 b24:	03043023          	sd	a6,32(s0)
 b28:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b2c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b30:	8622                	mv	a2,s0
 b32:	00000097          	auipc	ra,0x0
 b36:	e16080e7          	jalr	-490(ra) # 948 <vprintf>
}
 b3a:	60e2                	ld	ra,24(sp)
 b3c:	6442                	ld	s0,16(sp)
 b3e:	6161                	addi	sp,sp,80
 b40:	8082                	ret

0000000000000b42 <printf>:

void
printf(const char *fmt, ...)
{
 b42:	711d                	addi	sp,sp,-96
 b44:	ec06                	sd	ra,24(sp)
 b46:	e822                	sd	s0,16(sp)
 b48:	1000                	addi	s0,sp,32
 b4a:	e40c                	sd	a1,8(s0)
 b4c:	e810                	sd	a2,16(s0)
 b4e:	ec14                	sd	a3,24(s0)
 b50:	f018                	sd	a4,32(s0)
 b52:	f41c                	sd	a5,40(s0)
 b54:	03043823          	sd	a6,48(s0)
 b58:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b5c:	00840613          	addi	a2,s0,8
 b60:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b64:	85aa                	mv	a1,a0
 b66:	4505                	li	a0,1
 b68:	00000097          	auipc	ra,0x0
 b6c:	de0080e7          	jalr	-544(ra) # 948 <vprintf>
}
 b70:	60e2                	ld	ra,24(sp)
 b72:	6442                	ld	s0,16(sp)
 b74:	6125                	addi	sp,sp,96
 b76:	8082                	ret

0000000000000b78 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b78:	1141                	addi	sp,sp,-16
 b7a:	e422                	sd	s0,8(sp)
 b7c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b7e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b82:	00000797          	auipc	a5,0x0
 b86:	4a67b783          	ld	a5,1190(a5) # 1028 <freep>
 b8a:	a02d                	j	bb4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b8c:	4618                	lw	a4,8(a2)
 b8e:	9f2d                	addw	a4,a4,a1
 b90:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b94:	6398                	ld	a4,0(a5)
 b96:	6310                	ld	a2,0(a4)
 b98:	a83d                	j	bd6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b9a:	ff852703          	lw	a4,-8(a0)
 b9e:	9f31                	addw	a4,a4,a2
 ba0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ba2:	ff053683          	ld	a3,-16(a0)
 ba6:	a091                	j	bea <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ba8:	6398                	ld	a4,0(a5)
 baa:	00e7e463          	bltu	a5,a4,bb2 <free+0x3a>
 bae:	00e6ea63          	bltu	a3,a4,bc2 <free+0x4a>
{
 bb2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bb4:	fed7fae3          	bgeu	a5,a3,ba8 <free+0x30>
 bb8:	6398                	ld	a4,0(a5)
 bba:	00e6e463          	bltu	a3,a4,bc2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bbe:	fee7eae3          	bltu	a5,a4,bb2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 bc2:	ff852583          	lw	a1,-8(a0)
 bc6:	6390                	ld	a2,0(a5)
 bc8:	02059813          	slli	a6,a1,0x20
 bcc:	01c85713          	srli	a4,a6,0x1c
 bd0:	9736                	add	a4,a4,a3
 bd2:	fae60de3          	beq	a2,a4,b8c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 bd6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 bda:	4790                	lw	a2,8(a5)
 bdc:	02061593          	slli	a1,a2,0x20
 be0:	01c5d713          	srli	a4,a1,0x1c
 be4:	973e                	add	a4,a4,a5
 be6:	fae68ae3          	beq	a3,a4,b9a <free+0x22>
    p->s.ptr = bp->s.ptr;
 bea:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bec:	00000717          	auipc	a4,0x0
 bf0:	42f73e23          	sd	a5,1084(a4) # 1028 <freep>
}
 bf4:	6422                	ld	s0,8(sp)
 bf6:	0141                	addi	sp,sp,16
 bf8:	8082                	ret

0000000000000bfa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bfa:	7139                	addi	sp,sp,-64
 bfc:	fc06                	sd	ra,56(sp)
 bfe:	f822                	sd	s0,48(sp)
 c00:	f426                	sd	s1,40(sp)
 c02:	f04a                	sd	s2,32(sp)
 c04:	ec4e                	sd	s3,24(sp)
 c06:	e852                	sd	s4,16(sp)
 c08:	e456                	sd	s5,8(sp)
 c0a:	e05a                	sd	s6,0(sp)
 c0c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c0e:	02051493          	slli	s1,a0,0x20
 c12:	9081                	srli	s1,s1,0x20
 c14:	04bd                	addi	s1,s1,15
 c16:	8091                	srli	s1,s1,0x4
 c18:	0014899b          	addiw	s3,s1,1
 c1c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c1e:	00000517          	auipc	a0,0x0
 c22:	40a53503          	ld	a0,1034(a0) # 1028 <freep>
 c26:	c515                	beqz	a0,c52 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c28:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c2a:	4798                	lw	a4,8(a5)
 c2c:	02977f63          	bgeu	a4,s1,c6a <malloc+0x70>
  if(nu < 4096)
 c30:	8a4e                	mv	s4,s3
 c32:	0009871b          	sext.w	a4,s3
 c36:	6685                	lui	a3,0x1
 c38:	00d77363          	bgeu	a4,a3,c3e <malloc+0x44>
 c3c:	6a05                	lui	s4,0x1
 c3e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c42:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c46:	00000917          	auipc	s2,0x0
 c4a:	3e290913          	addi	s2,s2,994 # 1028 <freep>
  if(p == (char*)-1)
 c4e:	5afd                	li	s5,-1
 c50:	a895                	j	cc4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c52:	00000797          	auipc	a5,0x0
 c56:	3de78793          	addi	a5,a5,990 # 1030 <base>
 c5a:	00000717          	auipc	a4,0x0
 c5e:	3cf73723          	sd	a5,974(a4) # 1028 <freep>
 c62:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c64:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c68:	b7e1                	j	c30 <malloc+0x36>
      if(p->s.size == nunits)
 c6a:	02e48c63          	beq	s1,a4,ca2 <malloc+0xa8>
        p->s.size -= nunits;
 c6e:	4137073b          	subw	a4,a4,s3
 c72:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c74:	02071693          	slli	a3,a4,0x20
 c78:	01c6d713          	srli	a4,a3,0x1c
 c7c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c7e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c82:	00000717          	auipc	a4,0x0
 c86:	3aa73323          	sd	a0,934(a4) # 1028 <freep>
      return (void*)(p + 1);
 c8a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c8e:	70e2                	ld	ra,56(sp)
 c90:	7442                	ld	s0,48(sp)
 c92:	74a2                	ld	s1,40(sp)
 c94:	7902                	ld	s2,32(sp)
 c96:	69e2                	ld	s3,24(sp)
 c98:	6a42                	ld	s4,16(sp)
 c9a:	6aa2                	ld	s5,8(sp)
 c9c:	6b02                	ld	s6,0(sp)
 c9e:	6121                	addi	sp,sp,64
 ca0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ca2:	6398                	ld	a4,0(a5)
 ca4:	e118                	sd	a4,0(a0)
 ca6:	bff1                	j	c82 <malloc+0x88>
  hp->s.size = nu;
 ca8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cac:	0541                	addi	a0,a0,16
 cae:	00000097          	auipc	ra,0x0
 cb2:	eca080e7          	jalr	-310(ra) # b78 <free>
  return freep;
 cb6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 cba:	d971                	beqz	a0,c8e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cbc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 cbe:	4798                	lw	a4,8(a5)
 cc0:	fa9775e3          	bgeu	a4,s1,c6a <malloc+0x70>
    if(p == freep)
 cc4:	00093703          	ld	a4,0(s2)
 cc8:	853e                	mv	a0,a5
 cca:	fef719e3          	bne	a4,a5,cbc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 cce:	8552                	mv	a0,s4
 cd0:	00000097          	auipc	ra,0x0
 cd4:	b62080e7          	jalr	-1182(ra) # 832 <sbrk>
  if(p == (char*)-1)
 cd8:	fd5518e3          	bne	a0,s5,ca8 <malloc+0xae>
        return 0;
 cdc:	4501                	li	a0,0
 cde:	bf45                	j	c8e <malloc+0x94>
