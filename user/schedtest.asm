
user/_schedtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <validate>:
int paused[2];
unsigned long rand_next = 1;

//Treated as boolean
int validate(int argc, char * argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if(argc != 2){
   8:	4789                	li	a5,2
   a:	00f50f63          	beq	a0,a5,28 <validate+0x28>
        printf("Usage: ./schedtest <# Num Children>\n");
   e:	00001517          	auipc	a0,0x1
  12:	c9250513          	addi	a0,a0,-878 # ca0 <malloc+0xf2>
  16:	00001097          	auipc	ra,0x1
  1a:	ae0080e7          	jalr	-1312(ra) # af6 <printf>
        return 0;
  1e:	4501                	li	a0,0
    if(n < 10) {
        printf("Must have at least 10 children spawned. Canceling...\n");
        return 0;
    }
    return 1;
}
  20:	60a2                	ld	ra,8(sp)
  22:	6402                	ld	s0,0(sp)
  24:	0141                	addi	sp,sp,16
  26:	8082                	ret
    n = atoi(argv[1]);
  28:	6588                	ld	a0,8(a1)
  2a:	00000097          	auipc	ra,0x0
  2e:	506080e7          	jalr	1286(ra) # 530 <atoi>
  32:	87aa                	mv	a5,a0
  34:	00001717          	auipc	a4,0x1
  38:	fea72423          	sw	a0,-24(a4) # 101c <n>
    if(n < 10) {
  3c:	4725                	li	a4,9
    return 1;
  3e:	4505                	li	a0,1
    if(n < 10) {
  40:	fef740e3          	blt	a4,a5,20 <validate+0x20>
        printf("Must have at least 10 children spawned. Canceling...\n");
  44:	00001517          	auipc	a0,0x1
  48:	c8450513          	addi	a0,a0,-892 # cc8 <malloc+0x11a>
  4c:	00001097          	auipc	ra,0x1
  50:	aaa080e7          	jalr	-1366(ra) # af6 <printf>
        return 0;
  54:	4501                	li	a0,0
  56:	b7e9                	j	20 <validate+0x20>

0000000000000058 <alphabet>:

void alphabet()
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
    printf("I am %d, I will now think the alphabet forwards, and backwards, 50 times!\n", whoami);
  60:	00001597          	auipc	a1,0x1
  64:	fb85a583          	lw	a1,-72(a1) # 1018 <whoami>
  68:	00001517          	auipc	a0,0x1
  6c:	c9850513          	addi	a0,a0,-872 # d00 <malloc+0x152>
  70:	00001097          	auipc	ra,0x1
  74:	a86080e7          	jalr	-1402(ra) # af6 <printf>
  78:	03200713          	li	a4,50
{
  7c:	46e9                	li	a3,26
  7e:	a019                	j	84 <alphabet+0x2c>
    for(int i = 0; i < 50; i++) {
  80:	377d                	addiw	a4,a4,-1
  82:	cf01                	beqz	a4,9a <alphabet+0x42>
{
  84:	87b6                	mv	a5,a3
        for (char a = 'a'; a <= 'z'; a++);
  86:	37fd                	addiw	a5,a5,-1
  88:	0ff7f793          	zext.b	a5,a5
  8c:	ffed                	bnez	a5,86 <alphabet+0x2e>
  8e:	87b6                	mv	a5,a3
        for (char z = 'z'; z >= 'a'; z--);
  90:	37fd                	addiw	a5,a5,-1
  92:	0ff7f793          	zext.b	a5,a5
  96:	ffed                	bnez	a5,90 <alphabet+0x38>
  98:	b7e5                	j	80 <alphabet+0x28>
    }
}
  9a:	60a2                	ld	ra,8(sp)
  9c:	6402                	ld	s0,0(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

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

void sendChildrenToWork(int escalate, int thresh)
{
  fa:	7139                	addi	sp,sp,-64
  fc:	fc06                	sd	ra,56(sp)
  fe:	f822                	sd	s0,48(sp)
 100:	f426                	sd	s1,40(sp)
 102:	f04a                	sd	s2,32(sp)
 104:	ec4e                	sd	s3,24(sp)
 106:	0080                	addi	s0,sp,64

    for(int i = 0; i < n; i++){
 108:	00001797          	auipc	a5,0x1
 10c:	f147a783          	lw	a5,-236(a5) # 101c <n>
 110:	12f05c63          	blez	a5,248 <sendChildrenToWork+0x14e>
 114:	89aa                	mv	s3,a0
 116:	892e                	mv	s2,a1
        if((whoami = fork()) < 0 ){
 118:	00000097          	auipc	ra,0x0
 11c:	63e080e7          	jalr	1598(ra) # 756 <fork>
 120:	84aa                	mv	s1,a0
 122:	00001797          	auipc	a5,0x1
 126:	eea7ab23          	sw	a0,-266(a5) # 1018 <whoami>
 12a:	08054063          	bltz	a0,1aa <sendChildrenToWork+0xb0>
            printf("Fork Error!");
            exit(1);
        }
        if(whoami != -1){

            if(escalate == 1 && whoami >= thresh){
 12e:	4785                	li	a5,1
 130:	08f98a63          	beq	s3,a5,1c4 <sendChildrenToWork+0xca>
                printf("Attempting to escalate %d from 0x%x to 0x%x\n", whoami, getpri(), getpri()+1);
                setpri(getpri() + 1); // Request to elevate my priority by 1 level.
            }
            else if(escalate == -1 && whoami <= thresh){
 134:	57fd                	li	a5,-1
 136:	0cf98863          	beq	s3,a5,206 <sendChildrenToWork+0x10c>
                printf("Attempting to deescalate %d from 0x%x to 0x%x\n", whoami, getpri(), getpri()-1);
                setpri(getpri() - 1);
            }
            close(paused[1]); // close write, wont be writing
 13a:	00001517          	auipc	a0,0x1
 13e:	eda52503          	lw	a0,-294(a0) # 1014 <paused+0x4>
 142:	00000097          	auipc	ra,0x0
 146:	644080e7          	jalr	1604(ra) # 786 <close>
            int pause = 1;
 14a:	4785                	li	a5,1
 14c:	fcf42623          	sw	a5,-52(s0)
                printf("Hi I am '%d' with priority %x\n", whoami, getpri() );
 150:	00001497          	auipc	s1,0x1
 154:	ec84a483          	lw	s1,-312(s1) # 1018 <whoami>
 158:	00000097          	auipc	ra,0x0
 15c:	6c6080e7          	jalr	1734(ra) # 81e <getpri>
 160:	862a                	mv	a2,a0
 162:	85a6                	mv	a1,s1
 164:	00001517          	auipc	a0,0x1
 168:	c5c50513          	addi	a0,a0,-932 # dc0 <malloc+0x212>
 16c:	00001097          	auipc	ra,0x1
 170:	98a080e7          	jalr	-1654(ra) # af6 <printf>
            while(pause)
 174:	fcc42783          	lw	a5,-52(s0)
 178:	c385                	beqz	a5,198 <sendChildrenToWork+0x9e>
                read(paused[0], &pause, 1); // read from the buffer till no longer paused
 17a:	00001497          	auipc	s1,0x1
 17e:	e9648493          	addi	s1,s1,-362 # 1010 <paused>
 182:	4605                	li	a2,1
 184:	fcc40593          	addi	a1,s0,-52
 188:	4088                	lw	a0,0(s1)
 18a:	00000097          	auipc	ra,0x0
 18e:	5ec080e7          	jalr	1516(ra) # 776 <read>
            while(pause)
 192:	fcc42783          	lw	a5,-52(s0)
 196:	f7f5                	bnez	a5,182 <sendChildrenToWork+0x88>

            alphabet();
 198:	00000097          	auipc	ra,0x0
 19c:	ec0080e7          	jalr	-320(ra) # 58 <alphabet>
            exit(0);
 1a0:	4501                	li	a0,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	5bc080e7          	jalr	1468(ra) # 75e <exit>
            printf("Fork Error!");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	ba650513          	addi	a0,a0,-1114 # d50 <malloc+0x1a2>
 1b2:	00001097          	auipc	ra,0x1
 1b6:	944080e7          	jalr	-1724(ra) # af6 <printf>
            exit(1);
 1ba:	4505                	li	a0,1
 1bc:	00000097          	auipc	ra,0x0
 1c0:	5a2080e7          	jalr	1442(ra) # 75e <exit>
            if(escalate == 1 && whoami >= thresh){
 1c4:	f7254be3          	blt	a0,s2,13a <sendChildrenToWork+0x40>
                printf("Attempting to escalate %d from 0x%x to 0x%x\n", whoami, getpri(), getpri()+1);
 1c8:	00000097          	auipc	ra,0x0
 1cc:	656080e7          	jalr	1622(ra) # 81e <getpri>
 1d0:	892a                	mv	s2,a0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	64c080e7          	jalr	1612(ra) # 81e <getpri>
 1da:	0015069b          	addiw	a3,a0,1
 1de:	864a                	mv	a2,s2
 1e0:	85a6                	mv	a1,s1
 1e2:	00001517          	auipc	a0,0x1
 1e6:	b7e50513          	addi	a0,a0,-1154 # d60 <malloc+0x1b2>
 1ea:	00001097          	auipc	ra,0x1
 1ee:	90c080e7          	jalr	-1780(ra) # af6 <printf>
                setpri(getpri() + 1); // Request to elevate my priority by 1 level.
 1f2:	00000097          	auipc	ra,0x0
 1f6:	62c080e7          	jalr	1580(ra) # 81e <getpri>
 1fa:	2505                	addiw	a0,a0,1
 1fc:	00000097          	auipc	ra,0x0
 200:	62a080e7          	jalr	1578(ra) # 826 <setpri>
 204:	bf1d                	j	13a <sendChildrenToWork+0x40>
            else if(escalate == -1 && whoami <= thresh){
 206:	f2a94ae3          	blt	s2,a0,13a <sendChildrenToWork+0x40>
                printf("Attempting to deescalate %d from 0x%x to 0x%x\n", whoami, getpri(), getpri()-1);
 20a:	00000097          	auipc	ra,0x0
 20e:	614080e7          	jalr	1556(ra) # 81e <getpri>
 212:	892a                	mv	s2,a0
 214:	00000097          	auipc	ra,0x0
 218:	60a080e7          	jalr	1546(ra) # 81e <getpri>
 21c:	fff5069b          	addiw	a3,a0,-1
 220:	864a                	mv	a2,s2
 222:	85a6                	mv	a1,s1
 224:	00001517          	auipc	a0,0x1
 228:	b6c50513          	addi	a0,a0,-1172 # d90 <malloc+0x1e2>
 22c:	00001097          	auipc	ra,0x1
 230:	8ca080e7          	jalr	-1846(ra) # af6 <printf>
                setpri(getpri() - 1);
 234:	00000097          	auipc	ra,0x0
 238:	5ea080e7          	jalr	1514(ra) # 81e <getpri>
 23c:	357d                	addiw	a0,a0,-1
 23e:	00000097          	auipc	ra,0x0
 242:	5e8080e7          	jalr	1512(ra) # 826 <setpri>
 246:	bdd5                	j	13a <sendChildrenToWork+0x40>
        }
    }
    write(paused[1], "\1", 1);
 248:	4605                	li	a2,1
 24a:	00001597          	auipc	a1,0x1
 24e:	b9658593          	addi	a1,a1,-1130 # de0 <malloc+0x232>
 252:	00001517          	auipc	a0,0x1
 256:	dc252503          	lw	a0,-574(a0) # 1014 <paused+0x4>
 25a:	00000097          	auipc	ra,0x0
 25e:	524080e7          	jalr	1316(ra) # 77e <write>
    for(int i = 0; i < n; i++)
 262:	00001797          	auipc	a5,0x1
 266:	dba7a783          	lw	a5,-582(a5) # 101c <n>
 26a:	02f05163          	blez	a5,28c <sendChildrenToWork+0x192>
 26e:	4481                	li	s1,0
 270:	00001917          	auipc	s2,0x1
 274:	dac90913          	addi	s2,s2,-596 # 101c <n>
        wait(0); // wait for children to come back.
 278:	4501                	li	a0,0
 27a:	00000097          	auipc	ra,0x0
 27e:	4ec080e7          	jalr	1260(ra) # 766 <wait>
    for(int i = 0; i < n; i++)
 282:	2485                	addiw	s1,s1,1
 284:	00092783          	lw	a5,0(s2)
 288:	fef4c8e3          	blt	s1,a5,278 <sendChildrenToWork+0x17e>
}
 28c:	70e2                	ld	ra,56(sp)
 28e:	7442                	ld	s0,48(sp)
 290:	74a2                	ld	s1,40(sp)
 292:	7902                	ld	s2,32(sp)
 294:	69e2                	ld	s3,24(sp)
 296:	6121                	addi	sp,sp,64
 298:	8082                	ret

000000000000029a <main>:


/* ./schedtest <#children> */
int main(int argc, char * argv[]){
 29a:	7139                	addi	sp,sp,-64
 29c:	fc06                	sd	ra,56(sp)
 29e:	f822                	sd	s0,48(sp)
 2a0:	f426                	sd	s1,40(sp)
 2a2:	f04a                	sd	s2,32(sp)
 2a4:	ec4e                	sd	s3,24(sp)
 2a6:	e852                	sd	s4,16(sp)
 2a8:	e456                	sd	s5,8(sp)
 2aa:	0080                	addi	s0,sp,64
    if(!validate(argc, argv)) return 0;
 2ac:	00000097          	auipc	ra,0x0
 2b0:	d54080e7          	jalr	-684(ra) # 0 <validate>
 2b4:	e919                	bnez	a0,2ca <main+0x30>
   }
   return 0;



}
 2b6:	4501                	li	a0,0
 2b8:	70e2                	ld	ra,56(sp)
 2ba:	7442                	ld	s0,48(sp)
 2bc:	74a2                	ld	s1,40(sp)
 2be:	7902                	ld	s2,32(sp)
 2c0:	69e2                	ld	s3,24(sp)
 2c2:	6a42                	ld	s4,16(sp)
 2c4:	6aa2                	ld	s5,8(sp)
 2c6:	6121                	addi	sp,sp,64
 2c8:	8082                	ret
   printf("Welcome to the scheduling tool\nThis will test the current priorities of the system.\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	b1e50513          	addi	a0,a0,-1250 # de8 <malloc+0x23a>
 2d2:	00001097          	auipc	ra,0x1
 2d6:	824080e7          	jalr	-2012(ra) # af6 <printf>
   whoami = -1; // parent
 2da:	57fd                	li	a5,-1
 2dc:	00001717          	auipc	a4,0x1
 2e0:	d2f72e23          	sw	a5,-708(a4) # 1018 <whoami>
   int thresh = ((rand(&rand_next) % n)/2);
 2e4:	00001517          	auipc	a0,0x1
 2e8:	d1c50513          	addi	a0,a0,-740 # 1000 <rand_next>
 2ec:	00000097          	auipc	ra,0x0
 2f0:	db6080e7          	jalr	-586(ra) # a2 <do_rand>
 2f4:	00001797          	auipc	a5,0x1
 2f8:	d287a783          	lw	a5,-728(a5) # 101c <n>
 2fc:	02f569bb          	remw	s3,a0,a5
 300:	4789                	li	a5,2
 302:	02f9c9bb          	divw	s3,s3,a5
   printf("I am the Parent: %d\n", whoami);
 306:	55fd                	li	a1,-1
 308:	00001517          	auipc	a0,0x1
 30c:	b3850513          	addi	a0,a0,-1224 # e40 <malloc+0x292>
 310:	00000097          	auipc	ra,0x0
 314:	7e6080e7          	jalr	2022(ra) # af6 <printf>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 318:	00001497          	auipc	s1,0x1
 31c:	bc848493          	addi	s1,s1,-1080 # ee0 <prio>
 320:	00001a17          	auipc	s4,0x1
 324:	bd4a0a13          	addi	s4,s4,-1068 # ef4 <prio+0x14>
   printf("I am the Parent: %d\n", whoami);
 328:	8926                	mv	s2,s1
       printf("(No Escalation) Priority Test: 0x%x\n", prio[p]);
 32a:	00001a97          	auipc	s5,0x1
 32e:	b2ea8a93          	addi	s5,s5,-1234 # e58 <malloc+0x2aa>
 332:	00092583          	lw	a1,0(s2)
 336:	8556                	mv	a0,s5
 338:	00000097          	auipc	ra,0x0
 33c:	7be080e7          	jalr	1982(ra) # af6 <printf>
       sendChildrenToWork(0, thresh);
 340:	85ce                	mv	a1,s3
 342:	4501                	li	a0,0
 344:	00000097          	auipc	ra,0x0
 348:	db6080e7          	jalr	-586(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 34c:	0911                	addi	s2,s2,4
 34e:	ff4912e3          	bne	s2,s4,332 <main+0x98>
 352:	8926                	mv	s2,s1
       printf("(Applying Escalation) Priority Test: 0x%x\n", prio[p]);
 354:	00001a97          	auipc	s5,0x1
 358:	b2ca8a93          	addi	s5,s5,-1236 # e80 <malloc+0x2d2>
 35c:	00092583          	lw	a1,0(s2)
 360:	8556                	mv	a0,s5
 362:	00000097          	auipc	ra,0x0
 366:	794080e7          	jalr	1940(ra) # af6 <printf>
       sendChildrenToWork(1, thresh);
 36a:	85ce                	mv	a1,s3
 36c:	4505                	li	a0,1
 36e:	00000097          	auipc	ra,0x0
 372:	d8c080e7          	jalr	-628(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 376:	0911                	addi	s2,s2,4
 378:	ff4912e3          	bne	s2,s4,35c <main+0xc2>
       printf("(Applying Deescalation) Priority Test: 0x%x\n", prio[p]);
 37c:	00001917          	auipc	s2,0x1
 380:	b3490913          	addi	s2,s2,-1228 # eb0 <malloc+0x302>
 384:	408c                	lw	a1,0(s1)
 386:	854a                	mv	a0,s2
 388:	00000097          	auipc	ra,0x0
 38c:	76e080e7          	jalr	1902(ra) # af6 <printf>
       sendChildrenToWork(-1, thresh);
 390:	85ce                	mv	a1,s3
 392:	557d                	li	a0,-1
 394:	00000097          	auipc	ra,0x0
 398:	d66080e7          	jalr	-666(ra) # fa <sendChildrenToWork>
   for(int p = 0; p < (sizeof(prio)/sizeof(int)); p++){
 39c:	0491                	addi	s1,s1,4
 39e:	ff4493e3          	bne	s1,s4,384 <main+0xea>
 3a2:	bf11                	j	2b6 <main+0x1c>

00000000000003a4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  extern int main();
  main();
 3ac:	00000097          	auipc	ra,0x0
 3b0:	eee080e7          	jalr	-274(ra) # 29a <main>
  exit(0);
 3b4:	4501                	li	a0,0
 3b6:	00000097          	auipc	ra,0x0
 3ba:	3a8080e7          	jalr	936(ra) # 75e <exit>

00000000000003be <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3c4:	87aa                	mv	a5,a0
 3c6:	0585                	addi	a1,a1,1
 3c8:	0785                	addi	a5,a5,1
 3ca:	fff5c703          	lbu	a4,-1(a1)
 3ce:	fee78fa3          	sb	a4,-1(a5)
 3d2:	fb75                	bnez	a4,3c6 <strcpy+0x8>
    ;
  return os;
}
 3d4:	6422                	ld	s0,8(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3e0:	00054783          	lbu	a5,0(a0)
 3e4:	cb91                	beqz	a5,3f8 <strcmp+0x1e>
 3e6:	0005c703          	lbu	a4,0(a1)
 3ea:	00f71763          	bne	a4,a5,3f8 <strcmp+0x1e>
    p++, q++;
 3ee:	0505                	addi	a0,a0,1
 3f0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3f2:	00054783          	lbu	a5,0(a0)
 3f6:	fbe5                	bnez	a5,3e6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3f8:	0005c503          	lbu	a0,0(a1)
}
 3fc:	40a7853b          	subw	a0,a5,a0
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret

0000000000000406 <strlen>:

uint
strlen(const char *s)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 40c:	00054783          	lbu	a5,0(a0)
 410:	cf91                	beqz	a5,42c <strlen+0x26>
 412:	0505                	addi	a0,a0,1
 414:	87aa                	mv	a5,a0
 416:	86be                	mv	a3,a5
 418:	0785                	addi	a5,a5,1
 41a:	fff7c703          	lbu	a4,-1(a5)
 41e:	ff65                	bnez	a4,416 <strlen+0x10>
 420:	40a6853b          	subw	a0,a3,a0
 424:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  for(n = 0; s[n]; n++)
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <strlen+0x20>

0000000000000430 <memset>:

void*
memset(void *dst, int c, uint n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e422                	sd	s0,8(sp)
 434:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 436:	ca19                	beqz	a2,44c <memset+0x1c>
 438:	87aa                	mv	a5,a0
 43a:	1602                	slli	a2,a2,0x20
 43c:	9201                	srli	a2,a2,0x20
 43e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 442:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 446:	0785                	addi	a5,a5,1
 448:	fee79de3          	bne	a5,a4,442 <memset+0x12>
  }
  return dst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <strchr>:

char*
strchr(const char *s, char c)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  for(; *s; s++)
 458:	00054783          	lbu	a5,0(a0)
 45c:	cb99                	beqz	a5,472 <strchr+0x20>
    if(*s == c)
 45e:	00f58763          	beq	a1,a5,46c <strchr+0x1a>
  for(; *s; s++)
 462:	0505                	addi	a0,a0,1
 464:	00054783          	lbu	a5,0(a0)
 468:	fbfd                	bnez	a5,45e <strchr+0xc>
      return (char*)s;
  return 0;
 46a:	4501                	li	a0,0
}
 46c:	6422                	ld	s0,8(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret
  return 0;
 472:	4501                	li	a0,0
 474:	bfe5                	j	46c <strchr+0x1a>

0000000000000476 <gets>:

char*
gets(char *buf, int max)
{
 476:	711d                	addi	sp,sp,-96
 478:	ec86                	sd	ra,88(sp)
 47a:	e8a2                	sd	s0,80(sp)
 47c:	e4a6                	sd	s1,72(sp)
 47e:	e0ca                	sd	s2,64(sp)
 480:	fc4e                	sd	s3,56(sp)
 482:	f852                	sd	s4,48(sp)
 484:	f456                	sd	s5,40(sp)
 486:	f05a                	sd	s6,32(sp)
 488:	ec5e                	sd	s7,24(sp)
 48a:	1080                	addi	s0,sp,96
 48c:	8baa                	mv	s7,a0
 48e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 490:	892a                	mv	s2,a0
 492:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 494:	4aa9                	li	s5,10
 496:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 498:	89a6                	mv	s3,s1
 49a:	2485                	addiw	s1,s1,1
 49c:	0344d863          	bge	s1,s4,4cc <gets+0x56>
    cc = read(0, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	faf40593          	addi	a1,s0,-81
 4a6:	4501                	li	a0,0
 4a8:	00000097          	auipc	ra,0x0
 4ac:	2ce080e7          	jalr	718(ra) # 776 <read>
    if(cc < 1)
 4b0:	00a05e63          	blez	a0,4cc <gets+0x56>
    buf[i++] = c;
 4b4:	faf44783          	lbu	a5,-81(s0)
 4b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4bc:	01578763          	beq	a5,s5,4ca <gets+0x54>
 4c0:	0905                	addi	s2,s2,1
 4c2:	fd679be3          	bne	a5,s6,498 <gets+0x22>
  for(i=0; i+1 < max; ){
 4c6:	89a6                	mv	s3,s1
 4c8:	a011                	j	4cc <gets+0x56>
 4ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4cc:	99de                	add	s3,s3,s7
 4ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 4d2:	855e                	mv	a0,s7
 4d4:	60e6                	ld	ra,88(sp)
 4d6:	6446                	ld	s0,80(sp)
 4d8:	64a6                	ld	s1,72(sp)
 4da:	6906                	ld	s2,64(sp)
 4dc:	79e2                	ld	s3,56(sp)
 4de:	7a42                	ld	s4,48(sp)
 4e0:	7aa2                	ld	s5,40(sp)
 4e2:	7b02                	ld	s6,32(sp)
 4e4:	6be2                	ld	s7,24(sp)
 4e6:	6125                	addi	sp,sp,96
 4e8:	8082                	ret

00000000000004ea <stat>:

int
stat(const char *n, struct stat *st)
{
 4ea:	1101                	addi	sp,sp,-32
 4ec:	ec06                	sd	ra,24(sp)
 4ee:	e822                	sd	s0,16(sp)
 4f0:	e426                	sd	s1,8(sp)
 4f2:	e04a                	sd	s2,0(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4f8:	4581                	li	a1,0
 4fa:	00000097          	auipc	ra,0x0
 4fe:	2a4080e7          	jalr	676(ra) # 79e <open>
  if(fd < 0)
 502:	02054563          	bltz	a0,52c <stat+0x42>
 506:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 508:	85ca                	mv	a1,s2
 50a:	00000097          	auipc	ra,0x0
 50e:	2ac080e7          	jalr	684(ra) # 7b6 <fstat>
 512:	892a                	mv	s2,a0
  close(fd);
 514:	8526                	mv	a0,s1
 516:	00000097          	auipc	ra,0x0
 51a:	270080e7          	jalr	624(ra) # 786 <close>
  return r;
}
 51e:	854a                	mv	a0,s2
 520:	60e2                	ld	ra,24(sp)
 522:	6442                	ld	s0,16(sp)
 524:	64a2                	ld	s1,8(sp)
 526:	6902                	ld	s2,0(sp)
 528:	6105                	addi	sp,sp,32
 52a:	8082                	ret
    return -1;
 52c:	597d                	li	s2,-1
 52e:	bfc5                	j	51e <stat+0x34>

0000000000000530 <atoi>:

int
atoi(const char *s)
{
 530:	1141                	addi	sp,sp,-16
 532:	e422                	sd	s0,8(sp)
 534:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
 536:	00054683          	lbu	a3,0(a0)
 53a:	fd06879b          	addiw	a5,a3,-48
 53e:	0ff7f793          	zext.b	a5,a5
 542:	4625                	li	a2,9
 544:	02f66863          	bltu	a2,a5,574 <atoi+0x44>
 548:	872a                	mv	a4,a0
  n = 0;
 54a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 54c:	0705                	addi	a4,a4,1
 54e:	0025179b          	slliw	a5,a0,0x2
 552:	9fa9                	addw	a5,a5,a0
 554:	0017979b          	slliw	a5,a5,0x1
 558:	9fb5                	addw	a5,a5,a3
 55a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 55e:	00074683          	lbu	a3,0(a4)
 562:	fd06879b          	addiw	a5,a3,-48
 566:	0ff7f793          	zext.b	a5,a5
 56a:	fef671e3          	bgeu	a2,a5,54c <atoi+0x1c>

  return n;
}
 56e:	6422                	ld	s0,8(sp)
 570:	0141                	addi	sp,sp,16
 572:	8082                	ret
  n = 0;
 574:	4501                	li	a0,0
 576:	bfe5                	j	56e <atoi+0x3e>

0000000000000578 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
 578:	1141                	addi	sp,sp,-16
 57a:	e422                	sd	s0,8(sp)
 57c:	0800                	addi	s0,sp,16
 57e:	8eaa                	mv	t4,a0
    register const char *s = strt;
 580:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
 582:	02000693          	li	a3,32
        c = *s++;
 586:	883e                	mv	a6,a5
 588:	0785                	addi	a5,a5,1
 58a:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
 58e:	fed70ce3          	beq	a4,a3,586 <strtoi+0xe>
        c = *s++;
 592:	2701                	sext.w	a4,a4

    if (c == '-') {
 594:	02d00693          	li	a3,45
 598:	04d70d63          	beq	a4,a3,5f2 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
 59c:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
 5a0:	4f01                	li	t5,0
    } else if (c == '+')
 5a2:	04d70e63          	beq	a4,a3,5fe <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
 5a6:	fef67693          	andi	a3,a2,-17
 5aa:	ea99                	bnez	a3,5c0 <strtoi+0x48>
 5ac:	03000693          	li	a3,48
 5b0:	04d70c63          	beq	a4,a3,608 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
 5b4:	e611                	bnez	a2,5c0 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
 5b6:	03000693          	li	a3,48
 5ba:	0cd70b63          	beq	a4,a3,690 <strtoi+0x118>
 5be:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 5c0:	800008b7          	lui	a7,0x80000
 5c4:	fff8c893          	not	a7,a7
 5c8:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
 5cc:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
 5d0:	1882                	slli	a7,a7,0x20
 5d2:	0208d893          	srli	a7,a7,0x20
 5d6:	02c8d8b3          	divu	a7,a7,a2
 5da:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
 5de:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
 5e2:	0ac75163          	bge	a4,a2,684 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
 5e6:	4681                	li	a3,0
 5e8:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
 5ea:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 5ec:	2881                	sext.w	a7,a7
        else {
            any = 1;
 5ee:	4f85                	li	t6,1
 5f0:	a0a9                	j	63a <strtoi+0xc2>
        c = *s++;
 5f2:	0007c703          	lbu	a4,0(a5)
 5f6:	00280793          	addi	a5,a6,2
        neg = 1;
 5fa:	4f05                	li	t5,1
 5fc:	b76d                	j	5a6 <strtoi+0x2e>
        c = *s++;
 5fe:	0007c703          	lbu	a4,0(a5)
 602:	00280793          	addi	a5,a6,2
 606:	b745                	j	5a6 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
 608:	0007c683          	lbu	a3,0(a5)
 60c:	0df6f693          	andi	a3,a3,223
 610:	05800513          	li	a0,88
 614:	faa690e3          	bne	a3,a0,5b4 <strtoi+0x3c>
        c = s[1];
 618:	0017c703          	lbu	a4,1(a5)
        s += 2;
 61c:	0789                	addi	a5,a5,2
        base = 16;
 61e:	4641                	li	a2,16
 620:	b745                	j	5c0 <strtoi+0x48>
            any = -1;
 622:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 624:	00e2c463          	blt	t0,a4,62c <strtoi+0xb4>
 628:	a015                	j	64c <strtoi+0xd4>
            any = -1;
 62a:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
 62c:	0785                	addi	a5,a5,1
 62e:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
 632:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
 636:	02c75063          	bge	a4,a2,656 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 63a:	fe06c8e3          	bltz	a3,62a <strtoi+0xb2>
 63e:	0005081b          	sext.w	a6,a0
            any = -1;
 642:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
 644:	ff0e64e3          	bltu	t3,a6,62c <strtoi+0xb4>
 648:	fca88de3          	beq	a7,a0,622 <strtoi+0xaa>
            acc *= base;
 64c:	02c5053b          	mulw	a0,a0,a2
            acc += c;
 650:	9d39                	addw	a0,a0,a4
            any = 1;
 652:	86fe                	mv	a3,t6
 654:	bfe1                	j	62c <strtoi+0xb4>
        }
    }
    if (any < 0) {
 656:	0006cd63          	bltz	a3,670 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
 65a:	000f0463          	beqz	t5,662 <strtoi+0xea>
        acc = -acc;
 65e:	40a0053b          	negw	a0,a0
    if (end != 0)
 662:	c581                	beqz	a1,66a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 664:	ee89                	bnez	a3,67e <strtoi+0x106>
 666:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
 66a:	6422                	ld	s0,8(sp)
 66c:	0141                	addi	sp,sp,16
 66e:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
 670:	000f1d63          	bnez	t5,68a <strtoi+0x112>
 674:	80000537          	lui	a0,0x80000
 678:	fff54513          	not	a0,a0
    if (end != 0)
 67c:	d5fd                	beqz	a1,66a <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
 67e:	fff78e93          	addi	t4,a5,-1
 682:	b7d5                	j	666 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
 684:	4681                	li	a3,0
 686:	4501                	li	a0,0
 688:	bfc9                	j	65a <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
 68a:	80000537          	lui	a0,0x80000
 68e:	b7fd                	j	67c <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
 690:	80000e37          	lui	t3,0x80000
 694:	fffe4e13          	not	t3,t3
 698:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
 69c:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
 6a0:	003e589b          	srliw	a7,t3,0x3
 6a4:	8e46                	mv	t3,a7
            c -= '0';
 6a6:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
 6a8:	4621                	li	a2,8
 6aa:	bf35                	j	5e6 <strtoi+0x6e>

00000000000006ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6ac:	1141                	addi	sp,sp,-16
 6ae:	e422                	sd	s0,8(sp)
 6b0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6b2:	02b57463          	bgeu	a0,a1,6da <memmove+0x2e>
    while(n-- > 0)
 6b6:	00c05f63          	blez	a2,6d4 <memmove+0x28>
 6ba:	1602                	slli	a2,a2,0x20
 6bc:	9201                	srli	a2,a2,0x20
 6be:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6c2:	872a                	mv	a4,a0
      *dst++ = *src++;
 6c4:	0585                	addi	a1,a1,1
 6c6:	0705                	addi	a4,a4,1
 6c8:	fff5c683          	lbu	a3,-1(a1)
 6cc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6d0:	fee79ae3          	bne	a5,a4,6c4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6d4:	6422                	ld	s0,8(sp)
 6d6:	0141                	addi	sp,sp,16
 6d8:	8082                	ret
    dst += n;
 6da:	00c50733          	add	a4,a0,a2
    src += n;
 6de:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6e0:	fec05ae3          	blez	a2,6d4 <memmove+0x28>
 6e4:	fff6079b          	addiw	a5,a2,-1
 6e8:	1782                	slli	a5,a5,0x20
 6ea:	9381                	srli	a5,a5,0x20
 6ec:	fff7c793          	not	a5,a5
 6f0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6f2:	15fd                	addi	a1,a1,-1
 6f4:	177d                	addi	a4,a4,-1
 6f6:	0005c683          	lbu	a3,0(a1)
 6fa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6fe:	fee79ae3          	bne	a5,a4,6f2 <memmove+0x46>
 702:	bfc9                	j	6d4 <memmove+0x28>

0000000000000704 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 704:	1141                	addi	sp,sp,-16
 706:	e422                	sd	s0,8(sp)
 708:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 70a:	ca05                	beqz	a2,73a <memcmp+0x36>
 70c:	fff6069b          	addiw	a3,a2,-1
 710:	1682                	slli	a3,a3,0x20
 712:	9281                	srli	a3,a3,0x20
 714:	0685                	addi	a3,a3,1
 716:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 718:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffefd0>
 71c:	0005c703          	lbu	a4,0(a1)
 720:	00e79863          	bne	a5,a4,730 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 724:	0505                	addi	a0,a0,1
    p2++;
 726:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 728:	fed518e3          	bne	a0,a3,718 <memcmp+0x14>
  }
  return 0;
 72c:	4501                	li	a0,0
 72e:	a019                	j	734 <memcmp+0x30>
      return *p1 - *p2;
 730:	40e7853b          	subw	a0,a5,a4
}
 734:	6422                	ld	s0,8(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret
  return 0;
 73a:	4501                	li	a0,0
 73c:	bfe5                	j	734 <memcmp+0x30>

000000000000073e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 73e:	1141                	addi	sp,sp,-16
 740:	e406                	sd	ra,8(sp)
 742:	e022                	sd	s0,0(sp)
 744:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 746:	00000097          	auipc	ra,0x0
 74a:	f66080e7          	jalr	-154(ra) # 6ac <memmove>
}
 74e:	60a2                	ld	ra,8(sp)
 750:	6402                	ld	s0,0(sp)
 752:	0141                	addi	sp,sp,16
 754:	8082                	ret

0000000000000756 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 756:	4885                	li	a7,1
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <exit>:
.global exit
exit:
 li a7, SYS_exit
 75e:	4889                	li	a7,2
 ecall
 760:	00000073          	ecall
 ret
 764:	8082                	ret

0000000000000766 <wait>:
.global wait
wait:
 li a7, SYS_wait
 766:	488d                	li	a7,3
 ecall
 768:	00000073          	ecall
 ret
 76c:	8082                	ret

000000000000076e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 76e:	4891                	li	a7,4
 ecall
 770:	00000073          	ecall
 ret
 774:	8082                	ret

0000000000000776 <read>:
.global read
read:
 li a7, SYS_read
 776:	4895                	li	a7,5
 ecall
 778:	00000073          	ecall
 ret
 77c:	8082                	ret

000000000000077e <write>:
.global write
write:
 li a7, SYS_write
 77e:	48c1                	li	a7,16
 ecall
 780:	00000073          	ecall
 ret
 784:	8082                	ret

0000000000000786 <close>:
.global close
close:
 li a7, SYS_close
 786:	48d5                	li	a7,21
 ecall
 788:	00000073          	ecall
 ret
 78c:	8082                	ret

000000000000078e <kill>:
.global kill
kill:
 li a7, SYS_kill
 78e:	4899                	li	a7,6
 ecall
 790:	00000073          	ecall
 ret
 794:	8082                	ret

0000000000000796 <exec>:
.global exec
exec:
 li a7, SYS_exec
 796:	489d                	li	a7,7
 ecall
 798:	00000073          	ecall
 ret
 79c:	8082                	ret

000000000000079e <open>:
.global open
open:
 li a7, SYS_open
 79e:	48bd                	li	a7,15
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7a6:	48c5                	li	a7,17
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7ae:	48c9                	li	a7,18
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7b6:	48a1                	li	a7,8
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <link>:
.global link
link:
 li a7, SYS_link
 7be:	48cd                	li	a7,19
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7c6:	48d1                	li	a7,20
 ecall
 7c8:	00000073          	ecall
 ret
 7cc:	8082                	ret

00000000000007ce <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7ce:	48a5                	li	a7,9
 ecall
 7d0:	00000073          	ecall
 ret
 7d4:	8082                	ret

00000000000007d6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 7d6:	48a9                	li	a7,10
 ecall
 7d8:	00000073          	ecall
 ret
 7dc:	8082                	ret

00000000000007de <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7de:	48ad                	li	a7,11
 ecall
 7e0:	00000073          	ecall
 ret
 7e4:	8082                	ret

00000000000007e6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7e6:	48b1                	li	a7,12
 ecall
 7e8:	00000073          	ecall
 ret
 7ec:	8082                	ret

00000000000007ee <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7ee:	48b5                	li	a7,13
 ecall
 7f0:	00000073          	ecall
 ret
 7f4:	8082                	ret

00000000000007f6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7f6:	48b9                	li	a7,14
 ecall
 7f8:	00000073          	ecall
 ret
 7fc:	8082                	ret

00000000000007fe <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
 7fe:	48d9                	li	a7,22
 ecall
 800:	00000073          	ecall
 ret
 804:	8082                	ret

0000000000000806 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
 806:	48dd                	li	a7,23
 ecall
 808:	00000073          	ecall
 ret
 80c:	8082                	ret

000000000000080e <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
 80e:	48e1                	li	a7,24
 ecall
 810:	00000073          	ecall
 ret
 814:	8082                	ret

0000000000000816 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
 816:	48e5                	li	a7,25
 ecall
 818:	00000073          	ecall
 ret
 81c:	8082                	ret

000000000000081e <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
 81e:	48e9                	li	a7,26
 ecall
 820:	00000073          	ecall
 ret
 824:	8082                	ret

0000000000000826 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
 826:	48ed                	li	a7,27
 ecall
 828:	00000073          	ecall
 ret
 82c:	8082                	ret

000000000000082e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 82e:	1101                	addi	sp,sp,-32
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 83a:	4605                	li	a2,1
 83c:	fef40593          	addi	a1,s0,-17
 840:	00000097          	auipc	ra,0x0
 844:	f3e080e7          	jalr	-194(ra) # 77e <write>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6105                	addi	sp,sp,32
 84e:	8082                	ret

0000000000000850 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 850:	7139                	addi	sp,sp,-64
 852:	fc06                	sd	ra,56(sp)
 854:	f822                	sd	s0,48(sp)
 856:	f426                	sd	s1,40(sp)
 858:	f04a                	sd	s2,32(sp)
 85a:	ec4e                	sd	s3,24(sp)
 85c:	0080                	addi	s0,sp,64
 85e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 860:	c299                	beqz	a3,866 <printint+0x16>
 862:	0805c963          	bltz	a1,8f4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 866:	2581                	sext.w	a1,a1
  neg = 0;
 868:	4881                	li	a7,0
 86a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 86e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 870:	2601                	sext.w	a2,a2
 872:	00000517          	auipc	a0,0x0
 876:	6e650513          	addi	a0,a0,1766 # f58 <digits>
 87a:	883a                	mv	a6,a4
 87c:	2705                	addiw	a4,a4,1
 87e:	02c5f7bb          	remuw	a5,a1,a2
 882:	1782                	slli	a5,a5,0x20
 884:	9381                	srli	a5,a5,0x20
 886:	97aa                	add	a5,a5,a0
 888:	0007c783          	lbu	a5,0(a5)
 88c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 890:	0005879b          	sext.w	a5,a1
 894:	02c5d5bb          	divuw	a1,a1,a2
 898:	0685                	addi	a3,a3,1
 89a:	fec7f0e3          	bgeu	a5,a2,87a <printint+0x2a>
  if(neg)
 89e:	00088c63          	beqz	a7,8b6 <printint+0x66>
    buf[i++] = '-';
 8a2:	fd070793          	addi	a5,a4,-48
 8a6:	00878733          	add	a4,a5,s0
 8aa:	02d00793          	li	a5,45
 8ae:	fef70823          	sb	a5,-16(a4)
 8b2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 8b6:	02e05863          	blez	a4,8e6 <printint+0x96>
 8ba:	fc040793          	addi	a5,s0,-64
 8be:	00e78933          	add	s2,a5,a4
 8c2:	fff78993          	addi	s3,a5,-1
 8c6:	99ba                	add	s3,s3,a4
 8c8:	377d                	addiw	a4,a4,-1
 8ca:	1702                	slli	a4,a4,0x20
 8cc:	9301                	srli	a4,a4,0x20
 8ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8d2:	fff94583          	lbu	a1,-1(s2)
 8d6:	8526                	mv	a0,s1
 8d8:	00000097          	auipc	ra,0x0
 8dc:	f56080e7          	jalr	-170(ra) # 82e <putc>
  while(--i >= 0)
 8e0:	197d                	addi	s2,s2,-1
 8e2:	ff3918e3          	bne	s2,s3,8d2 <printint+0x82>
}
 8e6:	70e2                	ld	ra,56(sp)
 8e8:	7442                	ld	s0,48(sp)
 8ea:	74a2                	ld	s1,40(sp)
 8ec:	7902                	ld	s2,32(sp)
 8ee:	69e2                	ld	s3,24(sp)
 8f0:	6121                	addi	sp,sp,64
 8f2:	8082                	ret
    x = -xx;
 8f4:	40b005bb          	negw	a1,a1
    neg = 1;
 8f8:	4885                	li	a7,1
    x = -xx;
 8fa:	bf85                	j	86a <printint+0x1a>

00000000000008fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8fc:	715d                	addi	sp,sp,-80
 8fe:	e486                	sd	ra,72(sp)
 900:	e0a2                	sd	s0,64(sp)
 902:	fc26                	sd	s1,56(sp)
 904:	f84a                	sd	s2,48(sp)
 906:	f44e                	sd	s3,40(sp)
 908:	f052                	sd	s4,32(sp)
 90a:	ec56                	sd	s5,24(sp)
 90c:	e85a                	sd	s6,16(sp)
 90e:	e45e                	sd	s7,8(sp)
 910:	e062                	sd	s8,0(sp)
 912:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 914:	0005c903          	lbu	s2,0(a1)
 918:	18090c63          	beqz	s2,ab0 <vprintf+0x1b4>
 91c:	8aaa                	mv	s5,a0
 91e:	8bb2                	mv	s7,a2
 920:	00158493          	addi	s1,a1,1
  state = 0;
 924:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 926:	02500a13          	li	s4,37
 92a:	4b55                	li	s6,21
 92c:	a839                	j	94a <vprintf+0x4e>
        putc(fd, c);
 92e:	85ca                	mv	a1,s2
 930:	8556                	mv	a0,s5
 932:	00000097          	auipc	ra,0x0
 936:	efc080e7          	jalr	-260(ra) # 82e <putc>
 93a:	a019                	j	940 <vprintf+0x44>
    } else if(state == '%'){
 93c:	01498d63          	beq	s3,s4,956 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 940:	0485                	addi	s1,s1,1
 942:	fff4c903          	lbu	s2,-1(s1)
 946:	16090563          	beqz	s2,ab0 <vprintf+0x1b4>
    if(state == 0){
 94a:	fe0999e3          	bnez	s3,93c <vprintf+0x40>
      if(c == '%'){
 94e:	ff4910e3          	bne	s2,s4,92e <vprintf+0x32>
        state = '%';
 952:	89d2                	mv	s3,s4
 954:	b7f5                	j	940 <vprintf+0x44>
      if(c == 'd'){
 956:	13490263          	beq	s2,s4,a7a <vprintf+0x17e>
 95a:	f9d9079b          	addiw	a5,s2,-99
 95e:	0ff7f793          	zext.b	a5,a5
 962:	12fb6563          	bltu	s6,a5,a8c <vprintf+0x190>
 966:	f9d9079b          	addiw	a5,s2,-99
 96a:	0ff7f713          	zext.b	a4,a5
 96e:	10eb6f63          	bltu	s6,a4,a8c <vprintf+0x190>
 972:	00271793          	slli	a5,a4,0x2
 976:	00000717          	auipc	a4,0x0
 97a:	58a70713          	addi	a4,a4,1418 # f00 <prio+0x20>
 97e:	97ba                	add	a5,a5,a4
 980:	439c                	lw	a5,0(a5)
 982:	97ba                	add	a5,a5,a4
 984:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 986:	008b8913          	addi	s2,s7,8
 98a:	4685                	li	a3,1
 98c:	4629                	li	a2,10
 98e:	000ba583          	lw	a1,0(s7)
 992:	8556                	mv	a0,s5
 994:	00000097          	auipc	ra,0x0
 998:	ebc080e7          	jalr	-324(ra) # 850 <printint>
 99c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 99e:	4981                	li	s3,0
 9a0:	b745                	j	940 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9a2:	008b8913          	addi	s2,s7,8
 9a6:	4681                	li	a3,0
 9a8:	4629                	li	a2,10
 9aa:	000ba583          	lw	a1,0(s7)
 9ae:	8556                	mv	a0,s5
 9b0:	00000097          	auipc	ra,0x0
 9b4:	ea0080e7          	jalr	-352(ra) # 850 <printint>
 9b8:	8bca                	mv	s7,s2
      state = 0;
 9ba:	4981                	li	s3,0
 9bc:	b751                	j	940 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 9be:	008b8913          	addi	s2,s7,8
 9c2:	4681                	li	a3,0
 9c4:	4641                	li	a2,16
 9c6:	000ba583          	lw	a1,0(s7)
 9ca:	8556                	mv	a0,s5
 9cc:	00000097          	auipc	ra,0x0
 9d0:	e84080e7          	jalr	-380(ra) # 850 <printint>
 9d4:	8bca                	mv	s7,s2
      state = 0;
 9d6:	4981                	li	s3,0
 9d8:	b7a5                	j	940 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 9da:	008b8c13          	addi	s8,s7,8
 9de:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 9e2:	03000593          	li	a1,48
 9e6:	8556                	mv	a0,s5
 9e8:	00000097          	auipc	ra,0x0
 9ec:	e46080e7          	jalr	-442(ra) # 82e <putc>
  putc(fd, 'x');
 9f0:	07800593          	li	a1,120
 9f4:	8556                	mv	a0,s5
 9f6:	00000097          	auipc	ra,0x0
 9fa:	e38080e7          	jalr	-456(ra) # 82e <putc>
 9fe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a00:	00000b97          	auipc	s7,0x0
 a04:	558b8b93          	addi	s7,s7,1368 # f58 <digits>
 a08:	03c9d793          	srli	a5,s3,0x3c
 a0c:	97de                	add	a5,a5,s7
 a0e:	0007c583          	lbu	a1,0(a5)
 a12:	8556                	mv	a0,s5
 a14:	00000097          	auipc	ra,0x0
 a18:	e1a080e7          	jalr	-486(ra) # 82e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a1c:	0992                	slli	s3,s3,0x4
 a1e:	397d                	addiw	s2,s2,-1
 a20:	fe0914e3          	bnez	s2,a08 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 a24:	8be2                	mv	s7,s8
      state = 0;
 a26:	4981                	li	s3,0
 a28:	bf21                	j	940 <vprintf+0x44>
        s = va_arg(ap, char*);
 a2a:	008b8993          	addi	s3,s7,8
 a2e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 a32:	02090163          	beqz	s2,a54 <vprintf+0x158>
        while(*s != 0){
 a36:	00094583          	lbu	a1,0(s2)
 a3a:	c9a5                	beqz	a1,aaa <vprintf+0x1ae>
          putc(fd, *s);
 a3c:	8556                	mv	a0,s5
 a3e:	00000097          	auipc	ra,0x0
 a42:	df0080e7          	jalr	-528(ra) # 82e <putc>
          s++;
 a46:	0905                	addi	s2,s2,1
        while(*s != 0){
 a48:	00094583          	lbu	a1,0(s2)
 a4c:	f9e5                	bnez	a1,a3c <vprintf+0x140>
        s = va_arg(ap, char*);
 a4e:	8bce                	mv	s7,s3
      state = 0;
 a50:	4981                	li	s3,0
 a52:	b5fd                	j	940 <vprintf+0x44>
          s = "(null)";
 a54:	00000917          	auipc	s2,0x0
 a58:	4a490913          	addi	s2,s2,1188 # ef8 <prio+0x18>
        while(*s != 0){
 a5c:	02800593          	li	a1,40
 a60:	bff1                	j	a3c <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 a62:	008b8913          	addi	s2,s7,8
 a66:	000bc583          	lbu	a1,0(s7)
 a6a:	8556                	mv	a0,s5
 a6c:	00000097          	auipc	ra,0x0
 a70:	dc2080e7          	jalr	-574(ra) # 82e <putc>
 a74:	8bca                	mv	s7,s2
      state = 0;
 a76:	4981                	li	s3,0
 a78:	b5e1                	j	940 <vprintf+0x44>
        putc(fd, c);
 a7a:	02500593          	li	a1,37
 a7e:	8556                	mv	a0,s5
 a80:	00000097          	auipc	ra,0x0
 a84:	dae080e7          	jalr	-594(ra) # 82e <putc>
      state = 0;
 a88:	4981                	li	s3,0
 a8a:	bd5d                	j	940 <vprintf+0x44>
        putc(fd, '%');
 a8c:	02500593          	li	a1,37
 a90:	8556                	mv	a0,s5
 a92:	00000097          	auipc	ra,0x0
 a96:	d9c080e7          	jalr	-612(ra) # 82e <putc>
        putc(fd, c);
 a9a:	85ca                	mv	a1,s2
 a9c:	8556                	mv	a0,s5
 a9e:	00000097          	auipc	ra,0x0
 aa2:	d90080e7          	jalr	-624(ra) # 82e <putc>
      state = 0;
 aa6:	4981                	li	s3,0
 aa8:	bd61                	j	940 <vprintf+0x44>
        s = va_arg(ap, char*);
 aaa:	8bce                	mv	s7,s3
      state = 0;
 aac:	4981                	li	s3,0
 aae:	bd49                	j	940 <vprintf+0x44>
    }
  }
}
 ab0:	60a6                	ld	ra,72(sp)
 ab2:	6406                	ld	s0,64(sp)
 ab4:	74e2                	ld	s1,56(sp)
 ab6:	7942                	ld	s2,48(sp)
 ab8:	79a2                	ld	s3,40(sp)
 aba:	7a02                	ld	s4,32(sp)
 abc:	6ae2                	ld	s5,24(sp)
 abe:	6b42                	ld	s6,16(sp)
 ac0:	6ba2                	ld	s7,8(sp)
 ac2:	6c02                	ld	s8,0(sp)
 ac4:	6161                	addi	sp,sp,80
 ac6:	8082                	ret

0000000000000ac8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ac8:	715d                	addi	sp,sp,-80
 aca:	ec06                	sd	ra,24(sp)
 acc:	e822                	sd	s0,16(sp)
 ace:	1000                	addi	s0,sp,32
 ad0:	e010                	sd	a2,0(s0)
 ad2:	e414                	sd	a3,8(s0)
 ad4:	e818                	sd	a4,16(s0)
 ad6:	ec1c                	sd	a5,24(s0)
 ad8:	03043023          	sd	a6,32(s0)
 adc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ae0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ae4:	8622                	mv	a2,s0
 ae6:	00000097          	auipc	ra,0x0
 aea:	e16080e7          	jalr	-490(ra) # 8fc <vprintf>
}
 aee:	60e2                	ld	ra,24(sp)
 af0:	6442                	ld	s0,16(sp)
 af2:	6161                	addi	sp,sp,80
 af4:	8082                	ret

0000000000000af6 <printf>:

void
printf(const char *fmt, ...)
{
 af6:	711d                	addi	sp,sp,-96
 af8:	ec06                	sd	ra,24(sp)
 afa:	e822                	sd	s0,16(sp)
 afc:	1000                	addi	s0,sp,32
 afe:	e40c                	sd	a1,8(s0)
 b00:	e810                	sd	a2,16(s0)
 b02:	ec14                	sd	a3,24(s0)
 b04:	f018                	sd	a4,32(s0)
 b06:	f41c                	sd	a5,40(s0)
 b08:	03043823          	sd	a6,48(s0)
 b0c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b10:	00840613          	addi	a2,s0,8
 b14:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b18:	85aa                	mv	a1,a0
 b1a:	4505                	li	a0,1
 b1c:	00000097          	auipc	ra,0x0
 b20:	de0080e7          	jalr	-544(ra) # 8fc <vprintf>
}
 b24:	60e2                	ld	ra,24(sp)
 b26:	6442                	ld	s0,16(sp)
 b28:	6125                	addi	sp,sp,96
 b2a:	8082                	ret

0000000000000b2c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b2c:	1141                	addi	sp,sp,-16
 b2e:	e422                	sd	s0,8(sp)
 b30:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b32:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b36:	00000797          	auipc	a5,0x0
 b3a:	4ea7b783          	ld	a5,1258(a5) # 1020 <freep>
 b3e:	a02d                	j	b68 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b40:	4618                	lw	a4,8(a2)
 b42:	9f2d                	addw	a4,a4,a1
 b44:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b48:	6398                	ld	a4,0(a5)
 b4a:	6310                	ld	a2,0(a4)
 b4c:	a83d                	j	b8a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b4e:	ff852703          	lw	a4,-8(a0)
 b52:	9f31                	addw	a4,a4,a2
 b54:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b56:	ff053683          	ld	a3,-16(a0)
 b5a:	a091                	j	b9e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b5c:	6398                	ld	a4,0(a5)
 b5e:	00e7e463          	bltu	a5,a4,b66 <free+0x3a>
 b62:	00e6ea63          	bltu	a3,a4,b76 <free+0x4a>
{
 b66:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b68:	fed7fae3          	bgeu	a5,a3,b5c <free+0x30>
 b6c:	6398                	ld	a4,0(a5)
 b6e:	00e6e463          	bltu	a3,a4,b76 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b72:	fee7eae3          	bltu	a5,a4,b66 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 b76:	ff852583          	lw	a1,-8(a0)
 b7a:	6390                	ld	a2,0(a5)
 b7c:	02059813          	slli	a6,a1,0x20
 b80:	01c85713          	srli	a4,a6,0x1c
 b84:	9736                	add	a4,a4,a3
 b86:	fae60de3          	beq	a2,a4,b40 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b8a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b8e:	4790                	lw	a2,8(a5)
 b90:	02061593          	slli	a1,a2,0x20
 b94:	01c5d713          	srli	a4,a1,0x1c
 b98:	973e                	add	a4,a4,a5
 b9a:	fae68ae3          	beq	a3,a4,b4e <free+0x22>
    p->s.ptr = bp->s.ptr;
 b9e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ba0:	00000717          	auipc	a4,0x0
 ba4:	48f73023          	sd	a5,1152(a4) # 1020 <freep>
}
 ba8:	6422                	ld	s0,8(sp)
 baa:	0141                	addi	sp,sp,16
 bac:	8082                	ret

0000000000000bae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bae:	7139                	addi	sp,sp,-64
 bb0:	fc06                	sd	ra,56(sp)
 bb2:	f822                	sd	s0,48(sp)
 bb4:	f426                	sd	s1,40(sp)
 bb6:	f04a                	sd	s2,32(sp)
 bb8:	ec4e                	sd	s3,24(sp)
 bba:	e852                	sd	s4,16(sp)
 bbc:	e456                	sd	s5,8(sp)
 bbe:	e05a                	sd	s6,0(sp)
 bc0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bc2:	02051493          	slli	s1,a0,0x20
 bc6:	9081                	srli	s1,s1,0x20
 bc8:	04bd                	addi	s1,s1,15
 bca:	8091                	srli	s1,s1,0x4
 bcc:	0014899b          	addiw	s3,s1,1
 bd0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bd2:	00000517          	auipc	a0,0x0
 bd6:	44e53503          	ld	a0,1102(a0) # 1020 <freep>
 bda:	c515                	beqz	a0,c06 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bdc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bde:	4798                	lw	a4,8(a5)
 be0:	02977f63          	bgeu	a4,s1,c1e <malloc+0x70>
  if(nu < 4096)
 be4:	8a4e                	mv	s4,s3
 be6:	0009871b          	sext.w	a4,s3
 bea:	6685                	lui	a3,0x1
 bec:	00d77363          	bgeu	a4,a3,bf2 <malloc+0x44>
 bf0:	6a05                	lui	s4,0x1
 bf2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bf6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bfa:	00000917          	auipc	s2,0x0
 bfe:	42690913          	addi	s2,s2,1062 # 1020 <freep>
  if(p == (char*)-1)
 c02:	5afd                	li	s5,-1
 c04:	a895                	j	c78 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c06:	00000797          	auipc	a5,0x0
 c0a:	42a78793          	addi	a5,a5,1066 # 1030 <base>
 c0e:	00000717          	auipc	a4,0x0
 c12:	40f73923          	sd	a5,1042(a4) # 1020 <freep>
 c16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c18:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c1c:	b7e1                	j	be4 <malloc+0x36>
      if(p->s.size == nunits)
 c1e:	02e48c63          	beq	s1,a4,c56 <malloc+0xa8>
        p->s.size -= nunits;
 c22:	4137073b          	subw	a4,a4,s3
 c26:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c28:	02071693          	slli	a3,a4,0x20
 c2c:	01c6d713          	srli	a4,a3,0x1c
 c30:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c32:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c36:	00000717          	auipc	a4,0x0
 c3a:	3ea73523          	sd	a0,1002(a4) # 1020 <freep>
      return (void*)(p + 1);
 c3e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c42:	70e2                	ld	ra,56(sp)
 c44:	7442                	ld	s0,48(sp)
 c46:	74a2                	ld	s1,40(sp)
 c48:	7902                	ld	s2,32(sp)
 c4a:	69e2                	ld	s3,24(sp)
 c4c:	6a42                	ld	s4,16(sp)
 c4e:	6aa2                	ld	s5,8(sp)
 c50:	6b02                	ld	s6,0(sp)
 c52:	6121                	addi	sp,sp,64
 c54:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c56:	6398                	ld	a4,0(a5)
 c58:	e118                	sd	a4,0(a0)
 c5a:	bff1                	j	c36 <malloc+0x88>
  hp->s.size = nu;
 c5c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c60:	0541                	addi	a0,a0,16
 c62:	00000097          	auipc	ra,0x0
 c66:	eca080e7          	jalr	-310(ra) # b2c <free>
  return freep;
 c6a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c6e:	d971                	beqz	a0,c42 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c70:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c72:	4798                	lw	a4,8(a5)
 c74:	fa9775e3          	bgeu	a4,s1,c1e <malloc+0x70>
    if(p == freep)
 c78:	00093703          	ld	a4,0(s2)
 c7c:	853e                	mv	a0,a5
 c7e:	fef719e3          	bne	a4,a5,c70 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c82:	8552                	mv	a0,s4
 c84:	00000097          	auipc	ra,0x0
 c88:	b62080e7          	jalr	-1182(ra) # 7e6 <sbrk>
  if(p == (char*)-1)
 c8c:	fd5518e3          	bne	a0,s5,c5c <malloc+0xae>
        return 0;
 c90:	4501                	li	a0,0
 c92:	bf45                	j	c42 <malloc+0x94>
