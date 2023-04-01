
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8f813103          	ld	sp,-1800(sp) # 800088f8 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	90070713          	addi	a4,a4,-1792 # 80008950 <timer_scratch>
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
    80000066:	c5e78793          	addi	a5,a5,-930 # 80005cc0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca3f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	ddc78793          	addi	a5,a5,-548 # 80000e88 <main>
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
    8000012e:	414080e7          	jalr	1044(ra) # 8000253e <either_copyin>
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
    80000188:	90c50513          	addi	a0,a0,-1780 # 80010a90 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	8fc48493          	addi	s1,s1,-1796 # 80010a90 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	98c90913          	addi	s2,s2,-1652 # 80010b28 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	808080e7          	jalr	-2040(ra) # 800019bc <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	1cc080e7          	jalr	460(ra) # 80002388 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f16080e7          	jalr	-234(ra) # 800020e0 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	8b270713          	addi	a4,a4,-1870 # 80010a90 <cons>
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
    80000214:	2d8080e7          	jalr	728(ra) # 800024e8 <either_copyout>
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
    8000022c:	86850513          	addi	a0,a0,-1944 # 80010a90 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a6c080e7          	jalr	-1428(ra) # 80000c9c <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	85250513          	addi	a0,a0,-1966 # 80010a90 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a56080e7          	jalr	-1450(ra) # 80000c9c <release>
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
    80000272:	8af72d23          	sw	a5,-1862(a4) # 80010b28 <cons+0x98>
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
    800002cc:	7c850513          	addi	a0,a0,1992 # 80010a90 <cons>
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
    800002f2:	2a6080e7          	jalr	678(ra) # 80002594 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	79a50513          	addi	a0,a0,1946 # 80010a90 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	99e080e7          	jalr	-1634(ra) # 80000c9c <release>
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
    8000031e:	77670713          	addi	a4,a4,1910 # 80010a90 <cons>
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
    80000348:	74c78793          	addi	a5,a5,1868 # 80010a90 <cons>
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
    80000376:	7b67a783          	lw	a5,1974(a5) # 80010b28 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	70a70713          	addi	a4,a4,1802 # 80010a90 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	6fa48493          	addi	s1,s1,1786 # 80010a90 <cons>
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
    800003d6:	6be70713          	addi	a4,a4,1726 # 80010a90 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	74f72423          	sw	a5,1864(a4) # 80010b30 <cons+0xa0>
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
    80000412:	68278793          	addi	a5,a5,1666 # 80010a90 <cons>
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
    80000436:	6ec7ad23          	sw	a2,1786(a5) # 80010b2c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	6ee50513          	addi	a0,a0,1774 # 80010b28 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d02080e7          	jalr	-766(ra) # 80002144 <wakeup>
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
    80000460:	63450513          	addi	a0,a0,1588 # 80010a90 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	7b478793          	addi	a5,a5,1972 # 80020c28 <devsw>
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
    8000054c:	6007a423          	sw	zero,1544(a5) # 80010b50 <pr+0x18>
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
    8000056e:	b1650513          	addi	a0,a0,-1258 # 80008080 <digits+0x40>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	38f72a23          	sw	a5,916(a4) # 80008910 <panicked>
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
    800005bc:	598dad83          	lw	s11,1432(s11) # 80010b50 <pr+0x18>
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
    800005fa:	54250513          	addi	a0,a0,1346 # 80010b38 <pr>
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
    80000758:	3e450513          	addi	a0,a0,996 # 80010b38 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	540080e7          	jalr	1344(ra) # 80000c9c <release>
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
    80000774:	3c848493          	addi	s1,s1,968 # 80010b38 <pr>
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
    800007d4:	38850513          	addi	a0,a0,904 # 80010b58 <uart_tx_lock>
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
    80000800:	1147a783          	lw	a5,276(a5) # 80008910 <panicked>
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
    80000826:	41a080e7          	jalr	1050(ra) # 80000c3c <pop_off>
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
    80000838:	0e47b783          	ld	a5,228(a5) # 80008918 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	0e473703          	ld	a4,228(a4) # 80008920 <uart_tx_w>
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
    80000862:	2faa0a13          	addi	s4,s4,762 # 80010b58 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	0b248493          	addi	s1,s1,178 # 80008918 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	0b298993          	addi	s3,s3,178 # 80008920 <uart_tx_w>
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
    80000894:	8b4080e7          	jalr	-1868(ra) # 80002144 <wakeup>
    
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
    800008d0:	28c50513          	addi	a0,a0,652 # 80010b58 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0347a783          	lw	a5,52(a5) # 80008910 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	03a73703          	ld	a4,58(a4) # 80008920 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	02a7b783          	ld	a5,42(a5) # 80008918 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	25e98993          	addi	s3,s3,606 # 80010b58 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	01648493          	addi	s1,s1,22 # 80008918 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	01690913          	addi	s2,s2,22 # 80008920 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7c6080e7          	jalr	1990(ra) # 800020e0 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	22848493          	addi	s1,s1,552 # 80010b58 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	fce7be23          	sd	a4,-36(a5) # 80008920 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	346080e7          	jalr	838(ra) # 80000c9c <release>
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
    800009ba:	1a248493          	addi	s1,s1,418 # 80010b58 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2ca080e7          	jalr	714(ra) # 80000c9c <release>
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
    800009fc:	3c878793          	addi	a5,a5,968 # 80021dc0 <end>
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
    80000a14:	2d4080e7          	jalr	724(ra) # 80000ce4 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	17890913          	addi	s2,s2,376 # 80010b90 <kmem>
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
    80000a3a:	266080e7          	jalr	614(ra) # 80000c9c <release>
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
    80000aba:	0da50513          	addi	a0,a0,218 # 80010b90 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	2f650513          	addi	a0,a0,758 # 80021dc0 <end>
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
    80000af0:	0a448493          	addi	s1,s1,164 # 80010b90 <kmem>
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
    80000b08:	08c50513          	addi	a0,a0,140 # 80010b90 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	18e080e7          	jalr	398(ra) # 80000c9c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1c8080e7          	jalr	456(ra) # 80000ce4 <memset>
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
    80000b34:	06050513          	addi	a0,a0,96 # 80010b90 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	164080e7          	jalr	356(ra) # 80000c9c <release>
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
    80000b70:	e34080e7          	jalr	-460(ra) # 800019a0 <mycpu>
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
    80000ba2:	e02080e7          	jalr	-510(ra) # 800019a0 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	df6080e7          	jalr	-522(ra) # 800019a0 <mycpu>
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
    80000bc6:	dde080e7          	jalr	-546(ra) # 800019a0 <mycpu>
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
  if(holding(lk)){
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk)){
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
    80000c06:	d9e080e7          	jalr	-610(ra) # 800019a0 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    printf("Already have: %d\n", lk->cpu->proc->pid);
    80000c16:	689c                	ld	a5,16(s1)
    80000c18:	639c                	ld	a5,0(a5)
    80000c1a:	5b8c                	lw	a1,48(a5)
    80000c1c:	00007517          	auipc	a0,0x7
    80000c20:	45450513          	addi	a0,a0,1108 # 80008070 <digits+0x30>
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	962080e7          	jalr	-1694(ra) # 80000586 <printf>
    panic("acquire");
    80000c2c:	00007517          	auipc	a0,0x7
    80000c30:	45c50513          	addi	a0,a0,1116 # 80008088 <digits+0x48>
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	908080e7          	jalr	-1784(ra) # 8000053c <panic>

0000000080000c3c <pop_off>:

void
pop_off(void)
{
    80000c3c:	1141                	addi	sp,sp,-16
    80000c3e:	e406                	sd	ra,8(sp)
    80000c40:	e022                	sd	s0,0(sp)
    80000c42:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c44:	00001097          	auipc	ra,0x1
    80000c48:	d5c080e7          	jalr	-676(ra) # 800019a0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c50:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c52:	e78d                	bnez	a5,80000c7c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	02f05b63          	blez	a5,80000c8c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5a:	37fd                	addiw	a5,a5,-1
    80000c5c:	0007871b          	sext.w	a4,a5
    80000c60:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c62:	eb09                	bnez	a4,80000c74 <pop_off+0x38>
    80000c64:	5d7c                	lw	a5,124(a0)
    80000c66:	c799                	beqz	a5,80000c74 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c70:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c74:	60a2                	ld	ra,8(sp)
    80000c76:	6402                	ld	s0,0(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret
    panic("pop_off - interruptible");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	41450513          	addi	a0,a0,1044 # 80008090 <digits+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8b8080e7          	jalr	-1864(ra) # 8000053c <panic>
    panic("pop_off");
    80000c8c:	00007517          	auipc	a0,0x7
    80000c90:	41c50513          	addi	a0,a0,1052 # 800080a8 <digits+0x68>
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	8a8080e7          	jalr	-1880(ra) # 8000053c <panic>

0000000080000c9c <release>:
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
    80000ca6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	eb0080e7          	jalr	-336(ra) # 80000b58 <holding>
    80000cb0:	c115                	beqz	a0,80000cd4 <release+0x38>
  lk->cpu = 0;
    80000cb2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cba:	0f50000f          	fence	iorw,ow
    80000cbe:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f7a080e7          	jalr	-134(ra) # 80000c3c <pop_off>
}
    80000cca:	60e2                	ld	ra,24(sp)
    80000ccc:	6442                	ld	s0,16(sp)
    80000cce:	64a2                	ld	s1,8(sp)
    80000cd0:	6105                	addi	sp,sp,32
    80000cd2:	8082                	ret
    panic("release");
    80000cd4:	00007517          	auipc	a0,0x7
    80000cd8:	3dc50513          	addi	a0,a0,988 # 800080b0 <digits+0x70>
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	860080e7          	jalr	-1952(ra) # 8000053c <panic>

0000000080000ce4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e422                	sd	s0,8(sp)
    80000ce8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cea:	ca19                	beqz	a2,80000d00 <memset+0x1c>
    80000cec:	87aa                	mv	a5,a0
    80000cee:	1602                	slli	a2,a2,0x20
    80000cf0:	9201                	srli	a2,a2,0x20
    80000cf2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x12>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	c205                	beqz	a2,80000d66 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	02a5e263          	bltu	a1,a0,80000d6c <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d4c:	1602                	slli	a2,a2,0x20
    80000d4e:	9201                	srli	a2,a2,0x20
    80000d50:	00c587b3          	add	a5,a1,a2
{
    80000d54:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d56:	0585                	addi	a1,a1,1
    80000d58:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd241>
    80000d5a:	fff5c683          	lbu	a3,-1(a1)
    80000d5e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d62:	fef59ae3          	bne	a1,a5,80000d56 <memmove+0x16>

  return dst;
}
    80000d66:	6422                	ld	s0,8(sp)
    80000d68:	0141                	addi	sp,sp,16
    80000d6a:	8082                	ret
  if(s < d && s + n > d){
    80000d6c:	02061693          	slli	a3,a2,0x20
    80000d70:	9281                	srli	a3,a3,0x20
    80000d72:	00d58733          	add	a4,a1,a3
    80000d76:	fce57be3          	bgeu	a0,a4,80000d4c <memmove+0xc>
    d += n;
    80000d7a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d7c:	fff6079b          	addiw	a5,a2,-1
    80000d80:	1782                	slli	a5,a5,0x20
    80000d82:	9381                	srli	a5,a5,0x20
    80000d84:	fff7c793          	not	a5,a5
    80000d88:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8a:	177d                	addi	a4,a4,-1
    80000d8c:	16fd                	addi	a3,a3,-1
    80000d8e:	00074603          	lbu	a2,0(a4)
    80000d92:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d96:	fee79ae3          	bne	a5,a4,80000d8a <memmove+0x4a>
    80000d9a:	b7f1                	j	80000d66 <memmove+0x26>

0000000080000d9c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e406                	sd	ra,8(sp)
    80000da0:	e022                	sd	s0,0(sp)
    80000da2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da4:	00000097          	auipc	ra,0x0
    80000da8:	f9c080e7          	jalr	-100(ra) # 80000d40 <memmove>
}
    80000dac:	60a2                	ld	ra,8(sp)
    80000dae:	6402                	ld	s0,0(sp)
    80000db0:	0141                	addi	sp,sp,16
    80000db2:	8082                	ret

0000000080000db4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e422                	sd	s0,8(sp)
    80000db8:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dba:	ce11                	beqz	a2,80000dd6 <strncmp+0x22>
    80000dbc:	00054783          	lbu	a5,0(a0)
    80000dc0:	cf89                	beqz	a5,80000dda <strncmp+0x26>
    80000dc2:	0005c703          	lbu	a4,0(a1)
    80000dc6:	00f71a63          	bne	a4,a5,80000dda <strncmp+0x26>
    n--, p++, q++;
    80000dca:	367d                	addiw	a2,a2,-1
    80000dcc:	0505                	addi	a0,a0,1
    80000dce:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd0:	f675                	bnez	a2,80000dbc <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd2:	4501                	li	a0,0
    80000dd4:	a809                	j	80000de6 <strncmp+0x32>
    80000dd6:	4501                	li	a0,0
    80000dd8:	a039                	j	80000de6 <strncmp+0x32>
  if(n == 0)
    80000dda:	ca09                	beqz	a2,80000dec <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000ddc:	00054503          	lbu	a0,0(a0)
    80000de0:	0005c783          	lbu	a5,0(a1)
    80000de4:	9d1d                	subw	a0,a0,a5
}
    80000de6:	6422                	ld	s0,8(sp)
    80000de8:	0141                	addi	sp,sp,16
    80000dea:	8082                	ret
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	bfe5                	j	80000de6 <strncmp+0x32>

0000000080000df0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df0:	1141                	addi	sp,sp,-16
    80000df2:	e422                	sd	s0,8(sp)
    80000df4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df6:	87aa                	mv	a5,a0
    80000df8:	86b2                	mv	a3,a2
    80000dfa:	367d                	addiw	a2,a2,-1
    80000dfc:	00d05963          	blez	a3,80000e0e <strncpy+0x1e>
    80000e00:	0785                	addi	a5,a5,1
    80000e02:	0005c703          	lbu	a4,0(a1)
    80000e06:	fee78fa3          	sb	a4,-1(a5)
    80000e0a:	0585                	addi	a1,a1,1
    80000e0c:	f775                	bnez	a4,80000df8 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e0e:	873e                	mv	a4,a5
    80000e10:	9fb5                	addw	a5,a5,a3
    80000e12:	37fd                	addiw	a5,a5,-1
    80000e14:	00c05963          	blez	a2,80000e26 <strncpy+0x36>
    *s++ = 0;
    80000e18:	0705                	addi	a4,a4,1
    80000e1a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e1e:	40e786bb          	subw	a3,a5,a4
    80000e22:	fed04be3          	bgtz	a3,80000e18 <strncpy+0x28>
  return os;
}
    80000e26:	6422                	ld	s0,8(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e422                	sd	s0,8(sp)
    80000e30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e32:	02c05363          	blez	a2,80000e58 <safestrcpy+0x2c>
    80000e36:	fff6069b          	addiw	a3,a2,-1
    80000e3a:	1682                	slli	a3,a3,0x20
    80000e3c:	9281                	srli	a3,a3,0x20
    80000e3e:	96ae                	add	a3,a3,a1
    80000e40:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e42:	00d58963          	beq	a1,a3,80000e54 <safestrcpy+0x28>
    80000e46:	0585                	addi	a1,a1,1
    80000e48:	0785                	addi	a5,a5,1
    80000e4a:	fff5c703          	lbu	a4,-1(a1)
    80000e4e:	fee78fa3          	sb	a4,-1(a5)
    80000e52:	fb65                	bnez	a4,80000e42 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e54:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret

0000000080000e5e <strlen>:

int
strlen(const char *s)
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e422                	sd	s0,8(sp)
    80000e62:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e64:	00054783          	lbu	a5,0(a0)
    80000e68:	cf91                	beqz	a5,80000e84 <strlen+0x26>
    80000e6a:	0505                	addi	a0,a0,1
    80000e6c:	87aa                	mv	a5,a0
    80000e6e:	86be                	mv	a3,a5
    80000e70:	0785                	addi	a5,a5,1
    80000e72:	fff7c703          	lbu	a4,-1(a5)
    80000e76:	ff65                	bnez	a4,80000e6e <strlen+0x10>
    80000e78:	40a6853b          	subw	a0,a3,a0
    80000e7c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e7e:	6422                	ld	s0,8(sp)
    80000e80:	0141                	addi	sp,sp,16
    80000e82:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e84:	4501                	li	a0,0
    80000e86:	bfe5                	j	80000e7e <strlen+0x20>

0000000080000e88 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e88:	1141                	addi	sp,sp,-16
    80000e8a:	e406                	sd	ra,8(sp)
    80000e8c:	e022                	sd	s0,0(sp)
    80000e8e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	b00080e7          	jalr	-1280(ra) # 80001990 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e98:	00008717          	auipc	a4,0x8
    80000e9c:	a9070713          	addi	a4,a4,-1392 # 80008928 <started>
  if(cpuid() == 0){
    80000ea0:	c139                	beqz	a0,80000ee6 <main+0x5e>
    while(started == 0)
    80000ea2:	431c                	lw	a5,0(a4)
    80000ea4:	2781                	sext.w	a5,a5
    80000ea6:	dff5                	beqz	a5,80000ea2 <main+0x1a>
      ;
    __sync_synchronize();
    80000ea8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eac:	00001097          	auipc	ra,0x1
    80000eb0:	ae4080e7          	jalr	-1308(ra) # 80001990 <cpuid>
    80000eb4:	85aa                	mv	a1,a0
    80000eb6:	00007517          	auipc	a0,0x7
    80000eba:	21a50513          	addi	a0,a0,538 # 800080d0 <digits+0x90>
    80000ebe:	fffff097          	auipc	ra,0xfffff
    80000ec2:	6c8080e7          	jalr	1736(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000ec6:	00000097          	auipc	ra,0x0
    80000eca:	0d8080e7          	jalr	216(ra) # 80000f9e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ece:	00002097          	auipc	ra,0x2
    80000ed2:	808080e7          	jalr	-2040(ra) # 800026d6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed6:	00005097          	auipc	ra,0x5
    80000eda:	e2a080e7          	jalr	-470(ra) # 80005d00 <plicinithart>
  }

  scheduler();        
    80000ede:	00001097          	auipc	ra,0x1
    80000ee2:	fdc080e7          	jalr	-36(ra) # 80001eba <scheduler>
    consoleinit();
    80000ee6:	fffff097          	auipc	ra,0xfffff
    80000eea:	566080e7          	jalr	1382(ra) # 8000044c <consoleinit>
    printfinit();
    80000eee:	00000097          	auipc	ra,0x0
    80000ef2:	878080e7          	jalr	-1928(ra) # 80000766 <printfinit>
    printf("\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	18a50513          	addi	a0,a0,394 # 80008080 <digits+0x40>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	688080e7          	jalr	1672(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1b250513          	addi	a0,a0,434 # 800080b8 <digits+0x78>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	678080e7          	jalr	1656(ra) # 80000586 <printf>
    printf("\n");
    80000f16:	00007517          	auipc	a0,0x7
    80000f1a:	16a50513          	addi	a0,a0,362 # 80008080 <digits+0x40>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	668080e7          	jalr	1640(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	b80080e7          	jalr	-1152(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	326080e7          	jalr	806(ra) # 80001254 <kvminit>
    kvminithart();   // turn on paging
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	068080e7          	jalr	104(ra) # 80000f9e <kvminithart>
    procinit();      // process table
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	99e080e7          	jalr	-1634(ra) # 800018dc <procinit>
    trapinit();      // trap vectors
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	768080e7          	jalr	1896(ra) # 800026ae <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4e:	00001097          	auipc	ra,0x1
    80000f52:	788080e7          	jalr	1928(ra) # 800026d6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	d94080e7          	jalr	-620(ra) # 80005cea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5e:	00005097          	auipc	ra,0x5
    80000f62:	da2080e7          	jalr	-606(ra) # 80005d00 <plicinithart>
    binit();         // buffer cache
    80000f66:	00002097          	auipc	ra,0x2
    80000f6a:	f9c080e7          	jalr	-100(ra) # 80002f02 <binit>
    iinit();         // inode table
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	63a080e7          	jalr	1594(ra) # 800035a8 <iinit>
    fileinit();      // file table
    80000f76:	00003097          	auipc	ra,0x3
    80000f7a:	5b0080e7          	jalr	1456(ra) # 80004526 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	e8a080e7          	jalr	-374(ra) # 80005e08 <virtio_disk_init>
    userinit();      // first user process
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	d16080e7          	jalr	-746(ra) # 80001c9c <userinit>
    __sync_synchronize();
    80000f8e:	0ff0000f          	fence
    started = 1;
    80000f92:	4785                	li	a5,1
    80000f94:	00008717          	auipc	a4,0x8
    80000f98:	98f72a23          	sw	a5,-1644(a4) # 80008928 <started>
    80000f9c:	b789                	j	80000ede <main+0x56>

0000000080000f9e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f9e:	1141                	addi	sp,sp,-16
    80000fa0:	e422                	sd	s0,8(sp)
    80000fa2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa8:	00008797          	auipc	a5,0x8
    80000fac:	9887b783          	ld	a5,-1656(a5) # 80008930 <kernel_pagetable>
    80000fb0:	83b1                	srli	a5,a5,0xc
    80000fb2:	577d                	li	a4,-1
    80000fb4:	177e                	slli	a4,a4,0x3f
    80000fb6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fbc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fc0:	6422                	ld	s0,8(sp)
    80000fc2:	0141                	addi	sp,sp,16
    80000fc4:	8082                	ret

0000000080000fc6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc6:	7139                	addi	sp,sp,-64
    80000fc8:	fc06                	sd	ra,56(sp)
    80000fca:	f822                	sd	s0,48(sp)
    80000fcc:	f426                	sd	s1,40(sp)
    80000fce:	f04a                	sd	s2,32(sp)
    80000fd0:	ec4e                	sd	s3,24(sp)
    80000fd2:	e852                	sd	s4,16(sp)
    80000fd4:	e456                	sd	s5,8(sp)
    80000fd6:	e05a                	sd	s6,0(sp)
    80000fd8:	0080                	addi	s0,sp,64
    80000fda:	84aa                	mv	s1,a0
    80000fdc:	89ae                	mv	s3,a1
    80000fde:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe0:	57fd                	li	a5,-1
    80000fe2:	83e9                	srli	a5,a5,0x1a
    80000fe4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe8:	04b7f263          	bgeu	a5,a1,8000102c <walk+0x66>
    panic("walk");
    80000fec:	00007517          	auipc	a0,0x7
    80000ff0:	0fc50513          	addi	a0,a0,252 # 800080e8 <digits+0xa8>
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	548080e7          	jalr	1352(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffc:	060a8663          	beqz	s5,80001068 <walk+0xa2>
    80001000:	00000097          	auipc	ra,0x0
    80001004:	ae2080e7          	jalr	-1310(ra) # 80000ae2 <kalloc>
    80001008:	84aa                	mv	s1,a0
    8000100a:	c529                	beqz	a0,80001054 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100c:	6605                	lui	a2,0x1
    8000100e:	4581                	li	a1,0
    80001010:	00000097          	auipc	ra,0x0
    80001014:	cd4080e7          	jalr	-812(ra) # 80000ce4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001018:	00c4d793          	srli	a5,s1,0xc
    8000101c:	07aa                	slli	a5,a5,0xa
    8000101e:	0017e793          	ori	a5,a5,1
    80001022:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001026:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd237>
    80001028:	036a0063          	beq	s4,s6,80001048 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102c:	0149d933          	srl	s2,s3,s4
    80001030:	1ff97913          	andi	s2,s2,511
    80001034:	090e                	slli	s2,s2,0x3
    80001036:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001038:	00093483          	ld	s1,0(s2)
    8000103c:	0014f793          	andi	a5,s1,1
    80001040:	dfd5                	beqz	a5,80000ffc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001042:	80a9                	srli	s1,s1,0xa
    80001044:	04b2                	slli	s1,s1,0xc
    80001046:	b7c5                	j	80001026 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001048:	00c9d513          	srli	a0,s3,0xc
    8000104c:	1ff57513          	andi	a0,a0,511
    80001050:	050e                	slli	a0,a0,0x3
    80001052:	9526                	add	a0,a0,s1
}
    80001054:	70e2                	ld	ra,56(sp)
    80001056:	7442                	ld	s0,48(sp)
    80001058:	74a2                	ld	s1,40(sp)
    8000105a:	7902                	ld	s2,32(sp)
    8000105c:	69e2                	ld	s3,24(sp)
    8000105e:	6a42                	ld	s4,16(sp)
    80001060:	6aa2                	ld	s5,8(sp)
    80001062:	6b02                	ld	s6,0(sp)
    80001064:	6121                	addi	sp,sp,64
    80001066:	8082                	ret
        return 0;
    80001068:	4501                	li	a0,0
    8000106a:	b7ed                	j	80001054 <walk+0x8e>

000000008000106c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106c:	57fd                	li	a5,-1
    8000106e:	83e9                	srli	a5,a5,0x1a
    80001070:	00b7f463          	bgeu	a5,a1,80001078 <walkaddr+0xc>
    return 0;
    80001074:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001076:	8082                	ret
{
    80001078:	1141                	addi	sp,sp,-16
    8000107a:	e406                	sd	ra,8(sp)
    8000107c:	e022                	sd	s0,0(sp)
    8000107e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001080:	4601                	li	a2,0
    80001082:	00000097          	auipc	ra,0x0
    80001086:	f44080e7          	jalr	-188(ra) # 80000fc6 <walk>
  if(pte == 0)
    8000108a:	c105                	beqz	a0,800010aa <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000108e:	0117f693          	andi	a3,a5,17
    80001092:	4745                	li	a4,17
    return 0;
    80001094:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001096:	00e68663          	beq	a3,a4,800010a2 <walkaddr+0x36>
}
    8000109a:	60a2                	ld	ra,8(sp)
    8000109c:	6402                	ld	s0,0(sp)
    8000109e:	0141                	addi	sp,sp,16
    800010a0:	8082                	ret
  pa = PTE2PA(*pte);
    800010a2:	83a9                	srli	a5,a5,0xa
    800010a4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010a8:	bfcd                	j	8000109a <walkaddr+0x2e>
    return 0;
    800010aa:	4501                	li	a0,0
    800010ac:	b7fd                	j	8000109a <walkaddr+0x2e>

00000000800010ae <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ae:	715d                	addi	sp,sp,-80
    800010b0:	e486                	sd	ra,72(sp)
    800010b2:	e0a2                	sd	s0,64(sp)
    800010b4:	fc26                	sd	s1,56(sp)
    800010b6:	f84a                	sd	s2,48(sp)
    800010b8:	f44e                	sd	s3,40(sp)
    800010ba:	f052                	sd	s4,32(sp)
    800010bc:	ec56                	sd	s5,24(sp)
    800010be:	e85a                	sd	s6,16(sp)
    800010c0:	e45e                	sd	s7,8(sp)
    800010c2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c4:	c639                	beqz	a2,80001112 <mappages+0x64>
    800010c6:	8aaa                	mv	s5,a0
    800010c8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ca:	777d                	lui	a4,0xfffff
    800010cc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010d0:	fff58993          	addi	s3,a1,-1
    800010d4:	99b2                	add	s3,s3,a2
    800010d6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010da:	893e                	mv	s2,a5
    800010dc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e0:	6b85                	lui	s7,0x1
    800010e2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e6:	4605                	li	a2,1
    800010e8:	85ca                	mv	a1,s2
    800010ea:	8556                	mv	a0,s5
    800010ec:	00000097          	auipc	ra,0x0
    800010f0:	eda080e7          	jalr	-294(ra) # 80000fc6 <walk>
    800010f4:	cd1d                	beqz	a0,80001132 <mappages+0x84>
    if(*pte & PTE_V)
    800010f6:	611c                	ld	a5,0(a0)
    800010f8:	8b85                	andi	a5,a5,1
    800010fa:	e785                	bnez	a5,80001122 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010fc:	80b1                	srli	s1,s1,0xc
    800010fe:	04aa                	slli	s1,s1,0xa
    80001100:	0164e4b3          	or	s1,s1,s6
    80001104:	0014e493          	ori	s1,s1,1
    80001108:	e104                	sd	s1,0(a0)
    if(a == last)
    8000110a:	05390063          	beq	s2,s3,8000114a <mappages+0x9c>
    a += PGSIZE;
    8000110e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001110:	bfc9                	j	800010e2 <mappages+0x34>
    panic("mappages: size");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fde50513          	addi	a0,a0,-34 # 800080f0 <digits+0xb0>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	422080e7          	jalr	1058(ra) # 8000053c <panic>
      panic("mappages: remap");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	fde50513          	addi	a0,a0,-34 # 80008100 <digits+0xc0>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	412080e7          	jalr	1042(ra) # 8000053c <panic>
      return -1;
    80001132:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001134:	60a6                	ld	ra,72(sp)
    80001136:	6406                	ld	s0,64(sp)
    80001138:	74e2                	ld	s1,56(sp)
    8000113a:	7942                	ld	s2,48(sp)
    8000113c:	79a2                	ld	s3,40(sp)
    8000113e:	7a02                	ld	s4,32(sp)
    80001140:	6ae2                	ld	s5,24(sp)
    80001142:	6b42                	ld	s6,16(sp)
    80001144:	6ba2                	ld	s7,8(sp)
    80001146:	6161                	addi	sp,sp,80
    80001148:	8082                	ret
  return 0;
    8000114a:	4501                	li	a0,0
    8000114c:	b7e5                	j	80001134 <mappages+0x86>

000000008000114e <kvmmap>:
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e406                	sd	ra,8(sp)
    80001152:	e022                	sd	s0,0(sp)
    80001154:	0800                	addi	s0,sp,16
    80001156:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001158:	86b2                	mv	a3,a2
    8000115a:	863e                	mv	a2,a5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	f52080e7          	jalr	-174(ra) # 800010ae <mappages>
    80001164:	e509                	bnez	a0,8000116e <kvmmap+0x20>
}
    80001166:	60a2                	ld	ra,8(sp)
    80001168:	6402                	ld	s0,0(sp)
    8000116a:	0141                	addi	sp,sp,16
    8000116c:	8082                	ret
    panic("kvmmap");
    8000116e:	00007517          	auipc	a0,0x7
    80001172:	fa250513          	addi	a0,a0,-94 # 80008110 <digits+0xd0>
    80001176:	fffff097          	auipc	ra,0xfffff
    8000117a:	3c6080e7          	jalr	966(ra) # 8000053c <panic>

000000008000117e <kvmmake>:
{
    8000117e:	1101                	addi	sp,sp,-32
    80001180:	ec06                	sd	ra,24(sp)
    80001182:	e822                	sd	s0,16(sp)
    80001184:	e426                	sd	s1,8(sp)
    80001186:	e04a                	sd	s2,0(sp)
    80001188:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	958080e7          	jalr	-1704(ra) # 80000ae2 <kalloc>
    80001192:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001194:	6605                	lui	a2,0x1
    80001196:	4581                	li	a1,0
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	b4c080e7          	jalr	-1204(ra) # 80000ce4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10000637          	lui	a2,0x10000
    800011a8:	100005b7          	lui	a1,0x10000
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	fa0080e7          	jalr	-96(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	6685                	lui	a3,0x1
    800011ba:	10001637          	lui	a2,0x10001
    800011be:	100015b7          	lui	a1,0x10001
    800011c2:	8526                	mv	a0,s1
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f8a080e7          	jalr	-118(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011cc:	4719                	li	a4,6
    800011ce:	004006b7          	lui	a3,0x400
    800011d2:	0c000637          	lui	a2,0xc000
    800011d6:	0c0005b7          	lui	a1,0xc000
    800011da:	8526                	mv	a0,s1
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	f72080e7          	jalr	-142(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e4:	00007917          	auipc	s2,0x7
    800011e8:	e1c90913          	addi	s2,s2,-484 # 80008000 <etext>
    800011ec:	4729                	li	a4,10
    800011ee:	80007697          	auipc	a3,0x80007
    800011f2:	e1268693          	addi	a3,a3,-494 # 8000 <_entry-0x7fff8000>
    800011f6:	4605                	li	a2,1
    800011f8:	067e                	slli	a2,a2,0x1f
    800011fa:	85b2                	mv	a1,a2
    800011fc:	8526                	mv	a0,s1
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f50080e7          	jalr	-176(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001206:	4719                	li	a4,6
    80001208:	46c5                	li	a3,17
    8000120a:	06ee                	slli	a3,a3,0x1b
    8000120c:	412686b3          	sub	a3,a3,s2
    80001210:	864a                	mv	a2,s2
    80001212:	85ca                	mv	a1,s2
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f38080e7          	jalr	-200(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000121e:	4729                	li	a4,10
    80001220:	6685                	lui	a3,0x1
    80001222:	00006617          	auipc	a2,0x6
    80001226:	dde60613          	addi	a2,a2,-546 # 80007000 <_trampoline>
    8000122a:	040005b7          	lui	a1,0x4000
    8000122e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001230:	05b2                	slli	a1,a1,0xc
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f1a080e7          	jalr	-230(ra) # 8000114e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	608080e7          	jalr	1544(ra) # 80001846 <proc_mapstacks>
}
    80001246:	8526                	mv	a0,s1
    80001248:	60e2                	ld	ra,24(sp)
    8000124a:	6442                	ld	s0,16(sp)
    8000124c:	64a2                	ld	s1,8(sp)
    8000124e:	6902                	ld	s2,0(sp)
    80001250:	6105                	addi	sp,sp,32
    80001252:	8082                	ret

0000000080001254 <kvminit>:
{
    80001254:	1141                	addi	sp,sp,-16
    80001256:	e406                	sd	ra,8(sp)
    80001258:	e022                	sd	s0,0(sp)
    8000125a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f22080e7          	jalr	-222(ra) # 8000117e <kvmmake>
    80001264:	00007797          	auipc	a5,0x7
    80001268:	6ca7b623          	sd	a0,1740(a5) # 80008930 <kernel_pagetable>
}
    8000126c:	60a2                	ld	ra,8(sp)
    8000126e:	6402                	ld	s0,0(sp)
    80001270:	0141                	addi	sp,sp,16
    80001272:	8082                	ret

0000000080001274 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001274:	715d                	addi	sp,sp,-80
    80001276:	e486                	sd	ra,72(sp)
    80001278:	e0a2                	sd	s0,64(sp)
    8000127a:	fc26                	sd	s1,56(sp)
    8000127c:	f84a                	sd	s2,48(sp)
    8000127e:	f44e                	sd	s3,40(sp)
    80001280:	f052                	sd	s4,32(sp)
    80001282:	ec56                	sd	s5,24(sp)
    80001284:	e85a                	sd	s6,16(sp)
    80001286:	e45e                	sd	s7,8(sp)
    80001288:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128a:	03459793          	slli	a5,a1,0x34
    8000128e:	e795                	bnez	a5,800012ba <uvmunmap+0x46>
    80001290:	8a2a                	mv	s4,a0
    80001292:	892e                	mv	s2,a1
    80001294:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	0632                	slli	a2,a2,0xc
    80001298:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000129e:	6b05                	lui	s6,0x1
    800012a0:	0735e263          	bltu	a1,s3,80001304 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a4:	60a6                	ld	ra,72(sp)
    800012a6:	6406                	ld	s0,64(sp)
    800012a8:	74e2                	ld	s1,56(sp)
    800012aa:	7942                	ld	s2,48(sp)
    800012ac:	79a2                	ld	s3,40(sp)
    800012ae:	7a02                	ld	s4,32(sp)
    800012b0:	6ae2                	ld	s5,24(sp)
    800012b2:	6b42                	ld	s6,16(sp)
    800012b4:	6ba2                	ld	s7,8(sp)
    800012b6:	6161                	addi	sp,sp,80
    800012b8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27a080e7          	jalr	634(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e6650513          	addi	a0,a0,-410 # 80008130 <digits+0xf0>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26a080e7          	jalr	618(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25a080e7          	jalr	602(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e6e50513          	addi	a0,a0,-402 # 80008158 <digits+0x118>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24a080e7          	jalr	586(ra) # 8000053c <panic>
    *pte = 0;
    800012fa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fe:	995a                	add	s2,s2,s6
    80001300:	fb3972e3          	bgeu	s2,s3,800012a4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001304:	4601                	li	a2,0
    80001306:	85ca                	mv	a1,s2
    80001308:	8552                	mv	a0,s4
    8000130a:	00000097          	auipc	ra,0x0
    8000130e:	cbc080e7          	jalr	-836(ra) # 80000fc6 <walk>
    80001312:	84aa                	mv	s1,a0
    80001314:	d95d                	beqz	a0,800012ca <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001316:	6108                	ld	a0,0(a0)
    80001318:	00157793          	andi	a5,a0,1
    8000131c:	dfdd                	beqz	a5,800012da <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000131e:	3ff57793          	andi	a5,a0,1023
    80001322:	fd7784e3          	beq	a5,s7,800012ea <uvmunmap+0x76>
    if(do_free){
    80001326:	fc0a8ae3          	beqz	s5,800012fa <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000132a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000132c:	0532                	slli	a0,a0,0xc
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	6b6080e7          	jalr	1718(ra) # 800009e4 <kfree>
    80001336:	b7d1                	j	800012fa <uvmunmap+0x86>

0000000080001338 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001338:	1101                	addi	sp,sp,-32
    8000133a:	ec06                	sd	ra,24(sp)
    8000133c:	e822                	sd	s0,16(sp)
    8000133e:	e426                	sd	s1,8(sp)
    80001340:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001342:	fffff097          	auipc	ra,0xfffff
    80001346:	7a0080e7          	jalr	1952(ra) # 80000ae2 <kalloc>
    8000134a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134c:	c519                	beqz	a0,8000135a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000134e:	6605                	lui	a2,0x1
    80001350:	4581                	li	a1,0
    80001352:	00000097          	auipc	ra,0x0
    80001356:	992080e7          	jalr	-1646(ra) # 80000ce4 <memset>
  return pagetable;
}
    8000135a:	8526                	mv	a0,s1
    8000135c:	60e2                	ld	ra,24(sp)
    8000135e:	6442                	ld	s0,16(sp)
    80001360:	64a2                	ld	s1,8(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001366:	7179                	addi	sp,sp,-48
    80001368:	f406                	sd	ra,40(sp)
    8000136a:	f022                	sd	s0,32(sp)
    8000136c:	ec26                	sd	s1,24(sp)
    8000136e:	e84a                	sd	s2,16(sp)
    80001370:	e44e                	sd	s3,8(sp)
    80001372:	e052                	sd	s4,0(sp)
    80001374:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001376:	6785                	lui	a5,0x1
    80001378:	04f67863          	bgeu	a2,a5,800013c8 <uvmfirst+0x62>
    8000137c:	8a2a                	mv	s4,a0
    8000137e:	89ae                	mv	s3,a1
    80001380:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	760080e7          	jalr	1888(ra) # 80000ae2 <kalloc>
    8000138a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	00000097          	auipc	ra,0x0
    80001394:	954080e7          	jalr	-1708(ra) # 80000ce4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001398:	4779                	li	a4,30
    8000139a:	86ca                	mv	a3,s2
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	8552                	mv	a0,s4
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	d0c080e7          	jalr	-756(ra) # 800010ae <mappages>
  memmove(mem, src, sz);
    800013aa:	8626                	mv	a2,s1
    800013ac:	85ce                	mv	a1,s3
    800013ae:	854a                	mv	a0,s2
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	990080e7          	jalr	-1648(ra) # 80000d40 <memmove>
}
    800013b8:	70a2                	ld	ra,40(sp)
    800013ba:	7402                	ld	s0,32(sp)
    800013bc:	64e2                	ld	s1,24(sp)
    800013be:	6942                	ld	s2,16(sp)
    800013c0:	69a2                	ld	s3,8(sp)
    800013c2:	6a02                	ld	s4,0(sp)
    800013c4:	6145                	addi	sp,sp,48
    800013c6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c8:	00007517          	auipc	a0,0x7
    800013cc:	da850513          	addi	a0,a0,-600 # 80008170 <digits+0x130>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	16c080e7          	jalr	364(ra) # 8000053c <panic>

00000000800013d8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d8:	1101                	addi	sp,sp,-32
    800013da:	ec06                	sd	ra,24(sp)
    800013dc:	e822                	sd	s0,16(sp)
    800013de:	e426                	sd	s1,8(sp)
    800013e0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e4:	00b67d63          	bgeu	a2,a1,800013fe <uvmdealloc+0x26>
    800013e8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ea:	6785                	lui	a5,0x1
    800013ec:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013ee:	00f60733          	add	a4,a2,a5
    800013f2:	76fd                	lui	a3,0xfffff
    800013f4:	8f75                	and	a4,a4,a3
    800013f6:	97ae                	add	a5,a5,a1
    800013f8:	8ff5                	and	a5,a5,a3
    800013fa:	00f76863          	bltu	a4,a5,8000140a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013fe:	8526                	mv	a0,s1
    80001400:	60e2                	ld	ra,24(sp)
    80001402:	6442                	ld	s0,16(sp)
    80001404:	64a2                	ld	s1,8(sp)
    80001406:	6105                	addi	sp,sp,32
    80001408:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140a:	8f99                	sub	a5,a5,a4
    8000140c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000140e:	4685                	li	a3,1
    80001410:	0007861b          	sext.w	a2,a5
    80001414:	85ba                	mv	a1,a4
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	e5e080e7          	jalr	-418(ra) # 80001274 <uvmunmap>
    8000141e:	b7c5                	j	800013fe <uvmdealloc+0x26>

0000000080001420 <uvmalloc>:
  if(newsz < oldsz)
    80001420:	0ab66563          	bltu	a2,a1,800014ca <uvmalloc+0xaa>
{
    80001424:	7139                	addi	sp,sp,-64
    80001426:	fc06                	sd	ra,56(sp)
    80001428:	f822                	sd	s0,48(sp)
    8000142a:	f426                	sd	s1,40(sp)
    8000142c:	f04a                	sd	s2,32(sp)
    8000142e:	ec4e                	sd	s3,24(sp)
    80001430:	e852                	sd	s4,16(sp)
    80001432:	e456                	sd	s5,8(sp)
    80001434:	e05a                	sd	s6,0(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6785                	lui	a5,0x1
    8000143e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001440:	95be                	add	a1,a1,a5
    80001442:	77fd                	lui	a5,0xfffff
    80001444:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f363          	bgeu	s3,a2,800014ce <uvmalloc+0xae>
    8000144c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000144e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001452:	fffff097          	auipc	ra,0xfffff
    80001456:	690080e7          	jalr	1680(ra) # 80000ae2 <kalloc>
    8000145a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000145c:	c51d                	beqz	a0,8000148a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000145e:	6605                	lui	a2,0x1
    80001460:	4581                	li	a1,0
    80001462:	00000097          	auipc	ra,0x0
    80001466:	882080e7          	jalr	-1918(ra) # 80000ce4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000146a:	875a                	mv	a4,s6
    8000146c:	86a6                	mv	a3,s1
    8000146e:	6605                	lui	a2,0x1
    80001470:	85ca                	mv	a1,s2
    80001472:	8556                	mv	a0,s5
    80001474:	00000097          	auipc	ra,0x0
    80001478:	c3a080e7          	jalr	-966(ra) # 800010ae <mappages>
    8000147c:	e90d                	bnez	a0,800014ae <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147e:	6785                	lui	a5,0x1
    80001480:	993e                	add	s2,s2,a5
    80001482:	fd4968e3          	bltu	s2,s4,80001452 <uvmalloc+0x32>
  return newsz;
    80001486:	8552                	mv	a0,s4
    80001488:	a809                	j	8000149a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000148a:	864e                	mv	a2,s3
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8556                	mv	a0,s5
    80001490:	00000097          	auipc	ra,0x0
    80001494:	f48080e7          	jalr	-184(ra) # 800013d8 <uvmdealloc>
      return 0;
    80001498:	4501                	li	a0,0
}
    8000149a:	70e2                	ld	ra,56(sp)
    8000149c:	7442                	ld	s0,48(sp)
    8000149e:	74a2                	ld	s1,40(sp)
    800014a0:	7902                	ld	s2,32(sp)
    800014a2:	69e2                	ld	s3,24(sp)
    800014a4:	6a42                	ld	s4,16(sp)
    800014a6:	6aa2                	ld	s5,8(sp)
    800014a8:	6b02                	ld	s6,0(sp)
    800014aa:	6121                	addi	sp,sp,64
    800014ac:	8082                	ret
      kfree(mem);
    800014ae:	8526                	mv	a0,s1
    800014b0:	fffff097          	auipc	ra,0xfffff
    800014b4:	534080e7          	jalr	1332(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b8:	864e                	mv	a2,s3
    800014ba:	85ca                	mv	a1,s2
    800014bc:	8556                	mv	a0,s5
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	f1a080e7          	jalr	-230(ra) # 800013d8 <uvmdealloc>
      return 0;
    800014c6:	4501                	li	a0,0
    800014c8:	bfc9                	j	8000149a <uvmalloc+0x7a>
    return oldsz;
    800014ca:	852e                	mv	a0,a1
}
    800014cc:	8082                	ret
  return newsz;
    800014ce:	8532                	mv	a0,a2
    800014d0:	b7e9                	j	8000149a <uvmalloc+0x7a>

00000000800014d2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014d2:	7179                	addi	sp,sp,-48
    800014d4:	f406                	sd	ra,40(sp)
    800014d6:	f022                	sd	s0,32(sp)
    800014d8:	ec26                	sd	s1,24(sp)
    800014da:	e84a                	sd	s2,16(sp)
    800014dc:	e44e                	sd	s3,8(sp)
    800014de:	e052                	sd	s4,0(sp)
    800014e0:	1800                	addi	s0,sp,48
    800014e2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014e4:	84aa                	mv	s1,a0
    800014e6:	6905                	lui	s2,0x1
    800014e8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ea:	4985                	li	s3,1
    800014ec:	a829                	j	80001506 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ee:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014f0:	00c79513          	slli	a0,a5,0xc
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	fde080e7          	jalr	-34(ra) # 800014d2 <freewalk>
      pagetable[i] = 0;
    800014fc:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001500:	04a1                	addi	s1,s1,8
    80001502:	03248163          	beq	s1,s2,80001524 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001506:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001508:	00f7f713          	andi	a4,a5,15
    8000150c:	ff3701e3          	beq	a4,s3,800014ee <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001510:	8b85                	andi	a5,a5,1
    80001512:	d7fd                	beqz	a5,80001500 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001514:	00007517          	auipc	a0,0x7
    80001518:	c7c50513          	addi	a0,a0,-900 # 80008190 <digits+0x150>
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	020080e7          	jalr	32(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001524:	8552                	mv	a0,s4
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	4be080e7          	jalr	1214(ra) # 800009e4 <kfree>
}
    8000152e:	70a2                	ld	ra,40(sp)
    80001530:	7402                	ld	s0,32(sp)
    80001532:	64e2                	ld	s1,24(sp)
    80001534:	6942                	ld	s2,16(sp)
    80001536:	69a2                	ld	s3,8(sp)
    80001538:	6a02                	ld	s4,0(sp)
    8000153a:	6145                	addi	sp,sp,48
    8000153c:	8082                	ret

000000008000153e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000153e:	1101                	addi	sp,sp,-32
    80001540:	ec06                	sd	ra,24(sp)
    80001542:	e822                	sd	s0,16(sp)
    80001544:	e426                	sd	s1,8(sp)
    80001546:	1000                	addi	s0,sp,32
    80001548:	84aa                	mv	s1,a0
  if(sz > 0)
    8000154a:	e999                	bnez	a1,80001560 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000154c:	8526                	mv	a0,s1
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	f84080e7          	jalr	-124(ra) # 800014d2 <freewalk>
}
    80001556:	60e2                	ld	ra,24(sp)
    80001558:	6442                	ld	s0,16(sp)
    8000155a:	64a2                	ld	s1,8(sp)
    8000155c:	6105                	addi	sp,sp,32
    8000155e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001560:	6785                	lui	a5,0x1
    80001562:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001564:	95be                	add	a1,a1,a5
    80001566:	4685                	li	a3,1
    80001568:	00c5d613          	srli	a2,a1,0xc
    8000156c:	4581                	li	a1,0
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	d06080e7          	jalr	-762(ra) # 80001274 <uvmunmap>
    80001576:	bfd9                	j	8000154c <uvmfree+0xe>

0000000080001578 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001578:	c679                	beqz	a2,80001646 <uvmcopy+0xce>
{
    8000157a:	715d                	addi	sp,sp,-80
    8000157c:	e486                	sd	ra,72(sp)
    8000157e:	e0a2                	sd	s0,64(sp)
    80001580:	fc26                	sd	s1,56(sp)
    80001582:	f84a                	sd	s2,48(sp)
    80001584:	f44e                	sd	s3,40(sp)
    80001586:	f052                	sd	s4,32(sp)
    80001588:	ec56                	sd	s5,24(sp)
    8000158a:	e85a                	sd	s6,16(sp)
    8000158c:	e45e                	sd	s7,8(sp)
    8000158e:	0880                	addi	s0,sp,80
    80001590:	8b2a                	mv	s6,a0
    80001592:	8aae                	mv	s5,a1
    80001594:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001596:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001598:	4601                	li	a2,0
    8000159a:	85ce                	mv	a1,s3
    8000159c:	855a                	mv	a0,s6
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	a28080e7          	jalr	-1496(ra) # 80000fc6 <walk>
    800015a6:	c531                	beqz	a0,800015f2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a8:	6118                	ld	a4,0(a0)
    800015aa:	00177793          	andi	a5,a4,1
    800015ae:	cbb1                	beqz	a5,80001602 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b0:	00a75593          	srli	a1,a4,0xa
    800015b4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	526080e7          	jalr	1318(ra) # 80000ae2 <kalloc>
    800015c4:	892a                	mv	s2,a0
    800015c6:	c939                	beqz	a0,8000161c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85de                	mv	a1,s7
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	774080e7          	jalr	1908(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015d4:	8726                	mv	a4,s1
    800015d6:	86ca                	mv	a3,s2
    800015d8:	6605                	lui	a2,0x1
    800015da:	85ce                	mv	a1,s3
    800015dc:	8556                	mv	a0,s5
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	ad0080e7          	jalr	-1328(ra) # 800010ae <mappages>
    800015e6:	e515                	bnez	a0,80001612 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e8:	6785                	lui	a5,0x1
    800015ea:	99be                	add	s3,s3,a5
    800015ec:	fb49e6e3          	bltu	s3,s4,80001598 <uvmcopy+0x20>
    800015f0:	a081                	j	80001630 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bae50513          	addi	a0,a0,-1106 # 800081a0 <digits+0x160>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f42080e7          	jalr	-190(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    80001602:	00007517          	auipc	a0,0x7
    80001606:	bbe50513          	addi	a0,a0,-1090 # 800081c0 <digits+0x180>
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	f32080e7          	jalr	-206(ra) # 8000053c <panic>
      kfree(mem);
    80001612:	854a                	mv	a0,s2
    80001614:	fffff097          	auipc	ra,0xfffff
    80001618:	3d0080e7          	jalr	976(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000161c:	4685                	li	a3,1
    8000161e:	00c9d613          	srli	a2,s3,0xc
    80001622:	4581                	li	a1,0
    80001624:	8556                	mv	a0,s5
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	c4e080e7          	jalr	-946(ra) # 80001274 <uvmunmap>
  return -1;
    8000162e:	557d                	li	a0,-1
}
    80001630:	60a6                	ld	ra,72(sp)
    80001632:	6406                	ld	s0,64(sp)
    80001634:	74e2                	ld	s1,56(sp)
    80001636:	7942                	ld	s2,48(sp)
    80001638:	79a2                	ld	s3,40(sp)
    8000163a:	7a02                	ld	s4,32(sp)
    8000163c:	6ae2                	ld	s5,24(sp)
    8000163e:	6b42                	ld	s6,16(sp)
    80001640:	6ba2                	ld	s7,8(sp)
    80001642:	6161                	addi	sp,sp,80
    80001644:	8082                	ret
  return 0;
    80001646:	4501                	li	a0,0
}
    80001648:	8082                	ret

000000008000164a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000164a:	1141                	addi	sp,sp,-16
    8000164c:	e406                	sd	ra,8(sp)
    8000164e:	e022                	sd	s0,0(sp)
    80001650:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001652:	4601                	li	a2,0
    80001654:	00000097          	auipc	ra,0x0
    80001658:	972080e7          	jalr	-1678(ra) # 80000fc6 <walk>
  if(pte == 0)
    8000165c:	c901                	beqz	a0,8000166c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000165e:	611c                	ld	a5,0(a0)
    80001660:	9bbd                	andi	a5,a5,-17
    80001662:	e11c                	sd	a5,0(a0)
}
    80001664:	60a2                	ld	ra,8(sp)
    80001666:	6402                	ld	s0,0(sp)
    80001668:	0141                	addi	sp,sp,16
    8000166a:	8082                	ret
    panic("uvmclear");
    8000166c:	00007517          	auipc	a0,0x7
    80001670:	b7450513          	addi	a0,a0,-1164 # 800081e0 <digits+0x1a0>
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	ec8080e7          	jalr	-312(ra) # 8000053c <panic>

000000008000167c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000167c:	c6bd                	beqz	a3,800016ea <copyout+0x6e>
{
    8000167e:	715d                	addi	sp,sp,-80
    80001680:	e486                	sd	ra,72(sp)
    80001682:	e0a2                	sd	s0,64(sp)
    80001684:	fc26                	sd	s1,56(sp)
    80001686:	f84a                	sd	s2,48(sp)
    80001688:	f44e                	sd	s3,40(sp)
    8000168a:	f052                	sd	s4,32(sp)
    8000168c:	ec56                	sd	s5,24(sp)
    8000168e:	e85a                	sd	s6,16(sp)
    80001690:	e45e                	sd	s7,8(sp)
    80001692:	e062                	sd	s8,0(sp)
    80001694:	0880                	addi	s0,sp,80
    80001696:	8b2a                	mv	s6,a0
    80001698:	8c2e                	mv	s8,a1
    8000169a:	8a32                	mv	s4,a2
    8000169c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000169e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a0:	6a85                	lui	s5,0x1
    800016a2:	a015                	j	800016c6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016a4:	9562                	add	a0,a0,s8
    800016a6:	0004861b          	sext.w	a2,s1
    800016aa:	85d2                	mv	a1,s4
    800016ac:	41250533          	sub	a0,a0,s2
    800016b0:	fffff097          	auipc	ra,0xfffff
    800016b4:	690080e7          	jalr	1680(ra) # 80000d40 <memmove>

    len -= n;
    800016b8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016bc:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016be:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016c2:	02098263          	beqz	s3,800016e6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016c6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ca:	85ca                	mv	a1,s2
    800016cc:	855a                	mv	a0,s6
    800016ce:	00000097          	auipc	ra,0x0
    800016d2:	99e080e7          	jalr	-1634(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800016d6:	cd01                	beqz	a0,800016ee <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016d8:	418904b3          	sub	s1,s2,s8
    800016dc:	94d6                	add	s1,s1,s5
    800016de:	fc99f3e3          	bgeu	s3,s1,800016a4 <copyout+0x28>
    800016e2:	84ce                	mv	s1,s3
    800016e4:	b7c1                	j	800016a4 <copyout+0x28>
  }
  return 0;
    800016e6:	4501                	li	a0,0
    800016e8:	a021                	j	800016f0 <copyout+0x74>
    800016ea:	4501                	li	a0,0
}
    800016ec:	8082                	ret
      return -1;
    800016ee:	557d                	li	a0,-1
}
    800016f0:	60a6                	ld	ra,72(sp)
    800016f2:	6406                	ld	s0,64(sp)
    800016f4:	74e2                	ld	s1,56(sp)
    800016f6:	7942                	ld	s2,48(sp)
    800016f8:	79a2                	ld	s3,40(sp)
    800016fa:	7a02                	ld	s4,32(sp)
    800016fc:	6ae2                	ld	s5,24(sp)
    800016fe:	6b42                	ld	s6,16(sp)
    80001700:	6ba2                	ld	s7,8(sp)
    80001702:	6c02                	ld	s8,0(sp)
    80001704:	6161                	addi	sp,sp,80
    80001706:	8082                	ret

0000000080001708 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001708:	caa5                	beqz	a3,80001778 <copyin+0x70>
{
    8000170a:	715d                	addi	sp,sp,-80
    8000170c:	e486                	sd	ra,72(sp)
    8000170e:	e0a2                	sd	s0,64(sp)
    80001710:	fc26                	sd	s1,56(sp)
    80001712:	f84a                	sd	s2,48(sp)
    80001714:	f44e                	sd	s3,40(sp)
    80001716:	f052                	sd	s4,32(sp)
    80001718:	ec56                	sd	s5,24(sp)
    8000171a:	e85a                	sd	s6,16(sp)
    8000171c:	e45e                	sd	s7,8(sp)
    8000171e:	e062                	sd	s8,0(sp)
    80001720:	0880                	addi	s0,sp,80
    80001722:	8b2a                	mv	s6,a0
    80001724:	8a2e                	mv	s4,a1
    80001726:	8c32                	mv	s8,a2
    80001728:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000172a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000172c:	6a85                	lui	s5,0x1
    8000172e:	a01d                	j	80001754 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001730:	018505b3          	add	a1,a0,s8
    80001734:	0004861b          	sext.w	a2,s1
    80001738:	412585b3          	sub	a1,a1,s2
    8000173c:	8552                	mv	a0,s4
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	602080e7          	jalr	1538(ra) # 80000d40 <memmove>

    len -= n;
    80001746:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000174a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000174c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001750:	02098263          	beqz	s3,80001774 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001754:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001758:	85ca                	mv	a1,s2
    8000175a:	855a                	mv	a0,s6
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	910080e7          	jalr	-1776(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001764:	cd01                	beqz	a0,8000177c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001766:	418904b3          	sub	s1,s2,s8
    8000176a:	94d6                	add	s1,s1,s5
    8000176c:	fc99f2e3          	bgeu	s3,s1,80001730 <copyin+0x28>
    80001770:	84ce                	mv	s1,s3
    80001772:	bf7d                	j	80001730 <copyin+0x28>
  }
  return 0;
    80001774:	4501                	li	a0,0
    80001776:	a021                	j	8000177e <copyin+0x76>
    80001778:	4501                	li	a0,0
}
    8000177a:	8082                	ret
      return -1;
    8000177c:	557d                	li	a0,-1
}
    8000177e:	60a6                	ld	ra,72(sp)
    80001780:	6406                	ld	s0,64(sp)
    80001782:	74e2                	ld	s1,56(sp)
    80001784:	7942                	ld	s2,48(sp)
    80001786:	79a2                	ld	s3,40(sp)
    80001788:	7a02                	ld	s4,32(sp)
    8000178a:	6ae2                	ld	s5,24(sp)
    8000178c:	6b42                	ld	s6,16(sp)
    8000178e:	6ba2                	ld	s7,8(sp)
    80001790:	6c02                	ld	s8,0(sp)
    80001792:	6161                	addi	sp,sp,80
    80001794:	8082                	ret

0000000080001796 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001796:	c2dd                	beqz	a3,8000183c <copyinstr+0xa6>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	0880                	addi	s0,sp,80
    800017ae:	8a2a                	mv	s4,a0
    800017b0:	8b2e                	mv	s6,a1
    800017b2:	8bb2                	mv	s7,a2
    800017b4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017b6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b8:	6985                	lui	s3,0x1
    800017ba:	a02d                	j	800017e4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017bc:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c2:	37fd                	addiw	a5,a5,-1
    800017c4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017c8:	60a6                	ld	ra,72(sp)
    800017ca:	6406                	ld	s0,64(sp)
    800017cc:	74e2                	ld	s1,56(sp)
    800017ce:	7942                	ld	s2,48(sp)
    800017d0:	79a2                	ld	s3,40(sp)
    800017d2:	7a02                	ld	s4,32(sp)
    800017d4:	6ae2                	ld	s5,24(sp)
    800017d6:	6b42                	ld	s6,16(sp)
    800017d8:	6ba2                	ld	s7,8(sp)
    800017da:	6161                	addi	sp,sp,80
    800017dc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017de:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017e2:	c8a9                	beqz	s1,80001834 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017e4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017e8:	85ca                	mv	a1,s2
    800017ea:	8552                	mv	a0,s4
    800017ec:	00000097          	auipc	ra,0x0
    800017f0:	880080e7          	jalr	-1920(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800017f4:	c131                	beqz	a0,80001838 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017f6:	417906b3          	sub	a3,s2,s7
    800017fa:	96ce                	add	a3,a3,s3
    800017fc:	00d4f363          	bgeu	s1,a3,80001802 <copyinstr+0x6c>
    80001800:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001802:	955e                	add	a0,a0,s7
    80001804:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001808:	daf9                	beqz	a3,800017de <copyinstr+0x48>
    8000180a:	87da                	mv	a5,s6
    8000180c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000180e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001812:	96da                	add	a3,a3,s6
    80001814:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001816:	00f60733          	add	a4,a2,a5
    8000181a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd240>
    8000181e:	df59                	beqz	a4,800017bc <copyinstr+0x26>
        *dst = *p;
    80001820:	00e78023          	sb	a4,0(a5)
      dst++;
    80001824:	0785                	addi	a5,a5,1
    while(n > 0){
    80001826:	fed797e3          	bne	a5,a3,80001814 <copyinstr+0x7e>
    8000182a:	14fd                	addi	s1,s1,-1
    8000182c:	94c2                	add	s1,s1,a6
      --max;
    8000182e:	8c8d                	sub	s1,s1,a1
      dst++;
    80001830:	8b3e                	mv	s6,a5
    80001832:	b775                	j	800017de <copyinstr+0x48>
    80001834:	4781                	li	a5,0
    80001836:	b771                	j	800017c2 <copyinstr+0x2c>
      return -1;
    80001838:	557d                	li	a0,-1
    8000183a:	b779                	j	800017c8 <copyinstr+0x32>
  int got_null = 0;
    8000183c:	4781                	li	a5,0
  if(got_null){
    8000183e:	37fd                	addiw	a5,a5,-1
    80001840:	0007851b          	sext.w	a0,a5
}
    80001844:	8082                	ret

0000000080001846 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001846:	7139                	addi	sp,sp,-64
    80001848:	fc06                	sd	ra,56(sp)
    8000184a:	f822                	sd	s0,48(sp)
    8000184c:	f426                	sd	s1,40(sp)
    8000184e:	f04a                	sd	s2,32(sp)
    80001850:	ec4e                	sd	s3,24(sp)
    80001852:	e852                	sd	s4,16(sp)
    80001854:	e456                	sd	s5,8(sp)
    80001856:	e05a                	sd	s6,0(sp)
    80001858:	0080                	addi	s0,sp,64
    8000185a:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	0000f497          	auipc	s1,0xf
    80001860:	78448493          	addi	s1,s1,1924 # 80010fe0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001864:	8b26                	mv	s6,s1
    80001866:	00006a97          	auipc	s5,0x6
    8000186a:	79aa8a93          	addi	s5,s5,1946 # 80008000 <etext>
    8000186e:	04000937          	lui	s2,0x4000
    80001872:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001874:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	00015a17          	auipc	s4,0x15
    8000187a:	16aa0a13          	addi	s4,s4,362 # 800169e0 <tickslock>
    char *pa = kalloc();
    8000187e:	fffff097          	auipc	ra,0xfffff
    80001882:	264080e7          	jalr	612(ra) # 80000ae2 <kalloc>
    80001886:	862a                	mv	a2,a0
    if(pa == 0)
    80001888:	c131                	beqz	a0,800018cc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000188a:	416485b3          	sub	a1,s1,s6
    8000188e:	858d                	srai	a1,a1,0x3
    80001890:	000ab783          	ld	a5,0(s5)
    80001894:	02f585b3          	mul	a1,a1,a5
    80001898:	2585                	addiw	a1,a1,1
    8000189a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000189e:	4719                	li	a4,6
    800018a0:	6685                	lui	a3,0x1
    800018a2:	40b905b3          	sub	a1,s2,a1
    800018a6:	854e                	mv	a0,s3
    800018a8:	00000097          	auipc	ra,0x0
    800018ac:	8a6080e7          	jalr	-1882(ra) # 8000114e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b0:	16848493          	addi	s1,s1,360
    800018b4:	fd4495e3          	bne	s1,s4,8000187e <proc_mapstacks+0x38>
  }
}
    800018b8:	70e2                	ld	ra,56(sp)
    800018ba:	7442                	ld	s0,48(sp)
    800018bc:	74a2                	ld	s1,40(sp)
    800018be:	7902                	ld	s2,32(sp)
    800018c0:	69e2                	ld	s3,24(sp)
    800018c2:	6a42                	ld	s4,16(sp)
    800018c4:	6aa2                	ld	s5,8(sp)
    800018c6:	6b02                	ld	s6,0(sp)
    800018c8:	6121                	addi	sp,sp,64
    800018ca:	8082                	ret
      panic("kalloc");
    800018cc:	00007517          	auipc	a0,0x7
    800018d0:	92450513          	addi	a0,a0,-1756 # 800081f0 <digits+0x1b0>
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	c68080e7          	jalr	-920(ra) # 8000053c <panic>

00000000800018dc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018dc:	7139                	addi	sp,sp,-64
    800018de:	fc06                	sd	ra,56(sp)
    800018e0:	f822                	sd	s0,48(sp)
    800018e2:	f426                	sd	s1,40(sp)
    800018e4:	f04a                	sd	s2,32(sp)
    800018e6:	ec4e                	sd	s3,24(sp)
    800018e8:	e852                	sd	s4,16(sp)
    800018ea:	e456                	sd	s5,8(sp)
    800018ec:	e05a                	sd	s6,0(sp)
    800018ee:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018f0:	00007597          	auipc	a1,0x7
    800018f4:	90858593          	addi	a1,a1,-1784 # 800081f8 <digits+0x1b8>
    800018f8:	0000f517          	auipc	a0,0xf
    800018fc:	2b850513          	addi	a0,a0,696 # 80010bb0 <pid_lock>
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	242080e7          	jalr	578(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001908:	00007597          	auipc	a1,0x7
    8000190c:	8f858593          	addi	a1,a1,-1800 # 80008200 <digits+0x1c0>
    80001910:	0000f517          	auipc	a0,0xf
    80001914:	2b850513          	addi	a0,a0,696 # 80010bc8 <wait_lock>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	22a080e7          	jalr	554(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	0000f497          	auipc	s1,0xf
    80001924:	6c048493          	addi	s1,s1,1728 # 80010fe0 <proc>
      initlock(&p->lock, "proc");
    80001928:	00007b17          	auipc	s6,0x7
    8000192c:	8e8b0b13          	addi	s6,s6,-1816 # 80008210 <digits+0x1d0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001930:	8aa6                	mv	s5,s1
    80001932:	00006a17          	auipc	s4,0x6
    80001936:	6cea0a13          	addi	s4,s4,1742 # 80008000 <etext>
    8000193a:	04000937          	lui	s2,0x4000
    8000193e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001940:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	00015997          	auipc	s3,0x15
    80001946:	09e98993          	addi	s3,s3,158 # 800169e0 <tickslock>
      initlock(&p->lock, "proc");
    8000194a:	85da                	mv	a1,s6
    8000194c:	8526                	mv	a0,s1
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	1f4080e7          	jalr	500(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001956:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000195a:	415487b3          	sub	a5,s1,s5
    8000195e:	878d                	srai	a5,a5,0x3
    80001960:	000a3703          	ld	a4,0(s4)
    80001964:	02e787b3          	mul	a5,a5,a4
    80001968:	2785                	addiw	a5,a5,1
    8000196a:	00d7979b          	slliw	a5,a5,0xd
    8000196e:	40f907b3          	sub	a5,s2,a5
    80001972:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001974:	16848493          	addi	s1,s1,360
    80001978:	fd3499e3          	bne	s1,s3,8000194a <procinit+0x6e>
  }
}
    8000197c:	70e2                	ld	ra,56(sp)
    8000197e:	7442                	ld	s0,48(sp)
    80001980:	74a2                	ld	s1,40(sp)
    80001982:	7902                	ld	s2,32(sp)
    80001984:	69e2                	ld	s3,24(sp)
    80001986:	6a42                	ld	s4,16(sp)
    80001988:	6aa2                	ld	s5,8(sp)
    8000198a:	6b02                	ld	s6,0(sp)
    8000198c:	6121                	addi	sp,sp,64
    8000198e:	8082                	ret

0000000080001990 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001996:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001998:	2501                	sext.w	a0,a0
    8000199a:	6422                	ld	s0,8(sp)
    8000199c:	0141                	addi	sp,sp,16
    8000199e:	8082                	ret

00000000800019a0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019a0:	1141                	addi	sp,sp,-16
    800019a2:	e422                	sd	s0,8(sp)
    800019a4:	0800                	addi	s0,sp,16
    800019a6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a8:	2781                	sext.w	a5,a5
    800019aa:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ac:	0000f517          	auipc	a0,0xf
    800019b0:	23450513          	addi	a0,a0,564 # 80010be0 <cpus>
    800019b4:	953e                	add	a0,a0,a5
    800019b6:	6422                	ld	s0,8(sp)
    800019b8:	0141                	addi	sp,sp,16
    800019ba:	8082                	ret

00000000800019bc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019bc:	1101                	addi	sp,sp,-32
    800019be:	ec06                	sd	ra,24(sp)
    800019c0:	e822                	sd	s0,16(sp)
    800019c2:	e426                	sd	s1,8(sp)
    800019c4:	1000                	addi	s0,sp,32
  push_off();
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	1c0080e7          	jalr	448(ra) # 80000b86 <push_off>
    800019ce:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019d0:	2781                	sext.w	a5,a5
    800019d2:	079e                	slli	a5,a5,0x7
    800019d4:	0000f717          	auipc	a4,0xf
    800019d8:	1dc70713          	addi	a4,a4,476 # 80010bb0 <pid_lock>
    800019dc:	97ba                	add	a5,a5,a4
    800019de:	7b84                	ld	s1,48(a5)
  pop_off();
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	25c080e7          	jalr	604(ra) # 80000c3c <pop_off>
  return p;
}
    800019e8:	8526                	mv	a0,s1
    800019ea:	60e2                	ld	ra,24(sp)
    800019ec:	6442                	ld	s0,16(sp)
    800019ee:	64a2                	ld	s1,8(sp)
    800019f0:	6105                	addi	sp,sp,32
    800019f2:	8082                	ret

00000000800019f4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019f4:	1141                	addi	sp,sp,-16
    800019f6:	e406                	sd	ra,8(sp)
    800019f8:	e022                	sd	s0,0(sp)
    800019fa:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019fc:	00000097          	auipc	ra,0x0
    80001a00:	fc0080e7          	jalr	-64(ra) # 800019bc <myproc>
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	298080e7          	jalr	664(ra) # 80000c9c <release>

  if (first) {
    80001a0c:	00007797          	auipc	a5,0x7
    80001a10:	e847a783          	lw	a5,-380(a5) # 80008890 <first.1>
    80001a14:	eb89                	bnez	a5,80001a26 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a16:	00001097          	auipc	ra,0x1
    80001a1a:	cd8080e7          	jalr	-808(ra) # 800026ee <usertrapret>
}
    80001a1e:	60a2                	ld	ra,8(sp)
    80001a20:	6402                	ld	s0,0(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret
    first = 0;
    80001a26:	00007797          	auipc	a5,0x7
    80001a2a:	e607a523          	sw	zero,-406(a5) # 80008890 <first.1>
    fsinit(ROOTDEV);
    80001a2e:	4505                	li	a0,1
    80001a30:	00002097          	auipc	ra,0x2
    80001a34:	af8080e7          	jalr	-1288(ra) # 80003528 <fsinit>
    80001a38:	bff9                	j	80001a16 <forkret+0x22>

0000000080001a3a <allocpid>:
{
    80001a3a:	1101                	addi	sp,sp,-32
    80001a3c:	ec06                	sd	ra,24(sp)
    80001a3e:	e822                	sd	s0,16(sp)
    80001a40:	e426                	sd	s1,8(sp)
    80001a42:	e04a                	sd	s2,0(sp)
    80001a44:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a46:	0000f917          	auipc	s2,0xf
    80001a4a:	16a90913          	addi	s2,s2,362 # 80010bb0 <pid_lock>
    80001a4e:	854a                	mv	a0,s2
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	182080e7          	jalr	386(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a58:	00007797          	auipc	a5,0x7
    80001a5c:	e3c78793          	addi	a5,a5,-452 # 80008894 <nextpid>
    80001a60:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a62:	0014871b          	addiw	a4,s1,1
    80001a66:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a68:	854a                	mv	a0,s2
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	232080e7          	jalr	562(ra) # 80000c9c <release>
}
    80001a72:	8526                	mv	a0,s1
    80001a74:	60e2                	ld	ra,24(sp)
    80001a76:	6442                	ld	s0,16(sp)
    80001a78:	64a2                	ld	s1,8(sp)
    80001a7a:	6902                	ld	s2,0(sp)
    80001a7c:	6105                	addi	sp,sp,32
    80001a7e:	8082                	ret

0000000080001a80 <proc_pagetable>:
{
    80001a80:	1101                	addi	sp,sp,-32
    80001a82:	ec06                	sd	ra,24(sp)
    80001a84:	e822                	sd	s0,16(sp)
    80001a86:	e426                	sd	s1,8(sp)
    80001a88:	e04a                	sd	s2,0(sp)
    80001a8a:	1000                	addi	s0,sp,32
    80001a8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a8e:	00000097          	auipc	ra,0x0
    80001a92:	8aa080e7          	jalr	-1878(ra) # 80001338 <uvmcreate>
    80001a96:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a98:	c121                	beqz	a0,80001ad8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a9a:	4729                	li	a4,10
    80001a9c:	00005697          	auipc	a3,0x5
    80001aa0:	56468693          	addi	a3,a3,1380 # 80007000 <_trampoline>
    80001aa4:	6605                	lui	a2,0x1
    80001aa6:	040005b7          	lui	a1,0x4000
    80001aaa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aac:	05b2                	slli	a1,a1,0xc
    80001aae:	fffff097          	auipc	ra,0xfffff
    80001ab2:	600080e7          	jalr	1536(ra) # 800010ae <mappages>
    80001ab6:	02054863          	bltz	a0,80001ae6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aba:	4719                	li	a4,6
    80001abc:	05893683          	ld	a3,88(s2)
    80001ac0:	6605                	lui	a2,0x1
    80001ac2:	020005b7          	lui	a1,0x2000
    80001ac6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac8:	05b6                	slli	a1,a1,0xd
    80001aca:	8526                	mv	a0,s1
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	5e2080e7          	jalr	1506(ra) # 800010ae <mappages>
    80001ad4:	02054163          	bltz	a0,80001af6 <proc_pagetable+0x76>
}
    80001ad8:	8526                	mv	a0,s1
    80001ada:	60e2                	ld	ra,24(sp)
    80001adc:	6442                	ld	s0,16(sp)
    80001ade:	64a2                	ld	s1,8(sp)
    80001ae0:	6902                	ld	s2,0(sp)
    80001ae2:	6105                	addi	sp,sp,32
    80001ae4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a54080e7          	jalr	-1452(ra) # 8000153e <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	b7d5                	j	80001ad8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af6:	4681                	li	a3,0
    80001af8:	4605                	li	a2,1
    80001afa:	040005b7          	lui	a1,0x4000
    80001afe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b00:	05b2                	slli	a1,a1,0xc
    80001b02:	8526                	mv	a0,s1
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	770080e7          	jalr	1904(ra) # 80001274 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	a2e080e7          	jalr	-1490(ra) # 8000153e <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	bf7d                	j	80001ad8 <proc_pagetable+0x58>

0000000080001b1c <proc_freepagetable>:
{
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
    80001b28:	84aa                	mv	s1,a0
    80001b2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	73c080e7          	jalr	1852(ra) # 80001274 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b40:	4681                	li	a3,0
    80001b42:	4605                	li	a2,1
    80001b44:	020005b7          	lui	a1,0x2000
    80001b48:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b4a:	05b6                	slli	a1,a1,0xd
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	726080e7          	jalr	1830(ra) # 80001274 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b56:	85ca                	mv	a1,s2
    80001b58:	8526                	mv	a0,s1
    80001b5a:	00000097          	auipc	ra,0x0
    80001b5e:	9e4080e7          	jalr	-1564(ra) # 8000153e <uvmfree>
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6902                	ld	s2,0(sp)
    80001b6a:	6105                	addi	sp,sp,32
    80001b6c:	8082                	ret

0000000080001b6e <freeproc>:
{
    80001b6e:	1101                	addi	sp,sp,-32
    80001b70:	ec06                	sd	ra,24(sp)
    80001b72:	e822                	sd	s0,16(sp)
    80001b74:	e426                	sd	s1,8(sp)
    80001b76:	1000                	addi	s0,sp,32
    80001b78:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b7a:	6d28                	ld	a0,88(a0)
    80001b7c:	c509                	beqz	a0,80001b86 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	e66080e7          	jalr	-410(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b86:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b8a:	68a8                	ld	a0,80(s1)
    80001b8c:	c511                	beqz	a0,80001b98 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b8e:	64ac                	ld	a1,72(s1)
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	f8c080e7          	jalr	-116(ra) # 80001b1c <proc_freepagetable>
  p->pagetable = 0;
    80001b98:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b9c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ba4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bac:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb4:	0204a623          	sw	zero,44(s1)
  p->prio = 0;
    80001bb8:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bbc:	0004ac23          	sw	zero,24(s1)
}
    80001bc0:	60e2                	ld	ra,24(sp)
    80001bc2:	6442                	ld	s0,16(sp)
    80001bc4:	64a2                	ld	s1,8(sp)
    80001bc6:	6105                	addi	sp,sp,32
    80001bc8:	8082                	ret

0000000080001bca <allocproc>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	e04a                	sd	s2,0(sp)
    80001bd4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd6:	0000f497          	auipc	s1,0xf
    80001bda:	40a48493          	addi	s1,s1,1034 # 80010fe0 <proc>
    80001bde:	00015917          	auipc	s2,0x15
    80001be2:	e0290913          	addi	s2,s2,-510 # 800169e0 <tickslock>
    acquire(&p->lock);
    80001be6:	8526                	mv	a0,s1
    80001be8:	fffff097          	auipc	ra,0xfffff
    80001bec:	fea080e7          	jalr	-22(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bf0:	4c9c                	lw	a5,24(s1)
    80001bf2:	cf81                	beqz	a5,80001c0a <allocproc+0x40>
      release(&p->lock);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	0a6080e7          	jalr	166(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfe:	16848493          	addi	s1,s1,360
    80001c02:	ff2492e3          	bne	s1,s2,80001be6 <allocproc+0x1c>
  return 0;
    80001c06:	4481                	li	s1,0
    80001c08:	a899                	j	80001c5e <allocproc+0x94>
  p->pid   = allocpid();
    80001c0a:	00000097          	auipc	ra,0x0
    80001c0e:	e30080e7          	jalr	-464(ra) # 80001a3a <allocpid>
    80001c12:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c14:	4785                	li	a5,1
    80001c16:	cc9c                	sw	a5,24(s1)
  p->prio  = 0x0C;
    80001c18:	47b1                	li	a5,12
    80001c1a:	d8dc                	sw	a5,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	ec6080e7          	jalr	-314(ra) # 80000ae2 <kalloc>
    80001c24:	892a                	mv	s2,a0
    80001c26:	eca8                	sd	a0,88(s1)
    80001c28:	c131                	beqz	a0,80001c6c <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	e54080e7          	jalr	-428(ra) # 80001a80 <proc_pagetable>
    80001c34:	892a                	mv	s2,a0
    80001c36:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c38:	c531                	beqz	a0,80001c84 <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c3a:	07000613          	li	a2,112
    80001c3e:	4581                	li	a1,0
    80001c40:	06048513          	addi	a0,s1,96
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	0a0080e7          	jalr	160(ra) # 80000ce4 <memset>
  p->context.ra = (uint64)forkret;
    80001c4c:	00000797          	auipc	a5,0x0
    80001c50:	da878793          	addi	a5,a5,-600 # 800019f4 <forkret>
    80001c54:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c56:	60bc                	ld	a5,64(s1)
    80001c58:	6705                	lui	a4,0x1
    80001c5a:	97ba                	add	a5,a5,a4
    80001c5c:	f4bc                	sd	a5,104(s1)
}
    80001c5e:	8526                	mv	a0,s1
    80001c60:	60e2                	ld	ra,24(sp)
    80001c62:	6442                	ld	s0,16(sp)
    80001c64:	64a2                	ld	s1,8(sp)
    80001c66:	6902                	ld	s2,0(sp)
    80001c68:	6105                	addi	sp,sp,32
    80001c6a:	8082                	ret
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	f00080e7          	jalr	-256(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	024080e7          	jalr	36(ra) # 80000c9c <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	bff1                	j	80001c5e <allocproc+0x94>
    freeproc(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	ee8080e7          	jalr	-280(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	00c080e7          	jalr	12(ra) # 80000c9c <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	b7d1                	j	80001c5e <allocproc+0x94>

0000000080001c9c <userinit>:
{
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	f24080e7          	jalr	-220(ra) # 80001bca <allocproc>
    80001cae:	84aa                	mv	s1,a0
  initproc = p;
    80001cb0:	00007797          	auipc	a5,0x7
    80001cb4:	c8a7b423          	sd	a0,-888(a5) # 80008938 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb8:	03400613          	li	a2,52
    80001cbc:	00007597          	auipc	a1,0x7
    80001cc0:	be458593          	addi	a1,a1,-1052 # 800088a0 <initcode>
    80001cc4:	6928                	ld	a0,80(a0)
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	6a0080e7          	jalr	1696(ra) # 80001366 <uvmfirst>
  p->sz = PGSIZE;
    80001cce:	6785                	lui	a5,0x1
    80001cd0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd2:	6cb8                	ld	a4,88(s1)
    80001cd4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd8:	6cb8                	ld	a4,88(s1)
    80001cda:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cdc:	4641                	li	a2,16
    80001cde:	00006597          	auipc	a1,0x6
    80001ce2:	53a58593          	addi	a1,a1,1338 # 80008218 <digits+0x1d8>
    80001ce6:	15848513          	addi	a0,s1,344
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	142080e7          	jalr	322(ra) # 80000e2c <safestrcpy>
  p->cwd = namei("/");
    80001cf2:	00006517          	auipc	a0,0x6
    80001cf6:	53650513          	addi	a0,a0,1334 # 80008228 <digits+0x1e8>
    80001cfa:	00002097          	auipc	ra,0x2
    80001cfe:	24c080e7          	jalr	588(ra) # 80003f46 <namei>
    80001d02:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d06:	478d                	li	a5,3
    80001d08:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	f90080e7          	jalr	-112(ra) # 80000c9c <release>
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret

0000000080001d1e <growproc>:
{
    80001d1e:	1101                	addi	sp,sp,-32
    80001d20:	ec06                	sd	ra,24(sp)
    80001d22:	e822                	sd	s0,16(sp)
    80001d24:	e426                	sd	s1,8(sp)
    80001d26:	e04a                	sd	s2,0(sp)
    80001d28:	1000                	addi	s0,sp,32
    80001d2a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	c90080e7          	jalr	-880(ra) # 800019bc <myproc>
    80001d34:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d36:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d38:	01204c63          	bgtz	s2,80001d50 <growproc+0x32>
  } else if(n < 0){
    80001d3c:	02094663          	bltz	s2,80001d68 <growproc+0x4a>
  p->sz = sz;
    80001d40:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d42:	4501                	li	a0,0
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6902                	ld	s2,0(sp)
    80001d4c:	6105                	addi	sp,sp,32
    80001d4e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d50:	4691                	li	a3,4
    80001d52:	00b90633          	add	a2,s2,a1
    80001d56:	6928                	ld	a0,80(a0)
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	6c8080e7          	jalr	1736(ra) # 80001420 <uvmalloc>
    80001d60:	85aa                	mv	a1,a0
    80001d62:	fd79                	bnez	a0,80001d40 <growproc+0x22>
      return -1;
    80001d64:	557d                	li	a0,-1
    80001d66:	bff9                	j	80001d44 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d68:	00b90633          	add	a2,s2,a1
    80001d6c:	6928                	ld	a0,80(a0)
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	66a080e7          	jalr	1642(ra) # 800013d8 <uvmdealloc>
    80001d76:	85aa                	mv	a1,a0
    80001d78:	b7e1                	j	80001d40 <growproc+0x22>

0000000080001d7a <fork>:
{
    80001d7a:	7139                	addi	sp,sp,-64
    80001d7c:	fc06                	sd	ra,56(sp)
    80001d7e:	f822                	sd	s0,48(sp)
    80001d80:	f426                	sd	s1,40(sp)
    80001d82:	f04a                	sd	s2,32(sp)
    80001d84:	ec4e                	sd	s3,24(sp)
    80001d86:	e852                	sd	s4,16(sp)
    80001d88:	e456                	sd	s5,8(sp)
    80001d8a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	c30080e7          	jalr	-976(ra) # 800019bc <myproc>
    80001d94:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	e34080e7          	jalr	-460(ra) # 80001bca <allocproc>
    80001d9e:	10050c63          	beqz	a0,80001eb6 <fork+0x13c>
    80001da2:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da4:	048ab603          	ld	a2,72(s5)
    80001da8:	692c                	ld	a1,80(a0)
    80001daa:	050ab503          	ld	a0,80(s5)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	7ca080e7          	jalr	1994(ra) # 80001578 <uvmcopy>
    80001db6:	04054863          	bltz	a0,80001e06 <fork+0x8c>
  np->sz = p->sz;
    80001dba:	048ab783          	ld	a5,72(s5)
    80001dbe:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dc2:	058ab683          	ld	a3,88(s5)
    80001dc6:	87b6                	mv	a5,a3
    80001dc8:	058a3703          	ld	a4,88(s4)
    80001dcc:	12068693          	addi	a3,a3,288
    80001dd0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd4:	6788                	ld	a0,8(a5)
    80001dd6:	6b8c                	ld	a1,16(a5)
    80001dd8:	6f90                	ld	a2,24(a5)
    80001dda:	01073023          	sd	a6,0(a4)
    80001dde:	e708                	sd	a0,8(a4)
    80001de0:	eb0c                	sd	a1,16(a4)
    80001de2:	ef10                	sd	a2,24(a4)
    80001de4:	02078793          	addi	a5,a5,32
    80001de8:	02070713          	addi	a4,a4,32
    80001dec:	fed792e3          	bne	a5,a3,80001dd0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001df0:	058a3783          	ld	a5,88(s4)
    80001df4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001df8:	0d0a8493          	addi	s1,s5,208
    80001dfc:	0d0a0913          	addi	s2,s4,208
    80001e00:	150a8993          	addi	s3,s5,336
    80001e04:	a00d                	j	80001e26 <fork+0xac>
    freeproc(np);
    80001e06:	8552                	mv	a0,s4
    80001e08:	00000097          	auipc	ra,0x0
    80001e0c:	d66080e7          	jalr	-666(ra) # 80001b6e <freeproc>
    release(&np->lock);
    80001e10:	8552                	mv	a0,s4
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	e8a080e7          	jalr	-374(ra) # 80000c9c <release>
    return -1;
    80001e1a:	597d                	li	s2,-1
    80001e1c:	a059                	j	80001ea2 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e1e:	04a1                	addi	s1,s1,8
    80001e20:	0921                	addi	s2,s2,8
    80001e22:	01348b63          	beq	s1,s3,80001e38 <fork+0xbe>
    if(p->ofile[i])
    80001e26:	6088                	ld	a0,0(s1)
    80001e28:	d97d                	beqz	a0,80001e1e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e2a:	00002097          	auipc	ra,0x2
    80001e2e:	78e080e7          	jalr	1934(ra) # 800045b8 <filedup>
    80001e32:	00a93023          	sd	a0,0(s2)
    80001e36:	b7e5                	j	80001e1e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e38:	150ab503          	ld	a0,336(s5)
    80001e3c:	00002097          	auipc	ra,0x2
    80001e40:	926080e7          	jalr	-1754(ra) # 80003762 <idup>
    80001e44:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e48:	4641                	li	a2,16
    80001e4a:	158a8593          	addi	a1,s5,344
    80001e4e:	158a0513          	addi	a0,s4,344
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	fda080e7          	jalr	-38(ra) # 80000e2c <safestrcpy>
  pid = np->pid;
    80001e5a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e5e:	8552                	mv	a0,s4
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e3c080e7          	jalr	-452(ra) # 80000c9c <release>
  acquire(&wait_lock);
    80001e68:	0000f497          	auipc	s1,0xf
    80001e6c:	d6048493          	addi	s1,s1,-672 # 80010bc8 <wait_lock>
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d60080e7          	jalr	-672(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e7a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e1c080e7          	jalr	-484(ra) # 80000c9c <release>
  acquire(&np->lock);
    80001e88:	8552                	mv	a0,s4
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d48080e7          	jalr	-696(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e92:	478d                	li	a5,3
    80001e94:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e98:	8552                	mv	a0,s4
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	e02080e7          	jalr	-510(ra) # 80000c9c <release>
}
    80001ea2:	854a                	mv	a0,s2
    80001ea4:	70e2                	ld	ra,56(sp)
    80001ea6:	7442                	ld	s0,48(sp)
    80001ea8:	74a2                	ld	s1,40(sp)
    80001eaa:	7902                	ld	s2,32(sp)
    80001eac:	69e2                	ld	s3,24(sp)
    80001eae:	6a42                	ld	s4,16(sp)
    80001eb0:	6aa2                	ld	s5,8(sp)
    80001eb2:	6121                	addi	sp,sp,64
    80001eb4:	8082                	ret
    return -1;
    80001eb6:	597d                	li	s2,-1
    80001eb8:	b7ed                	j	80001ea2 <fork+0x128>

0000000080001eba <scheduler>:
{
    80001eba:	715d                	addi	sp,sp,-80
    80001ebc:	e486                	sd	ra,72(sp)
    80001ebe:	e0a2                	sd	s0,64(sp)
    80001ec0:	fc26                	sd	s1,56(sp)
    80001ec2:	f84a                	sd	s2,48(sp)
    80001ec4:	f44e                	sd	s3,40(sp)
    80001ec6:	f052                	sd	s4,32(sp)
    80001ec8:	ec56                	sd	s5,24(sp)
    80001eca:	e85a                	sd	s6,16(sp)
    80001ecc:	e45e                	sd	s7,8(sp)
    80001ece:	e062                	sd	s8,0(sp)
    80001ed0:	0880                	addi	s0,sp,80
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001ed6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ed8:	10079073          	csrw	sstatus,a5
  asm volatile("mv %0, tp" : "=r" (x) );
    80001edc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ede:	2781                	sext.w	a5,a5
  c->proc = 0; // kick the process out
    80001ee0:	00779b93          	slli	s7,a5,0x7
    80001ee4:	0000f717          	auipc	a4,0xf
    80001ee8:	ccc70713          	addi	a4,a4,-820 # 80010bb0 <pid_lock>
    80001eec:	975e                	add	a4,a4,s7
    80001eee:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80001ef2:	0000f717          	auipc	a4,0xf
    80001ef6:	cf670713          	addi	a4,a4,-778 # 80010be8 <cpus+0x8>
    80001efa:	9bba                	add	s7,s7,a4
      if(n->state != RUNNABLE){
    80001efc:	4a0d                	li	s4,3
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001efe:	00015997          	auipc	s3,0x15
    80001f02:	ae298993          	addi	s3,s3,-1310 # 800169e0 <tickslock>
      c->proc = p;
    80001f06:	079e                	slli	a5,a5,0x7
    80001f08:	0000fb17          	auipc	s6,0xf
    80001f0c:	ca8b0b13          	addi	s6,s6,-856 # 80010bb0 <pid_lock>
    80001f10:	9b3e                	add	s6,s6,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f16:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f1a:	10079073          	csrw	sstatus,a5
    for(n = proc; n < &proc[NPROC]; n++){
    80001f1e:	0000fa97          	auipc	s5,0xf
    80001f22:	0c2a8a93          	addi	s5,s5,194 # 80010fe0 <proc>
      p->state = RUNNING;
    80001f26:	4c11                	li	s8,4
    80001f28:	a061                	j	80001fb0 <scheduler+0xf6>
    80001f2a:	8956                	mv	s2,s5
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001f2c:	0000f497          	auipc	s1,0xf
    80001f30:	0b448493          	addi	s1,s1,180 # 80010fe0 <proc>
    80001f34:	a005                	j	80001f54 <scheduler+0x9a>
          release(&n1->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	d64080e7          	jalr	-668(ra) # 80000c9c <release>
          continue;
    80001f40:	a031                	j	80001f4c <scheduler+0x92>
        release(&n1->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	d58080e7          	jalr	-680(ra) # 80000c9c <release>
      for(n1 = proc; n1 < &proc[NPROC]; n1++){
    80001f4c:	16848493          	addi	s1,s1,360
    80001f50:	03348a63          	beq	s1,s3,80001f84 <scheduler+0xca>
        if(p == n1) continue;
    80001f54:	02990663          	beq	s2,s1,80001f80 <scheduler+0xc6>
        acquire(&n1->lock);
    80001f58:	8526                	mv	a0,s1
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	c78080e7          	jalr	-904(ra) # 80000bd2 <acquire>
        if(n1->state != RUNNABLE){
    80001f62:	4c9c                	lw	a5,24(s1)
    80001f64:	fd4799e3          	bne	a5,s4,80001f36 <scheduler+0x7c>
        if(n1->prio < p->prio){
    80001f68:	58d8                	lw	a4,52(s1)
    80001f6a:	03492783          	lw	a5,52(s2)
    80001f6e:	fcf75ae3          	bge	a4,a5,80001f42 <scheduler+0x88>
          release(&p->lock);
    80001f72:	854a                	mv	a0,s2
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	d28080e7          	jalr	-728(ra) # 80000c9c <release>
          continue;
    80001f7c:	8926                	mv	s2,s1
    80001f7e:	b7f9                	j	80001f4c <scheduler+0x92>
    80001f80:	8926                	mv	s2,s1
    80001f82:	b7e9                	j	80001f4c <scheduler+0x92>
      c->proc = p;
    80001f84:	032b3823          	sd	s2,48(s6)
      p->state = RUNNING;
    80001f88:	01892c23          	sw	s8,24(s2)
      swtch(&c->context, &p->context);
    80001f8c:	06090593          	addi	a1,s2,96
    80001f90:	855e                	mv	a0,s7
    80001f92:	00000097          	auipc	ra,0x0
    80001f96:	6b2080e7          	jalr	1714(ra) # 80002644 <swtch>
      c->proc = 0;
    80001f9a:	020b3823          	sd	zero,48(s6)
      release(&p->lock);
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	cfc080e7          	jalr	-772(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001fa8:	168a8a93          	addi	s5,s5,360
    80001fac:	f73a83e3          	beq	s5,s3,80001f12 <scheduler+0x58>
      acquire(&n->lock);
    80001fb0:	8556                	mv	a0,s5
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	c20080e7          	jalr	-992(ra) # 80000bd2 <acquire>
      if(n->state != RUNNABLE){
    80001fba:	018aa783          	lw	a5,24(s5)
    80001fbe:	f74786e3          	beq	a5,s4,80001f2a <scheduler+0x70>
        release(&n->lock);
    80001fc2:	8556                	mv	a0,s5
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	cd8080e7          	jalr	-808(ra) # 80000c9c <release>
        continue;
    80001fcc:	bff1                	j	80001fa8 <scheduler+0xee>

0000000080001fce <sched>:
{
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	9e0080e7          	jalr	-1568(ra) # 800019bc <myproc>
    80001fe4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	b72080e7          	jalr	-1166(ra) # 80000b58 <holding>
    80001fee:	c93d                	beqz	a0,80002064 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ff2:	2781                	sext.w	a5,a5
    80001ff4:	079e                	slli	a5,a5,0x7
    80001ff6:	0000f717          	auipc	a4,0xf
    80001ffa:	bba70713          	addi	a4,a4,-1094 # 80010bb0 <pid_lock>
    80001ffe:	97ba                	add	a5,a5,a4
    80002000:	0a87a703          	lw	a4,168(a5)
    80002004:	4785                	li	a5,1
    80002006:	06f71763          	bne	a4,a5,80002074 <sched+0xa6>
  if(p->state == RUNNING)
    8000200a:	4c98                	lw	a4,24(s1)
    8000200c:	4791                	li	a5,4
    8000200e:	06f70b63          	beq	a4,a5,80002084 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002012:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002016:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002018:	efb5                	bnez	a5,80002094 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000201c:	0000f917          	auipc	s2,0xf
    80002020:	b9490913          	addi	s2,s2,-1132 # 80010bb0 <pid_lock>
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	97ca                	add	a5,a5,s2
    8000202a:	0ac7a983          	lw	s3,172(a5)
    8000202e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002030:	2781                	sext.w	a5,a5
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	0000f597          	auipc	a1,0xf
    80002038:	bb458593          	addi	a1,a1,-1100 # 80010be8 <cpus+0x8>
    8000203c:	95be                	add	a1,a1,a5
    8000203e:	06048513          	addi	a0,s1,96
    80002042:	00000097          	auipc	ra,0x0
    80002046:	602080e7          	jalr	1538(ra) # 80002644 <swtch>
    8000204a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000204c:	2781                	sext.w	a5,a5
    8000204e:	079e                	slli	a5,a5,0x7
    80002050:	993e                	add	s2,s2,a5
    80002052:	0b392623          	sw	s3,172(s2)
}
    80002056:	70a2                	ld	ra,40(sp)
    80002058:	7402                	ld	s0,32(sp)
    8000205a:	64e2                	ld	s1,24(sp)
    8000205c:	6942                	ld	s2,16(sp)
    8000205e:	69a2                	ld	s3,8(sp)
    80002060:	6145                	addi	sp,sp,48
    80002062:	8082                	ret
    panic("sched p->lock");
    80002064:	00006517          	auipc	a0,0x6
    80002068:	1cc50513          	addi	a0,a0,460 # 80008230 <digits+0x1f0>
    8000206c:	ffffe097          	auipc	ra,0xffffe
    80002070:	4d0080e7          	jalr	1232(ra) # 8000053c <panic>
    panic("sched locks");
    80002074:	00006517          	auipc	a0,0x6
    80002078:	1cc50513          	addi	a0,a0,460 # 80008240 <digits+0x200>
    8000207c:	ffffe097          	auipc	ra,0xffffe
    80002080:	4c0080e7          	jalr	1216(ra) # 8000053c <panic>
    panic("sched running");
    80002084:	00006517          	auipc	a0,0x6
    80002088:	1cc50513          	addi	a0,a0,460 # 80008250 <digits+0x210>
    8000208c:	ffffe097          	auipc	ra,0xffffe
    80002090:	4b0080e7          	jalr	1200(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002094:	00006517          	auipc	a0,0x6
    80002098:	1cc50513          	addi	a0,a0,460 # 80008260 <digits+0x220>
    8000209c:	ffffe097          	auipc	ra,0xffffe
    800020a0:	4a0080e7          	jalr	1184(ra) # 8000053c <panic>

00000000800020a4 <yield>:
{
    800020a4:	1101                	addi	sp,sp,-32
    800020a6:	ec06                	sd	ra,24(sp)
    800020a8:	e822                	sd	s0,16(sp)
    800020aa:	e426                	sd	s1,8(sp)
    800020ac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	90e080e7          	jalr	-1778(ra) # 800019bc <myproc>
    800020b6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	b1a080e7          	jalr	-1254(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020c0:	478d                	li	a5,3
    800020c2:	cc9c                	sw	a5,24(s1)
  sched();
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	f0a080e7          	jalr	-246(ra) # 80001fce <sched>
  release(&p->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	bce080e7          	jalr	-1074(ra) # 80000c9c <release>
}
    800020d6:	60e2                	ld	ra,24(sp)
    800020d8:	6442                	ld	s0,16(sp)
    800020da:	64a2                	ld	s1,8(sp)
    800020dc:	6105                	addi	sp,sp,32
    800020de:	8082                	ret

00000000800020e0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020e0:	7179                	addi	sp,sp,-48
    800020e2:	f406                	sd	ra,40(sp)
    800020e4:	f022                	sd	s0,32(sp)
    800020e6:	ec26                	sd	s1,24(sp)
    800020e8:	e84a                	sd	s2,16(sp)
    800020ea:	e44e                	sd	s3,8(sp)
    800020ec:	1800                	addi	s0,sp,48
    800020ee:	89aa                	mv	s3,a0
    800020f0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020f2:	00000097          	auipc	ra,0x0
    800020f6:	8ca080e7          	jalr	-1846(ra) # 800019bc <myproc>
    800020fa:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ad6080e7          	jalr	-1322(ra) # 80000bd2 <acquire>
  release(lk);
    80002104:	854a                	mv	a0,s2
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	b96080e7          	jalr	-1130(ra) # 80000c9c <release>

  // Go to sleep.
  p->chan = chan;
    8000210e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002112:	4789                	li	a5,2
    80002114:	cc9c                	sw	a5,24(s1)

  sched();
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	eb8080e7          	jalr	-328(ra) # 80001fce <sched>

  // Tidy up.
  p->chan = 0;
    8000211e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002122:	8526                	mv	a0,s1
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b78080e7          	jalr	-1160(ra) # 80000c9c <release>
  acquire(lk);
    8000212c:	854a                	mv	a0,s2
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	aa4080e7          	jalr	-1372(ra) # 80000bd2 <acquire>
}
    80002136:	70a2                	ld	ra,40(sp)
    80002138:	7402                	ld	s0,32(sp)
    8000213a:	64e2                	ld	s1,24(sp)
    8000213c:	6942                	ld	s2,16(sp)
    8000213e:	69a2                	ld	s3,8(sp)
    80002140:	6145                	addi	sp,sp,48
    80002142:	8082                	ret

0000000080002144 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002144:	7139                	addi	sp,sp,-64
    80002146:	fc06                	sd	ra,56(sp)
    80002148:	f822                	sd	s0,48(sp)
    8000214a:	f426                	sd	s1,40(sp)
    8000214c:	f04a                	sd	s2,32(sp)
    8000214e:	ec4e                	sd	s3,24(sp)
    80002150:	e852                	sd	s4,16(sp)
    80002152:	e456                	sd	s5,8(sp)
    80002154:	0080                	addi	s0,sp,64
    80002156:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002158:	0000f497          	auipc	s1,0xf
    8000215c:	e8848493          	addi	s1,s1,-376 # 80010fe0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002160:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002162:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002164:	00015917          	auipc	s2,0x15
    80002168:	87c90913          	addi	s2,s2,-1924 # 800169e0 <tickslock>
    8000216c:	a811                	j	80002180 <wakeup+0x3c>
      }
      release(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b2c080e7          	jalr	-1236(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002178:	16848493          	addi	s1,s1,360
    8000217c:	03248663          	beq	s1,s2,800021a8 <wakeup+0x64>
    if(p != myproc()){
    80002180:	00000097          	auipc	ra,0x0
    80002184:	83c080e7          	jalr	-1988(ra) # 800019bc <myproc>
    80002188:	fea488e3          	beq	s1,a0,80002178 <wakeup+0x34>
      acquire(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	a44080e7          	jalr	-1468(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002196:	4c9c                	lw	a5,24(s1)
    80002198:	fd379be3          	bne	a5,s3,8000216e <wakeup+0x2a>
    8000219c:	709c                	ld	a5,32(s1)
    8000219e:	fd4798e3          	bne	a5,s4,8000216e <wakeup+0x2a>
        p->state = RUNNABLE;
    800021a2:	0154ac23          	sw	s5,24(s1)
    800021a6:	b7e1                	j	8000216e <wakeup+0x2a>
    }
  }
}
    800021a8:	70e2                	ld	ra,56(sp)
    800021aa:	7442                	ld	s0,48(sp)
    800021ac:	74a2                	ld	s1,40(sp)
    800021ae:	7902                	ld	s2,32(sp)
    800021b0:	69e2                	ld	s3,24(sp)
    800021b2:	6a42                	ld	s4,16(sp)
    800021b4:	6aa2                	ld	s5,8(sp)
    800021b6:	6121                	addi	sp,sp,64
    800021b8:	8082                	ret

00000000800021ba <reparent>:
{
    800021ba:	7179                	addi	sp,sp,-48
    800021bc:	f406                	sd	ra,40(sp)
    800021be:	f022                	sd	s0,32(sp)
    800021c0:	ec26                	sd	s1,24(sp)
    800021c2:	e84a                	sd	s2,16(sp)
    800021c4:	e44e                	sd	s3,8(sp)
    800021c6:	e052                	sd	s4,0(sp)
    800021c8:	1800                	addi	s0,sp,48
    800021ca:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021cc:	0000f497          	auipc	s1,0xf
    800021d0:	e1448493          	addi	s1,s1,-492 # 80010fe0 <proc>
      pp->parent = initproc;
    800021d4:	00006a17          	auipc	s4,0x6
    800021d8:	764a0a13          	addi	s4,s4,1892 # 80008938 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021dc:	00015997          	auipc	s3,0x15
    800021e0:	80498993          	addi	s3,s3,-2044 # 800169e0 <tickslock>
    800021e4:	a029                	j	800021ee <reparent+0x34>
    800021e6:	16848493          	addi	s1,s1,360
    800021ea:	01348d63          	beq	s1,s3,80002204 <reparent+0x4a>
    if(pp->parent == p){
    800021ee:	7c9c                	ld	a5,56(s1)
    800021f0:	ff279be3          	bne	a5,s2,800021e6 <reparent+0x2c>
      pp->parent = initproc;
    800021f4:	000a3503          	ld	a0,0(s4)
    800021f8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	f4a080e7          	jalr	-182(ra) # 80002144 <wakeup>
    80002202:	b7d5                	j	800021e6 <reparent+0x2c>
}
    80002204:	70a2                	ld	ra,40(sp)
    80002206:	7402                	ld	s0,32(sp)
    80002208:	64e2                	ld	s1,24(sp)
    8000220a:	6942                	ld	s2,16(sp)
    8000220c:	69a2                	ld	s3,8(sp)
    8000220e:	6a02                	ld	s4,0(sp)
    80002210:	6145                	addi	sp,sp,48
    80002212:	8082                	ret

0000000080002214 <exit>:
{
    80002214:	7179                	addi	sp,sp,-48
    80002216:	f406                	sd	ra,40(sp)
    80002218:	f022                	sd	s0,32(sp)
    8000221a:	ec26                	sd	s1,24(sp)
    8000221c:	e84a                	sd	s2,16(sp)
    8000221e:	e44e                	sd	s3,8(sp)
    80002220:	e052                	sd	s4,0(sp)
    80002222:	1800                	addi	s0,sp,48
    80002224:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	796080e7          	jalr	1942(ra) # 800019bc <myproc>
    8000222e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002230:	00006797          	auipc	a5,0x6
    80002234:	7087b783          	ld	a5,1800(a5) # 80008938 <initproc>
    80002238:	0d050493          	addi	s1,a0,208
    8000223c:	15050913          	addi	s2,a0,336
    80002240:	02a79363          	bne	a5,a0,80002266 <exit+0x52>
    panic("init exiting");
    80002244:	00006517          	auipc	a0,0x6
    80002248:	03450513          	addi	a0,a0,52 # 80008278 <digits+0x238>
    8000224c:	ffffe097          	auipc	ra,0xffffe
    80002250:	2f0080e7          	jalr	752(ra) # 8000053c <panic>
      fileclose(f);
    80002254:	00002097          	auipc	ra,0x2
    80002258:	3b6080e7          	jalr	950(ra) # 8000460a <fileclose>
      p->ofile[fd] = 0;
    8000225c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002260:	04a1                	addi	s1,s1,8
    80002262:	01248563          	beq	s1,s2,8000226c <exit+0x58>
    if(p->ofile[fd]){
    80002266:	6088                	ld	a0,0(s1)
    80002268:	f575                	bnez	a0,80002254 <exit+0x40>
    8000226a:	bfdd                	j	80002260 <exit+0x4c>
  begin_op();
    8000226c:	00002097          	auipc	ra,0x2
    80002270:	eda080e7          	jalr	-294(ra) # 80004146 <begin_op>
  iput(p->cwd);
    80002274:	1509b503          	ld	a0,336(s3)
    80002278:	00001097          	auipc	ra,0x1
    8000227c:	6e2080e7          	jalr	1762(ra) # 8000395a <iput>
  end_op();
    80002280:	00002097          	auipc	ra,0x2
    80002284:	f40080e7          	jalr	-192(ra) # 800041c0 <end_op>
  p->cwd = 0;
    80002288:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000228c:	0000f497          	auipc	s1,0xf
    80002290:	93c48493          	addi	s1,s1,-1732 # 80010bc8 <wait_lock>
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	93c080e7          	jalr	-1732(ra) # 80000bd2 <acquire>
  reparent(p);
    8000229e:	854e                	mv	a0,s3
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	f1a080e7          	jalr	-230(ra) # 800021ba <reparent>
  wakeup(p->parent);
    800022a8:	0389b503          	ld	a0,56(s3)
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	e98080e7          	jalr	-360(ra) # 80002144 <wakeup>
  acquire(&p->lock);
    800022b4:	854e                	mv	a0,s3
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	91c080e7          	jalr	-1764(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022be:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022c2:	4795                	li	a5,5
    800022c4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	9d2080e7          	jalr	-1582(ra) # 80000c9c <release>
  sched();
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	cfc080e7          	jalr	-772(ra) # 80001fce <sched>
  panic("zombie exit");
    800022da:	00006517          	auipc	a0,0x6
    800022de:	fae50513          	addi	a0,a0,-82 # 80008288 <digits+0x248>
    800022e2:	ffffe097          	auipc	ra,0xffffe
    800022e6:	25a080e7          	jalr	602(ra) # 8000053c <panic>

00000000800022ea <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022ea:	7179                	addi	sp,sp,-48
    800022ec:	f406                	sd	ra,40(sp)
    800022ee:	f022                	sd	s0,32(sp)
    800022f0:	ec26                	sd	s1,24(sp)
    800022f2:	e84a                	sd	s2,16(sp)
    800022f4:	e44e                	sd	s3,8(sp)
    800022f6:	1800                	addi	s0,sp,48
    800022f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022fa:	0000f497          	auipc	s1,0xf
    800022fe:	ce648493          	addi	s1,s1,-794 # 80010fe0 <proc>
    80002302:	00014997          	auipc	s3,0x14
    80002306:	6de98993          	addi	s3,s3,1758 # 800169e0 <tickslock>
    acquire(&p->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	8c6080e7          	jalr	-1850(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    80002314:	589c                	lw	a5,48(s1)
    80002316:	01278d63          	beq	a5,s2,80002330 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	980080e7          	jalr	-1664(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002324:	16848493          	addi	s1,s1,360
    80002328:	ff3491e3          	bne	s1,s3,8000230a <kill+0x20>
  }
  return -1;
    8000232c:	557d                	li	a0,-1
    8000232e:	a829                	j	80002348 <kill+0x5e>
      p->killed = 1;
    80002330:	4785                	li	a5,1
    80002332:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002334:	4c98                	lw	a4,24(s1)
    80002336:	4789                	li	a5,2
    80002338:	00f70f63          	beq	a4,a5,80002356 <kill+0x6c>
      release(&p->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	95e080e7          	jalr	-1698(ra) # 80000c9c <release>
      return 0;
    80002346:	4501                	li	a0,0
}
    80002348:	70a2                	ld	ra,40(sp)
    8000234a:	7402                	ld	s0,32(sp)
    8000234c:	64e2                	ld	s1,24(sp)
    8000234e:	6942                	ld	s2,16(sp)
    80002350:	69a2                	ld	s3,8(sp)
    80002352:	6145                	addi	sp,sp,48
    80002354:	8082                	ret
        p->state = RUNNABLE;
    80002356:	478d                	li	a5,3
    80002358:	cc9c                	sw	a5,24(s1)
    8000235a:	b7cd                	j	8000233c <kill+0x52>

000000008000235c <setkilled>:

void
setkilled(struct proc *p)
{
    8000235c:	1101                	addi	sp,sp,-32
    8000235e:	ec06                	sd	ra,24(sp)
    80002360:	e822                	sd	s0,16(sp)
    80002362:	e426                	sd	s1,8(sp)
    80002364:	1000                	addi	s0,sp,32
    80002366:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	86a080e7          	jalr	-1942(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002370:	4785                	li	a5,1
    80002372:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	926080e7          	jalr	-1754(ra) # 80000c9c <release>
}
    8000237e:	60e2                	ld	ra,24(sp)
    80002380:	6442                	ld	s0,16(sp)
    80002382:	64a2                	ld	s1,8(sp)
    80002384:	6105                	addi	sp,sp,32
    80002386:	8082                	ret

0000000080002388 <killed>:

int
killed(struct proc *p)
{
    80002388:	1101                	addi	sp,sp,-32
    8000238a:	ec06                	sd	ra,24(sp)
    8000238c:	e822                	sd	s0,16(sp)
    8000238e:	e426                	sd	s1,8(sp)
    80002390:	e04a                	sd	s2,0(sp)
    80002392:	1000                	addi	s0,sp,32
    80002394:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	83c080e7          	jalr	-1988(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000239e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	8f8080e7          	jalr	-1800(ra) # 80000c9c <release>
  return k;
}
    800023ac:	854a                	mv	a0,s2
    800023ae:	60e2                	ld	ra,24(sp)
    800023b0:	6442                	ld	s0,16(sp)
    800023b2:	64a2                	ld	s1,8(sp)
    800023b4:	6902                	ld	s2,0(sp)
    800023b6:	6105                	addi	sp,sp,32
    800023b8:	8082                	ret

00000000800023ba <wait>:
{
    800023ba:	715d                	addi	sp,sp,-80
    800023bc:	e486                	sd	ra,72(sp)
    800023be:	e0a2                	sd	s0,64(sp)
    800023c0:	fc26                	sd	s1,56(sp)
    800023c2:	f84a                	sd	s2,48(sp)
    800023c4:	f44e                	sd	s3,40(sp)
    800023c6:	f052                	sd	s4,32(sp)
    800023c8:	ec56                	sd	s5,24(sp)
    800023ca:	e85a                	sd	s6,16(sp)
    800023cc:	e45e                	sd	s7,8(sp)
    800023ce:	e062                	sd	s8,0(sp)
    800023d0:	0880                	addi	s0,sp,80
    800023d2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	5e8080e7          	jalr	1512(ra) # 800019bc <myproc>
    800023dc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023de:	0000e517          	auipc	a0,0xe
    800023e2:	7ea50513          	addi	a0,a0,2026 # 80010bc8 <wait_lock>
    800023e6:	ffffe097          	auipc	ra,0xffffe
    800023ea:	7ec080e7          	jalr	2028(ra) # 80000bd2 <acquire>
    havekids = 0;
    800023ee:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023f0:	4a15                	li	s4,5
        havekids = 1;
    800023f2:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f4:	00014997          	auipc	s3,0x14
    800023f8:	5ec98993          	addi	s3,s3,1516 # 800169e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023fc:	0000ec17          	auipc	s8,0xe
    80002400:	7ccc0c13          	addi	s8,s8,1996 # 80010bc8 <wait_lock>
    80002404:	a0d1                	j	800024c8 <wait+0x10e>
          pid = pp->pid;
    80002406:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000240a:	000b0e63          	beqz	s6,80002426 <wait+0x6c>
    8000240e:	4691                	li	a3,4
    80002410:	02c48613          	addi	a2,s1,44
    80002414:	85da                	mv	a1,s6
    80002416:	05093503          	ld	a0,80(s2)
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	262080e7          	jalr	610(ra) # 8000167c <copyout>
    80002422:	04054163          	bltz	a0,80002464 <wait+0xaa>
          freeproc(pp);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	746080e7          	jalr	1862(ra) # 80001b6e <freeproc>
          release(&pp->lock);
    80002430:	8526                	mv	a0,s1
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	86a080e7          	jalr	-1942(ra) # 80000c9c <release>
          release(&wait_lock);
    8000243a:	0000e517          	auipc	a0,0xe
    8000243e:	78e50513          	addi	a0,a0,1934 # 80010bc8 <wait_lock>
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	85a080e7          	jalr	-1958(ra) # 80000c9c <release>
}
    8000244a:	854e                	mv	a0,s3
    8000244c:	60a6                	ld	ra,72(sp)
    8000244e:	6406                	ld	s0,64(sp)
    80002450:	74e2                	ld	s1,56(sp)
    80002452:	7942                	ld	s2,48(sp)
    80002454:	79a2                	ld	s3,40(sp)
    80002456:	7a02                	ld	s4,32(sp)
    80002458:	6ae2                	ld	s5,24(sp)
    8000245a:	6b42                	ld	s6,16(sp)
    8000245c:	6ba2                	ld	s7,8(sp)
    8000245e:	6c02                	ld	s8,0(sp)
    80002460:	6161                	addi	sp,sp,80
    80002462:	8082                	ret
            release(&pp->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	836080e7          	jalr	-1994(ra) # 80000c9c <release>
            release(&wait_lock);
    8000246e:	0000e517          	auipc	a0,0xe
    80002472:	75a50513          	addi	a0,a0,1882 # 80010bc8 <wait_lock>
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	826080e7          	jalr	-2010(ra) # 80000c9c <release>
            return -1;
    8000247e:	59fd                	li	s3,-1
    80002480:	b7e9                	j	8000244a <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002482:	16848493          	addi	s1,s1,360
    80002486:	03348463          	beq	s1,s3,800024ae <wait+0xf4>
      if(pp->parent == p){
    8000248a:	7c9c                	ld	a5,56(s1)
    8000248c:	ff279be3          	bne	a5,s2,80002482 <wait+0xc8>
        acquire(&pp->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	740080e7          	jalr	1856(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    8000249a:	4c9c                	lw	a5,24(s1)
    8000249c:	f74785e3          	beq	a5,s4,80002406 <wait+0x4c>
        release(&pp->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7fa080e7          	jalr	2042(ra) # 80000c9c <release>
        havekids = 1;
    800024aa:	8756                	mv	a4,s5
    800024ac:	bfd9                	j	80002482 <wait+0xc8>
    if(!havekids || killed(p)){
    800024ae:	c31d                	beqz	a4,800024d4 <wait+0x11a>
    800024b0:	854a                	mv	a0,s2
    800024b2:	00000097          	auipc	ra,0x0
    800024b6:	ed6080e7          	jalr	-298(ra) # 80002388 <killed>
    800024ba:	ed09                	bnez	a0,800024d4 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024bc:	85e2                	mv	a1,s8
    800024be:	854a                	mv	a0,s2
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	c20080e7          	jalr	-992(ra) # 800020e0 <sleep>
    havekids = 0;
    800024c8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024ca:	0000f497          	auipc	s1,0xf
    800024ce:	b1648493          	addi	s1,s1,-1258 # 80010fe0 <proc>
    800024d2:	bf65                	j	8000248a <wait+0xd0>
      release(&wait_lock);
    800024d4:	0000e517          	auipc	a0,0xe
    800024d8:	6f450513          	addi	a0,a0,1780 # 80010bc8 <wait_lock>
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7c0080e7          	jalr	1984(ra) # 80000c9c <release>
      return -1;
    800024e4:	59fd                	li	s3,-1
    800024e6:	b795                	j	8000244a <wait+0x90>

00000000800024e8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024e8:	7179                	addi	sp,sp,-48
    800024ea:	f406                	sd	ra,40(sp)
    800024ec:	f022                	sd	s0,32(sp)
    800024ee:	ec26                	sd	s1,24(sp)
    800024f0:	e84a                	sd	s2,16(sp)
    800024f2:	e44e                	sd	s3,8(sp)
    800024f4:	e052                	sd	s4,0(sp)
    800024f6:	1800                	addi	s0,sp,48
    800024f8:	84aa                	mv	s1,a0
    800024fa:	892e                	mv	s2,a1
    800024fc:	89b2                	mv	s3,a2
    800024fe:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002500:	fffff097          	auipc	ra,0xfffff
    80002504:	4bc080e7          	jalr	1212(ra) # 800019bc <myproc>
  if(user_dst){
    80002508:	c08d                	beqz	s1,8000252a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000250a:	86d2                	mv	a3,s4
    8000250c:	864e                	mv	a2,s3
    8000250e:	85ca                	mv	a1,s2
    80002510:	6928                	ld	a0,80(a0)
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	16a080e7          	jalr	362(ra) # 8000167c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000251a:	70a2                	ld	ra,40(sp)
    8000251c:	7402                	ld	s0,32(sp)
    8000251e:	64e2                	ld	s1,24(sp)
    80002520:	6942                	ld	s2,16(sp)
    80002522:	69a2                	ld	s3,8(sp)
    80002524:	6a02                	ld	s4,0(sp)
    80002526:	6145                	addi	sp,sp,48
    80002528:	8082                	ret
    memmove((char *)dst, src, len);
    8000252a:	000a061b          	sext.w	a2,s4
    8000252e:	85ce                	mv	a1,s3
    80002530:	854a                	mv	a0,s2
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	80e080e7          	jalr	-2034(ra) # 80000d40 <memmove>
    return 0;
    8000253a:	8526                	mv	a0,s1
    8000253c:	bff9                	j	8000251a <either_copyout+0x32>

000000008000253e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000253e:	7179                	addi	sp,sp,-48
    80002540:	f406                	sd	ra,40(sp)
    80002542:	f022                	sd	s0,32(sp)
    80002544:	ec26                	sd	s1,24(sp)
    80002546:	e84a                	sd	s2,16(sp)
    80002548:	e44e                	sd	s3,8(sp)
    8000254a:	e052                	sd	s4,0(sp)
    8000254c:	1800                	addi	s0,sp,48
    8000254e:	892a                	mv	s2,a0
    80002550:	84ae                	mv	s1,a1
    80002552:	89b2                	mv	s3,a2
    80002554:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	466080e7          	jalr	1126(ra) # 800019bc <myproc>
  if(user_src){
    8000255e:	c08d                	beqz	s1,80002580 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002560:	86d2                	mv	a3,s4
    80002562:	864e                	mv	a2,s3
    80002564:	85ca                	mv	a1,s2
    80002566:	6928                	ld	a0,80(a0)
    80002568:	fffff097          	auipc	ra,0xfffff
    8000256c:	1a0080e7          	jalr	416(ra) # 80001708 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002570:	70a2                	ld	ra,40(sp)
    80002572:	7402                	ld	s0,32(sp)
    80002574:	64e2                	ld	s1,24(sp)
    80002576:	6942                	ld	s2,16(sp)
    80002578:	69a2                	ld	s3,8(sp)
    8000257a:	6a02                	ld	s4,0(sp)
    8000257c:	6145                	addi	sp,sp,48
    8000257e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002580:	000a061b          	sext.w	a2,s4
    80002584:	85ce                	mv	a1,s3
    80002586:	854a                	mv	a0,s2
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	7b8080e7          	jalr	1976(ra) # 80000d40 <memmove>
    return 0;
    80002590:	8526                	mv	a0,s1
    80002592:	bff9                	j	80002570 <either_copyin+0x32>

0000000080002594 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002594:	715d                	addi	sp,sp,-80
    80002596:	e486                	sd	ra,72(sp)
    80002598:	e0a2                	sd	s0,64(sp)
    8000259a:	fc26                	sd	s1,56(sp)
    8000259c:	f84a                	sd	s2,48(sp)
    8000259e:	f44e                	sd	s3,40(sp)
    800025a0:	f052                	sd	s4,32(sp)
    800025a2:	ec56                	sd	s5,24(sp)
    800025a4:	e85a                	sd	s6,16(sp)
    800025a6:	e45e                	sd	s7,8(sp)
    800025a8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025aa:	00006517          	auipc	a0,0x6
    800025ae:	ad650513          	addi	a0,a0,-1322 # 80008080 <digits+0x40>
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	fd4080e7          	jalr	-44(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ba:	0000f497          	auipc	s1,0xf
    800025be:	b7e48493          	addi	s1,s1,-1154 # 80011138 <proc+0x158>
    800025c2:	00014917          	auipc	s2,0x14
    800025c6:	57690913          	addi	s2,s2,1398 # 80016b38 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ca:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025cc:	00006997          	auipc	s3,0x6
    800025d0:	ccc98993          	addi	s3,s3,-820 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    800025d4:	00006a97          	auipc	s5,0x6
    800025d8:	ccca8a93          	addi	s5,s5,-820 # 800082a0 <digits+0x260>
    printf("\n");
    800025dc:	00006a17          	auipc	s4,0x6
    800025e0:	aa4a0a13          	addi	s4,s4,-1372 # 80008080 <digits+0x40>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e4:	00006b97          	auipc	s7,0x6
    800025e8:	cfcb8b93          	addi	s7,s7,-772 # 800082e0 <states.0>
    800025ec:	a00d                	j	8000260e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025ee:	ed86a583          	lw	a1,-296(a3)
    800025f2:	8556                	mv	a0,s5
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	f92080e7          	jalr	-110(ra) # 80000586 <printf>
    printf("\n");
    800025fc:	8552                	mv	a0,s4
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	f88080e7          	jalr	-120(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002606:	16848493          	addi	s1,s1,360
    8000260a:	03248263          	beq	s1,s2,8000262e <procdump+0x9a>
    if(p->state == UNUSED)
    8000260e:	86a6                	mv	a3,s1
    80002610:	ec04a783          	lw	a5,-320(s1)
    80002614:	dbed                	beqz	a5,80002606 <procdump+0x72>
      state = "???";
    80002616:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002618:	fcfb6be3          	bltu	s6,a5,800025ee <procdump+0x5a>
    8000261c:	02079713          	slli	a4,a5,0x20
    80002620:	01d75793          	srli	a5,a4,0x1d
    80002624:	97de                	add	a5,a5,s7
    80002626:	6390                	ld	a2,0(a5)
    80002628:	f279                	bnez	a2,800025ee <procdump+0x5a>
      state = "???";
    8000262a:	864e                	mv	a2,s3
    8000262c:	b7c9                	j	800025ee <procdump+0x5a>
  }
}
    8000262e:	60a6                	ld	ra,72(sp)
    80002630:	6406                	ld	s0,64(sp)
    80002632:	74e2                	ld	s1,56(sp)
    80002634:	7942                	ld	s2,48(sp)
    80002636:	79a2                	ld	s3,40(sp)
    80002638:	7a02                	ld	s4,32(sp)
    8000263a:	6ae2                	ld	s5,24(sp)
    8000263c:	6b42                	ld	s6,16(sp)
    8000263e:	6ba2                	ld	s7,8(sp)
    80002640:	6161                	addi	sp,sp,80
    80002642:	8082                	ret

0000000080002644 <swtch>:
    80002644:	00153023          	sd	ra,0(a0)
    80002648:	00253423          	sd	sp,8(a0)
    8000264c:	e900                	sd	s0,16(a0)
    8000264e:	ed04                	sd	s1,24(a0)
    80002650:	03253023          	sd	s2,32(a0)
    80002654:	03353423          	sd	s3,40(a0)
    80002658:	03453823          	sd	s4,48(a0)
    8000265c:	03553c23          	sd	s5,56(a0)
    80002660:	05653023          	sd	s6,64(a0)
    80002664:	05753423          	sd	s7,72(a0)
    80002668:	05853823          	sd	s8,80(a0)
    8000266c:	05953c23          	sd	s9,88(a0)
    80002670:	07a53023          	sd	s10,96(a0)
    80002674:	07b53423          	sd	s11,104(a0)
    80002678:	0005b083          	ld	ra,0(a1)
    8000267c:	0085b103          	ld	sp,8(a1)
    80002680:	6980                	ld	s0,16(a1)
    80002682:	6d84                	ld	s1,24(a1)
    80002684:	0205b903          	ld	s2,32(a1)
    80002688:	0285b983          	ld	s3,40(a1)
    8000268c:	0305ba03          	ld	s4,48(a1)
    80002690:	0385ba83          	ld	s5,56(a1)
    80002694:	0405bb03          	ld	s6,64(a1)
    80002698:	0485bb83          	ld	s7,72(a1)
    8000269c:	0505bc03          	ld	s8,80(a1)
    800026a0:	0585bc83          	ld	s9,88(a1)
    800026a4:	0605bd03          	ld	s10,96(a1)
    800026a8:	0685bd83          	ld	s11,104(a1)
    800026ac:	8082                	ret

00000000800026ae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ae:	1141                	addi	sp,sp,-16
    800026b0:	e406                	sd	ra,8(sp)
    800026b2:	e022                	sd	s0,0(sp)
    800026b4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026b6:	00006597          	auipc	a1,0x6
    800026ba:	c5a58593          	addi	a1,a1,-934 # 80008310 <states.0+0x30>
    800026be:	00014517          	auipc	a0,0x14
    800026c2:	32250513          	addi	a0,a0,802 # 800169e0 <tickslock>
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	47c080e7          	jalr	1148(ra) # 80000b42 <initlock>
}
    800026ce:	60a2                	ld	ra,8(sp)
    800026d0:	6402                	ld	s0,0(sp)
    800026d2:	0141                	addi	sp,sp,16
    800026d4:	8082                	ret

00000000800026d6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026d6:	1141                	addi	sp,sp,-16
    800026d8:	e422                	sd	s0,8(sp)
    800026da:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026dc:	00003797          	auipc	a5,0x3
    800026e0:	55478793          	addi	a5,a5,1364 # 80005c30 <kernelvec>
    800026e4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026e8:	6422                	ld	s0,8(sp)
    800026ea:	0141                	addi	sp,sp,16
    800026ec:	8082                	ret

00000000800026ee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ee:	1141                	addi	sp,sp,-16
    800026f0:	e406                	sd	ra,8(sp)
    800026f2:	e022                	sd	s0,0(sp)
    800026f4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	2c6080e7          	jalr	710(ra) # 800019bc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002702:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002704:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002708:	00005697          	auipc	a3,0x5
    8000270c:	8f868693          	addi	a3,a3,-1800 # 80007000 <_trampoline>
    80002710:	00005717          	auipc	a4,0x5
    80002714:	8f070713          	addi	a4,a4,-1808 # 80007000 <_trampoline>
    80002718:	8f15                	sub	a4,a4,a3
    8000271a:	040007b7          	lui	a5,0x4000
    8000271e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002720:	07b2                	slli	a5,a5,0xc
    80002722:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002724:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002728:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000272a:	18002673          	csrr	a2,satp
    8000272e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002730:	6d30                	ld	a2,88(a0)
    80002732:	6138                	ld	a4,64(a0)
    80002734:	6585                	lui	a1,0x1
    80002736:	972e                	add	a4,a4,a1
    80002738:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000273a:	6d38                	ld	a4,88(a0)
    8000273c:	00000617          	auipc	a2,0x0
    80002740:	13460613          	addi	a2,a2,308 # 80002870 <usertrap>
    80002744:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002746:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002748:	8612                	mv	a2,tp
    8000274a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000274c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002750:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002754:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002758:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000275c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000275e:	6f18                	ld	a4,24(a4)
    80002760:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002764:	6928                	ld	a0,80(a0)
    80002766:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002768:	00005717          	auipc	a4,0x5
    8000276c:	93470713          	addi	a4,a4,-1740 # 8000709c <userret>
    80002770:	8f15                	sub	a4,a4,a3
    80002772:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002774:	577d                	li	a4,-1
    80002776:	177e                	slli	a4,a4,0x3f
    80002778:	8d59                	or	a0,a0,a4
    8000277a:	9782                	jalr	a5
}
    8000277c:	60a2                	ld	ra,8(sp)
    8000277e:	6402                	ld	s0,0(sp)
    80002780:	0141                	addi	sp,sp,16
    80002782:	8082                	ret

0000000080002784 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000278e:	00014497          	auipc	s1,0x14
    80002792:	25248493          	addi	s1,s1,594 # 800169e0 <tickslock>
    80002796:	8526                	mv	a0,s1
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	43a080e7          	jalr	1082(ra) # 80000bd2 <acquire>
  ticks++;
    800027a0:	00006517          	auipc	a0,0x6
    800027a4:	1a050513          	addi	a0,a0,416 # 80008940 <ticks>
    800027a8:	411c                	lw	a5,0(a0)
    800027aa:	2785                	addiw	a5,a5,1
    800027ac:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027ae:	00000097          	auipc	ra,0x0
    800027b2:	996080e7          	jalr	-1642(ra) # 80002144 <wakeup>
  release(&tickslock);
    800027b6:	8526                	mv	a0,s1
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	4e4080e7          	jalr	1252(ra) # 80000c9c <release>
}
    800027c0:	60e2                	ld	ra,24(sp)
    800027c2:	6442                	ld	s0,16(sp)
    800027c4:	64a2                	ld	s1,8(sp)
    800027c6:	6105                	addi	sp,sp,32
    800027c8:	8082                	ret

00000000800027ca <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ca:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027ce:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027d0:	0807df63          	bgez	a5,8000286e <devintr+0xa4>
{
    800027d4:	1101                	addi	sp,sp,-32
    800027d6:	ec06                	sd	ra,24(sp)
    800027d8:	e822                	sd	s0,16(sp)
    800027da:	e426                	sd	s1,8(sp)
    800027dc:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027de:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027e2:	46a5                	li	a3,9
    800027e4:	00d70d63          	beq	a4,a3,800027fe <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800027e8:	577d                	li	a4,-1
    800027ea:	177e                	slli	a4,a4,0x3f
    800027ec:	0705                	addi	a4,a4,1
    return 0;
    800027ee:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027f0:	04e78e63          	beq	a5,a4,8000284c <devintr+0x82>
  }
}
    800027f4:	60e2                	ld	ra,24(sp)
    800027f6:	6442                	ld	s0,16(sp)
    800027f8:	64a2                	ld	s1,8(sp)
    800027fa:	6105                	addi	sp,sp,32
    800027fc:	8082                	ret
    int irq = plic_claim();
    800027fe:	00003097          	auipc	ra,0x3
    80002802:	53a080e7          	jalr	1338(ra) # 80005d38 <plic_claim>
    80002806:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002808:	47a9                	li	a5,10
    8000280a:	02f50763          	beq	a0,a5,80002838 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000280e:	4785                	li	a5,1
    80002810:	02f50963          	beq	a0,a5,80002842 <devintr+0x78>
    return 1;
    80002814:	4505                	li	a0,1
    } else if(irq){
    80002816:	dcf9                	beqz	s1,800027f4 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002818:	85a6                	mv	a1,s1
    8000281a:	00006517          	auipc	a0,0x6
    8000281e:	afe50513          	addi	a0,a0,-1282 # 80008318 <states.0+0x38>
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	d64080e7          	jalr	-668(ra) # 80000586 <printf>
      plic_complete(irq);
    8000282a:	8526                	mv	a0,s1
    8000282c:	00003097          	auipc	ra,0x3
    80002830:	530080e7          	jalr	1328(ra) # 80005d5c <plic_complete>
    return 1;
    80002834:	4505                	li	a0,1
    80002836:	bf7d                	j	800027f4 <devintr+0x2a>
      uartintr();
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	15c080e7          	jalr	348(ra) # 80000994 <uartintr>
    if(irq)
    80002840:	b7ed                	j	8000282a <devintr+0x60>
      virtio_disk_intr();
    80002842:	00004097          	auipc	ra,0x4
    80002846:	9e0080e7          	jalr	-1568(ra) # 80006222 <virtio_disk_intr>
    if(irq)
    8000284a:	b7c5                	j	8000282a <devintr+0x60>
    if(cpuid() == 0){
    8000284c:	fffff097          	auipc	ra,0xfffff
    80002850:	144080e7          	jalr	324(ra) # 80001990 <cpuid>
    80002854:	c901                	beqz	a0,80002864 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002856:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000285a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000285c:	14479073          	csrw	sip,a5
    return 2;
    80002860:	4509                	li	a0,2
    80002862:	bf49                	j	800027f4 <devintr+0x2a>
      clockintr();
    80002864:	00000097          	auipc	ra,0x0
    80002868:	f20080e7          	jalr	-224(ra) # 80002784 <clockintr>
    8000286c:	b7ed                	j	80002856 <devintr+0x8c>
}
    8000286e:	8082                	ret

0000000080002870 <usertrap>:
{
    80002870:	1101                	addi	sp,sp,-32
    80002872:	ec06                	sd	ra,24(sp)
    80002874:	e822                	sd	s0,16(sp)
    80002876:	e426                	sd	s1,8(sp)
    80002878:	e04a                	sd	s2,0(sp)
    8000287a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002880:	1007f793          	andi	a5,a5,256
    80002884:	e3b1                	bnez	a5,800028c8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002886:	00003797          	auipc	a5,0x3
    8000288a:	3aa78793          	addi	a5,a5,938 # 80005c30 <kernelvec>
    8000288e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	12a080e7          	jalr	298(ra) # 800019bc <myproc>
    8000289a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000289c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000289e:	14102773          	csrr	a4,sepc
    800028a2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028a8:	47a1                	li	a5,8
    800028aa:	02f70763          	beq	a4,a5,800028d8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	f1c080e7          	jalr	-228(ra) # 800027ca <devintr>
    800028b6:	892a                	mv	s2,a0
    800028b8:	c151                	beqz	a0,8000293c <usertrap+0xcc>
  if(killed(p))
    800028ba:	8526                	mv	a0,s1
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	acc080e7          	jalr	-1332(ra) # 80002388 <killed>
    800028c4:	c929                	beqz	a0,80002916 <usertrap+0xa6>
    800028c6:	a099                	j	8000290c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	a7050513          	addi	a0,a0,-1424 # 80008338 <states.0+0x58>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	c6c080e7          	jalr	-916(ra) # 8000053c <panic>
    if(killed(p))
    800028d8:	00000097          	auipc	ra,0x0
    800028dc:	ab0080e7          	jalr	-1360(ra) # 80002388 <killed>
    800028e0:	e921                	bnez	a0,80002930 <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028e2:	6cb8                	ld	a4,88(s1)
    800028e4:	6f1c                	ld	a5,24(a4)
    800028e6:	0791                	addi	a5,a5,4
    800028e8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f2:	10079073          	csrw	sstatus,a5
    syscall();
    800028f6:	00000097          	auipc	ra,0x0
    800028fa:	2d4080e7          	jalr	724(ra) # 80002bca <syscall>
  if(killed(p))
    800028fe:	8526                	mv	a0,s1
    80002900:	00000097          	auipc	ra,0x0
    80002904:	a88080e7          	jalr	-1400(ra) # 80002388 <killed>
    80002908:	c911                	beqz	a0,8000291c <usertrap+0xac>
    8000290a:	4901                	li	s2,0
    exit(-1);
    8000290c:	557d                	li	a0,-1
    8000290e:	00000097          	auipc	ra,0x0
    80002912:	906080e7          	jalr	-1786(ra) # 80002214 <exit>
  if(which_dev == 2)
    80002916:	4789                	li	a5,2
    80002918:	04f90f63          	beq	s2,a5,80002976 <usertrap+0x106>
  usertrapret();
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	dd2080e7          	jalr	-558(ra) # 800026ee <usertrapret>
}
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6902                	ld	s2,0(sp)
    8000292c:	6105                	addi	sp,sp,32
    8000292e:	8082                	ret
      exit(-1);
    80002930:	557d                	li	a0,-1
    80002932:	00000097          	auipc	ra,0x0
    80002936:	8e2080e7          	jalr	-1822(ra) # 80002214 <exit>
    8000293a:	b765                	j	800028e2 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000293c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002940:	5890                	lw	a2,48(s1)
    80002942:	00006517          	auipc	a0,0x6
    80002946:	a1650513          	addi	a0,a0,-1514 # 80008358 <states.0+0x78>
    8000294a:	ffffe097          	auipc	ra,0xffffe
    8000294e:	c3c080e7          	jalr	-964(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002952:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002956:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000295a:	00006517          	auipc	a0,0x6
    8000295e:	a2e50513          	addi	a0,a0,-1490 # 80008388 <states.0+0xa8>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	c24080e7          	jalr	-988(ra) # 80000586 <printf>
    setkilled(p);
    8000296a:	8526                	mv	a0,s1
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	9f0080e7          	jalr	-1552(ra) # 8000235c <setkilled>
    80002974:	b769                	j	800028fe <usertrap+0x8e>
    yield();
    80002976:	fffff097          	auipc	ra,0xfffff
    8000297a:	72e080e7          	jalr	1838(ra) # 800020a4 <yield>
    8000297e:	bf79                	j	8000291c <usertrap+0xac>

0000000080002980 <kerneltrap>:
{
    80002980:	7179                	addi	sp,sp,-48
    80002982:	f406                	sd	ra,40(sp)
    80002984:	f022                	sd	s0,32(sp)
    80002986:	ec26                	sd	s1,24(sp)
    80002988:	e84a                	sd	s2,16(sp)
    8000298a:	e44e                	sd	s3,8(sp)
    8000298c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002992:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002996:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000299a:	1004f793          	andi	a5,s1,256
    8000299e:	cb85                	beqz	a5,800029ce <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029a4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029a6:	ef85                	bnez	a5,800029de <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	e22080e7          	jalr	-478(ra) # 800027ca <devintr>
    800029b0:	cd1d                	beqz	a0,800029ee <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029b2:	4789                	li	a5,2
    800029b4:	06f50a63          	beq	a0,a5,80002a28 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029b8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029bc:	10049073          	csrw	sstatus,s1
}
    800029c0:	70a2                	ld	ra,40(sp)
    800029c2:	7402                	ld	s0,32(sp)
    800029c4:	64e2                	ld	s1,24(sp)
    800029c6:	6942                	ld	s2,16(sp)
    800029c8:	69a2                	ld	s3,8(sp)
    800029ca:	6145                	addi	sp,sp,48
    800029cc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ce:	00006517          	auipc	a0,0x6
    800029d2:	9da50513          	addi	a0,a0,-1574 # 800083a8 <states.0+0xc8>
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	b66080e7          	jalr	-1178(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800029de:	00006517          	auipc	a0,0x6
    800029e2:	9f250513          	addi	a0,a0,-1550 # 800083d0 <states.0+0xf0>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	b56080e7          	jalr	-1194(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800029ee:	85ce                	mv	a1,s3
    800029f0:	00006517          	auipc	a0,0x6
    800029f4:	a0050513          	addi	a0,a0,-1536 # 800083f0 <states.0+0x110>
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	b8e080e7          	jalr	-1138(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a00:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a04:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a08:	00006517          	auipc	a0,0x6
    80002a0c:	9f850513          	addi	a0,a0,-1544 # 80008400 <states.0+0x120>
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	b76080e7          	jalr	-1162(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	a0050513          	addi	a0,a0,-1536 # 80008418 <states.0+0x138>
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	b1c080e7          	jalr	-1252(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a28:	fffff097          	auipc	ra,0xfffff
    80002a2c:	f94080e7          	jalr	-108(ra) # 800019bc <myproc>
    80002a30:	d541                	beqz	a0,800029b8 <kerneltrap+0x38>
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	f8a080e7          	jalr	-118(ra) # 800019bc <myproc>
    80002a3a:	4d18                	lw	a4,24(a0)
    80002a3c:	4791                	li	a5,4
    80002a3e:	f6f71de3          	bne	a4,a5,800029b8 <kerneltrap+0x38>
    yield();
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	662080e7          	jalr	1634(ra) # 800020a4 <yield>
    80002a4a:	b7bd                	j	800029b8 <kerneltrap+0x38>

0000000080002a4c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	e426                	sd	s1,8(sp)
    80002a54:	1000                	addi	s0,sp,32
    80002a56:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	f64080e7          	jalr	-156(ra) # 800019bc <myproc>
  switch (n) {
    80002a60:	4795                	li	a5,5
    80002a62:	0497e163          	bltu	a5,s1,80002aa4 <argraw+0x58>
    80002a66:	048a                	slli	s1,s1,0x2
    80002a68:	00006717          	auipc	a4,0x6
    80002a6c:	9e870713          	addi	a4,a4,-1560 # 80008450 <states.0+0x170>
    80002a70:	94ba                	add	s1,s1,a4
    80002a72:	409c                	lw	a5,0(s1)
    80002a74:	97ba                	add	a5,a5,a4
    80002a76:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a78:	6d3c                	ld	a5,88(a0)
    80002a7a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a7c:	60e2                	ld	ra,24(sp)
    80002a7e:	6442                	ld	s0,16(sp)
    80002a80:	64a2                	ld	s1,8(sp)
    80002a82:	6105                	addi	sp,sp,32
    80002a84:	8082                	ret
    return p->trapframe->a1;
    80002a86:	6d3c                	ld	a5,88(a0)
    80002a88:	7fa8                	ld	a0,120(a5)
    80002a8a:	bfcd                	j	80002a7c <argraw+0x30>
    return p->trapframe->a2;
    80002a8c:	6d3c                	ld	a5,88(a0)
    80002a8e:	63c8                	ld	a0,128(a5)
    80002a90:	b7f5                	j	80002a7c <argraw+0x30>
    return p->trapframe->a3;
    80002a92:	6d3c                	ld	a5,88(a0)
    80002a94:	67c8                	ld	a0,136(a5)
    80002a96:	b7dd                	j	80002a7c <argraw+0x30>
    return p->trapframe->a4;
    80002a98:	6d3c                	ld	a5,88(a0)
    80002a9a:	6bc8                	ld	a0,144(a5)
    80002a9c:	b7c5                	j	80002a7c <argraw+0x30>
    return p->trapframe->a5;
    80002a9e:	6d3c                	ld	a5,88(a0)
    80002aa0:	6fc8                	ld	a0,152(a5)
    80002aa2:	bfe9                	j	80002a7c <argraw+0x30>
  panic("argraw");
    80002aa4:	00006517          	auipc	a0,0x6
    80002aa8:	98450513          	addi	a0,a0,-1660 # 80008428 <states.0+0x148>
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	a90080e7          	jalr	-1392(ra) # 8000053c <panic>

0000000080002ab4 <fetchaddr>:
{
    80002ab4:	1101                	addi	sp,sp,-32
    80002ab6:	ec06                	sd	ra,24(sp)
    80002ab8:	e822                	sd	s0,16(sp)
    80002aba:	e426                	sd	s1,8(sp)
    80002abc:	e04a                	sd	s2,0(sp)
    80002abe:	1000                	addi	s0,sp,32
    80002ac0:	84aa                	mv	s1,a0
    80002ac2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	ef8080e7          	jalr	-264(ra) # 800019bc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002acc:	653c                	ld	a5,72(a0)
    80002ace:	02f4f863          	bgeu	s1,a5,80002afe <fetchaddr+0x4a>
    80002ad2:	00848713          	addi	a4,s1,8
    80002ad6:	02e7e663          	bltu	a5,a4,80002b02 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ada:	46a1                	li	a3,8
    80002adc:	8626                	mv	a2,s1
    80002ade:	85ca                	mv	a1,s2
    80002ae0:	6928                	ld	a0,80(a0)
    80002ae2:	fffff097          	auipc	ra,0xfffff
    80002ae6:	c26080e7          	jalr	-986(ra) # 80001708 <copyin>
    80002aea:	00a03533          	snez	a0,a0
    80002aee:	40a00533          	neg	a0,a0
}
    80002af2:	60e2                	ld	ra,24(sp)
    80002af4:	6442                	ld	s0,16(sp)
    80002af6:	64a2                	ld	s1,8(sp)
    80002af8:	6902                	ld	s2,0(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret
    return -1;
    80002afe:	557d                	li	a0,-1
    80002b00:	bfcd                	j	80002af2 <fetchaddr+0x3e>
    80002b02:	557d                	li	a0,-1
    80002b04:	b7fd                	j	80002af2 <fetchaddr+0x3e>

0000000080002b06 <fetchstr>:
{
    80002b06:	7179                	addi	sp,sp,-48
    80002b08:	f406                	sd	ra,40(sp)
    80002b0a:	f022                	sd	s0,32(sp)
    80002b0c:	ec26                	sd	s1,24(sp)
    80002b0e:	e84a                	sd	s2,16(sp)
    80002b10:	e44e                	sd	s3,8(sp)
    80002b12:	1800                	addi	s0,sp,48
    80002b14:	892a                	mv	s2,a0
    80002b16:	84ae                	mv	s1,a1
    80002b18:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	ea2080e7          	jalr	-350(ra) # 800019bc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b22:	86ce                	mv	a3,s3
    80002b24:	864a                	mv	a2,s2
    80002b26:	85a6                	mv	a1,s1
    80002b28:	6928                	ld	a0,80(a0)
    80002b2a:	fffff097          	auipc	ra,0xfffff
    80002b2e:	c6c080e7          	jalr	-916(ra) # 80001796 <copyinstr>
    80002b32:	00054e63          	bltz	a0,80002b4e <fetchstr+0x48>
  return strlen(buf);
    80002b36:	8526                	mv	a0,s1
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	326080e7          	jalr	806(ra) # 80000e5e <strlen>
}
    80002b40:	70a2                	ld	ra,40(sp)
    80002b42:	7402                	ld	s0,32(sp)
    80002b44:	64e2                	ld	s1,24(sp)
    80002b46:	6942                	ld	s2,16(sp)
    80002b48:	69a2                	ld	s3,8(sp)
    80002b4a:	6145                	addi	sp,sp,48
    80002b4c:	8082                	ret
    return -1;
    80002b4e:	557d                	li	a0,-1
    80002b50:	bfc5                	j	80002b40 <fetchstr+0x3a>

0000000080002b52 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	1000                	addi	s0,sp,32
    80002b5c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5e:	00000097          	auipc	ra,0x0
    80002b62:	eee080e7          	jalr	-274(ra) # 80002a4c <argraw>
    80002b66:	c088                	sw	a0,0(s1)
}
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	64a2                	ld	s1,8(sp)
    80002b6e:	6105                	addi	sp,sp,32
    80002b70:	8082                	ret

0000000080002b72 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b72:	1101                	addi	sp,sp,-32
    80002b74:	ec06                	sd	ra,24(sp)
    80002b76:	e822                	sd	s0,16(sp)
    80002b78:	e426                	sd	s1,8(sp)
    80002b7a:	1000                	addi	s0,sp,32
    80002b7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	ece080e7          	jalr	-306(ra) # 80002a4c <argraw>
    80002b86:	e088                	sd	a0,0(s1)
}
    80002b88:	60e2                	ld	ra,24(sp)
    80002b8a:	6442                	ld	s0,16(sp)
    80002b8c:	64a2                	ld	s1,8(sp)
    80002b8e:	6105                	addi	sp,sp,32
    80002b90:	8082                	ret

0000000080002b92 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b92:	7179                	addi	sp,sp,-48
    80002b94:	f406                	sd	ra,40(sp)
    80002b96:	f022                	sd	s0,32(sp)
    80002b98:	ec26                	sd	s1,24(sp)
    80002b9a:	e84a                	sd	s2,16(sp)
    80002b9c:	1800                	addi	s0,sp,48
    80002b9e:	84ae                	mv	s1,a1
    80002ba0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ba2:	fd840593          	addi	a1,s0,-40
    80002ba6:	00000097          	auipc	ra,0x0
    80002baa:	fcc080e7          	jalr	-52(ra) # 80002b72 <argaddr>
  return fetchstr(addr, buf, max);
    80002bae:	864a                	mv	a2,s2
    80002bb0:	85a6                	mv	a1,s1
    80002bb2:	fd843503          	ld	a0,-40(s0)
    80002bb6:	00000097          	auipc	ra,0x0
    80002bba:	f50080e7          	jalr	-176(ra) # 80002b06 <fetchstr>
}
    80002bbe:	70a2                	ld	ra,40(sp)
    80002bc0:	7402                	ld	s0,32(sp)
    80002bc2:	64e2                	ld	s1,24(sp)
    80002bc4:	6942                	ld	s2,16(sp)
    80002bc6:	6145                	addi	sp,sp,48
    80002bc8:	8082                	ret

0000000080002bca <syscall>:
[SYS_setpri]  sys_setpri,
};

void
syscall(void)
{
    80002bca:	1101                	addi	sp,sp,-32
    80002bcc:	ec06                	sd	ra,24(sp)
    80002bce:	e822                	sd	s0,16(sp)
    80002bd0:	e426                	sd	s1,8(sp)
    80002bd2:	e04a                	sd	s2,0(sp)
    80002bd4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	de6080e7          	jalr	-538(ra) # 800019bc <myproc>
    80002bde:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002be0:	05853903          	ld	s2,88(a0)
    80002be4:	0a893783          	ld	a5,168(s2)
    80002be8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bec:	37fd                	addiw	a5,a5,-1
    80002bee:	4769                	li	a4,26
    80002bf0:	00f76f63          	bltu	a4,a5,80002c0e <syscall+0x44>
    80002bf4:	00369713          	slli	a4,a3,0x3
    80002bf8:	00006797          	auipc	a5,0x6
    80002bfc:	87078793          	addi	a5,a5,-1936 # 80008468 <syscalls>
    80002c00:	97ba                	add	a5,a5,a4
    80002c02:	639c                	ld	a5,0(a5)
    80002c04:	c789                	beqz	a5,80002c0e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c06:	9782                	jalr	a5
    80002c08:	06a93823          	sd	a0,112(s2)
    80002c0c:	a839                	j	80002c2a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c0e:	15848613          	addi	a2,s1,344
    80002c12:	588c                	lw	a1,48(s1)
    80002c14:	00006517          	auipc	a0,0x6
    80002c18:	81c50513          	addi	a0,a0,-2020 # 80008430 <states.0+0x150>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	96a080e7          	jalr	-1686(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c24:	6cbc                	ld	a5,88(s1)
    80002c26:	577d                	li	a4,-1
    80002c28:	fbb8                	sd	a4,112(a5)
  }
}
    80002c2a:	60e2                	ld	ra,24(sp)
    80002c2c:	6442                	ld	s0,16(sp)
    80002c2e:	64a2                	ld	s1,8(sp)
    80002c30:	6902                	ld	s2,0(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret

0000000080002c36 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c36:	1101                	addi	sp,sp,-32
    80002c38:	ec06                	sd	ra,24(sp)
    80002c3a:	e822                	sd	s0,16(sp)
    80002c3c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c3e:	fec40593          	addi	a1,s0,-20
    80002c42:	4501                	li	a0,0
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	f0e080e7          	jalr	-242(ra) # 80002b52 <argint>
  exit(n);
    80002c4c:	fec42503          	lw	a0,-20(s0)
    80002c50:	fffff097          	auipc	ra,0xfffff
    80002c54:	5c4080e7          	jalr	1476(ra) # 80002214 <exit>
  return 0;  // not reached
}
    80002c58:	4501                	li	a0,0
    80002c5a:	60e2                	ld	ra,24(sp)
    80002c5c:	6442                	ld	s0,16(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret

0000000080002c62 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c62:	1141                	addi	sp,sp,-16
    80002c64:	e406                	sd	ra,8(sp)
    80002c66:	e022                	sd	s0,0(sp)
    80002c68:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	d52080e7          	jalr	-686(ra) # 800019bc <myproc>
}
    80002c72:	5908                	lw	a0,48(a0)
    80002c74:	60a2                	ld	ra,8(sp)
    80002c76:	6402                	ld	s0,0(sp)
    80002c78:	0141                	addi	sp,sp,16
    80002c7a:	8082                	ret

0000000080002c7c <sys_fork>:

uint64
sys_fork(void)
{
    80002c7c:	1141                	addi	sp,sp,-16
    80002c7e:	e406                	sd	ra,8(sp)
    80002c80:	e022                	sd	s0,0(sp)
    80002c82:	0800                	addi	s0,sp,16
  return fork();
    80002c84:	fffff097          	auipc	ra,0xfffff
    80002c88:	0f6080e7          	jalr	246(ra) # 80001d7a <fork>
}
    80002c8c:	60a2                	ld	ra,8(sp)
    80002c8e:	6402                	ld	s0,0(sp)
    80002c90:	0141                	addi	sp,sp,16
    80002c92:	8082                	ret

0000000080002c94 <sys_wait>:

uint64
sys_wait(void)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c9c:	fe840593          	addi	a1,s0,-24
    80002ca0:	4501                	li	a0,0
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	ed0080e7          	jalr	-304(ra) # 80002b72 <argaddr>
  return wait(p);
    80002caa:	fe843503          	ld	a0,-24(s0)
    80002cae:	fffff097          	auipc	ra,0xfffff
    80002cb2:	70c080e7          	jalr	1804(ra) # 800023ba <wait>
}
    80002cb6:	60e2                	ld	ra,24(sp)
    80002cb8:	6442                	ld	s0,16(sp)
    80002cba:	6105                	addi	sp,sp,32
    80002cbc:	8082                	ret

0000000080002cbe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cbe:	7179                	addi	sp,sp,-48
    80002cc0:	f406                	sd	ra,40(sp)
    80002cc2:	f022                	sd	s0,32(sp)
    80002cc4:	ec26                	sd	s1,24(sp)
    80002cc6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cc8:	fdc40593          	addi	a1,s0,-36
    80002ccc:	4501                	li	a0,0
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	e84080e7          	jalr	-380(ra) # 80002b52 <argint>
  addr = myproc()->sz;
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	ce6080e7          	jalr	-794(ra) # 800019bc <myproc>
    80002cde:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ce0:	fdc42503          	lw	a0,-36(s0)
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	03a080e7          	jalr	58(ra) # 80001d1e <growproc>
    80002cec:	00054863          	bltz	a0,80002cfc <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6145                	addi	sp,sp,48
    80002cfa:	8082                	ret
    return -1;
    80002cfc:	54fd                	li	s1,-1
    80002cfe:	bfcd                	j	80002cf0 <sys_sbrk+0x32>

0000000080002d00 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d00:	7139                	addi	sp,sp,-64
    80002d02:	fc06                	sd	ra,56(sp)
    80002d04:	f822                	sd	s0,48(sp)
    80002d06:	f426                	sd	s1,40(sp)
    80002d08:	f04a                	sd	s2,32(sp)
    80002d0a:	ec4e                	sd	s3,24(sp)
    80002d0c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d0e:	fcc40593          	addi	a1,s0,-52
    80002d12:	4501                	li	a0,0
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	e3e080e7          	jalr	-450(ra) # 80002b52 <argint>
  acquire(&tickslock);
    80002d1c:	00014517          	auipc	a0,0x14
    80002d20:	cc450513          	addi	a0,a0,-828 # 800169e0 <tickslock>
    80002d24:	ffffe097          	auipc	ra,0xffffe
    80002d28:	eae080e7          	jalr	-338(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002d2c:	00006917          	auipc	s2,0x6
    80002d30:	c1492903          	lw	s2,-1004(s2) # 80008940 <ticks>
  while(ticks - ticks0 < n){
    80002d34:	fcc42783          	lw	a5,-52(s0)
    80002d38:	cf9d                	beqz	a5,80002d76 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d3a:	00014997          	auipc	s3,0x14
    80002d3e:	ca698993          	addi	s3,s3,-858 # 800169e0 <tickslock>
    80002d42:	00006497          	auipc	s1,0x6
    80002d46:	bfe48493          	addi	s1,s1,-1026 # 80008940 <ticks>
    if(killed(myproc())){
    80002d4a:	fffff097          	auipc	ra,0xfffff
    80002d4e:	c72080e7          	jalr	-910(ra) # 800019bc <myproc>
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	636080e7          	jalr	1590(ra) # 80002388 <killed>
    80002d5a:	ed15                	bnez	a0,80002d96 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d5c:	85ce                	mv	a1,s3
    80002d5e:	8526                	mv	a0,s1
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	380080e7          	jalr	896(ra) # 800020e0 <sleep>
  while(ticks - ticks0 < n){
    80002d68:	409c                	lw	a5,0(s1)
    80002d6a:	412787bb          	subw	a5,a5,s2
    80002d6e:	fcc42703          	lw	a4,-52(s0)
    80002d72:	fce7ece3          	bltu	a5,a4,80002d4a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d76:	00014517          	auipc	a0,0x14
    80002d7a:	c6a50513          	addi	a0,a0,-918 # 800169e0 <tickslock>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	f1e080e7          	jalr	-226(ra) # 80000c9c <release>
  return 0;
    80002d86:	4501                	li	a0,0
}
    80002d88:	70e2                	ld	ra,56(sp)
    80002d8a:	7442                	ld	s0,48(sp)
    80002d8c:	74a2                	ld	s1,40(sp)
    80002d8e:	7902                	ld	s2,32(sp)
    80002d90:	69e2                	ld	s3,24(sp)
    80002d92:	6121                	addi	sp,sp,64
    80002d94:	8082                	ret
      release(&tickslock);
    80002d96:	00014517          	auipc	a0,0x14
    80002d9a:	c4a50513          	addi	a0,a0,-950 # 800169e0 <tickslock>
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	efe080e7          	jalr	-258(ra) # 80000c9c <release>
      return -1;
    80002da6:	557d                	li	a0,-1
    80002da8:	b7c5                	j	80002d88 <sys_sleep+0x88>

0000000080002daa <sys_kill>:

uint64
sys_kill(void)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002db2:	fec40593          	addi	a1,s0,-20
    80002db6:	4501                	li	a0,0
    80002db8:	00000097          	auipc	ra,0x0
    80002dbc:	d9a080e7          	jalr	-614(ra) # 80002b52 <argint>
  return kill(pid);
    80002dc0:	fec42503          	lw	a0,-20(s0)
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	526080e7          	jalr	1318(ra) # 800022ea <kill>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret

0000000080002dd4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dd4:	1101                	addi	sp,sp,-32
    80002dd6:	ec06                	sd	ra,24(sp)
    80002dd8:	e822                	sd	s0,16(sp)
    80002dda:	e426                	sd	s1,8(sp)
    80002ddc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dde:	00014517          	auipc	a0,0x14
    80002de2:	c0250513          	addi	a0,a0,-1022 # 800169e0 <tickslock>
    80002de6:	ffffe097          	auipc	ra,0xffffe
    80002dea:	dec080e7          	jalr	-532(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002dee:	00006497          	auipc	s1,0x6
    80002df2:	b524a483          	lw	s1,-1198(s1) # 80008940 <ticks>
  release(&tickslock);
    80002df6:	00014517          	auipc	a0,0x14
    80002dfa:	bea50513          	addi	a0,a0,-1046 # 800169e0 <tickslock>
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	e9e080e7          	jalr	-354(ra) # 80000c9c <release>
  return xticks;
}
    80002e06:	02049513          	slli	a0,s1,0x20
    80002e0a:	9101                	srli	a0,a0,0x20
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	64a2                	ld	s1,8(sp)
    80002e12:	6105                	addi	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_getmem>:

//Project 2 syscalls:
uint64
sys_getmem(void)
{
    80002e16:	1141                	addi	sp,sp,-16
    80002e18:	e406                	sd	ra,8(sp)
    80002e1a:	e022                	sd	s0,0(sp)
    80002e1c:	0800                	addi	s0,sp,16
   return myproc()->sz; // return the size of this process
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	b9e080e7          	jalr	-1122(ra) # 800019bc <myproc>
}
    80002e26:	6528                	ld	a0,72(a0)
    80002e28:	60a2                	ld	ra,8(sp)
    80002e2a:	6402                	ld	s0,0(sp)
    80002e2c:	0141                	addi	sp,sp,16
    80002e2e:	8082                	ret

0000000080002e30 <sys_getstate>:

uint64
sys_getstate(void)
{
    80002e30:	1141                	addi	sp,sp,-16
    80002e32:	e406                	sd	ra,8(sp)
    80002e34:	e022                	sd	s0,0(sp)
    80002e36:	0800                	addi	s0,sp,16
  return myproc()->state;
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	b84080e7          	jalr	-1148(ra) # 800019bc <myproc>
}
    80002e40:	01856503          	lwu	a0,24(a0)
    80002e44:	60a2                	ld	ra,8(sp)
    80002e46:	6402                	ld	s0,0(sp)
    80002e48:	0141                	addi	sp,sp,16
    80002e4a:	8082                	ret

0000000080002e4c <sys_getparentpid>:

uint64
sys_getparentpid(void)
{
    80002e4c:	1141                	addi	sp,sp,-16
    80002e4e:	e406                	sd	ra,8(sp)
    80002e50:	e022                	sd	s0,0(sp)
    80002e52:	0800                	addi	s0,sp,16
  return myproc()->parent->pid; // reutrn the parent's pid
    80002e54:	fffff097          	auipc	ra,0xfffff
    80002e58:	b68080e7          	jalr	-1176(ra) # 800019bc <myproc>
    80002e5c:	7d1c                	ld	a5,56(a0)
}
    80002e5e:	5b88                	lw	a0,48(a5)
    80002e60:	60a2                	ld	ra,8(sp)
    80002e62:	6402                	ld	s0,0(sp)
    80002e64:	0141                	addi	sp,sp,16
    80002e66:	8082                	ret

0000000080002e68 <sys_getkstack>:

uint64
sys_getkstack(void)
{
    80002e68:	1141                	addi	sp,sp,-16
    80002e6a:	e406                	sd	ra,8(sp)
    80002e6c:	e022                	sd	s0,0(sp)
    80002e6e:	0800                	addi	s0,sp,16
  return myproc()->kstack; // return 64bit address (Base) of kstack
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	b4c080e7          	jalr	-1204(ra) # 800019bc <myproc>
}
    80002e78:	6128                	ld	a0,64(a0)
    80002e7a:	60a2                	ld	ra,8(sp)
    80002e7c:	6402                	ld	s0,0(sp)
    80002e7e:	0141                	addi	sp,sp,16
    80002e80:	8082                	ret

0000000080002e82 <sys_getpri>:

uint64
sys_getpri(void)
{
    80002e82:	1141                	addi	sp,sp,-16
    80002e84:	e406                	sd	ra,8(sp)
    80002e86:	e022                	sd	s0,0(sp)
    80002e88:	0800                	addi	s0,sp,16
  return myproc()->prio;
    80002e8a:	fffff097          	auipc	ra,0xfffff
    80002e8e:	b32080e7          	jalr	-1230(ra) # 800019bc <myproc>
}
    80002e92:	5948                	lw	a0,52(a0)
    80002e94:	60a2                	ld	ra,8(sp)
    80002e96:	6402                	ld	s0,0(sp)
    80002e98:	0141                	addi	sp,sp,16
    80002e9a:	8082                	ret

0000000080002e9c <sys_setpri>:

uint64
sys_setpri(void)
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	1000                	addi	s0,sp,32
  int reqpri;
  argint(0, &reqpri); // get the requested priority
    80002ea4:	fec40593          	addi	a1,s0,-20
    80002ea8:	4501                	li	a0,0
    80002eaa:	00000097          	auipc	ra,0x0
    80002eae:	ca8080e7          	jalr	-856(ra) # 80002b52 <argint>
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002eb2:	fec42783          	lw	a5,-20(s0)
    80002eb6:	ff67869b          	addiw	a3,a5,-10
    80002eba:	4715                	li	a4,5
     acquire(&myproc()->lock);
     myproc()->prio = reqpri;
     release(&myproc()->lock);
     return 0;
  }
  return -1;
    80002ebc:	557d                	li	a0,-1
  if(reqpri <= PRI_MAX && reqpri >= PRI_MIN && reqpri != 0x0E){
    80002ebe:	00d76563          	bltu	a4,a3,80002ec8 <sys_setpri+0x2c>
    80002ec2:	4739                	li	a4,14
    80002ec4:	00e79663          	bne	a5,a4,80002ed0 <sys_setpri+0x34>
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	6105                	addi	sp,sp,32
    80002ece:	8082                	ret
     acquire(&myproc()->lock);
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	aec080e7          	jalr	-1300(ra) # 800019bc <myproc>
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	cfa080e7          	jalr	-774(ra) # 80000bd2 <acquire>
     myproc()->prio = reqpri;
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	adc080e7          	jalr	-1316(ra) # 800019bc <myproc>
    80002ee8:	fec42783          	lw	a5,-20(s0)
    80002eec:	d95c                	sw	a5,52(a0)
     release(&myproc()->lock);
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	ace080e7          	jalr	-1330(ra) # 800019bc <myproc>
    80002ef6:	ffffe097          	auipc	ra,0xffffe
    80002efa:	da6080e7          	jalr	-602(ra) # 80000c9c <release>
     return 0;
    80002efe:	4501                	li	a0,0
    80002f00:	b7e1                	j	80002ec8 <sys_setpri+0x2c>

0000000080002f02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	e84a                	sd	s2,16(sp)
    80002f0c:	e44e                	sd	s3,8(sp)
    80002f0e:	e052                	sd	s4,0(sp)
    80002f10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f12:	00005597          	auipc	a1,0x5
    80002f16:	63658593          	addi	a1,a1,1590 # 80008548 <syscalls+0xe0>
    80002f1a:	00014517          	auipc	a0,0x14
    80002f1e:	ade50513          	addi	a0,a0,-1314 # 800169f8 <bcache>
    80002f22:	ffffe097          	auipc	ra,0xffffe
    80002f26:	c20080e7          	jalr	-992(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f2a:	0001c797          	auipc	a5,0x1c
    80002f2e:	ace78793          	addi	a5,a5,-1330 # 8001e9f8 <bcache+0x8000>
    80002f32:	0001c717          	auipc	a4,0x1c
    80002f36:	d2e70713          	addi	a4,a4,-722 # 8001ec60 <bcache+0x8268>
    80002f3a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f3e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f42:	00014497          	auipc	s1,0x14
    80002f46:	ace48493          	addi	s1,s1,-1330 # 80016a10 <bcache+0x18>
    b->next = bcache.head.next;
    80002f4a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f4c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f4e:	00005a17          	auipc	s4,0x5
    80002f52:	602a0a13          	addi	s4,s4,1538 # 80008550 <syscalls+0xe8>
    b->next = bcache.head.next;
    80002f56:	2b893783          	ld	a5,696(s2)
    80002f5a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f5c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f60:	85d2                	mv	a1,s4
    80002f62:	01048513          	addi	a0,s1,16
    80002f66:	00001097          	auipc	ra,0x1
    80002f6a:	496080e7          	jalr	1174(ra) # 800043fc <initsleeplock>
    bcache.head.next->prev = b;
    80002f6e:	2b893783          	ld	a5,696(s2)
    80002f72:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f74:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f78:	45848493          	addi	s1,s1,1112
    80002f7c:	fd349de3          	bne	s1,s3,80002f56 <binit+0x54>
  }
}
    80002f80:	70a2                	ld	ra,40(sp)
    80002f82:	7402                	ld	s0,32(sp)
    80002f84:	64e2                	ld	s1,24(sp)
    80002f86:	6942                	ld	s2,16(sp)
    80002f88:	69a2                	ld	s3,8(sp)
    80002f8a:	6a02                	ld	s4,0(sp)
    80002f8c:	6145                	addi	sp,sp,48
    80002f8e:	8082                	ret

0000000080002f90 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	e84a                	sd	s2,16(sp)
    80002f9a:	e44e                	sd	s3,8(sp)
    80002f9c:	1800                	addi	s0,sp,48
    80002f9e:	892a                	mv	s2,a0
    80002fa0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fa2:	00014517          	auipc	a0,0x14
    80002fa6:	a5650513          	addi	a0,a0,-1450 # 800169f8 <bcache>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	c28080e7          	jalr	-984(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fb2:	0001c497          	auipc	s1,0x1c
    80002fb6:	cfe4b483          	ld	s1,-770(s1) # 8001ecb0 <bcache+0x82b8>
    80002fba:	0001c797          	auipc	a5,0x1c
    80002fbe:	ca678793          	addi	a5,a5,-858 # 8001ec60 <bcache+0x8268>
    80002fc2:	02f48f63          	beq	s1,a5,80003000 <bread+0x70>
    80002fc6:	873e                	mv	a4,a5
    80002fc8:	a021                	j	80002fd0 <bread+0x40>
    80002fca:	68a4                	ld	s1,80(s1)
    80002fcc:	02e48a63          	beq	s1,a4,80003000 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fd0:	449c                	lw	a5,8(s1)
    80002fd2:	ff279ce3          	bne	a5,s2,80002fca <bread+0x3a>
    80002fd6:	44dc                	lw	a5,12(s1)
    80002fd8:	ff3799e3          	bne	a5,s3,80002fca <bread+0x3a>
      b->refcnt++;
    80002fdc:	40bc                	lw	a5,64(s1)
    80002fde:	2785                	addiw	a5,a5,1
    80002fe0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fe2:	00014517          	auipc	a0,0x14
    80002fe6:	a1650513          	addi	a0,a0,-1514 # 800169f8 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	cb2080e7          	jalr	-846(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80002ff2:	01048513          	addi	a0,s1,16
    80002ff6:	00001097          	auipc	ra,0x1
    80002ffa:	440080e7          	jalr	1088(ra) # 80004436 <acquiresleep>
      return b;
    80002ffe:	a8b9                	j	8000305c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003000:	0001c497          	auipc	s1,0x1c
    80003004:	ca84b483          	ld	s1,-856(s1) # 8001eca8 <bcache+0x82b0>
    80003008:	0001c797          	auipc	a5,0x1c
    8000300c:	c5878793          	addi	a5,a5,-936 # 8001ec60 <bcache+0x8268>
    80003010:	00f48863          	beq	s1,a5,80003020 <bread+0x90>
    80003014:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003016:	40bc                	lw	a5,64(s1)
    80003018:	cf81                	beqz	a5,80003030 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000301a:	64a4                	ld	s1,72(s1)
    8000301c:	fee49de3          	bne	s1,a4,80003016 <bread+0x86>
  panic("bget: no buffers");
    80003020:	00005517          	auipc	a0,0x5
    80003024:	53850513          	addi	a0,a0,1336 # 80008558 <syscalls+0xf0>
    80003028:	ffffd097          	auipc	ra,0xffffd
    8000302c:	514080e7          	jalr	1300(ra) # 8000053c <panic>
      b->dev = dev;
    80003030:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003034:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003038:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000303c:	4785                	li	a5,1
    8000303e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003040:	00014517          	auipc	a0,0x14
    80003044:	9b850513          	addi	a0,a0,-1608 # 800169f8 <bcache>
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	c54080e7          	jalr	-940(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80003050:	01048513          	addi	a0,s1,16
    80003054:	00001097          	auipc	ra,0x1
    80003058:	3e2080e7          	jalr	994(ra) # 80004436 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000305c:	409c                	lw	a5,0(s1)
    8000305e:	cb89                	beqz	a5,80003070 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003060:	8526                	mv	a0,s1
    80003062:	70a2                	ld	ra,40(sp)
    80003064:	7402                	ld	s0,32(sp)
    80003066:	64e2                	ld	s1,24(sp)
    80003068:	6942                	ld	s2,16(sp)
    8000306a:	69a2                	ld	s3,8(sp)
    8000306c:	6145                	addi	sp,sp,48
    8000306e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003070:	4581                	li	a1,0
    80003072:	8526                	mv	a0,s1
    80003074:	00003097          	auipc	ra,0x3
    80003078:	f7e080e7          	jalr	-130(ra) # 80005ff2 <virtio_disk_rw>
    b->valid = 1;
    8000307c:	4785                	li	a5,1
    8000307e:	c09c                	sw	a5,0(s1)
  return b;
    80003080:	b7c5                	j	80003060 <bread+0xd0>

0000000080003082 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003082:	1101                	addi	sp,sp,-32
    80003084:	ec06                	sd	ra,24(sp)
    80003086:	e822                	sd	s0,16(sp)
    80003088:	e426                	sd	s1,8(sp)
    8000308a:	1000                	addi	s0,sp,32
    8000308c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000308e:	0541                	addi	a0,a0,16
    80003090:	00001097          	auipc	ra,0x1
    80003094:	440080e7          	jalr	1088(ra) # 800044d0 <holdingsleep>
    80003098:	cd01                	beqz	a0,800030b0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000309a:	4585                	li	a1,1
    8000309c:	8526                	mv	a0,s1
    8000309e:	00003097          	auipc	ra,0x3
    800030a2:	f54080e7          	jalr	-172(ra) # 80005ff2 <virtio_disk_rw>
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret
    panic("bwrite");
    800030b0:	00005517          	auipc	a0,0x5
    800030b4:	4c050513          	addi	a0,a0,1216 # 80008570 <syscalls+0x108>
    800030b8:	ffffd097          	auipc	ra,0xffffd
    800030bc:	484080e7          	jalr	1156(ra) # 8000053c <panic>

00000000800030c0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030c0:	1101                	addi	sp,sp,-32
    800030c2:	ec06                	sd	ra,24(sp)
    800030c4:	e822                	sd	s0,16(sp)
    800030c6:	e426                	sd	s1,8(sp)
    800030c8:	e04a                	sd	s2,0(sp)
    800030ca:	1000                	addi	s0,sp,32
    800030cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ce:	01050913          	addi	s2,a0,16
    800030d2:	854a                	mv	a0,s2
    800030d4:	00001097          	auipc	ra,0x1
    800030d8:	3fc080e7          	jalr	1020(ra) # 800044d0 <holdingsleep>
    800030dc:	c925                	beqz	a0,8000314c <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030de:	854a                	mv	a0,s2
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	3ac080e7          	jalr	940(ra) # 8000448c <releasesleep>

  acquire(&bcache.lock);
    800030e8:	00014517          	auipc	a0,0x14
    800030ec:	91050513          	addi	a0,a0,-1776 # 800169f8 <bcache>
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	ae2080e7          	jalr	-1310(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030f8:	40bc                	lw	a5,64(s1)
    800030fa:	37fd                	addiw	a5,a5,-1
    800030fc:	0007871b          	sext.w	a4,a5
    80003100:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003102:	e71d                	bnez	a4,80003130 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003104:	68b8                	ld	a4,80(s1)
    80003106:	64bc                	ld	a5,72(s1)
    80003108:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000310a:	68b8                	ld	a4,80(s1)
    8000310c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000310e:	0001c797          	auipc	a5,0x1c
    80003112:	8ea78793          	addi	a5,a5,-1814 # 8001e9f8 <bcache+0x8000>
    80003116:	2b87b703          	ld	a4,696(a5)
    8000311a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000311c:	0001c717          	auipc	a4,0x1c
    80003120:	b4470713          	addi	a4,a4,-1212 # 8001ec60 <bcache+0x8268>
    80003124:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003126:	2b87b703          	ld	a4,696(a5)
    8000312a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000312c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003130:	00014517          	auipc	a0,0x14
    80003134:	8c850513          	addi	a0,a0,-1848 # 800169f8 <bcache>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	b64080e7          	jalr	-1180(ra) # 80000c9c <release>
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	64a2                	ld	s1,8(sp)
    80003146:	6902                	ld	s2,0(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret
    panic("brelse");
    8000314c:	00005517          	auipc	a0,0x5
    80003150:	42c50513          	addi	a0,a0,1068 # 80008578 <syscalls+0x110>
    80003154:	ffffd097          	auipc	ra,0xffffd
    80003158:	3e8080e7          	jalr	1000(ra) # 8000053c <panic>

000000008000315c <bpin>:

void
bpin(struct buf *b) {
    8000315c:	1101                	addi	sp,sp,-32
    8000315e:	ec06                	sd	ra,24(sp)
    80003160:	e822                	sd	s0,16(sp)
    80003162:	e426                	sd	s1,8(sp)
    80003164:	1000                	addi	s0,sp,32
    80003166:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003168:	00014517          	auipc	a0,0x14
    8000316c:	89050513          	addi	a0,a0,-1904 # 800169f8 <bcache>
    80003170:	ffffe097          	auipc	ra,0xffffe
    80003174:	a62080e7          	jalr	-1438(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003178:	40bc                	lw	a5,64(s1)
    8000317a:	2785                	addiw	a5,a5,1
    8000317c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000317e:	00014517          	auipc	a0,0x14
    80003182:	87a50513          	addi	a0,a0,-1926 # 800169f8 <bcache>
    80003186:	ffffe097          	auipc	ra,0xffffe
    8000318a:	b16080e7          	jalr	-1258(ra) # 80000c9c <release>
}
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	64a2                	ld	s1,8(sp)
    80003194:	6105                	addi	sp,sp,32
    80003196:	8082                	ret

0000000080003198 <bunpin>:

void
bunpin(struct buf *b) {
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	e426                	sd	s1,8(sp)
    800031a0:	1000                	addi	s0,sp,32
    800031a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031a4:	00014517          	auipc	a0,0x14
    800031a8:	85450513          	addi	a0,a0,-1964 # 800169f8 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	a26080e7          	jalr	-1498(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	37fd                	addiw	a5,a5,-1
    800031b8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031ba:	00014517          	auipc	a0,0x14
    800031be:	83e50513          	addi	a0,a0,-1986 # 800169f8 <bcache>
    800031c2:	ffffe097          	auipc	ra,0xffffe
    800031c6:	ada080e7          	jalr	-1318(ra) # 80000c9c <release>
}
    800031ca:	60e2                	ld	ra,24(sp)
    800031cc:	6442                	ld	s0,16(sp)
    800031ce:	64a2                	ld	s1,8(sp)
    800031d0:	6105                	addi	sp,sp,32
    800031d2:	8082                	ret

00000000800031d4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031d4:	1101                	addi	sp,sp,-32
    800031d6:	ec06                	sd	ra,24(sp)
    800031d8:	e822                	sd	s0,16(sp)
    800031da:	e426                	sd	s1,8(sp)
    800031dc:	e04a                	sd	s2,0(sp)
    800031de:	1000                	addi	s0,sp,32
    800031e0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031e2:	00d5d59b          	srliw	a1,a1,0xd
    800031e6:	0001c797          	auipc	a5,0x1c
    800031ea:	eee7a783          	lw	a5,-274(a5) # 8001f0d4 <sb+0x1c>
    800031ee:	9dbd                	addw	a1,a1,a5
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	da0080e7          	jalr	-608(ra) # 80002f90 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031f8:	0074f713          	andi	a4,s1,7
    800031fc:	4785                	li	a5,1
    800031fe:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003202:	14ce                	slli	s1,s1,0x33
    80003204:	90d9                	srli	s1,s1,0x36
    80003206:	00950733          	add	a4,a0,s1
    8000320a:	05874703          	lbu	a4,88(a4)
    8000320e:	00e7f6b3          	and	a3,a5,a4
    80003212:	c69d                	beqz	a3,80003240 <bfree+0x6c>
    80003214:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003216:	94aa                	add	s1,s1,a0
    80003218:	fff7c793          	not	a5,a5
    8000321c:	8f7d                	and	a4,a4,a5
    8000321e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003222:	00001097          	auipc	ra,0x1
    80003226:	0f6080e7          	jalr	246(ra) # 80004318 <log_write>
  brelse(bp);
    8000322a:	854a                	mv	a0,s2
    8000322c:	00000097          	auipc	ra,0x0
    80003230:	e94080e7          	jalr	-364(ra) # 800030c0 <brelse>
}
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6902                	ld	s2,0(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret
    panic("freeing free block");
    80003240:	00005517          	auipc	a0,0x5
    80003244:	34050513          	addi	a0,a0,832 # 80008580 <syscalls+0x118>
    80003248:	ffffd097          	auipc	ra,0xffffd
    8000324c:	2f4080e7          	jalr	756(ra) # 8000053c <panic>

0000000080003250 <balloc>:
{
    80003250:	711d                	addi	sp,sp,-96
    80003252:	ec86                	sd	ra,88(sp)
    80003254:	e8a2                	sd	s0,80(sp)
    80003256:	e4a6                	sd	s1,72(sp)
    80003258:	e0ca                	sd	s2,64(sp)
    8000325a:	fc4e                	sd	s3,56(sp)
    8000325c:	f852                	sd	s4,48(sp)
    8000325e:	f456                	sd	s5,40(sp)
    80003260:	f05a                	sd	s6,32(sp)
    80003262:	ec5e                	sd	s7,24(sp)
    80003264:	e862                	sd	s8,16(sp)
    80003266:	e466                	sd	s9,8(sp)
    80003268:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000326a:	0001c797          	auipc	a5,0x1c
    8000326e:	e527a783          	lw	a5,-430(a5) # 8001f0bc <sb+0x4>
    80003272:	cff5                	beqz	a5,8000336e <balloc+0x11e>
    80003274:	8baa                	mv	s7,a0
    80003276:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003278:	0001cb17          	auipc	s6,0x1c
    8000327c:	e40b0b13          	addi	s6,s6,-448 # 8001f0b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003280:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003282:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003284:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003286:	6c89                	lui	s9,0x2
    80003288:	a061                	j	80003310 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000328a:	97ca                	add	a5,a5,s2
    8000328c:	8e55                	or	a2,a2,a3
    8000328e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003292:	854a                	mv	a0,s2
    80003294:	00001097          	auipc	ra,0x1
    80003298:	084080e7          	jalr	132(ra) # 80004318 <log_write>
        brelse(bp);
    8000329c:	854a                	mv	a0,s2
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	e22080e7          	jalr	-478(ra) # 800030c0 <brelse>
  bp = bread(dev, bno);
    800032a6:	85a6                	mv	a1,s1
    800032a8:	855e                	mv	a0,s7
    800032aa:	00000097          	auipc	ra,0x0
    800032ae:	ce6080e7          	jalr	-794(ra) # 80002f90 <bread>
    800032b2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032b4:	40000613          	li	a2,1024
    800032b8:	4581                	li	a1,0
    800032ba:	05850513          	addi	a0,a0,88
    800032be:	ffffe097          	auipc	ra,0xffffe
    800032c2:	a26080e7          	jalr	-1498(ra) # 80000ce4 <memset>
  log_write(bp);
    800032c6:	854a                	mv	a0,s2
    800032c8:	00001097          	auipc	ra,0x1
    800032cc:	050080e7          	jalr	80(ra) # 80004318 <log_write>
  brelse(bp);
    800032d0:	854a                	mv	a0,s2
    800032d2:	00000097          	auipc	ra,0x0
    800032d6:	dee080e7          	jalr	-530(ra) # 800030c0 <brelse>
}
    800032da:	8526                	mv	a0,s1
    800032dc:	60e6                	ld	ra,88(sp)
    800032de:	6446                	ld	s0,80(sp)
    800032e0:	64a6                	ld	s1,72(sp)
    800032e2:	6906                	ld	s2,64(sp)
    800032e4:	79e2                	ld	s3,56(sp)
    800032e6:	7a42                	ld	s4,48(sp)
    800032e8:	7aa2                	ld	s5,40(sp)
    800032ea:	7b02                	ld	s6,32(sp)
    800032ec:	6be2                	ld	s7,24(sp)
    800032ee:	6c42                	ld	s8,16(sp)
    800032f0:	6ca2                	ld	s9,8(sp)
    800032f2:	6125                	addi	sp,sp,96
    800032f4:	8082                	ret
    brelse(bp);
    800032f6:	854a                	mv	a0,s2
    800032f8:	00000097          	auipc	ra,0x0
    800032fc:	dc8080e7          	jalr	-568(ra) # 800030c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003300:	015c87bb          	addw	a5,s9,s5
    80003304:	00078a9b          	sext.w	s5,a5
    80003308:	004b2703          	lw	a4,4(s6)
    8000330c:	06eaf163          	bgeu	s5,a4,8000336e <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003310:	41fad79b          	sraiw	a5,s5,0x1f
    80003314:	0137d79b          	srliw	a5,a5,0x13
    80003318:	015787bb          	addw	a5,a5,s5
    8000331c:	40d7d79b          	sraiw	a5,a5,0xd
    80003320:	01cb2583          	lw	a1,28(s6)
    80003324:	9dbd                	addw	a1,a1,a5
    80003326:	855e                	mv	a0,s7
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	c68080e7          	jalr	-920(ra) # 80002f90 <bread>
    80003330:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003332:	004b2503          	lw	a0,4(s6)
    80003336:	000a849b          	sext.w	s1,s5
    8000333a:	8762                	mv	a4,s8
    8000333c:	faa4fde3          	bgeu	s1,a0,800032f6 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003340:	00777693          	andi	a3,a4,7
    80003344:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003348:	41f7579b          	sraiw	a5,a4,0x1f
    8000334c:	01d7d79b          	srliw	a5,a5,0x1d
    80003350:	9fb9                	addw	a5,a5,a4
    80003352:	4037d79b          	sraiw	a5,a5,0x3
    80003356:	00f90633          	add	a2,s2,a5
    8000335a:	05864603          	lbu	a2,88(a2)
    8000335e:	00c6f5b3          	and	a1,a3,a2
    80003362:	d585                	beqz	a1,8000328a <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003364:	2705                	addiw	a4,a4,1
    80003366:	2485                	addiw	s1,s1,1
    80003368:	fd471ae3          	bne	a4,s4,8000333c <balloc+0xec>
    8000336c:	b769                	j	800032f6 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000336e:	00005517          	auipc	a0,0x5
    80003372:	22a50513          	addi	a0,a0,554 # 80008598 <syscalls+0x130>
    80003376:	ffffd097          	auipc	ra,0xffffd
    8000337a:	210080e7          	jalr	528(ra) # 80000586 <printf>
  return 0;
    8000337e:	4481                	li	s1,0
    80003380:	bfa9                	j	800032da <balloc+0x8a>

0000000080003382 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003382:	7179                	addi	sp,sp,-48
    80003384:	f406                	sd	ra,40(sp)
    80003386:	f022                	sd	s0,32(sp)
    80003388:	ec26                	sd	s1,24(sp)
    8000338a:	e84a                	sd	s2,16(sp)
    8000338c:	e44e                	sd	s3,8(sp)
    8000338e:	e052                	sd	s4,0(sp)
    80003390:	1800                	addi	s0,sp,48
    80003392:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003394:	47ad                	li	a5,11
    80003396:	02b7e863          	bltu	a5,a1,800033c6 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000339a:	02059793          	slli	a5,a1,0x20
    8000339e:	01e7d593          	srli	a1,a5,0x1e
    800033a2:	00b504b3          	add	s1,a0,a1
    800033a6:	0504a903          	lw	s2,80(s1)
    800033aa:	06091e63          	bnez	s2,80003426 <bmap+0xa4>
      addr = balloc(ip->dev);
    800033ae:	4108                	lw	a0,0(a0)
    800033b0:	00000097          	auipc	ra,0x0
    800033b4:	ea0080e7          	jalr	-352(ra) # 80003250 <balloc>
    800033b8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033bc:	06090563          	beqz	s2,80003426 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800033c0:	0524a823          	sw	s2,80(s1)
    800033c4:	a08d                	j	80003426 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033c6:	ff45849b          	addiw	s1,a1,-12
    800033ca:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033ce:	0ff00793          	li	a5,255
    800033d2:	08e7e563          	bltu	a5,a4,8000345c <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033d6:	08052903          	lw	s2,128(a0)
    800033da:	00091d63          	bnez	s2,800033f4 <bmap+0x72>
      addr = balloc(ip->dev);
    800033de:	4108                	lw	a0,0(a0)
    800033e0:	00000097          	auipc	ra,0x0
    800033e4:	e70080e7          	jalr	-400(ra) # 80003250 <balloc>
    800033e8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ec:	02090d63          	beqz	s2,80003426 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033f0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033f4:	85ca                	mv	a1,s2
    800033f6:	0009a503          	lw	a0,0(s3)
    800033fa:	00000097          	auipc	ra,0x0
    800033fe:	b96080e7          	jalr	-1130(ra) # 80002f90 <bread>
    80003402:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003404:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003408:	02049713          	slli	a4,s1,0x20
    8000340c:	01e75593          	srli	a1,a4,0x1e
    80003410:	00b784b3          	add	s1,a5,a1
    80003414:	0004a903          	lw	s2,0(s1)
    80003418:	02090063          	beqz	s2,80003438 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000341c:	8552                	mv	a0,s4
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	ca2080e7          	jalr	-862(ra) # 800030c0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003426:	854a                	mv	a0,s2
    80003428:	70a2                	ld	ra,40(sp)
    8000342a:	7402                	ld	s0,32(sp)
    8000342c:	64e2                	ld	s1,24(sp)
    8000342e:	6942                	ld	s2,16(sp)
    80003430:	69a2                	ld	s3,8(sp)
    80003432:	6a02                	ld	s4,0(sp)
    80003434:	6145                	addi	sp,sp,48
    80003436:	8082                	ret
      addr = balloc(ip->dev);
    80003438:	0009a503          	lw	a0,0(s3)
    8000343c:	00000097          	auipc	ra,0x0
    80003440:	e14080e7          	jalr	-492(ra) # 80003250 <balloc>
    80003444:	0005091b          	sext.w	s2,a0
      if(addr){
    80003448:	fc090ae3          	beqz	s2,8000341c <bmap+0x9a>
        a[bn] = addr;
    8000344c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003450:	8552                	mv	a0,s4
    80003452:	00001097          	auipc	ra,0x1
    80003456:	ec6080e7          	jalr	-314(ra) # 80004318 <log_write>
    8000345a:	b7c9                	j	8000341c <bmap+0x9a>
  panic("bmap: out of range");
    8000345c:	00005517          	auipc	a0,0x5
    80003460:	15450513          	addi	a0,a0,340 # 800085b0 <syscalls+0x148>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	0d8080e7          	jalr	216(ra) # 8000053c <panic>

000000008000346c <iget>:
{
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	e052                	sd	s4,0(sp)
    8000347a:	1800                	addi	s0,sp,48
    8000347c:	89aa                	mv	s3,a0
    8000347e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003480:	0001c517          	auipc	a0,0x1c
    80003484:	c5850513          	addi	a0,a0,-936 # 8001f0d8 <itable>
    80003488:	ffffd097          	auipc	ra,0xffffd
    8000348c:	74a080e7          	jalr	1866(ra) # 80000bd2 <acquire>
  empty = 0;
    80003490:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003492:	0001c497          	auipc	s1,0x1c
    80003496:	c5e48493          	addi	s1,s1,-930 # 8001f0f0 <itable+0x18>
    8000349a:	0001d697          	auipc	a3,0x1d
    8000349e:	6e668693          	addi	a3,a3,1766 # 80020b80 <log>
    800034a2:	a039                	j	800034b0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a4:	02090b63          	beqz	s2,800034da <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034a8:	08848493          	addi	s1,s1,136
    800034ac:	02d48a63          	beq	s1,a3,800034e0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034b0:	449c                	lw	a5,8(s1)
    800034b2:	fef059e3          	blez	a5,800034a4 <iget+0x38>
    800034b6:	4098                	lw	a4,0(s1)
    800034b8:	ff3716e3          	bne	a4,s3,800034a4 <iget+0x38>
    800034bc:	40d8                	lw	a4,4(s1)
    800034be:	ff4713e3          	bne	a4,s4,800034a4 <iget+0x38>
      ip->ref++;
    800034c2:	2785                	addiw	a5,a5,1
    800034c4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034c6:	0001c517          	auipc	a0,0x1c
    800034ca:	c1250513          	addi	a0,a0,-1006 # 8001f0d8 <itable>
    800034ce:	ffffd097          	auipc	ra,0xffffd
    800034d2:	7ce080e7          	jalr	1998(ra) # 80000c9c <release>
      return ip;
    800034d6:	8926                	mv	s2,s1
    800034d8:	a03d                	j	80003506 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034da:	f7f9                	bnez	a5,800034a8 <iget+0x3c>
    800034dc:	8926                	mv	s2,s1
    800034de:	b7e9                	j	800034a8 <iget+0x3c>
  if(empty == 0)
    800034e0:	02090c63          	beqz	s2,80003518 <iget+0xac>
  ip->dev = dev;
    800034e4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034e8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034ec:	4785                	li	a5,1
    800034ee:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034f2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034f6:	0001c517          	auipc	a0,0x1c
    800034fa:	be250513          	addi	a0,a0,-1054 # 8001f0d8 <itable>
    800034fe:	ffffd097          	auipc	ra,0xffffd
    80003502:	79e080e7          	jalr	1950(ra) # 80000c9c <release>
}
    80003506:	854a                	mv	a0,s2
    80003508:	70a2                	ld	ra,40(sp)
    8000350a:	7402                	ld	s0,32(sp)
    8000350c:	64e2                	ld	s1,24(sp)
    8000350e:	6942                	ld	s2,16(sp)
    80003510:	69a2                	ld	s3,8(sp)
    80003512:	6a02                	ld	s4,0(sp)
    80003514:	6145                	addi	sp,sp,48
    80003516:	8082                	ret
    panic("iget: no inodes");
    80003518:	00005517          	auipc	a0,0x5
    8000351c:	0b050513          	addi	a0,a0,176 # 800085c8 <syscalls+0x160>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	01c080e7          	jalr	28(ra) # 8000053c <panic>

0000000080003528 <fsinit>:
fsinit(int dev) {
    80003528:	7179                	addi	sp,sp,-48
    8000352a:	f406                	sd	ra,40(sp)
    8000352c:	f022                	sd	s0,32(sp)
    8000352e:	ec26                	sd	s1,24(sp)
    80003530:	e84a                	sd	s2,16(sp)
    80003532:	e44e                	sd	s3,8(sp)
    80003534:	1800                	addi	s0,sp,48
    80003536:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003538:	4585                	li	a1,1
    8000353a:	00000097          	auipc	ra,0x0
    8000353e:	a56080e7          	jalr	-1450(ra) # 80002f90 <bread>
    80003542:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003544:	0001c997          	auipc	s3,0x1c
    80003548:	b7498993          	addi	s3,s3,-1164 # 8001f0b8 <sb>
    8000354c:	02000613          	li	a2,32
    80003550:	05850593          	addi	a1,a0,88
    80003554:	854e                	mv	a0,s3
    80003556:	ffffd097          	auipc	ra,0xffffd
    8000355a:	7ea080e7          	jalr	2026(ra) # 80000d40 <memmove>
  brelse(bp);
    8000355e:	8526                	mv	a0,s1
    80003560:	00000097          	auipc	ra,0x0
    80003564:	b60080e7          	jalr	-1184(ra) # 800030c0 <brelse>
  if(sb.magic != FSMAGIC)
    80003568:	0009a703          	lw	a4,0(s3)
    8000356c:	102037b7          	lui	a5,0x10203
    80003570:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003574:	02f71263          	bne	a4,a5,80003598 <fsinit+0x70>
  initlog(dev, &sb);
    80003578:	0001c597          	auipc	a1,0x1c
    8000357c:	b4058593          	addi	a1,a1,-1216 # 8001f0b8 <sb>
    80003580:	854a                	mv	a0,s2
    80003582:	00001097          	auipc	ra,0x1
    80003586:	b2c080e7          	jalr	-1236(ra) # 800040ae <initlog>
}
    8000358a:	70a2                	ld	ra,40(sp)
    8000358c:	7402                	ld	s0,32(sp)
    8000358e:	64e2                	ld	s1,24(sp)
    80003590:	6942                	ld	s2,16(sp)
    80003592:	69a2                	ld	s3,8(sp)
    80003594:	6145                	addi	sp,sp,48
    80003596:	8082                	ret
    panic("invalid file system");
    80003598:	00005517          	auipc	a0,0x5
    8000359c:	04050513          	addi	a0,a0,64 # 800085d8 <syscalls+0x170>
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	f9c080e7          	jalr	-100(ra) # 8000053c <panic>

00000000800035a8 <iinit>:
{
    800035a8:	7179                	addi	sp,sp,-48
    800035aa:	f406                	sd	ra,40(sp)
    800035ac:	f022                	sd	s0,32(sp)
    800035ae:	ec26                	sd	s1,24(sp)
    800035b0:	e84a                	sd	s2,16(sp)
    800035b2:	e44e                	sd	s3,8(sp)
    800035b4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035b6:	00005597          	auipc	a1,0x5
    800035ba:	03a58593          	addi	a1,a1,58 # 800085f0 <syscalls+0x188>
    800035be:	0001c517          	auipc	a0,0x1c
    800035c2:	b1a50513          	addi	a0,a0,-1254 # 8001f0d8 <itable>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	57c080e7          	jalr	1404(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035ce:	0001c497          	auipc	s1,0x1c
    800035d2:	b3248493          	addi	s1,s1,-1230 # 8001f100 <itable+0x28>
    800035d6:	0001d997          	auipc	s3,0x1d
    800035da:	5ba98993          	addi	s3,s3,1466 # 80020b90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035de:	00005917          	auipc	s2,0x5
    800035e2:	01a90913          	addi	s2,s2,26 # 800085f8 <syscalls+0x190>
    800035e6:	85ca                	mv	a1,s2
    800035e8:	8526                	mv	a0,s1
    800035ea:	00001097          	auipc	ra,0x1
    800035ee:	e12080e7          	jalr	-494(ra) # 800043fc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035f2:	08848493          	addi	s1,s1,136
    800035f6:	ff3498e3          	bne	s1,s3,800035e6 <iinit+0x3e>
}
    800035fa:	70a2                	ld	ra,40(sp)
    800035fc:	7402                	ld	s0,32(sp)
    800035fe:	64e2                	ld	s1,24(sp)
    80003600:	6942                	ld	s2,16(sp)
    80003602:	69a2                	ld	s3,8(sp)
    80003604:	6145                	addi	sp,sp,48
    80003606:	8082                	ret

0000000080003608 <ialloc>:
{
    80003608:	7139                	addi	sp,sp,-64
    8000360a:	fc06                	sd	ra,56(sp)
    8000360c:	f822                	sd	s0,48(sp)
    8000360e:	f426                	sd	s1,40(sp)
    80003610:	f04a                	sd	s2,32(sp)
    80003612:	ec4e                	sd	s3,24(sp)
    80003614:	e852                	sd	s4,16(sp)
    80003616:	e456                	sd	s5,8(sp)
    80003618:	e05a                	sd	s6,0(sp)
    8000361a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000361c:	0001c717          	auipc	a4,0x1c
    80003620:	aa872703          	lw	a4,-1368(a4) # 8001f0c4 <sb+0xc>
    80003624:	4785                	li	a5,1
    80003626:	04e7f863          	bgeu	a5,a4,80003676 <ialloc+0x6e>
    8000362a:	8aaa                	mv	s5,a0
    8000362c:	8b2e                	mv	s6,a1
    8000362e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003630:	0001ca17          	auipc	s4,0x1c
    80003634:	a88a0a13          	addi	s4,s4,-1400 # 8001f0b8 <sb>
    80003638:	00495593          	srli	a1,s2,0x4
    8000363c:	018a2783          	lw	a5,24(s4)
    80003640:	9dbd                	addw	a1,a1,a5
    80003642:	8556                	mv	a0,s5
    80003644:	00000097          	auipc	ra,0x0
    80003648:	94c080e7          	jalr	-1716(ra) # 80002f90 <bread>
    8000364c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000364e:	05850993          	addi	s3,a0,88
    80003652:	00f97793          	andi	a5,s2,15
    80003656:	079a                	slli	a5,a5,0x6
    80003658:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000365a:	00099783          	lh	a5,0(s3)
    8000365e:	cf9d                	beqz	a5,8000369c <ialloc+0x94>
    brelse(bp);
    80003660:	00000097          	auipc	ra,0x0
    80003664:	a60080e7          	jalr	-1440(ra) # 800030c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003668:	0905                	addi	s2,s2,1
    8000366a:	00ca2703          	lw	a4,12(s4)
    8000366e:	0009079b          	sext.w	a5,s2
    80003672:	fce7e3e3          	bltu	a5,a4,80003638 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	f8a50513          	addi	a0,a0,-118 # 80008600 <syscalls+0x198>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	f08080e7          	jalr	-248(ra) # 80000586 <printf>
  return 0;
    80003686:	4501                	li	a0,0
}
    80003688:	70e2                	ld	ra,56(sp)
    8000368a:	7442                	ld	s0,48(sp)
    8000368c:	74a2                	ld	s1,40(sp)
    8000368e:	7902                	ld	s2,32(sp)
    80003690:	69e2                	ld	s3,24(sp)
    80003692:	6a42                	ld	s4,16(sp)
    80003694:	6aa2                	ld	s5,8(sp)
    80003696:	6b02                	ld	s6,0(sp)
    80003698:	6121                	addi	sp,sp,64
    8000369a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000369c:	04000613          	li	a2,64
    800036a0:	4581                	li	a1,0
    800036a2:	854e                	mv	a0,s3
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	640080e7          	jalr	1600(ra) # 80000ce4 <memset>
      dip->type = type;
    800036ac:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036b0:	8526                	mv	a0,s1
    800036b2:	00001097          	auipc	ra,0x1
    800036b6:	c66080e7          	jalr	-922(ra) # 80004318 <log_write>
      brelse(bp);
    800036ba:	8526                	mv	a0,s1
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	a04080e7          	jalr	-1532(ra) # 800030c0 <brelse>
      return iget(dev, inum);
    800036c4:	0009059b          	sext.w	a1,s2
    800036c8:	8556                	mv	a0,s5
    800036ca:	00000097          	auipc	ra,0x0
    800036ce:	da2080e7          	jalr	-606(ra) # 8000346c <iget>
    800036d2:	bf5d                	j	80003688 <ialloc+0x80>

00000000800036d4 <iupdate>:
{
    800036d4:	1101                	addi	sp,sp,-32
    800036d6:	ec06                	sd	ra,24(sp)
    800036d8:	e822                	sd	s0,16(sp)
    800036da:	e426                	sd	s1,8(sp)
    800036dc:	e04a                	sd	s2,0(sp)
    800036de:	1000                	addi	s0,sp,32
    800036e0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036e2:	415c                	lw	a5,4(a0)
    800036e4:	0047d79b          	srliw	a5,a5,0x4
    800036e8:	0001c597          	auipc	a1,0x1c
    800036ec:	9e85a583          	lw	a1,-1560(a1) # 8001f0d0 <sb+0x18>
    800036f0:	9dbd                	addw	a1,a1,a5
    800036f2:	4108                	lw	a0,0(a0)
    800036f4:	00000097          	auipc	ra,0x0
    800036f8:	89c080e7          	jalr	-1892(ra) # 80002f90 <bread>
    800036fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036fe:	05850793          	addi	a5,a0,88
    80003702:	40d8                	lw	a4,4(s1)
    80003704:	8b3d                	andi	a4,a4,15
    80003706:	071a                	slli	a4,a4,0x6
    80003708:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000370a:	04449703          	lh	a4,68(s1)
    8000370e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003712:	04649703          	lh	a4,70(s1)
    80003716:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000371a:	04849703          	lh	a4,72(s1)
    8000371e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003722:	04a49703          	lh	a4,74(s1)
    80003726:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000372a:	44f8                	lw	a4,76(s1)
    8000372c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000372e:	03400613          	li	a2,52
    80003732:	05048593          	addi	a1,s1,80
    80003736:	00c78513          	addi	a0,a5,12
    8000373a:	ffffd097          	auipc	ra,0xffffd
    8000373e:	606080e7          	jalr	1542(ra) # 80000d40 <memmove>
  log_write(bp);
    80003742:	854a                	mv	a0,s2
    80003744:	00001097          	auipc	ra,0x1
    80003748:	bd4080e7          	jalr	-1068(ra) # 80004318 <log_write>
  brelse(bp);
    8000374c:	854a                	mv	a0,s2
    8000374e:	00000097          	auipc	ra,0x0
    80003752:	972080e7          	jalr	-1678(ra) # 800030c0 <brelse>
}
    80003756:	60e2                	ld	ra,24(sp)
    80003758:	6442                	ld	s0,16(sp)
    8000375a:	64a2                	ld	s1,8(sp)
    8000375c:	6902                	ld	s2,0(sp)
    8000375e:	6105                	addi	sp,sp,32
    80003760:	8082                	ret

0000000080003762 <idup>:
{
    80003762:	1101                	addi	sp,sp,-32
    80003764:	ec06                	sd	ra,24(sp)
    80003766:	e822                	sd	s0,16(sp)
    80003768:	e426                	sd	s1,8(sp)
    8000376a:	1000                	addi	s0,sp,32
    8000376c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000376e:	0001c517          	auipc	a0,0x1c
    80003772:	96a50513          	addi	a0,a0,-1686 # 8001f0d8 <itable>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	45c080e7          	jalr	1116(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000377e:	449c                	lw	a5,8(s1)
    80003780:	2785                	addiw	a5,a5,1
    80003782:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003784:	0001c517          	auipc	a0,0x1c
    80003788:	95450513          	addi	a0,a0,-1708 # 8001f0d8 <itable>
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	510080e7          	jalr	1296(ra) # 80000c9c <release>
}
    80003794:	8526                	mv	a0,s1
    80003796:	60e2                	ld	ra,24(sp)
    80003798:	6442                	ld	s0,16(sp)
    8000379a:	64a2                	ld	s1,8(sp)
    8000379c:	6105                	addi	sp,sp,32
    8000379e:	8082                	ret

00000000800037a0 <ilock>:
{
    800037a0:	1101                	addi	sp,sp,-32
    800037a2:	ec06                	sd	ra,24(sp)
    800037a4:	e822                	sd	s0,16(sp)
    800037a6:	e426                	sd	s1,8(sp)
    800037a8:	e04a                	sd	s2,0(sp)
    800037aa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037ac:	c115                	beqz	a0,800037d0 <ilock+0x30>
    800037ae:	84aa                	mv	s1,a0
    800037b0:	451c                	lw	a5,8(a0)
    800037b2:	00f05f63          	blez	a5,800037d0 <ilock+0x30>
  acquiresleep(&ip->lock);
    800037b6:	0541                	addi	a0,a0,16
    800037b8:	00001097          	auipc	ra,0x1
    800037bc:	c7e080e7          	jalr	-898(ra) # 80004436 <acquiresleep>
  if(ip->valid == 0){
    800037c0:	40bc                	lw	a5,64(s1)
    800037c2:	cf99                	beqz	a5,800037e0 <ilock+0x40>
}
    800037c4:	60e2                	ld	ra,24(sp)
    800037c6:	6442                	ld	s0,16(sp)
    800037c8:	64a2                	ld	s1,8(sp)
    800037ca:	6902                	ld	s2,0(sp)
    800037cc:	6105                	addi	sp,sp,32
    800037ce:	8082                	ret
    panic("ilock");
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	e4850513          	addi	a0,a0,-440 # 80008618 <syscalls+0x1b0>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	d64080e7          	jalr	-668(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037e0:	40dc                	lw	a5,4(s1)
    800037e2:	0047d79b          	srliw	a5,a5,0x4
    800037e6:	0001c597          	auipc	a1,0x1c
    800037ea:	8ea5a583          	lw	a1,-1814(a1) # 8001f0d0 <sb+0x18>
    800037ee:	9dbd                	addw	a1,a1,a5
    800037f0:	4088                	lw	a0,0(s1)
    800037f2:	fffff097          	auipc	ra,0xfffff
    800037f6:	79e080e7          	jalr	1950(ra) # 80002f90 <bread>
    800037fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037fc:	05850593          	addi	a1,a0,88
    80003800:	40dc                	lw	a5,4(s1)
    80003802:	8bbd                	andi	a5,a5,15
    80003804:	079a                	slli	a5,a5,0x6
    80003806:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003808:	00059783          	lh	a5,0(a1)
    8000380c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003810:	00259783          	lh	a5,2(a1)
    80003814:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003818:	00459783          	lh	a5,4(a1)
    8000381c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003820:	00659783          	lh	a5,6(a1)
    80003824:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003828:	459c                	lw	a5,8(a1)
    8000382a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000382c:	03400613          	li	a2,52
    80003830:	05b1                	addi	a1,a1,12
    80003832:	05048513          	addi	a0,s1,80
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	50a080e7          	jalr	1290(ra) # 80000d40 <memmove>
    brelse(bp);
    8000383e:	854a                	mv	a0,s2
    80003840:	00000097          	auipc	ra,0x0
    80003844:	880080e7          	jalr	-1920(ra) # 800030c0 <brelse>
    ip->valid = 1;
    80003848:	4785                	li	a5,1
    8000384a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000384c:	04449783          	lh	a5,68(s1)
    80003850:	fbb5                	bnez	a5,800037c4 <ilock+0x24>
      panic("ilock: no type");
    80003852:	00005517          	auipc	a0,0x5
    80003856:	dce50513          	addi	a0,a0,-562 # 80008620 <syscalls+0x1b8>
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	ce2080e7          	jalr	-798(ra) # 8000053c <panic>

0000000080003862 <iunlock>:
{
    80003862:	1101                	addi	sp,sp,-32
    80003864:	ec06                	sd	ra,24(sp)
    80003866:	e822                	sd	s0,16(sp)
    80003868:	e426                	sd	s1,8(sp)
    8000386a:	e04a                	sd	s2,0(sp)
    8000386c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000386e:	c905                	beqz	a0,8000389e <iunlock+0x3c>
    80003870:	84aa                	mv	s1,a0
    80003872:	01050913          	addi	s2,a0,16
    80003876:	854a                	mv	a0,s2
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	c58080e7          	jalr	-936(ra) # 800044d0 <holdingsleep>
    80003880:	cd19                	beqz	a0,8000389e <iunlock+0x3c>
    80003882:	449c                	lw	a5,8(s1)
    80003884:	00f05d63          	blez	a5,8000389e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003888:	854a                	mv	a0,s2
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	c02080e7          	jalr	-1022(ra) # 8000448c <releasesleep>
}
    80003892:	60e2                	ld	ra,24(sp)
    80003894:	6442                	ld	s0,16(sp)
    80003896:	64a2                	ld	s1,8(sp)
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret
    panic("iunlock");
    8000389e:	00005517          	auipc	a0,0x5
    800038a2:	d9250513          	addi	a0,a0,-622 # 80008630 <syscalls+0x1c8>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	c96080e7          	jalr	-874(ra) # 8000053c <panic>

00000000800038ae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038ae:	7179                	addi	sp,sp,-48
    800038b0:	f406                	sd	ra,40(sp)
    800038b2:	f022                	sd	s0,32(sp)
    800038b4:	ec26                	sd	s1,24(sp)
    800038b6:	e84a                	sd	s2,16(sp)
    800038b8:	e44e                	sd	s3,8(sp)
    800038ba:	e052                	sd	s4,0(sp)
    800038bc:	1800                	addi	s0,sp,48
    800038be:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038c0:	05050493          	addi	s1,a0,80
    800038c4:	08050913          	addi	s2,a0,128
    800038c8:	a021                	j	800038d0 <itrunc+0x22>
    800038ca:	0491                	addi	s1,s1,4
    800038cc:	01248d63          	beq	s1,s2,800038e6 <itrunc+0x38>
    if(ip->addrs[i]){
    800038d0:	408c                	lw	a1,0(s1)
    800038d2:	dde5                	beqz	a1,800038ca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038d4:	0009a503          	lw	a0,0(s3)
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	8fc080e7          	jalr	-1796(ra) # 800031d4 <bfree>
      ip->addrs[i] = 0;
    800038e0:	0004a023          	sw	zero,0(s1)
    800038e4:	b7dd                	j	800038ca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038e6:	0809a583          	lw	a1,128(s3)
    800038ea:	e185                	bnez	a1,8000390a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038ec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038f0:	854e                	mv	a0,s3
    800038f2:	00000097          	auipc	ra,0x0
    800038f6:	de2080e7          	jalr	-542(ra) # 800036d4 <iupdate>
}
    800038fa:	70a2                	ld	ra,40(sp)
    800038fc:	7402                	ld	s0,32(sp)
    800038fe:	64e2                	ld	s1,24(sp)
    80003900:	6942                	ld	s2,16(sp)
    80003902:	69a2                	ld	s3,8(sp)
    80003904:	6a02                	ld	s4,0(sp)
    80003906:	6145                	addi	sp,sp,48
    80003908:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000390a:	0009a503          	lw	a0,0(s3)
    8000390e:	fffff097          	auipc	ra,0xfffff
    80003912:	682080e7          	jalr	1666(ra) # 80002f90 <bread>
    80003916:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003918:	05850493          	addi	s1,a0,88
    8000391c:	45850913          	addi	s2,a0,1112
    80003920:	a021                	j	80003928 <itrunc+0x7a>
    80003922:	0491                	addi	s1,s1,4
    80003924:	01248b63          	beq	s1,s2,8000393a <itrunc+0x8c>
      if(a[j])
    80003928:	408c                	lw	a1,0(s1)
    8000392a:	dde5                	beqz	a1,80003922 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000392c:	0009a503          	lw	a0,0(s3)
    80003930:	00000097          	auipc	ra,0x0
    80003934:	8a4080e7          	jalr	-1884(ra) # 800031d4 <bfree>
    80003938:	b7ed                	j	80003922 <itrunc+0x74>
    brelse(bp);
    8000393a:	8552                	mv	a0,s4
    8000393c:	fffff097          	auipc	ra,0xfffff
    80003940:	784080e7          	jalr	1924(ra) # 800030c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003944:	0809a583          	lw	a1,128(s3)
    80003948:	0009a503          	lw	a0,0(s3)
    8000394c:	00000097          	auipc	ra,0x0
    80003950:	888080e7          	jalr	-1912(ra) # 800031d4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003954:	0809a023          	sw	zero,128(s3)
    80003958:	bf51                	j	800038ec <itrunc+0x3e>

000000008000395a <iput>:
{
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	e04a                	sd	s2,0(sp)
    80003964:	1000                	addi	s0,sp,32
    80003966:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003968:	0001b517          	auipc	a0,0x1b
    8000396c:	77050513          	addi	a0,a0,1904 # 8001f0d8 <itable>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	262080e7          	jalr	610(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003978:	4498                	lw	a4,8(s1)
    8000397a:	4785                	li	a5,1
    8000397c:	02f70363          	beq	a4,a5,800039a2 <iput+0x48>
  ip->ref--;
    80003980:	449c                	lw	a5,8(s1)
    80003982:	37fd                	addiw	a5,a5,-1
    80003984:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003986:	0001b517          	auipc	a0,0x1b
    8000398a:	75250513          	addi	a0,a0,1874 # 8001f0d8 <itable>
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	30e080e7          	jalr	782(ra) # 80000c9c <release>
}
    80003996:	60e2                	ld	ra,24(sp)
    80003998:	6442                	ld	s0,16(sp)
    8000399a:	64a2                	ld	s1,8(sp)
    8000399c:	6902                	ld	s2,0(sp)
    8000399e:	6105                	addi	sp,sp,32
    800039a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039a2:	40bc                	lw	a5,64(s1)
    800039a4:	dff1                	beqz	a5,80003980 <iput+0x26>
    800039a6:	04a49783          	lh	a5,74(s1)
    800039aa:	fbf9                	bnez	a5,80003980 <iput+0x26>
    acquiresleep(&ip->lock);
    800039ac:	01048913          	addi	s2,s1,16
    800039b0:	854a                	mv	a0,s2
    800039b2:	00001097          	auipc	ra,0x1
    800039b6:	a84080e7          	jalr	-1404(ra) # 80004436 <acquiresleep>
    release(&itable.lock);
    800039ba:	0001b517          	auipc	a0,0x1b
    800039be:	71e50513          	addi	a0,a0,1822 # 8001f0d8 <itable>
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	2da080e7          	jalr	730(ra) # 80000c9c <release>
    itrunc(ip);
    800039ca:	8526                	mv	a0,s1
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	ee2080e7          	jalr	-286(ra) # 800038ae <itrunc>
    ip->type = 0;
    800039d4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039d8:	8526                	mv	a0,s1
    800039da:	00000097          	auipc	ra,0x0
    800039de:	cfa080e7          	jalr	-774(ra) # 800036d4 <iupdate>
    ip->valid = 0;
    800039e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039e6:	854a                	mv	a0,s2
    800039e8:	00001097          	auipc	ra,0x1
    800039ec:	aa4080e7          	jalr	-1372(ra) # 8000448c <releasesleep>
    acquire(&itable.lock);
    800039f0:	0001b517          	auipc	a0,0x1b
    800039f4:	6e850513          	addi	a0,a0,1768 # 8001f0d8 <itable>
    800039f8:	ffffd097          	auipc	ra,0xffffd
    800039fc:	1da080e7          	jalr	474(ra) # 80000bd2 <acquire>
    80003a00:	b741                	j	80003980 <iput+0x26>

0000000080003a02 <iunlockput>:
{
    80003a02:	1101                	addi	sp,sp,-32
    80003a04:	ec06                	sd	ra,24(sp)
    80003a06:	e822                	sd	s0,16(sp)
    80003a08:	e426                	sd	s1,8(sp)
    80003a0a:	1000                	addi	s0,sp,32
    80003a0c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	e54080e7          	jalr	-428(ra) # 80003862 <iunlock>
  iput(ip);
    80003a16:	8526                	mv	a0,s1
    80003a18:	00000097          	auipc	ra,0x0
    80003a1c:	f42080e7          	jalr	-190(ra) # 8000395a <iput>
}
    80003a20:	60e2                	ld	ra,24(sp)
    80003a22:	6442                	ld	s0,16(sp)
    80003a24:	64a2                	ld	s1,8(sp)
    80003a26:	6105                	addi	sp,sp,32
    80003a28:	8082                	ret

0000000080003a2a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a2a:	1141                	addi	sp,sp,-16
    80003a2c:	e422                	sd	s0,8(sp)
    80003a2e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a30:	411c                	lw	a5,0(a0)
    80003a32:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a34:	415c                	lw	a5,4(a0)
    80003a36:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a38:	04451783          	lh	a5,68(a0)
    80003a3c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a40:	04a51783          	lh	a5,74(a0)
    80003a44:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a48:	04c56783          	lwu	a5,76(a0)
    80003a4c:	e99c                	sd	a5,16(a1)
}
    80003a4e:	6422                	ld	s0,8(sp)
    80003a50:	0141                	addi	sp,sp,16
    80003a52:	8082                	ret

0000000080003a54 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a54:	457c                	lw	a5,76(a0)
    80003a56:	0ed7e963          	bltu	a5,a3,80003b48 <readi+0xf4>
{
    80003a5a:	7159                	addi	sp,sp,-112
    80003a5c:	f486                	sd	ra,104(sp)
    80003a5e:	f0a2                	sd	s0,96(sp)
    80003a60:	eca6                	sd	s1,88(sp)
    80003a62:	e8ca                	sd	s2,80(sp)
    80003a64:	e4ce                	sd	s3,72(sp)
    80003a66:	e0d2                	sd	s4,64(sp)
    80003a68:	fc56                	sd	s5,56(sp)
    80003a6a:	f85a                	sd	s6,48(sp)
    80003a6c:	f45e                	sd	s7,40(sp)
    80003a6e:	f062                	sd	s8,32(sp)
    80003a70:	ec66                	sd	s9,24(sp)
    80003a72:	e86a                	sd	s10,16(sp)
    80003a74:	e46e                	sd	s11,8(sp)
    80003a76:	1880                	addi	s0,sp,112
    80003a78:	8b2a                	mv	s6,a0
    80003a7a:	8bae                	mv	s7,a1
    80003a7c:	8a32                	mv	s4,a2
    80003a7e:	84b6                	mv	s1,a3
    80003a80:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a82:	9f35                	addw	a4,a4,a3
    return 0;
    80003a84:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a86:	0ad76063          	bltu	a4,a3,80003b26 <readi+0xd2>
  if(off + n > ip->size)
    80003a8a:	00e7f463          	bgeu	a5,a4,80003a92 <readi+0x3e>
    n = ip->size - off;
    80003a8e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a92:	0a0a8963          	beqz	s5,80003b44 <readi+0xf0>
    80003a96:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a98:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a9c:	5c7d                	li	s8,-1
    80003a9e:	a82d                	j	80003ad8 <readi+0x84>
    80003aa0:	020d1d93          	slli	s11,s10,0x20
    80003aa4:	020ddd93          	srli	s11,s11,0x20
    80003aa8:	05890613          	addi	a2,s2,88
    80003aac:	86ee                	mv	a3,s11
    80003aae:	963a                	add	a2,a2,a4
    80003ab0:	85d2                	mv	a1,s4
    80003ab2:	855e                	mv	a0,s7
    80003ab4:	fffff097          	auipc	ra,0xfffff
    80003ab8:	a34080e7          	jalr	-1484(ra) # 800024e8 <either_copyout>
    80003abc:	05850d63          	beq	a0,s8,80003b16 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ac0:	854a                	mv	a0,s2
    80003ac2:	fffff097          	auipc	ra,0xfffff
    80003ac6:	5fe080e7          	jalr	1534(ra) # 800030c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aca:	013d09bb          	addw	s3,s10,s3
    80003ace:	009d04bb          	addw	s1,s10,s1
    80003ad2:	9a6e                	add	s4,s4,s11
    80003ad4:	0559f763          	bgeu	s3,s5,80003b22 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ad8:	00a4d59b          	srliw	a1,s1,0xa
    80003adc:	855a                	mv	a0,s6
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	8a4080e7          	jalr	-1884(ra) # 80003382 <bmap>
    80003ae6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003aea:	cd85                	beqz	a1,80003b22 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003aec:	000b2503          	lw	a0,0(s6)
    80003af0:	fffff097          	auipc	ra,0xfffff
    80003af4:	4a0080e7          	jalr	1184(ra) # 80002f90 <bread>
    80003af8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003afa:	3ff4f713          	andi	a4,s1,1023
    80003afe:	40ec87bb          	subw	a5,s9,a4
    80003b02:	413a86bb          	subw	a3,s5,s3
    80003b06:	8d3e                	mv	s10,a5
    80003b08:	2781                	sext.w	a5,a5
    80003b0a:	0006861b          	sext.w	a2,a3
    80003b0e:	f8f679e3          	bgeu	a2,a5,80003aa0 <readi+0x4c>
    80003b12:	8d36                	mv	s10,a3
    80003b14:	b771                	j	80003aa0 <readi+0x4c>
      brelse(bp);
    80003b16:	854a                	mv	a0,s2
    80003b18:	fffff097          	auipc	ra,0xfffff
    80003b1c:	5a8080e7          	jalr	1448(ra) # 800030c0 <brelse>
      tot = -1;
    80003b20:	59fd                	li	s3,-1
  }
  return tot;
    80003b22:	0009851b          	sext.w	a0,s3
}
    80003b26:	70a6                	ld	ra,104(sp)
    80003b28:	7406                	ld	s0,96(sp)
    80003b2a:	64e6                	ld	s1,88(sp)
    80003b2c:	6946                	ld	s2,80(sp)
    80003b2e:	69a6                	ld	s3,72(sp)
    80003b30:	6a06                	ld	s4,64(sp)
    80003b32:	7ae2                	ld	s5,56(sp)
    80003b34:	7b42                	ld	s6,48(sp)
    80003b36:	7ba2                	ld	s7,40(sp)
    80003b38:	7c02                	ld	s8,32(sp)
    80003b3a:	6ce2                	ld	s9,24(sp)
    80003b3c:	6d42                	ld	s10,16(sp)
    80003b3e:	6da2                	ld	s11,8(sp)
    80003b40:	6165                	addi	sp,sp,112
    80003b42:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b44:	89d6                	mv	s3,s5
    80003b46:	bff1                	j	80003b22 <readi+0xce>
    return 0;
    80003b48:	4501                	li	a0,0
}
    80003b4a:	8082                	ret

0000000080003b4c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4c:	457c                	lw	a5,76(a0)
    80003b4e:	10d7e863          	bltu	a5,a3,80003c5e <writei+0x112>
{
    80003b52:	7159                	addi	sp,sp,-112
    80003b54:	f486                	sd	ra,104(sp)
    80003b56:	f0a2                	sd	s0,96(sp)
    80003b58:	eca6                	sd	s1,88(sp)
    80003b5a:	e8ca                	sd	s2,80(sp)
    80003b5c:	e4ce                	sd	s3,72(sp)
    80003b5e:	e0d2                	sd	s4,64(sp)
    80003b60:	fc56                	sd	s5,56(sp)
    80003b62:	f85a                	sd	s6,48(sp)
    80003b64:	f45e                	sd	s7,40(sp)
    80003b66:	f062                	sd	s8,32(sp)
    80003b68:	ec66                	sd	s9,24(sp)
    80003b6a:	e86a                	sd	s10,16(sp)
    80003b6c:	e46e                	sd	s11,8(sp)
    80003b6e:	1880                	addi	s0,sp,112
    80003b70:	8aaa                	mv	s5,a0
    80003b72:	8bae                	mv	s7,a1
    80003b74:	8a32                	mv	s4,a2
    80003b76:	8936                	mv	s2,a3
    80003b78:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b7a:	00e687bb          	addw	a5,a3,a4
    80003b7e:	0ed7e263          	bltu	a5,a3,80003c62 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b82:	00043737          	lui	a4,0x43
    80003b86:	0ef76063          	bltu	a4,a5,80003c66 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b8a:	0c0b0863          	beqz	s6,80003c5a <writei+0x10e>
    80003b8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b90:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b94:	5c7d                	li	s8,-1
    80003b96:	a091                	j	80003bda <writei+0x8e>
    80003b98:	020d1d93          	slli	s11,s10,0x20
    80003b9c:	020ddd93          	srli	s11,s11,0x20
    80003ba0:	05848513          	addi	a0,s1,88
    80003ba4:	86ee                	mv	a3,s11
    80003ba6:	8652                	mv	a2,s4
    80003ba8:	85de                	mv	a1,s7
    80003baa:	953a                	add	a0,a0,a4
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	992080e7          	jalr	-1646(ra) # 8000253e <either_copyin>
    80003bb4:	07850263          	beq	a0,s8,80003c18 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bb8:	8526                	mv	a0,s1
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	75e080e7          	jalr	1886(ra) # 80004318 <log_write>
    brelse(bp);
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	fffff097          	auipc	ra,0xfffff
    80003bc8:	4fc080e7          	jalr	1276(ra) # 800030c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bcc:	013d09bb          	addw	s3,s10,s3
    80003bd0:	012d093b          	addw	s2,s10,s2
    80003bd4:	9a6e                	add	s4,s4,s11
    80003bd6:	0569f663          	bgeu	s3,s6,80003c22 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bda:	00a9559b          	srliw	a1,s2,0xa
    80003bde:	8556                	mv	a0,s5
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	7a2080e7          	jalr	1954(ra) # 80003382 <bmap>
    80003be8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bec:	c99d                	beqz	a1,80003c22 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bee:	000aa503          	lw	a0,0(s5)
    80003bf2:	fffff097          	auipc	ra,0xfffff
    80003bf6:	39e080e7          	jalr	926(ra) # 80002f90 <bread>
    80003bfa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bfc:	3ff97713          	andi	a4,s2,1023
    80003c00:	40ec87bb          	subw	a5,s9,a4
    80003c04:	413b06bb          	subw	a3,s6,s3
    80003c08:	8d3e                	mv	s10,a5
    80003c0a:	2781                	sext.w	a5,a5
    80003c0c:	0006861b          	sext.w	a2,a3
    80003c10:	f8f674e3          	bgeu	a2,a5,80003b98 <writei+0x4c>
    80003c14:	8d36                	mv	s10,a3
    80003c16:	b749                	j	80003b98 <writei+0x4c>
      brelse(bp);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	4a6080e7          	jalr	1190(ra) # 800030c0 <brelse>
  }

  if(off > ip->size)
    80003c22:	04caa783          	lw	a5,76(s5)
    80003c26:	0127f463          	bgeu	a5,s2,80003c2e <writei+0xe2>
    ip->size = off;
    80003c2a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c2e:	8556                	mv	a0,s5
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	aa4080e7          	jalr	-1372(ra) # 800036d4 <iupdate>

  return tot;
    80003c38:	0009851b          	sext.w	a0,s3
}
    80003c3c:	70a6                	ld	ra,104(sp)
    80003c3e:	7406                	ld	s0,96(sp)
    80003c40:	64e6                	ld	s1,88(sp)
    80003c42:	6946                	ld	s2,80(sp)
    80003c44:	69a6                	ld	s3,72(sp)
    80003c46:	6a06                	ld	s4,64(sp)
    80003c48:	7ae2                	ld	s5,56(sp)
    80003c4a:	7b42                	ld	s6,48(sp)
    80003c4c:	7ba2                	ld	s7,40(sp)
    80003c4e:	7c02                	ld	s8,32(sp)
    80003c50:	6ce2                	ld	s9,24(sp)
    80003c52:	6d42                	ld	s10,16(sp)
    80003c54:	6da2                	ld	s11,8(sp)
    80003c56:	6165                	addi	sp,sp,112
    80003c58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c5a:	89da                	mv	s3,s6
    80003c5c:	bfc9                	j	80003c2e <writei+0xe2>
    return -1;
    80003c5e:	557d                	li	a0,-1
}
    80003c60:	8082                	ret
    return -1;
    80003c62:	557d                	li	a0,-1
    80003c64:	bfe1                	j	80003c3c <writei+0xf0>
    return -1;
    80003c66:	557d                	li	a0,-1
    80003c68:	bfd1                	j	80003c3c <writei+0xf0>

0000000080003c6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c6a:	1141                	addi	sp,sp,-16
    80003c6c:	e406                	sd	ra,8(sp)
    80003c6e:	e022                	sd	s0,0(sp)
    80003c70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c72:	4639                	li	a2,14
    80003c74:	ffffd097          	auipc	ra,0xffffd
    80003c78:	140080e7          	jalr	320(ra) # 80000db4 <strncmp>
}
    80003c7c:	60a2                	ld	ra,8(sp)
    80003c7e:	6402                	ld	s0,0(sp)
    80003c80:	0141                	addi	sp,sp,16
    80003c82:	8082                	ret

0000000080003c84 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c84:	7139                	addi	sp,sp,-64
    80003c86:	fc06                	sd	ra,56(sp)
    80003c88:	f822                	sd	s0,48(sp)
    80003c8a:	f426                	sd	s1,40(sp)
    80003c8c:	f04a                	sd	s2,32(sp)
    80003c8e:	ec4e                	sd	s3,24(sp)
    80003c90:	e852                	sd	s4,16(sp)
    80003c92:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c94:	04451703          	lh	a4,68(a0)
    80003c98:	4785                	li	a5,1
    80003c9a:	00f71a63          	bne	a4,a5,80003cae <dirlookup+0x2a>
    80003c9e:	892a                	mv	s2,a0
    80003ca0:	89ae                	mv	s3,a1
    80003ca2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca4:	457c                	lw	a5,76(a0)
    80003ca6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ca8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003caa:	e79d                	bnez	a5,80003cd8 <dirlookup+0x54>
    80003cac:	a8a5                	j	80003d24 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cae:	00005517          	auipc	a0,0x5
    80003cb2:	98a50513          	addi	a0,a0,-1654 # 80008638 <syscalls+0x1d0>
    80003cb6:	ffffd097          	auipc	ra,0xffffd
    80003cba:	886080e7          	jalr	-1914(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003cbe:	00005517          	auipc	a0,0x5
    80003cc2:	99250513          	addi	a0,a0,-1646 # 80008650 <syscalls+0x1e8>
    80003cc6:	ffffd097          	auipc	ra,0xffffd
    80003cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cce:	24c1                	addiw	s1,s1,16
    80003cd0:	04c92783          	lw	a5,76(s2)
    80003cd4:	04f4f763          	bgeu	s1,a5,80003d22 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cd8:	4741                	li	a4,16
    80003cda:	86a6                	mv	a3,s1
    80003cdc:	fc040613          	addi	a2,s0,-64
    80003ce0:	4581                	li	a1,0
    80003ce2:	854a                	mv	a0,s2
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	d70080e7          	jalr	-656(ra) # 80003a54 <readi>
    80003cec:	47c1                	li	a5,16
    80003cee:	fcf518e3          	bne	a0,a5,80003cbe <dirlookup+0x3a>
    if(de.inum == 0)
    80003cf2:	fc045783          	lhu	a5,-64(s0)
    80003cf6:	dfe1                	beqz	a5,80003cce <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cf8:	fc240593          	addi	a1,s0,-62
    80003cfc:	854e                	mv	a0,s3
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	f6c080e7          	jalr	-148(ra) # 80003c6a <namecmp>
    80003d06:	f561                	bnez	a0,80003cce <dirlookup+0x4a>
      if(poff)
    80003d08:	000a0463          	beqz	s4,80003d10 <dirlookup+0x8c>
        *poff = off;
    80003d0c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d10:	fc045583          	lhu	a1,-64(s0)
    80003d14:	00092503          	lw	a0,0(s2)
    80003d18:	fffff097          	auipc	ra,0xfffff
    80003d1c:	754080e7          	jalr	1876(ra) # 8000346c <iget>
    80003d20:	a011                	j	80003d24 <dirlookup+0xa0>
  return 0;
    80003d22:	4501                	li	a0,0
}
    80003d24:	70e2                	ld	ra,56(sp)
    80003d26:	7442                	ld	s0,48(sp)
    80003d28:	74a2                	ld	s1,40(sp)
    80003d2a:	7902                	ld	s2,32(sp)
    80003d2c:	69e2                	ld	s3,24(sp)
    80003d2e:	6a42                	ld	s4,16(sp)
    80003d30:	6121                	addi	sp,sp,64
    80003d32:	8082                	ret

0000000080003d34 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d34:	711d                	addi	sp,sp,-96
    80003d36:	ec86                	sd	ra,88(sp)
    80003d38:	e8a2                	sd	s0,80(sp)
    80003d3a:	e4a6                	sd	s1,72(sp)
    80003d3c:	e0ca                	sd	s2,64(sp)
    80003d3e:	fc4e                	sd	s3,56(sp)
    80003d40:	f852                	sd	s4,48(sp)
    80003d42:	f456                	sd	s5,40(sp)
    80003d44:	f05a                	sd	s6,32(sp)
    80003d46:	ec5e                	sd	s7,24(sp)
    80003d48:	e862                	sd	s8,16(sp)
    80003d4a:	e466                	sd	s9,8(sp)
    80003d4c:	1080                	addi	s0,sp,96
    80003d4e:	84aa                	mv	s1,a0
    80003d50:	8b2e                	mv	s6,a1
    80003d52:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d54:	00054703          	lbu	a4,0(a0)
    80003d58:	02f00793          	li	a5,47
    80003d5c:	02f70263          	beq	a4,a5,80003d80 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d60:	ffffe097          	auipc	ra,0xffffe
    80003d64:	c5c080e7          	jalr	-932(ra) # 800019bc <myproc>
    80003d68:	15053503          	ld	a0,336(a0)
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	9f6080e7          	jalr	-1546(ra) # 80003762 <idup>
    80003d74:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d76:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d7a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d7c:	4b85                	li	s7,1
    80003d7e:	a875                	j	80003e3a <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d80:	4585                	li	a1,1
    80003d82:	4505                	li	a0,1
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	6e8080e7          	jalr	1768(ra) # 8000346c <iget>
    80003d8c:	8a2a                	mv	s4,a0
    80003d8e:	b7e5                	j	80003d76 <namex+0x42>
      iunlockput(ip);
    80003d90:	8552                	mv	a0,s4
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	c70080e7          	jalr	-912(ra) # 80003a02 <iunlockput>
      return 0;
    80003d9a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d9c:	8552                	mv	a0,s4
    80003d9e:	60e6                	ld	ra,88(sp)
    80003da0:	6446                	ld	s0,80(sp)
    80003da2:	64a6                	ld	s1,72(sp)
    80003da4:	6906                	ld	s2,64(sp)
    80003da6:	79e2                	ld	s3,56(sp)
    80003da8:	7a42                	ld	s4,48(sp)
    80003daa:	7aa2                	ld	s5,40(sp)
    80003dac:	7b02                	ld	s6,32(sp)
    80003dae:	6be2                	ld	s7,24(sp)
    80003db0:	6c42                	ld	s8,16(sp)
    80003db2:	6ca2                	ld	s9,8(sp)
    80003db4:	6125                	addi	sp,sp,96
    80003db6:	8082                	ret
      iunlock(ip);
    80003db8:	8552                	mv	a0,s4
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	aa8080e7          	jalr	-1368(ra) # 80003862 <iunlock>
      return ip;
    80003dc2:	bfe9                	j	80003d9c <namex+0x68>
      iunlockput(ip);
    80003dc4:	8552                	mv	a0,s4
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c3c080e7          	jalr	-964(ra) # 80003a02 <iunlockput>
      return 0;
    80003dce:	8a4e                	mv	s4,s3
    80003dd0:	b7f1                	j	80003d9c <namex+0x68>
  len = path - s;
    80003dd2:	40998633          	sub	a2,s3,s1
    80003dd6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dda:	099c5863          	bge	s8,s9,80003e6a <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dde:	4639                	li	a2,14
    80003de0:	85a6                	mv	a1,s1
    80003de2:	8556                	mv	a0,s5
    80003de4:	ffffd097          	auipc	ra,0xffffd
    80003de8:	f5c080e7          	jalr	-164(ra) # 80000d40 <memmove>
    80003dec:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dee:	0004c783          	lbu	a5,0(s1)
    80003df2:	01279763          	bne	a5,s2,80003e00 <namex+0xcc>
    path++;
    80003df6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003df8:	0004c783          	lbu	a5,0(s1)
    80003dfc:	ff278de3          	beq	a5,s2,80003df6 <namex+0xc2>
    ilock(ip);
    80003e00:	8552                	mv	a0,s4
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	99e080e7          	jalr	-1634(ra) # 800037a0 <ilock>
    if(ip->type != T_DIR){
    80003e0a:	044a1783          	lh	a5,68(s4)
    80003e0e:	f97791e3          	bne	a5,s7,80003d90 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e12:	000b0563          	beqz	s6,80003e1c <namex+0xe8>
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	dfd9                	beqz	a5,80003db8 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e1c:	4601                	li	a2,0
    80003e1e:	85d6                	mv	a1,s5
    80003e20:	8552                	mv	a0,s4
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	e62080e7          	jalr	-414(ra) # 80003c84 <dirlookup>
    80003e2a:	89aa                	mv	s3,a0
    80003e2c:	dd41                	beqz	a0,80003dc4 <namex+0x90>
    iunlockput(ip);
    80003e2e:	8552                	mv	a0,s4
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	bd2080e7          	jalr	-1070(ra) # 80003a02 <iunlockput>
    ip = next;
    80003e38:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e3a:	0004c783          	lbu	a5,0(s1)
    80003e3e:	01279763          	bne	a5,s2,80003e4c <namex+0x118>
    path++;
    80003e42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e44:	0004c783          	lbu	a5,0(s1)
    80003e48:	ff278de3          	beq	a5,s2,80003e42 <namex+0x10e>
  if(*path == 0)
    80003e4c:	cb9d                	beqz	a5,80003e82 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e4e:	0004c783          	lbu	a5,0(s1)
    80003e52:	89a6                	mv	s3,s1
  len = path - s;
    80003e54:	4c81                	li	s9,0
    80003e56:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e58:	01278963          	beq	a5,s2,80003e6a <namex+0x136>
    80003e5c:	dbbd                	beqz	a5,80003dd2 <namex+0x9e>
    path++;
    80003e5e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e60:	0009c783          	lbu	a5,0(s3)
    80003e64:	ff279ce3          	bne	a5,s2,80003e5c <namex+0x128>
    80003e68:	b7ad                	j	80003dd2 <namex+0x9e>
    memmove(name, s, len);
    80003e6a:	2601                	sext.w	a2,a2
    80003e6c:	85a6                	mv	a1,s1
    80003e6e:	8556                	mv	a0,s5
    80003e70:	ffffd097          	auipc	ra,0xffffd
    80003e74:	ed0080e7          	jalr	-304(ra) # 80000d40 <memmove>
    name[len] = 0;
    80003e78:	9cd6                	add	s9,s9,s5
    80003e7a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e7e:	84ce                	mv	s1,s3
    80003e80:	b7bd                	j	80003dee <namex+0xba>
  if(nameiparent){
    80003e82:	f00b0de3          	beqz	s6,80003d9c <namex+0x68>
    iput(ip);
    80003e86:	8552                	mv	a0,s4
    80003e88:	00000097          	auipc	ra,0x0
    80003e8c:	ad2080e7          	jalr	-1326(ra) # 8000395a <iput>
    return 0;
    80003e90:	4a01                	li	s4,0
    80003e92:	b729                	j	80003d9c <namex+0x68>

0000000080003e94 <dirlink>:
{
    80003e94:	7139                	addi	sp,sp,-64
    80003e96:	fc06                	sd	ra,56(sp)
    80003e98:	f822                	sd	s0,48(sp)
    80003e9a:	f426                	sd	s1,40(sp)
    80003e9c:	f04a                	sd	s2,32(sp)
    80003e9e:	ec4e                	sd	s3,24(sp)
    80003ea0:	e852                	sd	s4,16(sp)
    80003ea2:	0080                	addi	s0,sp,64
    80003ea4:	892a                	mv	s2,a0
    80003ea6:	8a2e                	mv	s4,a1
    80003ea8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003eaa:	4601                	li	a2,0
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	dd8080e7          	jalr	-552(ra) # 80003c84 <dirlookup>
    80003eb4:	e93d                	bnez	a0,80003f2a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb6:	04c92483          	lw	s1,76(s2)
    80003eba:	c49d                	beqz	s1,80003ee8 <dirlink+0x54>
    80003ebc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ebe:	4741                	li	a4,16
    80003ec0:	86a6                	mv	a3,s1
    80003ec2:	fc040613          	addi	a2,s0,-64
    80003ec6:	4581                	li	a1,0
    80003ec8:	854a                	mv	a0,s2
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	b8a080e7          	jalr	-1142(ra) # 80003a54 <readi>
    80003ed2:	47c1                	li	a5,16
    80003ed4:	06f51163          	bne	a0,a5,80003f36 <dirlink+0xa2>
    if(de.inum == 0)
    80003ed8:	fc045783          	lhu	a5,-64(s0)
    80003edc:	c791                	beqz	a5,80003ee8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ede:	24c1                	addiw	s1,s1,16
    80003ee0:	04c92783          	lw	a5,76(s2)
    80003ee4:	fcf4ede3          	bltu	s1,a5,80003ebe <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ee8:	4639                	li	a2,14
    80003eea:	85d2                	mv	a1,s4
    80003eec:	fc240513          	addi	a0,s0,-62
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	f00080e7          	jalr	-256(ra) # 80000df0 <strncpy>
  de.inum = inum;
    80003ef8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003efc:	4741                	li	a4,16
    80003efe:	86a6                	mv	a3,s1
    80003f00:	fc040613          	addi	a2,s0,-64
    80003f04:	4581                	li	a1,0
    80003f06:	854a                	mv	a0,s2
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	c44080e7          	jalr	-956(ra) # 80003b4c <writei>
    80003f10:	1541                	addi	a0,a0,-16
    80003f12:	00a03533          	snez	a0,a0
    80003f16:	40a00533          	neg	a0,a0
}
    80003f1a:	70e2                	ld	ra,56(sp)
    80003f1c:	7442                	ld	s0,48(sp)
    80003f1e:	74a2                	ld	s1,40(sp)
    80003f20:	7902                	ld	s2,32(sp)
    80003f22:	69e2                	ld	s3,24(sp)
    80003f24:	6a42                	ld	s4,16(sp)
    80003f26:	6121                	addi	sp,sp,64
    80003f28:	8082                	ret
    iput(ip);
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	a30080e7          	jalr	-1488(ra) # 8000395a <iput>
    return -1;
    80003f32:	557d                	li	a0,-1
    80003f34:	b7dd                	j	80003f1a <dirlink+0x86>
      panic("dirlink read");
    80003f36:	00004517          	auipc	a0,0x4
    80003f3a:	72a50513          	addi	a0,a0,1834 # 80008660 <syscalls+0x1f8>
    80003f3e:	ffffc097          	auipc	ra,0xffffc
    80003f42:	5fe080e7          	jalr	1534(ra) # 8000053c <panic>

0000000080003f46 <namei>:

struct inode*
namei(char *path)
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f4e:	fe040613          	addi	a2,s0,-32
    80003f52:	4581                	li	a1,0
    80003f54:	00000097          	auipc	ra,0x0
    80003f58:	de0080e7          	jalr	-544(ra) # 80003d34 <namex>
}
    80003f5c:	60e2                	ld	ra,24(sp)
    80003f5e:	6442                	ld	s0,16(sp)
    80003f60:	6105                	addi	sp,sp,32
    80003f62:	8082                	ret

0000000080003f64 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f64:	1141                	addi	sp,sp,-16
    80003f66:	e406                	sd	ra,8(sp)
    80003f68:	e022                	sd	s0,0(sp)
    80003f6a:	0800                	addi	s0,sp,16
    80003f6c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f6e:	4585                	li	a1,1
    80003f70:	00000097          	auipc	ra,0x0
    80003f74:	dc4080e7          	jalr	-572(ra) # 80003d34 <namex>
}
    80003f78:	60a2                	ld	ra,8(sp)
    80003f7a:	6402                	ld	s0,0(sp)
    80003f7c:	0141                	addi	sp,sp,16
    80003f7e:	8082                	ret

0000000080003f80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f80:	1101                	addi	sp,sp,-32
    80003f82:	ec06                	sd	ra,24(sp)
    80003f84:	e822                	sd	s0,16(sp)
    80003f86:	e426                	sd	s1,8(sp)
    80003f88:	e04a                	sd	s2,0(sp)
    80003f8a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f8c:	0001d917          	auipc	s2,0x1d
    80003f90:	bf490913          	addi	s2,s2,-1036 # 80020b80 <log>
    80003f94:	01892583          	lw	a1,24(s2)
    80003f98:	02892503          	lw	a0,40(s2)
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	ff4080e7          	jalr	-12(ra) # 80002f90 <bread>
    80003fa4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fa6:	02c92603          	lw	a2,44(s2)
    80003faa:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fac:	00c05f63          	blez	a2,80003fca <write_head+0x4a>
    80003fb0:	0001d717          	auipc	a4,0x1d
    80003fb4:	c0070713          	addi	a4,a4,-1024 # 80020bb0 <log+0x30>
    80003fb8:	87aa                	mv	a5,a0
    80003fba:	060a                	slli	a2,a2,0x2
    80003fbc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fbe:	4314                	lw	a3,0(a4)
    80003fc0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fc2:	0711                	addi	a4,a4,4
    80003fc4:	0791                	addi	a5,a5,4
    80003fc6:	fec79ce3          	bne	a5,a2,80003fbe <write_head+0x3e>
  }
  bwrite(buf);
    80003fca:	8526                	mv	a0,s1
    80003fcc:	fffff097          	auipc	ra,0xfffff
    80003fd0:	0b6080e7          	jalr	182(ra) # 80003082 <bwrite>
  brelse(buf);
    80003fd4:	8526                	mv	a0,s1
    80003fd6:	fffff097          	auipc	ra,0xfffff
    80003fda:	0ea080e7          	jalr	234(ra) # 800030c0 <brelse>
}
    80003fde:	60e2                	ld	ra,24(sp)
    80003fe0:	6442                	ld	s0,16(sp)
    80003fe2:	64a2                	ld	s1,8(sp)
    80003fe4:	6902                	ld	s2,0(sp)
    80003fe6:	6105                	addi	sp,sp,32
    80003fe8:	8082                	ret

0000000080003fea <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fea:	0001d797          	auipc	a5,0x1d
    80003fee:	bc27a783          	lw	a5,-1086(a5) # 80020bac <log+0x2c>
    80003ff2:	0af05d63          	blez	a5,800040ac <install_trans+0xc2>
{
    80003ff6:	7139                	addi	sp,sp,-64
    80003ff8:	fc06                	sd	ra,56(sp)
    80003ffa:	f822                	sd	s0,48(sp)
    80003ffc:	f426                	sd	s1,40(sp)
    80003ffe:	f04a                	sd	s2,32(sp)
    80004000:	ec4e                	sd	s3,24(sp)
    80004002:	e852                	sd	s4,16(sp)
    80004004:	e456                	sd	s5,8(sp)
    80004006:	e05a                	sd	s6,0(sp)
    80004008:	0080                	addi	s0,sp,64
    8000400a:	8b2a                	mv	s6,a0
    8000400c:	0001da97          	auipc	s5,0x1d
    80004010:	ba4a8a93          	addi	s5,s5,-1116 # 80020bb0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004014:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004016:	0001d997          	auipc	s3,0x1d
    8000401a:	b6a98993          	addi	s3,s3,-1174 # 80020b80 <log>
    8000401e:	a00d                	j	80004040 <install_trans+0x56>
    brelse(lbuf);
    80004020:	854a                	mv	a0,s2
    80004022:	fffff097          	auipc	ra,0xfffff
    80004026:	09e080e7          	jalr	158(ra) # 800030c0 <brelse>
    brelse(dbuf);
    8000402a:	8526                	mv	a0,s1
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	094080e7          	jalr	148(ra) # 800030c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004034:	2a05                	addiw	s4,s4,1
    80004036:	0a91                	addi	s5,s5,4
    80004038:	02c9a783          	lw	a5,44(s3)
    8000403c:	04fa5e63          	bge	s4,a5,80004098 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004040:	0189a583          	lw	a1,24(s3)
    80004044:	014585bb          	addw	a1,a1,s4
    80004048:	2585                	addiw	a1,a1,1
    8000404a:	0289a503          	lw	a0,40(s3)
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	f42080e7          	jalr	-190(ra) # 80002f90 <bread>
    80004056:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004058:	000aa583          	lw	a1,0(s5)
    8000405c:	0289a503          	lw	a0,40(s3)
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	f30080e7          	jalr	-208(ra) # 80002f90 <bread>
    80004068:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000406a:	40000613          	li	a2,1024
    8000406e:	05890593          	addi	a1,s2,88
    80004072:	05850513          	addi	a0,a0,88
    80004076:	ffffd097          	auipc	ra,0xffffd
    8000407a:	cca080e7          	jalr	-822(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000407e:	8526                	mv	a0,s1
    80004080:	fffff097          	auipc	ra,0xfffff
    80004084:	002080e7          	jalr	2(ra) # 80003082 <bwrite>
    if(recovering == 0)
    80004088:	f80b1ce3          	bnez	s6,80004020 <install_trans+0x36>
      bunpin(dbuf);
    8000408c:	8526                	mv	a0,s1
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	10a080e7          	jalr	266(ra) # 80003198 <bunpin>
    80004096:	b769                	j	80004020 <install_trans+0x36>
}
    80004098:	70e2                	ld	ra,56(sp)
    8000409a:	7442                	ld	s0,48(sp)
    8000409c:	74a2                	ld	s1,40(sp)
    8000409e:	7902                	ld	s2,32(sp)
    800040a0:	69e2                	ld	s3,24(sp)
    800040a2:	6a42                	ld	s4,16(sp)
    800040a4:	6aa2                	ld	s5,8(sp)
    800040a6:	6b02                	ld	s6,0(sp)
    800040a8:	6121                	addi	sp,sp,64
    800040aa:	8082                	ret
    800040ac:	8082                	ret

00000000800040ae <initlog>:
{
    800040ae:	7179                	addi	sp,sp,-48
    800040b0:	f406                	sd	ra,40(sp)
    800040b2:	f022                	sd	s0,32(sp)
    800040b4:	ec26                	sd	s1,24(sp)
    800040b6:	e84a                	sd	s2,16(sp)
    800040b8:	e44e                	sd	s3,8(sp)
    800040ba:	1800                	addi	s0,sp,48
    800040bc:	892a                	mv	s2,a0
    800040be:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040c0:	0001d497          	auipc	s1,0x1d
    800040c4:	ac048493          	addi	s1,s1,-1344 # 80020b80 <log>
    800040c8:	00004597          	auipc	a1,0x4
    800040cc:	5a858593          	addi	a1,a1,1448 # 80008670 <syscalls+0x208>
    800040d0:	8526                	mv	a0,s1
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	a70080e7          	jalr	-1424(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040da:	0149a583          	lw	a1,20(s3)
    800040de:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040e0:	0109a783          	lw	a5,16(s3)
    800040e4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040e6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040ea:	854a                	mv	a0,s2
    800040ec:	fffff097          	auipc	ra,0xfffff
    800040f0:	ea4080e7          	jalr	-348(ra) # 80002f90 <bread>
  log.lh.n = lh->n;
    800040f4:	4d30                	lw	a2,88(a0)
    800040f6:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040f8:	00c05f63          	blez	a2,80004116 <initlog+0x68>
    800040fc:	87aa                	mv	a5,a0
    800040fe:	0001d717          	auipc	a4,0x1d
    80004102:	ab270713          	addi	a4,a4,-1358 # 80020bb0 <log+0x30>
    80004106:	060a                	slli	a2,a2,0x2
    80004108:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000410a:	4ff4                	lw	a3,92(a5)
    8000410c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000410e:	0791                	addi	a5,a5,4
    80004110:	0711                	addi	a4,a4,4
    80004112:	fec79ce3          	bne	a5,a2,8000410a <initlog+0x5c>
  brelse(buf);
    80004116:	fffff097          	auipc	ra,0xfffff
    8000411a:	faa080e7          	jalr	-86(ra) # 800030c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000411e:	4505                	li	a0,1
    80004120:	00000097          	auipc	ra,0x0
    80004124:	eca080e7          	jalr	-310(ra) # 80003fea <install_trans>
  log.lh.n = 0;
    80004128:	0001d797          	auipc	a5,0x1d
    8000412c:	a807a223          	sw	zero,-1404(a5) # 80020bac <log+0x2c>
  write_head(); // clear the log
    80004130:	00000097          	auipc	ra,0x0
    80004134:	e50080e7          	jalr	-432(ra) # 80003f80 <write_head>
}
    80004138:	70a2                	ld	ra,40(sp)
    8000413a:	7402                	ld	s0,32(sp)
    8000413c:	64e2                	ld	s1,24(sp)
    8000413e:	6942                	ld	s2,16(sp)
    80004140:	69a2                	ld	s3,8(sp)
    80004142:	6145                	addi	sp,sp,48
    80004144:	8082                	ret

0000000080004146 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004146:	1101                	addi	sp,sp,-32
    80004148:	ec06                	sd	ra,24(sp)
    8000414a:	e822                	sd	s0,16(sp)
    8000414c:	e426                	sd	s1,8(sp)
    8000414e:	e04a                	sd	s2,0(sp)
    80004150:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004152:	0001d517          	auipc	a0,0x1d
    80004156:	a2e50513          	addi	a0,a0,-1490 # 80020b80 <log>
    8000415a:	ffffd097          	auipc	ra,0xffffd
    8000415e:	a78080e7          	jalr	-1416(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004162:	0001d497          	auipc	s1,0x1d
    80004166:	a1e48493          	addi	s1,s1,-1506 # 80020b80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000416a:	4979                	li	s2,30
    8000416c:	a039                	j	8000417a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000416e:	85a6                	mv	a1,s1
    80004170:	8526                	mv	a0,s1
    80004172:	ffffe097          	auipc	ra,0xffffe
    80004176:	f6e080e7          	jalr	-146(ra) # 800020e0 <sleep>
    if(log.committing){
    8000417a:	50dc                	lw	a5,36(s1)
    8000417c:	fbed                	bnez	a5,8000416e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000417e:	5098                	lw	a4,32(s1)
    80004180:	2705                	addiw	a4,a4,1
    80004182:	0027179b          	slliw	a5,a4,0x2
    80004186:	9fb9                	addw	a5,a5,a4
    80004188:	0017979b          	slliw	a5,a5,0x1
    8000418c:	54d4                	lw	a3,44(s1)
    8000418e:	9fb5                	addw	a5,a5,a3
    80004190:	00f95963          	bge	s2,a5,800041a2 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004194:	85a6                	mv	a1,s1
    80004196:	8526                	mv	a0,s1
    80004198:	ffffe097          	auipc	ra,0xffffe
    8000419c:	f48080e7          	jalr	-184(ra) # 800020e0 <sleep>
    800041a0:	bfe9                	j	8000417a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041a2:	0001d517          	auipc	a0,0x1d
    800041a6:	9de50513          	addi	a0,a0,-1570 # 80020b80 <log>
    800041aa:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	af0080e7          	jalr	-1296(ra) # 80000c9c <release>
      break;
    }
  }
}
    800041b4:	60e2                	ld	ra,24(sp)
    800041b6:	6442                	ld	s0,16(sp)
    800041b8:	64a2                	ld	s1,8(sp)
    800041ba:	6902                	ld	s2,0(sp)
    800041bc:	6105                	addi	sp,sp,32
    800041be:	8082                	ret

00000000800041c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041c0:	7139                	addi	sp,sp,-64
    800041c2:	fc06                	sd	ra,56(sp)
    800041c4:	f822                	sd	s0,48(sp)
    800041c6:	f426                	sd	s1,40(sp)
    800041c8:	f04a                	sd	s2,32(sp)
    800041ca:	ec4e                	sd	s3,24(sp)
    800041cc:	e852                	sd	s4,16(sp)
    800041ce:	e456                	sd	s5,8(sp)
    800041d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041d2:	0001d497          	auipc	s1,0x1d
    800041d6:	9ae48493          	addi	s1,s1,-1618 # 80020b80 <log>
    800041da:	8526                	mv	a0,s1
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	9f6080e7          	jalr	-1546(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041e4:	509c                	lw	a5,32(s1)
    800041e6:	37fd                	addiw	a5,a5,-1
    800041e8:	0007891b          	sext.w	s2,a5
    800041ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041ee:	50dc                	lw	a5,36(s1)
    800041f0:	e7b9                	bnez	a5,8000423e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041f2:	04091e63          	bnez	s2,8000424e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041f6:	0001d497          	auipc	s1,0x1d
    800041fa:	98a48493          	addi	s1,s1,-1654 # 80020b80 <log>
    800041fe:	4785                	li	a5,1
    80004200:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004202:	8526                	mv	a0,s1
    80004204:	ffffd097          	auipc	ra,0xffffd
    80004208:	a98080e7          	jalr	-1384(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000420c:	54dc                	lw	a5,44(s1)
    8000420e:	06f04763          	bgtz	a5,8000427c <end_op+0xbc>
    acquire(&log.lock);
    80004212:	0001d497          	auipc	s1,0x1d
    80004216:	96e48493          	addi	s1,s1,-1682 # 80020b80 <log>
    8000421a:	8526                	mv	a0,s1
    8000421c:	ffffd097          	auipc	ra,0xffffd
    80004220:	9b6080e7          	jalr	-1610(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004224:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004228:	8526                	mv	a0,s1
    8000422a:	ffffe097          	auipc	ra,0xffffe
    8000422e:	f1a080e7          	jalr	-230(ra) # 80002144 <wakeup>
    release(&log.lock);
    80004232:	8526                	mv	a0,s1
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	a68080e7          	jalr	-1432(ra) # 80000c9c <release>
}
    8000423c:	a03d                	j	8000426a <end_op+0xaa>
    panic("log.committing");
    8000423e:	00004517          	auipc	a0,0x4
    80004242:	43a50513          	addi	a0,a0,1082 # 80008678 <syscalls+0x210>
    80004246:	ffffc097          	auipc	ra,0xffffc
    8000424a:	2f6080e7          	jalr	758(ra) # 8000053c <panic>
    wakeup(&log);
    8000424e:	0001d497          	auipc	s1,0x1d
    80004252:	93248493          	addi	s1,s1,-1742 # 80020b80 <log>
    80004256:	8526                	mv	a0,s1
    80004258:	ffffe097          	auipc	ra,0xffffe
    8000425c:	eec080e7          	jalr	-276(ra) # 80002144 <wakeup>
  release(&log.lock);
    80004260:	8526                	mv	a0,s1
    80004262:	ffffd097          	auipc	ra,0xffffd
    80004266:	a3a080e7          	jalr	-1478(ra) # 80000c9c <release>
}
    8000426a:	70e2                	ld	ra,56(sp)
    8000426c:	7442                	ld	s0,48(sp)
    8000426e:	74a2                	ld	s1,40(sp)
    80004270:	7902                	ld	s2,32(sp)
    80004272:	69e2                	ld	s3,24(sp)
    80004274:	6a42                	ld	s4,16(sp)
    80004276:	6aa2                	ld	s5,8(sp)
    80004278:	6121                	addi	sp,sp,64
    8000427a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000427c:	0001da97          	auipc	s5,0x1d
    80004280:	934a8a93          	addi	s5,s5,-1740 # 80020bb0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004284:	0001da17          	auipc	s4,0x1d
    80004288:	8fca0a13          	addi	s4,s4,-1796 # 80020b80 <log>
    8000428c:	018a2583          	lw	a1,24(s4)
    80004290:	012585bb          	addw	a1,a1,s2
    80004294:	2585                	addiw	a1,a1,1
    80004296:	028a2503          	lw	a0,40(s4)
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	cf6080e7          	jalr	-778(ra) # 80002f90 <bread>
    800042a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042a4:	000aa583          	lw	a1,0(s5)
    800042a8:	028a2503          	lw	a0,40(s4)
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	ce4080e7          	jalr	-796(ra) # 80002f90 <bread>
    800042b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042b6:	40000613          	li	a2,1024
    800042ba:	05850593          	addi	a1,a0,88
    800042be:	05848513          	addi	a0,s1,88
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	a7e080e7          	jalr	-1410(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800042ca:	8526                	mv	a0,s1
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	db6080e7          	jalr	-586(ra) # 80003082 <bwrite>
    brelse(from);
    800042d4:	854e                	mv	a0,s3
    800042d6:	fffff097          	auipc	ra,0xfffff
    800042da:	dea080e7          	jalr	-534(ra) # 800030c0 <brelse>
    brelse(to);
    800042de:	8526                	mv	a0,s1
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	de0080e7          	jalr	-544(ra) # 800030c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e8:	2905                	addiw	s2,s2,1
    800042ea:	0a91                	addi	s5,s5,4
    800042ec:	02ca2783          	lw	a5,44(s4)
    800042f0:	f8f94ee3          	blt	s2,a5,8000428c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042f4:	00000097          	auipc	ra,0x0
    800042f8:	c8c080e7          	jalr	-884(ra) # 80003f80 <write_head>
    install_trans(0); // Now install writes to home locations
    800042fc:	4501                	li	a0,0
    800042fe:	00000097          	auipc	ra,0x0
    80004302:	cec080e7          	jalr	-788(ra) # 80003fea <install_trans>
    log.lh.n = 0;
    80004306:	0001d797          	auipc	a5,0x1d
    8000430a:	8a07a323          	sw	zero,-1882(a5) # 80020bac <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000430e:	00000097          	auipc	ra,0x0
    80004312:	c72080e7          	jalr	-910(ra) # 80003f80 <write_head>
    80004316:	bdf5                	j	80004212 <end_op+0x52>

0000000080004318 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004318:	1101                	addi	sp,sp,-32
    8000431a:	ec06                	sd	ra,24(sp)
    8000431c:	e822                	sd	s0,16(sp)
    8000431e:	e426                	sd	s1,8(sp)
    80004320:	e04a                	sd	s2,0(sp)
    80004322:	1000                	addi	s0,sp,32
    80004324:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004326:	0001d917          	auipc	s2,0x1d
    8000432a:	85a90913          	addi	s2,s2,-1958 # 80020b80 <log>
    8000432e:	854a                	mv	a0,s2
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	8a2080e7          	jalr	-1886(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004338:	02c92603          	lw	a2,44(s2)
    8000433c:	47f5                	li	a5,29
    8000433e:	06c7c563          	blt	a5,a2,800043a8 <log_write+0x90>
    80004342:	0001d797          	auipc	a5,0x1d
    80004346:	85a7a783          	lw	a5,-1958(a5) # 80020b9c <log+0x1c>
    8000434a:	37fd                	addiw	a5,a5,-1
    8000434c:	04f65e63          	bge	a2,a5,800043a8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004350:	0001d797          	auipc	a5,0x1d
    80004354:	8507a783          	lw	a5,-1968(a5) # 80020ba0 <log+0x20>
    80004358:	06f05063          	blez	a5,800043b8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000435c:	4781                	li	a5,0
    8000435e:	06c05563          	blez	a2,800043c8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004362:	44cc                	lw	a1,12(s1)
    80004364:	0001d717          	auipc	a4,0x1d
    80004368:	84c70713          	addi	a4,a4,-1972 # 80020bb0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000436c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000436e:	4314                	lw	a3,0(a4)
    80004370:	04b68c63          	beq	a3,a1,800043c8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004374:	2785                	addiw	a5,a5,1
    80004376:	0711                	addi	a4,a4,4
    80004378:	fef61be3          	bne	a2,a5,8000436e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000437c:	0621                	addi	a2,a2,8
    8000437e:	060a                	slli	a2,a2,0x2
    80004380:	0001d797          	auipc	a5,0x1d
    80004384:	80078793          	addi	a5,a5,-2048 # 80020b80 <log>
    80004388:	97b2                	add	a5,a5,a2
    8000438a:	44d8                	lw	a4,12(s1)
    8000438c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000438e:	8526                	mv	a0,s1
    80004390:	fffff097          	auipc	ra,0xfffff
    80004394:	dcc080e7          	jalr	-564(ra) # 8000315c <bpin>
    log.lh.n++;
    80004398:	0001c717          	auipc	a4,0x1c
    8000439c:	7e870713          	addi	a4,a4,2024 # 80020b80 <log>
    800043a0:	575c                	lw	a5,44(a4)
    800043a2:	2785                	addiw	a5,a5,1
    800043a4:	d75c                	sw	a5,44(a4)
    800043a6:	a82d                	j	800043e0 <log_write+0xc8>
    panic("too big a transaction");
    800043a8:	00004517          	auipc	a0,0x4
    800043ac:	2e050513          	addi	a0,a0,736 # 80008688 <syscalls+0x220>
    800043b0:	ffffc097          	auipc	ra,0xffffc
    800043b4:	18c080e7          	jalr	396(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800043b8:	00004517          	auipc	a0,0x4
    800043bc:	2e850513          	addi	a0,a0,744 # 800086a0 <syscalls+0x238>
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	17c080e7          	jalr	380(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043c8:	00878693          	addi	a3,a5,8
    800043cc:	068a                	slli	a3,a3,0x2
    800043ce:	0001c717          	auipc	a4,0x1c
    800043d2:	7b270713          	addi	a4,a4,1970 # 80020b80 <log>
    800043d6:	9736                	add	a4,a4,a3
    800043d8:	44d4                	lw	a3,12(s1)
    800043da:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043dc:	faf609e3          	beq	a2,a5,8000438e <log_write+0x76>
  }
  release(&log.lock);
    800043e0:	0001c517          	auipc	a0,0x1c
    800043e4:	7a050513          	addi	a0,a0,1952 # 80020b80 <log>
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	8b4080e7          	jalr	-1868(ra) # 80000c9c <release>
}
    800043f0:	60e2                	ld	ra,24(sp)
    800043f2:	6442                	ld	s0,16(sp)
    800043f4:	64a2                	ld	s1,8(sp)
    800043f6:	6902                	ld	s2,0(sp)
    800043f8:	6105                	addi	sp,sp,32
    800043fa:	8082                	ret

00000000800043fc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043fc:	1101                	addi	sp,sp,-32
    800043fe:	ec06                	sd	ra,24(sp)
    80004400:	e822                	sd	s0,16(sp)
    80004402:	e426                	sd	s1,8(sp)
    80004404:	e04a                	sd	s2,0(sp)
    80004406:	1000                	addi	s0,sp,32
    80004408:	84aa                	mv	s1,a0
    8000440a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000440c:	00004597          	auipc	a1,0x4
    80004410:	2b458593          	addi	a1,a1,692 # 800086c0 <syscalls+0x258>
    80004414:	0521                	addi	a0,a0,8
    80004416:	ffffc097          	auipc	ra,0xffffc
    8000441a:	72c080e7          	jalr	1836(ra) # 80000b42 <initlock>
  lk->name = name;
    8000441e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004422:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004426:	0204a423          	sw	zero,40(s1)
}
    8000442a:	60e2                	ld	ra,24(sp)
    8000442c:	6442                	ld	s0,16(sp)
    8000442e:	64a2                	ld	s1,8(sp)
    80004430:	6902                	ld	s2,0(sp)
    80004432:	6105                	addi	sp,sp,32
    80004434:	8082                	ret

0000000080004436 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004436:	1101                	addi	sp,sp,-32
    80004438:	ec06                	sd	ra,24(sp)
    8000443a:	e822                	sd	s0,16(sp)
    8000443c:	e426                	sd	s1,8(sp)
    8000443e:	e04a                	sd	s2,0(sp)
    80004440:	1000                	addi	s0,sp,32
    80004442:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004444:	00850913          	addi	s2,a0,8
    80004448:	854a                	mv	a0,s2
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	788080e7          	jalr	1928(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004452:	409c                	lw	a5,0(s1)
    80004454:	cb89                	beqz	a5,80004466 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004456:	85ca                	mv	a1,s2
    80004458:	8526                	mv	a0,s1
    8000445a:	ffffe097          	auipc	ra,0xffffe
    8000445e:	c86080e7          	jalr	-890(ra) # 800020e0 <sleep>
  while (lk->locked) {
    80004462:	409c                	lw	a5,0(s1)
    80004464:	fbed                	bnez	a5,80004456 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004466:	4785                	li	a5,1
    80004468:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	552080e7          	jalr	1362(ra) # 800019bc <myproc>
    80004472:	591c                	lw	a5,48(a0)
    80004474:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004476:	854a                	mv	a0,s2
    80004478:	ffffd097          	auipc	ra,0xffffd
    8000447c:	824080e7          	jalr	-2012(ra) # 80000c9c <release>
}
    80004480:	60e2                	ld	ra,24(sp)
    80004482:	6442                	ld	s0,16(sp)
    80004484:	64a2                	ld	s1,8(sp)
    80004486:	6902                	ld	s2,0(sp)
    80004488:	6105                	addi	sp,sp,32
    8000448a:	8082                	ret

000000008000448c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000448c:	1101                	addi	sp,sp,-32
    8000448e:	ec06                	sd	ra,24(sp)
    80004490:	e822                	sd	s0,16(sp)
    80004492:	e426                	sd	s1,8(sp)
    80004494:	e04a                	sd	s2,0(sp)
    80004496:	1000                	addi	s0,sp,32
    80004498:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000449a:	00850913          	addi	s2,a0,8
    8000449e:	854a                	mv	a0,s2
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	732080e7          	jalr	1842(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800044a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044ac:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044b0:	8526                	mv	a0,s1
    800044b2:	ffffe097          	auipc	ra,0xffffe
    800044b6:	c92080e7          	jalr	-878(ra) # 80002144 <wakeup>
  release(&lk->lk);
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	7e0080e7          	jalr	2016(ra) # 80000c9c <release>
}
    800044c4:	60e2                	ld	ra,24(sp)
    800044c6:	6442                	ld	s0,16(sp)
    800044c8:	64a2                	ld	s1,8(sp)
    800044ca:	6902                	ld	s2,0(sp)
    800044cc:	6105                	addi	sp,sp,32
    800044ce:	8082                	ret

00000000800044d0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044d0:	7179                	addi	sp,sp,-48
    800044d2:	f406                	sd	ra,40(sp)
    800044d4:	f022                	sd	s0,32(sp)
    800044d6:	ec26                	sd	s1,24(sp)
    800044d8:	e84a                	sd	s2,16(sp)
    800044da:	e44e                	sd	s3,8(sp)
    800044dc:	1800                	addi	s0,sp,48
    800044de:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044e0:	00850913          	addi	s2,a0,8
    800044e4:	854a                	mv	a0,s2
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	6ec080e7          	jalr	1772(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ee:	409c                	lw	a5,0(s1)
    800044f0:	ef99                	bnez	a5,8000450e <holdingsleep+0x3e>
    800044f2:	4481                	li	s1,0
  release(&lk->lk);
    800044f4:	854a                	mv	a0,s2
    800044f6:	ffffc097          	auipc	ra,0xffffc
    800044fa:	7a6080e7          	jalr	1958(ra) # 80000c9c <release>
  return r;
}
    800044fe:	8526                	mv	a0,s1
    80004500:	70a2                	ld	ra,40(sp)
    80004502:	7402                	ld	s0,32(sp)
    80004504:	64e2                	ld	s1,24(sp)
    80004506:	6942                	ld	s2,16(sp)
    80004508:	69a2                	ld	s3,8(sp)
    8000450a:	6145                	addi	sp,sp,48
    8000450c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000450e:	0284a983          	lw	s3,40(s1)
    80004512:	ffffd097          	auipc	ra,0xffffd
    80004516:	4aa080e7          	jalr	1194(ra) # 800019bc <myproc>
    8000451a:	5904                	lw	s1,48(a0)
    8000451c:	413484b3          	sub	s1,s1,s3
    80004520:	0014b493          	seqz	s1,s1
    80004524:	bfc1                	j	800044f4 <holdingsleep+0x24>

0000000080004526 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004526:	1141                	addi	sp,sp,-16
    80004528:	e406                	sd	ra,8(sp)
    8000452a:	e022                	sd	s0,0(sp)
    8000452c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000452e:	00004597          	auipc	a1,0x4
    80004532:	1a258593          	addi	a1,a1,418 # 800086d0 <syscalls+0x268>
    80004536:	0001c517          	auipc	a0,0x1c
    8000453a:	79250513          	addi	a0,a0,1938 # 80020cc8 <ftable>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	604080e7          	jalr	1540(ra) # 80000b42 <initlock>
}
    80004546:	60a2                	ld	ra,8(sp)
    80004548:	6402                	ld	s0,0(sp)
    8000454a:	0141                	addi	sp,sp,16
    8000454c:	8082                	ret

000000008000454e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000454e:	1101                	addi	sp,sp,-32
    80004550:	ec06                	sd	ra,24(sp)
    80004552:	e822                	sd	s0,16(sp)
    80004554:	e426                	sd	s1,8(sp)
    80004556:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004558:	0001c517          	auipc	a0,0x1c
    8000455c:	77050513          	addi	a0,a0,1904 # 80020cc8 <ftable>
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	672080e7          	jalr	1650(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004568:	0001c497          	auipc	s1,0x1c
    8000456c:	77848493          	addi	s1,s1,1912 # 80020ce0 <ftable+0x18>
    80004570:	0001d717          	auipc	a4,0x1d
    80004574:	71070713          	addi	a4,a4,1808 # 80021c80 <disk>
    if(f->ref == 0){
    80004578:	40dc                	lw	a5,4(s1)
    8000457a:	cf99                	beqz	a5,80004598 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000457c:	02848493          	addi	s1,s1,40
    80004580:	fee49ce3          	bne	s1,a4,80004578 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004584:	0001c517          	auipc	a0,0x1c
    80004588:	74450513          	addi	a0,a0,1860 # 80020cc8 <ftable>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	710080e7          	jalr	1808(ra) # 80000c9c <release>
  return 0;
    80004594:	4481                	li	s1,0
    80004596:	a819                	j	800045ac <filealloc+0x5e>
      f->ref = 1;
    80004598:	4785                	li	a5,1
    8000459a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000459c:	0001c517          	auipc	a0,0x1c
    800045a0:	72c50513          	addi	a0,a0,1836 # 80020cc8 <ftable>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	6f8080e7          	jalr	1784(ra) # 80000c9c <release>
}
    800045ac:	8526                	mv	a0,s1
    800045ae:	60e2                	ld	ra,24(sp)
    800045b0:	6442                	ld	s0,16(sp)
    800045b2:	64a2                	ld	s1,8(sp)
    800045b4:	6105                	addi	sp,sp,32
    800045b6:	8082                	ret

00000000800045b8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045b8:	1101                	addi	sp,sp,-32
    800045ba:	ec06                	sd	ra,24(sp)
    800045bc:	e822                	sd	s0,16(sp)
    800045be:	e426                	sd	s1,8(sp)
    800045c0:	1000                	addi	s0,sp,32
    800045c2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045c4:	0001c517          	auipc	a0,0x1c
    800045c8:	70450513          	addi	a0,a0,1796 # 80020cc8 <ftable>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	606080e7          	jalr	1542(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045d4:	40dc                	lw	a5,4(s1)
    800045d6:	02f05263          	blez	a5,800045fa <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045da:	2785                	addiw	a5,a5,1
    800045dc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045de:	0001c517          	auipc	a0,0x1c
    800045e2:	6ea50513          	addi	a0,a0,1770 # 80020cc8 <ftable>
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	6b6080e7          	jalr	1718(ra) # 80000c9c <release>
  return f;
}
    800045ee:	8526                	mv	a0,s1
    800045f0:	60e2                	ld	ra,24(sp)
    800045f2:	6442                	ld	s0,16(sp)
    800045f4:	64a2                	ld	s1,8(sp)
    800045f6:	6105                	addi	sp,sp,32
    800045f8:	8082                	ret
    panic("filedup");
    800045fa:	00004517          	auipc	a0,0x4
    800045fe:	0de50513          	addi	a0,a0,222 # 800086d8 <syscalls+0x270>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	f3a080e7          	jalr	-198(ra) # 8000053c <panic>

000000008000460a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000460a:	7139                	addi	sp,sp,-64
    8000460c:	fc06                	sd	ra,56(sp)
    8000460e:	f822                	sd	s0,48(sp)
    80004610:	f426                	sd	s1,40(sp)
    80004612:	f04a                	sd	s2,32(sp)
    80004614:	ec4e                	sd	s3,24(sp)
    80004616:	e852                	sd	s4,16(sp)
    80004618:	e456                	sd	s5,8(sp)
    8000461a:	0080                	addi	s0,sp,64
    8000461c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000461e:	0001c517          	auipc	a0,0x1c
    80004622:	6aa50513          	addi	a0,a0,1706 # 80020cc8 <ftable>
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	5ac080e7          	jalr	1452(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000462e:	40dc                	lw	a5,4(s1)
    80004630:	06f05163          	blez	a5,80004692 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004634:	37fd                	addiw	a5,a5,-1
    80004636:	0007871b          	sext.w	a4,a5
    8000463a:	c0dc                	sw	a5,4(s1)
    8000463c:	06e04363          	bgtz	a4,800046a2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004640:	0004a903          	lw	s2,0(s1)
    80004644:	0094ca83          	lbu	s5,9(s1)
    80004648:	0104ba03          	ld	s4,16(s1)
    8000464c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004650:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004654:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004658:	0001c517          	auipc	a0,0x1c
    8000465c:	67050513          	addi	a0,a0,1648 # 80020cc8 <ftable>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	63c080e7          	jalr	1596(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    80004668:	4785                	li	a5,1
    8000466a:	04f90d63          	beq	s2,a5,800046c4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000466e:	3979                	addiw	s2,s2,-2
    80004670:	4785                	li	a5,1
    80004672:	0527e063          	bltu	a5,s2,800046b2 <fileclose+0xa8>
    begin_op();
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	ad0080e7          	jalr	-1328(ra) # 80004146 <begin_op>
    iput(ff.ip);
    8000467e:	854e                	mv	a0,s3
    80004680:	fffff097          	auipc	ra,0xfffff
    80004684:	2da080e7          	jalr	730(ra) # 8000395a <iput>
    end_op();
    80004688:	00000097          	auipc	ra,0x0
    8000468c:	b38080e7          	jalr	-1224(ra) # 800041c0 <end_op>
    80004690:	a00d                	j	800046b2 <fileclose+0xa8>
    panic("fileclose");
    80004692:	00004517          	auipc	a0,0x4
    80004696:	04e50513          	addi	a0,a0,78 # 800086e0 <syscalls+0x278>
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	ea2080e7          	jalr	-350(ra) # 8000053c <panic>
    release(&ftable.lock);
    800046a2:	0001c517          	auipc	a0,0x1c
    800046a6:	62650513          	addi	a0,a0,1574 # 80020cc8 <ftable>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	5f2080e7          	jalr	1522(ra) # 80000c9c <release>
  }
}
    800046b2:	70e2                	ld	ra,56(sp)
    800046b4:	7442                	ld	s0,48(sp)
    800046b6:	74a2                	ld	s1,40(sp)
    800046b8:	7902                	ld	s2,32(sp)
    800046ba:	69e2                	ld	s3,24(sp)
    800046bc:	6a42                	ld	s4,16(sp)
    800046be:	6aa2                	ld	s5,8(sp)
    800046c0:	6121                	addi	sp,sp,64
    800046c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046c4:	85d6                	mv	a1,s5
    800046c6:	8552                	mv	a0,s4
    800046c8:	00000097          	auipc	ra,0x0
    800046cc:	348080e7          	jalr	840(ra) # 80004a10 <pipeclose>
    800046d0:	b7cd                	j	800046b2 <fileclose+0xa8>

00000000800046d2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046d2:	715d                	addi	sp,sp,-80
    800046d4:	e486                	sd	ra,72(sp)
    800046d6:	e0a2                	sd	s0,64(sp)
    800046d8:	fc26                	sd	s1,56(sp)
    800046da:	f84a                	sd	s2,48(sp)
    800046dc:	f44e                	sd	s3,40(sp)
    800046de:	0880                	addi	s0,sp,80
    800046e0:	84aa                	mv	s1,a0
    800046e2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046e4:	ffffd097          	auipc	ra,0xffffd
    800046e8:	2d8080e7          	jalr	728(ra) # 800019bc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046ec:	409c                	lw	a5,0(s1)
    800046ee:	37f9                	addiw	a5,a5,-2
    800046f0:	4705                	li	a4,1
    800046f2:	04f76763          	bltu	a4,a5,80004740 <filestat+0x6e>
    800046f6:	892a                	mv	s2,a0
    ilock(f->ip);
    800046f8:	6c88                	ld	a0,24(s1)
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	0a6080e7          	jalr	166(ra) # 800037a0 <ilock>
    stati(f->ip, &st);
    80004702:	fb840593          	addi	a1,s0,-72
    80004706:	6c88                	ld	a0,24(s1)
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	322080e7          	jalr	802(ra) # 80003a2a <stati>
    iunlock(f->ip);
    80004710:	6c88                	ld	a0,24(s1)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	150080e7          	jalr	336(ra) # 80003862 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000471a:	46e1                	li	a3,24
    8000471c:	fb840613          	addi	a2,s0,-72
    80004720:	85ce                	mv	a1,s3
    80004722:	05093503          	ld	a0,80(s2)
    80004726:	ffffd097          	auipc	ra,0xffffd
    8000472a:	f56080e7          	jalr	-170(ra) # 8000167c <copyout>
    8000472e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004732:	60a6                	ld	ra,72(sp)
    80004734:	6406                	ld	s0,64(sp)
    80004736:	74e2                	ld	s1,56(sp)
    80004738:	7942                	ld	s2,48(sp)
    8000473a:	79a2                	ld	s3,40(sp)
    8000473c:	6161                	addi	sp,sp,80
    8000473e:	8082                	ret
  return -1;
    80004740:	557d                	li	a0,-1
    80004742:	bfc5                	j	80004732 <filestat+0x60>

0000000080004744 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004744:	7179                	addi	sp,sp,-48
    80004746:	f406                	sd	ra,40(sp)
    80004748:	f022                	sd	s0,32(sp)
    8000474a:	ec26                	sd	s1,24(sp)
    8000474c:	e84a                	sd	s2,16(sp)
    8000474e:	e44e                	sd	s3,8(sp)
    80004750:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004752:	00854783          	lbu	a5,8(a0)
    80004756:	c3d5                	beqz	a5,800047fa <fileread+0xb6>
    80004758:	84aa                	mv	s1,a0
    8000475a:	89ae                	mv	s3,a1
    8000475c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000475e:	411c                	lw	a5,0(a0)
    80004760:	4705                	li	a4,1
    80004762:	04e78963          	beq	a5,a4,800047b4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004766:	470d                	li	a4,3
    80004768:	04e78d63          	beq	a5,a4,800047c2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000476c:	4709                	li	a4,2
    8000476e:	06e79e63          	bne	a5,a4,800047ea <fileread+0xa6>
    ilock(f->ip);
    80004772:	6d08                	ld	a0,24(a0)
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	02c080e7          	jalr	44(ra) # 800037a0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000477c:	874a                	mv	a4,s2
    8000477e:	5094                	lw	a3,32(s1)
    80004780:	864e                	mv	a2,s3
    80004782:	4585                	li	a1,1
    80004784:	6c88                	ld	a0,24(s1)
    80004786:	fffff097          	auipc	ra,0xfffff
    8000478a:	2ce080e7          	jalr	718(ra) # 80003a54 <readi>
    8000478e:	892a                	mv	s2,a0
    80004790:	00a05563          	blez	a0,8000479a <fileread+0x56>
      f->off += r;
    80004794:	509c                	lw	a5,32(s1)
    80004796:	9fa9                	addw	a5,a5,a0
    80004798:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000479a:	6c88                	ld	a0,24(s1)
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	0c6080e7          	jalr	198(ra) # 80003862 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047a4:	854a                	mv	a0,s2
    800047a6:	70a2                	ld	ra,40(sp)
    800047a8:	7402                	ld	s0,32(sp)
    800047aa:	64e2                	ld	s1,24(sp)
    800047ac:	6942                	ld	s2,16(sp)
    800047ae:	69a2                	ld	s3,8(sp)
    800047b0:	6145                	addi	sp,sp,48
    800047b2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047b4:	6908                	ld	a0,16(a0)
    800047b6:	00000097          	auipc	ra,0x0
    800047ba:	3c2080e7          	jalr	962(ra) # 80004b78 <piperead>
    800047be:	892a                	mv	s2,a0
    800047c0:	b7d5                	j	800047a4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047c2:	02451783          	lh	a5,36(a0)
    800047c6:	03079693          	slli	a3,a5,0x30
    800047ca:	92c1                	srli	a3,a3,0x30
    800047cc:	4725                	li	a4,9
    800047ce:	02d76863          	bltu	a4,a3,800047fe <fileread+0xba>
    800047d2:	0792                	slli	a5,a5,0x4
    800047d4:	0001c717          	auipc	a4,0x1c
    800047d8:	45470713          	addi	a4,a4,1108 # 80020c28 <devsw>
    800047dc:	97ba                	add	a5,a5,a4
    800047de:	639c                	ld	a5,0(a5)
    800047e0:	c38d                	beqz	a5,80004802 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047e2:	4505                	li	a0,1
    800047e4:	9782                	jalr	a5
    800047e6:	892a                	mv	s2,a0
    800047e8:	bf75                	j	800047a4 <fileread+0x60>
    panic("fileread");
    800047ea:	00004517          	auipc	a0,0x4
    800047ee:	f0650513          	addi	a0,a0,-250 # 800086f0 <syscalls+0x288>
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	d4a080e7          	jalr	-694(ra) # 8000053c <panic>
    return -1;
    800047fa:	597d                	li	s2,-1
    800047fc:	b765                	j	800047a4 <fileread+0x60>
      return -1;
    800047fe:	597d                	li	s2,-1
    80004800:	b755                	j	800047a4 <fileread+0x60>
    80004802:	597d                	li	s2,-1
    80004804:	b745                	j	800047a4 <fileread+0x60>

0000000080004806 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004806:	00954783          	lbu	a5,9(a0)
    8000480a:	10078e63          	beqz	a5,80004926 <filewrite+0x120>
{
    8000480e:	715d                	addi	sp,sp,-80
    80004810:	e486                	sd	ra,72(sp)
    80004812:	e0a2                	sd	s0,64(sp)
    80004814:	fc26                	sd	s1,56(sp)
    80004816:	f84a                	sd	s2,48(sp)
    80004818:	f44e                	sd	s3,40(sp)
    8000481a:	f052                	sd	s4,32(sp)
    8000481c:	ec56                	sd	s5,24(sp)
    8000481e:	e85a                	sd	s6,16(sp)
    80004820:	e45e                	sd	s7,8(sp)
    80004822:	e062                	sd	s8,0(sp)
    80004824:	0880                	addi	s0,sp,80
    80004826:	892a                	mv	s2,a0
    80004828:	8b2e                	mv	s6,a1
    8000482a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000482c:	411c                	lw	a5,0(a0)
    8000482e:	4705                	li	a4,1
    80004830:	02e78263          	beq	a5,a4,80004854 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004834:	470d                	li	a4,3
    80004836:	02e78563          	beq	a5,a4,80004860 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000483a:	4709                	li	a4,2
    8000483c:	0ce79d63          	bne	a5,a4,80004916 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004840:	0ac05b63          	blez	a2,800048f6 <filewrite+0xf0>
    int i = 0;
    80004844:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004846:	6b85                	lui	s7,0x1
    80004848:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000484c:	6c05                	lui	s8,0x1
    8000484e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004852:	a851                	j	800048e6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004854:	6908                	ld	a0,16(a0)
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	22a080e7          	jalr	554(ra) # 80004a80 <pipewrite>
    8000485e:	a045                	j	800048fe <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004860:	02451783          	lh	a5,36(a0)
    80004864:	03079693          	slli	a3,a5,0x30
    80004868:	92c1                	srli	a3,a3,0x30
    8000486a:	4725                	li	a4,9
    8000486c:	0ad76f63          	bltu	a4,a3,8000492a <filewrite+0x124>
    80004870:	0792                	slli	a5,a5,0x4
    80004872:	0001c717          	auipc	a4,0x1c
    80004876:	3b670713          	addi	a4,a4,950 # 80020c28 <devsw>
    8000487a:	97ba                	add	a5,a5,a4
    8000487c:	679c                	ld	a5,8(a5)
    8000487e:	cbc5                	beqz	a5,8000492e <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004880:	4505                	li	a0,1
    80004882:	9782                	jalr	a5
    80004884:	a8ad                	j	800048fe <filewrite+0xf8>
      if(n1 > max)
    80004886:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000488a:	00000097          	auipc	ra,0x0
    8000488e:	8bc080e7          	jalr	-1860(ra) # 80004146 <begin_op>
      ilock(f->ip);
    80004892:	01893503          	ld	a0,24(s2)
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	f0a080e7          	jalr	-246(ra) # 800037a0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000489e:	8756                	mv	a4,s5
    800048a0:	02092683          	lw	a3,32(s2)
    800048a4:	01698633          	add	a2,s3,s6
    800048a8:	4585                	li	a1,1
    800048aa:	01893503          	ld	a0,24(s2)
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	29e080e7          	jalr	670(ra) # 80003b4c <writei>
    800048b6:	84aa                	mv	s1,a0
    800048b8:	00a05763          	blez	a0,800048c6 <filewrite+0xc0>
        f->off += r;
    800048bc:	02092783          	lw	a5,32(s2)
    800048c0:	9fa9                	addw	a5,a5,a0
    800048c2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048c6:	01893503          	ld	a0,24(s2)
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	f98080e7          	jalr	-104(ra) # 80003862 <iunlock>
      end_op();
    800048d2:	00000097          	auipc	ra,0x0
    800048d6:	8ee080e7          	jalr	-1810(ra) # 800041c0 <end_op>

      if(r != n1){
    800048da:	009a9f63          	bne	s5,s1,800048f8 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048de:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048e2:	0149db63          	bge	s3,s4,800048f8 <filewrite+0xf2>
      int n1 = n - i;
    800048e6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048ea:	0004879b          	sext.w	a5,s1
    800048ee:	f8fbdce3          	bge	s7,a5,80004886 <filewrite+0x80>
    800048f2:	84e2                	mv	s1,s8
    800048f4:	bf49                	j	80004886 <filewrite+0x80>
    int i = 0;
    800048f6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048f8:	033a1d63          	bne	s4,s3,80004932 <filewrite+0x12c>
    800048fc:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048fe:	60a6                	ld	ra,72(sp)
    80004900:	6406                	ld	s0,64(sp)
    80004902:	74e2                	ld	s1,56(sp)
    80004904:	7942                	ld	s2,48(sp)
    80004906:	79a2                	ld	s3,40(sp)
    80004908:	7a02                	ld	s4,32(sp)
    8000490a:	6ae2                	ld	s5,24(sp)
    8000490c:	6b42                	ld	s6,16(sp)
    8000490e:	6ba2                	ld	s7,8(sp)
    80004910:	6c02                	ld	s8,0(sp)
    80004912:	6161                	addi	sp,sp,80
    80004914:	8082                	ret
    panic("filewrite");
    80004916:	00004517          	auipc	a0,0x4
    8000491a:	dea50513          	addi	a0,a0,-534 # 80008700 <syscalls+0x298>
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	c1e080e7          	jalr	-994(ra) # 8000053c <panic>
    return -1;
    80004926:	557d                	li	a0,-1
}
    80004928:	8082                	ret
      return -1;
    8000492a:	557d                	li	a0,-1
    8000492c:	bfc9                	j	800048fe <filewrite+0xf8>
    8000492e:	557d                	li	a0,-1
    80004930:	b7f9                	j	800048fe <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004932:	557d                	li	a0,-1
    80004934:	b7e9                	j	800048fe <filewrite+0xf8>

0000000080004936 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004936:	7179                	addi	sp,sp,-48
    80004938:	f406                	sd	ra,40(sp)
    8000493a:	f022                	sd	s0,32(sp)
    8000493c:	ec26                	sd	s1,24(sp)
    8000493e:	e84a                	sd	s2,16(sp)
    80004940:	e44e                	sd	s3,8(sp)
    80004942:	e052                	sd	s4,0(sp)
    80004944:	1800                	addi	s0,sp,48
    80004946:	84aa                	mv	s1,a0
    80004948:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000494a:	0005b023          	sd	zero,0(a1)
    8000494e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004952:	00000097          	auipc	ra,0x0
    80004956:	bfc080e7          	jalr	-1028(ra) # 8000454e <filealloc>
    8000495a:	e088                	sd	a0,0(s1)
    8000495c:	c551                	beqz	a0,800049e8 <pipealloc+0xb2>
    8000495e:	00000097          	auipc	ra,0x0
    80004962:	bf0080e7          	jalr	-1040(ra) # 8000454e <filealloc>
    80004966:	00aa3023          	sd	a0,0(s4)
    8000496a:	c92d                	beqz	a0,800049dc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	176080e7          	jalr	374(ra) # 80000ae2 <kalloc>
    80004974:	892a                	mv	s2,a0
    80004976:	c125                	beqz	a0,800049d6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004978:	4985                	li	s3,1
    8000497a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000497e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004982:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004986:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000498a:	00004597          	auipc	a1,0x4
    8000498e:	d8658593          	addi	a1,a1,-634 # 80008710 <syscalls+0x2a8>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	1b0080e7          	jalr	432(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    8000499a:	609c                	ld	a5,0(s1)
    8000499c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049a0:	609c                	ld	a5,0(s1)
    800049a2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049a6:	609c                	ld	a5,0(s1)
    800049a8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049ac:	609c                	ld	a5,0(s1)
    800049ae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049b2:	000a3783          	ld	a5,0(s4)
    800049b6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049ba:	000a3783          	ld	a5,0(s4)
    800049be:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049c2:	000a3783          	ld	a5,0(s4)
    800049c6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049ca:	000a3783          	ld	a5,0(s4)
    800049ce:	0127b823          	sd	s2,16(a5)
  return 0;
    800049d2:	4501                	li	a0,0
    800049d4:	a025                	j	800049fc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049d6:	6088                	ld	a0,0(s1)
    800049d8:	e501                	bnez	a0,800049e0 <pipealloc+0xaa>
    800049da:	a039                	j	800049e8 <pipealloc+0xb2>
    800049dc:	6088                	ld	a0,0(s1)
    800049de:	c51d                	beqz	a0,80004a0c <pipealloc+0xd6>
    fileclose(*f0);
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	c2a080e7          	jalr	-982(ra) # 8000460a <fileclose>
  if(*f1)
    800049e8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049ec:	557d                	li	a0,-1
  if(*f1)
    800049ee:	c799                	beqz	a5,800049fc <pipealloc+0xc6>
    fileclose(*f1);
    800049f0:	853e                	mv	a0,a5
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	c18080e7          	jalr	-1000(ra) # 8000460a <fileclose>
  return -1;
    800049fa:	557d                	li	a0,-1
}
    800049fc:	70a2                	ld	ra,40(sp)
    800049fe:	7402                	ld	s0,32(sp)
    80004a00:	64e2                	ld	s1,24(sp)
    80004a02:	6942                	ld	s2,16(sp)
    80004a04:	69a2                	ld	s3,8(sp)
    80004a06:	6a02                	ld	s4,0(sp)
    80004a08:	6145                	addi	sp,sp,48
    80004a0a:	8082                	ret
  return -1;
    80004a0c:	557d                	li	a0,-1
    80004a0e:	b7fd                	j	800049fc <pipealloc+0xc6>

0000000080004a10 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	e426                	sd	s1,8(sp)
    80004a18:	e04a                	sd	s2,0(sp)
    80004a1a:	1000                	addi	s0,sp,32
    80004a1c:	84aa                	mv	s1,a0
    80004a1e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	1b2080e7          	jalr	434(ra) # 80000bd2 <acquire>
  if(writable){
    80004a28:	02090d63          	beqz	s2,80004a62 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a2c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a30:	21848513          	addi	a0,s1,536
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	710080e7          	jalr	1808(ra) # 80002144 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a3c:	2204b783          	ld	a5,544(s1)
    80004a40:	eb95                	bnez	a5,80004a74 <pipeclose+0x64>
    release(&pi->lock);
    80004a42:	8526                	mv	a0,s1
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	258080e7          	jalr	600(ra) # 80000c9c <release>
    kfree((char*)pi);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	f96080e7          	jalr	-106(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a56:	60e2                	ld	ra,24(sp)
    80004a58:	6442                	ld	s0,16(sp)
    80004a5a:	64a2                	ld	s1,8(sp)
    80004a5c:	6902                	ld	s2,0(sp)
    80004a5e:	6105                	addi	sp,sp,32
    80004a60:	8082                	ret
    pi->readopen = 0;
    80004a62:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a66:	21c48513          	addi	a0,s1,540
    80004a6a:	ffffd097          	auipc	ra,0xffffd
    80004a6e:	6da080e7          	jalr	1754(ra) # 80002144 <wakeup>
    80004a72:	b7e9                	j	80004a3c <pipeclose+0x2c>
    release(&pi->lock);
    80004a74:	8526                	mv	a0,s1
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	226080e7          	jalr	550(ra) # 80000c9c <release>
}
    80004a7e:	bfe1                	j	80004a56 <pipeclose+0x46>

0000000080004a80 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a80:	711d                	addi	sp,sp,-96
    80004a82:	ec86                	sd	ra,88(sp)
    80004a84:	e8a2                	sd	s0,80(sp)
    80004a86:	e4a6                	sd	s1,72(sp)
    80004a88:	e0ca                	sd	s2,64(sp)
    80004a8a:	fc4e                	sd	s3,56(sp)
    80004a8c:	f852                	sd	s4,48(sp)
    80004a8e:	f456                	sd	s5,40(sp)
    80004a90:	f05a                	sd	s6,32(sp)
    80004a92:	ec5e                	sd	s7,24(sp)
    80004a94:	e862                	sd	s8,16(sp)
    80004a96:	1080                	addi	s0,sp,96
    80004a98:	84aa                	mv	s1,a0
    80004a9a:	8aae                	mv	s5,a1
    80004a9c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	f1e080e7          	jalr	-226(ra) # 800019bc <myproc>
    80004aa6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	128080e7          	jalr	296(ra) # 80000bd2 <acquire>
  while(i < n){
    80004ab2:	0b405663          	blez	s4,80004b5e <pipewrite+0xde>
  int i = 0;
    80004ab6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ab8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004aba:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004abe:	21c48b93          	addi	s7,s1,540
    80004ac2:	a089                	j	80004b04 <pipewrite+0x84>
      release(&pi->lock);
    80004ac4:	8526                	mv	a0,s1
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	1d6080e7          	jalr	470(ra) # 80000c9c <release>
      return -1;
    80004ace:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ad0:	854a                	mv	a0,s2
    80004ad2:	60e6                	ld	ra,88(sp)
    80004ad4:	6446                	ld	s0,80(sp)
    80004ad6:	64a6                	ld	s1,72(sp)
    80004ad8:	6906                	ld	s2,64(sp)
    80004ada:	79e2                	ld	s3,56(sp)
    80004adc:	7a42                	ld	s4,48(sp)
    80004ade:	7aa2                	ld	s5,40(sp)
    80004ae0:	7b02                	ld	s6,32(sp)
    80004ae2:	6be2                	ld	s7,24(sp)
    80004ae4:	6c42                	ld	s8,16(sp)
    80004ae6:	6125                	addi	sp,sp,96
    80004ae8:	8082                	ret
      wakeup(&pi->nread);
    80004aea:	8562                	mv	a0,s8
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	658080e7          	jalr	1624(ra) # 80002144 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004af4:	85a6                	mv	a1,s1
    80004af6:	855e                	mv	a0,s7
    80004af8:	ffffd097          	auipc	ra,0xffffd
    80004afc:	5e8080e7          	jalr	1512(ra) # 800020e0 <sleep>
  while(i < n){
    80004b00:	07495063          	bge	s2,s4,80004b60 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004b04:	2204a783          	lw	a5,544(s1)
    80004b08:	dfd5                	beqz	a5,80004ac4 <pipewrite+0x44>
    80004b0a:	854e                	mv	a0,s3
    80004b0c:	ffffe097          	auipc	ra,0xffffe
    80004b10:	87c080e7          	jalr	-1924(ra) # 80002388 <killed>
    80004b14:	f945                	bnez	a0,80004ac4 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b16:	2184a783          	lw	a5,536(s1)
    80004b1a:	21c4a703          	lw	a4,540(s1)
    80004b1e:	2007879b          	addiw	a5,a5,512
    80004b22:	fcf704e3          	beq	a4,a5,80004aea <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b26:	4685                	li	a3,1
    80004b28:	01590633          	add	a2,s2,s5
    80004b2c:	faf40593          	addi	a1,s0,-81
    80004b30:	0509b503          	ld	a0,80(s3)
    80004b34:	ffffd097          	auipc	ra,0xffffd
    80004b38:	bd4080e7          	jalr	-1068(ra) # 80001708 <copyin>
    80004b3c:	03650263          	beq	a0,s6,80004b60 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b40:	21c4a783          	lw	a5,540(s1)
    80004b44:	0017871b          	addiw	a4,a5,1
    80004b48:	20e4ae23          	sw	a4,540(s1)
    80004b4c:	1ff7f793          	andi	a5,a5,511
    80004b50:	97a6                	add	a5,a5,s1
    80004b52:	faf44703          	lbu	a4,-81(s0)
    80004b56:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b5a:	2905                	addiw	s2,s2,1
    80004b5c:	b755                	j	80004b00 <pipewrite+0x80>
  int i = 0;
    80004b5e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b60:	21848513          	addi	a0,s1,536
    80004b64:	ffffd097          	auipc	ra,0xffffd
    80004b68:	5e0080e7          	jalr	1504(ra) # 80002144 <wakeup>
  release(&pi->lock);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	12e080e7          	jalr	302(ra) # 80000c9c <release>
  return i;
    80004b76:	bfa9                	j	80004ad0 <pipewrite+0x50>

0000000080004b78 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b78:	715d                	addi	sp,sp,-80
    80004b7a:	e486                	sd	ra,72(sp)
    80004b7c:	e0a2                	sd	s0,64(sp)
    80004b7e:	fc26                	sd	s1,56(sp)
    80004b80:	f84a                	sd	s2,48(sp)
    80004b82:	f44e                	sd	s3,40(sp)
    80004b84:	f052                	sd	s4,32(sp)
    80004b86:	ec56                	sd	s5,24(sp)
    80004b88:	e85a                	sd	s6,16(sp)
    80004b8a:	0880                	addi	s0,sp,80
    80004b8c:	84aa                	mv	s1,a0
    80004b8e:	892e                	mv	s2,a1
    80004b90:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b92:	ffffd097          	auipc	ra,0xffffd
    80004b96:	e2a080e7          	jalr	-470(ra) # 800019bc <myproc>
    80004b9a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	ffffc097          	auipc	ra,0xffffc
    80004ba2:	034080e7          	jalr	52(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ba6:	2184a703          	lw	a4,536(s1)
    80004baa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bae:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb2:	02f71763          	bne	a4,a5,80004be0 <piperead+0x68>
    80004bb6:	2244a783          	lw	a5,548(s1)
    80004bba:	c39d                	beqz	a5,80004be0 <piperead+0x68>
    if(killed(pr)){
    80004bbc:	8552                	mv	a0,s4
    80004bbe:	ffffd097          	auipc	ra,0xffffd
    80004bc2:	7ca080e7          	jalr	1994(ra) # 80002388 <killed>
    80004bc6:	e949                	bnez	a0,80004c58 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc8:	85a6                	mv	a1,s1
    80004bca:	854e                	mv	a0,s3
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	514080e7          	jalr	1300(ra) # 800020e0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bd4:	2184a703          	lw	a4,536(s1)
    80004bd8:	21c4a783          	lw	a5,540(s1)
    80004bdc:	fcf70de3          	beq	a4,a5,80004bb6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be4:	05505463          	blez	s5,80004c2c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004be8:	2184a783          	lw	a5,536(s1)
    80004bec:	21c4a703          	lw	a4,540(s1)
    80004bf0:	02f70e63          	beq	a4,a5,80004c2c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bf4:	0017871b          	addiw	a4,a5,1
    80004bf8:	20e4ac23          	sw	a4,536(s1)
    80004bfc:	1ff7f793          	andi	a5,a5,511
    80004c00:	97a6                	add	a5,a5,s1
    80004c02:	0187c783          	lbu	a5,24(a5)
    80004c06:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c0a:	4685                	li	a3,1
    80004c0c:	fbf40613          	addi	a2,s0,-65
    80004c10:	85ca                	mv	a1,s2
    80004c12:	050a3503          	ld	a0,80(s4)
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	a66080e7          	jalr	-1434(ra) # 8000167c <copyout>
    80004c1e:	01650763          	beq	a0,s6,80004c2c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c22:	2985                	addiw	s3,s3,1
    80004c24:	0905                	addi	s2,s2,1
    80004c26:	fd3a91e3          	bne	s5,s3,80004be8 <piperead+0x70>
    80004c2a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c2c:	21c48513          	addi	a0,s1,540
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	514080e7          	jalr	1300(ra) # 80002144 <wakeup>
  release(&pi->lock);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	062080e7          	jalr	98(ra) # 80000c9c <release>
  return i;
}
    80004c42:	854e                	mv	a0,s3
    80004c44:	60a6                	ld	ra,72(sp)
    80004c46:	6406                	ld	s0,64(sp)
    80004c48:	74e2                	ld	s1,56(sp)
    80004c4a:	7942                	ld	s2,48(sp)
    80004c4c:	79a2                	ld	s3,40(sp)
    80004c4e:	7a02                	ld	s4,32(sp)
    80004c50:	6ae2                	ld	s5,24(sp)
    80004c52:	6b42                	ld	s6,16(sp)
    80004c54:	6161                	addi	sp,sp,80
    80004c56:	8082                	ret
      release(&pi->lock);
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	042080e7          	jalr	66(ra) # 80000c9c <release>
      return -1;
    80004c62:	59fd                	li	s3,-1
    80004c64:	bff9                	j	80004c42 <piperead+0xca>

0000000080004c66 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c66:	1141                	addi	sp,sp,-16
    80004c68:	e422                	sd	s0,8(sp)
    80004c6a:	0800                	addi	s0,sp,16
    80004c6c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c6e:	8905                	andi	a0,a0,1
    80004c70:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c72:	8b89                	andi	a5,a5,2
    80004c74:	c399                	beqz	a5,80004c7a <flags2perm+0x14>
      perm |= PTE_W;
    80004c76:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c7a:	6422                	ld	s0,8(sp)
    80004c7c:	0141                	addi	sp,sp,16
    80004c7e:	8082                	ret

0000000080004c80 <exec>:

int
exec(char *path, char **argv)
{
    80004c80:	df010113          	addi	sp,sp,-528
    80004c84:	20113423          	sd	ra,520(sp)
    80004c88:	20813023          	sd	s0,512(sp)
    80004c8c:	ffa6                	sd	s1,504(sp)
    80004c8e:	fbca                	sd	s2,496(sp)
    80004c90:	f7ce                	sd	s3,488(sp)
    80004c92:	f3d2                	sd	s4,480(sp)
    80004c94:	efd6                	sd	s5,472(sp)
    80004c96:	ebda                	sd	s6,464(sp)
    80004c98:	e7de                	sd	s7,456(sp)
    80004c9a:	e3e2                	sd	s8,448(sp)
    80004c9c:	ff66                	sd	s9,440(sp)
    80004c9e:	fb6a                	sd	s10,432(sp)
    80004ca0:	f76e                	sd	s11,424(sp)
    80004ca2:	0c00                	addi	s0,sp,528
    80004ca4:	892a                	mv	s2,a0
    80004ca6:	dea43c23          	sd	a0,-520(s0)
    80004caa:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	d0e080e7          	jalr	-754(ra) # 800019bc <myproc>
    80004cb6:	84aa                	mv	s1,a0

  begin_op();
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	48e080e7          	jalr	1166(ra) # 80004146 <begin_op>

  if((ip = namei(path)) == 0){
    80004cc0:	854a                	mv	a0,s2
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	284080e7          	jalr	644(ra) # 80003f46 <namei>
    80004cca:	c92d                	beqz	a0,80004d3c <exec+0xbc>
    80004ccc:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	ad2080e7          	jalr	-1326(ra) # 800037a0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cd6:	04000713          	li	a4,64
    80004cda:	4681                	li	a3,0
    80004cdc:	e5040613          	addi	a2,s0,-432
    80004ce0:	4581                	li	a1,0
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	fffff097          	auipc	ra,0xfffff
    80004ce8:	d70080e7          	jalr	-656(ra) # 80003a54 <readi>
    80004cec:	04000793          	li	a5,64
    80004cf0:	00f51a63          	bne	a0,a5,80004d04 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cf4:	e5042703          	lw	a4,-432(s0)
    80004cf8:	464c47b7          	lui	a5,0x464c4
    80004cfc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d00:	04f70463          	beq	a4,a5,80004d48 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d04:	8552                	mv	a0,s4
    80004d06:	fffff097          	auipc	ra,0xfffff
    80004d0a:	cfc080e7          	jalr	-772(ra) # 80003a02 <iunlockput>
    end_op();
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	4b2080e7          	jalr	1202(ra) # 800041c0 <end_op>
  }
  return -1;
    80004d16:	557d                	li	a0,-1
}
    80004d18:	20813083          	ld	ra,520(sp)
    80004d1c:	20013403          	ld	s0,512(sp)
    80004d20:	74fe                	ld	s1,504(sp)
    80004d22:	795e                	ld	s2,496(sp)
    80004d24:	79be                	ld	s3,488(sp)
    80004d26:	7a1e                	ld	s4,480(sp)
    80004d28:	6afe                	ld	s5,472(sp)
    80004d2a:	6b5e                	ld	s6,464(sp)
    80004d2c:	6bbe                	ld	s7,456(sp)
    80004d2e:	6c1e                	ld	s8,448(sp)
    80004d30:	7cfa                	ld	s9,440(sp)
    80004d32:	7d5a                	ld	s10,432(sp)
    80004d34:	7dba                	ld	s11,424(sp)
    80004d36:	21010113          	addi	sp,sp,528
    80004d3a:	8082                	ret
    end_op();
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	484080e7          	jalr	1156(ra) # 800041c0 <end_op>
    return -1;
    80004d44:	557d                	li	a0,-1
    80004d46:	bfc9                	j	80004d18 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d48:	8526                	mv	a0,s1
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	d36080e7          	jalr	-714(ra) # 80001a80 <proc_pagetable>
    80004d52:	8b2a                	mv	s6,a0
    80004d54:	d945                	beqz	a0,80004d04 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d56:	e7042d03          	lw	s10,-400(s0)
    80004d5a:	e8845783          	lhu	a5,-376(s0)
    80004d5e:	10078463          	beqz	a5,80004e66 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d62:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d64:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d66:	6c85                	lui	s9,0x1
    80004d68:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d6c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d70:	6a85                	lui	s5,0x1
    80004d72:	a0b5                	j	80004dde <exec+0x15e>
      panic("loadseg: address should exist");
    80004d74:	00004517          	auipc	a0,0x4
    80004d78:	9a450513          	addi	a0,a0,-1628 # 80008718 <syscalls+0x2b0>
    80004d7c:	ffffb097          	auipc	ra,0xffffb
    80004d80:	7c0080e7          	jalr	1984(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004d84:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d86:	8726                	mv	a4,s1
    80004d88:	012c06bb          	addw	a3,s8,s2
    80004d8c:	4581                	li	a1,0
    80004d8e:	8552                	mv	a0,s4
    80004d90:	fffff097          	auipc	ra,0xfffff
    80004d94:	cc4080e7          	jalr	-828(ra) # 80003a54 <readi>
    80004d98:	2501                	sext.w	a0,a0
    80004d9a:	24a49863          	bne	s1,a0,80004fea <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004d9e:	012a893b          	addw	s2,s5,s2
    80004da2:	03397563          	bgeu	s2,s3,80004dcc <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004da6:	02091593          	slli	a1,s2,0x20
    80004daa:	9181                	srli	a1,a1,0x20
    80004dac:	95de                	add	a1,a1,s7
    80004dae:	855a                	mv	a0,s6
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	2bc080e7          	jalr	700(ra) # 8000106c <walkaddr>
    80004db8:	862a                	mv	a2,a0
    if(pa == 0)
    80004dba:	dd4d                	beqz	a0,80004d74 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004dbc:	412984bb          	subw	s1,s3,s2
    80004dc0:	0004879b          	sext.w	a5,s1
    80004dc4:	fcfcf0e3          	bgeu	s9,a5,80004d84 <exec+0x104>
    80004dc8:	84d6                	mv	s1,s5
    80004dca:	bf6d                	j	80004d84 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dcc:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd0:	2d85                	addiw	s11,s11,1
    80004dd2:	038d0d1b          	addiw	s10,s10,56
    80004dd6:	e8845783          	lhu	a5,-376(s0)
    80004dda:	08fdd763          	bge	s11,a5,80004e68 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dde:	2d01                	sext.w	s10,s10
    80004de0:	03800713          	li	a4,56
    80004de4:	86ea                	mv	a3,s10
    80004de6:	e1840613          	addi	a2,s0,-488
    80004dea:	4581                	li	a1,0
    80004dec:	8552                	mv	a0,s4
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	c66080e7          	jalr	-922(ra) # 80003a54 <readi>
    80004df6:	03800793          	li	a5,56
    80004dfa:	1ef51663          	bne	a0,a5,80004fe6 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004dfe:	e1842783          	lw	a5,-488(s0)
    80004e02:	4705                	li	a4,1
    80004e04:	fce796e3          	bne	a5,a4,80004dd0 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004e08:	e4043483          	ld	s1,-448(s0)
    80004e0c:	e3843783          	ld	a5,-456(s0)
    80004e10:	1ef4e863          	bltu	s1,a5,80005000 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e14:	e2843783          	ld	a5,-472(s0)
    80004e18:	94be                	add	s1,s1,a5
    80004e1a:	1ef4e663          	bltu	s1,a5,80005006 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004e1e:	df043703          	ld	a4,-528(s0)
    80004e22:	8ff9                	and	a5,a5,a4
    80004e24:	1e079463          	bnez	a5,8000500c <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e28:	e1c42503          	lw	a0,-484(s0)
    80004e2c:	00000097          	auipc	ra,0x0
    80004e30:	e3a080e7          	jalr	-454(ra) # 80004c66 <flags2perm>
    80004e34:	86aa                	mv	a3,a0
    80004e36:	8626                	mv	a2,s1
    80004e38:	85ca                	mv	a1,s2
    80004e3a:	855a                	mv	a0,s6
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	5e4080e7          	jalr	1508(ra) # 80001420 <uvmalloc>
    80004e44:	e0a43423          	sd	a0,-504(s0)
    80004e48:	1c050563          	beqz	a0,80005012 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e4c:	e2843b83          	ld	s7,-472(s0)
    80004e50:	e2042c03          	lw	s8,-480(s0)
    80004e54:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e58:	00098463          	beqz	s3,80004e60 <exec+0x1e0>
    80004e5c:	4901                	li	s2,0
    80004e5e:	b7a1                	j	80004da6 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e60:	e0843903          	ld	s2,-504(s0)
    80004e64:	b7b5                	j	80004dd0 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e66:	4901                	li	s2,0
  iunlockput(ip);
    80004e68:	8552                	mv	a0,s4
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	b98080e7          	jalr	-1128(ra) # 80003a02 <iunlockput>
  end_op();
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	34e080e7          	jalr	846(ra) # 800041c0 <end_op>
  p = myproc();
    80004e7a:	ffffd097          	auipc	ra,0xffffd
    80004e7e:	b42080e7          	jalr	-1214(ra) # 800019bc <myproc>
    80004e82:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e84:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e88:	6985                	lui	s3,0x1
    80004e8a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e8c:	99ca                	add	s3,s3,s2
    80004e8e:	77fd                	lui	a5,0xfffff
    80004e90:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e94:	4691                	li	a3,4
    80004e96:	6609                	lui	a2,0x2
    80004e98:	964e                	add	a2,a2,s3
    80004e9a:	85ce                	mv	a1,s3
    80004e9c:	855a                	mv	a0,s6
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	582080e7          	jalr	1410(ra) # 80001420 <uvmalloc>
    80004ea6:	892a                	mv	s2,a0
    80004ea8:	e0a43423          	sd	a0,-504(s0)
    80004eac:	e509                	bnez	a0,80004eb6 <exec+0x236>
  if(pagetable)
    80004eae:	e1343423          	sd	s3,-504(s0)
    80004eb2:	4a01                	li	s4,0
    80004eb4:	aa1d                	j	80004fea <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004eb6:	75f9                	lui	a1,0xffffe
    80004eb8:	95aa                	add	a1,a1,a0
    80004eba:	855a                	mv	a0,s6
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	78e080e7          	jalr	1934(ra) # 8000164a <uvmclear>
  stackbase = sp - PGSIZE;
    80004ec4:	7bfd                	lui	s7,0xfffff
    80004ec6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ec8:	e0043783          	ld	a5,-512(s0)
    80004ecc:	6388                	ld	a0,0(a5)
    80004ece:	c52d                	beqz	a0,80004f38 <exec+0x2b8>
    80004ed0:	e9040993          	addi	s3,s0,-368
    80004ed4:	f9040c13          	addi	s8,s0,-112
    80004ed8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eda:	ffffc097          	auipc	ra,0xffffc
    80004ede:	f84080e7          	jalr	-124(ra) # 80000e5e <strlen>
    80004ee2:	0015079b          	addiw	a5,a0,1
    80004ee6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004eea:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004eee:	13796563          	bltu	s2,s7,80005018 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ef2:	e0043d03          	ld	s10,-512(s0)
    80004ef6:	000d3a03          	ld	s4,0(s10)
    80004efa:	8552                	mv	a0,s4
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	f62080e7          	jalr	-158(ra) # 80000e5e <strlen>
    80004f04:	0015069b          	addiw	a3,a0,1
    80004f08:	8652                	mv	a2,s4
    80004f0a:	85ca                	mv	a1,s2
    80004f0c:	855a                	mv	a0,s6
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	76e080e7          	jalr	1902(ra) # 8000167c <copyout>
    80004f16:	10054363          	bltz	a0,8000501c <exec+0x39c>
    ustack[argc] = sp;
    80004f1a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f1e:	0485                	addi	s1,s1,1
    80004f20:	008d0793          	addi	a5,s10,8
    80004f24:	e0f43023          	sd	a5,-512(s0)
    80004f28:	008d3503          	ld	a0,8(s10)
    80004f2c:	c909                	beqz	a0,80004f3e <exec+0x2be>
    if(argc >= MAXARG)
    80004f2e:	09a1                	addi	s3,s3,8
    80004f30:	fb8995e3          	bne	s3,s8,80004eda <exec+0x25a>
  ip = 0;
    80004f34:	4a01                	li	s4,0
    80004f36:	a855                	j	80004fea <exec+0x36a>
  sp = sz;
    80004f38:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f3c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f3e:	00349793          	slli	a5,s1,0x3
    80004f42:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd1d0>
    80004f46:	97a2                	add	a5,a5,s0
    80004f48:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f4c:	00148693          	addi	a3,s1,1
    80004f50:	068e                	slli	a3,a3,0x3
    80004f52:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f56:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f5a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f5e:	f57968e3          	bltu	s2,s7,80004eae <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f62:	e9040613          	addi	a2,s0,-368
    80004f66:	85ca                	mv	a1,s2
    80004f68:	855a                	mv	a0,s6
    80004f6a:	ffffc097          	auipc	ra,0xffffc
    80004f6e:	712080e7          	jalr	1810(ra) # 8000167c <copyout>
    80004f72:	0a054763          	bltz	a0,80005020 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004f76:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f7a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f7e:	df843783          	ld	a5,-520(s0)
    80004f82:	0007c703          	lbu	a4,0(a5)
    80004f86:	cf11                	beqz	a4,80004fa2 <exec+0x322>
    80004f88:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f8a:	02f00693          	li	a3,47
    80004f8e:	a039                	j	80004f9c <exec+0x31c>
      last = s+1;
    80004f90:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f94:	0785                	addi	a5,a5,1
    80004f96:	fff7c703          	lbu	a4,-1(a5)
    80004f9a:	c701                	beqz	a4,80004fa2 <exec+0x322>
    if(*s == '/')
    80004f9c:	fed71ce3          	bne	a4,a3,80004f94 <exec+0x314>
    80004fa0:	bfc5                	j	80004f90 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fa2:	4641                	li	a2,16
    80004fa4:	df843583          	ld	a1,-520(s0)
    80004fa8:	158a8513          	addi	a0,s5,344
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	e80080e7          	jalr	-384(ra) # 80000e2c <safestrcpy>
  oldpagetable = p->pagetable;
    80004fb4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004fb8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004fbc:	e0843783          	ld	a5,-504(s0)
    80004fc0:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fc4:	058ab783          	ld	a5,88(s5)
    80004fc8:	e6843703          	ld	a4,-408(s0)
    80004fcc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fce:	058ab783          	ld	a5,88(s5)
    80004fd2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fd6:	85e6                	mv	a1,s9
    80004fd8:	ffffd097          	auipc	ra,0xffffd
    80004fdc:	b44080e7          	jalr	-1212(ra) # 80001b1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fe0:	0004851b          	sext.w	a0,s1
    80004fe4:	bb15                	j	80004d18 <exec+0x98>
    80004fe6:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fea:	e0843583          	ld	a1,-504(s0)
    80004fee:	855a                	mv	a0,s6
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	b2c080e7          	jalr	-1236(ra) # 80001b1c <proc_freepagetable>
  return -1;
    80004ff8:	557d                	li	a0,-1
  if(ip){
    80004ffa:	d00a0fe3          	beqz	s4,80004d18 <exec+0x98>
    80004ffe:	b319                	j	80004d04 <exec+0x84>
    80005000:	e1243423          	sd	s2,-504(s0)
    80005004:	b7dd                	j	80004fea <exec+0x36a>
    80005006:	e1243423          	sd	s2,-504(s0)
    8000500a:	b7c5                	j	80004fea <exec+0x36a>
    8000500c:	e1243423          	sd	s2,-504(s0)
    80005010:	bfe9                	j	80004fea <exec+0x36a>
    80005012:	e1243423          	sd	s2,-504(s0)
    80005016:	bfd1                	j	80004fea <exec+0x36a>
  ip = 0;
    80005018:	4a01                	li	s4,0
    8000501a:	bfc1                	j	80004fea <exec+0x36a>
    8000501c:	4a01                	li	s4,0
  if(pagetable)
    8000501e:	b7f1                	j	80004fea <exec+0x36a>
  sz = sz1;
    80005020:	e0843983          	ld	s3,-504(s0)
    80005024:	b569                	j	80004eae <exec+0x22e>

0000000080005026 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005026:	7179                	addi	sp,sp,-48
    80005028:	f406                	sd	ra,40(sp)
    8000502a:	f022                	sd	s0,32(sp)
    8000502c:	ec26                	sd	s1,24(sp)
    8000502e:	e84a                	sd	s2,16(sp)
    80005030:	1800                	addi	s0,sp,48
    80005032:	892e                	mv	s2,a1
    80005034:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005036:	fdc40593          	addi	a1,s0,-36
    8000503a:	ffffe097          	auipc	ra,0xffffe
    8000503e:	b18080e7          	jalr	-1256(ra) # 80002b52 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005042:	fdc42703          	lw	a4,-36(s0)
    80005046:	47bd                	li	a5,15
    80005048:	02e7eb63          	bltu	a5,a4,8000507e <argfd+0x58>
    8000504c:	ffffd097          	auipc	ra,0xffffd
    80005050:	970080e7          	jalr	-1680(ra) # 800019bc <myproc>
    80005054:	fdc42703          	lw	a4,-36(s0)
    80005058:	01a70793          	addi	a5,a4,26
    8000505c:	078e                	slli	a5,a5,0x3
    8000505e:	953e                	add	a0,a0,a5
    80005060:	611c                	ld	a5,0(a0)
    80005062:	c385                	beqz	a5,80005082 <argfd+0x5c>
    return -1;
  if(pfd)
    80005064:	00090463          	beqz	s2,8000506c <argfd+0x46>
    *pfd = fd;
    80005068:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000506c:	4501                	li	a0,0
  if(pf)
    8000506e:	c091                	beqz	s1,80005072 <argfd+0x4c>
    *pf = f;
    80005070:	e09c                	sd	a5,0(s1)
}
    80005072:	70a2                	ld	ra,40(sp)
    80005074:	7402                	ld	s0,32(sp)
    80005076:	64e2                	ld	s1,24(sp)
    80005078:	6942                	ld	s2,16(sp)
    8000507a:	6145                	addi	sp,sp,48
    8000507c:	8082                	ret
    return -1;
    8000507e:	557d                	li	a0,-1
    80005080:	bfcd                	j	80005072 <argfd+0x4c>
    80005082:	557d                	li	a0,-1
    80005084:	b7fd                	j	80005072 <argfd+0x4c>

0000000080005086 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005086:	1101                	addi	sp,sp,-32
    80005088:	ec06                	sd	ra,24(sp)
    8000508a:	e822                	sd	s0,16(sp)
    8000508c:	e426                	sd	s1,8(sp)
    8000508e:	1000                	addi	s0,sp,32
    80005090:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	92a080e7          	jalr	-1750(ra) # 800019bc <myproc>
    8000509a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000509c:	0d050793          	addi	a5,a0,208
    800050a0:	4501                	li	a0,0
    800050a2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050a4:	6398                	ld	a4,0(a5)
    800050a6:	cb19                	beqz	a4,800050bc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050a8:	2505                	addiw	a0,a0,1
    800050aa:	07a1                	addi	a5,a5,8
    800050ac:	fed51ce3          	bne	a0,a3,800050a4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050b0:	557d                	li	a0,-1
}
    800050b2:	60e2                	ld	ra,24(sp)
    800050b4:	6442                	ld	s0,16(sp)
    800050b6:	64a2                	ld	s1,8(sp)
    800050b8:	6105                	addi	sp,sp,32
    800050ba:	8082                	ret
      p->ofile[fd] = f;
    800050bc:	01a50793          	addi	a5,a0,26
    800050c0:	078e                	slli	a5,a5,0x3
    800050c2:	963e                	add	a2,a2,a5
    800050c4:	e204                	sd	s1,0(a2)
      return fd;
    800050c6:	b7f5                	j	800050b2 <fdalloc+0x2c>

00000000800050c8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050c8:	715d                	addi	sp,sp,-80
    800050ca:	e486                	sd	ra,72(sp)
    800050cc:	e0a2                	sd	s0,64(sp)
    800050ce:	fc26                	sd	s1,56(sp)
    800050d0:	f84a                	sd	s2,48(sp)
    800050d2:	f44e                	sd	s3,40(sp)
    800050d4:	f052                	sd	s4,32(sp)
    800050d6:	ec56                	sd	s5,24(sp)
    800050d8:	e85a                	sd	s6,16(sp)
    800050da:	0880                	addi	s0,sp,80
    800050dc:	8b2e                	mv	s6,a1
    800050de:	89b2                	mv	s3,a2
    800050e0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050e2:	fb040593          	addi	a1,s0,-80
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	e7e080e7          	jalr	-386(ra) # 80003f64 <nameiparent>
    800050ee:	84aa                	mv	s1,a0
    800050f0:	14050b63          	beqz	a0,80005246 <create+0x17e>
    return 0;

  ilock(dp);
    800050f4:	ffffe097          	auipc	ra,0xffffe
    800050f8:	6ac080e7          	jalr	1708(ra) # 800037a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050fc:	4601                	li	a2,0
    800050fe:	fb040593          	addi	a1,s0,-80
    80005102:	8526                	mv	a0,s1
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	b80080e7          	jalr	-1152(ra) # 80003c84 <dirlookup>
    8000510c:	8aaa                	mv	s5,a0
    8000510e:	c921                	beqz	a0,8000515e <create+0x96>
    iunlockput(dp);
    80005110:	8526                	mv	a0,s1
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	8f0080e7          	jalr	-1808(ra) # 80003a02 <iunlockput>
    ilock(ip);
    8000511a:	8556                	mv	a0,s5
    8000511c:	ffffe097          	auipc	ra,0xffffe
    80005120:	684080e7          	jalr	1668(ra) # 800037a0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005124:	4789                	li	a5,2
    80005126:	02fb1563          	bne	s6,a5,80005150 <create+0x88>
    8000512a:	044ad783          	lhu	a5,68(s5)
    8000512e:	37f9                	addiw	a5,a5,-2
    80005130:	17c2                	slli	a5,a5,0x30
    80005132:	93c1                	srli	a5,a5,0x30
    80005134:	4705                	li	a4,1
    80005136:	00f76d63          	bltu	a4,a5,80005150 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000513a:	8556                	mv	a0,s5
    8000513c:	60a6                	ld	ra,72(sp)
    8000513e:	6406                	ld	s0,64(sp)
    80005140:	74e2                	ld	s1,56(sp)
    80005142:	7942                	ld	s2,48(sp)
    80005144:	79a2                	ld	s3,40(sp)
    80005146:	7a02                	ld	s4,32(sp)
    80005148:	6ae2                	ld	s5,24(sp)
    8000514a:	6b42                	ld	s6,16(sp)
    8000514c:	6161                	addi	sp,sp,80
    8000514e:	8082                	ret
    iunlockput(ip);
    80005150:	8556                	mv	a0,s5
    80005152:	fffff097          	auipc	ra,0xfffff
    80005156:	8b0080e7          	jalr	-1872(ra) # 80003a02 <iunlockput>
    return 0;
    8000515a:	4a81                	li	s5,0
    8000515c:	bff9                	j	8000513a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000515e:	85da                	mv	a1,s6
    80005160:	4088                	lw	a0,0(s1)
    80005162:	ffffe097          	auipc	ra,0xffffe
    80005166:	4a6080e7          	jalr	1190(ra) # 80003608 <ialloc>
    8000516a:	8a2a                	mv	s4,a0
    8000516c:	c529                	beqz	a0,800051b6 <create+0xee>
  ilock(ip);
    8000516e:	ffffe097          	auipc	ra,0xffffe
    80005172:	632080e7          	jalr	1586(ra) # 800037a0 <ilock>
  ip->major = major;
    80005176:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000517a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000517e:	4905                	li	s2,1
    80005180:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005184:	8552                	mv	a0,s4
    80005186:	ffffe097          	auipc	ra,0xffffe
    8000518a:	54e080e7          	jalr	1358(ra) # 800036d4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000518e:	032b0b63          	beq	s6,s2,800051c4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005192:	004a2603          	lw	a2,4(s4)
    80005196:	fb040593          	addi	a1,s0,-80
    8000519a:	8526                	mv	a0,s1
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	cf8080e7          	jalr	-776(ra) # 80003e94 <dirlink>
    800051a4:	06054f63          	bltz	a0,80005222 <create+0x15a>
  iunlockput(dp);
    800051a8:	8526                	mv	a0,s1
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	858080e7          	jalr	-1960(ra) # 80003a02 <iunlockput>
  return ip;
    800051b2:	8ad2                	mv	s5,s4
    800051b4:	b759                	j	8000513a <create+0x72>
    iunlockput(dp);
    800051b6:	8526                	mv	a0,s1
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	84a080e7          	jalr	-1974(ra) # 80003a02 <iunlockput>
    return 0;
    800051c0:	8ad2                	mv	s5,s4
    800051c2:	bfa5                	j	8000513a <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051c4:	004a2603          	lw	a2,4(s4)
    800051c8:	00003597          	auipc	a1,0x3
    800051cc:	57058593          	addi	a1,a1,1392 # 80008738 <syscalls+0x2d0>
    800051d0:	8552                	mv	a0,s4
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	cc2080e7          	jalr	-830(ra) # 80003e94 <dirlink>
    800051da:	04054463          	bltz	a0,80005222 <create+0x15a>
    800051de:	40d0                	lw	a2,4(s1)
    800051e0:	00003597          	auipc	a1,0x3
    800051e4:	56058593          	addi	a1,a1,1376 # 80008740 <syscalls+0x2d8>
    800051e8:	8552                	mv	a0,s4
    800051ea:	fffff097          	auipc	ra,0xfffff
    800051ee:	caa080e7          	jalr	-854(ra) # 80003e94 <dirlink>
    800051f2:	02054863          	bltz	a0,80005222 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051f6:	004a2603          	lw	a2,4(s4)
    800051fa:	fb040593          	addi	a1,s0,-80
    800051fe:	8526                	mv	a0,s1
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	c94080e7          	jalr	-876(ra) # 80003e94 <dirlink>
    80005208:	00054d63          	bltz	a0,80005222 <create+0x15a>
    dp->nlink++;  // for ".."
    8000520c:	04a4d783          	lhu	a5,74(s1)
    80005210:	2785                	addiw	a5,a5,1
    80005212:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005216:	8526                	mv	a0,s1
    80005218:	ffffe097          	auipc	ra,0xffffe
    8000521c:	4bc080e7          	jalr	1212(ra) # 800036d4 <iupdate>
    80005220:	b761                	j	800051a8 <create+0xe0>
  ip->nlink = 0;
    80005222:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005226:	8552                	mv	a0,s4
    80005228:	ffffe097          	auipc	ra,0xffffe
    8000522c:	4ac080e7          	jalr	1196(ra) # 800036d4 <iupdate>
  iunlockput(ip);
    80005230:	8552                	mv	a0,s4
    80005232:	ffffe097          	auipc	ra,0xffffe
    80005236:	7d0080e7          	jalr	2000(ra) # 80003a02 <iunlockput>
  iunlockput(dp);
    8000523a:	8526                	mv	a0,s1
    8000523c:	ffffe097          	auipc	ra,0xffffe
    80005240:	7c6080e7          	jalr	1990(ra) # 80003a02 <iunlockput>
  return 0;
    80005244:	bddd                	j	8000513a <create+0x72>
    return 0;
    80005246:	8aaa                	mv	s5,a0
    80005248:	bdcd                	j	8000513a <create+0x72>

000000008000524a <sys_dup>:
{
    8000524a:	7179                	addi	sp,sp,-48
    8000524c:	f406                	sd	ra,40(sp)
    8000524e:	f022                	sd	s0,32(sp)
    80005250:	ec26                	sd	s1,24(sp)
    80005252:	e84a                	sd	s2,16(sp)
    80005254:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005256:	fd840613          	addi	a2,s0,-40
    8000525a:	4581                	li	a1,0
    8000525c:	4501                	li	a0,0
    8000525e:	00000097          	auipc	ra,0x0
    80005262:	dc8080e7          	jalr	-568(ra) # 80005026 <argfd>
    return -1;
    80005266:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005268:	02054363          	bltz	a0,8000528e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000526c:	fd843903          	ld	s2,-40(s0)
    80005270:	854a                	mv	a0,s2
    80005272:	00000097          	auipc	ra,0x0
    80005276:	e14080e7          	jalr	-492(ra) # 80005086 <fdalloc>
    8000527a:	84aa                	mv	s1,a0
    return -1;
    8000527c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000527e:	00054863          	bltz	a0,8000528e <sys_dup+0x44>
  filedup(f);
    80005282:	854a                	mv	a0,s2
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	334080e7          	jalr	820(ra) # 800045b8 <filedup>
  return fd;
    8000528c:	87a6                	mv	a5,s1
}
    8000528e:	853e                	mv	a0,a5
    80005290:	70a2                	ld	ra,40(sp)
    80005292:	7402                	ld	s0,32(sp)
    80005294:	64e2                	ld	s1,24(sp)
    80005296:	6942                	ld	s2,16(sp)
    80005298:	6145                	addi	sp,sp,48
    8000529a:	8082                	ret

000000008000529c <sys_read>:
{
    8000529c:	7179                	addi	sp,sp,-48
    8000529e:	f406                	sd	ra,40(sp)
    800052a0:	f022                	sd	s0,32(sp)
    800052a2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052a4:	fd840593          	addi	a1,s0,-40
    800052a8:	4505                	li	a0,1
    800052aa:	ffffe097          	auipc	ra,0xffffe
    800052ae:	8c8080e7          	jalr	-1848(ra) # 80002b72 <argaddr>
  argint(2, &n);
    800052b2:	fe440593          	addi	a1,s0,-28
    800052b6:	4509                	li	a0,2
    800052b8:	ffffe097          	auipc	ra,0xffffe
    800052bc:	89a080e7          	jalr	-1894(ra) # 80002b52 <argint>
  if(argfd(0, 0, &f) < 0)
    800052c0:	fe840613          	addi	a2,s0,-24
    800052c4:	4581                	li	a1,0
    800052c6:	4501                	li	a0,0
    800052c8:	00000097          	auipc	ra,0x0
    800052cc:	d5e080e7          	jalr	-674(ra) # 80005026 <argfd>
    800052d0:	87aa                	mv	a5,a0
    return -1;
    800052d2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052d4:	0007cc63          	bltz	a5,800052ec <sys_read+0x50>
  return fileread(f, p, n);
    800052d8:	fe442603          	lw	a2,-28(s0)
    800052dc:	fd843583          	ld	a1,-40(s0)
    800052e0:	fe843503          	ld	a0,-24(s0)
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	460080e7          	jalr	1120(ra) # 80004744 <fileread>
}
    800052ec:	70a2                	ld	ra,40(sp)
    800052ee:	7402                	ld	s0,32(sp)
    800052f0:	6145                	addi	sp,sp,48
    800052f2:	8082                	ret

00000000800052f4 <sys_write>:
{
    800052f4:	7179                	addi	sp,sp,-48
    800052f6:	f406                	sd	ra,40(sp)
    800052f8:	f022                	sd	s0,32(sp)
    800052fa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052fc:	fd840593          	addi	a1,s0,-40
    80005300:	4505                	li	a0,1
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	870080e7          	jalr	-1936(ra) # 80002b72 <argaddr>
  argint(2, &n);
    8000530a:	fe440593          	addi	a1,s0,-28
    8000530e:	4509                	li	a0,2
    80005310:	ffffe097          	auipc	ra,0xffffe
    80005314:	842080e7          	jalr	-1982(ra) # 80002b52 <argint>
  if(argfd(0, 0, &f) < 0)
    80005318:	fe840613          	addi	a2,s0,-24
    8000531c:	4581                	li	a1,0
    8000531e:	4501                	li	a0,0
    80005320:	00000097          	auipc	ra,0x0
    80005324:	d06080e7          	jalr	-762(ra) # 80005026 <argfd>
    80005328:	87aa                	mv	a5,a0
    return -1;
    8000532a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000532c:	0007cc63          	bltz	a5,80005344 <sys_write+0x50>
  return filewrite(f, p, n);
    80005330:	fe442603          	lw	a2,-28(s0)
    80005334:	fd843583          	ld	a1,-40(s0)
    80005338:	fe843503          	ld	a0,-24(s0)
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	4ca080e7          	jalr	1226(ra) # 80004806 <filewrite>
}
    80005344:	70a2                	ld	ra,40(sp)
    80005346:	7402                	ld	s0,32(sp)
    80005348:	6145                	addi	sp,sp,48
    8000534a:	8082                	ret

000000008000534c <sys_close>:
{
    8000534c:	1101                	addi	sp,sp,-32
    8000534e:	ec06                	sd	ra,24(sp)
    80005350:	e822                	sd	s0,16(sp)
    80005352:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005354:	fe040613          	addi	a2,s0,-32
    80005358:	fec40593          	addi	a1,s0,-20
    8000535c:	4501                	li	a0,0
    8000535e:	00000097          	auipc	ra,0x0
    80005362:	cc8080e7          	jalr	-824(ra) # 80005026 <argfd>
    return -1;
    80005366:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005368:	02054463          	bltz	a0,80005390 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	650080e7          	jalr	1616(ra) # 800019bc <myproc>
    80005374:	fec42783          	lw	a5,-20(s0)
    80005378:	07e9                	addi	a5,a5,26
    8000537a:	078e                	slli	a5,a5,0x3
    8000537c:	953e                	add	a0,a0,a5
    8000537e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005382:	fe043503          	ld	a0,-32(s0)
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	284080e7          	jalr	644(ra) # 8000460a <fileclose>
  return 0;
    8000538e:	4781                	li	a5,0
}
    80005390:	853e                	mv	a0,a5
    80005392:	60e2                	ld	ra,24(sp)
    80005394:	6442                	ld	s0,16(sp)
    80005396:	6105                	addi	sp,sp,32
    80005398:	8082                	ret

000000008000539a <sys_fstat>:
{
    8000539a:	1101                	addi	sp,sp,-32
    8000539c:	ec06                	sd	ra,24(sp)
    8000539e:	e822                	sd	s0,16(sp)
    800053a0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053a2:	fe040593          	addi	a1,s0,-32
    800053a6:	4505                	li	a0,1
    800053a8:	ffffd097          	auipc	ra,0xffffd
    800053ac:	7ca080e7          	jalr	1994(ra) # 80002b72 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053b0:	fe840613          	addi	a2,s0,-24
    800053b4:	4581                	li	a1,0
    800053b6:	4501                	li	a0,0
    800053b8:	00000097          	auipc	ra,0x0
    800053bc:	c6e080e7          	jalr	-914(ra) # 80005026 <argfd>
    800053c0:	87aa                	mv	a5,a0
    return -1;
    800053c2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053c4:	0007ca63          	bltz	a5,800053d8 <sys_fstat+0x3e>
  return filestat(f, st);
    800053c8:	fe043583          	ld	a1,-32(s0)
    800053cc:	fe843503          	ld	a0,-24(s0)
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	302080e7          	jalr	770(ra) # 800046d2 <filestat>
}
    800053d8:	60e2                	ld	ra,24(sp)
    800053da:	6442                	ld	s0,16(sp)
    800053dc:	6105                	addi	sp,sp,32
    800053de:	8082                	ret

00000000800053e0 <sys_link>:
{
    800053e0:	7169                	addi	sp,sp,-304
    800053e2:	f606                	sd	ra,296(sp)
    800053e4:	f222                	sd	s0,288(sp)
    800053e6:	ee26                	sd	s1,280(sp)
    800053e8:	ea4a                	sd	s2,272(sp)
    800053ea:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ec:	08000613          	li	a2,128
    800053f0:	ed040593          	addi	a1,s0,-304
    800053f4:	4501                	li	a0,0
    800053f6:	ffffd097          	auipc	ra,0xffffd
    800053fa:	79c080e7          	jalr	1948(ra) # 80002b92 <argstr>
    return -1;
    800053fe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005400:	10054e63          	bltz	a0,8000551c <sys_link+0x13c>
    80005404:	08000613          	li	a2,128
    80005408:	f5040593          	addi	a1,s0,-176
    8000540c:	4505                	li	a0,1
    8000540e:	ffffd097          	auipc	ra,0xffffd
    80005412:	784080e7          	jalr	1924(ra) # 80002b92 <argstr>
    return -1;
    80005416:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005418:	10054263          	bltz	a0,8000551c <sys_link+0x13c>
  begin_op();
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	d2a080e7          	jalr	-726(ra) # 80004146 <begin_op>
  if((ip = namei(old)) == 0){
    80005424:	ed040513          	addi	a0,s0,-304
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	b1e080e7          	jalr	-1250(ra) # 80003f46 <namei>
    80005430:	84aa                	mv	s1,a0
    80005432:	c551                	beqz	a0,800054be <sys_link+0xde>
  ilock(ip);
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	36c080e7          	jalr	876(ra) # 800037a0 <ilock>
  if(ip->type == T_DIR){
    8000543c:	04449703          	lh	a4,68(s1)
    80005440:	4785                	li	a5,1
    80005442:	08f70463          	beq	a4,a5,800054ca <sys_link+0xea>
  ip->nlink++;
    80005446:	04a4d783          	lhu	a5,74(s1)
    8000544a:	2785                	addiw	a5,a5,1
    8000544c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	282080e7          	jalr	642(ra) # 800036d4 <iupdate>
  iunlock(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	406080e7          	jalr	1030(ra) # 80003862 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005464:	fd040593          	addi	a1,s0,-48
    80005468:	f5040513          	addi	a0,s0,-176
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	af8080e7          	jalr	-1288(ra) # 80003f64 <nameiparent>
    80005474:	892a                	mv	s2,a0
    80005476:	c935                	beqz	a0,800054ea <sys_link+0x10a>
  ilock(dp);
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	328080e7          	jalr	808(ra) # 800037a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005480:	00092703          	lw	a4,0(s2)
    80005484:	409c                	lw	a5,0(s1)
    80005486:	04f71d63          	bne	a4,a5,800054e0 <sys_link+0x100>
    8000548a:	40d0                	lw	a2,4(s1)
    8000548c:	fd040593          	addi	a1,s0,-48
    80005490:	854a                	mv	a0,s2
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	a02080e7          	jalr	-1534(ra) # 80003e94 <dirlink>
    8000549a:	04054363          	bltz	a0,800054e0 <sys_link+0x100>
  iunlockput(dp);
    8000549e:	854a                	mv	a0,s2
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	562080e7          	jalr	1378(ra) # 80003a02 <iunlockput>
  iput(ip);
    800054a8:	8526                	mv	a0,s1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	4b0080e7          	jalr	1200(ra) # 8000395a <iput>
  end_op();
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	d0e080e7          	jalr	-754(ra) # 800041c0 <end_op>
  return 0;
    800054ba:	4781                	li	a5,0
    800054bc:	a085                	j	8000551c <sys_link+0x13c>
    end_op();
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	d02080e7          	jalr	-766(ra) # 800041c0 <end_op>
    return -1;
    800054c6:	57fd                	li	a5,-1
    800054c8:	a891                	j	8000551c <sys_link+0x13c>
    iunlockput(ip);
    800054ca:	8526                	mv	a0,s1
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	536080e7          	jalr	1334(ra) # 80003a02 <iunlockput>
    end_op();
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	cec080e7          	jalr	-788(ra) # 800041c0 <end_op>
    return -1;
    800054dc:	57fd                	li	a5,-1
    800054de:	a83d                	j	8000551c <sys_link+0x13c>
    iunlockput(dp);
    800054e0:	854a                	mv	a0,s2
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	520080e7          	jalr	1312(ra) # 80003a02 <iunlockput>
  ilock(ip);
    800054ea:	8526                	mv	a0,s1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	2b4080e7          	jalr	692(ra) # 800037a0 <ilock>
  ip->nlink--;
    800054f4:	04a4d783          	lhu	a5,74(s1)
    800054f8:	37fd                	addiw	a5,a5,-1
    800054fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054fe:	8526                	mv	a0,s1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	1d4080e7          	jalr	468(ra) # 800036d4 <iupdate>
  iunlockput(ip);
    80005508:	8526                	mv	a0,s1
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	4f8080e7          	jalr	1272(ra) # 80003a02 <iunlockput>
  end_op();
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	cae080e7          	jalr	-850(ra) # 800041c0 <end_op>
  return -1;
    8000551a:	57fd                	li	a5,-1
}
    8000551c:	853e                	mv	a0,a5
    8000551e:	70b2                	ld	ra,296(sp)
    80005520:	7412                	ld	s0,288(sp)
    80005522:	64f2                	ld	s1,280(sp)
    80005524:	6952                	ld	s2,272(sp)
    80005526:	6155                	addi	sp,sp,304
    80005528:	8082                	ret

000000008000552a <sys_unlink>:
{
    8000552a:	7151                	addi	sp,sp,-240
    8000552c:	f586                	sd	ra,232(sp)
    8000552e:	f1a2                	sd	s0,224(sp)
    80005530:	eda6                	sd	s1,216(sp)
    80005532:	e9ca                	sd	s2,208(sp)
    80005534:	e5ce                	sd	s3,200(sp)
    80005536:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005538:	08000613          	li	a2,128
    8000553c:	f3040593          	addi	a1,s0,-208
    80005540:	4501                	li	a0,0
    80005542:	ffffd097          	auipc	ra,0xffffd
    80005546:	650080e7          	jalr	1616(ra) # 80002b92 <argstr>
    8000554a:	18054163          	bltz	a0,800056cc <sys_unlink+0x1a2>
  begin_op();
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	bf8080e7          	jalr	-1032(ra) # 80004146 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005556:	fb040593          	addi	a1,s0,-80
    8000555a:	f3040513          	addi	a0,s0,-208
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	a06080e7          	jalr	-1530(ra) # 80003f64 <nameiparent>
    80005566:	84aa                	mv	s1,a0
    80005568:	c979                	beqz	a0,8000563e <sys_unlink+0x114>
  ilock(dp);
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	236080e7          	jalr	566(ra) # 800037a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005572:	00003597          	auipc	a1,0x3
    80005576:	1c658593          	addi	a1,a1,454 # 80008738 <syscalls+0x2d0>
    8000557a:	fb040513          	addi	a0,s0,-80
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	6ec080e7          	jalr	1772(ra) # 80003c6a <namecmp>
    80005586:	14050a63          	beqz	a0,800056da <sys_unlink+0x1b0>
    8000558a:	00003597          	auipc	a1,0x3
    8000558e:	1b658593          	addi	a1,a1,438 # 80008740 <syscalls+0x2d8>
    80005592:	fb040513          	addi	a0,s0,-80
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	6d4080e7          	jalr	1748(ra) # 80003c6a <namecmp>
    8000559e:	12050e63          	beqz	a0,800056da <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055a2:	f2c40613          	addi	a2,s0,-212
    800055a6:	fb040593          	addi	a1,s0,-80
    800055aa:	8526                	mv	a0,s1
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	6d8080e7          	jalr	1752(ra) # 80003c84 <dirlookup>
    800055b4:	892a                	mv	s2,a0
    800055b6:	12050263          	beqz	a0,800056da <sys_unlink+0x1b0>
  ilock(ip);
    800055ba:	ffffe097          	auipc	ra,0xffffe
    800055be:	1e6080e7          	jalr	486(ra) # 800037a0 <ilock>
  if(ip->nlink < 1)
    800055c2:	04a91783          	lh	a5,74(s2)
    800055c6:	08f05263          	blez	a5,8000564a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055ca:	04491703          	lh	a4,68(s2)
    800055ce:	4785                	li	a5,1
    800055d0:	08f70563          	beq	a4,a5,8000565a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055d4:	4641                	li	a2,16
    800055d6:	4581                	li	a1,0
    800055d8:	fc040513          	addi	a0,s0,-64
    800055dc:	ffffb097          	auipc	ra,0xffffb
    800055e0:	708080e7          	jalr	1800(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055e4:	4741                	li	a4,16
    800055e6:	f2c42683          	lw	a3,-212(s0)
    800055ea:	fc040613          	addi	a2,s0,-64
    800055ee:	4581                	li	a1,0
    800055f0:	8526                	mv	a0,s1
    800055f2:	ffffe097          	auipc	ra,0xffffe
    800055f6:	55a080e7          	jalr	1370(ra) # 80003b4c <writei>
    800055fa:	47c1                	li	a5,16
    800055fc:	0af51563          	bne	a0,a5,800056a6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005600:	04491703          	lh	a4,68(s2)
    80005604:	4785                	li	a5,1
    80005606:	0af70863          	beq	a4,a5,800056b6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000560a:	8526                	mv	a0,s1
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	3f6080e7          	jalr	1014(ra) # 80003a02 <iunlockput>
  ip->nlink--;
    80005614:	04a95783          	lhu	a5,74(s2)
    80005618:	37fd                	addiw	a5,a5,-1
    8000561a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000561e:	854a                	mv	a0,s2
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	0b4080e7          	jalr	180(ra) # 800036d4 <iupdate>
  iunlockput(ip);
    80005628:	854a                	mv	a0,s2
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	3d8080e7          	jalr	984(ra) # 80003a02 <iunlockput>
  end_op();
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	b8e080e7          	jalr	-1138(ra) # 800041c0 <end_op>
  return 0;
    8000563a:	4501                	li	a0,0
    8000563c:	a84d                	j	800056ee <sys_unlink+0x1c4>
    end_op();
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	b82080e7          	jalr	-1150(ra) # 800041c0 <end_op>
    return -1;
    80005646:	557d                	li	a0,-1
    80005648:	a05d                	j	800056ee <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000564a:	00003517          	auipc	a0,0x3
    8000564e:	0fe50513          	addi	a0,a0,254 # 80008748 <syscalls+0x2e0>
    80005652:	ffffb097          	auipc	ra,0xffffb
    80005656:	eea080e7          	jalr	-278(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000565a:	04c92703          	lw	a4,76(s2)
    8000565e:	02000793          	li	a5,32
    80005662:	f6e7f9e3          	bgeu	a5,a4,800055d4 <sys_unlink+0xaa>
    80005666:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000566a:	4741                	li	a4,16
    8000566c:	86ce                	mv	a3,s3
    8000566e:	f1840613          	addi	a2,s0,-232
    80005672:	4581                	li	a1,0
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	3de080e7          	jalr	990(ra) # 80003a54 <readi>
    8000567e:	47c1                	li	a5,16
    80005680:	00f51b63          	bne	a0,a5,80005696 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005684:	f1845783          	lhu	a5,-232(s0)
    80005688:	e7a1                	bnez	a5,800056d0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000568a:	29c1                	addiw	s3,s3,16
    8000568c:	04c92783          	lw	a5,76(s2)
    80005690:	fcf9ede3          	bltu	s3,a5,8000566a <sys_unlink+0x140>
    80005694:	b781                	j	800055d4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005696:	00003517          	auipc	a0,0x3
    8000569a:	0ca50513          	addi	a0,a0,202 # 80008760 <syscalls+0x2f8>
    8000569e:	ffffb097          	auipc	ra,0xffffb
    800056a2:	e9e080e7          	jalr	-354(ra) # 8000053c <panic>
    panic("unlink: writei");
    800056a6:	00003517          	auipc	a0,0x3
    800056aa:	0d250513          	addi	a0,a0,210 # 80008778 <syscalls+0x310>
    800056ae:	ffffb097          	auipc	ra,0xffffb
    800056b2:	e8e080e7          	jalr	-370(ra) # 8000053c <panic>
    dp->nlink--;
    800056b6:	04a4d783          	lhu	a5,74(s1)
    800056ba:	37fd                	addiw	a5,a5,-1
    800056bc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056c0:	8526                	mv	a0,s1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	012080e7          	jalr	18(ra) # 800036d4 <iupdate>
    800056ca:	b781                	j	8000560a <sys_unlink+0xe0>
    return -1;
    800056cc:	557d                	li	a0,-1
    800056ce:	a005                	j	800056ee <sys_unlink+0x1c4>
    iunlockput(ip);
    800056d0:	854a                	mv	a0,s2
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	330080e7          	jalr	816(ra) # 80003a02 <iunlockput>
  iunlockput(dp);
    800056da:	8526                	mv	a0,s1
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	326080e7          	jalr	806(ra) # 80003a02 <iunlockput>
  end_op();
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	adc080e7          	jalr	-1316(ra) # 800041c0 <end_op>
  return -1;
    800056ec:	557d                	li	a0,-1
}
    800056ee:	70ae                	ld	ra,232(sp)
    800056f0:	740e                	ld	s0,224(sp)
    800056f2:	64ee                	ld	s1,216(sp)
    800056f4:	694e                	ld	s2,208(sp)
    800056f6:	69ae                	ld	s3,200(sp)
    800056f8:	616d                	addi	sp,sp,240
    800056fa:	8082                	ret

00000000800056fc <sys_open>:

uint64
sys_open(void)
{
    800056fc:	7131                	addi	sp,sp,-192
    800056fe:	fd06                	sd	ra,184(sp)
    80005700:	f922                	sd	s0,176(sp)
    80005702:	f526                	sd	s1,168(sp)
    80005704:	f14a                	sd	s2,160(sp)
    80005706:	ed4e                	sd	s3,152(sp)
    80005708:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000570a:	f4c40593          	addi	a1,s0,-180
    8000570e:	4505                	li	a0,1
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	442080e7          	jalr	1090(ra) # 80002b52 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005718:	08000613          	li	a2,128
    8000571c:	f5040593          	addi	a1,s0,-176
    80005720:	4501                	li	a0,0
    80005722:	ffffd097          	auipc	ra,0xffffd
    80005726:	470080e7          	jalr	1136(ra) # 80002b92 <argstr>
    8000572a:	87aa                	mv	a5,a0
    return -1;
    8000572c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000572e:	0a07c863          	bltz	a5,800057de <sys_open+0xe2>

  begin_op();
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	a14080e7          	jalr	-1516(ra) # 80004146 <begin_op>

  if(omode & O_CREATE){
    8000573a:	f4c42783          	lw	a5,-180(s0)
    8000573e:	2007f793          	andi	a5,a5,512
    80005742:	cbdd                	beqz	a5,800057f8 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005744:	4681                	li	a3,0
    80005746:	4601                	li	a2,0
    80005748:	4589                	li	a1,2
    8000574a:	f5040513          	addi	a0,s0,-176
    8000574e:	00000097          	auipc	ra,0x0
    80005752:	97a080e7          	jalr	-1670(ra) # 800050c8 <create>
    80005756:	84aa                	mv	s1,a0
    if(ip == 0){
    80005758:	c951                	beqz	a0,800057ec <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000575a:	04449703          	lh	a4,68(s1)
    8000575e:	478d                	li	a5,3
    80005760:	00f71763          	bne	a4,a5,8000576e <sys_open+0x72>
    80005764:	0464d703          	lhu	a4,70(s1)
    80005768:	47a5                	li	a5,9
    8000576a:	0ce7ec63          	bltu	a5,a4,80005842 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	de0080e7          	jalr	-544(ra) # 8000454e <filealloc>
    80005776:	892a                	mv	s2,a0
    80005778:	c56d                	beqz	a0,80005862 <sys_open+0x166>
    8000577a:	00000097          	auipc	ra,0x0
    8000577e:	90c080e7          	jalr	-1780(ra) # 80005086 <fdalloc>
    80005782:	89aa                	mv	s3,a0
    80005784:	0c054a63          	bltz	a0,80005858 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005788:	04449703          	lh	a4,68(s1)
    8000578c:	478d                	li	a5,3
    8000578e:	0ef70563          	beq	a4,a5,80005878 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005792:	4789                	li	a5,2
    80005794:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005798:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000579c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057a0:	f4c42783          	lw	a5,-180(s0)
    800057a4:	0017c713          	xori	a4,a5,1
    800057a8:	8b05                	andi	a4,a4,1
    800057aa:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057ae:	0037f713          	andi	a4,a5,3
    800057b2:	00e03733          	snez	a4,a4
    800057b6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057ba:	4007f793          	andi	a5,a5,1024
    800057be:	c791                	beqz	a5,800057ca <sys_open+0xce>
    800057c0:	04449703          	lh	a4,68(s1)
    800057c4:	4789                	li	a5,2
    800057c6:	0cf70063          	beq	a4,a5,80005886 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	096080e7          	jalr	150(ra) # 80003862 <iunlock>
  end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	9ec080e7          	jalr	-1556(ra) # 800041c0 <end_op>

  return fd;
    800057dc:	854e                	mv	a0,s3
}
    800057de:	70ea                	ld	ra,184(sp)
    800057e0:	744a                	ld	s0,176(sp)
    800057e2:	74aa                	ld	s1,168(sp)
    800057e4:	790a                	ld	s2,160(sp)
    800057e6:	69ea                	ld	s3,152(sp)
    800057e8:	6129                	addi	sp,sp,192
    800057ea:	8082                	ret
      end_op();
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	9d4080e7          	jalr	-1580(ra) # 800041c0 <end_op>
      return -1;
    800057f4:	557d                	li	a0,-1
    800057f6:	b7e5                	j	800057de <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057f8:	f5040513          	addi	a0,s0,-176
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	74a080e7          	jalr	1866(ra) # 80003f46 <namei>
    80005804:	84aa                	mv	s1,a0
    80005806:	c905                	beqz	a0,80005836 <sys_open+0x13a>
    ilock(ip);
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	f98080e7          	jalr	-104(ra) # 800037a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005810:	04449703          	lh	a4,68(s1)
    80005814:	4785                	li	a5,1
    80005816:	f4f712e3          	bne	a4,a5,8000575a <sys_open+0x5e>
    8000581a:	f4c42783          	lw	a5,-180(s0)
    8000581e:	dba1                	beqz	a5,8000576e <sys_open+0x72>
      iunlockput(ip);
    80005820:	8526                	mv	a0,s1
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	1e0080e7          	jalr	480(ra) # 80003a02 <iunlockput>
      end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	996080e7          	jalr	-1642(ra) # 800041c0 <end_op>
      return -1;
    80005832:	557d                	li	a0,-1
    80005834:	b76d                	j	800057de <sys_open+0xe2>
      end_op();
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	98a080e7          	jalr	-1654(ra) # 800041c0 <end_op>
      return -1;
    8000583e:	557d                	li	a0,-1
    80005840:	bf79                	j	800057de <sys_open+0xe2>
    iunlockput(ip);
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	1be080e7          	jalr	446(ra) # 80003a02 <iunlockput>
    end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	974080e7          	jalr	-1676(ra) # 800041c0 <end_op>
    return -1;
    80005854:	557d                	li	a0,-1
    80005856:	b761                	j	800057de <sys_open+0xe2>
      fileclose(f);
    80005858:	854a                	mv	a0,s2
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	db0080e7          	jalr	-592(ra) # 8000460a <fileclose>
    iunlockput(ip);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	19e080e7          	jalr	414(ra) # 80003a02 <iunlockput>
    end_op();
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	954080e7          	jalr	-1708(ra) # 800041c0 <end_op>
    return -1;
    80005874:	557d                	li	a0,-1
    80005876:	b7a5                	j	800057de <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005878:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000587c:	04649783          	lh	a5,70(s1)
    80005880:	02f91223          	sh	a5,36(s2)
    80005884:	bf21                	j	8000579c <sys_open+0xa0>
    itrunc(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	026080e7          	jalr	38(ra) # 800038ae <itrunc>
    80005890:	bf2d                	j	800057ca <sys_open+0xce>

0000000080005892 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005892:	7175                	addi	sp,sp,-144
    80005894:	e506                	sd	ra,136(sp)
    80005896:	e122                	sd	s0,128(sp)
    80005898:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	8ac080e7          	jalr	-1876(ra) # 80004146 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058a2:	08000613          	li	a2,128
    800058a6:	f7040593          	addi	a1,s0,-144
    800058aa:	4501                	li	a0,0
    800058ac:	ffffd097          	auipc	ra,0xffffd
    800058b0:	2e6080e7          	jalr	742(ra) # 80002b92 <argstr>
    800058b4:	02054963          	bltz	a0,800058e6 <sys_mkdir+0x54>
    800058b8:	4681                	li	a3,0
    800058ba:	4601                	li	a2,0
    800058bc:	4585                	li	a1,1
    800058be:	f7040513          	addi	a0,s0,-144
    800058c2:	00000097          	auipc	ra,0x0
    800058c6:	806080e7          	jalr	-2042(ra) # 800050c8 <create>
    800058ca:	cd11                	beqz	a0,800058e6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	136080e7          	jalr	310(ra) # 80003a02 <iunlockput>
  end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	8ec080e7          	jalr	-1812(ra) # 800041c0 <end_op>
  return 0;
    800058dc:	4501                	li	a0,0
}
    800058de:	60aa                	ld	ra,136(sp)
    800058e0:	640a                	ld	s0,128(sp)
    800058e2:	6149                	addi	sp,sp,144
    800058e4:	8082                	ret
    end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	8da080e7          	jalr	-1830(ra) # 800041c0 <end_op>
    return -1;
    800058ee:	557d                	li	a0,-1
    800058f0:	b7fd                	j	800058de <sys_mkdir+0x4c>

00000000800058f2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058f2:	7135                	addi	sp,sp,-160
    800058f4:	ed06                	sd	ra,152(sp)
    800058f6:	e922                	sd	s0,144(sp)
    800058f8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058fa:	fffff097          	auipc	ra,0xfffff
    800058fe:	84c080e7          	jalr	-1972(ra) # 80004146 <begin_op>
  argint(1, &major);
    80005902:	f6c40593          	addi	a1,s0,-148
    80005906:	4505                	li	a0,1
    80005908:	ffffd097          	auipc	ra,0xffffd
    8000590c:	24a080e7          	jalr	586(ra) # 80002b52 <argint>
  argint(2, &minor);
    80005910:	f6840593          	addi	a1,s0,-152
    80005914:	4509                	li	a0,2
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	23c080e7          	jalr	572(ra) # 80002b52 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000591e:	08000613          	li	a2,128
    80005922:	f7040593          	addi	a1,s0,-144
    80005926:	4501                	li	a0,0
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	26a080e7          	jalr	618(ra) # 80002b92 <argstr>
    80005930:	02054b63          	bltz	a0,80005966 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005934:	f6841683          	lh	a3,-152(s0)
    80005938:	f6c41603          	lh	a2,-148(s0)
    8000593c:	458d                	li	a1,3
    8000593e:	f7040513          	addi	a0,s0,-144
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	786080e7          	jalr	1926(ra) # 800050c8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000594a:	cd11                	beqz	a0,80005966 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	0b6080e7          	jalr	182(ra) # 80003a02 <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	86c080e7          	jalr	-1940(ra) # 800041c0 <end_op>
  return 0;
    8000595c:	4501                	li	a0,0
}
    8000595e:	60ea                	ld	ra,152(sp)
    80005960:	644a                	ld	s0,144(sp)
    80005962:	610d                	addi	sp,sp,160
    80005964:	8082                	ret
    end_op();
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	85a080e7          	jalr	-1958(ra) # 800041c0 <end_op>
    return -1;
    8000596e:	557d                	li	a0,-1
    80005970:	b7fd                	j	8000595e <sys_mknod+0x6c>

0000000080005972 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005972:	7135                	addi	sp,sp,-160
    80005974:	ed06                	sd	ra,152(sp)
    80005976:	e922                	sd	s0,144(sp)
    80005978:	e526                	sd	s1,136(sp)
    8000597a:	e14a                	sd	s2,128(sp)
    8000597c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000597e:	ffffc097          	auipc	ra,0xffffc
    80005982:	03e080e7          	jalr	62(ra) # 800019bc <myproc>
    80005986:	892a                	mv	s2,a0
  
  begin_op();
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	7be080e7          	jalr	1982(ra) # 80004146 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005990:	08000613          	li	a2,128
    80005994:	f6040593          	addi	a1,s0,-160
    80005998:	4501                	li	a0,0
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	1f8080e7          	jalr	504(ra) # 80002b92 <argstr>
    800059a2:	04054b63          	bltz	a0,800059f8 <sys_chdir+0x86>
    800059a6:	f6040513          	addi	a0,s0,-160
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	59c080e7          	jalr	1436(ra) # 80003f46 <namei>
    800059b2:	84aa                	mv	s1,a0
    800059b4:	c131                	beqz	a0,800059f8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	dea080e7          	jalr	-534(ra) # 800037a0 <ilock>
  if(ip->type != T_DIR){
    800059be:	04449703          	lh	a4,68(s1)
    800059c2:	4785                	li	a5,1
    800059c4:	04f71063          	bne	a4,a5,80005a04 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	e98080e7          	jalr	-360(ra) # 80003862 <iunlock>
  iput(p->cwd);
    800059d2:	15093503          	ld	a0,336(s2)
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	f84080e7          	jalr	-124(ra) # 8000395a <iput>
  end_op();
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	7e2080e7          	jalr	2018(ra) # 800041c0 <end_op>
  p->cwd = ip;
    800059e6:	14993823          	sd	s1,336(s2)
  return 0;
    800059ea:	4501                	li	a0,0
}
    800059ec:	60ea                	ld	ra,152(sp)
    800059ee:	644a                	ld	s0,144(sp)
    800059f0:	64aa                	ld	s1,136(sp)
    800059f2:	690a                	ld	s2,128(sp)
    800059f4:	610d                	addi	sp,sp,160
    800059f6:	8082                	ret
    end_op();
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	7c8080e7          	jalr	1992(ra) # 800041c0 <end_op>
    return -1;
    80005a00:	557d                	li	a0,-1
    80005a02:	b7ed                	j	800059ec <sys_chdir+0x7a>
    iunlockput(ip);
    80005a04:	8526                	mv	a0,s1
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	ffc080e7          	jalr	-4(ra) # 80003a02 <iunlockput>
    end_op();
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	7b2080e7          	jalr	1970(ra) # 800041c0 <end_op>
    return -1;
    80005a16:	557d                	li	a0,-1
    80005a18:	bfd1                	j	800059ec <sys_chdir+0x7a>

0000000080005a1a <sys_exec>:

uint64
sys_exec(void)
{
    80005a1a:	7121                	addi	sp,sp,-448
    80005a1c:	ff06                	sd	ra,440(sp)
    80005a1e:	fb22                	sd	s0,432(sp)
    80005a20:	f726                	sd	s1,424(sp)
    80005a22:	f34a                	sd	s2,416(sp)
    80005a24:	ef4e                	sd	s3,408(sp)
    80005a26:	eb52                	sd	s4,400(sp)
    80005a28:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a2a:	e4840593          	addi	a1,s0,-440
    80005a2e:	4505                	li	a0,1
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	142080e7          	jalr	322(ra) # 80002b72 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a38:	08000613          	li	a2,128
    80005a3c:	f5040593          	addi	a1,s0,-176
    80005a40:	4501                	li	a0,0
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	150080e7          	jalr	336(ra) # 80002b92 <argstr>
    80005a4a:	87aa                	mv	a5,a0
    return -1;
    80005a4c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a4e:	0c07c263          	bltz	a5,80005b12 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a52:	10000613          	li	a2,256
    80005a56:	4581                	li	a1,0
    80005a58:	e5040513          	addi	a0,s0,-432
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	288080e7          	jalr	648(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a64:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a68:	89a6                	mv	s3,s1
    80005a6a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a6c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a70:	00391513          	slli	a0,s2,0x3
    80005a74:	e4040593          	addi	a1,s0,-448
    80005a78:	e4843783          	ld	a5,-440(s0)
    80005a7c:	953e                	add	a0,a0,a5
    80005a7e:	ffffd097          	auipc	ra,0xffffd
    80005a82:	036080e7          	jalr	54(ra) # 80002ab4 <fetchaddr>
    80005a86:	02054a63          	bltz	a0,80005aba <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a8a:	e4043783          	ld	a5,-448(s0)
    80005a8e:	c3b9                	beqz	a5,80005ad4 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a90:	ffffb097          	auipc	ra,0xffffb
    80005a94:	052080e7          	jalr	82(ra) # 80000ae2 <kalloc>
    80005a98:	85aa                	mv	a1,a0
    80005a9a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a9e:	cd11                	beqz	a0,80005aba <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005aa0:	6605                	lui	a2,0x1
    80005aa2:	e4043503          	ld	a0,-448(s0)
    80005aa6:	ffffd097          	auipc	ra,0xffffd
    80005aaa:	060080e7          	jalr	96(ra) # 80002b06 <fetchstr>
    80005aae:	00054663          	bltz	a0,80005aba <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005ab2:	0905                	addi	s2,s2,1
    80005ab4:	09a1                	addi	s3,s3,8
    80005ab6:	fb491de3          	bne	s2,s4,80005a70 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aba:	f5040913          	addi	s2,s0,-176
    80005abe:	6088                	ld	a0,0(s1)
    80005ac0:	c921                	beqz	a0,80005b10 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ac2:	ffffb097          	auipc	ra,0xffffb
    80005ac6:	f22080e7          	jalr	-222(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aca:	04a1                	addi	s1,s1,8
    80005acc:	ff2499e3          	bne	s1,s2,80005abe <sys_exec+0xa4>
  return -1;
    80005ad0:	557d                	li	a0,-1
    80005ad2:	a081                	j	80005b12 <sys_exec+0xf8>
      argv[i] = 0;
    80005ad4:	0009079b          	sext.w	a5,s2
    80005ad8:	078e                	slli	a5,a5,0x3
    80005ada:	fd078793          	addi	a5,a5,-48
    80005ade:	97a2                	add	a5,a5,s0
    80005ae0:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ae4:	e5040593          	addi	a1,s0,-432
    80005ae8:	f5040513          	addi	a0,s0,-176
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	194080e7          	jalr	404(ra) # 80004c80 <exec>
    80005af4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af6:	f5040993          	addi	s3,s0,-176
    80005afa:	6088                	ld	a0,0(s1)
    80005afc:	c901                	beqz	a0,80005b0c <sys_exec+0xf2>
    kfree(argv[i]);
    80005afe:	ffffb097          	auipc	ra,0xffffb
    80005b02:	ee6080e7          	jalr	-282(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b06:	04a1                	addi	s1,s1,8
    80005b08:	ff3499e3          	bne	s1,s3,80005afa <sys_exec+0xe0>
  return ret;
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	a011                	j	80005b12 <sys_exec+0xf8>
  return -1;
    80005b10:	557d                	li	a0,-1
}
    80005b12:	70fa                	ld	ra,440(sp)
    80005b14:	745a                	ld	s0,432(sp)
    80005b16:	74ba                	ld	s1,424(sp)
    80005b18:	791a                	ld	s2,416(sp)
    80005b1a:	69fa                	ld	s3,408(sp)
    80005b1c:	6a5a                	ld	s4,400(sp)
    80005b1e:	6139                	addi	sp,sp,448
    80005b20:	8082                	ret

0000000080005b22 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b22:	7139                	addi	sp,sp,-64
    80005b24:	fc06                	sd	ra,56(sp)
    80005b26:	f822                	sd	s0,48(sp)
    80005b28:	f426                	sd	s1,40(sp)
    80005b2a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b2c:	ffffc097          	auipc	ra,0xffffc
    80005b30:	e90080e7          	jalr	-368(ra) # 800019bc <myproc>
    80005b34:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b36:	fd840593          	addi	a1,s0,-40
    80005b3a:	4501                	li	a0,0
    80005b3c:	ffffd097          	auipc	ra,0xffffd
    80005b40:	036080e7          	jalr	54(ra) # 80002b72 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b44:	fc840593          	addi	a1,s0,-56
    80005b48:	fd040513          	addi	a0,s0,-48
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	dea080e7          	jalr	-534(ra) # 80004936 <pipealloc>
    return -1;
    80005b54:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b56:	0c054463          	bltz	a0,80005c1e <sys_pipe+0xfc>
  fd0 = -1;
    80005b5a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b5e:	fd043503          	ld	a0,-48(s0)
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	524080e7          	jalr	1316(ra) # 80005086 <fdalloc>
    80005b6a:	fca42223          	sw	a0,-60(s0)
    80005b6e:	08054b63          	bltz	a0,80005c04 <sys_pipe+0xe2>
    80005b72:	fc843503          	ld	a0,-56(s0)
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	510080e7          	jalr	1296(ra) # 80005086 <fdalloc>
    80005b7e:	fca42023          	sw	a0,-64(s0)
    80005b82:	06054863          	bltz	a0,80005bf2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b86:	4691                	li	a3,4
    80005b88:	fc440613          	addi	a2,s0,-60
    80005b8c:	fd843583          	ld	a1,-40(s0)
    80005b90:	68a8                	ld	a0,80(s1)
    80005b92:	ffffc097          	auipc	ra,0xffffc
    80005b96:	aea080e7          	jalr	-1302(ra) # 8000167c <copyout>
    80005b9a:	02054063          	bltz	a0,80005bba <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b9e:	4691                	li	a3,4
    80005ba0:	fc040613          	addi	a2,s0,-64
    80005ba4:	fd843583          	ld	a1,-40(s0)
    80005ba8:	0591                	addi	a1,a1,4
    80005baa:	68a8                	ld	a0,80(s1)
    80005bac:	ffffc097          	auipc	ra,0xffffc
    80005bb0:	ad0080e7          	jalr	-1328(ra) # 8000167c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bb4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bb6:	06055463          	bgez	a0,80005c1e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005bba:	fc442783          	lw	a5,-60(s0)
    80005bbe:	07e9                	addi	a5,a5,26
    80005bc0:	078e                	slli	a5,a5,0x3
    80005bc2:	97a6                	add	a5,a5,s1
    80005bc4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bc8:	fc042783          	lw	a5,-64(s0)
    80005bcc:	07e9                	addi	a5,a5,26
    80005bce:	078e                	slli	a5,a5,0x3
    80005bd0:	94be                	add	s1,s1,a5
    80005bd2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bd6:	fd043503          	ld	a0,-48(s0)
    80005bda:	fffff097          	auipc	ra,0xfffff
    80005bde:	a30080e7          	jalr	-1488(ra) # 8000460a <fileclose>
    fileclose(wf);
    80005be2:	fc843503          	ld	a0,-56(s0)
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	a24080e7          	jalr	-1500(ra) # 8000460a <fileclose>
    return -1;
    80005bee:	57fd                	li	a5,-1
    80005bf0:	a03d                	j	80005c1e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bf2:	fc442783          	lw	a5,-60(s0)
    80005bf6:	0007c763          	bltz	a5,80005c04 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bfa:	07e9                	addi	a5,a5,26
    80005bfc:	078e                	slli	a5,a5,0x3
    80005bfe:	97a6                	add	a5,a5,s1
    80005c00:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c04:	fd043503          	ld	a0,-48(s0)
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	a02080e7          	jalr	-1534(ra) # 8000460a <fileclose>
    fileclose(wf);
    80005c10:	fc843503          	ld	a0,-56(s0)
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	9f6080e7          	jalr	-1546(ra) # 8000460a <fileclose>
    return -1;
    80005c1c:	57fd                	li	a5,-1
}
    80005c1e:	853e                	mv	a0,a5
    80005c20:	70e2                	ld	ra,56(sp)
    80005c22:	7442                	ld	s0,48(sp)
    80005c24:	74a2                	ld	s1,40(sp)
    80005c26:	6121                	addi	sp,sp,64
    80005c28:	8082                	ret
    80005c2a:	0000                	unimp
    80005c2c:	0000                	unimp
	...

0000000080005c30 <kernelvec>:
    80005c30:	7111                	addi	sp,sp,-256
    80005c32:	e006                	sd	ra,0(sp)
    80005c34:	e40a                	sd	sp,8(sp)
    80005c36:	e80e                	sd	gp,16(sp)
    80005c38:	ec12                	sd	tp,24(sp)
    80005c3a:	f016                	sd	t0,32(sp)
    80005c3c:	f41a                	sd	t1,40(sp)
    80005c3e:	f81e                	sd	t2,48(sp)
    80005c40:	fc22                	sd	s0,56(sp)
    80005c42:	e0a6                	sd	s1,64(sp)
    80005c44:	e4aa                	sd	a0,72(sp)
    80005c46:	e8ae                	sd	a1,80(sp)
    80005c48:	ecb2                	sd	a2,88(sp)
    80005c4a:	f0b6                	sd	a3,96(sp)
    80005c4c:	f4ba                	sd	a4,104(sp)
    80005c4e:	f8be                	sd	a5,112(sp)
    80005c50:	fcc2                	sd	a6,120(sp)
    80005c52:	e146                	sd	a7,128(sp)
    80005c54:	e54a                	sd	s2,136(sp)
    80005c56:	e94e                	sd	s3,144(sp)
    80005c58:	ed52                	sd	s4,152(sp)
    80005c5a:	f156                	sd	s5,160(sp)
    80005c5c:	f55a                	sd	s6,168(sp)
    80005c5e:	f95e                	sd	s7,176(sp)
    80005c60:	fd62                	sd	s8,184(sp)
    80005c62:	e1e6                	sd	s9,192(sp)
    80005c64:	e5ea                	sd	s10,200(sp)
    80005c66:	e9ee                	sd	s11,208(sp)
    80005c68:	edf2                	sd	t3,216(sp)
    80005c6a:	f1f6                	sd	t4,224(sp)
    80005c6c:	f5fa                	sd	t5,232(sp)
    80005c6e:	f9fe                	sd	t6,240(sp)
    80005c70:	d11fc0ef          	jal	ra,80002980 <kerneltrap>
    80005c74:	6082                	ld	ra,0(sp)
    80005c76:	6122                	ld	sp,8(sp)
    80005c78:	61c2                	ld	gp,16(sp)
    80005c7a:	7282                	ld	t0,32(sp)
    80005c7c:	7322                	ld	t1,40(sp)
    80005c7e:	73c2                	ld	t2,48(sp)
    80005c80:	7462                	ld	s0,56(sp)
    80005c82:	6486                	ld	s1,64(sp)
    80005c84:	6526                	ld	a0,72(sp)
    80005c86:	65c6                	ld	a1,80(sp)
    80005c88:	6666                	ld	a2,88(sp)
    80005c8a:	7686                	ld	a3,96(sp)
    80005c8c:	7726                	ld	a4,104(sp)
    80005c8e:	77c6                	ld	a5,112(sp)
    80005c90:	7866                	ld	a6,120(sp)
    80005c92:	688a                	ld	a7,128(sp)
    80005c94:	692a                	ld	s2,136(sp)
    80005c96:	69ca                	ld	s3,144(sp)
    80005c98:	6a6a                	ld	s4,152(sp)
    80005c9a:	7a8a                	ld	s5,160(sp)
    80005c9c:	7b2a                	ld	s6,168(sp)
    80005c9e:	7bca                	ld	s7,176(sp)
    80005ca0:	7c6a                	ld	s8,184(sp)
    80005ca2:	6c8e                	ld	s9,192(sp)
    80005ca4:	6d2e                	ld	s10,200(sp)
    80005ca6:	6dce                	ld	s11,208(sp)
    80005ca8:	6e6e                	ld	t3,216(sp)
    80005caa:	7e8e                	ld	t4,224(sp)
    80005cac:	7f2e                	ld	t5,232(sp)
    80005cae:	7fce                	ld	t6,240(sp)
    80005cb0:	6111                	addi	sp,sp,256
    80005cb2:	10200073          	sret
    80005cb6:	00000013          	nop
    80005cba:	00000013          	nop
    80005cbe:	0001                	nop

0000000080005cc0 <timervec>:
    80005cc0:	34051573          	csrrw	a0,mscratch,a0
    80005cc4:	e10c                	sd	a1,0(a0)
    80005cc6:	e510                	sd	a2,8(a0)
    80005cc8:	e914                	sd	a3,16(a0)
    80005cca:	6d0c                	ld	a1,24(a0)
    80005ccc:	7110                	ld	a2,32(a0)
    80005cce:	6194                	ld	a3,0(a1)
    80005cd0:	96b2                	add	a3,a3,a2
    80005cd2:	e194                	sd	a3,0(a1)
    80005cd4:	4589                	li	a1,2
    80005cd6:	14459073          	csrw	sip,a1
    80005cda:	6914                	ld	a3,16(a0)
    80005cdc:	6510                	ld	a2,8(a0)
    80005cde:	610c                	ld	a1,0(a0)
    80005ce0:	34051573          	csrrw	a0,mscratch,a0
    80005ce4:	30200073          	mret
	...

0000000080005cea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cea:	1141                	addi	sp,sp,-16
    80005cec:	e422                	sd	s0,8(sp)
    80005cee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cf0:	0c0007b7          	lui	a5,0xc000
    80005cf4:	4705                	li	a4,1
    80005cf6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cf8:	c3d8                	sw	a4,4(a5)
}
    80005cfa:	6422                	ld	s0,8(sp)
    80005cfc:	0141                	addi	sp,sp,16
    80005cfe:	8082                	ret

0000000080005d00 <plicinithart>:

void
plicinithart(void)
{
    80005d00:	1141                	addi	sp,sp,-16
    80005d02:	e406                	sd	ra,8(sp)
    80005d04:	e022                	sd	s0,0(sp)
    80005d06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	c88080e7          	jalr	-888(ra) # 80001990 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d10:	0085171b          	slliw	a4,a0,0x8
    80005d14:	0c0027b7          	lui	a5,0xc002
    80005d18:	97ba                	add	a5,a5,a4
    80005d1a:	40200713          	li	a4,1026
    80005d1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d22:	00d5151b          	slliw	a0,a0,0xd
    80005d26:	0c2017b7          	lui	a5,0xc201
    80005d2a:	97aa                	add	a5,a5,a0
    80005d2c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d30:	60a2                	ld	ra,8(sp)
    80005d32:	6402                	ld	s0,0(sp)
    80005d34:	0141                	addi	sp,sp,16
    80005d36:	8082                	ret

0000000080005d38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d38:	1141                	addi	sp,sp,-16
    80005d3a:	e406                	sd	ra,8(sp)
    80005d3c:	e022                	sd	s0,0(sp)
    80005d3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d40:	ffffc097          	auipc	ra,0xffffc
    80005d44:	c50080e7          	jalr	-944(ra) # 80001990 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d48:	00d5151b          	slliw	a0,a0,0xd
    80005d4c:	0c2017b7          	lui	a5,0xc201
    80005d50:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d52:	43c8                	lw	a0,4(a5)
    80005d54:	60a2                	ld	ra,8(sp)
    80005d56:	6402                	ld	s0,0(sp)
    80005d58:	0141                	addi	sp,sp,16
    80005d5a:	8082                	ret

0000000080005d5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d5c:	1101                	addi	sp,sp,-32
    80005d5e:	ec06                	sd	ra,24(sp)
    80005d60:	e822                	sd	s0,16(sp)
    80005d62:	e426                	sd	s1,8(sp)
    80005d64:	1000                	addi	s0,sp,32
    80005d66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	c28080e7          	jalr	-984(ra) # 80001990 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d70:	00d5151b          	slliw	a0,a0,0xd
    80005d74:	0c2017b7          	lui	a5,0xc201
    80005d78:	97aa                	add	a5,a5,a0
    80005d7a:	c3c4                	sw	s1,4(a5)
}
    80005d7c:	60e2                	ld	ra,24(sp)
    80005d7e:	6442                	ld	s0,16(sp)
    80005d80:	64a2                	ld	s1,8(sp)
    80005d82:	6105                	addi	sp,sp,32
    80005d84:	8082                	ret

0000000080005d86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d86:	1141                	addi	sp,sp,-16
    80005d88:	e406                	sd	ra,8(sp)
    80005d8a:	e022                	sd	s0,0(sp)
    80005d8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d8e:	479d                	li	a5,7
    80005d90:	04a7cc63          	blt	a5,a0,80005de8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d94:	0001c797          	auipc	a5,0x1c
    80005d98:	eec78793          	addi	a5,a5,-276 # 80021c80 <disk>
    80005d9c:	97aa                	add	a5,a5,a0
    80005d9e:	0187c783          	lbu	a5,24(a5)
    80005da2:	ebb9                	bnez	a5,80005df8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005da4:	00451693          	slli	a3,a0,0x4
    80005da8:	0001c797          	auipc	a5,0x1c
    80005dac:	ed878793          	addi	a5,a5,-296 # 80021c80 <disk>
    80005db0:	6398                	ld	a4,0(a5)
    80005db2:	9736                	add	a4,a4,a3
    80005db4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005db8:	6398                	ld	a4,0(a5)
    80005dba:	9736                	add	a4,a4,a3
    80005dbc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005dc0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005dc4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005dc8:	97aa                	add	a5,a5,a0
    80005dca:	4705                	li	a4,1
    80005dcc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005dd0:	0001c517          	auipc	a0,0x1c
    80005dd4:	ec850513          	addi	a0,a0,-312 # 80021c98 <disk+0x18>
    80005dd8:	ffffc097          	auipc	ra,0xffffc
    80005ddc:	36c080e7          	jalr	876(ra) # 80002144 <wakeup>
}
    80005de0:	60a2                	ld	ra,8(sp)
    80005de2:	6402                	ld	s0,0(sp)
    80005de4:	0141                	addi	sp,sp,16
    80005de6:	8082                	ret
    panic("free_desc 1");
    80005de8:	00003517          	auipc	a0,0x3
    80005dec:	9a050513          	addi	a0,a0,-1632 # 80008788 <syscalls+0x320>
    80005df0:	ffffa097          	auipc	ra,0xffffa
    80005df4:	74c080e7          	jalr	1868(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005df8:	00003517          	auipc	a0,0x3
    80005dfc:	9a050513          	addi	a0,a0,-1632 # 80008798 <syscalls+0x330>
    80005e00:	ffffa097          	auipc	ra,0xffffa
    80005e04:	73c080e7          	jalr	1852(ra) # 8000053c <panic>

0000000080005e08 <virtio_disk_init>:
{
    80005e08:	1101                	addi	sp,sp,-32
    80005e0a:	ec06                	sd	ra,24(sp)
    80005e0c:	e822                	sd	s0,16(sp)
    80005e0e:	e426                	sd	s1,8(sp)
    80005e10:	e04a                	sd	s2,0(sp)
    80005e12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e14:	00003597          	auipc	a1,0x3
    80005e18:	99458593          	addi	a1,a1,-1644 # 800087a8 <syscalls+0x340>
    80005e1c:	0001c517          	auipc	a0,0x1c
    80005e20:	f8c50513          	addi	a0,a0,-116 # 80021da8 <disk+0x128>
    80005e24:	ffffb097          	auipc	ra,0xffffb
    80005e28:	d1e080e7          	jalr	-738(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e2c:	100017b7          	lui	a5,0x10001
    80005e30:	4398                	lw	a4,0(a5)
    80005e32:	2701                	sext.w	a4,a4
    80005e34:	747277b7          	lui	a5,0x74727
    80005e38:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e3c:	14f71b63          	bne	a4,a5,80005f92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e40:	100017b7          	lui	a5,0x10001
    80005e44:	43dc                	lw	a5,4(a5)
    80005e46:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e48:	4709                	li	a4,2
    80005e4a:	14e79463          	bne	a5,a4,80005f92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e4e:	100017b7          	lui	a5,0x10001
    80005e52:	479c                	lw	a5,8(a5)
    80005e54:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e56:	12e79e63          	bne	a5,a4,80005f92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e5a:	100017b7          	lui	a5,0x10001
    80005e5e:	47d8                	lw	a4,12(a5)
    80005e60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e62:	554d47b7          	lui	a5,0x554d4
    80005e66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e6a:	12f71463          	bne	a4,a5,80005f92 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e76:	4705                	li	a4,1
    80005e78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e7a:	470d                	li	a4,3
    80005e7c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e7e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e80:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e84:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc99f>
    80005e88:	8f75                	and	a4,a4,a3
    80005e8a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8c:	472d                	li	a4,11
    80005e8e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e90:	5bbc                	lw	a5,112(a5)
    80005e92:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e96:	8ba1                	andi	a5,a5,8
    80005e98:	10078563          	beqz	a5,80005fa2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e9c:	100017b7          	lui	a5,0x10001
    80005ea0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ea4:	43fc                	lw	a5,68(a5)
    80005ea6:	2781                	sext.w	a5,a5
    80005ea8:	10079563          	bnez	a5,80005fb2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005eac:	100017b7          	lui	a5,0x10001
    80005eb0:	5bdc                	lw	a5,52(a5)
    80005eb2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005eb4:	10078763          	beqz	a5,80005fc2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005eb8:	471d                	li	a4,7
    80005eba:	10f77c63          	bgeu	a4,a5,80005fd2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005ebe:	ffffb097          	auipc	ra,0xffffb
    80005ec2:	c24080e7          	jalr	-988(ra) # 80000ae2 <kalloc>
    80005ec6:	0001c497          	auipc	s1,0x1c
    80005eca:	dba48493          	addi	s1,s1,-582 # 80021c80 <disk>
    80005ece:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ed0:	ffffb097          	auipc	ra,0xffffb
    80005ed4:	c12080e7          	jalr	-1006(ra) # 80000ae2 <kalloc>
    80005ed8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	c08080e7          	jalr	-1016(ra) # 80000ae2 <kalloc>
    80005ee2:	87aa                	mv	a5,a0
    80005ee4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ee6:	6088                	ld	a0,0(s1)
    80005ee8:	cd6d                	beqz	a0,80005fe2 <virtio_disk_init+0x1da>
    80005eea:	0001c717          	auipc	a4,0x1c
    80005eee:	d9e73703          	ld	a4,-610(a4) # 80021c88 <disk+0x8>
    80005ef2:	cb65                	beqz	a4,80005fe2 <virtio_disk_init+0x1da>
    80005ef4:	c7fd                	beqz	a5,80005fe2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ef6:	6605                	lui	a2,0x1
    80005ef8:	4581                	li	a1,0
    80005efa:	ffffb097          	auipc	ra,0xffffb
    80005efe:	dea080e7          	jalr	-534(ra) # 80000ce4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f02:	0001c497          	auipc	s1,0x1c
    80005f06:	d7e48493          	addi	s1,s1,-642 # 80021c80 <disk>
    80005f0a:	6605                	lui	a2,0x1
    80005f0c:	4581                	li	a1,0
    80005f0e:	6488                	ld	a0,8(s1)
    80005f10:	ffffb097          	auipc	ra,0xffffb
    80005f14:	dd4080e7          	jalr	-556(ra) # 80000ce4 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f18:	6605                	lui	a2,0x1
    80005f1a:	4581                	li	a1,0
    80005f1c:	6888                	ld	a0,16(s1)
    80005f1e:	ffffb097          	auipc	ra,0xffffb
    80005f22:	dc6080e7          	jalr	-570(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f26:	100017b7          	lui	a5,0x10001
    80005f2a:	4721                	li	a4,8
    80005f2c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f2e:	4098                	lw	a4,0(s1)
    80005f30:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f34:	40d8                	lw	a4,4(s1)
    80005f36:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f3a:	6498                	ld	a4,8(s1)
    80005f3c:	0007069b          	sext.w	a3,a4
    80005f40:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f44:	9701                	srai	a4,a4,0x20
    80005f46:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f4a:	6898                	ld	a4,16(s1)
    80005f4c:	0007069b          	sext.w	a3,a4
    80005f50:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f54:	9701                	srai	a4,a4,0x20
    80005f56:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f5a:	4705                	li	a4,1
    80005f5c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f5e:	00e48c23          	sb	a4,24(s1)
    80005f62:	00e48ca3          	sb	a4,25(s1)
    80005f66:	00e48d23          	sb	a4,26(s1)
    80005f6a:	00e48da3          	sb	a4,27(s1)
    80005f6e:	00e48e23          	sb	a4,28(s1)
    80005f72:	00e48ea3          	sb	a4,29(s1)
    80005f76:	00e48f23          	sb	a4,30(s1)
    80005f7a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f7e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f82:	0727a823          	sw	s2,112(a5)
}
    80005f86:	60e2                	ld	ra,24(sp)
    80005f88:	6442                	ld	s0,16(sp)
    80005f8a:	64a2                	ld	s1,8(sp)
    80005f8c:	6902                	ld	s2,0(sp)
    80005f8e:	6105                	addi	sp,sp,32
    80005f90:	8082                	ret
    panic("could not find virtio disk");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	82650513          	addi	a0,a0,-2010 # 800087b8 <syscalls+0x350>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	83650513          	addi	a0,a0,-1994 # 800087d8 <syscalls+0x370>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	84650513          	addi	a0,a0,-1978 # 800087f8 <syscalls+0x390>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	85650513          	addi	a0,a0,-1962 # 80008818 <syscalls+0x3b0>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fd2:	00003517          	auipc	a0,0x3
    80005fd6:	86650513          	addi	a0,a0,-1946 # 80008838 <syscalls+0x3d0>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fe2:	00003517          	auipc	a0,0x3
    80005fe6:	87650513          	addi	a0,a0,-1930 # 80008858 <syscalls+0x3f0>
    80005fea:	ffffa097          	auipc	ra,0xffffa
    80005fee:	552080e7          	jalr	1362(ra) # 8000053c <panic>

0000000080005ff2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ff2:	7159                	addi	sp,sp,-112
    80005ff4:	f486                	sd	ra,104(sp)
    80005ff6:	f0a2                	sd	s0,96(sp)
    80005ff8:	eca6                	sd	s1,88(sp)
    80005ffa:	e8ca                	sd	s2,80(sp)
    80005ffc:	e4ce                	sd	s3,72(sp)
    80005ffe:	e0d2                	sd	s4,64(sp)
    80006000:	fc56                	sd	s5,56(sp)
    80006002:	f85a                	sd	s6,48(sp)
    80006004:	f45e                	sd	s7,40(sp)
    80006006:	f062                	sd	s8,32(sp)
    80006008:	ec66                	sd	s9,24(sp)
    8000600a:	e86a                	sd	s10,16(sp)
    8000600c:	1880                	addi	s0,sp,112
    8000600e:	8a2a                	mv	s4,a0
    80006010:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006012:	00c52c83          	lw	s9,12(a0)
    80006016:	001c9c9b          	slliw	s9,s9,0x1
    8000601a:	1c82                	slli	s9,s9,0x20
    8000601c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006020:	0001c517          	auipc	a0,0x1c
    80006024:	d8850513          	addi	a0,a0,-632 # 80021da8 <disk+0x128>
    80006028:	ffffb097          	auipc	ra,0xffffb
    8000602c:	baa080e7          	jalr	-1110(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006030:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006032:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006034:	0001cb17          	auipc	s6,0x1c
    80006038:	c4cb0b13          	addi	s6,s6,-948 # 80021c80 <disk>
  for(int i = 0; i < 3; i++){
    8000603c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000603e:	0001cc17          	auipc	s8,0x1c
    80006042:	d6ac0c13          	addi	s8,s8,-662 # 80021da8 <disk+0x128>
    80006046:	a095                	j	800060aa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006048:	00fb0733          	add	a4,s6,a5
    8000604c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006050:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006052:	0207c563          	bltz	a5,8000607c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006056:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006058:	0591                	addi	a1,a1,4
    8000605a:	05560d63          	beq	a2,s5,800060b4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000605e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006060:	0001c717          	auipc	a4,0x1c
    80006064:	c2070713          	addi	a4,a4,-992 # 80021c80 <disk>
    80006068:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000606a:	01874683          	lbu	a3,24(a4)
    8000606e:	fee9                	bnez	a3,80006048 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006070:	2785                	addiw	a5,a5,1
    80006072:	0705                	addi	a4,a4,1
    80006074:	fe979be3          	bne	a5,s1,8000606a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006078:	57fd                	li	a5,-1
    8000607a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000607c:	00c05e63          	blez	a2,80006098 <virtio_disk_rw+0xa6>
    80006080:	060a                	slli	a2,a2,0x2
    80006082:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006086:	0009a503          	lw	a0,0(s3)
    8000608a:	00000097          	auipc	ra,0x0
    8000608e:	cfc080e7          	jalr	-772(ra) # 80005d86 <free_desc>
      for(int j = 0; j < i; j++)
    80006092:	0991                	addi	s3,s3,4
    80006094:	ffa999e3          	bne	s3,s10,80006086 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006098:	85e2                	mv	a1,s8
    8000609a:	0001c517          	auipc	a0,0x1c
    8000609e:	bfe50513          	addi	a0,a0,-1026 # 80021c98 <disk+0x18>
    800060a2:	ffffc097          	auipc	ra,0xffffc
    800060a6:	03e080e7          	jalr	62(ra) # 800020e0 <sleep>
  for(int i = 0; i < 3; i++){
    800060aa:	f9040993          	addi	s3,s0,-112
{
    800060ae:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800060b0:	864a                	mv	a2,s2
    800060b2:	b775                	j	8000605e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060b4:	f9042503          	lw	a0,-112(s0)
    800060b8:	00a50713          	addi	a4,a0,10
    800060bc:	0712                	slli	a4,a4,0x4

  if(write)
    800060be:	0001c797          	auipc	a5,0x1c
    800060c2:	bc278793          	addi	a5,a5,-1086 # 80021c80 <disk>
    800060c6:	00e786b3          	add	a3,a5,a4
    800060ca:	01703633          	snez	a2,s7
    800060ce:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060d0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060d4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060d8:	f6070613          	addi	a2,a4,-160
    800060dc:	6394                	ld	a3,0(a5)
    800060de:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060e0:	00870593          	addi	a1,a4,8
    800060e4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060e6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060e8:	0007b803          	ld	a6,0(a5)
    800060ec:	9642                	add	a2,a2,a6
    800060ee:	46c1                	li	a3,16
    800060f0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060f2:	4585                	li	a1,1
    800060f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060f8:	f9442683          	lw	a3,-108(s0)
    800060fc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006100:	0692                	slli	a3,a3,0x4
    80006102:	9836                	add	a6,a6,a3
    80006104:	058a0613          	addi	a2,s4,88
    80006108:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000610c:	0007b803          	ld	a6,0(a5)
    80006110:	96c2                	add	a3,a3,a6
    80006112:	40000613          	li	a2,1024
    80006116:	c690                	sw	a2,8(a3)
  if(write)
    80006118:	001bb613          	seqz	a2,s7
    8000611c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006120:	00166613          	ori	a2,a2,1
    80006124:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006128:	f9842603          	lw	a2,-104(s0)
    8000612c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006130:	00250693          	addi	a3,a0,2
    80006134:	0692                	slli	a3,a3,0x4
    80006136:	96be                	add	a3,a3,a5
    80006138:	58fd                	li	a7,-1
    8000613a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000613e:	0612                	slli	a2,a2,0x4
    80006140:	9832                	add	a6,a6,a2
    80006142:	f9070713          	addi	a4,a4,-112
    80006146:	973e                	add	a4,a4,a5
    80006148:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000614c:	6398                	ld	a4,0(a5)
    8000614e:	9732                	add	a4,a4,a2
    80006150:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006152:	4609                	li	a2,2
    80006154:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006158:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000615c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006160:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006164:	6794                	ld	a3,8(a5)
    80006166:	0026d703          	lhu	a4,2(a3)
    8000616a:	8b1d                	andi	a4,a4,7
    8000616c:	0706                	slli	a4,a4,0x1
    8000616e:	96ba                	add	a3,a3,a4
    80006170:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006174:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006178:	6798                	ld	a4,8(a5)
    8000617a:	00275783          	lhu	a5,2(a4)
    8000617e:	2785                	addiw	a5,a5,1
    80006180:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006184:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006190:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006194:	0001c917          	auipc	s2,0x1c
    80006198:	c1490913          	addi	s2,s2,-1004 # 80021da8 <disk+0x128>
  while(b->disk == 1) {
    8000619c:	4485                	li	s1,1
    8000619e:	00b79c63          	bne	a5,a1,800061b6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800061a2:	85ca                	mv	a1,s2
    800061a4:	8552                	mv	a0,s4
    800061a6:	ffffc097          	auipc	ra,0xffffc
    800061aa:	f3a080e7          	jalr	-198(ra) # 800020e0 <sleep>
  while(b->disk == 1) {
    800061ae:	004a2783          	lw	a5,4(s4)
    800061b2:	fe9788e3          	beq	a5,s1,800061a2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800061b6:	f9042903          	lw	s2,-112(s0)
    800061ba:	00290713          	addi	a4,s2,2
    800061be:	0712                	slli	a4,a4,0x4
    800061c0:	0001c797          	auipc	a5,0x1c
    800061c4:	ac078793          	addi	a5,a5,-1344 # 80021c80 <disk>
    800061c8:	97ba                	add	a5,a5,a4
    800061ca:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061ce:	0001c997          	auipc	s3,0x1c
    800061d2:	ab298993          	addi	s3,s3,-1358 # 80021c80 <disk>
    800061d6:	00491713          	slli	a4,s2,0x4
    800061da:	0009b783          	ld	a5,0(s3)
    800061de:	97ba                	add	a5,a5,a4
    800061e0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061e4:	854a                	mv	a0,s2
    800061e6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061ea:	00000097          	auipc	ra,0x0
    800061ee:	b9c080e7          	jalr	-1124(ra) # 80005d86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061f2:	8885                	andi	s1,s1,1
    800061f4:	f0ed                	bnez	s1,800061d6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061f6:	0001c517          	auipc	a0,0x1c
    800061fa:	bb250513          	addi	a0,a0,-1102 # 80021da8 <disk+0x128>
    800061fe:	ffffb097          	auipc	ra,0xffffb
    80006202:	a9e080e7          	jalr	-1378(ra) # 80000c9c <release>
}
    80006206:	70a6                	ld	ra,104(sp)
    80006208:	7406                	ld	s0,96(sp)
    8000620a:	64e6                	ld	s1,88(sp)
    8000620c:	6946                	ld	s2,80(sp)
    8000620e:	69a6                	ld	s3,72(sp)
    80006210:	6a06                	ld	s4,64(sp)
    80006212:	7ae2                	ld	s5,56(sp)
    80006214:	7b42                	ld	s6,48(sp)
    80006216:	7ba2                	ld	s7,40(sp)
    80006218:	7c02                	ld	s8,32(sp)
    8000621a:	6ce2                	ld	s9,24(sp)
    8000621c:	6d42                	ld	s10,16(sp)
    8000621e:	6165                	addi	sp,sp,112
    80006220:	8082                	ret

0000000080006222 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006222:	1101                	addi	sp,sp,-32
    80006224:	ec06                	sd	ra,24(sp)
    80006226:	e822                	sd	s0,16(sp)
    80006228:	e426                	sd	s1,8(sp)
    8000622a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000622c:	0001c497          	auipc	s1,0x1c
    80006230:	a5448493          	addi	s1,s1,-1452 # 80021c80 <disk>
    80006234:	0001c517          	auipc	a0,0x1c
    80006238:	b7450513          	addi	a0,a0,-1164 # 80021da8 <disk+0x128>
    8000623c:	ffffb097          	auipc	ra,0xffffb
    80006240:	996080e7          	jalr	-1642(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006244:	10001737          	lui	a4,0x10001
    80006248:	533c                	lw	a5,96(a4)
    8000624a:	8b8d                	andi	a5,a5,3
    8000624c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000624e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006252:	689c                	ld	a5,16(s1)
    80006254:	0204d703          	lhu	a4,32(s1)
    80006258:	0027d783          	lhu	a5,2(a5)
    8000625c:	04f70863          	beq	a4,a5,800062ac <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006260:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006264:	6898                	ld	a4,16(s1)
    80006266:	0204d783          	lhu	a5,32(s1)
    8000626a:	8b9d                	andi	a5,a5,7
    8000626c:	078e                	slli	a5,a5,0x3
    8000626e:	97ba                	add	a5,a5,a4
    80006270:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006272:	00278713          	addi	a4,a5,2
    80006276:	0712                	slli	a4,a4,0x4
    80006278:	9726                	add	a4,a4,s1
    8000627a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000627e:	e721                	bnez	a4,800062c6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006280:	0789                	addi	a5,a5,2
    80006282:	0792                	slli	a5,a5,0x4
    80006284:	97a6                	add	a5,a5,s1
    80006286:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006288:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000628c:	ffffc097          	auipc	ra,0xffffc
    80006290:	eb8080e7          	jalr	-328(ra) # 80002144 <wakeup>

    disk.used_idx += 1;
    80006294:	0204d783          	lhu	a5,32(s1)
    80006298:	2785                	addiw	a5,a5,1
    8000629a:	17c2                	slli	a5,a5,0x30
    8000629c:	93c1                	srli	a5,a5,0x30
    8000629e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062a2:	6898                	ld	a4,16(s1)
    800062a4:	00275703          	lhu	a4,2(a4)
    800062a8:	faf71ce3          	bne	a4,a5,80006260 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800062ac:	0001c517          	auipc	a0,0x1c
    800062b0:	afc50513          	addi	a0,a0,-1284 # 80021da8 <disk+0x128>
    800062b4:	ffffb097          	auipc	ra,0xffffb
    800062b8:	9e8080e7          	jalr	-1560(ra) # 80000c9c <release>
}
    800062bc:	60e2                	ld	ra,24(sp)
    800062be:	6442                	ld	s0,16(sp)
    800062c0:	64a2                	ld	s1,8(sp)
    800062c2:	6105                	addi	sp,sp,32
    800062c4:	8082                	ret
      panic("virtio_disk_intr status");
    800062c6:	00002517          	auipc	a0,0x2
    800062ca:	5aa50513          	addi	a0,a0,1450 # 80008870 <syscalls+0x408>
    800062ce:	ffffa097          	auipc	ra,0xffffa
    800062d2:	26e080e7          	jalr	622(ra) # 8000053c <panic>
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
