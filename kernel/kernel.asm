
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d813103          	ld	sp,-1832(sp) # 800088d8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	8e070713          	addi	a4,a4,-1824 # 80008930 <timer_scratch>
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
    80000066:	c4e78793          	addi	a5,a5,-946 # 80005cb0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca5f>
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
    8000012e:	402080e7          	jalr	1026(ra) # 8000252c <either_copyin>
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
    80000188:	8ec50513          	addi	a0,a0,-1812 # 80010a70 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	8dc48493          	addi	s1,s1,-1828 # 80010a70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	96c90913          	addi	s2,s2,-1684 # 80010b08 <cons+0x98>
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
    800001c0:	1ba080e7          	jalr	442(ra) # 80002376 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f04080e7          	jalr	-252(ra) # 800020ce <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	89270713          	addi	a4,a4,-1902 # 80010a70 <cons>
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
    80000214:	2c6080e7          	jalr	710(ra) # 800024d6 <either_copyout>
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
    8000022c:	84850513          	addi	a0,a0,-1976 # 80010a70 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	83250513          	addi	a0,a0,-1998 # 80010a70 <cons>
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
    80000272:	88f72d23          	sw	a5,-1894(a4) # 80010b08 <cons+0x98>
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
    800002cc:	7a850513          	addi	a0,a0,1960 # 80010a70 <cons>
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
    800002f2:	294080e7          	jalr	660(ra) # 80002582 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	77a50513          	addi	a0,a0,1914 # 80010a70 <cons>
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
    8000031e:	75670713          	addi	a4,a4,1878 # 80010a70 <cons>
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
    80000348:	72c78793          	addi	a5,a5,1836 # 80010a70 <cons>
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
    80000376:	7967a783          	lw	a5,1942(a5) # 80010b08 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	6ea70713          	addi	a4,a4,1770 # 80010a70 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	6da48493          	addi	s1,s1,1754 # 80010a70 <cons>
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
    800003d6:	69e70713          	addi	a4,a4,1694 # 80010a70 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	72f72423          	sw	a5,1832(a4) # 80010b10 <cons+0xa0>
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
    80000412:	66278793          	addi	a5,a5,1634 # 80010a70 <cons>
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
    80000436:	6cc7ad23          	sw	a2,1754(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	6ce50513          	addi	a0,a0,1742 # 80010b08 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	cf0080e7          	jalr	-784(ra) # 80002132 <wakeup>
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
    80000460:	61450513          	addi	a0,a0,1556 # 80010a70 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	79478793          	addi	a5,a5,1940 # 80020c08 <devsw>
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
    8000054c:	5e07a423          	sw	zero,1512(a5) # 80010b30 <pr+0x18>
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
    80000580:	36f72a23          	sw	a5,884(a4) # 800088f0 <panicked>
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
    800005bc:	578dad83          	lw	s11,1400(s11) # 80010b30 <pr+0x18>
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
    800005fa:	52250513          	addi	a0,a0,1314 # 80010b18 <pr>
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
    80000758:	3c450513          	addi	a0,a0,964 # 80010b18 <pr>
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
    80000774:	3a848493          	addi	s1,s1,936 # 80010b18 <pr>
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
    800007d4:	36850513          	addi	a0,a0,872 # 80010b38 <uart_tx_lock>
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
    80000800:	0f47a783          	lw	a5,244(a5) # 800088f0 <panicked>
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
    80000838:	0c47b783          	ld	a5,196(a5) # 800088f8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	0c473703          	ld	a4,196(a4) # 80008900 <uart_tx_w>
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
    80000862:	2daa0a13          	addi	s4,s4,730 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	09248493          	addi	s1,s1,146 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	09298993          	addi	s3,s3,146 # 80008900 <uart_tx_w>
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
    80000894:	8a2080e7          	jalr	-1886(ra) # 80002132 <wakeup>
    
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
    800008d0:	26c50513          	addi	a0,a0,620 # 80010b38 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0147a783          	lw	a5,20(a5) # 800088f0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	01a73703          	ld	a4,26(a4) # 80008900 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	00a7b783          	ld	a5,10(a5) # 800088f8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	23e98993          	addi	s3,s3,574 # 80010b38 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	ff648493          	addi	s1,s1,-10 # 800088f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	ff690913          	addi	s2,s2,-10 # 80008900 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7b4080e7          	jalr	1972(ra) # 800020ce <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	20848493          	addi	s1,s1,520 # 80010b38 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	fae7be23          	sd	a4,-68(a5) # 80008900 <uart_tx_w>
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
    800009ba:	18248493          	addi	s1,s1,386 # 80010b38 <uart_tx_lock>
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
    800009fc:	3a878793          	addi	a5,a5,936 # 80021da0 <end>
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
    80000a1c:	15890913          	addi	s2,s2,344 # 80010b70 <kmem>
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
    80000aba:	0ba50513          	addi	a0,a0,186 # 80010b70 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	2d650513          	addi	a0,a0,726 # 80021da0 <end>
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
    80000af0:	08448493          	addi	s1,s1,132 # 80010b70 <kmem>
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
    80000b08:	06c50513          	addi	a0,a0,108 # 80010b70 <kmem>
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
    80000b34:	04050513          	addi	a0,a0,64 # 80010b70 <kmem>
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
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd261>
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
    80000e86:	a8670713          	addi	a4,a4,-1402 # 80008908 <started>
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
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	80c080e7          	jalr	-2036(ra) # 800026c4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e30080e7          	jalr	-464(ra) # 80005cf0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fd8080e7          	jalr	-40(ra) # 80001ea0 <scheduler>
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
    80000f34:	76c080e7          	jalr	1900(ra) # 8000269c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	78c080e7          	jalr	1932(ra) # 800026c4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d9a080e7          	jalr	-614(ra) # 80005cda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	da8080e7          	jalr	-600(ra) # 80005cf0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	fa0080e7          	jalr	-96(ra) # 80002ef0 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	63e080e7          	jalr	1598(ra) # 80003596 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5b4080e7          	jalr	1460(ra) # 80004514 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e90080e7          	jalr	-368(ra) # 80005df8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d12080e7          	jalr	-750(ra) # 80001c82 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	98f72523          	sw	a5,-1654(a4) # 80008908 <started>
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
    80000f96:	97e7b783          	ld	a5,-1666(a5) # 80008910 <kernel_pagetable>
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
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd257>
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
    80001252:	6ca7b123          	sd	a0,1730(a5) # 80008910 <kernel_pagetable>
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
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd260>
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
    8000184a:	77a48493          	addi	s1,s1,1914 # 80010fc0 <proc>
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
    80001864:	160a0a13          	addi	s4,s4,352 # 800169c0 <tickslock>
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
    800018e6:	2ae50513          	addi	a0,a0,686 # 80010b90 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	2ae50513          	addi	a0,a0,686 # 80010ba8 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	6b648493          	addi	s1,s1,1718 # 80010fc0 <proc>
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
    80001930:	09498993          	addi	s3,s3,148 # 800169c0 <tickslock>
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
    8000199a:	22a50513          	addi	a0,a0,554 # 80010bc0 <cpus>
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
    800019c2:	1d270713          	addi	a4,a4,466 # 80010b90 <pid_lock>
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
    80001a04:	cdc080e7          	jalr	-804(ra) # 800026dc <usertrapret>
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
    80001a1e:	afc080e7          	jalr	-1284(ra) # 80003516 <fsinit>
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
    80001a34:	16090913          	addi	s2,s2,352 # 80010b90 <pid_lock>
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
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	addi	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	0000f497          	auipc	s1,0xf
    80001bc0:	40448493          	addi	s1,s1,1028 # 80010fc0 <proc>
    80001bc4:	00015917          	auipc	s2,0x15
    80001bc8:	dfc90913          	addi	s2,s2,-516 # 800169c0 <tickslock>
    acquire(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	004080e7          	jalr	4(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bd6:	4c9c                	lw	a5,24(s1)
    80001bd8:	cf81                	beqz	a5,80001bf0 <allocproc+0x40>
      release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be4:	16848493          	addi	s1,s1,360
    80001be8:	ff2492e3          	bne	s1,s2,80001bcc <allocproc+0x1c>
  return 0;
    80001bec:	4481                	li	s1,0
    80001bee:	a899                	j	80001c44 <allocproc+0x94>
  p->pid   = allocpid();
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e34080e7          	jalr	-460(ra) # 80001a24 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  p->prio  = 0x0C;
    80001bfe:	47b1                	li	a5,12
    80001c00:	d8dc                	sw	a5,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c02:	fffff097          	auipc	ra,0xfffff
    80001c06:	ee0080e7          	jalr	-288(ra) # 80000ae2 <kalloc>
    80001c0a:	892a                	mv	s2,a0
    80001c0c:	eca8                	sd	a0,88(s1)
    80001c0e:	c131                	beqz	a0,80001c52 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c10:	8526                	mv	a0,s1
    80001c12:	00000097          	auipc	ra,0x0
    80001c16:	e58080e7          	jalr	-424(ra) # 80001a6a <proc_pagetable>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c1e:	c531                	beqz	a0,80001c6a <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c20:	07000613          	li	a2,112
    80001c24:	4581                	li	a1,0
    80001c26:	06048513          	addi	a0,s1,96
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	0a4080e7          	jalr	164(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c32:	00000797          	auipc	a5,0x0
    80001c36:	dac78793          	addi	a5,a5,-596 # 800019de <forkret>
    80001c3a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3c:	60bc                	ld	a5,64(s1)
    80001c3e:	6705                	lui	a4,0x1
    80001c40:	97ba                	add	a5,a5,a4
    80001c42:	f4bc                	sd	a5,104(s1)
}
    80001c44:	8526                	mv	a0,s1
    80001c46:	60e2                	ld	ra,24(sp)
    80001c48:	6442                	ld	s0,16(sp)
    80001c4a:	64a2                	ld	s1,8(sp)
    80001c4c:	6902                	ld	s2,0(sp)
    80001c4e:	6105                	addi	sp,sp,32
    80001c50:	8082                	ret
    freeproc(p);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	f04080e7          	jalr	-252(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	028080e7          	jalr	40(ra) # 80000c86 <release>
    return 0;
    80001c66:	84ca                	mv	s1,s2
    80001c68:	bff1                	j	80001c44 <allocproc+0x94>
    freeproc(p);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	eec080e7          	jalr	-276(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c74:	8526                	mv	a0,s1
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	010080e7          	jalr	16(ra) # 80000c86 <release>
    return 0;
    80001c7e:	84ca                	mv	s1,s2
    80001c80:	b7d1                	j	80001c44 <allocproc+0x94>

0000000080001c82 <userinit>:
{
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	f24080e7          	jalr	-220(ra) # 80001bb0 <allocproc>
    80001c94:	84aa                	mv	s1,a0
  initproc = p;
    80001c96:	00007797          	auipc	a5,0x7
    80001c9a:	c8a7b123          	sd	a0,-894(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c9e:	03400613          	li	a2,52
    80001ca2:	00007597          	auipc	a1,0x7
    80001ca6:	bde58593          	addi	a1,a1,-1058 # 80008880 <initcode>
    80001caa:	6928                	ld	a0,80(a0)
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	6a4080e7          	jalr	1700(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cb4:	6785                	lui	a5,0x1
    80001cb6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cb8:	6cb8                	ld	a4,88(s1)
    80001cba:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cbe:	6cb8                	ld	a4,88(s1)
    80001cc0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc2:	4641                	li	a2,16
    80001cc4:	00006597          	auipc	a1,0x6
    80001cc8:	53c58593          	addi	a1,a1,1340 # 80008200 <digits+0x1c0>
    80001ccc:	15848513          	addi	a0,s1,344
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	146080e7          	jalr	326(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cd8:	00006517          	auipc	a0,0x6
    80001cdc:	53850513          	addi	a0,a0,1336 # 80008210 <digits+0x1d0>
    80001ce0:	00002097          	auipc	ra,0x2
    80001ce4:	254080e7          	jalr	596(ra) # 80003f34 <namei>
    80001ce8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cec:	478d                	li	a5,3
    80001cee:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	f94080e7          	jalr	-108(ra) # 80000c86 <release>
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <growproc>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	e04a                	sd	s2,0(sp)
    80001d0e:	1000                	addi	s0,sp,32
    80001d10:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	c94080e7          	jalr	-876(ra) # 800019a6 <myproc>
    80001d1a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d1e:	01204c63          	bgtz	s2,80001d36 <growproc+0x32>
  } else if(n < 0){
    80001d22:	02094663          	bltz	s2,80001d4e <growproc+0x4a>
  p->sz = sz;
    80001d26:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d28:	4501                	li	a0,0
}
    80001d2a:	60e2                	ld	ra,24(sp)
    80001d2c:	6442                	ld	s0,16(sp)
    80001d2e:	64a2                	ld	s1,8(sp)
    80001d30:	6902                	ld	s2,0(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d36:	4691                	li	a3,4
    80001d38:	00b90633          	add	a2,s2,a1
    80001d3c:	6928                	ld	a0,80(a0)
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	6cc080e7          	jalr	1740(ra) # 8000140a <uvmalloc>
    80001d46:	85aa                	mv	a1,a0
    80001d48:	fd79                	bnez	a0,80001d26 <growproc+0x22>
      return -1;
    80001d4a:	557d                	li	a0,-1
    80001d4c:	bff9                	j	80001d2a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4e:	00b90633          	add	a2,s2,a1
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	66e080e7          	jalr	1646(ra) # 800013c2 <uvmdealloc>
    80001d5c:	85aa                	mv	a1,a0
    80001d5e:	b7e1                	j	80001d26 <growproc+0x22>

0000000080001d60 <fork>:
{
    80001d60:	7139                	addi	sp,sp,-64
    80001d62:	fc06                	sd	ra,56(sp)
    80001d64:	f822                	sd	s0,48(sp)
    80001d66:	f426                	sd	s1,40(sp)
    80001d68:	f04a                	sd	s2,32(sp)
    80001d6a:	ec4e                	sd	s3,24(sp)
    80001d6c:	e852                	sd	s4,16(sp)
    80001d6e:	e456                	sd	s5,8(sp)
    80001d70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d72:	00000097          	auipc	ra,0x0
    80001d76:	c34080e7          	jalr	-972(ra) # 800019a6 <myproc>
    80001d7a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	e34080e7          	jalr	-460(ra) # 80001bb0 <allocproc>
    80001d84:	10050c63          	beqz	a0,80001e9c <fork+0x13c>
    80001d88:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8a:	048ab603          	ld	a2,72(s5)
    80001d8e:	692c                	ld	a1,80(a0)
    80001d90:	050ab503          	ld	a0,80(s5)
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	7ce080e7          	jalr	1998(ra) # 80001562 <uvmcopy>
    80001d9c:	04054863          	bltz	a0,80001dec <fork+0x8c>
  np->sz = p->sz;
    80001da0:	048ab783          	ld	a5,72(s5)
    80001da4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001da8:	058ab683          	ld	a3,88(s5)
    80001dac:	87b6                	mv	a5,a3
    80001dae:	058a3703          	ld	a4,88(s4)
    80001db2:	12068693          	addi	a3,a3,288
    80001db6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dba:	6788                	ld	a0,8(a5)
    80001dbc:	6b8c                	ld	a1,16(a5)
    80001dbe:	6f90                	ld	a2,24(a5)
    80001dc0:	01073023          	sd	a6,0(a4)
    80001dc4:	e708                	sd	a0,8(a4)
    80001dc6:	eb0c                	sd	a1,16(a4)
    80001dc8:	ef10                	sd	a2,24(a4)
    80001dca:	02078793          	addi	a5,a5,32
    80001dce:	02070713          	addi	a4,a4,32
    80001dd2:	fed792e3          	bne	a5,a3,80001db6 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd6:	058a3783          	ld	a5,88(s4)
    80001dda:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dde:	0d0a8493          	addi	s1,s5,208
    80001de2:	0d0a0913          	addi	s2,s4,208
    80001de6:	150a8993          	addi	s3,s5,336
    80001dea:	a00d                	j	80001e0c <fork+0xac>
    freeproc(np);
    80001dec:	8552                	mv	a0,s4
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	d6a080e7          	jalr	-662(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001df6:	8552                	mv	a0,s4
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	e8e080e7          	jalr	-370(ra) # 80000c86 <release>
    return -1;
    80001e00:	597d                	li	s2,-1
    80001e02:	a059                	j	80001e88 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e04:	04a1                	addi	s1,s1,8
    80001e06:	0921                	addi	s2,s2,8
    80001e08:	01348b63          	beq	s1,s3,80001e1e <fork+0xbe>
    if(p->ofile[i])
    80001e0c:	6088                	ld	a0,0(s1)
    80001e0e:	d97d                	beqz	a0,80001e04 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e10:	00002097          	auipc	ra,0x2
    80001e14:	796080e7          	jalr	1942(ra) # 800045a6 <filedup>
    80001e18:	00a93023          	sd	a0,0(s2)
    80001e1c:	b7e5                	j	80001e04 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e1e:	150ab503          	ld	a0,336(s5)
    80001e22:	00002097          	auipc	ra,0x2
    80001e26:	92e080e7          	jalr	-1746(ra) # 80003750 <idup>
    80001e2a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2e:	4641                	li	a2,16
    80001e30:	158a8593          	addi	a1,s5,344
    80001e34:	158a0513          	addi	a0,s4,344
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	fde080e7          	jalr	-34(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e40:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e44:	8552                	mv	a0,s4
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	e40080e7          	jalr	-448(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e4e:	0000f497          	auipc	s1,0xf
    80001e52:	d5a48493          	addi	s1,s1,-678 # 80010ba8 <wait_lock>
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	d7a080e7          	jalr	-646(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e60:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e64:	8526                	mv	a0,s1
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	e20080e7          	jalr	-480(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e6e:	8552                	mv	a0,s4
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	d62080e7          	jalr	-670(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e78:	478d                	li	a5,3
    80001e7a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e7e:	8552                	mv	a0,s4
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e06080e7          	jalr	-506(ra) # 80000c86 <release>
}
    80001e88:	854a                	mv	a0,s2
    80001e8a:	70e2                	ld	ra,56(sp)
    80001e8c:	7442                	ld	s0,48(sp)
    80001e8e:	74a2                	ld	s1,40(sp)
    80001e90:	7902                	ld	s2,32(sp)
    80001e92:	69e2                	ld	s3,24(sp)
    80001e94:	6a42                	ld	s4,16(sp)
    80001e96:	6aa2                	ld	s5,8(sp)
    80001e98:	6121                	addi	sp,sp,64
    80001e9a:	8082                	ret
    return -1;
    80001e9c:	597d                	li	s2,-1
    80001e9e:	b7ed                	j	80001e88 <fork+0x128>

0000000080001ea0 <scheduler>:
{
    80001ea0:	7159                	addi	sp,sp,-112
    80001ea2:	f486                	sd	ra,104(sp)
    80001ea4:	f0a2                	sd	s0,96(sp)
    80001ea6:	eca6                	sd	s1,88(sp)
    80001ea8:	e8ca                	sd	s2,80(sp)
    80001eaa:	e4ce                	sd	s3,72(sp)
    80001eac:	e0d2                	sd	s4,64(sp)
    80001eae:	fc56                	sd	s5,56(sp)
    80001eb0:	f85a                	sd	s6,48(sp)
    80001eb2:	f45e                	sd	s7,40(sp)
    80001eb4:	f062                	sd	s8,32(sp)
    80001eb6:	ec66                	sd	s9,24(sp)
    80001eb8:	e86a                	sd	s10,16(sp)
    80001eba:	e46e                	sd	s11,8(sp)
    80001ebc:	1880                	addi	s0,sp,112
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ebe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001ec2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ec4:	10079073          	csrw	sstatus,a5
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ec8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eca:	2781                	sext.w	a5,a5
  c->proc = 0; // kick the process out
    80001ecc:	00779d13          	slli	s10,a5,0x7
    80001ed0:	0000f717          	auipc	a4,0xf
    80001ed4:	cc070713          	addi	a4,a4,-832 # 80010b90 <pid_lock>
    80001ed8:	976a                	add	a4,a4,s10
    80001eda:	02073823          	sd	zero,48(a4)
    swtch(&c->context, &p->context);
    80001ede:	0000f717          	auipc	a4,0xf
    80001ee2:	cea70713          	addi	a4,a4,-790 # 80010bc8 <cpus+0x8>
    80001ee6:	9d3a                	add	s10,s10,a4
  int currMin = 1, i = 2; // dont want to get the lock for init
    80001ee8:	4985                	li	s3,1
    acquire(&proc[currMin].lock);
    80001eea:	16800c13          	li	s8,360
    80001eee:	0000fb97          	auipc	s7,0xf
    80001ef2:	0d2b8b93          	addi	s7,s7,210 # 80010fc0 <proc>
    for(i = 2; i < NPROC; i++){
    80001ef6:	4d89                	li	s11,2
       if(p->state == RUNNABLE){
    80001ef8:	4b0d                	li	s6,3
    c->proc = p;
    80001efa:	079e                	slli	a5,a5,0x7
    80001efc:	0000fc97          	auipc	s9,0xf
    80001f00:	c94c8c93          	addi	s9,s9,-876 # 80010b90 <pid_lock>
    80001f04:	9cbe                	add	s9,s9,a5
    80001f06:	a071                	j	80001f92 <scheduler+0xf2>
            release(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	d7c080e7          	jalr	-644(ra) # 80000c86 <release>
    80001f12:	a031                	j	80001f1e <scheduler+0x7e>
          release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	d70080e7          	jalr	-656(ra) # 80000c86 <release>
    for(i = 2; i < NPROC; i++){
    80001f1e:	2905                	addiw	s2,s2,1
    80001f20:	16848493          	addi	s1,s1,360
    80001f24:	03590a63          	beq	s2,s5,80001f58 <scheduler+0xb8>
       acquire(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	ca8080e7          	jalr	-856(ra) # 80000bd2 <acquire>
       if(p->state == RUNNABLE){
    80001f32:	4c9c                	lw	a5,24(s1)
    80001f34:	ff6790e3          	bne	a5,s6,80001f14 <scheduler+0x74>
          if(p->prio < proc[currMin].prio){
    80001f38:	038987b3          	mul	a5,s3,s8
    80001f3c:	97de                	add	a5,a5,s7
    80001f3e:	58d8                	lw	a4,52(s1)
    80001f40:	5bdc                	lw	a5,52(a5)
    80001f42:	fcf753e3          	bge	a4,a5,80001f08 <scheduler+0x68>
            release(&proc[currMin].lock); // release the lock on the other process that isnt the min
    80001f46:	03898533          	mul	a0,s3,s8
    80001f4a:	955e                	add	a0,a0,s7
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d3a080e7          	jalr	-710(ra) # 80000c86 <release>
            currMin = i; // update min
    80001f54:	89ca                	mv	s3,s2
    80001f56:	b7e1                	j	80001f1e <scheduler+0x7e>
    p = &proc[currMin];
    80001f58:	038987b3          	mul	a5,s3,s8
    80001f5c:	017784b3          	add	s1,a5,s7
    p->state = RUNNING;
    80001f60:	4711                	li	a4,4
    80001f62:	cc98                	sw	a4,24(s1)
    c->proc = p;
    80001f64:	029cb823          	sd	s1,48(s9)
    swtch(&c->context, &p->context);
    80001f68:	06078793          	addi	a5,a5,96
    80001f6c:	00fb85b3          	add	a1,s7,a5
    80001f70:	856a                	mv	a0,s10
    80001f72:	00000097          	auipc	ra,0x0
    80001f76:	6c0080e7          	jalr	1728(ra) # 80002632 <swtch>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f7e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f80:	10079073          	csrw	sstatus,a5
    c->proc = 0;
    80001f84:	020cb823          	sd	zero,48(s9)
    release(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	fffff097          	auipc	ra,0xfffff
    80001f8e:	cfc080e7          	jalr	-772(ra) # 80000c86 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9a:	10079073          	csrw	sstatus,a5
    acquire(&proc[currMin].lock);
    80001f9e:	03898533          	mul	a0,s3,s8
    80001fa2:	955e                	add	a0,a0,s7
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	c2e080e7          	jalr	-978(ra) # 80000bd2 <acquire>
    for(i = 2; i < NPROC; i++){
    80001fac:	0000f497          	auipc	s1,0xf
    80001fb0:	2e448493          	addi	s1,s1,740 # 80011290 <proc+0x2d0>
    80001fb4:	896e                	mv	s2,s11
    80001fb6:	04000a93          	li	s5,64
    80001fba:	b7bd                	j	80001f28 <scheduler+0x88>

0000000080001fbc <sched>:
{
    80001fbc:	7179                	addi	sp,sp,-48
    80001fbe:	f406                	sd	ra,40(sp)
    80001fc0:	f022                	sd	s0,32(sp)
    80001fc2:	ec26                	sd	s1,24(sp)
    80001fc4:	e84a                	sd	s2,16(sp)
    80001fc6:	e44e                	sd	s3,8(sp)
    80001fc8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fca:	00000097          	auipc	ra,0x0
    80001fce:	9dc080e7          	jalr	-1572(ra) # 800019a6 <myproc>
    80001fd2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	b84080e7          	jalr	-1148(ra) # 80000b58 <holding>
    80001fdc:	c93d                	beqz	a0,80002052 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe0:	2781                	sext.w	a5,a5
    80001fe2:	079e                	slli	a5,a5,0x7
    80001fe4:	0000f717          	auipc	a4,0xf
    80001fe8:	bac70713          	addi	a4,a4,-1108 # 80010b90 <pid_lock>
    80001fec:	97ba                	add	a5,a5,a4
    80001fee:	0a87a703          	lw	a4,168(a5)
    80001ff2:	4785                	li	a5,1
    80001ff4:	06f71763          	bne	a4,a5,80002062 <sched+0xa6>
  if(p->state == RUNNING)
    80001ff8:	4c98                	lw	a4,24(s1)
    80001ffa:	4791                	li	a5,4
    80001ffc:	06f70b63          	beq	a4,a5,80002072 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002000:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002004:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002006:	efb5                	bnez	a5,80002082 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002008:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000200a:	0000f917          	auipc	s2,0xf
    8000200e:	b8690913          	addi	s2,s2,-1146 # 80010b90 <pid_lock>
    80002012:	2781                	sext.w	a5,a5
    80002014:	079e                	slli	a5,a5,0x7
    80002016:	97ca                	add	a5,a5,s2
    80002018:	0ac7a983          	lw	s3,172(a5)
    8000201c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	0000f597          	auipc	a1,0xf
    80002026:	ba658593          	addi	a1,a1,-1114 # 80010bc8 <cpus+0x8>
    8000202a:	95be                	add	a1,a1,a5
    8000202c:	06048513          	addi	a0,s1,96
    80002030:	00000097          	auipc	ra,0x0
    80002034:	602080e7          	jalr	1538(ra) # 80002632 <swtch>
    80002038:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	079e                	slli	a5,a5,0x7
    8000203e:	993e                	add	s2,s2,a5
    80002040:	0b392623          	sw	s3,172(s2)
}
    80002044:	70a2                	ld	ra,40(sp)
    80002046:	7402                	ld	s0,32(sp)
    80002048:	64e2                	ld	s1,24(sp)
    8000204a:	6942                	ld	s2,16(sp)
    8000204c:	69a2                	ld	s3,8(sp)
    8000204e:	6145                	addi	sp,sp,48
    80002050:	8082                	ret
    panic("sched p->lock");
    80002052:	00006517          	auipc	a0,0x6
    80002056:	1c650513          	addi	a0,a0,454 # 80008218 <digits+0x1d8>
    8000205a:	ffffe097          	auipc	ra,0xffffe
    8000205e:	4e2080e7          	jalr	1250(ra) # 8000053c <panic>
    panic("sched locks");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	1c650513          	addi	a0,a0,454 # 80008228 <digits+0x1e8>
    8000206a:	ffffe097          	auipc	ra,0xffffe
    8000206e:	4d2080e7          	jalr	1234(ra) # 8000053c <panic>
    panic("sched running");
    80002072:	00006517          	auipc	a0,0x6
    80002076:	1c650513          	addi	a0,a0,454 # 80008238 <digits+0x1f8>
    8000207a:	ffffe097          	auipc	ra,0xffffe
    8000207e:	4c2080e7          	jalr	1218(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	1c650513          	addi	a0,a0,454 # 80008248 <digits+0x208>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>

0000000080002092 <yield>:
{
    80002092:	1101                	addi	sp,sp,-32
    80002094:	ec06                	sd	ra,24(sp)
    80002096:	e822                	sd	s0,16(sp)
    80002098:	e426                	sd	s1,8(sp)
    8000209a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	90a080e7          	jalr	-1782(ra) # 800019a6 <myproc>
    800020a4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	b2c080e7          	jalr	-1236(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020ae:	478d                	li	a5,3
    800020b0:	cc9c                	sw	a5,24(s1)
  sched();
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	f0a080e7          	jalr	-246(ra) # 80001fbc <sched>
  release(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	bca080e7          	jalr	-1078(ra) # 80000c86 <release>
}
    800020c4:	60e2                	ld	ra,24(sp)
    800020c6:	6442                	ld	s0,16(sp)
    800020c8:	64a2                	ld	s1,8(sp)
    800020ca:	6105                	addi	sp,sp,32
    800020cc:	8082                	ret

00000000800020ce <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ce:	7179                	addi	sp,sp,-48
    800020d0:	f406                	sd	ra,40(sp)
    800020d2:	f022                	sd	s0,32(sp)
    800020d4:	ec26                	sd	s1,24(sp)
    800020d6:	e84a                	sd	s2,16(sp)
    800020d8:	e44e                	sd	s3,8(sp)
    800020da:	1800                	addi	s0,sp,48
    800020dc:	89aa                	mv	s3,a0
    800020de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	8c6080e7          	jalr	-1850(ra) # 800019a6 <myproc>
    800020e8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	ae8080e7          	jalr	-1304(ra) # 80000bd2 <acquire>
  release(lk);
    800020f2:	854a                	mv	a0,s2
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	b92080e7          	jalr	-1134(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800020fc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002100:	4789                	li	a5,2
    80002102:	cc9c                	sw	a5,24(s1)

  sched();
    80002104:	00000097          	auipc	ra,0x0
    80002108:	eb8080e7          	jalr	-328(ra) # 80001fbc <sched>

  // Tidy up.
  p->chan = 0;
    8000210c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b74080e7          	jalr	-1164(ra) # 80000c86 <release>
  acquire(lk);
    8000211a:	854a                	mv	a0,s2
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	ab6080e7          	jalr	-1354(ra) # 80000bd2 <acquire>
}
    80002124:	70a2                	ld	ra,40(sp)
    80002126:	7402                	ld	s0,32(sp)
    80002128:	64e2                	ld	s1,24(sp)
    8000212a:	6942                	ld	s2,16(sp)
    8000212c:	69a2                	ld	s3,8(sp)
    8000212e:	6145                	addi	sp,sp,48
    80002130:	8082                	ret

0000000080002132 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002132:	7139                	addi	sp,sp,-64
    80002134:	fc06                	sd	ra,56(sp)
    80002136:	f822                	sd	s0,48(sp)
    80002138:	f426                	sd	s1,40(sp)
    8000213a:	f04a                	sd	s2,32(sp)
    8000213c:	ec4e                	sd	s3,24(sp)
    8000213e:	e852                	sd	s4,16(sp)
    80002140:	e456                	sd	s5,8(sp)
    80002142:	0080                	addi	s0,sp,64
    80002144:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002146:	0000f497          	auipc	s1,0xf
    8000214a:	e7a48493          	addi	s1,s1,-390 # 80010fc0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000214e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002150:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002152:	00015917          	auipc	s2,0x15
    80002156:	86e90913          	addi	s2,s2,-1938 # 800169c0 <tickslock>
    8000215a:	a811                	j	8000216e <wakeup+0x3c>
      }
      release(&p->lock);
    8000215c:	8526                	mv	a0,s1
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	b28080e7          	jalr	-1240(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002166:	16848493          	addi	s1,s1,360
    8000216a:	03248663          	beq	s1,s2,80002196 <wakeup+0x64>
    if(p != myproc()){
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	838080e7          	jalr	-1992(ra) # 800019a6 <myproc>
    80002176:	fea488e3          	beq	s1,a0,80002166 <wakeup+0x34>
      acquire(&p->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	a56080e7          	jalr	-1450(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002184:	4c9c                	lw	a5,24(s1)
    80002186:	fd379be3          	bne	a5,s3,8000215c <wakeup+0x2a>
    8000218a:	709c                	ld	a5,32(s1)
    8000218c:	fd4798e3          	bne	a5,s4,8000215c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002190:	0154ac23          	sw	s5,24(s1)
    80002194:	b7e1                	j	8000215c <wakeup+0x2a>
    }
  }
}
    80002196:	70e2                	ld	ra,56(sp)
    80002198:	7442                	ld	s0,48(sp)
    8000219a:	74a2                	ld	s1,40(sp)
    8000219c:	7902                	ld	s2,32(sp)
    8000219e:	69e2                	ld	s3,24(sp)
    800021a0:	6a42                	ld	s4,16(sp)
    800021a2:	6aa2                	ld	s5,8(sp)
    800021a4:	6121                	addi	sp,sp,64
    800021a6:	8082                	ret

00000000800021a8 <reparent>:
{
    800021a8:	7179                	addi	sp,sp,-48
    800021aa:	f406                	sd	ra,40(sp)
    800021ac:	f022                	sd	s0,32(sp)
    800021ae:	ec26                	sd	s1,24(sp)
    800021b0:	e84a                	sd	s2,16(sp)
    800021b2:	e44e                	sd	s3,8(sp)
    800021b4:	e052                	sd	s4,0(sp)
    800021b6:	1800                	addi	s0,sp,48
    800021b8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ba:	0000f497          	auipc	s1,0xf
    800021be:	e0648493          	addi	s1,s1,-506 # 80010fc0 <proc>
      pp->parent = initproc;
    800021c2:	00006a17          	auipc	s4,0x6
    800021c6:	756a0a13          	addi	s4,s4,1878 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ca:	00014997          	auipc	s3,0x14
    800021ce:	7f698993          	addi	s3,s3,2038 # 800169c0 <tickslock>
    800021d2:	a029                	j	800021dc <reparent+0x34>
    800021d4:	16848493          	addi	s1,s1,360
    800021d8:	01348d63          	beq	s1,s3,800021f2 <reparent+0x4a>
    if(pp->parent == p){
    800021dc:	7c9c                	ld	a5,56(s1)
    800021de:	ff279be3          	bne	a5,s2,800021d4 <reparent+0x2c>
      pp->parent = initproc;
    800021e2:	000a3503          	ld	a0,0(s4)
    800021e6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	f4a080e7          	jalr	-182(ra) # 80002132 <wakeup>
    800021f0:	b7d5                	j	800021d4 <reparent+0x2c>
}
    800021f2:	70a2                	ld	ra,40(sp)
    800021f4:	7402                	ld	s0,32(sp)
    800021f6:	64e2                	ld	s1,24(sp)
    800021f8:	6942                	ld	s2,16(sp)
    800021fa:	69a2                	ld	s3,8(sp)
    800021fc:	6a02                	ld	s4,0(sp)
    800021fe:	6145                	addi	sp,sp,48
    80002200:	8082                	ret

0000000080002202 <exit>:
{
    80002202:	7179                	addi	sp,sp,-48
    80002204:	f406                	sd	ra,40(sp)
    80002206:	f022                	sd	s0,32(sp)
    80002208:	ec26                	sd	s1,24(sp)
    8000220a:	e84a                	sd	s2,16(sp)
    8000220c:	e44e                	sd	s3,8(sp)
    8000220e:	e052                	sd	s4,0(sp)
    80002210:	1800                	addi	s0,sp,48
    80002212:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	792080e7          	jalr	1938(ra) # 800019a6 <myproc>
    8000221c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000221e:	00006797          	auipc	a5,0x6
    80002222:	6fa7b783          	ld	a5,1786(a5) # 80008918 <initproc>
    80002226:	0d050493          	addi	s1,a0,208
    8000222a:	15050913          	addi	s2,a0,336
    8000222e:	02a79363          	bne	a5,a0,80002254 <exit+0x52>
    panic("init exiting");
    80002232:	00006517          	auipc	a0,0x6
    80002236:	02e50513          	addi	a0,a0,46 # 80008260 <digits+0x220>
    8000223a:	ffffe097          	auipc	ra,0xffffe
    8000223e:	302080e7          	jalr	770(ra) # 8000053c <panic>
      fileclose(f);
    80002242:	00002097          	auipc	ra,0x2
    80002246:	3b6080e7          	jalr	950(ra) # 800045f8 <fileclose>
      p->ofile[fd] = 0;
    8000224a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000224e:	04a1                	addi	s1,s1,8
    80002250:	01248563          	beq	s1,s2,8000225a <exit+0x58>
    if(p->ofile[fd]){
    80002254:	6088                	ld	a0,0(s1)
    80002256:	f575                	bnez	a0,80002242 <exit+0x40>
    80002258:	bfdd                	j	8000224e <exit+0x4c>
  begin_op();
    8000225a:	00002097          	auipc	ra,0x2
    8000225e:	eda080e7          	jalr	-294(ra) # 80004134 <begin_op>
  iput(p->cwd);
    80002262:	1509b503          	ld	a0,336(s3)
    80002266:	00001097          	auipc	ra,0x1
    8000226a:	6e2080e7          	jalr	1762(ra) # 80003948 <iput>
  end_op();
    8000226e:	00002097          	auipc	ra,0x2
    80002272:	f40080e7          	jalr	-192(ra) # 800041ae <end_op>
  p->cwd = 0;
    80002276:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000227a:	0000f497          	auipc	s1,0xf
    8000227e:	92e48493          	addi	s1,s1,-1746 # 80010ba8 <wait_lock>
    80002282:	8526                	mv	a0,s1
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	94e080e7          	jalr	-1714(ra) # 80000bd2 <acquire>
  reparent(p);
    8000228c:	854e                	mv	a0,s3
    8000228e:	00000097          	auipc	ra,0x0
    80002292:	f1a080e7          	jalr	-230(ra) # 800021a8 <reparent>
  wakeup(p->parent);
    80002296:	0389b503          	ld	a0,56(s3)
    8000229a:	00000097          	auipc	ra,0x0
    8000229e:	e98080e7          	jalr	-360(ra) # 80002132 <wakeup>
  acquire(&p->lock);
    800022a2:	854e                	mv	a0,s3
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	92e080e7          	jalr	-1746(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022ac:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022b0:	4795                	li	a5,5
    800022b2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	9ce080e7          	jalr	-1586(ra) # 80000c86 <release>
  sched();
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	cfc080e7          	jalr	-772(ra) # 80001fbc <sched>
  panic("zombie exit");
    800022c8:	00006517          	auipc	a0,0x6
    800022cc:	fa850513          	addi	a0,a0,-88 # 80008270 <digits+0x230>
    800022d0:	ffffe097          	auipc	ra,0xffffe
    800022d4:	26c080e7          	jalr	620(ra) # 8000053c <panic>

00000000800022d8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022d8:	7179                	addi	sp,sp,-48
    800022da:	f406                	sd	ra,40(sp)
    800022dc:	f022                	sd	s0,32(sp)
    800022de:	ec26                	sd	s1,24(sp)
    800022e0:	e84a                	sd	s2,16(sp)
    800022e2:	e44e                	sd	s3,8(sp)
    800022e4:	1800                	addi	s0,sp,48
    800022e6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022e8:	0000f497          	auipc	s1,0xf
    800022ec:	cd848493          	addi	s1,s1,-808 # 80010fc0 <proc>
    800022f0:	00014997          	auipc	s3,0x14
    800022f4:	6d098993          	addi	s3,s3,1744 # 800169c0 <tickslock>
    acquire(&p->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	8d8080e7          	jalr	-1832(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    80002302:	589c                	lw	a5,48(s1)
    80002304:	01278d63          	beq	a5,s2,8000231e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	97c080e7          	jalr	-1668(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002312:	16848493          	addi	s1,s1,360
    80002316:	ff3491e3          	bne	s1,s3,800022f8 <kill+0x20>
  }
  return -1;
    8000231a:	557d                	li	a0,-1
    8000231c:	a829                	j	80002336 <kill+0x5e>
      p->killed = 1;
    8000231e:	4785                	li	a5,1
    80002320:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002322:	4c98                	lw	a4,24(s1)
    80002324:	4789                	li	a5,2
    80002326:	00f70f63          	beq	a4,a5,80002344 <kill+0x6c>
      release(&p->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	95a080e7          	jalr	-1702(ra) # 80000c86 <release>
      return 0;
    80002334:	4501                	li	a0,0
}
    80002336:	70a2                	ld	ra,40(sp)
    80002338:	7402                	ld	s0,32(sp)
    8000233a:	64e2                	ld	s1,24(sp)
    8000233c:	6942                	ld	s2,16(sp)
    8000233e:	69a2                	ld	s3,8(sp)
    80002340:	6145                	addi	sp,sp,48
    80002342:	8082                	ret
        p->state = RUNNABLE;
    80002344:	478d                	li	a5,3
    80002346:	cc9c                	sw	a5,24(s1)
    80002348:	b7cd                	j	8000232a <kill+0x52>

000000008000234a <setkilled>:

void
setkilled(struct proc *p)
{
    8000234a:	1101                	addi	sp,sp,-32
    8000234c:	ec06                	sd	ra,24(sp)
    8000234e:	e822                	sd	s0,16(sp)
    80002350:	e426                	sd	s1,8(sp)
    80002352:	1000                	addi	s0,sp,32
    80002354:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	87c080e7          	jalr	-1924(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000235e:	4785                	li	a5,1
    80002360:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	922080e7          	jalr	-1758(ra) # 80000c86 <release>
}
    8000236c:	60e2                	ld	ra,24(sp)
    8000236e:	6442                	ld	s0,16(sp)
    80002370:	64a2                	ld	s1,8(sp)
    80002372:	6105                	addi	sp,sp,32
    80002374:	8082                	ret

0000000080002376 <killed>:

int
killed(struct proc *p)
{
    80002376:	1101                	addi	sp,sp,-32
    80002378:	ec06                	sd	ra,24(sp)
    8000237a:	e822                	sd	s0,16(sp)
    8000237c:	e426                	sd	s1,8(sp)
    8000237e:	e04a                	sd	s2,0(sp)
    80002380:	1000                	addi	s0,sp,32
    80002382:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	84e080e7          	jalr	-1970(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000238c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	8f4080e7          	jalr	-1804(ra) # 80000c86 <release>
  return k;
}
    8000239a:	854a                	mv	a0,s2
    8000239c:	60e2                	ld	ra,24(sp)
    8000239e:	6442                	ld	s0,16(sp)
    800023a0:	64a2                	ld	s1,8(sp)
    800023a2:	6902                	ld	s2,0(sp)
    800023a4:	6105                	addi	sp,sp,32
    800023a6:	8082                	ret

00000000800023a8 <wait>:
{
    800023a8:	715d                	addi	sp,sp,-80
    800023aa:	e486                	sd	ra,72(sp)
    800023ac:	e0a2                	sd	s0,64(sp)
    800023ae:	fc26                	sd	s1,56(sp)
    800023b0:	f84a                	sd	s2,48(sp)
    800023b2:	f44e                	sd	s3,40(sp)
    800023b4:	f052                	sd	s4,32(sp)
    800023b6:	ec56                	sd	s5,24(sp)
    800023b8:	e85a                	sd	s6,16(sp)
    800023ba:	e45e                	sd	s7,8(sp)
    800023bc:	e062                	sd	s8,0(sp)
    800023be:	0880                	addi	s0,sp,80
    800023c0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	5e4080e7          	jalr	1508(ra) # 800019a6 <myproc>
    800023ca:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023cc:	0000e517          	auipc	a0,0xe
    800023d0:	7dc50513          	addi	a0,a0,2012 # 80010ba8 <wait_lock>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	7fe080e7          	jalr	2046(ra) # 80000bd2 <acquire>
    havekids = 0;
    800023dc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023de:	4a15                	li	s4,5
        havekids = 1;
    800023e0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e2:	00014997          	auipc	s3,0x14
    800023e6:	5de98993          	addi	s3,s3,1502 # 800169c0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023ea:	0000ec17          	auipc	s8,0xe
    800023ee:	7bec0c13          	addi	s8,s8,1982 # 80010ba8 <wait_lock>
    800023f2:	a0d1                	j	800024b6 <wait+0x10e>
          pid = pp->pid;
    800023f4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023f8:	000b0e63          	beqz	s6,80002414 <wait+0x6c>
    800023fc:	4691                	li	a3,4
    800023fe:	02c48613          	addi	a2,s1,44
    80002402:	85da                	mv	a1,s6
    80002404:	05093503          	ld	a0,80(s2)
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	25e080e7          	jalr	606(ra) # 80001666 <copyout>
    80002410:	04054163          	bltz	a0,80002452 <wait+0xaa>
          freeproc(pp);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	742080e7          	jalr	1858(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	866080e7          	jalr	-1946(ra) # 80000c86 <release>
          release(&wait_lock);
    80002428:	0000e517          	auipc	a0,0xe
    8000242c:	78050513          	addi	a0,a0,1920 # 80010ba8 <wait_lock>
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	856080e7          	jalr	-1962(ra) # 80000c86 <release>
}
    80002438:	854e                	mv	a0,s3
    8000243a:	60a6                	ld	ra,72(sp)
    8000243c:	6406                	ld	s0,64(sp)
    8000243e:	74e2                	ld	s1,56(sp)
    80002440:	7942                	ld	s2,48(sp)
    80002442:	79a2                	ld	s3,40(sp)
    80002444:	7a02                	ld	s4,32(sp)
    80002446:	6ae2                	ld	s5,24(sp)
    80002448:	6b42                	ld	s6,16(sp)
    8000244a:	6ba2                	ld	s7,8(sp)
    8000244c:	6c02                	ld	s8,0(sp)
    8000244e:	6161                	addi	sp,sp,80
    80002450:	8082                	ret
            release(&pp->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	832080e7          	jalr	-1998(ra) # 80000c86 <release>
            release(&wait_lock);
    8000245c:	0000e517          	auipc	a0,0xe
    80002460:	74c50513          	addi	a0,a0,1868 # 80010ba8 <wait_lock>
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	822080e7          	jalr	-2014(ra) # 80000c86 <release>
            return -1;
    8000246c:	59fd                	li	s3,-1
    8000246e:	b7e9                	j	80002438 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002470:	16848493          	addi	s1,s1,360
    80002474:	03348463          	beq	s1,s3,8000249c <wait+0xf4>
      if(pp->parent == p){
    80002478:	7c9c                	ld	a5,56(s1)
    8000247a:	ff279be3          	bne	a5,s2,80002470 <wait+0xc8>
        acquire(&pp->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	752080e7          	jalr	1874(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002488:	4c9c                	lw	a5,24(s1)
    8000248a:	f74785e3          	beq	a5,s4,800023f4 <wait+0x4c>
        release(&pp->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	ffffe097          	auipc	ra,0xffffe
    80002494:	7f6080e7          	jalr	2038(ra) # 80000c86 <release>
        havekids = 1;
    80002498:	8756                	mv	a4,s5
    8000249a:	bfd9                	j	80002470 <wait+0xc8>
    if(!havekids || killed(p)){
    8000249c:	c31d                	beqz	a4,800024c2 <wait+0x11a>
    8000249e:	854a                	mv	a0,s2
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	ed6080e7          	jalr	-298(ra) # 80002376 <killed>
    800024a8:	ed09                	bnez	a0,800024c2 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024aa:	85e2                	mv	a1,s8
    800024ac:	854a                	mv	a0,s2
    800024ae:	00000097          	auipc	ra,0x0
    800024b2:	c20080e7          	jalr	-992(ra) # 800020ce <sleep>
    havekids = 0;
    800024b6:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b8:	0000f497          	auipc	s1,0xf
    800024bc:	b0848493          	addi	s1,s1,-1272 # 80010fc0 <proc>
    800024c0:	bf65                	j	80002478 <wait+0xd0>
      release(&wait_lock);
    800024c2:	0000e517          	auipc	a0,0xe
    800024c6:	6e650513          	addi	a0,a0,1766 # 80010ba8 <wait_lock>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	7bc080e7          	jalr	1980(ra) # 80000c86 <release>
      return -1;
    800024d2:	59fd                	li	s3,-1
    800024d4:	b795                	j	80002438 <wait+0x90>

00000000800024d6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d6:	7179                	addi	sp,sp,-48
    800024d8:	f406                	sd	ra,40(sp)
    800024da:	f022                	sd	s0,32(sp)
    800024dc:	ec26                	sd	s1,24(sp)
    800024de:	e84a                	sd	s2,16(sp)
    800024e0:	e44e                	sd	s3,8(sp)
    800024e2:	e052                	sd	s4,0(sp)
    800024e4:	1800                	addi	s0,sp,48
    800024e6:	84aa                	mv	s1,a0
    800024e8:	892e                	mv	s2,a1
    800024ea:	89b2                	mv	s3,a2
    800024ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	4b8080e7          	jalr	1208(ra) # 800019a6 <myproc>
  if(user_dst){
    800024f6:	c08d                	beqz	s1,80002518 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024f8:	86d2                	mv	a3,s4
    800024fa:	864e                	mv	a2,s3
    800024fc:	85ca                	mv	a1,s2
    800024fe:	6928                	ld	a0,80(a0)
    80002500:	fffff097          	auipc	ra,0xfffff
    80002504:	166080e7          	jalr	358(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6a02                	ld	s4,0(sp)
    80002514:	6145                	addi	sp,sp,48
    80002516:	8082                	ret
    memmove((char *)dst, src, len);
    80002518:	000a061b          	sext.w	a2,s4
    8000251c:	85ce                	mv	a1,s3
    8000251e:	854a                	mv	a0,s2
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	80a080e7          	jalr	-2038(ra) # 80000d2a <memmove>
    return 0;
    80002528:	8526                	mv	a0,s1
    8000252a:	bff9                	j	80002508 <either_copyout+0x32>

000000008000252c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000252c:	7179                	addi	sp,sp,-48
    8000252e:	f406                	sd	ra,40(sp)
    80002530:	f022                	sd	s0,32(sp)
    80002532:	ec26                	sd	s1,24(sp)
    80002534:	e84a                	sd	s2,16(sp)
    80002536:	e44e                	sd	s3,8(sp)
    80002538:	e052                	sd	s4,0(sp)
    8000253a:	1800                	addi	s0,sp,48
    8000253c:	892a                	mv	s2,a0
    8000253e:	84ae                	mv	s1,a1
    80002540:	89b2                	mv	s3,a2
    80002542:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	462080e7          	jalr	1122(ra) # 800019a6 <myproc>
  if(user_src){
    8000254c:	c08d                	beqz	s1,8000256e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000254e:	86d2                	mv	a3,s4
    80002550:	864e                	mv	a2,s3
    80002552:	85ca                	mv	a1,s2
    80002554:	6928                	ld	a0,80(a0)
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	19c080e7          	jalr	412(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000255e:	70a2                	ld	ra,40(sp)
    80002560:	7402                	ld	s0,32(sp)
    80002562:	64e2                	ld	s1,24(sp)
    80002564:	6942                	ld	s2,16(sp)
    80002566:	69a2                	ld	s3,8(sp)
    80002568:	6a02                	ld	s4,0(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000256e:	000a061b          	sext.w	a2,s4
    80002572:	85ce                	mv	a1,s3
    80002574:	854a                	mv	a0,s2
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	7b4080e7          	jalr	1972(ra) # 80000d2a <memmove>
    return 0;
    8000257e:	8526                	mv	a0,s1
    80002580:	bff9                	j	8000255e <either_copyin+0x32>

0000000080002582 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002582:	715d                	addi	sp,sp,-80
    80002584:	e486                	sd	ra,72(sp)
    80002586:	e0a2                	sd	s0,64(sp)
    80002588:	fc26                	sd	s1,56(sp)
    8000258a:	f84a                	sd	s2,48(sp)
    8000258c:	f44e                	sd	s3,40(sp)
    8000258e:	f052                	sd	s4,32(sp)
    80002590:	ec56                	sd	s5,24(sp)
    80002592:	e85a                	sd	s6,16(sp)
    80002594:	e45e                	sd	s7,8(sp)
    80002596:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002598:	00006517          	auipc	a0,0x6
    8000259c:	b3050513          	addi	a0,a0,-1232 # 800080c8 <digits+0x88>
    800025a0:	ffffe097          	auipc	ra,0xffffe
    800025a4:	fe6080e7          	jalr	-26(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a8:	0000f497          	auipc	s1,0xf
    800025ac:	b7048493          	addi	s1,s1,-1168 # 80011118 <proc+0x158>
    800025b0:	00014917          	auipc	s2,0x14
    800025b4:	56890913          	addi	s2,s2,1384 # 80016b18 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025ba:	00006997          	auipc	s3,0x6
    800025be:	cc698993          	addi	s3,s3,-826 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025c2:	00006a97          	auipc	s5,0x6
    800025c6:	cc6a8a93          	addi	s5,s5,-826 # 80008288 <digits+0x248>
    printf("\n");
    800025ca:	00006a17          	auipc	s4,0x6
    800025ce:	afea0a13          	addi	s4,s4,-1282 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d2:	00006b97          	auipc	s7,0x6
    800025d6:	cf6b8b93          	addi	s7,s7,-778 # 800082c8 <states.0>
    800025da:	a00d                	j	800025fc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025dc:	ed86a583          	lw	a1,-296(a3)
    800025e0:	8556                	mv	a0,s5
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	fa4080e7          	jalr	-92(ra) # 80000586 <printf>
    printf("\n");
    800025ea:	8552                	mv	a0,s4
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	f9a080e7          	jalr	-102(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f4:	16848493          	addi	s1,s1,360
    800025f8:	03248263          	beq	s1,s2,8000261c <procdump+0x9a>
    if(p->state == UNUSED)
    800025fc:	86a6                	mv	a3,s1
    800025fe:	ec04a783          	lw	a5,-320(s1)
    80002602:	dbed                	beqz	a5,800025f4 <procdump+0x72>
      state = "???";
    80002604:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002606:	fcfb6be3          	bltu	s6,a5,800025dc <procdump+0x5a>
    8000260a:	02079713          	slli	a4,a5,0x20
    8000260e:	01d75793          	srli	a5,a4,0x1d
    80002612:	97de                	add	a5,a5,s7
    80002614:	6390                	ld	a2,0(a5)
    80002616:	f279                	bnez	a2,800025dc <procdump+0x5a>
      state = "???";
    80002618:	864e                	mv	a2,s3
    8000261a:	b7c9                	j	800025dc <procdump+0x5a>
  }
}
    8000261c:	60a6                	ld	ra,72(sp)
    8000261e:	6406                	ld	s0,64(sp)
    80002620:	74e2                	ld	s1,56(sp)
    80002622:	7942                	ld	s2,48(sp)
    80002624:	79a2                	ld	s3,40(sp)
    80002626:	7a02                	ld	s4,32(sp)
    80002628:	6ae2                	ld	s5,24(sp)
    8000262a:	6b42                	ld	s6,16(sp)
    8000262c:	6ba2                	ld	s7,8(sp)
    8000262e:	6161                	addi	sp,sp,80
    80002630:	8082                	ret

0000000080002632 <swtch>:
    80002632:	00153023          	sd	ra,0(a0)
    80002636:	00253423          	sd	sp,8(a0)
    8000263a:	e900                	sd	s0,16(a0)
    8000263c:	ed04                	sd	s1,24(a0)
    8000263e:	03253023          	sd	s2,32(a0)
    80002642:	03353423          	sd	s3,40(a0)
    80002646:	03453823          	sd	s4,48(a0)
    8000264a:	03553c23          	sd	s5,56(a0)
    8000264e:	05653023          	sd	s6,64(a0)
    80002652:	05753423          	sd	s7,72(a0)
    80002656:	05853823          	sd	s8,80(a0)
    8000265a:	05953c23          	sd	s9,88(a0)
    8000265e:	07a53023          	sd	s10,96(a0)
    80002662:	07b53423          	sd	s11,104(a0)
    80002666:	0005b083          	ld	ra,0(a1)
    8000266a:	0085b103          	ld	sp,8(a1)
    8000266e:	6980                	ld	s0,16(a1)
    80002670:	6d84                	ld	s1,24(a1)
    80002672:	0205b903          	ld	s2,32(a1)
    80002676:	0285b983          	ld	s3,40(a1)
    8000267a:	0305ba03          	ld	s4,48(a1)
    8000267e:	0385ba83          	ld	s5,56(a1)
    80002682:	0405bb03          	ld	s6,64(a1)
    80002686:	0485bb83          	ld	s7,72(a1)
    8000268a:	0505bc03          	ld	s8,80(a1)
    8000268e:	0585bc83          	ld	s9,88(a1)
    80002692:	0605bd03          	ld	s10,96(a1)
    80002696:	0685bd83          	ld	s11,104(a1)
    8000269a:	8082                	ret

000000008000269c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000269c:	1141                	addi	sp,sp,-16
    8000269e:	e406                	sd	ra,8(sp)
    800026a0:	e022                	sd	s0,0(sp)
    800026a2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026a4:	00006597          	auipc	a1,0x6
    800026a8:	c5458593          	addi	a1,a1,-940 # 800082f8 <states.0+0x30>
    800026ac:	00014517          	auipc	a0,0x14
    800026b0:	31450513          	addi	a0,a0,788 # 800169c0 <tickslock>
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	48e080e7          	jalr	1166(ra) # 80000b42 <initlock>
}
    800026bc:	60a2                	ld	ra,8(sp)
    800026be:	6402                	ld	s0,0(sp)
    800026c0:	0141                	addi	sp,sp,16
    800026c2:	8082                	ret

00000000800026c4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026c4:	1141                	addi	sp,sp,-16
    800026c6:	e422                	sd	s0,8(sp)
    800026c8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ca:	00003797          	auipc	a5,0x3
    800026ce:	55678793          	addi	a5,a5,1366 # 80005c20 <kernelvec>
    800026d2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026d6:	6422                	ld	s0,8(sp)
    800026d8:	0141                	addi	sp,sp,16
    800026da:	8082                	ret

00000000800026dc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026dc:	1141                	addi	sp,sp,-16
    800026de:	e406                	sd	ra,8(sp)
    800026e0:	e022                	sd	s0,0(sp)
    800026e2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026e4:	fffff097          	auipc	ra,0xfffff
    800026e8:	2c2080e7          	jalr	706(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026f0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026f6:	00005697          	auipc	a3,0x5
    800026fa:	90a68693          	addi	a3,a3,-1782 # 80007000 <_trampoline>
    800026fe:	00005717          	auipc	a4,0x5
    80002702:	90270713          	addi	a4,a4,-1790 # 80007000 <_trampoline>
    80002706:	8f15                	sub	a4,a4,a3
    80002708:	040007b7          	lui	a5,0x4000
    8000270c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000270e:	07b2                	slli	a5,a5,0xc
    80002710:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002712:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002716:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002718:	18002673          	csrr	a2,satp
    8000271c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000271e:	6d30                	ld	a2,88(a0)
    80002720:	6138                	ld	a4,64(a0)
    80002722:	6585                	lui	a1,0x1
    80002724:	972e                	add	a4,a4,a1
    80002726:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002728:	6d38                	ld	a4,88(a0)
    8000272a:	00000617          	auipc	a2,0x0
    8000272e:	13460613          	addi	a2,a2,308 # 8000285e <usertrap>
    80002732:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002734:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002736:	8612                	mv	a2,tp
    80002738:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000273e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002742:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002746:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000274a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000274c:	6f18                	ld	a4,24(a4)
    8000274e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002752:	6928                	ld	a0,80(a0)
    80002754:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002756:	00005717          	auipc	a4,0x5
    8000275a:	94670713          	addi	a4,a4,-1722 # 8000709c <userret>
    8000275e:	8f15                	sub	a4,a4,a3
    80002760:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002762:	577d                	li	a4,-1
    80002764:	177e                	slli	a4,a4,0x3f
    80002766:	8d59                	or	a0,a0,a4
    80002768:	9782                	jalr	a5
}
    8000276a:	60a2                	ld	ra,8(sp)
    8000276c:	6402                	ld	s0,0(sp)
    8000276e:	0141                	addi	sp,sp,16
    80002770:	8082                	ret

0000000080002772 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002772:	1101                	addi	sp,sp,-32
    80002774:	ec06                	sd	ra,24(sp)
    80002776:	e822                	sd	s0,16(sp)
    80002778:	e426                	sd	s1,8(sp)
    8000277a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000277c:	00014497          	auipc	s1,0x14
    80002780:	24448493          	addi	s1,s1,580 # 800169c0 <tickslock>
    80002784:	8526                	mv	a0,s1
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	44c080e7          	jalr	1100(ra) # 80000bd2 <acquire>
  ticks++;
    8000278e:	00006517          	auipc	a0,0x6
    80002792:	19250513          	addi	a0,a0,402 # 80008920 <ticks>
    80002796:	411c                	lw	a5,0(a0)
    80002798:	2785                	addiw	a5,a5,1
    8000279a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000279c:	00000097          	auipc	ra,0x0
    800027a0:	996080e7          	jalr	-1642(ra) # 80002132 <wakeup>
  release(&tickslock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4e0080e7          	jalr	1248(ra) # 80000c86 <release>
}
    800027ae:	60e2                	ld	ra,24(sp)
    800027b0:	6442                	ld	s0,16(sp)
    800027b2:	64a2                	ld	s1,8(sp)
    800027b4:	6105                	addi	sp,sp,32
    800027b6:	8082                	ret

00000000800027b8 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b8:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027bc:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027be:	0807df63          	bgez	a5,8000285c <devintr+0xa4>
{
    800027c2:	1101                	addi	sp,sp,-32
    800027c4:	ec06                	sd	ra,24(sp)
    800027c6:	e822                	sd	s0,16(sp)
    800027c8:	e426                	sd	s1,8(sp)
    800027ca:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027cc:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027d0:	46a5                	li	a3,9
    800027d2:	00d70d63          	beq	a4,a3,800027ec <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800027d6:	577d                	li	a4,-1
    800027d8:	177e                	slli	a4,a4,0x3f
    800027da:	0705                	addi	a4,a4,1
    return 0;
    800027dc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027de:	04e78e63          	beq	a5,a4,8000283a <devintr+0x82>
  }
}
    800027e2:	60e2                	ld	ra,24(sp)
    800027e4:	6442                	ld	s0,16(sp)
    800027e6:	64a2                	ld	s1,8(sp)
    800027e8:	6105                	addi	sp,sp,32
    800027ea:	8082                	ret
    int irq = plic_claim();
    800027ec:	00003097          	auipc	ra,0x3
    800027f0:	53c080e7          	jalr	1340(ra) # 80005d28 <plic_claim>
    800027f4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027f6:	47a9                	li	a5,10
    800027f8:	02f50763          	beq	a0,a5,80002826 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800027fc:	4785                	li	a5,1
    800027fe:	02f50963          	beq	a0,a5,80002830 <devintr+0x78>
    return 1;
    80002802:	4505                	li	a0,1
    } else if(irq){
    80002804:	dcf9                	beqz	s1,800027e2 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002806:	85a6                	mv	a1,s1
    80002808:	00006517          	auipc	a0,0x6
    8000280c:	af850513          	addi	a0,a0,-1288 # 80008300 <states.0+0x38>
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	d76080e7          	jalr	-650(ra) # 80000586 <printf>
      plic_complete(irq);
    80002818:	8526                	mv	a0,s1
    8000281a:	00003097          	auipc	ra,0x3
    8000281e:	532080e7          	jalr	1330(ra) # 80005d4c <plic_complete>
    return 1;
    80002822:	4505                	li	a0,1
    80002824:	bf7d                	j	800027e2 <devintr+0x2a>
      uartintr();
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	16e080e7          	jalr	366(ra) # 80000994 <uartintr>
    if(irq)
    8000282e:	b7ed                	j	80002818 <devintr+0x60>
      virtio_disk_intr();
    80002830:	00004097          	auipc	ra,0x4
    80002834:	9e2080e7          	jalr	-1566(ra) # 80006212 <virtio_disk_intr>
    if(irq)
    80002838:	b7c5                	j	80002818 <devintr+0x60>
    if(cpuid() == 0){
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	140080e7          	jalr	320(ra) # 8000197a <cpuid>
    80002842:	c901                	beqz	a0,80002852 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002844:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002848:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000284a:	14479073          	csrw	sip,a5
    return 2;
    8000284e:	4509                	li	a0,2
    80002850:	bf49                	j	800027e2 <devintr+0x2a>
      clockintr();
    80002852:	00000097          	auipc	ra,0x0
    80002856:	f20080e7          	jalr	-224(ra) # 80002772 <clockintr>
    8000285a:	b7ed                	j	80002844 <devintr+0x8c>
}
    8000285c:	8082                	ret

000000008000285e <usertrap>:
{
    8000285e:	1101                	addi	sp,sp,-32
    80002860:	ec06                	sd	ra,24(sp)
    80002862:	e822                	sd	s0,16(sp)
    80002864:	e426                	sd	s1,8(sp)
    80002866:	e04a                	sd	s2,0(sp)
    80002868:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000286e:	1007f793          	andi	a5,a5,256
    80002872:	e3b1                	bnez	a5,800028b6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002874:	00003797          	auipc	a5,0x3
    80002878:	3ac78793          	addi	a5,a5,940 # 80005c20 <kernelvec>
    8000287c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002880:	fffff097          	auipc	ra,0xfffff
    80002884:	126080e7          	jalr	294(ra) # 800019a6 <myproc>
    80002888:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000288a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000288c:	14102773          	csrr	a4,sepc
    80002890:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002892:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002896:	47a1                	li	a5,8
    80002898:	02f70763          	beq	a4,a5,800028c6 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000289c:	00000097          	auipc	ra,0x0
    800028a0:	f1c080e7          	jalr	-228(ra) # 800027b8 <devintr>
    800028a4:	892a                	mv	s2,a0
    800028a6:	c151                	beqz	a0,8000292a <usertrap+0xcc>
  if(killed(p))
    800028a8:	8526                	mv	a0,s1
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	acc080e7          	jalr	-1332(ra) # 80002376 <killed>
    800028b2:	c929                	beqz	a0,80002904 <usertrap+0xa6>
    800028b4:	a099                	j	800028fa <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028b6:	00006517          	auipc	a0,0x6
    800028ba:	a6a50513          	addi	a0,a0,-1430 # 80008320 <states.0+0x58>
    800028be:	ffffe097          	auipc	ra,0xffffe
    800028c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>
    if(killed(p))
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	ab0080e7          	jalr	-1360(ra) # 80002376 <killed>
    800028ce:	e921                	bnez	a0,8000291e <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028d0:	6cb8                	ld	a4,88(s1)
    800028d2:	6f1c                	ld	a5,24(a4)
    800028d4:	0791                	addi	a5,a5,4
    800028d6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028dc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e0:	10079073          	csrw	sstatus,a5
    syscall();
    800028e4:	00000097          	auipc	ra,0x0
    800028e8:	2d4080e7          	jalr	724(ra) # 80002bb8 <syscall>
  if(killed(p))
    800028ec:	8526                	mv	a0,s1
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	a88080e7          	jalr	-1400(ra) # 80002376 <killed>
    800028f6:	c911                	beqz	a0,8000290a <usertrap+0xac>
    800028f8:	4901                	li	s2,0
    exit(-1);
    800028fa:	557d                	li	a0,-1
    800028fc:	00000097          	auipc	ra,0x0
    80002900:	906080e7          	jalr	-1786(ra) # 80002202 <exit>
  if(which_dev == 2)
    80002904:	4789                	li	a5,2
    80002906:	04f90f63          	beq	s2,a5,80002964 <usertrap+0x106>
  usertrapret();
    8000290a:	00000097          	auipc	ra,0x0
    8000290e:	dd2080e7          	jalr	-558(ra) # 800026dc <usertrapret>
}
    80002912:	60e2                	ld	ra,24(sp)
    80002914:	6442                	ld	s0,16(sp)
    80002916:	64a2                	ld	s1,8(sp)
    80002918:	6902                	ld	s2,0(sp)
    8000291a:	6105                	addi	sp,sp,32
    8000291c:	8082                	ret
      exit(-1);
    8000291e:	557d                	li	a0,-1
    80002920:	00000097          	auipc	ra,0x0
    80002924:	8e2080e7          	jalr	-1822(ra) # 80002202 <exit>
    80002928:	b765                	j	800028d0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000292e:	5890                	lw	a2,48(s1)
    80002930:	00006517          	auipc	a0,0x6
    80002934:	a1050513          	addi	a0,a0,-1520 # 80008340 <states.0+0x78>
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	c4e080e7          	jalr	-946(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002940:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002944:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002948:	00006517          	auipc	a0,0x6
    8000294c:	a2850513          	addi	a0,a0,-1496 # 80008370 <states.0+0xa8>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	c36080e7          	jalr	-970(ra) # 80000586 <printf>
    setkilled(p);
    80002958:	8526                	mv	a0,s1
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	9f0080e7          	jalr	-1552(ra) # 8000234a <setkilled>
    80002962:	b769                	j	800028ec <usertrap+0x8e>
    yield();
    80002964:	fffff097          	auipc	ra,0xfffff
    80002968:	72e080e7          	jalr	1838(ra) # 80002092 <yield>
    8000296c:	bf79                	j	8000290a <usertrap+0xac>

000000008000296e <kerneltrap>:
{
    8000296e:	7179                	addi	sp,sp,-48
    80002970:	f406                	sd	ra,40(sp)
    80002972:	f022                	sd	s0,32(sp)
    80002974:	ec26                	sd	s1,24(sp)
    80002976:	e84a                	sd	s2,16(sp)
    80002978:	e44e                	sd	s3,8(sp)
    8000297a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002980:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002984:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002988:	1004f793          	andi	a5,s1,256
    8000298c:	cb85                	beqz	a5,800029bc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000298e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002992:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002994:	ef85                	bnez	a5,800029cc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	e22080e7          	jalr	-478(ra) # 800027b8 <devintr>
    8000299e:	cd1d                	beqz	a0,800029dc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a0:	4789                	li	a5,2
    800029a2:	06f50a63          	beq	a0,a5,80002a16 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029a6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029aa:	10049073          	csrw	sstatus,s1
}
    800029ae:	70a2                	ld	ra,40(sp)
    800029b0:	7402                	ld	s0,32(sp)
    800029b2:	64e2                	ld	s1,24(sp)
    800029b4:	6942                	ld	s2,16(sp)
    800029b6:	69a2                	ld	s3,8(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	9d450513          	addi	a0,a0,-1580 # 80008390 <states.0+0xc8>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	b78080e7          	jalr	-1160(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	9ec50513          	addi	a0,a0,-1556 # 800083b8 <states.0+0xf0>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	b68080e7          	jalr	-1176(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800029dc:	85ce                	mv	a1,s3
    800029de:	00006517          	auipc	a0,0x6
    800029e2:	9fa50513          	addi	a0,a0,-1542 # 800083d8 <states.0+0x110>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	ba0080e7          	jalr	-1120(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ee:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029f2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	9f250513          	addi	a0,a0,-1550 # 800083e8 <states.0+0x120>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b88080e7          	jalr	-1144(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002a06:	00006517          	auipc	a0,0x6
    80002a0a:	9fa50513          	addi	a0,a0,-1542 # 80008400 <states.0+0x138>
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	b2e080e7          	jalr	-1234(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	f90080e7          	jalr	-112(ra) # 800019a6 <myproc>
    80002a1e:	d541                	beqz	a0,800029a6 <kerneltrap+0x38>
    80002a20:	fffff097          	auipc	ra,0xfffff
    80002a24:	f86080e7          	jalr	-122(ra) # 800019a6 <myproc>
    80002a28:	4d18                	lw	a4,24(a0)
    80002a2a:	4791                	li	a5,4
    80002a2c:	f6f71de3          	bne	a4,a5,800029a6 <kerneltrap+0x38>
    yield();
    80002a30:	fffff097          	auipc	ra,0xfffff
    80002a34:	662080e7          	jalr	1634(ra) # 80002092 <yield>
    80002a38:	b7bd                	j	800029a6 <kerneltrap+0x38>

0000000080002a3a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a3a:	1101                	addi	sp,sp,-32
    80002a3c:	ec06                	sd	ra,24(sp)
    80002a3e:	e822                	sd	s0,16(sp)
    80002a40:	e426                	sd	s1,8(sp)
    80002a42:	1000                	addi	s0,sp,32
    80002a44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a46:	fffff097          	auipc	ra,0xfffff
    80002a4a:	f60080e7          	jalr	-160(ra) # 800019a6 <myproc>
  switch (n) {
    80002a4e:	4795                	li	a5,5
    80002a50:	0497e163          	bltu	a5,s1,80002a92 <argraw+0x58>
    80002a54:	048a                	slli	s1,s1,0x2
    80002a56:	00006717          	auipc	a4,0x6
    80002a5a:	9e270713          	addi	a4,a4,-1566 # 80008438 <states.0+0x170>
    80002a5e:	94ba                	add	s1,s1,a4
    80002a60:	409c                	lw	a5,0(s1)
    80002a62:	97ba                	add	a5,a5,a4
    80002a64:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a66:	6d3c                	ld	a5,88(a0)
    80002a68:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret
    return p->trapframe->a1;
    80002a74:	6d3c                	ld	a5,88(a0)
    80002a76:	7fa8                	ld	a0,120(a5)
    80002a78:	bfcd                	j	80002a6a <argraw+0x30>
    return p->trapframe->a2;
    80002a7a:	6d3c                	ld	a5,88(a0)
    80002a7c:	63c8                	ld	a0,128(a5)
    80002a7e:	b7f5                	j	80002a6a <argraw+0x30>
    return p->trapframe->a3;
    80002a80:	6d3c                	ld	a5,88(a0)
    80002a82:	67c8                	ld	a0,136(a5)
    80002a84:	b7dd                	j	80002a6a <argraw+0x30>
    return p->trapframe->a4;
    80002a86:	6d3c                	ld	a5,88(a0)
    80002a88:	6bc8                	ld	a0,144(a5)
    80002a8a:	b7c5                	j	80002a6a <argraw+0x30>
    return p->trapframe->a5;
    80002a8c:	6d3c                	ld	a5,88(a0)
    80002a8e:	6fc8                	ld	a0,152(a5)
    80002a90:	bfe9                	j	80002a6a <argraw+0x30>
  panic("argraw");
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	97e50513          	addi	a0,a0,-1666 # 80008410 <states.0+0x148>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	aa2080e7          	jalr	-1374(ra) # 8000053c <panic>

0000000080002aa2 <fetchaddr>:
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	e426                	sd	s1,8(sp)
    80002aaa:	e04a                	sd	s2,0(sp)
    80002aac:	1000                	addi	s0,sp,32
    80002aae:	84aa                	mv	s1,a0
    80002ab0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	ef4080e7          	jalr	-268(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002aba:	653c                	ld	a5,72(a0)
    80002abc:	02f4f863          	bgeu	s1,a5,80002aec <fetchaddr+0x4a>
    80002ac0:	00848713          	addi	a4,s1,8
    80002ac4:	02e7e663          	bltu	a5,a4,80002af0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ac8:	46a1                	li	a3,8
    80002aca:	8626                	mv	a2,s1
    80002acc:	85ca                	mv	a1,s2
    80002ace:	6928                	ld	a0,80(a0)
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	c22080e7          	jalr	-990(ra) # 800016f2 <copyin>
    80002ad8:	00a03533          	snez	a0,a0
    80002adc:	40a00533          	neg	a0,a0
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6902                	ld	s2,0(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret
    return -1;
    80002aec:	557d                	li	a0,-1
    80002aee:	bfcd                	j	80002ae0 <fetchaddr+0x3e>
    80002af0:	557d                	li	a0,-1
    80002af2:	b7fd                	j	80002ae0 <fetchaddr+0x3e>

0000000080002af4 <fetchstr>:
{
    80002af4:	7179                	addi	sp,sp,-48
    80002af6:	f406                	sd	ra,40(sp)
    80002af8:	f022                	sd	s0,32(sp)
    80002afa:	ec26                	sd	s1,24(sp)
    80002afc:	e84a                	sd	s2,16(sp)
    80002afe:	e44e                	sd	s3,8(sp)
    80002b00:	1800                	addi	s0,sp,48
    80002b02:	892a                	mv	s2,a0
    80002b04:	84ae                	mv	s1,a1
    80002b06:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	e9e080e7          	jalr	-354(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b10:	86ce                	mv	a3,s3
    80002b12:	864a                	mv	a2,s2
    80002b14:	85a6                	mv	a1,s1
    80002b16:	6928                	ld	a0,80(a0)
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	c68080e7          	jalr	-920(ra) # 80001780 <copyinstr>
    80002b20:	00054e63          	bltz	a0,80002b3c <fetchstr+0x48>
  return strlen(buf);
    80002b24:	8526                	mv	a0,s1
    80002b26:	ffffe097          	auipc	ra,0xffffe
    80002b2a:	322080e7          	jalr	802(ra) # 80000e48 <strlen>
}
    80002b2e:	70a2                	ld	ra,40(sp)
    80002b30:	7402                	ld	s0,32(sp)
    80002b32:	64e2                	ld	s1,24(sp)
    80002b34:	6942                	ld	s2,16(sp)
    80002b36:	69a2                	ld	s3,8(sp)
    80002b38:	6145                	addi	sp,sp,48
    80002b3a:	8082                	ret
    return -1;
    80002b3c:	557d                	li	a0,-1
    80002b3e:	bfc5                	j	80002b2e <fetchstr+0x3a>

0000000080002b40 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	1000                	addi	s0,sp,32
    80002b4a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b4c:	00000097          	auipc	ra,0x0
    80002b50:	eee080e7          	jalr	-274(ra) # 80002a3a <argraw>
    80002b54:	c088                	sw	a0,0(s1)
}
    80002b56:	60e2                	ld	ra,24(sp)
    80002b58:	6442                	ld	s0,16(sp)
    80002b5a:	64a2                	ld	s1,8(sp)
    80002b5c:	6105                	addi	sp,sp,32
    80002b5e:	8082                	ret

0000000080002b60 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	1000                	addi	s0,sp,32
    80002b6a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	ece080e7          	jalr	-306(ra) # 80002a3a <argraw>
    80002b74:	e088                	sd	a0,0(s1)
}
    80002b76:	60e2                	ld	ra,24(sp)
    80002b78:	6442                	ld	s0,16(sp)
    80002b7a:	64a2                	ld	s1,8(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret

0000000080002b80 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b80:	7179                	addi	sp,sp,-48
    80002b82:	f406                	sd	ra,40(sp)
    80002b84:	f022                	sd	s0,32(sp)
    80002b86:	ec26                	sd	s1,24(sp)
    80002b88:	e84a                	sd	s2,16(sp)
    80002b8a:	1800                	addi	s0,sp,48
    80002b8c:	84ae                	mv	s1,a1
    80002b8e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b90:	fd840593          	addi	a1,s0,-40
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	fcc080e7          	jalr	-52(ra) # 80002b60 <argaddr>
  return fetchstr(addr, buf, max);
    80002b9c:	864a                	mv	a2,s2
    80002b9e:	85a6                	mv	a1,s1
    80002ba0:	fd843503          	ld	a0,-40(s0)
    80002ba4:	00000097          	auipc	ra,0x0
    80002ba8:	f50080e7          	jalr	-176(ra) # 80002af4 <fetchstr>
}
    80002bac:	70a2                	ld	ra,40(sp)
    80002bae:	7402                	ld	s0,32(sp)
    80002bb0:	64e2                	ld	s1,24(sp)
    80002bb2:	6942                	ld	s2,16(sp)
    80002bb4:	6145                	addi	sp,sp,48
    80002bb6:	8082                	ret

0000000080002bb8 <syscall>:
[SYS_setpri]  sys_setpri,
};

void
syscall(void)
{
    80002bb8:	1101                	addi	sp,sp,-32
    80002bba:	ec06                	sd	ra,24(sp)
    80002bbc:	e822                	sd	s0,16(sp)
    80002bbe:	e426                	sd	s1,8(sp)
    80002bc0:	e04a                	sd	s2,0(sp)
    80002bc2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bc4:	fffff097          	auipc	ra,0xfffff
    80002bc8:	de2080e7          	jalr	-542(ra) # 800019a6 <myproc>
    80002bcc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bce:	05853903          	ld	s2,88(a0)
    80002bd2:	0a893783          	ld	a5,168(s2)
    80002bd6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bda:	37fd                	addiw	a5,a5,-1
    80002bdc:	4769                	li	a4,26
    80002bde:	00f76f63          	bltu	a4,a5,80002bfc <syscall+0x44>
    80002be2:	00369713          	slli	a4,a3,0x3
    80002be6:	00006797          	auipc	a5,0x6
    80002bea:	86a78793          	addi	a5,a5,-1942 # 80008450 <syscalls>
    80002bee:	97ba                	add	a5,a5,a4
    80002bf0:	639c                	ld	a5,0(a5)
    80002bf2:	c789                	beqz	a5,80002bfc <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002bf4:	9782                	jalr	a5
    80002bf6:	06a93823          	sd	a0,112(s2)
    80002bfa:	a839                	j	80002c18 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bfc:	15848613          	addi	a2,s1,344
    80002c00:	588c                	lw	a1,48(s1)
    80002c02:	00006517          	auipc	a0,0x6
    80002c06:	81650513          	addi	a0,a0,-2026 # 80008418 <states.0+0x150>
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	97c080e7          	jalr	-1668(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c12:	6cbc                	ld	a5,88(s1)
    80002c14:	577d                	li	a4,-1
    80002c16:	fbb8                	sd	a4,112(a5)
  }
}
    80002c18:	60e2                	ld	ra,24(sp)
    80002c1a:	6442                	ld	s0,16(sp)
    80002c1c:	64a2                	ld	s1,8(sp)
    80002c1e:	6902                	ld	s2,0(sp)
    80002c20:	6105                	addi	sp,sp,32
    80002c22:	8082                	ret

0000000080002c24 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c2c:	fec40593          	addi	a1,s0,-20
    80002c30:	4501                	li	a0,0
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	f0e080e7          	jalr	-242(ra) # 80002b40 <argint>
  exit(n);
    80002c3a:	fec42503          	lw	a0,-20(s0)
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	5c4080e7          	jalr	1476(ra) # 80002202 <exit>
  return 0;  // not reached
}
    80002c46:	4501                	li	a0,0
    80002c48:	60e2                	ld	ra,24(sp)
    80002c4a:	6442                	ld	s0,16(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c50:	1141                	addi	sp,sp,-16
    80002c52:	e406                	sd	ra,8(sp)
    80002c54:	e022                	sd	s0,0(sp)
    80002c56:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	d4e080e7          	jalr	-690(ra) # 800019a6 <myproc>
}
    80002c60:	5908                	lw	a0,48(a0)
    80002c62:	60a2                	ld	ra,8(sp)
    80002c64:	6402                	ld	s0,0(sp)
    80002c66:	0141                	addi	sp,sp,16
    80002c68:	8082                	ret

0000000080002c6a <sys_fork>:

uint64
sys_fork(void)
{
    80002c6a:	1141                	addi	sp,sp,-16
    80002c6c:	e406                	sd	ra,8(sp)
    80002c6e:	e022                	sd	s0,0(sp)
    80002c70:	0800                	addi	s0,sp,16
  return fork();
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	0ee080e7          	jalr	238(ra) # 80001d60 <fork>
}
    80002c7a:	60a2                	ld	ra,8(sp)
    80002c7c:	6402                	ld	s0,0(sp)
    80002c7e:	0141                	addi	sp,sp,16
    80002c80:	8082                	ret

0000000080002c82 <sys_wait>:

uint64
sys_wait(void)
{
    80002c82:	1101                	addi	sp,sp,-32
    80002c84:	ec06                	sd	ra,24(sp)
    80002c86:	e822                	sd	s0,16(sp)
    80002c88:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c8a:	fe840593          	addi	a1,s0,-24
    80002c8e:	4501                	li	a0,0
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	ed0080e7          	jalr	-304(ra) # 80002b60 <argaddr>
  return wait(p);
    80002c98:	fe843503          	ld	a0,-24(s0)
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	70c080e7          	jalr	1804(ra) # 800023a8 <wait>
}
    80002ca4:	60e2                	ld	ra,24(sp)
    80002ca6:	6442                	ld	s0,16(sp)
    80002ca8:	6105                	addi	sp,sp,32
    80002caa:	8082                	ret

0000000080002cac <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cac:	7179                	addi	sp,sp,-48
    80002cae:	f406                	sd	ra,40(sp)
    80002cb0:	f022                	sd	s0,32(sp)
    80002cb2:	ec26                	sd	s1,24(sp)
    80002cb4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cb6:	fdc40593          	addi	a1,s0,-36
    80002cba:	4501                	li	a0,0
    80002cbc:	00000097          	auipc	ra,0x0
    80002cc0:	e84080e7          	jalr	-380(ra) # 80002b40 <argint>
  addr = myproc()->sz;
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	ce2080e7          	jalr	-798(ra) # 800019a6 <myproc>
    80002ccc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cce:	fdc42503          	lw	a0,-36(s0)
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	032080e7          	jalr	50(ra) # 80001d04 <growproc>
    80002cda:	00054863          	bltz	a0,80002cea <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002cde:	8526                	mv	a0,s1
    80002ce0:	70a2                	ld	ra,40(sp)
    80002ce2:	7402                	ld	s0,32(sp)
    80002ce4:	64e2                	ld	s1,24(sp)
    80002ce6:	6145                	addi	sp,sp,48
    80002ce8:	8082                	ret
    return -1;
    80002cea:	54fd                	li	s1,-1
    80002cec:	bfcd                	j	80002cde <sys_sbrk+0x32>

0000000080002cee <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cee:	7139                	addi	sp,sp,-64
    80002cf0:	fc06                	sd	ra,56(sp)
    80002cf2:	f822                	sd	s0,48(sp)
    80002cf4:	f426                	sd	s1,40(sp)
    80002cf6:	f04a                	sd	s2,32(sp)
    80002cf8:	ec4e                	sd	s3,24(sp)
    80002cfa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cfc:	fcc40593          	addi	a1,s0,-52
    80002d00:	4501                	li	a0,0
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	e3e080e7          	jalr	-450(ra) # 80002b40 <argint>
  acquire(&tickslock);
    80002d0a:	00014517          	auipc	a0,0x14
    80002d0e:	cb650513          	addi	a0,a0,-842 # 800169c0 <tickslock>
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	ec0080e7          	jalr	-320(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002d1a:	00006917          	auipc	s2,0x6
    80002d1e:	c0692903          	lw	s2,-1018(s2) # 80008920 <ticks>
  while(ticks - ticks0 < n){
    80002d22:	fcc42783          	lw	a5,-52(s0)
    80002d26:	cf9d                	beqz	a5,80002d64 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d28:	00014997          	auipc	s3,0x14
    80002d2c:	c9898993          	addi	s3,s3,-872 # 800169c0 <tickslock>
    80002d30:	00006497          	auipc	s1,0x6
    80002d34:	bf048493          	addi	s1,s1,-1040 # 80008920 <ticks>
    if(killed(myproc())){
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	c6e080e7          	jalr	-914(ra) # 800019a6 <myproc>
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	636080e7          	jalr	1590(ra) # 80002376 <killed>
    80002d48:	ed15                	bnez	a0,80002d84 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d4a:	85ce                	mv	a1,s3
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	380080e7          	jalr	896(ra) # 800020ce <sleep>
  while(ticks - ticks0 < n){
    80002d56:	409c                	lw	a5,0(s1)
    80002d58:	412787bb          	subw	a5,a5,s2
    80002d5c:	fcc42703          	lw	a4,-52(s0)
    80002d60:	fce7ece3          	bltu	a5,a4,80002d38 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d64:	00014517          	auipc	a0,0x14
    80002d68:	c5c50513          	addi	a0,a0,-932 # 800169c0 <tickslock>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	f1a080e7          	jalr	-230(ra) # 80000c86 <release>
  return 0;
    80002d74:	4501                	li	a0,0
}
    80002d76:	70e2                	ld	ra,56(sp)
    80002d78:	7442                	ld	s0,48(sp)
    80002d7a:	74a2                	ld	s1,40(sp)
    80002d7c:	7902                	ld	s2,32(sp)
    80002d7e:	69e2                	ld	s3,24(sp)
    80002d80:	6121                	addi	sp,sp,64
    80002d82:	8082                	ret
      release(&tickslock);
    80002d84:	00014517          	auipc	a0,0x14
    80002d88:	c3c50513          	addi	a0,a0,-964 # 800169c0 <tickslock>
    80002d8c:	ffffe097          	auipc	ra,0xffffe
    80002d90:	efa080e7          	jalr	-262(ra) # 80000c86 <release>
      return -1;
    80002d94:	557d                	li	a0,-1
    80002d96:	b7c5                	j	80002d76 <sys_sleep+0x88>

0000000080002d98 <sys_kill>:

uint64
sys_kill(void)
{
    80002d98:	1101                	addi	sp,sp,-32
    80002d9a:	ec06                	sd	ra,24(sp)
    80002d9c:	e822                	sd	s0,16(sp)
    80002d9e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002da0:	fec40593          	addi	a1,s0,-20
    80002da4:	4501                	li	a0,0
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	d9a080e7          	jalr	-614(ra) # 80002b40 <argint>
  return kill(pid);
    80002dae:	fec42503          	lw	a0,-20(s0)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	526080e7          	jalr	1318(ra) # 800022d8 <kill>
}
    80002dba:	60e2                	ld	ra,24(sp)
    80002dbc:	6442                	ld	s0,16(sp)
    80002dbe:	6105                	addi	sp,sp,32
    80002dc0:	8082                	ret

0000000080002dc2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dc2:	1101                	addi	sp,sp,-32
    80002dc4:	ec06                	sd	ra,24(sp)
    80002dc6:	e822                	sd	s0,16(sp)
    80002dc8:	e426                	sd	s1,8(sp)
    80002dca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dcc:	00014517          	auipc	a0,0x14
    80002dd0:	bf450513          	addi	a0,a0,-1036 # 800169c0 <tickslock>
    80002dd4:	ffffe097          	auipc	ra,0xffffe
    80002dd8:	dfe080e7          	jalr	-514(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002ddc:	00006497          	auipc	s1,0x6
    80002de0:	b444a483          	lw	s1,-1212(s1) # 80008920 <ticks>
  release(&tickslock);
    80002de4:	00014517          	auipc	a0,0x14
    80002de8:	bdc50513          	addi	a0,a0,-1060 # 800169c0 <tickslock>
    80002dec:	ffffe097          	auipc	ra,0xffffe
    80002df0:	e9a080e7          	jalr	-358(ra) # 80000c86 <release>
  return xticks;
}
    80002df4:	02049513          	slli	a0,s1,0x20
    80002df8:	9101                	srli	a0,a0,0x20
    80002dfa:	60e2                	ld	ra,24(sp)
    80002dfc:	6442                	ld	s0,16(sp)
    80002dfe:	64a2                	ld	s1,8(sp)
    80002e00:	6105                	addi	sp,sp,32
    80002e02:	8082                	ret

0000000080002e04 <sys_getmem>:

//Project 2 syscalls:
uint64
sys_getmem(void)
{
    80002e04:	1141                	addi	sp,sp,-16
    80002e06:	e406                	sd	ra,8(sp)
    80002e08:	e022                	sd	s0,0(sp)
    80002e0a:	0800                	addi	s0,sp,16
   return myproc()->sz; // return the size of this process
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	b9a080e7          	jalr	-1126(ra) # 800019a6 <myproc>
}
    80002e14:	6528                	ld	a0,72(a0)
    80002e16:	60a2                	ld	ra,8(sp)
    80002e18:	6402                	ld	s0,0(sp)
    80002e1a:	0141                	addi	sp,sp,16
    80002e1c:	8082                	ret

0000000080002e1e <sys_getstate>:

uint64
sys_getstate(void)
{
    80002e1e:	1141                	addi	sp,sp,-16
    80002e20:	e406                	sd	ra,8(sp)
    80002e22:	e022                	sd	s0,0(sp)
    80002e24:	0800                	addi	s0,sp,16
  return myproc()->state;
    80002e26:	fffff097          	auipc	ra,0xfffff
    80002e2a:	b80080e7          	jalr	-1152(ra) # 800019a6 <myproc>
}
    80002e2e:	01856503          	lwu	a0,24(a0)
    80002e32:	60a2                	ld	ra,8(sp)
    80002e34:	6402                	ld	s0,0(sp)
    80002e36:	0141                	addi	sp,sp,16
    80002e38:	8082                	ret

0000000080002e3a <sys_getparentpid>:

uint64
sys_getparentpid(void)
{
    80002e3a:	1141                	addi	sp,sp,-16
    80002e3c:	e406                	sd	ra,8(sp)
    80002e3e:	e022                	sd	s0,0(sp)
    80002e40:	0800                	addi	s0,sp,16
  return myproc()->parent->pid; // reutrn the parent's pid
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	b64080e7          	jalr	-1180(ra) # 800019a6 <myproc>
    80002e4a:	7d1c                	ld	a5,56(a0)
}
    80002e4c:	5b88                	lw	a0,48(a5)
    80002e4e:	60a2                	ld	ra,8(sp)
    80002e50:	6402                	ld	s0,0(sp)
    80002e52:	0141                	addi	sp,sp,16
    80002e54:	8082                	ret

0000000080002e56 <sys_getkstack>:

uint64
sys_getkstack(void)
{
    80002e56:	1141                	addi	sp,sp,-16
    80002e58:	e406                	sd	ra,8(sp)
    80002e5a:	e022                	sd	s0,0(sp)
    80002e5c:	0800                	addi	s0,sp,16
  return myproc()->kstack; // return 64bit address (Base) of kstack
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	b48080e7          	jalr	-1208(ra) # 800019a6 <myproc>
}
    80002e66:	6128                	ld	a0,64(a0)
    80002e68:	60a2                	ld	ra,8(sp)
    80002e6a:	6402                	ld	s0,0(sp)
    80002e6c:	0141                	addi	sp,sp,16
    80002e6e:	8082                	ret

0000000080002e70 <sys_getpri>:

uint64
sys_getpri(void)
{
    80002e70:	1141                	addi	sp,sp,-16
    80002e72:	e406                	sd	ra,8(sp)
    80002e74:	e022                	sd	s0,0(sp)
    80002e76:	0800                	addi	s0,sp,16
  return myproc()->prio;
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	b2e080e7          	jalr	-1234(ra) # 800019a6 <myproc>
}
    80002e80:	5948                	lw	a0,52(a0)
    80002e82:	60a2                	ld	ra,8(sp)
    80002e84:	6402                	ld	s0,0(sp)
    80002e86:	0141                	addi	sp,sp,16
    80002e88:	8082                	ret

0000000080002e8a <sys_setpri>:

uint64
sys_setpri(void)
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	1000                	addi	s0,sp,32
  int reqpri;
  argint(0, &reqpri); // get the requested priority
    80002e92:	fec40593          	addi	a1,s0,-20
    80002e96:	4501                	li	a0,0
    80002e98:	00000097          	auipc	ra,0x0
    80002e9c:	ca8080e7          	jalr	-856(ra) # 80002b40 <argint>
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002ea0:	fec42783          	lw	a5,-20(s0)
    80002ea4:	ff67869b          	addiw	a3,a5,-10
    80002ea8:	4715                	li	a4,5
     acquire(&myproc()->lock);
     myproc()->prio = reqpri;
     release(&myproc()->lock);
     return 0;
  }
  return -1;
    80002eaa:	557d                	li	a0,-1
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002eac:	00d76563          	bltu	a4,a3,80002eb6 <sys_setpri+0x2c>
    80002eb0:	4739                	li	a4,14
    80002eb2:	00e79663          	bne	a5,a4,80002ebe <sys_setpri+0x34>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret
     acquire(&myproc()->lock);
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	ae8080e7          	jalr	-1304(ra) # 800019a6 <myproc>
    80002ec6:	ffffe097          	auipc	ra,0xffffe
    80002eca:	d0c080e7          	jalr	-756(ra) # 80000bd2 <acquire>
     myproc()->prio = reqpri;
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	ad8080e7          	jalr	-1320(ra) # 800019a6 <myproc>
    80002ed6:	fec42783          	lw	a5,-20(s0)
    80002eda:	d95c                	sw	a5,52(a0)
     release(&myproc()->lock);
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	aca080e7          	jalr	-1334(ra) # 800019a6 <myproc>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	da2080e7          	jalr	-606(ra) # 80000c86 <release>
     return 0;
    80002eec:	4501                	li	a0,0
    80002eee:	b7e1                	j	80002eb6 <sys_setpri+0x2c>

0000000080002ef0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ef0:	7179                	addi	sp,sp,-48
    80002ef2:	f406                	sd	ra,40(sp)
    80002ef4:	f022                	sd	s0,32(sp)
    80002ef6:	ec26                	sd	s1,24(sp)
    80002ef8:	e84a                	sd	s2,16(sp)
    80002efa:	e44e                	sd	s3,8(sp)
    80002efc:	e052                	sd	s4,0(sp)
    80002efe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f00:	00005597          	auipc	a1,0x5
    80002f04:	63058593          	addi	a1,a1,1584 # 80008530 <syscalls+0xe0>
    80002f08:	00014517          	auipc	a0,0x14
    80002f0c:	ad050513          	addi	a0,a0,-1328 # 800169d8 <bcache>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	c32080e7          	jalr	-974(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f18:	0001c797          	auipc	a5,0x1c
    80002f1c:	ac078793          	addi	a5,a5,-1344 # 8001e9d8 <bcache+0x8000>
    80002f20:	0001c717          	auipc	a4,0x1c
    80002f24:	d2070713          	addi	a4,a4,-736 # 8001ec40 <bcache+0x8268>
    80002f28:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f2c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f30:	00014497          	auipc	s1,0x14
    80002f34:	ac048493          	addi	s1,s1,-1344 # 800169f0 <bcache+0x18>
    b->next = bcache.head.next;
    80002f38:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f3a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f3c:	00005a17          	auipc	s4,0x5
    80002f40:	5fca0a13          	addi	s4,s4,1532 # 80008538 <syscalls+0xe8>
    b->next = bcache.head.next;
    80002f44:	2b893783          	ld	a5,696(s2)
    80002f48:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f4a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f4e:	85d2                	mv	a1,s4
    80002f50:	01048513          	addi	a0,s1,16
    80002f54:	00001097          	auipc	ra,0x1
    80002f58:	496080e7          	jalr	1174(ra) # 800043ea <initsleeplock>
    bcache.head.next->prev = b;
    80002f5c:	2b893783          	ld	a5,696(s2)
    80002f60:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f62:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f66:	45848493          	addi	s1,s1,1112
    80002f6a:	fd349de3          	bne	s1,s3,80002f44 <binit+0x54>
  }
}
    80002f6e:	70a2                	ld	ra,40(sp)
    80002f70:	7402                	ld	s0,32(sp)
    80002f72:	64e2                	ld	s1,24(sp)
    80002f74:	6942                	ld	s2,16(sp)
    80002f76:	69a2                	ld	s3,8(sp)
    80002f78:	6a02                	ld	s4,0(sp)
    80002f7a:	6145                	addi	sp,sp,48
    80002f7c:	8082                	ret

0000000080002f7e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	e44e                	sd	s3,8(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	892a                	mv	s2,a0
    80002f8e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f90:	00014517          	auipc	a0,0x14
    80002f94:	a4850513          	addi	a0,a0,-1464 # 800169d8 <bcache>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	c3a080e7          	jalr	-966(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fa0:	0001c497          	auipc	s1,0x1c
    80002fa4:	cf04b483          	ld	s1,-784(s1) # 8001ec90 <bcache+0x82b8>
    80002fa8:	0001c797          	auipc	a5,0x1c
    80002fac:	c9878793          	addi	a5,a5,-872 # 8001ec40 <bcache+0x8268>
    80002fb0:	02f48f63          	beq	s1,a5,80002fee <bread+0x70>
    80002fb4:	873e                	mv	a4,a5
    80002fb6:	a021                	j	80002fbe <bread+0x40>
    80002fb8:	68a4                	ld	s1,80(s1)
    80002fba:	02e48a63          	beq	s1,a4,80002fee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fbe:	449c                	lw	a5,8(s1)
    80002fc0:	ff279ce3          	bne	a5,s2,80002fb8 <bread+0x3a>
    80002fc4:	44dc                	lw	a5,12(s1)
    80002fc6:	ff3799e3          	bne	a5,s3,80002fb8 <bread+0x3a>
      b->refcnt++;
    80002fca:	40bc                	lw	a5,64(s1)
    80002fcc:	2785                	addiw	a5,a5,1
    80002fce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd0:	00014517          	auipc	a0,0x14
    80002fd4:	a0850513          	addi	a0,a0,-1528 # 800169d8 <bcache>
    80002fd8:	ffffe097          	auipc	ra,0xffffe
    80002fdc:	cae080e7          	jalr	-850(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fe0:	01048513          	addi	a0,s1,16
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	440080e7          	jalr	1088(ra) # 80004424 <acquiresleep>
      return b;
    80002fec:	a8b9                	j	8000304a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fee:	0001c497          	auipc	s1,0x1c
    80002ff2:	c9a4b483          	ld	s1,-870(s1) # 8001ec88 <bcache+0x82b0>
    80002ff6:	0001c797          	auipc	a5,0x1c
    80002ffa:	c4a78793          	addi	a5,a5,-950 # 8001ec40 <bcache+0x8268>
    80002ffe:	00f48863          	beq	s1,a5,8000300e <bread+0x90>
    80003002:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003004:	40bc                	lw	a5,64(s1)
    80003006:	cf81                	beqz	a5,8000301e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003008:	64a4                	ld	s1,72(s1)
    8000300a:	fee49de3          	bne	s1,a4,80003004 <bread+0x86>
  panic("bget: no buffers");
    8000300e:	00005517          	auipc	a0,0x5
    80003012:	53250513          	addi	a0,a0,1330 # 80008540 <syscalls+0xf0>
    80003016:	ffffd097          	auipc	ra,0xffffd
    8000301a:	526080e7          	jalr	1318(ra) # 8000053c <panic>
      b->dev = dev;
    8000301e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003022:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003026:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000302a:	4785                	li	a5,1
    8000302c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000302e:	00014517          	auipc	a0,0x14
    80003032:	9aa50513          	addi	a0,a0,-1622 # 800169d8 <bcache>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	c50080e7          	jalr	-944(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000303e:	01048513          	addi	a0,s1,16
    80003042:	00001097          	auipc	ra,0x1
    80003046:	3e2080e7          	jalr	994(ra) # 80004424 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000304a:	409c                	lw	a5,0(s1)
    8000304c:	cb89                	beqz	a5,8000305e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000304e:	8526                	mv	a0,s1
    80003050:	70a2                	ld	ra,40(sp)
    80003052:	7402                	ld	s0,32(sp)
    80003054:	64e2                	ld	s1,24(sp)
    80003056:	6942                	ld	s2,16(sp)
    80003058:	69a2                	ld	s3,8(sp)
    8000305a:	6145                	addi	sp,sp,48
    8000305c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000305e:	4581                	li	a1,0
    80003060:	8526                	mv	a0,s1
    80003062:	00003097          	auipc	ra,0x3
    80003066:	f80080e7          	jalr	-128(ra) # 80005fe2 <virtio_disk_rw>
    b->valid = 1;
    8000306a:	4785                	li	a5,1
    8000306c:	c09c                	sw	a5,0(s1)
  return b;
    8000306e:	b7c5                	j	8000304e <bread+0xd0>

0000000080003070 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	addi	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000307c:	0541                	addi	a0,a0,16
    8000307e:	00001097          	auipc	ra,0x1
    80003082:	440080e7          	jalr	1088(ra) # 800044be <holdingsleep>
    80003086:	cd01                	beqz	a0,8000309e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003088:	4585                	li	a1,1
    8000308a:	8526                	mv	a0,s1
    8000308c:	00003097          	auipc	ra,0x3
    80003090:	f56080e7          	jalr	-170(ra) # 80005fe2 <virtio_disk_rw>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret
    panic("bwrite");
    8000309e:	00005517          	auipc	a0,0x5
    800030a2:	4ba50513          	addi	a0,a0,1210 # 80008558 <syscalls+0x108>
    800030a6:	ffffd097          	auipc	ra,0xffffd
    800030aa:	496080e7          	jalr	1174(ra) # 8000053c <panic>

00000000800030ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030ae:	1101                	addi	sp,sp,-32
    800030b0:	ec06                	sd	ra,24(sp)
    800030b2:	e822                	sd	s0,16(sp)
    800030b4:	e426                	sd	s1,8(sp)
    800030b6:	e04a                	sd	s2,0(sp)
    800030b8:	1000                	addi	s0,sp,32
    800030ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030bc:	01050913          	addi	s2,a0,16
    800030c0:	854a                	mv	a0,s2
    800030c2:	00001097          	auipc	ra,0x1
    800030c6:	3fc080e7          	jalr	1020(ra) # 800044be <holdingsleep>
    800030ca:	c925                	beqz	a0,8000313a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030cc:	854a                	mv	a0,s2
    800030ce:	00001097          	auipc	ra,0x1
    800030d2:	3ac080e7          	jalr	940(ra) # 8000447a <releasesleep>

  acquire(&bcache.lock);
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	90250513          	addi	a0,a0,-1790 # 800169d8 <bcache>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	af4080e7          	jalr	-1292(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030e6:	40bc                	lw	a5,64(s1)
    800030e8:	37fd                	addiw	a5,a5,-1
    800030ea:	0007871b          	sext.w	a4,a5
    800030ee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030f0:	e71d                	bnez	a4,8000311e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030f2:	68b8                	ld	a4,80(s1)
    800030f4:	64bc                	ld	a5,72(s1)
    800030f6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030f8:	68b8                	ld	a4,80(s1)
    800030fa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030fc:	0001c797          	auipc	a5,0x1c
    80003100:	8dc78793          	addi	a5,a5,-1828 # 8001e9d8 <bcache+0x8000>
    80003104:	2b87b703          	ld	a4,696(a5)
    80003108:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000310a:	0001c717          	auipc	a4,0x1c
    8000310e:	b3670713          	addi	a4,a4,-1226 # 8001ec40 <bcache+0x8268>
    80003112:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003114:	2b87b703          	ld	a4,696(a5)
    80003118:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000311a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000311e:	00014517          	auipc	a0,0x14
    80003122:	8ba50513          	addi	a0,a0,-1862 # 800169d8 <bcache>
    80003126:	ffffe097          	auipc	ra,0xffffe
    8000312a:	b60080e7          	jalr	-1184(ra) # 80000c86 <release>
}
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	64a2                	ld	s1,8(sp)
    80003134:	6902                	ld	s2,0(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret
    panic("brelse");
    8000313a:	00005517          	auipc	a0,0x5
    8000313e:	42650513          	addi	a0,a0,1062 # 80008560 <syscalls+0x110>
    80003142:	ffffd097          	auipc	ra,0xffffd
    80003146:	3fa080e7          	jalr	1018(ra) # 8000053c <panic>

000000008000314a <bpin>:

void
bpin(struct buf *b) {
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003156:	00014517          	auipc	a0,0x14
    8000315a:	88250513          	addi	a0,a0,-1918 # 800169d8 <bcache>
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	a74080e7          	jalr	-1420(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003166:	40bc                	lw	a5,64(s1)
    80003168:	2785                	addiw	a5,a5,1
    8000316a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316c:	00014517          	auipc	a0,0x14
    80003170:	86c50513          	addi	a0,a0,-1940 # 800169d8 <bcache>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b12080e7          	jalr	-1262(ra) # 80000c86 <release>
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret

0000000080003186 <bunpin>:

void
bunpin(struct buf *b) {
    80003186:	1101                	addi	sp,sp,-32
    80003188:	ec06                	sd	ra,24(sp)
    8000318a:	e822                	sd	s0,16(sp)
    8000318c:	e426                	sd	s1,8(sp)
    8000318e:	1000                	addi	s0,sp,32
    80003190:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003192:	00014517          	auipc	a0,0x14
    80003196:	84650513          	addi	a0,a0,-1978 # 800169d8 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	a38080e7          	jalr	-1480(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031a2:	40bc                	lw	a5,64(s1)
    800031a4:	37fd                	addiw	a5,a5,-1
    800031a6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031a8:	00014517          	auipc	a0,0x14
    800031ac:	83050513          	addi	a0,a0,-2000 # 800169d8 <bcache>
    800031b0:	ffffe097          	auipc	ra,0xffffe
    800031b4:	ad6080e7          	jalr	-1322(ra) # 80000c86 <release>
}
    800031b8:	60e2                	ld	ra,24(sp)
    800031ba:	6442                	ld	s0,16(sp)
    800031bc:	64a2                	ld	s1,8(sp)
    800031be:	6105                	addi	sp,sp,32
    800031c0:	8082                	ret

00000000800031c2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031c2:	1101                	addi	sp,sp,-32
    800031c4:	ec06                	sd	ra,24(sp)
    800031c6:	e822                	sd	s0,16(sp)
    800031c8:	e426                	sd	s1,8(sp)
    800031ca:	e04a                	sd	s2,0(sp)
    800031cc:	1000                	addi	s0,sp,32
    800031ce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031d0:	00d5d59b          	srliw	a1,a1,0xd
    800031d4:	0001c797          	auipc	a5,0x1c
    800031d8:	ee07a783          	lw	a5,-288(a5) # 8001f0b4 <sb+0x1c>
    800031dc:	9dbd                	addw	a1,a1,a5
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	da0080e7          	jalr	-608(ra) # 80002f7e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031e6:	0074f713          	andi	a4,s1,7
    800031ea:	4785                	li	a5,1
    800031ec:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031f0:	14ce                	slli	s1,s1,0x33
    800031f2:	90d9                	srli	s1,s1,0x36
    800031f4:	00950733          	add	a4,a0,s1
    800031f8:	05874703          	lbu	a4,88(a4)
    800031fc:	00e7f6b3          	and	a3,a5,a4
    80003200:	c69d                	beqz	a3,8000322e <bfree+0x6c>
    80003202:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003204:	94aa                	add	s1,s1,a0
    80003206:	fff7c793          	not	a5,a5
    8000320a:	8f7d                	and	a4,a4,a5
    8000320c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003210:	00001097          	auipc	ra,0x1
    80003214:	0f6080e7          	jalr	246(ra) # 80004306 <log_write>
  brelse(bp);
    80003218:	854a                	mv	a0,s2
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	e94080e7          	jalr	-364(ra) # 800030ae <brelse>
}
    80003222:	60e2                	ld	ra,24(sp)
    80003224:	6442                	ld	s0,16(sp)
    80003226:	64a2                	ld	s1,8(sp)
    80003228:	6902                	ld	s2,0(sp)
    8000322a:	6105                	addi	sp,sp,32
    8000322c:	8082                	ret
    panic("freeing free block");
    8000322e:	00005517          	auipc	a0,0x5
    80003232:	33a50513          	addi	a0,a0,826 # 80008568 <syscalls+0x118>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	306080e7          	jalr	774(ra) # 8000053c <panic>

000000008000323e <balloc>:
{
    8000323e:	711d                	addi	sp,sp,-96
    80003240:	ec86                	sd	ra,88(sp)
    80003242:	e8a2                	sd	s0,80(sp)
    80003244:	e4a6                	sd	s1,72(sp)
    80003246:	e0ca                	sd	s2,64(sp)
    80003248:	fc4e                	sd	s3,56(sp)
    8000324a:	f852                	sd	s4,48(sp)
    8000324c:	f456                	sd	s5,40(sp)
    8000324e:	f05a                	sd	s6,32(sp)
    80003250:	ec5e                	sd	s7,24(sp)
    80003252:	e862                	sd	s8,16(sp)
    80003254:	e466                	sd	s9,8(sp)
    80003256:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003258:	0001c797          	auipc	a5,0x1c
    8000325c:	e447a783          	lw	a5,-444(a5) # 8001f09c <sb+0x4>
    80003260:	cff5                	beqz	a5,8000335c <balloc+0x11e>
    80003262:	8baa                	mv	s7,a0
    80003264:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003266:	0001cb17          	auipc	s6,0x1c
    8000326a:	e32b0b13          	addi	s6,s6,-462 # 8001f098 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000326e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003270:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003272:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003274:	6c89                	lui	s9,0x2
    80003276:	a061                	j	800032fe <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003278:	97ca                	add	a5,a5,s2
    8000327a:	8e55                	or	a2,a2,a3
    8000327c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003280:	854a                	mv	a0,s2
    80003282:	00001097          	auipc	ra,0x1
    80003286:	084080e7          	jalr	132(ra) # 80004306 <log_write>
        brelse(bp);
    8000328a:	854a                	mv	a0,s2
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	e22080e7          	jalr	-478(ra) # 800030ae <brelse>
  bp = bread(dev, bno);
    80003294:	85a6                	mv	a1,s1
    80003296:	855e                	mv	a0,s7
    80003298:	00000097          	auipc	ra,0x0
    8000329c:	ce6080e7          	jalr	-794(ra) # 80002f7e <bread>
    800032a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032a2:	40000613          	li	a2,1024
    800032a6:	4581                	li	a1,0
    800032a8:	05850513          	addi	a0,a0,88
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	a22080e7          	jalr	-1502(ra) # 80000cce <memset>
  log_write(bp);
    800032b4:	854a                	mv	a0,s2
    800032b6:	00001097          	auipc	ra,0x1
    800032ba:	050080e7          	jalr	80(ra) # 80004306 <log_write>
  brelse(bp);
    800032be:	854a                	mv	a0,s2
    800032c0:	00000097          	auipc	ra,0x0
    800032c4:	dee080e7          	jalr	-530(ra) # 800030ae <brelse>
}
    800032c8:	8526                	mv	a0,s1
    800032ca:	60e6                	ld	ra,88(sp)
    800032cc:	6446                	ld	s0,80(sp)
    800032ce:	64a6                	ld	s1,72(sp)
    800032d0:	6906                	ld	s2,64(sp)
    800032d2:	79e2                	ld	s3,56(sp)
    800032d4:	7a42                	ld	s4,48(sp)
    800032d6:	7aa2                	ld	s5,40(sp)
    800032d8:	7b02                	ld	s6,32(sp)
    800032da:	6be2                	ld	s7,24(sp)
    800032dc:	6c42                	ld	s8,16(sp)
    800032de:	6ca2                	ld	s9,8(sp)
    800032e0:	6125                	addi	sp,sp,96
    800032e2:	8082                	ret
    brelse(bp);
    800032e4:	854a                	mv	a0,s2
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	dc8080e7          	jalr	-568(ra) # 800030ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032ee:	015c87bb          	addw	a5,s9,s5
    800032f2:	00078a9b          	sext.w	s5,a5
    800032f6:	004b2703          	lw	a4,4(s6)
    800032fa:	06eaf163          	bgeu	s5,a4,8000335c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032fe:	41fad79b          	sraiw	a5,s5,0x1f
    80003302:	0137d79b          	srliw	a5,a5,0x13
    80003306:	015787bb          	addw	a5,a5,s5
    8000330a:	40d7d79b          	sraiw	a5,a5,0xd
    8000330e:	01cb2583          	lw	a1,28(s6)
    80003312:	9dbd                	addw	a1,a1,a5
    80003314:	855e                	mv	a0,s7
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	c68080e7          	jalr	-920(ra) # 80002f7e <bread>
    8000331e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003320:	004b2503          	lw	a0,4(s6)
    80003324:	000a849b          	sext.w	s1,s5
    80003328:	8762                	mv	a4,s8
    8000332a:	faa4fde3          	bgeu	s1,a0,800032e4 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000332e:	00777693          	andi	a3,a4,7
    80003332:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003336:	41f7579b          	sraiw	a5,a4,0x1f
    8000333a:	01d7d79b          	srliw	a5,a5,0x1d
    8000333e:	9fb9                	addw	a5,a5,a4
    80003340:	4037d79b          	sraiw	a5,a5,0x3
    80003344:	00f90633          	add	a2,s2,a5
    80003348:	05864603          	lbu	a2,88(a2)
    8000334c:	00c6f5b3          	and	a1,a3,a2
    80003350:	d585                	beqz	a1,80003278 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003352:	2705                	addiw	a4,a4,1
    80003354:	2485                	addiw	s1,s1,1
    80003356:	fd471ae3          	bne	a4,s4,8000332a <balloc+0xec>
    8000335a:	b769                	j	800032e4 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000335c:	00005517          	auipc	a0,0x5
    80003360:	22450513          	addi	a0,a0,548 # 80008580 <syscalls+0x130>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	222080e7          	jalr	546(ra) # 80000586 <printf>
  return 0;
    8000336c:	4481                	li	s1,0
    8000336e:	bfa9                	j	800032c8 <balloc+0x8a>

0000000080003370 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003370:	7179                	addi	sp,sp,-48
    80003372:	f406                	sd	ra,40(sp)
    80003374:	f022                	sd	s0,32(sp)
    80003376:	ec26                	sd	s1,24(sp)
    80003378:	e84a                	sd	s2,16(sp)
    8000337a:	e44e                	sd	s3,8(sp)
    8000337c:	e052                	sd	s4,0(sp)
    8000337e:	1800                	addi	s0,sp,48
    80003380:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003382:	47ad                	li	a5,11
    80003384:	02b7e863          	bltu	a5,a1,800033b4 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003388:	02059793          	slli	a5,a1,0x20
    8000338c:	01e7d593          	srli	a1,a5,0x1e
    80003390:	00b504b3          	add	s1,a0,a1
    80003394:	0504a903          	lw	s2,80(s1)
    80003398:	06091e63          	bnez	s2,80003414 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000339c:	4108                	lw	a0,0(a0)
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	ea0080e7          	jalr	-352(ra) # 8000323e <balloc>
    800033a6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033aa:	06090563          	beqz	s2,80003414 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800033ae:	0524a823          	sw	s2,80(s1)
    800033b2:	a08d                	j	80003414 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033b4:	ff45849b          	addiw	s1,a1,-12
    800033b8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033bc:	0ff00793          	li	a5,255
    800033c0:	08e7e563          	bltu	a5,a4,8000344a <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033c4:	08052903          	lw	s2,128(a0)
    800033c8:	00091d63          	bnez	s2,800033e2 <bmap+0x72>
      addr = balloc(ip->dev);
    800033cc:	4108                	lw	a0,0(a0)
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	e70080e7          	jalr	-400(ra) # 8000323e <balloc>
    800033d6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033da:	02090d63          	beqz	s2,80003414 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033de:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033e2:	85ca                	mv	a1,s2
    800033e4:	0009a503          	lw	a0,0(s3)
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	b96080e7          	jalr	-1130(ra) # 80002f7e <bread>
    800033f0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033f2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033f6:	02049713          	slli	a4,s1,0x20
    800033fa:	01e75593          	srli	a1,a4,0x1e
    800033fe:	00b784b3          	add	s1,a5,a1
    80003402:	0004a903          	lw	s2,0(s1)
    80003406:	02090063          	beqz	s2,80003426 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000340a:	8552                	mv	a0,s4
    8000340c:	00000097          	auipc	ra,0x0
    80003410:	ca2080e7          	jalr	-862(ra) # 800030ae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003414:	854a                	mv	a0,s2
    80003416:	70a2                	ld	ra,40(sp)
    80003418:	7402                	ld	s0,32(sp)
    8000341a:	64e2                	ld	s1,24(sp)
    8000341c:	6942                	ld	s2,16(sp)
    8000341e:	69a2                	ld	s3,8(sp)
    80003420:	6a02                	ld	s4,0(sp)
    80003422:	6145                	addi	sp,sp,48
    80003424:	8082                	ret
      addr = balloc(ip->dev);
    80003426:	0009a503          	lw	a0,0(s3)
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	e14080e7          	jalr	-492(ra) # 8000323e <balloc>
    80003432:	0005091b          	sext.w	s2,a0
      if(addr){
    80003436:	fc090ae3          	beqz	s2,8000340a <bmap+0x9a>
        a[bn] = addr;
    8000343a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000343e:	8552                	mv	a0,s4
    80003440:	00001097          	auipc	ra,0x1
    80003444:	ec6080e7          	jalr	-314(ra) # 80004306 <log_write>
    80003448:	b7c9                	j	8000340a <bmap+0x9a>
  panic("bmap: out of range");
    8000344a:	00005517          	auipc	a0,0x5
    8000344e:	14e50513          	addi	a0,a0,334 # 80008598 <syscalls+0x148>
    80003452:	ffffd097          	auipc	ra,0xffffd
    80003456:	0ea080e7          	jalr	234(ra) # 8000053c <panic>

000000008000345a <iget>:
{
    8000345a:	7179                	addi	sp,sp,-48
    8000345c:	f406                	sd	ra,40(sp)
    8000345e:	f022                	sd	s0,32(sp)
    80003460:	ec26                	sd	s1,24(sp)
    80003462:	e84a                	sd	s2,16(sp)
    80003464:	e44e                	sd	s3,8(sp)
    80003466:	e052                	sd	s4,0(sp)
    80003468:	1800                	addi	s0,sp,48
    8000346a:	89aa                	mv	s3,a0
    8000346c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000346e:	0001c517          	auipc	a0,0x1c
    80003472:	c4a50513          	addi	a0,a0,-950 # 8001f0b8 <itable>
    80003476:	ffffd097          	auipc	ra,0xffffd
    8000347a:	75c080e7          	jalr	1884(ra) # 80000bd2 <acquire>
  empty = 0;
    8000347e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003480:	0001c497          	auipc	s1,0x1c
    80003484:	c5048493          	addi	s1,s1,-944 # 8001f0d0 <itable+0x18>
    80003488:	0001d697          	auipc	a3,0x1d
    8000348c:	6d868693          	addi	a3,a3,1752 # 80020b60 <log>
    80003490:	a039                	j	8000349e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003492:	02090b63          	beqz	s2,800034c8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003496:	08848493          	addi	s1,s1,136
    8000349a:	02d48a63          	beq	s1,a3,800034ce <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000349e:	449c                	lw	a5,8(s1)
    800034a0:	fef059e3          	blez	a5,80003492 <iget+0x38>
    800034a4:	4098                	lw	a4,0(s1)
    800034a6:	ff3716e3          	bne	a4,s3,80003492 <iget+0x38>
    800034aa:	40d8                	lw	a4,4(s1)
    800034ac:	ff4713e3          	bne	a4,s4,80003492 <iget+0x38>
      ip->ref++;
    800034b0:	2785                	addiw	a5,a5,1
    800034b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034b4:	0001c517          	auipc	a0,0x1c
    800034b8:	c0450513          	addi	a0,a0,-1020 # 8001f0b8 <itable>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	7ca080e7          	jalr	1994(ra) # 80000c86 <release>
      return ip;
    800034c4:	8926                	mv	s2,s1
    800034c6:	a03d                	j	800034f4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034c8:	f7f9                	bnez	a5,80003496 <iget+0x3c>
    800034ca:	8926                	mv	s2,s1
    800034cc:	b7e9                	j	80003496 <iget+0x3c>
  if(empty == 0)
    800034ce:	02090c63          	beqz	s2,80003506 <iget+0xac>
  ip->dev = dev;
    800034d2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034d6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034da:	4785                	li	a5,1
    800034dc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034e0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034e4:	0001c517          	auipc	a0,0x1c
    800034e8:	bd450513          	addi	a0,a0,-1068 # 8001f0b8 <itable>
    800034ec:	ffffd097          	auipc	ra,0xffffd
    800034f0:	79a080e7          	jalr	1946(ra) # 80000c86 <release>
}
    800034f4:	854a                	mv	a0,s2
    800034f6:	70a2                	ld	ra,40(sp)
    800034f8:	7402                	ld	s0,32(sp)
    800034fa:	64e2                	ld	s1,24(sp)
    800034fc:	6942                	ld	s2,16(sp)
    800034fe:	69a2                	ld	s3,8(sp)
    80003500:	6a02                	ld	s4,0(sp)
    80003502:	6145                	addi	sp,sp,48
    80003504:	8082                	ret
    panic("iget: no inodes");
    80003506:	00005517          	auipc	a0,0x5
    8000350a:	0aa50513          	addi	a0,a0,170 # 800085b0 <syscalls+0x160>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	02e080e7          	jalr	46(ra) # 8000053c <panic>

0000000080003516 <fsinit>:
fsinit(int dev) {
    80003516:	7179                	addi	sp,sp,-48
    80003518:	f406                	sd	ra,40(sp)
    8000351a:	f022                	sd	s0,32(sp)
    8000351c:	ec26                	sd	s1,24(sp)
    8000351e:	e84a                	sd	s2,16(sp)
    80003520:	e44e                	sd	s3,8(sp)
    80003522:	1800                	addi	s0,sp,48
    80003524:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003526:	4585                	li	a1,1
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	a56080e7          	jalr	-1450(ra) # 80002f7e <bread>
    80003530:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003532:	0001c997          	auipc	s3,0x1c
    80003536:	b6698993          	addi	s3,s3,-1178 # 8001f098 <sb>
    8000353a:	02000613          	li	a2,32
    8000353e:	05850593          	addi	a1,a0,88
    80003542:	854e                	mv	a0,s3
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	7e6080e7          	jalr	2022(ra) # 80000d2a <memmove>
  brelse(bp);
    8000354c:	8526                	mv	a0,s1
    8000354e:	00000097          	auipc	ra,0x0
    80003552:	b60080e7          	jalr	-1184(ra) # 800030ae <brelse>
  if(sb.magic != FSMAGIC)
    80003556:	0009a703          	lw	a4,0(s3)
    8000355a:	102037b7          	lui	a5,0x10203
    8000355e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003562:	02f71263          	bne	a4,a5,80003586 <fsinit+0x70>
  initlog(dev, &sb);
    80003566:	0001c597          	auipc	a1,0x1c
    8000356a:	b3258593          	addi	a1,a1,-1230 # 8001f098 <sb>
    8000356e:	854a                	mv	a0,s2
    80003570:	00001097          	auipc	ra,0x1
    80003574:	b2c080e7          	jalr	-1236(ra) # 8000409c <initlog>
}
    80003578:	70a2                	ld	ra,40(sp)
    8000357a:	7402                	ld	s0,32(sp)
    8000357c:	64e2                	ld	s1,24(sp)
    8000357e:	6942                	ld	s2,16(sp)
    80003580:	69a2                	ld	s3,8(sp)
    80003582:	6145                	addi	sp,sp,48
    80003584:	8082                	ret
    panic("invalid file system");
    80003586:	00005517          	auipc	a0,0x5
    8000358a:	03a50513          	addi	a0,a0,58 # 800085c0 <syscalls+0x170>
    8000358e:	ffffd097          	auipc	ra,0xffffd
    80003592:	fae080e7          	jalr	-82(ra) # 8000053c <panic>

0000000080003596 <iinit>:
{
    80003596:	7179                	addi	sp,sp,-48
    80003598:	f406                	sd	ra,40(sp)
    8000359a:	f022                	sd	s0,32(sp)
    8000359c:	ec26                	sd	s1,24(sp)
    8000359e:	e84a                	sd	s2,16(sp)
    800035a0:	e44e                	sd	s3,8(sp)
    800035a2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035a4:	00005597          	auipc	a1,0x5
    800035a8:	03458593          	addi	a1,a1,52 # 800085d8 <syscalls+0x188>
    800035ac:	0001c517          	auipc	a0,0x1c
    800035b0:	b0c50513          	addi	a0,a0,-1268 # 8001f0b8 <itable>
    800035b4:	ffffd097          	auipc	ra,0xffffd
    800035b8:	58e080e7          	jalr	1422(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035bc:	0001c497          	auipc	s1,0x1c
    800035c0:	b2448493          	addi	s1,s1,-1244 # 8001f0e0 <itable+0x28>
    800035c4:	0001d997          	auipc	s3,0x1d
    800035c8:	5ac98993          	addi	s3,s3,1452 # 80020b70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035cc:	00005917          	auipc	s2,0x5
    800035d0:	01490913          	addi	s2,s2,20 # 800085e0 <syscalls+0x190>
    800035d4:	85ca                	mv	a1,s2
    800035d6:	8526                	mv	a0,s1
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	e12080e7          	jalr	-494(ra) # 800043ea <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035e0:	08848493          	addi	s1,s1,136
    800035e4:	ff3498e3          	bne	s1,s3,800035d4 <iinit+0x3e>
}
    800035e8:	70a2                	ld	ra,40(sp)
    800035ea:	7402                	ld	s0,32(sp)
    800035ec:	64e2                	ld	s1,24(sp)
    800035ee:	6942                	ld	s2,16(sp)
    800035f0:	69a2                	ld	s3,8(sp)
    800035f2:	6145                	addi	sp,sp,48
    800035f4:	8082                	ret

00000000800035f6 <ialloc>:
{
    800035f6:	7139                	addi	sp,sp,-64
    800035f8:	fc06                	sd	ra,56(sp)
    800035fa:	f822                	sd	s0,48(sp)
    800035fc:	f426                	sd	s1,40(sp)
    800035fe:	f04a                	sd	s2,32(sp)
    80003600:	ec4e                	sd	s3,24(sp)
    80003602:	e852                	sd	s4,16(sp)
    80003604:	e456                	sd	s5,8(sp)
    80003606:	e05a                	sd	s6,0(sp)
    80003608:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000360a:	0001c717          	auipc	a4,0x1c
    8000360e:	a9a72703          	lw	a4,-1382(a4) # 8001f0a4 <sb+0xc>
    80003612:	4785                	li	a5,1
    80003614:	04e7f863          	bgeu	a5,a4,80003664 <ialloc+0x6e>
    80003618:	8aaa                	mv	s5,a0
    8000361a:	8b2e                	mv	s6,a1
    8000361c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000361e:	0001ca17          	auipc	s4,0x1c
    80003622:	a7aa0a13          	addi	s4,s4,-1414 # 8001f098 <sb>
    80003626:	00495593          	srli	a1,s2,0x4
    8000362a:	018a2783          	lw	a5,24(s4)
    8000362e:	9dbd                	addw	a1,a1,a5
    80003630:	8556                	mv	a0,s5
    80003632:	00000097          	auipc	ra,0x0
    80003636:	94c080e7          	jalr	-1716(ra) # 80002f7e <bread>
    8000363a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000363c:	05850993          	addi	s3,a0,88
    80003640:	00f97793          	andi	a5,s2,15
    80003644:	079a                	slli	a5,a5,0x6
    80003646:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003648:	00099783          	lh	a5,0(s3)
    8000364c:	cf9d                	beqz	a5,8000368a <ialloc+0x94>
    brelse(bp);
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	a60080e7          	jalr	-1440(ra) # 800030ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003656:	0905                	addi	s2,s2,1
    80003658:	00ca2703          	lw	a4,12(s4)
    8000365c:	0009079b          	sext.w	a5,s2
    80003660:	fce7e3e3          	bltu	a5,a4,80003626 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	f8450513          	addi	a0,a0,-124 # 800085e8 <syscalls+0x198>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	f1a080e7          	jalr	-230(ra) # 80000586 <printf>
  return 0;
    80003674:	4501                	li	a0,0
}
    80003676:	70e2                	ld	ra,56(sp)
    80003678:	7442                	ld	s0,48(sp)
    8000367a:	74a2                	ld	s1,40(sp)
    8000367c:	7902                	ld	s2,32(sp)
    8000367e:	69e2                	ld	s3,24(sp)
    80003680:	6a42                	ld	s4,16(sp)
    80003682:	6aa2                	ld	s5,8(sp)
    80003684:	6b02                	ld	s6,0(sp)
    80003686:	6121                	addi	sp,sp,64
    80003688:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000368a:	04000613          	li	a2,64
    8000368e:	4581                	li	a1,0
    80003690:	854e                	mv	a0,s3
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	63c080e7          	jalr	1596(ra) # 80000cce <memset>
      dip->type = type;
    8000369a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000369e:	8526                	mv	a0,s1
    800036a0:	00001097          	auipc	ra,0x1
    800036a4:	c66080e7          	jalr	-922(ra) # 80004306 <log_write>
      brelse(bp);
    800036a8:	8526                	mv	a0,s1
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	a04080e7          	jalr	-1532(ra) # 800030ae <brelse>
      return iget(dev, inum);
    800036b2:	0009059b          	sext.w	a1,s2
    800036b6:	8556                	mv	a0,s5
    800036b8:	00000097          	auipc	ra,0x0
    800036bc:	da2080e7          	jalr	-606(ra) # 8000345a <iget>
    800036c0:	bf5d                	j	80003676 <ialloc+0x80>

00000000800036c2 <iupdate>:
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	e04a                	sd	s2,0(sp)
    800036cc:	1000                	addi	s0,sp,32
    800036ce:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036d0:	415c                	lw	a5,4(a0)
    800036d2:	0047d79b          	srliw	a5,a5,0x4
    800036d6:	0001c597          	auipc	a1,0x1c
    800036da:	9da5a583          	lw	a1,-1574(a1) # 8001f0b0 <sb+0x18>
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	4108                	lw	a0,0(a0)
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	89c080e7          	jalr	-1892(ra) # 80002f7e <bread>
    800036ea:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ec:	05850793          	addi	a5,a0,88
    800036f0:	40d8                	lw	a4,4(s1)
    800036f2:	8b3d                	andi	a4,a4,15
    800036f4:	071a                	slli	a4,a4,0x6
    800036f6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036f8:	04449703          	lh	a4,68(s1)
    800036fc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003700:	04649703          	lh	a4,70(s1)
    80003704:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003708:	04849703          	lh	a4,72(s1)
    8000370c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003710:	04a49703          	lh	a4,74(s1)
    80003714:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003718:	44f8                	lw	a4,76(s1)
    8000371a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000371c:	03400613          	li	a2,52
    80003720:	05048593          	addi	a1,s1,80
    80003724:	00c78513          	addi	a0,a5,12
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>
  log_write(bp);
    80003730:	854a                	mv	a0,s2
    80003732:	00001097          	auipc	ra,0x1
    80003736:	bd4080e7          	jalr	-1068(ra) # 80004306 <log_write>
  brelse(bp);
    8000373a:	854a                	mv	a0,s2
    8000373c:	00000097          	auipc	ra,0x0
    80003740:	972080e7          	jalr	-1678(ra) # 800030ae <brelse>
}
    80003744:	60e2                	ld	ra,24(sp)
    80003746:	6442                	ld	s0,16(sp)
    80003748:	64a2                	ld	s1,8(sp)
    8000374a:	6902                	ld	s2,0(sp)
    8000374c:	6105                	addi	sp,sp,32
    8000374e:	8082                	ret

0000000080003750 <idup>:
{
    80003750:	1101                	addi	sp,sp,-32
    80003752:	ec06                	sd	ra,24(sp)
    80003754:	e822                	sd	s0,16(sp)
    80003756:	e426                	sd	s1,8(sp)
    80003758:	1000                	addi	s0,sp,32
    8000375a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000375c:	0001c517          	auipc	a0,0x1c
    80003760:	95c50513          	addi	a0,a0,-1700 # 8001f0b8 <itable>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	46e080e7          	jalr	1134(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000376c:	449c                	lw	a5,8(s1)
    8000376e:	2785                	addiw	a5,a5,1
    80003770:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003772:	0001c517          	auipc	a0,0x1c
    80003776:	94650513          	addi	a0,a0,-1722 # 8001f0b8 <itable>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	50c080e7          	jalr	1292(ra) # 80000c86 <release>
}
    80003782:	8526                	mv	a0,s1
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret

000000008000378e <ilock>:
{
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	e04a                	sd	s2,0(sp)
    80003798:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000379a:	c115                	beqz	a0,800037be <ilock+0x30>
    8000379c:	84aa                	mv	s1,a0
    8000379e:	451c                	lw	a5,8(a0)
    800037a0:	00f05f63          	blez	a5,800037be <ilock+0x30>
  acquiresleep(&ip->lock);
    800037a4:	0541                	addi	a0,a0,16
    800037a6:	00001097          	auipc	ra,0x1
    800037aa:	c7e080e7          	jalr	-898(ra) # 80004424 <acquiresleep>
  if(ip->valid == 0){
    800037ae:	40bc                	lw	a5,64(s1)
    800037b0:	cf99                	beqz	a5,800037ce <ilock+0x40>
}
    800037b2:	60e2                	ld	ra,24(sp)
    800037b4:	6442                	ld	s0,16(sp)
    800037b6:	64a2                	ld	s1,8(sp)
    800037b8:	6902                	ld	s2,0(sp)
    800037ba:	6105                	addi	sp,sp,32
    800037bc:	8082                	ret
    panic("ilock");
    800037be:	00005517          	auipc	a0,0x5
    800037c2:	e4250513          	addi	a0,a0,-446 # 80008600 <syscalls+0x1b0>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	d76080e7          	jalr	-650(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037ce:	40dc                	lw	a5,4(s1)
    800037d0:	0047d79b          	srliw	a5,a5,0x4
    800037d4:	0001c597          	auipc	a1,0x1c
    800037d8:	8dc5a583          	lw	a1,-1828(a1) # 8001f0b0 <sb+0x18>
    800037dc:	9dbd                	addw	a1,a1,a5
    800037de:	4088                	lw	a0,0(s1)
    800037e0:	fffff097          	auipc	ra,0xfffff
    800037e4:	79e080e7          	jalr	1950(ra) # 80002f7e <bread>
    800037e8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ea:	05850593          	addi	a1,a0,88
    800037ee:	40dc                	lw	a5,4(s1)
    800037f0:	8bbd                	andi	a5,a5,15
    800037f2:	079a                	slli	a5,a5,0x6
    800037f4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037f6:	00059783          	lh	a5,0(a1)
    800037fa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037fe:	00259783          	lh	a5,2(a1)
    80003802:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003806:	00459783          	lh	a5,4(a1)
    8000380a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000380e:	00659783          	lh	a5,6(a1)
    80003812:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003816:	459c                	lw	a5,8(a1)
    80003818:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000381a:	03400613          	li	a2,52
    8000381e:	05b1                	addi	a1,a1,12
    80003820:	05048513          	addi	a0,s1,80
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	506080e7          	jalr	1286(ra) # 80000d2a <memmove>
    brelse(bp);
    8000382c:	854a                	mv	a0,s2
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	880080e7          	jalr	-1920(ra) # 800030ae <brelse>
    ip->valid = 1;
    80003836:	4785                	li	a5,1
    80003838:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000383a:	04449783          	lh	a5,68(s1)
    8000383e:	fbb5                	bnez	a5,800037b2 <ilock+0x24>
      panic("ilock: no type");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	dc850513          	addi	a0,a0,-568 # 80008608 <syscalls+0x1b8>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	cf4080e7          	jalr	-780(ra) # 8000053c <panic>

0000000080003850 <iunlock>:
{
    80003850:	1101                	addi	sp,sp,-32
    80003852:	ec06                	sd	ra,24(sp)
    80003854:	e822                	sd	s0,16(sp)
    80003856:	e426                	sd	s1,8(sp)
    80003858:	e04a                	sd	s2,0(sp)
    8000385a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000385c:	c905                	beqz	a0,8000388c <iunlock+0x3c>
    8000385e:	84aa                	mv	s1,a0
    80003860:	01050913          	addi	s2,a0,16
    80003864:	854a                	mv	a0,s2
    80003866:	00001097          	auipc	ra,0x1
    8000386a:	c58080e7          	jalr	-936(ra) # 800044be <holdingsleep>
    8000386e:	cd19                	beqz	a0,8000388c <iunlock+0x3c>
    80003870:	449c                	lw	a5,8(s1)
    80003872:	00f05d63          	blez	a5,8000388c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003876:	854a                	mv	a0,s2
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	c02080e7          	jalr	-1022(ra) # 8000447a <releasesleep>
}
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	64a2                	ld	s1,8(sp)
    80003886:	6902                	ld	s2,0(sp)
    80003888:	6105                	addi	sp,sp,32
    8000388a:	8082                	ret
    panic("iunlock");
    8000388c:	00005517          	auipc	a0,0x5
    80003890:	d8c50513          	addi	a0,a0,-628 # 80008618 <syscalls+0x1c8>
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	ca8080e7          	jalr	-856(ra) # 8000053c <panic>

000000008000389c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000389c:	7179                	addi	sp,sp,-48
    8000389e:	f406                	sd	ra,40(sp)
    800038a0:	f022                	sd	s0,32(sp)
    800038a2:	ec26                	sd	s1,24(sp)
    800038a4:	e84a                	sd	s2,16(sp)
    800038a6:	e44e                	sd	s3,8(sp)
    800038a8:	e052                	sd	s4,0(sp)
    800038aa:	1800                	addi	s0,sp,48
    800038ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038ae:	05050493          	addi	s1,a0,80
    800038b2:	08050913          	addi	s2,a0,128
    800038b6:	a021                	j	800038be <itrunc+0x22>
    800038b8:	0491                	addi	s1,s1,4
    800038ba:	01248d63          	beq	s1,s2,800038d4 <itrunc+0x38>
    if(ip->addrs[i]){
    800038be:	408c                	lw	a1,0(s1)
    800038c0:	dde5                	beqz	a1,800038b8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038c2:	0009a503          	lw	a0,0(s3)
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	8fc080e7          	jalr	-1796(ra) # 800031c2 <bfree>
      ip->addrs[i] = 0;
    800038ce:	0004a023          	sw	zero,0(s1)
    800038d2:	b7dd                	j	800038b8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038d4:	0809a583          	lw	a1,128(s3)
    800038d8:	e185                	bnez	a1,800038f8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038da:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038de:	854e                	mv	a0,s3
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	de2080e7          	jalr	-542(ra) # 800036c2 <iupdate>
}
    800038e8:	70a2                	ld	ra,40(sp)
    800038ea:	7402                	ld	s0,32(sp)
    800038ec:	64e2                	ld	s1,24(sp)
    800038ee:	6942                	ld	s2,16(sp)
    800038f0:	69a2                	ld	s3,8(sp)
    800038f2:	6a02                	ld	s4,0(sp)
    800038f4:	6145                	addi	sp,sp,48
    800038f6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038f8:	0009a503          	lw	a0,0(s3)
    800038fc:	fffff097          	auipc	ra,0xfffff
    80003900:	682080e7          	jalr	1666(ra) # 80002f7e <bread>
    80003904:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003906:	05850493          	addi	s1,a0,88
    8000390a:	45850913          	addi	s2,a0,1112
    8000390e:	a021                	j	80003916 <itrunc+0x7a>
    80003910:	0491                	addi	s1,s1,4
    80003912:	01248b63          	beq	s1,s2,80003928 <itrunc+0x8c>
      if(a[j])
    80003916:	408c                	lw	a1,0(s1)
    80003918:	dde5                	beqz	a1,80003910 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000391a:	0009a503          	lw	a0,0(s3)
    8000391e:	00000097          	auipc	ra,0x0
    80003922:	8a4080e7          	jalr	-1884(ra) # 800031c2 <bfree>
    80003926:	b7ed                	j	80003910 <itrunc+0x74>
    brelse(bp);
    80003928:	8552                	mv	a0,s4
    8000392a:	fffff097          	auipc	ra,0xfffff
    8000392e:	784080e7          	jalr	1924(ra) # 800030ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003932:	0809a583          	lw	a1,128(s3)
    80003936:	0009a503          	lw	a0,0(s3)
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	888080e7          	jalr	-1912(ra) # 800031c2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003942:	0809a023          	sw	zero,128(s3)
    80003946:	bf51                	j	800038da <itrunc+0x3e>

0000000080003948 <iput>:
{
    80003948:	1101                	addi	sp,sp,-32
    8000394a:	ec06                	sd	ra,24(sp)
    8000394c:	e822                	sd	s0,16(sp)
    8000394e:	e426                	sd	s1,8(sp)
    80003950:	e04a                	sd	s2,0(sp)
    80003952:	1000                	addi	s0,sp,32
    80003954:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003956:	0001b517          	auipc	a0,0x1b
    8000395a:	76250513          	addi	a0,a0,1890 # 8001f0b8 <itable>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	274080e7          	jalr	628(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003966:	4498                	lw	a4,8(s1)
    80003968:	4785                	li	a5,1
    8000396a:	02f70363          	beq	a4,a5,80003990 <iput+0x48>
  ip->ref--;
    8000396e:	449c                	lw	a5,8(s1)
    80003970:	37fd                	addiw	a5,a5,-1
    80003972:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003974:	0001b517          	auipc	a0,0x1b
    80003978:	74450513          	addi	a0,a0,1860 # 8001f0b8 <itable>
    8000397c:	ffffd097          	auipc	ra,0xffffd
    80003980:	30a080e7          	jalr	778(ra) # 80000c86 <release>
}
    80003984:	60e2                	ld	ra,24(sp)
    80003986:	6442                	ld	s0,16(sp)
    80003988:	64a2                	ld	s1,8(sp)
    8000398a:	6902                	ld	s2,0(sp)
    8000398c:	6105                	addi	sp,sp,32
    8000398e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003990:	40bc                	lw	a5,64(s1)
    80003992:	dff1                	beqz	a5,8000396e <iput+0x26>
    80003994:	04a49783          	lh	a5,74(s1)
    80003998:	fbf9                	bnez	a5,8000396e <iput+0x26>
    acquiresleep(&ip->lock);
    8000399a:	01048913          	addi	s2,s1,16
    8000399e:	854a                	mv	a0,s2
    800039a0:	00001097          	auipc	ra,0x1
    800039a4:	a84080e7          	jalr	-1404(ra) # 80004424 <acquiresleep>
    release(&itable.lock);
    800039a8:	0001b517          	auipc	a0,0x1b
    800039ac:	71050513          	addi	a0,a0,1808 # 8001f0b8 <itable>
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	2d6080e7          	jalr	726(ra) # 80000c86 <release>
    itrunc(ip);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	ee2080e7          	jalr	-286(ra) # 8000389c <itrunc>
    ip->type = 0;
    800039c2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039c6:	8526                	mv	a0,s1
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	cfa080e7          	jalr	-774(ra) # 800036c2 <iupdate>
    ip->valid = 0;
    800039d0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039d4:	854a                	mv	a0,s2
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	aa4080e7          	jalr	-1372(ra) # 8000447a <releasesleep>
    acquire(&itable.lock);
    800039de:	0001b517          	auipc	a0,0x1b
    800039e2:	6da50513          	addi	a0,a0,1754 # 8001f0b8 <itable>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	1ec080e7          	jalr	492(ra) # 80000bd2 <acquire>
    800039ee:	b741                	j	8000396e <iput+0x26>

00000000800039f0 <iunlockput>:
{
    800039f0:	1101                	addi	sp,sp,-32
    800039f2:	ec06                	sd	ra,24(sp)
    800039f4:	e822                	sd	s0,16(sp)
    800039f6:	e426                	sd	s1,8(sp)
    800039f8:	1000                	addi	s0,sp,32
    800039fa:	84aa                	mv	s1,a0
  iunlock(ip);
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	e54080e7          	jalr	-428(ra) # 80003850 <iunlock>
  iput(ip);
    80003a04:	8526                	mv	a0,s1
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	f42080e7          	jalr	-190(ra) # 80003948 <iput>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6105                	addi	sp,sp,32
    80003a16:	8082                	ret

0000000080003a18 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a18:	1141                	addi	sp,sp,-16
    80003a1a:	e422                	sd	s0,8(sp)
    80003a1c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a1e:	411c                	lw	a5,0(a0)
    80003a20:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a22:	415c                	lw	a5,4(a0)
    80003a24:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a26:	04451783          	lh	a5,68(a0)
    80003a2a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a2e:	04a51783          	lh	a5,74(a0)
    80003a32:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a36:	04c56783          	lwu	a5,76(a0)
    80003a3a:	e99c                	sd	a5,16(a1)
}
    80003a3c:	6422                	ld	s0,8(sp)
    80003a3e:	0141                	addi	sp,sp,16
    80003a40:	8082                	ret

0000000080003a42 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a42:	457c                	lw	a5,76(a0)
    80003a44:	0ed7e963          	bltu	a5,a3,80003b36 <readi+0xf4>
{
    80003a48:	7159                	addi	sp,sp,-112
    80003a4a:	f486                	sd	ra,104(sp)
    80003a4c:	f0a2                	sd	s0,96(sp)
    80003a4e:	eca6                	sd	s1,88(sp)
    80003a50:	e8ca                	sd	s2,80(sp)
    80003a52:	e4ce                	sd	s3,72(sp)
    80003a54:	e0d2                	sd	s4,64(sp)
    80003a56:	fc56                	sd	s5,56(sp)
    80003a58:	f85a                	sd	s6,48(sp)
    80003a5a:	f45e                	sd	s7,40(sp)
    80003a5c:	f062                	sd	s8,32(sp)
    80003a5e:	ec66                	sd	s9,24(sp)
    80003a60:	e86a                	sd	s10,16(sp)
    80003a62:	e46e                	sd	s11,8(sp)
    80003a64:	1880                	addi	s0,sp,112
    80003a66:	8b2a                	mv	s6,a0
    80003a68:	8bae                	mv	s7,a1
    80003a6a:	8a32                	mv	s4,a2
    80003a6c:	84b6                	mv	s1,a3
    80003a6e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a70:	9f35                	addw	a4,a4,a3
    return 0;
    80003a72:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a74:	0ad76063          	bltu	a4,a3,80003b14 <readi+0xd2>
  if(off + n > ip->size)
    80003a78:	00e7f463          	bgeu	a5,a4,80003a80 <readi+0x3e>
    n = ip->size - off;
    80003a7c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a80:	0a0a8963          	beqz	s5,80003b32 <readi+0xf0>
    80003a84:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a86:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a8a:	5c7d                	li	s8,-1
    80003a8c:	a82d                	j	80003ac6 <readi+0x84>
    80003a8e:	020d1d93          	slli	s11,s10,0x20
    80003a92:	020ddd93          	srli	s11,s11,0x20
    80003a96:	05890613          	addi	a2,s2,88
    80003a9a:	86ee                	mv	a3,s11
    80003a9c:	963a                	add	a2,a2,a4
    80003a9e:	85d2                	mv	a1,s4
    80003aa0:	855e                	mv	a0,s7
    80003aa2:	fffff097          	auipc	ra,0xfffff
    80003aa6:	a34080e7          	jalr	-1484(ra) # 800024d6 <either_copyout>
    80003aaa:	05850d63          	beq	a0,s8,80003b04 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003aae:	854a                	mv	a0,s2
    80003ab0:	fffff097          	auipc	ra,0xfffff
    80003ab4:	5fe080e7          	jalr	1534(ra) # 800030ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ab8:	013d09bb          	addw	s3,s10,s3
    80003abc:	009d04bb          	addw	s1,s10,s1
    80003ac0:	9a6e                	add	s4,s4,s11
    80003ac2:	0559f763          	bgeu	s3,s5,80003b10 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ac6:	00a4d59b          	srliw	a1,s1,0xa
    80003aca:	855a                	mv	a0,s6
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	8a4080e7          	jalr	-1884(ra) # 80003370 <bmap>
    80003ad4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ad8:	cd85                	beqz	a1,80003b10 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ada:	000b2503          	lw	a0,0(s6)
    80003ade:	fffff097          	auipc	ra,0xfffff
    80003ae2:	4a0080e7          	jalr	1184(ra) # 80002f7e <bread>
    80003ae6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae8:	3ff4f713          	andi	a4,s1,1023
    80003aec:	40ec87bb          	subw	a5,s9,a4
    80003af0:	413a86bb          	subw	a3,s5,s3
    80003af4:	8d3e                	mv	s10,a5
    80003af6:	2781                	sext.w	a5,a5
    80003af8:	0006861b          	sext.w	a2,a3
    80003afc:	f8f679e3          	bgeu	a2,a5,80003a8e <readi+0x4c>
    80003b00:	8d36                	mv	s10,a3
    80003b02:	b771                	j	80003a8e <readi+0x4c>
      brelse(bp);
    80003b04:	854a                	mv	a0,s2
    80003b06:	fffff097          	auipc	ra,0xfffff
    80003b0a:	5a8080e7          	jalr	1448(ra) # 800030ae <brelse>
      tot = -1;
    80003b0e:	59fd                	li	s3,-1
  }
  return tot;
    80003b10:	0009851b          	sext.w	a0,s3
}
    80003b14:	70a6                	ld	ra,104(sp)
    80003b16:	7406                	ld	s0,96(sp)
    80003b18:	64e6                	ld	s1,88(sp)
    80003b1a:	6946                	ld	s2,80(sp)
    80003b1c:	69a6                	ld	s3,72(sp)
    80003b1e:	6a06                	ld	s4,64(sp)
    80003b20:	7ae2                	ld	s5,56(sp)
    80003b22:	7b42                	ld	s6,48(sp)
    80003b24:	7ba2                	ld	s7,40(sp)
    80003b26:	7c02                	ld	s8,32(sp)
    80003b28:	6ce2                	ld	s9,24(sp)
    80003b2a:	6d42                	ld	s10,16(sp)
    80003b2c:	6da2                	ld	s11,8(sp)
    80003b2e:	6165                	addi	sp,sp,112
    80003b30:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b32:	89d6                	mv	s3,s5
    80003b34:	bff1                	j	80003b10 <readi+0xce>
    return 0;
    80003b36:	4501                	li	a0,0
}
    80003b38:	8082                	ret

0000000080003b3a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b3a:	457c                	lw	a5,76(a0)
    80003b3c:	10d7e863          	bltu	a5,a3,80003c4c <writei+0x112>
{
    80003b40:	7159                	addi	sp,sp,-112
    80003b42:	f486                	sd	ra,104(sp)
    80003b44:	f0a2                	sd	s0,96(sp)
    80003b46:	eca6                	sd	s1,88(sp)
    80003b48:	e8ca                	sd	s2,80(sp)
    80003b4a:	e4ce                	sd	s3,72(sp)
    80003b4c:	e0d2                	sd	s4,64(sp)
    80003b4e:	fc56                	sd	s5,56(sp)
    80003b50:	f85a                	sd	s6,48(sp)
    80003b52:	f45e                	sd	s7,40(sp)
    80003b54:	f062                	sd	s8,32(sp)
    80003b56:	ec66                	sd	s9,24(sp)
    80003b58:	e86a                	sd	s10,16(sp)
    80003b5a:	e46e                	sd	s11,8(sp)
    80003b5c:	1880                	addi	s0,sp,112
    80003b5e:	8aaa                	mv	s5,a0
    80003b60:	8bae                	mv	s7,a1
    80003b62:	8a32                	mv	s4,a2
    80003b64:	8936                	mv	s2,a3
    80003b66:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b68:	00e687bb          	addw	a5,a3,a4
    80003b6c:	0ed7e263          	bltu	a5,a3,80003c50 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b70:	00043737          	lui	a4,0x43
    80003b74:	0ef76063          	bltu	a4,a5,80003c54 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b78:	0c0b0863          	beqz	s6,80003c48 <writei+0x10e>
    80003b7c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b82:	5c7d                	li	s8,-1
    80003b84:	a091                	j	80003bc8 <writei+0x8e>
    80003b86:	020d1d93          	slli	s11,s10,0x20
    80003b8a:	020ddd93          	srli	s11,s11,0x20
    80003b8e:	05848513          	addi	a0,s1,88
    80003b92:	86ee                	mv	a3,s11
    80003b94:	8652                	mv	a2,s4
    80003b96:	85de                	mv	a1,s7
    80003b98:	953a                	add	a0,a0,a4
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	992080e7          	jalr	-1646(ra) # 8000252c <either_copyin>
    80003ba2:	07850263          	beq	a0,s8,80003c06 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	75e080e7          	jalr	1886(ra) # 80004306 <log_write>
    brelse(bp);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	fffff097          	auipc	ra,0xfffff
    80003bb6:	4fc080e7          	jalr	1276(ra) # 800030ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bba:	013d09bb          	addw	s3,s10,s3
    80003bbe:	012d093b          	addw	s2,s10,s2
    80003bc2:	9a6e                	add	s4,s4,s11
    80003bc4:	0569f663          	bgeu	s3,s6,80003c10 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bc8:	00a9559b          	srliw	a1,s2,0xa
    80003bcc:	8556                	mv	a0,s5
    80003bce:	fffff097          	auipc	ra,0xfffff
    80003bd2:	7a2080e7          	jalr	1954(ra) # 80003370 <bmap>
    80003bd6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bda:	c99d                	beqz	a1,80003c10 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bdc:	000aa503          	lw	a0,0(s5)
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	39e080e7          	jalr	926(ra) # 80002f7e <bread>
    80003be8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bea:	3ff97713          	andi	a4,s2,1023
    80003bee:	40ec87bb          	subw	a5,s9,a4
    80003bf2:	413b06bb          	subw	a3,s6,s3
    80003bf6:	8d3e                	mv	s10,a5
    80003bf8:	2781                	sext.w	a5,a5
    80003bfa:	0006861b          	sext.w	a2,a3
    80003bfe:	f8f674e3          	bgeu	a2,a5,80003b86 <writei+0x4c>
    80003c02:	8d36                	mv	s10,a3
    80003c04:	b749                	j	80003b86 <writei+0x4c>
      brelse(bp);
    80003c06:	8526                	mv	a0,s1
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	4a6080e7          	jalr	1190(ra) # 800030ae <brelse>
  }

  if(off > ip->size)
    80003c10:	04caa783          	lw	a5,76(s5)
    80003c14:	0127f463          	bgeu	a5,s2,80003c1c <writei+0xe2>
    ip->size = off;
    80003c18:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c1c:	8556                	mv	a0,s5
    80003c1e:	00000097          	auipc	ra,0x0
    80003c22:	aa4080e7          	jalr	-1372(ra) # 800036c2 <iupdate>

  return tot;
    80003c26:	0009851b          	sext.w	a0,s3
}
    80003c2a:	70a6                	ld	ra,104(sp)
    80003c2c:	7406                	ld	s0,96(sp)
    80003c2e:	64e6                	ld	s1,88(sp)
    80003c30:	6946                	ld	s2,80(sp)
    80003c32:	69a6                	ld	s3,72(sp)
    80003c34:	6a06                	ld	s4,64(sp)
    80003c36:	7ae2                	ld	s5,56(sp)
    80003c38:	7b42                	ld	s6,48(sp)
    80003c3a:	7ba2                	ld	s7,40(sp)
    80003c3c:	7c02                	ld	s8,32(sp)
    80003c3e:	6ce2                	ld	s9,24(sp)
    80003c40:	6d42                	ld	s10,16(sp)
    80003c42:	6da2                	ld	s11,8(sp)
    80003c44:	6165                	addi	sp,sp,112
    80003c46:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c48:	89da                	mv	s3,s6
    80003c4a:	bfc9                	j	80003c1c <writei+0xe2>
    return -1;
    80003c4c:	557d                	li	a0,-1
}
    80003c4e:	8082                	ret
    return -1;
    80003c50:	557d                	li	a0,-1
    80003c52:	bfe1                	j	80003c2a <writei+0xf0>
    return -1;
    80003c54:	557d                	li	a0,-1
    80003c56:	bfd1                	j	80003c2a <writei+0xf0>

0000000080003c58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c58:	1141                	addi	sp,sp,-16
    80003c5a:	e406                	sd	ra,8(sp)
    80003c5c:	e022                	sd	s0,0(sp)
    80003c5e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c60:	4639                	li	a2,14
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	13c080e7          	jalr	316(ra) # 80000d9e <strncmp>
}
    80003c6a:	60a2                	ld	ra,8(sp)
    80003c6c:	6402                	ld	s0,0(sp)
    80003c6e:	0141                	addi	sp,sp,16
    80003c70:	8082                	ret

0000000080003c72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c72:	7139                	addi	sp,sp,-64
    80003c74:	fc06                	sd	ra,56(sp)
    80003c76:	f822                	sd	s0,48(sp)
    80003c78:	f426                	sd	s1,40(sp)
    80003c7a:	f04a                	sd	s2,32(sp)
    80003c7c:	ec4e                	sd	s3,24(sp)
    80003c7e:	e852                	sd	s4,16(sp)
    80003c80:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c82:	04451703          	lh	a4,68(a0)
    80003c86:	4785                	li	a5,1
    80003c88:	00f71a63          	bne	a4,a5,80003c9c <dirlookup+0x2a>
    80003c8c:	892a                	mv	s2,a0
    80003c8e:	89ae                	mv	s3,a1
    80003c90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c92:	457c                	lw	a5,76(a0)
    80003c94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c98:	e79d                	bnez	a5,80003cc6 <dirlookup+0x54>
    80003c9a:	a8a5                	j	80003d12 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	98450513          	addi	a0,a0,-1660 # 80008620 <syscalls+0x1d0>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	898080e7          	jalr	-1896(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003cac:	00005517          	auipc	a0,0x5
    80003cb0:	98c50513          	addi	a0,a0,-1652 # 80008638 <syscalls+0x1e8>
    80003cb4:	ffffd097          	auipc	ra,0xffffd
    80003cb8:	888080e7          	jalr	-1912(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cbc:	24c1                	addiw	s1,s1,16
    80003cbe:	04c92783          	lw	a5,76(s2)
    80003cc2:	04f4f763          	bgeu	s1,a5,80003d10 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cc6:	4741                	li	a4,16
    80003cc8:	86a6                	mv	a3,s1
    80003cca:	fc040613          	addi	a2,s0,-64
    80003cce:	4581                	li	a1,0
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	00000097          	auipc	ra,0x0
    80003cd6:	d70080e7          	jalr	-656(ra) # 80003a42 <readi>
    80003cda:	47c1                	li	a5,16
    80003cdc:	fcf518e3          	bne	a0,a5,80003cac <dirlookup+0x3a>
    if(de.inum == 0)
    80003ce0:	fc045783          	lhu	a5,-64(s0)
    80003ce4:	dfe1                	beqz	a5,80003cbc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ce6:	fc240593          	addi	a1,s0,-62
    80003cea:	854e                	mv	a0,s3
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	f6c080e7          	jalr	-148(ra) # 80003c58 <namecmp>
    80003cf4:	f561                	bnez	a0,80003cbc <dirlookup+0x4a>
      if(poff)
    80003cf6:	000a0463          	beqz	s4,80003cfe <dirlookup+0x8c>
        *poff = off;
    80003cfa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cfe:	fc045583          	lhu	a1,-64(s0)
    80003d02:	00092503          	lw	a0,0(s2)
    80003d06:	fffff097          	auipc	ra,0xfffff
    80003d0a:	754080e7          	jalr	1876(ra) # 8000345a <iget>
    80003d0e:	a011                	j	80003d12 <dirlookup+0xa0>
  return 0;
    80003d10:	4501                	li	a0,0
}
    80003d12:	70e2                	ld	ra,56(sp)
    80003d14:	7442                	ld	s0,48(sp)
    80003d16:	74a2                	ld	s1,40(sp)
    80003d18:	7902                	ld	s2,32(sp)
    80003d1a:	69e2                	ld	s3,24(sp)
    80003d1c:	6a42                	ld	s4,16(sp)
    80003d1e:	6121                	addi	sp,sp,64
    80003d20:	8082                	ret

0000000080003d22 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d22:	711d                	addi	sp,sp,-96
    80003d24:	ec86                	sd	ra,88(sp)
    80003d26:	e8a2                	sd	s0,80(sp)
    80003d28:	e4a6                	sd	s1,72(sp)
    80003d2a:	e0ca                	sd	s2,64(sp)
    80003d2c:	fc4e                	sd	s3,56(sp)
    80003d2e:	f852                	sd	s4,48(sp)
    80003d30:	f456                	sd	s5,40(sp)
    80003d32:	f05a                	sd	s6,32(sp)
    80003d34:	ec5e                	sd	s7,24(sp)
    80003d36:	e862                	sd	s8,16(sp)
    80003d38:	e466                	sd	s9,8(sp)
    80003d3a:	1080                	addi	s0,sp,96
    80003d3c:	84aa                	mv	s1,a0
    80003d3e:	8b2e                	mv	s6,a1
    80003d40:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d42:	00054703          	lbu	a4,0(a0)
    80003d46:	02f00793          	li	a5,47
    80003d4a:	02f70263          	beq	a4,a5,80003d6e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d4e:	ffffe097          	auipc	ra,0xffffe
    80003d52:	c58080e7          	jalr	-936(ra) # 800019a6 <myproc>
    80003d56:	15053503          	ld	a0,336(a0)
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	9f6080e7          	jalr	-1546(ra) # 80003750 <idup>
    80003d62:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d64:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d68:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d6a:	4b85                	li	s7,1
    80003d6c:	a875                	j	80003e28 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d6e:	4585                	li	a1,1
    80003d70:	4505                	li	a0,1
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	6e8080e7          	jalr	1768(ra) # 8000345a <iget>
    80003d7a:	8a2a                	mv	s4,a0
    80003d7c:	b7e5                	j	80003d64 <namex+0x42>
      iunlockput(ip);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	c70080e7          	jalr	-912(ra) # 800039f0 <iunlockput>
      return 0;
    80003d88:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d8a:	8552                	mv	a0,s4
    80003d8c:	60e6                	ld	ra,88(sp)
    80003d8e:	6446                	ld	s0,80(sp)
    80003d90:	64a6                	ld	s1,72(sp)
    80003d92:	6906                	ld	s2,64(sp)
    80003d94:	79e2                	ld	s3,56(sp)
    80003d96:	7a42                	ld	s4,48(sp)
    80003d98:	7aa2                	ld	s5,40(sp)
    80003d9a:	7b02                	ld	s6,32(sp)
    80003d9c:	6be2                	ld	s7,24(sp)
    80003d9e:	6c42                	ld	s8,16(sp)
    80003da0:	6ca2                	ld	s9,8(sp)
    80003da2:	6125                	addi	sp,sp,96
    80003da4:	8082                	ret
      iunlock(ip);
    80003da6:	8552                	mv	a0,s4
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	aa8080e7          	jalr	-1368(ra) # 80003850 <iunlock>
      return ip;
    80003db0:	bfe9                	j	80003d8a <namex+0x68>
      iunlockput(ip);
    80003db2:	8552                	mv	a0,s4
    80003db4:	00000097          	auipc	ra,0x0
    80003db8:	c3c080e7          	jalr	-964(ra) # 800039f0 <iunlockput>
      return 0;
    80003dbc:	8a4e                	mv	s4,s3
    80003dbe:	b7f1                	j	80003d8a <namex+0x68>
  len = path - s;
    80003dc0:	40998633          	sub	a2,s3,s1
    80003dc4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dc8:	099c5863          	bge	s8,s9,80003e58 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dcc:	4639                	li	a2,14
    80003dce:	85a6                	mv	a1,s1
    80003dd0:	8556                	mv	a0,s5
    80003dd2:	ffffd097          	auipc	ra,0xffffd
    80003dd6:	f58080e7          	jalr	-168(ra) # 80000d2a <memmove>
    80003dda:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ddc:	0004c783          	lbu	a5,0(s1)
    80003de0:	01279763          	bne	a5,s2,80003dee <namex+0xcc>
    path++;
    80003de4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003de6:	0004c783          	lbu	a5,0(s1)
    80003dea:	ff278de3          	beq	a5,s2,80003de4 <namex+0xc2>
    ilock(ip);
    80003dee:	8552                	mv	a0,s4
    80003df0:	00000097          	auipc	ra,0x0
    80003df4:	99e080e7          	jalr	-1634(ra) # 8000378e <ilock>
    if(ip->type != T_DIR){
    80003df8:	044a1783          	lh	a5,68(s4)
    80003dfc:	f97791e3          	bne	a5,s7,80003d7e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e00:	000b0563          	beqz	s6,80003e0a <namex+0xe8>
    80003e04:	0004c783          	lbu	a5,0(s1)
    80003e08:	dfd9                	beqz	a5,80003da6 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e0a:	4601                	li	a2,0
    80003e0c:	85d6                	mv	a1,s5
    80003e0e:	8552                	mv	a0,s4
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	e62080e7          	jalr	-414(ra) # 80003c72 <dirlookup>
    80003e18:	89aa                	mv	s3,a0
    80003e1a:	dd41                	beqz	a0,80003db2 <namex+0x90>
    iunlockput(ip);
    80003e1c:	8552                	mv	a0,s4
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	bd2080e7          	jalr	-1070(ra) # 800039f0 <iunlockput>
    ip = next;
    80003e26:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e28:	0004c783          	lbu	a5,0(s1)
    80003e2c:	01279763          	bne	a5,s2,80003e3a <namex+0x118>
    path++;
    80003e30:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e32:	0004c783          	lbu	a5,0(s1)
    80003e36:	ff278de3          	beq	a5,s2,80003e30 <namex+0x10e>
  if(*path == 0)
    80003e3a:	cb9d                	beqz	a5,80003e70 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e3c:	0004c783          	lbu	a5,0(s1)
    80003e40:	89a6                	mv	s3,s1
  len = path - s;
    80003e42:	4c81                	li	s9,0
    80003e44:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e46:	01278963          	beq	a5,s2,80003e58 <namex+0x136>
    80003e4a:	dbbd                	beqz	a5,80003dc0 <namex+0x9e>
    path++;
    80003e4c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e4e:	0009c783          	lbu	a5,0(s3)
    80003e52:	ff279ce3          	bne	a5,s2,80003e4a <namex+0x128>
    80003e56:	b7ad                	j	80003dc0 <namex+0x9e>
    memmove(name, s, len);
    80003e58:	2601                	sext.w	a2,a2
    80003e5a:	85a6                	mv	a1,s1
    80003e5c:	8556                	mv	a0,s5
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	ecc080e7          	jalr	-308(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e66:	9cd6                	add	s9,s9,s5
    80003e68:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e6c:	84ce                	mv	s1,s3
    80003e6e:	b7bd                	j	80003ddc <namex+0xba>
  if(nameiparent){
    80003e70:	f00b0de3          	beqz	s6,80003d8a <namex+0x68>
    iput(ip);
    80003e74:	8552                	mv	a0,s4
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	ad2080e7          	jalr	-1326(ra) # 80003948 <iput>
    return 0;
    80003e7e:	4a01                	li	s4,0
    80003e80:	b729                	j	80003d8a <namex+0x68>

0000000080003e82 <dirlink>:
{
    80003e82:	7139                	addi	sp,sp,-64
    80003e84:	fc06                	sd	ra,56(sp)
    80003e86:	f822                	sd	s0,48(sp)
    80003e88:	f426                	sd	s1,40(sp)
    80003e8a:	f04a                	sd	s2,32(sp)
    80003e8c:	ec4e                	sd	s3,24(sp)
    80003e8e:	e852                	sd	s4,16(sp)
    80003e90:	0080                	addi	s0,sp,64
    80003e92:	892a                	mv	s2,a0
    80003e94:	8a2e                	mv	s4,a1
    80003e96:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e98:	4601                	li	a2,0
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	dd8080e7          	jalr	-552(ra) # 80003c72 <dirlookup>
    80003ea2:	e93d                	bnez	a0,80003f18 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea4:	04c92483          	lw	s1,76(s2)
    80003ea8:	c49d                	beqz	s1,80003ed6 <dirlink+0x54>
    80003eaa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eac:	4741                	li	a4,16
    80003eae:	86a6                	mv	a3,s1
    80003eb0:	fc040613          	addi	a2,s0,-64
    80003eb4:	4581                	li	a1,0
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	b8a080e7          	jalr	-1142(ra) # 80003a42 <readi>
    80003ec0:	47c1                	li	a5,16
    80003ec2:	06f51163          	bne	a0,a5,80003f24 <dirlink+0xa2>
    if(de.inum == 0)
    80003ec6:	fc045783          	lhu	a5,-64(s0)
    80003eca:	c791                	beqz	a5,80003ed6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ecc:	24c1                	addiw	s1,s1,16
    80003ece:	04c92783          	lw	a5,76(s2)
    80003ed2:	fcf4ede3          	bltu	s1,a5,80003eac <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ed6:	4639                	li	a2,14
    80003ed8:	85d2                	mv	a1,s4
    80003eda:	fc240513          	addi	a0,s0,-62
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	efc080e7          	jalr	-260(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003ee6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eea:	4741                	li	a4,16
    80003eec:	86a6                	mv	a3,s1
    80003eee:	fc040613          	addi	a2,s0,-64
    80003ef2:	4581                	li	a1,0
    80003ef4:	854a                	mv	a0,s2
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	c44080e7          	jalr	-956(ra) # 80003b3a <writei>
    80003efe:	1541                	addi	a0,a0,-16
    80003f00:	00a03533          	snez	a0,a0
    80003f04:	40a00533          	neg	a0,a0
}
    80003f08:	70e2                	ld	ra,56(sp)
    80003f0a:	7442                	ld	s0,48(sp)
    80003f0c:	74a2                	ld	s1,40(sp)
    80003f0e:	7902                	ld	s2,32(sp)
    80003f10:	69e2                	ld	s3,24(sp)
    80003f12:	6a42                	ld	s4,16(sp)
    80003f14:	6121                	addi	sp,sp,64
    80003f16:	8082                	ret
    iput(ip);
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	a30080e7          	jalr	-1488(ra) # 80003948 <iput>
    return -1;
    80003f20:	557d                	li	a0,-1
    80003f22:	b7dd                	j	80003f08 <dirlink+0x86>
      panic("dirlink read");
    80003f24:	00004517          	auipc	a0,0x4
    80003f28:	72450513          	addi	a0,a0,1828 # 80008648 <syscalls+0x1f8>
    80003f2c:	ffffc097          	auipc	ra,0xffffc
    80003f30:	610080e7          	jalr	1552(ra) # 8000053c <panic>

0000000080003f34 <namei>:

struct inode*
namei(char *path)
{
    80003f34:	1101                	addi	sp,sp,-32
    80003f36:	ec06                	sd	ra,24(sp)
    80003f38:	e822                	sd	s0,16(sp)
    80003f3a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f3c:	fe040613          	addi	a2,s0,-32
    80003f40:	4581                	li	a1,0
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	de0080e7          	jalr	-544(ra) # 80003d22 <namex>
}
    80003f4a:	60e2                	ld	ra,24(sp)
    80003f4c:	6442                	ld	s0,16(sp)
    80003f4e:	6105                	addi	sp,sp,32
    80003f50:	8082                	ret

0000000080003f52 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f52:	1141                	addi	sp,sp,-16
    80003f54:	e406                	sd	ra,8(sp)
    80003f56:	e022                	sd	s0,0(sp)
    80003f58:	0800                	addi	s0,sp,16
    80003f5a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f5c:	4585                	li	a1,1
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	dc4080e7          	jalr	-572(ra) # 80003d22 <namex>
}
    80003f66:	60a2                	ld	ra,8(sp)
    80003f68:	6402                	ld	s0,0(sp)
    80003f6a:	0141                	addi	sp,sp,16
    80003f6c:	8082                	ret

0000000080003f6e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f6e:	1101                	addi	sp,sp,-32
    80003f70:	ec06                	sd	ra,24(sp)
    80003f72:	e822                	sd	s0,16(sp)
    80003f74:	e426                	sd	s1,8(sp)
    80003f76:	e04a                	sd	s2,0(sp)
    80003f78:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f7a:	0001d917          	auipc	s2,0x1d
    80003f7e:	be690913          	addi	s2,s2,-1050 # 80020b60 <log>
    80003f82:	01892583          	lw	a1,24(s2)
    80003f86:	02892503          	lw	a0,40(s2)
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	ff4080e7          	jalr	-12(ra) # 80002f7e <bread>
    80003f92:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f94:	02c92603          	lw	a2,44(s2)
    80003f98:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f9a:	00c05f63          	blez	a2,80003fb8 <write_head+0x4a>
    80003f9e:	0001d717          	auipc	a4,0x1d
    80003fa2:	bf270713          	addi	a4,a4,-1038 # 80020b90 <log+0x30>
    80003fa6:	87aa                	mv	a5,a0
    80003fa8:	060a                	slli	a2,a2,0x2
    80003faa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fac:	4314                	lw	a3,0(a4)
    80003fae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fb0:	0711                	addi	a4,a4,4
    80003fb2:	0791                	addi	a5,a5,4
    80003fb4:	fec79ce3          	bne	a5,a2,80003fac <write_head+0x3e>
  }
  bwrite(buf);
    80003fb8:	8526                	mv	a0,s1
    80003fba:	fffff097          	auipc	ra,0xfffff
    80003fbe:	0b6080e7          	jalr	182(ra) # 80003070 <bwrite>
  brelse(buf);
    80003fc2:	8526                	mv	a0,s1
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	0ea080e7          	jalr	234(ra) # 800030ae <brelse>
}
    80003fcc:	60e2                	ld	ra,24(sp)
    80003fce:	6442                	ld	s0,16(sp)
    80003fd0:	64a2                	ld	s1,8(sp)
    80003fd2:	6902                	ld	s2,0(sp)
    80003fd4:	6105                	addi	sp,sp,32
    80003fd6:	8082                	ret

0000000080003fd8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd8:	0001d797          	auipc	a5,0x1d
    80003fdc:	bb47a783          	lw	a5,-1100(a5) # 80020b8c <log+0x2c>
    80003fe0:	0af05d63          	blez	a5,8000409a <install_trans+0xc2>
{
    80003fe4:	7139                	addi	sp,sp,-64
    80003fe6:	fc06                	sd	ra,56(sp)
    80003fe8:	f822                	sd	s0,48(sp)
    80003fea:	f426                	sd	s1,40(sp)
    80003fec:	f04a                	sd	s2,32(sp)
    80003fee:	ec4e                	sd	s3,24(sp)
    80003ff0:	e852                	sd	s4,16(sp)
    80003ff2:	e456                	sd	s5,8(sp)
    80003ff4:	e05a                	sd	s6,0(sp)
    80003ff6:	0080                	addi	s0,sp,64
    80003ff8:	8b2a                	mv	s6,a0
    80003ffa:	0001da97          	auipc	s5,0x1d
    80003ffe:	b96a8a93          	addi	s5,s5,-1130 # 80020b90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004002:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004004:	0001d997          	auipc	s3,0x1d
    80004008:	b5c98993          	addi	s3,s3,-1188 # 80020b60 <log>
    8000400c:	a00d                	j	8000402e <install_trans+0x56>
    brelse(lbuf);
    8000400e:	854a                	mv	a0,s2
    80004010:	fffff097          	auipc	ra,0xfffff
    80004014:	09e080e7          	jalr	158(ra) # 800030ae <brelse>
    brelse(dbuf);
    80004018:	8526                	mv	a0,s1
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	094080e7          	jalr	148(ra) # 800030ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004022:	2a05                	addiw	s4,s4,1
    80004024:	0a91                	addi	s5,s5,4
    80004026:	02c9a783          	lw	a5,44(s3)
    8000402a:	04fa5e63          	bge	s4,a5,80004086 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000402e:	0189a583          	lw	a1,24(s3)
    80004032:	014585bb          	addw	a1,a1,s4
    80004036:	2585                	addiw	a1,a1,1
    80004038:	0289a503          	lw	a0,40(s3)
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	f42080e7          	jalr	-190(ra) # 80002f7e <bread>
    80004044:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004046:	000aa583          	lw	a1,0(s5)
    8000404a:	0289a503          	lw	a0,40(s3)
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	f30080e7          	jalr	-208(ra) # 80002f7e <bread>
    80004056:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004058:	40000613          	li	a2,1024
    8000405c:	05890593          	addi	a1,s2,88
    80004060:	05850513          	addi	a0,a0,88
    80004064:	ffffd097          	auipc	ra,0xffffd
    80004068:	cc6080e7          	jalr	-826(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000406c:	8526                	mv	a0,s1
    8000406e:	fffff097          	auipc	ra,0xfffff
    80004072:	002080e7          	jalr	2(ra) # 80003070 <bwrite>
    if(recovering == 0)
    80004076:	f80b1ce3          	bnez	s6,8000400e <install_trans+0x36>
      bunpin(dbuf);
    8000407a:	8526                	mv	a0,s1
    8000407c:	fffff097          	auipc	ra,0xfffff
    80004080:	10a080e7          	jalr	266(ra) # 80003186 <bunpin>
    80004084:	b769                	j	8000400e <install_trans+0x36>
}
    80004086:	70e2                	ld	ra,56(sp)
    80004088:	7442                	ld	s0,48(sp)
    8000408a:	74a2                	ld	s1,40(sp)
    8000408c:	7902                	ld	s2,32(sp)
    8000408e:	69e2                	ld	s3,24(sp)
    80004090:	6a42                	ld	s4,16(sp)
    80004092:	6aa2                	ld	s5,8(sp)
    80004094:	6b02                	ld	s6,0(sp)
    80004096:	6121                	addi	sp,sp,64
    80004098:	8082                	ret
    8000409a:	8082                	ret

000000008000409c <initlog>:
{
    8000409c:	7179                	addi	sp,sp,-48
    8000409e:	f406                	sd	ra,40(sp)
    800040a0:	f022                	sd	s0,32(sp)
    800040a2:	ec26                	sd	s1,24(sp)
    800040a4:	e84a                	sd	s2,16(sp)
    800040a6:	e44e                	sd	s3,8(sp)
    800040a8:	1800                	addi	s0,sp,48
    800040aa:	892a                	mv	s2,a0
    800040ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040ae:	0001d497          	auipc	s1,0x1d
    800040b2:	ab248493          	addi	s1,s1,-1358 # 80020b60 <log>
    800040b6:	00004597          	auipc	a1,0x4
    800040ba:	5a258593          	addi	a1,a1,1442 # 80008658 <syscalls+0x208>
    800040be:	8526                	mv	a0,s1
    800040c0:	ffffd097          	auipc	ra,0xffffd
    800040c4:	a82080e7          	jalr	-1406(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040c8:	0149a583          	lw	a1,20(s3)
    800040cc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040ce:	0109a783          	lw	a5,16(s3)
    800040d2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040d4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040d8:	854a                	mv	a0,s2
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	ea4080e7          	jalr	-348(ra) # 80002f7e <bread>
  log.lh.n = lh->n;
    800040e2:	4d30                	lw	a2,88(a0)
    800040e4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040e6:	00c05f63          	blez	a2,80004104 <initlog+0x68>
    800040ea:	87aa                	mv	a5,a0
    800040ec:	0001d717          	auipc	a4,0x1d
    800040f0:	aa470713          	addi	a4,a4,-1372 # 80020b90 <log+0x30>
    800040f4:	060a                	slli	a2,a2,0x2
    800040f6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040f8:	4ff4                	lw	a3,92(a5)
    800040fa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040fc:	0791                	addi	a5,a5,4
    800040fe:	0711                	addi	a4,a4,4
    80004100:	fec79ce3          	bne	a5,a2,800040f8 <initlog+0x5c>
  brelse(buf);
    80004104:	fffff097          	auipc	ra,0xfffff
    80004108:	faa080e7          	jalr	-86(ra) # 800030ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000410c:	4505                	li	a0,1
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	eca080e7          	jalr	-310(ra) # 80003fd8 <install_trans>
  log.lh.n = 0;
    80004116:	0001d797          	auipc	a5,0x1d
    8000411a:	a607ab23          	sw	zero,-1418(a5) # 80020b8c <log+0x2c>
  write_head(); // clear the log
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	e50080e7          	jalr	-432(ra) # 80003f6e <write_head>
}
    80004126:	70a2                	ld	ra,40(sp)
    80004128:	7402                	ld	s0,32(sp)
    8000412a:	64e2                	ld	s1,24(sp)
    8000412c:	6942                	ld	s2,16(sp)
    8000412e:	69a2                	ld	s3,8(sp)
    80004130:	6145                	addi	sp,sp,48
    80004132:	8082                	ret

0000000080004134 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004134:	1101                	addi	sp,sp,-32
    80004136:	ec06                	sd	ra,24(sp)
    80004138:	e822                	sd	s0,16(sp)
    8000413a:	e426                	sd	s1,8(sp)
    8000413c:	e04a                	sd	s2,0(sp)
    8000413e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004140:	0001d517          	auipc	a0,0x1d
    80004144:	a2050513          	addi	a0,a0,-1504 # 80020b60 <log>
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	a8a080e7          	jalr	-1398(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004150:	0001d497          	auipc	s1,0x1d
    80004154:	a1048493          	addi	s1,s1,-1520 # 80020b60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004158:	4979                	li	s2,30
    8000415a:	a039                	j	80004168 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000415c:	85a6                	mv	a1,s1
    8000415e:	8526                	mv	a0,s1
    80004160:	ffffe097          	auipc	ra,0xffffe
    80004164:	f6e080e7          	jalr	-146(ra) # 800020ce <sleep>
    if(log.committing){
    80004168:	50dc                	lw	a5,36(s1)
    8000416a:	fbed                	bnez	a5,8000415c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000416c:	5098                	lw	a4,32(s1)
    8000416e:	2705                	addiw	a4,a4,1
    80004170:	0027179b          	slliw	a5,a4,0x2
    80004174:	9fb9                	addw	a5,a5,a4
    80004176:	0017979b          	slliw	a5,a5,0x1
    8000417a:	54d4                	lw	a3,44(s1)
    8000417c:	9fb5                	addw	a5,a5,a3
    8000417e:	00f95963          	bge	s2,a5,80004190 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004182:	85a6                	mv	a1,s1
    80004184:	8526                	mv	a0,s1
    80004186:	ffffe097          	auipc	ra,0xffffe
    8000418a:	f48080e7          	jalr	-184(ra) # 800020ce <sleep>
    8000418e:	bfe9                	j	80004168 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004190:	0001d517          	auipc	a0,0x1d
    80004194:	9d050513          	addi	a0,a0,-1584 # 80020b60 <log>
    80004198:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000419a:	ffffd097          	auipc	ra,0xffffd
    8000419e:	aec080e7          	jalr	-1300(ra) # 80000c86 <release>
      break;
    }
  }
}
    800041a2:	60e2                	ld	ra,24(sp)
    800041a4:	6442                	ld	s0,16(sp)
    800041a6:	64a2                	ld	s1,8(sp)
    800041a8:	6902                	ld	s2,0(sp)
    800041aa:	6105                	addi	sp,sp,32
    800041ac:	8082                	ret

00000000800041ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041ae:	7139                	addi	sp,sp,-64
    800041b0:	fc06                	sd	ra,56(sp)
    800041b2:	f822                	sd	s0,48(sp)
    800041b4:	f426                	sd	s1,40(sp)
    800041b6:	f04a                	sd	s2,32(sp)
    800041b8:	ec4e                	sd	s3,24(sp)
    800041ba:	e852                	sd	s4,16(sp)
    800041bc:	e456                	sd	s5,8(sp)
    800041be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041c0:	0001d497          	auipc	s1,0x1d
    800041c4:	9a048493          	addi	s1,s1,-1632 # 80020b60 <log>
    800041c8:	8526                	mv	a0,s1
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	a08080e7          	jalr	-1528(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041d2:	509c                	lw	a5,32(s1)
    800041d4:	37fd                	addiw	a5,a5,-1
    800041d6:	0007891b          	sext.w	s2,a5
    800041da:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041dc:	50dc                	lw	a5,36(s1)
    800041de:	e7b9                	bnez	a5,8000422c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041e0:	04091e63          	bnez	s2,8000423c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041e4:	0001d497          	auipc	s1,0x1d
    800041e8:	97c48493          	addi	s1,s1,-1668 # 80020b60 <log>
    800041ec:	4785                	li	a5,1
    800041ee:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041f0:	8526                	mv	a0,s1
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	a94080e7          	jalr	-1388(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041fa:	54dc                	lw	a5,44(s1)
    800041fc:	06f04763          	bgtz	a5,8000426a <end_op+0xbc>
    acquire(&log.lock);
    80004200:	0001d497          	auipc	s1,0x1d
    80004204:	96048493          	addi	s1,s1,-1696 # 80020b60 <log>
    80004208:	8526                	mv	a0,s1
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	9c8080e7          	jalr	-1592(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004212:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004216:	8526                	mv	a0,s1
    80004218:	ffffe097          	auipc	ra,0xffffe
    8000421c:	f1a080e7          	jalr	-230(ra) # 80002132 <wakeup>
    release(&log.lock);
    80004220:	8526                	mv	a0,s1
    80004222:	ffffd097          	auipc	ra,0xffffd
    80004226:	a64080e7          	jalr	-1436(ra) # 80000c86 <release>
}
    8000422a:	a03d                	j	80004258 <end_op+0xaa>
    panic("log.committing");
    8000422c:	00004517          	auipc	a0,0x4
    80004230:	43450513          	addi	a0,a0,1076 # 80008660 <syscalls+0x210>
    80004234:	ffffc097          	auipc	ra,0xffffc
    80004238:	308080e7          	jalr	776(ra) # 8000053c <panic>
    wakeup(&log);
    8000423c:	0001d497          	auipc	s1,0x1d
    80004240:	92448493          	addi	s1,s1,-1756 # 80020b60 <log>
    80004244:	8526                	mv	a0,s1
    80004246:	ffffe097          	auipc	ra,0xffffe
    8000424a:	eec080e7          	jalr	-276(ra) # 80002132 <wakeup>
  release(&log.lock);
    8000424e:	8526                	mv	a0,s1
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	a36080e7          	jalr	-1482(ra) # 80000c86 <release>
}
    80004258:	70e2                	ld	ra,56(sp)
    8000425a:	7442                	ld	s0,48(sp)
    8000425c:	74a2                	ld	s1,40(sp)
    8000425e:	7902                	ld	s2,32(sp)
    80004260:	69e2                	ld	s3,24(sp)
    80004262:	6a42                	ld	s4,16(sp)
    80004264:	6aa2                	ld	s5,8(sp)
    80004266:	6121                	addi	sp,sp,64
    80004268:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000426a:	0001da97          	auipc	s5,0x1d
    8000426e:	926a8a93          	addi	s5,s5,-1754 # 80020b90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004272:	0001da17          	auipc	s4,0x1d
    80004276:	8eea0a13          	addi	s4,s4,-1810 # 80020b60 <log>
    8000427a:	018a2583          	lw	a1,24(s4)
    8000427e:	012585bb          	addw	a1,a1,s2
    80004282:	2585                	addiw	a1,a1,1
    80004284:	028a2503          	lw	a0,40(s4)
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	cf6080e7          	jalr	-778(ra) # 80002f7e <bread>
    80004290:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004292:	000aa583          	lw	a1,0(s5)
    80004296:	028a2503          	lw	a0,40(s4)
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	ce4080e7          	jalr	-796(ra) # 80002f7e <bread>
    800042a2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042a4:	40000613          	li	a2,1024
    800042a8:	05850593          	addi	a1,a0,88
    800042ac:	05848513          	addi	a0,s1,88
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	a7a080e7          	jalr	-1414(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800042b8:	8526                	mv	a0,s1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	db6080e7          	jalr	-586(ra) # 80003070 <bwrite>
    brelse(from);
    800042c2:	854e                	mv	a0,s3
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	dea080e7          	jalr	-534(ra) # 800030ae <brelse>
    brelse(to);
    800042cc:	8526                	mv	a0,s1
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	de0080e7          	jalr	-544(ra) # 800030ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042d6:	2905                	addiw	s2,s2,1
    800042d8:	0a91                	addi	s5,s5,4
    800042da:	02ca2783          	lw	a5,44(s4)
    800042de:	f8f94ee3          	blt	s2,a5,8000427a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	c8c080e7          	jalr	-884(ra) # 80003f6e <write_head>
    install_trans(0); // Now install writes to home locations
    800042ea:	4501                	li	a0,0
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	cec080e7          	jalr	-788(ra) # 80003fd8 <install_trans>
    log.lh.n = 0;
    800042f4:	0001d797          	auipc	a5,0x1d
    800042f8:	8807ac23          	sw	zero,-1896(a5) # 80020b8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	c72080e7          	jalr	-910(ra) # 80003f6e <write_head>
    80004304:	bdf5                	j	80004200 <end_op+0x52>

0000000080004306 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004306:	1101                	addi	sp,sp,-32
    80004308:	ec06                	sd	ra,24(sp)
    8000430a:	e822                	sd	s0,16(sp)
    8000430c:	e426                	sd	s1,8(sp)
    8000430e:	e04a                	sd	s2,0(sp)
    80004310:	1000                	addi	s0,sp,32
    80004312:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004314:	0001d917          	auipc	s2,0x1d
    80004318:	84c90913          	addi	s2,s2,-1972 # 80020b60 <log>
    8000431c:	854a                	mv	a0,s2
    8000431e:	ffffd097          	auipc	ra,0xffffd
    80004322:	8b4080e7          	jalr	-1868(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004326:	02c92603          	lw	a2,44(s2)
    8000432a:	47f5                	li	a5,29
    8000432c:	06c7c563          	blt	a5,a2,80004396 <log_write+0x90>
    80004330:	0001d797          	auipc	a5,0x1d
    80004334:	84c7a783          	lw	a5,-1972(a5) # 80020b7c <log+0x1c>
    80004338:	37fd                	addiw	a5,a5,-1
    8000433a:	04f65e63          	bge	a2,a5,80004396 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000433e:	0001d797          	auipc	a5,0x1d
    80004342:	8427a783          	lw	a5,-1982(a5) # 80020b80 <log+0x20>
    80004346:	06f05063          	blez	a5,800043a6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000434a:	4781                	li	a5,0
    8000434c:	06c05563          	blez	a2,800043b6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004350:	44cc                	lw	a1,12(s1)
    80004352:	0001d717          	auipc	a4,0x1d
    80004356:	83e70713          	addi	a4,a4,-1986 # 80020b90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000435a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000435c:	4314                	lw	a3,0(a4)
    8000435e:	04b68c63          	beq	a3,a1,800043b6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004362:	2785                	addiw	a5,a5,1
    80004364:	0711                	addi	a4,a4,4
    80004366:	fef61be3          	bne	a2,a5,8000435c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000436a:	0621                	addi	a2,a2,8
    8000436c:	060a                	slli	a2,a2,0x2
    8000436e:	0001c797          	auipc	a5,0x1c
    80004372:	7f278793          	addi	a5,a5,2034 # 80020b60 <log>
    80004376:	97b2                	add	a5,a5,a2
    80004378:	44d8                	lw	a4,12(s1)
    8000437a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000437c:	8526                	mv	a0,s1
    8000437e:	fffff097          	auipc	ra,0xfffff
    80004382:	dcc080e7          	jalr	-564(ra) # 8000314a <bpin>
    log.lh.n++;
    80004386:	0001c717          	auipc	a4,0x1c
    8000438a:	7da70713          	addi	a4,a4,2010 # 80020b60 <log>
    8000438e:	575c                	lw	a5,44(a4)
    80004390:	2785                	addiw	a5,a5,1
    80004392:	d75c                	sw	a5,44(a4)
    80004394:	a82d                	j	800043ce <log_write+0xc8>
    panic("too big a transaction");
    80004396:	00004517          	auipc	a0,0x4
    8000439a:	2da50513          	addi	a0,a0,730 # 80008670 <syscalls+0x220>
    8000439e:	ffffc097          	auipc	ra,0xffffc
    800043a2:	19e080e7          	jalr	414(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800043a6:	00004517          	auipc	a0,0x4
    800043aa:	2e250513          	addi	a0,a0,738 # 80008688 <syscalls+0x238>
    800043ae:	ffffc097          	auipc	ra,0xffffc
    800043b2:	18e080e7          	jalr	398(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043b6:	00878693          	addi	a3,a5,8
    800043ba:	068a                	slli	a3,a3,0x2
    800043bc:	0001c717          	auipc	a4,0x1c
    800043c0:	7a470713          	addi	a4,a4,1956 # 80020b60 <log>
    800043c4:	9736                	add	a4,a4,a3
    800043c6:	44d4                	lw	a3,12(s1)
    800043c8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043ca:	faf609e3          	beq	a2,a5,8000437c <log_write+0x76>
  }
  release(&log.lock);
    800043ce:	0001c517          	auipc	a0,0x1c
    800043d2:	79250513          	addi	a0,a0,1938 # 80020b60 <log>
    800043d6:	ffffd097          	auipc	ra,0xffffd
    800043da:	8b0080e7          	jalr	-1872(ra) # 80000c86 <release>
}
    800043de:	60e2                	ld	ra,24(sp)
    800043e0:	6442                	ld	s0,16(sp)
    800043e2:	64a2                	ld	s1,8(sp)
    800043e4:	6902                	ld	s2,0(sp)
    800043e6:	6105                	addi	sp,sp,32
    800043e8:	8082                	ret

00000000800043ea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043ea:	1101                	addi	sp,sp,-32
    800043ec:	ec06                	sd	ra,24(sp)
    800043ee:	e822                	sd	s0,16(sp)
    800043f0:	e426                	sd	s1,8(sp)
    800043f2:	e04a                	sd	s2,0(sp)
    800043f4:	1000                	addi	s0,sp,32
    800043f6:	84aa                	mv	s1,a0
    800043f8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043fa:	00004597          	auipc	a1,0x4
    800043fe:	2ae58593          	addi	a1,a1,686 # 800086a8 <syscalls+0x258>
    80004402:	0521                	addi	a0,a0,8
    80004404:	ffffc097          	auipc	ra,0xffffc
    80004408:	73e080e7          	jalr	1854(ra) # 80000b42 <initlock>
  lk->name = name;
    8000440c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004410:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004414:	0204a423          	sw	zero,40(s1)
}
    80004418:	60e2                	ld	ra,24(sp)
    8000441a:	6442                	ld	s0,16(sp)
    8000441c:	64a2                	ld	s1,8(sp)
    8000441e:	6902                	ld	s2,0(sp)
    80004420:	6105                	addi	sp,sp,32
    80004422:	8082                	ret

0000000080004424 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004424:	1101                	addi	sp,sp,-32
    80004426:	ec06                	sd	ra,24(sp)
    80004428:	e822                	sd	s0,16(sp)
    8000442a:	e426                	sd	s1,8(sp)
    8000442c:	e04a                	sd	s2,0(sp)
    8000442e:	1000                	addi	s0,sp,32
    80004430:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004432:	00850913          	addi	s2,a0,8
    80004436:	854a                	mv	a0,s2
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	79a080e7          	jalr	1946(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004440:	409c                	lw	a5,0(s1)
    80004442:	cb89                	beqz	a5,80004454 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004444:	85ca                	mv	a1,s2
    80004446:	8526                	mv	a0,s1
    80004448:	ffffe097          	auipc	ra,0xffffe
    8000444c:	c86080e7          	jalr	-890(ra) # 800020ce <sleep>
  while (lk->locked) {
    80004450:	409c                	lw	a5,0(s1)
    80004452:	fbed                	bnez	a5,80004444 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004454:	4785                	li	a5,1
    80004456:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004458:	ffffd097          	auipc	ra,0xffffd
    8000445c:	54e080e7          	jalr	1358(ra) # 800019a6 <myproc>
    80004460:	591c                	lw	a5,48(a0)
    80004462:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004464:	854a                	mv	a0,s2
    80004466:	ffffd097          	auipc	ra,0xffffd
    8000446a:	820080e7          	jalr	-2016(ra) # 80000c86 <release>
}
    8000446e:	60e2                	ld	ra,24(sp)
    80004470:	6442                	ld	s0,16(sp)
    80004472:	64a2                	ld	s1,8(sp)
    80004474:	6902                	ld	s2,0(sp)
    80004476:	6105                	addi	sp,sp,32
    80004478:	8082                	ret

000000008000447a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000447a:	1101                	addi	sp,sp,-32
    8000447c:	ec06                	sd	ra,24(sp)
    8000447e:	e822                	sd	s0,16(sp)
    80004480:	e426                	sd	s1,8(sp)
    80004482:	e04a                	sd	s2,0(sp)
    80004484:	1000                	addi	s0,sp,32
    80004486:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004488:	00850913          	addi	s2,a0,8
    8000448c:	854a                	mv	a0,s2
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	744080e7          	jalr	1860(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004496:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000449a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000449e:	8526                	mv	a0,s1
    800044a0:	ffffe097          	auipc	ra,0xffffe
    800044a4:	c92080e7          	jalr	-878(ra) # 80002132 <wakeup>
  release(&lk->lk);
    800044a8:	854a                	mv	a0,s2
    800044aa:	ffffc097          	auipc	ra,0xffffc
    800044ae:	7dc080e7          	jalr	2012(ra) # 80000c86 <release>
}
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6902                	ld	s2,0(sp)
    800044ba:	6105                	addi	sp,sp,32
    800044bc:	8082                	ret

00000000800044be <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044be:	7179                	addi	sp,sp,-48
    800044c0:	f406                	sd	ra,40(sp)
    800044c2:	f022                	sd	s0,32(sp)
    800044c4:	ec26                	sd	s1,24(sp)
    800044c6:	e84a                	sd	s2,16(sp)
    800044c8:	e44e                	sd	s3,8(sp)
    800044ca:	1800                	addi	s0,sp,48
    800044cc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044ce:	00850913          	addi	s2,a0,8
    800044d2:	854a                	mv	a0,s2
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	6fe080e7          	jalr	1790(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044dc:	409c                	lw	a5,0(s1)
    800044de:	ef99                	bnez	a5,800044fc <holdingsleep+0x3e>
    800044e0:	4481                	li	s1,0
  release(&lk->lk);
    800044e2:	854a                	mv	a0,s2
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	7a2080e7          	jalr	1954(ra) # 80000c86 <release>
  return r;
}
    800044ec:	8526                	mv	a0,s1
    800044ee:	70a2                	ld	ra,40(sp)
    800044f0:	7402                	ld	s0,32(sp)
    800044f2:	64e2                	ld	s1,24(sp)
    800044f4:	6942                	ld	s2,16(sp)
    800044f6:	69a2                	ld	s3,8(sp)
    800044f8:	6145                	addi	sp,sp,48
    800044fa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044fc:	0284a983          	lw	s3,40(s1)
    80004500:	ffffd097          	auipc	ra,0xffffd
    80004504:	4a6080e7          	jalr	1190(ra) # 800019a6 <myproc>
    80004508:	5904                	lw	s1,48(a0)
    8000450a:	413484b3          	sub	s1,s1,s3
    8000450e:	0014b493          	seqz	s1,s1
    80004512:	bfc1                	j	800044e2 <holdingsleep+0x24>

0000000080004514 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004514:	1141                	addi	sp,sp,-16
    80004516:	e406                	sd	ra,8(sp)
    80004518:	e022                	sd	s0,0(sp)
    8000451a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000451c:	00004597          	auipc	a1,0x4
    80004520:	19c58593          	addi	a1,a1,412 # 800086b8 <syscalls+0x268>
    80004524:	0001c517          	auipc	a0,0x1c
    80004528:	78450513          	addi	a0,a0,1924 # 80020ca8 <ftable>
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	616080e7          	jalr	1558(ra) # 80000b42 <initlock>
}
    80004534:	60a2                	ld	ra,8(sp)
    80004536:	6402                	ld	s0,0(sp)
    80004538:	0141                	addi	sp,sp,16
    8000453a:	8082                	ret

000000008000453c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000453c:	1101                	addi	sp,sp,-32
    8000453e:	ec06                	sd	ra,24(sp)
    80004540:	e822                	sd	s0,16(sp)
    80004542:	e426                	sd	s1,8(sp)
    80004544:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004546:	0001c517          	auipc	a0,0x1c
    8000454a:	76250513          	addi	a0,a0,1890 # 80020ca8 <ftable>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	684080e7          	jalr	1668(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004556:	0001c497          	auipc	s1,0x1c
    8000455a:	76a48493          	addi	s1,s1,1898 # 80020cc0 <ftable+0x18>
    8000455e:	0001d717          	auipc	a4,0x1d
    80004562:	70270713          	addi	a4,a4,1794 # 80021c60 <disk>
    if(f->ref == 0){
    80004566:	40dc                	lw	a5,4(s1)
    80004568:	cf99                	beqz	a5,80004586 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000456a:	02848493          	addi	s1,s1,40
    8000456e:	fee49ce3          	bne	s1,a4,80004566 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004572:	0001c517          	auipc	a0,0x1c
    80004576:	73650513          	addi	a0,a0,1846 # 80020ca8 <ftable>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	70c080e7          	jalr	1804(ra) # 80000c86 <release>
  return 0;
    80004582:	4481                	li	s1,0
    80004584:	a819                	j	8000459a <filealloc+0x5e>
      f->ref = 1;
    80004586:	4785                	li	a5,1
    80004588:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000458a:	0001c517          	auipc	a0,0x1c
    8000458e:	71e50513          	addi	a0,a0,1822 # 80020ca8 <ftable>
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	6f4080e7          	jalr	1780(ra) # 80000c86 <release>
}
    8000459a:	8526                	mv	a0,s1
    8000459c:	60e2                	ld	ra,24(sp)
    8000459e:	6442                	ld	s0,16(sp)
    800045a0:	64a2                	ld	s1,8(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret

00000000800045a6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045a6:	1101                	addi	sp,sp,-32
    800045a8:	ec06                	sd	ra,24(sp)
    800045aa:	e822                	sd	s0,16(sp)
    800045ac:	e426                	sd	s1,8(sp)
    800045ae:	1000                	addi	s0,sp,32
    800045b0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045b2:	0001c517          	auipc	a0,0x1c
    800045b6:	6f650513          	addi	a0,a0,1782 # 80020ca8 <ftable>
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	618080e7          	jalr	1560(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045c2:	40dc                	lw	a5,4(s1)
    800045c4:	02f05263          	blez	a5,800045e8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045c8:	2785                	addiw	a5,a5,1
    800045ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045cc:	0001c517          	auipc	a0,0x1c
    800045d0:	6dc50513          	addi	a0,a0,1756 # 80020ca8 <ftable>
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	6b2080e7          	jalr	1714(ra) # 80000c86 <release>
  return f;
}
    800045dc:	8526                	mv	a0,s1
    800045de:	60e2                	ld	ra,24(sp)
    800045e0:	6442                	ld	s0,16(sp)
    800045e2:	64a2                	ld	s1,8(sp)
    800045e4:	6105                	addi	sp,sp,32
    800045e6:	8082                	ret
    panic("filedup");
    800045e8:	00004517          	auipc	a0,0x4
    800045ec:	0d850513          	addi	a0,a0,216 # 800086c0 <syscalls+0x270>
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	f4c080e7          	jalr	-180(ra) # 8000053c <panic>

00000000800045f8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045f8:	7139                	addi	sp,sp,-64
    800045fa:	fc06                	sd	ra,56(sp)
    800045fc:	f822                	sd	s0,48(sp)
    800045fe:	f426                	sd	s1,40(sp)
    80004600:	f04a                	sd	s2,32(sp)
    80004602:	ec4e                	sd	s3,24(sp)
    80004604:	e852                	sd	s4,16(sp)
    80004606:	e456                	sd	s5,8(sp)
    80004608:	0080                	addi	s0,sp,64
    8000460a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000460c:	0001c517          	auipc	a0,0x1c
    80004610:	69c50513          	addi	a0,a0,1692 # 80020ca8 <ftable>
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	5be080e7          	jalr	1470(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000461c:	40dc                	lw	a5,4(s1)
    8000461e:	06f05163          	blez	a5,80004680 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004622:	37fd                	addiw	a5,a5,-1
    80004624:	0007871b          	sext.w	a4,a5
    80004628:	c0dc                	sw	a5,4(s1)
    8000462a:	06e04363          	bgtz	a4,80004690 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000462e:	0004a903          	lw	s2,0(s1)
    80004632:	0094ca83          	lbu	s5,9(s1)
    80004636:	0104ba03          	ld	s4,16(s1)
    8000463a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000463e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004642:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004646:	0001c517          	auipc	a0,0x1c
    8000464a:	66250513          	addi	a0,a0,1634 # 80020ca8 <ftable>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	638080e7          	jalr	1592(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004656:	4785                	li	a5,1
    80004658:	04f90d63          	beq	s2,a5,800046b2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000465c:	3979                	addiw	s2,s2,-2
    8000465e:	4785                	li	a5,1
    80004660:	0527e063          	bltu	a5,s2,800046a0 <fileclose+0xa8>
    begin_op();
    80004664:	00000097          	auipc	ra,0x0
    80004668:	ad0080e7          	jalr	-1328(ra) # 80004134 <begin_op>
    iput(ff.ip);
    8000466c:	854e                	mv	a0,s3
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	2da080e7          	jalr	730(ra) # 80003948 <iput>
    end_op();
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	b38080e7          	jalr	-1224(ra) # 800041ae <end_op>
    8000467e:	a00d                	j	800046a0 <fileclose+0xa8>
    panic("fileclose");
    80004680:	00004517          	auipc	a0,0x4
    80004684:	04850513          	addi	a0,a0,72 # 800086c8 <syscalls+0x278>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	eb4080e7          	jalr	-332(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004690:	0001c517          	auipc	a0,0x1c
    80004694:	61850513          	addi	a0,a0,1560 # 80020ca8 <ftable>
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	5ee080e7          	jalr	1518(ra) # 80000c86 <release>
  }
}
    800046a0:	70e2                	ld	ra,56(sp)
    800046a2:	7442                	ld	s0,48(sp)
    800046a4:	74a2                	ld	s1,40(sp)
    800046a6:	7902                	ld	s2,32(sp)
    800046a8:	69e2                	ld	s3,24(sp)
    800046aa:	6a42                	ld	s4,16(sp)
    800046ac:	6aa2                	ld	s5,8(sp)
    800046ae:	6121                	addi	sp,sp,64
    800046b0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046b2:	85d6                	mv	a1,s5
    800046b4:	8552                	mv	a0,s4
    800046b6:	00000097          	auipc	ra,0x0
    800046ba:	348080e7          	jalr	840(ra) # 800049fe <pipeclose>
    800046be:	b7cd                	j	800046a0 <fileclose+0xa8>

00000000800046c0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046c0:	715d                	addi	sp,sp,-80
    800046c2:	e486                	sd	ra,72(sp)
    800046c4:	e0a2                	sd	s0,64(sp)
    800046c6:	fc26                	sd	s1,56(sp)
    800046c8:	f84a                	sd	s2,48(sp)
    800046ca:	f44e                	sd	s3,40(sp)
    800046cc:	0880                	addi	s0,sp,80
    800046ce:	84aa                	mv	s1,a0
    800046d0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046d2:	ffffd097          	auipc	ra,0xffffd
    800046d6:	2d4080e7          	jalr	724(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046da:	409c                	lw	a5,0(s1)
    800046dc:	37f9                	addiw	a5,a5,-2
    800046de:	4705                	li	a4,1
    800046e0:	04f76763          	bltu	a4,a5,8000472e <filestat+0x6e>
    800046e4:	892a                	mv	s2,a0
    ilock(f->ip);
    800046e6:	6c88                	ld	a0,24(s1)
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	0a6080e7          	jalr	166(ra) # 8000378e <ilock>
    stati(f->ip, &st);
    800046f0:	fb840593          	addi	a1,s0,-72
    800046f4:	6c88                	ld	a0,24(s1)
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	322080e7          	jalr	802(ra) # 80003a18 <stati>
    iunlock(f->ip);
    800046fe:	6c88                	ld	a0,24(s1)
    80004700:	fffff097          	auipc	ra,0xfffff
    80004704:	150080e7          	jalr	336(ra) # 80003850 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004708:	46e1                	li	a3,24
    8000470a:	fb840613          	addi	a2,s0,-72
    8000470e:	85ce                	mv	a1,s3
    80004710:	05093503          	ld	a0,80(s2)
    80004714:	ffffd097          	auipc	ra,0xffffd
    80004718:	f52080e7          	jalr	-174(ra) # 80001666 <copyout>
    8000471c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004720:	60a6                	ld	ra,72(sp)
    80004722:	6406                	ld	s0,64(sp)
    80004724:	74e2                	ld	s1,56(sp)
    80004726:	7942                	ld	s2,48(sp)
    80004728:	79a2                	ld	s3,40(sp)
    8000472a:	6161                	addi	sp,sp,80
    8000472c:	8082                	ret
  return -1;
    8000472e:	557d                	li	a0,-1
    80004730:	bfc5                	j	80004720 <filestat+0x60>

0000000080004732 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004732:	7179                	addi	sp,sp,-48
    80004734:	f406                	sd	ra,40(sp)
    80004736:	f022                	sd	s0,32(sp)
    80004738:	ec26                	sd	s1,24(sp)
    8000473a:	e84a                	sd	s2,16(sp)
    8000473c:	e44e                	sd	s3,8(sp)
    8000473e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004740:	00854783          	lbu	a5,8(a0)
    80004744:	c3d5                	beqz	a5,800047e8 <fileread+0xb6>
    80004746:	84aa                	mv	s1,a0
    80004748:	89ae                	mv	s3,a1
    8000474a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000474c:	411c                	lw	a5,0(a0)
    8000474e:	4705                	li	a4,1
    80004750:	04e78963          	beq	a5,a4,800047a2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004754:	470d                	li	a4,3
    80004756:	04e78d63          	beq	a5,a4,800047b0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000475a:	4709                	li	a4,2
    8000475c:	06e79e63          	bne	a5,a4,800047d8 <fileread+0xa6>
    ilock(f->ip);
    80004760:	6d08                	ld	a0,24(a0)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	02c080e7          	jalr	44(ra) # 8000378e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000476a:	874a                	mv	a4,s2
    8000476c:	5094                	lw	a3,32(s1)
    8000476e:	864e                	mv	a2,s3
    80004770:	4585                	li	a1,1
    80004772:	6c88                	ld	a0,24(s1)
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	2ce080e7          	jalr	718(ra) # 80003a42 <readi>
    8000477c:	892a                	mv	s2,a0
    8000477e:	00a05563          	blez	a0,80004788 <fileread+0x56>
      f->off += r;
    80004782:	509c                	lw	a5,32(s1)
    80004784:	9fa9                	addw	a5,a5,a0
    80004786:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004788:	6c88                	ld	a0,24(s1)
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	0c6080e7          	jalr	198(ra) # 80003850 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004792:	854a                	mv	a0,s2
    80004794:	70a2                	ld	ra,40(sp)
    80004796:	7402                	ld	s0,32(sp)
    80004798:	64e2                	ld	s1,24(sp)
    8000479a:	6942                	ld	s2,16(sp)
    8000479c:	69a2                	ld	s3,8(sp)
    8000479e:	6145                	addi	sp,sp,48
    800047a0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047a2:	6908                	ld	a0,16(a0)
    800047a4:	00000097          	auipc	ra,0x0
    800047a8:	3c2080e7          	jalr	962(ra) # 80004b66 <piperead>
    800047ac:	892a                	mv	s2,a0
    800047ae:	b7d5                	j	80004792 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047b0:	02451783          	lh	a5,36(a0)
    800047b4:	03079693          	slli	a3,a5,0x30
    800047b8:	92c1                	srli	a3,a3,0x30
    800047ba:	4725                	li	a4,9
    800047bc:	02d76863          	bltu	a4,a3,800047ec <fileread+0xba>
    800047c0:	0792                	slli	a5,a5,0x4
    800047c2:	0001c717          	auipc	a4,0x1c
    800047c6:	44670713          	addi	a4,a4,1094 # 80020c08 <devsw>
    800047ca:	97ba                	add	a5,a5,a4
    800047cc:	639c                	ld	a5,0(a5)
    800047ce:	c38d                	beqz	a5,800047f0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047d0:	4505                	li	a0,1
    800047d2:	9782                	jalr	a5
    800047d4:	892a                	mv	s2,a0
    800047d6:	bf75                	j	80004792 <fileread+0x60>
    panic("fileread");
    800047d8:	00004517          	auipc	a0,0x4
    800047dc:	f0050513          	addi	a0,a0,-256 # 800086d8 <syscalls+0x288>
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	d5c080e7          	jalr	-676(ra) # 8000053c <panic>
    return -1;
    800047e8:	597d                	li	s2,-1
    800047ea:	b765                	j	80004792 <fileread+0x60>
      return -1;
    800047ec:	597d                	li	s2,-1
    800047ee:	b755                	j	80004792 <fileread+0x60>
    800047f0:	597d                	li	s2,-1
    800047f2:	b745                	j	80004792 <fileread+0x60>

00000000800047f4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047f4:	00954783          	lbu	a5,9(a0)
    800047f8:	10078e63          	beqz	a5,80004914 <filewrite+0x120>
{
    800047fc:	715d                	addi	sp,sp,-80
    800047fe:	e486                	sd	ra,72(sp)
    80004800:	e0a2                	sd	s0,64(sp)
    80004802:	fc26                	sd	s1,56(sp)
    80004804:	f84a                	sd	s2,48(sp)
    80004806:	f44e                	sd	s3,40(sp)
    80004808:	f052                	sd	s4,32(sp)
    8000480a:	ec56                	sd	s5,24(sp)
    8000480c:	e85a                	sd	s6,16(sp)
    8000480e:	e45e                	sd	s7,8(sp)
    80004810:	e062                	sd	s8,0(sp)
    80004812:	0880                	addi	s0,sp,80
    80004814:	892a                	mv	s2,a0
    80004816:	8b2e                	mv	s6,a1
    80004818:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000481a:	411c                	lw	a5,0(a0)
    8000481c:	4705                	li	a4,1
    8000481e:	02e78263          	beq	a5,a4,80004842 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004822:	470d                	li	a4,3
    80004824:	02e78563          	beq	a5,a4,8000484e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004828:	4709                	li	a4,2
    8000482a:	0ce79d63          	bne	a5,a4,80004904 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000482e:	0ac05b63          	blez	a2,800048e4 <filewrite+0xf0>
    int i = 0;
    80004832:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004834:	6b85                	lui	s7,0x1
    80004836:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000483a:	6c05                	lui	s8,0x1
    8000483c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004840:	a851                	j	800048d4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004842:	6908                	ld	a0,16(a0)
    80004844:	00000097          	auipc	ra,0x0
    80004848:	22a080e7          	jalr	554(ra) # 80004a6e <pipewrite>
    8000484c:	a045                	j	800048ec <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000484e:	02451783          	lh	a5,36(a0)
    80004852:	03079693          	slli	a3,a5,0x30
    80004856:	92c1                	srli	a3,a3,0x30
    80004858:	4725                	li	a4,9
    8000485a:	0ad76f63          	bltu	a4,a3,80004918 <filewrite+0x124>
    8000485e:	0792                	slli	a5,a5,0x4
    80004860:	0001c717          	auipc	a4,0x1c
    80004864:	3a870713          	addi	a4,a4,936 # 80020c08 <devsw>
    80004868:	97ba                	add	a5,a5,a4
    8000486a:	679c                	ld	a5,8(a5)
    8000486c:	cbc5                	beqz	a5,8000491c <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000486e:	4505                	li	a0,1
    80004870:	9782                	jalr	a5
    80004872:	a8ad                	j	800048ec <filewrite+0xf8>
      if(n1 > max)
    80004874:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004878:	00000097          	auipc	ra,0x0
    8000487c:	8bc080e7          	jalr	-1860(ra) # 80004134 <begin_op>
      ilock(f->ip);
    80004880:	01893503          	ld	a0,24(s2)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	f0a080e7          	jalr	-246(ra) # 8000378e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000488c:	8756                	mv	a4,s5
    8000488e:	02092683          	lw	a3,32(s2)
    80004892:	01698633          	add	a2,s3,s6
    80004896:	4585                	li	a1,1
    80004898:	01893503          	ld	a0,24(s2)
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	29e080e7          	jalr	670(ra) # 80003b3a <writei>
    800048a4:	84aa                	mv	s1,a0
    800048a6:	00a05763          	blez	a0,800048b4 <filewrite+0xc0>
        f->off += r;
    800048aa:	02092783          	lw	a5,32(s2)
    800048ae:	9fa9                	addw	a5,a5,a0
    800048b0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048b4:	01893503          	ld	a0,24(s2)
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	f98080e7          	jalr	-104(ra) # 80003850 <iunlock>
      end_op();
    800048c0:	00000097          	auipc	ra,0x0
    800048c4:	8ee080e7          	jalr	-1810(ra) # 800041ae <end_op>

      if(r != n1){
    800048c8:	009a9f63          	bne	s5,s1,800048e6 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048cc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048d0:	0149db63          	bge	s3,s4,800048e6 <filewrite+0xf2>
      int n1 = n - i;
    800048d4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048d8:	0004879b          	sext.w	a5,s1
    800048dc:	f8fbdce3          	bge	s7,a5,80004874 <filewrite+0x80>
    800048e0:	84e2                	mv	s1,s8
    800048e2:	bf49                	j	80004874 <filewrite+0x80>
    int i = 0;
    800048e4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048e6:	033a1d63          	bne	s4,s3,80004920 <filewrite+0x12c>
    800048ea:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048ec:	60a6                	ld	ra,72(sp)
    800048ee:	6406                	ld	s0,64(sp)
    800048f0:	74e2                	ld	s1,56(sp)
    800048f2:	7942                	ld	s2,48(sp)
    800048f4:	79a2                	ld	s3,40(sp)
    800048f6:	7a02                	ld	s4,32(sp)
    800048f8:	6ae2                	ld	s5,24(sp)
    800048fa:	6b42                	ld	s6,16(sp)
    800048fc:	6ba2                	ld	s7,8(sp)
    800048fe:	6c02                	ld	s8,0(sp)
    80004900:	6161                	addi	sp,sp,80
    80004902:	8082                	ret
    panic("filewrite");
    80004904:	00004517          	auipc	a0,0x4
    80004908:	de450513          	addi	a0,a0,-540 # 800086e8 <syscalls+0x298>
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	c30080e7          	jalr	-976(ra) # 8000053c <panic>
    return -1;
    80004914:	557d                	li	a0,-1
}
    80004916:	8082                	ret
      return -1;
    80004918:	557d                	li	a0,-1
    8000491a:	bfc9                	j	800048ec <filewrite+0xf8>
    8000491c:	557d                	li	a0,-1
    8000491e:	b7f9                	j	800048ec <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004920:	557d                	li	a0,-1
    80004922:	b7e9                	j	800048ec <filewrite+0xf8>

0000000080004924 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004924:	7179                	addi	sp,sp,-48
    80004926:	f406                	sd	ra,40(sp)
    80004928:	f022                	sd	s0,32(sp)
    8000492a:	ec26                	sd	s1,24(sp)
    8000492c:	e84a                	sd	s2,16(sp)
    8000492e:	e44e                	sd	s3,8(sp)
    80004930:	e052                	sd	s4,0(sp)
    80004932:	1800                	addi	s0,sp,48
    80004934:	84aa                	mv	s1,a0
    80004936:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004938:	0005b023          	sd	zero,0(a1)
    8000493c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004940:	00000097          	auipc	ra,0x0
    80004944:	bfc080e7          	jalr	-1028(ra) # 8000453c <filealloc>
    80004948:	e088                	sd	a0,0(s1)
    8000494a:	c551                	beqz	a0,800049d6 <pipealloc+0xb2>
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	bf0080e7          	jalr	-1040(ra) # 8000453c <filealloc>
    80004954:	00aa3023          	sd	a0,0(s4)
    80004958:	c92d                	beqz	a0,800049ca <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	188080e7          	jalr	392(ra) # 80000ae2 <kalloc>
    80004962:	892a                	mv	s2,a0
    80004964:	c125                	beqz	a0,800049c4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004966:	4985                	li	s3,1
    80004968:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000496c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004970:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004974:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004978:	00004597          	auipc	a1,0x4
    8000497c:	d8058593          	addi	a1,a1,-640 # 800086f8 <syscalls+0x2a8>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	1c2080e7          	jalr	450(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004988:	609c                	ld	a5,0(s1)
    8000498a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000498e:	609c                	ld	a5,0(s1)
    80004990:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004994:	609c                	ld	a5,0(s1)
    80004996:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000499a:	609c                	ld	a5,0(s1)
    8000499c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049a0:	000a3783          	ld	a5,0(s4)
    800049a4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049a8:	000a3783          	ld	a5,0(s4)
    800049ac:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049b0:	000a3783          	ld	a5,0(s4)
    800049b4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049b8:	000a3783          	ld	a5,0(s4)
    800049bc:	0127b823          	sd	s2,16(a5)
  return 0;
    800049c0:	4501                	li	a0,0
    800049c2:	a025                	j	800049ea <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049c4:	6088                	ld	a0,0(s1)
    800049c6:	e501                	bnez	a0,800049ce <pipealloc+0xaa>
    800049c8:	a039                	j	800049d6 <pipealloc+0xb2>
    800049ca:	6088                	ld	a0,0(s1)
    800049cc:	c51d                	beqz	a0,800049fa <pipealloc+0xd6>
    fileclose(*f0);
    800049ce:	00000097          	auipc	ra,0x0
    800049d2:	c2a080e7          	jalr	-982(ra) # 800045f8 <fileclose>
  if(*f1)
    800049d6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049da:	557d                	li	a0,-1
  if(*f1)
    800049dc:	c799                	beqz	a5,800049ea <pipealloc+0xc6>
    fileclose(*f1);
    800049de:	853e                	mv	a0,a5
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	c18080e7          	jalr	-1000(ra) # 800045f8 <fileclose>
  return -1;
    800049e8:	557d                	li	a0,-1
}
    800049ea:	70a2                	ld	ra,40(sp)
    800049ec:	7402                	ld	s0,32(sp)
    800049ee:	64e2                	ld	s1,24(sp)
    800049f0:	6942                	ld	s2,16(sp)
    800049f2:	69a2                	ld	s3,8(sp)
    800049f4:	6a02                	ld	s4,0(sp)
    800049f6:	6145                	addi	sp,sp,48
    800049f8:	8082                	ret
  return -1;
    800049fa:	557d                	li	a0,-1
    800049fc:	b7fd                	j	800049ea <pipealloc+0xc6>

00000000800049fe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049fe:	1101                	addi	sp,sp,-32
    80004a00:	ec06                	sd	ra,24(sp)
    80004a02:	e822                	sd	s0,16(sp)
    80004a04:	e426                	sd	s1,8(sp)
    80004a06:	e04a                	sd	s2,0(sp)
    80004a08:	1000                	addi	s0,sp,32
    80004a0a:	84aa                	mv	s1,a0
    80004a0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	1c4080e7          	jalr	452(ra) # 80000bd2 <acquire>
  if(writable){
    80004a16:	02090d63          	beqz	s2,80004a50 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a1a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a1e:	21848513          	addi	a0,s1,536
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	710080e7          	jalr	1808(ra) # 80002132 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a2a:	2204b783          	ld	a5,544(s1)
    80004a2e:	eb95                	bnez	a5,80004a62 <pipeclose+0x64>
    release(&pi->lock);
    80004a30:	8526                	mv	a0,s1
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	254080e7          	jalr	596(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	fa8080e7          	jalr	-88(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a44:	60e2                	ld	ra,24(sp)
    80004a46:	6442                	ld	s0,16(sp)
    80004a48:	64a2                	ld	s1,8(sp)
    80004a4a:	6902                	ld	s2,0(sp)
    80004a4c:	6105                	addi	sp,sp,32
    80004a4e:	8082                	ret
    pi->readopen = 0;
    80004a50:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a54:	21c48513          	addi	a0,s1,540
    80004a58:	ffffd097          	auipc	ra,0xffffd
    80004a5c:	6da080e7          	jalr	1754(ra) # 80002132 <wakeup>
    80004a60:	b7e9                	j	80004a2a <pipeclose+0x2c>
    release(&pi->lock);
    80004a62:	8526                	mv	a0,s1
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	222080e7          	jalr	546(ra) # 80000c86 <release>
}
    80004a6c:	bfe1                	j	80004a44 <pipeclose+0x46>

0000000080004a6e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a6e:	711d                	addi	sp,sp,-96
    80004a70:	ec86                	sd	ra,88(sp)
    80004a72:	e8a2                	sd	s0,80(sp)
    80004a74:	e4a6                	sd	s1,72(sp)
    80004a76:	e0ca                	sd	s2,64(sp)
    80004a78:	fc4e                	sd	s3,56(sp)
    80004a7a:	f852                	sd	s4,48(sp)
    80004a7c:	f456                	sd	s5,40(sp)
    80004a7e:	f05a                	sd	s6,32(sp)
    80004a80:	ec5e                	sd	s7,24(sp)
    80004a82:	e862                	sd	s8,16(sp)
    80004a84:	1080                	addi	s0,sp,96
    80004a86:	84aa                	mv	s1,a0
    80004a88:	8aae                	mv	s5,a1
    80004a8a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a8c:	ffffd097          	auipc	ra,0xffffd
    80004a90:	f1a080e7          	jalr	-230(ra) # 800019a6 <myproc>
    80004a94:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a96:	8526                	mv	a0,s1
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	13a080e7          	jalr	314(ra) # 80000bd2 <acquire>
  while(i < n){
    80004aa0:	0b405663          	blez	s4,80004b4c <pipewrite+0xde>
  int i = 0;
    80004aa4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aa6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004aa8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aac:	21c48b93          	addi	s7,s1,540
    80004ab0:	a089                	j	80004af2 <pipewrite+0x84>
      release(&pi->lock);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	1d2080e7          	jalr	466(ra) # 80000c86 <release>
      return -1;
    80004abc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004abe:	854a                	mv	a0,s2
    80004ac0:	60e6                	ld	ra,88(sp)
    80004ac2:	6446                	ld	s0,80(sp)
    80004ac4:	64a6                	ld	s1,72(sp)
    80004ac6:	6906                	ld	s2,64(sp)
    80004ac8:	79e2                	ld	s3,56(sp)
    80004aca:	7a42                	ld	s4,48(sp)
    80004acc:	7aa2                	ld	s5,40(sp)
    80004ace:	7b02                	ld	s6,32(sp)
    80004ad0:	6be2                	ld	s7,24(sp)
    80004ad2:	6c42                	ld	s8,16(sp)
    80004ad4:	6125                	addi	sp,sp,96
    80004ad6:	8082                	ret
      wakeup(&pi->nread);
    80004ad8:	8562                	mv	a0,s8
    80004ada:	ffffd097          	auipc	ra,0xffffd
    80004ade:	658080e7          	jalr	1624(ra) # 80002132 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ae2:	85a6                	mv	a1,s1
    80004ae4:	855e                	mv	a0,s7
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	5e8080e7          	jalr	1512(ra) # 800020ce <sleep>
  while(i < n){
    80004aee:	07495063          	bge	s2,s4,80004b4e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004af2:	2204a783          	lw	a5,544(s1)
    80004af6:	dfd5                	beqz	a5,80004ab2 <pipewrite+0x44>
    80004af8:	854e                	mv	a0,s3
    80004afa:	ffffe097          	auipc	ra,0xffffe
    80004afe:	87c080e7          	jalr	-1924(ra) # 80002376 <killed>
    80004b02:	f945                	bnez	a0,80004ab2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b04:	2184a783          	lw	a5,536(s1)
    80004b08:	21c4a703          	lw	a4,540(s1)
    80004b0c:	2007879b          	addiw	a5,a5,512
    80004b10:	fcf704e3          	beq	a4,a5,80004ad8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b14:	4685                	li	a3,1
    80004b16:	01590633          	add	a2,s2,s5
    80004b1a:	faf40593          	addi	a1,s0,-81
    80004b1e:	0509b503          	ld	a0,80(s3)
    80004b22:	ffffd097          	auipc	ra,0xffffd
    80004b26:	bd0080e7          	jalr	-1072(ra) # 800016f2 <copyin>
    80004b2a:	03650263          	beq	a0,s6,80004b4e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b2e:	21c4a783          	lw	a5,540(s1)
    80004b32:	0017871b          	addiw	a4,a5,1
    80004b36:	20e4ae23          	sw	a4,540(s1)
    80004b3a:	1ff7f793          	andi	a5,a5,511
    80004b3e:	97a6                	add	a5,a5,s1
    80004b40:	faf44703          	lbu	a4,-81(s0)
    80004b44:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b48:	2905                	addiw	s2,s2,1
    80004b4a:	b755                	j	80004aee <pipewrite+0x80>
  int i = 0;
    80004b4c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b4e:	21848513          	addi	a0,s1,536
    80004b52:	ffffd097          	auipc	ra,0xffffd
    80004b56:	5e0080e7          	jalr	1504(ra) # 80002132 <wakeup>
  release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	12a080e7          	jalr	298(ra) # 80000c86 <release>
  return i;
    80004b64:	bfa9                	j	80004abe <pipewrite+0x50>

0000000080004b66 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b66:	715d                	addi	sp,sp,-80
    80004b68:	e486                	sd	ra,72(sp)
    80004b6a:	e0a2                	sd	s0,64(sp)
    80004b6c:	fc26                	sd	s1,56(sp)
    80004b6e:	f84a                	sd	s2,48(sp)
    80004b70:	f44e                	sd	s3,40(sp)
    80004b72:	f052                	sd	s4,32(sp)
    80004b74:	ec56                	sd	s5,24(sp)
    80004b76:	e85a                	sd	s6,16(sp)
    80004b78:	0880                	addi	s0,sp,80
    80004b7a:	84aa                	mv	s1,a0
    80004b7c:	892e                	mv	s2,a1
    80004b7e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b80:	ffffd097          	auipc	ra,0xffffd
    80004b84:	e26080e7          	jalr	-474(ra) # 800019a6 <myproc>
    80004b88:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	046080e7          	jalr	70(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b94:	2184a703          	lw	a4,536(s1)
    80004b98:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b9c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ba0:	02f71763          	bne	a4,a5,80004bce <piperead+0x68>
    80004ba4:	2244a783          	lw	a5,548(s1)
    80004ba8:	c39d                	beqz	a5,80004bce <piperead+0x68>
    if(killed(pr)){
    80004baa:	8552                	mv	a0,s4
    80004bac:	ffffd097          	auipc	ra,0xffffd
    80004bb0:	7ca080e7          	jalr	1994(ra) # 80002376 <killed>
    80004bb4:	e949                	bnez	a0,80004c46 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bb6:	85a6                	mv	a1,s1
    80004bb8:	854e                	mv	a0,s3
    80004bba:	ffffd097          	auipc	ra,0xffffd
    80004bbe:	514080e7          	jalr	1300(ra) # 800020ce <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bc2:	2184a703          	lw	a4,536(s1)
    80004bc6:	21c4a783          	lw	a5,540(s1)
    80004bca:	fcf70de3          	beq	a4,a5,80004ba4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bce:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bd0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bd2:	05505463          	blez	s5,80004c1a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bd6:	2184a783          	lw	a5,536(s1)
    80004bda:	21c4a703          	lw	a4,540(s1)
    80004bde:	02f70e63          	beq	a4,a5,80004c1a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004be2:	0017871b          	addiw	a4,a5,1
    80004be6:	20e4ac23          	sw	a4,536(s1)
    80004bea:	1ff7f793          	andi	a5,a5,511
    80004bee:	97a6                	add	a5,a5,s1
    80004bf0:	0187c783          	lbu	a5,24(a5)
    80004bf4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bf8:	4685                	li	a3,1
    80004bfa:	fbf40613          	addi	a2,s0,-65
    80004bfe:	85ca                	mv	a1,s2
    80004c00:	050a3503          	ld	a0,80(s4)
    80004c04:	ffffd097          	auipc	ra,0xffffd
    80004c08:	a62080e7          	jalr	-1438(ra) # 80001666 <copyout>
    80004c0c:	01650763          	beq	a0,s6,80004c1a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c10:	2985                	addiw	s3,s3,1
    80004c12:	0905                	addi	s2,s2,1
    80004c14:	fd3a91e3          	bne	s5,s3,80004bd6 <piperead+0x70>
    80004c18:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c1a:	21c48513          	addi	a0,s1,540
    80004c1e:	ffffd097          	auipc	ra,0xffffd
    80004c22:	514080e7          	jalr	1300(ra) # 80002132 <wakeup>
  release(&pi->lock);
    80004c26:	8526                	mv	a0,s1
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	05e080e7          	jalr	94(ra) # 80000c86 <release>
  return i;
}
    80004c30:	854e                	mv	a0,s3
    80004c32:	60a6                	ld	ra,72(sp)
    80004c34:	6406                	ld	s0,64(sp)
    80004c36:	74e2                	ld	s1,56(sp)
    80004c38:	7942                	ld	s2,48(sp)
    80004c3a:	79a2                	ld	s3,40(sp)
    80004c3c:	7a02                	ld	s4,32(sp)
    80004c3e:	6ae2                	ld	s5,24(sp)
    80004c40:	6b42                	ld	s6,16(sp)
    80004c42:	6161                	addi	sp,sp,80
    80004c44:	8082                	ret
      release(&pi->lock);
    80004c46:	8526                	mv	a0,s1
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	03e080e7          	jalr	62(ra) # 80000c86 <release>
      return -1;
    80004c50:	59fd                	li	s3,-1
    80004c52:	bff9                	j	80004c30 <piperead+0xca>

0000000080004c54 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c54:	1141                	addi	sp,sp,-16
    80004c56:	e422                	sd	s0,8(sp)
    80004c58:	0800                	addi	s0,sp,16
    80004c5a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c5c:	8905                	andi	a0,a0,1
    80004c5e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c60:	8b89                	andi	a5,a5,2
    80004c62:	c399                	beqz	a5,80004c68 <flags2perm+0x14>
      perm |= PTE_W;
    80004c64:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c68:	6422                	ld	s0,8(sp)
    80004c6a:	0141                	addi	sp,sp,16
    80004c6c:	8082                	ret

0000000080004c6e <exec>:

int
exec(char *path, char **argv)
{
    80004c6e:	df010113          	addi	sp,sp,-528
    80004c72:	20113423          	sd	ra,520(sp)
    80004c76:	20813023          	sd	s0,512(sp)
    80004c7a:	ffa6                	sd	s1,504(sp)
    80004c7c:	fbca                	sd	s2,496(sp)
    80004c7e:	f7ce                	sd	s3,488(sp)
    80004c80:	f3d2                	sd	s4,480(sp)
    80004c82:	efd6                	sd	s5,472(sp)
    80004c84:	ebda                	sd	s6,464(sp)
    80004c86:	e7de                	sd	s7,456(sp)
    80004c88:	e3e2                	sd	s8,448(sp)
    80004c8a:	ff66                	sd	s9,440(sp)
    80004c8c:	fb6a                	sd	s10,432(sp)
    80004c8e:	f76e                	sd	s11,424(sp)
    80004c90:	0c00                	addi	s0,sp,528
    80004c92:	892a                	mv	s2,a0
    80004c94:	dea43c23          	sd	a0,-520(s0)
    80004c98:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	d0a080e7          	jalr	-758(ra) # 800019a6 <myproc>
    80004ca4:	84aa                	mv	s1,a0

  begin_op();
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	48e080e7          	jalr	1166(ra) # 80004134 <begin_op>

  if((ip = namei(path)) == 0){
    80004cae:	854a                	mv	a0,s2
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	284080e7          	jalr	644(ra) # 80003f34 <namei>
    80004cb8:	c92d                	beqz	a0,80004d2a <exec+0xbc>
    80004cba:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cbc:	fffff097          	auipc	ra,0xfffff
    80004cc0:	ad2080e7          	jalr	-1326(ra) # 8000378e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cc4:	04000713          	li	a4,64
    80004cc8:	4681                	li	a3,0
    80004cca:	e5040613          	addi	a2,s0,-432
    80004cce:	4581                	li	a1,0
    80004cd0:	8552                	mv	a0,s4
    80004cd2:	fffff097          	auipc	ra,0xfffff
    80004cd6:	d70080e7          	jalr	-656(ra) # 80003a42 <readi>
    80004cda:	04000793          	li	a5,64
    80004cde:	00f51a63          	bne	a0,a5,80004cf2 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ce2:	e5042703          	lw	a4,-432(s0)
    80004ce6:	464c47b7          	lui	a5,0x464c4
    80004cea:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cee:	04f70463          	beq	a4,a5,80004d36 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cf2:	8552                	mv	a0,s4
    80004cf4:	fffff097          	auipc	ra,0xfffff
    80004cf8:	cfc080e7          	jalr	-772(ra) # 800039f0 <iunlockput>
    end_op();
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	4b2080e7          	jalr	1202(ra) # 800041ae <end_op>
  }
  return -1;
    80004d04:	557d                	li	a0,-1
}
    80004d06:	20813083          	ld	ra,520(sp)
    80004d0a:	20013403          	ld	s0,512(sp)
    80004d0e:	74fe                	ld	s1,504(sp)
    80004d10:	795e                	ld	s2,496(sp)
    80004d12:	79be                	ld	s3,488(sp)
    80004d14:	7a1e                	ld	s4,480(sp)
    80004d16:	6afe                	ld	s5,472(sp)
    80004d18:	6b5e                	ld	s6,464(sp)
    80004d1a:	6bbe                	ld	s7,456(sp)
    80004d1c:	6c1e                	ld	s8,448(sp)
    80004d1e:	7cfa                	ld	s9,440(sp)
    80004d20:	7d5a                	ld	s10,432(sp)
    80004d22:	7dba                	ld	s11,424(sp)
    80004d24:	21010113          	addi	sp,sp,528
    80004d28:	8082                	ret
    end_op();
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	484080e7          	jalr	1156(ra) # 800041ae <end_op>
    return -1;
    80004d32:	557d                	li	a0,-1
    80004d34:	bfc9                	j	80004d06 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	d32080e7          	jalr	-718(ra) # 80001a6a <proc_pagetable>
    80004d40:	8b2a                	mv	s6,a0
    80004d42:	d945                	beqz	a0,80004cf2 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d44:	e7042d03          	lw	s10,-400(s0)
    80004d48:	e8845783          	lhu	a5,-376(s0)
    80004d4c:	10078463          	beqz	a5,80004e54 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d50:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d52:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d54:	6c85                	lui	s9,0x1
    80004d56:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d5a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d5e:	6a85                	lui	s5,0x1
    80004d60:	a0b5                	j	80004dcc <exec+0x15e>
      panic("loadseg: address should exist");
    80004d62:	00004517          	auipc	a0,0x4
    80004d66:	99e50513          	addi	a0,a0,-1634 # 80008700 <syscalls+0x2b0>
    80004d6a:	ffffb097          	auipc	ra,0xffffb
    80004d6e:	7d2080e7          	jalr	2002(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004d72:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d74:	8726                	mv	a4,s1
    80004d76:	012c06bb          	addw	a3,s8,s2
    80004d7a:	4581                	li	a1,0
    80004d7c:	8552                	mv	a0,s4
    80004d7e:	fffff097          	auipc	ra,0xfffff
    80004d82:	cc4080e7          	jalr	-828(ra) # 80003a42 <readi>
    80004d86:	2501                	sext.w	a0,a0
    80004d88:	24a49863          	bne	s1,a0,80004fd8 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004d8c:	012a893b          	addw	s2,s5,s2
    80004d90:	03397563          	bgeu	s2,s3,80004dba <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004d94:	02091593          	slli	a1,s2,0x20
    80004d98:	9181                	srli	a1,a1,0x20
    80004d9a:	95de                	add	a1,a1,s7
    80004d9c:	855a                	mv	a0,s6
    80004d9e:	ffffc097          	auipc	ra,0xffffc
    80004da2:	2b8080e7          	jalr	696(ra) # 80001056 <walkaddr>
    80004da6:	862a                	mv	a2,a0
    if(pa == 0)
    80004da8:	dd4d                	beqz	a0,80004d62 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004daa:	412984bb          	subw	s1,s3,s2
    80004dae:	0004879b          	sext.w	a5,s1
    80004db2:	fcfcf0e3          	bgeu	s9,a5,80004d72 <exec+0x104>
    80004db6:	84d6                	mv	s1,s5
    80004db8:	bf6d                	j	80004d72 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dba:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dbe:	2d85                	addiw	s11,s11,1
    80004dc0:	038d0d1b          	addiw	s10,s10,56
    80004dc4:	e8845783          	lhu	a5,-376(s0)
    80004dc8:	08fdd763          	bge	s11,a5,80004e56 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dcc:	2d01                	sext.w	s10,s10
    80004dce:	03800713          	li	a4,56
    80004dd2:	86ea                	mv	a3,s10
    80004dd4:	e1840613          	addi	a2,s0,-488
    80004dd8:	4581                	li	a1,0
    80004dda:	8552                	mv	a0,s4
    80004ddc:	fffff097          	auipc	ra,0xfffff
    80004de0:	c66080e7          	jalr	-922(ra) # 80003a42 <readi>
    80004de4:	03800793          	li	a5,56
    80004de8:	1ef51663          	bne	a0,a5,80004fd4 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004dec:	e1842783          	lw	a5,-488(s0)
    80004df0:	4705                	li	a4,1
    80004df2:	fce796e3          	bne	a5,a4,80004dbe <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004df6:	e4043483          	ld	s1,-448(s0)
    80004dfa:	e3843783          	ld	a5,-456(s0)
    80004dfe:	1ef4e863          	bltu	s1,a5,80004fee <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e02:	e2843783          	ld	a5,-472(s0)
    80004e06:	94be                	add	s1,s1,a5
    80004e08:	1ef4e663          	bltu	s1,a5,80004ff4 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004e0c:	df043703          	ld	a4,-528(s0)
    80004e10:	8ff9                	and	a5,a5,a4
    80004e12:	1e079463          	bnez	a5,80004ffa <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e16:	e1c42503          	lw	a0,-484(s0)
    80004e1a:	00000097          	auipc	ra,0x0
    80004e1e:	e3a080e7          	jalr	-454(ra) # 80004c54 <flags2perm>
    80004e22:	86aa                	mv	a3,a0
    80004e24:	8626                	mv	a2,s1
    80004e26:	85ca                	mv	a1,s2
    80004e28:	855a                	mv	a0,s6
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	5e0080e7          	jalr	1504(ra) # 8000140a <uvmalloc>
    80004e32:	e0a43423          	sd	a0,-504(s0)
    80004e36:	1c050563          	beqz	a0,80005000 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e3a:	e2843b83          	ld	s7,-472(s0)
    80004e3e:	e2042c03          	lw	s8,-480(s0)
    80004e42:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e46:	00098463          	beqz	s3,80004e4e <exec+0x1e0>
    80004e4a:	4901                	li	s2,0
    80004e4c:	b7a1                	j	80004d94 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e4e:	e0843903          	ld	s2,-504(s0)
    80004e52:	b7b5                	j	80004dbe <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e54:	4901                	li	s2,0
  iunlockput(ip);
    80004e56:	8552                	mv	a0,s4
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	b98080e7          	jalr	-1128(ra) # 800039f0 <iunlockput>
  end_op();
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	34e080e7          	jalr	846(ra) # 800041ae <end_op>
  p = myproc();
    80004e68:	ffffd097          	auipc	ra,0xffffd
    80004e6c:	b3e080e7          	jalr	-1218(ra) # 800019a6 <myproc>
    80004e70:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e72:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e76:	6985                	lui	s3,0x1
    80004e78:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e7a:	99ca                	add	s3,s3,s2
    80004e7c:	77fd                	lui	a5,0xfffff
    80004e7e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e82:	4691                	li	a3,4
    80004e84:	6609                	lui	a2,0x2
    80004e86:	964e                	add	a2,a2,s3
    80004e88:	85ce                	mv	a1,s3
    80004e8a:	855a                	mv	a0,s6
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	57e080e7          	jalr	1406(ra) # 8000140a <uvmalloc>
    80004e94:	892a                	mv	s2,a0
    80004e96:	e0a43423          	sd	a0,-504(s0)
    80004e9a:	e509                	bnez	a0,80004ea4 <exec+0x236>
  if(pagetable)
    80004e9c:	e1343423          	sd	s3,-504(s0)
    80004ea0:	4a01                	li	s4,0
    80004ea2:	aa1d                	j	80004fd8 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ea4:	75f9                	lui	a1,0xffffe
    80004ea6:	95aa                	add	a1,a1,a0
    80004ea8:	855a                	mv	a0,s6
    80004eaa:	ffffc097          	auipc	ra,0xffffc
    80004eae:	78a080e7          	jalr	1930(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004eb2:	7bfd                	lui	s7,0xfffff
    80004eb4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004eb6:	e0043783          	ld	a5,-512(s0)
    80004eba:	6388                	ld	a0,0(a5)
    80004ebc:	c52d                	beqz	a0,80004f26 <exec+0x2b8>
    80004ebe:	e9040993          	addi	s3,s0,-368
    80004ec2:	f9040c13          	addi	s8,s0,-112
    80004ec6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ec8:	ffffc097          	auipc	ra,0xffffc
    80004ecc:	f80080e7          	jalr	-128(ra) # 80000e48 <strlen>
    80004ed0:	0015079b          	addiw	a5,a0,1
    80004ed4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ed8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004edc:	13796563          	bltu	s2,s7,80005006 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ee0:	e0043d03          	ld	s10,-512(s0)
    80004ee4:	000d3a03          	ld	s4,0(s10)
    80004ee8:	8552                	mv	a0,s4
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	f5e080e7          	jalr	-162(ra) # 80000e48 <strlen>
    80004ef2:	0015069b          	addiw	a3,a0,1
    80004ef6:	8652                	mv	a2,s4
    80004ef8:	85ca                	mv	a1,s2
    80004efa:	855a                	mv	a0,s6
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	76a080e7          	jalr	1898(ra) # 80001666 <copyout>
    80004f04:	10054363          	bltz	a0,8000500a <exec+0x39c>
    ustack[argc] = sp;
    80004f08:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f0c:	0485                	addi	s1,s1,1
    80004f0e:	008d0793          	addi	a5,s10,8
    80004f12:	e0f43023          	sd	a5,-512(s0)
    80004f16:	008d3503          	ld	a0,8(s10)
    80004f1a:	c909                	beqz	a0,80004f2c <exec+0x2be>
    if(argc >= MAXARG)
    80004f1c:	09a1                	addi	s3,s3,8
    80004f1e:	fb8995e3          	bne	s3,s8,80004ec8 <exec+0x25a>
  ip = 0;
    80004f22:	4a01                	li	s4,0
    80004f24:	a855                	j	80004fd8 <exec+0x36a>
  sp = sz;
    80004f26:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f2a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f2c:	00349793          	slli	a5,s1,0x3
    80004f30:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd1f0>
    80004f34:	97a2                	add	a5,a5,s0
    80004f36:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f3a:	00148693          	addi	a3,s1,1
    80004f3e:	068e                	slli	a3,a3,0x3
    80004f40:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f44:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f48:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f4c:	f57968e3          	bltu	s2,s7,80004e9c <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f50:	e9040613          	addi	a2,s0,-368
    80004f54:	85ca                	mv	a1,s2
    80004f56:	855a                	mv	a0,s6
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	70e080e7          	jalr	1806(ra) # 80001666 <copyout>
    80004f60:	0a054763          	bltz	a0,8000500e <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004f64:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f68:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f6c:	df843783          	ld	a5,-520(s0)
    80004f70:	0007c703          	lbu	a4,0(a5)
    80004f74:	cf11                	beqz	a4,80004f90 <exec+0x322>
    80004f76:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f78:	02f00693          	li	a3,47
    80004f7c:	a039                	j	80004f8a <exec+0x31c>
      last = s+1;
    80004f7e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f82:	0785                	addi	a5,a5,1
    80004f84:	fff7c703          	lbu	a4,-1(a5)
    80004f88:	c701                	beqz	a4,80004f90 <exec+0x322>
    if(*s == '/')
    80004f8a:	fed71ce3          	bne	a4,a3,80004f82 <exec+0x314>
    80004f8e:	bfc5                	j	80004f7e <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f90:	4641                	li	a2,16
    80004f92:	df843583          	ld	a1,-520(s0)
    80004f96:	158a8513          	addi	a0,s5,344
    80004f9a:	ffffc097          	auipc	ra,0xffffc
    80004f9e:	e7c080e7          	jalr	-388(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fa2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004fa6:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004faa:	e0843783          	ld	a5,-504(s0)
    80004fae:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fb2:	058ab783          	ld	a5,88(s5)
    80004fb6:	e6843703          	ld	a4,-408(s0)
    80004fba:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fbc:	058ab783          	ld	a5,88(s5)
    80004fc0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fc4:	85e6                	mv	a1,s9
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	b40080e7          	jalr	-1216(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fce:	0004851b          	sext.w	a0,s1
    80004fd2:	bb15                	j	80004d06 <exec+0x98>
    80004fd4:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fd8:	e0843583          	ld	a1,-504(s0)
    80004fdc:	855a                	mv	a0,s6
    80004fde:	ffffd097          	auipc	ra,0xffffd
    80004fe2:	b28080e7          	jalr	-1240(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80004fe6:	557d                	li	a0,-1
  if(ip){
    80004fe8:	d00a0fe3          	beqz	s4,80004d06 <exec+0x98>
    80004fec:	b319                	j	80004cf2 <exec+0x84>
    80004fee:	e1243423          	sd	s2,-504(s0)
    80004ff2:	b7dd                	j	80004fd8 <exec+0x36a>
    80004ff4:	e1243423          	sd	s2,-504(s0)
    80004ff8:	b7c5                	j	80004fd8 <exec+0x36a>
    80004ffa:	e1243423          	sd	s2,-504(s0)
    80004ffe:	bfe9                	j	80004fd8 <exec+0x36a>
    80005000:	e1243423          	sd	s2,-504(s0)
    80005004:	bfd1                	j	80004fd8 <exec+0x36a>
  ip = 0;
    80005006:	4a01                	li	s4,0
    80005008:	bfc1                	j	80004fd8 <exec+0x36a>
    8000500a:	4a01                	li	s4,0
  if(pagetable)
    8000500c:	b7f1                	j	80004fd8 <exec+0x36a>
  sz = sz1;
    8000500e:	e0843983          	ld	s3,-504(s0)
    80005012:	b569                	j	80004e9c <exec+0x22e>

0000000080005014 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005014:	7179                	addi	sp,sp,-48
    80005016:	f406                	sd	ra,40(sp)
    80005018:	f022                	sd	s0,32(sp)
    8000501a:	ec26                	sd	s1,24(sp)
    8000501c:	e84a                	sd	s2,16(sp)
    8000501e:	1800                	addi	s0,sp,48
    80005020:	892e                	mv	s2,a1
    80005022:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005024:	fdc40593          	addi	a1,s0,-36
    80005028:	ffffe097          	auipc	ra,0xffffe
    8000502c:	b18080e7          	jalr	-1256(ra) # 80002b40 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005030:	fdc42703          	lw	a4,-36(s0)
    80005034:	47bd                	li	a5,15
    80005036:	02e7eb63          	bltu	a5,a4,8000506c <argfd+0x58>
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	96c080e7          	jalr	-1684(ra) # 800019a6 <myproc>
    80005042:	fdc42703          	lw	a4,-36(s0)
    80005046:	01a70793          	addi	a5,a4,26
    8000504a:	078e                	slli	a5,a5,0x3
    8000504c:	953e                	add	a0,a0,a5
    8000504e:	611c                	ld	a5,0(a0)
    80005050:	c385                	beqz	a5,80005070 <argfd+0x5c>
    return -1;
  if(pfd)
    80005052:	00090463          	beqz	s2,8000505a <argfd+0x46>
    *pfd = fd;
    80005056:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000505a:	4501                	li	a0,0
  if(pf)
    8000505c:	c091                	beqz	s1,80005060 <argfd+0x4c>
    *pf = f;
    8000505e:	e09c                	sd	a5,0(s1)
}
    80005060:	70a2                	ld	ra,40(sp)
    80005062:	7402                	ld	s0,32(sp)
    80005064:	64e2                	ld	s1,24(sp)
    80005066:	6942                	ld	s2,16(sp)
    80005068:	6145                	addi	sp,sp,48
    8000506a:	8082                	ret
    return -1;
    8000506c:	557d                	li	a0,-1
    8000506e:	bfcd                	j	80005060 <argfd+0x4c>
    80005070:	557d                	li	a0,-1
    80005072:	b7fd                	j	80005060 <argfd+0x4c>

0000000080005074 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005074:	1101                	addi	sp,sp,-32
    80005076:	ec06                	sd	ra,24(sp)
    80005078:	e822                	sd	s0,16(sp)
    8000507a:	e426                	sd	s1,8(sp)
    8000507c:	1000                	addi	s0,sp,32
    8000507e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005080:	ffffd097          	auipc	ra,0xffffd
    80005084:	926080e7          	jalr	-1754(ra) # 800019a6 <myproc>
    80005088:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000508a:	0d050793          	addi	a5,a0,208
    8000508e:	4501                	li	a0,0
    80005090:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005092:	6398                	ld	a4,0(a5)
    80005094:	cb19                	beqz	a4,800050aa <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005096:	2505                	addiw	a0,a0,1
    80005098:	07a1                	addi	a5,a5,8
    8000509a:	fed51ce3          	bne	a0,a3,80005092 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000509e:	557d                	li	a0,-1
}
    800050a0:	60e2                	ld	ra,24(sp)
    800050a2:	6442                	ld	s0,16(sp)
    800050a4:	64a2                	ld	s1,8(sp)
    800050a6:	6105                	addi	sp,sp,32
    800050a8:	8082                	ret
      p->ofile[fd] = f;
    800050aa:	01a50793          	addi	a5,a0,26
    800050ae:	078e                	slli	a5,a5,0x3
    800050b0:	963e                	add	a2,a2,a5
    800050b2:	e204                	sd	s1,0(a2)
      return fd;
    800050b4:	b7f5                	j	800050a0 <fdalloc+0x2c>

00000000800050b6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050b6:	715d                	addi	sp,sp,-80
    800050b8:	e486                	sd	ra,72(sp)
    800050ba:	e0a2                	sd	s0,64(sp)
    800050bc:	fc26                	sd	s1,56(sp)
    800050be:	f84a                	sd	s2,48(sp)
    800050c0:	f44e                	sd	s3,40(sp)
    800050c2:	f052                	sd	s4,32(sp)
    800050c4:	ec56                	sd	s5,24(sp)
    800050c6:	e85a                	sd	s6,16(sp)
    800050c8:	0880                	addi	s0,sp,80
    800050ca:	8b2e                	mv	s6,a1
    800050cc:	89b2                	mv	s3,a2
    800050ce:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050d0:	fb040593          	addi	a1,s0,-80
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	e7e080e7          	jalr	-386(ra) # 80003f52 <nameiparent>
    800050dc:	84aa                	mv	s1,a0
    800050de:	14050b63          	beqz	a0,80005234 <create+0x17e>
    return 0;

  ilock(dp);
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	6ac080e7          	jalr	1708(ra) # 8000378e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050ea:	4601                	li	a2,0
    800050ec:	fb040593          	addi	a1,s0,-80
    800050f0:	8526                	mv	a0,s1
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	b80080e7          	jalr	-1152(ra) # 80003c72 <dirlookup>
    800050fa:	8aaa                	mv	s5,a0
    800050fc:	c921                	beqz	a0,8000514c <create+0x96>
    iunlockput(dp);
    800050fe:	8526                	mv	a0,s1
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	8f0080e7          	jalr	-1808(ra) # 800039f0 <iunlockput>
    ilock(ip);
    80005108:	8556                	mv	a0,s5
    8000510a:	ffffe097          	auipc	ra,0xffffe
    8000510e:	684080e7          	jalr	1668(ra) # 8000378e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005112:	4789                	li	a5,2
    80005114:	02fb1563          	bne	s6,a5,8000513e <create+0x88>
    80005118:	044ad783          	lhu	a5,68(s5)
    8000511c:	37f9                	addiw	a5,a5,-2
    8000511e:	17c2                	slli	a5,a5,0x30
    80005120:	93c1                	srli	a5,a5,0x30
    80005122:	4705                	li	a4,1
    80005124:	00f76d63          	bltu	a4,a5,8000513e <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005128:	8556                	mv	a0,s5
    8000512a:	60a6                	ld	ra,72(sp)
    8000512c:	6406                	ld	s0,64(sp)
    8000512e:	74e2                	ld	s1,56(sp)
    80005130:	7942                	ld	s2,48(sp)
    80005132:	79a2                	ld	s3,40(sp)
    80005134:	7a02                	ld	s4,32(sp)
    80005136:	6ae2                	ld	s5,24(sp)
    80005138:	6b42                	ld	s6,16(sp)
    8000513a:	6161                	addi	sp,sp,80
    8000513c:	8082                	ret
    iunlockput(ip);
    8000513e:	8556                	mv	a0,s5
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	8b0080e7          	jalr	-1872(ra) # 800039f0 <iunlockput>
    return 0;
    80005148:	4a81                	li	s5,0
    8000514a:	bff9                	j	80005128 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000514c:	85da                	mv	a1,s6
    8000514e:	4088                	lw	a0,0(s1)
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	4a6080e7          	jalr	1190(ra) # 800035f6 <ialloc>
    80005158:	8a2a                	mv	s4,a0
    8000515a:	c529                	beqz	a0,800051a4 <create+0xee>
  ilock(ip);
    8000515c:	ffffe097          	auipc	ra,0xffffe
    80005160:	632080e7          	jalr	1586(ra) # 8000378e <ilock>
  ip->major = major;
    80005164:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005168:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000516c:	4905                	li	s2,1
    8000516e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005172:	8552                	mv	a0,s4
    80005174:	ffffe097          	auipc	ra,0xffffe
    80005178:	54e080e7          	jalr	1358(ra) # 800036c2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000517c:	032b0b63          	beq	s6,s2,800051b2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005180:	004a2603          	lw	a2,4(s4)
    80005184:	fb040593          	addi	a1,s0,-80
    80005188:	8526                	mv	a0,s1
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	cf8080e7          	jalr	-776(ra) # 80003e82 <dirlink>
    80005192:	06054f63          	bltz	a0,80005210 <create+0x15a>
  iunlockput(dp);
    80005196:	8526                	mv	a0,s1
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	858080e7          	jalr	-1960(ra) # 800039f0 <iunlockput>
  return ip;
    800051a0:	8ad2                	mv	s5,s4
    800051a2:	b759                	j	80005128 <create+0x72>
    iunlockput(dp);
    800051a4:	8526                	mv	a0,s1
    800051a6:	fffff097          	auipc	ra,0xfffff
    800051aa:	84a080e7          	jalr	-1974(ra) # 800039f0 <iunlockput>
    return 0;
    800051ae:	8ad2                	mv	s5,s4
    800051b0:	bfa5                	j	80005128 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051b2:	004a2603          	lw	a2,4(s4)
    800051b6:	00003597          	auipc	a1,0x3
    800051ba:	56a58593          	addi	a1,a1,1386 # 80008720 <syscalls+0x2d0>
    800051be:	8552                	mv	a0,s4
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	cc2080e7          	jalr	-830(ra) # 80003e82 <dirlink>
    800051c8:	04054463          	bltz	a0,80005210 <create+0x15a>
    800051cc:	40d0                	lw	a2,4(s1)
    800051ce:	00003597          	auipc	a1,0x3
    800051d2:	55a58593          	addi	a1,a1,1370 # 80008728 <syscalls+0x2d8>
    800051d6:	8552                	mv	a0,s4
    800051d8:	fffff097          	auipc	ra,0xfffff
    800051dc:	caa080e7          	jalr	-854(ra) # 80003e82 <dirlink>
    800051e0:	02054863          	bltz	a0,80005210 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051e4:	004a2603          	lw	a2,4(s4)
    800051e8:	fb040593          	addi	a1,s0,-80
    800051ec:	8526                	mv	a0,s1
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	c94080e7          	jalr	-876(ra) # 80003e82 <dirlink>
    800051f6:	00054d63          	bltz	a0,80005210 <create+0x15a>
    dp->nlink++;  // for ".."
    800051fa:	04a4d783          	lhu	a5,74(s1)
    800051fe:	2785                	addiw	a5,a5,1
    80005200:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005204:	8526                	mv	a0,s1
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	4bc080e7          	jalr	1212(ra) # 800036c2 <iupdate>
    8000520e:	b761                	j	80005196 <create+0xe0>
  ip->nlink = 0;
    80005210:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005214:	8552                	mv	a0,s4
    80005216:	ffffe097          	auipc	ra,0xffffe
    8000521a:	4ac080e7          	jalr	1196(ra) # 800036c2 <iupdate>
  iunlockput(ip);
    8000521e:	8552                	mv	a0,s4
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	7d0080e7          	jalr	2000(ra) # 800039f0 <iunlockput>
  iunlockput(dp);
    80005228:	8526                	mv	a0,s1
    8000522a:	ffffe097          	auipc	ra,0xffffe
    8000522e:	7c6080e7          	jalr	1990(ra) # 800039f0 <iunlockput>
  return 0;
    80005232:	bddd                	j	80005128 <create+0x72>
    return 0;
    80005234:	8aaa                	mv	s5,a0
    80005236:	bdcd                	j	80005128 <create+0x72>

0000000080005238 <sys_dup>:
{
    80005238:	7179                	addi	sp,sp,-48
    8000523a:	f406                	sd	ra,40(sp)
    8000523c:	f022                	sd	s0,32(sp)
    8000523e:	ec26                	sd	s1,24(sp)
    80005240:	e84a                	sd	s2,16(sp)
    80005242:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005244:	fd840613          	addi	a2,s0,-40
    80005248:	4581                	li	a1,0
    8000524a:	4501                	li	a0,0
    8000524c:	00000097          	auipc	ra,0x0
    80005250:	dc8080e7          	jalr	-568(ra) # 80005014 <argfd>
    return -1;
    80005254:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005256:	02054363          	bltz	a0,8000527c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000525a:	fd843903          	ld	s2,-40(s0)
    8000525e:	854a                	mv	a0,s2
    80005260:	00000097          	auipc	ra,0x0
    80005264:	e14080e7          	jalr	-492(ra) # 80005074 <fdalloc>
    80005268:	84aa                	mv	s1,a0
    return -1;
    8000526a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000526c:	00054863          	bltz	a0,8000527c <sys_dup+0x44>
  filedup(f);
    80005270:	854a                	mv	a0,s2
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	334080e7          	jalr	820(ra) # 800045a6 <filedup>
  return fd;
    8000527a:	87a6                	mv	a5,s1
}
    8000527c:	853e                	mv	a0,a5
    8000527e:	70a2                	ld	ra,40(sp)
    80005280:	7402                	ld	s0,32(sp)
    80005282:	64e2                	ld	s1,24(sp)
    80005284:	6942                	ld	s2,16(sp)
    80005286:	6145                	addi	sp,sp,48
    80005288:	8082                	ret

000000008000528a <sys_read>:
{
    8000528a:	7179                	addi	sp,sp,-48
    8000528c:	f406                	sd	ra,40(sp)
    8000528e:	f022                	sd	s0,32(sp)
    80005290:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005292:	fd840593          	addi	a1,s0,-40
    80005296:	4505                	li	a0,1
    80005298:	ffffe097          	auipc	ra,0xffffe
    8000529c:	8c8080e7          	jalr	-1848(ra) # 80002b60 <argaddr>
  argint(2, &n);
    800052a0:	fe440593          	addi	a1,s0,-28
    800052a4:	4509                	li	a0,2
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	89a080e7          	jalr	-1894(ra) # 80002b40 <argint>
  if(argfd(0, 0, &f) < 0)
    800052ae:	fe840613          	addi	a2,s0,-24
    800052b2:	4581                	li	a1,0
    800052b4:	4501                	li	a0,0
    800052b6:	00000097          	auipc	ra,0x0
    800052ba:	d5e080e7          	jalr	-674(ra) # 80005014 <argfd>
    800052be:	87aa                	mv	a5,a0
    return -1;
    800052c0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c2:	0007cc63          	bltz	a5,800052da <sys_read+0x50>
  return fileread(f, p, n);
    800052c6:	fe442603          	lw	a2,-28(s0)
    800052ca:	fd843583          	ld	a1,-40(s0)
    800052ce:	fe843503          	ld	a0,-24(s0)
    800052d2:	fffff097          	auipc	ra,0xfffff
    800052d6:	460080e7          	jalr	1120(ra) # 80004732 <fileread>
}
    800052da:	70a2                	ld	ra,40(sp)
    800052dc:	7402                	ld	s0,32(sp)
    800052de:	6145                	addi	sp,sp,48
    800052e0:	8082                	ret

00000000800052e2 <sys_write>:
{
    800052e2:	7179                	addi	sp,sp,-48
    800052e4:	f406                	sd	ra,40(sp)
    800052e6:	f022                	sd	s0,32(sp)
    800052e8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052ea:	fd840593          	addi	a1,s0,-40
    800052ee:	4505                	li	a0,1
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	870080e7          	jalr	-1936(ra) # 80002b60 <argaddr>
  argint(2, &n);
    800052f8:	fe440593          	addi	a1,s0,-28
    800052fc:	4509                	li	a0,2
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	842080e7          	jalr	-1982(ra) # 80002b40 <argint>
  if(argfd(0, 0, &f) < 0)
    80005306:	fe840613          	addi	a2,s0,-24
    8000530a:	4581                	li	a1,0
    8000530c:	4501                	li	a0,0
    8000530e:	00000097          	auipc	ra,0x0
    80005312:	d06080e7          	jalr	-762(ra) # 80005014 <argfd>
    80005316:	87aa                	mv	a5,a0
    return -1;
    80005318:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000531a:	0007cc63          	bltz	a5,80005332 <sys_write+0x50>
  return filewrite(f, p, n);
    8000531e:	fe442603          	lw	a2,-28(s0)
    80005322:	fd843583          	ld	a1,-40(s0)
    80005326:	fe843503          	ld	a0,-24(s0)
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	4ca080e7          	jalr	1226(ra) # 800047f4 <filewrite>
}
    80005332:	70a2                	ld	ra,40(sp)
    80005334:	7402                	ld	s0,32(sp)
    80005336:	6145                	addi	sp,sp,48
    80005338:	8082                	ret

000000008000533a <sys_close>:
{
    8000533a:	1101                	addi	sp,sp,-32
    8000533c:	ec06                	sd	ra,24(sp)
    8000533e:	e822                	sd	s0,16(sp)
    80005340:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005342:	fe040613          	addi	a2,s0,-32
    80005346:	fec40593          	addi	a1,s0,-20
    8000534a:	4501                	li	a0,0
    8000534c:	00000097          	auipc	ra,0x0
    80005350:	cc8080e7          	jalr	-824(ra) # 80005014 <argfd>
    return -1;
    80005354:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005356:	02054463          	bltz	a0,8000537e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000535a:	ffffc097          	auipc	ra,0xffffc
    8000535e:	64c080e7          	jalr	1612(ra) # 800019a6 <myproc>
    80005362:	fec42783          	lw	a5,-20(s0)
    80005366:	07e9                	addi	a5,a5,26
    80005368:	078e                	slli	a5,a5,0x3
    8000536a:	953e                	add	a0,a0,a5
    8000536c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005370:	fe043503          	ld	a0,-32(s0)
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	284080e7          	jalr	644(ra) # 800045f8 <fileclose>
  return 0;
    8000537c:	4781                	li	a5,0
}
    8000537e:	853e                	mv	a0,a5
    80005380:	60e2                	ld	ra,24(sp)
    80005382:	6442                	ld	s0,16(sp)
    80005384:	6105                	addi	sp,sp,32
    80005386:	8082                	ret

0000000080005388 <sys_fstat>:
{
    80005388:	1101                	addi	sp,sp,-32
    8000538a:	ec06                	sd	ra,24(sp)
    8000538c:	e822                	sd	s0,16(sp)
    8000538e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005390:	fe040593          	addi	a1,s0,-32
    80005394:	4505                	li	a0,1
    80005396:	ffffd097          	auipc	ra,0xffffd
    8000539a:	7ca080e7          	jalr	1994(ra) # 80002b60 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000539e:	fe840613          	addi	a2,s0,-24
    800053a2:	4581                	li	a1,0
    800053a4:	4501                	li	a0,0
    800053a6:	00000097          	auipc	ra,0x0
    800053aa:	c6e080e7          	jalr	-914(ra) # 80005014 <argfd>
    800053ae:	87aa                	mv	a5,a0
    return -1;
    800053b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053b2:	0007ca63          	bltz	a5,800053c6 <sys_fstat+0x3e>
  return filestat(f, st);
    800053b6:	fe043583          	ld	a1,-32(s0)
    800053ba:	fe843503          	ld	a0,-24(s0)
    800053be:	fffff097          	auipc	ra,0xfffff
    800053c2:	302080e7          	jalr	770(ra) # 800046c0 <filestat>
}
    800053c6:	60e2                	ld	ra,24(sp)
    800053c8:	6442                	ld	s0,16(sp)
    800053ca:	6105                	addi	sp,sp,32
    800053cc:	8082                	ret

00000000800053ce <sys_link>:
{
    800053ce:	7169                	addi	sp,sp,-304
    800053d0:	f606                	sd	ra,296(sp)
    800053d2:	f222                	sd	s0,288(sp)
    800053d4:	ee26                	sd	s1,280(sp)
    800053d6:	ea4a                	sd	s2,272(sp)
    800053d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053da:	08000613          	li	a2,128
    800053de:	ed040593          	addi	a1,s0,-304
    800053e2:	4501                	li	a0,0
    800053e4:	ffffd097          	auipc	ra,0xffffd
    800053e8:	79c080e7          	jalr	1948(ra) # 80002b80 <argstr>
    return -1;
    800053ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ee:	10054e63          	bltz	a0,8000550a <sys_link+0x13c>
    800053f2:	08000613          	li	a2,128
    800053f6:	f5040593          	addi	a1,s0,-176
    800053fa:	4505                	li	a0,1
    800053fc:	ffffd097          	auipc	ra,0xffffd
    80005400:	784080e7          	jalr	1924(ra) # 80002b80 <argstr>
    return -1;
    80005404:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005406:	10054263          	bltz	a0,8000550a <sys_link+0x13c>
  begin_op();
    8000540a:	fffff097          	auipc	ra,0xfffff
    8000540e:	d2a080e7          	jalr	-726(ra) # 80004134 <begin_op>
  if((ip = namei(old)) == 0){
    80005412:	ed040513          	addi	a0,s0,-304
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	b1e080e7          	jalr	-1250(ra) # 80003f34 <namei>
    8000541e:	84aa                	mv	s1,a0
    80005420:	c551                	beqz	a0,800054ac <sys_link+0xde>
  ilock(ip);
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	36c080e7          	jalr	876(ra) # 8000378e <ilock>
  if(ip->type == T_DIR){
    8000542a:	04449703          	lh	a4,68(s1)
    8000542e:	4785                	li	a5,1
    80005430:	08f70463          	beq	a4,a5,800054b8 <sys_link+0xea>
  ip->nlink++;
    80005434:	04a4d783          	lhu	a5,74(s1)
    80005438:	2785                	addiw	a5,a5,1
    8000543a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000543e:	8526                	mv	a0,s1
    80005440:	ffffe097          	auipc	ra,0xffffe
    80005444:	282080e7          	jalr	642(ra) # 800036c2 <iupdate>
  iunlock(ip);
    80005448:	8526                	mv	a0,s1
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	406080e7          	jalr	1030(ra) # 80003850 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005452:	fd040593          	addi	a1,s0,-48
    80005456:	f5040513          	addi	a0,s0,-176
    8000545a:	fffff097          	auipc	ra,0xfffff
    8000545e:	af8080e7          	jalr	-1288(ra) # 80003f52 <nameiparent>
    80005462:	892a                	mv	s2,a0
    80005464:	c935                	beqz	a0,800054d8 <sys_link+0x10a>
  ilock(dp);
    80005466:	ffffe097          	auipc	ra,0xffffe
    8000546a:	328080e7          	jalr	808(ra) # 8000378e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000546e:	00092703          	lw	a4,0(s2)
    80005472:	409c                	lw	a5,0(s1)
    80005474:	04f71d63          	bne	a4,a5,800054ce <sys_link+0x100>
    80005478:	40d0                	lw	a2,4(s1)
    8000547a:	fd040593          	addi	a1,s0,-48
    8000547e:	854a                	mv	a0,s2
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	a02080e7          	jalr	-1534(ra) # 80003e82 <dirlink>
    80005488:	04054363          	bltz	a0,800054ce <sys_link+0x100>
  iunlockput(dp);
    8000548c:	854a                	mv	a0,s2
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	562080e7          	jalr	1378(ra) # 800039f0 <iunlockput>
  iput(ip);
    80005496:	8526                	mv	a0,s1
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	4b0080e7          	jalr	1200(ra) # 80003948 <iput>
  end_op();
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	d0e080e7          	jalr	-754(ra) # 800041ae <end_op>
  return 0;
    800054a8:	4781                	li	a5,0
    800054aa:	a085                	j	8000550a <sys_link+0x13c>
    end_op();
    800054ac:	fffff097          	auipc	ra,0xfffff
    800054b0:	d02080e7          	jalr	-766(ra) # 800041ae <end_op>
    return -1;
    800054b4:	57fd                	li	a5,-1
    800054b6:	a891                	j	8000550a <sys_link+0x13c>
    iunlockput(ip);
    800054b8:	8526                	mv	a0,s1
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	536080e7          	jalr	1334(ra) # 800039f0 <iunlockput>
    end_op();
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	cec080e7          	jalr	-788(ra) # 800041ae <end_op>
    return -1;
    800054ca:	57fd                	li	a5,-1
    800054cc:	a83d                	j	8000550a <sys_link+0x13c>
    iunlockput(dp);
    800054ce:	854a                	mv	a0,s2
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	520080e7          	jalr	1312(ra) # 800039f0 <iunlockput>
  ilock(ip);
    800054d8:	8526                	mv	a0,s1
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	2b4080e7          	jalr	692(ra) # 8000378e <ilock>
  ip->nlink--;
    800054e2:	04a4d783          	lhu	a5,74(s1)
    800054e6:	37fd                	addiw	a5,a5,-1
    800054e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	1d4080e7          	jalr	468(ra) # 800036c2 <iupdate>
  iunlockput(ip);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	4f8080e7          	jalr	1272(ra) # 800039f0 <iunlockput>
  end_op();
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	cae080e7          	jalr	-850(ra) # 800041ae <end_op>
  return -1;
    80005508:	57fd                	li	a5,-1
}
    8000550a:	853e                	mv	a0,a5
    8000550c:	70b2                	ld	ra,296(sp)
    8000550e:	7412                	ld	s0,288(sp)
    80005510:	64f2                	ld	s1,280(sp)
    80005512:	6952                	ld	s2,272(sp)
    80005514:	6155                	addi	sp,sp,304
    80005516:	8082                	ret

0000000080005518 <sys_unlink>:
{
    80005518:	7151                	addi	sp,sp,-240
    8000551a:	f586                	sd	ra,232(sp)
    8000551c:	f1a2                	sd	s0,224(sp)
    8000551e:	eda6                	sd	s1,216(sp)
    80005520:	e9ca                	sd	s2,208(sp)
    80005522:	e5ce                	sd	s3,200(sp)
    80005524:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005526:	08000613          	li	a2,128
    8000552a:	f3040593          	addi	a1,s0,-208
    8000552e:	4501                	li	a0,0
    80005530:	ffffd097          	auipc	ra,0xffffd
    80005534:	650080e7          	jalr	1616(ra) # 80002b80 <argstr>
    80005538:	18054163          	bltz	a0,800056ba <sys_unlink+0x1a2>
  begin_op();
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	bf8080e7          	jalr	-1032(ra) # 80004134 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005544:	fb040593          	addi	a1,s0,-80
    80005548:	f3040513          	addi	a0,s0,-208
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	a06080e7          	jalr	-1530(ra) # 80003f52 <nameiparent>
    80005554:	84aa                	mv	s1,a0
    80005556:	c979                	beqz	a0,8000562c <sys_unlink+0x114>
  ilock(dp);
    80005558:	ffffe097          	auipc	ra,0xffffe
    8000555c:	236080e7          	jalr	566(ra) # 8000378e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005560:	00003597          	auipc	a1,0x3
    80005564:	1c058593          	addi	a1,a1,448 # 80008720 <syscalls+0x2d0>
    80005568:	fb040513          	addi	a0,s0,-80
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	6ec080e7          	jalr	1772(ra) # 80003c58 <namecmp>
    80005574:	14050a63          	beqz	a0,800056c8 <sys_unlink+0x1b0>
    80005578:	00003597          	auipc	a1,0x3
    8000557c:	1b058593          	addi	a1,a1,432 # 80008728 <syscalls+0x2d8>
    80005580:	fb040513          	addi	a0,s0,-80
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	6d4080e7          	jalr	1748(ra) # 80003c58 <namecmp>
    8000558c:	12050e63          	beqz	a0,800056c8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005590:	f2c40613          	addi	a2,s0,-212
    80005594:	fb040593          	addi	a1,s0,-80
    80005598:	8526                	mv	a0,s1
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	6d8080e7          	jalr	1752(ra) # 80003c72 <dirlookup>
    800055a2:	892a                	mv	s2,a0
    800055a4:	12050263          	beqz	a0,800056c8 <sys_unlink+0x1b0>
  ilock(ip);
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	1e6080e7          	jalr	486(ra) # 8000378e <ilock>
  if(ip->nlink < 1)
    800055b0:	04a91783          	lh	a5,74(s2)
    800055b4:	08f05263          	blez	a5,80005638 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055b8:	04491703          	lh	a4,68(s2)
    800055bc:	4785                	li	a5,1
    800055be:	08f70563          	beq	a4,a5,80005648 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055c2:	4641                	li	a2,16
    800055c4:	4581                	li	a1,0
    800055c6:	fc040513          	addi	a0,s0,-64
    800055ca:	ffffb097          	auipc	ra,0xffffb
    800055ce:	704080e7          	jalr	1796(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055d2:	4741                	li	a4,16
    800055d4:	f2c42683          	lw	a3,-212(s0)
    800055d8:	fc040613          	addi	a2,s0,-64
    800055dc:	4581                	li	a1,0
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	55a080e7          	jalr	1370(ra) # 80003b3a <writei>
    800055e8:	47c1                	li	a5,16
    800055ea:	0af51563          	bne	a0,a5,80005694 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055ee:	04491703          	lh	a4,68(s2)
    800055f2:	4785                	li	a5,1
    800055f4:	0af70863          	beq	a4,a5,800056a4 <sys_unlink+0x18c>
  iunlockput(dp);
    800055f8:	8526                	mv	a0,s1
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	3f6080e7          	jalr	1014(ra) # 800039f0 <iunlockput>
  ip->nlink--;
    80005602:	04a95783          	lhu	a5,74(s2)
    80005606:	37fd                	addiw	a5,a5,-1
    80005608:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000560c:	854a                	mv	a0,s2
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	0b4080e7          	jalr	180(ra) # 800036c2 <iupdate>
  iunlockput(ip);
    80005616:	854a                	mv	a0,s2
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	3d8080e7          	jalr	984(ra) # 800039f0 <iunlockput>
  end_op();
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	b8e080e7          	jalr	-1138(ra) # 800041ae <end_op>
  return 0;
    80005628:	4501                	li	a0,0
    8000562a:	a84d                	j	800056dc <sys_unlink+0x1c4>
    end_op();
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	b82080e7          	jalr	-1150(ra) # 800041ae <end_op>
    return -1;
    80005634:	557d                	li	a0,-1
    80005636:	a05d                	j	800056dc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005638:	00003517          	auipc	a0,0x3
    8000563c:	0f850513          	addi	a0,a0,248 # 80008730 <syscalls+0x2e0>
    80005640:	ffffb097          	auipc	ra,0xffffb
    80005644:	efc080e7          	jalr	-260(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005648:	04c92703          	lw	a4,76(s2)
    8000564c:	02000793          	li	a5,32
    80005650:	f6e7f9e3          	bgeu	a5,a4,800055c2 <sys_unlink+0xaa>
    80005654:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005658:	4741                	li	a4,16
    8000565a:	86ce                	mv	a3,s3
    8000565c:	f1840613          	addi	a2,s0,-232
    80005660:	4581                	li	a1,0
    80005662:	854a                	mv	a0,s2
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	3de080e7          	jalr	990(ra) # 80003a42 <readi>
    8000566c:	47c1                	li	a5,16
    8000566e:	00f51b63          	bne	a0,a5,80005684 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005672:	f1845783          	lhu	a5,-232(s0)
    80005676:	e7a1                	bnez	a5,800056be <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005678:	29c1                	addiw	s3,s3,16
    8000567a:	04c92783          	lw	a5,76(s2)
    8000567e:	fcf9ede3          	bltu	s3,a5,80005658 <sys_unlink+0x140>
    80005682:	b781                	j	800055c2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005684:	00003517          	auipc	a0,0x3
    80005688:	0c450513          	addi	a0,a0,196 # 80008748 <syscalls+0x2f8>
    8000568c:	ffffb097          	auipc	ra,0xffffb
    80005690:	eb0080e7          	jalr	-336(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005694:	00003517          	auipc	a0,0x3
    80005698:	0cc50513          	addi	a0,a0,204 # 80008760 <syscalls+0x310>
    8000569c:	ffffb097          	auipc	ra,0xffffb
    800056a0:	ea0080e7          	jalr	-352(ra) # 8000053c <panic>
    dp->nlink--;
    800056a4:	04a4d783          	lhu	a5,74(s1)
    800056a8:	37fd                	addiw	a5,a5,-1
    800056aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	012080e7          	jalr	18(ra) # 800036c2 <iupdate>
    800056b8:	b781                	j	800055f8 <sys_unlink+0xe0>
    return -1;
    800056ba:	557d                	li	a0,-1
    800056bc:	a005                	j	800056dc <sys_unlink+0x1c4>
    iunlockput(ip);
    800056be:	854a                	mv	a0,s2
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	330080e7          	jalr	816(ra) # 800039f0 <iunlockput>
  iunlockput(dp);
    800056c8:	8526                	mv	a0,s1
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	326080e7          	jalr	806(ra) # 800039f0 <iunlockput>
  end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	adc080e7          	jalr	-1316(ra) # 800041ae <end_op>
  return -1;
    800056da:	557d                	li	a0,-1
}
    800056dc:	70ae                	ld	ra,232(sp)
    800056de:	740e                	ld	s0,224(sp)
    800056e0:	64ee                	ld	s1,216(sp)
    800056e2:	694e                	ld	s2,208(sp)
    800056e4:	69ae                	ld	s3,200(sp)
    800056e6:	616d                	addi	sp,sp,240
    800056e8:	8082                	ret

00000000800056ea <sys_open>:

uint64
sys_open(void)
{
    800056ea:	7131                	addi	sp,sp,-192
    800056ec:	fd06                	sd	ra,184(sp)
    800056ee:	f922                	sd	s0,176(sp)
    800056f0:	f526                	sd	s1,168(sp)
    800056f2:	f14a                	sd	s2,160(sp)
    800056f4:	ed4e                	sd	s3,152(sp)
    800056f6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056f8:	f4c40593          	addi	a1,s0,-180
    800056fc:	4505                	li	a0,1
    800056fe:	ffffd097          	auipc	ra,0xffffd
    80005702:	442080e7          	jalr	1090(ra) # 80002b40 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005706:	08000613          	li	a2,128
    8000570a:	f5040593          	addi	a1,s0,-176
    8000570e:	4501                	li	a0,0
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	470080e7          	jalr	1136(ra) # 80002b80 <argstr>
    80005718:	87aa                	mv	a5,a0
    return -1;
    8000571a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000571c:	0a07c863          	bltz	a5,800057cc <sys_open+0xe2>

  begin_op();
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	a14080e7          	jalr	-1516(ra) # 80004134 <begin_op>

  if(omode & O_CREATE){
    80005728:	f4c42783          	lw	a5,-180(s0)
    8000572c:	2007f793          	andi	a5,a5,512
    80005730:	cbdd                	beqz	a5,800057e6 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005732:	4681                	li	a3,0
    80005734:	4601                	li	a2,0
    80005736:	4589                	li	a1,2
    80005738:	f5040513          	addi	a0,s0,-176
    8000573c:	00000097          	auipc	ra,0x0
    80005740:	97a080e7          	jalr	-1670(ra) # 800050b6 <create>
    80005744:	84aa                	mv	s1,a0
    if(ip == 0){
    80005746:	c951                	beqz	a0,800057da <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005748:	04449703          	lh	a4,68(s1)
    8000574c:	478d                	li	a5,3
    8000574e:	00f71763          	bne	a4,a5,8000575c <sys_open+0x72>
    80005752:	0464d703          	lhu	a4,70(s1)
    80005756:	47a5                	li	a5,9
    80005758:	0ce7ec63          	bltu	a5,a4,80005830 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000575c:	fffff097          	auipc	ra,0xfffff
    80005760:	de0080e7          	jalr	-544(ra) # 8000453c <filealloc>
    80005764:	892a                	mv	s2,a0
    80005766:	c56d                	beqz	a0,80005850 <sys_open+0x166>
    80005768:	00000097          	auipc	ra,0x0
    8000576c:	90c080e7          	jalr	-1780(ra) # 80005074 <fdalloc>
    80005770:	89aa                	mv	s3,a0
    80005772:	0c054a63          	bltz	a0,80005846 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005776:	04449703          	lh	a4,68(s1)
    8000577a:	478d                	li	a5,3
    8000577c:	0ef70563          	beq	a4,a5,80005866 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005780:	4789                	li	a5,2
    80005782:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005786:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000578a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000578e:	f4c42783          	lw	a5,-180(s0)
    80005792:	0017c713          	xori	a4,a5,1
    80005796:	8b05                	andi	a4,a4,1
    80005798:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000579c:	0037f713          	andi	a4,a5,3
    800057a0:	00e03733          	snez	a4,a4
    800057a4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057a8:	4007f793          	andi	a5,a5,1024
    800057ac:	c791                	beqz	a5,800057b8 <sys_open+0xce>
    800057ae:	04449703          	lh	a4,68(s1)
    800057b2:	4789                	li	a5,2
    800057b4:	0cf70063          	beq	a4,a5,80005874 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	096080e7          	jalr	150(ra) # 80003850 <iunlock>
  end_op();
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	9ec080e7          	jalr	-1556(ra) # 800041ae <end_op>

  return fd;
    800057ca:	854e                	mv	a0,s3
}
    800057cc:	70ea                	ld	ra,184(sp)
    800057ce:	744a                	ld	s0,176(sp)
    800057d0:	74aa                	ld	s1,168(sp)
    800057d2:	790a                	ld	s2,160(sp)
    800057d4:	69ea                	ld	s3,152(sp)
    800057d6:	6129                	addi	sp,sp,192
    800057d8:	8082                	ret
      end_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	9d4080e7          	jalr	-1580(ra) # 800041ae <end_op>
      return -1;
    800057e2:	557d                	li	a0,-1
    800057e4:	b7e5                	j	800057cc <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057e6:	f5040513          	addi	a0,s0,-176
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	74a080e7          	jalr	1866(ra) # 80003f34 <namei>
    800057f2:	84aa                	mv	s1,a0
    800057f4:	c905                	beqz	a0,80005824 <sys_open+0x13a>
    ilock(ip);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	f98080e7          	jalr	-104(ra) # 8000378e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057fe:	04449703          	lh	a4,68(s1)
    80005802:	4785                	li	a5,1
    80005804:	f4f712e3          	bne	a4,a5,80005748 <sys_open+0x5e>
    80005808:	f4c42783          	lw	a5,-180(s0)
    8000580c:	dba1                	beqz	a5,8000575c <sys_open+0x72>
      iunlockput(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	1e0080e7          	jalr	480(ra) # 800039f0 <iunlockput>
      end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	996080e7          	jalr	-1642(ra) # 800041ae <end_op>
      return -1;
    80005820:	557d                	li	a0,-1
    80005822:	b76d                	j	800057cc <sys_open+0xe2>
      end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	98a080e7          	jalr	-1654(ra) # 800041ae <end_op>
      return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	bf79                	j	800057cc <sys_open+0xe2>
    iunlockput(ip);
    80005830:	8526                	mv	a0,s1
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	1be080e7          	jalr	446(ra) # 800039f0 <iunlockput>
    end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	974080e7          	jalr	-1676(ra) # 800041ae <end_op>
    return -1;
    80005842:	557d                	li	a0,-1
    80005844:	b761                	j	800057cc <sys_open+0xe2>
      fileclose(f);
    80005846:	854a                	mv	a0,s2
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	db0080e7          	jalr	-592(ra) # 800045f8 <fileclose>
    iunlockput(ip);
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	19e080e7          	jalr	414(ra) # 800039f0 <iunlockput>
    end_op();
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	954080e7          	jalr	-1708(ra) # 800041ae <end_op>
    return -1;
    80005862:	557d                	li	a0,-1
    80005864:	b7a5                	j	800057cc <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005866:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000586a:	04649783          	lh	a5,70(s1)
    8000586e:	02f91223          	sh	a5,36(s2)
    80005872:	bf21                	j	8000578a <sys_open+0xa0>
    itrunc(ip);
    80005874:	8526                	mv	a0,s1
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	026080e7          	jalr	38(ra) # 8000389c <itrunc>
    8000587e:	bf2d                	j	800057b8 <sys_open+0xce>

0000000080005880 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005880:	7175                	addi	sp,sp,-144
    80005882:	e506                	sd	ra,136(sp)
    80005884:	e122                	sd	s0,128(sp)
    80005886:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	8ac080e7          	jalr	-1876(ra) # 80004134 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005890:	08000613          	li	a2,128
    80005894:	f7040593          	addi	a1,s0,-144
    80005898:	4501                	li	a0,0
    8000589a:	ffffd097          	auipc	ra,0xffffd
    8000589e:	2e6080e7          	jalr	742(ra) # 80002b80 <argstr>
    800058a2:	02054963          	bltz	a0,800058d4 <sys_mkdir+0x54>
    800058a6:	4681                	li	a3,0
    800058a8:	4601                	li	a2,0
    800058aa:	4585                	li	a1,1
    800058ac:	f7040513          	addi	a0,s0,-144
    800058b0:	00000097          	auipc	ra,0x0
    800058b4:	806080e7          	jalr	-2042(ra) # 800050b6 <create>
    800058b8:	cd11                	beqz	a0,800058d4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	136080e7          	jalr	310(ra) # 800039f0 <iunlockput>
  end_op();
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	8ec080e7          	jalr	-1812(ra) # 800041ae <end_op>
  return 0;
    800058ca:	4501                	li	a0,0
}
    800058cc:	60aa                	ld	ra,136(sp)
    800058ce:	640a                	ld	s0,128(sp)
    800058d0:	6149                	addi	sp,sp,144
    800058d2:	8082                	ret
    end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	8da080e7          	jalr	-1830(ra) # 800041ae <end_op>
    return -1;
    800058dc:	557d                	li	a0,-1
    800058de:	b7fd                	j	800058cc <sys_mkdir+0x4c>

00000000800058e0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058e0:	7135                	addi	sp,sp,-160
    800058e2:	ed06                	sd	ra,152(sp)
    800058e4:	e922                	sd	s0,144(sp)
    800058e6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	84c080e7          	jalr	-1972(ra) # 80004134 <begin_op>
  argint(1, &major);
    800058f0:	f6c40593          	addi	a1,s0,-148
    800058f4:	4505                	li	a0,1
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	24a080e7          	jalr	586(ra) # 80002b40 <argint>
  argint(2, &minor);
    800058fe:	f6840593          	addi	a1,s0,-152
    80005902:	4509                	li	a0,2
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	23c080e7          	jalr	572(ra) # 80002b40 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000590c:	08000613          	li	a2,128
    80005910:	f7040593          	addi	a1,s0,-144
    80005914:	4501                	li	a0,0
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	26a080e7          	jalr	618(ra) # 80002b80 <argstr>
    8000591e:	02054b63          	bltz	a0,80005954 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005922:	f6841683          	lh	a3,-152(s0)
    80005926:	f6c41603          	lh	a2,-148(s0)
    8000592a:	458d                	li	a1,3
    8000592c:	f7040513          	addi	a0,s0,-144
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	786080e7          	jalr	1926(ra) # 800050b6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005938:	cd11                	beqz	a0,80005954 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	0b6080e7          	jalr	182(ra) # 800039f0 <iunlockput>
  end_op();
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	86c080e7          	jalr	-1940(ra) # 800041ae <end_op>
  return 0;
    8000594a:	4501                	li	a0,0
}
    8000594c:	60ea                	ld	ra,152(sp)
    8000594e:	644a                	ld	s0,144(sp)
    80005950:	610d                	addi	sp,sp,160
    80005952:	8082                	ret
    end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	85a080e7          	jalr	-1958(ra) # 800041ae <end_op>
    return -1;
    8000595c:	557d                	li	a0,-1
    8000595e:	b7fd                	j	8000594c <sys_mknod+0x6c>

0000000080005960 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005960:	7135                	addi	sp,sp,-160
    80005962:	ed06                	sd	ra,152(sp)
    80005964:	e922                	sd	s0,144(sp)
    80005966:	e526                	sd	s1,136(sp)
    80005968:	e14a                	sd	s2,128(sp)
    8000596a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000596c:	ffffc097          	auipc	ra,0xffffc
    80005970:	03a080e7          	jalr	58(ra) # 800019a6 <myproc>
    80005974:	892a                	mv	s2,a0
  
  begin_op();
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	7be080e7          	jalr	1982(ra) # 80004134 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000597e:	08000613          	li	a2,128
    80005982:	f6040593          	addi	a1,s0,-160
    80005986:	4501                	li	a0,0
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	1f8080e7          	jalr	504(ra) # 80002b80 <argstr>
    80005990:	04054b63          	bltz	a0,800059e6 <sys_chdir+0x86>
    80005994:	f6040513          	addi	a0,s0,-160
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	59c080e7          	jalr	1436(ra) # 80003f34 <namei>
    800059a0:	84aa                	mv	s1,a0
    800059a2:	c131                	beqz	a0,800059e6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	dea080e7          	jalr	-534(ra) # 8000378e <ilock>
  if(ip->type != T_DIR){
    800059ac:	04449703          	lh	a4,68(s1)
    800059b0:	4785                	li	a5,1
    800059b2:	04f71063          	bne	a4,a5,800059f2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059b6:	8526                	mv	a0,s1
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	e98080e7          	jalr	-360(ra) # 80003850 <iunlock>
  iput(p->cwd);
    800059c0:	15093503          	ld	a0,336(s2)
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	f84080e7          	jalr	-124(ra) # 80003948 <iput>
  end_op();
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	7e2080e7          	jalr	2018(ra) # 800041ae <end_op>
  p->cwd = ip;
    800059d4:	14993823          	sd	s1,336(s2)
  return 0;
    800059d8:	4501                	li	a0,0
}
    800059da:	60ea                	ld	ra,152(sp)
    800059dc:	644a                	ld	s0,144(sp)
    800059de:	64aa                	ld	s1,136(sp)
    800059e0:	690a                	ld	s2,128(sp)
    800059e2:	610d                	addi	sp,sp,160
    800059e4:	8082                	ret
    end_op();
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	7c8080e7          	jalr	1992(ra) # 800041ae <end_op>
    return -1;
    800059ee:	557d                	li	a0,-1
    800059f0:	b7ed                	j	800059da <sys_chdir+0x7a>
    iunlockput(ip);
    800059f2:	8526                	mv	a0,s1
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	ffc080e7          	jalr	-4(ra) # 800039f0 <iunlockput>
    end_op();
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	7b2080e7          	jalr	1970(ra) # 800041ae <end_op>
    return -1;
    80005a04:	557d                	li	a0,-1
    80005a06:	bfd1                	j	800059da <sys_chdir+0x7a>

0000000080005a08 <sys_exec>:

uint64
sys_exec(void)
{
    80005a08:	7121                	addi	sp,sp,-448
    80005a0a:	ff06                	sd	ra,440(sp)
    80005a0c:	fb22                	sd	s0,432(sp)
    80005a0e:	f726                	sd	s1,424(sp)
    80005a10:	f34a                	sd	s2,416(sp)
    80005a12:	ef4e                	sd	s3,408(sp)
    80005a14:	eb52                	sd	s4,400(sp)
    80005a16:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a18:	e4840593          	addi	a1,s0,-440
    80005a1c:	4505                	li	a0,1
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	142080e7          	jalr	322(ra) # 80002b60 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a26:	08000613          	li	a2,128
    80005a2a:	f5040593          	addi	a1,s0,-176
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	150080e7          	jalr	336(ra) # 80002b80 <argstr>
    80005a38:	87aa                	mv	a5,a0
    return -1;
    80005a3a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a3c:	0c07c263          	bltz	a5,80005b00 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a40:	10000613          	li	a2,256
    80005a44:	4581                	li	a1,0
    80005a46:	e5040513          	addi	a0,s0,-432
    80005a4a:	ffffb097          	auipc	ra,0xffffb
    80005a4e:	284080e7          	jalr	644(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a52:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a56:	89a6                	mv	s3,s1
    80005a58:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a5a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a5e:	00391513          	slli	a0,s2,0x3
    80005a62:	e4040593          	addi	a1,s0,-448
    80005a66:	e4843783          	ld	a5,-440(s0)
    80005a6a:	953e                	add	a0,a0,a5
    80005a6c:	ffffd097          	auipc	ra,0xffffd
    80005a70:	036080e7          	jalr	54(ra) # 80002aa2 <fetchaddr>
    80005a74:	02054a63          	bltz	a0,80005aa8 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a78:	e4043783          	ld	a5,-448(s0)
    80005a7c:	c3b9                	beqz	a5,80005ac2 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a7e:	ffffb097          	auipc	ra,0xffffb
    80005a82:	064080e7          	jalr	100(ra) # 80000ae2 <kalloc>
    80005a86:	85aa                	mv	a1,a0
    80005a88:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a8c:	cd11                	beqz	a0,80005aa8 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a8e:	6605                	lui	a2,0x1
    80005a90:	e4043503          	ld	a0,-448(s0)
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	060080e7          	jalr	96(ra) # 80002af4 <fetchstr>
    80005a9c:	00054663          	bltz	a0,80005aa8 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005aa0:	0905                	addi	s2,s2,1
    80005aa2:	09a1                	addi	s3,s3,8
    80005aa4:	fb491de3          	bne	s2,s4,80005a5e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa8:	f5040913          	addi	s2,s0,-176
    80005aac:	6088                	ld	a0,0(s1)
    80005aae:	c921                	beqz	a0,80005afe <sys_exec+0xf6>
    kfree(argv[i]);
    80005ab0:	ffffb097          	auipc	ra,0xffffb
    80005ab4:	f34080e7          	jalr	-204(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ab8:	04a1                	addi	s1,s1,8
    80005aba:	ff2499e3          	bne	s1,s2,80005aac <sys_exec+0xa4>
  return -1;
    80005abe:	557d                	li	a0,-1
    80005ac0:	a081                	j	80005b00 <sys_exec+0xf8>
      argv[i] = 0;
    80005ac2:	0009079b          	sext.w	a5,s2
    80005ac6:	078e                	slli	a5,a5,0x3
    80005ac8:	fd078793          	addi	a5,a5,-48
    80005acc:	97a2                	add	a5,a5,s0
    80005ace:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ad2:	e5040593          	addi	a1,s0,-432
    80005ad6:	f5040513          	addi	a0,s0,-176
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	194080e7          	jalr	404(ra) # 80004c6e <exec>
    80005ae2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae4:	f5040993          	addi	s3,s0,-176
    80005ae8:	6088                	ld	a0,0(s1)
    80005aea:	c901                	beqz	a0,80005afa <sys_exec+0xf2>
    kfree(argv[i]);
    80005aec:	ffffb097          	auipc	ra,0xffffb
    80005af0:	ef8080e7          	jalr	-264(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af4:	04a1                	addi	s1,s1,8
    80005af6:	ff3499e3          	bne	s1,s3,80005ae8 <sys_exec+0xe0>
  return ret;
    80005afa:	854a                	mv	a0,s2
    80005afc:	a011                	j	80005b00 <sys_exec+0xf8>
  return -1;
    80005afe:	557d                	li	a0,-1
}
    80005b00:	70fa                	ld	ra,440(sp)
    80005b02:	745a                	ld	s0,432(sp)
    80005b04:	74ba                	ld	s1,424(sp)
    80005b06:	791a                	ld	s2,416(sp)
    80005b08:	69fa                	ld	s3,408(sp)
    80005b0a:	6a5a                	ld	s4,400(sp)
    80005b0c:	6139                	addi	sp,sp,448
    80005b0e:	8082                	ret

0000000080005b10 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b10:	7139                	addi	sp,sp,-64
    80005b12:	fc06                	sd	ra,56(sp)
    80005b14:	f822                	sd	s0,48(sp)
    80005b16:	f426                	sd	s1,40(sp)
    80005b18:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b1a:	ffffc097          	auipc	ra,0xffffc
    80005b1e:	e8c080e7          	jalr	-372(ra) # 800019a6 <myproc>
    80005b22:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b24:	fd840593          	addi	a1,s0,-40
    80005b28:	4501                	li	a0,0
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	036080e7          	jalr	54(ra) # 80002b60 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b32:	fc840593          	addi	a1,s0,-56
    80005b36:	fd040513          	addi	a0,s0,-48
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	dea080e7          	jalr	-534(ra) # 80004924 <pipealloc>
    return -1;
    80005b42:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b44:	0c054463          	bltz	a0,80005c0c <sys_pipe+0xfc>
  fd0 = -1;
    80005b48:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b4c:	fd043503          	ld	a0,-48(s0)
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	524080e7          	jalr	1316(ra) # 80005074 <fdalloc>
    80005b58:	fca42223          	sw	a0,-60(s0)
    80005b5c:	08054b63          	bltz	a0,80005bf2 <sys_pipe+0xe2>
    80005b60:	fc843503          	ld	a0,-56(s0)
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	510080e7          	jalr	1296(ra) # 80005074 <fdalloc>
    80005b6c:	fca42023          	sw	a0,-64(s0)
    80005b70:	06054863          	bltz	a0,80005be0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b74:	4691                	li	a3,4
    80005b76:	fc440613          	addi	a2,s0,-60
    80005b7a:	fd843583          	ld	a1,-40(s0)
    80005b7e:	68a8                	ld	a0,80(s1)
    80005b80:	ffffc097          	auipc	ra,0xffffc
    80005b84:	ae6080e7          	jalr	-1306(ra) # 80001666 <copyout>
    80005b88:	02054063          	bltz	a0,80005ba8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b8c:	4691                	li	a3,4
    80005b8e:	fc040613          	addi	a2,s0,-64
    80005b92:	fd843583          	ld	a1,-40(s0)
    80005b96:	0591                	addi	a1,a1,4
    80005b98:	68a8                	ld	a0,80(s1)
    80005b9a:	ffffc097          	auipc	ra,0xffffc
    80005b9e:	acc080e7          	jalr	-1332(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ba2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ba4:	06055463          	bgez	a0,80005c0c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005ba8:	fc442783          	lw	a5,-60(s0)
    80005bac:	07e9                	addi	a5,a5,26
    80005bae:	078e                	slli	a5,a5,0x3
    80005bb0:	97a6                	add	a5,a5,s1
    80005bb2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bb6:	fc042783          	lw	a5,-64(s0)
    80005bba:	07e9                	addi	a5,a5,26
    80005bbc:	078e                	slli	a5,a5,0x3
    80005bbe:	94be                	add	s1,s1,a5
    80005bc0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bc4:	fd043503          	ld	a0,-48(s0)
    80005bc8:	fffff097          	auipc	ra,0xfffff
    80005bcc:	a30080e7          	jalr	-1488(ra) # 800045f8 <fileclose>
    fileclose(wf);
    80005bd0:	fc843503          	ld	a0,-56(s0)
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	a24080e7          	jalr	-1500(ra) # 800045f8 <fileclose>
    return -1;
    80005bdc:	57fd                	li	a5,-1
    80005bde:	a03d                	j	80005c0c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005be0:	fc442783          	lw	a5,-60(s0)
    80005be4:	0007c763          	bltz	a5,80005bf2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005be8:	07e9                	addi	a5,a5,26
    80005bea:	078e                	slli	a5,a5,0x3
    80005bec:	97a6                	add	a5,a5,s1
    80005bee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005bf2:	fd043503          	ld	a0,-48(s0)
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	a02080e7          	jalr	-1534(ra) # 800045f8 <fileclose>
    fileclose(wf);
    80005bfe:	fc843503          	ld	a0,-56(s0)
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	9f6080e7          	jalr	-1546(ra) # 800045f8 <fileclose>
    return -1;
    80005c0a:	57fd                	li	a5,-1
}
    80005c0c:	853e                	mv	a0,a5
    80005c0e:	70e2                	ld	ra,56(sp)
    80005c10:	7442                	ld	s0,48(sp)
    80005c12:	74a2                	ld	s1,40(sp)
    80005c14:	6121                	addi	sp,sp,64
    80005c16:	8082                	ret
	...

0000000080005c20 <kernelvec>:
    80005c20:	7111                	addi	sp,sp,-256
    80005c22:	e006                	sd	ra,0(sp)
    80005c24:	e40a                	sd	sp,8(sp)
    80005c26:	e80e                	sd	gp,16(sp)
    80005c28:	ec12                	sd	tp,24(sp)
    80005c2a:	f016                	sd	t0,32(sp)
    80005c2c:	f41a                	sd	t1,40(sp)
    80005c2e:	f81e                	sd	t2,48(sp)
    80005c30:	fc22                	sd	s0,56(sp)
    80005c32:	e0a6                	sd	s1,64(sp)
    80005c34:	e4aa                	sd	a0,72(sp)
    80005c36:	e8ae                	sd	a1,80(sp)
    80005c38:	ecb2                	sd	a2,88(sp)
    80005c3a:	f0b6                	sd	a3,96(sp)
    80005c3c:	f4ba                	sd	a4,104(sp)
    80005c3e:	f8be                	sd	a5,112(sp)
    80005c40:	fcc2                	sd	a6,120(sp)
    80005c42:	e146                	sd	a7,128(sp)
    80005c44:	e54a                	sd	s2,136(sp)
    80005c46:	e94e                	sd	s3,144(sp)
    80005c48:	ed52                	sd	s4,152(sp)
    80005c4a:	f156                	sd	s5,160(sp)
    80005c4c:	f55a                	sd	s6,168(sp)
    80005c4e:	f95e                	sd	s7,176(sp)
    80005c50:	fd62                	sd	s8,184(sp)
    80005c52:	e1e6                	sd	s9,192(sp)
    80005c54:	e5ea                	sd	s10,200(sp)
    80005c56:	e9ee                	sd	s11,208(sp)
    80005c58:	edf2                	sd	t3,216(sp)
    80005c5a:	f1f6                	sd	t4,224(sp)
    80005c5c:	f5fa                	sd	t5,232(sp)
    80005c5e:	f9fe                	sd	t6,240(sp)
    80005c60:	d0ffc0ef          	jal	ra,8000296e <kerneltrap>
    80005c64:	6082                	ld	ra,0(sp)
    80005c66:	6122                	ld	sp,8(sp)
    80005c68:	61c2                	ld	gp,16(sp)
    80005c6a:	7282                	ld	t0,32(sp)
    80005c6c:	7322                	ld	t1,40(sp)
    80005c6e:	73c2                	ld	t2,48(sp)
    80005c70:	7462                	ld	s0,56(sp)
    80005c72:	6486                	ld	s1,64(sp)
    80005c74:	6526                	ld	a0,72(sp)
    80005c76:	65c6                	ld	a1,80(sp)
    80005c78:	6666                	ld	a2,88(sp)
    80005c7a:	7686                	ld	a3,96(sp)
    80005c7c:	7726                	ld	a4,104(sp)
    80005c7e:	77c6                	ld	a5,112(sp)
    80005c80:	7866                	ld	a6,120(sp)
    80005c82:	688a                	ld	a7,128(sp)
    80005c84:	692a                	ld	s2,136(sp)
    80005c86:	69ca                	ld	s3,144(sp)
    80005c88:	6a6a                	ld	s4,152(sp)
    80005c8a:	7a8a                	ld	s5,160(sp)
    80005c8c:	7b2a                	ld	s6,168(sp)
    80005c8e:	7bca                	ld	s7,176(sp)
    80005c90:	7c6a                	ld	s8,184(sp)
    80005c92:	6c8e                	ld	s9,192(sp)
    80005c94:	6d2e                	ld	s10,200(sp)
    80005c96:	6dce                	ld	s11,208(sp)
    80005c98:	6e6e                	ld	t3,216(sp)
    80005c9a:	7e8e                	ld	t4,224(sp)
    80005c9c:	7f2e                	ld	t5,232(sp)
    80005c9e:	7fce                	ld	t6,240(sp)
    80005ca0:	6111                	addi	sp,sp,256
    80005ca2:	10200073          	sret
    80005ca6:	00000013          	nop
    80005caa:	00000013          	nop
    80005cae:	0001                	nop

0000000080005cb0 <timervec>:
    80005cb0:	34051573          	csrrw	a0,mscratch,a0
    80005cb4:	e10c                	sd	a1,0(a0)
    80005cb6:	e510                	sd	a2,8(a0)
    80005cb8:	e914                	sd	a3,16(a0)
    80005cba:	6d0c                	ld	a1,24(a0)
    80005cbc:	7110                	ld	a2,32(a0)
    80005cbe:	6194                	ld	a3,0(a1)
    80005cc0:	96b2                	add	a3,a3,a2
    80005cc2:	e194                	sd	a3,0(a1)
    80005cc4:	4589                	li	a1,2
    80005cc6:	14459073          	csrw	sip,a1
    80005cca:	6914                	ld	a3,16(a0)
    80005ccc:	6510                	ld	a2,8(a0)
    80005cce:	610c                	ld	a1,0(a0)
    80005cd0:	34051573          	csrrw	a0,mscratch,a0
    80005cd4:	30200073          	mret
	...

0000000080005cda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cda:	1141                	addi	sp,sp,-16
    80005cdc:	e422                	sd	s0,8(sp)
    80005cde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ce0:	0c0007b7          	lui	a5,0xc000
    80005ce4:	4705                	li	a4,1
    80005ce6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ce8:	c3d8                	sw	a4,4(a5)
}
    80005cea:	6422                	ld	s0,8(sp)
    80005cec:	0141                	addi	sp,sp,16
    80005cee:	8082                	ret

0000000080005cf0 <plicinithart>:

void
plicinithart(void)
{
    80005cf0:	1141                	addi	sp,sp,-16
    80005cf2:	e406                	sd	ra,8(sp)
    80005cf4:	e022                	sd	s0,0(sp)
    80005cf6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	c82080e7          	jalr	-894(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d00:	0085171b          	slliw	a4,a0,0x8
    80005d04:	0c0027b7          	lui	a5,0xc002
    80005d08:	97ba                	add	a5,a5,a4
    80005d0a:	40200713          	li	a4,1026
    80005d0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d12:	00d5151b          	slliw	a0,a0,0xd
    80005d16:	0c2017b7          	lui	a5,0xc201
    80005d1a:	97aa                	add	a5,a5,a0
    80005d1c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d20:	60a2                	ld	ra,8(sp)
    80005d22:	6402                	ld	s0,0(sp)
    80005d24:	0141                	addi	sp,sp,16
    80005d26:	8082                	ret

0000000080005d28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d28:	1141                	addi	sp,sp,-16
    80005d2a:	e406                	sd	ra,8(sp)
    80005d2c:	e022                	sd	s0,0(sp)
    80005d2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d30:	ffffc097          	auipc	ra,0xffffc
    80005d34:	c4a080e7          	jalr	-950(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d38:	00d5151b          	slliw	a0,a0,0xd
    80005d3c:	0c2017b7          	lui	a5,0xc201
    80005d40:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d42:	43c8                	lw	a0,4(a5)
    80005d44:	60a2                	ld	ra,8(sp)
    80005d46:	6402                	ld	s0,0(sp)
    80005d48:	0141                	addi	sp,sp,16
    80005d4a:	8082                	ret

0000000080005d4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d4c:	1101                	addi	sp,sp,-32
    80005d4e:	ec06                	sd	ra,24(sp)
    80005d50:	e822                	sd	s0,16(sp)
    80005d52:	e426                	sd	s1,8(sp)
    80005d54:	1000                	addi	s0,sp,32
    80005d56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d58:	ffffc097          	auipc	ra,0xffffc
    80005d5c:	c22080e7          	jalr	-990(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d60:	00d5151b          	slliw	a0,a0,0xd
    80005d64:	0c2017b7          	lui	a5,0xc201
    80005d68:	97aa                	add	a5,a5,a0
    80005d6a:	c3c4                	sw	s1,4(a5)
}
    80005d6c:	60e2                	ld	ra,24(sp)
    80005d6e:	6442                	ld	s0,16(sp)
    80005d70:	64a2                	ld	s1,8(sp)
    80005d72:	6105                	addi	sp,sp,32
    80005d74:	8082                	ret

0000000080005d76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d76:	1141                	addi	sp,sp,-16
    80005d78:	e406                	sd	ra,8(sp)
    80005d7a:	e022                	sd	s0,0(sp)
    80005d7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d7e:	479d                	li	a5,7
    80005d80:	04a7cc63          	blt	a5,a0,80005dd8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d84:	0001c797          	auipc	a5,0x1c
    80005d88:	edc78793          	addi	a5,a5,-292 # 80021c60 <disk>
    80005d8c:	97aa                	add	a5,a5,a0
    80005d8e:	0187c783          	lbu	a5,24(a5)
    80005d92:	ebb9                	bnez	a5,80005de8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d94:	00451693          	slli	a3,a0,0x4
    80005d98:	0001c797          	auipc	a5,0x1c
    80005d9c:	ec878793          	addi	a5,a5,-312 # 80021c60 <disk>
    80005da0:	6398                	ld	a4,0(a5)
    80005da2:	9736                	add	a4,a4,a3
    80005da4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005da8:	6398                	ld	a4,0(a5)
    80005daa:	9736                	add	a4,a4,a3
    80005dac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005db0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005db4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005db8:	97aa                	add	a5,a5,a0
    80005dba:	4705                	li	a4,1
    80005dbc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005dc0:	0001c517          	auipc	a0,0x1c
    80005dc4:	eb850513          	addi	a0,a0,-328 # 80021c78 <disk+0x18>
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	36a080e7          	jalr	874(ra) # 80002132 <wakeup>
}
    80005dd0:	60a2                	ld	ra,8(sp)
    80005dd2:	6402                	ld	s0,0(sp)
    80005dd4:	0141                	addi	sp,sp,16
    80005dd6:	8082                	ret
    panic("free_desc 1");
    80005dd8:	00003517          	auipc	a0,0x3
    80005ddc:	99850513          	addi	a0,a0,-1640 # 80008770 <syscalls+0x320>
    80005de0:	ffffa097          	auipc	ra,0xffffa
    80005de4:	75c080e7          	jalr	1884(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005de8:	00003517          	auipc	a0,0x3
    80005dec:	99850513          	addi	a0,a0,-1640 # 80008780 <syscalls+0x330>
    80005df0:	ffffa097          	auipc	ra,0xffffa
    80005df4:	74c080e7          	jalr	1868(ra) # 8000053c <panic>

0000000080005df8 <virtio_disk_init>:
{
    80005df8:	1101                	addi	sp,sp,-32
    80005dfa:	ec06                	sd	ra,24(sp)
    80005dfc:	e822                	sd	s0,16(sp)
    80005dfe:	e426                	sd	s1,8(sp)
    80005e00:	e04a                	sd	s2,0(sp)
    80005e02:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e04:	00003597          	auipc	a1,0x3
    80005e08:	98c58593          	addi	a1,a1,-1652 # 80008790 <syscalls+0x340>
    80005e0c:	0001c517          	auipc	a0,0x1c
    80005e10:	f7c50513          	addi	a0,a0,-132 # 80021d88 <disk+0x128>
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	d2e080e7          	jalr	-722(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e1c:	100017b7          	lui	a5,0x10001
    80005e20:	4398                	lw	a4,0(a5)
    80005e22:	2701                	sext.w	a4,a4
    80005e24:	747277b7          	lui	a5,0x74727
    80005e28:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e2c:	14f71b63          	bne	a4,a5,80005f82 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e30:	100017b7          	lui	a5,0x10001
    80005e34:	43dc                	lw	a5,4(a5)
    80005e36:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e38:	4709                	li	a4,2
    80005e3a:	14e79463          	bne	a5,a4,80005f82 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e3e:	100017b7          	lui	a5,0x10001
    80005e42:	479c                	lw	a5,8(a5)
    80005e44:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e46:	12e79e63          	bne	a5,a4,80005f82 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e4a:	100017b7          	lui	a5,0x10001
    80005e4e:	47d8                	lw	a4,12(a5)
    80005e50:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e52:	554d47b7          	lui	a5,0x554d4
    80005e56:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e5a:	12f71463          	bne	a4,a5,80005f82 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e5e:	100017b7          	lui	a5,0x10001
    80005e62:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e66:	4705                	li	a4,1
    80005e68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e6a:	470d                	li	a4,3
    80005e6c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e6e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e70:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e74:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9bf>
    80005e78:	8f75                	and	a4,a4,a3
    80005e7a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e7c:	472d                	li	a4,11
    80005e7e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e80:	5bbc                	lw	a5,112(a5)
    80005e82:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e86:	8ba1                	andi	a5,a5,8
    80005e88:	10078563          	beqz	a5,80005f92 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e8c:	100017b7          	lui	a5,0x10001
    80005e90:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e94:	43fc                	lw	a5,68(a5)
    80005e96:	2781                	sext.w	a5,a5
    80005e98:	10079563          	bnez	a5,80005fa2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e9c:	100017b7          	lui	a5,0x10001
    80005ea0:	5bdc                	lw	a5,52(a5)
    80005ea2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ea4:	10078763          	beqz	a5,80005fb2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005ea8:	471d                	li	a4,7
    80005eaa:	10f77c63          	bgeu	a4,a5,80005fc2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005eae:	ffffb097          	auipc	ra,0xffffb
    80005eb2:	c34080e7          	jalr	-972(ra) # 80000ae2 <kalloc>
    80005eb6:	0001c497          	auipc	s1,0x1c
    80005eba:	daa48493          	addi	s1,s1,-598 # 80021c60 <disk>
    80005ebe:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ec0:	ffffb097          	auipc	ra,0xffffb
    80005ec4:	c22080e7          	jalr	-990(ra) # 80000ae2 <kalloc>
    80005ec8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eca:	ffffb097          	auipc	ra,0xffffb
    80005ece:	c18080e7          	jalr	-1000(ra) # 80000ae2 <kalloc>
    80005ed2:	87aa                	mv	a5,a0
    80005ed4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ed6:	6088                	ld	a0,0(s1)
    80005ed8:	cd6d                	beqz	a0,80005fd2 <virtio_disk_init+0x1da>
    80005eda:	0001c717          	auipc	a4,0x1c
    80005ede:	d8e73703          	ld	a4,-626(a4) # 80021c68 <disk+0x8>
    80005ee2:	cb65                	beqz	a4,80005fd2 <virtio_disk_init+0x1da>
    80005ee4:	c7fd                	beqz	a5,80005fd2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ee6:	6605                	lui	a2,0x1
    80005ee8:	4581                	li	a1,0
    80005eea:	ffffb097          	auipc	ra,0xffffb
    80005eee:	de4080e7          	jalr	-540(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ef2:	0001c497          	auipc	s1,0x1c
    80005ef6:	d6e48493          	addi	s1,s1,-658 # 80021c60 <disk>
    80005efa:	6605                	lui	a2,0x1
    80005efc:	4581                	li	a1,0
    80005efe:	6488                	ld	a0,8(s1)
    80005f00:	ffffb097          	auipc	ra,0xffffb
    80005f04:	dce080e7          	jalr	-562(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005f08:	6605                	lui	a2,0x1
    80005f0a:	4581                	li	a1,0
    80005f0c:	6888                	ld	a0,16(s1)
    80005f0e:	ffffb097          	auipc	ra,0xffffb
    80005f12:	dc0080e7          	jalr	-576(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f16:	100017b7          	lui	a5,0x10001
    80005f1a:	4721                	li	a4,8
    80005f1c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f1e:	4098                	lw	a4,0(s1)
    80005f20:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f24:	40d8                	lw	a4,4(s1)
    80005f26:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f2a:	6498                	ld	a4,8(s1)
    80005f2c:	0007069b          	sext.w	a3,a4
    80005f30:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f34:	9701                	srai	a4,a4,0x20
    80005f36:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f3a:	6898                	ld	a4,16(s1)
    80005f3c:	0007069b          	sext.w	a3,a4
    80005f40:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f44:	9701                	srai	a4,a4,0x20
    80005f46:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f4a:	4705                	li	a4,1
    80005f4c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f4e:	00e48c23          	sb	a4,24(s1)
    80005f52:	00e48ca3          	sb	a4,25(s1)
    80005f56:	00e48d23          	sb	a4,26(s1)
    80005f5a:	00e48da3          	sb	a4,27(s1)
    80005f5e:	00e48e23          	sb	a4,28(s1)
    80005f62:	00e48ea3          	sb	a4,29(s1)
    80005f66:	00e48f23          	sb	a4,30(s1)
    80005f6a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f6e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f72:	0727a823          	sw	s2,112(a5)
}
    80005f76:	60e2                	ld	ra,24(sp)
    80005f78:	6442                	ld	s0,16(sp)
    80005f7a:	64a2                	ld	s1,8(sp)
    80005f7c:	6902                	ld	s2,0(sp)
    80005f7e:	6105                	addi	sp,sp,32
    80005f80:	8082                	ret
    panic("could not find virtio disk");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	81e50513          	addi	a0,a0,-2018 # 800087a0 <syscalls+0x350>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b2080e7          	jalr	1458(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	82e50513          	addi	a0,a0,-2002 # 800087c0 <syscalls+0x370>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	83e50513          	addi	a0,a0,-1986 # 800087e0 <syscalls+0x390>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	84e50513          	addi	a0,a0,-1970 # 80008800 <syscalls+0x3b0>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	85e50513          	addi	a0,a0,-1954 # 80008820 <syscalls+0x3d0>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fd2:	00003517          	auipc	a0,0x3
    80005fd6:	86e50513          	addi	a0,a0,-1938 # 80008840 <syscalls+0x3f0>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>

0000000080005fe2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fe2:	7159                	addi	sp,sp,-112
    80005fe4:	f486                	sd	ra,104(sp)
    80005fe6:	f0a2                	sd	s0,96(sp)
    80005fe8:	eca6                	sd	s1,88(sp)
    80005fea:	e8ca                	sd	s2,80(sp)
    80005fec:	e4ce                	sd	s3,72(sp)
    80005fee:	e0d2                	sd	s4,64(sp)
    80005ff0:	fc56                	sd	s5,56(sp)
    80005ff2:	f85a                	sd	s6,48(sp)
    80005ff4:	f45e                	sd	s7,40(sp)
    80005ff6:	f062                	sd	s8,32(sp)
    80005ff8:	ec66                	sd	s9,24(sp)
    80005ffa:	e86a                	sd	s10,16(sp)
    80005ffc:	1880                	addi	s0,sp,112
    80005ffe:	8a2a                	mv	s4,a0
    80006000:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006002:	00c52c83          	lw	s9,12(a0)
    80006006:	001c9c9b          	slliw	s9,s9,0x1
    8000600a:	1c82                	slli	s9,s9,0x20
    8000600c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006010:	0001c517          	auipc	a0,0x1c
    80006014:	d7850513          	addi	a0,a0,-648 # 80021d88 <disk+0x128>
    80006018:	ffffb097          	auipc	ra,0xffffb
    8000601c:	bba080e7          	jalr	-1094(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006020:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006022:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006024:	0001cb17          	auipc	s6,0x1c
    80006028:	c3cb0b13          	addi	s6,s6,-964 # 80021c60 <disk>
  for(int i = 0; i < 3; i++){
    8000602c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000602e:	0001cc17          	auipc	s8,0x1c
    80006032:	d5ac0c13          	addi	s8,s8,-678 # 80021d88 <disk+0x128>
    80006036:	a095                	j	8000609a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006038:	00fb0733          	add	a4,s6,a5
    8000603c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006040:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006042:	0207c563          	bltz	a5,8000606c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006046:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006048:	0591                	addi	a1,a1,4
    8000604a:	05560d63          	beq	a2,s5,800060a4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000604e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006050:	0001c717          	auipc	a4,0x1c
    80006054:	c1070713          	addi	a4,a4,-1008 # 80021c60 <disk>
    80006058:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000605a:	01874683          	lbu	a3,24(a4)
    8000605e:	fee9                	bnez	a3,80006038 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006060:	2785                	addiw	a5,a5,1
    80006062:	0705                	addi	a4,a4,1
    80006064:	fe979be3          	bne	a5,s1,8000605a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006068:	57fd                	li	a5,-1
    8000606a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000606c:	00c05e63          	blez	a2,80006088 <virtio_disk_rw+0xa6>
    80006070:	060a                	slli	a2,a2,0x2
    80006072:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006076:	0009a503          	lw	a0,0(s3)
    8000607a:	00000097          	auipc	ra,0x0
    8000607e:	cfc080e7          	jalr	-772(ra) # 80005d76 <free_desc>
      for(int j = 0; j < i; j++)
    80006082:	0991                	addi	s3,s3,4
    80006084:	ffa999e3          	bne	s3,s10,80006076 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006088:	85e2                	mv	a1,s8
    8000608a:	0001c517          	auipc	a0,0x1c
    8000608e:	bee50513          	addi	a0,a0,-1042 # 80021c78 <disk+0x18>
    80006092:	ffffc097          	auipc	ra,0xffffc
    80006096:	03c080e7          	jalr	60(ra) # 800020ce <sleep>
  for(int i = 0; i < 3; i++){
    8000609a:	f9040993          	addi	s3,s0,-112
{
    8000609e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800060a0:	864a                	mv	a2,s2
    800060a2:	b775                	j	8000604e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060a4:	f9042503          	lw	a0,-112(s0)
    800060a8:	00a50713          	addi	a4,a0,10
    800060ac:	0712                	slli	a4,a4,0x4

  if(write)
    800060ae:	0001c797          	auipc	a5,0x1c
    800060b2:	bb278793          	addi	a5,a5,-1102 # 80021c60 <disk>
    800060b6:	00e786b3          	add	a3,a5,a4
    800060ba:	01703633          	snez	a2,s7
    800060be:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060c0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060c4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060c8:	f6070613          	addi	a2,a4,-160
    800060cc:	6394                	ld	a3,0(a5)
    800060ce:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060d0:	00870593          	addi	a1,a4,8
    800060d4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060d6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060d8:	0007b803          	ld	a6,0(a5)
    800060dc:	9642                	add	a2,a2,a6
    800060de:	46c1                	li	a3,16
    800060e0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060e2:	4585                	li	a1,1
    800060e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060e8:	f9442683          	lw	a3,-108(s0)
    800060ec:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060f0:	0692                	slli	a3,a3,0x4
    800060f2:	9836                	add	a6,a6,a3
    800060f4:	058a0613          	addi	a2,s4,88
    800060f8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060fc:	0007b803          	ld	a6,0(a5)
    80006100:	96c2                	add	a3,a3,a6
    80006102:	40000613          	li	a2,1024
    80006106:	c690                	sw	a2,8(a3)
  if(write)
    80006108:	001bb613          	seqz	a2,s7
    8000610c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006110:	00166613          	ori	a2,a2,1
    80006114:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006118:	f9842603          	lw	a2,-104(s0)
    8000611c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006120:	00250693          	addi	a3,a0,2
    80006124:	0692                	slli	a3,a3,0x4
    80006126:	96be                	add	a3,a3,a5
    80006128:	58fd                	li	a7,-1
    8000612a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000612e:	0612                	slli	a2,a2,0x4
    80006130:	9832                	add	a6,a6,a2
    80006132:	f9070713          	addi	a4,a4,-112
    80006136:	973e                	add	a4,a4,a5
    80006138:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000613c:	6398                	ld	a4,0(a5)
    8000613e:	9732                	add	a4,a4,a2
    80006140:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006142:	4609                	li	a2,2
    80006144:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006148:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000614c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006150:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006154:	6794                	ld	a3,8(a5)
    80006156:	0026d703          	lhu	a4,2(a3)
    8000615a:	8b1d                	andi	a4,a4,7
    8000615c:	0706                	slli	a4,a4,0x1
    8000615e:	96ba                	add	a3,a3,a4
    80006160:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006164:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006168:	6798                	ld	a4,8(a5)
    8000616a:	00275783          	lhu	a5,2(a4)
    8000616e:	2785                	addiw	a5,a5,1
    80006170:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006174:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006178:	100017b7          	lui	a5,0x10001
    8000617c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006180:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006184:	0001c917          	auipc	s2,0x1c
    80006188:	c0490913          	addi	s2,s2,-1020 # 80021d88 <disk+0x128>
  while(b->disk == 1) {
    8000618c:	4485                	li	s1,1
    8000618e:	00b79c63          	bne	a5,a1,800061a6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006192:	85ca                	mv	a1,s2
    80006194:	8552                	mv	a0,s4
    80006196:	ffffc097          	auipc	ra,0xffffc
    8000619a:	f38080e7          	jalr	-200(ra) # 800020ce <sleep>
  while(b->disk == 1) {
    8000619e:	004a2783          	lw	a5,4(s4)
    800061a2:	fe9788e3          	beq	a5,s1,80006192 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800061a6:	f9042903          	lw	s2,-112(s0)
    800061aa:	00290713          	addi	a4,s2,2
    800061ae:	0712                	slli	a4,a4,0x4
    800061b0:	0001c797          	auipc	a5,0x1c
    800061b4:	ab078793          	addi	a5,a5,-1360 # 80021c60 <disk>
    800061b8:	97ba                	add	a5,a5,a4
    800061ba:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061be:	0001c997          	auipc	s3,0x1c
    800061c2:	aa298993          	addi	s3,s3,-1374 # 80021c60 <disk>
    800061c6:	00491713          	slli	a4,s2,0x4
    800061ca:	0009b783          	ld	a5,0(s3)
    800061ce:	97ba                	add	a5,a5,a4
    800061d0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061d4:	854a                	mv	a0,s2
    800061d6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061da:	00000097          	auipc	ra,0x0
    800061de:	b9c080e7          	jalr	-1124(ra) # 80005d76 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061e2:	8885                	andi	s1,s1,1
    800061e4:	f0ed                	bnez	s1,800061c6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061e6:	0001c517          	auipc	a0,0x1c
    800061ea:	ba250513          	addi	a0,a0,-1118 # 80021d88 <disk+0x128>
    800061ee:	ffffb097          	auipc	ra,0xffffb
    800061f2:	a98080e7          	jalr	-1384(ra) # 80000c86 <release>
}
    800061f6:	70a6                	ld	ra,104(sp)
    800061f8:	7406                	ld	s0,96(sp)
    800061fa:	64e6                	ld	s1,88(sp)
    800061fc:	6946                	ld	s2,80(sp)
    800061fe:	69a6                	ld	s3,72(sp)
    80006200:	6a06                	ld	s4,64(sp)
    80006202:	7ae2                	ld	s5,56(sp)
    80006204:	7b42                	ld	s6,48(sp)
    80006206:	7ba2                	ld	s7,40(sp)
    80006208:	7c02                	ld	s8,32(sp)
    8000620a:	6ce2                	ld	s9,24(sp)
    8000620c:	6d42                	ld	s10,16(sp)
    8000620e:	6165                	addi	sp,sp,112
    80006210:	8082                	ret

0000000080006212 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006212:	1101                	addi	sp,sp,-32
    80006214:	ec06                	sd	ra,24(sp)
    80006216:	e822                	sd	s0,16(sp)
    80006218:	e426                	sd	s1,8(sp)
    8000621a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000621c:	0001c497          	auipc	s1,0x1c
    80006220:	a4448493          	addi	s1,s1,-1468 # 80021c60 <disk>
    80006224:	0001c517          	auipc	a0,0x1c
    80006228:	b6450513          	addi	a0,a0,-1180 # 80021d88 <disk+0x128>
    8000622c:	ffffb097          	auipc	ra,0xffffb
    80006230:	9a6080e7          	jalr	-1626(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006234:	10001737          	lui	a4,0x10001
    80006238:	533c                	lw	a5,96(a4)
    8000623a:	8b8d                	andi	a5,a5,3
    8000623c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000623e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006242:	689c                	ld	a5,16(s1)
    80006244:	0204d703          	lhu	a4,32(s1)
    80006248:	0027d783          	lhu	a5,2(a5)
    8000624c:	04f70863          	beq	a4,a5,8000629c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006250:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006254:	6898                	ld	a4,16(s1)
    80006256:	0204d783          	lhu	a5,32(s1)
    8000625a:	8b9d                	andi	a5,a5,7
    8000625c:	078e                	slli	a5,a5,0x3
    8000625e:	97ba                	add	a5,a5,a4
    80006260:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006262:	00278713          	addi	a4,a5,2
    80006266:	0712                	slli	a4,a4,0x4
    80006268:	9726                	add	a4,a4,s1
    8000626a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000626e:	e721                	bnez	a4,800062b6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006270:	0789                	addi	a5,a5,2
    80006272:	0792                	slli	a5,a5,0x4
    80006274:	97a6                	add	a5,a5,s1
    80006276:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006278:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000627c:	ffffc097          	auipc	ra,0xffffc
    80006280:	eb6080e7          	jalr	-330(ra) # 80002132 <wakeup>

    disk.used_idx += 1;
    80006284:	0204d783          	lhu	a5,32(s1)
    80006288:	2785                	addiw	a5,a5,1
    8000628a:	17c2                	slli	a5,a5,0x30
    8000628c:	93c1                	srli	a5,a5,0x30
    8000628e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006292:	6898                	ld	a4,16(s1)
    80006294:	00275703          	lhu	a4,2(a4)
    80006298:	faf71ce3          	bne	a4,a5,80006250 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000629c:	0001c517          	auipc	a0,0x1c
    800062a0:	aec50513          	addi	a0,a0,-1300 # 80021d88 <disk+0x128>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	9e2080e7          	jalr	-1566(ra) # 80000c86 <release>
}
    800062ac:	60e2                	ld	ra,24(sp)
    800062ae:	6442                	ld	s0,16(sp)
    800062b0:	64a2                	ld	s1,8(sp)
    800062b2:	6105                	addi	sp,sp,32
    800062b4:	8082                	ret
      panic("virtio_disk_intr status");
    800062b6:	00002517          	auipc	a0,0x2
    800062ba:	5a250513          	addi	a0,a0,1442 # 80008858 <syscalls+0x408>
    800062be:	ffffa097          	auipc	ra,0xffffa
    800062c2:	27e080e7          	jalr	638(ra) # 8000053c <panic>
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
