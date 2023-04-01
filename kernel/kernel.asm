
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a5010113          	addi	sp,sp,-1456 # 80008a50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8c070713          	addi	a4,a4,-1856 # 80008910 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c3e78793          	addi	a5,a5,-962 # 80005ca0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca7f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3f0080e7          	jalr	1008(ra) # 8000251a <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	8cc50513          	addi	a0,a0,-1844 # 80010a50 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	8bc48493          	addi	s1,s1,-1860 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	94c90913          	addi	s2,s2,-1716 # 80010ae8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	1a8080e7          	jalr	424(ra) # 80002364 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	ef2080e7          	jalr	-270(ra) # 800020bc <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	87270713          	addi	a4,a4,-1934 # 80010a50 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	2b4080e7          	jalr	692(ra) # 800024c4 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	82850513          	addi	a0,a0,-2008 # 80010a50 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	81250513          	addi	a0,a0,-2030 # 80010a50 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	86f72d23          	sw	a5,-1926(a4) # 80010ae8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	78850513          	addi	a0,a0,1928 # 80010a50 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	282080e7          	jalr	642(ra) # 80002570 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	75a50513          	addi	a0,a0,1882 # 80010a50 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	73670713          	addi	a4,a4,1846 # 80010a50 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	70c78793          	addi	a5,a5,1804 # 80010a50 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7767a783          	lw	a5,1910(a5) # 80010ae8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	6ca70713          	addi	a4,a4,1738 # 80010a50 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	6ba48493          	addi	s1,s1,1722 # 80010a50 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	67e70713          	addi	a4,a4,1662 # 80010a50 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	70f72423          	sw	a5,1800(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	64278793          	addi	a5,a5,1602 # 80010a50 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	6ac7ad23          	sw	a2,1722(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	6ae50513          	addi	a0,a0,1710 # 80010ae8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	cde080e7          	jalr	-802(ra) # 80002120 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	5f450513          	addi	a0,a0,1524 # 80010a50 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	77478793          	addi	a5,a5,1908 # 80020be8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5c07a423          	sw	zero,1480(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	34f72a23          	sw	a5,852(a4) # 800088d0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	558dad83          	lw	s11,1368(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	50250513          	addi	a0,a0,1282 # 80010af8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	3a450513          	addi	a0,a0,932 # 80010af8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	38848493          	addi	s1,s1,904 # 80010af8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	34850513          	addi	a0,a0,840 # 80010b18 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0d47a783          	lw	a5,212(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0a47b783          	ld	a5,164(a5) # 800088d8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	0a473703          	ld	a4,164(a4) # 800088e0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	2baa0a13          	addi	s4,s4,698 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	07248493          	addi	s1,s1,114 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	07298993          	addi	s3,s3,114 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	890080e7          	jalr	-1904(ra) # 80002120 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	24c50513          	addi	a0,a0,588 # 80010b18 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	ff47a783          	lw	a5,-12(a5) # 800088d0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	ffa73703          	ld	a4,-6(a4) # 800088e0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	fea7b783          	ld	a5,-22(a5) # 800088d8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	21e98993          	addi	s3,s3,542 # 80010b18 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	fd648493          	addi	s1,s1,-42 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	fd690913          	addi	s2,s2,-42 # 800088e0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7a2080e7          	jalr	1954(ra) # 800020bc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1e848493          	addi	s1,s1,488 # 80010b18 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f8e7be23          	sd	a4,-100(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	16248493          	addi	s1,s1,354 # 80010b18 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	38878793          	addi	a5,a5,904 # 80021d80 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	13890913          	addi	s2,s2,312 # 80010b50 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	09a50513          	addi	a0,a0,154 # 80010b50 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	2b650513          	addi	a0,a0,694 # 80021d80 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	06448493          	addi	s1,s1,100 # 80010b50 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	04c50513          	addi	a0,a0,76 # 80010b50 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	02050513          	addi	a0,a0,32 # 80010b50 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd281>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a6670713          	addi	a4,a4,-1434 # 800088e8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7fa080e7          	jalr	2042(ra) # 800026b2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e20080e7          	jalr	-480(ra) # 80005ce0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fdc080e7          	jalr	-36(ra) # 80001ea4 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	75a080e7          	jalr	1882(ra) # 8000268a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	77a080e7          	jalr	1914(ra) # 800026b2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d8a080e7          	jalr	-630(ra) # 80005cca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d98080e7          	jalr	-616(ra) # 80005ce0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f8e080e7          	jalr	-114(ra) # 80002ede <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	62c080e7          	jalr	1580(ra) # 80003584 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5a2080e7          	jalr	1442(ra) # 80004502 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e80080e7          	jalr	-384(ra) # 80005de8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d16080e7          	jalr	-746(ra) # 80001c86 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	96f72523          	sw	a5,-1686(a4) # 800088e8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	95e7b783          	ld	a5,-1698(a5) # 800088f0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd277>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	6aa7b123          	sd	a0,1698(a5) # 800088f0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd280>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	75a48493          	addi	s1,s1,1882 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	addi	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00015a17          	auipc	s4,0x15
    80001864:	140a0a13          	addi	s4,s4,320 # 800169a0 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	srai	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addiw	a1,a1,1
    80001884:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	16848493          	addi	s1,s1,360
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	addi	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	addi	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	28e50513          	addi	a0,a0,654 # 80010b70 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	28e50513          	addi	a0,a0,654 # 80010b88 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	69648493          	addi	s1,s1,1686 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	addi	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	addi	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00015997          	auipc	s3,0x15
    80001930:	07498993          	addi	s3,s3,116 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	srai	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addiw	a5,a5,1
    80001954:	00d7979b          	slliw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	16848493          	addi	s1,s1,360
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	addi	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	addi	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	addi	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	addi	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	20a50513          	addi	a0,a0,522 # 80010ba0 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	addi	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	addi	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	slli	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	1b270713          	addi	a4,a4,434 # 80010b70 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	addi	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	e7a7a783          	lw	a5,-390(a5) # 80008870 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	cca080e7          	jalr	-822(ra) # 800026ca <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	e607a023          	sw	zero,-416(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	aea080e7          	jalr	-1302(ra) # 80003504 <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	14090913          	addi	s2,s2,320 # 80010b70 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	e3278793          	addi	a5,a5,-462 # 80008874 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addiw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	addi	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	addi	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	slli	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	slli	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	addi	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	slli	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	addi	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->prio = 0;
    80001ba2:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001ba6:	0004ac23          	sw	zero,24(s1)
}
    80001baa:	60e2                	ld	ra,24(sp)
    80001bac:	6442                	ld	s0,16(sp)
    80001bae:	64a2                	ld	s1,8(sp)
    80001bb0:	6105                	addi	sp,sp,32
    80001bb2:	8082                	ret

0000000080001bb4 <allocproc>:
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	e04a                	sd	s2,0(sp)
    80001bbe:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc0:	0000f497          	auipc	s1,0xf
    80001bc4:	3e048493          	addi	s1,s1,992 # 80010fa0 <proc>
    80001bc8:	00015917          	auipc	s2,0x15
    80001bcc:	dd890913          	addi	s2,s2,-552 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	000080e7          	jalr	ra # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bda:	4c9c                	lw	a5,24(s1)
    80001bdc:	cf81                	beqz	a5,80001bf4 <allocproc+0x40>
      release(&p->lock);
    80001bde:	8526                	mv	a0,s1
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	0a6080e7          	jalr	166(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be8:	16848493          	addi	s1,s1,360
    80001bec:	ff2492e3          	bne	s1,s2,80001bd0 <allocproc+0x1c>
  return 0;
    80001bf0:	4481                	li	s1,0
    80001bf2:	a899                	j	80001c48 <allocproc+0x94>
  p->pid   = allocpid();
    80001bf4:	00000097          	auipc	ra,0x0
    80001bf8:	e30080e7          	jalr	-464(ra) # 80001a24 <allocpid>
    80001bfc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfe:	4785                	li	a5,1
    80001c00:	cc9c                	sw	a5,24(s1)
  p->prio  = 0x0C;
    80001c02:	47b1                	li	a5,12
    80001c04:	d8dc                	sw	a5,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	edc080e7          	jalr	-292(ra) # 80000ae2 <kalloc>
    80001c0e:	892a                	mv	s2,a0
    80001c10:	eca8                	sd	a0,88(s1)
    80001c12:	c131                	beqz	a0,80001c56 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c14:	8526                	mv	a0,s1
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	e54080e7          	jalr	-428(ra) # 80001a6a <proc_pagetable>
    80001c1e:	892a                	mv	s2,a0
    80001c20:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c22:	c531                	beqz	a0,80001c6e <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c24:	07000613          	li	a2,112
    80001c28:	4581                	li	a1,0
    80001c2a:	06048513          	addi	a0,s1,96
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	0a0080e7          	jalr	160(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c36:	00000797          	auipc	a5,0x0
    80001c3a:	da878793          	addi	a5,a5,-600 # 800019de <forkret>
    80001c3e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c40:	60bc                	ld	a5,64(s1)
    80001c42:	6705                	lui	a4,0x1
    80001c44:	97ba                	add	a5,a5,a4
    80001c46:	f4bc                	sd	a5,104(s1)
}
    80001c48:	8526                	mv	a0,s1
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6902                	ld	s2,0(sp)
    80001c52:	6105                	addi	sp,sp,32
    80001c54:	8082                	ret
    freeproc(p);
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	f00080e7          	jalr	-256(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c60:	8526                	mv	a0,s1
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	024080e7          	jalr	36(ra) # 80000c86 <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	bff1                	j	80001c48 <allocproc+0x94>
    freeproc(p);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	ee8080e7          	jalr	-280(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	00c080e7          	jalr	12(ra) # 80000c86 <release>
    return 0;
    80001c82:	84ca                	mv	s1,s2
    80001c84:	b7d1                	j	80001c48 <allocproc+0x94>

0000000080001c86 <userinit>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	f24080e7          	jalr	-220(ra) # 80001bb4 <allocproc>
    80001c98:	84aa                	mv	s1,a0
  initproc = p;
    80001c9a:	00007797          	auipc	a5,0x7
    80001c9e:	c4a7bf23          	sd	a0,-930(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca2:	03400613          	li	a2,52
    80001ca6:	00007597          	auipc	a1,0x7
    80001caa:	bda58593          	addi	a1,a1,-1062 # 80008880 <initcode>
    80001cae:	6928                	ld	a0,80(a0)
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	6a0080e7          	jalr	1696(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cb8:	6785                	lui	a5,0x1
    80001cba:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cbc:	6cb8                	ld	a4,88(s1)
    80001cbe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc2:	6cb8                	ld	a4,88(s1)
    80001cc4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc6:	4641                	li	a2,16
    80001cc8:	00006597          	auipc	a1,0x6
    80001ccc:	53858593          	addi	a1,a1,1336 # 80008200 <digits+0x1c0>
    80001cd0:	15848513          	addi	a0,s1,344
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	142080e7          	jalr	322(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cdc:	00006517          	auipc	a0,0x6
    80001ce0:	53450513          	addi	a0,a0,1332 # 80008210 <digits+0x1d0>
    80001ce4:	00002097          	auipc	ra,0x2
    80001ce8:	23e080e7          	jalr	574(ra) # 80003f22 <namei>
    80001cec:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	f90080e7          	jalr	-112(ra) # 80000c86 <release>
}
    80001cfe:	60e2                	ld	ra,24(sp)
    80001d00:	6442                	ld	s0,16(sp)
    80001d02:	64a2                	ld	s1,8(sp)
    80001d04:	6105                	addi	sp,sp,32
    80001d06:	8082                	ret

0000000080001d08 <growproc>:
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	e04a                	sd	s2,0(sp)
    80001d12:	1000                	addi	s0,sp,32
    80001d14:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	c90080e7          	jalr	-880(ra) # 800019a6 <myproc>
    80001d1e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d20:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d22:	01204c63          	bgtz	s2,80001d3a <growproc+0x32>
  } else if(n < 0){
    80001d26:	02094663          	bltz	s2,80001d52 <growproc+0x4a>
  p->sz = sz;
    80001d2a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2c:	4501                	li	a0,0
}
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d3a:	4691                	li	a3,4
    80001d3c:	00b90633          	add	a2,s2,a1
    80001d40:	6928                	ld	a0,80(a0)
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	6c8080e7          	jalr	1736(ra) # 8000140a <uvmalloc>
    80001d4a:	85aa                	mv	a1,a0
    80001d4c:	fd79                	bnez	a0,80001d2a <growproc+0x22>
      return -1;
    80001d4e:	557d                	li	a0,-1
    80001d50:	bff9                	j	80001d2e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d52:	00b90633          	add	a2,s2,a1
    80001d56:	6928                	ld	a0,80(a0)
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	66a080e7          	jalr	1642(ra) # 800013c2 <uvmdealloc>
    80001d60:	85aa                	mv	a1,a0
    80001d62:	b7e1                	j	80001d2a <growproc+0x22>

0000000080001d64 <fork>:
{
    80001d64:	7139                	addi	sp,sp,-64
    80001d66:	fc06                	sd	ra,56(sp)
    80001d68:	f822                	sd	s0,48(sp)
    80001d6a:	f426                	sd	s1,40(sp)
    80001d6c:	f04a                	sd	s2,32(sp)
    80001d6e:	ec4e                	sd	s3,24(sp)
    80001d70:	e852                	sd	s4,16(sp)
    80001d72:	e456                	sd	s5,8(sp)
    80001d74:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	c30080e7          	jalr	-976(ra) # 800019a6 <myproc>
    80001d7e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d80:	00000097          	auipc	ra,0x0
    80001d84:	e34080e7          	jalr	-460(ra) # 80001bb4 <allocproc>
    80001d88:	10050c63          	beqz	a0,80001ea0 <fork+0x13c>
    80001d8c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8e:	048ab603          	ld	a2,72(s5)
    80001d92:	692c                	ld	a1,80(a0)
    80001d94:	050ab503          	ld	a0,80(s5)
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	7ca080e7          	jalr	1994(ra) # 80001562 <uvmcopy>
    80001da0:	04054863          	bltz	a0,80001df0 <fork+0x8c>
  np->sz = p->sz;
    80001da4:	048ab783          	ld	a5,72(s5)
    80001da8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dac:	058ab683          	ld	a3,88(s5)
    80001db0:	87b6                	mv	a5,a3
    80001db2:	058a3703          	ld	a4,88(s4)
    80001db6:	12068693          	addi	a3,a3,288
    80001dba:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbe:	6788                	ld	a0,8(a5)
    80001dc0:	6b8c                	ld	a1,16(a5)
    80001dc2:	6f90                	ld	a2,24(a5)
    80001dc4:	01073023          	sd	a6,0(a4)
    80001dc8:	e708                	sd	a0,8(a4)
    80001dca:	eb0c                	sd	a1,16(a4)
    80001dcc:	ef10                	sd	a2,24(a4)
    80001dce:	02078793          	addi	a5,a5,32
    80001dd2:	02070713          	addi	a4,a4,32
    80001dd6:	fed792e3          	bne	a5,a3,80001dba <fork+0x56>
  np->trapframe->a0 = 0;
    80001dda:	058a3783          	ld	a5,88(s4)
    80001dde:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de2:	0d0a8493          	addi	s1,s5,208
    80001de6:	0d0a0913          	addi	s2,s4,208
    80001dea:	150a8993          	addi	s3,s5,336
    80001dee:	a00d                	j	80001e10 <fork+0xac>
    freeproc(np);
    80001df0:	8552                	mv	a0,s4
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	d66080e7          	jalr	-666(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001dfa:	8552                	mv	a0,s4
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	e8a080e7          	jalr	-374(ra) # 80000c86 <release>
    return -1;
    80001e04:	597d                	li	s2,-1
    80001e06:	a059                	j	80001e8c <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e08:	04a1                	addi	s1,s1,8
    80001e0a:	0921                	addi	s2,s2,8
    80001e0c:	01348b63          	beq	s1,s3,80001e22 <fork+0xbe>
    if(p->ofile[i])
    80001e10:	6088                	ld	a0,0(s1)
    80001e12:	d97d                	beqz	a0,80001e08 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e14:	00002097          	auipc	ra,0x2
    80001e18:	780080e7          	jalr	1920(ra) # 80004594 <filedup>
    80001e1c:	00a93023          	sd	a0,0(s2)
    80001e20:	b7e5                	j	80001e08 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e22:	150ab503          	ld	a0,336(s5)
    80001e26:	00002097          	auipc	ra,0x2
    80001e2a:	918080e7          	jalr	-1768(ra) # 8000373e <idup>
    80001e2e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e32:	4641                	li	a2,16
    80001e34:	158a8593          	addi	a1,s5,344
    80001e38:	158a0513          	addi	a0,s4,344
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	fda080e7          	jalr	-38(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e44:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e48:	8552                	mv	a0,s4
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	e3c080e7          	jalr	-452(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e52:	0000f497          	auipc	s1,0xf
    80001e56:	d3648493          	addi	s1,s1,-714 # 80010b88 <wait_lock>
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	d76080e7          	jalr	-650(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e64:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	e1c080e7          	jalr	-484(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e72:	8552                	mv	a0,s4
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d5e080e7          	jalr	-674(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e7c:	478d                	li	a5,3
    80001e7e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e82:	8552                	mv	a0,s4
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	e02080e7          	jalr	-510(ra) # 80000c86 <release>
}
    80001e8c:	854a                	mv	a0,s2
    80001e8e:	70e2                	ld	ra,56(sp)
    80001e90:	7442                	ld	s0,48(sp)
    80001e92:	74a2                	ld	s1,40(sp)
    80001e94:	7902                	ld	s2,32(sp)
    80001e96:	69e2                	ld	s3,24(sp)
    80001e98:	6a42                	ld	s4,16(sp)
    80001e9a:	6aa2                	ld	s5,8(sp)
    80001e9c:	6121                	addi	sp,sp,64
    80001e9e:	8082                	ret
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	b7ed                	j	80001e8c <fork+0x128>

0000000080001ea4 <scheduler>:
{
    80001ea4:	715d                	addi	sp,sp,-80
    80001ea6:	e486                	sd	ra,72(sp)
    80001ea8:	e0a2                	sd	s0,64(sp)
    80001eaa:	fc26                	sd	s1,56(sp)
    80001eac:	f84a                	sd	s2,48(sp)
    80001eae:	f44e                	sd	s3,40(sp)
    80001eb0:	f052                	sd	s4,32(sp)
    80001eb2:	ec56                	sd	s5,24(sp)
    80001eb4:	e85a                	sd	s6,16(sp)
    80001eb6:	e45e                	sd	s7,8(sp)
    80001eb8:	e062                	sd	s8,0(sp)
    80001eba:	0880                	addi	s0,sp,80
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ebc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001ec0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ec2:	10079073          	csrw	sstatus,a5
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ec6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec8:	2781                	sext.w	a5,a5
  c->proc = 0; // kick the process out
    80001eca:	00779b93          	slli	s7,a5,0x7
    80001ece:	0000f717          	auipc	a4,0xf
    80001ed2:	ca270713          	addi	a4,a4,-862 # 80010b70 <pid_lock>
    80001ed6:	975e                	add	a4,a4,s7
    80001ed8:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80001edc:	0000f717          	auipc	a4,0xf
    80001ee0:	ccc70713          	addi	a4,a4,-820 # 80010ba8 <cpus+0x8>
    80001ee4:	9bba                	add	s7,s7,a4
      if(n->state != RUNNABLE){
    80001ee6:	498d                	li	s3,3
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001ee8:	00015a17          	auipc	s4,0x15
    80001eec:	ab8a0a13          	addi	s4,s4,-1352 # 800169a0 <tickslock>
      c->proc = p;
    80001ef0:	079e                	slli	a5,a5,0x7
    80001ef2:	0000fb17          	auipc	s6,0xf
    80001ef6:	c7eb0b13          	addi	s6,s6,-898 # 80010b70 <pid_lock>
    80001efa:	9b3e                	add	s6,s6,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001efc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f04:	10079073          	csrw	sstatus,a5
    for(n = proc; n < &proc[NPROC]; n++){
    80001f08:	0000fa97          	auipc	s5,0xf
    80001f0c:	098a8a93          	addi	s5,s5,152 # 80010fa0 <proc>
      p->state = RUNNING;
    80001f10:	4c11                	li	s8,4
    80001f12:	a8ad                	j	80001f8c <scheduler+0xe8>
    80001f14:	8956                	mv	s2,s5
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001f16:	0000f497          	auipc	s1,0xf
    80001f1a:	08a48493          	addi	s1,s1,138 # 80010fa0 <proc>
    80001f1e:	a821                	j	80001f36 <scheduler+0x92>
          release(&n1->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d64080e7          	jalr	-668(ra) # 80000c86 <release>
          continue;
    80001f2a:	a011                	j	80001f2e <scheduler+0x8a>
    80001f2c:	8926                	mv	s2,s1
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001f2e:	16848493          	addi	s1,s1,360
    80001f32:	03448763          	beq	s1,s4,80001f60 <scheduler+0xbc>
        if(p == n1) continue;
    80001f36:	fe990be3          	beq	s2,s1,80001f2c <scheduler+0x88>
        acquire(&n1->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	c96080e7          	jalr	-874(ra) # 80000bd2 <acquire>
        if(n1->state != RUNNABLE){
    80001f44:	4c9c                	lw	a5,24(s1)
    80001f46:	fd379de3          	bne	a5,s3,80001f20 <scheduler+0x7c>
        if(n1->state < p->state){
    80001f4a:	01892783          	lw	a5,24(s2)
    80001f4e:	fef9f0e3          	bgeu	s3,a5,80001f2e <scheduler+0x8a>
          release(&p->lock);
    80001f52:	854a                	mv	a0,s2
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	d32080e7          	jalr	-718(ra) # 80000c86 <release>
    80001f5c:	8926                	mv	s2,s1
    80001f5e:	bfc1                	j	80001f2e <scheduler+0x8a>
      c->proc = p;
    80001f60:	032b3823          	sd	s2,48(s6)
      p->state = RUNNING;
    80001f64:	01892c23          	sw	s8,24(s2)
      swtch(&c->context, &p->context);
    80001f68:	06090593          	addi	a1,s2,96
    80001f6c:	855e                	mv	a0,s7
    80001f6e:	00000097          	auipc	ra,0x0
    80001f72:	6b2080e7          	jalr	1714(ra) # 80002620 <swtch>
      c->proc = 0;
    80001f76:	020b3823          	sd	zero,48(s6)
      release(&p->lock);
    80001f7a:	854a                	mv	a0,s2
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d0a080e7          	jalr	-758(ra) # 80000c86 <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001f84:	168a8a93          	addi	s5,s5,360
    80001f88:	f74a8ae3          	beq	s5,s4,80001efc <scheduler+0x58>
      acquire(&n->lock);
    80001f8c:	8556                	mv	a0,s5
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	c44080e7          	jalr	-956(ra) # 80000bd2 <acquire>
      if(n->state != RUNNABLE){
    80001f96:	018aa783          	lw	a5,24(s5)
    80001f9a:	f7378de3          	beq	a5,s3,80001f14 <scheduler+0x70>
        release(&n->lock);
    80001f9e:	8556                	mv	a0,s5
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	ce6080e7          	jalr	-794(ra) # 80000c86 <release>
        continue;
    80001fa8:	bff1                	j	80001f84 <scheduler+0xe0>

0000000080001faa <sched>:
{
    80001faa:	7179                	addi	sp,sp,-48
    80001fac:	f406                	sd	ra,40(sp)
    80001fae:	f022                	sd	s0,32(sp)
    80001fb0:	ec26                	sd	s1,24(sp)
    80001fb2:	e84a                	sd	s2,16(sp)
    80001fb4:	e44e                	sd	s3,8(sp)
    80001fb6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	9ee080e7          	jalr	-1554(ra) # 800019a6 <myproc>
    80001fc0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fc2:	fffff097          	auipc	ra,0xfffff
    80001fc6:	b96080e7          	jalr	-1130(ra) # 80000b58 <holding>
    80001fca:	c93d                	beqz	a0,80002040 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fcc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fce:	2781                	sext.w	a5,a5
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	0000f717          	auipc	a4,0xf
    80001fd6:	b9e70713          	addi	a4,a4,-1122 # 80010b70 <pid_lock>
    80001fda:	97ba                	add	a5,a5,a4
    80001fdc:	0a87a703          	lw	a4,168(a5)
    80001fe0:	4785                	li	a5,1
    80001fe2:	06f71763          	bne	a4,a5,80002050 <sched+0xa6>
  if(p->state == RUNNING)
    80001fe6:	4c98                	lw	a4,24(s1)
    80001fe8:	4791                	li	a5,4
    80001fea:	06f70b63          	beq	a4,a5,80002060 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ff4:	efb5                	bnez	a5,80002070 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ff8:	0000f917          	auipc	s2,0xf
    80001ffc:	b7890913          	addi	s2,s2,-1160 # 80010b70 <pid_lock>
    80002000:	2781                	sext.w	a5,a5
    80002002:	079e                	slli	a5,a5,0x7
    80002004:	97ca                	add	a5,a5,s2
    80002006:	0ac7a983          	lw	s3,172(a5)
    8000200a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	0000f597          	auipc	a1,0xf
    80002014:	b9858593          	addi	a1,a1,-1128 # 80010ba8 <cpus+0x8>
    80002018:	95be                	add	a1,a1,a5
    8000201a:	06048513          	addi	a0,s1,96
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	602080e7          	jalr	1538(ra) # 80002620 <swtch>
    80002026:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002028:	2781                	sext.w	a5,a5
    8000202a:	079e                	slli	a5,a5,0x7
    8000202c:	993e                	add	s2,s2,a5
    8000202e:	0b392623          	sw	s3,172(s2)
}
    80002032:	70a2                	ld	ra,40(sp)
    80002034:	7402                	ld	s0,32(sp)
    80002036:	64e2                	ld	s1,24(sp)
    80002038:	6942                	ld	s2,16(sp)
    8000203a:	69a2                	ld	s3,8(sp)
    8000203c:	6145                	addi	sp,sp,48
    8000203e:	8082                	ret
    panic("sched p->lock");
    80002040:	00006517          	auipc	a0,0x6
    80002044:	1d850513          	addi	a0,a0,472 # 80008218 <digits+0x1d8>
    80002048:	ffffe097          	auipc	ra,0xffffe
    8000204c:	4f4080e7          	jalr	1268(ra) # 8000053c <panic>
    panic("sched locks");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	1d850513          	addi	a0,a0,472 # 80008228 <digits+0x1e8>
    80002058:	ffffe097          	auipc	ra,0xffffe
    8000205c:	4e4080e7          	jalr	1252(ra) # 8000053c <panic>
    panic("sched running");
    80002060:	00006517          	auipc	a0,0x6
    80002064:	1d850513          	addi	a0,a0,472 # 80008238 <digits+0x1f8>
    80002068:	ffffe097          	auipc	ra,0xffffe
    8000206c:	4d4080e7          	jalr	1236(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002070:	00006517          	auipc	a0,0x6
    80002074:	1d850513          	addi	a0,a0,472 # 80008248 <digits+0x208>
    80002078:	ffffe097          	auipc	ra,0xffffe
    8000207c:	4c4080e7          	jalr	1220(ra) # 8000053c <panic>

0000000080002080 <yield>:
{
    80002080:	1101                	addi	sp,sp,-32
    80002082:	ec06                	sd	ra,24(sp)
    80002084:	e822                	sd	s0,16(sp)
    80002086:	e426                	sd	s1,8(sp)
    80002088:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	91c080e7          	jalr	-1764(ra) # 800019a6 <myproc>
    80002092:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	b3e080e7          	jalr	-1218(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000209c:	478d                	li	a5,3
    8000209e:	cc9c                	sw	a5,24(s1)
  sched();
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	f0a080e7          	jalr	-246(ra) # 80001faa <sched>
  release(&p->lock);
    800020a8:	8526                	mv	a0,s1
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	bdc080e7          	jalr	-1060(ra) # 80000c86 <release>
}
    800020b2:	60e2                	ld	ra,24(sp)
    800020b4:	6442                	ld	s0,16(sp)
    800020b6:	64a2                	ld	s1,8(sp)
    800020b8:	6105                	addi	sp,sp,32
    800020ba:	8082                	ret

00000000800020bc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020bc:	7179                	addi	sp,sp,-48
    800020be:	f406                	sd	ra,40(sp)
    800020c0:	f022                	sd	s0,32(sp)
    800020c2:	ec26                	sd	s1,24(sp)
    800020c4:	e84a                	sd	s2,16(sp)
    800020c6:	e44e                	sd	s3,8(sp)
    800020c8:	1800                	addi	s0,sp,48
    800020ca:	89aa                	mv	s3,a0
    800020cc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ce:	00000097          	auipc	ra,0x0
    800020d2:	8d8080e7          	jalr	-1832(ra) # 800019a6 <myproc>
    800020d6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020d8:	fffff097          	auipc	ra,0xfffff
    800020dc:	afa080e7          	jalr	-1286(ra) # 80000bd2 <acquire>
  release(lk);
    800020e0:	854a                	mv	a0,s2
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	ba4080e7          	jalr	-1116(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800020ea:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020ee:	4789                	li	a5,2
    800020f0:	cc9c                	sw	a5,24(s1)

  sched();
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	eb8080e7          	jalr	-328(ra) # 80001faa <sched>

  // Tidy up.
  p->chan = 0;
    800020fa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b86080e7          	jalr	-1146(ra) # 80000c86 <release>
  acquire(lk);
    80002108:	854a                	mv	a0,s2
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	ac8080e7          	jalr	-1336(ra) # 80000bd2 <acquire>
}
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6942                	ld	s2,16(sp)
    8000211a:	69a2                	ld	s3,8(sp)
    8000211c:	6145                	addi	sp,sp,48
    8000211e:	8082                	ret

0000000080002120 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002120:	7139                	addi	sp,sp,-64
    80002122:	fc06                	sd	ra,56(sp)
    80002124:	f822                	sd	s0,48(sp)
    80002126:	f426                	sd	s1,40(sp)
    80002128:	f04a                	sd	s2,32(sp)
    8000212a:	ec4e                	sd	s3,24(sp)
    8000212c:	e852                	sd	s4,16(sp)
    8000212e:	e456                	sd	s5,8(sp)
    80002130:	0080                	addi	s0,sp,64
    80002132:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002134:	0000f497          	auipc	s1,0xf
    80002138:	e6c48493          	addi	s1,s1,-404 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000213c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000213e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002140:	00015917          	auipc	s2,0x15
    80002144:	86090913          	addi	s2,s2,-1952 # 800169a0 <tickslock>
    80002148:	a811                	j	8000215c <wakeup+0x3c>
      }
      release(&p->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	b3a080e7          	jalr	-1222(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002154:	16848493          	addi	s1,s1,360
    80002158:	03248663          	beq	s1,s2,80002184 <wakeup+0x64>
    if(p != myproc()){
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	84a080e7          	jalr	-1974(ra) # 800019a6 <myproc>
    80002164:	fea488e3          	beq	s1,a0,80002154 <wakeup+0x34>
      acquire(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	a68080e7          	jalr	-1432(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002172:	4c9c                	lw	a5,24(s1)
    80002174:	fd379be3          	bne	a5,s3,8000214a <wakeup+0x2a>
    80002178:	709c                	ld	a5,32(s1)
    8000217a:	fd4798e3          	bne	a5,s4,8000214a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000217e:	0154ac23          	sw	s5,24(s1)
    80002182:	b7e1                	j	8000214a <wakeup+0x2a>
    }
  }
}
    80002184:	70e2                	ld	ra,56(sp)
    80002186:	7442                	ld	s0,48(sp)
    80002188:	74a2                	ld	s1,40(sp)
    8000218a:	7902                	ld	s2,32(sp)
    8000218c:	69e2                	ld	s3,24(sp)
    8000218e:	6a42                	ld	s4,16(sp)
    80002190:	6aa2                	ld	s5,8(sp)
    80002192:	6121                	addi	sp,sp,64
    80002194:	8082                	ret

0000000080002196 <reparent>:
{
    80002196:	7179                	addi	sp,sp,-48
    80002198:	f406                	sd	ra,40(sp)
    8000219a:	f022                	sd	s0,32(sp)
    8000219c:	ec26                	sd	s1,24(sp)
    8000219e:	e84a                	sd	s2,16(sp)
    800021a0:	e44e                	sd	s3,8(sp)
    800021a2:	e052                	sd	s4,0(sp)
    800021a4:	1800                	addi	s0,sp,48
    800021a6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a8:	0000f497          	auipc	s1,0xf
    800021ac:	df848493          	addi	s1,s1,-520 # 80010fa0 <proc>
      pp->parent = initproc;
    800021b0:	00006a17          	auipc	s4,0x6
    800021b4:	748a0a13          	addi	s4,s4,1864 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	00014997          	auipc	s3,0x14
    800021bc:	7e898993          	addi	s3,s3,2024 # 800169a0 <tickslock>
    800021c0:	a029                	j	800021ca <reparent+0x34>
    800021c2:	16848493          	addi	s1,s1,360
    800021c6:	01348d63          	beq	s1,s3,800021e0 <reparent+0x4a>
    if(pp->parent == p){
    800021ca:	7c9c                	ld	a5,56(s1)
    800021cc:	ff279be3          	bne	a5,s2,800021c2 <reparent+0x2c>
      pp->parent = initproc;
    800021d0:	000a3503          	ld	a0,0(s4)
    800021d4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	f4a080e7          	jalr	-182(ra) # 80002120 <wakeup>
    800021de:	b7d5                	j	800021c2 <reparent+0x2c>
}
    800021e0:	70a2                	ld	ra,40(sp)
    800021e2:	7402                	ld	s0,32(sp)
    800021e4:	64e2                	ld	s1,24(sp)
    800021e6:	6942                	ld	s2,16(sp)
    800021e8:	69a2                	ld	s3,8(sp)
    800021ea:	6a02                	ld	s4,0(sp)
    800021ec:	6145                	addi	sp,sp,48
    800021ee:	8082                	ret

00000000800021f0 <exit>:
{
    800021f0:	7179                	addi	sp,sp,-48
    800021f2:	f406                	sd	ra,40(sp)
    800021f4:	f022                	sd	s0,32(sp)
    800021f6:	ec26                	sd	s1,24(sp)
    800021f8:	e84a                	sd	s2,16(sp)
    800021fa:	e44e                	sd	s3,8(sp)
    800021fc:	e052                	sd	s4,0(sp)
    800021fe:	1800                	addi	s0,sp,48
    80002200:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	7a4080e7          	jalr	1956(ra) # 800019a6 <myproc>
    8000220a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000220c:	00006797          	auipc	a5,0x6
    80002210:	6ec7b783          	ld	a5,1772(a5) # 800088f8 <initproc>
    80002214:	0d050493          	addi	s1,a0,208
    80002218:	15050913          	addi	s2,a0,336
    8000221c:	02a79363          	bne	a5,a0,80002242 <exit+0x52>
    panic("init exiting");
    80002220:	00006517          	auipc	a0,0x6
    80002224:	04050513          	addi	a0,a0,64 # 80008260 <digits+0x220>
    80002228:	ffffe097          	auipc	ra,0xffffe
    8000222c:	314080e7          	jalr	788(ra) # 8000053c <panic>
      fileclose(f);
    80002230:	00002097          	auipc	ra,0x2
    80002234:	3b6080e7          	jalr	950(ra) # 800045e6 <fileclose>
      p->ofile[fd] = 0;
    80002238:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000223c:	04a1                	addi	s1,s1,8
    8000223e:	01248563          	beq	s1,s2,80002248 <exit+0x58>
    if(p->ofile[fd]){
    80002242:	6088                	ld	a0,0(s1)
    80002244:	f575                	bnez	a0,80002230 <exit+0x40>
    80002246:	bfdd                	j	8000223c <exit+0x4c>
  begin_op();
    80002248:	00002097          	auipc	ra,0x2
    8000224c:	eda080e7          	jalr	-294(ra) # 80004122 <begin_op>
  iput(p->cwd);
    80002250:	1509b503          	ld	a0,336(s3)
    80002254:	00001097          	auipc	ra,0x1
    80002258:	6e2080e7          	jalr	1762(ra) # 80003936 <iput>
  end_op();
    8000225c:	00002097          	auipc	ra,0x2
    80002260:	f40080e7          	jalr	-192(ra) # 8000419c <end_op>
  p->cwd = 0;
    80002264:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002268:	0000f497          	auipc	s1,0xf
    8000226c:	92048493          	addi	s1,s1,-1760 # 80010b88 <wait_lock>
    80002270:	8526                	mv	a0,s1
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	960080e7          	jalr	-1696(ra) # 80000bd2 <acquire>
  reparent(p);
    8000227a:	854e                	mv	a0,s3
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	f1a080e7          	jalr	-230(ra) # 80002196 <reparent>
  wakeup(p->parent);
    80002284:	0389b503          	ld	a0,56(s3)
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	e98080e7          	jalr	-360(ra) # 80002120 <wakeup>
  acquire(&p->lock);
    80002290:	854e                	mv	a0,s3
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	940080e7          	jalr	-1728(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000229a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000229e:	4795                	li	a5,5
    800022a0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	9e0080e7          	jalr	-1568(ra) # 80000c86 <release>
  sched();
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	cfc080e7          	jalr	-772(ra) # 80001faa <sched>
  panic("zombie exit");
    800022b6:	00006517          	auipc	a0,0x6
    800022ba:	fba50513          	addi	a0,a0,-70 # 80008270 <digits+0x230>
    800022be:	ffffe097          	auipc	ra,0xffffe
    800022c2:	27e080e7          	jalr	638(ra) # 8000053c <panic>

00000000800022c6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022c6:	7179                	addi	sp,sp,-48
    800022c8:	f406                	sd	ra,40(sp)
    800022ca:	f022                	sd	s0,32(sp)
    800022cc:	ec26                	sd	s1,24(sp)
    800022ce:	e84a                	sd	s2,16(sp)
    800022d0:	e44e                	sd	s3,8(sp)
    800022d2:	1800                	addi	s0,sp,48
    800022d4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022d6:	0000f497          	auipc	s1,0xf
    800022da:	cca48493          	addi	s1,s1,-822 # 80010fa0 <proc>
    800022de:	00014997          	auipc	s3,0x14
    800022e2:	6c298993          	addi	s3,s3,1730 # 800169a0 <tickslock>
    acquire(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	8ea080e7          	jalr	-1814(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800022f0:	589c                	lw	a5,48(s1)
    800022f2:	01278d63          	beq	a5,s2,8000230c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022f6:	8526                	mv	a0,s1
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	98e080e7          	jalr	-1650(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002300:	16848493          	addi	s1,s1,360
    80002304:	ff3491e3          	bne	s1,s3,800022e6 <kill+0x20>
  }
  return -1;
    80002308:	557d                	li	a0,-1
    8000230a:	a829                	j	80002324 <kill+0x5e>
      p->killed = 1;
    8000230c:	4785                	li	a5,1
    8000230e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002310:	4c98                	lw	a4,24(s1)
    80002312:	4789                	li	a5,2
    80002314:	00f70f63          	beq	a4,a5,80002332 <kill+0x6c>
      release(&p->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	96c080e7          	jalr	-1684(ra) # 80000c86 <release>
      return 0;
    80002322:	4501                	li	a0,0
}
    80002324:	70a2                	ld	ra,40(sp)
    80002326:	7402                	ld	s0,32(sp)
    80002328:	64e2                	ld	s1,24(sp)
    8000232a:	6942                	ld	s2,16(sp)
    8000232c:	69a2                	ld	s3,8(sp)
    8000232e:	6145                	addi	sp,sp,48
    80002330:	8082                	ret
        p->state = RUNNABLE;
    80002332:	478d                	li	a5,3
    80002334:	cc9c                	sw	a5,24(s1)
    80002336:	b7cd                	j	80002318 <kill+0x52>

0000000080002338 <setkilled>:

void
setkilled(struct proc *p)
{
    80002338:	1101                	addi	sp,sp,-32
    8000233a:	ec06                	sd	ra,24(sp)
    8000233c:	e822                	sd	s0,16(sp)
    8000233e:	e426                	sd	s1,8(sp)
    80002340:	1000                	addi	s0,sp,32
    80002342:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	88e080e7          	jalr	-1906(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000234c:	4785                	li	a5,1
    8000234e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	934080e7          	jalr	-1740(ra) # 80000c86 <release>
}
    8000235a:	60e2                	ld	ra,24(sp)
    8000235c:	6442                	ld	s0,16(sp)
    8000235e:	64a2                	ld	s1,8(sp)
    80002360:	6105                	addi	sp,sp,32
    80002362:	8082                	ret

0000000080002364 <killed>:

int
killed(struct proc *p)
{
    80002364:	1101                	addi	sp,sp,-32
    80002366:	ec06                	sd	ra,24(sp)
    80002368:	e822                	sd	s0,16(sp)
    8000236a:	e426                	sd	s1,8(sp)
    8000236c:	e04a                	sd	s2,0(sp)
    8000236e:	1000                	addi	s0,sp,32
    80002370:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	860080e7          	jalr	-1952(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000237a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	906080e7          	jalr	-1786(ra) # 80000c86 <release>
  return k;
}
    80002388:	854a                	mv	a0,s2
    8000238a:	60e2                	ld	ra,24(sp)
    8000238c:	6442                	ld	s0,16(sp)
    8000238e:	64a2                	ld	s1,8(sp)
    80002390:	6902                	ld	s2,0(sp)
    80002392:	6105                	addi	sp,sp,32
    80002394:	8082                	ret

0000000080002396 <wait>:
{
    80002396:	715d                	addi	sp,sp,-80
    80002398:	e486                	sd	ra,72(sp)
    8000239a:	e0a2                	sd	s0,64(sp)
    8000239c:	fc26                	sd	s1,56(sp)
    8000239e:	f84a                	sd	s2,48(sp)
    800023a0:	f44e                	sd	s3,40(sp)
    800023a2:	f052                	sd	s4,32(sp)
    800023a4:	ec56                	sd	s5,24(sp)
    800023a6:	e85a                	sd	s6,16(sp)
    800023a8:	e45e                	sd	s7,8(sp)
    800023aa:	e062                	sd	s8,0(sp)
    800023ac:	0880                	addi	s0,sp,80
    800023ae:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	5f6080e7          	jalr	1526(ra) # 800019a6 <myproc>
    800023b8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023ba:	0000e517          	auipc	a0,0xe
    800023be:	7ce50513          	addi	a0,a0,1998 # 80010b88 <wait_lock>
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	810080e7          	jalr	-2032(ra) # 80000bd2 <acquire>
    havekids = 0;
    800023ca:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023cc:	4a15                	li	s4,5
        havekids = 1;
    800023ce:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d0:	00014997          	auipc	s3,0x14
    800023d4:	5d098993          	addi	s3,s3,1488 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023d8:	0000ec17          	auipc	s8,0xe
    800023dc:	7b0c0c13          	addi	s8,s8,1968 # 80010b88 <wait_lock>
    800023e0:	a0d1                	j	800024a4 <wait+0x10e>
          pid = pp->pid;
    800023e2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023e6:	000b0e63          	beqz	s6,80002402 <wait+0x6c>
    800023ea:	4691                	li	a3,4
    800023ec:	02c48613          	addi	a2,s1,44
    800023f0:	85da                	mv	a1,s6
    800023f2:	05093503          	ld	a0,80(s2)
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	270080e7          	jalr	624(ra) # 80001666 <copyout>
    800023fe:	04054163          	bltz	a0,80002440 <wait+0xaa>
          freeproc(pp);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	754080e7          	jalr	1876(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    8000240c:	8526                	mv	a0,s1
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	878080e7          	jalr	-1928(ra) # 80000c86 <release>
          release(&wait_lock);
    80002416:	0000e517          	auipc	a0,0xe
    8000241a:	77250513          	addi	a0,a0,1906 # 80010b88 <wait_lock>
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	868080e7          	jalr	-1944(ra) # 80000c86 <release>
}
    80002426:	854e                	mv	a0,s3
    80002428:	60a6                	ld	ra,72(sp)
    8000242a:	6406                	ld	s0,64(sp)
    8000242c:	74e2                	ld	s1,56(sp)
    8000242e:	7942                	ld	s2,48(sp)
    80002430:	79a2                	ld	s3,40(sp)
    80002432:	7a02                	ld	s4,32(sp)
    80002434:	6ae2                	ld	s5,24(sp)
    80002436:	6b42                	ld	s6,16(sp)
    80002438:	6ba2                	ld	s7,8(sp)
    8000243a:	6c02                	ld	s8,0(sp)
    8000243c:	6161                	addi	sp,sp,80
    8000243e:	8082                	ret
            release(&pp->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	844080e7          	jalr	-1980(ra) # 80000c86 <release>
            release(&wait_lock);
    8000244a:	0000e517          	auipc	a0,0xe
    8000244e:	73e50513          	addi	a0,a0,1854 # 80010b88 <wait_lock>
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	834080e7          	jalr	-1996(ra) # 80000c86 <release>
            return -1;
    8000245a:	59fd                	li	s3,-1
    8000245c:	b7e9                	j	80002426 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000245e:	16848493          	addi	s1,s1,360
    80002462:	03348463          	beq	s1,s3,8000248a <wait+0xf4>
      if(pp->parent == p){
    80002466:	7c9c                	ld	a5,56(s1)
    80002468:	ff279be3          	bne	a5,s2,8000245e <wait+0xc8>
        acquire(&pp->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	764080e7          	jalr	1892(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002476:	4c9c                	lw	a5,24(s1)
    80002478:	f74785e3          	beq	a5,s4,800023e2 <wait+0x4c>
        release(&pp->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	808080e7          	jalr	-2040(ra) # 80000c86 <release>
        havekids = 1;
    80002486:	8756                	mv	a4,s5
    80002488:	bfd9                	j	8000245e <wait+0xc8>
    if(!havekids || killed(p)){
    8000248a:	c31d                	beqz	a4,800024b0 <wait+0x11a>
    8000248c:	854a                	mv	a0,s2
    8000248e:	00000097          	auipc	ra,0x0
    80002492:	ed6080e7          	jalr	-298(ra) # 80002364 <killed>
    80002496:	ed09                	bnez	a0,800024b0 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002498:	85e2                	mv	a1,s8
    8000249a:	854a                	mv	a0,s2
    8000249c:	00000097          	auipc	ra,0x0
    800024a0:	c20080e7          	jalr	-992(ra) # 800020bc <sleep>
    havekids = 0;
    800024a4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a6:	0000f497          	auipc	s1,0xf
    800024aa:	afa48493          	addi	s1,s1,-1286 # 80010fa0 <proc>
    800024ae:	bf65                	j	80002466 <wait+0xd0>
      release(&wait_lock);
    800024b0:	0000e517          	auipc	a0,0xe
    800024b4:	6d850513          	addi	a0,a0,1752 # 80010b88 <wait_lock>
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7ce080e7          	jalr	1998(ra) # 80000c86 <release>
      return -1;
    800024c0:	59fd                	li	s3,-1
    800024c2:	b795                	j	80002426 <wait+0x90>

00000000800024c4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	84aa                	mv	s1,a0
    800024d6:	892e                	mv	s2,a1
    800024d8:	89b2                	mv	s3,a2
    800024da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	4ca080e7          	jalr	1226(ra) # 800019a6 <myproc>
  if(user_dst){
    800024e4:	c08d                	beqz	s1,80002506 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e6:	86d2                	mv	a3,s4
    800024e8:	864e                	mv	a2,s3
    800024ea:	85ca                	mv	a1,s2
    800024ec:	6928                	ld	a0,80(a0)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	178080e7          	jalr	376(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    memmove((char *)dst, src, len);
    80002506:	000a061b          	sext.w	a2,s4
    8000250a:	85ce                	mv	a1,s3
    8000250c:	854a                	mv	a0,s2
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	81c080e7          	jalr	-2020(ra) # 80000d2a <memmove>
    return 0;
    80002516:	8526                	mv	a0,s1
    80002518:	bff9                	j	800024f6 <either_copyout+0x32>

000000008000251a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000251a:	7179                	addi	sp,sp,-48
    8000251c:	f406                	sd	ra,40(sp)
    8000251e:	f022                	sd	s0,32(sp)
    80002520:	ec26                	sd	s1,24(sp)
    80002522:	e84a                	sd	s2,16(sp)
    80002524:	e44e                	sd	s3,8(sp)
    80002526:	e052                	sd	s4,0(sp)
    80002528:	1800                	addi	s0,sp,48
    8000252a:	892a                	mv	s2,a0
    8000252c:	84ae                	mv	s1,a1
    8000252e:	89b2                	mv	s3,a2
    80002530:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	474080e7          	jalr	1140(ra) # 800019a6 <myproc>
  if(user_src){
    8000253a:	c08d                	beqz	s1,8000255c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000253c:	86d2                	mv	a3,s4
    8000253e:	864e                	mv	a2,s3
    80002540:	85ca                	mv	a1,s2
    80002542:	6928                	ld	a0,80(a0)
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	1ae080e7          	jalr	430(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000255c:	000a061b          	sext.w	a2,s4
    80002560:	85ce                	mv	a1,s3
    80002562:	854a                	mv	a0,s2
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	7c6080e7          	jalr	1990(ra) # 80000d2a <memmove>
    return 0;
    8000256c:	8526                	mv	a0,s1
    8000256e:	bff9                	j	8000254c <either_copyin+0x32>

0000000080002570 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002570:	715d                	addi	sp,sp,-80
    80002572:	e486                	sd	ra,72(sp)
    80002574:	e0a2                	sd	s0,64(sp)
    80002576:	fc26                	sd	s1,56(sp)
    80002578:	f84a                	sd	s2,48(sp)
    8000257a:	f44e                	sd	s3,40(sp)
    8000257c:	f052                	sd	s4,32(sp)
    8000257e:	ec56                	sd	s5,24(sp)
    80002580:	e85a                	sd	s6,16(sp)
    80002582:	e45e                	sd	s7,8(sp)
    80002584:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002586:	00006517          	auipc	a0,0x6
    8000258a:	b4250513          	addi	a0,a0,-1214 # 800080c8 <digits+0x88>
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	ff8080e7          	jalr	-8(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002596:	0000f497          	auipc	s1,0xf
    8000259a:	b6248493          	addi	s1,s1,-1182 # 800110f8 <proc+0x158>
    8000259e:	00014917          	auipc	s2,0x14
    800025a2:	55a90913          	addi	s2,s2,1370 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025a8:	00006997          	auipc	s3,0x6
    800025ac:	cd898993          	addi	s3,s3,-808 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025b0:	00006a97          	auipc	s5,0x6
    800025b4:	cd8a8a93          	addi	s5,s5,-808 # 80008288 <digits+0x248>
    printf("\n");
    800025b8:	00006a17          	auipc	s4,0x6
    800025bc:	b10a0a13          	addi	s4,s4,-1264 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c0:	00006b97          	auipc	s7,0x6
    800025c4:	d08b8b93          	addi	s7,s7,-760 # 800082c8 <states.0>
    800025c8:	a00d                	j	800025ea <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025ca:	ed86a583          	lw	a1,-296(a3)
    800025ce:	8556                	mv	a0,s5
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	fb6080e7          	jalr	-74(ra) # 80000586 <printf>
    printf("\n");
    800025d8:	8552                	mv	a0,s4
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	fac080e7          	jalr	-84(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e2:	16848493          	addi	s1,s1,360
    800025e6:	03248263          	beq	s1,s2,8000260a <procdump+0x9a>
    if(p->state == UNUSED)
    800025ea:	86a6                	mv	a3,s1
    800025ec:	ec04a783          	lw	a5,-320(s1)
    800025f0:	dbed                	beqz	a5,800025e2 <procdump+0x72>
      state = "???";
    800025f2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f4:	fcfb6be3          	bltu	s6,a5,800025ca <procdump+0x5a>
    800025f8:	02079713          	slli	a4,a5,0x20
    800025fc:	01d75793          	srli	a5,a4,0x1d
    80002600:	97de                	add	a5,a5,s7
    80002602:	6390                	ld	a2,0(a5)
    80002604:	f279                	bnez	a2,800025ca <procdump+0x5a>
      state = "???";
    80002606:	864e                	mv	a2,s3
    80002608:	b7c9                	j	800025ca <procdump+0x5a>
  }
}
    8000260a:	60a6                	ld	ra,72(sp)
    8000260c:	6406                	ld	s0,64(sp)
    8000260e:	74e2                	ld	s1,56(sp)
    80002610:	7942                	ld	s2,48(sp)
    80002612:	79a2                	ld	s3,40(sp)
    80002614:	7a02                	ld	s4,32(sp)
    80002616:	6ae2                	ld	s5,24(sp)
    80002618:	6b42                	ld	s6,16(sp)
    8000261a:	6ba2                	ld	s7,8(sp)
    8000261c:	6161                	addi	sp,sp,80
    8000261e:	8082                	ret

0000000080002620 <swtch>:
    80002620:	00153023          	sd	ra,0(a0)
    80002624:	00253423          	sd	sp,8(a0)
    80002628:	e900                	sd	s0,16(a0)
    8000262a:	ed04                	sd	s1,24(a0)
    8000262c:	03253023          	sd	s2,32(a0)
    80002630:	03353423          	sd	s3,40(a0)
    80002634:	03453823          	sd	s4,48(a0)
    80002638:	03553c23          	sd	s5,56(a0)
    8000263c:	05653023          	sd	s6,64(a0)
    80002640:	05753423          	sd	s7,72(a0)
    80002644:	05853823          	sd	s8,80(a0)
    80002648:	05953c23          	sd	s9,88(a0)
    8000264c:	07a53023          	sd	s10,96(a0)
    80002650:	07b53423          	sd	s11,104(a0)
    80002654:	0005b083          	ld	ra,0(a1)
    80002658:	0085b103          	ld	sp,8(a1)
    8000265c:	6980                	ld	s0,16(a1)
    8000265e:	6d84                	ld	s1,24(a1)
    80002660:	0205b903          	ld	s2,32(a1)
    80002664:	0285b983          	ld	s3,40(a1)
    80002668:	0305ba03          	ld	s4,48(a1)
    8000266c:	0385ba83          	ld	s5,56(a1)
    80002670:	0405bb03          	ld	s6,64(a1)
    80002674:	0485bb83          	ld	s7,72(a1)
    80002678:	0505bc03          	ld	s8,80(a1)
    8000267c:	0585bc83          	ld	s9,88(a1)
    80002680:	0605bd03          	ld	s10,96(a1)
    80002684:	0685bd83          	ld	s11,104(a1)
    80002688:	8082                	ret

000000008000268a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000268a:	1141                	addi	sp,sp,-16
    8000268c:	e406                	sd	ra,8(sp)
    8000268e:	e022                	sd	s0,0(sp)
    80002690:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002692:	00006597          	auipc	a1,0x6
    80002696:	c6658593          	addi	a1,a1,-922 # 800082f8 <states.0+0x30>
    8000269a:	00014517          	auipc	a0,0x14
    8000269e:	30650513          	addi	a0,a0,774 # 800169a0 <tickslock>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	4a0080e7          	jalr	1184(ra) # 80000b42 <initlock>
}
    800026aa:	60a2                	ld	ra,8(sp)
    800026ac:	6402                	ld	s0,0(sp)
    800026ae:	0141                	addi	sp,sp,16
    800026b0:	8082                	ret

00000000800026b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026b2:	1141                	addi	sp,sp,-16
    800026b4:	e422                	sd	s0,8(sp)
    800026b6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b8:	00003797          	auipc	a5,0x3
    800026bc:	55878793          	addi	a5,a5,1368 # 80005c10 <kernelvec>
    800026c0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026c4:	6422                	ld	s0,8(sp)
    800026c6:	0141                	addi	sp,sp,16
    800026c8:	8082                	ret

00000000800026ca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ca:	1141                	addi	sp,sp,-16
    800026cc:	e406                	sd	ra,8(sp)
    800026ce:	e022                	sd	s0,0(sp)
    800026d0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	2d4080e7          	jalr	724(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026de:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026e4:	00005697          	auipc	a3,0x5
    800026e8:	91c68693          	addi	a3,a3,-1764 # 80007000 <_trampoline>
    800026ec:	00005717          	auipc	a4,0x5
    800026f0:	91470713          	addi	a4,a4,-1772 # 80007000 <_trampoline>
    800026f4:	8f15                	sub	a4,a4,a3
    800026f6:	040007b7          	lui	a5,0x4000
    800026fa:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026fc:	07b2                	slli	a5,a5,0xc
    800026fe:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002700:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002704:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002706:	18002673          	csrr	a2,satp
    8000270a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000270c:	6d30                	ld	a2,88(a0)
    8000270e:	6138                	ld	a4,64(a0)
    80002710:	6585                	lui	a1,0x1
    80002712:	972e                	add	a4,a4,a1
    80002714:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002716:	6d38                	ld	a4,88(a0)
    80002718:	00000617          	auipc	a2,0x0
    8000271c:	13460613          	addi	a2,a2,308 # 8000284c <usertrap>
    80002720:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002722:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002724:	8612                	mv	a2,tp
    80002726:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000272c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002730:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002734:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002738:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000273a:	6f18                	ld	a4,24(a4)
    8000273c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002740:	6928                	ld	a0,80(a0)
    80002742:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002744:	00005717          	auipc	a4,0x5
    80002748:	95870713          	addi	a4,a4,-1704 # 8000709c <userret>
    8000274c:	8f15                	sub	a4,a4,a3
    8000274e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002750:	577d                	li	a4,-1
    80002752:	177e                	slli	a4,a4,0x3f
    80002754:	8d59                	or	a0,a0,a4
    80002756:	9782                	jalr	a5
}
    80002758:	60a2                	ld	ra,8(sp)
    8000275a:	6402                	ld	s0,0(sp)
    8000275c:	0141                	addi	sp,sp,16
    8000275e:	8082                	ret

0000000080002760 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	e426                	sd	s1,8(sp)
    80002768:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000276a:	00014497          	auipc	s1,0x14
    8000276e:	23648493          	addi	s1,s1,566 # 800169a0 <tickslock>
    80002772:	8526                	mv	a0,s1
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	45e080e7          	jalr	1118(ra) # 80000bd2 <acquire>
  ticks++;
    8000277c:	00006517          	auipc	a0,0x6
    80002780:	18450513          	addi	a0,a0,388 # 80008900 <ticks>
    80002784:	411c                	lw	a5,0(a0)
    80002786:	2785                	addiw	a5,a5,1
    80002788:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000278a:	00000097          	auipc	ra,0x0
    8000278e:	996080e7          	jalr	-1642(ra) # 80002120 <wakeup>
  release(&tickslock);
    80002792:	8526                	mv	a0,s1
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	4f2080e7          	jalr	1266(ra) # 80000c86 <release>
}
    8000279c:	60e2                	ld	ra,24(sp)
    8000279e:	6442                	ld	s0,16(sp)
    800027a0:	64a2                	ld	s1,8(sp)
    800027a2:	6105                	addi	sp,sp,32
    800027a4:	8082                	ret

00000000800027a6 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027a6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027aa:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027ac:	0807df63          	bgez	a5,8000284a <devintr+0xa4>
{
    800027b0:	1101                	addi	sp,sp,-32
    800027b2:	ec06                	sd	ra,24(sp)
    800027b4:	e822                	sd	s0,16(sp)
    800027b6:	e426                	sd	s1,8(sp)
    800027b8:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027ba:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027be:	46a5                	li	a3,9
    800027c0:	00d70d63          	beq	a4,a3,800027da <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800027c4:	577d                	li	a4,-1
    800027c6:	177e                	slli	a4,a4,0x3f
    800027c8:	0705                	addi	a4,a4,1
    return 0;
    800027ca:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027cc:	04e78e63          	beq	a5,a4,80002828 <devintr+0x82>
  }
}
    800027d0:	60e2                	ld	ra,24(sp)
    800027d2:	6442                	ld	s0,16(sp)
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	6105                	addi	sp,sp,32
    800027d8:	8082                	ret
    int irq = plic_claim();
    800027da:	00003097          	auipc	ra,0x3
    800027de:	53e080e7          	jalr	1342(ra) # 80005d18 <plic_claim>
    800027e2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027e4:	47a9                	li	a5,10
    800027e6:	02f50763          	beq	a0,a5,80002814 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800027ea:	4785                	li	a5,1
    800027ec:	02f50963          	beq	a0,a5,8000281e <devintr+0x78>
    return 1;
    800027f0:	4505                	li	a0,1
    } else if(irq){
    800027f2:	dcf9                	beqz	s1,800027d0 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027f4:	85a6                	mv	a1,s1
    800027f6:	00006517          	auipc	a0,0x6
    800027fa:	b0a50513          	addi	a0,a0,-1270 # 80008300 <states.0+0x38>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	d88080e7          	jalr	-632(ra) # 80000586 <printf>
      plic_complete(irq);
    80002806:	8526                	mv	a0,s1
    80002808:	00003097          	auipc	ra,0x3
    8000280c:	534080e7          	jalr	1332(ra) # 80005d3c <plic_complete>
    return 1;
    80002810:	4505                	li	a0,1
    80002812:	bf7d                	j	800027d0 <devintr+0x2a>
      uartintr();
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	180080e7          	jalr	384(ra) # 80000994 <uartintr>
    if(irq)
    8000281c:	b7ed                	j	80002806 <devintr+0x60>
      virtio_disk_intr();
    8000281e:	00004097          	auipc	ra,0x4
    80002822:	9e4080e7          	jalr	-1564(ra) # 80006202 <virtio_disk_intr>
    if(irq)
    80002826:	b7c5                	j	80002806 <devintr+0x60>
    if(cpuid() == 0){
    80002828:	fffff097          	auipc	ra,0xfffff
    8000282c:	152080e7          	jalr	338(ra) # 8000197a <cpuid>
    80002830:	c901                	beqz	a0,80002840 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002832:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002836:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002838:	14479073          	csrw	sip,a5
    return 2;
    8000283c:	4509                	li	a0,2
    8000283e:	bf49                	j	800027d0 <devintr+0x2a>
      clockintr();
    80002840:	00000097          	auipc	ra,0x0
    80002844:	f20080e7          	jalr	-224(ra) # 80002760 <clockintr>
    80002848:	b7ed                	j	80002832 <devintr+0x8c>
}
    8000284a:	8082                	ret

000000008000284c <usertrap>:
{
    8000284c:	1101                	addi	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	e04a                	sd	s2,0(sp)
    80002856:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002858:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000285c:	1007f793          	andi	a5,a5,256
    80002860:	e3b1                	bnez	a5,800028a4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002862:	00003797          	auipc	a5,0x3
    80002866:	3ae78793          	addi	a5,a5,942 # 80005c10 <kernelvec>
    8000286a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000286e:	fffff097          	auipc	ra,0xfffff
    80002872:	138080e7          	jalr	312(ra) # 800019a6 <myproc>
    80002876:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002878:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287a:	14102773          	csrr	a4,sepc
    8000287e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002880:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002884:	47a1                	li	a5,8
    80002886:	02f70763          	beq	a4,a5,800028b4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	f1c080e7          	jalr	-228(ra) # 800027a6 <devintr>
    80002892:	892a                	mv	s2,a0
    80002894:	c151                	beqz	a0,80002918 <usertrap+0xcc>
  if(killed(p))
    80002896:	8526                	mv	a0,s1
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	acc080e7          	jalr	-1332(ra) # 80002364 <killed>
    800028a0:	c929                	beqz	a0,800028f2 <usertrap+0xa6>
    800028a2:	a099                	j	800028e8 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028a4:	00006517          	auipc	a0,0x6
    800028a8:	a7c50513          	addi	a0,a0,-1412 # 80008320 <states.0+0x58>
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	c90080e7          	jalr	-880(ra) # 8000053c <panic>
    if(killed(p))
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	ab0080e7          	jalr	-1360(ra) # 80002364 <killed>
    800028bc:	e921                	bnez	a0,8000290c <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028be:	6cb8                	ld	a4,88(s1)
    800028c0:	6f1c                	ld	a5,24(a4)
    800028c2:	0791                	addi	a5,a5,4
    800028c4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028ca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ce:	10079073          	csrw	sstatus,a5
    syscall();
    800028d2:	00000097          	auipc	ra,0x0
    800028d6:	2d4080e7          	jalr	724(ra) # 80002ba6 <syscall>
  if(killed(p))
    800028da:	8526                	mv	a0,s1
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	a88080e7          	jalr	-1400(ra) # 80002364 <killed>
    800028e4:	c911                	beqz	a0,800028f8 <usertrap+0xac>
    800028e6:	4901                	li	s2,0
    exit(-1);
    800028e8:	557d                	li	a0,-1
    800028ea:	00000097          	auipc	ra,0x0
    800028ee:	906080e7          	jalr	-1786(ra) # 800021f0 <exit>
  if(which_dev == 2)
    800028f2:	4789                	li	a5,2
    800028f4:	04f90f63          	beq	s2,a5,80002952 <usertrap+0x106>
  usertrapret();
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	dd2080e7          	jalr	-558(ra) # 800026ca <usertrapret>
}
    80002900:	60e2                	ld	ra,24(sp)
    80002902:	6442                	ld	s0,16(sp)
    80002904:	64a2                	ld	s1,8(sp)
    80002906:	6902                	ld	s2,0(sp)
    80002908:	6105                	addi	sp,sp,32
    8000290a:	8082                	ret
      exit(-1);
    8000290c:	557d                	li	a0,-1
    8000290e:	00000097          	auipc	ra,0x0
    80002912:	8e2080e7          	jalr	-1822(ra) # 800021f0 <exit>
    80002916:	b765                	j	800028be <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002918:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000291c:	5890                	lw	a2,48(s1)
    8000291e:	00006517          	auipc	a0,0x6
    80002922:	a2250513          	addi	a0,a0,-1502 # 80008340 <states.0+0x78>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c60080e7          	jalr	-928(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000292e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002932:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002936:	00006517          	auipc	a0,0x6
    8000293a:	a3a50513          	addi	a0,a0,-1478 # 80008370 <states.0+0xa8>
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	c48080e7          	jalr	-952(ra) # 80000586 <printf>
    setkilled(p);
    80002946:	8526                	mv	a0,s1
    80002948:	00000097          	auipc	ra,0x0
    8000294c:	9f0080e7          	jalr	-1552(ra) # 80002338 <setkilled>
    80002950:	b769                	j	800028da <usertrap+0x8e>
    yield();
    80002952:	fffff097          	auipc	ra,0xfffff
    80002956:	72e080e7          	jalr	1838(ra) # 80002080 <yield>
    8000295a:	bf79                	j	800028f8 <usertrap+0xac>

000000008000295c <kerneltrap>:
{
    8000295c:	7179                	addi	sp,sp,-48
    8000295e:	f406                	sd	ra,40(sp)
    80002960:	f022                	sd	s0,32(sp)
    80002962:	ec26                	sd	s1,24(sp)
    80002964:	e84a                	sd	s2,16(sp)
    80002966:	e44e                	sd	s3,8(sp)
    80002968:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002972:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002976:	1004f793          	andi	a5,s1,256
    8000297a:	cb85                	beqz	a5,800029aa <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002980:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002982:	ef85                	bnez	a5,800029ba <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002984:	00000097          	auipc	ra,0x0
    80002988:	e22080e7          	jalr	-478(ra) # 800027a6 <devintr>
    8000298c:	cd1d                	beqz	a0,800029ca <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000298e:	4789                	li	a5,2
    80002990:	06f50a63          	beq	a0,a5,80002a04 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002994:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002998:	10049073          	csrw	sstatus,s1
}
    8000299c:	70a2                	ld	ra,40(sp)
    8000299e:	7402                	ld	s0,32(sp)
    800029a0:	64e2                	ld	s1,24(sp)
    800029a2:	6942                	ld	s2,16(sp)
    800029a4:	69a2                	ld	s3,8(sp)
    800029a6:	6145                	addi	sp,sp,48
    800029a8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	9e650513          	addi	a0,a0,-1562 # 80008390 <states.0+0xc8>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	b8a080e7          	jalr	-1142(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	9fe50513          	addi	a0,a0,-1538 # 800083b8 <states.0+0xf0>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	b7a080e7          	jalr	-1158(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800029ca:	85ce                	mv	a1,s3
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	a0c50513          	addi	a0,a0,-1524 # 800083d8 <states.0+0x110>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	bb2080e7          	jalr	-1102(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029dc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e4:	00006517          	auipc	a0,0x6
    800029e8:	a0450513          	addi	a0,a0,-1532 # 800083e8 <states.0+0x120>
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	b9a080e7          	jalr	-1126(ra) # 80000586 <printf>
    panic("kerneltrap");
    800029f4:	00006517          	auipc	a0,0x6
    800029f8:	a0c50513          	addi	a0,a0,-1524 # 80008400 <states.0+0x138>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	b40080e7          	jalr	-1216(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	fa2080e7          	jalr	-94(ra) # 800019a6 <myproc>
    80002a0c:	d541                	beqz	a0,80002994 <kerneltrap+0x38>
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	f98080e7          	jalr	-104(ra) # 800019a6 <myproc>
    80002a16:	4d18                	lw	a4,24(a0)
    80002a18:	4791                	li	a5,4
    80002a1a:	f6f71de3          	bne	a4,a5,80002994 <kerneltrap+0x38>
    yield();
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	662080e7          	jalr	1634(ra) # 80002080 <yield>
    80002a26:	b7bd                	j	80002994 <kerneltrap+0x38>

0000000080002a28 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a28:	1101                	addi	sp,sp,-32
    80002a2a:	ec06                	sd	ra,24(sp)
    80002a2c:	e822                	sd	s0,16(sp)
    80002a2e:	e426                	sd	s1,8(sp)
    80002a30:	1000                	addi	s0,sp,32
    80002a32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	f72080e7          	jalr	-142(ra) # 800019a6 <myproc>
  switch (n) {
    80002a3c:	4795                	li	a5,5
    80002a3e:	0497e163          	bltu	a5,s1,80002a80 <argraw+0x58>
    80002a42:	048a                	slli	s1,s1,0x2
    80002a44:	00006717          	auipc	a4,0x6
    80002a48:	9f470713          	addi	a4,a4,-1548 # 80008438 <states.0+0x170>
    80002a4c:	94ba                	add	s1,s1,a4
    80002a4e:	409c                	lw	a5,0(s1)
    80002a50:	97ba                	add	a5,a5,a4
    80002a52:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a58:	60e2                	ld	ra,24(sp)
    80002a5a:	6442                	ld	s0,16(sp)
    80002a5c:	64a2                	ld	s1,8(sp)
    80002a5e:	6105                	addi	sp,sp,32
    80002a60:	8082                	ret
    return p->trapframe->a1;
    80002a62:	6d3c                	ld	a5,88(a0)
    80002a64:	7fa8                	ld	a0,120(a5)
    80002a66:	bfcd                	j	80002a58 <argraw+0x30>
    return p->trapframe->a2;
    80002a68:	6d3c                	ld	a5,88(a0)
    80002a6a:	63c8                	ld	a0,128(a5)
    80002a6c:	b7f5                	j	80002a58 <argraw+0x30>
    return p->trapframe->a3;
    80002a6e:	6d3c                	ld	a5,88(a0)
    80002a70:	67c8                	ld	a0,136(a5)
    80002a72:	b7dd                	j	80002a58 <argraw+0x30>
    return p->trapframe->a4;
    80002a74:	6d3c                	ld	a5,88(a0)
    80002a76:	6bc8                	ld	a0,144(a5)
    80002a78:	b7c5                	j	80002a58 <argraw+0x30>
    return p->trapframe->a5;
    80002a7a:	6d3c                	ld	a5,88(a0)
    80002a7c:	6fc8                	ld	a0,152(a5)
    80002a7e:	bfe9                	j	80002a58 <argraw+0x30>
  panic("argraw");
    80002a80:	00006517          	auipc	a0,0x6
    80002a84:	99050513          	addi	a0,a0,-1648 # 80008410 <states.0+0x148>
    80002a88:	ffffe097          	auipc	ra,0xffffe
    80002a8c:	ab4080e7          	jalr	-1356(ra) # 8000053c <panic>

0000000080002a90 <fetchaddr>:
{
    80002a90:	1101                	addi	sp,sp,-32
    80002a92:	ec06                	sd	ra,24(sp)
    80002a94:	e822                	sd	s0,16(sp)
    80002a96:	e426                	sd	s1,8(sp)
    80002a98:	e04a                	sd	s2,0(sp)
    80002a9a:	1000                	addi	s0,sp,32
    80002a9c:	84aa                	mv	s1,a0
    80002a9e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	f06080e7          	jalr	-250(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002aa8:	653c                	ld	a5,72(a0)
    80002aaa:	02f4f863          	bgeu	s1,a5,80002ada <fetchaddr+0x4a>
    80002aae:	00848713          	addi	a4,s1,8
    80002ab2:	02e7e663          	bltu	a5,a4,80002ade <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ab6:	46a1                	li	a3,8
    80002ab8:	8626                	mv	a2,s1
    80002aba:	85ca                	mv	a1,s2
    80002abc:	6928                	ld	a0,80(a0)
    80002abe:	fffff097          	auipc	ra,0xfffff
    80002ac2:	c34080e7          	jalr	-972(ra) # 800016f2 <copyin>
    80002ac6:	00a03533          	snez	a0,a0
    80002aca:	40a00533          	neg	a0,a0
}
    80002ace:	60e2                	ld	ra,24(sp)
    80002ad0:	6442                	ld	s0,16(sp)
    80002ad2:	64a2                	ld	s1,8(sp)
    80002ad4:	6902                	ld	s2,0(sp)
    80002ad6:	6105                	addi	sp,sp,32
    80002ad8:	8082                	ret
    return -1;
    80002ada:	557d                	li	a0,-1
    80002adc:	bfcd                	j	80002ace <fetchaddr+0x3e>
    80002ade:	557d                	li	a0,-1
    80002ae0:	b7fd                	j	80002ace <fetchaddr+0x3e>

0000000080002ae2 <fetchstr>:
{
    80002ae2:	7179                	addi	sp,sp,-48
    80002ae4:	f406                	sd	ra,40(sp)
    80002ae6:	f022                	sd	s0,32(sp)
    80002ae8:	ec26                	sd	s1,24(sp)
    80002aea:	e84a                	sd	s2,16(sp)
    80002aec:	e44e                	sd	s3,8(sp)
    80002aee:	1800                	addi	s0,sp,48
    80002af0:	892a                	mv	s2,a0
    80002af2:	84ae                	mv	s1,a1
    80002af4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	eb0080e7          	jalr	-336(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002afe:	86ce                	mv	a3,s3
    80002b00:	864a                	mv	a2,s2
    80002b02:	85a6                	mv	a1,s1
    80002b04:	6928                	ld	a0,80(a0)
    80002b06:	fffff097          	auipc	ra,0xfffff
    80002b0a:	c7a080e7          	jalr	-902(ra) # 80001780 <copyinstr>
    80002b0e:	00054e63          	bltz	a0,80002b2a <fetchstr+0x48>
  return strlen(buf);
    80002b12:	8526                	mv	a0,s1
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	334080e7          	jalr	820(ra) # 80000e48 <strlen>
}
    80002b1c:	70a2                	ld	ra,40(sp)
    80002b1e:	7402                	ld	s0,32(sp)
    80002b20:	64e2                	ld	s1,24(sp)
    80002b22:	6942                	ld	s2,16(sp)
    80002b24:	69a2                	ld	s3,8(sp)
    80002b26:	6145                	addi	sp,sp,48
    80002b28:	8082                	ret
    return -1;
    80002b2a:	557d                	li	a0,-1
    80002b2c:	bfc5                	j	80002b1c <fetchstr+0x3a>

0000000080002b2e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b2e:	1101                	addi	sp,sp,-32
    80002b30:	ec06                	sd	ra,24(sp)
    80002b32:	e822                	sd	s0,16(sp)
    80002b34:	e426                	sd	s1,8(sp)
    80002b36:	1000                	addi	s0,sp,32
    80002b38:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b3a:	00000097          	auipc	ra,0x0
    80002b3e:	eee080e7          	jalr	-274(ra) # 80002a28 <argraw>
    80002b42:	c088                	sw	a0,0(s1)
}
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret

0000000080002b4e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b4e:	1101                	addi	sp,sp,-32
    80002b50:	ec06                	sd	ra,24(sp)
    80002b52:	e822                	sd	s0,16(sp)
    80002b54:	e426                	sd	s1,8(sp)
    80002b56:	1000                	addi	s0,sp,32
    80002b58:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	ece080e7          	jalr	-306(ra) # 80002a28 <argraw>
    80002b62:	e088                	sd	a0,0(s1)
}
    80002b64:	60e2                	ld	ra,24(sp)
    80002b66:	6442                	ld	s0,16(sp)
    80002b68:	64a2                	ld	s1,8(sp)
    80002b6a:	6105                	addi	sp,sp,32
    80002b6c:	8082                	ret

0000000080002b6e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b6e:	7179                	addi	sp,sp,-48
    80002b70:	f406                	sd	ra,40(sp)
    80002b72:	f022                	sd	s0,32(sp)
    80002b74:	ec26                	sd	s1,24(sp)
    80002b76:	e84a                	sd	s2,16(sp)
    80002b78:	1800                	addi	s0,sp,48
    80002b7a:	84ae                	mv	s1,a1
    80002b7c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b7e:	fd840593          	addi	a1,s0,-40
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	fcc080e7          	jalr	-52(ra) # 80002b4e <argaddr>
  return fetchstr(addr, buf, max);
    80002b8a:	864a                	mv	a2,s2
    80002b8c:	85a6                	mv	a1,s1
    80002b8e:	fd843503          	ld	a0,-40(s0)
    80002b92:	00000097          	auipc	ra,0x0
    80002b96:	f50080e7          	jalr	-176(ra) # 80002ae2 <fetchstr>
}
    80002b9a:	70a2                	ld	ra,40(sp)
    80002b9c:	7402                	ld	s0,32(sp)
    80002b9e:	64e2                	ld	s1,24(sp)
    80002ba0:	6942                	ld	s2,16(sp)
    80002ba2:	6145                	addi	sp,sp,48
    80002ba4:	8082                	ret

0000000080002ba6 <syscall>:
[SYS_setpri]  sys_setpri,
};

void
syscall(void)
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	e426                	sd	s1,8(sp)
    80002bae:	e04a                	sd	s2,0(sp)
    80002bb0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	df4080e7          	jalr	-524(ra) # 800019a6 <myproc>
    80002bba:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bbc:	05853903          	ld	s2,88(a0)
    80002bc0:	0a893783          	ld	a5,168(s2)
    80002bc4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bc8:	37fd                	addiw	a5,a5,-1
    80002bca:	4769                	li	a4,26
    80002bcc:	00f76f63          	bltu	a4,a5,80002bea <syscall+0x44>
    80002bd0:	00369713          	slli	a4,a3,0x3
    80002bd4:	00006797          	auipc	a5,0x6
    80002bd8:	87c78793          	addi	a5,a5,-1924 # 80008450 <syscalls>
    80002bdc:	97ba                	add	a5,a5,a4
    80002bde:	639c                	ld	a5,0(a5)
    80002be0:	c789                	beqz	a5,80002bea <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002be2:	9782                	jalr	a5
    80002be4:	06a93823          	sd	a0,112(s2)
    80002be8:	a839                	j	80002c06 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bea:	15848613          	addi	a2,s1,344
    80002bee:	588c                	lw	a1,48(s1)
    80002bf0:	00006517          	auipc	a0,0x6
    80002bf4:	82850513          	addi	a0,a0,-2008 # 80008418 <states.0+0x150>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	98e080e7          	jalr	-1650(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c00:	6cbc                	ld	a5,88(s1)
    80002c02:	577d                	li	a4,-1
    80002c04:	fbb8                	sd	a4,112(a5)
  }
}
    80002c06:	60e2                	ld	ra,24(sp)
    80002c08:	6442                	ld	s0,16(sp)
    80002c0a:	64a2                	ld	s1,8(sp)
    80002c0c:	6902                	ld	s2,0(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret

0000000080002c12 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c1a:	fec40593          	addi	a1,s0,-20
    80002c1e:	4501                	li	a0,0
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	f0e080e7          	jalr	-242(ra) # 80002b2e <argint>
  exit(n);
    80002c28:	fec42503          	lw	a0,-20(s0)
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	5c4080e7          	jalr	1476(ra) # 800021f0 <exit>
  return 0;  // not reached
}
    80002c34:	4501                	li	a0,0
    80002c36:	60e2                	ld	ra,24(sp)
    80002c38:	6442                	ld	s0,16(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c3e:	1141                	addi	sp,sp,-16
    80002c40:	e406                	sd	ra,8(sp)
    80002c42:	e022                	sd	s0,0(sp)
    80002c44:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	d60080e7          	jalr	-672(ra) # 800019a6 <myproc>
}
    80002c4e:	5908                	lw	a0,48(a0)
    80002c50:	60a2                	ld	ra,8(sp)
    80002c52:	6402                	ld	s0,0(sp)
    80002c54:	0141                	addi	sp,sp,16
    80002c56:	8082                	ret

0000000080002c58 <sys_fork>:

uint64
sys_fork(void)
{
    80002c58:	1141                	addi	sp,sp,-16
    80002c5a:	e406                	sd	ra,8(sp)
    80002c5c:	e022                	sd	s0,0(sp)
    80002c5e:	0800                	addi	s0,sp,16
  return fork();
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	104080e7          	jalr	260(ra) # 80001d64 <fork>
}
    80002c68:	60a2                	ld	ra,8(sp)
    80002c6a:	6402                	ld	s0,0(sp)
    80002c6c:	0141                	addi	sp,sp,16
    80002c6e:	8082                	ret

0000000080002c70 <sys_wait>:

uint64
sys_wait(void)
{
    80002c70:	1101                	addi	sp,sp,-32
    80002c72:	ec06                	sd	ra,24(sp)
    80002c74:	e822                	sd	s0,16(sp)
    80002c76:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c78:	fe840593          	addi	a1,s0,-24
    80002c7c:	4501                	li	a0,0
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	ed0080e7          	jalr	-304(ra) # 80002b4e <argaddr>
  return wait(p);
    80002c86:	fe843503          	ld	a0,-24(s0)
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	70c080e7          	jalr	1804(ra) # 80002396 <wait>
}
    80002c92:	60e2                	ld	ra,24(sp)
    80002c94:	6442                	ld	s0,16(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret

0000000080002c9a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c9a:	7179                	addi	sp,sp,-48
    80002c9c:	f406                	sd	ra,40(sp)
    80002c9e:	f022                	sd	s0,32(sp)
    80002ca0:	ec26                	sd	s1,24(sp)
    80002ca2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ca4:	fdc40593          	addi	a1,s0,-36
    80002ca8:	4501                	li	a0,0
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	e84080e7          	jalr	-380(ra) # 80002b2e <argint>
  addr = myproc()->sz;
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	cf4080e7          	jalr	-780(ra) # 800019a6 <myproc>
    80002cba:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cbc:	fdc42503          	lw	a0,-36(s0)
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	048080e7          	jalr	72(ra) # 80001d08 <growproc>
    80002cc8:	00054863          	bltz	a0,80002cd8 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ccc:	8526                	mv	a0,s1
    80002cce:	70a2                	ld	ra,40(sp)
    80002cd0:	7402                	ld	s0,32(sp)
    80002cd2:	64e2                	ld	s1,24(sp)
    80002cd4:	6145                	addi	sp,sp,48
    80002cd6:	8082                	ret
    return -1;
    80002cd8:	54fd                	li	s1,-1
    80002cda:	bfcd                	j	80002ccc <sys_sbrk+0x32>

0000000080002cdc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cdc:	7139                	addi	sp,sp,-64
    80002cde:	fc06                	sd	ra,56(sp)
    80002ce0:	f822                	sd	s0,48(sp)
    80002ce2:	f426                	sd	s1,40(sp)
    80002ce4:	f04a                	sd	s2,32(sp)
    80002ce6:	ec4e                	sd	s3,24(sp)
    80002ce8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cea:	fcc40593          	addi	a1,s0,-52
    80002cee:	4501                	li	a0,0
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	e3e080e7          	jalr	-450(ra) # 80002b2e <argint>
  acquire(&tickslock);
    80002cf8:	00014517          	auipc	a0,0x14
    80002cfc:	ca850513          	addi	a0,a0,-856 # 800169a0 <tickslock>
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	ed2080e7          	jalr	-302(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002d08:	00006917          	auipc	s2,0x6
    80002d0c:	bf892903          	lw	s2,-1032(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002d10:	fcc42783          	lw	a5,-52(s0)
    80002d14:	cf9d                	beqz	a5,80002d52 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d16:	00014997          	auipc	s3,0x14
    80002d1a:	c8a98993          	addi	s3,s3,-886 # 800169a0 <tickslock>
    80002d1e:	00006497          	auipc	s1,0x6
    80002d22:	be248493          	addi	s1,s1,-1054 # 80008900 <ticks>
    if(killed(myproc())){
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	c80080e7          	jalr	-896(ra) # 800019a6 <myproc>
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	636080e7          	jalr	1590(ra) # 80002364 <killed>
    80002d36:	ed15                	bnez	a0,80002d72 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d38:	85ce                	mv	a1,s3
    80002d3a:	8526                	mv	a0,s1
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	380080e7          	jalr	896(ra) # 800020bc <sleep>
  while(ticks - ticks0 < n){
    80002d44:	409c                	lw	a5,0(s1)
    80002d46:	412787bb          	subw	a5,a5,s2
    80002d4a:	fcc42703          	lw	a4,-52(s0)
    80002d4e:	fce7ece3          	bltu	a5,a4,80002d26 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d52:	00014517          	auipc	a0,0x14
    80002d56:	c4e50513          	addi	a0,a0,-946 # 800169a0 <tickslock>
    80002d5a:	ffffe097          	auipc	ra,0xffffe
    80002d5e:	f2c080e7          	jalr	-212(ra) # 80000c86 <release>
  return 0;
    80002d62:	4501                	li	a0,0
}
    80002d64:	70e2                	ld	ra,56(sp)
    80002d66:	7442                	ld	s0,48(sp)
    80002d68:	74a2                	ld	s1,40(sp)
    80002d6a:	7902                	ld	s2,32(sp)
    80002d6c:	69e2                	ld	s3,24(sp)
    80002d6e:	6121                	addi	sp,sp,64
    80002d70:	8082                	ret
      release(&tickslock);
    80002d72:	00014517          	auipc	a0,0x14
    80002d76:	c2e50513          	addi	a0,a0,-978 # 800169a0 <tickslock>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	f0c080e7          	jalr	-244(ra) # 80000c86 <release>
      return -1;
    80002d82:	557d                	li	a0,-1
    80002d84:	b7c5                	j	80002d64 <sys_sleep+0x88>

0000000080002d86 <sys_kill>:

uint64
sys_kill(void)
{
    80002d86:	1101                	addi	sp,sp,-32
    80002d88:	ec06                	sd	ra,24(sp)
    80002d8a:	e822                	sd	s0,16(sp)
    80002d8c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d8e:	fec40593          	addi	a1,s0,-20
    80002d92:	4501                	li	a0,0
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	d9a080e7          	jalr	-614(ra) # 80002b2e <argint>
  return kill(pid);
    80002d9c:	fec42503          	lw	a0,-20(s0)
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	526080e7          	jalr	1318(ra) # 800022c6 <kill>
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dba:	00014517          	auipc	a0,0x14
    80002dbe:	be650513          	addi	a0,a0,-1050 # 800169a0 <tickslock>
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	e10080e7          	jalr	-496(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002dca:	00006497          	auipc	s1,0x6
    80002dce:	b364a483          	lw	s1,-1226(s1) # 80008900 <ticks>
  release(&tickslock);
    80002dd2:	00014517          	auipc	a0,0x14
    80002dd6:	bce50513          	addi	a0,a0,-1074 # 800169a0 <tickslock>
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	eac080e7          	jalr	-340(ra) # 80000c86 <release>
  return xticks;
}
    80002de2:	02049513          	slli	a0,s1,0x20
    80002de6:	9101                	srli	a0,a0,0x20
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	64a2                	ld	s1,8(sp)
    80002dee:	6105                	addi	sp,sp,32
    80002df0:	8082                	ret

0000000080002df2 <sys_getmem>:

//Project 2 syscalls:
uint64
sys_getmem(void)
{
    80002df2:	1141                	addi	sp,sp,-16
    80002df4:	e406                	sd	ra,8(sp)
    80002df6:	e022                	sd	s0,0(sp)
    80002df8:	0800                	addi	s0,sp,16
   return myproc()->sz; // return the size of this process
    80002dfa:	fffff097          	auipc	ra,0xfffff
    80002dfe:	bac080e7          	jalr	-1108(ra) # 800019a6 <myproc>
}
    80002e02:	6528                	ld	a0,72(a0)
    80002e04:	60a2                	ld	ra,8(sp)
    80002e06:	6402                	ld	s0,0(sp)
    80002e08:	0141                	addi	sp,sp,16
    80002e0a:	8082                	ret

0000000080002e0c <sys_getstate>:

uint64
sys_getstate(void)
{
    80002e0c:	1141                	addi	sp,sp,-16
    80002e0e:	e406                	sd	ra,8(sp)
    80002e10:	e022                	sd	s0,0(sp)
    80002e12:	0800                	addi	s0,sp,16
  return myproc()->state;
    80002e14:	fffff097          	auipc	ra,0xfffff
    80002e18:	b92080e7          	jalr	-1134(ra) # 800019a6 <myproc>
}
    80002e1c:	01856503          	lwu	a0,24(a0)
    80002e20:	60a2                	ld	ra,8(sp)
    80002e22:	6402                	ld	s0,0(sp)
    80002e24:	0141                	addi	sp,sp,16
    80002e26:	8082                	ret

0000000080002e28 <sys_getparentpid>:

uint64
sys_getparentpid(void)
{
    80002e28:	1141                	addi	sp,sp,-16
    80002e2a:	e406                	sd	ra,8(sp)
    80002e2c:	e022                	sd	s0,0(sp)
    80002e2e:	0800                	addi	s0,sp,16
  return myproc()->parent->pid; // reutrn the parent's pid
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	b76080e7          	jalr	-1162(ra) # 800019a6 <myproc>
    80002e38:	7d1c                	ld	a5,56(a0)
}
    80002e3a:	5b88                	lw	a0,48(a5)
    80002e3c:	60a2                	ld	ra,8(sp)
    80002e3e:	6402                	ld	s0,0(sp)
    80002e40:	0141                	addi	sp,sp,16
    80002e42:	8082                	ret

0000000080002e44 <sys_getkstack>:

uint64
sys_getkstack(void)
{
    80002e44:	1141                	addi	sp,sp,-16
    80002e46:	e406                	sd	ra,8(sp)
    80002e48:	e022                	sd	s0,0(sp)
    80002e4a:	0800                	addi	s0,sp,16
  return myproc()->kstack; // return 64bit address (Base) of kstack
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	b5a080e7          	jalr	-1190(ra) # 800019a6 <myproc>
}
    80002e54:	6128                	ld	a0,64(a0)
    80002e56:	60a2                	ld	ra,8(sp)
    80002e58:	6402                	ld	s0,0(sp)
    80002e5a:	0141                	addi	sp,sp,16
    80002e5c:	8082                	ret

0000000080002e5e <sys_getpri>:

uint64
sys_getpri(void)
{
    80002e5e:	1141                	addi	sp,sp,-16
    80002e60:	e406                	sd	ra,8(sp)
    80002e62:	e022                	sd	s0,0(sp)
    80002e64:	0800                	addi	s0,sp,16
  return myproc()->prio;
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	b40080e7          	jalr	-1216(ra) # 800019a6 <myproc>
}
    80002e6e:	5948                	lw	a0,52(a0)
    80002e70:	60a2                	ld	ra,8(sp)
    80002e72:	6402                	ld	s0,0(sp)
    80002e74:	0141                	addi	sp,sp,16
    80002e76:	8082                	ret

0000000080002e78 <sys_setpri>:

uint64
sys_setpri(void)
{
    80002e78:	1101                	addi	sp,sp,-32
    80002e7a:	ec06                	sd	ra,24(sp)
    80002e7c:	e822                	sd	s0,16(sp)
    80002e7e:	1000                	addi	s0,sp,32
  int reqpri;
  argint(0, &reqpri); // get the requested priority
    80002e80:	fec40593          	addi	a1,s0,-20
    80002e84:	4501                	li	a0,0
    80002e86:	00000097          	auipc	ra,0x0
    80002e8a:	ca8080e7          	jalr	-856(ra) # 80002b2e <argint>
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002e8e:	fec42783          	lw	a5,-20(s0)
    80002e92:	ff67869b          	addiw	a3,a5,-10
    80002e96:	4715                	li	a4,5
     acquire(&myproc()->lock);
     myproc()->prio = reqpri;
     release(&myproc()->lock);
     return 0;
  }
  return -1;
    80002e98:	557d                	li	a0,-1
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002e9a:	00d76563          	bltu	a4,a3,80002ea4 <sys_setpri+0x2c>
    80002e9e:	4739                	li	a4,14
    80002ea0:	00e79663          	bne	a5,a4,80002eac <sys_setpri+0x34>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret
     acquire(&myproc()->lock);
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	afa080e7          	jalr	-1286(ra) # 800019a6 <myproc>
    80002eb4:	ffffe097          	auipc	ra,0xffffe
    80002eb8:	d1e080e7          	jalr	-738(ra) # 80000bd2 <acquire>
     myproc()->prio = reqpri;
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	aea080e7          	jalr	-1302(ra) # 800019a6 <myproc>
    80002ec4:	fec42783          	lw	a5,-20(s0)
    80002ec8:	d95c                	sw	a5,52(a0)
     release(&myproc()->lock);
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	adc080e7          	jalr	-1316(ra) # 800019a6 <myproc>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	db4080e7          	jalr	-588(ra) # 80000c86 <release>
     return 0;
    80002eda:	4501                	li	a0,0
    80002edc:	b7e1                	j	80002ea4 <sys_setpri+0x2c>

0000000080002ede <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ede:	7179                	addi	sp,sp,-48
    80002ee0:	f406                	sd	ra,40(sp)
    80002ee2:	f022                	sd	s0,32(sp)
    80002ee4:	ec26                	sd	s1,24(sp)
    80002ee6:	e84a                	sd	s2,16(sp)
    80002ee8:	e44e                	sd	s3,8(sp)
    80002eea:	e052                	sd	s4,0(sp)
    80002eec:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eee:	00005597          	auipc	a1,0x5
    80002ef2:	64258593          	addi	a1,a1,1602 # 80008530 <syscalls+0xe0>
    80002ef6:	00014517          	auipc	a0,0x14
    80002efa:	ac250513          	addi	a0,a0,-1342 # 800169b8 <bcache>
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	c44080e7          	jalr	-956(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f06:	0001c797          	auipc	a5,0x1c
    80002f0a:	ab278793          	addi	a5,a5,-1358 # 8001e9b8 <bcache+0x8000>
    80002f0e:	0001c717          	auipc	a4,0x1c
    80002f12:	d1270713          	addi	a4,a4,-750 # 8001ec20 <bcache+0x8268>
    80002f16:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f1a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f1e:	00014497          	auipc	s1,0x14
    80002f22:	ab248493          	addi	s1,s1,-1358 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002f26:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f28:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f2a:	00005a17          	auipc	s4,0x5
    80002f2e:	60ea0a13          	addi	s4,s4,1550 # 80008538 <syscalls+0xe8>
    b->next = bcache.head.next;
    80002f32:	2b893783          	ld	a5,696(s2)
    80002f36:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f38:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f3c:	85d2                	mv	a1,s4
    80002f3e:	01048513          	addi	a0,s1,16
    80002f42:	00001097          	auipc	ra,0x1
    80002f46:	496080e7          	jalr	1174(ra) # 800043d8 <initsleeplock>
    bcache.head.next->prev = b;
    80002f4a:	2b893783          	ld	a5,696(s2)
    80002f4e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f50:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f54:	45848493          	addi	s1,s1,1112
    80002f58:	fd349de3          	bne	s1,s3,80002f32 <binit+0x54>
  }
}
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	64e2                	ld	s1,24(sp)
    80002f62:	6942                	ld	s2,16(sp)
    80002f64:	69a2                	ld	s3,8(sp)
    80002f66:	6a02                	ld	s4,0(sp)
    80002f68:	6145                	addi	sp,sp,48
    80002f6a:	8082                	ret

0000000080002f6c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f6c:	7179                	addi	sp,sp,-48
    80002f6e:	f406                	sd	ra,40(sp)
    80002f70:	f022                	sd	s0,32(sp)
    80002f72:	ec26                	sd	s1,24(sp)
    80002f74:	e84a                	sd	s2,16(sp)
    80002f76:	e44e                	sd	s3,8(sp)
    80002f78:	1800                	addi	s0,sp,48
    80002f7a:	892a                	mv	s2,a0
    80002f7c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f7e:	00014517          	auipc	a0,0x14
    80002f82:	a3a50513          	addi	a0,a0,-1478 # 800169b8 <bcache>
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	c4c080e7          	jalr	-948(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f8e:	0001c497          	auipc	s1,0x1c
    80002f92:	ce24b483          	ld	s1,-798(s1) # 8001ec70 <bcache+0x82b8>
    80002f96:	0001c797          	auipc	a5,0x1c
    80002f9a:	c8a78793          	addi	a5,a5,-886 # 8001ec20 <bcache+0x8268>
    80002f9e:	02f48f63          	beq	s1,a5,80002fdc <bread+0x70>
    80002fa2:	873e                	mv	a4,a5
    80002fa4:	a021                	j	80002fac <bread+0x40>
    80002fa6:	68a4                	ld	s1,80(s1)
    80002fa8:	02e48a63          	beq	s1,a4,80002fdc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fac:	449c                	lw	a5,8(s1)
    80002fae:	ff279ce3          	bne	a5,s2,80002fa6 <bread+0x3a>
    80002fb2:	44dc                	lw	a5,12(s1)
    80002fb4:	ff3799e3          	bne	a5,s3,80002fa6 <bread+0x3a>
      b->refcnt++;
    80002fb8:	40bc                	lw	a5,64(s1)
    80002fba:	2785                	addiw	a5,a5,1
    80002fbc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fbe:	00014517          	auipc	a0,0x14
    80002fc2:	9fa50513          	addi	a0,a0,-1542 # 800169b8 <bcache>
    80002fc6:	ffffe097          	auipc	ra,0xffffe
    80002fca:	cc0080e7          	jalr	-832(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fce:	01048513          	addi	a0,s1,16
    80002fd2:	00001097          	auipc	ra,0x1
    80002fd6:	440080e7          	jalr	1088(ra) # 80004412 <acquiresleep>
      return b;
    80002fda:	a8b9                	j	80003038 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fdc:	0001c497          	auipc	s1,0x1c
    80002fe0:	c8c4b483          	ld	s1,-884(s1) # 8001ec68 <bcache+0x82b0>
    80002fe4:	0001c797          	auipc	a5,0x1c
    80002fe8:	c3c78793          	addi	a5,a5,-964 # 8001ec20 <bcache+0x8268>
    80002fec:	00f48863          	beq	s1,a5,80002ffc <bread+0x90>
    80002ff0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ff2:	40bc                	lw	a5,64(s1)
    80002ff4:	cf81                	beqz	a5,8000300c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ff6:	64a4                	ld	s1,72(s1)
    80002ff8:	fee49de3          	bne	s1,a4,80002ff2 <bread+0x86>
  panic("bget: no buffers");
    80002ffc:	00005517          	auipc	a0,0x5
    80003000:	54450513          	addi	a0,a0,1348 # 80008540 <syscalls+0xf0>
    80003004:	ffffd097          	auipc	ra,0xffffd
    80003008:	538080e7          	jalr	1336(ra) # 8000053c <panic>
      b->dev = dev;
    8000300c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003010:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003014:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003018:	4785                	li	a5,1
    8000301a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000301c:	00014517          	auipc	a0,0x14
    80003020:	99c50513          	addi	a0,a0,-1636 # 800169b8 <bcache>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	c62080e7          	jalr	-926(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000302c:	01048513          	addi	a0,s1,16
    80003030:	00001097          	auipc	ra,0x1
    80003034:	3e2080e7          	jalr	994(ra) # 80004412 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003038:	409c                	lw	a5,0(s1)
    8000303a:	cb89                	beqz	a5,8000304c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000303c:	8526                	mv	a0,s1
    8000303e:	70a2                	ld	ra,40(sp)
    80003040:	7402                	ld	s0,32(sp)
    80003042:	64e2                	ld	s1,24(sp)
    80003044:	6942                	ld	s2,16(sp)
    80003046:	69a2                	ld	s3,8(sp)
    80003048:	6145                	addi	sp,sp,48
    8000304a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000304c:	4581                	li	a1,0
    8000304e:	8526                	mv	a0,s1
    80003050:	00003097          	auipc	ra,0x3
    80003054:	f82080e7          	jalr	-126(ra) # 80005fd2 <virtio_disk_rw>
    b->valid = 1;
    80003058:	4785                	li	a5,1
    8000305a:	c09c                	sw	a5,0(s1)
  return b;
    8000305c:	b7c5                	j	8000303c <bread+0xd0>

000000008000305e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	1000                	addi	s0,sp,32
    80003068:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306a:	0541                	addi	a0,a0,16
    8000306c:	00001097          	auipc	ra,0x1
    80003070:	440080e7          	jalr	1088(ra) # 800044ac <holdingsleep>
    80003074:	cd01                	beqz	a0,8000308c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003076:	4585                	li	a1,1
    80003078:	8526                	mv	a0,s1
    8000307a:	00003097          	auipc	ra,0x3
    8000307e:	f58080e7          	jalr	-168(ra) # 80005fd2 <virtio_disk_rw>
}
    80003082:	60e2                	ld	ra,24(sp)
    80003084:	6442                	ld	s0,16(sp)
    80003086:	64a2                	ld	s1,8(sp)
    80003088:	6105                	addi	sp,sp,32
    8000308a:	8082                	ret
    panic("bwrite");
    8000308c:	00005517          	auipc	a0,0x5
    80003090:	4cc50513          	addi	a0,a0,1228 # 80008558 <syscalls+0x108>
    80003094:	ffffd097          	auipc	ra,0xffffd
    80003098:	4a8080e7          	jalr	1192(ra) # 8000053c <panic>

000000008000309c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000309c:	1101                	addi	sp,sp,-32
    8000309e:	ec06                	sd	ra,24(sp)
    800030a0:	e822                	sd	s0,16(sp)
    800030a2:	e426                	sd	s1,8(sp)
    800030a4:	e04a                	sd	s2,0(sp)
    800030a6:	1000                	addi	s0,sp,32
    800030a8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030aa:	01050913          	addi	s2,a0,16
    800030ae:	854a                	mv	a0,s2
    800030b0:	00001097          	auipc	ra,0x1
    800030b4:	3fc080e7          	jalr	1020(ra) # 800044ac <holdingsleep>
    800030b8:	c925                	beqz	a0,80003128 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030ba:	854a                	mv	a0,s2
    800030bc:	00001097          	auipc	ra,0x1
    800030c0:	3ac080e7          	jalr	940(ra) # 80004468 <releasesleep>

  acquire(&bcache.lock);
    800030c4:	00014517          	auipc	a0,0x14
    800030c8:	8f450513          	addi	a0,a0,-1804 # 800169b8 <bcache>
    800030cc:	ffffe097          	auipc	ra,0xffffe
    800030d0:	b06080e7          	jalr	-1274(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030d4:	40bc                	lw	a5,64(s1)
    800030d6:	37fd                	addiw	a5,a5,-1
    800030d8:	0007871b          	sext.w	a4,a5
    800030dc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030de:	e71d                	bnez	a4,8000310c <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030e0:	68b8                	ld	a4,80(s1)
    800030e2:	64bc                	ld	a5,72(s1)
    800030e4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030e6:	68b8                	ld	a4,80(s1)
    800030e8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030ea:	0001c797          	auipc	a5,0x1c
    800030ee:	8ce78793          	addi	a5,a5,-1842 # 8001e9b8 <bcache+0x8000>
    800030f2:	2b87b703          	ld	a4,696(a5)
    800030f6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030f8:	0001c717          	auipc	a4,0x1c
    800030fc:	b2870713          	addi	a4,a4,-1240 # 8001ec20 <bcache+0x8268>
    80003100:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003102:	2b87b703          	ld	a4,696(a5)
    80003106:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003108:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000310c:	00014517          	auipc	a0,0x14
    80003110:	8ac50513          	addi	a0,a0,-1876 # 800169b8 <bcache>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	b72080e7          	jalr	-1166(ra) # 80000c86 <release>
}
    8000311c:	60e2                	ld	ra,24(sp)
    8000311e:	6442                	ld	s0,16(sp)
    80003120:	64a2                	ld	s1,8(sp)
    80003122:	6902                	ld	s2,0(sp)
    80003124:	6105                	addi	sp,sp,32
    80003126:	8082                	ret
    panic("brelse");
    80003128:	00005517          	auipc	a0,0x5
    8000312c:	43850513          	addi	a0,a0,1080 # 80008560 <syscalls+0x110>
    80003130:	ffffd097          	auipc	ra,0xffffd
    80003134:	40c080e7          	jalr	1036(ra) # 8000053c <panic>

0000000080003138 <bpin>:

void
bpin(struct buf *b) {
    80003138:	1101                	addi	sp,sp,-32
    8000313a:	ec06                	sd	ra,24(sp)
    8000313c:	e822                	sd	s0,16(sp)
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	1000                	addi	s0,sp,32
    80003142:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003144:	00014517          	auipc	a0,0x14
    80003148:	87450513          	addi	a0,a0,-1932 # 800169b8 <bcache>
    8000314c:	ffffe097          	auipc	ra,0xffffe
    80003150:	a86080e7          	jalr	-1402(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003154:	40bc                	lw	a5,64(s1)
    80003156:	2785                	addiw	a5,a5,1
    80003158:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000315a:	00014517          	auipc	a0,0x14
    8000315e:	85e50513          	addi	a0,a0,-1954 # 800169b8 <bcache>
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	b24080e7          	jalr	-1244(ra) # 80000c86 <release>
}
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	64a2                	ld	s1,8(sp)
    80003170:	6105                	addi	sp,sp,32
    80003172:	8082                	ret

0000000080003174 <bunpin>:

void
bunpin(struct buf *b) {
    80003174:	1101                	addi	sp,sp,-32
    80003176:	ec06                	sd	ra,24(sp)
    80003178:	e822                	sd	s0,16(sp)
    8000317a:	e426                	sd	s1,8(sp)
    8000317c:	1000                	addi	s0,sp,32
    8000317e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003180:	00014517          	auipc	a0,0x14
    80003184:	83850513          	addi	a0,a0,-1992 # 800169b8 <bcache>
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	a4a080e7          	jalr	-1462(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003190:	40bc                	lw	a5,64(s1)
    80003192:	37fd                	addiw	a5,a5,-1
    80003194:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003196:	00014517          	auipc	a0,0x14
    8000319a:	82250513          	addi	a0,a0,-2014 # 800169b8 <bcache>
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	ae8080e7          	jalr	-1304(ra) # 80000c86 <release>
}
    800031a6:	60e2                	ld	ra,24(sp)
    800031a8:	6442                	ld	s0,16(sp)
    800031aa:	64a2                	ld	s1,8(sp)
    800031ac:	6105                	addi	sp,sp,32
    800031ae:	8082                	ret

00000000800031b0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031b0:	1101                	addi	sp,sp,-32
    800031b2:	ec06                	sd	ra,24(sp)
    800031b4:	e822                	sd	s0,16(sp)
    800031b6:	e426                	sd	s1,8(sp)
    800031b8:	e04a                	sd	s2,0(sp)
    800031ba:	1000                	addi	s0,sp,32
    800031bc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031be:	00d5d59b          	srliw	a1,a1,0xd
    800031c2:	0001c797          	auipc	a5,0x1c
    800031c6:	ed27a783          	lw	a5,-302(a5) # 8001f094 <sb+0x1c>
    800031ca:	9dbd                	addw	a1,a1,a5
    800031cc:	00000097          	auipc	ra,0x0
    800031d0:	da0080e7          	jalr	-608(ra) # 80002f6c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031d4:	0074f713          	andi	a4,s1,7
    800031d8:	4785                	li	a5,1
    800031da:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031de:	14ce                	slli	s1,s1,0x33
    800031e0:	90d9                	srli	s1,s1,0x36
    800031e2:	00950733          	add	a4,a0,s1
    800031e6:	05874703          	lbu	a4,88(a4)
    800031ea:	00e7f6b3          	and	a3,a5,a4
    800031ee:	c69d                	beqz	a3,8000321c <bfree+0x6c>
    800031f0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031f2:	94aa                	add	s1,s1,a0
    800031f4:	fff7c793          	not	a5,a5
    800031f8:	8f7d                	and	a4,a4,a5
    800031fa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031fe:	00001097          	auipc	ra,0x1
    80003202:	0f6080e7          	jalr	246(ra) # 800042f4 <log_write>
  brelse(bp);
    80003206:	854a                	mv	a0,s2
    80003208:	00000097          	auipc	ra,0x0
    8000320c:	e94080e7          	jalr	-364(ra) # 8000309c <brelse>
}
    80003210:	60e2                	ld	ra,24(sp)
    80003212:	6442                	ld	s0,16(sp)
    80003214:	64a2                	ld	s1,8(sp)
    80003216:	6902                	ld	s2,0(sp)
    80003218:	6105                	addi	sp,sp,32
    8000321a:	8082                	ret
    panic("freeing free block");
    8000321c:	00005517          	auipc	a0,0x5
    80003220:	34c50513          	addi	a0,a0,844 # 80008568 <syscalls+0x118>
    80003224:	ffffd097          	auipc	ra,0xffffd
    80003228:	318080e7          	jalr	792(ra) # 8000053c <panic>

000000008000322c <balloc>:
{
    8000322c:	711d                	addi	sp,sp,-96
    8000322e:	ec86                	sd	ra,88(sp)
    80003230:	e8a2                	sd	s0,80(sp)
    80003232:	e4a6                	sd	s1,72(sp)
    80003234:	e0ca                	sd	s2,64(sp)
    80003236:	fc4e                	sd	s3,56(sp)
    80003238:	f852                	sd	s4,48(sp)
    8000323a:	f456                	sd	s5,40(sp)
    8000323c:	f05a                	sd	s6,32(sp)
    8000323e:	ec5e                	sd	s7,24(sp)
    80003240:	e862                	sd	s8,16(sp)
    80003242:	e466                	sd	s9,8(sp)
    80003244:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003246:	0001c797          	auipc	a5,0x1c
    8000324a:	e367a783          	lw	a5,-458(a5) # 8001f07c <sb+0x4>
    8000324e:	cff5                	beqz	a5,8000334a <balloc+0x11e>
    80003250:	8baa                	mv	s7,a0
    80003252:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003254:	0001cb17          	auipc	s6,0x1c
    80003258:	e24b0b13          	addi	s6,s6,-476 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000325c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000325e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003260:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003262:	6c89                	lui	s9,0x2
    80003264:	a061                	j	800032ec <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003266:	97ca                	add	a5,a5,s2
    80003268:	8e55                	or	a2,a2,a3
    8000326a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	00001097          	auipc	ra,0x1
    80003274:	084080e7          	jalr	132(ra) # 800042f4 <log_write>
        brelse(bp);
    80003278:	854a                	mv	a0,s2
    8000327a:	00000097          	auipc	ra,0x0
    8000327e:	e22080e7          	jalr	-478(ra) # 8000309c <brelse>
  bp = bread(dev, bno);
    80003282:	85a6                	mv	a1,s1
    80003284:	855e                	mv	a0,s7
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	ce6080e7          	jalr	-794(ra) # 80002f6c <bread>
    8000328e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003290:	40000613          	li	a2,1024
    80003294:	4581                	li	a1,0
    80003296:	05850513          	addi	a0,a0,88
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	a34080e7          	jalr	-1484(ra) # 80000cce <memset>
  log_write(bp);
    800032a2:	854a                	mv	a0,s2
    800032a4:	00001097          	auipc	ra,0x1
    800032a8:	050080e7          	jalr	80(ra) # 800042f4 <log_write>
  brelse(bp);
    800032ac:	854a                	mv	a0,s2
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	dee080e7          	jalr	-530(ra) # 8000309c <brelse>
}
    800032b6:	8526                	mv	a0,s1
    800032b8:	60e6                	ld	ra,88(sp)
    800032ba:	6446                	ld	s0,80(sp)
    800032bc:	64a6                	ld	s1,72(sp)
    800032be:	6906                	ld	s2,64(sp)
    800032c0:	79e2                	ld	s3,56(sp)
    800032c2:	7a42                	ld	s4,48(sp)
    800032c4:	7aa2                	ld	s5,40(sp)
    800032c6:	7b02                	ld	s6,32(sp)
    800032c8:	6be2                	ld	s7,24(sp)
    800032ca:	6c42                	ld	s8,16(sp)
    800032cc:	6ca2                	ld	s9,8(sp)
    800032ce:	6125                	addi	sp,sp,96
    800032d0:	8082                	ret
    brelse(bp);
    800032d2:	854a                	mv	a0,s2
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	dc8080e7          	jalr	-568(ra) # 8000309c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032dc:	015c87bb          	addw	a5,s9,s5
    800032e0:	00078a9b          	sext.w	s5,a5
    800032e4:	004b2703          	lw	a4,4(s6)
    800032e8:	06eaf163          	bgeu	s5,a4,8000334a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032ec:	41fad79b          	sraiw	a5,s5,0x1f
    800032f0:	0137d79b          	srliw	a5,a5,0x13
    800032f4:	015787bb          	addw	a5,a5,s5
    800032f8:	40d7d79b          	sraiw	a5,a5,0xd
    800032fc:	01cb2583          	lw	a1,28(s6)
    80003300:	9dbd                	addw	a1,a1,a5
    80003302:	855e                	mv	a0,s7
    80003304:	00000097          	auipc	ra,0x0
    80003308:	c68080e7          	jalr	-920(ra) # 80002f6c <bread>
    8000330c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000330e:	004b2503          	lw	a0,4(s6)
    80003312:	000a849b          	sext.w	s1,s5
    80003316:	8762                	mv	a4,s8
    80003318:	faa4fde3          	bgeu	s1,a0,800032d2 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000331c:	00777693          	andi	a3,a4,7
    80003320:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003324:	41f7579b          	sraiw	a5,a4,0x1f
    80003328:	01d7d79b          	srliw	a5,a5,0x1d
    8000332c:	9fb9                	addw	a5,a5,a4
    8000332e:	4037d79b          	sraiw	a5,a5,0x3
    80003332:	00f90633          	add	a2,s2,a5
    80003336:	05864603          	lbu	a2,88(a2)
    8000333a:	00c6f5b3          	and	a1,a3,a2
    8000333e:	d585                	beqz	a1,80003266 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003340:	2705                	addiw	a4,a4,1
    80003342:	2485                	addiw	s1,s1,1
    80003344:	fd471ae3          	bne	a4,s4,80003318 <balloc+0xec>
    80003348:	b769                	j	800032d2 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000334a:	00005517          	auipc	a0,0x5
    8000334e:	23650513          	addi	a0,a0,566 # 80008580 <syscalls+0x130>
    80003352:	ffffd097          	auipc	ra,0xffffd
    80003356:	234080e7          	jalr	564(ra) # 80000586 <printf>
  return 0;
    8000335a:	4481                	li	s1,0
    8000335c:	bfa9                	j	800032b6 <balloc+0x8a>

000000008000335e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000335e:	7179                	addi	sp,sp,-48
    80003360:	f406                	sd	ra,40(sp)
    80003362:	f022                	sd	s0,32(sp)
    80003364:	ec26                	sd	s1,24(sp)
    80003366:	e84a                	sd	s2,16(sp)
    80003368:	e44e                	sd	s3,8(sp)
    8000336a:	e052                	sd	s4,0(sp)
    8000336c:	1800                	addi	s0,sp,48
    8000336e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003370:	47ad                	li	a5,11
    80003372:	02b7e863          	bltu	a5,a1,800033a2 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003376:	02059793          	slli	a5,a1,0x20
    8000337a:	01e7d593          	srli	a1,a5,0x1e
    8000337e:	00b504b3          	add	s1,a0,a1
    80003382:	0504a903          	lw	s2,80(s1)
    80003386:	06091e63          	bnez	s2,80003402 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000338a:	4108                	lw	a0,0(a0)
    8000338c:	00000097          	auipc	ra,0x0
    80003390:	ea0080e7          	jalr	-352(ra) # 8000322c <balloc>
    80003394:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003398:	06090563          	beqz	s2,80003402 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000339c:	0524a823          	sw	s2,80(s1)
    800033a0:	a08d                	j	80003402 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033a2:	ff45849b          	addiw	s1,a1,-12
    800033a6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033aa:	0ff00793          	li	a5,255
    800033ae:	08e7e563          	bltu	a5,a4,80003438 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033b2:	08052903          	lw	s2,128(a0)
    800033b6:	00091d63          	bnez	s2,800033d0 <bmap+0x72>
      addr = balloc(ip->dev);
    800033ba:	4108                	lw	a0,0(a0)
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	e70080e7          	jalr	-400(ra) # 8000322c <balloc>
    800033c4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033c8:	02090d63          	beqz	s2,80003402 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033cc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033d0:	85ca                	mv	a1,s2
    800033d2:	0009a503          	lw	a0,0(s3)
    800033d6:	00000097          	auipc	ra,0x0
    800033da:	b96080e7          	jalr	-1130(ra) # 80002f6c <bread>
    800033de:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033e0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033e4:	02049713          	slli	a4,s1,0x20
    800033e8:	01e75593          	srli	a1,a4,0x1e
    800033ec:	00b784b3          	add	s1,a5,a1
    800033f0:	0004a903          	lw	s2,0(s1)
    800033f4:	02090063          	beqz	s2,80003414 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033f8:	8552                	mv	a0,s4
    800033fa:	00000097          	auipc	ra,0x0
    800033fe:	ca2080e7          	jalr	-862(ra) # 8000309c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003402:	854a                	mv	a0,s2
    80003404:	70a2                	ld	ra,40(sp)
    80003406:	7402                	ld	s0,32(sp)
    80003408:	64e2                	ld	s1,24(sp)
    8000340a:	6942                	ld	s2,16(sp)
    8000340c:	69a2                	ld	s3,8(sp)
    8000340e:	6a02                	ld	s4,0(sp)
    80003410:	6145                	addi	sp,sp,48
    80003412:	8082                	ret
      addr = balloc(ip->dev);
    80003414:	0009a503          	lw	a0,0(s3)
    80003418:	00000097          	auipc	ra,0x0
    8000341c:	e14080e7          	jalr	-492(ra) # 8000322c <balloc>
    80003420:	0005091b          	sext.w	s2,a0
      if(addr){
    80003424:	fc090ae3          	beqz	s2,800033f8 <bmap+0x9a>
        a[bn] = addr;
    80003428:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000342c:	8552                	mv	a0,s4
    8000342e:	00001097          	auipc	ra,0x1
    80003432:	ec6080e7          	jalr	-314(ra) # 800042f4 <log_write>
    80003436:	b7c9                	j	800033f8 <bmap+0x9a>
  panic("bmap: out of range");
    80003438:	00005517          	auipc	a0,0x5
    8000343c:	16050513          	addi	a0,a0,352 # 80008598 <syscalls+0x148>
    80003440:	ffffd097          	auipc	ra,0xffffd
    80003444:	0fc080e7          	jalr	252(ra) # 8000053c <panic>

0000000080003448 <iget>:
{
    80003448:	7179                	addi	sp,sp,-48
    8000344a:	f406                	sd	ra,40(sp)
    8000344c:	f022                	sd	s0,32(sp)
    8000344e:	ec26                	sd	s1,24(sp)
    80003450:	e84a                	sd	s2,16(sp)
    80003452:	e44e                	sd	s3,8(sp)
    80003454:	e052                	sd	s4,0(sp)
    80003456:	1800                	addi	s0,sp,48
    80003458:	89aa                	mv	s3,a0
    8000345a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000345c:	0001c517          	auipc	a0,0x1c
    80003460:	c3c50513          	addi	a0,a0,-964 # 8001f098 <itable>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	76e080e7          	jalr	1902(ra) # 80000bd2 <acquire>
  empty = 0;
    8000346c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000346e:	0001c497          	auipc	s1,0x1c
    80003472:	c4248493          	addi	s1,s1,-958 # 8001f0b0 <itable+0x18>
    80003476:	0001d697          	auipc	a3,0x1d
    8000347a:	6ca68693          	addi	a3,a3,1738 # 80020b40 <log>
    8000347e:	a039                	j	8000348c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003480:	02090b63          	beqz	s2,800034b6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003484:	08848493          	addi	s1,s1,136
    80003488:	02d48a63          	beq	s1,a3,800034bc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000348c:	449c                	lw	a5,8(s1)
    8000348e:	fef059e3          	blez	a5,80003480 <iget+0x38>
    80003492:	4098                	lw	a4,0(s1)
    80003494:	ff3716e3          	bne	a4,s3,80003480 <iget+0x38>
    80003498:	40d8                	lw	a4,4(s1)
    8000349a:	ff4713e3          	bne	a4,s4,80003480 <iget+0x38>
      ip->ref++;
    8000349e:	2785                	addiw	a5,a5,1
    800034a0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034a2:	0001c517          	auipc	a0,0x1c
    800034a6:	bf650513          	addi	a0,a0,-1034 # 8001f098 <itable>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	7dc080e7          	jalr	2012(ra) # 80000c86 <release>
      return ip;
    800034b2:	8926                	mv	s2,s1
    800034b4:	a03d                	j	800034e2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034b6:	f7f9                	bnez	a5,80003484 <iget+0x3c>
    800034b8:	8926                	mv	s2,s1
    800034ba:	b7e9                	j	80003484 <iget+0x3c>
  if(empty == 0)
    800034bc:	02090c63          	beqz	s2,800034f4 <iget+0xac>
  ip->dev = dev;
    800034c0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034c4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034c8:	4785                	li	a5,1
    800034ca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ce:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034d2:	0001c517          	auipc	a0,0x1c
    800034d6:	bc650513          	addi	a0,a0,-1082 # 8001f098 <itable>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	7ac080e7          	jalr	1964(ra) # 80000c86 <release>
}
    800034e2:	854a                	mv	a0,s2
    800034e4:	70a2                	ld	ra,40(sp)
    800034e6:	7402                	ld	s0,32(sp)
    800034e8:	64e2                	ld	s1,24(sp)
    800034ea:	6942                	ld	s2,16(sp)
    800034ec:	69a2                	ld	s3,8(sp)
    800034ee:	6a02                	ld	s4,0(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret
    panic("iget: no inodes");
    800034f4:	00005517          	auipc	a0,0x5
    800034f8:	0bc50513          	addi	a0,a0,188 # 800085b0 <syscalls+0x160>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	040080e7          	jalr	64(ra) # 8000053c <panic>

0000000080003504 <fsinit>:
fsinit(int dev) {
    80003504:	7179                	addi	sp,sp,-48
    80003506:	f406                	sd	ra,40(sp)
    80003508:	f022                	sd	s0,32(sp)
    8000350a:	ec26                	sd	s1,24(sp)
    8000350c:	e84a                	sd	s2,16(sp)
    8000350e:	e44e                	sd	s3,8(sp)
    80003510:	1800                	addi	s0,sp,48
    80003512:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003514:	4585                	li	a1,1
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	a56080e7          	jalr	-1450(ra) # 80002f6c <bread>
    8000351e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003520:	0001c997          	auipc	s3,0x1c
    80003524:	b5898993          	addi	s3,s3,-1192 # 8001f078 <sb>
    80003528:	02000613          	li	a2,32
    8000352c:	05850593          	addi	a1,a0,88
    80003530:	854e                	mv	a0,s3
    80003532:	ffffd097          	auipc	ra,0xffffd
    80003536:	7f8080e7          	jalr	2040(ra) # 80000d2a <memmove>
  brelse(bp);
    8000353a:	8526                	mv	a0,s1
    8000353c:	00000097          	auipc	ra,0x0
    80003540:	b60080e7          	jalr	-1184(ra) # 8000309c <brelse>
  if(sb.magic != FSMAGIC)
    80003544:	0009a703          	lw	a4,0(s3)
    80003548:	102037b7          	lui	a5,0x10203
    8000354c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003550:	02f71263          	bne	a4,a5,80003574 <fsinit+0x70>
  initlog(dev, &sb);
    80003554:	0001c597          	auipc	a1,0x1c
    80003558:	b2458593          	addi	a1,a1,-1244 # 8001f078 <sb>
    8000355c:	854a                	mv	a0,s2
    8000355e:	00001097          	auipc	ra,0x1
    80003562:	b2c080e7          	jalr	-1236(ra) # 8000408a <initlog>
}
    80003566:	70a2                	ld	ra,40(sp)
    80003568:	7402                	ld	s0,32(sp)
    8000356a:	64e2                	ld	s1,24(sp)
    8000356c:	6942                	ld	s2,16(sp)
    8000356e:	69a2                	ld	s3,8(sp)
    80003570:	6145                	addi	sp,sp,48
    80003572:	8082                	ret
    panic("invalid file system");
    80003574:	00005517          	auipc	a0,0x5
    80003578:	04c50513          	addi	a0,a0,76 # 800085c0 <syscalls+0x170>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	fc0080e7          	jalr	-64(ra) # 8000053c <panic>

0000000080003584 <iinit>:
{
    80003584:	7179                	addi	sp,sp,-48
    80003586:	f406                	sd	ra,40(sp)
    80003588:	f022                	sd	s0,32(sp)
    8000358a:	ec26                	sd	s1,24(sp)
    8000358c:	e84a                	sd	s2,16(sp)
    8000358e:	e44e                	sd	s3,8(sp)
    80003590:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003592:	00005597          	auipc	a1,0x5
    80003596:	04658593          	addi	a1,a1,70 # 800085d8 <syscalls+0x188>
    8000359a:	0001c517          	auipc	a0,0x1c
    8000359e:	afe50513          	addi	a0,a0,-1282 # 8001f098 <itable>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	5a0080e7          	jalr	1440(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035aa:	0001c497          	auipc	s1,0x1c
    800035ae:	b1648493          	addi	s1,s1,-1258 # 8001f0c0 <itable+0x28>
    800035b2:	0001d997          	auipc	s3,0x1d
    800035b6:	59e98993          	addi	s3,s3,1438 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035ba:	00005917          	auipc	s2,0x5
    800035be:	02690913          	addi	s2,s2,38 # 800085e0 <syscalls+0x190>
    800035c2:	85ca                	mv	a1,s2
    800035c4:	8526                	mv	a0,s1
    800035c6:	00001097          	auipc	ra,0x1
    800035ca:	e12080e7          	jalr	-494(ra) # 800043d8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035ce:	08848493          	addi	s1,s1,136
    800035d2:	ff3498e3          	bne	s1,s3,800035c2 <iinit+0x3e>
}
    800035d6:	70a2                	ld	ra,40(sp)
    800035d8:	7402                	ld	s0,32(sp)
    800035da:	64e2                	ld	s1,24(sp)
    800035dc:	6942                	ld	s2,16(sp)
    800035de:	69a2                	ld	s3,8(sp)
    800035e0:	6145                	addi	sp,sp,48
    800035e2:	8082                	ret

00000000800035e4 <ialloc>:
{
    800035e4:	7139                	addi	sp,sp,-64
    800035e6:	fc06                	sd	ra,56(sp)
    800035e8:	f822                	sd	s0,48(sp)
    800035ea:	f426                	sd	s1,40(sp)
    800035ec:	f04a                	sd	s2,32(sp)
    800035ee:	ec4e                	sd	s3,24(sp)
    800035f0:	e852                	sd	s4,16(sp)
    800035f2:	e456                	sd	s5,8(sp)
    800035f4:	e05a                	sd	s6,0(sp)
    800035f6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035f8:	0001c717          	auipc	a4,0x1c
    800035fc:	a8c72703          	lw	a4,-1396(a4) # 8001f084 <sb+0xc>
    80003600:	4785                	li	a5,1
    80003602:	04e7f863          	bgeu	a5,a4,80003652 <ialloc+0x6e>
    80003606:	8aaa                	mv	s5,a0
    80003608:	8b2e                	mv	s6,a1
    8000360a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000360c:	0001ca17          	auipc	s4,0x1c
    80003610:	a6ca0a13          	addi	s4,s4,-1428 # 8001f078 <sb>
    80003614:	00495593          	srli	a1,s2,0x4
    80003618:	018a2783          	lw	a5,24(s4)
    8000361c:	9dbd                	addw	a1,a1,a5
    8000361e:	8556                	mv	a0,s5
    80003620:	00000097          	auipc	ra,0x0
    80003624:	94c080e7          	jalr	-1716(ra) # 80002f6c <bread>
    80003628:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000362a:	05850993          	addi	s3,a0,88
    8000362e:	00f97793          	andi	a5,s2,15
    80003632:	079a                	slli	a5,a5,0x6
    80003634:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003636:	00099783          	lh	a5,0(s3)
    8000363a:	cf9d                	beqz	a5,80003678 <ialloc+0x94>
    brelse(bp);
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	a60080e7          	jalr	-1440(ra) # 8000309c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003644:	0905                	addi	s2,s2,1
    80003646:	00ca2703          	lw	a4,12(s4)
    8000364a:	0009079b          	sext.w	a5,s2
    8000364e:	fce7e3e3          	bltu	a5,a4,80003614 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	f9650513          	addi	a0,a0,-106 # 800085e8 <syscalls+0x198>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	f2c080e7          	jalr	-212(ra) # 80000586 <printf>
  return 0;
    80003662:	4501                	li	a0,0
}
    80003664:	70e2                	ld	ra,56(sp)
    80003666:	7442                	ld	s0,48(sp)
    80003668:	74a2                	ld	s1,40(sp)
    8000366a:	7902                	ld	s2,32(sp)
    8000366c:	69e2                	ld	s3,24(sp)
    8000366e:	6a42                	ld	s4,16(sp)
    80003670:	6aa2                	ld	s5,8(sp)
    80003672:	6b02                	ld	s6,0(sp)
    80003674:	6121                	addi	sp,sp,64
    80003676:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003678:	04000613          	li	a2,64
    8000367c:	4581                	li	a1,0
    8000367e:	854e                	mv	a0,s3
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	64e080e7          	jalr	1614(ra) # 80000cce <memset>
      dip->type = type;
    80003688:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000368c:	8526                	mv	a0,s1
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	c66080e7          	jalr	-922(ra) # 800042f4 <log_write>
      brelse(bp);
    80003696:	8526                	mv	a0,s1
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	a04080e7          	jalr	-1532(ra) # 8000309c <brelse>
      return iget(dev, inum);
    800036a0:	0009059b          	sext.w	a1,s2
    800036a4:	8556                	mv	a0,s5
    800036a6:	00000097          	auipc	ra,0x0
    800036aa:	da2080e7          	jalr	-606(ra) # 80003448 <iget>
    800036ae:	bf5d                	j	80003664 <ialloc+0x80>

00000000800036b0 <iupdate>:
{
    800036b0:	1101                	addi	sp,sp,-32
    800036b2:	ec06                	sd	ra,24(sp)
    800036b4:	e822                	sd	s0,16(sp)
    800036b6:	e426                	sd	s1,8(sp)
    800036b8:	e04a                	sd	s2,0(sp)
    800036ba:	1000                	addi	s0,sp,32
    800036bc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036be:	415c                	lw	a5,4(a0)
    800036c0:	0047d79b          	srliw	a5,a5,0x4
    800036c4:	0001c597          	auipc	a1,0x1c
    800036c8:	9cc5a583          	lw	a1,-1588(a1) # 8001f090 <sb+0x18>
    800036cc:	9dbd                	addw	a1,a1,a5
    800036ce:	4108                	lw	a0,0(a0)
    800036d0:	00000097          	auipc	ra,0x0
    800036d4:	89c080e7          	jalr	-1892(ra) # 80002f6c <bread>
    800036d8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036da:	05850793          	addi	a5,a0,88
    800036de:	40d8                	lw	a4,4(s1)
    800036e0:	8b3d                	andi	a4,a4,15
    800036e2:	071a                	slli	a4,a4,0x6
    800036e4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036e6:	04449703          	lh	a4,68(s1)
    800036ea:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036ee:	04649703          	lh	a4,70(s1)
    800036f2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036f6:	04849703          	lh	a4,72(s1)
    800036fa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036fe:	04a49703          	lh	a4,74(s1)
    80003702:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003706:	44f8                	lw	a4,76(s1)
    80003708:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000370a:	03400613          	li	a2,52
    8000370e:	05048593          	addi	a1,s1,80
    80003712:	00c78513          	addi	a0,a5,12
    80003716:	ffffd097          	auipc	ra,0xffffd
    8000371a:	614080e7          	jalr	1556(ra) # 80000d2a <memmove>
  log_write(bp);
    8000371e:	854a                	mv	a0,s2
    80003720:	00001097          	auipc	ra,0x1
    80003724:	bd4080e7          	jalr	-1068(ra) # 800042f4 <log_write>
  brelse(bp);
    80003728:	854a                	mv	a0,s2
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	972080e7          	jalr	-1678(ra) # 8000309c <brelse>
}
    80003732:	60e2                	ld	ra,24(sp)
    80003734:	6442                	ld	s0,16(sp)
    80003736:	64a2                	ld	s1,8(sp)
    80003738:	6902                	ld	s2,0(sp)
    8000373a:	6105                	addi	sp,sp,32
    8000373c:	8082                	ret

000000008000373e <idup>:
{
    8000373e:	1101                	addi	sp,sp,-32
    80003740:	ec06                	sd	ra,24(sp)
    80003742:	e822                	sd	s0,16(sp)
    80003744:	e426                	sd	s1,8(sp)
    80003746:	1000                	addi	s0,sp,32
    80003748:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000374a:	0001c517          	auipc	a0,0x1c
    8000374e:	94e50513          	addi	a0,a0,-1714 # 8001f098 <itable>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	480080e7          	jalr	1152(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000375a:	449c                	lw	a5,8(s1)
    8000375c:	2785                	addiw	a5,a5,1
    8000375e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003760:	0001c517          	auipc	a0,0x1c
    80003764:	93850513          	addi	a0,a0,-1736 # 8001f098 <itable>
    80003768:	ffffd097          	auipc	ra,0xffffd
    8000376c:	51e080e7          	jalr	1310(ra) # 80000c86 <release>
}
    80003770:	8526                	mv	a0,s1
    80003772:	60e2                	ld	ra,24(sp)
    80003774:	6442                	ld	s0,16(sp)
    80003776:	64a2                	ld	s1,8(sp)
    80003778:	6105                	addi	sp,sp,32
    8000377a:	8082                	ret

000000008000377c <ilock>:
{
    8000377c:	1101                	addi	sp,sp,-32
    8000377e:	ec06                	sd	ra,24(sp)
    80003780:	e822                	sd	s0,16(sp)
    80003782:	e426                	sd	s1,8(sp)
    80003784:	e04a                	sd	s2,0(sp)
    80003786:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003788:	c115                	beqz	a0,800037ac <ilock+0x30>
    8000378a:	84aa                	mv	s1,a0
    8000378c:	451c                	lw	a5,8(a0)
    8000378e:	00f05f63          	blez	a5,800037ac <ilock+0x30>
  acquiresleep(&ip->lock);
    80003792:	0541                	addi	a0,a0,16
    80003794:	00001097          	auipc	ra,0x1
    80003798:	c7e080e7          	jalr	-898(ra) # 80004412 <acquiresleep>
  if(ip->valid == 0){
    8000379c:	40bc                	lw	a5,64(s1)
    8000379e:	cf99                	beqz	a5,800037bc <ilock+0x40>
}
    800037a0:	60e2                	ld	ra,24(sp)
    800037a2:	6442                	ld	s0,16(sp)
    800037a4:	64a2                	ld	s1,8(sp)
    800037a6:	6902                	ld	s2,0(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret
    panic("ilock");
    800037ac:	00005517          	auipc	a0,0x5
    800037b0:	e5450513          	addi	a0,a0,-428 # 80008600 <syscalls+0x1b0>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	d88080e7          	jalr	-632(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037bc:	40dc                	lw	a5,4(s1)
    800037be:	0047d79b          	srliw	a5,a5,0x4
    800037c2:	0001c597          	auipc	a1,0x1c
    800037c6:	8ce5a583          	lw	a1,-1842(a1) # 8001f090 <sb+0x18>
    800037ca:	9dbd                	addw	a1,a1,a5
    800037cc:	4088                	lw	a0,0(s1)
    800037ce:	fffff097          	auipc	ra,0xfffff
    800037d2:	79e080e7          	jalr	1950(ra) # 80002f6c <bread>
    800037d6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d8:	05850593          	addi	a1,a0,88
    800037dc:	40dc                	lw	a5,4(s1)
    800037de:	8bbd                	andi	a5,a5,15
    800037e0:	079a                	slli	a5,a5,0x6
    800037e2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037e4:	00059783          	lh	a5,0(a1)
    800037e8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037ec:	00259783          	lh	a5,2(a1)
    800037f0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037f4:	00459783          	lh	a5,4(a1)
    800037f8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037fc:	00659783          	lh	a5,6(a1)
    80003800:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003804:	459c                	lw	a5,8(a1)
    80003806:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003808:	03400613          	li	a2,52
    8000380c:	05b1                	addi	a1,a1,12
    8000380e:	05048513          	addi	a0,s1,80
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	518080e7          	jalr	1304(ra) # 80000d2a <memmove>
    brelse(bp);
    8000381a:	854a                	mv	a0,s2
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	880080e7          	jalr	-1920(ra) # 8000309c <brelse>
    ip->valid = 1;
    80003824:	4785                	li	a5,1
    80003826:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003828:	04449783          	lh	a5,68(s1)
    8000382c:	fbb5                	bnez	a5,800037a0 <ilock+0x24>
      panic("ilock: no type");
    8000382e:	00005517          	auipc	a0,0x5
    80003832:	dda50513          	addi	a0,a0,-550 # 80008608 <syscalls+0x1b8>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	d06080e7          	jalr	-762(ra) # 8000053c <panic>

000000008000383e <iunlock>:
{
    8000383e:	1101                	addi	sp,sp,-32
    80003840:	ec06                	sd	ra,24(sp)
    80003842:	e822                	sd	s0,16(sp)
    80003844:	e426                	sd	s1,8(sp)
    80003846:	e04a                	sd	s2,0(sp)
    80003848:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000384a:	c905                	beqz	a0,8000387a <iunlock+0x3c>
    8000384c:	84aa                	mv	s1,a0
    8000384e:	01050913          	addi	s2,a0,16
    80003852:	854a                	mv	a0,s2
    80003854:	00001097          	auipc	ra,0x1
    80003858:	c58080e7          	jalr	-936(ra) # 800044ac <holdingsleep>
    8000385c:	cd19                	beqz	a0,8000387a <iunlock+0x3c>
    8000385e:	449c                	lw	a5,8(s1)
    80003860:	00f05d63          	blez	a5,8000387a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003864:	854a                	mv	a0,s2
    80003866:	00001097          	auipc	ra,0x1
    8000386a:	c02080e7          	jalr	-1022(ra) # 80004468 <releasesleep>
}
    8000386e:	60e2                	ld	ra,24(sp)
    80003870:	6442                	ld	s0,16(sp)
    80003872:	64a2                	ld	s1,8(sp)
    80003874:	6902                	ld	s2,0(sp)
    80003876:	6105                	addi	sp,sp,32
    80003878:	8082                	ret
    panic("iunlock");
    8000387a:	00005517          	auipc	a0,0x5
    8000387e:	d9e50513          	addi	a0,a0,-610 # 80008618 <syscalls+0x1c8>
    80003882:	ffffd097          	auipc	ra,0xffffd
    80003886:	cba080e7          	jalr	-838(ra) # 8000053c <panic>

000000008000388a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000388a:	7179                	addi	sp,sp,-48
    8000388c:	f406                	sd	ra,40(sp)
    8000388e:	f022                	sd	s0,32(sp)
    80003890:	ec26                	sd	s1,24(sp)
    80003892:	e84a                	sd	s2,16(sp)
    80003894:	e44e                	sd	s3,8(sp)
    80003896:	e052                	sd	s4,0(sp)
    80003898:	1800                	addi	s0,sp,48
    8000389a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000389c:	05050493          	addi	s1,a0,80
    800038a0:	08050913          	addi	s2,a0,128
    800038a4:	a021                	j	800038ac <itrunc+0x22>
    800038a6:	0491                	addi	s1,s1,4
    800038a8:	01248d63          	beq	s1,s2,800038c2 <itrunc+0x38>
    if(ip->addrs[i]){
    800038ac:	408c                	lw	a1,0(s1)
    800038ae:	dde5                	beqz	a1,800038a6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038b0:	0009a503          	lw	a0,0(s3)
    800038b4:	00000097          	auipc	ra,0x0
    800038b8:	8fc080e7          	jalr	-1796(ra) # 800031b0 <bfree>
      ip->addrs[i] = 0;
    800038bc:	0004a023          	sw	zero,0(s1)
    800038c0:	b7dd                	j	800038a6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038c2:	0809a583          	lw	a1,128(s3)
    800038c6:	e185                	bnez	a1,800038e6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038c8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038cc:	854e                	mv	a0,s3
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	de2080e7          	jalr	-542(ra) # 800036b0 <iupdate>
}
    800038d6:	70a2                	ld	ra,40(sp)
    800038d8:	7402                	ld	s0,32(sp)
    800038da:	64e2                	ld	s1,24(sp)
    800038dc:	6942                	ld	s2,16(sp)
    800038de:	69a2                	ld	s3,8(sp)
    800038e0:	6a02                	ld	s4,0(sp)
    800038e2:	6145                	addi	sp,sp,48
    800038e4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038e6:	0009a503          	lw	a0,0(s3)
    800038ea:	fffff097          	auipc	ra,0xfffff
    800038ee:	682080e7          	jalr	1666(ra) # 80002f6c <bread>
    800038f2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038f4:	05850493          	addi	s1,a0,88
    800038f8:	45850913          	addi	s2,a0,1112
    800038fc:	a021                	j	80003904 <itrunc+0x7a>
    800038fe:	0491                	addi	s1,s1,4
    80003900:	01248b63          	beq	s1,s2,80003916 <itrunc+0x8c>
      if(a[j])
    80003904:	408c                	lw	a1,0(s1)
    80003906:	dde5                	beqz	a1,800038fe <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003908:	0009a503          	lw	a0,0(s3)
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	8a4080e7          	jalr	-1884(ra) # 800031b0 <bfree>
    80003914:	b7ed                	j	800038fe <itrunc+0x74>
    brelse(bp);
    80003916:	8552                	mv	a0,s4
    80003918:	fffff097          	auipc	ra,0xfffff
    8000391c:	784080e7          	jalr	1924(ra) # 8000309c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003920:	0809a583          	lw	a1,128(s3)
    80003924:	0009a503          	lw	a0,0(s3)
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	888080e7          	jalr	-1912(ra) # 800031b0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003930:	0809a023          	sw	zero,128(s3)
    80003934:	bf51                	j	800038c8 <itrunc+0x3e>

0000000080003936 <iput>:
{
    80003936:	1101                	addi	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	e04a                	sd	s2,0(sp)
    80003940:	1000                	addi	s0,sp,32
    80003942:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003944:	0001b517          	auipc	a0,0x1b
    80003948:	75450513          	addi	a0,a0,1876 # 8001f098 <itable>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	286080e7          	jalr	646(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003954:	4498                	lw	a4,8(s1)
    80003956:	4785                	li	a5,1
    80003958:	02f70363          	beq	a4,a5,8000397e <iput+0x48>
  ip->ref--;
    8000395c:	449c                	lw	a5,8(s1)
    8000395e:	37fd                	addiw	a5,a5,-1
    80003960:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003962:	0001b517          	auipc	a0,0x1b
    80003966:	73650513          	addi	a0,a0,1846 # 8001f098 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	31c080e7          	jalr	796(ra) # 80000c86 <release>
}
    80003972:	60e2                	ld	ra,24(sp)
    80003974:	6442                	ld	s0,16(sp)
    80003976:	64a2                	ld	s1,8(sp)
    80003978:	6902                	ld	s2,0(sp)
    8000397a:	6105                	addi	sp,sp,32
    8000397c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000397e:	40bc                	lw	a5,64(s1)
    80003980:	dff1                	beqz	a5,8000395c <iput+0x26>
    80003982:	04a49783          	lh	a5,74(s1)
    80003986:	fbf9                	bnez	a5,8000395c <iput+0x26>
    acquiresleep(&ip->lock);
    80003988:	01048913          	addi	s2,s1,16
    8000398c:	854a                	mv	a0,s2
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	a84080e7          	jalr	-1404(ra) # 80004412 <acquiresleep>
    release(&itable.lock);
    80003996:	0001b517          	auipc	a0,0x1b
    8000399a:	70250513          	addi	a0,a0,1794 # 8001f098 <itable>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	2e8080e7          	jalr	744(ra) # 80000c86 <release>
    itrunc(ip);
    800039a6:	8526                	mv	a0,s1
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	ee2080e7          	jalr	-286(ra) # 8000388a <itrunc>
    ip->type = 0;
    800039b0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039b4:	8526                	mv	a0,s1
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	cfa080e7          	jalr	-774(ra) # 800036b0 <iupdate>
    ip->valid = 0;
    800039be:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039c2:	854a                	mv	a0,s2
    800039c4:	00001097          	auipc	ra,0x1
    800039c8:	aa4080e7          	jalr	-1372(ra) # 80004468 <releasesleep>
    acquire(&itable.lock);
    800039cc:	0001b517          	auipc	a0,0x1b
    800039d0:	6cc50513          	addi	a0,a0,1740 # 8001f098 <itable>
    800039d4:	ffffd097          	auipc	ra,0xffffd
    800039d8:	1fe080e7          	jalr	510(ra) # 80000bd2 <acquire>
    800039dc:	b741                	j	8000395c <iput+0x26>

00000000800039de <iunlockput>:
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	1000                	addi	s0,sp,32
    800039e8:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ea:	00000097          	auipc	ra,0x0
    800039ee:	e54080e7          	jalr	-428(ra) # 8000383e <iunlock>
  iput(ip);
    800039f2:	8526                	mv	a0,s1
    800039f4:	00000097          	auipc	ra,0x0
    800039f8:	f42080e7          	jalr	-190(ra) # 80003936 <iput>
}
    800039fc:	60e2                	ld	ra,24(sp)
    800039fe:	6442                	ld	s0,16(sp)
    80003a00:	64a2                	ld	s1,8(sp)
    80003a02:	6105                	addi	sp,sp,32
    80003a04:	8082                	ret

0000000080003a06 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a06:	1141                	addi	sp,sp,-16
    80003a08:	e422                	sd	s0,8(sp)
    80003a0a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a0c:	411c                	lw	a5,0(a0)
    80003a0e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a10:	415c                	lw	a5,4(a0)
    80003a12:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a14:	04451783          	lh	a5,68(a0)
    80003a18:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a1c:	04a51783          	lh	a5,74(a0)
    80003a20:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a24:	04c56783          	lwu	a5,76(a0)
    80003a28:	e99c                	sd	a5,16(a1)
}
    80003a2a:	6422                	ld	s0,8(sp)
    80003a2c:	0141                	addi	sp,sp,16
    80003a2e:	8082                	ret

0000000080003a30 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a30:	457c                	lw	a5,76(a0)
    80003a32:	0ed7e963          	bltu	a5,a3,80003b24 <readi+0xf4>
{
    80003a36:	7159                	addi	sp,sp,-112
    80003a38:	f486                	sd	ra,104(sp)
    80003a3a:	f0a2                	sd	s0,96(sp)
    80003a3c:	eca6                	sd	s1,88(sp)
    80003a3e:	e8ca                	sd	s2,80(sp)
    80003a40:	e4ce                	sd	s3,72(sp)
    80003a42:	e0d2                	sd	s4,64(sp)
    80003a44:	fc56                	sd	s5,56(sp)
    80003a46:	f85a                	sd	s6,48(sp)
    80003a48:	f45e                	sd	s7,40(sp)
    80003a4a:	f062                	sd	s8,32(sp)
    80003a4c:	ec66                	sd	s9,24(sp)
    80003a4e:	e86a                	sd	s10,16(sp)
    80003a50:	e46e                	sd	s11,8(sp)
    80003a52:	1880                	addi	s0,sp,112
    80003a54:	8b2a                	mv	s6,a0
    80003a56:	8bae                	mv	s7,a1
    80003a58:	8a32                	mv	s4,a2
    80003a5a:	84b6                	mv	s1,a3
    80003a5c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a5e:	9f35                	addw	a4,a4,a3
    return 0;
    80003a60:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a62:	0ad76063          	bltu	a4,a3,80003b02 <readi+0xd2>
  if(off + n > ip->size)
    80003a66:	00e7f463          	bgeu	a5,a4,80003a6e <readi+0x3e>
    n = ip->size - off;
    80003a6a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a6e:	0a0a8963          	beqz	s5,80003b20 <readi+0xf0>
    80003a72:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a74:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a78:	5c7d                	li	s8,-1
    80003a7a:	a82d                	j	80003ab4 <readi+0x84>
    80003a7c:	020d1d93          	slli	s11,s10,0x20
    80003a80:	020ddd93          	srli	s11,s11,0x20
    80003a84:	05890613          	addi	a2,s2,88
    80003a88:	86ee                	mv	a3,s11
    80003a8a:	963a                	add	a2,a2,a4
    80003a8c:	85d2                	mv	a1,s4
    80003a8e:	855e                	mv	a0,s7
    80003a90:	fffff097          	auipc	ra,0xfffff
    80003a94:	a34080e7          	jalr	-1484(ra) # 800024c4 <either_copyout>
    80003a98:	05850d63          	beq	a0,s8,80003af2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a9c:	854a                	mv	a0,s2
    80003a9e:	fffff097          	auipc	ra,0xfffff
    80003aa2:	5fe080e7          	jalr	1534(ra) # 8000309c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa6:	013d09bb          	addw	s3,s10,s3
    80003aaa:	009d04bb          	addw	s1,s10,s1
    80003aae:	9a6e                	add	s4,s4,s11
    80003ab0:	0559f763          	bgeu	s3,s5,80003afe <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ab4:	00a4d59b          	srliw	a1,s1,0xa
    80003ab8:	855a                	mv	a0,s6
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	8a4080e7          	jalr	-1884(ra) # 8000335e <bmap>
    80003ac2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ac6:	cd85                	beqz	a1,80003afe <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ac8:	000b2503          	lw	a0,0(s6)
    80003acc:	fffff097          	auipc	ra,0xfffff
    80003ad0:	4a0080e7          	jalr	1184(ra) # 80002f6c <bread>
    80003ad4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ad6:	3ff4f713          	andi	a4,s1,1023
    80003ada:	40ec87bb          	subw	a5,s9,a4
    80003ade:	413a86bb          	subw	a3,s5,s3
    80003ae2:	8d3e                	mv	s10,a5
    80003ae4:	2781                	sext.w	a5,a5
    80003ae6:	0006861b          	sext.w	a2,a3
    80003aea:	f8f679e3          	bgeu	a2,a5,80003a7c <readi+0x4c>
    80003aee:	8d36                	mv	s10,a3
    80003af0:	b771                	j	80003a7c <readi+0x4c>
      brelse(bp);
    80003af2:	854a                	mv	a0,s2
    80003af4:	fffff097          	auipc	ra,0xfffff
    80003af8:	5a8080e7          	jalr	1448(ra) # 8000309c <brelse>
      tot = -1;
    80003afc:	59fd                	li	s3,-1
  }
  return tot;
    80003afe:	0009851b          	sext.w	a0,s3
}
    80003b02:	70a6                	ld	ra,104(sp)
    80003b04:	7406                	ld	s0,96(sp)
    80003b06:	64e6                	ld	s1,88(sp)
    80003b08:	6946                	ld	s2,80(sp)
    80003b0a:	69a6                	ld	s3,72(sp)
    80003b0c:	6a06                	ld	s4,64(sp)
    80003b0e:	7ae2                	ld	s5,56(sp)
    80003b10:	7b42                	ld	s6,48(sp)
    80003b12:	7ba2                	ld	s7,40(sp)
    80003b14:	7c02                	ld	s8,32(sp)
    80003b16:	6ce2                	ld	s9,24(sp)
    80003b18:	6d42                	ld	s10,16(sp)
    80003b1a:	6da2                	ld	s11,8(sp)
    80003b1c:	6165                	addi	sp,sp,112
    80003b1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b20:	89d6                	mv	s3,s5
    80003b22:	bff1                	j	80003afe <readi+0xce>
    return 0;
    80003b24:	4501                	li	a0,0
}
    80003b26:	8082                	ret

0000000080003b28 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b28:	457c                	lw	a5,76(a0)
    80003b2a:	10d7e863          	bltu	a5,a3,80003c3a <writei+0x112>
{
    80003b2e:	7159                	addi	sp,sp,-112
    80003b30:	f486                	sd	ra,104(sp)
    80003b32:	f0a2                	sd	s0,96(sp)
    80003b34:	eca6                	sd	s1,88(sp)
    80003b36:	e8ca                	sd	s2,80(sp)
    80003b38:	e4ce                	sd	s3,72(sp)
    80003b3a:	e0d2                	sd	s4,64(sp)
    80003b3c:	fc56                	sd	s5,56(sp)
    80003b3e:	f85a                	sd	s6,48(sp)
    80003b40:	f45e                	sd	s7,40(sp)
    80003b42:	f062                	sd	s8,32(sp)
    80003b44:	ec66                	sd	s9,24(sp)
    80003b46:	e86a                	sd	s10,16(sp)
    80003b48:	e46e                	sd	s11,8(sp)
    80003b4a:	1880                	addi	s0,sp,112
    80003b4c:	8aaa                	mv	s5,a0
    80003b4e:	8bae                	mv	s7,a1
    80003b50:	8a32                	mv	s4,a2
    80003b52:	8936                	mv	s2,a3
    80003b54:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b56:	00e687bb          	addw	a5,a3,a4
    80003b5a:	0ed7e263          	bltu	a5,a3,80003c3e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b5e:	00043737          	lui	a4,0x43
    80003b62:	0ef76063          	bltu	a4,a5,80003c42 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b66:	0c0b0863          	beqz	s6,80003c36 <writei+0x10e>
    80003b6a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b70:	5c7d                	li	s8,-1
    80003b72:	a091                	j	80003bb6 <writei+0x8e>
    80003b74:	020d1d93          	slli	s11,s10,0x20
    80003b78:	020ddd93          	srli	s11,s11,0x20
    80003b7c:	05848513          	addi	a0,s1,88
    80003b80:	86ee                	mv	a3,s11
    80003b82:	8652                	mv	a2,s4
    80003b84:	85de                	mv	a1,s7
    80003b86:	953a                	add	a0,a0,a4
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	992080e7          	jalr	-1646(ra) # 8000251a <either_copyin>
    80003b90:	07850263          	beq	a0,s8,80003bf4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b94:	8526                	mv	a0,s1
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	75e080e7          	jalr	1886(ra) # 800042f4 <log_write>
    brelse(bp);
    80003b9e:	8526                	mv	a0,s1
    80003ba0:	fffff097          	auipc	ra,0xfffff
    80003ba4:	4fc080e7          	jalr	1276(ra) # 8000309c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ba8:	013d09bb          	addw	s3,s10,s3
    80003bac:	012d093b          	addw	s2,s10,s2
    80003bb0:	9a6e                	add	s4,s4,s11
    80003bb2:	0569f663          	bgeu	s3,s6,80003bfe <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bb6:	00a9559b          	srliw	a1,s2,0xa
    80003bba:	8556                	mv	a0,s5
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	7a2080e7          	jalr	1954(ra) # 8000335e <bmap>
    80003bc4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bc8:	c99d                	beqz	a1,80003bfe <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bca:	000aa503          	lw	a0,0(s5)
    80003bce:	fffff097          	auipc	ra,0xfffff
    80003bd2:	39e080e7          	jalr	926(ra) # 80002f6c <bread>
    80003bd6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd8:	3ff97713          	andi	a4,s2,1023
    80003bdc:	40ec87bb          	subw	a5,s9,a4
    80003be0:	413b06bb          	subw	a3,s6,s3
    80003be4:	8d3e                	mv	s10,a5
    80003be6:	2781                	sext.w	a5,a5
    80003be8:	0006861b          	sext.w	a2,a3
    80003bec:	f8f674e3          	bgeu	a2,a5,80003b74 <writei+0x4c>
    80003bf0:	8d36                	mv	s10,a3
    80003bf2:	b749                	j	80003b74 <writei+0x4c>
      brelse(bp);
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	4a6080e7          	jalr	1190(ra) # 8000309c <brelse>
  }

  if(off > ip->size)
    80003bfe:	04caa783          	lw	a5,76(s5)
    80003c02:	0127f463          	bgeu	a5,s2,80003c0a <writei+0xe2>
    ip->size = off;
    80003c06:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c0a:	8556                	mv	a0,s5
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	aa4080e7          	jalr	-1372(ra) # 800036b0 <iupdate>

  return tot;
    80003c14:	0009851b          	sext.w	a0,s3
}
    80003c18:	70a6                	ld	ra,104(sp)
    80003c1a:	7406                	ld	s0,96(sp)
    80003c1c:	64e6                	ld	s1,88(sp)
    80003c1e:	6946                	ld	s2,80(sp)
    80003c20:	69a6                	ld	s3,72(sp)
    80003c22:	6a06                	ld	s4,64(sp)
    80003c24:	7ae2                	ld	s5,56(sp)
    80003c26:	7b42                	ld	s6,48(sp)
    80003c28:	7ba2                	ld	s7,40(sp)
    80003c2a:	7c02                	ld	s8,32(sp)
    80003c2c:	6ce2                	ld	s9,24(sp)
    80003c2e:	6d42                	ld	s10,16(sp)
    80003c30:	6da2                	ld	s11,8(sp)
    80003c32:	6165                	addi	sp,sp,112
    80003c34:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c36:	89da                	mv	s3,s6
    80003c38:	bfc9                	j	80003c0a <writei+0xe2>
    return -1;
    80003c3a:	557d                	li	a0,-1
}
    80003c3c:	8082                	ret
    return -1;
    80003c3e:	557d                	li	a0,-1
    80003c40:	bfe1                	j	80003c18 <writei+0xf0>
    return -1;
    80003c42:	557d                	li	a0,-1
    80003c44:	bfd1                	j	80003c18 <writei+0xf0>

0000000080003c46 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c46:	1141                	addi	sp,sp,-16
    80003c48:	e406                	sd	ra,8(sp)
    80003c4a:	e022                	sd	s0,0(sp)
    80003c4c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c4e:	4639                	li	a2,14
    80003c50:	ffffd097          	auipc	ra,0xffffd
    80003c54:	14e080e7          	jalr	334(ra) # 80000d9e <strncmp>
}
    80003c58:	60a2                	ld	ra,8(sp)
    80003c5a:	6402                	ld	s0,0(sp)
    80003c5c:	0141                	addi	sp,sp,16
    80003c5e:	8082                	ret

0000000080003c60 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c60:	7139                	addi	sp,sp,-64
    80003c62:	fc06                	sd	ra,56(sp)
    80003c64:	f822                	sd	s0,48(sp)
    80003c66:	f426                	sd	s1,40(sp)
    80003c68:	f04a                	sd	s2,32(sp)
    80003c6a:	ec4e                	sd	s3,24(sp)
    80003c6c:	e852                	sd	s4,16(sp)
    80003c6e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c70:	04451703          	lh	a4,68(a0)
    80003c74:	4785                	li	a5,1
    80003c76:	00f71a63          	bne	a4,a5,80003c8a <dirlookup+0x2a>
    80003c7a:	892a                	mv	s2,a0
    80003c7c:	89ae                	mv	s3,a1
    80003c7e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c80:	457c                	lw	a5,76(a0)
    80003c82:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c84:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c86:	e79d                	bnez	a5,80003cb4 <dirlookup+0x54>
    80003c88:	a8a5                	j	80003d00 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c8a:	00005517          	auipc	a0,0x5
    80003c8e:	99650513          	addi	a0,a0,-1642 # 80008620 <syscalls+0x1d0>
    80003c92:	ffffd097          	auipc	ra,0xffffd
    80003c96:	8aa080e7          	jalr	-1878(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c9a:	00005517          	auipc	a0,0x5
    80003c9e:	99e50513          	addi	a0,a0,-1634 # 80008638 <syscalls+0x1e8>
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	89a080e7          	jalr	-1894(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003caa:	24c1                	addiw	s1,s1,16
    80003cac:	04c92783          	lw	a5,76(s2)
    80003cb0:	04f4f763          	bgeu	s1,a5,80003cfe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb4:	4741                	li	a4,16
    80003cb6:	86a6                	mv	a3,s1
    80003cb8:	fc040613          	addi	a2,s0,-64
    80003cbc:	4581                	li	a1,0
    80003cbe:	854a                	mv	a0,s2
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	d70080e7          	jalr	-656(ra) # 80003a30 <readi>
    80003cc8:	47c1                	li	a5,16
    80003cca:	fcf518e3          	bne	a0,a5,80003c9a <dirlookup+0x3a>
    if(de.inum == 0)
    80003cce:	fc045783          	lhu	a5,-64(s0)
    80003cd2:	dfe1                	beqz	a5,80003caa <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cd4:	fc240593          	addi	a1,s0,-62
    80003cd8:	854e                	mv	a0,s3
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	f6c080e7          	jalr	-148(ra) # 80003c46 <namecmp>
    80003ce2:	f561                	bnez	a0,80003caa <dirlookup+0x4a>
      if(poff)
    80003ce4:	000a0463          	beqz	s4,80003cec <dirlookup+0x8c>
        *poff = off;
    80003ce8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cec:	fc045583          	lhu	a1,-64(s0)
    80003cf0:	00092503          	lw	a0,0(s2)
    80003cf4:	fffff097          	auipc	ra,0xfffff
    80003cf8:	754080e7          	jalr	1876(ra) # 80003448 <iget>
    80003cfc:	a011                	j	80003d00 <dirlookup+0xa0>
  return 0;
    80003cfe:	4501                	li	a0,0
}
    80003d00:	70e2                	ld	ra,56(sp)
    80003d02:	7442                	ld	s0,48(sp)
    80003d04:	74a2                	ld	s1,40(sp)
    80003d06:	7902                	ld	s2,32(sp)
    80003d08:	69e2                	ld	s3,24(sp)
    80003d0a:	6a42                	ld	s4,16(sp)
    80003d0c:	6121                	addi	sp,sp,64
    80003d0e:	8082                	ret

0000000080003d10 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d10:	711d                	addi	sp,sp,-96
    80003d12:	ec86                	sd	ra,88(sp)
    80003d14:	e8a2                	sd	s0,80(sp)
    80003d16:	e4a6                	sd	s1,72(sp)
    80003d18:	e0ca                	sd	s2,64(sp)
    80003d1a:	fc4e                	sd	s3,56(sp)
    80003d1c:	f852                	sd	s4,48(sp)
    80003d1e:	f456                	sd	s5,40(sp)
    80003d20:	f05a                	sd	s6,32(sp)
    80003d22:	ec5e                	sd	s7,24(sp)
    80003d24:	e862                	sd	s8,16(sp)
    80003d26:	e466                	sd	s9,8(sp)
    80003d28:	1080                	addi	s0,sp,96
    80003d2a:	84aa                	mv	s1,a0
    80003d2c:	8b2e                	mv	s6,a1
    80003d2e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d30:	00054703          	lbu	a4,0(a0)
    80003d34:	02f00793          	li	a5,47
    80003d38:	02f70263          	beq	a4,a5,80003d5c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d3c:	ffffe097          	auipc	ra,0xffffe
    80003d40:	c6a080e7          	jalr	-918(ra) # 800019a6 <myproc>
    80003d44:	15053503          	ld	a0,336(a0)
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	9f6080e7          	jalr	-1546(ra) # 8000373e <idup>
    80003d50:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d52:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d56:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d58:	4b85                	li	s7,1
    80003d5a:	a875                	j	80003e16 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d5c:	4585                	li	a1,1
    80003d5e:	4505                	li	a0,1
    80003d60:	fffff097          	auipc	ra,0xfffff
    80003d64:	6e8080e7          	jalr	1768(ra) # 80003448 <iget>
    80003d68:	8a2a                	mv	s4,a0
    80003d6a:	b7e5                	j	80003d52 <namex+0x42>
      iunlockput(ip);
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	c70080e7          	jalr	-912(ra) # 800039de <iunlockput>
      return 0;
    80003d76:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d78:	8552                	mv	a0,s4
    80003d7a:	60e6                	ld	ra,88(sp)
    80003d7c:	6446                	ld	s0,80(sp)
    80003d7e:	64a6                	ld	s1,72(sp)
    80003d80:	6906                	ld	s2,64(sp)
    80003d82:	79e2                	ld	s3,56(sp)
    80003d84:	7a42                	ld	s4,48(sp)
    80003d86:	7aa2                	ld	s5,40(sp)
    80003d88:	7b02                	ld	s6,32(sp)
    80003d8a:	6be2                	ld	s7,24(sp)
    80003d8c:	6c42                	ld	s8,16(sp)
    80003d8e:	6ca2                	ld	s9,8(sp)
    80003d90:	6125                	addi	sp,sp,96
    80003d92:	8082                	ret
      iunlock(ip);
    80003d94:	8552                	mv	a0,s4
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	aa8080e7          	jalr	-1368(ra) # 8000383e <iunlock>
      return ip;
    80003d9e:	bfe9                	j	80003d78 <namex+0x68>
      iunlockput(ip);
    80003da0:	8552                	mv	a0,s4
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	c3c080e7          	jalr	-964(ra) # 800039de <iunlockput>
      return 0;
    80003daa:	8a4e                	mv	s4,s3
    80003dac:	b7f1                	j	80003d78 <namex+0x68>
  len = path - s;
    80003dae:	40998633          	sub	a2,s3,s1
    80003db2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003db6:	099c5863          	bge	s8,s9,80003e46 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dba:	4639                	li	a2,14
    80003dbc:	85a6                	mv	a1,s1
    80003dbe:	8556                	mv	a0,s5
    80003dc0:	ffffd097          	auipc	ra,0xffffd
    80003dc4:	f6a080e7          	jalr	-150(ra) # 80000d2a <memmove>
    80003dc8:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dca:	0004c783          	lbu	a5,0(s1)
    80003dce:	01279763          	bne	a5,s2,80003ddc <namex+0xcc>
    path++;
    80003dd2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dd4:	0004c783          	lbu	a5,0(s1)
    80003dd8:	ff278de3          	beq	a5,s2,80003dd2 <namex+0xc2>
    ilock(ip);
    80003ddc:	8552                	mv	a0,s4
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	99e080e7          	jalr	-1634(ra) # 8000377c <ilock>
    if(ip->type != T_DIR){
    80003de6:	044a1783          	lh	a5,68(s4)
    80003dea:	f97791e3          	bne	a5,s7,80003d6c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003dee:	000b0563          	beqz	s6,80003df8 <namex+0xe8>
    80003df2:	0004c783          	lbu	a5,0(s1)
    80003df6:	dfd9                	beqz	a5,80003d94 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003df8:	4601                	li	a2,0
    80003dfa:	85d6                	mv	a1,s5
    80003dfc:	8552                	mv	a0,s4
    80003dfe:	00000097          	auipc	ra,0x0
    80003e02:	e62080e7          	jalr	-414(ra) # 80003c60 <dirlookup>
    80003e06:	89aa                	mv	s3,a0
    80003e08:	dd41                	beqz	a0,80003da0 <namex+0x90>
    iunlockput(ip);
    80003e0a:	8552                	mv	a0,s4
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	bd2080e7          	jalr	-1070(ra) # 800039de <iunlockput>
    ip = next;
    80003e14:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	01279763          	bne	a5,s2,80003e28 <namex+0x118>
    path++;
    80003e1e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e20:	0004c783          	lbu	a5,0(s1)
    80003e24:	ff278de3          	beq	a5,s2,80003e1e <namex+0x10e>
  if(*path == 0)
    80003e28:	cb9d                	beqz	a5,80003e5e <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e2a:	0004c783          	lbu	a5,0(s1)
    80003e2e:	89a6                	mv	s3,s1
  len = path - s;
    80003e30:	4c81                	li	s9,0
    80003e32:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e34:	01278963          	beq	a5,s2,80003e46 <namex+0x136>
    80003e38:	dbbd                	beqz	a5,80003dae <namex+0x9e>
    path++;
    80003e3a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e3c:	0009c783          	lbu	a5,0(s3)
    80003e40:	ff279ce3          	bne	a5,s2,80003e38 <namex+0x128>
    80003e44:	b7ad                	j	80003dae <namex+0x9e>
    memmove(name, s, len);
    80003e46:	2601                	sext.w	a2,a2
    80003e48:	85a6                	mv	a1,s1
    80003e4a:	8556                	mv	a0,s5
    80003e4c:	ffffd097          	auipc	ra,0xffffd
    80003e50:	ede080e7          	jalr	-290(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e54:	9cd6                	add	s9,s9,s5
    80003e56:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e5a:	84ce                	mv	s1,s3
    80003e5c:	b7bd                	j	80003dca <namex+0xba>
  if(nameiparent){
    80003e5e:	f00b0de3          	beqz	s6,80003d78 <namex+0x68>
    iput(ip);
    80003e62:	8552                	mv	a0,s4
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	ad2080e7          	jalr	-1326(ra) # 80003936 <iput>
    return 0;
    80003e6c:	4a01                	li	s4,0
    80003e6e:	b729                	j	80003d78 <namex+0x68>

0000000080003e70 <dirlink>:
{
    80003e70:	7139                	addi	sp,sp,-64
    80003e72:	fc06                	sd	ra,56(sp)
    80003e74:	f822                	sd	s0,48(sp)
    80003e76:	f426                	sd	s1,40(sp)
    80003e78:	f04a                	sd	s2,32(sp)
    80003e7a:	ec4e                	sd	s3,24(sp)
    80003e7c:	e852                	sd	s4,16(sp)
    80003e7e:	0080                	addi	s0,sp,64
    80003e80:	892a                	mv	s2,a0
    80003e82:	8a2e                	mv	s4,a1
    80003e84:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e86:	4601                	li	a2,0
    80003e88:	00000097          	auipc	ra,0x0
    80003e8c:	dd8080e7          	jalr	-552(ra) # 80003c60 <dirlookup>
    80003e90:	e93d                	bnez	a0,80003f06 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e92:	04c92483          	lw	s1,76(s2)
    80003e96:	c49d                	beqz	s1,80003ec4 <dirlink+0x54>
    80003e98:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9a:	4741                	li	a4,16
    80003e9c:	86a6                	mv	a3,s1
    80003e9e:	fc040613          	addi	a2,s0,-64
    80003ea2:	4581                	li	a1,0
    80003ea4:	854a                	mv	a0,s2
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	b8a080e7          	jalr	-1142(ra) # 80003a30 <readi>
    80003eae:	47c1                	li	a5,16
    80003eb0:	06f51163          	bne	a0,a5,80003f12 <dirlink+0xa2>
    if(de.inum == 0)
    80003eb4:	fc045783          	lhu	a5,-64(s0)
    80003eb8:	c791                	beqz	a5,80003ec4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eba:	24c1                	addiw	s1,s1,16
    80003ebc:	04c92783          	lw	a5,76(s2)
    80003ec0:	fcf4ede3          	bltu	s1,a5,80003e9a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ec4:	4639                	li	a2,14
    80003ec6:	85d2                	mv	a1,s4
    80003ec8:	fc240513          	addi	a0,s0,-62
    80003ecc:	ffffd097          	auipc	ra,0xffffd
    80003ed0:	f0e080e7          	jalr	-242(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003ed4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed8:	4741                	li	a4,16
    80003eda:	86a6                	mv	a3,s1
    80003edc:	fc040613          	addi	a2,s0,-64
    80003ee0:	4581                	li	a1,0
    80003ee2:	854a                	mv	a0,s2
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	c44080e7          	jalr	-956(ra) # 80003b28 <writei>
    80003eec:	1541                	addi	a0,a0,-16
    80003eee:	00a03533          	snez	a0,a0
    80003ef2:	40a00533          	neg	a0,a0
}
    80003ef6:	70e2                	ld	ra,56(sp)
    80003ef8:	7442                	ld	s0,48(sp)
    80003efa:	74a2                	ld	s1,40(sp)
    80003efc:	7902                	ld	s2,32(sp)
    80003efe:	69e2                	ld	s3,24(sp)
    80003f00:	6a42                	ld	s4,16(sp)
    80003f02:	6121                	addi	sp,sp,64
    80003f04:	8082                	ret
    iput(ip);
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	a30080e7          	jalr	-1488(ra) # 80003936 <iput>
    return -1;
    80003f0e:	557d                	li	a0,-1
    80003f10:	b7dd                	j	80003ef6 <dirlink+0x86>
      panic("dirlink read");
    80003f12:	00004517          	auipc	a0,0x4
    80003f16:	73650513          	addi	a0,a0,1846 # 80008648 <syscalls+0x1f8>
    80003f1a:	ffffc097          	auipc	ra,0xffffc
    80003f1e:	622080e7          	jalr	1570(ra) # 8000053c <panic>

0000000080003f22 <namei>:

struct inode*
namei(char *path)
{
    80003f22:	1101                	addi	sp,sp,-32
    80003f24:	ec06                	sd	ra,24(sp)
    80003f26:	e822                	sd	s0,16(sp)
    80003f28:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f2a:	fe040613          	addi	a2,s0,-32
    80003f2e:	4581                	li	a1,0
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	de0080e7          	jalr	-544(ra) # 80003d10 <namex>
}
    80003f38:	60e2                	ld	ra,24(sp)
    80003f3a:	6442                	ld	s0,16(sp)
    80003f3c:	6105                	addi	sp,sp,32
    80003f3e:	8082                	ret

0000000080003f40 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f40:	1141                	addi	sp,sp,-16
    80003f42:	e406                	sd	ra,8(sp)
    80003f44:	e022                	sd	s0,0(sp)
    80003f46:	0800                	addi	s0,sp,16
    80003f48:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f4a:	4585                	li	a1,1
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	dc4080e7          	jalr	-572(ra) # 80003d10 <namex>
}
    80003f54:	60a2                	ld	ra,8(sp)
    80003f56:	6402                	ld	s0,0(sp)
    80003f58:	0141                	addi	sp,sp,16
    80003f5a:	8082                	ret

0000000080003f5c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f5c:	1101                	addi	sp,sp,-32
    80003f5e:	ec06                	sd	ra,24(sp)
    80003f60:	e822                	sd	s0,16(sp)
    80003f62:	e426                	sd	s1,8(sp)
    80003f64:	e04a                	sd	s2,0(sp)
    80003f66:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f68:	0001d917          	auipc	s2,0x1d
    80003f6c:	bd890913          	addi	s2,s2,-1064 # 80020b40 <log>
    80003f70:	01892583          	lw	a1,24(s2)
    80003f74:	02892503          	lw	a0,40(s2)
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	ff4080e7          	jalr	-12(ra) # 80002f6c <bread>
    80003f80:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f82:	02c92603          	lw	a2,44(s2)
    80003f86:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f88:	00c05f63          	blez	a2,80003fa6 <write_head+0x4a>
    80003f8c:	0001d717          	auipc	a4,0x1d
    80003f90:	be470713          	addi	a4,a4,-1052 # 80020b70 <log+0x30>
    80003f94:	87aa                	mv	a5,a0
    80003f96:	060a                	slli	a2,a2,0x2
    80003f98:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f9a:	4314                	lw	a3,0(a4)
    80003f9c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f9e:	0711                	addi	a4,a4,4
    80003fa0:	0791                	addi	a5,a5,4
    80003fa2:	fec79ce3          	bne	a5,a2,80003f9a <write_head+0x3e>
  }
  bwrite(buf);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	fffff097          	auipc	ra,0xfffff
    80003fac:	0b6080e7          	jalr	182(ra) # 8000305e <bwrite>
  brelse(buf);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	0ea080e7          	jalr	234(ra) # 8000309c <brelse>
}
    80003fba:	60e2                	ld	ra,24(sp)
    80003fbc:	6442                	ld	s0,16(sp)
    80003fbe:	64a2                	ld	s1,8(sp)
    80003fc0:	6902                	ld	s2,0(sp)
    80003fc2:	6105                	addi	sp,sp,32
    80003fc4:	8082                	ret

0000000080003fc6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc6:	0001d797          	auipc	a5,0x1d
    80003fca:	ba67a783          	lw	a5,-1114(a5) # 80020b6c <log+0x2c>
    80003fce:	0af05d63          	blez	a5,80004088 <install_trans+0xc2>
{
    80003fd2:	7139                	addi	sp,sp,-64
    80003fd4:	fc06                	sd	ra,56(sp)
    80003fd6:	f822                	sd	s0,48(sp)
    80003fd8:	f426                	sd	s1,40(sp)
    80003fda:	f04a                	sd	s2,32(sp)
    80003fdc:	ec4e                	sd	s3,24(sp)
    80003fde:	e852                	sd	s4,16(sp)
    80003fe0:	e456                	sd	s5,8(sp)
    80003fe2:	e05a                	sd	s6,0(sp)
    80003fe4:	0080                	addi	s0,sp,64
    80003fe6:	8b2a                	mv	s6,a0
    80003fe8:	0001da97          	auipc	s5,0x1d
    80003fec:	b88a8a93          	addi	s5,s5,-1144 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ff2:	0001d997          	auipc	s3,0x1d
    80003ff6:	b4e98993          	addi	s3,s3,-1202 # 80020b40 <log>
    80003ffa:	a00d                	j	8000401c <install_trans+0x56>
    brelse(lbuf);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	09e080e7          	jalr	158(ra) # 8000309c <brelse>
    brelse(dbuf);
    80004006:	8526                	mv	a0,s1
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	094080e7          	jalr	148(ra) # 8000309c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004010:	2a05                	addiw	s4,s4,1
    80004012:	0a91                	addi	s5,s5,4
    80004014:	02c9a783          	lw	a5,44(s3)
    80004018:	04fa5e63          	bge	s4,a5,80004074 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000401c:	0189a583          	lw	a1,24(s3)
    80004020:	014585bb          	addw	a1,a1,s4
    80004024:	2585                	addiw	a1,a1,1
    80004026:	0289a503          	lw	a0,40(s3)
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	f42080e7          	jalr	-190(ra) # 80002f6c <bread>
    80004032:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004034:	000aa583          	lw	a1,0(s5)
    80004038:	0289a503          	lw	a0,40(s3)
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	f30080e7          	jalr	-208(ra) # 80002f6c <bread>
    80004044:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004046:	40000613          	li	a2,1024
    8000404a:	05890593          	addi	a1,s2,88
    8000404e:	05850513          	addi	a0,a0,88
    80004052:	ffffd097          	auipc	ra,0xffffd
    80004056:	cd8080e7          	jalr	-808(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000405a:	8526                	mv	a0,s1
    8000405c:	fffff097          	auipc	ra,0xfffff
    80004060:	002080e7          	jalr	2(ra) # 8000305e <bwrite>
    if(recovering == 0)
    80004064:	f80b1ce3          	bnez	s6,80003ffc <install_trans+0x36>
      bunpin(dbuf);
    80004068:	8526                	mv	a0,s1
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	10a080e7          	jalr	266(ra) # 80003174 <bunpin>
    80004072:	b769                	j	80003ffc <install_trans+0x36>
}
    80004074:	70e2                	ld	ra,56(sp)
    80004076:	7442                	ld	s0,48(sp)
    80004078:	74a2                	ld	s1,40(sp)
    8000407a:	7902                	ld	s2,32(sp)
    8000407c:	69e2                	ld	s3,24(sp)
    8000407e:	6a42                	ld	s4,16(sp)
    80004080:	6aa2                	ld	s5,8(sp)
    80004082:	6b02                	ld	s6,0(sp)
    80004084:	6121                	addi	sp,sp,64
    80004086:	8082                	ret
    80004088:	8082                	ret

000000008000408a <initlog>:
{
    8000408a:	7179                	addi	sp,sp,-48
    8000408c:	f406                	sd	ra,40(sp)
    8000408e:	f022                	sd	s0,32(sp)
    80004090:	ec26                	sd	s1,24(sp)
    80004092:	e84a                	sd	s2,16(sp)
    80004094:	e44e                	sd	s3,8(sp)
    80004096:	1800                	addi	s0,sp,48
    80004098:	892a                	mv	s2,a0
    8000409a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000409c:	0001d497          	auipc	s1,0x1d
    800040a0:	aa448493          	addi	s1,s1,-1372 # 80020b40 <log>
    800040a4:	00004597          	auipc	a1,0x4
    800040a8:	5b458593          	addi	a1,a1,1460 # 80008658 <syscalls+0x208>
    800040ac:	8526                	mv	a0,s1
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	a94080e7          	jalr	-1388(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040b6:	0149a583          	lw	a1,20(s3)
    800040ba:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040bc:	0109a783          	lw	a5,16(s3)
    800040c0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040c2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040c6:	854a                	mv	a0,s2
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	ea4080e7          	jalr	-348(ra) # 80002f6c <bread>
  log.lh.n = lh->n;
    800040d0:	4d30                	lw	a2,88(a0)
    800040d2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040d4:	00c05f63          	blez	a2,800040f2 <initlog+0x68>
    800040d8:	87aa                	mv	a5,a0
    800040da:	0001d717          	auipc	a4,0x1d
    800040de:	a9670713          	addi	a4,a4,-1386 # 80020b70 <log+0x30>
    800040e2:	060a                	slli	a2,a2,0x2
    800040e4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040e6:	4ff4                	lw	a3,92(a5)
    800040e8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ea:	0791                	addi	a5,a5,4
    800040ec:	0711                	addi	a4,a4,4
    800040ee:	fec79ce3          	bne	a5,a2,800040e6 <initlog+0x5c>
  brelse(buf);
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	faa080e7          	jalr	-86(ra) # 8000309c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040fa:	4505                	li	a0,1
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	eca080e7          	jalr	-310(ra) # 80003fc6 <install_trans>
  log.lh.n = 0;
    80004104:	0001d797          	auipc	a5,0x1d
    80004108:	a607a423          	sw	zero,-1432(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	e50080e7          	jalr	-432(ra) # 80003f5c <write_head>
}
    80004114:	70a2                	ld	ra,40(sp)
    80004116:	7402                	ld	s0,32(sp)
    80004118:	64e2                	ld	s1,24(sp)
    8000411a:	6942                	ld	s2,16(sp)
    8000411c:	69a2                	ld	s3,8(sp)
    8000411e:	6145                	addi	sp,sp,48
    80004120:	8082                	ret

0000000080004122 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004122:	1101                	addi	sp,sp,-32
    80004124:	ec06                	sd	ra,24(sp)
    80004126:	e822                	sd	s0,16(sp)
    80004128:	e426                	sd	s1,8(sp)
    8000412a:	e04a                	sd	s2,0(sp)
    8000412c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000412e:	0001d517          	auipc	a0,0x1d
    80004132:	a1250513          	addi	a0,a0,-1518 # 80020b40 <log>
    80004136:	ffffd097          	auipc	ra,0xffffd
    8000413a:	a9c080e7          	jalr	-1380(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000413e:	0001d497          	auipc	s1,0x1d
    80004142:	a0248493          	addi	s1,s1,-1534 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004146:	4979                	li	s2,30
    80004148:	a039                	j	80004156 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000414a:	85a6                	mv	a1,s1
    8000414c:	8526                	mv	a0,s1
    8000414e:	ffffe097          	auipc	ra,0xffffe
    80004152:	f6e080e7          	jalr	-146(ra) # 800020bc <sleep>
    if(log.committing){
    80004156:	50dc                	lw	a5,36(s1)
    80004158:	fbed                	bnez	a5,8000414a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000415a:	5098                	lw	a4,32(s1)
    8000415c:	2705                	addiw	a4,a4,1
    8000415e:	0027179b          	slliw	a5,a4,0x2
    80004162:	9fb9                	addw	a5,a5,a4
    80004164:	0017979b          	slliw	a5,a5,0x1
    80004168:	54d4                	lw	a3,44(s1)
    8000416a:	9fb5                	addw	a5,a5,a3
    8000416c:	00f95963          	bge	s2,a5,8000417e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004170:	85a6                	mv	a1,s1
    80004172:	8526                	mv	a0,s1
    80004174:	ffffe097          	auipc	ra,0xffffe
    80004178:	f48080e7          	jalr	-184(ra) # 800020bc <sleep>
    8000417c:	bfe9                	j	80004156 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000417e:	0001d517          	auipc	a0,0x1d
    80004182:	9c250513          	addi	a0,a0,-1598 # 80020b40 <log>
    80004186:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	afe080e7          	jalr	-1282(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004190:	60e2                	ld	ra,24(sp)
    80004192:	6442                	ld	s0,16(sp)
    80004194:	64a2                	ld	s1,8(sp)
    80004196:	6902                	ld	s2,0(sp)
    80004198:	6105                	addi	sp,sp,32
    8000419a:	8082                	ret

000000008000419c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000419c:	7139                	addi	sp,sp,-64
    8000419e:	fc06                	sd	ra,56(sp)
    800041a0:	f822                	sd	s0,48(sp)
    800041a2:	f426                	sd	s1,40(sp)
    800041a4:	f04a                	sd	s2,32(sp)
    800041a6:	ec4e                	sd	s3,24(sp)
    800041a8:	e852                	sd	s4,16(sp)
    800041aa:	e456                	sd	s5,8(sp)
    800041ac:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041ae:	0001d497          	auipc	s1,0x1d
    800041b2:	99248493          	addi	s1,s1,-1646 # 80020b40 <log>
    800041b6:	8526                	mv	a0,s1
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	a1a080e7          	jalr	-1510(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041c0:	509c                	lw	a5,32(s1)
    800041c2:	37fd                	addiw	a5,a5,-1
    800041c4:	0007891b          	sext.w	s2,a5
    800041c8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041ca:	50dc                	lw	a5,36(s1)
    800041cc:	e7b9                	bnez	a5,8000421a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041ce:	04091e63          	bnez	s2,8000422a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041d2:	0001d497          	auipc	s1,0x1d
    800041d6:	96e48493          	addi	s1,s1,-1682 # 80020b40 <log>
    800041da:	4785                	li	a5,1
    800041dc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041de:	8526                	mv	a0,s1
    800041e0:	ffffd097          	auipc	ra,0xffffd
    800041e4:	aa6080e7          	jalr	-1370(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041e8:	54dc                	lw	a5,44(s1)
    800041ea:	06f04763          	bgtz	a5,80004258 <end_op+0xbc>
    acquire(&log.lock);
    800041ee:	0001d497          	auipc	s1,0x1d
    800041f2:	95248493          	addi	s1,s1,-1710 # 80020b40 <log>
    800041f6:	8526                	mv	a0,s1
    800041f8:	ffffd097          	auipc	ra,0xffffd
    800041fc:	9da080e7          	jalr	-1574(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004200:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004204:	8526                	mv	a0,s1
    80004206:	ffffe097          	auipc	ra,0xffffe
    8000420a:	f1a080e7          	jalr	-230(ra) # 80002120 <wakeup>
    release(&log.lock);
    8000420e:	8526                	mv	a0,s1
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	a76080e7          	jalr	-1418(ra) # 80000c86 <release>
}
    80004218:	a03d                	j	80004246 <end_op+0xaa>
    panic("log.committing");
    8000421a:	00004517          	auipc	a0,0x4
    8000421e:	44650513          	addi	a0,a0,1094 # 80008660 <syscalls+0x210>
    80004222:	ffffc097          	auipc	ra,0xffffc
    80004226:	31a080e7          	jalr	794(ra) # 8000053c <panic>
    wakeup(&log);
    8000422a:	0001d497          	auipc	s1,0x1d
    8000422e:	91648493          	addi	s1,s1,-1770 # 80020b40 <log>
    80004232:	8526                	mv	a0,s1
    80004234:	ffffe097          	auipc	ra,0xffffe
    80004238:	eec080e7          	jalr	-276(ra) # 80002120 <wakeup>
  release(&log.lock);
    8000423c:	8526                	mv	a0,s1
    8000423e:	ffffd097          	auipc	ra,0xffffd
    80004242:	a48080e7          	jalr	-1464(ra) # 80000c86 <release>
}
    80004246:	70e2                	ld	ra,56(sp)
    80004248:	7442                	ld	s0,48(sp)
    8000424a:	74a2                	ld	s1,40(sp)
    8000424c:	7902                	ld	s2,32(sp)
    8000424e:	69e2                	ld	s3,24(sp)
    80004250:	6a42                	ld	s4,16(sp)
    80004252:	6aa2                	ld	s5,8(sp)
    80004254:	6121                	addi	sp,sp,64
    80004256:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004258:	0001da97          	auipc	s5,0x1d
    8000425c:	918a8a93          	addi	s5,s5,-1768 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004260:	0001da17          	auipc	s4,0x1d
    80004264:	8e0a0a13          	addi	s4,s4,-1824 # 80020b40 <log>
    80004268:	018a2583          	lw	a1,24(s4)
    8000426c:	012585bb          	addw	a1,a1,s2
    80004270:	2585                	addiw	a1,a1,1
    80004272:	028a2503          	lw	a0,40(s4)
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	cf6080e7          	jalr	-778(ra) # 80002f6c <bread>
    8000427e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004280:	000aa583          	lw	a1,0(s5)
    80004284:	028a2503          	lw	a0,40(s4)
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	ce4080e7          	jalr	-796(ra) # 80002f6c <bread>
    80004290:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004292:	40000613          	li	a2,1024
    80004296:	05850593          	addi	a1,a0,88
    8000429a:	05848513          	addi	a0,s1,88
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	a8c080e7          	jalr	-1396(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800042a6:	8526                	mv	a0,s1
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	db6080e7          	jalr	-586(ra) # 8000305e <bwrite>
    brelse(from);
    800042b0:	854e                	mv	a0,s3
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	dea080e7          	jalr	-534(ra) # 8000309c <brelse>
    brelse(to);
    800042ba:	8526                	mv	a0,s1
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	de0080e7          	jalr	-544(ra) # 8000309c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c4:	2905                	addiw	s2,s2,1
    800042c6:	0a91                	addi	s5,s5,4
    800042c8:	02ca2783          	lw	a5,44(s4)
    800042cc:	f8f94ee3          	blt	s2,a5,80004268 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	c8c080e7          	jalr	-884(ra) # 80003f5c <write_head>
    install_trans(0); // Now install writes to home locations
    800042d8:	4501                	li	a0,0
    800042da:	00000097          	auipc	ra,0x0
    800042de:	cec080e7          	jalr	-788(ra) # 80003fc6 <install_trans>
    log.lh.n = 0;
    800042e2:	0001d797          	auipc	a5,0x1d
    800042e6:	8807a523          	sw	zero,-1910(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ea:	00000097          	auipc	ra,0x0
    800042ee:	c72080e7          	jalr	-910(ra) # 80003f5c <write_head>
    800042f2:	bdf5                	j	800041ee <end_op+0x52>

00000000800042f4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f4:	1101                	addi	sp,sp,-32
    800042f6:	ec06                	sd	ra,24(sp)
    800042f8:	e822                	sd	s0,16(sp)
    800042fa:	e426                	sd	s1,8(sp)
    800042fc:	e04a                	sd	s2,0(sp)
    800042fe:	1000                	addi	s0,sp,32
    80004300:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004302:	0001d917          	auipc	s2,0x1d
    80004306:	83e90913          	addi	s2,s2,-1986 # 80020b40 <log>
    8000430a:	854a                	mv	a0,s2
    8000430c:	ffffd097          	auipc	ra,0xffffd
    80004310:	8c6080e7          	jalr	-1850(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004314:	02c92603          	lw	a2,44(s2)
    80004318:	47f5                	li	a5,29
    8000431a:	06c7c563          	blt	a5,a2,80004384 <log_write+0x90>
    8000431e:	0001d797          	auipc	a5,0x1d
    80004322:	83e7a783          	lw	a5,-1986(a5) # 80020b5c <log+0x1c>
    80004326:	37fd                	addiw	a5,a5,-1
    80004328:	04f65e63          	bge	a2,a5,80004384 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000432c:	0001d797          	auipc	a5,0x1d
    80004330:	8347a783          	lw	a5,-1996(a5) # 80020b60 <log+0x20>
    80004334:	06f05063          	blez	a5,80004394 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004338:	4781                	li	a5,0
    8000433a:	06c05563          	blez	a2,800043a4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000433e:	44cc                	lw	a1,12(s1)
    80004340:	0001d717          	auipc	a4,0x1d
    80004344:	83070713          	addi	a4,a4,-2000 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004348:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000434a:	4314                	lw	a3,0(a4)
    8000434c:	04b68c63          	beq	a3,a1,800043a4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004350:	2785                	addiw	a5,a5,1
    80004352:	0711                	addi	a4,a4,4
    80004354:	fef61be3          	bne	a2,a5,8000434a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004358:	0621                	addi	a2,a2,8
    8000435a:	060a                	slli	a2,a2,0x2
    8000435c:	0001c797          	auipc	a5,0x1c
    80004360:	7e478793          	addi	a5,a5,2020 # 80020b40 <log>
    80004364:	97b2                	add	a5,a5,a2
    80004366:	44d8                	lw	a4,12(s1)
    80004368:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000436a:	8526                	mv	a0,s1
    8000436c:	fffff097          	auipc	ra,0xfffff
    80004370:	dcc080e7          	jalr	-564(ra) # 80003138 <bpin>
    log.lh.n++;
    80004374:	0001c717          	auipc	a4,0x1c
    80004378:	7cc70713          	addi	a4,a4,1996 # 80020b40 <log>
    8000437c:	575c                	lw	a5,44(a4)
    8000437e:	2785                	addiw	a5,a5,1
    80004380:	d75c                	sw	a5,44(a4)
    80004382:	a82d                	j	800043bc <log_write+0xc8>
    panic("too big a transaction");
    80004384:	00004517          	auipc	a0,0x4
    80004388:	2ec50513          	addi	a0,a0,748 # 80008670 <syscalls+0x220>
    8000438c:	ffffc097          	auipc	ra,0xffffc
    80004390:	1b0080e7          	jalr	432(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004394:	00004517          	auipc	a0,0x4
    80004398:	2f450513          	addi	a0,a0,756 # 80008688 <syscalls+0x238>
    8000439c:	ffffc097          	auipc	ra,0xffffc
    800043a0:	1a0080e7          	jalr	416(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043a4:	00878693          	addi	a3,a5,8
    800043a8:	068a                	slli	a3,a3,0x2
    800043aa:	0001c717          	auipc	a4,0x1c
    800043ae:	79670713          	addi	a4,a4,1942 # 80020b40 <log>
    800043b2:	9736                	add	a4,a4,a3
    800043b4:	44d4                	lw	a3,12(s1)
    800043b6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043b8:	faf609e3          	beq	a2,a5,8000436a <log_write+0x76>
  }
  release(&log.lock);
    800043bc:	0001c517          	auipc	a0,0x1c
    800043c0:	78450513          	addi	a0,a0,1924 # 80020b40 <log>
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	8c2080e7          	jalr	-1854(ra) # 80000c86 <release>
}
    800043cc:	60e2                	ld	ra,24(sp)
    800043ce:	6442                	ld	s0,16(sp)
    800043d0:	64a2                	ld	s1,8(sp)
    800043d2:	6902                	ld	s2,0(sp)
    800043d4:	6105                	addi	sp,sp,32
    800043d6:	8082                	ret

00000000800043d8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043d8:	1101                	addi	sp,sp,-32
    800043da:	ec06                	sd	ra,24(sp)
    800043dc:	e822                	sd	s0,16(sp)
    800043de:	e426                	sd	s1,8(sp)
    800043e0:	e04a                	sd	s2,0(sp)
    800043e2:	1000                	addi	s0,sp,32
    800043e4:	84aa                	mv	s1,a0
    800043e6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043e8:	00004597          	auipc	a1,0x4
    800043ec:	2c058593          	addi	a1,a1,704 # 800086a8 <syscalls+0x258>
    800043f0:	0521                	addi	a0,a0,8
    800043f2:	ffffc097          	auipc	ra,0xffffc
    800043f6:	750080e7          	jalr	1872(ra) # 80000b42 <initlock>
  lk->name = name;
    800043fa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004402:	0204a423          	sw	zero,40(s1)
}
    80004406:	60e2                	ld	ra,24(sp)
    80004408:	6442                	ld	s0,16(sp)
    8000440a:	64a2                	ld	s1,8(sp)
    8000440c:	6902                	ld	s2,0(sp)
    8000440e:	6105                	addi	sp,sp,32
    80004410:	8082                	ret

0000000080004412 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004412:	1101                	addi	sp,sp,-32
    80004414:	ec06                	sd	ra,24(sp)
    80004416:	e822                	sd	s0,16(sp)
    80004418:	e426                	sd	s1,8(sp)
    8000441a:	e04a                	sd	s2,0(sp)
    8000441c:	1000                	addi	s0,sp,32
    8000441e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004420:	00850913          	addi	s2,a0,8
    80004424:	854a                	mv	a0,s2
    80004426:	ffffc097          	auipc	ra,0xffffc
    8000442a:	7ac080e7          	jalr	1964(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000442e:	409c                	lw	a5,0(s1)
    80004430:	cb89                	beqz	a5,80004442 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004432:	85ca                	mv	a1,s2
    80004434:	8526                	mv	a0,s1
    80004436:	ffffe097          	auipc	ra,0xffffe
    8000443a:	c86080e7          	jalr	-890(ra) # 800020bc <sleep>
  while (lk->locked) {
    8000443e:	409c                	lw	a5,0(s1)
    80004440:	fbed                	bnez	a5,80004432 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004442:	4785                	li	a5,1
    80004444:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004446:	ffffd097          	auipc	ra,0xffffd
    8000444a:	560080e7          	jalr	1376(ra) # 800019a6 <myproc>
    8000444e:	591c                	lw	a5,48(a0)
    80004450:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004452:	854a                	mv	a0,s2
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	832080e7          	jalr	-1998(ra) # 80000c86 <release>
}
    8000445c:	60e2                	ld	ra,24(sp)
    8000445e:	6442                	ld	s0,16(sp)
    80004460:	64a2                	ld	s1,8(sp)
    80004462:	6902                	ld	s2,0(sp)
    80004464:	6105                	addi	sp,sp,32
    80004466:	8082                	ret

0000000080004468 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004468:	1101                	addi	sp,sp,-32
    8000446a:	ec06                	sd	ra,24(sp)
    8000446c:	e822                	sd	s0,16(sp)
    8000446e:	e426                	sd	s1,8(sp)
    80004470:	e04a                	sd	s2,0(sp)
    80004472:	1000                	addi	s0,sp,32
    80004474:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004476:	00850913          	addi	s2,a0,8
    8000447a:	854a                	mv	a0,s2
    8000447c:	ffffc097          	auipc	ra,0xffffc
    80004480:	756080e7          	jalr	1878(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004484:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004488:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000448c:	8526                	mv	a0,s1
    8000448e:	ffffe097          	auipc	ra,0xffffe
    80004492:	c92080e7          	jalr	-878(ra) # 80002120 <wakeup>
  release(&lk->lk);
    80004496:	854a                	mv	a0,s2
    80004498:	ffffc097          	auipc	ra,0xffffc
    8000449c:	7ee080e7          	jalr	2030(ra) # 80000c86 <release>
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	64a2                	ld	s1,8(sp)
    800044a6:	6902                	ld	s2,0(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044ac:	7179                	addi	sp,sp,-48
    800044ae:	f406                	sd	ra,40(sp)
    800044b0:	f022                	sd	s0,32(sp)
    800044b2:	ec26                	sd	s1,24(sp)
    800044b4:	e84a                	sd	s2,16(sp)
    800044b6:	e44e                	sd	s3,8(sp)
    800044b8:	1800                	addi	s0,sp,48
    800044ba:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044bc:	00850913          	addi	s2,a0,8
    800044c0:	854a                	mv	a0,s2
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	710080e7          	jalr	1808(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ca:	409c                	lw	a5,0(s1)
    800044cc:	ef99                	bnez	a5,800044ea <holdingsleep+0x3e>
    800044ce:	4481                	li	s1,0
  release(&lk->lk);
    800044d0:	854a                	mv	a0,s2
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	7b4080e7          	jalr	1972(ra) # 80000c86 <release>
  return r;
}
    800044da:	8526                	mv	a0,s1
    800044dc:	70a2                	ld	ra,40(sp)
    800044de:	7402                	ld	s0,32(sp)
    800044e0:	64e2                	ld	s1,24(sp)
    800044e2:	6942                	ld	s2,16(sp)
    800044e4:	69a2                	ld	s3,8(sp)
    800044e6:	6145                	addi	sp,sp,48
    800044e8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ea:	0284a983          	lw	s3,40(s1)
    800044ee:	ffffd097          	auipc	ra,0xffffd
    800044f2:	4b8080e7          	jalr	1208(ra) # 800019a6 <myproc>
    800044f6:	5904                	lw	s1,48(a0)
    800044f8:	413484b3          	sub	s1,s1,s3
    800044fc:	0014b493          	seqz	s1,s1
    80004500:	bfc1                	j	800044d0 <holdingsleep+0x24>

0000000080004502 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004502:	1141                	addi	sp,sp,-16
    80004504:	e406                	sd	ra,8(sp)
    80004506:	e022                	sd	s0,0(sp)
    80004508:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000450a:	00004597          	auipc	a1,0x4
    8000450e:	1ae58593          	addi	a1,a1,430 # 800086b8 <syscalls+0x268>
    80004512:	0001c517          	auipc	a0,0x1c
    80004516:	77650513          	addi	a0,a0,1910 # 80020c88 <ftable>
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	628080e7          	jalr	1576(ra) # 80000b42 <initlock>
}
    80004522:	60a2                	ld	ra,8(sp)
    80004524:	6402                	ld	s0,0(sp)
    80004526:	0141                	addi	sp,sp,16
    80004528:	8082                	ret

000000008000452a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000452a:	1101                	addi	sp,sp,-32
    8000452c:	ec06                	sd	ra,24(sp)
    8000452e:	e822                	sd	s0,16(sp)
    80004530:	e426                	sd	s1,8(sp)
    80004532:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004534:	0001c517          	auipc	a0,0x1c
    80004538:	75450513          	addi	a0,a0,1876 # 80020c88 <ftable>
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	696080e7          	jalr	1686(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004544:	0001c497          	auipc	s1,0x1c
    80004548:	75c48493          	addi	s1,s1,1884 # 80020ca0 <ftable+0x18>
    8000454c:	0001d717          	auipc	a4,0x1d
    80004550:	6f470713          	addi	a4,a4,1780 # 80021c40 <disk>
    if(f->ref == 0){
    80004554:	40dc                	lw	a5,4(s1)
    80004556:	cf99                	beqz	a5,80004574 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004558:	02848493          	addi	s1,s1,40
    8000455c:	fee49ce3          	bne	s1,a4,80004554 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004560:	0001c517          	auipc	a0,0x1c
    80004564:	72850513          	addi	a0,a0,1832 # 80020c88 <ftable>
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	71e080e7          	jalr	1822(ra) # 80000c86 <release>
  return 0;
    80004570:	4481                	li	s1,0
    80004572:	a819                	j	80004588 <filealloc+0x5e>
      f->ref = 1;
    80004574:	4785                	li	a5,1
    80004576:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004578:	0001c517          	auipc	a0,0x1c
    8000457c:	71050513          	addi	a0,a0,1808 # 80020c88 <ftable>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	706080e7          	jalr	1798(ra) # 80000c86 <release>
}
    80004588:	8526                	mv	a0,s1
    8000458a:	60e2                	ld	ra,24(sp)
    8000458c:	6442                	ld	s0,16(sp)
    8000458e:	64a2                	ld	s1,8(sp)
    80004590:	6105                	addi	sp,sp,32
    80004592:	8082                	ret

0000000080004594 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004594:	1101                	addi	sp,sp,-32
    80004596:	ec06                	sd	ra,24(sp)
    80004598:	e822                	sd	s0,16(sp)
    8000459a:	e426                	sd	s1,8(sp)
    8000459c:	1000                	addi	s0,sp,32
    8000459e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045a0:	0001c517          	auipc	a0,0x1c
    800045a4:	6e850513          	addi	a0,a0,1768 # 80020c88 <ftable>
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	62a080e7          	jalr	1578(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045b0:	40dc                	lw	a5,4(s1)
    800045b2:	02f05263          	blez	a5,800045d6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045b6:	2785                	addiw	a5,a5,1
    800045b8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045ba:	0001c517          	auipc	a0,0x1c
    800045be:	6ce50513          	addi	a0,a0,1742 # 80020c88 <ftable>
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	6c4080e7          	jalr	1732(ra) # 80000c86 <release>
  return f;
}
    800045ca:	8526                	mv	a0,s1
    800045cc:	60e2                	ld	ra,24(sp)
    800045ce:	6442                	ld	s0,16(sp)
    800045d0:	64a2                	ld	s1,8(sp)
    800045d2:	6105                	addi	sp,sp,32
    800045d4:	8082                	ret
    panic("filedup");
    800045d6:	00004517          	auipc	a0,0x4
    800045da:	0ea50513          	addi	a0,a0,234 # 800086c0 <syscalls+0x270>
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	f5e080e7          	jalr	-162(ra) # 8000053c <panic>

00000000800045e6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045e6:	7139                	addi	sp,sp,-64
    800045e8:	fc06                	sd	ra,56(sp)
    800045ea:	f822                	sd	s0,48(sp)
    800045ec:	f426                	sd	s1,40(sp)
    800045ee:	f04a                	sd	s2,32(sp)
    800045f0:	ec4e                	sd	s3,24(sp)
    800045f2:	e852                	sd	s4,16(sp)
    800045f4:	e456                	sd	s5,8(sp)
    800045f6:	0080                	addi	s0,sp,64
    800045f8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045fa:	0001c517          	auipc	a0,0x1c
    800045fe:	68e50513          	addi	a0,a0,1678 # 80020c88 <ftable>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	5d0080e7          	jalr	1488(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000460a:	40dc                	lw	a5,4(s1)
    8000460c:	06f05163          	blez	a5,8000466e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004610:	37fd                	addiw	a5,a5,-1
    80004612:	0007871b          	sext.w	a4,a5
    80004616:	c0dc                	sw	a5,4(s1)
    80004618:	06e04363          	bgtz	a4,8000467e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000461c:	0004a903          	lw	s2,0(s1)
    80004620:	0094ca83          	lbu	s5,9(s1)
    80004624:	0104ba03          	ld	s4,16(s1)
    80004628:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000462c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004630:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004634:	0001c517          	auipc	a0,0x1c
    80004638:	65450513          	addi	a0,a0,1620 # 80020c88 <ftable>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	64a080e7          	jalr	1610(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004644:	4785                	li	a5,1
    80004646:	04f90d63          	beq	s2,a5,800046a0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000464a:	3979                	addiw	s2,s2,-2
    8000464c:	4785                	li	a5,1
    8000464e:	0527e063          	bltu	a5,s2,8000468e <fileclose+0xa8>
    begin_op();
    80004652:	00000097          	auipc	ra,0x0
    80004656:	ad0080e7          	jalr	-1328(ra) # 80004122 <begin_op>
    iput(ff.ip);
    8000465a:	854e                	mv	a0,s3
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	2da080e7          	jalr	730(ra) # 80003936 <iput>
    end_op();
    80004664:	00000097          	auipc	ra,0x0
    80004668:	b38080e7          	jalr	-1224(ra) # 8000419c <end_op>
    8000466c:	a00d                	j	8000468e <fileclose+0xa8>
    panic("fileclose");
    8000466e:	00004517          	auipc	a0,0x4
    80004672:	05a50513          	addi	a0,a0,90 # 800086c8 <syscalls+0x278>
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	ec6080e7          	jalr	-314(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000467e:	0001c517          	auipc	a0,0x1c
    80004682:	60a50513          	addi	a0,a0,1546 # 80020c88 <ftable>
    80004686:	ffffc097          	auipc	ra,0xffffc
    8000468a:	600080e7          	jalr	1536(ra) # 80000c86 <release>
  }
}
    8000468e:	70e2                	ld	ra,56(sp)
    80004690:	7442                	ld	s0,48(sp)
    80004692:	74a2                	ld	s1,40(sp)
    80004694:	7902                	ld	s2,32(sp)
    80004696:	69e2                	ld	s3,24(sp)
    80004698:	6a42                	ld	s4,16(sp)
    8000469a:	6aa2                	ld	s5,8(sp)
    8000469c:	6121                	addi	sp,sp,64
    8000469e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046a0:	85d6                	mv	a1,s5
    800046a2:	8552                	mv	a0,s4
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	348080e7          	jalr	840(ra) # 800049ec <pipeclose>
    800046ac:	b7cd                	j	8000468e <fileclose+0xa8>

00000000800046ae <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046ae:	715d                	addi	sp,sp,-80
    800046b0:	e486                	sd	ra,72(sp)
    800046b2:	e0a2                	sd	s0,64(sp)
    800046b4:	fc26                	sd	s1,56(sp)
    800046b6:	f84a                	sd	s2,48(sp)
    800046b8:	f44e                	sd	s3,40(sp)
    800046ba:	0880                	addi	s0,sp,80
    800046bc:	84aa                	mv	s1,a0
    800046be:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046c0:	ffffd097          	auipc	ra,0xffffd
    800046c4:	2e6080e7          	jalr	742(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046c8:	409c                	lw	a5,0(s1)
    800046ca:	37f9                	addiw	a5,a5,-2
    800046cc:	4705                	li	a4,1
    800046ce:	04f76763          	bltu	a4,a5,8000471c <filestat+0x6e>
    800046d2:	892a                	mv	s2,a0
    ilock(f->ip);
    800046d4:	6c88                	ld	a0,24(s1)
    800046d6:	fffff097          	auipc	ra,0xfffff
    800046da:	0a6080e7          	jalr	166(ra) # 8000377c <ilock>
    stati(f->ip, &st);
    800046de:	fb840593          	addi	a1,s0,-72
    800046e2:	6c88                	ld	a0,24(s1)
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	322080e7          	jalr	802(ra) # 80003a06 <stati>
    iunlock(f->ip);
    800046ec:	6c88                	ld	a0,24(s1)
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	150080e7          	jalr	336(ra) # 8000383e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046f6:	46e1                	li	a3,24
    800046f8:	fb840613          	addi	a2,s0,-72
    800046fc:	85ce                	mv	a1,s3
    800046fe:	05093503          	ld	a0,80(s2)
    80004702:	ffffd097          	auipc	ra,0xffffd
    80004706:	f64080e7          	jalr	-156(ra) # 80001666 <copyout>
    8000470a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000470e:	60a6                	ld	ra,72(sp)
    80004710:	6406                	ld	s0,64(sp)
    80004712:	74e2                	ld	s1,56(sp)
    80004714:	7942                	ld	s2,48(sp)
    80004716:	79a2                	ld	s3,40(sp)
    80004718:	6161                	addi	sp,sp,80
    8000471a:	8082                	ret
  return -1;
    8000471c:	557d                	li	a0,-1
    8000471e:	bfc5                	j	8000470e <filestat+0x60>

0000000080004720 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004720:	7179                	addi	sp,sp,-48
    80004722:	f406                	sd	ra,40(sp)
    80004724:	f022                	sd	s0,32(sp)
    80004726:	ec26                	sd	s1,24(sp)
    80004728:	e84a                	sd	s2,16(sp)
    8000472a:	e44e                	sd	s3,8(sp)
    8000472c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000472e:	00854783          	lbu	a5,8(a0)
    80004732:	c3d5                	beqz	a5,800047d6 <fileread+0xb6>
    80004734:	84aa                	mv	s1,a0
    80004736:	89ae                	mv	s3,a1
    80004738:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000473a:	411c                	lw	a5,0(a0)
    8000473c:	4705                	li	a4,1
    8000473e:	04e78963          	beq	a5,a4,80004790 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004742:	470d                	li	a4,3
    80004744:	04e78d63          	beq	a5,a4,8000479e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004748:	4709                	li	a4,2
    8000474a:	06e79e63          	bne	a5,a4,800047c6 <fileread+0xa6>
    ilock(f->ip);
    8000474e:	6d08                	ld	a0,24(a0)
    80004750:	fffff097          	auipc	ra,0xfffff
    80004754:	02c080e7          	jalr	44(ra) # 8000377c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004758:	874a                	mv	a4,s2
    8000475a:	5094                	lw	a3,32(s1)
    8000475c:	864e                	mv	a2,s3
    8000475e:	4585                	li	a1,1
    80004760:	6c88                	ld	a0,24(s1)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	2ce080e7          	jalr	718(ra) # 80003a30 <readi>
    8000476a:	892a                	mv	s2,a0
    8000476c:	00a05563          	blez	a0,80004776 <fileread+0x56>
      f->off += r;
    80004770:	509c                	lw	a5,32(s1)
    80004772:	9fa9                	addw	a5,a5,a0
    80004774:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004776:	6c88                	ld	a0,24(s1)
    80004778:	fffff097          	auipc	ra,0xfffff
    8000477c:	0c6080e7          	jalr	198(ra) # 8000383e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004780:	854a                	mv	a0,s2
    80004782:	70a2                	ld	ra,40(sp)
    80004784:	7402                	ld	s0,32(sp)
    80004786:	64e2                	ld	s1,24(sp)
    80004788:	6942                	ld	s2,16(sp)
    8000478a:	69a2                	ld	s3,8(sp)
    8000478c:	6145                	addi	sp,sp,48
    8000478e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004790:	6908                	ld	a0,16(a0)
    80004792:	00000097          	auipc	ra,0x0
    80004796:	3c2080e7          	jalr	962(ra) # 80004b54 <piperead>
    8000479a:	892a                	mv	s2,a0
    8000479c:	b7d5                	j	80004780 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000479e:	02451783          	lh	a5,36(a0)
    800047a2:	03079693          	slli	a3,a5,0x30
    800047a6:	92c1                	srli	a3,a3,0x30
    800047a8:	4725                	li	a4,9
    800047aa:	02d76863          	bltu	a4,a3,800047da <fileread+0xba>
    800047ae:	0792                	slli	a5,a5,0x4
    800047b0:	0001c717          	auipc	a4,0x1c
    800047b4:	43870713          	addi	a4,a4,1080 # 80020be8 <devsw>
    800047b8:	97ba                	add	a5,a5,a4
    800047ba:	639c                	ld	a5,0(a5)
    800047bc:	c38d                	beqz	a5,800047de <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047be:	4505                	li	a0,1
    800047c0:	9782                	jalr	a5
    800047c2:	892a                	mv	s2,a0
    800047c4:	bf75                	j	80004780 <fileread+0x60>
    panic("fileread");
    800047c6:	00004517          	auipc	a0,0x4
    800047ca:	f1250513          	addi	a0,a0,-238 # 800086d8 <syscalls+0x288>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	d6e080e7          	jalr	-658(ra) # 8000053c <panic>
    return -1;
    800047d6:	597d                	li	s2,-1
    800047d8:	b765                	j	80004780 <fileread+0x60>
      return -1;
    800047da:	597d                	li	s2,-1
    800047dc:	b755                	j	80004780 <fileread+0x60>
    800047de:	597d                	li	s2,-1
    800047e0:	b745                	j	80004780 <fileread+0x60>

00000000800047e2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047e2:	00954783          	lbu	a5,9(a0)
    800047e6:	10078e63          	beqz	a5,80004902 <filewrite+0x120>
{
    800047ea:	715d                	addi	sp,sp,-80
    800047ec:	e486                	sd	ra,72(sp)
    800047ee:	e0a2                	sd	s0,64(sp)
    800047f0:	fc26                	sd	s1,56(sp)
    800047f2:	f84a                	sd	s2,48(sp)
    800047f4:	f44e                	sd	s3,40(sp)
    800047f6:	f052                	sd	s4,32(sp)
    800047f8:	ec56                	sd	s5,24(sp)
    800047fa:	e85a                	sd	s6,16(sp)
    800047fc:	e45e                	sd	s7,8(sp)
    800047fe:	e062                	sd	s8,0(sp)
    80004800:	0880                	addi	s0,sp,80
    80004802:	892a                	mv	s2,a0
    80004804:	8b2e                	mv	s6,a1
    80004806:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004808:	411c                	lw	a5,0(a0)
    8000480a:	4705                	li	a4,1
    8000480c:	02e78263          	beq	a5,a4,80004830 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004810:	470d                	li	a4,3
    80004812:	02e78563          	beq	a5,a4,8000483c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004816:	4709                	li	a4,2
    80004818:	0ce79d63          	bne	a5,a4,800048f2 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000481c:	0ac05b63          	blez	a2,800048d2 <filewrite+0xf0>
    int i = 0;
    80004820:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004822:	6b85                	lui	s7,0x1
    80004824:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004828:	6c05                	lui	s8,0x1
    8000482a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000482e:	a851                	j	800048c2 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004830:	6908                	ld	a0,16(a0)
    80004832:	00000097          	auipc	ra,0x0
    80004836:	22a080e7          	jalr	554(ra) # 80004a5c <pipewrite>
    8000483a:	a045                	j	800048da <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000483c:	02451783          	lh	a5,36(a0)
    80004840:	03079693          	slli	a3,a5,0x30
    80004844:	92c1                	srli	a3,a3,0x30
    80004846:	4725                	li	a4,9
    80004848:	0ad76f63          	bltu	a4,a3,80004906 <filewrite+0x124>
    8000484c:	0792                	slli	a5,a5,0x4
    8000484e:	0001c717          	auipc	a4,0x1c
    80004852:	39a70713          	addi	a4,a4,922 # 80020be8 <devsw>
    80004856:	97ba                	add	a5,a5,a4
    80004858:	679c                	ld	a5,8(a5)
    8000485a:	cbc5                	beqz	a5,8000490a <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000485c:	4505                	li	a0,1
    8000485e:	9782                	jalr	a5
    80004860:	a8ad                	j	800048da <filewrite+0xf8>
      if(n1 > max)
    80004862:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004866:	00000097          	auipc	ra,0x0
    8000486a:	8bc080e7          	jalr	-1860(ra) # 80004122 <begin_op>
      ilock(f->ip);
    8000486e:	01893503          	ld	a0,24(s2)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	f0a080e7          	jalr	-246(ra) # 8000377c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000487a:	8756                	mv	a4,s5
    8000487c:	02092683          	lw	a3,32(s2)
    80004880:	01698633          	add	a2,s3,s6
    80004884:	4585                	li	a1,1
    80004886:	01893503          	ld	a0,24(s2)
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	29e080e7          	jalr	670(ra) # 80003b28 <writei>
    80004892:	84aa                	mv	s1,a0
    80004894:	00a05763          	blez	a0,800048a2 <filewrite+0xc0>
        f->off += r;
    80004898:	02092783          	lw	a5,32(s2)
    8000489c:	9fa9                	addw	a5,a5,a0
    8000489e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048a2:	01893503          	ld	a0,24(s2)
    800048a6:	fffff097          	auipc	ra,0xfffff
    800048aa:	f98080e7          	jalr	-104(ra) # 8000383e <iunlock>
      end_op();
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	8ee080e7          	jalr	-1810(ra) # 8000419c <end_op>

      if(r != n1){
    800048b6:	009a9f63          	bne	s5,s1,800048d4 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048ba:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048be:	0149db63          	bge	s3,s4,800048d4 <filewrite+0xf2>
      int n1 = n - i;
    800048c2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048c6:	0004879b          	sext.w	a5,s1
    800048ca:	f8fbdce3          	bge	s7,a5,80004862 <filewrite+0x80>
    800048ce:	84e2                	mv	s1,s8
    800048d0:	bf49                	j	80004862 <filewrite+0x80>
    int i = 0;
    800048d2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048d4:	033a1d63          	bne	s4,s3,8000490e <filewrite+0x12c>
    800048d8:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048da:	60a6                	ld	ra,72(sp)
    800048dc:	6406                	ld	s0,64(sp)
    800048de:	74e2                	ld	s1,56(sp)
    800048e0:	7942                	ld	s2,48(sp)
    800048e2:	79a2                	ld	s3,40(sp)
    800048e4:	7a02                	ld	s4,32(sp)
    800048e6:	6ae2                	ld	s5,24(sp)
    800048e8:	6b42                	ld	s6,16(sp)
    800048ea:	6ba2                	ld	s7,8(sp)
    800048ec:	6c02                	ld	s8,0(sp)
    800048ee:	6161                	addi	sp,sp,80
    800048f0:	8082                	ret
    panic("filewrite");
    800048f2:	00004517          	auipc	a0,0x4
    800048f6:	df650513          	addi	a0,a0,-522 # 800086e8 <syscalls+0x298>
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	c42080e7          	jalr	-958(ra) # 8000053c <panic>
    return -1;
    80004902:	557d                	li	a0,-1
}
    80004904:	8082                	ret
      return -1;
    80004906:	557d                	li	a0,-1
    80004908:	bfc9                	j	800048da <filewrite+0xf8>
    8000490a:	557d                	li	a0,-1
    8000490c:	b7f9                	j	800048da <filewrite+0xf8>
    ret = (i == n ? n : -1);
    8000490e:	557d                	li	a0,-1
    80004910:	b7e9                	j	800048da <filewrite+0xf8>

0000000080004912 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004912:	7179                	addi	sp,sp,-48
    80004914:	f406                	sd	ra,40(sp)
    80004916:	f022                	sd	s0,32(sp)
    80004918:	ec26                	sd	s1,24(sp)
    8000491a:	e84a                	sd	s2,16(sp)
    8000491c:	e44e                	sd	s3,8(sp)
    8000491e:	e052                	sd	s4,0(sp)
    80004920:	1800                	addi	s0,sp,48
    80004922:	84aa                	mv	s1,a0
    80004924:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004926:	0005b023          	sd	zero,0(a1)
    8000492a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000492e:	00000097          	auipc	ra,0x0
    80004932:	bfc080e7          	jalr	-1028(ra) # 8000452a <filealloc>
    80004936:	e088                	sd	a0,0(s1)
    80004938:	c551                	beqz	a0,800049c4 <pipealloc+0xb2>
    8000493a:	00000097          	auipc	ra,0x0
    8000493e:	bf0080e7          	jalr	-1040(ra) # 8000452a <filealloc>
    80004942:	00aa3023          	sd	a0,0(s4)
    80004946:	c92d                	beqz	a0,800049b8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	19a080e7          	jalr	410(ra) # 80000ae2 <kalloc>
    80004950:	892a                	mv	s2,a0
    80004952:	c125                	beqz	a0,800049b2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004954:	4985                	li	s3,1
    80004956:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000495a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000495e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004962:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004966:	00004597          	auipc	a1,0x4
    8000496a:	d9258593          	addi	a1,a1,-622 # 800086f8 <syscalls+0x2a8>
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	1d4080e7          	jalr	468(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004976:	609c                	ld	a5,0(s1)
    80004978:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000497c:	609c                	ld	a5,0(s1)
    8000497e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004982:	609c                	ld	a5,0(s1)
    80004984:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004988:	609c                	ld	a5,0(s1)
    8000498a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000498e:	000a3783          	ld	a5,0(s4)
    80004992:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004996:	000a3783          	ld	a5,0(s4)
    8000499a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000499e:	000a3783          	ld	a5,0(s4)
    800049a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049a6:	000a3783          	ld	a5,0(s4)
    800049aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800049ae:	4501                	li	a0,0
    800049b0:	a025                	j	800049d8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049b2:	6088                	ld	a0,0(s1)
    800049b4:	e501                	bnez	a0,800049bc <pipealloc+0xaa>
    800049b6:	a039                	j	800049c4 <pipealloc+0xb2>
    800049b8:	6088                	ld	a0,0(s1)
    800049ba:	c51d                	beqz	a0,800049e8 <pipealloc+0xd6>
    fileclose(*f0);
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	c2a080e7          	jalr	-982(ra) # 800045e6 <fileclose>
  if(*f1)
    800049c4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049c8:	557d                	li	a0,-1
  if(*f1)
    800049ca:	c799                	beqz	a5,800049d8 <pipealloc+0xc6>
    fileclose(*f1);
    800049cc:	853e                	mv	a0,a5
    800049ce:	00000097          	auipc	ra,0x0
    800049d2:	c18080e7          	jalr	-1000(ra) # 800045e6 <fileclose>
  return -1;
    800049d6:	557d                	li	a0,-1
}
    800049d8:	70a2                	ld	ra,40(sp)
    800049da:	7402                	ld	s0,32(sp)
    800049dc:	64e2                	ld	s1,24(sp)
    800049de:	6942                	ld	s2,16(sp)
    800049e0:	69a2                	ld	s3,8(sp)
    800049e2:	6a02                	ld	s4,0(sp)
    800049e4:	6145                	addi	sp,sp,48
    800049e6:	8082                	ret
  return -1;
    800049e8:	557d                	li	a0,-1
    800049ea:	b7fd                	j	800049d8 <pipealloc+0xc6>

00000000800049ec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ec:	1101                	addi	sp,sp,-32
    800049ee:	ec06                	sd	ra,24(sp)
    800049f0:	e822                	sd	s0,16(sp)
    800049f2:	e426                	sd	s1,8(sp)
    800049f4:	e04a                	sd	s2,0(sp)
    800049f6:	1000                	addi	s0,sp,32
    800049f8:	84aa                	mv	s1,a0
    800049fa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	1d6080e7          	jalr	470(ra) # 80000bd2 <acquire>
  if(writable){
    80004a04:	02090d63          	beqz	s2,80004a3e <pipeclose+0x52>
    pi->writeopen = 0;
    80004a08:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a0c:	21848513          	addi	a0,s1,536
    80004a10:	ffffd097          	auipc	ra,0xffffd
    80004a14:	710080e7          	jalr	1808(ra) # 80002120 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a18:	2204b783          	ld	a5,544(s1)
    80004a1c:	eb95                	bnez	a5,80004a50 <pipeclose+0x64>
    release(&pi->lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	266080e7          	jalr	614(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	fba080e7          	jalr	-70(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a32:	60e2                	ld	ra,24(sp)
    80004a34:	6442                	ld	s0,16(sp)
    80004a36:	64a2                	ld	s1,8(sp)
    80004a38:	6902                	ld	s2,0(sp)
    80004a3a:	6105                	addi	sp,sp,32
    80004a3c:	8082                	ret
    pi->readopen = 0;
    80004a3e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a42:	21c48513          	addi	a0,s1,540
    80004a46:	ffffd097          	auipc	ra,0xffffd
    80004a4a:	6da080e7          	jalr	1754(ra) # 80002120 <wakeup>
    80004a4e:	b7e9                	j	80004a18 <pipeclose+0x2c>
    release(&pi->lock);
    80004a50:	8526                	mv	a0,s1
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	234080e7          	jalr	564(ra) # 80000c86 <release>
}
    80004a5a:	bfe1                	j	80004a32 <pipeclose+0x46>

0000000080004a5c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a5c:	711d                	addi	sp,sp,-96
    80004a5e:	ec86                	sd	ra,88(sp)
    80004a60:	e8a2                	sd	s0,80(sp)
    80004a62:	e4a6                	sd	s1,72(sp)
    80004a64:	e0ca                	sd	s2,64(sp)
    80004a66:	fc4e                	sd	s3,56(sp)
    80004a68:	f852                	sd	s4,48(sp)
    80004a6a:	f456                	sd	s5,40(sp)
    80004a6c:	f05a                	sd	s6,32(sp)
    80004a6e:	ec5e                	sd	s7,24(sp)
    80004a70:	e862                	sd	s8,16(sp)
    80004a72:	1080                	addi	s0,sp,96
    80004a74:	84aa                	mv	s1,a0
    80004a76:	8aae                	mv	s5,a1
    80004a78:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a7a:	ffffd097          	auipc	ra,0xffffd
    80004a7e:	f2c080e7          	jalr	-212(ra) # 800019a6 <myproc>
    80004a82:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a84:	8526                	mv	a0,s1
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	14c080e7          	jalr	332(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a8e:	0b405663          	blez	s4,80004b3a <pipewrite+0xde>
  int i = 0;
    80004a92:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a94:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a96:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a9a:	21c48b93          	addi	s7,s1,540
    80004a9e:	a089                	j	80004ae0 <pipewrite+0x84>
      release(&pi->lock);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	1e4080e7          	jalr	484(ra) # 80000c86 <release>
      return -1;
    80004aaa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004aac:	854a                	mv	a0,s2
    80004aae:	60e6                	ld	ra,88(sp)
    80004ab0:	6446                	ld	s0,80(sp)
    80004ab2:	64a6                	ld	s1,72(sp)
    80004ab4:	6906                	ld	s2,64(sp)
    80004ab6:	79e2                	ld	s3,56(sp)
    80004ab8:	7a42                	ld	s4,48(sp)
    80004aba:	7aa2                	ld	s5,40(sp)
    80004abc:	7b02                	ld	s6,32(sp)
    80004abe:	6be2                	ld	s7,24(sp)
    80004ac0:	6c42                	ld	s8,16(sp)
    80004ac2:	6125                	addi	sp,sp,96
    80004ac4:	8082                	ret
      wakeup(&pi->nread);
    80004ac6:	8562                	mv	a0,s8
    80004ac8:	ffffd097          	auipc	ra,0xffffd
    80004acc:	658080e7          	jalr	1624(ra) # 80002120 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ad0:	85a6                	mv	a1,s1
    80004ad2:	855e                	mv	a0,s7
    80004ad4:	ffffd097          	auipc	ra,0xffffd
    80004ad8:	5e8080e7          	jalr	1512(ra) # 800020bc <sleep>
  while(i < n){
    80004adc:	07495063          	bge	s2,s4,80004b3c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ae0:	2204a783          	lw	a5,544(s1)
    80004ae4:	dfd5                	beqz	a5,80004aa0 <pipewrite+0x44>
    80004ae6:	854e                	mv	a0,s3
    80004ae8:	ffffe097          	auipc	ra,0xffffe
    80004aec:	87c080e7          	jalr	-1924(ra) # 80002364 <killed>
    80004af0:	f945                	bnez	a0,80004aa0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004af2:	2184a783          	lw	a5,536(s1)
    80004af6:	21c4a703          	lw	a4,540(s1)
    80004afa:	2007879b          	addiw	a5,a5,512
    80004afe:	fcf704e3          	beq	a4,a5,80004ac6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b02:	4685                	li	a3,1
    80004b04:	01590633          	add	a2,s2,s5
    80004b08:	faf40593          	addi	a1,s0,-81
    80004b0c:	0509b503          	ld	a0,80(s3)
    80004b10:	ffffd097          	auipc	ra,0xffffd
    80004b14:	be2080e7          	jalr	-1054(ra) # 800016f2 <copyin>
    80004b18:	03650263          	beq	a0,s6,80004b3c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b1c:	21c4a783          	lw	a5,540(s1)
    80004b20:	0017871b          	addiw	a4,a5,1
    80004b24:	20e4ae23          	sw	a4,540(s1)
    80004b28:	1ff7f793          	andi	a5,a5,511
    80004b2c:	97a6                	add	a5,a5,s1
    80004b2e:	faf44703          	lbu	a4,-81(s0)
    80004b32:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b36:	2905                	addiw	s2,s2,1
    80004b38:	b755                	j	80004adc <pipewrite+0x80>
  int i = 0;
    80004b3a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b3c:	21848513          	addi	a0,s1,536
    80004b40:	ffffd097          	auipc	ra,0xffffd
    80004b44:	5e0080e7          	jalr	1504(ra) # 80002120 <wakeup>
  release(&pi->lock);
    80004b48:	8526                	mv	a0,s1
    80004b4a:	ffffc097          	auipc	ra,0xffffc
    80004b4e:	13c080e7          	jalr	316(ra) # 80000c86 <release>
  return i;
    80004b52:	bfa9                	j	80004aac <pipewrite+0x50>

0000000080004b54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b54:	715d                	addi	sp,sp,-80
    80004b56:	e486                	sd	ra,72(sp)
    80004b58:	e0a2                	sd	s0,64(sp)
    80004b5a:	fc26                	sd	s1,56(sp)
    80004b5c:	f84a                	sd	s2,48(sp)
    80004b5e:	f44e                	sd	s3,40(sp)
    80004b60:	f052                	sd	s4,32(sp)
    80004b62:	ec56                	sd	s5,24(sp)
    80004b64:	e85a                	sd	s6,16(sp)
    80004b66:	0880                	addi	s0,sp,80
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	892e                	mv	s2,a1
    80004b6c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	e38080e7          	jalr	-456(ra) # 800019a6 <myproc>
    80004b76:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	058080e7          	jalr	88(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b82:	2184a703          	lw	a4,536(s1)
    80004b86:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b8a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b8e:	02f71763          	bne	a4,a5,80004bbc <piperead+0x68>
    80004b92:	2244a783          	lw	a5,548(s1)
    80004b96:	c39d                	beqz	a5,80004bbc <piperead+0x68>
    if(killed(pr)){
    80004b98:	8552                	mv	a0,s4
    80004b9a:	ffffd097          	auipc	ra,0xffffd
    80004b9e:	7ca080e7          	jalr	1994(ra) # 80002364 <killed>
    80004ba2:	e949                	bnez	a0,80004c34 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba4:	85a6                	mv	a1,s1
    80004ba6:	854e                	mv	a0,s3
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	514080e7          	jalr	1300(ra) # 800020bc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb0:	2184a703          	lw	a4,536(s1)
    80004bb4:	21c4a783          	lw	a5,540(s1)
    80004bb8:	fcf70de3          	beq	a4,a5,80004b92 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bbc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bbe:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc0:	05505463          	blez	s5,80004c08 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bc4:	2184a783          	lw	a5,536(s1)
    80004bc8:	21c4a703          	lw	a4,540(s1)
    80004bcc:	02f70e63          	beq	a4,a5,80004c08 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bd0:	0017871b          	addiw	a4,a5,1
    80004bd4:	20e4ac23          	sw	a4,536(s1)
    80004bd8:	1ff7f793          	andi	a5,a5,511
    80004bdc:	97a6                	add	a5,a5,s1
    80004bde:	0187c783          	lbu	a5,24(a5)
    80004be2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be6:	4685                	li	a3,1
    80004be8:	fbf40613          	addi	a2,s0,-65
    80004bec:	85ca                	mv	a1,s2
    80004bee:	050a3503          	ld	a0,80(s4)
    80004bf2:	ffffd097          	auipc	ra,0xffffd
    80004bf6:	a74080e7          	jalr	-1420(ra) # 80001666 <copyout>
    80004bfa:	01650763          	beq	a0,s6,80004c08 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bfe:	2985                	addiw	s3,s3,1
    80004c00:	0905                	addi	s2,s2,1
    80004c02:	fd3a91e3          	bne	s5,s3,80004bc4 <piperead+0x70>
    80004c06:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c08:	21c48513          	addi	a0,s1,540
    80004c0c:	ffffd097          	auipc	ra,0xffffd
    80004c10:	514080e7          	jalr	1300(ra) # 80002120 <wakeup>
  release(&pi->lock);
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	070080e7          	jalr	112(ra) # 80000c86 <release>
  return i;
}
    80004c1e:	854e                	mv	a0,s3
    80004c20:	60a6                	ld	ra,72(sp)
    80004c22:	6406                	ld	s0,64(sp)
    80004c24:	74e2                	ld	s1,56(sp)
    80004c26:	7942                	ld	s2,48(sp)
    80004c28:	79a2                	ld	s3,40(sp)
    80004c2a:	7a02                	ld	s4,32(sp)
    80004c2c:	6ae2                	ld	s5,24(sp)
    80004c2e:	6b42                	ld	s6,16(sp)
    80004c30:	6161                	addi	sp,sp,80
    80004c32:	8082                	ret
      release(&pi->lock);
    80004c34:	8526                	mv	a0,s1
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	050080e7          	jalr	80(ra) # 80000c86 <release>
      return -1;
    80004c3e:	59fd                	li	s3,-1
    80004c40:	bff9                	j	80004c1e <piperead+0xca>

0000000080004c42 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c42:	1141                	addi	sp,sp,-16
    80004c44:	e422                	sd	s0,8(sp)
    80004c46:	0800                	addi	s0,sp,16
    80004c48:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c4a:	8905                	andi	a0,a0,1
    80004c4c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c4e:	8b89                	andi	a5,a5,2
    80004c50:	c399                	beqz	a5,80004c56 <flags2perm+0x14>
      perm |= PTE_W;
    80004c52:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c56:	6422                	ld	s0,8(sp)
    80004c58:	0141                	addi	sp,sp,16
    80004c5a:	8082                	ret

0000000080004c5c <exec>:

int
exec(char *path, char **argv)
{
    80004c5c:	df010113          	addi	sp,sp,-528
    80004c60:	20113423          	sd	ra,520(sp)
    80004c64:	20813023          	sd	s0,512(sp)
    80004c68:	ffa6                	sd	s1,504(sp)
    80004c6a:	fbca                	sd	s2,496(sp)
    80004c6c:	f7ce                	sd	s3,488(sp)
    80004c6e:	f3d2                	sd	s4,480(sp)
    80004c70:	efd6                	sd	s5,472(sp)
    80004c72:	ebda                	sd	s6,464(sp)
    80004c74:	e7de                	sd	s7,456(sp)
    80004c76:	e3e2                	sd	s8,448(sp)
    80004c78:	ff66                	sd	s9,440(sp)
    80004c7a:	fb6a                	sd	s10,432(sp)
    80004c7c:	f76e                	sd	s11,424(sp)
    80004c7e:	0c00                	addi	s0,sp,528
    80004c80:	892a                	mv	s2,a0
    80004c82:	dea43c23          	sd	a0,-520(s0)
    80004c86:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c8a:	ffffd097          	auipc	ra,0xffffd
    80004c8e:	d1c080e7          	jalr	-740(ra) # 800019a6 <myproc>
    80004c92:	84aa                	mv	s1,a0

  begin_op();
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	48e080e7          	jalr	1166(ra) # 80004122 <begin_op>

  if((ip = namei(path)) == 0){
    80004c9c:	854a                	mv	a0,s2
    80004c9e:	fffff097          	auipc	ra,0xfffff
    80004ca2:	284080e7          	jalr	644(ra) # 80003f22 <namei>
    80004ca6:	c92d                	beqz	a0,80004d18 <exec+0xbc>
    80004ca8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	ad2080e7          	jalr	-1326(ra) # 8000377c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cb2:	04000713          	li	a4,64
    80004cb6:	4681                	li	a3,0
    80004cb8:	e5040613          	addi	a2,s0,-432
    80004cbc:	4581                	li	a1,0
    80004cbe:	8552                	mv	a0,s4
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	d70080e7          	jalr	-656(ra) # 80003a30 <readi>
    80004cc8:	04000793          	li	a5,64
    80004ccc:	00f51a63          	bne	a0,a5,80004ce0 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cd0:	e5042703          	lw	a4,-432(s0)
    80004cd4:	464c47b7          	lui	a5,0x464c4
    80004cd8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cdc:	04f70463          	beq	a4,a5,80004d24 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ce0:	8552                	mv	a0,s4
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	cfc080e7          	jalr	-772(ra) # 800039de <iunlockput>
    end_op();
    80004cea:	fffff097          	auipc	ra,0xfffff
    80004cee:	4b2080e7          	jalr	1202(ra) # 8000419c <end_op>
  }
  return -1;
    80004cf2:	557d                	li	a0,-1
}
    80004cf4:	20813083          	ld	ra,520(sp)
    80004cf8:	20013403          	ld	s0,512(sp)
    80004cfc:	74fe                	ld	s1,504(sp)
    80004cfe:	795e                	ld	s2,496(sp)
    80004d00:	79be                	ld	s3,488(sp)
    80004d02:	7a1e                	ld	s4,480(sp)
    80004d04:	6afe                	ld	s5,472(sp)
    80004d06:	6b5e                	ld	s6,464(sp)
    80004d08:	6bbe                	ld	s7,456(sp)
    80004d0a:	6c1e                	ld	s8,448(sp)
    80004d0c:	7cfa                	ld	s9,440(sp)
    80004d0e:	7d5a                	ld	s10,432(sp)
    80004d10:	7dba                	ld	s11,424(sp)
    80004d12:	21010113          	addi	sp,sp,528
    80004d16:	8082                	ret
    end_op();
    80004d18:	fffff097          	auipc	ra,0xfffff
    80004d1c:	484080e7          	jalr	1156(ra) # 8000419c <end_op>
    return -1;
    80004d20:	557d                	li	a0,-1
    80004d22:	bfc9                	j	80004cf4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d24:	8526                	mv	a0,s1
    80004d26:	ffffd097          	auipc	ra,0xffffd
    80004d2a:	d44080e7          	jalr	-700(ra) # 80001a6a <proc_pagetable>
    80004d2e:	8b2a                	mv	s6,a0
    80004d30:	d945                	beqz	a0,80004ce0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d32:	e7042d03          	lw	s10,-400(s0)
    80004d36:	e8845783          	lhu	a5,-376(s0)
    80004d3a:	10078463          	beqz	a5,80004e42 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d3e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d40:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d42:	6c85                	lui	s9,0x1
    80004d44:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d48:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d4c:	6a85                	lui	s5,0x1
    80004d4e:	a0b5                	j	80004dba <exec+0x15e>
      panic("loadseg: address should exist");
    80004d50:	00004517          	auipc	a0,0x4
    80004d54:	9b050513          	addi	a0,a0,-1616 # 80008700 <syscalls+0x2b0>
    80004d58:	ffffb097          	auipc	ra,0xffffb
    80004d5c:	7e4080e7          	jalr	2020(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004d60:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d62:	8726                	mv	a4,s1
    80004d64:	012c06bb          	addw	a3,s8,s2
    80004d68:	4581                	li	a1,0
    80004d6a:	8552                	mv	a0,s4
    80004d6c:	fffff097          	auipc	ra,0xfffff
    80004d70:	cc4080e7          	jalr	-828(ra) # 80003a30 <readi>
    80004d74:	2501                	sext.w	a0,a0
    80004d76:	24a49863          	bne	s1,a0,80004fc6 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004d7a:	012a893b          	addw	s2,s5,s2
    80004d7e:	03397563          	bgeu	s2,s3,80004da8 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004d82:	02091593          	slli	a1,s2,0x20
    80004d86:	9181                	srli	a1,a1,0x20
    80004d88:	95de                	add	a1,a1,s7
    80004d8a:	855a                	mv	a0,s6
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	2ca080e7          	jalr	714(ra) # 80001056 <walkaddr>
    80004d94:	862a                	mv	a2,a0
    if(pa == 0)
    80004d96:	dd4d                	beqz	a0,80004d50 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004d98:	412984bb          	subw	s1,s3,s2
    80004d9c:	0004879b          	sext.w	a5,s1
    80004da0:	fcfcf0e3          	bgeu	s9,a5,80004d60 <exec+0x104>
    80004da4:	84d6                	mv	s1,s5
    80004da6:	bf6d                	j	80004d60 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004da8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dac:	2d85                	addiw	s11,s11,1
    80004dae:	038d0d1b          	addiw	s10,s10,56
    80004db2:	e8845783          	lhu	a5,-376(s0)
    80004db6:	08fdd763          	bge	s11,a5,80004e44 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dba:	2d01                	sext.w	s10,s10
    80004dbc:	03800713          	li	a4,56
    80004dc0:	86ea                	mv	a3,s10
    80004dc2:	e1840613          	addi	a2,s0,-488
    80004dc6:	4581                	li	a1,0
    80004dc8:	8552                	mv	a0,s4
    80004dca:	fffff097          	auipc	ra,0xfffff
    80004dce:	c66080e7          	jalr	-922(ra) # 80003a30 <readi>
    80004dd2:	03800793          	li	a5,56
    80004dd6:	1ef51663          	bne	a0,a5,80004fc2 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004dda:	e1842783          	lw	a5,-488(s0)
    80004dde:	4705                	li	a4,1
    80004de0:	fce796e3          	bne	a5,a4,80004dac <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004de4:	e4043483          	ld	s1,-448(s0)
    80004de8:	e3843783          	ld	a5,-456(s0)
    80004dec:	1ef4e863          	bltu	s1,a5,80004fdc <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004df0:	e2843783          	ld	a5,-472(s0)
    80004df4:	94be                	add	s1,s1,a5
    80004df6:	1ef4e663          	bltu	s1,a5,80004fe2 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004dfa:	df043703          	ld	a4,-528(s0)
    80004dfe:	8ff9                	and	a5,a5,a4
    80004e00:	1e079463          	bnez	a5,80004fe8 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e04:	e1c42503          	lw	a0,-484(s0)
    80004e08:	00000097          	auipc	ra,0x0
    80004e0c:	e3a080e7          	jalr	-454(ra) # 80004c42 <flags2perm>
    80004e10:	86aa                	mv	a3,a0
    80004e12:	8626                	mv	a2,s1
    80004e14:	85ca                	mv	a1,s2
    80004e16:	855a                	mv	a0,s6
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	5f2080e7          	jalr	1522(ra) # 8000140a <uvmalloc>
    80004e20:	e0a43423          	sd	a0,-504(s0)
    80004e24:	1c050563          	beqz	a0,80004fee <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e28:	e2843b83          	ld	s7,-472(s0)
    80004e2c:	e2042c03          	lw	s8,-480(s0)
    80004e30:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e34:	00098463          	beqz	s3,80004e3c <exec+0x1e0>
    80004e38:	4901                	li	s2,0
    80004e3a:	b7a1                	j	80004d82 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e3c:	e0843903          	ld	s2,-504(s0)
    80004e40:	b7b5                	j	80004dac <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e42:	4901                	li	s2,0
  iunlockput(ip);
    80004e44:	8552                	mv	a0,s4
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	b98080e7          	jalr	-1128(ra) # 800039de <iunlockput>
  end_op();
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	34e080e7          	jalr	846(ra) # 8000419c <end_op>
  p = myproc();
    80004e56:	ffffd097          	auipc	ra,0xffffd
    80004e5a:	b50080e7          	jalr	-1200(ra) # 800019a6 <myproc>
    80004e5e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e60:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e64:	6985                	lui	s3,0x1
    80004e66:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e68:	99ca                	add	s3,s3,s2
    80004e6a:	77fd                	lui	a5,0xfffff
    80004e6c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e70:	4691                	li	a3,4
    80004e72:	6609                	lui	a2,0x2
    80004e74:	964e                	add	a2,a2,s3
    80004e76:	85ce                	mv	a1,s3
    80004e78:	855a                	mv	a0,s6
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	590080e7          	jalr	1424(ra) # 8000140a <uvmalloc>
    80004e82:	892a                	mv	s2,a0
    80004e84:	e0a43423          	sd	a0,-504(s0)
    80004e88:	e509                	bnez	a0,80004e92 <exec+0x236>
  if(pagetable)
    80004e8a:	e1343423          	sd	s3,-504(s0)
    80004e8e:	4a01                	li	s4,0
    80004e90:	aa1d                	j	80004fc6 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e92:	75f9                	lui	a1,0xffffe
    80004e94:	95aa                	add	a1,a1,a0
    80004e96:	855a                	mv	a0,s6
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	79c080e7          	jalr	1948(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ea0:	7bfd                	lui	s7,0xfffff
    80004ea2:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ea4:	e0043783          	ld	a5,-512(s0)
    80004ea8:	6388                	ld	a0,0(a5)
    80004eaa:	c52d                	beqz	a0,80004f14 <exec+0x2b8>
    80004eac:	e9040993          	addi	s3,s0,-368
    80004eb0:	f9040c13          	addi	s8,s0,-112
    80004eb4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	f92080e7          	jalr	-110(ra) # 80000e48 <strlen>
    80004ebe:	0015079b          	addiw	a5,a0,1
    80004ec2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ec6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004eca:	13796563          	bltu	s2,s7,80004ff4 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ece:	e0043d03          	ld	s10,-512(s0)
    80004ed2:	000d3a03          	ld	s4,0(s10)
    80004ed6:	8552                	mv	a0,s4
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	f70080e7          	jalr	-144(ra) # 80000e48 <strlen>
    80004ee0:	0015069b          	addiw	a3,a0,1
    80004ee4:	8652                	mv	a2,s4
    80004ee6:	85ca                	mv	a1,s2
    80004ee8:	855a                	mv	a0,s6
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	77c080e7          	jalr	1916(ra) # 80001666 <copyout>
    80004ef2:	10054363          	bltz	a0,80004ff8 <exec+0x39c>
    ustack[argc] = sp;
    80004ef6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004efa:	0485                	addi	s1,s1,1
    80004efc:	008d0793          	addi	a5,s10,8
    80004f00:	e0f43023          	sd	a5,-512(s0)
    80004f04:	008d3503          	ld	a0,8(s10)
    80004f08:	c909                	beqz	a0,80004f1a <exec+0x2be>
    if(argc >= MAXARG)
    80004f0a:	09a1                	addi	s3,s3,8
    80004f0c:	fb8995e3          	bne	s3,s8,80004eb6 <exec+0x25a>
  ip = 0;
    80004f10:	4a01                	li	s4,0
    80004f12:	a855                	j	80004fc6 <exec+0x36a>
  sp = sz;
    80004f14:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f18:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f1a:	00349793          	slli	a5,s1,0x3
    80004f1e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd210>
    80004f22:	97a2                	add	a5,a5,s0
    80004f24:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f28:	00148693          	addi	a3,s1,1
    80004f2c:	068e                	slli	a3,a3,0x3
    80004f2e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f32:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f36:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f3a:	f57968e3          	bltu	s2,s7,80004e8a <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f3e:	e9040613          	addi	a2,s0,-368
    80004f42:	85ca                	mv	a1,s2
    80004f44:	855a                	mv	a0,s6
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	720080e7          	jalr	1824(ra) # 80001666 <copyout>
    80004f4e:	0a054763          	bltz	a0,80004ffc <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004f52:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f56:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f5a:	df843783          	ld	a5,-520(s0)
    80004f5e:	0007c703          	lbu	a4,0(a5)
    80004f62:	cf11                	beqz	a4,80004f7e <exec+0x322>
    80004f64:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f66:	02f00693          	li	a3,47
    80004f6a:	a039                	j	80004f78 <exec+0x31c>
      last = s+1;
    80004f6c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f70:	0785                	addi	a5,a5,1
    80004f72:	fff7c703          	lbu	a4,-1(a5)
    80004f76:	c701                	beqz	a4,80004f7e <exec+0x322>
    if(*s == '/')
    80004f78:	fed71ce3          	bne	a4,a3,80004f70 <exec+0x314>
    80004f7c:	bfc5                	j	80004f6c <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f7e:	4641                	li	a2,16
    80004f80:	df843583          	ld	a1,-520(s0)
    80004f84:	158a8513          	addi	a0,s5,344
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	e8e080e7          	jalr	-370(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f90:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f94:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f98:	e0843783          	ld	a5,-504(s0)
    80004f9c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fa0:	058ab783          	ld	a5,88(s5)
    80004fa4:	e6843703          	ld	a4,-408(s0)
    80004fa8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004faa:	058ab783          	ld	a5,88(s5)
    80004fae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fb2:	85e6                	mv	a1,s9
    80004fb4:	ffffd097          	auipc	ra,0xffffd
    80004fb8:	b52080e7          	jalr	-1198(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fbc:	0004851b          	sext.w	a0,s1
    80004fc0:	bb15                	j	80004cf4 <exec+0x98>
    80004fc2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fc6:	e0843583          	ld	a1,-504(s0)
    80004fca:	855a                	mv	a0,s6
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	b3a080e7          	jalr	-1222(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80004fd4:	557d                	li	a0,-1
  if(ip){
    80004fd6:	d00a0fe3          	beqz	s4,80004cf4 <exec+0x98>
    80004fda:	b319                	j	80004ce0 <exec+0x84>
    80004fdc:	e1243423          	sd	s2,-504(s0)
    80004fe0:	b7dd                	j	80004fc6 <exec+0x36a>
    80004fe2:	e1243423          	sd	s2,-504(s0)
    80004fe6:	b7c5                	j	80004fc6 <exec+0x36a>
    80004fe8:	e1243423          	sd	s2,-504(s0)
    80004fec:	bfe9                	j	80004fc6 <exec+0x36a>
    80004fee:	e1243423          	sd	s2,-504(s0)
    80004ff2:	bfd1                	j	80004fc6 <exec+0x36a>
  ip = 0;
    80004ff4:	4a01                	li	s4,0
    80004ff6:	bfc1                	j	80004fc6 <exec+0x36a>
    80004ff8:	4a01                	li	s4,0
  if(pagetable)
    80004ffa:	b7f1                	j	80004fc6 <exec+0x36a>
  sz = sz1;
    80004ffc:	e0843983          	ld	s3,-504(s0)
    80005000:	b569                	j	80004e8a <exec+0x22e>

0000000080005002 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005002:	7179                	addi	sp,sp,-48
    80005004:	f406                	sd	ra,40(sp)
    80005006:	f022                	sd	s0,32(sp)
    80005008:	ec26                	sd	s1,24(sp)
    8000500a:	e84a                	sd	s2,16(sp)
    8000500c:	1800                	addi	s0,sp,48
    8000500e:	892e                	mv	s2,a1
    80005010:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005012:	fdc40593          	addi	a1,s0,-36
    80005016:	ffffe097          	auipc	ra,0xffffe
    8000501a:	b18080e7          	jalr	-1256(ra) # 80002b2e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000501e:	fdc42703          	lw	a4,-36(s0)
    80005022:	47bd                	li	a5,15
    80005024:	02e7eb63          	bltu	a5,a4,8000505a <argfd+0x58>
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	97e080e7          	jalr	-1666(ra) # 800019a6 <myproc>
    80005030:	fdc42703          	lw	a4,-36(s0)
    80005034:	01a70793          	addi	a5,a4,26
    80005038:	078e                	slli	a5,a5,0x3
    8000503a:	953e                	add	a0,a0,a5
    8000503c:	611c                	ld	a5,0(a0)
    8000503e:	c385                	beqz	a5,8000505e <argfd+0x5c>
    return -1;
  if(pfd)
    80005040:	00090463          	beqz	s2,80005048 <argfd+0x46>
    *pfd = fd;
    80005044:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005048:	4501                	li	a0,0
  if(pf)
    8000504a:	c091                	beqz	s1,8000504e <argfd+0x4c>
    *pf = f;
    8000504c:	e09c                	sd	a5,0(s1)
}
    8000504e:	70a2                	ld	ra,40(sp)
    80005050:	7402                	ld	s0,32(sp)
    80005052:	64e2                	ld	s1,24(sp)
    80005054:	6942                	ld	s2,16(sp)
    80005056:	6145                	addi	sp,sp,48
    80005058:	8082                	ret
    return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	bfcd                	j	8000504e <argfd+0x4c>
    8000505e:	557d                	li	a0,-1
    80005060:	b7fd                	j	8000504e <argfd+0x4c>

0000000080005062 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005062:	1101                	addi	sp,sp,-32
    80005064:	ec06                	sd	ra,24(sp)
    80005066:	e822                	sd	s0,16(sp)
    80005068:	e426                	sd	s1,8(sp)
    8000506a:	1000                	addi	s0,sp,32
    8000506c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000506e:	ffffd097          	auipc	ra,0xffffd
    80005072:	938080e7          	jalr	-1736(ra) # 800019a6 <myproc>
    80005076:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005078:	0d050793          	addi	a5,a0,208
    8000507c:	4501                	li	a0,0
    8000507e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005080:	6398                	ld	a4,0(a5)
    80005082:	cb19                	beqz	a4,80005098 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005084:	2505                	addiw	a0,a0,1
    80005086:	07a1                	addi	a5,a5,8
    80005088:	fed51ce3          	bne	a0,a3,80005080 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000508c:	557d                	li	a0,-1
}
    8000508e:	60e2                	ld	ra,24(sp)
    80005090:	6442                	ld	s0,16(sp)
    80005092:	64a2                	ld	s1,8(sp)
    80005094:	6105                	addi	sp,sp,32
    80005096:	8082                	ret
      p->ofile[fd] = f;
    80005098:	01a50793          	addi	a5,a0,26
    8000509c:	078e                	slli	a5,a5,0x3
    8000509e:	963e                	add	a2,a2,a5
    800050a0:	e204                	sd	s1,0(a2)
      return fd;
    800050a2:	b7f5                	j	8000508e <fdalloc+0x2c>

00000000800050a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050a4:	715d                	addi	sp,sp,-80
    800050a6:	e486                	sd	ra,72(sp)
    800050a8:	e0a2                	sd	s0,64(sp)
    800050aa:	fc26                	sd	s1,56(sp)
    800050ac:	f84a                	sd	s2,48(sp)
    800050ae:	f44e                	sd	s3,40(sp)
    800050b0:	f052                	sd	s4,32(sp)
    800050b2:	ec56                	sd	s5,24(sp)
    800050b4:	e85a                	sd	s6,16(sp)
    800050b6:	0880                	addi	s0,sp,80
    800050b8:	8b2e                	mv	s6,a1
    800050ba:	89b2                	mv	s3,a2
    800050bc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050be:	fb040593          	addi	a1,s0,-80
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	e7e080e7          	jalr	-386(ra) # 80003f40 <nameiparent>
    800050ca:	84aa                	mv	s1,a0
    800050cc:	14050b63          	beqz	a0,80005222 <create+0x17e>
    return 0;

  ilock(dp);
    800050d0:	ffffe097          	auipc	ra,0xffffe
    800050d4:	6ac080e7          	jalr	1708(ra) # 8000377c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050d8:	4601                	li	a2,0
    800050da:	fb040593          	addi	a1,s0,-80
    800050de:	8526                	mv	a0,s1
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	b80080e7          	jalr	-1152(ra) # 80003c60 <dirlookup>
    800050e8:	8aaa                	mv	s5,a0
    800050ea:	c921                	beqz	a0,8000513a <create+0x96>
    iunlockput(dp);
    800050ec:	8526                	mv	a0,s1
    800050ee:	fffff097          	auipc	ra,0xfffff
    800050f2:	8f0080e7          	jalr	-1808(ra) # 800039de <iunlockput>
    ilock(ip);
    800050f6:	8556                	mv	a0,s5
    800050f8:	ffffe097          	auipc	ra,0xffffe
    800050fc:	684080e7          	jalr	1668(ra) # 8000377c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005100:	4789                	li	a5,2
    80005102:	02fb1563          	bne	s6,a5,8000512c <create+0x88>
    80005106:	044ad783          	lhu	a5,68(s5)
    8000510a:	37f9                	addiw	a5,a5,-2
    8000510c:	17c2                	slli	a5,a5,0x30
    8000510e:	93c1                	srli	a5,a5,0x30
    80005110:	4705                	li	a4,1
    80005112:	00f76d63          	bltu	a4,a5,8000512c <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005116:	8556                	mv	a0,s5
    80005118:	60a6                	ld	ra,72(sp)
    8000511a:	6406                	ld	s0,64(sp)
    8000511c:	74e2                	ld	s1,56(sp)
    8000511e:	7942                	ld	s2,48(sp)
    80005120:	79a2                	ld	s3,40(sp)
    80005122:	7a02                	ld	s4,32(sp)
    80005124:	6ae2                	ld	s5,24(sp)
    80005126:	6b42                	ld	s6,16(sp)
    80005128:	6161                	addi	sp,sp,80
    8000512a:	8082                	ret
    iunlockput(ip);
    8000512c:	8556                	mv	a0,s5
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	8b0080e7          	jalr	-1872(ra) # 800039de <iunlockput>
    return 0;
    80005136:	4a81                	li	s5,0
    80005138:	bff9                	j	80005116 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000513a:	85da                	mv	a1,s6
    8000513c:	4088                	lw	a0,0(s1)
    8000513e:	ffffe097          	auipc	ra,0xffffe
    80005142:	4a6080e7          	jalr	1190(ra) # 800035e4 <ialloc>
    80005146:	8a2a                	mv	s4,a0
    80005148:	c529                	beqz	a0,80005192 <create+0xee>
  ilock(ip);
    8000514a:	ffffe097          	auipc	ra,0xffffe
    8000514e:	632080e7          	jalr	1586(ra) # 8000377c <ilock>
  ip->major = major;
    80005152:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005156:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000515a:	4905                	li	s2,1
    8000515c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005160:	8552                	mv	a0,s4
    80005162:	ffffe097          	auipc	ra,0xffffe
    80005166:	54e080e7          	jalr	1358(ra) # 800036b0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000516a:	032b0b63          	beq	s6,s2,800051a0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000516e:	004a2603          	lw	a2,4(s4)
    80005172:	fb040593          	addi	a1,s0,-80
    80005176:	8526                	mv	a0,s1
    80005178:	fffff097          	auipc	ra,0xfffff
    8000517c:	cf8080e7          	jalr	-776(ra) # 80003e70 <dirlink>
    80005180:	06054f63          	bltz	a0,800051fe <create+0x15a>
  iunlockput(dp);
    80005184:	8526                	mv	a0,s1
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	858080e7          	jalr	-1960(ra) # 800039de <iunlockput>
  return ip;
    8000518e:	8ad2                	mv	s5,s4
    80005190:	b759                	j	80005116 <create+0x72>
    iunlockput(dp);
    80005192:	8526                	mv	a0,s1
    80005194:	fffff097          	auipc	ra,0xfffff
    80005198:	84a080e7          	jalr	-1974(ra) # 800039de <iunlockput>
    return 0;
    8000519c:	8ad2                	mv	s5,s4
    8000519e:	bfa5                	j	80005116 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051a0:	004a2603          	lw	a2,4(s4)
    800051a4:	00003597          	auipc	a1,0x3
    800051a8:	57c58593          	addi	a1,a1,1404 # 80008720 <syscalls+0x2d0>
    800051ac:	8552                	mv	a0,s4
    800051ae:	fffff097          	auipc	ra,0xfffff
    800051b2:	cc2080e7          	jalr	-830(ra) # 80003e70 <dirlink>
    800051b6:	04054463          	bltz	a0,800051fe <create+0x15a>
    800051ba:	40d0                	lw	a2,4(s1)
    800051bc:	00003597          	auipc	a1,0x3
    800051c0:	56c58593          	addi	a1,a1,1388 # 80008728 <syscalls+0x2d8>
    800051c4:	8552                	mv	a0,s4
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	caa080e7          	jalr	-854(ra) # 80003e70 <dirlink>
    800051ce:	02054863          	bltz	a0,800051fe <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051d2:	004a2603          	lw	a2,4(s4)
    800051d6:	fb040593          	addi	a1,s0,-80
    800051da:	8526                	mv	a0,s1
    800051dc:	fffff097          	auipc	ra,0xfffff
    800051e0:	c94080e7          	jalr	-876(ra) # 80003e70 <dirlink>
    800051e4:	00054d63          	bltz	a0,800051fe <create+0x15a>
    dp->nlink++;  // for ".."
    800051e8:	04a4d783          	lhu	a5,74(s1)
    800051ec:	2785                	addiw	a5,a5,1
    800051ee:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051f2:	8526                	mv	a0,s1
    800051f4:	ffffe097          	auipc	ra,0xffffe
    800051f8:	4bc080e7          	jalr	1212(ra) # 800036b0 <iupdate>
    800051fc:	b761                	j	80005184 <create+0xe0>
  ip->nlink = 0;
    800051fe:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005202:	8552                	mv	a0,s4
    80005204:	ffffe097          	auipc	ra,0xffffe
    80005208:	4ac080e7          	jalr	1196(ra) # 800036b0 <iupdate>
  iunlockput(ip);
    8000520c:	8552                	mv	a0,s4
    8000520e:	ffffe097          	auipc	ra,0xffffe
    80005212:	7d0080e7          	jalr	2000(ra) # 800039de <iunlockput>
  iunlockput(dp);
    80005216:	8526                	mv	a0,s1
    80005218:	ffffe097          	auipc	ra,0xffffe
    8000521c:	7c6080e7          	jalr	1990(ra) # 800039de <iunlockput>
  return 0;
    80005220:	bddd                	j	80005116 <create+0x72>
    return 0;
    80005222:	8aaa                	mv	s5,a0
    80005224:	bdcd                	j	80005116 <create+0x72>

0000000080005226 <sys_dup>:
{
    80005226:	7179                	addi	sp,sp,-48
    80005228:	f406                	sd	ra,40(sp)
    8000522a:	f022                	sd	s0,32(sp)
    8000522c:	ec26                	sd	s1,24(sp)
    8000522e:	e84a                	sd	s2,16(sp)
    80005230:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005232:	fd840613          	addi	a2,s0,-40
    80005236:	4581                	li	a1,0
    80005238:	4501                	li	a0,0
    8000523a:	00000097          	auipc	ra,0x0
    8000523e:	dc8080e7          	jalr	-568(ra) # 80005002 <argfd>
    return -1;
    80005242:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005244:	02054363          	bltz	a0,8000526a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005248:	fd843903          	ld	s2,-40(s0)
    8000524c:	854a                	mv	a0,s2
    8000524e:	00000097          	auipc	ra,0x0
    80005252:	e14080e7          	jalr	-492(ra) # 80005062 <fdalloc>
    80005256:	84aa                	mv	s1,a0
    return -1;
    80005258:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000525a:	00054863          	bltz	a0,8000526a <sys_dup+0x44>
  filedup(f);
    8000525e:	854a                	mv	a0,s2
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	334080e7          	jalr	820(ra) # 80004594 <filedup>
  return fd;
    80005268:	87a6                	mv	a5,s1
}
    8000526a:	853e                	mv	a0,a5
    8000526c:	70a2                	ld	ra,40(sp)
    8000526e:	7402                	ld	s0,32(sp)
    80005270:	64e2                	ld	s1,24(sp)
    80005272:	6942                	ld	s2,16(sp)
    80005274:	6145                	addi	sp,sp,48
    80005276:	8082                	ret

0000000080005278 <sys_read>:
{
    80005278:	7179                	addi	sp,sp,-48
    8000527a:	f406                	sd	ra,40(sp)
    8000527c:	f022                	sd	s0,32(sp)
    8000527e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005280:	fd840593          	addi	a1,s0,-40
    80005284:	4505                	li	a0,1
    80005286:	ffffe097          	auipc	ra,0xffffe
    8000528a:	8c8080e7          	jalr	-1848(ra) # 80002b4e <argaddr>
  argint(2, &n);
    8000528e:	fe440593          	addi	a1,s0,-28
    80005292:	4509                	li	a0,2
    80005294:	ffffe097          	auipc	ra,0xffffe
    80005298:	89a080e7          	jalr	-1894(ra) # 80002b2e <argint>
  if(argfd(0, 0, &f) < 0)
    8000529c:	fe840613          	addi	a2,s0,-24
    800052a0:	4581                	li	a1,0
    800052a2:	4501                	li	a0,0
    800052a4:	00000097          	auipc	ra,0x0
    800052a8:	d5e080e7          	jalr	-674(ra) # 80005002 <argfd>
    800052ac:	87aa                	mv	a5,a0
    return -1;
    800052ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052b0:	0007cc63          	bltz	a5,800052c8 <sys_read+0x50>
  return fileread(f, p, n);
    800052b4:	fe442603          	lw	a2,-28(s0)
    800052b8:	fd843583          	ld	a1,-40(s0)
    800052bc:	fe843503          	ld	a0,-24(s0)
    800052c0:	fffff097          	auipc	ra,0xfffff
    800052c4:	460080e7          	jalr	1120(ra) # 80004720 <fileread>
}
    800052c8:	70a2                	ld	ra,40(sp)
    800052ca:	7402                	ld	s0,32(sp)
    800052cc:	6145                	addi	sp,sp,48
    800052ce:	8082                	ret

00000000800052d0 <sys_write>:
{
    800052d0:	7179                	addi	sp,sp,-48
    800052d2:	f406                	sd	ra,40(sp)
    800052d4:	f022                	sd	s0,32(sp)
    800052d6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052d8:	fd840593          	addi	a1,s0,-40
    800052dc:	4505                	li	a0,1
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	870080e7          	jalr	-1936(ra) # 80002b4e <argaddr>
  argint(2, &n);
    800052e6:	fe440593          	addi	a1,s0,-28
    800052ea:	4509                	li	a0,2
    800052ec:	ffffe097          	auipc	ra,0xffffe
    800052f0:	842080e7          	jalr	-1982(ra) # 80002b2e <argint>
  if(argfd(0, 0, &f) < 0)
    800052f4:	fe840613          	addi	a2,s0,-24
    800052f8:	4581                	li	a1,0
    800052fa:	4501                	li	a0,0
    800052fc:	00000097          	auipc	ra,0x0
    80005300:	d06080e7          	jalr	-762(ra) # 80005002 <argfd>
    80005304:	87aa                	mv	a5,a0
    return -1;
    80005306:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005308:	0007cc63          	bltz	a5,80005320 <sys_write+0x50>
  return filewrite(f, p, n);
    8000530c:	fe442603          	lw	a2,-28(s0)
    80005310:	fd843583          	ld	a1,-40(s0)
    80005314:	fe843503          	ld	a0,-24(s0)
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	4ca080e7          	jalr	1226(ra) # 800047e2 <filewrite>
}
    80005320:	70a2                	ld	ra,40(sp)
    80005322:	7402                	ld	s0,32(sp)
    80005324:	6145                	addi	sp,sp,48
    80005326:	8082                	ret

0000000080005328 <sys_close>:
{
    80005328:	1101                	addi	sp,sp,-32
    8000532a:	ec06                	sd	ra,24(sp)
    8000532c:	e822                	sd	s0,16(sp)
    8000532e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005330:	fe040613          	addi	a2,s0,-32
    80005334:	fec40593          	addi	a1,s0,-20
    80005338:	4501                	li	a0,0
    8000533a:	00000097          	auipc	ra,0x0
    8000533e:	cc8080e7          	jalr	-824(ra) # 80005002 <argfd>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005344:	02054463          	bltz	a0,8000536c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	65e080e7          	jalr	1630(ra) # 800019a6 <myproc>
    80005350:	fec42783          	lw	a5,-20(s0)
    80005354:	07e9                	addi	a5,a5,26
    80005356:	078e                	slli	a5,a5,0x3
    80005358:	953e                	add	a0,a0,a5
    8000535a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000535e:	fe043503          	ld	a0,-32(s0)
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	284080e7          	jalr	644(ra) # 800045e6 <fileclose>
  return 0;
    8000536a:	4781                	li	a5,0
}
    8000536c:	853e                	mv	a0,a5
    8000536e:	60e2                	ld	ra,24(sp)
    80005370:	6442                	ld	s0,16(sp)
    80005372:	6105                	addi	sp,sp,32
    80005374:	8082                	ret

0000000080005376 <sys_fstat>:
{
    80005376:	1101                	addi	sp,sp,-32
    80005378:	ec06                	sd	ra,24(sp)
    8000537a:	e822                	sd	s0,16(sp)
    8000537c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000537e:	fe040593          	addi	a1,s0,-32
    80005382:	4505                	li	a0,1
    80005384:	ffffd097          	auipc	ra,0xffffd
    80005388:	7ca080e7          	jalr	1994(ra) # 80002b4e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000538c:	fe840613          	addi	a2,s0,-24
    80005390:	4581                	li	a1,0
    80005392:	4501                	li	a0,0
    80005394:	00000097          	auipc	ra,0x0
    80005398:	c6e080e7          	jalr	-914(ra) # 80005002 <argfd>
    8000539c:	87aa                	mv	a5,a0
    return -1;
    8000539e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053a0:	0007ca63          	bltz	a5,800053b4 <sys_fstat+0x3e>
  return filestat(f, st);
    800053a4:	fe043583          	ld	a1,-32(s0)
    800053a8:	fe843503          	ld	a0,-24(s0)
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	302080e7          	jalr	770(ra) # 800046ae <filestat>
}
    800053b4:	60e2                	ld	ra,24(sp)
    800053b6:	6442                	ld	s0,16(sp)
    800053b8:	6105                	addi	sp,sp,32
    800053ba:	8082                	ret

00000000800053bc <sys_link>:
{
    800053bc:	7169                	addi	sp,sp,-304
    800053be:	f606                	sd	ra,296(sp)
    800053c0:	f222                	sd	s0,288(sp)
    800053c2:	ee26                	sd	s1,280(sp)
    800053c4:	ea4a                	sd	s2,272(sp)
    800053c6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053c8:	08000613          	li	a2,128
    800053cc:	ed040593          	addi	a1,s0,-304
    800053d0:	4501                	li	a0,0
    800053d2:	ffffd097          	auipc	ra,0xffffd
    800053d6:	79c080e7          	jalr	1948(ra) # 80002b6e <argstr>
    return -1;
    800053da:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053dc:	10054e63          	bltz	a0,800054f8 <sys_link+0x13c>
    800053e0:	08000613          	li	a2,128
    800053e4:	f5040593          	addi	a1,s0,-176
    800053e8:	4505                	li	a0,1
    800053ea:	ffffd097          	auipc	ra,0xffffd
    800053ee:	784080e7          	jalr	1924(ra) # 80002b6e <argstr>
    return -1;
    800053f2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053f4:	10054263          	bltz	a0,800054f8 <sys_link+0x13c>
  begin_op();
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	d2a080e7          	jalr	-726(ra) # 80004122 <begin_op>
  if((ip = namei(old)) == 0){
    80005400:	ed040513          	addi	a0,s0,-304
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	b1e080e7          	jalr	-1250(ra) # 80003f22 <namei>
    8000540c:	84aa                	mv	s1,a0
    8000540e:	c551                	beqz	a0,8000549a <sys_link+0xde>
  ilock(ip);
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	36c080e7          	jalr	876(ra) # 8000377c <ilock>
  if(ip->type == T_DIR){
    80005418:	04449703          	lh	a4,68(s1)
    8000541c:	4785                	li	a5,1
    8000541e:	08f70463          	beq	a4,a5,800054a6 <sys_link+0xea>
  ip->nlink++;
    80005422:	04a4d783          	lhu	a5,74(s1)
    80005426:	2785                	addiw	a5,a5,1
    80005428:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000542c:	8526                	mv	a0,s1
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	282080e7          	jalr	642(ra) # 800036b0 <iupdate>
  iunlock(ip);
    80005436:	8526                	mv	a0,s1
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	406080e7          	jalr	1030(ra) # 8000383e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005440:	fd040593          	addi	a1,s0,-48
    80005444:	f5040513          	addi	a0,s0,-176
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	af8080e7          	jalr	-1288(ra) # 80003f40 <nameiparent>
    80005450:	892a                	mv	s2,a0
    80005452:	c935                	beqz	a0,800054c6 <sys_link+0x10a>
  ilock(dp);
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	328080e7          	jalr	808(ra) # 8000377c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000545c:	00092703          	lw	a4,0(s2)
    80005460:	409c                	lw	a5,0(s1)
    80005462:	04f71d63          	bne	a4,a5,800054bc <sys_link+0x100>
    80005466:	40d0                	lw	a2,4(s1)
    80005468:	fd040593          	addi	a1,s0,-48
    8000546c:	854a                	mv	a0,s2
    8000546e:	fffff097          	auipc	ra,0xfffff
    80005472:	a02080e7          	jalr	-1534(ra) # 80003e70 <dirlink>
    80005476:	04054363          	bltz	a0,800054bc <sys_link+0x100>
  iunlockput(dp);
    8000547a:	854a                	mv	a0,s2
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	562080e7          	jalr	1378(ra) # 800039de <iunlockput>
  iput(ip);
    80005484:	8526                	mv	a0,s1
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	4b0080e7          	jalr	1200(ra) # 80003936 <iput>
  end_op();
    8000548e:	fffff097          	auipc	ra,0xfffff
    80005492:	d0e080e7          	jalr	-754(ra) # 8000419c <end_op>
  return 0;
    80005496:	4781                	li	a5,0
    80005498:	a085                	j	800054f8 <sys_link+0x13c>
    end_op();
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	d02080e7          	jalr	-766(ra) # 8000419c <end_op>
    return -1;
    800054a2:	57fd                	li	a5,-1
    800054a4:	a891                	j	800054f8 <sys_link+0x13c>
    iunlockput(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	536080e7          	jalr	1334(ra) # 800039de <iunlockput>
    end_op();
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	cec080e7          	jalr	-788(ra) # 8000419c <end_op>
    return -1;
    800054b8:	57fd                	li	a5,-1
    800054ba:	a83d                	j	800054f8 <sys_link+0x13c>
    iunlockput(dp);
    800054bc:	854a                	mv	a0,s2
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	520080e7          	jalr	1312(ra) # 800039de <iunlockput>
  ilock(ip);
    800054c6:	8526                	mv	a0,s1
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	2b4080e7          	jalr	692(ra) # 8000377c <ilock>
  ip->nlink--;
    800054d0:	04a4d783          	lhu	a5,74(s1)
    800054d4:	37fd                	addiw	a5,a5,-1
    800054d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054da:	8526                	mv	a0,s1
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	1d4080e7          	jalr	468(ra) # 800036b0 <iupdate>
  iunlockput(ip);
    800054e4:	8526                	mv	a0,s1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	4f8080e7          	jalr	1272(ra) # 800039de <iunlockput>
  end_op();
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	cae080e7          	jalr	-850(ra) # 8000419c <end_op>
  return -1;
    800054f6:	57fd                	li	a5,-1
}
    800054f8:	853e                	mv	a0,a5
    800054fa:	70b2                	ld	ra,296(sp)
    800054fc:	7412                	ld	s0,288(sp)
    800054fe:	64f2                	ld	s1,280(sp)
    80005500:	6952                	ld	s2,272(sp)
    80005502:	6155                	addi	sp,sp,304
    80005504:	8082                	ret

0000000080005506 <sys_unlink>:
{
    80005506:	7151                	addi	sp,sp,-240
    80005508:	f586                	sd	ra,232(sp)
    8000550a:	f1a2                	sd	s0,224(sp)
    8000550c:	eda6                	sd	s1,216(sp)
    8000550e:	e9ca                	sd	s2,208(sp)
    80005510:	e5ce                	sd	s3,200(sp)
    80005512:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005514:	08000613          	li	a2,128
    80005518:	f3040593          	addi	a1,s0,-208
    8000551c:	4501                	li	a0,0
    8000551e:	ffffd097          	auipc	ra,0xffffd
    80005522:	650080e7          	jalr	1616(ra) # 80002b6e <argstr>
    80005526:	18054163          	bltz	a0,800056a8 <sys_unlink+0x1a2>
  begin_op();
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	bf8080e7          	jalr	-1032(ra) # 80004122 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005532:	fb040593          	addi	a1,s0,-80
    80005536:	f3040513          	addi	a0,s0,-208
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	a06080e7          	jalr	-1530(ra) # 80003f40 <nameiparent>
    80005542:	84aa                	mv	s1,a0
    80005544:	c979                	beqz	a0,8000561a <sys_unlink+0x114>
  ilock(dp);
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	236080e7          	jalr	566(ra) # 8000377c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000554e:	00003597          	auipc	a1,0x3
    80005552:	1d258593          	addi	a1,a1,466 # 80008720 <syscalls+0x2d0>
    80005556:	fb040513          	addi	a0,s0,-80
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	6ec080e7          	jalr	1772(ra) # 80003c46 <namecmp>
    80005562:	14050a63          	beqz	a0,800056b6 <sys_unlink+0x1b0>
    80005566:	00003597          	auipc	a1,0x3
    8000556a:	1c258593          	addi	a1,a1,450 # 80008728 <syscalls+0x2d8>
    8000556e:	fb040513          	addi	a0,s0,-80
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	6d4080e7          	jalr	1748(ra) # 80003c46 <namecmp>
    8000557a:	12050e63          	beqz	a0,800056b6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000557e:	f2c40613          	addi	a2,s0,-212
    80005582:	fb040593          	addi	a1,s0,-80
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	6d8080e7          	jalr	1752(ra) # 80003c60 <dirlookup>
    80005590:	892a                	mv	s2,a0
    80005592:	12050263          	beqz	a0,800056b6 <sys_unlink+0x1b0>
  ilock(ip);
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	1e6080e7          	jalr	486(ra) # 8000377c <ilock>
  if(ip->nlink < 1)
    8000559e:	04a91783          	lh	a5,74(s2)
    800055a2:	08f05263          	blez	a5,80005626 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055a6:	04491703          	lh	a4,68(s2)
    800055aa:	4785                	li	a5,1
    800055ac:	08f70563          	beq	a4,a5,80005636 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055b0:	4641                	li	a2,16
    800055b2:	4581                	li	a1,0
    800055b4:	fc040513          	addi	a0,s0,-64
    800055b8:	ffffb097          	auipc	ra,0xffffb
    800055bc:	716080e7          	jalr	1814(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055c0:	4741                	li	a4,16
    800055c2:	f2c42683          	lw	a3,-212(s0)
    800055c6:	fc040613          	addi	a2,s0,-64
    800055ca:	4581                	li	a1,0
    800055cc:	8526                	mv	a0,s1
    800055ce:	ffffe097          	auipc	ra,0xffffe
    800055d2:	55a080e7          	jalr	1370(ra) # 80003b28 <writei>
    800055d6:	47c1                	li	a5,16
    800055d8:	0af51563          	bne	a0,a5,80005682 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055dc:	04491703          	lh	a4,68(s2)
    800055e0:	4785                	li	a5,1
    800055e2:	0af70863          	beq	a4,a5,80005692 <sys_unlink+0x18c>
  iunlockput(dp);
    800055e6:	8526                	mv	a0,s1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	3f6080e7          	jalr	1014(ra) # 800039de <iunlockput>
  ip->nlink--;
    800055f0:	04a95783          	lhu	a5,74(s2)
    800055f4:	37fd                	addiw	a5,a5,-1
    800055f6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055fa:	854a                	mv	a0,s2
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	0b4080e7          	jalr	180(ra) # 800036b0 <iupdate>
  iunlockput(ip);
    80005604:	854a                	mv	a0,s2
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	3d8080e7          	jalr	984(ra) # 800039de <iunlockput>
  end_op();
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	b8e080e7          	jalr	-1138(ra) # 8000419c <end_op>
  return 0;
    80005616:	4501                	li	a0,0
    80005618:	a84d                	j	800056ca <sys_unlink+0x1c4>
    end_op();
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	b82080e7          	jalr	-1150(ra) # 8000419c <end_op>
    return -1;
    80005622:	557d                	li	a0,-1
    80005624:	a05d                	j	800056ca <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005626:	00003517          	auipc	a0,0x3
    8000562a:	10a50513          	addi	a0,a0,266 # 80008730 <syscalls+0x2e0>
    8000562e:	ffffb097          	auipc	ra,0xffffb
    80005632:	f0e080e7          	jalr	-242(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005636:	04c92703          	lw	a4,76(s2)
    8000563a:	02000793          	li	a5,32
    8000563e:	f6e7f9e3          	bgeu	a5,a4,800055b0 <sys_unlink+0xaa>
    80005642:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005646:	4741                	li	a4,16
    80005648:	86ce                	mv	a3,s3
    8000564a:	f1840613          	addi	a2,s0,-232
    8000564e:	4581                	li	a1,0
    80005650:	854a                	mv	a0,s2
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	3de080e7          	jalr	990(ra) # 80003a30 <readi>
    8000565a:	47c1                	li	a5,16
    8000565c:	00f51b63          	bne	a0,a5,80005672 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005660:	f1845783          	lhu	a5,-232(s0)
    80005664:	e7a1                	bnez	a5,800056ac <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005666:	29c1                	addiw	s3,s3,16
    80005668:	04c92783          	lw	a5,76(s2)
    8000566c:	fcf9ede3          	bltu	s3,a5,80005646 <sys_unlink+0x140>
    80005670:	b781                	j	800055b0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005672:	00003517          	auipc	a0,0x3
    80005676:	0d650513          	addi	a0,a0,214 # 80008748 <syscalls+0x2f8>
    8000567a:	ffffb097          	auipc	ra,0xffffb
    8000567e:	ec2080e7          	jalr	-318(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005682:	00003517          	auipc	a0,0x3
    80005686:	0de50513          	addi	a0,a0,222 # 80008760 <syscalls+0x310>
    8000568a:	ffffb097          	auipc	ra,0xffffb
    8000568e:	eb2080e7          	jalr	-334(ra) # 8000053c <panic>
    dp->nlink--;
    80005692:	04a4d783          	lhu	a5,74(s1)
    80005696:	37fd                	addiw	a5,a5,-1
    80005698:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	012080e7          	jalr	18(ra) # 800036b0 <iupdate>
    800056a6:	b781                	j	800055e6 <sys_unlink+0xe0>
    return -1;
    800056a8:	557d                	li	a0,-1
    800056aa:	a005                	j	800056ca <sys_unlink+0x1c4>
    iunlockput(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	330080e7          	jalr	816(ra) # 800039de <iunlockput>
  iunlockput(dp);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	326080e7          	jalr	806(ra) # 800039de <iunlockput>
  end_op();
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	adc080e7          	jalr	-1316(ra) # 8000419c <end_op>
  return -1;
    800056c8:	557d                	li	a0,-1
}
    800056ca:	70ae                	ld	ra,232(sp)
    800056cc:	740e                	ld	s0,224(sp)
    800056ce:	64ee                	ld	s1,216(sp)
    800056d0:	694e                	ld	s2,208(sp)
    800056d2:	69ae                	ld	s3,200(sp)
    800056d4:	616d                	addi	sp,sp,240
    800056d6:	8082                	ret

00000000800056d8 <sys_open>:

uint64
sys_open(void)
{
    800056d8:	7131                	addi	sp,sp,-192
    800056da:	fd06                	sd	ra,184(sp)
    800056dc:	f922                	sd	s0,176(sp)
    800056de:	f526                	sd	s1,168(sp)
    800056e0:	f14a                	sd	s2,160(sp)
    800056e2:	ed4e                	sd	s3,152(sp)
    800056e4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056e6:	f4c40593          	addi	a1,s0,-180
    800056ea:	4505                	li	a0,1
    800056ec:	ffffd097          	auipc	ra,0xffffd
    800056f0:	442080e7          	jalr	1090(ra) # 80002b2e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056f4:	08000613          	li	a2,128
    800056f8:	f5040593          	addi	a1,s0,-176
    800056fc:	4501                	li	a0,0
    800056fe:	ffffd097          	auipc	ra,0xffffd
    80005702:	470080e7          	jalr	1136(ra) # 80002b6e <argstr>
    80005706:	87aa                	mv	a5,a0
    return -1;
    80005708:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000570a:	0a07c863          	bltz	a5,800057ba <sys_open+0xe2>

  begin_op();
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	a14080e7          	jalr	-1516(ra) # 80004122 <begin_op>

  if(omode & O_CREATE){
    80005716:	f4c42783          	lw	a5,-180(s0)
    8000571a:	2007f793          	andi	a5,a5,512
    8000571e:	cbdd                	beqz	a5,800057d4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005720:	4681                	li	a3,0
    80005722:	4601                	li	a2,0
    80005724:	4589                	li	a1,2
    80005726:	f5040513          	addi	a0,s0,-176
    8000572a:	00000097          	auipc	ra,0x0
    8000572e:	97a080e7          	jalr	-1670(ra) # 800050a4 <create>
    80005732:	84aa                	mv	s1,a0
    if(ip == 0){
    80005734:	c951                	beqz	a0,800057c8 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005736:	04449703          	lh	a4,68(s1)
    8000573a:	478d                	li	a5,3
    8000573c:	00f71763          	bne	a4,a5,8000574a <sys_open+0x72>
    80005740:	0464d703          	lhu	a4,70(s1)
    80005744:	47a5                	li	a5,9
    80005746:	0ce7ec63          	bltu	a5,a4,8000581e <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	de0080e7          	jalr	-544(ra) # 8000452a <filealloc>
    80005752:	892a                	mv	s2,a0
    80005754:	c56d                	beqz	a0,8000583e <sys_open+0x166>
    80005756:	00000097          	auipc	ra,0x0
    8000575a:	90c080e7          	jalr	-1780(ra) # 80005062 <fdalloc>
    8000575e:	89aa                	mv	s3,a0
    80005760:	0c054a63          	bltz	a0,80005834 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005764:	04449703          	lh	a4,68(s1)
    80005768:	478d                	li	a5,3
    8000576a:	0ef70563          	beq	a4,a5,80005854 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000576e:	4789                	li	a5,2
    80005770:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005774:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005778:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000577c:	f4c42783          	lw	a5,-180(s0)
    80005780:	0017c713          	xori	a4,a5,1
    80005784:	8b05                	andi	a4,a4,1
    80005786:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000578a:	0037f713          	andi	a4,a5,3
    8000578e:	00e03733          	snez	a4,a4
    80005792:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005796:	4007f793          	andi	a5,a5,1024
    8000579a:	c791                	beqz	a5,800057a6 <sys_open+0xce>
    8000579c:	04449703          	lh	a4,68(s1)
    800057a0:	4789                	li	a5,2
    800057a2:	0cf70063          	beq	a4,a5,80005862 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	096080e7          	jalr	150(ra) # 8000383e <iunlock>
  end_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	9ec080e7          	jalr	-1556(ra) # 8000419c <end_op>

  return fd;
    800057b8:	854e                	mv	a0,s3
}
    800057ba:	70ea                	ld	ra,184(sp)
    800057bc:	744a                	ld	s0,176(sp)
    800057be:	74aa                	ld	s1,168(sp)
    800057c0:	790a                	ld	s2,160(sp)
    800057c2:	69ea                	ld	s3,152(sp)
    800057c4:	6129                	addi	sp,sp,192
    800057c6:	8082                	ret
      end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	9d4080e7          	jalr	-1580(ra) # 8000419c <end_op>
      return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	b7e5                	j	800057ba <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057d4:	f5040513          	addi	a0,s0,-176
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	74a080e7          	jalr	1866(ra) # 80003f22 <namei>
    800057e0:	84aa                	mv	s1,a0
    800057e2:	c905                	beqz	a0,80005812 <sys_open+0x13a>
    ilock(ip);
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	f98080e7          	jalr	-104(ra) # 8000377c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057ec:	04449703          	lh	a4,68(s1)
    800057f0:	4785                	li	a5,1
    800057f2:	f4f712e3          	bne	a4,a5,80005736 <sys_open+0x5e>
    800057f6:	f4c42783          	lw	a5,-180(s0)
    800057fa:	dba1                	beqz	a5,8000574a <sys_open+0x72>
      iunlockput(ip);
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	1e0080e7          	jalr	480(ra) # 800039de <iunlockput>
      end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	996080e7          	jalr	-1642(ra) # 8000419c <end_op>
      return -1;
    8000580e:	557d                	li	a0,-1
    80005810:	b76d                	j	800057ba <sys_open+0xe2>
      end_op();
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	98a080e7          	jalr	-1654(ra) # 8000419c <end_op>
      return -1;
    8000581a:	557d                	li	a0,-1
    8000581c:	bf79                	j	800057ba <sys_open+0xe2>
    iunlockput(ip);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	1be080e7          	jalr	446(ra) # 800039de <iunlockput>
    end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	974080e7          	jalr	-1676(ra) # 8000419c <end_op>
    return -1;
    80005830:	557d                	li	a0,-1
    80005832:	b761                	j	800057ba <sys_open+0xe2>
      fileclose(f);
    80005834:	854a                	mv	a0,s2
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	db0080e7          	jalr	-592(ra) # 800045e6 <fileclose>
    iunlockput(ip);
    8000583e:	8526                	mv	a0,s1
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	19e080e7          	jalr	414(ra) # 800039de <iunlockput>
    end_op();
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	954080e7          	jalr	-1708(ra) # 8000419c <end_op>
    return -1;
    80005850:	557d                	li	a0,-1
    80005852:	b7a5                	j	800057ba <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005854:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005858:	04649783          	lh	a5,70(s1)
    8000585c:	02f91223          	sh	a5,36(s2)
    80005860:	bf21                	j	80005778 <sys_open+0xa0>
    itrunc(ip);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	026080e7          	jalr	38(ra) # 8000388a <itrunc>
    8000586c:	bf2d                	j	800057a6 <sys_open+0xce>

000000008000586e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000586e:	7175                	addi	sp,sp,-144
    80005870:	e506                	sd	ra,136(sp)
    80005872:	e122                	sd	s0,128(sp)
    80005874:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	8ac080e7          	jalr	-1876(ra) # 80004122 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000587e:	08000613          	li	a2,128
    80005882:	f7040593          	addi	a1,s0,-144
    80005886:	4501                	li	a0,0
    80005888:	ffffd097          	auipc	ra,0xffffd
    8000588c:	2e6080e7          	jalr	742(ra) # 80002b6e <argstr>
    80005890:	02054963          	bltz	a0,800058c2 <sys_mkdir+0x54>
    80005894:	4681                	li	a3,0
    80005896:	4601                	li	a2,0
    80005898:	4585                	li	a1,1
    8000589a:	f7040513          	addi	a0,s0,-144
    8000589e:	00000097          	auipc	ra,0x0
    800058a2:	806080e7          	jalr	-2042(ra) # 800050a4 <create>
    800058a6:	cd11                	beqz	a0,800058c2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	136080e7          	jalr	310(ra) # 800039de <iunlockput>
  end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	8ec080e7          	jalr	-1812(ra) # 8000419c <end_op>
  return 0;
    800058b8:	4501                	li	a0,0
}
    800058ba:	60aa                	ld	ra,136(sp)
    800058bc:	640a                	ld	s0,128(sp)
    800058be:	6149                	addi	sp,sp,144
    800058c0:	8082                	ret
    end_op();
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	8da080e7          	jalr	-1830(ra) # 8000419c <end_op>
    return -1;
    800058ca:	557d                	li	a0,-1
    800058cc:	b7fd                	j	800058ba <sys_mkdir+0x4c>

00000000800058ce <sys_mknod>:

uint64
sys_mknod(void)
{
    800058ce:	7135                	addi	sp,sp,-160
    800058d0:	ed06                	sd	ra,152(sp)
    800058d2:	e922                	sd	s0,144(sp)
    800058d4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	84c080e7          	jalr	-1972(ra) # 80004122 <begin_op>
  argint(1, &major);
    800058de:	f6c40593          	addi	a1,s0,-148
    800058e2:	4505                	li	a0,1
    800058e4:	ffffd097          	auipc	ra,0xffffd
    800058e8:	24a080e7          	jalr	586(ra) # 80002b2e <argint>
  argint(2, &minor);
    800058ec:	f6840593          	addi	a1,s0,-152
    800058f0:	4509                	li	a0,2
    800058f2:	ffffd097          	auipc	ra,0xffffd
    800058f6:	23c080e7          	jalr	572(ra) # 80002b2e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058fa:	08000613          	li	a2,128
    800058fe:	f7040593          	addi	a1,s0,-144
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	26a080e7          	jalr	618(ra) # 80002b6e <argstr>
    8000590c:	02054b63          	bltz	a0,80005942 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005910:	f6841683          	lh	a3,-152(s0)
    80005914:	f6c41603          	lh	a2,-148(s0)
    80005918:	458d                	li	a1,3
    8000591a:	f7040513          	addi	a0,s0,-144
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	786080e7          	jalr	1926(ra) # 800050a4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005926:	cd11                	beqz	a0,80005942 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	0b6080e7          	jalr	182(ra) # 800039de <iunlockput>
  end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	86c080e7          	jalr	-1940(ra) # 8000419c <end_op>
  return 0;
    80005938:	4501                	li	a0,0
}
    8000593a:	60ea                	ld	ra,152(sp)
    8000593c:	644a                	ld	s0,144(sp)
    8000593e:	610d                	addi	sp,sp,160
    80005940:	8082                	ret
    end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	85a080e7          	jalr	-1958(ra) # 8000419c <end_op>
    return -1;
    8000594a:	557d                	li	a0,-1
    8000594c:	b7fd                	j	8000593a <sys_mknod+0x6c>

000000008000594e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000594e:	7135                	addi	sp,sp,-160
    80005950:	ed06                	sd	ra,152(sp)
    80005952:	e922                	sd	s0,144(sp)
    80005954:	e526                	sd	s1,136(sp)
    80005956:	e14a                	sd	s2,128(sp)
    80005958:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000595a:	ffffc097          	auipc	ra,0xffffc
    8000595e:	04c080e7          	jalr	76(ra) # 800019a6 <myproc>
    80005962:	892a                	mv	s2,a0
  
  begin_op();
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	7be080e7          	jalr	1982(ra) # 80004122 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000596c:	08000613          	li	a2,128
    80005970:	f6040593          	addi	a1,s0,-160
    80005974:	4501                	li	a0,0
    80005976:	ffffd097          	auipc	ra,0xffffd
    8000597a:	1f8080e7          	jalr	504(ra) # 80002b6e <argstr>
    8000597e:	04054b63          	bltz	a0,800059d4 <sys_chdir+0x86>
    80005982:	f6040513          	addi	a0,s0,-160
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	59c080e7          	jalr	1436(ra) # 80003f22 <namei>
    8000598e:	84aa                	mv	s1,a0
    80005990:	c131                	beqz	a0,800059d4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	dea080e7          	jalr	-534(ra) # 8000377c <ilock>
  if(ip->type != T_DIR){
    8000599a:	04449703          	lh	a4,68(s1)
    8000599e:	4785                	li	a5,1
    800059a0:	04f71063          	bne	a4,a5,800059e0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	e98080e7          	jalr	-360(ra) # 8000383e <iunlock>
  iput(p->cwd);
    800059ae:	15093503          	ld	a0,336(s2)
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	f84080e7          	jalr	-124(ra) # 80003936 <iput>
  end_op();
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	7e2080e7          	jalr	2018(ra) # 8000419c <end_op>
  p->cwd = ip;
    800059c2:	14993823          	sd	s1,336(s2)
  return 0;
    800059c6:	4501                	li	a0,0
}
    800059c8:	60ea                	ld	ra,152(sp)
    800059ca:	644a                	ld	s0,144(sp)
    800059cc:	64aa                	ld	s1,136(sp)
    800059ce:	690a                	ld	s2,128(sp)
    800059d0:	610d                	addi	sp,sp,160
    800059d2:	8082                	ret
    end_op();
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	7c8080e7          	jalr	1992(ra) # 8000419c <end_op>
    return -1;
    800059dc:	557d                	li	a0,-1
    800059de:	b7ed                	j	800059c8 <sys_chdir+0x7a>
    iunlockput(ip);
    800059e0:	8526                	mv	a0,s1
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	ffc080e7          	jalr	-4(ra) # 800039de <iunlockput>
    end_op();
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	7b2080e7          	jalr	1970(ra) # 8000419c <end_op>
    return -1;
    800059f2:	557d                	li	a0,-1
    800059f4:	bfd1                	j	800059c8 <sys_chdir+0x7a>

00000000800059f6 <sys_exec>:

uint64
sys_exec(void)
{
    800059f6:	7121                	addi	sp,sp,-448
    800059f8:	ff06                	sd	ra,440(sp)
    800059fa:	fb22                	sd	s0,432(sp)
    800059fc:	f726                	sd	s1,424(sp)
    800059fe:	f34a                	sd	s2,416(sp)
    80005a00:	ef4e                	sd	s3,408(sp)
    80005a02:	eb52                	sd	s4,400(sp)
    80005a04:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a06:	e4840593          	addi	a1,s0,-440
    80005a0a:	4505                	li	a0,1
    80005a0c:	ffffd097          	auipc	ra,0xffffd
    80005a10:	142080e7          	jalr	322(ra) # 80002b4e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a14:	08000613          	li	a2,128
    80005a18:	f5040593          	addi	a1,s0,-176
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	150080e7          	jalr	336(ra) # 80002b6e <argstr>
    80005a26:	87aa                	mv	a5,a0
    return -1;
    80005a28:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a2a:	0c07c263          	bltz	a5,80005aee <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a2e:	10000613          	li	a2,256
    80005a32:	4581                	li	a1,0
    80005a34:	e5040513          	addi	a0,s0,-432
    80005a38:	ffffb097          	auipc	ra,0xffffb
    80005a3c:	296080e7          	jalr	662(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a40:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a44:	89a6                	mv	s3,s1
    80005a46:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a48:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a4c:	00391513          	slli	a0,s2,0x3
    80005a50:	e4040593          	addi	a1,s0,-448
    80005a54:	e4843783          	ld	a5,-440(s0)
    80005a58:	953e                	add	a0,a0,a5
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	036080e7          	jalr	54(ra) # 80002a90 <fetchaddr>
    80005a62:	02054a63          	bltz	a0,80005a96 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a66:	e4043783          	ld	a5,-448(s0)
    80005a6a:	c3b9                	beqz	a5,80005ab0 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	076080e7          	jalr	118(ra) # 80000ae2 <kalloc>
    80005a74:	85aa                	mv	a1,a0
    80005a76:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a7a:	cd11                	beqz	a0,80005a96 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a7c:	6605                	lui	a2,0x1
    80005a7e:	e4043503          	ld	a0,-448(s0)
    80005a82:	ffffd097          	auipc	ra,0xffffd
    80005a86:	060080e7          	jalr	96(ra) # 80002ae2 <fetchstr>
    80005a8a:	00054663          	bltz	a0,80005a96 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005a8e:	0905                	addi	s2,s2,1
    80005a90:	09a1                	addi	s3,s3,8
    80005a92:	fb491de3          	bne	s2,s4,80005a4c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a96:	f5040913          	addi	s2,s0,-176
    80005a9a:	6088                	ld	a0,0(s1)
    80005a9c:	c921                	beqz	a0,80005aec <sys_exec+0xf6>
    kfree(argv[i]);
    80005a9e:	ffffb097          	auipc	ra,0xffffb
    80005aa2:	f46080e7          	jalr	-186(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa6:	04a1                	addi	s1,s1,8
    80005aa8:	ff2499e3          	bne	s1,s2,80005a9a <sys_exec+0xa4>
  return -1;
    80005aac:	557d                	li	a0,-1
    80005aae:	a081                	j	80005aee <sys_exec+0xf8>
      argv[i] = 0;
    80005ab0:	0009079b          	sext.w	a5,s2
    80005ab4:	078e                	slli	a5,a5,0x3
    80005ab6:	fd078793          	addi	a5,a5,-48
    80005aba:	97a2                	add	a5,a5,s0
    80005abc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ac0:	e5040593          	addi	a1,s0,-432
    80005ac4:	f5040513          	addi	a0,s0,-176
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	194080e7          	jalr	404(ra) # 80004c5c <exec>
    80005ad0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad2:	f5040993          	addi	s3,s0,-176
    80005ad6:	6088                	ld	a0,0(s1)
    80005ad8:	c901                	beqz	a0,80005ae8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005ada:	ffffb097          	auipc	ra,0xffffb
    80005ade:	f0a080e7          	jalr	-246(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae2:	04a1                	addi	s1,s1,8
    80005ae4:	ff3499e3          	bne	s1,s3,80005ad6 <sys_exec+0xe0>
  return ret;
    80005ae8:	854a                	mv	a0,s2
    80005aea:	a011                	j	80005aee <sys_exec+0xf8>
  return -1;
    80005aec:	557d                	li	a0,-1
}
    80005aee:	70fa                	ld	ra,440(sp)
    80005af0:	745a                	ld	s0,432(sp)
    80005af2:	74ba                	ld	s1,424(sp)
    80005af4:	791a                	ld	s2,416(sp)
    80005af6:	69fa                	ld	s3,408(sp)
    80005af8:	6a5a                	ld	s4,400(sp)
    80005afa:	6139                	addi	sp,sp,448
    80005afc:	8082                	ret

0000000080005afe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005afe:	7139                	addi	sp,sp,-64
    80005b00:	fc06                	sd	ra,56(sp)
    80005b02:	f822                	sd	s0,48(sp)
    80005b04:	f426                	sd	s1,40(sp)
    80005b06:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b08:	ffffc097          	auipc	ra,0xffffc
    80005b0c:	e9e080e7          	jalr	-354(ra) # 800019a6 <myproc>
    80005b10:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b12:	fd840593          	addi	a1,s0,-40
    80005b16:	4501                	li	a0,0
    80005b18:	ffffd097          	auipc	ra,0xffffd
    80005b1c:	036080e7          	jalr	54(ra) # 80002b4e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b20:	fc840593          	addi	a1,s0,-56
    80005b24:	fd040513          	addi	a0,s0,-48
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	dea080e7          	jalr	-534(ra) # 80004912 <pipealloc>
    return -1;
    80005b30:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b32:	0c054463          	bltz	a0,80005bfa <sys_pipe+0xfc>
  fd0 = -1;
    80005b36:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b3a:	fd043503          	ld	a0,-48(s0)
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	524080e7          	jalr	1316(ra) # 80005062 <fdalloc>
    80005b46:	fca42223          	sw	a0,-60(s0)
    80005b4a:	08054b63          	bltz	a0,80005be0 <sys_pipe+0xe2>
    80005b4e:	fc843503          	ld	a0,-56(s0)
    80005b52:	fffff097          	auipc	ra,0xfffff
    80005b56:	510080e7          	jalr	1296(ra) # 80005062 <fdalloc>
    80005b5a:	fca42023          	sw	a0,-64(s0)
    80005b5e:	06054863          	bltz	a0,80005bce <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b62:	4691                	li	a3,4
    80005b64:	fc440613          	addi	a2,s0,-60
    80005b68:	fd843583          	ld	a1,-40(s0)
    80005b6c:	68a8                	ld	a0,80(s1)
    80005b6e:	ffffc097          	auipc	ra,0xffffc
    80005b72:	af8080e7          	jalr	-1288(ra) # 80001666 <copyout>
    80005b76:	02054063          	bltz	a0,80005b96 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b7a:	4691                	li	a3,4
    80005b7c:	fc040613          	addi	a2,s0,-64
    80005b80:	fd843583          	ld	a1,-40(s0)
    80005b84:	0591                	addi	a1,a1,4
    80005b86:	68a8                	ld	a0,80(s1)
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	ade080e7          	jalr	-1314(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b90:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b92:	06055463          	bgez	a0,80005bfa <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b96:	fc442783          	lw	a5,-60(s0)
    80005b9a:	07e9                	addi	a5,a5,26
    80005b9c:	078e                	slli	a5,a5,0x3
    80005b9e:	97a6                	add	a5,a5,s1
    80005ba0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ba4:	fc042783          	lw	a5,-64(s0)
    80005ba8:	07e9                	addi	a5,a5,26
    80005baa:	078e                	slli	a5,a5,0x3
    80005bac:	94be                	add	s1,s1,a5
    80005bae:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bb2:	fd043503          	ld	a0,-48(s0)
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	a30080e7          	jalr	-1488(ra) # 800045e6 <fileclose>
    fileclose(wf);
    80005bbe:	fc843503          	ld	a0,-56(s0)
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	a24080e7          	jalr	-1500(ra) # 800045e6 <fileclose>
    return -1;
    80005bca:	57fd                	li	a5,-1
    80005bcc:	a03d                	j	80005bfa <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bce:	fc442783          	lw	a5,-60(s0)
    80005bd2:	0007c763          	bltz	a5,80005be0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bd6:	07e9                	addi	a5,a5,26
    80005bd8:	078e                	slli	a5,a5,0x3
    80005bda:	97a6                	add	a5,a5,s1
    80005bdc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005be0:	fd043503          	ld	a0,-48(s0)
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	a02080e7          	jalr	-1534(ra) # 800045e6 <fileclose>
    fileclose(wf);
    80005bec:	fc843503          	ld	a0,-56(s0)
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	9f6080e7          	jalr	-1546(ra) # 800045e6 <fileclose>
    return -1;
    80005bf8:	57fd                	li	a5,-1
}
    80005bfa:	853e                	mv	a0,a5
    80005bfc:	70e2                	ld	ra,56(sp)
    80005bfe:	7442                	ld	s0,48(sp)
    80005c00:	74a2                	ld	s1,40(sp)
    80005c02:	6121                	addi	sp,sp,64
    80005c04:	8082                	ret
	...

0000000080005c10 <kernelvec>:
    80005c10:	7111                	addi	sp,sp,-256
    80005c12:	e006                	sd	ra,0(sp)
    80005c14:	e40a                	sd	sp,8(sp)
    80005c16:	e80e                	sd	gp,16(sp)
    80005c18:	ec12                	sd	tp,24(sp)
    80005c1a:	f016                	sd	t0,32(sp)
    80005c1c:	f41a                	sd	t1,40(sp)
    80005c1e:	f81e                	sd	t2,48(sp)
    80005c20:	fc22                	sd	s0,56(sp)
    80005c22:	e0a6                	sd	s1,64(sp)
    80005c24:	e4aa                	sd	a0,72(sp)
    80005c26:	e8ae                	sd	a1,80(sp)
    80005c28:	ecb2                	sd	a2,88(sp)
    80005c2a:	f0b6                	sd	a3,96(sp)
    80005c2c:	f4ba                	sd	a4,104(sp)
    80005c2e:	f8be                	sd	a5,112(sp)
    80005c30:	fcc2                	sd	a6,120(sp)
    80005c32:	e146                	sd	a7,128(sp)
    80005c34:	e54a                	sd	s2,136(sp)
    80005c36:	e94e                	sd	s3,144(sp)
    80005c38:	ed52                	sd	s4,152(sp)
    80005c3a:	f156                	sd	s5,160(sp)
    80005c3c:	f55a                	sd	s6,168(sp)
    80005c3e:	f95e                	sd	s7,176(sp)
    80005c40:	fd62                	sd	s8,184(sp)
    80005c42:	e1e6                	sd	s9,192(sp)
    80005c44:	e5ea                	sd	s10,200(sp)
    80005c46:	e9ee                	sd	s11,208(sp)
    80005c48:	edf2                	sd	t3,216(sp)
    80005c4a:	f1f6                	sd	t4,224(sp)
    80005c4c:	f5fa                	sd	t5,232(sp)
    80005c4e:	f9fe                	sd	t6,240(sp)
    80005c50:	d0dfc0ef          	jal	ra,8000295c <kerneltrap>
    80005c54:	6082                	ld	ra,0(sp)
    80005c56:	6122                	ld	sp,8(sp)
    80005c58:	61c2                	ld	gp,16(sp)
    80005c5a:	7282                	ld	t0,32(sp)
    80005c5c:	7322                	ld	t1,40(sp)
    80005c5e:	73c2                	ld	t2,48(sp)
    80005c60:	7462                	ld	s0,56(sp)
    80005c62:	6486                	ld	s1,64(sp)
    80005c64:	6526                	ld	a0,72(sp)
    80005c66:	65c6                	ld	a1,80(sp)
    80005c68:	6666                	ld	a2,88(sp)
    80005c6a:	7686                	ld	a3,96(sp)
    80005c6c:	7726                	ld	a4,104(sp)
    80005c6e:	77c6                	ld	a5,112(sp)
    80005c70:	7866                	ld	a6,120(sp)
    80005c72:	688a                	ld	a7,128(sp)
    80005c74:	692a                	ld	s2,136(sp)
    80005c76:	69ca                	ld	s3,144(sp)
    80005c78:	6a6a                	ld	s4,152(sp)
    80005c7a:	7a8a                	ld	s5,160(sp)
    80005c7c:	7b2a                	ld	s6,168(sp)
    80005c7e:	7bca                	ld	s7,176(sp)
    80005c80:	7c6a                	ld	s8,184(sp)
    80005c82:	6c8e                	ld	s9,192(sp)
    80005c84:	6d2e                	ld	s10,200(sp)
    80005c86:	6dce                	ld	s11,208(sp)
    80005c88:	6e6e                	ld	t3,216(sp)
    80005c8a:	7e8e                	ld	t4,224(sp)
    80005c8c:	7f2e                	ld	t5,232(sp)
    80005c8e:	7fce                	ld	t6,240(sp)
    80005c90:	6111                	addi	sp,sp,256
    80005c92:	10200073          	sret
    80005c96:	00000013          	nop
    80005c9a:	00000013          	nop
    80005c9e:	0001                	nop

0000000080005ca0 <timervec>:
    80005ca0:	34051573          	csrrw	a0,mscratch,a0
    80005ca4:	e10c                	sd	a1,0(a0)
    80005ca6:	e510                	sd	a2,8(a0)
    80005ca8:	e914                	sd	a3,16(a0)
    80005caa:	6d0c                	ld	a1,24(a0)
    80005cac:	7110                	ld	a2,32(a0)
    80005cae:	6194                	ld	a3,0(a1)
    80005cb0:	96b2                	add	a3,a3,a2
    80005cb2:	e194                	sd	a3,0(a1)
    80005cb4:	4589                	li	a1,2
    80005cb6:	14459073          	csrw	sip,a1
    80005cba:	6914                	ld	a3,16(a0)
    80005cbc:	6510                	ld	a2,8(a0)
    80005cbe:	610c                	ld	a1,0(a0)
    80005cc0:	34051573          	csrrw	a0,mscratch,a0
    80005cc4:	30200073          	mret
	...

0000000080005cca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cca:	1141                	addi	sp,sp,-16
    80005ccc:	e422                	sd	s0,8(sp)
    80005cce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cd0:	0c0007b7          	lui	a5,0xc000
    80005cd4:	4705                	li	a4,1
    80005cd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cd8:	c3d8                	sw	a4,4(a5)
}
    80005cda:	6422                	ld	s0,8(sp)
    80005cdc:	0141                	addi	sp,sp,16
    80005cde:	8082                	ret

0000000080005ce0 <plicinithart>:

void
plicinithart(void)
{
    80005ce0:	1141                	addi	sp,sp,-16
    80005ce2:	e406                	sd	ra,8(sp)
    80005ce4:	e022                	sd	s0,0(sp)
    80005ce6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce8:	ffffc097          	auipc	ra,0xffffc
    80005cec:	c92080e7          	jalr	-878(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cf0:	0085171b          	slliw	a4,a0,0x8
    80005cf4:	0c0027b7          	lui	a5,0xc002
    80005cf8:	97ba                	add	a5,a5,a4
    80005cfa:	40200713          	li	a4,1026
    80005cfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d02:	00d5151b          	slliw	a0,a0,0xd
    80005d06:	0c2017b7          	lui	a5,0xc201
    80005d0a:	97aa                	add	a5,a5,a0
    80005d0c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d10:	60a2                	ld	ra,8(sp)
    80005d12:	6402                	ld	s0,0(sp)
    80005d14:	0141                	addi	sp,sp,16
    80005d16:	8082                	ret

0000000080005d18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d18:	1141                	addi	sp,sp,-16
    80005d1a:	e406                	sd	ra,8(sp)
    80005d1c:	e022                	sd	s0,0(sp)
    80005d1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d20:	ffffc097          	auipc	ra,0xffffc
    80005d24:	c5a080e7          	jalr	-934(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d28:	00d5151b          	slliw	a0,a0,0xd
    80005d2c:	0c2017b7          	lui	a5,0xc201
    80005d30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d32:	43c8                	lw	a0,4(a5)
    80005d34:	60a2                	ld	ra,8(sp)
    80005d36:	6402                	ld	s0,0(sp)
    80005d38:	0141                	addi	sp,sp,16
    80005d3a:	8082                	ret

0000000080005d3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d3c:	1101                	addi	sp,sp,-32
    80005d3e:	ec06                	sd	ra,24(sp)
    80005d40:	e822                	sd	s0,16(sp)
    80005d42:	e426                	sd	s1,8(sp)
    80005d44:	1000                	addi	s0,sp,32
    80005d46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	c32080e7          	jalr	-974(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d50:	00d5151b          	slliw	a0,a0,0xd
    80005d54:	0c2017b7          	lui	a5,0xc201
    80005d58:	97aa                	add	a5,a5,a0
    80005d5a:	c3c4                	sw	s1,4(a5)
}
    80005d5c:	60e2                	ld	ra,24(sp)
    80005d5e:	6442                	ld	s0,16(sp)
    80005d60:	64a2                	ld	s1,8(sp)
    80005d62:	6105                	addi	sp,sp,32
    80005d64:	8082                	ret

0000000080005d66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d66:	1141                	addi	sp,sp,-16
    80005d68:	e406                	sd	ra,8(sp)
    80005d6a:	e022                	sd	s0,0(sp)
    80005d6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d6e:	479d                	li	a5,7
    80005d70:	04a7cc63          	blt	a5,a0,80005dc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d74:	0001c797          	auipc	a5,0x1c
    80005d78:	ecc78793          	addi	a5,a5,-308 # 80021c40 <disk>
    80005d7c:	97aa                	add	a5,a5,a0
    80005d7e:	0187c783          	lbu	a5,24(a5)
    80005d82:	ebb9                	bnez	a5,80005dd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d84:	00451693          	slli	a3,a0,0x4
    80005d88:	0001c797          	auipc	a5,0x1c
    80005d8c:	eb878793          	addi	a5,a5,-328 # 80021c40 <disk>
    80005d90:	6398                	ld	a4,0(a5)
    80005d92:	9736                	add	a4,a4,a3
    80005d94:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d98:	6398                	ld	a4,0(a5)
    80005d9a:	9736                	add	a4,a4,a3
    80005d9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005da0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005da4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005da8:	97aa                	add	a5,a5,a0
    80005daa:	4705                	li	a4,1
    80005dac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005db0:	0001c517          	auipc	a0,0x1c
    80005db4:	ea850513          	addi	a0,a0,-344 # 80021c58 <disk+0x18>
    80005db8:	ffffc097          	auipc	ra,0xffffc
    80005dbc:	368080e7          	jalr	872(ra) # 80002120 <wakeup>
}
    80005dc0:	60a2                	ld	ra,8(sp)
    80005dc2:	6402                	ld	s0,0(sp)
    80005dc4:	0141                	addi	sp,sp,16
    80005dc6:	8082                	ret
    panic("free_desc 1");
    80005dc8:	00003517          	auipc	a0,0x3
    80005dcc:	9a850513          	addi	a0,a0,-1624 # 80008770 <syscalls+0x320>
    80005dd0:	ffffa097          	auipc	ra,0xffffa
    80005dd4:	76c080e7          	jalr	1900(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005dd8:	00003517          	auipc	a0,0x3
    80005ddc:	9a850513          	addi	a0,a0,-1624 # 80008780 <syscalls+0x330>
    80005de0:	ffffa097          	auipc	ra,0xffffa
    80005de4:	75c080e7          	jalr	1884(ra) # 8000053c <panic>

0000000080005de8 <virtio_disk_init>:
{
    80005de8:	1101                	addi	sp,sp,-32
    80005dea:	ec06                	sd	ra,24(sp)
    80005dec:	e822                	sd	s0,16(sp)
    80005dee:	e426                	sd	s1,8(sp)
    80005df0:	e04a                	sd	s2,0(sp)
    80005df2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005df4:	00003597          	auipc	a1,0x3
    80005df8:	99c58593          	addi	a1,a1,-1636 # 80008790 <syscalls+0x340>
    80005dfc:	0001c517          	auipc	a0,0x1c
    80005e00:	f6c50513          	addi	a0,a0,-148 # 80021d68 <disk+0x128>
    80005e04:	ffffb097          	auipc	ra,0xffffb
    80005e08:	d3e080e7          	jalr	-706(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e0c:	100017b7          	lui	a5,0x10001
    80005e10:	4398                	lw	a4,0(a5)
    80005e12:	2701                	sext.w	a4,a4
    80005e14:	747277b7          	lui	a5,0x74727
    80005e18:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e1c:	14f71b63          	bne	a4,a5,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e20:	100017b7          	lui	a5,0x10001
    80005e24:	43dc                	lw	a5,4(a5)
    80005e26:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e28:	4709                	li	a4,2
    80005e2a:	14e79463          	bne	a5,a4,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e2e:	100017b7          	lui	a5,0x10001
    80005e32:	479c                	lw	a5,8(a5)
    80005e34:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e36:	12e79e63          	bne	a5,a4,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e3a:	100017b7          	lui	a5,0x10001
    80005e3e:	47d8                	lw	a4,12(a5)
    80005e40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e42:	554d47b7          	lui	a5,0x554d4
    80005e46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e4a:	12f71463          	bne	a4,a5,80005f72 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e4e:	100017b7          	lui	a5,0x10001
    80005e52:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e56:	4705                	li	a4,1
    80005e58:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e5a:	470d                	li	a4,3
    80005e5c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e5e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9df>
    80005e68:	8f75                	and	a4,a4,a3
    80005e6a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e6c:	472d                	li	a4,11
    80005e6e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e70:	5bbc                	lw	a5,112(a5)
    80005e72:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e76:	8ba1                	andi	a5,a5,8
    80005e78:	10078563          	beqz	a5,80005f82 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e7c:	100017b7          	lui	a5,0x10001
    80005e80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e84:	43fc                	lw	a5,68(a5)
    80005e86:	2781                	sext.w	a5,a5
    80005e88:	10079563          	bnez	a5,80005f92 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e8c:	100017b7          	lui	a5,0x10001
    80005e90:	5bdc                	lw	a5,52(a5)
    80005e92:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e94:	10078763          	beqz	a5,80005fa2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e98:	471d                	li	a4,7
    80005e9a:	10f77c63          	bgeu	a4,a5,80005fb2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e9e:	ffffb097          	auipc	ra,0xffffb
    80005ea2:	c44080e7          	jalr	-956(ra) # 80000ae2 <kalloc>
    80005ea6:	0001c497          	auipc	s1,0x1c
    80005eaa:	d9a48493          	addi	s1,s1,-614 # 80021c40 <disk>
    80005eae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	c32080e7          	jalr	-974(ra) # 80000ae2 <kalloc>
    80005eb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	c28080e7          	jalr	-984(ra) # 80000ae2 <kalloc>
    80005ec2:	87aa                	mv	a5,a0
    80005ec4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ec6:	6088                	ld	a0,0(s1)
    80005ec8:	cd6d                	beqz	a0,80005fc2 <virtio_disk_init+0x1da>
    80005eca:	0001c717          	auipc	a4,0x1c
    80005ece:	d7e73703          	ld	a4,-642(a4) # 80021c48 <disk+0x8>
    80005ed2:	cb65                	beqz	a4,80005fc2 <virtio_disk_init+0x1da>
    80005ed4:	c7fd                	beqz	a5,80005fc2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ed6:	6605                	lui	a2,0x1
    80005ed8:	4581                	li	a1,0
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	df4080e7          	jalr	-524(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ee2:	0001c497          	auipc	s1,0x1c
    80005ee6:	d5e48493          	addi	s1,s1,-674 # 80021c40 <disk>
    80005eea:	6605                	lui	a2,0x1
    80005eec:	4581                	li	a1,0
    80005eee:	6488                	ld	a0,8(s1)
    80005ef0:	ffffb097          	auipc	ra,0xffffb
    80005ef4:	dde080e7          	jalr	-546(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005ef8:	6605                	lui	a2,0x1
    80005efa:	4581                	li	a1,0
    80005efc:	6888                	ld	a0,16(s1)
    80005efe:	ffffb097          	auipc	ra,0xffffb
    80005f02:	dd0080e7          	jalr	-560(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f06:	100017b7          	lui	a5,0x10001
    80005f0a:	4721                	li	a4,8
    80005f0c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f0e:	4098                	lw	a4,0(s1)
    80005f10:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f14:	40d8                	lw	a4,4(s1)
    80005f16:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f1a:	6498                	ld	a4,8(s1)
    80005f1c:	0007069b          	sext.w	a3,a4
    80005f20:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f24:	9701                	srai	a4,a4,0x20
    80005f26:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f2a:	6898                	ld	a4,16(s1)
    80005f2c:	0007069b          	sext.w	a3,a4
    80005f30:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f34:	9701                	srai	a4,a4,0x20
    80005f36:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f3a:	4705                	li	a4,1
    80005f3c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f3e:	00e48c23          	sb	a4,24(s1)
    80005f42:	00e48ca3          	sb	a4,25(s1)
    80005f46:	00e48d23          	sb	a4,26(s1)
    80005f4a:	00e48da3          	sb	a4,27(s1)
    80005f4e:	00e48e23          	sb	a4,28(s1)
    80005f52:	00e48ea3          	sb	a4,29(s1)
    80005f56:	00e48f23          	sb	a4,30(s1)
    80005f5a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f5e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f62:	0727a823          	sw	s2,112(a5)
}
    80005f66:	60e2                	ld	ra,24(sp)
    80005f68:	6442                	ld	s0,16(sp)
    80005f6a:	64a2                	ld	s1,8(sp)
    80005f6c:	6902                	ld	s2,0(sp)
    80005f6e:	6105                	addi	sp,sp,32
    80005f70:	8082                	ret
    panic("could not find virtio disk");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	82e50513          	addi	a0,a0,-2002 # 800087a0 <syscalls+0x350>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c2080e7          	jalr	1474(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	83e50513          	addi	a0,a0,-1986 # 800087c0 <syscalls+0x370>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b2080e7          	jalr	1458(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	84e50513          	addi	a0,a0,-1970 # 800087e0 <syscalls+0x390>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	85e50513          	addi	a0,a0,-1954 # 80008800 <syscalls+0x3b0>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	86e50513          	addi	a0,a0,-1938 # 80008820 <syscalls+0x3d0>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	87e50513          	addi	a0,a0,-1922 # 80008840 <syscalls+0x3f0>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>

0000000080005fd2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fd2:	7159                	addi	sp,sp,-112
    80005fd4:	f486                	sd	ra,104(sp)
    80005fd6:	f0a2                	sd	s0,96(sp)
    80005fd8:	eca6                	sd	s1,88(sp)
    80005fda:	e8ca                	sd	s2,80(sp)
    80005fdc:	e4ce                	sd	s3,72(sp)
    80005fde:	e0d2                	sd	s4,64(sp)
    80005fe0:	fc56                	sd	s5,56(sp)
    80005fe2:	f85a                	sd	s6,48(sp)
    80005fe4:	f45e                	sd	s7,40(sp)
    80005fe6:	f062                	sd	s8,32(sp)
    80005fe8:	ec66                	sd	s9,24(sp)
    80005fea:	e86a                	sd	s10,16(sp)
    80005fec:	1880                	addi	s0,sp,112
    80005fee:	8a2a                	mv	s4,a0
    80005ff0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ff2:	00c52c83          	lw	s9,12(a0)
    80005ff6:	001c9c9b          	slliw	s9,s9,0x1
    80005ffa:	1c82                	slli	s9,s9,0x20
    80005ffc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006000:	0001c517          	auipc	a0,0x1c
    80006004:	d6850513          	addi	a0,a0,-664 # 80021d68 <disk+0x128>
    80006008:	ffffb097          	auipc	ra,0xffffb
    8000600c:	bca080e7          	jalr	-1078(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006010:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006012:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006014:	0001cb17          	auipc	s6,0x1c
    80006018:	c2cb0b13          	addi	s6,s6,-980 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    8000601c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000601e:	0001cc17          	auipc	s8,0x1c
    80006022:	d4ac0c13          	addi	s8,s8,-694 # 80021d68 <disk+0x128>
    80006026:	a095                	j	8000608a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006028:	00fb0733          	add	a4,s6,a5
    8000602c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006030:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006032:	0207c563          	bltz	a5,8000605c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006036:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006038:	0591                	addi	a1,a1,4
    8000603a:	05560d63          	beq	a2,s5,80006094 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000603e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006040:	0001c717          	auipc	a4,0x1c
    80006044:	c0070713          	addi	a4,a4,-1024 # 80021c40 <disk>
    80006048:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000604a:	01874683          	lbu	a3,24(a4)
    8000604e:	fee9                	bnez	a3,80006028 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006050:	2785                	addiw	a5,a5,1
    80006052:	0705                	addi	a4,a4,1
    80006054:	fe979be3          	bne	a5,s1,8000604a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006058:	57fd                	li	a5,-1
    8000605a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000605c:	00c05e63          	blez	a2,80006078 <virtio_disk_rw+0xa6>
    80006060:	060a                	slli	a2,a2,0x2
    80006062:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006066:	0009a503          	lw	a0,0(s3)
    8000606a:	00000097          	auipc	ra,0x0
    8000606e:	cfc080e7          	jalr	-772(ra) # 80005d66 <free_desc>
      for(int j = 0; j < i; j++)
    80006072:	0991                	addi	s3,s3,4
    80006074:	ffa999e3          	bne	s3,s10,80006066 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006078:	85e2                	mv	a1,s8
    8000607a:	0001c517          	auipc	a0,0x1c
    8000607e:	bde50513          	addi	a0,a0,-1058 # 80021c58 <disk+0x18>
    80006082:	ffffc097          	auipc	ra,0xffffc
    80006086:	03a080e7          	jalr	58(ra) # 800020bc <sleep>
  for(int i = 0; i < 3; i++){
    8000608a:	f9040993          	addi	s3,s0,-112
{
    8000608e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006090:	864a                	mv	a2,s2
    80006092:	b775                	j	8000603e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006094:	f9042503          	lw	a0,-112(s0)
    80006098:	00a50713          	addi	a4,a0,10
    8000609c:	0712                	slli	a4,a4,0x4

  if(write)
    8000609e:	0001c797          	auipc	a5,0x1c
    800060a2:	ba278793          	addi	a5,a5,-1118 # 80021c40 <disk>
    800060a6:	00e786b3          	add	a3,a5,a4
    800060aa:	01703633          	snez	a2,s7
    800060ae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060b0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060b4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060b8:	f6070613          	addi	a2,a4,-160
    800060bc:	6394                	ld	a3,0(a5)
    800060be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060c0:	00870593          	addi	a1,a4,8
    800060c4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060c6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060c8:	0007b803          	ld	a6,0(a5)
    800060cc:	9642                	add	a2,a2,a6
    800060ce:	46c1                	li	a3,16
    800060d0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060d2:	4585                	li	a1,1
    800060d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060d8:	f9442683          	lw	a3,-108(s0)
    800060dc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060e0:	0692                	slli	a3,a3,0x4
    800060e2:	9836                	add	a6,a6,a3
    800060e4:	058a0613          	addi	a2,s4,88
    800060e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060ec:	0007b803          	ld	a6,0(a5)
    800060f0:	96c2                	add	a3,a3,a6
    800060f2:	40000613          	li	a2,1024
    800060f6:	c690                	sw	a2,8(a3)
  if(write)
    800060f8:	001bb613          	seqz	a2,s7
    800060fc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006100:	00166613          	ori	a2,a2,1
    80006104:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006108:	f9842603          	lw	a2,-104(s0)
    8000610c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006110:	00250693          	addi	a3,a0,2
    80006114:	0692                	slli	a3,a3,0x4
    80006116:	96be                	add	a3,a3,a5
    80006118:	58fd                	li	a7,-1
    8000611a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000611e:	0612                	slli	a2,a2,0x4
    80006120:	9832                	add	a6,a6,a2
    80006122:	f9070713          	addi	a4,a4,-112
    80006126:	973e                	add	a4,a4,a5
    80006128:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000612c:	6398                	ld	a4,0(a5)
    8000612e:	9732                	add	a4,a4,a2
    80006130:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006132:	4609                	li	a2,2
    80006134:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006138:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000613c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006140:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006144:	6794                	ld	a3,8(a5)
    80006146:	0026d703          	lhu	a4,2(a3)
    8000614a:	8b1d                	andi	a4,a4,7
    8000614c:	0706                	slli	a4,a4,0x1
    8000614e:	96ba                	add	a3,a3,a4
    80006150:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006154:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006158:	6798                	ld	a4,8(a5)
    8000615a:	00275783          	lhu	a5,2(a4)
    8000615e:	2785                	addiw	a5,a5,1
    80006160:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006164:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006170:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006174:	0001c917          	auipc	s2,0x1c
    80006178:	bf490913          	addi	s2,s2,-1036 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    8000617c:	4485                	li	s1,1
    8000617e:	00b79c63          	bne	a5,a1,80006196 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006182:	85ca                	mv	a1,s2
    80006184:	8552                	mv	a0,s4
    80006186:	ffffc097          	auipc	ra,0xffffc
    8000618a:	f36080e7          	jalr	-202(ra) # 800020bc <sleep>
  while(b->disk == 1) {
    8000618e:	004a2783          	lw	a5,4(s4)
    80006192:	fe9788e3          	beq	a5,s1,80006182 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006196:	f9042903          	lw	s2,-112(s0)
    8000619a:	00290713          	addi	a4,s2,2
    8000619e:	0712                	slli	a4,a4,0x4
    800061a0:	0001c797          	auipc	a5,0x1c
    800061a4:	aa078793          	addi	a5,a5,-1376 # 80021c40 <disk>
    800061a8:	97ba                	add	a5,a5,a4
    800061aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061ae:	0001c997          	auipc	s3,0x1c
    800061b2:	a9298993          	addi	s3,s3,-1390 # 80021c40 <disk>
    800061b6:	00491713          	slli	a4,s2,0x4
    800061ba:	0009b783          	ld	a5,0(s3)
    800061be:	97ba                	add	a5,a5,a4
    800061c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061c4:	854a                	mv	a0,s2
    800061c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061ca:	00000097          	auipc	ra,0x0
    800061ce:	b9c080e7          	jalr	-1124(ra) # 80005d66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061d2:	8885                	andi	s1,s1,1
    800061d4:	f0ed                	bnez	s1,800061b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061d6:	0001c517          	auipc	a0,0x1c
    800061da:	b9250513          	addi	a0,a0,-1134 # 80021d68 <disk+0x128>
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	aa8080e7          	jalr	-1368(ra) # 80000c86 <release>
}
    800061e6:	70a6                	ld	ra,104(sp)
    800061e8:	7406                	ld	s0,96(sp)
    800061ea:	64e6                	ld	s1,88(sp)
    800061ec:	6946                	ld	s2,80(sp)
    800061ee:	69a6                	ld	s3,72(sp)
    800061f0:	6a06                	ld	s4,64(sp)
    800061f2:	7ae2                	ld	s5,56(sp)
    800061f4:	7b42                	ld	s6,48(sp)
    800061f6:	7ba2                	ld	s7,40(sp)
    800061f8:	7c02                	ld	s8,32(sp)
    800061fa:	6ce2                	ld	s9,24(sp)
    800061fc:	6d42                	ld	s10,16(sp)
    800061fe:	6165                	addi	sp,sp,112
    80006200:	8082                	ret

0000000080006202 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006202:	1101                	addi	sp,sp,-32
    80006204:	ec06                	sd	ra,24(sp)
    80006206:	e822                	sd	s0,16(sp)
    80006208:	e426                	sd	s1,8(sp)
    8000620a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000620c:	0001c497          	auipc	s1,0x1c
    80006210:	a3448493          	addi	s1,s1,-1484 # 80021c40 <disk>
    80006214:	0001c517          	auipc	a0,0x1c
    80006218:	b5450513          	addi	a0,a0,-1196 # 80021d68 <disk+0x128>
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	9b6080e7          	jalr	-1610(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006224:	10001737          	lui	a4,0x10001
    80006228:	533c                	lw	a5,96(a4)
    8000622a:	8b8d                	andi	a5,a5,3
    8000622c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000622e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006232:	689c                	ld	a5,16(s1)
    80006234:	0204d703          	lhu	a4,32(s1)
    80006238:	0027d783          	lhu	a5,2(a5)
    8000623c:	04f70863          	beq	a4,a5,8000628c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006240:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006244:	6898                	ld	a4,16(s1)
    80006246:	0204d783          	lhu	a5,32(s1)
    8000624a:	8b9d                	andi	a5,a5,7
    8000624c:	078e                	slli	a5,a5,0x3
    8000624e:	97ba                	add	a5,a5,a4
    80006250:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006252:	00278713          	addi	a4,a5,2
    80006256:	0712                	slli	a4,a4,0x4
    80006258:	9726                	add	a4,a4,s1
    8000625a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000625e:	e721                	bnez	a4,800062a6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006260:	0789                	addi	a5,a5,2
    80006262:	0792                	slli	a5,a5,0x4
    80006264:	97a6                	add	a5,a5,s1
    80006266:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006268:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000626c:	ffffc097          	auipc	ra,0xffffc
    80006270:	eb4080e7          	jalr	-332(ra) # 80002120 <wakeup>

    disk.used_idx += 1;
    80006274:	0204d783          	lhu	a5,32(s1)
    80006278:	2785                	addiw	a5,a5,1
    8000627a:	17c2                	slli	a5,a5,0x30
    8000627c:	93c1                	srli	a5,a5,0x30
    8000627e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006282:	6898                	ld	a4,16(s1)
    80006284:	00275703          	lhu	a4,2(a4)
    80006288:	faf71ce3          	bne	a4,a5,80006240 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000628c:	0001c517          	auipc	a0,0x1c
    80006290:	adc50513          	addi	a0,a0,-1316 # 80021d68 <disk+0x128>
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	9f2080e7          	jalr	-1550(ra) # 80000c86 <release>
}
    8000629c:	60e2                	ld	ra,24(sp)
    8000629e:	6442                	ld	s0,16(sp)
    800062a0:	64a2                	ld	s1,8(sp)
    800062a2:	6105                	addi	sp,sp,32
    800062a4:	8082                	ret
      panic("virtio_disk_intr status");
    800062a6:	00002517          	auipc	a0,0x2
    800062aa:	5b250513          	addi	a0,a0,1458 # 80008858 <syscalls+0x408>
    800062ae:	ffffa097          	auipc	ra,0xffffa
    800062b2:	28e080e7          	jalr	654(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
