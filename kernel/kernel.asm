
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	91013103          	ld	sp,-1776(sp) # 80008910 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	92070713          	addi	a4,a4,-1760 # 80008970 <timer_scratch>
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
    80000066:	d5e78793          	addi	a5,a5,-674 # 80005dc0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca1f>
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
    8000012e:	496080e7          	jalr	1174(ra) # 800025c0 <either_copyin>
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
    80000188:	92c50513          	addi	a0,a0,-1748 # 80010ab0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	91c48493          	addi	s1,s1,-1764 # 80010ab0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	9ac90913          	addi	s2,s2,-1620 # 80010b48 <cons+0x98>
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
    800001c0:	24e080e7          	jalr	590(ra) # 8000240a <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f98080e7          	jalr	-104(ra) # 80002162 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	8d270713          	addi	a4,a4,-1838 # 80010ab0 <cons>
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
    80000214:	35a080e7          	jalr	858(ra) # 8000256a <either_copyout>
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
    8000022c:	88850513          	addi	a0,a0,-1912 # 80010ab0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a6c080e7          	jalr	-1428(ra) # 80000c9c <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	87250513          	addi	a0,a0,-1934 # 80010ab0 <cons>
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
    80000272:	8cf72d23          	sw	a5,-1830(a4) # 80010b48 <cons+0x98>
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
    800002cc:	7e850513          	addi	a0,a0,2024 # 80010ab0 <cons>
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
    800002f2:	328080e7          	jalr	808(ra) # 80002616 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	7ba50513          	addi	a0,a0,1978 # 80010ab0 <cons>
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
    8000031e:	79670713          	addi	a4,a4,1942 # 80010ab0 <cons>
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
    80000348:	76c78793          	addi	a5,a5,1900 # 80010ab0 <cons>
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
    80000376:	7d67a783          	lw	a5,2006(a5) # 80010b48 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	72a70713          	addi	a4,a4,1834 # 80010ab0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	71a48493          	addi	s1,s1,1818 # 80010ab0 <cons>
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
    800003d6:	6de70713          	addi	a4,a4,1758 # 80010ab0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	76f72423          	sw	a5,1896(a4) # 80010b50 <cons+0xa0>
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
    80000412:	6a278793          	addi	a5,a5,1698 # 80010ab0 <cons>
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
    80000436:	70c7ad23          	sw	a2,1818(a5) # 80010b4c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	70e50513          	addi	a0,a0,1806 # 80010b48 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d84080e7          	jalr	-636(ra) # 800021c6 <wakeup>
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
    80000460:	65450513          	addi	a0,a0,1620 # 80010ab0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	7d478793          	addi	a5,a5,2004 # 80020c48 <devsw>
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
    8000054c:	6207a423          	sw	zero,1576(a5) # 80010b70 <pr+0x18>
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
    80000580:	3af72a23          	sw	a5,948(a4) # 80008930 <panicked>
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
    800005bc:	5b8dad83          	lw	s11,1464(s11) # 80010b70 <pr+0x18>
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
    800005fa:	56250513          	addi	a0,a0,1378 # 80010b58 <pr>
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
    80000758:	40450513          	addi	a0,a0,1028 # 80010b58 <pr>
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
    80000774:	3e848493          	addi	s1,s1,1000 # 80010b58 <pr>
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
    800007d4:	3a850513          	addi	a0,a0,936 # 80010b78 <uart_tx_lock>
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
    80000800:	1347a783          	lw	a5,308(a5) # 80008930 <panicked>
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
    80000838:	1047b783          	ld	a5,260(a5) # 80008938 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	10473703          	ld	a4,260(a4) # 80008940 <uart_tx_w>
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
    80000862:	31aa0a13          	addi	s4,s4,794 # 80010b78 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	0d248493          	addi	s1,s1,210 # 80008938 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	0d298993          	addi	s3,s3,210 # 80008940 <uart_tx_w>
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
    80000894:	936080e7          	jalr	-1738(ra) # 800021c6 <wakeup>
    
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
    800008d0:	2ac50513          	addi	a0,a0,684 # 80010b78 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0547a783          	lw	a5,84(a5) # 80008930 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	05a73703          	ld	a4,90(a4) # 80008940 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	04a7b783          	ld	a5,74(a5) # 80008938 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	27e98993          	addi	s3,s3,638 # 80010b78 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	03648493          	addi	s1,s1,54 # 80008938 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	03690913          	addi	s2,s2,54 # 80008940 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	848080e7          	jalr	-1976(ra) # 80002162 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	24848493          	addi	s1,s1,584 # 80010b78 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	fee7be23          	sd	a4,-4(a5) # 80008940 <uart_tx_w>
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
    800009ba:	1c248493          	addi	s1,s1,450 # 80010b78 <uart_tx_lock>
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
    800009fc:	3e878793          	addi	a5,a5,1000 # 80021de0 <end>
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
    80000a1c:	19890913          	addi	s2,s2,408 # 80010bb0 <kmem>
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
    80000aba:	0fa50513          	addi	a0,a0,250 # 80010bb0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	31650513          	addi	a0,a0,790 # 80021de0 <end>
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
    80000af0:	0c448493          	addi	s1,s1,196 # 80010bb0 <kmem>
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
    80000b08:	0ac50513          	addi	a0,a0,172 # 80010bb0 <kmem>
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
    80000b34:	08050513          	addi	a0,a0,128 # 80010bb0 <kmem>
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
    80000d58:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd221>
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
    80000e9c:	ab070713          	addi	a4,a4,-1360 # 80008948 <started>
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
    80000ed2:	88a080e7          	jalr	-1910(ra) # 80002758 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed6:	00005097          	auipc	ra,0x5
    80000eda:	f2a080e7          	jalr	-214(ra) # 80005e00 <plicinithart>
  }

  scheduler();        
    80000ede:	00001097          	auipc	ra,0x1
    80000ee2:	fe4080e7          	jalr	-28(ra) # 80001ec2 <scheduler>
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
    80000f4a:	7ea080e7          	jalr	2026(ra) # 80002730 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4e:	00002097          	auipc	ra,0x2
    80000f52:	80a080e7          	jalr	-2038(ra) # 80002758 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	e94080e7          	jalr	-364(ra) # 80005dea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5e:	00005097          	auipc	ra,0x5
    80000f62:	ea2080e7          	jalr	-350(ra) # 80005e00 <plicinithart>
    binit();         // buffer cache
    80000f66:	00002097          	auipc	ra,0x2
    80000f6a:	094080e7          	jalr	148(ra) # 80002ffa <binit>
    iinit();         // inode table
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	732080e7          	jalr	1842(ra) # 800036a0 <iinit>
    fileinit();      // file table
    80000f76:	00003097          	auipc	ra,0x3
    80000f7a:	6a8080e7          	jalr	1704(ra) # 8000461e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	f8a080e7          	jalr	-118(ra) # 80005f08 <virtio_disk_init>
    userinit();      // first user process
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	d16080e7          	jalr	-746(ra) # 80001c9c <userinit>
    __sync_synchronize();
    80000f8e:	0ff0000f          	fence
    started = 1;
    80000f92:	4785                	li	a5,1
    80000f94:	00008717          	auipc	a4,0x8
    80000f98:	9af72a23          	sw	a5,-1612(a4) # 80008948 <started>
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
    80000fac:	9a87b783          	ld	a5,-1624(a5) # 80008950 <kernel_pagetable>
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
    80001026:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd217>
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
    80001268:	6ea7b623          	sd	a0,1772(a5) # 80008950 <kernel_pagetable>
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
    8000181a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd220>
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
    80001860:	7a448493          	addi	s1,s1,1956 # 80011000 <proc>
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
    8000187a:	18aa0a13          	addi	s4,s4,394 # 80016a00 <tickslock>
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
    800018fc:	2d850513          	addi	a0,a0,728 # 80010bd0 <pid_lock>
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	242080e7          	jalr	578(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001908:	00007597          	auipc	a1,0x7
    8000190c:	8f858593          	addi	a1,a1,-1800 # 80008200 <digits+0x1c0>
    80001910:	0000f517          	auipc	a0,0xf
    80001914:	2d850513          	addi	a0,a0,728 # 80010be8 <wait_lock>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	22a080e7          	jalr	554(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	0000f497          	auipc	s1,0xf
    80001924:	6e048493          	addi	s1,s1,1760 # 80011000 <proc>
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
    80001946:	0be98993          	addi	s3,s3,190 # 80016a00 <tickslock>
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
    800019b0:	25450513          	addi	a0,a0,596 # 80010c00 <cpus>
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
    800019d8:	1fc70713          	addi	a4,a4,508 # 80010bd0 <pid_lock>
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
    80001a10:	eb47a783          	lw	a5,-332(a5) # 800088c0 <first.1>
    80001a14:	eb89                	bnez	a5,80001a26 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a16:	00001097          	auipc	ra,0x1
    80001a1a:	d5a080e7          	jalr	-678(ra) # 80002770 <usertrapret>
}
    80001a1e:	60a2                	ld	ra,8(sp)
    80001a20:	6402                	ld	s0,0(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret
    first = 0;
    80001a26:	00007797          	auipc	a5,0x7
    80001a2a:	e807ad23          	sw	zero,-358(a5) # 800088c0 <first.1>
    fsinit(ROOTDEV);
    80001a2e:	4505                	li	a0,1
    80001a30:	00002097          	auipc	ra,0x2
    80001a34:	bf0080e7          	jalr	-1040(ra) # 80003620 <fsinit>
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
    80001a4a:	18a90913          	addi	s2,s2,394 # 80010bd0 <pid_lock>
    80001a4e:	854a                	mv	a0,s2
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	182080e7          	jalr	386(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a58:	00007797          	auipc	a5,0x7
    80001a5c:	e6c78793          	addi	a5,a5,-404 # 800088c4 <nextpid>
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
    80001bda:	42a48493          	addi	s1,s1,1066 # 80011000 <proc>
    80001bde:	00015917          	auipc	s2,0x15
    80001be2:	e2290913          	addi	s2,s2,-478 # 80016a00 <tickslock>
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
  p->prio  = HIGHEST;
    80001c18:	0204aa23          	sw	zero,52(s1)
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
    80001cb4:	caa7b423          	sd	a0,-856(a5) # 80008958 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb8:	03400613          	li	a2,52
    80001cbc:	00007597          	auipc	a1,0x7
    80001cc0:	c1458593          	addi	a1,a1,-1004 # 800088d0 <initcode>
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
    80001cfe:	344080e7          	jalr	836(ra) # 8000403e <namei>
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
    80001d9e:	12050063          	beqz	a0,80001ebe <fork+0x144>
    80001da2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da4:	048ab603          	ld	a2,72(s5)
    80001da8:	692c                	ld	a1,80(a0)
    80001daa:	050ab503          	ld	a0,80(s5)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	7ca080e7          	jalr	1994(ra) # 80001578 <uvmcopy>
    80001db6:	04054863          	bltz	a0,80001e06 <fork+0x8c>
  np->sz = p->sz;
    80001dba:	048ab783          	ld	a5,72(s5)
    80001dbe:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc2:	058ab683          	ld	a3,88(s5)
    80001dc6:	87b6                	mv	a5,a3
    80001dc8:	0589b703          	ld	a4,88(s3)
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
    80001df0:	0589b783          	ld	a5,88(s3)
    80001df4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001df8:	0d0a8493          	addi	s1,s5,208
    80001dfc:	0d098913          	addi	s2,s3,208
    80001e00:	150a8a13          	addi	s4,s5,336
    80001e04:	a00d                	j	80001e26 <fork+0xac>
    freeproc(np);
    80001e06:	854e                	mv	a0,s3
    80001e08:	00000097          	auipc	ra,0x0
    80001e0c:	d66080e7          	jalr	-666(ra) # 80001b6e <freeproc>
    release(&np->lock);
    80001e10:	854e                	mv	a0,s3
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	e8a080e7          	jalr	-374(ra) # 80000c9c <release>
    return -1;
    80001e1a:	597d                	li	s2,-1
    80001e1c:	a079                	j	80001eaa <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e1e:	04a1                	addi	s1,s1,8
    80001e20:	0921                	addi	s2,s2,8
    80001e22:	01448b63          	beq	s1,s4,80001e38 <fork+0xbe>
    if(p->ofile[i])
    80001e26:	6088                	ld	a0,0(s1)
    80001e28:	d97d                	beqz	a0,80001e1e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e2a:	00003097          	auipc	ra,0x3
    80001e2e:	886080e7          	jalr	-1914(ra) # 800046b0 <filedup>
    80001e32:	00a93023          	sd	a0,0(s2)
    80001e36:	b7e5                	j	80001e1e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e38:	150ab503          	ld	a0,336(s5)
    80001e3c:	00002097          	auipc	ra,0x2
    80001e40:	a1e080e7          	jalr	-1506(ra) # 8000385a <idup>
    80001e44:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e48:	4641                	li	a2,16
    80001e4a:	158a8593          	addi	a1,s5,344
    80001e4e:	15898513          	addi	a0,s3,344
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	fda080e7          	jalr	-38(ra) # 80000e2c <safestrcpy>
  pid = np->pid;
    80001e5a:	0309a903          	lw	s2,48(s3)
  np->prio = p->prio;
    80001e5e:	034aa783          	lw	a5,52(s5)
    80001e62:	02f9aa23          	sw	a5,52(s3)
  release(&np->lock);
    80001e66:	854e                	mv	a0,s3
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e34080e7          	jalr	-460(ra) # 80000c9c <release>
  acquire(&wait_lock);
    80001e70:	0000f497          	auipc	s1,0xf
    80001e74:	d7848493          	addi	s1,s1,-648 # 80010be8 <wait_lock>
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d58080e7          	jalr	-680(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e82:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e86:	8526                	mv	a0,s1
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	e14080e7          	jalr	-492(ra) # 80000c9c <release>
  acquire(&np->lock);
    80001e90:	854e                	mv	a0,s3
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	d40080e7          	jalr	-704(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e9a:	478d                	li	a5,3
    80001e9c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea0:	854e                	mv	a0,s3
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	dfa080e7          	jalr	-518(ra) # 80000c9c <release>
}
    80001eaa:	854a                	mv	a0,s2
    80001eac:	70e2                	ld	ra,56(sp)
    80001eae:	7442                	ld	s0,48(sp)
    80001eb0:	74a2                	ld	s1,40(sp)
    80001eb2:	7902                	ld	s2,32(sp)
    80001eb4:	69e2                	ld	s3,24(sp)
    80001eb6:	6a42                	ld	s4,16(sp)
    80001eb8:	6aa2                	ld	s5,8(sp)
    80001eba:	6121                	addi	sp,sp,64
    80001ebc:	8082                	ret
    return -1;
    80001ebe:	597d                	li	s2,-1
    80001ec0:	b7ed                	j	80001eaa <fork+0x130>

0000000080001ec2 <scheduler>:
{
    80001ec2:	715d                	addi	sp,sp,-80
    80001ec4:	e486                	sd	ra,72(sp)
    80001ec6:	e0a2                	sd	s0,64(sp)
    80001ec8:	fc26                	sd	s1,56(sp)
    80001eca:	f84a                	sd	s2,48(sp)
    80001ecc:	f44e                	sd	s3,40(sp)
    80001ece:	f052                	sd	s4,32(sp)
    80001ed0:	ec56                	sd	s5,24(sp)
    80001ed2:	e85a                	sd	s6,16(sp)
    80001ed4:	e45e                	sd	s7,8(sp)
    80001ed6:	0880                	addi	s0,sp,80
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001edc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ede:	10079073          	csrw	sstatus,a5
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ee2:	8792                	mv	a5,tp
  int id = r_tp();
    80001ee4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ee6:	00779b13          	slli	s6,a5,0x7
    80001eea:	0000f717          	auipc	a4,0xf
    80001eee:	ce670713          	addi	a4,a4,-794 # 80010bd0 <pid_lock>
    80001ef2:	975a                	add	a4,a4,s6
    80001ef4:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &n->context);
    80001ef8:	0000f717          	auipc	a4,0xf
    80001efc:	d1070713          	addi	a4,a4,-752 # 80010c08 <cpus+0x8>
    80001f00:	9b3a                	add	s6,s6,a4
      if(n->state == RUNNABLE){
    80001f02:	490d                	li	s2,3
    for(n = proc; n < &proc[NPROC]; n++){
    80001f04:	00015997          	auipc	s3,0x15
    80001f08:	afc98993          	addi	s3,s3,-1284 # 80016a00 <tickslock>
      c->proc = n;
    80001f0c:	079e                	slli	a5,a5,0x7
    80001f0e:	0000fa17          	auipc	s4,0xf
    80001f12:	cc2a0a13          	addi	s4,s4,-830 # 80010bd0 <pid_lock>
    80001f16:	9a3e                	add	s4,s4,a5
      n->state = RUNNING;
    80001f18:	4a91                	li	s5,4
    80001f1a:	a0b1                	j	80001f66 <scheduler+0xa4>
      release(&n->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	d7e080e7          	jalr	-642(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001f26:	16848493          	addi	s1,s1,360
    80001f2a:	05348963          	beq	s1,s3,80001f7c <scheduler+0xba>
      acquire(&n->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	ca2080e7          	jalr	-862(ra) # 80000bd2 <acquire>
      if(n->state == RUNNABLE){
    80001f38:	4c9c                	lw	a5,24(s1)
    80001f3a:	ff2791e3          	bne	a5,s2,80001f1c <scheduler+0x5a>
        if(n-> prio == HIGHEST){
    80001f3e:	58dc                	lw	a5,52(s1)
    80001f40:	fff1                	bnez	a5,80001f1c <scheduler+0x5a>
      c->proc = n;
    80001f42:	029a3823          	sd	s1,48(s4)
      n->state = RUNNING;
    80001f46:	0154ac23          	sw	s5,24(s1)
      swtch(&c->context, &n->context);
    80001f4a:	06048593          	addi	a1,s1,96
    80001f4e:	855a                	mv	a0,s6
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	776080e7          	jalr	1910(ra) # 800026c6 <swtch>
      c->proc = 0;
    80001f58:	020a3823          	sd	zero,48(s4)
      release(&n->lock);
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	d3e080e7          	jalr	-706(ra) # 80000c9c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f6e:	10079073          	csrw	sstatus,a5
    for(n = proc; n < &proc[NPROC]; n++){
    80001f72:	0000f497          	auipc	s1,0xf
    80001f76:	08e48493          	addi	s1,s1,142 # 80011000 <proc>
    80001f7a:	bf55                	j	80001f2e <scheduler+0x6c>
    for(n = proc; n < &proc[NPROC]; n++){
    80001f7c:	0000f497          	auipc	s1,0xf
    80001f80:	08448493          	addi	s1,s1,132 # 80011000 <proc>
        if(n-> prio == HIGH){
    80001f84:	4b85                	li	s7,1
    80001f86:	a811                	j	80001f9a <scheduler+0xd8>
      release(&n->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	fffff097          	auipc	ra,0xfffff
    80001f8e:	d12080e7          	jalr	-750(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001f92:	16848493          	addi	s1,s1,360
    80001f96:	01348e63          	beq	s1,s3,80001fb2 <scheduler+0xf0>
      acquire(&n->lock);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	c36080e7          	jalr	-970(ra) # 80000bd2 <acquire>
      if(n->state == RUNNABLE){
    80001fa4:	4c9c                	lw	a5,24(s1)
    80001fa6:	ff2791e3          	bne	a5,s2,80001f88 <scheduler+0xc6>
        if(n-> prio == HIGH){
    80001faa:	58dc                	lw	a5,52(s1)
    80001fac:	fd779ee3          	bne	a5,s7,80001f88 <scheduler+0xc6>
    80001fb0:	bf49                	j	80001f42 <scheduler+0x80>
    for(n = proc; n < &proc[NPROC]; n++){
    80001fb2:	0000f497          	auipc	s1,0xf
    80001fb6:	04e48493          	addi	s1,s1,78 # 80011000 <proc>
        if(n-> prio == MIDDLE){
    80001fba:	4b89                	li	s7,2
    80001fbc:	a811                	j	80001fd0 <scheduler+0x10e>
      release(&n->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	cdc080e7          	jalr	-804(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001fc8:	16848493          	addi	s1,s1,360
    80001fcc:	01348e63          	beq	s1,s3,80001fe8 <scheduler+0x126>
      acquire(&n->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	c00080e7          	jalr	-1024(ra) # 80000bd2 <acquire>
      if(n->state == RUNNABLE){
    80001fda:	4c9c                	lw	a5,24(s1)
    80001fdc:	ff2791e3          	bne	a5,s2,80001fbe <scheduler+0xfc>
        if(n-> prio == MIDDLE){
    80001fe0:	58dc                	lw	a5,52(s1)
    80001fe2:	fd779ee3          	bne	a5,s7,80001fbe <scheduler+0xfc>
    80001fe6:	bfb1                	j	80001f42 <scheduler+0x80>
    for(n = proc; n < &proc[NPROC]; n++){
    80001fe8:	0000f497          	auipc	s1,0xf
    80001fec:	01848493          	addi	s1,s1,24 # 80011000 <proc>
    80001ff0:	a811                	j	80002004 <scheduler+0x142>
      release(&n->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	ca8080e7          	jalr	-856(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80001ffc:	16848493          	addi	s1,s1,360
    80002000:	01348e63          	beq	s1,s3,8000201c <scheduler+0x15a>
      acquire(&n->lock);
    80002004:	8526                	mv	a0,s1
    80002006:	fffff097          	auipc	ra,0xfffff
    8000200a:	bcc080e7          	jalr	-1076(ra) # 80000bd2 <acquire>
      if(n->state == RUNNABLE){
    8000200e:	4c9c                	lw	a5,24(s1)
    80002010:	ff2791e3          	bne	a5,s2,80001ff2 <scheduler+0x130>
        if(n-> prio == LOW){
    80002014:	58dc                	lw	a5,52(s1)
    80002016:	fd279ee3          	bne	a5,s2,80001ff2 <scheduler+0x130>
    8000201a:	b725                	j	80001f42 <scheduler+0x80>
    for(n = proc; n < &proc[NPROC]; n++){
    8000201c:	0000f497          	auipc	s1,0xf
    80002020:	fe448493          	addi	s1,s1,-28 # 80011000 <proc>
    80002024:	a811                	j	80002038 <scheduler+0x176>
      release(&n->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	c74080e7          	jalr	-908(ra) # 80000c9c <release>
    for(n = proc; n < &proc[NPROC]; n++){
    80002030:	16848493          	addi	s1,s1,360
    80002034:	f33489e3          	beq	s1,s3,80001f66 <scheduler+0xa4>
      acquire(&n->lock);
    80002038:	8526                	mv	a0,s1
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	b98080e7          	jalr	-1128(ra) # 80000bd2 <acquire>
      if(n->state == RUNNABLE){
    80002042:	4c9c                	lw	a5,24(s1)
    80002044:	ff2791e3          	bne	a5,s2,80002026 <scheduler+0x164>
        if(n-> prio == LOWEST){
    80002048:	58dc                	lw	a5,52(s1)
    8000204a:	fd579ee3          	bne	a5,s5,80002026 <scheduler+0x164>
    8000204e:	bdd5                	j	80001f42 <scheduler+0x80>

0000000080002050 <sched>:
{
    80002050:	7179                	addi	sp,sp,-48
    80002052:	f406                	sd	ra,40(sp)
    80002054:	f022                	sd	s0,32(sp)
    80002056:	ec26                	sd	s1,24(sp)
    80002058:	e84a                	sd	s2,16(sp)
    8000205a:	e44e                	sd	s3,8(sp)
    8000205c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	95e080e7          	jalr	-1698(ra) # 800019bc <myproc>
    80002066:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	af0080e7          	jalr	-1296(ra) # 80000b58 <holding>
    80002070:	c93d                	beqz	a0,800020e6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002072:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002074:	2781                	sext.w	a5,a5
    80002076:	079e                	slli	a5,a5,0x7
    80002078:	0000f717          	auipc	a4,0xf
    8000207c:	b5870713          	addi	a4,a4,-1192 # 80010bd0 <pid_lock>
    80002080:	97ba                	add	a5,a5,a4
    80002082:	0a87a703          	lw	a4,168(a5)
    80002086:	4785                	li	a5,1
    80002088:	06f71763          	bne	a4,a5,800020f6 <sched+0xa6>
  if(p->state == RUNNING)
    8000208c:	4c98                	lw	a4,24(s1)
    8000208e:	4791                	li	a5,4
    80002090:	06f70b63          	beq	a4,a5,80002106 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002094:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002098:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000209a:	efb5                	bnez	a5,80002116 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000209c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000209e:	0000f917          	auipc	s2,0xf
    800020a2:	b3290913          	addi	s2,s2,-1230 # 80010bd0 <pid_lock>
    800020a6:	2781                	sext.w	a5,a5
    800020a8:	079e                	slli	a5,a5,0x7
    800020aa:	97ca                	add	a5,a5,s2
    800020ac:	0ac7a983          	lw	s3,172(a5)
    800020b0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	0000f597          	auipc	a1,0xf
    800020ba:	b5258593          	addi	a1,a1,-1198 # 80010c08 <cpus+0x8>
    800020be:	95be                	add	a1,a1,a5
    800020c0:	06048513          	addi	a0,s1,96
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	602080e7          	jalr	1538(ra) # 800026c6 <swtch>
    800020cc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020ce:	2781                	sext.w	a5,a5
    800020d0:	079e                	slli	a5,a5,0x7
    800020d2:	993e                	add	s2,s2,a5
    800020d4:	0b392623          	sw	s3,172(s2)
}
    800020d8:	70a2                	ld	ra,40(sp)
    800020da:	7402                	ld	s0,32(sp)
    800020dc:	64e2                	ld	s1,24(sp)
    800020de:	6942                	ld	s2,16(sp)
    800020e0:	69a2                	ld	s3,8(sp)
    800020e2:	6145                	addi	sp,sp,48
    800020e4:	8082                	ret
    panic("sched p->lock");
    800020e6:	00006517          	auipc	a0,0x6
    800020ea:	14a50513          	addi	a0,a0,330 # 80008230 <digits+0x1f0>
    800020ee:	ffffe097          	auipc	ra,0xffffe
    800020f2:	44e080e7          	jalr	1102(ra) # 8000053c <panic>
    panic("sched locks");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	14a50513          	addi	a0,a0,330 # 80008240 <digits+0x200>
    800020fe:	ffffe097          	auipc	ra,0xffffe
    80002102:	43e080e7          	jalr	1086(ra) # 8000053c <panic>
    panic("sched running");
    80002106:	00006517          	auipc	a0,0x6
    8000210a:	14a50513          	addi	a0,a0,330 # 80008250 <digits+0x210>
    8000210e:	ffffe097          	auipc	ra,0xffffe
    80002112:	42e080e7          	jalr	1070(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002116:	00006517          	auipc	a0,0x6
    8000211a:	14a50513          	addi	a0,a0,330 # 80008260 <digits+0x220>
    8000211e:	ffffe097          	auipc	ra,0xffffe
    80002122:	41e080e7          	jalr	1054(ra) # 8000053c <panic>

0000000080002126 <yield>:
{
    80002126:	1101                	addi	sp,sp,-32
    80002128:	ec06                	sd	ra,24(sp)
    8000212a:	e822                	sd	s0,16(sp)
    8000212c:	e426                	sd	s1,8(sp)
    8000212e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	88c080e7          	jalr	-1908(ra) # 800019bc <myproc>
    80002138:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	a98080e7          	jalr	-1384(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002142:	478d                	li	a5,3
    80002144:	cc9c                	sw	a5,24(s1)
  sched();
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	f0a080e7          	jalr	-246(ra) # 80002050 <sched>
  release(&p->lock);
    8000214e:	8526                	mv	a0,s1
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b4c080e7          	jalr	-1204(ra) # 80000c9c <release>
}
    80002158:	60e2                	ld	ra,24(sp)
    8000215a:	6442                	ld	s0,16(sp)
    8000215c:	64a2                	ld	s1,8(sp)
    8000215e:	6105                	addi	sp,sp,32
    80002160:	8082                	ret

0000000080002162 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002162:	7179                	addi	sp,sp,-48
    80002164:	f406                	sd	ra,40(sp)
    80002166:	f022                	sd	s0,32(sp)
    80002168:	ec26                	sd	s1,24(sp)
    8000216a:	e84a                	sd	s2,16(sp)
    8000216c:	e44e                	sd	s3,8(sp)
    8000216e:	1800                	addi	s0,sp,48
    80002170:	89aa                	mv	s3,a0
    80002172:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002174:	00000097          	auipc	ra,0x0
    80002178:	848080e7          	jalr	-1976(ra) # 800019bc <myproc>
    8000217c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	a54080e7          	jalr	-1452(ra) # 80000bd2 <acquire>
  release(lk);
    80002186:	854a                	mv	a0,s2
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	b14080e7          	jalr	-1260(ra) # 80000c9c <release>

  // Go to sleep.
  p->chan = chan;
    80002190:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002194:	4789                	li	a5,2
    80002196:	cc9c                	sw	a5,24(s1)

  sched();
    80002198:	00000097          	auipc	ra,0x0
    8000219c:	eb8080e7          	jalr	-328(ra) # 80002050 <sched>

  // Tidy up.
  p->chan = 0;
    800021a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	af6080e7          	jalr	-1290(ra) # 80000c9c <release>
  acquire(lk);
    800021ae:	854a                	mv	a0,s2
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	a22080e7          	jalr	-1502(ra) # 80000bd2 <acquire>
}
    800021b8:	70a2                	ld	ra,40(sp)
    800021ba:	7402                	ld	s0,32(sp)
    800021bc:	64e2                	ld	s1,24(sp)
    800021be:	6942                	ld	s2,16(sp)
    800021c0:	69a2                	ld	s3,8(sp)
    800021c2:	6145                	addi	sp,sp,48
    800021c4:	8082                	ret

00000000800021c6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021c6:	7139                	addi	sp,sp,-64
    800021c8:	fc06                	sd	ra,56(sp)
    800021ca:	f822                	sd	s0,48(sp)
    800021cc:	f426                	sd	s1,40(sp)
    800021ce:	f04a                	sd	s2,32(sp)
    800021d0:	ec4e                	sd	s3,24(sp)
    800021d2:	e852                	sd	s4,16(sp)
    800021d4:	e456                	sd	s5,8(sp)
    800021d6:	0080                	addi	s0,sp,64
    800021d8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021da:	0000f497          	auipc	s1,0xf
    800021de:	e2648493          	addi	s1,s1,-474 # 80011000 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021e2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021e4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021e6:	00015917          	auipc	s2,0x15
    800021ea:	81a90913          	addi	s2,s2,-2022 # 80016a00 <tickslock>
    800021ee:	a811                	j	80002202 <wakeup+0x3c>
      }
      release(&p->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	aaa080e7          	jalr	-1366(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021fa:	16848493          	addi	s1,s1,360
    800021fe:	03248663          	beq	s1,s2,8000222a <wakeup+0x64>
    if(p != myproc()){
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	7ba080e7          	jalr	1978(ra) # 800019bc <myproc>
    8000220a:	fea488e3          	beq	s1,a0,800021fa <wakeup+0x34>
      acquire(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	9c2080e7          	jalr	-1598(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002218:	4c9c                	lw	a5,24(s1)
    8000221a:	fd379be3          	bne	a5,s3,800021f0 <wakeup+0x2a>
    8000221e:	709c                	ld	a5,32(s1)
    80002220:	fd4798e3          	bne	a5,s4,800021f0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002224:	0154ac23          	sw	s5,24(s1)
    80002228:	b7e1                	j	800021f0 <wakeup+0x2a>
    }
  }
}
    8000222a:	70e2                	ld	ra,56(sp)
    8000222c:	7442                	ld	s0,48(sp)
    8000222e:	74a2                	ld	s1,40(sp)
    80002230:	7902                	ld	s2,32(sp)
    80002232:	69e2                	ld	s3,24(sp)
    80002234:	6a42                	ld	s4,16(sp)
    80002236:	6aa2                	ld	s5,8(sp)
    80002238:	6121                	addi	sp,sp,64
    8000223a:	8082                	ret

000000008000223c <reparent>:
{
    8000223c:	7179                	addi	sp,sp,-48
    8000223e:	f406                	sd	ra,40(sp)
    80002240:	f022                	sd	s0,32(sp)
    80002242:	ec26                	sd	s1,24(sp)
    80002244:	e84a                	sd	s2,16(sp)
    80002246:	e44e                	sd	s3,8(sp)
    80002248:	e052                	sd	s4,0(sp)
    8000224a:	1800                	addi	s0,sp,48
    8000224c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000224e:	0000f497          	auipc	s1,0xf
    80002252:	db248493          	addi	s1,s1,-590 # 80011000 <proc>
      pp->parent = initproc;
    80002256:	00006a17          	auipc	s4,0x6
    8000225a:	702a0a13          	addi	s4,s4,1794 # 80008958 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000225e:	00014997          	auipc	s3,0x14
    80002262:	7a298993          	addi	s3,s3,1954 # 80016a00 <tickslock>
    80002266:	a029                	j	80002270 <reparent+0x34>
    80002268:	16848493          	addi	s1,s1,360
    8000226c:	01348d63          	beq	s1,s3,80002286 <reparent+0x4a>
    if(pp->parent == p){
    80002270:	7c9c                	ld	a5,56(s1)
    80002272:	ff279be3          	bne	a5,s2,80002268 <reparent+0x2c>
      pp->parent = initproc;
    80002276:	000a3503          	ld	a0,0(s4)
    8000227a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	f4a080e7          	jalr	-182(ra) # 800021c6 <wakeup>
    80002284:	b7d5                	j	80002268 <reparent+0x2c>
}
    80002286:	70a2                	ld	ra,40(sp)
    80002288:	7402                	ld	s0,32(sp)
    8000228a:	64e2                	ld	s1,24(sp)
    8000228c:	6942                	ld	s2,16(sp)
    8000228e:	69a2                	ld	s3,8(sp)
    80002290:	6a02                	ld	s4,0(sp)
    80002292:	6145                	addi	sp,sp,48
    80002294:	8082                	ret

0000000080002296 <exit>:
{
    80002296:	7179                	addi	sp,sp,-48
    80002298:	f406                	sd	ra,40(sp)
    8000229a:	f022                	sd	s0,32(sp)
    8000229c:	ec26                	sd	s1,24(sp)
    8000229e:	e84a                	sd	s2,16(sp)
    800022a0:	e44e                	sd	s3,8(sp)
    800022a2:	e052                	sd	s4,0(sp)
    800022a4:	1800                	addi	s0,sp,48
    800022a6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	714080e7          	jalr	1812(ra) # 800019bc <myproc>
    800022b0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022b2:	00006797          	auipc	a5,0x6
    800022b6:	6a67b783          	ld	a5,1702(a5) # 80008958 <initproc>
    800022ba:	0d050493          	addi	s1,a0,208
    800022be:	15050913          	addi	s2,a0,336
    800022c2:	02a79363          	bne	a5,a0,800022e8 <exit+0x52>
    panic("init exiting");
    800022c6:	00006517          	auipc	a0,0x6
    800022ca:	fb250513          	addi	a0,a0,-78 # 80008278 <digits+0x238>
    800022ce:	ffffe097          	auipc	ra,0xffffe
    800022d2:	26e080e7          	jalr	622(ra) # 8000053c <panic>
      fileclose(f);
    800022d6:	00002097          	auipc	ra,0x2
    800022da:	42c080e7          	jalr	1068(ra) # 80004702 <fileclose>
      p->ofile[fd] = 0;
    800022de:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022e2:	04a1                	addi	s1,s1,8
    800022e4:	01248563          	beq	s1,s2,800022ee <exit+0x58>
    if(p->ofile[fd]){
    800022e8:	6088                	ld	a0,0(s1)
    800022ea:	f575                	bnez	a0,800022d6 <exit+0x40>
    800022ec:	bfdd                	j	800022e2 <exit+0x4c>
  begin_op();
    800022ee:	00002097          	auipc	ra,0x2
    800022f2:	f50080e7          	jalr	-176(ra) # 8000423e <begin_op>
  iput(p->cwd);
    800022f6:	1509b503          	ld	a0,336(s3)
    800022fa:	00001097          	auipc	ra,0x1
    800022fe:	758080e7          	jalr	1880(ra) # 80003a52 <iput>
  end_op();
    80002302:	00002097          	auipc	ra,0x2
    80002306:	fb6080e7          	jalr	-74(ra) # 800042b8 <end_op>
  p->cwd = 0;
    8000230a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000230e:	0000f497          	auipc	s1,0xf
    80002312:	8da48493          	addi	s1,s1,-1830 # 80010be8 <wait_lock>
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	8ba080e7          	jalr	-1862(ra) # 80000bd2 <acquire>
  reparent(p);
    80002320:	854e                	mv	a0,s3
    80002322:	00000097          	auipc	ra,0x0
    80002326:	f1a080e7          	jalr	-230(ra) # 8000223c <reparent>
  wakeup(p->parent);
    8000232a:	0389b503          	ld	a0,56(s3)
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	e98080e7          	jalr	-360(ra) # 800021c6 <wakeup>
  acquire(&p->lock);
    80002336:	854e                	mv	a0,s3
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	89a080e7          	jalr	-1894(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002340:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002344:	4795                	li	a5,5
    80002346:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	950080e7          	jalr	-1712(ra) # 80000c9c <release>
  sched();
    80002354:	00000097          	auipc	ra,0x0
    80002358:	cfc080e7          	jalr	-772(ra) # 80002050 <sched>
  panic("zombie exit");
    8000235c:	00006517          	auipc	a0,0x6
    80002360:	f2c50513          	addi	a0,a0,-212 # 80008288 <digits+0x248>
    80002364:	ffffe097          	auipc	ra,0xffffe
    80002368:	1d8080e7          	jalr	472(ra) # 8000053c <panic>

000000008000236c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000236c:	7179                	addi	sp,sp,-48
    8000236e:	f406                	sd	ra,40(sp)
    80002370:	f022                	sd	s0,32(sp)
    80002372:	ec26                	sd	s1,24(sp)
    80002374:	e84a                	sd	s2,16(sp)
    80002376:	e44e                	sd	s3,8(sp)
    80002378:	1800                	addi	s0,sp,48
    8000237a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000237c:	0000f497          	auipc	s1,0xf
    80002380:	c8448493          	addi	s1,s1,-892 # 80011000 <proc>
    80002384:	00014997          	auipc	s3,0x14
    80002388:	67c98993          	addi	s3,s3,1660 # 80016a00 <tickslock>
    acquire(&p->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	844080e7          	jalr	-1980(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    80002396:	589c                	lw	a5,48(s1)
    80002398:	01278d63          	beq	a5,s2,800023b2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	8fe080e7          	jalr	-1794(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a6:	16848493          	addi	s1,s1,360
    800023aa:	ff3491e3          	bne	s1,s3,8000238c <kill+0x20>
  }
  return -1;
    800023ae:	557d                	li	a0,-1
    800023b0:	a829                	j	800023ca <kill+0x5e>
      p->killed = 1;
    800023b2:	4785                	li	a5,1
    800023b4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023b6:	4c98                	lw	a4,24(s1)
    800023b8:	4789                	li	a5,2
    800023ba:	00f70f63          	beq	a4,a5,800023d8 <kill+0x6c>
      release(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8dc080e7          	jalr	-1828(ra) # 80000c9c <release>
      return 0;
    800023c8:	4501                	li	a0,0
}
    800023ca:	70a2                	ld	ra,40(sp)
    800023cc:	7402                	ld	s0,32(sp)
    800023ce:	64e2                	ld	s1,24(sp)
    800023d0:	6942                	ld	s2,16(sp)
    800023d2:	69a2                	ld	s3,8(sp)
    800023d4:	6145                	addi	sp,sp,48
    800023d6:	8082                	ret
        p->state = RUNNABLE;
    800023d8:	478d                	li	a5,3
    800023da:	cc9c                	sw	a5,24(s1)
    800023dc:	b7cd                	j	800023be <kill+0x52>

00000000800023de <setkilled>:

void
setkilled(struct proc *p)
{
    800023de:	1101                	addi	sp,sp,-32
    800023e0:	ec06                	sd	ra,24(sp)
    800023e2:	e822                	sd	s0,16(sp)
    800023e4:	e426                	sd	s1,8(sp)
    800023e6:	1000                	addi	s0,sp,32
    800023e8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ea:	ffffe097          	auipc	ra,0xffffe
    800023ee:	7e8080e7          	jalr	2024(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800023f2:	4785                	li	a5,1
    800023f4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	8a4080e7          	jalr	-1884(ra) # 80000c9c <release>
}
    80002400:	60e2                	ld	ra,24(sp)
    80002402:	6442                	ld	s0,16(sp)
    80002404:	64a2                	ld	s1,8(sp)
    80002406:	6105                	addi	sp,sp,32
    80002408:	8082                	ret

000000008000240a <killed>:

int
killed(struct proc *p)
{
    8000240a:	1101                	addi	sp,sp,-32
    8000240c:	ec06                	sd	ra,24(sp)
    8000240e:	e822                	sd	s0,16(sp)
    80002410:	e426                	sd	s1,8(sp)
    80002412:	e04a                	sd	s2,0(sp)
    80002414:	1000                	addi	s0,sp,32
    80002416:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7ba080e7          	jalr	1978(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002420:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	876080e7          	jalr	-1930(ra) # 80000c9c <release>
  return k;
}
    8000242e:	854a                	mv	a0,s2
    80002430:	60e2                	ld	ra,24(sp)
    80002432:	6442                	ld	s0,16(sp)
    80002434:	64a2                	ld	s1,8(sp)
    80002436:	6902                	ld	s2,0(sp)
    80002438:	6105                	addi	sp,sp,32
    8000243a:	8082                	ret

000000008000243c <wait>:
{
    8000243c:	715d                	addi	sp,sp,-80
    8000243e:	e486                	sd	ra,72(sp)
    80002440:	e0a2                	sd	s0,64(sp)
    80002442:	fc26                	sd	s1,56(sp)
    80002444:	f84a                	sd	s2,48(sp)
    80002446:	f44e                	sd	s3,40(sp)
    80002448:	f052                	sd	s4,32(sp)
    8000244a:	ec56                	sd	s5,24(sp)
    8000244c:	e85a                	sd	s6,16(sp)
    8000244e:	e45e                	sd	s7,8(sp)
    80002450:	e062                	sd	s8,0(sp)
    80002452:	0880                	addi	s0,sp,80
    80002454:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	566080e7          	jalr	1382(ra) # 800019bc <myproc>
    8000245e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002460:	0000e517          	auipc	a0,0xe
    80002464:	78850513          	addi	a0,a0,1928 # 80010be8 <wait_lock>
    80002468:	ffffe097          	auipc	ra,0xffffe
    8000246c:	76a080e7          	jalr	1898(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002470:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002472:	4a15                	li	s4,5
        havekids = 1;
    80002474:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002476:	00014997          	auipc	s3,0x14
    8000247a:	58a98993          	addi	s3,s3,1418 # 80016a00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000247e:	0000ec17          	auipc	s8,0xe
    80002482:	76ac0c13          	addi	s8,s8,1898 # 80010be8 <wait_lock>
    80002486:	a0d1                	j	8000254a <wait+0x10e>
          pid = pp->pid;
    80002488:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000248c:	000b0e63          	beqz	s6,800024a8 <wait+0x6c>
    80002490:	4691                	li	a3,4
    80002492:	02c48613          	addi	a2,s1,44
    80002496:	85da                	mv	a1,s6
    80002498:	05093503          	ld	a0,80(s2)
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	1e0080e7          	jalr	480(ra) # 8000167c <copyout>
    800024a4:	04054163          	bltz	a0,800024e6 <wait+0xaa>
          freeproc(pp);
    800024a8:	8526                	mv	a0,s1
    800024aa:	fffff097          	auipc	ra,0xfffff
    800024ae:	6c4080e7          	jalr	1732(ra) # 80001b6e <freeproc>
          release(&pp->lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	7e8080e7          	jalr	2024(ra) # 80000c9c <release>
          release(&wait_lock);
    800024bc:	0000e517          	auipc	a0,0xe
    800024c0:	72c50513          	addi	a0,a0,1836 # 80010be8 <wait_lock>
    800024c4:	ffffe097          	auipc	ra,0xffffe
    800024c8:	7d8080e7          	jalr	2008(ra) # 80000c9c <release>
}
    800024cc:	854e                	mv	a0,s3
    800024ce:	60a6                	ld	ra,72(sp)
    800024d0:	6406                	ld	s0,64(sp)
    800024d2:	74e2                	ld	s1,56(sp)
    800024d4:	7942                	ld	s2,48(sp)
    800024d6:	79a2                	ld	s3,40(sp)
    800024d8:	7a02                	ld	s4,32(sp)
    800024da:	6ae2                	ld	s5,24(sp)
    800024dc:	6b42                	ld	s6,16(sp)
    800024de:	6ba2                	ld	s7,8(sp)
    800024e0:	6c02                	ld	s8,0(sp)
    800024e2:	6161                	addi	sp,sp,80
    800024e4:	8082                	ret
            release(&pp->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	7b4080e7          	jalr	1972(ra) # 80000c9c <release>
            release(&wait_lock);
    800024f0:	0000e517          	auipc	a0,0xe
    800024f4:	6f850513          	addi	a0,a0,1784 # 80010be8 <wait_lock>
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	7a4080e7          	jalr	1956(ra) # 80000c9c <release>
            return -1;
    80002500:	59fd                	li	s3,-1
    80002502:	b7e9                	j	800024cc <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002504:	16848493          	addi	s1,s1,360
    80002508:	03348463          	beq	s1,s3,80002530 <wait+0xf4>
      if(pp->parent == p){
    8000250c:	7c9c                	ld	a5,56(s1)
    8000250e:	ff279be3          	bne	a5,s2,80002504 <wait+0xc8>
        acquire(&pp->lock);
    80002512:	8526                	mv	a0,s1
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	6be080e7          	jalr	1726(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    8000251c:	4c9c                	lw	a5,24(s1)
    8000251e:	f74785e3          	beq	a5,s4,80002488 <wait+0x4c>
        release(&pp->lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	778080e7          	jalr	1912(ra) # 80000c9c <release>
        havekids = 1;
    8000252c:	8756                	mv	a4,s5
    8000252e:	bfd9                	j	80002504 <wait+0xc8>
    if(!havekids || killed(p)){
    80002530:	c31d                	beqz	a4,80002556 <wait+0x11a>
    80002532:	854a                	mv	a0,s2
    80002534:	00000097          	auipc	ra,0x0
    80002538:	ed6080e7          	jalr	-298(ra) # 8000240a <killed>
    8000253c:	ed09                	bnez	a0,80002556 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000253e:	85e2                	mv	a1,s8
    80002540:	854a                	mv	a0,s2
    80002542:	00000097          	auipc	ra,0x0
    80002546:	c20080e7          	jalr	-992(ra) # 80002162 <sleep>
    havekids = 0;
    8000254a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000254c:	0000f497          	auipc	s1,0xf
    80002550:	ab448493          	addi	s1,s1,-1356 # 80011000 <proc>
    80002554:	bf65                	j	8000250c <wait+0xd0>
      release(&wait_lock);
    80002556:	0000e517          	auipc	a0,0xe
    8000255a:	69250513          	addi	a0,a0,1682 # 80010be8 <wait_lock>
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	73e080e7          	jalr	1854(ra) # 80000c9c <release>
      return -1;
    80002566:	59fd                	li	s3,-1
    80002568:	b795                	j	800024cc <wait+0x90>

000000008000256a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000256a:	7179                	addi	sp,sp,-48
    8000256c:	f406                	sd	ra,40(sp)
    8000256e:	f022                	sd	s0,32(sp)
    80002570:	ec26                	sd	s1,24(sp)
    80002572:	e84a                	sd	s2,16(sp)
    80002574:	e44e                	sd	s3,8(sp)
    80002576:	e052                	sd	s4,0(sp)
    80002578:	1800                	addi	s0,sp,48
    8000257a:	84aa                	mv	s1,a0
    8000257c:	892e                	mv	s2,a1
    8000257e:	89b2                	mv	s3,a2
    80002580:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	43a080e7          	jalr	1082(ra) # 800019bc <myproc>
  if(user_dst){
    8000258a:	c08d                	beqz	s1,800025ac <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000258c:	86d2                	mv	a3,s4
    8000258e:	864e                	mv	a2,s3
    80002590:	85ca                	mv	a1,s2
    80002592:	6928                	ld	a0,80(a0)
    80002594:	fffff097          	auipc	ra,0xfffff
    80002598:	0e8080e7          	jalr	232(ra) # 8000167c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000259c:	70a2                	ld	ra,40(sp)
    8000259e:	7402                	ld	s0,32(sp)
    800025a0:	64e2                	ld	s1,24(sp)
    800025a2:	6942                	ld	s2,16(sp)
    800025a4:	69a2                	ld	s3,8(sp)
    800025a6:	6a02                	ld	s4,0(sp)
    800025a8:	6145                	addi	sp,sp,48
    800025aa:	8082                	ret
    memmove((char *)dst, src, len);
    800025ac:	000a061b          	sext.w	a2,s4
    800025b0:	85ce                	mv	a1,s3
    800025b2:	854a                	mv	a0,s2
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	78c080e7          	jalr	1932(ra) # 80000d40 <memmove>
    return 0;
    800025bc:	8526                	mv	a0,s1
    800025be:	bff9                	j	8000259c <either_copyout+0x32>

00000000800025c0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025c0:	7179                	addi	sp,sp,-48
    800025c2:	f406                	sd	ra,40(sp)
    800025c4:	f022                	sd	s0,32(sp)
    800025c6:	ec26                	sd	s1,24(sp)
    800025c8:	e84a                	sd	s2,16(sp)
    800025ca:	e44e                	sd	s3,8(sp)
    800025cc:	e052                	sd	s4,0(sp)
    800025ce:	1800                	addi	s0,sp,48
    800025d0:	892a                	mv	s2,a0
    800025d2:	84ae                	mv	s1,a1
    800025d4:	89b2                	mv	s3,a2
    800025d6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	3e4080e7          	jalr	996(ra) # 800019bc <myproc>
  if(user_src){
    800025e0:	c08d                	beqz	s1,80002602 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025e2:	86d2                	mv	a3,s4
    800025e4:	864e                	mv	a2,s3
    800025e6:	85ca                	mv	a1,s2
    800025e8:	6928                	ld	a0,80(a0)
    800025ea:	fffff097          	auipc	ra,0xfffff
    800025ee:	11e080e7          	jalr	286(ra) # 80001708 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025f2:	70a2                	ld	ra,40(sp)
    800025f4:	7402                	ld	s0,32(sp)
    800025f6:	64e2                	ld	s1,24(sp)
    800025f8:	6942                	ld	s2,16(sp)
    800025fa:	69a2                	ld	s3,8(sp)
    800025fc:	6a02                	ld	s4,0(sp)
    800025fe:	6145                	addi	sp,sp,48
    80002600:	8082                	ret
    memmove(dst, (char*)src, len);
    80002602:	000a061b          	sext.w	a2,s4
    80002606:	85ce                	mv	a1,s3
    80002608:	854a                	mv	a0,s2
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	736080e7          	jalr	1846(ra) # 80000d40 <memmove>
    return 0;
    80002612:	8526                	mv	a0,s1
    80002614:	bff9                	j	800025f2 <either_copyin+0x32>

0000000080002616 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002616:	715d                	addi	sp,sp,-80
    80002618:	e486                	sd	ra,72(sp)
    8000261a:	e0a2                	sd	s0,64(sp)
    8000261c:	fc26                	sd	s1,56(sp)
    8000261e:	f84a                	sd	s2,48(sp)
    80002620:	f44e                	sd	s3,40(sp)
    80002622:	f052                	sd	s4,32(sp)
    80002624:	ec56                	sd	s5,24(sp)
    80002626:	e85a                	sd	s6,16(sp)
    80002628:	e45e                	sd	s7,8(sp)
    8000262a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000262c:	00006517          	auipc	a0,0x6
    80002630:	a5450513          	addi	a0,a0,-1452 # 80008080 <digits+0x40>
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	f52080e7          	jalr	-174(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000263c:	0000f497          	auipc	s1,0xf
    80002640:	b1c48493          	addi	s1,s1,-1252 # 80011158 <proc+0x158>
    80002644:	00014917          	auipc	s2,0x14
    80002648:	51490913          	addi	s2,s2,1300 # 80016b58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000264e:	00006997          	auipc	s3,0x6
    80002652:	c4a98993          	addi	s3,s3,-950 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    80002656:	00006a97          	auipc	s5,0x6
    8000265a:	c4aa8a93          	addi	s5,s5,-950 # 800082a0 <digits+0x260>
    printf("\n");
    8000265e:	00006a17          	auipc	s4,0x6
    80002662:	a22a0a13          	addi	s4,s4,-1502 # 80008080 <digits+0x40>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002666:	00006b97          	auipc	s7,0x6
    8000266a:	c7ab8b93          	addi	s7,s7,-902 # 800082e0 <states.0>
    8000266e:	a00d                	j	80002690 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002670:	ed86a583          	lw	a1,-296(a3)
    80002674:	8556                	mv	a0,s5
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	f10080e7          	jalr	-240(ra) # 80000586 <printf>
    printf("\n");
    8000267e:	8552                	mv	a0,s4
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	f06080e7          	jalr	-250(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002688:	16848493          	addi	s1,s1,360
    8000268c:	03248263          	beq	s1,s2,800026b0 <procdump+0x9a>
    if(p->state == UNUSED)
    80002690:	86a6                	mv	a3,s1
    80002692:	ec04a783          	lw	a5,-320(s1)
    80002696:	dbed                	beqz	a5,80002688 <procdump+0x72>
      state = "???";
    80002698:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269a:	fcfb6be3          	bltu	s6,a5,80002670 <procdump+0x5a>
    8000269e:	02079713          	slli	a4,a5,0x20
    800026a2:	01d75793          	srli	a5,a4,0x1d
    800026a6:	97de                	add	a5,a5,s7
    800026a8:	6390                	ld	a2,0(a5)
    800026aa:	f279                	bnez	a2,80002670 <procdump+0x5a>
      state = "???";
    800026ac:	864e                	mv	a2,s3
    800026ae:	b7c9                	j	80002670 <procdump+0x5a>
  }
}
    800026b0:	60a6                	ld	ra,72(sp)
    800026b2:	6406                	ld	s0,64(sp)
    800026b4:	74e2                	ld	s1,56(sp)
    800026b6:	7942                	ld	s2,48(sp)
    800026b8:	79a2                	ld	s3,40(sp)
    800026ba:	7a02                	ld	s4,32(sp)
    800026bc:	6ae2                	ld	s5,24(sp)
    800026be:	6b42                	ld	s6,16(sp)
    800026c0:	6ba2                	ld	s7,8(sp)
    800026c2:	6161                	addi	sp,sp,80
    800026c4:	8082                	ret

00000000800026c6 <swtch>:
    800026c6:	00153023          	sd	ra,0(a0)
    800026ca:	00253423          	sd	sp,8(a0)
    800026ce:	e900                	sd	s0,16(a0)
    800026d0:	ed04                	sd	s1,24(a0)
    800026d2:	03253023          	sd	s2,32(a0)
    800026d6:	03353423          	sd	s3,40(a0)
    800026da:	03453823          	sd	s4,48(a0)
    800026de:	03553c23          	sd	s5,56(a0)
    800026e2:	05653023          	sd	s6,64(a0)
    800026e6:	05753423          	sd	s7,72(a0)
    800026ea:	05853823          	sd	s8,80(a0)
    800026ee:	05953c23          	sd	s9,88(a0)
    800026f2:	07a53023          	sd	s10,96(a0)
    800026f6:	07b53423          	sd	s11,104(a0)
    800026fa:	0005b083          	ld	ra,0(a1)
    800026fe:	0085b103          	ld	sp,8(a1)
    80002702:	6980                	ld	s0,16(a1)
    80002704:	6d84                	ld	s1,24(a1)
    80002706:	0205b903          	ld	s2,32(a1)
    8000270a:	0285b983          	ld	s3,40(a1)
    8000270e:	0305ba03          	ld	s4,48(a1)
    80002712:	0385ba83          	ld	s5,56(a1)
    80002716:	0405bb03          	ld	s6,64(a1)
    8000271a:	0485bb83          	ld	s7,72(a1)
    8000271e:	0505bc03          	ld	s8,80(a1)
    80002722:	0585bc83          	ld	s9,88(a1)
    80002726:	0605bd03          	ld	s10,96(a1)
    8000272a:	0685bd83          	ld	s11,104(a1)
    8000272e:	8082                	ret

0000000080002730 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002730:	1141                	addi	sp,sp,-16
    80002732:	e406                	sd	ra,8(sp)
    80002734:	e022                	sd	s0,0(sp)
    80002736:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002738:	00006597          	auipc	a1,0x6
    8000273c:	bd858593          	addi	a1,a1,-1064 # 80008310 <states.0+0x30>
    80002740:	00014517          	auipc	a0,0x14
    80002744:	2c050513          	addi	a0,a0,704 # 80016a00 <tickslock>
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	3fa080e7          	jalr	1018(ra) # 80000b42 <initlock>
}
    80002750:	60a2                	ld	ra,8(sp)
    80002752:	6402                	ld	s0,0(sp)
    80002754:	0141                	addi	sp,sp,16
    80002756:	8082                	ret

0000000080002758 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002758:	1141                	addi	sp,sp,-16
    8000275a:	e422                	sd	s0,8(sp)
    8000275c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000275e:	00003797          	auipc	a5,0x3
    80002762:	5d278793          	addi	a5,a5,1490 # 80005d30 <kernelvec>
    80002766:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000276a:	6422                	ld	s0,8(sp)
    8000276c:	0141                	addi	sp,sp,16
    8000276e:	8082                	ret

0000000080002770 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002770:	1141                	addi	sp,sp,-16
    80002772:	e406                	sd	ra,8(sp)
    80002774:	e022                	sd	s0,0(sp)
    80002776:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002778:	fffff097          	auipc	ra,0xfffff
    8000277c:	244080e7          	jalr	580(ra) # 800019bc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002780:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002784:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002786:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000278a:	00005697          	auipc	a3,0x5
    8000278e:	87668693          	addi	a3,a3,-1930 # 80007000 <_trampoline>
    80002792:	00005717          	auipc	a4,0x5
    80002796:	86e70713          	addi	a4,a4,-1938 # 80007000 <_trampoline>
    8000279a:	8f15                	sub	a4,a4,a3
    8000279c:	040007b7          	lui	a5,0x4000
    800027a0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027a2:	07b2                	slli	a5,a5,0xc
    800027a4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027ac:	18002673          	csrr	a2,satp
    800027b0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027b2:	6d30                	ld	a2,88(a0)
    800027b4:	6138                	ld	a4,64(a0)
    800027b6:	6585                	lui	a1,0x1
    800027b8:	972e                	add	a4,a4,a1
    800027ba:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027bc:	6d38                	ld	a4,88(a0)
    800027be:	00000617          	auipc	a2,0x0
    800027c2:	13460613          	addi	a2,a2,308 # 800028f2 <usertrap>
    800027c6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027c8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027ca:	8612                	mv	a2,tp
    800027cc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ce:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027d2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027d6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027da:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027de:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027e0:	6f18                	ld	a4,24(a4)
    800027e2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027e6:	6928                	ld	a0,80(a0)
    800027e8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027ea:	00005717          	auipc	a4,0x5
    800027ee:	8b270713          	addi	a4,a4,-1870 # 8000709c <userret>
    800027f2:	8f15                	sub	a4,a4,a3
    800027f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027f6:	577d                	li	a4,-1
    800027f8:	177e                	slli	a4,a4,0x3f
    800027fa:	8d59                	or	a0,a0,a4
    800027fc:	9782                	jalr	a5
}
    800027fe:	60a2                	ld	ra,8(sp)
    80002800:	6402                	ld	s0,0(sp)
    80002802:	0141                	addi	sp,sp,16
    80002804:	8082                	ret

0000000080002806 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002806:	1101                	addi	sp,sp,-32
    80002808:	ec06                	sd	ra,24(sp)
    8000280a:	e822                	sd	s0,16(sp)
    8000280c:	e426                	sd	s1,8(sp)
    8000280e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002810:	00014497          	auipc	s1,0x14
    80002814:	1f048493          	addi	s1,s1,496 # 80016a00 <tickslock>
    80002818:	8526                	mv	a0,s1
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	3b8080e7          	jalr	952(ra) # 80000bd2 <acquire>
  ticks++;
    80002822:	00006517          	auipc	a0,0x6
    80002826:	13e50513          	addi	a0,a0,318 # 80008960 <ticks>
    8000282a:	411c                	lw	a5,0(a0)
    8000282c:	2785                	addiw	a5,a5,1
    8000282e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002830:	00000097          	auipc	ra,0x0
    80002834:	996080e7          	jalr	-1642(ra) # 800021c6 <wakeup>
  release(&tickslock);
    80002838:	8526                	mv	a0,s1
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	462080e7          	jalr	1122(ra) # 80000c9c <release>
}
    80002842:	60e2                	ld	ra,24(sp)
    80002844:	6442                	ld	s0,16(sp)
    80002846:	64a2                	ld	s1,8(sp)
    80002848:	6105                	addi	sp,sp,32
    8000284a:	8082                	ret

000000008000284c <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284c:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002850:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002852:	0807df63          	bgez	a5,800028f0 <devintr+0xa4>
{
    80002856:	1101                	addi	sp,sp,-32
    80002858:	ec06                	sd	ra,24(sp)
    8000285a:	e822                	sd	s0,16(sp)
    8000285c:	e426                	sd	s1,8(sp)
    8000285e:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002860:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002864:	46a5                	li	a3,9
    80002866:	00d70d63          	beq	a4,a3,80002880 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    8000286a:	577d                	li	a4,-1
    8000286c:	177e                	slli	a4,a4,0x3f
    8000286e:	0705                	addi	a4,a4,1
    return 0;
    80002870:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002872:	04e78e63          	beq	a5,a4,800028ce <devintr+0x82>
  }
}
    80002876:	60e2                	ld	ra,24(sp)
    80002878:	6442                	ld	s0,16(sp)
    8000287a:	64a2                	ld	s1,8(sp)
    8000287c:	6105                	addi	sp,sp,32
    8000287e:	8082                	ret
    int irq = plic_claim();
    80002880:	00003097          	auipc	ra,0x3
    80002884:	5b8080e7          	jalr	1464(ra) # 80005e38 <plic_claim>
    80002888:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000288a:	47a9                	li	a5,10
    8000288c:	02f50763          	beq	a0,a5,800028ba <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002890:	4785                	li	a5,1
    80002892:	02f50963          	beq	a0,a5,800028c4 <devintr+0x78>
    return 1;
    80002896:	4505                	li	a0,1
    } else if(irq){
    80002898:	dcf9                	beqz	s1,80002876 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    8000289a:	85a6                	mv	a1,s1
    8000289c:	00006517          	auipc	a0,0x6
    800028a0:	a7c50513          	addi	a0,a0,-1412 # 80008318 <states.0+0x38>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	ce2080e7          	jalr	-798(ra) # 80000586 <printf>
      plic_complete(irq);
    800028ac:	8526                	mv	a0,s1
    800028ae:	00003097          	auipc	ra,0x3
    800028b2:	5ae080e7          	jalr	1454(ra) # 80005e5c <plic_complete>
    return 1;
    800028b6:	4505                	li	a0,1
    800028b8:	bf7d                	j	80002876 <devintr+0x2a>
      uartintr();
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	0da080e7          	jalr	218(ra) # 80000994 <uartintr>
    if(irq)
    800028c2:	b7ed                	j	800028ac <devintr+0x60>
      virtio_disk_intr();
    800028c4:	00004097          	auipc	ra,0x4
    800028c8:	a5e080e7          	jalr	-1442(ra) # 80006322 <virtio_disk_intr>
    if(irq)
    800028cc:	b7c5                	j	800028ac <devintr+0x60>
    if(cpuid() == 0){
    800028ce:	fffff097          	auipc	ra,0xfffff
    800028d2:	0c2080e7          	jalr	194(ra) # 80001990 <cpuid>
    800028d6:	c901                	beqz	a0,800028e6 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028d8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028de:	14479073          	csrw	sip,a5
    return 2;
    800028e2:	4509                	li	a0,2
    800028e4:	bf49                	j	80002876 <devintr+0x2a>
      clockintr();
    800028e6:	00000097          	auipc	ra,0x0
    800028ea:	f20080e7          	jalr	-224(ra) # 80002806 <clockintr>
    800028ee:	b7ed                	j	800028d8 <devintr+0x8c>
}
    800028f0:	8082                	ret

00000000800028f2 <usertrap>:
{
    800028f2:	1101                	addi	sp,sp,-32
    800028f4:	ec06                	sd	ra,24(sp)
    800028f6:	e822                	sd	s0,16(sp)
    800028f8:	e426                	sd	s1,8(sp)
    800028fa:	e04a                	sd	s2,0(sp)
    800028fc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fe:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002902:	1007f793          	andi	a5,a5,256
    80002906:	e3b1                	bnez	a5,8000294a <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002908:	00003797          	auipc	a5,0x3
    8000290c:	42878793          	addi	a5,a5,1064 # 80005d30 <kernelvec>
    80002910:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	0a8080e7          	jalr	168(ra) # 800019bc <myproc>
    8000291c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000291e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002920:	14102773          	csrr	a4,sepc
    80002924:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002926:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000292a:	47a1                	li	a5,8
    8000292c:	02f70763          	beq	a4,a5,8000295a <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002930:	00000097          	auipc	ra,0x0
    80002934:	f1c080e7          	jalr	-228(ra) # 8000284c <devintr>
    80002938:	892a                	mv	s2,a0
    8000293a:	c151                	beqz	a0,800029be <usertrap+0xcc>
  if(killed(p))
    8000293c:	8526                	mv	a0,s1
    8000293e:	00000097          	auipc	ra,0x0
    80002942:	acc080e7          	jalr	-1332(ra) # 8000240a <killed>
    80002946:	c929                	beqz	a0,80002998 <usertrap+0xa6>
    80002948:	a099                	j	8000298e <usertrap+0x9c>
    panic("usertrap: not from user mode");
    8000294a:	00006517          	auipc	a0,0x6
    8000294e:	9ee50513          	addi	a0,a0,-1554 # 80008338 <states.0+0x58>
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	bea080e7          	jalr	-1046(ra) # 8000053c <panic>
    if(killed(p))
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	ab0080e7          	jalr	-1360(ra) # 8000240a <killed>
    80002962:	e921                	bnez	a0,800029b2 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002964:	6cb8                	ld	a4,88(s1)
    80002966:	6f1c                	ld	a5,24(a4)
    80002968:	0791                	addi	a5,a5,4
    8000296a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002970:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002974:	10079073          	csrw	sstatus,a5
    syscall();
    80002978:	00000097          	auipc	ra,0x0
    8000297c:	2d4080e7          	jalr	724(ra) # 80002c4c <syscall>
  if(killed(p))
    80002980:	8526                	mv	a0,s1
    80002982:	00000097          	auipc	ra,0x0
    80002986:	a88080e7          	jalr	-1400(ra) # 8000240a <killed>
    8000298a:	c911                	beqz	a0,8000299e <usertrap+0xac>
    8000298c:	4901                	li	s2,0
    exit(-1);
    8000298e:	557d                	li	a0,-1
    80002990:	00000097          	auipc	ra,0x0
    80002994:	906080e7          	jalr	-1786(ra) # 80002296 <exit>
  if(which_dev == 2)
    80002998:	4789                	li	a5,2
    8000299a:	04f90f63          	beq	s2,a5,800029f8 <usertrap+0x106>
  usertrapret();
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	dd2080e7          	jalr	-558(ra) # 80002770 <usertrapret>
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6902                	ld	s2,0(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
      exit(-1);
    800029b2:	557d                	li	a0,-1
    800029b4:	00000097          	auipc	ra,0x0
    800029b8:	8e2080e7          	jalr	-1822(ra) # 80002296 <exit>
    800029bc:	b765                	j	80002964 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029be:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029c2:	5890                	lw	a2,48(s1)
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	99450513          	addi	a0,a0,-1644 # 80008358 <states.0+0x78>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	bba080e7          	jalr	-1094(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	9ac50513          	addi	a0,a0,-1620 # 80008388 <states.0+0xa8>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	ba2080e7          	jalr	-1118(ra) # 80000586 <printf>
    setkilled(p);
    800029ec:	8526                	mv	a0,s1
    800029ee:	00000097          	auipc	ra,0x0
    800029f2:	9f0080e7          	jalr	-1552(ra) # 800023de <setkilled>
    800029f6:	b769                	j	80002980 <usertrap+0x8e>
    yield();
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	72e080e7          	jalr	1838(ra) # 80002126 <yield>
    80002a00:	bf79                	j	8000299e <usertrap+0xac>

0000000080002a02 <kerneltrap>:
{
    80002a02:	7179                	addi	sp,sp,-48
    80002a04:	f406                	sd	ra,40(sp)
    80002a06:	f022                	sd	s0,32(sp)
    80002a08:	ec26                	sd	s1,24(sp)
    80002a0a:	e84a                	sd	s2,16(sp)
    80002a0c:	e44e                	sd	s3,8(sp)
    80002a0e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a10:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a14:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a18:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a1c:	1004f793          	andi	a5,s1,256
    80002a20:	cb85                	beqz	a5,80002a50 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a26:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a28:	ef85                	bnez	a5,80002a60 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a2a:	00000097          	auipc	ra,0x0
    80002a2e:	e22080e7          	jalr	-478(ra) # 8000284c <devintr>
    80002a32:	cd1d                	beqz	a0,80002a70 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a34:	4789                	li	a5,2
    80002a36:	06f50a63          	beq	a0,a5,80002aaa <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a3a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3e:	10049073          	csrw	sstatus,s1
}
    80002a42:	70a2                	ld	ra,40(sp)
    80002a44:	7402                	ld	s0,32(sp)
    80002a46:	64e2                	ld	s1,24(sp)
    80002a48:	6942                	ld	s2,16(sp)
    80002a4a:	69a2                	ld	s3,8(sp)
    80002a4c:	6145                	addi	sp,sp,48
    80002a4e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a50:	00006517          	auipc	a0,0x6
    80002a54:	95850513          	addi	a0,a0,-1704 # 800083a8 <states.0+0xc8>
    80002a58:	ffffe097          	auipc	ra,0xffffe
    80002a5c:	ae4080e7          	jalr	-1308(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002a60:	00006517          	auipc	a0,0x6
    80002a64:	97050513          	addi	a0,a0,-1680 # 800083d0 <states.0+0xf0>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	ad4080e7          	jalr	-1324(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002a70:	85ce                	mv	a1,s3
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	97e50513          	addi	a0,a0,-1666 # 800083f0 <states.0+0x110>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	b0c080e7          	jalr	-1268(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a82:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a86:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	97650513          	addi	a0,a0,-1674 # 80008400 <states.0+0x120>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	af4080e7          	jalr	-1292(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	97e50513          	addi	a0,a0,-1666 # 80008418 <states.0+0x138>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	a9a080e7          	jalr	-1382(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aaa:	fffff097          	auipc	ra,0xfffff
    80002aae:	f12080e7          	jalr	-238(ra) # 800019bc <myproc>
    80002ab2:	d541                	beqz	a0,80002a3a <kerneltrap+0x38>
    80002ab4:	fffff097          	auipc	ra,0xfffff
    80002ab8:	f08080e7          	jalr	-248(ra) # 800019bc <myproc>
    80002abc:	4d18                	lw	a4,24(a0)
    80002abe:	4791                	li	a5,4
    80002ac0:	f6f71de3          	bne	a4,a5,80002a3a <kerneltrap+0x38>
    yield();
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	662080e7          	jalr	1634(ra) # 80002126 <yield>
    80002acc:	b7bd                	j	80002a3a <kerneltrap+0x38>

0000000080002ace <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ace:	1101                	addi	sp,sp,-32
    80002ad0:	ec06                	sd	ra,24(sp)
    80002ad2:	e822                	sd	s0,16(sp)
    80002ad4:	e426                	sd	s1,8(sp)
    80002ad6:	1000                	addi	s0,sp,32
    80002ad8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ada:	fffff097          	auipc	ra,0xfffff
    80002ade:	ee2080e7          	jalr	-286(ra) # 800019bc <myproc>
  switch (n) {
    80002ae2:	4795                	li	a5,5
    80002ae4:	0497e163          	bltu	a5,s1,80002b26 <argraw+0x58>
    80002ae8:	048a                	slli	s1,s1,0x2
    80002aea:	00006717          	auipc	a4,0x6
    80002aee:	96670713          	addi	a4,a4,-1690 # 80008450 <states.0+0x170>
    80002af2:	94ba                	add	s1,s1,a4
    80002af4:	409c                	lw	a5,0(s1)
    80002af6:	97ba                	add	a5,a5,a4
    80002af8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002afa:	6d3c                	ld	a5,88(a0)
    80002afc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6105                	addi	sp,sp,32
    80002b06:	8082                	ret
    return p->trapframe->a1;
    80002b08:	6d3c                	ld	a5,88(a0)
    80002b0a:	7fa8                	ld	a0,120(a5)
    80002b0c:	bfcd                	j	80002afe <argraw+0x30>
    return p->trapframe->a2;
    80002b0e:	6d3c                	ld	a5,88(a0)
    80002b10:	63c8                	ld	a0,128(a5)
    80002b12:	b7f5                	j	80002afe <argraw+0x30>
    return p->trapframe->a3;
    80002b14:	6d3c                	ld	a5,88(a0)
    80002b16:	67c8                	ld	a0,136(a5)
    80002b18:	b7dd                	j	80002afe <argraw+0x30>
    return p->trapframe->a4;
    80002b1a:	6d3c                	ld	a5,88(a0)
    80002b1c:	6bc8                	ld	a0,144(a5)
    80002b1e:	b7c5                	j	80002afe <argraw+0x30>
    return p->trapframe->a5;
    80002b20:	6d3c                	ld	a5,88(a0)
    80002b22:	6fc8                	ld	a0,152(a5)
    80002b24:	bfe9                	j	80002afe <argraw+0x30>
  panic("argraw");
    80002b26:	00006517          	auipc	a0,0x6
    80002b2a:	90250513          	addi	a0,a0,-1790 # 80008428 <states.0+0x148>
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	a0e080e7          	jalr	-1522(ra) # 8000053c <panic>

0000000080002b36 <fetchaddr>:
{
    80002b36:	1101                	addi	sp,sp,-32
    80002b38:	ec06                	sd	ra,24(sp)
    80002b3a:	e822                	sd	s0,16(sp)
    80002b3c:	e426                	sd	s1,8(sp)
    80002b3e:	e04a                	sd	s2,0(sp)
    80002b40:	1000                	addi	s0,sp,32
    80002b42:	84aa                	mv	s1,a0
    80002b44:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b46:	fffff097          	auipc	ra,0xfffff
    80002b4a:	e76080e7          	jalr	-394(ra) # 800019bc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b4e:	653c                	ld	a5,72(a0)
    80002b50:	02f4f863          	bgeu	s1,a5,80002b80 <fetchaddr+0x4a>
    80002b54:	00848713          	addi	a4,s1,8
    80002b58:	02e7e663          	bltu	a5,a4,80002b84 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b5c:	46a1                	li	a3,8
    80002b5e:	8626                	mv	a2,s1
    80002b60:	85ca                	mv	a1,s2
    80002b62:	6928                	ld	a0,80(a0)
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	ba4080e7          	jalr	-1116(ra) # 80001708 <copyin>
    80002b6c:	00a03533          	snez	a0,a0
    80002b70:	40a00533          	neg	a0,a0
}
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	64a2                	ld	s1,8(sp)
    80002b7a:	6902                	ld	s2,0(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret
    return -1;
    80002b80:	557d                	li	a0,-1
    80002b82:	bfcd                	j	80002b74 <fetchaddr+0x3e>
    80002b84:	557d                	li	a0,-1
    80002b86:	b7fd                	j	80002b74 <fetchaddr+0x3e>

0000000080002b88 <fetchstr>:
{
    80002b88:	7179                	addi	sp,sp,-48
    80002b8a:	f406                	sd	ra,40(sp)
    80002b8c:	f022                	sd	s0,32(sp)
    80002b8e:	ec26                	sd	s1,24(sp)
    80002b90:	e84a                	sd	s2,16(sp)
    80002b92:	e44e                	sd	s3,8(sp)
    80002b94:	1800                	addi	s0,sp,48
    80002b96:	892a                	mv	s2,a0
    80002b98:	84ae                	mv	s1,a1
    80002b9a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	e20080e7          	jalr	-480(ra) # 800019bc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ba4:	86ce                	mv	a3,s3
    80002ba6:	864a                	mv	a2,s2
    80002ba8:	85a6                	mv	a1,s1
    80002baa:	6928                	ld	a0,80(a0)
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	bea080e7          	jalr	-1046(ra) # 80001796 <copyinstr>
    80002bb4:	00054e63          	bltz	a0,80002bd0 <fetchstr+0x48>
  return strlen(buf);
    80002bb8:	8526                	mv	a0,s1
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	2a4080e7          	jalr	676(ra) # 80000e5e <strlen>
}
    80002bc2:	70a2                	ld	ra,40(sp)
    80002bc4:	7402                	ld	s0,32(sp)
    80002bc6:	64e2                	ld	s1,24(sp)
    80002bc8:	6942                	ld	s2,16(sp)
    80002bca:	69a2                	ld	s3,8(sp)
    80002bcc:	6145                	addi	sp,sp,48
    80002bce:	8082                	ret
    return -1;
    80002bd0:	557d                	li	a0,-1
    80002bd2:	bfc5                	j	80002bc2 <fetchstr+0x3a>

0000000080002bd4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002bd4:	1101                	addi	sp,sp,-32
    80002bd6:	ec06                	sd	ra,24(sp)
    80002bd8:	e822                	sd	s0,16(sp)
    80002bda:	e426                	sd	s1,8(sp)
    80002bdc:	1000                	addi	s0,sp,32
    80002bde:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	eee080e7          	jalr	-274(ra) # 80002ace <argraw>
    80002be8:	c088                	sw	a0,0(s1)
}
    80002bea:	60e2                	ld	ra,24(sp)
    80002bec:	6442                	ld	s0,16(sp)
    80002bee:	64a2                	ld	s1,8(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret

0000000080002bf4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	e426                	sd	s1,8(sp)
    80002bfc:	1000                	addi	s0,sp,32
    80002bfe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c00:	00000097          	auipc	ra,0x0
    80002c04:	ece080e7          	jalr	-306(ra) # 80002ace <argraw>
    80002c08:	e088                	sd	a0,0(s1)
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c14:	7179                	addi	sp,sp,-48
    80002c16:	f406                	sd	ra,40(sp)
    80002c18:	f022                	sd	s0,32(sp)
    80002c1a:	ec26                	sd	s1,24(sp)
    80002c1c:	e84a                	sd	s2,16(sp)
    80002c1e:	1800                	addi	s0,sp,48
    80002c20:	84ae                	mv	s1,a1
    80002c22:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c24:	fd840593          	addi	a1,s0,-40
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	fcc080e7          	jalr	-52(ra) # 80002bf4 <argaddr>
  return fetchstr(addr, buf, max);
    80002c30:	864a                	mv	a2,s2
    80002c32:	85a6                	mv	a1,s1
    80002c34:	fd843503          	ld	a0,-40(s0)
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	f50080e7          	jalr	-176(ra) # 80002b88 <fetchstr>
}
    80002c40:	70a2                	ld	ra,40(sp)
    80002c42:	7402                	ld	s0,32(sp)
    80002c44:	64e2                	ld	s1,24(sp)
    80002c46:	6942                	ld	s2,16(sp)
    80002c48:	6145                	addi	sp,sp,48
    80002c4a:	8082                	ret

0000000080002c4c <syscall>:
[SYS_setpri]  sys_setpri,
};

void
syscall(void)
{
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	e426                	sd	s1,8(sp)
    80002c54:	e04a                	sd	s2,0(sp)
    80002c56:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	d64080e7          	jalr	-668(ra) # 800019bc <myproc>
    80002c60:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c62:	05853903          	ld	s2,88(a0)
    80002c66:	0a893783          	ld	a5,168(s2)
    80002c6a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c6e:	37fd                	addiw	a5,a5,-1
    80002c70:	4769                	li	a4,26
    80002c72:	00f76f63          	bltu	a4,a5,80002c90 <syscall+0x44>
    80002c76:	00369713          	slli	a4,a3,0x3
    80002c7a:	00005797          	auipc	a5,0x5
    80002c7e:	7ee78793          	addi	a5,a5,2030 # 80008468 <syscalls>
    80002c82:	97ba                	add	a5,a5,a4
    80002c84:	639c                	ld	a5,0(a5)
    80002c86:	c789                	beqz	a5,80002c90 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c88:	9782                	jalr	a5
    80002c8a:	06a93823          	sd	a0,112(s2)
    80002c8e:	a839                	j	80002cac <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c90:	15848613          	addi	a2,s1,344
    80002c94:	588c                	lw	a1,48(s1)
    80002c96:	00005517          	auipc	a0,0x5
    80002c9a:	79a50513          	addi	a0,a0,1946 # 80008430 <states.0+0x150>
    80002c9e:	ffffe097          	auipc	ra,0xffffe
    80002ca2:	8e8080e7          	jalr	-1816(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ca6:	6cbc                	ld	a5,88(s1)
    80002ca8:	577d                	li	a4,-1
    80002caa:	fbb8                	sd	a4,112(a5)
  }
}
    80002cac:	60e2                	ld	ra,24(sp)
    80002cae:	6442                	ld	s0,16(sp)
    80002cb0:	64a2                	ld	s1,8(sp)
    80002cb2:	6902                	ld	s2,0(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cc0:	fec40593          	addi	a1,s0,-20
    80002cc4:	4501                	li	a0,0
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	f0e080e7          	jalr	-242(ra) # 80002bd4 <argint>
  exit(n);
    80002cce:	fec42503          	lw	a0,-20(s0)
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	5c4080e7          	jalr	1476(ra) # 80002296 <exit>
  return 0;  // not reached
}
    80002cda:	4501                	li	a0,0
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ce4:	1141                	addi	sp,sp,-16
    80002ce6:	e406                	sd	ra,8(sp)
    80002ce8:	e022                	sd	s0,0(sp)
    80002cea:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	cd0080e7          	jalr	-816(ra) # 800019bc <myproc>
}
    80002cf4:	5908                	lw	a0,48(a0)
    80002cf6:	60a2                	ld	ra,8(sp)
    80002cf8:	6402                	ld	s0,0(sp)
    80002cfa:	0141                	addi	sp,sp,16
    80002cfc:	8082                	ret

0000000080002cfe <sys_fork>:

uint64
sys_fork(void)
{
    80002cfe:	1141                	addi	sp,sp,-16
    80002d00:	e406                	sd	ra,8(sp)
    80002d02:	e022                	sd	s0,0(sp)
    80002d04:	0800                	addi	s0,sp,16
  return fork();
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	074080e7          	jalr	116(ra) # 80001d7a <fork>
}
    80002d0e:	60a2                	ld	ra,8(sp)
    80002d10:	6402                	ld	s0,0(sp)
    80002d12:	0141                	addi	sp,sp,16
    80002d14:	8082                	ret

0000000080002d16 <sys_wait>:

uint64
sys_wait(void)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d1e:	fe840593          	addi	a1,s0,-24
    80002d22:	4501                	li	a0,0
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	ed0080e7          	jalr	-304(ra) # 80002bf4 <argaddr>
  return wait(p);
    80002d2c:	fe843503          	ld	a0,-24(s0)
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	70c080e7          	jalr	1804(ra) # 8000243c <wait>
}
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	6105                	addi	sp,sp,32
    80002d3e:	8082                	ret

0000000080002d40 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d40:	7179                	addi	sp,sp,-48
    80002d42:	f406                	sd	ra,40(sp)
    80002d44:	f022                	sd	s0,32(sp)
    80002d46:	ec26                	sd	s1,24(sp)
    80002d48:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d4a:	fdc40593          	addi	a1,s0,-36
    80002d4e:	4501                	li	a0,0
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	e84080e7          	jalr	-380(ra) # 80002bd4 <argint>
  addr = myproc()->sz;
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	c64080e7          	jalr	-924(ra) # 800019bc <myproc>
    80002d60:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d62:	fdc42503          	lw	a0,-36(s0)
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	fb8080e7          	jalr	-72(ra) # 80001d1e <growproc>
    80002d6e:	00054863          	bltz	a0,80002d7e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d72:	8526                	mv	a0,s1
    80002d74:	70a2                	ld	ra,40(sp)
    80002d76:	7402                	ld	s0,32(sp)
    80002d78:	64e2                	ld	s1,24(sp)
    80002d7a:	6145                	addi	sp,sp,48
    80002d7c:	8082                	ret
    return -1;
    80002d7e:	54fd                	li	s1,-1
    80002d80:	bfcd                	j	80002d72 <sys_sbrk+0x32>

0000000080002d82 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d82:	7139                	addi	sp,sp,-64
    80002d84:	fc06                	sd	ra,56(sp)
    80002d86:	f822                	sd	s0,48(sp)
    80002d88:	f426                	sd	s1,40(sp)
    80002d8a:	f04a                	sd	s2,32(sp)
    80002d8c:	ec4e                	sd	s3,24(sp)
    80002d8e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d90:	fcc40593          	addi	a1,s0,-52
    80002d94:	4501                	li	a0,0
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	e3e080e7          	jalr	-450(ra) # 80002bd4 <argint>
  acquire(&tickslock);
    80002d9e:	00014517          	auipc	a0,0x14
    80002da2:	c6250513          	addi	a0,a0,-926 # 80016a00 <tickslock>
    80002da6:	ffffe097          	auipc	ra,0xffffe
    80002daa:	e2c080e7          	jalr	-468(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002dae:	00006917          	auipc	s2,0x6
    80002db2:	bb292903          	lw	s2,-1102(s2) # 80008960 <ticks>
  while(ticks - ticks0 < n){
    80002db6:	fcc42783          	lw	a5,-52(s0)
    80002dba:	cf9d                	beqz	a5,80002df8 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dbc:	00014997          	auipc	s3,0x14
    80002dc0:	c4498993          	addi	s3,s3,-956 # 80016a00 <tickslock>
    80002dc4:	00006497          	auipc	s1,0x6
    80002dc8:	b9c48493          	addi	s1,s1,-1124 # 80008960 <ticks>
    if(killed(myproc())){
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	bf0080e7          	jalr	-1040(ra) # 800019bc <myproc>
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	636080e7          	jalr	1590(ra) # 8000240a <killed>
    80002ddc:	ed15                	bnez	a0,80002e18 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002dde:	85ce                	mv	a1,s3
    80002de0:	8526                	mv	a0,s1
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	380080e7          	jalr	896(ra) # 80002162 <sleep>
  while(ticks - ticks0 < n){
    80002dea:	409c                	lw	a5,0(s1)
    80002dec:	412787bb          	subw	a5,a5,s2
    80002df0:	fcc42703          	lw	a4,-52(s0)
    80002df4:	fce7ece3          	bltu	a5,a4,80002dcc <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002df8:	00014517          	auipc	a0,0x14
    80002dfc:	c0850513          	addi	a0,a0,-1016 # 80016a00 <tickslock>
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	e9c080e7          	jalr	-356(ra) # 80000c9c <release>
  return 0;
    80002e08:	4501                	li	a0,0
}
    80002e0a:	70e2                	ld	ra,56(sp)
    80002e0c:	7442                	ld	s0,48(sp)
    80002e0e:	74a2                	ld	s1,40(sp)
    80002e10:	7902                	ld	s2,32(sp)
    80002e12:	69e2                	ld	s3,24(sp)
    80002e14:	6121                	addi	sp,sp,64
    80002e16:	8082                	ret
      release(&tickslock);
    80002e18:	00014517          	auipc	a0,0x14
    80002e1c:	be850513          	addi	a0,a0,-1048 # 80016a00 <tickslock>
    80002e20:	ffffe097          	auipc	ra,0xffffe
    80002e24:	e7c080e7          	jalr	-388(ra) # 80000c9c <release>
      return -1;
    80002e28:	557d                	li	a0,-1
    80002e2a:	b7c5                	j	80002e0a <sys_sleep+0x88>

0000000080002e2c <sys_kill>:

uint64
sys_kill(void)
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e34:	fec40593          	addi	a1,s0,-20
    80002e38:	4501                	li	a0,0
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	d9a080e7          	jalr	-614(ra) # 80002bd4 <argint>
  return kill(pid);
    80002e42:	fec42503          	lw	a0,-20(s0)
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	526080e7          	jalr	1318(ra) # 8000236c <kill>
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	e426                	sd	s1,8(sp)
    80002e5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e60:	00014517          	auipc	a0,0x14
    80002e64:	ba050513          	addi	a0,a0,-1120 # 80016a00 <tickslock>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	d6a080e7          	jalr	-662(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e70:	00006497          	auipc	s1,0x6
    80002e74:	af04a483          	lw	s1,-1296(s1) # 80008960 <ticks>
  release(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	b8850513          	addi	a0,a0,-1144 # 80016a00 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	e1c080e7          	jalr	-484(ra) # 80000c9c <release>
  return xticks;
}
    80002e88:	02049513          	slli	a0,s1,0x20
    80002e8c:	9101                	srli	a0,a0,0x20
    80002e8e:	60e2                	ld	ra,24(sp)
    80002e90:	6442                	ld	s0,16(sp)
    80002e92:	64a2                	ld	s1,8(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <sys_getmem>:

//Project 2 syscalls:
uint64
sys_getmem(void)
{
    80002e98:	1141                	addi	sp,sp,-16
    80002e9a:	e406                	sd	ra,8(sp)
    80002e9c:	e022                	sd	s0,0(sp)
    80002e9e:	0800                	addi	s0,sp,16
   return myproc()->sz; // return the size of this process
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	b1c080e7          	jalr	-1252(ra) # 800019bc <myproc>
}
    80002ea8:	6528                	ld	a0,72(a0)
    80002eaa:	60a2                	ld	ra,8(sp)
    80002eac:	6402                	ld	s0,0(sp)
    80002eae:	0141                	addi	sp,sp,16
    80002eb0:	8082                	ret

0000000080002eb2 <sys_getstate>:

uint64
sys_getstate(void)
{
    80002eb2:	1141                	addi	sp,sp,-16
    80002eb4:	e406                	sd	ra,8(sp)
    80002eb6:	e022                	sd	s0,0(sp)
    80002eb8:	0800                	addi	s0,sp,16
  return myproc()->state;
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	b02080e7          	jalr	-1278(ra) # 800019bc <myproc>
}
    80002ec2:	01856503          	lwu	a0,24(a0)
    80002ec6:	60a2                	ld	ra,8(sp)
    80002ec8:	6402                	ld	s0,0(sp)
    80002eca:	0141                	addi	sp,sp,16
    80002ecc:	8082                	ret

0000000080002ece <sys_getparentpid>:

uint64
sys_getparentpid(void)
{
    80002ece:	1141                	addi	sp,sp,-16
    80002ed0:	e406                	sd	ra,8(sp)
    80002ed2:	e022                	sd	s0,0(sp)
    80002ed4:	0800                	addi	s0,sp,16
  return myproc()->parent->pid; // reutrn the parent's pid
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	ae6080e7          	jalr	-1306(ra) # 800019bc <myproc>
    80002ede:	7d1c                	ld	a5,56(a0)
}
    80002ee0:	5b88                	lw	a0,48(a5)
    80002ee2:	60a2                	ld	ra,8(sp)
    80002ee4:	6402                	ld	s0,0(sp)
    80002ee6:	0141                	addi	sp,sp,16
    80002ee8:	8082                	ret

0000000080002eea <sys_getkstack>:

uint64
sys_getkstack(void)
{
    80002eea:	1141                	addi	sp,sp,-16
    80002eec:	e406                	sd	ra,8(sp)
    80002eee:	e022                	sd	s0,0(sp)
    80002ef0:	0800                	addi	s0,sp,16
  return myproc()->kstack; // return 64bit address (Base) of kstack
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	aca080e7          	jalr	-1334(ra) # 800019bc <myproc>
}
    80002efa:	6128                	ld	a0,64(a0)
    80002efc:	60a2                	ld	ra,8(sp)
    80002efe:	6402                	ld	s0,0(sp)
    80002f00:	0141                	addi	sp,sp,16
    80002f02:	8082                	ret

0000000080002f04 <sys_getpri>:

uint64
sys_getpri(void)
{
    80002f04:	1101                	addi	sp,sp,-32
    80002f06:	ec06                	sd	ra,24(sp)
    80002f08:	e822                	sd	s0,16(sp)
    80002f0a:	e426                	sd	s1,8(sp)
    80002f0c:	1000                	addi	s0,sp,32
  int mypri;
  acquire(&myproc()->lock);
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	aae080e7          	jalr	-1362(ra) # 800019bc <myproc>
    80002f16:	ffffe097          	auipc	ra,0xffffe
    80002f1a:	cbc080e7          	jalr	-836(ra) # 80000bd2 <acquire>
  mypri = myproc()->prio;
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	a9e080e7          	jalr	-1378(ra) # 800019bc <myproc>
    80002f26:	5944                	lw	s1,52(a0)
  release(&myproc()->lock);
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	a94080e7          	jalr	-1388(ra) # 800019bc <myproc>
    80002f30:	ffffe097          	auipc	ra,0xffffe
    80002f34:	d6c080e7          	jalr	-660(ra) # 80000c9c <release>
  switch(mypri){
    80002f38:	4791                	li	a5,4
    80002f3a:	0297e763          	bltu	a5,s1,80002f68 <sys_getpri+0x64>
    80002f3e:	048a                	slli	s1,s1,0x2
    80002f40:	00005717          	auipc	a4,0x5
    80002f44:	60870713          	addi	a4,a4,1544 # 80008548 <syscalls+0xe0>
    80002f48:	94ba                	add	s1,s1,a4
    80002f4a:	409c                	lw	a5,0(s1)
    80002f4c:	97ba                	add	a5,a5,a4
    80002f4e:	8782                	jr	a5
    case HIGHEST:
      return 0xC;
    80002f50:	4531                	li	a0,12
      return 0xD;
    case LOWEST:
      return 0xF;
  }
  return -1;
}
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	64a2                	ld	s1,8(sp)
    80002f58:	6105                	addi	sp,sp,32
    80002f5a:	8082                	ret
      return 0xB;
    80002f5c:	452d                	li	a0,11
    80002f5e:	bfd5                	j	80002f52 <sys_getpri+0x4e>
      return 0xD;
    80002f60:	4535                	li	a0,13
    80002f62:	bfc5                	j	80002f52 <sys_getpri+0x4e>
      return 0xF;
    80002f64:	453d                	li	a0,15
    80002f66:	b7f5                	j	80002f52 <sys_getpri+0x4e>
  return -1;
    80002f68:	557d                	li	a0,-1
    80002f6a:	b7e5                	j	80002f52 <sys_getpri+0x4e>
  switch(mypri){
    80002f6c:	4529                	li	a0,10
    80002f6e:	b7d5                	j	80002f52 <sys_getpri+0x4e>

0000000080002f70 <sys_setpri>:

uint64
sys_setpri(void)
{
    80002f70:	7179                	addi	sp,sp,-48
    80002f72:	f406                	sd	ra,40(sp)
    80002f74:	f022                	sd	s0,32(sp)
    80002f76:	ec26                	sd	s1,24(sp)
    80002f78:	1800                	addi	s0,sp,48
  int reqpri;
  struct proc *p;
  argint(0, &reqpri); // get the requested priority
    80002f7a:	fdc40593          	addi	a1,s0,-36
    80002f7e:	4501                	li	a0,0
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	c54080e7          	jalr	-940(ra) # 80002bd4 <argint>
  p = myproc();
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	a34080e7          	jalr	-1484(ra) # 800019bc <myproc>
    80002f90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002f92:	ffffe097          	auipc	ra,0xffffe
    80002f96:	c40080e7          	jalr	-960(ra) # 80000bd2 <acquire>
  
  switch(reqpri){
    80002f9a:	fdc42783          	lw	a5,-36(s0)
    80002f9e:	37d9                	addiw	a5,a5,-10
    80002fa0:	0007869b          	sext.w	a3,a5
    80002fa4:	4715                	li	a4,5
    80002fa6:	02d76463          	bltu	a4,a3,80002fce <sys_setpri+0x5e>
    80002faa:	02079713          	slli	a4,a5,0x20
    80002fae:	01e75793          	srli	a5,a4,0x1e
    80002fb2:	00005717          	auipc	a4,0x5
    80002fb6:	5aa70713          	addi	a4,a4,1450 # 8000855c <syscalls+0xf4>
    80002fba:	97ba                	add	a5,a5,a4
    80002fbc:	439c                	lw	a5,0(a5)
    80002fbe:	97ba                	add	a5,a5,a4
    80002fc0:	8782                	jr	a5
    80002fc2:	4785                	li	a5,1
    80002fc4:	a839                	j	80002fe2 <sys_setpri+0x72>
      case 0xB:
        p->prio = MIDDLE;
        break;
      case 0xD:
        p->prio = LOW;
        break;
    80002fc6:	478d                	li	a5,3
    80002fc8:	a829                	j	80002fe2 <sys_setpri+0x72>
      case 0xF:
        p->prio = LOWEST;
        break;
    80002fca:	4791                	li	a5,4
    80002fcc:	a819                	j	80002fe2 <sys_setpri+0x72>
      default:
        release(&p->lock);
    80002fce:	8526                	mv	a0,s1
    80002fd0:	ffffe097          	auipc	ra,0xffffe
    80002fd4:	ccc080e7          	jalr	-820(ra) # 80000c9c <release>
        return -1;
    80002fd8:	557d                	li	a0,-1
    80002fda:	a819                	j	80002ff0 <sys_setpri+0x80>
  switch(reqpri){
    80002fdc:	4781                	li	a5,0
    80002fde:	a011                	j	80002fe2 <sys_setpri+0x72>
    80002fe0:	4789                	li	a5,2
        p->prio = HIGHEST;
    80002fe2:	d8dc                	sw	a5,52(s1)
    }

  release(&p->lock);
    80002fe4:	8526                	mv	a0,s1
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	cb6080e7          	jalr	-842(ra) # 80000c9c <release>
  return 0;
    80002fee:	4501                	li	a0,0
}
    80002ff0:	70a2                	ld	ra,40(sp)
    80002ff2:	7402                	ld	s0,32(sp)
    80002ff4:	64e2                	ld	s1,24(sp)
    80002ff6:	6145                	addi	sp,sp,48
    80002ff8:	8082                	ret

0000000080002ffa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ffa:	7179                	addi	sp,sp,-48
    80002ffc:	f406                	sd	ra,40(sp)
    80002ffe:	f022                	sd	s0,32(sp)
    80003000:	ec26                	sd	s1,24(sp)
    80003002:	e84a                	sd	s2,16(sp)
    80003004:	e44e                	sd	s3,8(sp)
    80003006:	e052                	sd	s4,0(sp)
    80003008:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000300a:	00005597          	auipc	a1,0x5
    8000300e:	56e58593          	addi	a1,a1,1390 # 80008578 <syscalls+0x110>
    80003012:	00014517          	auipc	a0,0x14
    80003016:	a0650513          	addi	a0,a0,-1530 # 80016a18 <bcache>
    8000301a:	ffffe097          	auipc	ra,0xffffe
    8000301e:	b28080e7          	jalr	-1240(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003022:	0001c797          	auipc	a5,0x1c
    80003026:	9f678793          	addi	a5,a5,-1546 # 8001ea18 <bcache+0x8000>
    8000302a:	0001c717          	auipc	a4,0x1c
    8000302e:	c5670713          	addi	a4,a4,-938 # 8001ec80 <bcache+0x8268>
    80003032:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003036:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000303a:	00014497          	auipc	s1,0x14
    8000303e:	9f648493          	addi	s1,s1,-1546 # 80016a30 <bcache+0x18>
    b->next = bcache.head.next;
    80003042:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003044:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003046:	00005a17          	auipc	s4,0x5
    8000304a:	53aa0a13          	addi	s4,s4,1338 # 80008580 <syscalls+0x118>
    b->next = bcache.head.next;
    8000304e:	2b893783          	ld	a5,696(s2)
    80003052:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003054:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003058:	85d2                	mv	a1,s4
    8000305a:	01048513          	addi	a0,s1,16
    8000305e:	00001097          	auipc	ra,0x1
    80003062:	496080e7          	jalr	1174(ra) # 800044f4 <initsleeplock>
    bcache.head.next->prev = b;
    80003066:	2b893783          	ld	a5,696(s2)
    8000306a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000306c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003070:	45848493          	addi	s1,s1,1112
    80003074:	fd349de3          	bne	s1,s3,8000304e <binit+0x54>
  }
}
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6942                	ld	s2,16(sp)
    80003080:	69a2                	ld	s3,8(sp)
    80003082:	6a02                	ld	s4,0(sp)
    80003084:	6145                	addi	sp,sp,48
    80003086:	8082                	ret

0000000080003088 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003088:	7179                	addi	sp,sp,-48
    8000308a:	f406                	sd	ra,40(sp)
    8000308c:	f022                	sd	s0,32(sp)
    8000308e:	ec26                	sd	s1,24(sp)
    80003090:	e84a                	sd	s2,16(sp)
    80003092:	e44e                	sd	s3,8(sp)
    80003094:	1800                	addi	s0,sp,48
    80003096:	892a                	mv	s2,a0
    80003098:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000309a:	00014517          	auipc	a0,0x14
    8000309e:	97e50513          	addi	a0,a0,-1666 # 80016a18 <bcache>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	b30080e7          	jalr	-1232(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030aa:	0001c497          	auipc	s1,0x1c
    800030ae:	c264b483          	ld	s1,-986(s1) # 8001ecd0 <bcache+0x82b8>
    800030b2:	0001c797          	auipc	a5,0x1c
    800030b6:	bce78793          	addi	a5,a5,-1074 # 8001ec80 <bcache+0x8268>
    800030ba:	02f48f63          	beq	s1,a5,800030f8 <bread+0x70>
    800030be:	873e                	mv	a4,a5
    800030c0:	a021                	j	800030c8 <bread+0x40>
    800030c2:	68a4                	ld	s1,80(s1)
    800030c4:	02e48a63          	beq	s1,a4,800030f8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030c8:	449c                	lw	a5,8(s1)
    800030ca:	ff279ce3          	bne	a5,s2,800030c2 <bread+0x3a>
    800030ce:	44dc                	lw	a5,12(s1)
    800030d0:	ff3799e3          	bne	a5,s3,800030c2 <bread+0x3a>
      b->refcnt++;
    800030d4:	40bc                	lw	a5,64(s1)
    800030d6:	2785                	addiw	a5,a5,1
    800030d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030da:	00014517          	auipc	a0,0x14
    800030de:	93e50513          	addi	a0,a0,-1730 # 80016a18 <bcache>
    800030e2:	ffffe097          	auipc	ra,0xffffe
    800030e6:	bba080e7          	jalr	-1094(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    800030ea:	01048513          	addi	a0,s1,16
    800030ee:	00001097          	auipc	ra,0x1
    800030f2:	440080e7          	jalr	1088(ra) # 8000452e <acquiresleep>
      return b;
    800030f6:	a8b9                	j	80003154 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030f8:	0001c497          	auipc	s1,0x1c
    800030fc:	bd04b483          	ld	s1,-1072(s1) # 8001ecc8 <bcache+0x82b0>
    80003100:	0001c797          	auipc	a5,0x1c
    80003104:	b8078793          	addi	a5,a5,-1152 # 8001ec80 <bcache+0x8268>
    80003108:	00f48863          	beq	s1,a5,80003118 <bread+0x90>
    8000310c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000310e:	40bc                	lw	a5,64(s1)
    80003110:	cf81                	beqz	a5,80003128 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003112:	64a4                	ld	s1,72(s1)
    80003114:	fee49de3          	bne	s1,a4,8000310e <bread+0x86>
  panic("bget: no buffers");
    80003118:	00005517          	auipc	a0,0x5
    8000311c:	47050513          	addi	a0,a0,1136 # 80008588 <syscalls+0x120>
    80003120:	ffffd097          	auipc	ra,0xffffd
    80003124:	41c080e7          	jalr	1052(ra) # 8000053c <panic>
      b->dev = dev;
    80003128:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000312c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003130:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003134:	4785                	li	a5,1
    80003136:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003138:	00014517          	auipc	a0,0x14
    8000313c:	8e050513          	addi	a0,a0,-1824 # 80016a18 <bcache>
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	b5c080e7          	jalr	-1188(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80003148:	01048513          	addi	a0,s1,16
    8000314c:	00001097          	auipc	ra,0x1
    80003150:	3e2080e7          	jalr	994(ra) # 8000452e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003154:	409c                	lw	a5,0(s1)
    80003156:	cb89                	beqz	a5,80003168 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003158:	8526                	mv	a0,s1
    8000315a:	70a2                	ld	ra,40(sp)
    8000315c:	7402                	ld	s0,32(sp)
    8000315e:	64e2                	ld	s1,24(sp)
    80003160:	6942                	ld	s2,16(sp)
    80003162:	69a2                	ld	s3,8(sp)
    80003164:	6145                	addi	sp,sp,48
    80003166:	8082                	ret
    virtio_disk_rw(b, 0);
    80003168:	4581                	li	a1,0
    8000316a:	8526                	mv	a0,s1
    8000316c:	00003097          	auipc	ra,0x3
    80003170:	f86080e7          	jalr	-122(ra) # 800060f2 <virtio_disk_rw>
    b->valid = 1;
    80003174:	4785                	li	a5,1
    80003176:	c09c                	sw	a5,0(s1)
  return b;
    80003178:	b7c5                	j	80003158 <bread+0xd0>

000000008000317a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000317a:	1101                	addi	sp,sp,-32
    8000317c:	ec06                	sd	ra,24(sp)
    8000317e:	e822                	sd	s0,16(sp)
    80003180:	e426                	sd	s1,8(sp)
    80003182:	1000                	addi	s0,sp,32
    80003184:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003186:	0541                	addi	a0,a0,16
    80003188:	00001097          	auipc	ra,0x1
    8000318c:	440080e7          	jalr	1088(ra) # 800045c8 <holdingsleep>
    80003190:	cd01                	beqz	a0,800031a8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003192:	4585                	li	a1,1
    80003194:	8526                	mv	a0,s1
    80003196:	00003097          	auipc	ra,0x3
    8000319a:	f5c080e7          	jalr	-164(ra) # 800060f2 <virtio_disk_rw>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6105                	addi	sp,sp,32
    800031a6:	8082                	ret
    panic("bwrite");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	3f850513          	addi	a0,a0,1016 # 800085a0 <syscalls+0x138>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	38c080e7          	jalr	908(ra) # 8000053c <panic>

00000000800031b8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031b8:	1101                	addi	sp,sp,-32
    800031ba:	ec06                	sd	ra,24(sp)
    800031bc:	e822                	sd	s0,16(sp)
    800031be:	e426                	sd	s1,8(sp)
    800031c0:	e04a                	sd	s2,0(sp)
    800031c2:	1000                	addi	s0,sp,32
    800031c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031c6:	01050913          	addi	s2,a0,16
    800031ca:	854a                	mv	a0,s2
    800031cc:	00001097          	auipc	ra,0x1
    800031d0:	3fc080e7          	jalr	1020(ra) # 800045c8 <holdingsleep>
    800031d4:	c925                	beqz	a0,80003244 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800031d6:	854a                	mv	a0,s2
    800031d8:	00001097          	auipc	ra,0x1
    800031dc:	3ac080e7          	jalr	940(ra) # 80004584 <releasesleep>

  acquire(&bcache.lock);
    800031e0:	00014517          	auipc	a0,0x14
    800031e4:	83850513          	addi	a0,a0,-1992 # 80016a18 <bcache>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	9ea080e7          	jalr	-1558(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031f0:	40bc                	lw	a5,64(s1)
    800031f2:	37fd                	addiw	a5,a5,-1
    800031f4:	0007871b          	sext.w	a4,a5
    800031f8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031fa:	e71d                	bnez	a4,80003228 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031fc:	68b8                	ld	a4,80(s1)
    800031fe:	64bc                	ld	a5,72(s1)
    80003200:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003202:	68b8                	ld	a4,80(s1)
    80003204:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003206:	0001c797          	auipc	a5,0x1c
    8000320a:	81278793          	addi	a5,a5,-2030 # 8001ea18 <bcache+0x8000>
    8000320e:	2b87b703          	ld	a4,696(a5)
    80003212:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003214:	0001c717          	auipc	a4,0x1c
    80003218:	a6c70713          	addi	a4,a4,-1428 # 8001ec80 <bcache+0x8268>
    8000321c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000321e:	2b87b703          	ld	a4,696(a5)
    80003222:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003224:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003228:	00013517          	auipc	a0,0x13
    8000322c:	7f050513          	addi	a0,a0,2032 # 80016a18 <bcache>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	a6c080e7          	jalr	-1428(ra) # 80000c9c <release>
}
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	64a2                	ld	s1,8(sp)
    8000323e:	6902                	ld	s2,0(sp)
    80003240:	6105                	addi	sp,sp,32
    80003242:	8082                	ret
    panic("brelse");
    80003244:	00005517          	auipc	a0,0x5
    80003248:	36450513          	addi	a0,a0,868 # 800085a8 <syscalls+0x140>
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	2f0080e7          	jalr	752(ra) # 8000053c <panic>

0000000080003254 <bpin>:

void
bpin(struct buf *b) {
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	1000                	addi	s0,sp,32
    8000325e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003260:	00013517          	auipc	a0,0x13
    80003264:	7b850513          	addi	a0,a0,1976 # 80016a18 <bcache>
    80003268:	ffffe097          	auipc	ra,0xffffe
    8000326c:	96a080e7          	jalr	-1686(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003270:	40bc                	lw	a5,64(s1)
    80003272:	2785                	addiw	a5,a5,1
    80003274:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003276:	00013517          	auipc	a0,0x13
    8000327a:	7a250513          	addi	a0,a0,1954 # 80016a18 <bcache>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	a1e080e7          	jalr	-1506(ra) # 80000c9c <release>
}
    80003286:	60e2                	ld	ra,24(sp)
    80003288:	6442                	ld	s0,16(sp)
    8000328a:	64a2                	ld	s1,8(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret

0000000080003290 <bunpin>:

void
bunpin(struct buf *b) {
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	1000                	addi	s0,sp,32
    8000329a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000329c:	00013517          	auipc	a0,0x13
    800032a0:	77c50513          	addi	a0,a0,1916 # 80016a18 <bcache>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	92e080e7          	jalr	-1746(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800032ac:	40bc                	lw	a5,64(s1)
    800032ae:	37fd                	addiw	a5,a5,-1
    800032b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b2:	00013517          	auipc	a0,0x13
    800032b6:	76650513          	addi	a0,a0,1894 # 80016a18 <bcache>
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	9e2080e7          	jalr	-1566(ra) # 80000c9c <release>
}
    800032c2:	60e2                	ld	ra,24(sp)
    800032c4:	6442                	ld	s0,16(sp)
    800032c6:	64a2                	ld	s1,8(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032cc:	1101                	addi	sp,sp,-32
    800032ce:	ec06                	sd	ra,24(sp)
    800032d0:	e822                	sd	s0,16(sp)
    800032d2:	e426                	sd	s1,8(sp)
    800032d4:	e04a                	sd	s2,0(sp)
    800032d6:	1000                	addi	s0,sp,32
    800032d8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032da:	00d5d59b          	srliw	a1,a1,0xd
    800032de:	0001c797          	auipc	a5,0x1c
    800032e2:	e167a783          	lw	a5,-490(a5) # 8001f0f4 <sb+0x1c>
    800032e6:	9dbd                	addw	a1,a1,a5
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	da0080e7          	jalr	-608(ra) # 80003088 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032f0:	0074f713          	andi	a4,s1,7
    800032f4:	4785                	li	a5,1
    800032f6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032fa:	14ce                	slli	s1,s1,0x33
    800032fc:	90d9                	srli	s1,s1,0x36
    800032fe:	00950733          	add	a4,a0,s1
    80003302:	05874703          	lbu	a4,88(a4)
    80003306:	00e7f6b3          	and	a3,a5,a4
    8000330a:	c69d                	beqz	a3,80003338 <bfree+0x6c>
    8000330c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000330e:	94aa                	add	s1,s1,a0
    80003310:	fff7c793          	not	a5,a5
    80003314:	8f7d                	and	a4,a4,a5
    80003316:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000331a:	00001097          	auipc	ra,0x1
    8000331e:	0f6080e7          	jalr	246(ra) # 80004410 <log_write>
  brelse(bp);
    80003322:	854a                	mv	a0,s2
    80003324:	00000097          	auipc	ra,0x0
    80003328:	e94080e7          	jalr	-364(ra) # 800031b8 <brelse>
}
    8000332c:	60e2                	ld	ra,24(sp)
    8000332e:	6442                	ld	s0,16(sp)
    80003330:	64a2                	ld	s1,8(sp)
    80003332:	6902                	ld	s2,0(sp)
    80003334:	6105                	addi	sp,sp,32
    80003336:	8082                	ret
    panic("freeing free block");
    80003338:	00005517          	auipc	a0,0x5
    8000333c:	27850513          	addi	a0,a0,632 # 800085b0 <syscalls+0x148>
    80003340:	ffffd097          	auipc	ra,0xffffd
    80003344:	1fc080e7          	jalr	508(ra) # 8000053c <panic>

0000000080003348 <balloc>:
{
    80003348:	711d                	addi	sp,sp,-96
    8000334a:	ec86                	sd	ra,88(sp)
    8000334c:	e8a2                	sd	s0,80(sp)
    8000334e:	e4a6                	sd	s1,72(sp)
    80003350:	e0ca                	sd	s2,64(sp)
    80003352:	fc4e                	sd	s3,56(sp)
    80003354:	f852                	sd	s4,48(sp)
    80003356:	f456                	sd	s5,40(sp)
    80003358:	f05a                	sd	s6,32(sp)
    8000335a:	ec5e                	sd	s7,24(sp)
    8000335c:	e862                	sd	s8,16(sp)
    8000335e:	e466                	sd	s9,8(sp)
    80003360:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003362:	0001c797          	auipc	a5,0x1c
    80003366:	d7a7a783          	lw	a5,-646(a5) # 8001f0dc <sb+0x4>
    8000336a:	cff5                	beqz	a5,80003466 <balloc+0x11e>
    8000336c:	8baa                	mv	s7,a0
    8000336e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003370:	0001cb17          	auipc	s6,0x1c
    80003374:	d68b0b13          	addi	s6,s6,-664 # 8001f0d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003378:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000337a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000337e:	6c89                	lui	s9,0x2
    80003380:	a061                	j	80003408 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003382:	97ca                	add	a5,a5,s2
    80003384:	8e55                	or	a2,a2,a3
    80003386:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000338a:	854a                	mv	a0,s2
    8000338c:	00001097          	auipc	ra,0x1
    80003390:	084080e7          	jalr	132(ra) # 80004410 <log_write>
        brelse(bp);
    80003394:	854a                	mv	a0,s2
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	e22080e7          	jalr	-478(ra) # 800031b8 <brelse>
  bp = bread(dev, bno);
    8000339e:	85a6                	mv	a1,s1
    800033a0:	855e                	mv	a0,s7
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	ce6080e7          	jalr	-794(ra) # 80003088 <bread>
    800033aa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033ac:	40000613          	li	a2,1024
    800033b0:	4581                	li	a1,0
    800033b2:	05850513          	addi	a0,a0,88
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	92e080e7          	jalr	-1746(ra) # 80000ce4 <memset>
  log_write(bp);
    800033be:	854a                	mv	a0,s2
    800033c0:	00001097          	auipc	ra,0x1
    800033c4:	050080e7          	jalr	80(ra) # 80004410 <log_write>
  brelse(bp);
    800033c8:	854a                	mv	a0,s2
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	dee080e7          	jalr	-530(ra) # 800031b8 <brelse>
}
    800033d2:	8526                	mv	a0,s1
    800033d4:	60e6                	ld	ra,88(sp)
    800033d6:	6446                	ld	s0,80(sp)
    800033d8:	64a6                	ld	s1,72(sp)
    800033da:	6906                	ld	s2,64(sp)
    800033dc:	79e2                	ld	s3,56(sp)
    800033de:	7a42                	ld	s4,48(sp)
    800033e0:	7aa2                	ld	s5,40(sp)
    800033e2:	7b02                	ld	s6,32(sp)
    800033e4:	6be2                	ld	s7,24(sp)
    800033e6:	6c42                	ld	s8,16(sp)
    800033e8:	6ca2                	ld	s9,8(sp)
    800033ea:	6125                	addi	sp,sp,96
    800033ec:	8082                	ret
    brelse(bp);
    800033ee:	854a                	mv	a0,s2
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	dc8080e7          	jalr	-568(ra) # 800031b8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033f8:	015c87bb          	addw	a5,s9,s5
    800033fc:	00078a9b          	sext.w	s5,a5
    80003400:	004b2703          	lw	a4,4(s6)
    80003404:	06eaf163          	bgeu	s5,a4,80003466 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003408:	41fad79b          	sraiw	a5,s5,0x1f
    8000340c:	0137d79b          	srliw	a5,a5,0x13
    80003410:	015787bb          	addw	a5,a5,s5
    80003414:	40d7d79b          	sraiw	a5,a5,0xd
    80003418:	01cb2583          	lw	a1,28(s6)
    8000341c:	9dbd                	addw	a1,a1,a5
    8000341e:	855e                	mv	a0,s7
    80003420:	00000097          	auipc	ra,0x0
    80003424:	c68080e7          	jalr	-920(ra) # 80003088 <bread>
    80003428:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000342a:	004b2503          	lw	a0,4(s6)
    8000342e:	000a849b          	sext.w	s1,s5
    80003432:	8762                	mv	a4,s8
    80003434:	faa4fde3          	bgeu	s1,a0,800033ee <balloc+0xa6>
      m = 1 << (bi % 8);
    80003438:	00777693          	andi	a3,a4,7
    8000343c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003440:	41f7579b          	sraiw	a5,a4,0x1f
    80003444:	01d7d79b          	srliw	a5,a5,0x1d
    80003448:	9fb9                	addw	a5,a5,a4
    8000344a:	4037d79b          	sraiw	a5,a5,0x3
    8000344e:	00f90633          	add	a2,s2,a5
    80003452:	05864603          	lbu	a2,88(a2)
    80003456:	00c6f5b3          	and	a1,a3,a2
    8000345a:	d585                	beqz	a1,80003382 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345c:	2705                	addiw	a4,a4,1
    8000345e:	2485                	addiw	s1,s1,1
    80003460:	fd471ae3          	bne	a4,s4,80003434 <balloc+0xec>
    80003464:	b769                	j	800033ee <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	16250513          	addi	a0,a0,354 # 800085c8 <syscalls+0x160>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	118080e7          	jalr	280(ra) # 80000586 <printf>
  return 0;
    80003476:	4481                	li	s1,0
    80003478:	bfa9                	j	800033d2 <balloc+0x8a>

000000008000347a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000347a:	7179                	addi	sp,sp,-48
    8000347c:	f406                	sd	ra,40(sp)
    8000347e:	f022                	sd	s0,32(sp)
    80003480:	ec26                	sd	s1,24(sp)
    80003482:	e84a                	sd	s2,16(sp)
    80003484:	e44e                	sd	s3,8(sp)
    80003486:	e052                	sd	s4,0(sp)
    80003488:	1800                	addi	s0,sp,48
    8000348a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000348c:	47ad                	li	a5,11
    8000348e:	02b7e863          	bltu	a5,a1,800034be <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003492:	02059793          	slli	a5,a1,0x20
    80003496:	01e7d593          	srli	a1,a5,0x1e
    8000349a:	00b504b3          	add	s1,a0,a1
    8000349e:	0504a903          	lw	s2,80(s1)
    800034a2:	06091e63          	bnez	s2,8000351e <bmap+0xa4>
      addr = balloc(ip->dev);
    800034a6:	4108                	lw	a0,0(a0)
    800034a8:	00000097          	auipc	ra,0x0
    800034ac:	ea0080e7          	jalr	-352(ra) # 80003348 <balloc>
    800034b0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034b4:	06090563          	beqz	s2,8000351e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800034b8:	0524a823          	sw	s2,80(s1)
    800034bc:	a08d                	j	8000351e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034be:	ff45849b          	addiw	s1,a1,-12
    800034c2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034c6:	0ff00793          	li	a5,255
    800034ca:	08e7e563          	bltu	a5,a4,80003554 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034ce:	08052903          	lw	s2,128(a0)
    800034d2:	00091d63          	bnez	s2,800034ec <bmap+0x72>
      addr = balloc(ip->dev);
    800034d6:	4108                	lw	a0,0(a0)
    800034d8:	00000097          	auipc	ra,0x0
    800034dc:	e70080e7          	jalr	-400(ra) # 80003348 <balloc>
    800034e0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034e4:	02090d63          	beqz	s2,8000351e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034e8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800034ec:	85ca                	mv	a1,s2
    800034ee:	0009a503          	lw	a0,0(s3)
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	b96080e7          	jalr	-1130(ra) # 80003088 <bread>
    800034fa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034fc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003500:	02049713          	slli	a4,s1,0x20
    80003504:	01e75593          	srli	a1,a4,0x1e
    80003508:	00b784b3          	add	s1,a5,a1
    8000350c:	0004a903          	lw	s2,0(s1)
    80003510:	02090063          	beqz	s2,80003530 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003514:	8552                	mv	a0,s4
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	ca2080e7          	jalr	-862(ra) # 800031b8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000351e:	854a                	mv	a0,s2
    80003520:	70a2                	ld	ra,40(sp)
    80003522:	7402                	ld	s0,32(sp)
    80003524:	64e2                	ld	s1,24(sp)
    80003526:	6942                	ld	s2,16(sp)
    80003528:	69a2                	ld	s3,8(sp)
    8000352a:	6a02                	ld	s4,0(sp)
    8000352c:	6145                	addi	sp,sp,48
    8000352e:	8082                	ret
      addr = balloc(ip->dev);
    80003530:	0009a503          	lw	a0,0(s3)
    80003534:	00000097          	auipc	ra,0x0
    80003538:	e14080e7          	jalr	-492(ra) # 80003348 <balloc>
    8000353c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003540:	fc090ae3          	beqz	s2,80003514 <bmap+0x9a>
        a[bn] = addr;
    80003544:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003548:	8552                	mv	a0,s4
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	ec6080e7          	jalr	-314(ra) # 80004410 <log_write>
    80003552:	b7c9                	j	80003514 <bmap+0x9a>
  panic("bmap: out of range");
    80003554:	00005517          	auipc	a0,0x5
    80003558:	08c50513          	addi	a0,a0,140 # 800085e0 <syscalls+0x178>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	fe0080e7          	jalr	-32(ra) # 8000053c <panic>

0000000080003564 <iget>:
{
    80003564:	7179                	addi	sp,sp,-48
    80003566:	f406                	sd	ra,40(sp)
    80003568:	f022                	sd	s0,32(sp)
    8000356a:	ec26                	sd	s1,24(sp)
    8000356c:	e84a                	sd	s2,16(sp)
    8000356e:	e44e                	sd	s3,8(sp)
    80003570:	e052                	sd	s4,0(sp)
    80003572:	1800                	addi	s0,sp,48
    80003574:	89aa                	mv	s3,a0
    80003576:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003578:	0001c517          	auipc	a0,0x1c
    8000357c:	b8050513          	addi	a0,a0,-1152 # 8001f0f8 <itable>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	652080e7          	jalr	1618(ra) # 80000bd2 <acquire>
  empty = 0;
    80003588:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000358a:	0001c497          	auipc	s1,0x1c
    8000358e:	b8648493          	addi	s1,s1,-1146 # 8001f110 <itable+0x18>
    80003592:	0001d697          	auipc	a3,0x1d
    80003596:	60e68693          	addi	a3,a3,1550 # 80020ba0 <log>
    8000359a:	a039                	j	800035a8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000359c:	02090b63          	beqz	s2,800035d2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035a0:	08848493          	addi	s1,s1,136
    800035a4:	02d48a63          	beq	s1,a3,800035d8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035a8:	449c                	lw	a5,8(s1)
    800035aa:	fef059e3          	blez	a5,8000359c <iget+0x38>
    800035ae:	4098                	lw	a4,0(s1)
    800035b0:	ff3716e3          	bne	a4,s3,8000359c <iget+0x38>
    800035b4:	40d8                	lw	a4,4(s1)
    800035b6:	ff4713e3          	bne	a4,s4,8000359c <iget+0x38>
      ip->ref++;
    800035ba:	2785                	addiw	a5,a5,1
    800035bc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035be:	0001c517          	auipc	a0,0x1c
    800035c2:	b3a50513          	addi	a0,a0,-1222 # 8001f0f8 <itable>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	6d6080e7          	jalr	1750(ra) # 80000c9c <release>
      return ip;
    800035ce:	8926                	mv	s2,s1
    800035d0:	a03d                	j	800035fe <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035d2:	f7f9                	bnez	a5,800035a0 <iget+0x3c>
    800035d4:	8926                	mv	s2,s1
    800035d6:	b7e9                	j	800035a0 <iget+0x3c>
  if(empty == 0)
    800035d8:	02090c63          	beqz	s2,80003610 <iget+0xac>
  ip->dev = dev;
    800035dc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035e0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035e4:	4785                	li	a5,1
    800035e6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035ea:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035ee:	0001c517          	auipc	a0,0x1c
    800035f2:	b0a50513          	addi	a0,a0,-1270 # 8001f0f8 <itable>
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	6a6080e7          	jalr	1702(ra) # 80000c9c <release>
}
    800035fe:	854a                	mv	a0,s2
    80003600:	70a2                	ld	ra,40(sp)
    80003602:	7402                	ld	s0,32(sp)
    80003604:	64e2                	ld	s1,24(sp)
    80003606:	6942                	ld	s2,16(sp)
    80003608:	69a2                	ld	s3,8(sp)
    8000360a:	6a02                	ld	s4,0(sp)
    8000360c:	6145                	addi	sp,sp,48
    8000360e:	8082                	ret
    panic("iget: no inodes");
    80003610:	00005517          	auipc	a0,0x5
    80003614:	fe850513          	addi	a0,a0,-24 # 800085f8 <syscalls+0x190>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	f24080e7          	jalr	-220(ra) # 8000053c <panic>

0000000080003620 <fsinit>:
fsinit(int dev) {
    80003620:	7179                	addi	sp,sp,-48
    80003622:	f406                	sd	ra,40(sp)
    80003624:	f022                	sd	s0,32(sp)
    80003626:	ec26                	sd	s1,24(sp)
    80003628:	e84a                	sd	s2,16(sp)
    8000362a:	e44e                	sd	s3,8(sp)
    8000362c:	1800                	addi	s0,sp,48
    8000362e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003630:	4585                	li	a1,1
    80003632:	00000097          	auipc	ra,0x0
    80003636:	a56080e7          	jalr	-1450(ra) # 80003088 <bread>
    8000363a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000363c:	0001c997          	auipc	s3,0x1c
    80003640:	a9c98993          	addi	s3,s3,-1380 # 8001f0d8 <sb>
    80003644:	02000613          	li	a2,32
    80003648:	05850593          	addi	a1,a0,88
    8000364c:	854e                	mv	a0,s3
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	6f2080e7          	jalr	1778(ra) # 80000d40 <memmove>
  brelse(bp);
    80003656:	8526                	mv	a0,s1
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	b60080e7          	jalr	-1184(ra) # 800031b8 <brelse>
  if(sb.magic != FSMAGIC)
    80003660:	0009a703          	lw	a4,0(s3)
    80003664:	102037b7          	lui	a5,0x10203
    80003668:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000366c:	02f71263          	bne	a4,a5,80003690 <fsinit+0x70>
  initlog(dev, &sb);
    80003670:	0001c597          	auipc	a1,0x1c
    80003674:	a6858593          	addi	a1,a1,-1432 # 8001f0d8 <sb>
    80003678:	854a                	mv	a0,s2
    8000367a:	00001097          	auipc	ra,0x1
    8000367e:	b2c080e7          	jalr	-1236(ra) # 800041a6 <initlog>
}
    80003682:	70a2                	ld	ra,40(sp)
    80003684:	7402                	ld	s0,32(sp)
    80003686:	64e2                	ld	s1,24(sp)
    80003688:	6942                	ld	s2,16(sp)
    8000368a:	69a2                	ld	s3,8(sp)
    8000368c:	6145                	addi	sp,sp,48
    8000368e:	8082                	ret
    panic("invalid file system");
    80003690:	00005517          	auipc	a0,0x5
    80003694:	f7850513          	addi	a0,a0,-136 # 80008608 <syscalls+0x1a0>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	ea4080e7          	jalr	-348(ra) # 8000053c <panic>

00000000800036a0 <iinit>:
{
    800036a0:	7179                	addi	sp,sp,-48
    800036a2:	f406                	sd	ra,40(sp)
    800036a4:	f022                	sd	s0,32(sp)
    800036a6:	ec26                	sd	s1,24(sp)
    800036a8:	e84a                	sd	s2,16(sp)
    800036aa:	e44e                	sd	s3,8(sp)
    800036ac:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036ae:	00005597          	auipc	a1,0x5
    800036b2:	f7258593          	addi	a1,a1,-142 # 80008620 <syscalls+0x1b8>
    800036b6:	0001c517          	auipc	a0,0x1c
    800036ba:	a4250513          	addi	a0,a0,-1470 # 8001f0f8 <itable>
    800036be:	ffffd097          	auipc	ra,0xffffd
    800036c2:	484080e7          	jalr	1156(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036c6:	0001c497          	auipc	s1,0x1c
    800036ca:	a5a48493          	addi	s1,s1,-1446 # 8001f120 <itable+0x28>
    800036ce:	0001d997          	auipc	s3,0x1d
    800036d2:	4e298993          	addi	s3,s3,1250 # 80020bb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036d6:	00005917          	auipc	s2,0x5
    800036da:	f5290913          	addi	s2,s2,-174 # 80008628 <syscalls+0x1c0>
    800036de:	85ca                	mv	a1,s2
    800036e0:	8526                	mv	a0,s1
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	e12080e7          	jalr	-494(ra) # 800044f4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036ea:	08848493          	addi	s1,s1,136
    800036ee:	ff3498e3          	bne	s1,s3,800036de <iinit+0x3e>
}
    800036f2:	70a2                	ld	ra,40(sp)
    800036f4:	7402                	ld	s0,32(sp)
    800036f6:	64e2                	ld	s1,24(sp)
    800036f8:	6942                	ld	s2,16(sp)
    800036fa:	69a2                	ld	s3,8(sp)
    800036fc:	6145                	addi	sp,sp,48
    800036fe:	8082                	ret

0000000080003700 <ialloc>:
{
    80003700:	7139                	addi	sp,sp,-64
    80003702:	fc06                	sd	ra,56(sp)
    80003704:	f822                	sd	s0,48(sp)
    80003706:	f426                	sd	s1,40(sp)
    80003708:	f04a                	sd	s2,32(sp)
    8000370a:	ec4e                	sd	s3,24(sp)
    8000370c:	e852                	sd	s4,16(sp)
    8000370e:	e456                	sd	s5,8(sp)
    80003710:	e05a                	sd	s6,0(sp)
    80003712:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003714:	0001c717          	auipc	a4,0x1c
    80003718:	9d072703          	lw	a4,-1584(a4) # 8001f0e4 <sb+0xc>
    8000371c:	4785                	li	a5,1
    8000371e:	04e7f863          	bgeu	a5,a4,8000376e <ialloc+0x6e>
    80003722:	8aaa                	mv	s5,a0
    80003724:	8b2e                	mv	s6,a1
    80003726:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003728:	0001ca17          	auipc	s4,0x1c
    8000372c:	9b0a0a13          	addi	s4,s4,-1616 # 8001f0d8 <sb>
    80003730:	00495593          	srli	a1,s2,0x4
    80003734:	018a2783          	lw	a5,24(s4)
    80003738:	9dbd                	addw	a1,a1,a5
    8000373a:	8556                	mv	a0,s5
    8000373c:	00000097          	auipc	ra,0x0
    80003740:	94c080e7          	jalr	-1716(ra) # 80003088 <bread>
    80003744:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003746:	05850993          	addi	s3,a0,88
    8000374a:	00f97793          	andi	a5,s2,15
    8000374e:	079a                	slli	a5,a5,0x6
    80003750:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003752:	00099783          	lh	a5,0(s3)
    80003756:	cf9d                	beqz	a5,80003794 <ialloc+0x94>
    brelse(bp);
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	a60080e7          	jalr	-1440(ra) # 800031b8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003760:	0905                	addi	s2,s2,1
    80003762:	00ca2703          	lw	a4,12(s4)
    80003766:	0009079b          	sext.w	a5,s2
    8000376a:	fce7e3e3          	bltu	a5,a4,80003730 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000376e:	00005517          	auipc	a0,0x5
    80003772:	ec250513          	addi	a0,a0,-318 # 80008630 <syscalls+0x1c8>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	e10080e7          	jalr	-496(ra) # 80000586 <printf>
  return 0;
    8000377e:	4501                	li	a0,0
}
    80003780:	70e2                	ld	ra,56(sp)
    80003782:	7442                	ld	s0,48(sp)
    80003784:	74a2                	ld	s1,40(sp)
    80003786:	7902                	ld	s2,32(sp)
    80003788:	69e2                	ld	s3,24(sp)
    8000378a:	6a42                	ld	s4,16(sp)
    8000378c:	6aa2                	ld	s5,8(sp)
    8000378e:	6b02                	ld	s6,0(sp)
    80003790:	6121                	addi	sp,sp,64
    80003792:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003794:	04000613          	li	a2,64
    80003798:	4581                	li	a1,0
    8000379a:	854e                	mv	a0,s3
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	548080e7          	jalr	1352(ra) # 80000ce4 <memset>
      dip->type = type;
    800037a4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037a8:	8526                	mv	a0,s1
    800037aa:	00001097          	auipc	ra,0x1
    800037ae:	c66080e7          	jalr	-922(ra) # 80004410 <log_write>
      brelse(bp);
    800037b2:	8526                	mv	a0,s1
    800037b4:	00000097          	auipc	ra,0x0
    800037b8:	a04080e7          	jalr	-1532(ra) # 800031b8 <brelse>
      return iget(dev, inum);
    800037bc:	0009059b          	sext.w	a1,s2
    800037c0:	8556                	mv	a0,s5
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	da2080e7          	jalr	-606(ra) # 80003564 <iget>
    800037ca:	bf5d                	j	80003780 <ialloc+0x80>

00000000800037cc <iupdate>:
{
    800037cc:	1101                	addi	sp,sp,-32
    800037ce:	ec06                	sd	ra,24(sp)
    800037d0:	e822                	sd	s0,16(sp)
    800037d2:	e426                	sd	s1,8(sp)
    800037d4:	e04a                	sd	s2,0(sp)
    800037d6:	1000                	addi	s0,sp,32
    800037d8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037da:	415c                	lw	a5,4(a0)
    800037dc:	0047d79b          	srliw	a5,a5,0x4
    800037e0:	0001c597          	auipc	a1,0x1c
    800037e4:	9105a583          	lw	a1,-1776(a1) # 8001f0f0 <sb+0x18>
    800037e8:	9dbd                	addw	a1,a1,a5
    800037ea:	4108                	lw	a0,0(a0)
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	89c080e7          	jalr	-1892(ra) # 80003088 <bread>
    800037f4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037f6:	05850793          	addi	a5,a0,88
    800037fa:	40d8                	lw	a4,4(s1)
    800037fc:	8b3d                	andi	a4,a4,15
    800037fe:	071a                	slli	a4,a4,0x6
    80003800:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003802:	04449703          	lh	a4,68(s1)
    80003806:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000380a:	04649703          	lh	a4,70(s1)
    8000380e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003812:	04849703          	lh	a4,72(s1)
    80003816:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000381a:	04a49703          	lh	a4,74(s1)
    8000381e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003822:	44f8                	lw	a4,76(s1)
    80003824:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003826:	03400613          	li	a2,52
    8000382a:	05048593          	addi	a1,s1,80
    8000382e:	00c78513          	addi	a0,a5,12
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	50e080e7          	jalr	1294(ra) # 80000d40 <memmove>
  log_write(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	bd4080e7          	jalr	-1068(ra) # 80004410 <log_write>
  brelse(bp);
    80003844:	854a                	mv	a0,s2
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	972080e7          	jalr	-1678(ra) # 800031b8 <brelse>
}
    8000384e:	60e2                	ld	ra,24(sp)
    80003850:	6442                	ld	s0,16(sp)
    80003852:	64a2                	ld	s1,8(sp)
    80003854:	6902                	ld	s2,0(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret

000000008000385a <idup>:
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	1000                	addi	s0,sp,32
    80003864:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003866:	0001c517          	auipc	a0,0x1c
    8000386a:	89250513          	addi	a0,a0,-1902 # 8001f0f8 <itable>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	364080e7          	jalr	868(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003876:	449c                	lw	a5,8(s1)
    80003878:	2785                	addiw	a5,a5,1
    8000387a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000387c:	0001c517          	auipc	a0,0x1c
    80003880:	87c50513          	addi	a0,a0,-1924 # 8001f0f8 <itable>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	418080e7          	jalr	1048(ra) # 80000c9c <release>
}
    8000388c:	8526                	mv	a0,s1
    8000388e:	60e2                	ld	ra,24(sp)
    80003890:	6442                	ld	s0,16(sp)
    80003892:	64a2                	ld	s1,8(sp)
    80003894:	6105                	addi	sp,sp,32
    80003896:	8082                	ret

0000000080003898 <ilock>:
{
    80003898:	1101                	addi	sp,sp,-32
    8000389a:	ec06                	sd	ra,24(sp)
    8000389c:	e822                	sd	s0,16(sp)
    8000389e:	e426                	sd	s1,8(sp)
    800038a0:	e04a                	sd	s2,0(sp)
    800038a2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038a4:	c115                	beqz	a0,800038c8 <ilock+0x30>
    800038a6:	84aa                	mv	s1,a0
    800038a8:	451c                	lw	a5,8(a0)
    800038aa:	00f05f63          	blez	a5,800038c8 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038ae:	0541                	addi	a0,a0,16
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	c7e080e7          	jalr	-898(ra) # 8000452e <acquiresleep>
  if(ip->valid == 0){
    800038b8:	40bc                	lw	a5,64(s1)
    800038ba:	cf99                	beqz	a5,800038d8 <ilock+0x40>
}
    800038bc:	60e2                	ld	ra,24(sp)
    800038be:	6442                	ld	s0,16(sp)
    800038c0:	64a2                	ld	s1,8(sp)
    800038c2:	6902                	ld	s2,0(sp)
    800038c4:	6105                	addi	sp,sp,32
    800038c6:	8082                	ret
    panic("ilock");
    800038c8:	00005517          	auipc	a0,0x5
    800038cc:	d8050513          	addi	a0,a0,-640 # 80008648 <syscalls+0x1e0>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	c6c080e7          	jalr	-916(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038d8:	40dc                	lw	a5,4(s1)
    800038da:	0047d79b          	srliw	a5,a5,0x4
    800038de:	0001c597          	auipc	a1,0x1c
    800038e2:	8125a583          	lw	a1,-2030(a1) # 8001f0f0 <sb+0x18>
    800038e6:	9dbd                	addw	a1,a1,a5
    800038e8:	4088                	lw	a0,0(s1)
    800038ea:	fffff097          	auipc	ra,0xfffff
    800038ee:	79e080e7          	jalr	1950(ra) # 80003088 <bread>
    800038f2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038f4:	05850593          	addi	a1,a0,88
    800038f8:	40dc                	lw	a5,4(s1)
    800038fa:	8bbd                	andi	a5,a5,15
    800038fc:	079a                	slli	a5,a5,0x6
    800038fe:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003900:	00059783          	lh	a5,0(a1)
    80003904:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003908:	00259783          	lh	a5,2(a1)
    8000390c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003910:	00459783          	lh	a5,4(a1)
    80003914:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003918:	00659783          	lh	a5,6(a1)
    8000391c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003920:	459c                	lw	a5,8(a1)
    80003922:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003924:	03400613          	li	a2,52
    80003928:	05b1                	addi	a1,a1,12
    8000392a:	05048513          	addi	a0,s1,80
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	412080e7          	jalr	1042(ra) # 80000d40 <memmove>
    brelse(bp);
    80003936:	854a                	mv	a0,s2
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	880080e7          	jalr	-1920(ra) # 800031b8 <brelse>
    ip->valid = 1;
    80003940:	4785                	li	a5,1
    80003942:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003944:	04449783          	lh	a5,68(s1)
    80003948:	fbb5                	bnez	a5,800038bc <ilock+0x24>
      panic("ilock: no type");
    8000394a:	00005517          	auipc	a0,0x5
    8000394e:	d0650513          	addi	a0,a0,-762 # 80008650 <syscalls+0x1e8>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	bea080e7          	jalr	-1046(ra) # 8000053c <panic>

000000008000395a <iunlock>:
{
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	e04a                	sd	s2,0(sp)
    80003964:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003966:	c905                	beqz	a0,80003996 <iunlock+0x3c>
    80003968:	84aa                	mv	s1,a0
    8000396a:	01050913          	addi	s2,a0,16
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	c58080e7          	jalr	-936(ra) # 800045c8 <holdingsleep>
    80003978:	cd19                	beqz	a0,80003996 <iunlock+0x3c>
    8000397a:	449c                	lw	a5,8(s1)
    8000397c:	00f05d63          	blez	a5,80003996 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003980:	854a                	mv	a0,s2
    80003982:	00001097          	auipc	ra,0x1
    80003986:	c02080e7          	jalr	-1022(ra) # 80004584 <releasesleep>
}
    8000398a:	60e2                	ld	ra,24(sp)
    8000398c:	6442                	ld	s0,16(sp)
    8000398e:	64a2                	ld	s1,8(sp)
    80003990:	6902                	ld	s2,0(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret
    panic("iunlock");
    80003996:	00005517          	auipc	a0,0x5
    8000399a:	cca50513          	addi	a0,a0,-822 # 80008660 <syscalls+0x1f8>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	b9e080e7          	jalr	-1122(ra) # 8000053c <panic>

00000000800039a6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039a6:	7179                	addi	sp,sp,-48
    800039a8:	f406                	sd	ra,40(sp)
    800039aa:	f022                	sd	s0,32(sp)
    800039ac:	ec26                	sd	s1,24(sp)
    800039ae:	e84a                	sd	s2,16(sp)
    800039b0:	e44e                	sd	s3,8(sp)
    800039b2:	e052                	sd	s4,0(sp)
    800039b4:	1800                	addi	s0,sp,48
    800039b6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039b8:	05050493          	addi	s1,a0,80
    800039bc:	08050913          	addi	s2,a0,128
    800039c0:	a021                	j	800039c8 <itrunc+0x22>
    800039c2:	0491                	addi	s1,s1,4
    800039c4:	01248d63          	beq	s1,s2,800039de <itrunc+0x38>
    if(ip->addrs[i]){
    800039c8:	408c                	lw	a1,0(s1)
    800039ca:	dde5                	beqz	a1,800039c2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039cc:	0009a503          	lw	a0,0(s3)
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	8fc080e7          	jalr	-1796(ra) # 800032cc <bfree>
      ip->addrs[i] = 0;
    800039d8:	0004a023          	sw	zero,0(s1)
    800039dc:	b7dd                	j	800039c2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039de:	0809a583          	lw	a1,128(s3)
    800039e2:	e185                	bnez	a1,80003a02 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039e4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039e8:	854e                	mv	a0,s3
    800039ea:	00000097          	auipc	ra,0x0
    800039ee:	de2080e7          	jalr	-542(ra) # 800037cc <iupdate>
}
    800039f2:	70a2                	ld	ra,40(sp)
    800039f4:	7402                	ld	s0,32(sp)
    800039f6:	64e2                	ld	s1,24(sp)
    800039f8:	6942                	ld	s2,16(sp)
    800039fa:	69a2                	ld	s3,8(sp)
    800039fc:	6a02                	ld	s4,0(sp)
    800039fe:	6145                	addi	sp,sp,48
    80003a00:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a02:	0009a503          	lw	a0,0(s3)
    80003a06:	fffff097          	auipc	ra,0xfffff
    80003a0a:	682080e7          	jalr	1666(ra) # 80003088 <bread>
    80003a0e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a10:	05850493          	addi	s1,a0,88
    80003a14:	45850913          	addi	s2,a0,1112
    80003a18:	a021                	j	80003a20 <itrunc+0x7a>
    80003a1a:	0491                	addi	s1,s1,4
    80003a1c:	01248b63          	beq	s1,s2,80003a32 <itrunc+0x8c>
      if(a[j])
    80003a20:	408c                	lw	a1,0(s1)
    80003a22:	dde5                	beqz	a1,80003a1a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a24:	0009a503          	lw	a0,0(s3)
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	8a4080e7          	jalr	-1884(ra) # 800032cc <bfree>
    80003a30:	b7ed                	j	80003a1a <itrunc+0x74>
    brelse(bp);
    80003a32:	8552                	mv	a0,s4
    80003a34:	fffff097          	auipc	ra,0xfffff
    80003a38:	784080e7          	jalr	1924(ra) # 800031b8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a3c:	0809a583          	lw	a1,128(s3)
    80003a40:	0009a503          	lw	a0,0(s3)
    80003a44:	00000097          	auipc	ra,0x0
    80003a48:	888080e7          	jalr	-1912(ra) # 800032cc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a4c:	0809a023          	sw	zero,128(s3)
    80003a50:	bf51                	j	800039e4 <itrunc+0x3e>

0000000080003a52 <iput>:
{
    80003a52:	1101                	addi	sp,sp,-32
    80003a54:	ec06                	sd	ra,24(sp)
    80003a56:	e822                	sd	s0,16(sp)
    80003a58:	e426                	sd	s1,8(sp)
    80003a5a:	e04a                	sd	s2,0(sp)
    80003a5c:	1000                	addi	s0,sp,32
    80003a5e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a60:	0001b517          	auipc	a0,0x1b
    80003a64:	69850513          	addi	a0,a0,1688 # 8001f0f8 <itable>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	16a080e7          	jalr	362(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a70:	4498                	lw	a4,8(s1)
    80003a72:	4785                	li	a5,1
    80003a74:	02f70363          	beq	a4,a5,80003a9a <iput+0x48>
  ip->ref--;
    80003a78:	449c                	lw	a5,8(s1)
    80003a7a:	37fd                	addiw	a5,a5,-1
    80003a7c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a7e:	0001b517          	auipc	a0,0x1b
    80003a82:	67a50513          	addi	a0,a0,1658 # 8001f0f8 <itable>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	216080e7          	jalr	534(ra) # 80000c9c <release>
}
    80003a8e:	60e2                	ld	ra,24(sp)
    80003a90:	6442                	ld	s0,16(sp)
    80003a92:	64a2                	ld	s1,8(sp)
    80003a94:	6902                	ld	s2,0(sp)
    80003a96:	6105                	addi	sp,sp,32
    80003a98:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a9a:	40bc                	lw	a5,64(s1)
    80003a9c:	dff1                	beqz	a5,80003a78 <iput+0x26>
    80003a9e:	04a49783          	lh	a5,74(s1)
    80003aa2:	fbf9                	bnez	a5,80003a78 <iput+0x26>
    acquiresleep(&ip->lock);
    80003aa4:	01048913          	addi	s2,s1,16
    80003aa8:	854a                	mv	a0,s2
    80003aaa:	00001097          	auipc	ra,0x1
    80003aae:	a84080e7          	jalr	-1404(ra) # 8000452e <acquiresleep>
    release(&itable.lock);
    80003ab2:	0001b517          	auipc	a0,0x1b
    80003ab6:	64650513          	addi	a0,a0,1606 # 8001f0f8 <itable>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	1e2080e7          	jalr	482(ra) # 80000c9c <release>
    itrunc(ip);
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	00000097          	auipc	ra,0x0
    80003ac8:	ee2080e7          	jalr	-286(ra) # 800039a6 <itrunc>
    ip->type = 0;
    80003acc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	cfa080e7          	jalr	-774(ra) # 800037cc <iupdate>
    ip->valid = 0;
    80003ada:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ade:	854a                	mv	a0,s2
    80003ae0:	00001097          	auipc	ra,0x1
    80003ae4:	aa4080e7          	jalr	-1372(ra) # 80004584 <releasesleep>
    acquire(&itable.lock);
    80003ae8:	0001b517          	auipc	a0,0x1b
    80003aec:	61050513          	addi	a0,a0,1552 # 8001f0f8 <itable>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	0e2080e7          	jalr	226(ra) # 80000bd2 <acquire>
    80003af8:	b741                	j	80003a78 <iput+0x26>

0000000080003afa <iunlockput>:
{
    80003afa:	1101                	addi	sp,sp,-32
    80003afc:	ec06                	sd	ra,24(sp)
    80003afe:	e822                	sd	s0,16(sp)
    80003b00:	e426                	sd	s1,8(sp)
    80003b02:	1000                	addi	s0,sp,32
    80003b04:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	e54080e7          	jalr	-428(ra) # 8000395a <iunlock>
  iput(ip);
    80003b0e:	8526                	mv	a0,s1
    80003b10:	00000097          	auipc	ra,0x0
    80003b14:	f42080e7          	jalr	-190(ra) # 80003a52 <iput>
}
    80003b18:	60e2                	ld	ra,24(sp)
    80003b1a:	6442                	ld	s0,16(sp)
    80003b1c:	64a2                	ld	s1,8(sp)
    80003b1e:	6105                	addi	sp,sp,32
    80003b20:	8082                	ret

0000000080003b22 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b22:	1141                	addi	sp,sp,-16
    80003b24:	e422                	sd	s0,8(sp)
    80003b26:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b28:	411c                	lw	a5,0(a0)
    80003b2a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b2c:	415c                	lw	a5,4(a0)
    80003b2e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b30:	04451783          	lh	a5,68(a0)
    80003b34:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b38:	04a51783          	lh	a5,74(a0)
    80003b3c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b40:	04c56783          	lwu	a5,76(a0)
    80003b44:	e99c                	sd	a5,16(a1)
}
    80003b46:	6422                	ld	s0,8(sp)
    80003b48:	0141                	addi	sp,sp,16
    80003b4a:	8082                	ret

0000000080003b4c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4c:	457c                	lw	a5,76(a0)
    80003b4e:	0ed7e963          	bltu	a5,a3,80003c40 <readi+0xf4>
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
    80003b70:	8b2a                	mv	s6,a0
    80003b72:	8bae                	mv	s7,a1
    80003b74:	8a32                	mv	s4,a2
    80003b76:	84b6                	mv	s1,a3
    80003b78:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b7a:	9f35                	addw	a4,a4,a3
    return 0;
    80003b7c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b7e:	0ad76063          	bltu	a4,a3,80003c1e <readi+0xd2>
  if(off + n > ip->size)
    80003b82:	00e7f463          	bgeu	a5,a4,80003b8a <readi+0x3e>
    n = ip->size - off;
    80003b86:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b8a:	0a0a8963          	beqz	s5,80003c3c <readi+0xf0>
    80003b8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b90:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b94:	5c7d                	li	s8,-1
    80003b96:	a82d                	j	80003bd0 <readi+0x84>
    80003b98:	020d1d93          	slli	s11,s10,0x20
    80003b9c:	020ddd93          	srli	s11,s11,0x20
    80003ba0:	05890613          	addi	a2,s2,88
    80003ba4:	86ee                	mv	a3,s11
    80003ba6:	963a                	add	a2,a2,a4
    80003ba8:	85d2                	mv	a1,s4
    80003baa:	855e                	mv	a0,s7
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	9be080e7          	jalr	-1602(ra) # 8000256a <either_copyout>
    80003bb4:	05850d63          	beq	a0,s8,80003c0e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bb8:	854a                	mv	a0,s2
    80003bba:	fffff097          	auipc	ra,0xfffff
    80003bbe:	5fe080e7          	jalr	1534(ra) # 800031b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc2:	013d09bb          	addw	s3,s10,s3
    80003bc6:	009d04bb          	addw	s1,s10,s1
    80003bca:	9a6e                	add	s4,s4,s11
    80003bcc:	0559f763          	bgeu	s3,s5,80003c1a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003bd0:	00a4d59b          	srliw	a1,s1,0xa
    80003bd4:	855a                	mv	a0,s6
    80003bd6:	00000097          	auipc	ra,0x0
    80003bda:	8a4080e7          	jalr	-1884(ra) # 8000347a <bmap>
    80003bde:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003be2:	cd85                	beqz	a1,80003c1a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003be4:	000b2503          	lw	a0,0(s6)
    80003be8:	fffff097          	auipc	ra,0xfffff
    80003bec:	4a0080e7          	jalr	1184(ra) # 80003088 <bread>
    80003bf0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf2:	3ff4f713          	andi	a4,s1,1023
    80003bf6:	40ec87bb          	subw	a5,s9,a4
    80003bfa:	413a86bb          	subw	a3,s5,s3
    80003bfe:	8d3e                	mv	s10,a5
    80003c00:	2781                	sext.w	a5,a5
    80003c02:	0006861b          	sext.w	a2,a3
    80003c06:	f8f679e3          	bgeu	a2,a5,80003b98 <readi+0x4c>
    80003c0a:	8d36                	mv	s10,a3
    80003c0c:	b771                	j	80003b98 <readi+0x4c>
      brelse(bp);
    80003c0e:	854a                	mv	a0,s2
    80003c10:	fffff097          	auipc	ra,0xfffff
    80003c14:	5a8080e7          	jalr	1448(ra) # 800031b8 <brelse>
      tot = -1;
    80003c18:	59fd                	li	s3,-1
  }
  return tot;
    80003c1a:	0009851b          	sext.w	a0,s3
}
    80003c1e:	70a6                	ld	ra,104(sp)
    80003c20:	7406                	ld	s0,96(sp)
    80003c22:	64e6                	ld	s1,88(sp)
    80003c24:	6946                	ld	s2,80(sp)
    80003c26:	69a6                	ld	s3,72(sp)
    80003c28:	6a06                	ld	s4,64(sp)
    80003c2a:	7ae2                	ld	s5,56(sp)
    80003c2c:	7b42                	ld	s6,48(sp)
    80003c2e:	7ba2                	ld	s7,40(sp)
    80003c30:	7c02                	ld	s8,32(sp)
    80003c32:	6ce2                	ld	s9,24(sp)
    80003c34:	6d42                	ld	s10,16(sp)
    80003c36:	6da2                	ld	s11,8(sp)
    80003c38:	6165                	addi	sp,sp,112
    80003c3a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c3c:	89d6                	mv	s3,s5
    80003c3e:	bff1                	j	80003c1a <readi+0xce>
    return 0;
    80003c40:	4501                	li	a0,0
}
    80003c42:	8082                	ret

0000000080003c44 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c44:	457c                	lw	a5,76(a0)
    80003c46:	10d7e863          	bltu	a5,a3,80003d56 <writei+0x112>
{
    80003c4a:	7159                	addi	sp,sp,-112
    80003c4c:	f486                	sd	ra,104(sp)
    80003c4e:	f0a2                	sd	s0,96(sp)
    80003c50:	eca6                	sd	s1,88(sp)
    80003c52:	e8ca                	sd	s2,80(sp)
    80003c54:	e4ce                	sd	s3,72(sp)
    80003c56:	e0d2                	sd	s4,64(sp)
    80003c58:	fc56                	sd	s5,56(sp)
    80003c5a:	f85a                	sd	s6,48(sp)
    80003c5c:	f45e                	sd	s7,40(sp)
    80003c5e:	f062                	sd	s8,32(sp)
    80003c60:	ec66                	sd	s9,24(sp)
    80003c62:	e86a                	sd	s10,16(sp)
    80003c64:	e46e                	sd	s11,8(sp)
    80003c66:	1880                	addi	s0,sp,112
    80003c68:	8aaa                	mv	s5,a0
    80003c6a:	8bae                	mv	s7,a1
    80003c6c:	8a32                	mv	s4,a2
    80003c6e:	8936                	mv	s2,a3
    80003c70:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c72:	00e687bb          	addw	a5,a3,a4
    80003c76:	0ed7e263          	bltu	a5,a3,80003d5a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c7a:	00043737          	lui	a4,0x43
    80003c7e:	0ef76063          	bltu	a4,a5,80003d5e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c82:	0c0b0863          	beqz	s6,80003d52 <writei+0x10e>
    80003c86:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c88:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c8c:	5c7d                	li	s8,-1
    80003c8e:	a091                	j	80003cd2 <writei+0x8e>
    80003c90:	020d1d93          	slli	s11,s10,0x20
    80003c94:	020ddd93          	srli	s11,s11,0x20
    80003c98:	05848513          	addi	a0,s1,88
    80003c9c:	86ee                	mv	a3,s11
    80003c9e:	8652                	mv	a2,s4
    80003ca0:	85de                	mv	a1,s7
    80003ca2:	953a                	add	a0,a0,a4
    80003ca4:	fffff097          	auipc	ra,0xfffff
    80003ca8:	91c080e7          	jalr	-1764(ra) # 800025c0 <either_copyin>
    80003cac:	07850263          	beq	a0,s8,80003d10 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cb0:	8526                	mv	a0,s1
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	75e080e7          	jalr	1886(ra) # 80004410 <log_write>
    brelse(bp);
    80003cba:	8526                	mv	a0,s1
    80003cbc:	fffff097          	auipc	ra,0xfffff
    80003cc0:	4fc080e7          	jalr	1276(ra) # 800031b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cc4:	013d09bb          	addw	s3,s10,s3
    80003cc8:	012d093b          	addw	s2,s10,s2
    80003ccc:	9a6e                	add	s4,s4,s11
    80003cce:	0569f663          	bgeu	s3,s6,80003d1a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003cd2:	00a9559b          	srliw	a1,s2,0xa
    80003cd6:	8556                	mv	a0,s5
    80003cd8:	fffff097          	auipc	ra,0xfffff
    80003cdc:	7a2080e7          	jalr	1954(ra) # 8000347a <bmap>
    80003ce0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ce4:	c99d                	beqz	a1,80003d1a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ce6:	000aa503          	lw	a0,0(s5)
    80003cea:	fffff097          	auipc	ra,0xfffff
    80003cee:	39e080e7          	jalr	926(ra) # 80003088 <bread>
    80003cf2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf4:	3ff97713          	andi	a4,s2,1023
    80003cf8:	40ec87bb          	subw	a5,s9,a4
    80003cfc:	413b06bb          	subw	a3,s6,s3
    80003d00:	8d3e                	mv	s10,a5
    80003d02:	2781                	sext.w	a5,a5
    80003d04:	0006861b          	sext.w	a2,a3
    80003d08:	f8f674e3          	bgeu	a2,a5,80003c90 <writei+0x4c>
    80003d0c:	8d36                	mv	s10,a3
    80003d0e:	b749                	j	80003c90 <writei+0x4c>
      brelse(bp);
    80003d10:	8526                	mv	a0,s1
    80003d12:	fffff097          	auipc	ra,0xfffff
    80003d16:	4a6080e7          	jalr	1190(ra) # 800031b8 <brelse>
  }

  if(off > ip->size)
    80003d1a:	04caa783          	lw	a5,76(s5)
    80003d1e:	0127f463          	bgeu	a5,s2,80003d26 <writei+0xe2>
    ip->size = off;
    80003d22:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d26:	8556                	mv	a0,s5
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	aa4080e7          	jalr	-1372(ra) # 800037cc <iupdate>

  return tot;
    80003d30:	0009851b          	sext.w	a0,s3
}
    80003d34:	70a6                	ld	ra,104(sp)
    80003d36:	7406                	ld	s0,96(sp)
    80003d38:	64e6                	ld	s1,88(sp)
    80003d3a:	6946                	ld	s2,80(sp)
    80003d3c:	69a6                	ld	s3,72(sp)
    80003d3e:	6a06                	ld	s4,64(sp)
    80003d40:	7ae2                	ld	s5,56(sp)
    80003d42:	7b42                	ld	s6,48(sp)
    80003d44:	7ba2                	ld	s7,40(sp)
    80003d46:	7c02                	ld	s8,32(sp)
    80003d48:	6ce2                	ld	s9,24(sp)
    80003d4a:	6d42                	ld	s10,16(sp)
    80003d4c:	6da2                	ld	s11,8(sp)
    80003d4e:	6165                	addi	sp,sp,112
    80003d50:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d52:	89da                	mv	s3,s6
    80003d54:	bfc9                	j	80003d26 <writei+0xe2>
    return -1;
    80003d56:	557d                	li	a0,-1
}
    80003d58:	8082                	ret
    return -1;
    80003d5a:	557d                	li	a0,-1
    80003d5c:	bfe1                	j	80003d34 <writei+0xf0>
    return -1;
    80003d5e:	557d                	li	a0,-1
    80003d60:	bfd1                	j	80003d34 <writei+0xf0>

0000000080003d62 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d62:	1141                	addi	sp,sp,-16
    80003d64:	e406                	sd	ra,8(sp)
    80003d66:	e022                	sd	s0,0(sp)
    80003d68:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d6a:	4639                	li	a2,14
    80003d6c:	ffffd097          	auipc	ra,0xffffd
    80003d70:	048080e7          	jalr	72(ra) # 80000db4 <strncmp>
}
    80003d74:	60a2                	ld	ra,8(sp)
    80003d76:	6402                	ld	s0,0(sp)
    80003d78:	0141                	addi	sp,sp,16
    80003d7a:	8082                	ret

0000000080003d7c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d7c:	7139                	addi	sp,sp,-64
    80003d7e:	fc06                	sd	ra,56(sp)
    80003d80:	f822                	sd	s0,48(sp)
    80003d82:	f426                	sd	s1,40(sp)
    80003d84:	f04a                	sd	s2,32(sp)
    80003d86:	ec4e                	sd	s3,24(sp)
    80003d88:	e852                	sd	s4,16(sp)
    80003d8a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d8c:	04451703          	lh	a4,68(a0)
    80003d90:	4785                	li	a5,1
    80003d92:	00f71a63          	bne	a4,a5,80003da6 <dirlookup+0x2a>
    80003d96:	892a                	mv	s2,a0
    80003d98:	89ae                	mv	s3,a1
    80003d9a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9c:	457c                	lw	a5,76(a0)
    80003d9e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003da0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da2:	e79d                	bnez	a5,80003dd0 <dirlookup+0x54>
    80003da4:	a8a5                	j	80003e1c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003da6:	00005517          	auipc	a0,0x5
    80003daa:	8c250513          	addi	a0,a0,-1854 # 80008668 <syscalls+0x200>
    80003dae:	ffffc097          	auipc	ra,0xffffc
    80003db2:	78e080e7          	jalr	1934(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003db6:	00005517          	auipc	a0,0x5
    80003dba:	8ca50513          	addi	a0,a0,-1846 # 80008680 <syscalls+0x218>
    80003dbe:	ffffc097          	auipc	ra,0xffffc
    80003dc2:	77e080e7          	jalr	1918(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc6:	24c1                	addiw	s1,s1,16
    80003dc8:	04c92783          	lw	a5,76(s2)
    80003dcc:	04f4f763          	bgeu	s1,a5,80003e1a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd0:	4741                	li	a4,16
    80003dd2:	86a6                	mv	a3,s1
    80003dd4:	fc040613          	addi	a2,s0,-64
    80003dd8:	4581                	li	a1,0
    80003dda:	854a                	mv	a0,s2
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	d70080e7          	jalr	-656(ra) # 80003b4c <readi>
    80003de4:	47c1                	li	a5,16
    80003de6:	fcf518e3          	bne	a0,a5,80003db6 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dea:	fc045783          	lhu	a5,-64(s0)
    80003dee:	dfe1                	beqz	a5,80003dc6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003df0:	fc240593          	addi	a1,s0,-62
    80003df4:	854e                	mv	a0,s3
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	f6c080e7          	jalr	-148(ra) # 80003d62 <namecmp>
    80003dfe:	f561                	bnez	a0,80003dc6 <dirlookup+0x4a>
      if(poff)
    80003e00:	000a0463          	beqz	s4,80003e08 <dirlookup+0x8c>
        *poff = off;
    80003e04:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e08:	fc045583          	lhu	a1,-64(s0)
    80003e0c:	00092503          	lw	a0,0(s2)
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	754080e7          	jalr	1876(ra) # 80003564 <iget>
    80003e18:	a011                	j	80003e1c <dirlookup+0xa0>
  return 0;
    80003e1a:	4501                	li	a0,0
}
    80003e1c:	70e2                	ld	ra,56(sp)
    80003e1e:	7442                	ld	s0,48(sp)
    80003e20:	74a2                	ld	s1,40(sp)
    80003e22:	7902                	ld	s2,32(sp)
    80003e24:	69e2                	ld	s3,24(sp)
    80003e26:	6a42                	ld	s4,16(sp)
    80003e28:	6121                	addi	sp,sp,64
    80003e2a:	8082                	ret

0000000080003e2c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e2c:	711d                	addi	sp,sp,-96
    80003e2e:	ec86                	sd	ra,88(sp)
    80003e30:	e8a2                	sd	s0,80(sp)
    80003e32:	e4a6                	sd	s1,72(sp)
    80003e34:	e0ca                	sd	s2,64(sp)
    80003e36:	fc4e                	sd	s3,56(sp)
    80003e38:	f852                	sd	s4,48(sp)
    80003e3a:	f456                	sd	s5,40(sp)
    80003e3c:	f05a                	sd	s6,32(sp)
    80003e3e:	ec5e                	sd	s7,24(sp)
    80003e40:	e862                	sd	s8,16(sp)
    80003e42:	e466                	sd	s9,8(sp)
    80003e44:	1080                	addi	s0,sp,96
    80003e46:	84aa                	mv	s1,a0
    80003e48:	8b2e                	mv	s6,a1
    80003e4a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e4c:	00054703          	lbu	a4,0(a0)
    80003e50:	02f00793          	li	a5,47
    80003e54:	02f70263          	beq	a4,a5,80003e78 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e58:	ffffe097          	auipc	ra,0xffffe
    80003e5c:	b64080e7          	jalr	-1180(ra) # 800019bc <myproc>
    80003e60:	15053503          	ld	a0,336(a0)
    80003e64:	00000097          	auipc	ra,0x0
    80003e68:	9f6080e7          	jalr	-1546(ra) # 8000385a <idup>
    80003e6c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e6e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e72:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e74:	4b85                	li	s7,1
    80003e76:	a875                	j	80003f32 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003e78:	4585                	li	a1,1
    80003e7a:	4505                	li	a0,1
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	6e8080e7          	jalr	1768(ra) # 80003564 <iget>
    80003e84:	8a2a                	mv	s4,a0
    80003e86:	b7e5                	j	80003e6e <namex+0x42>
      iunlockput(ip);
    80003e88:	8552                	mv	a0,s4
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	c70080e7          	jalr	-912(ra) # 80003afa <iunlockput>
      return 0;
    80003e92:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e94:	8552                	mv	a0,s4
    80003e96:	60e6                	ld	ra,88(sp)
    80003e98:	6446                	ld	s0,80(sp)
    80003e9a:	64a6                	ld	s1,72(sp)
    80003e9c:	6906                	ld	s2,64(sp)
    80003e9e:	79e2                	ld	s3,56(sp)
    80003ea0:	7a42                	ld	s4,48(sp)
    80003ea2:	7aa2                	ld	s5,40(sp)
    80003ea4:	7b02                	ld	s6,32(sp)
    80003ea6:	6be2                	ld	s7,24(sp)
    80003ea8:	6c42                	ld	s8,16(sp)
    80003eaa:	6ca2                	ld	s9,8(sp)
    80003eac:	6125                	addi	sp,sp,96
    80003eae:	8082                	ret
      iunlock(ip);
    80003eb0:	8552                	mv	a0,s4
    80003eb2:	00000097          	auipc	ra,0x0
    80003eb6:	aa8080e7          	jalr	-1368(ra) # 8000395a <iunlock>
      return ip;
    80003eba:	bfe9                	j	80003e94 <namex+0x68>
      iunlockput(ip);
    80003ebc:	8552                	mv	a0,s4
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	c3c080e7          	jalr	-964(ra) # 80003afa <iunlockput>
      return 0;
    80003ec6:	8a4e                	mv	s4,s3
    80003ec8:	b7f1                	j	80003e94 <namex+0x68>
  len = path - s;
    80003eca:	40998633          	sub	a2,s3,s1
    80003ece:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ed2:	099c5863          	bge	s8,s9,80003f62 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ed6:	4639                	li	a2,14
    80003ed8:	85a6                	mv	a1,s1
    80003eda:	8556                	mv	a0,s5
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	e64080e7          	jalr	-412(ra) # 80000d40 <memmove>
    80003ee4:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ee6:	0004c783          	lbu	a5,0(s1)
    80003eea:	01279763          	bne	a5,s2,80003ef8 <namex+0xcc>
    path++;
    80003eee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ef0:	0004c783          	lbu	a5,0(s1)
    80003ef4:	ff278de3          	beq	a5,s2,80003eee <namex+0xc2>
    ilock(ip);
    80003ef8:	8552                	mv	a0,s4
    80003efa:	00000097          	auipc	ra,0x0
    80003efe:	99e080e7          	jalr	-1634(ra) # 80003898 <ilock>
    if(ip->type != T_DIR){
    80003f02:	044a1783          	lh	a5,68(s4)
    80003f06:	f97791e3          	bne	a5,s7,80003e88 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003f0a:	000b0563          	beqz	s6,80003f14 <namex+0xe8>
    80003f0e:	0004c783          	lbu	a5,0(s1)
    80003f12:	dfd9                	beqz	a5,80003eb0 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f14:	4601                	li	a2,0
    80003f16:	85d6                	mv	a1,s5
    80003f18:	8552                	mv	a0,s4
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	e62080e7          	jalr	-414(ra) # 80003d7c <dirlookup>
    80003f22:	89aa                	mv	s3,a0
    80003f24:	dd41                	beqz	a0,80003ebc <namex+0x90>
    iunlockput(ip);
    80003f26:	8552                	mv	a0,s4
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	bd2080e7          	jalr	-1070(ra) # 80003afa <iunlockput>
    ip = next;
    80003f30:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f32:	0004c783          	lbu	a5,0(s1)
    80003f36:	01279763          	bne	a5,s2,80003f44 <namex+0x118>
    path++;
    80003f3a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f3c:	0004c783          	lbu	a5,0(s1)
    80003f40:	ff278de3          	beq	a5,s2,80003f3a <namex+0x10e>
  if(*path == 0)
    80003f44:	cb9d                	beqz	a5,80003f7a <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003f46:	0004c783          	lbu	a5,0(s1)
    80003f4a:	89a6                	mv	s3,s1
  len = path - s;
    80003f4c:	4c81                	li	s9,0
    80003f4e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f50:	01278963          	beq	a5,s2,80003f62 <namex+0x136>
    80003f54:	dbbd                	beqz	a5,80003eca <namex+0x9e>
    path++;
    80003f56:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f58:	0009c783          	lbu	a5,0(s3)
    80003f5c:	ff279ce3          	bne	a5,s2,80003f54 <namex+0x128>
    80003f60:	b7ad                	j	80003eca <namex+0x9e>
    memmove(name, s, len);
    80003f62:	2601                	sext.w	a2,a2
    80003f64:	85a6                	mv	a1,s1
    80003f66:	8556                	mv	a0,s5
    80003f68:	ffffd097          	auipc	ra,0xffffd
    80003f6c:	dd8080e7          	jalr	-552(ra) # 80000d40 <memmove>
    name[len] = 0;
    80003f70:	9cd6                	add	s9,s9,s5
    80003f72:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f76:	84ce                	mv	s1,s3
    80003f78:	b7bd                	j	80003ee6 <namex+0xba>
  if(nameiparent){
    80003f7a:	f00b0de3          	beqz	s6,80003e94 <namex+0x68>
    iput(ip);
    80003f7e:	8552                	mv	a0,s4
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	ad2080e7          	jalr	-1326(ra) # 80003a52 <iput>
    return 0;
    80003f88:	4a01                	li	s4,0
    80003f8a:	b729                	j	80003e94 <namex+0x68>

0000000080003f8c <dirlink>:
{
    80003f8c:	7139                	addi	sp,sp,-64
    80003f8e:	fc06                	sd	ra,56(sp)
    80003f90:	f822                	sd	s0,48(sp)
    80003f92:	f426                	sd	s1,40(sp)
    80003f94:	f04a                	sd	s2,32(sp)
    80003f96:	ec4e                	sd	s3,24(sp)
    80003f98:	e852                	sd	s4,16(sp)
    80003f9a:	0080                	addi	s0,sp,64
    80003f9c:	892a                	mv	s2,a0
    80003f9e:	8a2e                	mv	s4,a1
    80003fa0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fa2:	4601                	li	a2,0
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	dd8080e7          	jalr	-552(ra) # 80003d7c <dirlookup>
    80003fac:	e93d                	bnez	a0,80004022 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fae:	04c92483          	lw	s1,76(s2)
    80003fb2:	c49d                	beqz	s1,80003fe0 <dirlink+0x54>
    80003fb4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fb6:	4741                	li	a4,16
    80003fb8:	86a6                	mv	a3,s1
    80003fba:	fc040613          	addi	a2,s0,-64
    80003fbe:	4581                	li	a1,0
    80003fc0:	854a                	mv	a0,s2
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	b8a080e7          	jalr	-1142(ra) # 80003b4c <readi>
    80003fca:	47c1                	li	a5,16
    80003fcc:	06f51163          	bne	a0,a5,8000402e <dirlink+0xa2>
    if(de.inum == 0)
    80003fd0:	fc045783          	lhu	a5,-64(s0)
    80003fd4:	c791                	beqz	a5,80003fe0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd6:	24c1                	addiw	s1,s1,16
    80003fd8:	04c92783          	lw	a5,76(s2)
    80003fdc:	fcf4ede3          	bltu	s1,a5,80003fb6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fe0:	4639                	li	a2,14
    80003fe2:	85d2                	mv	a1,s4
    80003fe4:	fc240513          	addi	a0,s0,-62
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	e08080e7          	jalr	-504(ra) # 80000df0 <strncpy>
  de.inum = inum;
    80003ff0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff4:	4741                	li	a4,16
    80003ff6:	86a6                	mv	a3,s1
    80003ff8:	fc040613          	addi	a2,s0,-64
    80003ffc:	4581                	li	a1,0
    80003ffe:	854a                	mv	a0,s2
    80004000:	00000097          	auipc	ra,0x0
    80004004:	c44080e7          	jalr	-956(ra) # 80003c44 <writei>
    80004008:	1541                	addi	a0,a0,-16
    8000400a:	00a03533          	snez	a0,a0
    8000400e:	40a00533          	neg	a0,a0
}
    80004012:	70e2                	ld	ra,56(sp)
    80004014:	7442                	ld	s0,48(sp)
    80004016:	74a2                	ld	s1,40(sp)
    80004018:	7902                	ld	s2,32(sp)
    8000401a:	69e2                	ld	s3,24(sp)
    8000401c:	6a42                	ld	s4,16(sp)
    8000401e:	6121                	addi	sp,sp,64
    80004020:	8082                	ret
    iput(ip);
    80004022:	00000097          	auipc	ra,0x0
    80004026:	a30080e7          	jalr	-1488(ra) # 80003a52 <iput>
    return -1;
    8000402a:	557d                	li	a0,-1
    8000402c:	b7dd                	j	80004012 <dirlink+0x86>
      panic("dirlink read");
    8000402e:	00004517          	auipc	a0,0x4
    80004032:	66250513          	addi	a0,a0,1634 # 80008690 <syscalls+0x228>
    80004036:	ffffc097          	auipc	ra,0xffffc
    8000403a:	506080e7          	jalr	1286(ra) # 8000053c <panic>

000000008000403e <namei>:

struct inode*
namei(char *path)
{
    8000403e:	1101                	addi	sp,sp,-32
    80004040:	ec06                	sd	ra,24(sp)
    80004042:	e822                	sd	s0,16(sp)
    80004044:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004046:	fe040613          	addi	a2,s0,-32
    8000404a:	4581                	li	a1,0
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	de0080e7          	jalr	-544(ra) # 80003e2c <namex>
}
    80004054:	60e2                	ld	ra,24(sp)
    80004056:	6442                	ld	s0,16(sp)
    80004058:	6105                	addi	sp,sp,32
    8000405a:	8082                	ret

000000008000405c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000405c:	1141                	addi	sp,sp,-16
    8000405e:	e406                	sd	ra,8(sp)
    80004060:	e022                	sd	s0,0(sp)
    80004062:	0800                	addi	s0,sp,16
    80004064:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004066:	4585                	li	a1,1
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	dc4080e7          	jalr	-572(ra) # 80003e2c <namex>
}
    80004070:	60a2                	ld	ra,8(sp)
    80004072:	6402                	ld	s0,0(sp)
    80004074:	0141                	addi	sp,sp,16
    80004076:	8082                	ret

0000000080004078 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004078:	1101                	addi	sp,sp,-32
    8000407a:	ec06                	sd	ra,24(sp)
    8000407c:	e822                	sd	s0,16(sp)
    8000407e:	e426                	sd	s1,8(sp)
    80004080:	e04a                	sd	s2,0(sp)
    80004082:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004084:	0001d917          	auipc	s2,0x1d
    80004088:	b1c90913          	addi	s2,s2,-1252 # 80020ba0 <log>
    8000408c:	01892583          	lw	a1,24(s2)
    80004090:	02892503          	lw	a0,40(s2)
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	ff4080e7          	jalr	-12(ra) # 80003088 <bread>
    8000409c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000409e:	02c92603          	lw	a2,44(s2)
    800040a2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040a4:	00c05f63          	blez	a2,800040c2 <write_head+0x4a>
    800040a8:	0001d717          	auipc	a4,0x1d
    800040ac:	b2870713          	addi	a4,a4,-1240 # 80020bd0 <log+0x30>
    800040b0:	87aa                	mv	a5,a0
    800040b2:	060a                	slli	a2,a2,0x2
    800040b4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040b6:	4314                	lw	a3,0(a4)
    800040b8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040ba:	0711                	addi	a4,a4,4
    800040bc:	0791                	addi	a5,a5,4
    800040be:	fec79ce3          	bne	a5,a2,800040b6 <write_head+0x3e>
  }
  bwrite(buf);
    800040c2:	8526                	mv	a0,s1
    800040c4:	fffff097          	auipc	ra,0xfffff
    800040c8:	0b6080e7          	jalr	182(ra) # 8000317a <bwrite>
  brelse(buf);
    800040cc:	8526                	mv	a0,s1
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	0ea080e7          	jalr	234(ra) # 800031b8 <brelse>
}
    800040d6:	60e2                	ld	ra,24(sp)
    800040d8:	6442                	ld	s0,16(sp)
    800040da:	64a2                	ld	s1,8(sp)
    800040dc:	6902                	ld	s2,0(sp)
    800040de:	6105                	addi	sp,sp,32
    800040e0:	8082                	ret

00000000800040e2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e2:	0001d797          	auipc	a5,0x1d
    800040e6:	aea7a783          	lw	a5,-1302(a5) # 80020bcc <log+0x2c>
    800040ea:	0af05d63          	blez	a5,800041a4 <install_trans+0xc2>
{
    800040ee:	7139                	addi	sp,sp,-64
    800040f0:	fc06                	sd	ra,56(sp)
    800040f2:	f822                	sd	s0,48(sp)
    800040f4:	f426                	sd	s1,40(sp)
    800040f6:	f04a                	sd	s2,32(sp)
    800040f8:	ec4e                	sd	s3,24(sp)
    800040fa:	e852                	sd	s4,16(sp)
    800040fc:	e456                	sd	s5,8(sp)
    800040fe:	e05a                	sd	s6,0(sp)
    80004100:	0080                	addi	s0,sp,64
    80004102:	8b2a                	mv	s6,a0
    80004104:	0001da97          	auipc	s5,0x1d
    80004108:	acca8a93          	addi	s5,s5,-1332 # 80020bd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000410c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000410e:	0001d997          	auipc	s3,0x1d
    80004112:	a9298993          	addi	s3,s3,-1390 # 80020ba0 <log>
    80004116:	a00d                	j	80004138 <install_trans+0x56>
    brelse(lbuf);
    80004118:	854a                	mv	a0,s2
    8000411a:	fffff097          	auipc	ra,0xfffff
    8000411e:	09e080e7          	jalr	158(ra) # 800031b8 <brelse>
    brelse(dbuf);
    80004122:	8526                	mv	a0,s1
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	094080e7          	jalr	148(ra) # 800031b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000412c:	2a05                	addiw	s4,s4,1
    8000412e:	0a91                	addi	s5,s5,4
    80004130:	02c9a783          	lw	a5,44(s3)
    80004134:	04fa5e63          	bge	s4,a5,80004190 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004138:	0189a583          	lw	a1,24(s3)
    8000413c:	014585bb          	addw	a1,a1,s4
    80004140:	2585                	addiw	a1,a1,1
    80004142:	0289a503          	lw	a0,40(s3)
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	f42080e7          	jalr	-190(ra) # 80003088 <bread>
    8000414e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004150:	000aa583          	lw	a1,0(s5)
    80004154:	0289a503          	lw	a0,40(s3)
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	f30080e7          	jalr	-208(ra) # 80003088 <bread>
    80004160:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004162:	40000613          	li	a2,1024
    80004166:	05890593          	addi	a1,s2,88
    8000416a:	05850513          	addi	a0,a0,88
    8000416e:	ffffd097          	auipc	ra,0xffffd
    80004172:	bd2080e7          	jalr	-1070(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004176:	8526                	mv	a0,s1
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	002080e7          	jalr	2(ra) # 8000317a <bwrite>
    if(recovering == 0)
    80004180:	f80b1ce3          	bnez	s6,80004118 <install_trans+0x36>
      bunpin(dbuf);
    80004184:	8526                	mv	a0,s1
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	10a080e7          	jalr	266(ra) # 80003290 <bunpin>
    8000418e:	b769                	j	80004118 <install_trans+0x36>
}
    80004190:	70e2                	ld	ra,56(sp)
    80004192:	7442                	ld	s0,48(sp)
    80004194:	74a2                	ld	s1,40(sp)
    80004196:	7902                	ld	s2,32(sp)
    80004198:	69e2                	ld	s3,24(sp)
    8000419a:	6a42                	ld	s4,16(sp)
    8000419c:	6aa2                	ld	s5,8(sp)
    8000419e:	6b02                	ld	s6,0(sp)
    800041a0:	6121                	addi	sp,sp,64
    800041a2:	8082                	ret
    800041a4:	8082                	ret

00000000800041a6 <initlog>:
{
    800041a6:	7179                	addi	sp,sp,-48
    800041a8:	f406                	sd	ra,40(sp)
    800041aa:	f022                	sd	s0,32(sp)
    800041ac:	ec26                	sd	s1,24(sp)
    800041ae:	e84a                	sd	s2,16(sp)
    800041b0:	e44e                	sd	s3,8(sp)
    800041b2:	1800                	addi	s0,sp,48
    800041b4:	892a                	mv	s2,a0
    800041b6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041b8:	0001d497          	auipc	s1,0x1d
    800041bc:	9e848493          	addi	s1,s1,-1560 # 80020ba0 <log>
    800041c0:	00004597          	auipc	a1,0x4
    800041c4:	4e058593          	addi	a1,a1,1248 # 800086a0 <syscalls+0x238>
    800041c8:	8526                	mv	a0,s1
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	978080e7          	jalr	-1672(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800041d2:	0149a583          	lw	a1,20(s3)
    800041d6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041d8:	0109a783          	lw	a5,16(s3)
    800041dc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041de:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041e2:	854a                	mv	a0,s2
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	ea4080e7          	jalr	-348(ra) # 80003088 <bread>
  log.lh.n = lh->n;
    800041ec:	4d30                	lw	a2,88(a0)
    800041ee:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041f0:	00c05f63          	blez	a2,8000420e <initlog+0x68>
    800041f4:	87aa                	mv	a5,a0
    800041f6:	0001d717          	auipc	a4,0x1d
    800041fa:	9da70713          	addi	a4,a4,-1574 # 80020bd0 <log+0x30>
    800041fe:	060a                	slli	a2,a2,0x2
    80004200:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004202:	4ff4                	lw	a3,92(a5)
    80004204:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004206:	0791                	addi	a5,a5,4
    80004208:	0711                	addi	a4,a4,4
    8000420a:	fec79ce3          	bne	a5,a2,80004202 <initlog+0x5c>
  brelse(buf);
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	faa080e7          	jalr	-86(ra) # 800031b8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004216:	4505                	li	a0,1
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	eca080e7          	jalr	-310(ra) # 800040e2 <install_trans>
  log.lh.n = 0;
    80004220:	0001d797          	auipc	a5,0x1d
    80004224:	9a07a623          	sw	zero,-1620(a5) # 80020bcc <log+0x2c>
  write_head(); // clear the log
    80004228:	00000097          	auipc	ra,0x0
    8000422c:	e50080e7          	jalr	-432(ra) # 80004078 <write_head>
}
    80004230:	70a2                	ld	ra,40(sp)
    80004232:	7402                	ld	s0,32(sp)
    80004234:	64e2                	ld	s1,24(sp)
    80004236:	6942                	ld	s2,16(sp)
    80004238:	69a2                	ld	s3,8(sp)
    8000423a:	6145                	addi	sp,sp,48
    8000423c:	8082                	ret

000000008000423e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000423e:	1101                	addi	sp,sp,-32
    80004240:	ec06                	sd	ra,24(sp)
    80004242:	e822                	sd	s0,16(sp)
    80004244:	e426                	sd	s1,8(sp)
    80004246:	e04a                	sd	s2,0(sp)
    80004248:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000424a:	0001d517          	auipc	a0,0x1d
    8000424e:	95650513          	addi	a0,a0,-1706 # 80020ba0 <log>
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	980080e7          	jalr	-1664(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000425a:	0001d497          	auipc	s1,0x1d
    8000425e:	94648493          	addi	s1,s1,-1722 # 80020ba0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004262:	4979                	li	s2,30
    80004264:	a039                	j	80004272 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004266:	85a6                	mv	a1,s1
    80004268:	8526                	mv	a0,s1
    8000426a:	ffffe097          	auipc	ra,0xffffe
    8000426e:	ef8080e7          	jalr	-264(ra) # 80002162 <sleep>
    if(log.committing){
    80004272:	50dc                	lw	a5,36(s1)
    80004274:	fbed                	bnez	a5,80004266 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004276:	5098                	lw	a4,32(s1)
    80004278:	2705                	addiw	a4,a4,1
    8000427a:	0027179b          	slliw	a5,a4,0x2
    8000427e:	9fb9                	addw	a5,a5,a4
    80004280:	0017979b          	slliw	a5,a5,0x1
    80004284:	54d4                	lw	a3,44(s1)
    80004286:	9fb5                	addw	a5,a5,a3
    80004288:	00f95963          	bge	s2,a5,8000429a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000428c:	85a6                	mv	a1,s1
    8000428e:	8526                	mv	a0,s1
    80004290:	ffffe097          	auipc	ra,0xffffe
    80004294:	ed2080e7          	jalr	-302(ra) # 80002162 <sleep>
    80004298:	bfe9                	j	80004272 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000429a:	0001d517          	auipc	a0,0x1d
    8000429e:	90650513          	addi	a0,a0,-1786 # 80020ba0 <log>
    800042a2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	9f8080e7          	jalr	-1544(ra) # 80000c9c <release>
      break;
    }
  }
}
    800042ac:	60e2                	ld	ra,24(sp)
    800042ae:	6442                	ld	s0,16(sp)
    800042b0:	64a2                	ld	s1,8(sp)
    800042b2:	6902                	ld	s2,0(sp)
    800042b4:	6105                	addi	sp,sp,32
    800042b6:	8082                	ret

00000000800042b8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042b8:	7139                	addi	sp,sp,-64
    800042ba:	fc06                	sd	ra,56(sp)
    800042bc:	f822                	sd	s0,48(sp)
    800042be:	f426                	sd	s1,40(sp)
    800042c0:	f04a                	sd	s2,32(sp)
    800042c2:	ec4e                	sd	s3,24(sp)
    800042c4:	e852                	sd	s4,16(sp)
    800042c6:	e456                	sd	s5,8(sp)
    800042c8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042ca:	0001d497          	auipc	s1,0x1d
    800042ce:	8d648493          	addi	s1,s1,-1834 # 80020ba0 <log>
    800042d2:	8526                	mv	a0,s1
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	8fe080e7          	jalr	-1794(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800042dc:	509c                	lw	a5,32(s1)
    800042de:	37fd                	addiw	a5,a5,-1
    800042e0:	0007891b          	sext.w	s2,a5
    800042e4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042e6:	50dc                	lw	a5,36(s1)
    800042e8:	e7b9                	bnez	a5,80004336 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042ea:	04091e63          	bnez	s2,80004346 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800042ee:	0001d497          	auipc	s1,0x1d
    800042f2:	8b248493          	addi	s1,s1,-1870 # 80020ba0 <log>
    800042f6:	4785                	li	a5,1
    800042f8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042fa:	8526                	mv	a0,s1
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	9a0080e7          	jalr	-1632(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004304:	54dc                	lw	a5,44(s1)
    80004306:	06f04763          	bgtz	a5,80004374 <end_op+0xbc>
    acquire(&log.lock);
    8000430a:	0001d497          	auipc	s1,0x1d
    8000430e:	89648493          	addi	s1,s1,-1898 # 80020ba0 <log>
    80004312:	8526                	mv	a0,s1
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	8be080e7          	jalr	-1858(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000431c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004320:	8526                	mv	a0,s1
    80004322:	ffffe097          	auipc	ra,0xffffe
    80004326:	ea4080e7          	jalr	-348(ra) # 800021c6 <wakeup>
    release(&log.lock);
    8000432a:	8526                	mv	a0,s1
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	970080e7          	jalr	-1680(ra) # 80000c9c <release>
}
    80004334:	a03d                	j	80004362 <end_op+0xaa>
    panic("log.committing");
    80004336:	00004517          	auipc	a0,0x4
    8000433a:	37250513          	addi	a0,a0,882 # 800086a8 <syscalls+0x240>
    8000433e:	ffffc097          	auipc	ra,0xffffc
    80004342:	1fe080e7          	jalr	510(ra) # 8000053c <panic>
    wakeup(&log);
    80004346:	0001d497          	auipc	s1,0x1d
    8000434a:	85a48493          	addi	s1,s1,-1958 # 80020ba0 <log>
    8000434e:	8526                	mv	a0,s1
    80004350:	ffffe097          	auipc	ra,0xffffe
    80004354:	e76080e7          	jalr	-394(ra) # 800021c6 <wakeup>
  release(&log.lock);
    80004358:	8526                	mv	a0,s1
    8000435a:	ffffd097          	auipc	ra,0xffffd
    8000435e:	942080e7          	jalr	-1726(ra) # 80000c9c <release>
}
    80004362:	70e2                	ld	ra,56(sp)
    80004364:	7442                	ld	s0,48(sp)
    80004366:	74a2                	ld	s1,40(sp)
    80004368:	7902                	ld	s2,32(sp)
    8000436a:	69e2                	ld	s3,24(sp)
    8000436c:	6a42                	ld	s4,16(sp)
    8000436e:	6aa2                	ld	s5,8(sp)
    80004370:	6121                	addi	sp,sp,64
    80004372:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004374:	0001da97          	auipc	s5,0x1d
    80004378:	85ca8a93          	addi	s5,s5,-1956 # 80020bd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000437c:	0001da17          	auipc	s4,0x1d
    80004380:	824a0a13          	addi	s4,s4,-2012 # 80020ba0 <log>
    80004384:	018a2583          	lw	a1,24(s4)
    80004388:	012585bb          	addw	a1,a1,s2
    8000438c:	2585                	addiw	a1,a1,1
    8000438e:	028a2503          	lw	a0,40(s4)
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	cf6080e7          	jalr	-778(ra) # 80003088 <bread>
    8000439a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000439c:	000aa583          	lw	a1,0(s5)
    800043a0:	028a2503          	lw	a0,40(s4)
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	ce4080e7          	jalr	-796(ra) # 80003088 <bread>
    800043ac:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043ae:	40000613          	li	a2,1024
    800043b2:	05850593          	addi	a1,a0,88
    800043b6:	05848513          	addi	a0,s1,88
    800043ba:	ffffd097          	auipc	ra,0xffffd
    800043be:	986080e7          	jalr	-1658(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800043c2:	8526                	mv	a0,s1
    800043c4:	fffff097          	auipc	ra,0xfffff
    800043c8:	db6080e7          	jalr	-586(ra) # 8000317a <bwrite>
    brelse(from);
    800043cc:	854e                	mv	a0,s3
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	dea080e7          	jalr	-534(ra) # 800031b8 <brelse>
    brelse(to);
    800043d6:	8526                	mv	a0,s1
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	de0080e7          	jalr	-544(ra) # 800031b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e0:	2905                	addiw	s2,s2,1
    800043e2:	0a91                	addi	s5,s5,4
    800043e4:	02ca2783          	lw	a5,44(s4)
    800043e8:	f8f94ee3          	blt	s2,a5,80004384 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043ec:	00000097          	auipc	ra,0x0
    800043f0:	c8c080e7          	jalr	-884(ra) # 80004078 <write_head>
    install_trans(0); // Now install writes to home locations
    800043f4:	4501                	li	a0,0
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	cec080e7          	jalr	-788(ra) # 800040e2 <install_trans>
    log.lh.n = 0;
    800043fe:	0001c797          	auipc	a5,0x1c
    80004402:	7c07a723          	sw	zero,1998(a5) # 80020bcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	c72080e7          	jalr	-910(ra) # 80004078 <write_head>
    8000440e:	bdf5                	j	8000430a <end_op+0x52>

0000000080004410 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004410:	1101                	addi	sp,sp,-32
    80004412:	ec06                	sd	ra,24(sp)
    80004414:	e822                	sd	s0,16(sp)
    80004416:	e426                	sd	s1,8(sp)
    80004418:	e04a                	sd	s2,0(sp)
    8000441a:	1000                	addi	s0,sp,32
    8000441c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000441e:	0001c917          	auipc	s2,0x1c
    80004422:	78290913          	addi	s2,s2,1922 # 80020ba0 <log>
    80004426:	854a                	mv	a0,s2
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	7aa080e7          	jalr	1962(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004430:	02c92603          	lw	a2,44(s2)
    80004434:	47f5                	li	a5,29
    80004436:	06c7c563          	blt	a5,a2,800044a0 <log_write+0x90>
    8000443a:	0001c797          	auipc	a5,0x1c
    8000443e:	7827a783          	lw	a5,1922(a5) # 80020bbc <log+0x1c>
    80004442:	37fd                	addiw	a5,a5,-1
    80004444:	04f65e63          	bge	a2,a5,800044a0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004448:	0001c797          	auipc	a5,0x1c
    8000444c:	7787a783          	lw	a5,1912(a5) # 80020bc0 <log+0x20>
    80004450:	06f05063          	blez	a5,800044b0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004454:	4781                	li	a5,0
    80004456:	06c05563          	blez	a2,800044c0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000445a:	44cc                	lw	a1,12(s1)
    8000445c:	0001c717          	auipc	a4,0x1c
    80004460:	77470713          	addi	a4,a4,1908 # 80020bd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004464:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004466:	4314                	lw	a3,0(a4)
    80004468:	04b68c63          	beq	a3,a1,800044c0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000446c:	2785                	addiw	a5,a5,1
    8000446e:	0711                	addi	a4,a4,4
    80004470:	fef61be3          	bne	a2,a5,80004466 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004474:	0621                	addi	a2,a2,8
    80004476:	060a                	slli	a2,a2,0x2
    80004478:	0001c797          	auipc	a5,0x1c
    8000447c:	72878793          	addi	a5,a5,1832 # 80020ba0 <log>
    80004480:	97b2                	add	a5,a5,a2
    80004482:	44d8                	lw	a4,12(s1)
    80004484:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004486:	8526                	mv	a0,s1
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	dcc080e7          	jalr	-564(ra) # 80003254 <bpin>
    log.lh.n++;
    80004490:	0001c717          	auipc	a4,0x1c
    80004494:	71070713          	addi	a4,a4,1808 # 80020ba0 <log>
    80004498:	575c                	lw	a5,44(a4)
    8000449a:	2785                	addiw	a5,a5,1
    8000449c:	d75c                	sw	a5,44(a4)
    8000449e:	a82d                	j	800044d8 <log_write+0xc8>
    panic("too big a transaction");
    800044a0:	00004517          	auipc	a0,0x4
    800044a4:	21850513          	addi	a0,a0,536 # 800086b8 <syscalls+0x250>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	094080e7          	jalr	148(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800044b0:	00004517          	auipc	a0,0x4
    800044b4:	22050513          	addi	a0,a0,544 # 800086d0 <syscalls+0x268>
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	084080e7          	jalr	132(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800044c0:	00878693          	addi	a3,a5,8
    800044c4:	068a                	slli	a3,a3,0x2
    800044c6:	0001c717          	auipc	a4,0x1c
    800044ca:	6da70713          	addi	a4,a4,1754 # 80020ba0 <log>
    800044ce:	9736                	add	a4,a4,a3
    800044d0:	44d4                	lw	a3,12(s1)
    800044d2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044d4:	faf609e3          	beq	a2,a5,80004486 <log_write+0x76>
  }
  release(&log.lock);
    800044d8:	0001c517          	auipc	a0,0x1c
    800044dc:	6c850513          	addi	a0,a0,1736 # 80020ba0 <log>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	7bc080e7          	jalr	1980(ra) # 80000c9c <release>
}
    800044e8:	60e2                	ld	ra,24(sp)
    800044ea:	6442                	ld	s0,16(sp)
    800044ec:	64a2                	ld	s1,8(sp)
    800044ee:	6902                	ld	s2,0(sp)
    800044f0:	6105                	addi	sp,sp,32
    800044f2:	8082                	ret

00000000800044f4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044f4:	1101                	addi	sp,sp,-32
    800044f6:	ec06                	sd	ra,24(sp)
    800044f8:	e822                	sd	s0,16(sp)
    800044fa:	e426                	sd	s1,8(sp)
    800044fc:	e04a                	sd	s2,0(sp)
    800044fe:	1000                	addi	s0,sp,32
    80004500:	84aa                	mv	s1,a0
    80004502:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004504:	00004597          	auipc	a1,0x4
    80004508:	1ec58593          	addi	a1,a1,492 # 800086f0 <syscalls+0x288>
    8000450c:	0521                	addi	a0,a0,8
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	634080e7          	jalr	1588(ra) # 80000b42 <initlock>
  lk->name = name;
    80004516:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000451a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000451e:	0204a423          	sw	zero,40(s1)
}
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6902                	ld	s2,0(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret

000000008000452e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000452e:	1101                	addi	sp,sp,-32
    80004530:	ec06                	sd	ra,24(sp)
    80004532:	e822                	sd	s0,16(sp)
    80004534:	e426                	sd	s1,8(sp)
    80004536:	e04a                	sd	s2,0(sp)
    80004538:	1000                	addi	s0,sp,32
    8000453a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000453c:	00850913          	addi	s2,a0,8
    80004540:	854a                	mv	a0,s2
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	690080e7          	jalr	1680(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000454a:	409c                	lw	a5,0(s1)
    8000454c:	cb89                	beqz	a5,8000455e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000454e:	85ca                	mv	a1,s2
    80004550:	8526                	mv	a0,s1
    80004552:	ffffe097          	auipc	ra,0xffffe
    80004556:	c10080e7          	jalr	-1008(ra) # 80002162 <sleep>
  while (lk->locked) {
    8000455a:	409c                	lw	a5,0(s1)
    8000455c:	fbed                	bnez	a5,8000454e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000455e:	4785                	li	a5,1
    80004560:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004562:	ffffd097          	auipc	ra,0xffffd
    80004566:	45a080e7          	jalr	1114(ra) # 800019bc <myproc>
    8000456a:	591c                	lw	a5,48(a0)
    8000456c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000456e:	854a                	mv	a0,s2
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	72c080e7          	jalr	1836(ra) # 80000c9c <release>
}
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	64a2                	ld	s1,8(sp)
    8000457e:	6902                	ld	s2,0(sp)
    80004580:	6105                	addi	sp,sp,32
    80004582:	8082                	ret

0000000080004584 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004584:	1101                	addi	sp,sp,-32
    80004586:	ec06                	sd	ra,24(sp)
    80004588:	e822                	sd	s0,16(sp)
    8000458a:	e426                	sd	s1,8(sp)
    8000458c:	e04a                	sd	s2,0(sp)
    8000458e:	1000                	addi	s0,sp,32
    80004590:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004592:	00850913          	addi	s2,a0,8
    80004596:	854a                	mv	a0,s2
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	63a080e7          	jalr	1594(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800045a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045a4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045a8:	8526                	mv	a0,s1
    800045aa:	ffffe097          	auipc	ra,0xffffe
    800045ae:	c1c080e7          	jalr	-996(ra) # 800021c6 <wakeup>
  release(&lk->lk);
    800045b2:	854a                	mv	a0,s2
    800045b4:	ffffc097          	auipc	ra,0xffffc
    800045b8:	6e8080e7          	jalr	1768(ra) # 80000c9c <release>
}
    800045bc:	60e2                	ld	ra,24(sp)
    800045be:	6442                	ld	s0,16(sp)
    800045c0:	64a2                	ld	s1,8(sp)
    800045c2:	6902                	ld	s2,0(sp)
    800045c4:	6105                	addi	sp,sp,32
    800045c6:	8082                	ret

00000000800045c8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045c8:	7179                	addi	sp,sp,-48
    800045ca:	f406                	sd	ra,40(sp)
    800045cc:	f022                	sd	s0,32(sp)
    800045ce:	ec26                	sd	s1,24(sp)
    800045d0:	e84a                	sd	s2,16(sp)
    800045d2:	e44e                	sd	s3,8(sp)
    800045d4:	1800                	addi	s0,sp,48
    800045d6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045d8:	00850913          	addi	s2,a0,8
    800045dc:	854a                	mv	a0,s2
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	5f4080e7          	jalr	1524(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045e6:	409c                	lw	a5,0(s1)
    800045e8:	ef99                	bnez	a5,80004606 <holdingsleep+0x3e>
    800045ea:	4481                	li	s1,0
  release(&lk->lk);
    800045ec:	854a                	mv	a0,s2
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	6ae080e7          	jalr	1710(ra) # 80000c9c <release>
  return r;
}
    800045f6:	8526                	mv	a0,s1
    800045f8:	70a2                	ld	ra,40(sp)
    800045fa:	7402                	ld	s0,32(sp)
    800045fc:	64e2                	ld	s1,24(sp)
    800045fe:	6942                	ld	s2,16(sp)
    80004600:	69a2                	ld	s3,8(sp)
    80004602:	6145                	addi	sp,sp,48
    80004604:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004606:	0284a983          	lw	s3,40(s1)
    8000460a:	ffffd097          	auipc	ra,0xffffd
    8000460e:	3b2080e7          	jalr	946(ra) # 800019bc <myproc>
    80004612:	5904                	lw	s1,48(a0)
    80004614:	413484b3          	sub	s1,s1,s3
    80004618:	0014b493          	seqz	s1,s1
    8000461c:	bfc1                	j	800045ec <holdingsleep+0x24>

000000008000461e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000461e:	1141                	addi	sp,sp,-16
    80004620:	e406                	sd	ra,8(sp)
    80004622:	e022                	sd	s0,0(sp)
    80004624:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004626:	00004597          	auipc	a1,0x4
    8000462a:	0da58593          	addi	a1,a1,218 # 80008700 <syscalls+0x298>
    8000462e:	0001c517          	auipc	a0,0x1c
    80004632:	6ba50513          	addi	a0,a0,1722 # 80020ce8 <ftable>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	50c080e7          	jalr	1292(ra) # 80000b42 <initlock>
}
    8000463e:	60a2                	ld	ra,8(sp)
    80004640:	6402                	ld	s0,0(sp)
    80004642:	0141                	addi	sp,sp,16
    80004644:	8082                	ret

0000000080004646 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	e426                	sd	s1,8(sp)
    8000464e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004650:	0001c517          	auipc	a0,0x1c
    80004654:	69850513          	addi	a0,a0,1688 # 80020ce8 <ftable>
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	57a080e7          	jalr	1402(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004660:	0001c497          	auipc	s1,0x1c
    80004664:	6a048493          	addi	s1,s1,1696 # 80020d00 <ftable+0x18>
    80004668:	0001d717          	auipc	a4,0x1d
    8000466c:	63870713          	addi	a4,a4,1592 # 80021ca0 <disk>
    if(f->ref == 0){
    80004670:	40dc                	lw	a5,4(s1)
    80004672:	cf99                	beqz	a5,80004690 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004674:	02848493          	addi	s1,s1,40
    80004678:	fee49ce3          	bne	s1,a4,80004670 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000467c:	0001c517          	auipc	a0,0x1c
    80004680:	66c50513          	addi	a0,a0,1644 # 80020ce8 <ftable>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	618080e7          	jalr	1560(ra) # 80000c9c <release>
  return 0;
    8000468c:	4481                	li	s1,0
    8000468e:	a819                	j	800046a4 <filealloc+0x5e>
      f->ref = 1;
    80004690:	4785                	li	a5,1
    80004692:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004694:	0001c517          	auipc	a0,0x1c
    80004698:	65450513          	addi	a0,a0,1620 # 80020ce8 <ftable>
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	600080e7          	jalr	1536(ra) # 80000c9c <release>
}
    800046a4:	8526                	mv	a0,s1
    800046a6:	60e2                	ld	ra,24(sp)
    800046a8:	6442                	ld	s0,16(sp)
    800046aa:	64a2                	ld	s1,8(sp)
    800046ac:	6105                	addi	sp,sp,32
    800046ae:	8082                	ret

00000000800046b0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046b0:	1101                	addi	sp,sp,-32
    800046b2:	ec06                	sd	ra,24(sp)
    800046b4:	e822                	sd	s0,16(sp)
    800046b6:	e426                	sd	s1,8(sp)
    800046b8:	1000                	addi	s0,sp,32
    800046ba:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046bc:	0001c517          	auipc	a0,0x1c
    800046c0:	62c50513          	addi	a0,a0,1580 # 80020ce8 <ftable>
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	50e080e7          	jalr	1294(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800046cc:	40dc                	lw	a5,4(s1)
    800046ce:	02f05263          	blez	a5,800046f2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046d2:	2785                	addiw	a5,a5,1
    800046d4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046d6:	0001c517          	auipc	a0,0x1c
    800046da:	61250513          	addi	a0,a0,1554 # 80020ce8 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	5be080e7          	jalr	1470(ra) # 80000c9c <release>
  return f;
}
    800046e6:	8526                	mv	a0,s1
    800046e8:	60e2                	ld	ra,24(sp)
    800046ea:	6442                	ld	s0,16(sp)
    800046ec:	64a2                	ld	s1,8(sp)
    800046ee:	6105                	addi	sp,sp,32
    800046f0:	8082                	ret
    panic("filedup");
    800046f2:	00004517          	auipc	a0,0x4
    800046f6:	01650513          	addi	a0,a0,22 # 80008708 <syscalls+0x2a0>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	e42080e7          	jalr	-446(ra) # 8000053c <panic>

0000000080004702 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004702:	7139                	addi	sp,sp,-64
    80004704:	fc06                	sd	ra,56(sp)
    80004706:	f822                	sd	s0,48(sp)
    80004708:	f426                	sd	s1,40(sp)
    8000470a:	f04a                	sd	s2,32(sp)
    8000470c:	ec4e                	sd	s3,24(sp)
    8000470e:	e852                	sd	s4,16(sp)
    80004710:	e456                	sd	s5,8(sp)
    80004712:	0080                	addi	s0,sp,64
    80004714:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004716:	0001c517          	auipc	a0,0x1c
    8000471a:	5d250513          	addi	a0,a0,1490 # 80020ce8 <ftable>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	4b4080e7          	jalr	1204(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004726:	40dc                	lw	a5,4(s1)
    80004728:	06f05163          	blez	a5,8000478a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000472c:	37fd                	addiw	a5,a5,-1
    8000472e:	0007871b          	sext.w	a4,a5
    80004732:	c0dc                	sw	a5,4(s1)
    80004734:	06e04363          	bgtz	a4,8000479a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004738:	0004a903          	lw	s2,0(s1)
    8000473c:	0094ca83          	lbu	s5,9(s1)
    80004740:	0104ba03          	ld	s4,16(s1)
    80004744:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004748:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000474c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004750:	0001c517          	auipc	a0,0x1c
    80004754:	59850513          	addi	a0,a0,1432 # 80020ce8 <ftable>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	544080e7          	jalr	1348(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    80004760:	4785                	li	a5,1
    80004762:	04f90d63          	beq	s2,a5,800047bc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004766:	3979                	addiw	s2,s2,-2
    80004768:	4785                	li	a5,1
    8000476a:	0527e063          	bltu	a5,s2,800047aa <fileclose+0xa8>
    begin_op();
    8000476e:	00000097          	auipc	ra,0x0
    80004772:	ad0080e7          	jalr	-1328(ra) # 8000423e <begin_op>
    iput(ff.ip);
    80004776:	854e                	mv	a0,s3
    80004778:	fffff097          	auipc	ra,0xfffff
    8000477c:	2da080e7          	jalr	730(ra) # 80003a52 <iput>
    end_op();
    80004780:	00000097          	auipc	ra,0x0
    80004784:	b38080e7          	jalr	-1224(ra) # 800042b8 <end_op>
    80004788:	a00d                	j	800047aa <fileclose+0xa8>
    panic("fileclose");
    8000478a:	00004517          	auipc	a0,0x4
    8000478e:	f8650513          	addi	a0,a0,-122 # 80008710 <syscalls+0x2a8>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	daa080e7          	jalr	-598(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000479a:	0001c517          	auipc	a0,0x1c
    8000479e:	54e50513          	addi	a0,a0,1358 # 80020ce8 <ftable>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	4fa080e7          	jalr	1274(ra) # 80000c9c <release>
  }
}
    800047aa:	70e2                	ld	ra,56(sp)
    800047ac:	7442                	ld	s0,48(sp)
    800047ae:	74a2                	ld	s1,40(sp)
    800047b0:	7902                	ld	s2,32(sp)
    800047b2:	69e2                	ld	s3,24(sp)
    800047b4:	6a42                	ld	s4,16(sp)
    800047b6:	6aa2                	ld	s5,8(sp)
    800047b8:	6121                	addi	sp,sp,64
    800047ba:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047bc:	85d6                	mv	a1,s5
    800047be:	8552                	mv	a0,s4
    800047c0:	00000097          	auipc	ra,0x0
    800047c4:	348080e7          	jalr	840(ra) # 80004b08 <pipeclose>
    800047c8:	b7cd                	j	800047aa <fileclose+0xa8>

00000000800047ca <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047ca:	715d                	addi	sp,sp,-80
    800047cc:	e486                	sd	ra,72(sp)
    800047ce:	e0a2                	sd	s0,64(sp)
    800047d0:	fc26                	sd	s1,56(sp)
    800047d2:	f84a                	sd	s2,48(sp)
    800047d4:	f44e                	sd	s3,40(sp)
    800047d6:	0880                	addi	s0,sp,80
    800047d8:	84aa                	mv	s1,a0
    800047da:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047dc:	ffffd097          	auipc	ra,0xffffd
    800047e0:	1e0080e7          	jalr	480(ra) # 800019bc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047e4:	409c                	lw	a5,0(s1)
    800047e6:	37f9                	addiw	a5,a5,-2
    800047e8:	4705                	li	a4,1
    800047ea:	04f76763          	bltu	a4,a5,80004838 <filestat+0x6e>
    800047ee:	892a                	mv	s2,a0
    ilock(f->ip);
    800047f0:	6c88                	ld	a0,24(s1)
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	0a6080e7          	jalr	166(ra) # 80003898 <ilock>
    stati(f->ip, &st);
    800047fa:	fb840593          	addi	a1,s0,-72
    800047fe:	6c88                	ld	a0,24(s1)
    80004800:	fffff097          	auipc	ra,0xfffff
    80004804:	322080e7          	jalr	802(ra) # 80003b22 <stati>
    iunlock(f->ip);
    80004808:	6c88                	ld	a0,24(s1)
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	150080e7          	jalr	336(ra) # 8000395a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004812:	46e1                	li	a3,24
    80004814:	fb840613          	addi	a2,s0,-72
    80004818:	85ce                	mv	a1,s3
    8000481a:	05093503          	ld	a0,80(s2)
    8000481e:	ffffd097          	auipc	ra,0xffffd
    80004822:	e5e080e7          	jalr	-418(ra) # 8000167c <copyout>
    80004826:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000482a:	60a6                	ld	ra,72(sp)
    8000482c:	6406                	ld	s0,64(sp)
    8000482e:	74e2                	ld	s1,56(sp)
    80004830:	7942                	ld	s2,48(sp)
    80004832:	79a2                	ld	s3,40(sp)
    80004834:	6161                	addi	sp,sp,80
    80004836:	8082                	ret
  return -1;
    80004838:	557d                	li	a0,-1
    8000483a:	bfc5                	j	8000482a <filestat+0x60>

000000008000483c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000483c:	7179                	addi	sp,sp,-48
    8000483e:	f406                	sd	ra,40(sp)
    80004840:	f022                	sd	s0,32(sp)
    80004842:	ec26                	sd	s1,24(sp)
    80004844:	e84a                	sd	s2,16(sp)
    80004846:	e44e                	sd	s3,8(sp)
    80004848:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000484a:	00854783          	lbu	a5,8(a0)
    8000484e:	c3d5                	beqz	a5,800048f2 <fileread+0xb6>
    80004850:	84aa                	mv	s1,a0
    80004852:	89ae                	mv	s3,a1
    80004854:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004856:	411c                	lw	a5,0(a0)
    80004858:	4705                	li	a4,1
    8000485a:	04e78963          	beq	a5,a4,800048ac <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000485e:	470d                	li	a4,3
    80004860:	04e78d63          	beq	a5,a4,800048ba <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004864:	4709                	li	a4,2
    80004866:	06e79e63          	bne	a5,a4,800048e2 <fileread+0xa6>
    ilock(f->ip);
    8000486a:	6d08                	ld	a0,24(a0)
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	02c080e7          	jalr	44(ra) # 80003898 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004874:	874a                	mv	a4,s2
    80004876:	5094                	lw	a3,32(s1)
    80004878:	864e                	mv	a2,s3
    8000487a:	4585                	li	a1,1
    8000487c:	6c88                	ld	a0,24(s1)
    8000487e:	fffff097          	auipc	ra,0xfffff
    80004882:	2ce080e7          	jalr	718(ra) # 80003b4c <readi>
    80004886:	892a                	mv	s2,a0
    80004888:	00a05563          	blez	a0,80004892 <fileread+0x56>
      f->off += r;
    8000488c:	509c                	lw	a5,32(s1)
    8000488e:	9fa9                	addw	a5,a5,a0
    80004890:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004892:	6c88                	ld	a0,24(s1)
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	0c6080e7          	jalr	198(ra) # 8000395a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000489c:	854a                	mv	a0,s2
    8000489e:	70a2                	ld	ra,40(sp)
    800048a0:	7402                	ld	s0,32(sp)
    800048a2:	64e2                	ld	s1,24(sp)
    800048a4:	6942                	ld	s2,16(sp)
    800048a6:	69a2                	ld	s3,8(sp)
    800048a8:	6145                	addi	sp,sp,48
    800048aa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048ac:	6908                	ld	a0,16(a0)
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	3c2080e7          	jalr	962(ra) # 80004c70 <piperead>
    800048b6:	892a                	mv	s2,a0
    800048b8:	b7d5                	j	8000489c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048ba:	02451783          	lh	a5,36(a0)
    800048be:	03079693          	slli	a3,a5,0x30
    800048c2:	92c1                	srli	a3,a3,0x30
    800048c4:	4725                	li	a4,9
    800048c6:	02d76863          	bltu	a4,a3,800048f6 <fileread+0xba>
    800048ca:	0792                	slli	a5,a5,0x4
    800048cc:	0001c717          	auipc	a4,0x1c
    800048d0:	37c70713          	addi	a4,a4,892 # 80020c48 <devsw>
    800048d4:	97ba                	add	a5,a5,a4
    800048d6:	639c                	ld	a5,0(a5)
    800048d8:	c38d                	beqz	a5,800048fa <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048da:	4505                	li	a0,1
    800048dc:	9782                	jalr	a5
    800048de:	892a                	mv	s2,a0
    800048e0:	bf75                	j	8000489c <fileread+0x60>
    panic("fileread");
    800048e2:	00004517          	auipc	a0,0x4
    800048e6:	e3e50513          	addi	a0,a0,-450 # 80008720 <syscalls+0x2b8>
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	c52080e7          	jalr	-942(ra) # 8000053c <panic>
    return -1;
    800048f2:	597d                	li	s2,-1
    800048f4:	b765                	j	8000489c <fileread+0x60>
      return -1;
    800048f6:	597d                	li	s2,-1
    800048f8:	b755                	j	8000489c <fileread+0x60>
    800048fa:	597d                	li	s2,-1
    800048fc:	b745                	j	8000489c <fileread+0x60>

00000000800048fe <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048fe:	00954783          	lbu	a5,9(a0)
    80004902:	10078e63          	beqz	a5,80004a1e <filewrite+0x120>
{
    80004906:	715d                	addi	sp,sp,-80
    80004908:	e486                	sd	ra,72(sp)
    8000490a:	e0a2                	sd	s0,64(sp)
    8000490c:	fc26                	sd	s1,56(sp)
    8000490e:	f84a                	sd	s2,48(sp)
    80004910:	f44e                	sd	s3,40(sp)
    80004912:	f052                	sd	s4,32(sp)
    80004914:	ec56                	sd	s5,24(sp)
    80004916:	e85a                	sd	s6,16(sp)
    80004918:	e45e                	sd	s7,8(sp)
    8000491a:	e062                	sd	s8,0(sp)
    8000491c:	0880                	addi	s0,sp,80
    8000491e:	892a                	mv	s2,a0
    80004920:	8b2e                	mv	s6,a1
    80004922:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004924:	411c                	lw	a5,0(a0)
    80004926:	4705                	li	a4,1
    80004928:	02e78263          	beq	a5,a4,8000494c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000492c:	470d                	li	a4,3
    8000492e:	02e78563          	beq	a5,a4,80004958 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004932:	4709                	li	a4,2
    80004934:	0ce79d63          	bne	a5,a4,80004a0e <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004938:	0ac05b63          	blez	a2,800049ee <filewrite+0xf0>
    int i = 0;
    8000493c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000493e:	6b85                	lui	s7,0x1
    80004940:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004944:	6c05                	lui	s8,0x1
    80004946:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000494a:	a851                	j	800049de <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000494c:	6908                	ld	a0,16(a0)
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	22a080e7          	jalr	554(ra) # 80004b78 <pipewrite>
    80004956:	a045                	j	800049f6 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004958:	02451783          	lh	a5,36(a0)
    8000495c:	03079693          	slli	a3,a5,0x30
    80004960:	92c1                	srli	a3,a3,0x30
    80004962:	4725                	li	a4,9
    80004964:	0ad76f63          	bltu	a4,a3,80004a22 <filewrite+0x124>
    80004968:	0792                	slli	a5,a5,0x4
    8000496a:	0001c717          	auipc	a4,0x1c
    8000496e:	2de70713          	addi	a4,a4,734 # 80020c48 <devsw>
    80004972:	97ba                	add	a5,a5,a4
    80004974:	679c                	ld	a5,8(a5)
    80004976:	cbc5                	beqz	a5,80004a26 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004978:	4505                	li	a0,1
    8000497a:	9782                	jalr	a5
    8000497c:	a8ad                	j	800049f6 <filewrite+0xf8>
      if(n1 > max)
    8000497e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004982:	00000097          	auipc	ra,0x0
    80004986:	8bc080e7          	jalr	-1860(ra) # 8000423e <begin_op>
      ilock(f->ip);
    8000498a:	01893503          	ld	a0,24(s2)
    8000498e:	fffff097          	auipc	ra,0xfffff
    80004992:	f0a080e7          	jalr	-246(ra) # 80003898 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004996:	8756                	mv	a4,s5
    80004998:	02092683          	lw	a3,32(s2)
    8000499c:	01698633          	add	a2,s3,s6
    800049a0:	4585                	li	a1,1
    800049a2:	01893503          	ld	a0,24(s2)
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	29e080e7          	jalr	670(ra) # 80003c44 <writei>
    800049ae:	84aa                	mv	s1,a0
    800049b0:	00a05763          	blez	a0,800049be <filewrite+0xc0>
        f->off += r;
    800049b4:	02092783          	lw	a5,32(s2)
    800049b8:	9fa9                	addw	a5,a5,a0
    800049ba:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049be:	01893503          	ld	a0,24(s2)
    800049c2:	fffff097          	auipc	ra,0xfffff
    800049c6:	f98080e7          	jalr	-104(ra) # 8000395a <iunlock>
      end_op();
    800049ca:	00000097          	auipc	ra,0x0
    800049ce:	8ee080e7          	jalr	-1810(ra) # 800042b8 <end_op>

      if(r != n1){
    800049d2:	009a9f63          	bne	s5,s1,800049f0 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800049d6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049da:	0149db63          	bge	s3,s4,800049f0 <filewrite+0xf2>
      int n1 = n - i;
    800049de:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800049e2:	0004879b          	sext.w	a5,s1
    800049e6:	f8fbdce3          	bge	s7,a5,8000497e <filewrite+0x80>
    800049ea:	84e2                	mv	s1,s8
    800049ec:	bf49                	j	8000497e <filewrite+0x80>
    int i = 0;
    800049ee:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800049f0:	033a1d63          	bne	s4,s3,80004a2a <filewrite+0x12c>
    800049f4:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049f6:	60a6                	ld	ra,72(sp)
    800049f8:	6406                	ld	s0,64(sp)
    800049fa:	74e2                	ld	s1,56(sp)
    800049fc:	7942                	ld	s2,48(sp)
    800049fe:	79a2                	ld	s3,40(sp)
    80004a00:	7a02                	ld	s4,32(sp)
    80004a02:	6ae2                	ld	s5,24(sp)
    80004a04:	6b42                	ld	s6,16(sp)
    80004a06:	6ba2                	ld	s7,8(sp)
    80004a08:	6c02                	ld	s8,0(sp)
    80004a0a:	6161                	addi	sp,sp,80
    80004a0c:	8082                	ret
    panic("filewrite");
    80004a0e:	00004517          	auipc	a0,0x4
    80004a12:	d2250513          	addi	a0,a0,-734 # 80008730 <syscalls+0x2c8>
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	b26080e7          	jalr	-1242(ra) # 8000053c <panic>
    return -1;
    80004a1e:	557d                	li	a0,-1
}
    80004a20:	8082                	ret
      return -1;
    80004a22:	557d                	li	a0,-1
    80004a24:	bfc9                	j	800049f6 <filewrite+0xf8>
    80004a26:	557d                	li	a0,-1
    80004a28:	b7f9                	j	800049f6 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004a2a:	557d                	li	a0,-1
    80004a2c:	b7e9                	j	800049f6 <filewrite+0xf8>

0000000080004a2e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a2e:	7179                	addi	sp,sp,-48
    80004a30:	f406                	sd	ra,40(sp)
    80004a32:	f022                	sd	s0,32(sp)
    80004a34:	ec26                	sd	s1,24(sp)
    80004a36:	e84a                	sd	s2,16(sp)
    80004a38:	e44e                	sd	s3,8(sp)
    80004a3a:	e052                	sd	s4,0(sp)
    80004a3c:	1800                	addi	s0,sp,48
    80004a3e:	84aa                	mv	s1,a0
    80004a40:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a42:	0005b023          	sd	zero,0(a1)
    80004a46:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	bfc080e7          	jalr	-1028(ra) # 80004646 <filealloc>
    80004a52:	e088                	sd	a0,0(s1)
    80004a54:	c551                	beqz	a0,80004ae0 <pipealloc+0xb2>
    80004a56:	00000097          	auipc	ra,0x0
    80004a5a:	bf0080e7          	jalr	-1040(ra) # 80004646 <filealloc>
    80004a5e:	00aa3023          	sd	a0,0(s4)
    80004a62:	c92d                	beqz	a0,80004ad4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	07e080e7          	jalr	126(ra) # 80000ae2 <kalloc>
    80004a6c:	892a                	mv	s2,a0
    80004a6e:	c125                	beqz	a0,80004ace <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a70:	4985                	li	s3,1
    80004a72:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a76:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a7a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a7e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a82:	00004597          	auipc	a1,0x4
    80004a86:	cbe58593          	addi	a1,a1,-834 # 80008740 <syscalls+0x2d8>
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	0b8080e7          	jalr	184(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004a92:	609c                	ld	a5,0(s1)
    80004a94:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a98:	609c                	ld	a5,0(s1)
    80004a9a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a9e:	609c                	ld	a5,0(s1)
    80004aa0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004aa4:	609c                	ld	a5,0(s1)
    80004aa6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004aaa:	000a3783          	ld	a5,0(s4)
    80004aae:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ab2:	000a3783          	ld	a5,0(s4)
    80004ab6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aba:	000a3783          	ld	a5,0(s4)
    80004abe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ac2:	000a3783          	ld	a5,0(s4)
    80004ac6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004aca:	4501                	li	a0,0
    80004acc:	a025                	j	80004af4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ace:	6088                	ld	a0,0(s1)
    80004ad0:	e501                	bnez	a0,80004ad8 <pipealloc+0xaa>
    80004ad2:	a039                	j	80004ae0 <pipealloc+0xb2>
    80004ad4:	6088                	ld	a0,0(s1)
    80004ad6:	c51d                	beqz	a0,80004b04 <pipealloc+0xd6>
    fileclose(*f0);
    80004ad8:	00000097          	auipc	ra,0x0
    80004adc:	c2a080e7          	jalr	-982(ra) # 80004702 <fileclose>
  if(*f1)
    80004ae0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ae4:	557d                	li	a0,-1
  if(*f1)
    80004ae6:	c799                	beqz	a5,80004af4 <pipealloc+0xc6>
    fileclose(*f1);
    80004ae8:	853e                	mv	a0,a5
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	c18080e7          	jalr	-1000(ra) # 80004702 <fileclose>
  return -1;
    80004af2:	557d                	li	a0,-1
}
    80004af4:	70a2                	ld	ra,40(sp)
    80004af6:	7402                	ld	s0,32(sp)
    80004af8:	64e2                	ld	s1,24(sp)
    80004afa:	6942                	ld	s2,16(sp)
    80004afc:	69a2                	ld	s3,8(sp)
    80004afe:	6a02                	ld	s4,0(sp)
    80004b00:	6145                	addi	sp,sp,48
    80004b02:	8082                	ret
  return -1;
    80004b04:	557d                	li	a0,-1
    80004b06:	b7fd                	j	80004af4 <pipealloc+0xc6>

0000000080004b08 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b08:	1101                	addi	sp,sp,-32
    80004b0a:	ec06                	sd	ra,24(sp)
    80004b0c:	e822                	sd	s0,16(sp)
    80004b0e:	e426                	sd	s1,8(sp)
    80004b10:	e04a                	sd	s2,0(sp)
    80004b12:	1000                	addi	s0,sp,32
    80004b14:	84aa                	mv	s1,a0
    80004b16:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	0ba080e7          	jalr	186(ra) # 80000bd2 <acquire>
  if(writable){
    80004b20:	02090d63          	beqz	s2,80004b5a <pipeclose+0x52>
    pi->writeopen = 0;
    80004b24:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b28:	21848513          	addi	a0,s1,536
    80004b2c:	ffffd097          	auipc	ra,0xffffd
    80004b30:	69a080e7          	jalr	1690(ra) # 800021c6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b34:	2204b783          	ld	a5,544(s1)
    80004b38:	eb95                	bnez	a5,80004b6c <pipeclose+0x64>
    release(&pi->lock);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	160080e7          	jalr	352(ra) # 80000c9c <release>
    kfree((char*)pi);
    80004b44:	8526                	mv	a0,s1
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	e9e080e7          	jalr	-354(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004b4e:	60e2                	ld	ra,24(sp)
    80004b50:	6442                	ld	s0,16(sp)
    80004b52:	64a2                	ld	s1,8(sp)
    80004b54:	6902                	ld	s2,0(sp)
    80004b56:	6105                	addi	sp,sp,32
    80004b58:	8082                	ret
    pi->readopen = 0;
    80004b5a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b5e:	21c48513          	addi	a0,s1,540
    80004b62:	ffffd097          	auipc	ra,0xffffd
    80004b66:	664080e7          	jalr	1636(ra) # 800021c6 <wakeup>
    80004b6a:	b7e9                	j	80004b34 <pipeclose+0x2c>
    release(&pi->lock);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	12e080e7          	jalr	302(ra) # 80000c9c <release>
}
    80004b76:	bfe1                	j	80004b4e <pipeclose+0x46>

0000000080004b78 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b78:	711d                	addi	sp,sp,-96
    80004b7a:	ec86                	sd	ra,88(sp)
    80004b7c:	e8a2                	sd	s0,80(sp)
    80004b7e:	e4a6                	sd	s1,72(sp)
    80004b80:	e0ca                	sd	s2,64(sp)
    80004b82:	fc4e                	sd	s3,56(sp)
    80004b84:	f852                	sd	s4,48(sp)
    80004b86:	f456                	sd	s5,40(sp)
    80004b88:	f05a                	sd	s6,32(sp)
    80004b8a:	ec5e                	sd	s7,24(sp)
    80004b8c:	e862                	sd	s8,16(sp)
    80004b8e:	1080                	addi	s0,sp,96
    80004b90:	84aa                	mv	s1,a0
    80004b92:	8aae                	mv	s5,a1
    80004b94:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	e26080e7          	jalr	-474(ra) # 800019bc <myproc>
    80004b9e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	030080e7          	jalr	48(ra) # 80000bd2 <acquire>
  while(i < n){
    80004baa:	0b405663          	blez	s4,80004c56 <pipewrite+0xde>
  int i = 0;
    80004bae:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bb0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004bb2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bb6:	21c48b93          	addi	s7,s1,540
    80004bba:	a089                	j	80004bfc <pipewrite+0x84>
      release(&pi->lock);
    80004bbc:	8526                	mv	a0,s1
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	0de080e7          	jalr	222(ra) # 80000c9c <release>
      return -1;
    80004bc6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bc8:	854a                	mv	a0,s2
    80004bca:	60e6                	ld	ra,88(sp)
    80004bcc:	6446                	ld	s0,80(sp)
    80004bce:	64a6                	ld	s1,72(sp)
    80004bd0:	6906                	ld	s2,64(sp)
    80004bd2:	79e2                	ld	s3,56(sp)
    80004bd4:	7a42                	ld	s4,48(sp)
    80004bd6:	7aa2                	ld	s5,40(sp)
    80004bd8:	7b02                	ld	s6,32(sp)
    80004bda:	6be2                	ld	s7,24(sp)
    80004bdc:	6c42                	ld	s8,16(sp)
    80004bde:	6125                	addi	sp,sp,96
    80004be0:	8082                	ret
      wakeup(&pi->nread);
    80004be2:	8562                	mv	a0,s8
    80004be4:	ffffd097          	auipc	ra,0xffffd
    80004be8:	5e2080e7          	jalr	1506(ra) # 800021c6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bec:	85a6                	mv	a1,s1
    80004bee:	855e                	mv	a0,s7
    80004bf0:	ffffd097          	auipc	ra,0xffffd
    80004bf4:	572080e7          	jalr	1394(ra) # 80002162 <sleep>
  while(i < n){
    80004bf8:	07495063          	bge	s2,s4,80004c58 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004bfc:	2204a783          	lw	a5,544(s1)
    80004c00:	dfd5                	beqz	a5,80004bbc <pipewrite+0x44>
    80004c02:	854e                	mv	a0,s3
    80004c04:	ffffe097          	auipc	ra,0xffffe
    80004c08:	806080e7          	jalr	-2042(ra) # 8000240a <killed>
    80004c0c:	f945                	bnez	a0,80004bbc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c0e:	2184a783          	lw	a5,536(s1)
    80004c12:	21c4a703          	lw	a4,540(s1)
    80004c16:	2007879b          	addiw	a5,a5,512
    80004c1a:	fcf704e3          	beq	a4,a5,80004be2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c1e:	4685                	li	a3,1
    80004c20:	01590633          	add	a2,s2,s5
    80004c24:	faf40593          	addi	a1,s0,-81
    80004c28:	0509b503          	ld	a0,80(s3)
    80004c2c:	ffffd097          	auipc	ra,0xffffd
    80004c30:	adc080e7          	jalr	-1316(ra) # 80001708 <copyin>
    80004c34:	03650263          	beq	a0,s6,80004c58 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c38:	21c4a783          	lw	a5,540(s1)
    80004c3c:	0017871b          	addiw	a4,a5,1
    80004c40:	20e4ae23          	sw	a4,540(s1)
    80004c44:	1ff7f793          	andi	a5,a5,511
    80004c48:	97a6                	add	a5,a5,s1
    80004c4a:	faf44703          	lbu	a4,-81(s0)
    80004c4e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c52:	2905                	addiw	s2,s2,1
    80004c54:	b755                	j	80004bf8 <pipewrite+0x80>
  int i = 0;
    80004c56:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004c58:	21848513          	addi	a0,s1,536
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	56a080e7          	jalr	1386(ra) # 800021c6 <wakeup>
  release(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	036080e7          	jalr	54(ra) # 80000c9c <release>
  return i;
    80004c6e:	bfa9                	j	80004bc8 <pipewrite+0x50>

0000000080004c70 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c70:	715d                	addi	sp,sp,-80
    80004c72:	e486                	sd	ra,72(sp)
    80004c74:	e0a2                	sd	s0,64(sp)
    80004c76:	fc26                	sd	s1,56(sp)
    80004c78:	f84a                	sd	s2,48(sp)
    80004c7a:	f44e                	sd	s3,40(sp)
    80004c7c:	f052                	sd	s4,32(sp)
    80004c7e:	ec56                	sd	s5,24(sp)
    80004c80:	e85a                	sd	s6,16(sp)
    80004c82:	0880                	addi	s0,sp,80
    80004c84:	84aa                	mv	s1,a0
    80004c86:	892e                	mv	s2,a1
    80004c88:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c8a:	ffffd097          	auipc	ra,0xffffd
    80004c8e:	d32080e7          	jalr	-718(ra) # 800019bc <myproc>
    80004c92:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c94:	8526                	mv	a0,s1
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	f3c080e7          	jalr	-196(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c9e:	2184a703          	lw	a4,536(s1)
    80004ca2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ca6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004caa:	02f71763          	bne	a4,a5,80004cd8 <piperead+0x68>
    80004cae:	2244a783          	lw	a5,548(s1)
    80004cb2:	c39d                	beqz	a5,80004cd8 <piperead+0x68>
    if(killed(pr)){
    80004cb4:	8552                	mv	a0,s4
    80004cb6:	ffffd097          	auipc	ra,0xffffd
    80004cba:	754080e7          	jalr	1876(ra) # 8000240a <killed>
    80004cbe:	e949                	bnez	a0,80004d50 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cc0:	85a6                	mv	a1,s1
    80004cc2:	854e                	mv	a0,s3
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	49e080e7          	jalr	1182(ra) # 80002162 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ccc:	2184a703          	lw	a4,536(s1)
    80004cd0:	21c4a783          	lw	a5,540(s1)
    80004cd4:	fcf70de3          	beq	a4,a5,80004cae <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cd8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cda:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cdc:	05505463          	blez	s5,80004d24 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004ce0:	2184a783          	lw	a5,536(s1)
    80004ce4:	21c4a703          	lw	a4,540(s1)
    80004ce8:	02f70e63          	beq	a4,a5,80004d24 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cec:	0017871b          	addiw	a4,a5,1
    80004cf0:	20e4ac23          	sw	a4,536(s1)
    80004cf4:	1ff7f793          	andi	a5,a5,511
    80004cf8:	97a6                	add	a5,a5,s1
    80004cfa:	0187c783          	lbu	a5,24(a5)
    80004cfe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d02:	4685                	li	a3,1
    80004d04:	fbf40613          	addi	a2,s0,-65
    80004d08:	85ca                	mv	a1,s2
    80004d0a:	050a3503          	ld	a0,80(s4)
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	96e080e7          	jalr	-1682(ra) # 8000167c <copyout>
    80004d16:	01650763          	beq	a0,s6,80004d24 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d1a:	2985                	addiw	s3,s3,1
    80004d1c:	0905                	addi	s2,s2,1
    80004d1e:	fd3a91e3          	bne	s5,s3,80004ce0 <piperead+0x70>
    80004d22:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d24:	21c48513          	addi	a0,s1,540
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	49e080e7          	jalr	1182(ra) # 800021c6 <wakeup>
  release(&pi->lock);
    80004d30:	8526                	mv	a0,s1
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	f6a080e7          	jalr	-150(ra) # 80000c9c <release>
  return i;
}
    80004d3a:	854e                	mv	a0,s3
    80004d3c:	60a6                	ld	ra,72(sp)
    80004d3e:	6406                	ld	s0,64(sp)
    80004d40:	74e2                	ld	s1,56(sp)
    80004d42:	7942                	ld	s2,48(sp)
    80004d44:	79a2                	ld	s3,40(sp)
    80004d46:	7a02                	ld	s4,32(sp)
    80004d48:	6ae2                	ld	s5,24(sp)
    80004d4a:	6b42                	ld	s6,16(sp)
    80004d4c:	6161                	addi	sp,sp,80
    80004d4e:	8082                	ret
      release(&pi->lock);
    80004d50:	8526                	mv	a0,s1
    80004d52:	ffffc097          	auipc	ra,0xffffc
    80004d56:	f4a080e7          	jalr	-182(ra) # 80000c9c <release>
      return -1;
    80004d5a:	59fd                	li	s3,-1
    80004d5c:	bff9                	j	80004d3a <piperead+0xca>

0000000080004d5e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d5e:	1141                	addi	sp,sp,-16
    80004d60:	e422                	sd	s0,8(sp)
    80004d62:	0800                	addi	s0,sp,16
    80004d64:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d66:	8905                	andi	a0,a0,1
    80004d68:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004d6a:	8b89                	andi	a5,a5,2
    80004d6c:	c399                	beqz	a5,80004d72 <flags2perm+0x14>
      perm |= PTE_W;
    80004d6e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004d72:	6422                	ld	s0,8(sp)
    80004d74:	0141                	addi	sp,sp,16
    80004d76:	8082                	ret

0000000080004d78 <exec>:

int
exec(char *path, char **argv)
{
    80004d78:	df010113          	addi	sp,sp,-528
    80004d7c:	20113423          	sd	ra,520(sp)
    80004d80:	20813023          	sd	s0,512(sp)
    80004d84:	ffa6                	sd	s1,504(sp)
    80004d86:	fbca                	sd	s2,496(sp)
    80004d88:	f7ce                	sd	s3,488(sp)
    80004d8a:	f3d2                	sd	s4,480(sp)
    80004d8c:	efd6                	sd	s5,472(sp)
    80004d8e:	ebda                	sd	s6,464(sp)
    80004d90:	e7de                	sd	s7,456(sp)
    80004d92:	e3e2                	sd	s8,448(sp)
    80004d94:	ff66                	sd	s9,440(sp)
    80004d96:	fb6a                	sd	s10,432(sp)
    80004d98:	f76e                	sd	s11,424(sp)
    80004d9a:	0c00                	addi	s0,sp,528
    80004d9c:	892a                	mv	s2,a0
    80004d9e:	dea43c23          	sd	a0,-520(s0)
    80004da2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	c16080e7          	jalr	-1002(ra) # 800019bc <myproc>
    80004dae:	84aa                	mv	s1,a0

  begin_op();
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	48e080e7          	jalr	1166(ra) # 8000423e <begin_op>

  if((ip = namei(path)) == 0){
    80004db8:	854a                	mv	a0,s2
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	284080e7          	jalr	644(ra) # 8000403e <namei>
    80004dc2:	c92d                	beqz	a0,80004e34 <exec+0xbc>
    80004dc4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	ad2080e7          	jalr	-1326(ra) # 80003898 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dce:	04000713          	li	a4,64
    80004dd2:	4681                	li	a3,0
    80004dd4:	e5040613          	addi	a2,s0,-432
    80004dd8:	4581                	li	a1,0
    80004dda:	8552                	mv	a0,s4
    80004ddc:	fffff097          	auipc	ra,0xfffff
    80004de0:	d70080e7          	jalr	-656(ra) # 80003b4c <readi>
    80004de4:	04000793          	li	a5,64
    80004de8:	00f51a63          	bne	a0,a5,80004dfc <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004dec:	e5042703          	lw	a4,-432(s0)
    80004df0:	464c47b7          	lui	a5,0x464c4
    80004df4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004df8:	04f70463          	beq	a4,a5,80004e40 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dfc:	8552                	mv	a0,s4
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	cfc080e7          	jalr	-772(ra) # 80003afa <iunlockput>
    end_op();
    80004e06:	fffff097          	auipc	ra,0xfffff
    80004e0a:	4b2080e7          	jalr	1202(ra) # 800042b8 <end_op>
  }
  return -1;
    80004e0e:	557d                	li	a0,-1
}
    80004e10:	20813083          	ld	ra,520(sp)
    80004e14:	20013403          	ld	s0,512(sp)
    80004e18:	74fe                	ld	s1,504(sp)
    80004e1a:	795e                	ld	s2,496(sp)
    80004e1c:	79be                	ld	s3,488(sp)
    80004e1e:	7a1e                	ld	s4,480(sp)
    80004e20:	6afe                	ld	s5,472(sp)
    80004e22:	6b5e                	ld	s6,464(sp)
    80004e24:	6bbe                	ld	s7,456(sp)
    80004e26:	6c1e                	ld	s8,448(sp)
    80004e28:	7cfa                	ld	s9,440(sp)
    80004e2a:	7d5a                	ld	s10,432(sp)
    80004e2c:	7dba                	ld	s11,424(sp)
    80004e2e:	21010113          	addi	sp,sp,528
    80004e32:	8082                	ret
    end_op();
    80004e34:	fffff097          	auipc	ra,0xfffff
    80004e38:	484080e7          	jalr	1156(ra) # 800042b8 <end_op>
    return -1;
    80004e3c:	557d                	li	a0,-1
    80004e3e:	bfc9                	j	80004e10 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e40:	8526                	mv	a0,s1
    80004e42:	ffffd097          	auipc	ra,0xffffd
    80004e46:	c3e080e7          	jalr	-962(ra) # 80001a80 <proc_pagetable>
    80004e4a:	8b2a                	mv	s6,a0
    80004e4c:	d945                	beqz	a0,80004dfc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e4e:	e7042d03          	lw	s10,-400(s0)
    80004e52:	e8845783          	lhu	a5,-376(s0)
    80004e56:	10078463          	beqz	a5,80004f5e <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e5a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e5c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004e5e:	6c85                	lui	s9,0x1
    80004e60:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e64:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004e68:	6a85                	lui	s5,0x1
    80004e6a:	a0b5                	j	80004ed6 <exec+0x15e>
      panic("loadseg: address should exist");
    80004e6c:	00004517          	auipc	a0,0x4
    80004e70:	8dc50513          	addi	a0,a0,-1828 # 80008748 <syscalls+0x2e0>
    80004e74:	ffffb097          	auipc	ra,0xffffb
    80004e78:	6c8080e7          	jalr	1736(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004e7c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e7e:	8726                	mv	a4,s1
    80004e80:	012c06bb          	addw	a3,s8,s2
    80004e84:	4581                	li	a1,0
    80004e86:	8552                	mv	a0,s4
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	cc4080e7          	jalr	-828(ra) # 80003b4c <readi>
    80004e90:	2501                	sext.w	a0,a0
    80004e92:	24a49863          	bne	s1,a0,800050e2 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004e96:	012a893b          	addw	s2,s5,s2
    80004e9a:	03397563          	bgeu	s2,s3,80004ec4 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004e9e:	02091593          	slli	a1,s2,0x20
    80004ea2:	9181                	srli	a1,a1,0x20
    80004ea4:	95de                	add	a1,a1,s7
    80004ea6:	855a                	mv	a0,s6
    80004ea8:	ffffc097          	auipc	ra,0xffffc
    80004eac:	1c4080e7          	jalr	452(ra) # 8000106c <walkaddr>
    80004eb0:	862a                	mv	a2,a0
    if(pa == 0)
    80004eb2:	dd4d                	beqz	a0,80004e6c <exec+0xf4>
    if(sz - i < PGSIZE)
    80004eb4:	412984bb          	subw	s1,s3,s2
    80004eb8:	0004879b          	sext.w	a5,s1
    80004ebc:	fcfcf0e3          	bgeu	s9,a5,80004e7c <exec+0x104>
    80004ec0:	84d6                	mv	s1,s5
    80004ec2:	bf6d                	j	80004e7c <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ec4:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ec8:	2d85                	addiw	s11,s11,1
    80004eca:	038d0d1b          	addiw	s10,s10,56
    80004ece:	e8845783          	lhu	a5,-376(s0)
    80004ed2:	08fdd763          	bge	s11,a5,80004f60 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ed6:	2d01                	sext.w	s10,s10
    80004ed8:	03800713          	li	a4,56
    80004edc:	86ea                	mv	a3,s10
    80004ede:	e1840613          	addi	a2,s0,-488
    80004ee2:	4581                	li	a1,0
    80004ee4:	8552                	mv	a0,s4
    80004ee6:	fffff097          	auipc	ra,0xfffff
    80004eea:	c66080e7          	jalr	-922(ra) # 80003b4c <readi>
    80004eee:	03800793          	li	a5,56
    80004ef2:	1ef51663          	bne	a0,a5,800050de <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004ef6:	e1842783          	lw	a5,-488(s0)
    80004efa:	4705                	li	a4,1
    80004efc:	fce796e3          	bne	a5,a4,80004ec8 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004f00:	e4043483          	ld	s1,-448(s0)
    80004f04:	e3843783          	ld	a5,-456(s0)
    80004f08:	1ef4e863          	bltu	s1,a5,800050f8 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f0c:	e2843783          	ld	a5,-472(s0)
    80004f10:	94be                	add	s1,s1,a5
    80004f12:	1ef4e663          	bltu	s1,a5,800050fe <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004f16:	df043703          	ld	a4,-528(s0)
    80004f1a:	8ff9                	and	a5,a5,a4
    80004f1c:	1e079463          	bnez	a5,80005104 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f20:	e1c42503          	lw	a0,-484(s0)
    80004f24:	00000097          	auipc	ra,0x0
    80004f28:	e3a080e7          	jalr	-454(ra) # 80004d5e <flags2perm>
    80004f2c:	86aa                	mv	a3,a0
    80004f2e:	8626                	mv	a2,s1
    80004f30:	85ca                	mv	a1,s2
    80004f32:	855a                	mv	a0,s6
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	4ec080e7          	jalr	1260(ra) # 80001420 <uvmalloc>
    80004f3c:	e0a43423          	sd	a0,-504(s0)
    80004f40:	1c050563          	beqz	a0,8000510a <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f44:	e2843b83          	ld	s7,-472(s0)
    80004f48:	e2042c03          	lw	s8,-480(s0)
    80004f4c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f50:	00098463          	beqz	s3,80004f58 <exec+0x1e0>
    80004f54:	4901                	li	s2,0
    80004f56:	b7a1                	j	80004e9e <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f58:	e0843903          	ld	s2,-504(s0)
    80004f5c:	b7b5                	j	80004ec8 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f5e:	4901                	li	s2,0
  iunlockput(ip);
    80004f60:	8552                	mv	a0,s4
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	b98080e7          	jalr	-1128(ra) # 80003afa <iunlockput>
  end_op();
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	34e080e7          	jalr	846(ra) # 800042b8 <end_op>
  p = myproc();
    80004f72:	ffffd097          	auipc	ra,0xffffd
    80004f76:	a4a080e7          	jalr	-1462(ra) # 800019bc <myproc>
    80004f7a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f7c:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004f80:	6985                	lui	s3,0x1
    80004f82:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004f84:	99ca                	add	s3,s3,s2
    80004f86:	77fd                	lui	a5,0xfffff
    80004f88:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f8c:	4691                	li	a3,4
    80004f8e:	6609                	lui	a2,0x2
    80004f90:	964e                	add	a2,a2,s3
    80004f92:	85ce                	mv	a1,s3
    80004f94:	855a                	mv	a0,s6
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	48a080e7          	jalr	1162(ra) # 80001420 <uvmalloc>
    80004f9e:	892a                	mv	s2,a0
    80004fa0:	e0a43423          	sd	a0,-504(s0)
    80004fa4:	e509                	bnez	a0,80004fae <exec+0x236>
  if(pagetable)
    80004fa6:	e1343423          	sd	s3,-504(s0)
    80004faa:	4a01                	li	s4,0
    80004fac:	aa1d                	j	800050e2 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fae:	75f9                	lui	a1,0xffffe
    80004fb0:	95aa                	add	a1,a1,a0
    80004fb2:	855a                	mv	a0,s6
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	696080e7          	jalr	1686(ra) # 8000164a <uvmclear>
  stackbase = sp - PGSIZE;
    80004fbc:	7bfd                	lui	s7,0xfffff
    80004fbe:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004fc0:	e0043783          	ld	a5,-512(s0)
    80004fc4:	6388                	ld	a0,0(a5)
    80004fc6:	c52d                	beqz	a0,80005030 <exec+0x2b8>
    80004fc8:	e9040993          	addi	s3,s0,-368
    80004fcc:	f9040c13          	addi	s8,s0,-112
    80004fd0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	e8c080e7          	jalr	-372(ra) # 80000e5e <strlen>
    80004fda:	0015079b          	addiw	a5,a0,1
    80004fde:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fe2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004fe6:	13796563          	bltu	s2,s7,80005110 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fea:	e0043d03          	ld	s10,-512(s0)
    80004fee:	000d3a03          	ld	s4,0(s10)
    80004ff2:	8552                	mv	a0,s4
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	e6a080e7          	jalr	-406(ra) # 80000e5e <strlen>
    80004ffc:	0015069b          	addiw	a3,a0,1
    80005000:	8652                	mv	a2,s4
    80005002:	85ca                	mv	a1,s2
    80005004:	855a                	mv	a0,s6
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	676080e7          	jalr	1654(ra) # 8000167c <copyout>
    8000500e:	10054363          	bltz	a0,80005114 <exec+0x39c>
    ustack[argc] = sp;
    80005012:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005016:	0485                	addi	s1,s1,1
    80005018:	008d0793          	addi	a5,s10,8
    8000501c:	e0f43023          	sd	a5,-512(s0)
    80005020:	008d3503          	ld	a0,8(s10)
    80005024:	c909                	beqz	a0,80005036 <exec+0x2be>
    if(argc >= MAXARG)
    80005026:	09a1                	addi	s3,s3,8
    80005028:	fb8995e3          	bne	s3,s8,80004fd2 <exec+0x25a>
  ip = 0;
    8000502c:	4a01                	li	s4,0
    8000502e:	a855                	j	800050e2 <exec+0x36a>
  sp = sz;
    80005030:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005034:	4481                	li	s1,0
  ustack[argc] = 0;
    80005036:	00349793          	slli	a5,s1,0x3
    8000503a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd1b0>
    8000503e:	97a2                	add	a5,a5,s0
    80005040:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005044:	00148693          	addi	a3,s1,1
    80005048:	068e                	slli	a3,a3,0x3
    8000504a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000504e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005052:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005056:	f57968e3          	bltu	s2,s7,80004fa6 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000505a:	e9040613          	addi	a2,s0,-368
    8000505e:	85ca                	mv	a1,s2
    80005060:	855a                	mv	a0,s6
    80005062:	ffffc097          	auipc	ra,0xffffc
    80005066:	61a080e7          	jalr	1562(ra) # 8000167c <copyout>
    8000506a:	0a054763          	bltz	a0,80005118 <exec+0x3a0>
  p->trapframe->a1 = sp;
    8000506e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005072:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005076:	df843783          	ld	a5,-520(s0)
    8000507a:	0007c703          	lbu	a4,0(a5)
    8000507e:	cf11                	beqz	a4,8000509a <exec+0x322>
    80005080:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005082:	02f00693          	li	a3,47
    80005086:	a039                	j	80005094 <exec+0x31c>
      last = s+1;
    80005088:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000508c:	0785                	addi	a5,a5,1
    8000508e:	fff7c703          	lbu	a4,-1(a5)
    80005092:	c701                	beqz	a4,8000509a <exec+0x322>
    if(*s == '/')
    80005094:	fed71ce3          	bne	a4,a3,8000508c <exec+0x314>
    80005098:	bfc5                	j	80005088 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    8000509a:	4641                	li	a2,16
    8000509c:	df843583          	ld	a1,-520(s0)
    800050a0:	158a8513          	addi	a0,s5,344
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	d88080e7          	jalr	-632(ra) # 80000e2c <safestrcpy>
  oldpagetable = p->pagetable;
    800050ac:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050b0:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800050b4:	e0843783          	ld	a5,-504(s0)
    800050b8:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050bc:	058ab783          	ld	a5,88(s5)
    800050c0:	e6843703          	ld	a4,-408(s0)
    800050c4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050c6:	058ab783          	ld	a5,88(s5)
    800050ca:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050ce:	85e6                	mv	a1,s9
    800050d0:	ffffd097          	auipc	ra,0xffffd
    800050d4:	a4c080e7          	jalr	-1460(ra) # 80001b1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050d8:	0004851b          	sext.w	a0,s1
    800050dc:	bb15                	j	80004e10 <exec+0x98>
    800050de:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050e2:	e0843583          	ld	a1,-504(s0)
    800050e6:	855a                	mv	a0,s6
    800050e8:	ffffd097          	auipc	ra,0xffffd
    800050ec:	a34080e7          	jalr	-1484(ra) # 80001b1c <proc_freepagetable>
  return -1;
    800050f0:	557d                	li	a0,-1
  if(ip){
    800050f2:	d00a0fe3          	beqz	s4,80004e10 <exec+0x98>
    800050f6:	b319                	j	80004dfc <exec+0x84>
    800050f8:	e1243423          	sd	s2,-504(s0)
    800050fc:	b7dd                	j	800050e2 <exec+0x36a>
    800050fe:	e1243423          	sd	s2,-504(s0)
    80005102:	b7c5                	j	800050e2 <exec+0x36a>
    80005104:	e1243423          	sd	s2,-504(s0)
    80005108:	bfe9                	j	800050e2 <exec+0x36a>
    8000510a:	e1243423          	sd	s2,-504(s0)
    8000510e:	bfd1                	j	800050e2 <exec+0x36a>
  ip = 0;
    80005110:	4a01                	li	s4,0
    80005112:	bfc1                	j	800050e2 <exec+0x36a>
    80005114:	4a01                	li	s4,0
  if(pagetable)
    80005116:	b7f1                	j	800050e2 <exec+0x36a>
  sz = sz1;
    80005118:	e0843983          	ld	s3,-504(s0)
    8000511c:	b569                	j	80004fa6 <exec+0x22e>

000000008000511e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000511e:	7179                	addi	sp,sp,-48
    80005120:	f406                	sd	ra,40(sp)
    80005122:	f022                	sd	s0,32(sp)
    80005124:	ec26                	sd	s1,24(sp)
    80005126:	e84a                	sd	s2,16(sp)
    80005128:	1800                	addi	s0,sp,48
    8000512a:	892e                	mv	s2,a1
    8000512c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000512e:	fdc40593          	addi	a1,s0,-36
    80005132:	ffffe097          	auipc	ra,0xffffe
    80005136:	aa2080e7          	jalr	-1374(ra) # 80002bd4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000513a:	fdc42703          	lw	a4,-36(s0)
    8000513e:	47bd                	li	a5,15
    80005140:	02e7eb63          	bltu	a5,a4,80005176 <argfd+0x58>
    80005144:	ffffd097          	auipc	ra,0xffffd
    80005148:	878080e7          	jalr	-1928(ra) # 800019bc <myproc>
    8000514c:	fdc42703          	lw	a4,-36(s0)
    80005150:	01a70793          	addi	a5,a4,26
    80005154:	078e                	slli	a5,a5,0x3
    80005156:	953e                	add	a0,a0,a5
    80005158:	611c                	ld	a5,0(a0)
    8000515a:	c385                	beqz	a5,8000517a <argfd+0x5c>
    return -1;
  if(pfd)
    8000515c:	00090463          	beqz	s2,80005164 <argfd+0x46>
    *pfd = fd;
    80005160:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005164:	4501                	li	a0,0
  if(pf)
    80005166:	c091                	beqz	s1,8000516a <argfd+0x4c>
    *pf = f;
    80005168:	e09c                	sd	a5,0(s1)
}
    8000516a:	70a2                	ld	ra,40(sp)
    8000516c:	7402                	ld	s0,32(sp)
    8000516e:	64e2                	ld	s1,24(sp)
    80005170:	6942                	ld	s2,16(sp)
    80005172:	6145                	addi	sp,sp,48
    80005174:	8082                	ret
    return -1;
    80005176:	557d                	li	a0,-1
    80005178:	bfcd                	j	8000516a <argfd+0x4c>
    8000517a:	557d                	li	a0,-1
    8000517c:	b7fd                	j	8000516a <argfd+0x4c>

000000008000517e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000517e:	1101                	addi	sp,sp,-32
    80005180:	ec06                	sd	ra,24(sp)
    80005182:	e822                	sd	s0,16(sp)
    80005184:	e426                	sd	s1,8(sp)
    80005186:	1000                	addi	s0,sp,32
    80005188:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000518a:	ffffd097          	auipc	ra,0xffffd
    8000518e:	832080e7          	jalr	-1998(ra) # 800019bc <myproc>
    80005192:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005194:	0d050793          	addi	a5,a0,208
    80005198:	4501                	li	a0,0
    8000519a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000519c:	6398                	ld	a4,0(a5)
    8000519e:	cb19                	beqz	a4,800051b4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051a0:	2505                	addiw	a0,a0,1
    800051a2:	07a1                	addi	a5,a5,8
    800051a4:	fed51ce3          	bne	a0,a3,8000519c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051a8:	557d                	li	a0,-1
}
    800051aa:	60e2                	ld	ra,24(sp)
    800051ac:	6442                	ld	s0,16(sp)
    800051ae:	64a2                	ld	s1,8(sp)
    800051b0:	6105                	addi	sp,sp,32
    800051b2:	8082                	ret
      p->ofile[fd] = f;
    800051b4:	01a50793          	addi	a5,a0,26
    800051b8:	078e                	slli	a5,a5,0x3
    800051ba:	963e                	add	a2,a2,a5
    800051bc:	e204                	sd	s1,0(a2)
      return fd;
    800051be:	b7f5                	j	800051aa <fdalloc+0x2c>

00000000800051c0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051c0:	715d                	addi	sp,sp,-80
    800051c2:	e486                	sd	ra,72(sp)
    800051c4:	e0a2                	sd	s0,64(sp)
    800051c6:	fc26                	sd	s1,56(sp)
    800051c8:	f84a                	sd	s2,48(sp)
    800051ca:	f44e                	sd	s3,40(sp)
    800051cc:	f052                	sd	s4,32(sp)
    800051ce:	ec56                	sd	s5,24(sp)
    800051d0:	e85a                	sd	s6,16(sp)
    800051d2:	0880                	addi	s0,sp,80
    800051d4:	8b2e                	mv	s6,a1
    800051d6:	89b2                	mv	s3,a2
    800051d8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051da:	fb040593          	addi	a1,s0,-80
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	e7e080e7          	jalr	-386(ra) # 8000405c <nameiparent>
    800051e6:	84aa                	mv	s1,a0
    800051e8:	14050b63          	beqz	a0,8000533e <create+0x17e>
    return 0;

  ilock(dp);
    800051ec:	ffffe097          	auipc	ra,0xffffe
    800051f0:	6ac080e7          	jalr	1708(ra) # 80003898 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051f4:	4601                	li	a2,0
    800051f6:	fb040593          	addi	a1,s0,-80
    800051fa:	8526                	mv	a0,s1
    800051fc:	fffff097          	auipc	ra,0xfffff
    80005200:	b80080e7          	jalr	-1152(ra) # 80003d7c <dirlookup>
    80005204:	8aaa                	mv	s5,a0
    80005206:	c921                	beqz	a0,80005256 <create+0x96>
    iunlockput(dp);
    80005208:	8526                	mv	a0,s1
    8000520a:	fffff097          	auipc	ra,0xfffff
    8000520e:	8f0080e7          	jalr	-1808(ra) # 80003afa <iunlockput>
    ilock(ip);
    80005212:	8556                	mv	a0,s5
    80005214:	ffffe097          	auipc	ra,0xffffe
    80005218:	684080e7          	jalr	1668(ra) # 80003898 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000521c:	4789                	li	a5,2
    8000521e:	02fb1563          	bne	s6,a5,80005248 <create+0x88>
    80005222:	044ad783          	lhu	a5,68(s5)
    80005226:	37f9                	addiw	a5,a5,-2
    80005228:	17c2                	slli	a5,a5,0x30
    8000522a:	93c1                	srli	a5,a5,0x30
    8000522c:	4705                	li	a4,1
    8000522e:	00f76d63          	bltu	a4,a5,80005248 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005232:	8556                	mv	a0,s5
    80005234:	60a6                	ld	ra,72(sp)
    80005236:	6406                	ld	s0,64(sp)
    80005238:	74e2                	ld	s1,56(sp)
    8000523a:	7942                	ld	s2,48(sp)
    8000523c:	79a2                	ld	s3,40(sp)
    8000523e:	7a02                	ld	s4,32(sp)
    80005240:	6ae2                	ld	s5,24(sp)
    80005242:	6b42                	ld	s6,16(sp)
    80005244:	6161                	addi	sp,sp,80
    80005246:	8082                	ret
    iunlockput(ip);
    80005248:	8556                	mv	a0,s5
    8000524a:	fffff097          	auipc	ra,0xfffff
    8000524e:	8b0080e7          	jalr	-1872(ra) # 80003afa <iunlockput>
    return 0;
    80005252:	4a81                	li	s5,0
    80005254:	bff9                	j	80005232 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005256:	85da                	mv	a1,s6
    80005258:	4088                	lw	a0,0(s1)
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	4a6080e7          	jalr	1190(ra) # 80003700 <ialloc>
    80005262:	8a2a                	mv	s4,a0
    80005264:	c529                	beqz	a0,800052ae <create+0xee>
  ilock(ip);
    80005266:	ffffe097          	auipc	ra,0xffffe
    8000526a:	632080e7          	jalr	1586(ra) # 80003898 <ilock>
  ip->major = major;
    8000526e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005272:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005276:	4905                	li	s2,1
    80005278:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000527c:	8552                	mv	a0,s4
    8000527e:	ffffe097          	auipc	ra,0xffffe
    80005282:	54e080e7          	jalr	1358(ra) # 800037cc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005286:	032b0b63          	beq	s6,s2,800052bc <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000528a:	004a2603          	lw	a2,4(s4)
    8000528e:	fb040593          	addi	a1,s0,-80
    80005292:	8526                	mv	a0,s1
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	cf8080e7          	jalr	-776(ra) # 80003f8c <dirlink>
    8000529c:	06054f63          	bltz	a0,8000531a <create+0x15a>
  iunlockput(dp);
    800052a0:	8526                	mv	a0,s1
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	858080e7          	jalr	-1960(ra) # 80003afa <iunlockput>
  return ip;
    800052aa:	8ad2                	mv	s5,s4
    800052ac:	b759                	j	80005232 <create+0x72>
    iunlockput(dp);
    800052ae:	8526                	mv	a0,s1
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	84a080e7          	jalr	-1974(ra) # 80003afa <iunlockput>
    return 0;
    800052b8:	8ad2                	mv	s5,s4
    800052ba:	bfa5                	j	80005232 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052bc:	004a2603          	lw	a2,4(s4)
    800052c0:	00003597          	auipc	a1,0x3
    800052c4:	4a858593          	addi	a1,a1,1192 # 80008768 <syscalls+0x300>
    800052c8:	8552                	mv	a0,s4
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	cc2080e7          	jalr	-830(ra) # 80003f8c <dirlink>
    800052d2:	04054463          	bltz	a0,8000531a <create+0x15a>
    800052d6:	40d0                	lw	a2,4(s1)
    800052d8:	00003597          	auipc	a1,0x3
    800052dc:	49858593          	addi	a1,a1,1176 # 80008770 <syscalls+0x308>
    800052e0:	8552                	mv	a0,s4
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	caa080e7          	jalr	-854(ra) # 80003f8c <dirlink>
    800052ea:	02054863          	bltz	a0,8000531a <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800052ee:	004a2603          	lw	a2,4(s4)
    800052f2:	fb040593          	addi	a1,s0,-80
    800052f6:	8526                	mv	a0,s1
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	c94080e7          	jalr	-876(ra) # 80003f8c <dirlink>
    80005300:	00054d63          	bltz	a0,8000531a <create+0x15a>
    dp->nlink++;  // for ".."
    80005304:	04a4d783          	lhu	a5,74(s1)
    80005308:	2785                	addiw	a5,a5,1
    8000530a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000530e:	8526                	mv	a0,s1
    80005310:	ffffe097          	auipc	ra,0xffffe
    80005314:	4bc080e7          	jalr	1212(ra) # 800037cc <iupdate>
    80005318:	b761                	j	800052a0 <create+0xe0>
  ip->nlink = 0;
    8000531a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000531e:	8552                	mv	a0,s4
    80005320:	ffffe097          	auipc	ra,0xffffe
    80005324:	4ac080e7          	jalr	1196(ra) # 800037cc <iupdate>
  iunlockput(ip);
    80005328:	8552                	mv	a0,s4
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	7d0080e7          	jalr	2000(ra) # 80003afa <iunlockput>
  iunlockput(dp);
    80005332:	8526                	mv	a0,s1
    80005334:	ffffe097          	auipc	ra,0xffffe
    80005338:	7c6080e7          	jalr	1990(ra) # 80003afa <iunlockput>
  return 0;
    8000533c:	bddd                	j	80005232 <create+0x72>
    return 0;
    8000533e:	8aaa                	mv	s5,a0
    80005340:	bdcd                	j	80005232 <create+0x72>

0000000080005342 <sys_dup>:
{
    80005342:	7179                	addi	sp,sp,-48
    80005344:	f406                	sd	ra,40(sp)
    80005346:	f022                	sd	s0,32(sp)
    80005348:	ec26                	sd	s1,24(sp)
    8000534a:	e84a                	sd	s2,16(sp)
    8000534c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000534e:	fd840613          	addi	a2,s0,-40
    80005352:	4581                	li	a1,0
    80005354:	4501                	li	a0,0
    80005356:	00000097          	auipc	ra,0x0
    8000535a:	dc8080e7          	jalr	-568(ra) # 8000511e <argfd>
    return -1;
    8000535e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005360:	02054363          	bltz	a0,80005386 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005364:	fd843903          	ld	s2,-40(s0)
    80005368:	854a                	mv	a0,s2
    8000536a:	00000097          	auipc	ra,0x0
    8000536e:	e14080e7          	jalr	-492(ra) # 8000517e <fdalloc>
    80005372:	84aa                	mv	s1,a0
    return -1;
    80005374:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005376:	00054863          	bltz	a0,80005386 <sys_dup+0x44>
  filedup(f);
    8000537a:	854a                	mv	a0,s2
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	334080e7          	jalr	820(ra) # 800046b0 <filedup>
  return fd;
    80005384:	87a6                	mv	a5,s1
}
    80005386:	853e                	mv	a0,a5
    80005388:	70a2                	ld	ra,40(sp)
    8000538a:	7402                	ld	s0,32(sp)
    8000538c:	64e2                	ld	s1,24(sp)
    8000538e:	6942                	ld	s2,16(sp)
    80005390:	6145                	addi	sp,sp,48
    80005392:	8082                	ret

0000000080005394 <sys_read>:
{
    80005394:	7179                	addi	sp,sp,-48
    80005396:	f406                	sd	ra,40(sp)
    80005398:	f022                	sd	s0,32(sp)
    8000539a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000539c:	fd840593          	addi	a1,s0,-40
    800053a0:	4505                	li	a0,1
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	852080e7          	jalr	-1966(ra) # 80002bf4 <argaddr>
  argint(2, &n);
    800053aa:	fe440593          	addi	a1,s0,-28
    800053ae:	4509                	li	a0,2
    800053b0:	ffffe097          	auipc	ra,0xffffe
    800053b4:	824080e7          	jalr	-2012(ra) # 80002bd4 <argint>
  if(argfd(0, 0, &f) < 0)
    800053b8:	fe840613          	addi	a2,s0,-24
    800053bc:	4581                	li	a1,0
    800053be:	4501                	li	a0,0
    800053c0:	00000097          	auipc	ra,0x0
    800053c4:	d5e080e7          	jalr	-674(ra) # 8000511e <argfd>
    800053c8:	87aa                	mv	a5,a0
    return -1;
    800053ca:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053cc:	0007cc63          	bltz	a5,800053e4 <sys_read+0x50>
  return fileread(f, p, n);
    800053d0:	fe442603          	lw	a2,-28(s0)
    800053d4:	fd843583          	ld	a1,-40(s0)
    800053d8:	fe843503          	ld	a0,-24(s0)
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	460080e7          	jalr	1120(ra) # 8000483c <fileread>
}
    800053e4:	70a2                	ld	ra,40(sp)
    800053e6:	7402                	ld	s0,32(sp)
    800053e8:	6145                	addi	sp,sp,48
    800053ea:	8082                	ret

00000000800053ec <sys_write>:
{
    800053ec:	7179                	addi	sp,sp,-48
    800053ee:	f406                	sd	ra,40(sp)
    800053f0:	f022                	sd	s0,32(sp)
    800053f2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053f4:	fd840593          	addi	a1,s0,-40
    800053f8:	4505                	li	a0,1
    800053fa:	ffffd097          	auipc	ra,0xffffd
    800053fe:	7fa080e7          	jalr	2042(ra) # 80002bf4 <argaddr>
  argint(2, &n);
    80005402:	fe440593          	addi	a1,s0,-28
    80005406:	4509                	li	a0,2
    80005408:	ffffd097          	auipc	ra,0xffffd
    8000540c:	7cc080e7          	jalr	1996(ra) # 80002bd4 <argint>
  if(argfd(0, 0, &f) < 0)
    80005410:	fe840613          	addi	a2,s0,-24
    80005414:	4581                	li	a1,0
    80005416:	4501                	li	a0,0
    80005418:	00000097          	auipc	ra,0x0
    8000541c:	d06080e7          	jalr	-762(ra) # 8000511e <argfd>
    80005420:	87aa                	mv	a5,a0
    return -1;
    80005422:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005424:	0007cc63          	bltz	a5,8000543c <sys_write+0x50>
  return filewrite(f, p, n);
    80005428:	fe442603          	lw	a2,-28(s0)
    8000542c:	fd843583          	ld	a1,-40(s0)
    80005430:	fe843503          	ld	a0,-24(s0)
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	4ca080e7          	jalr	1226(ra) # 800048fe <filewrite>
}
    8000543c:	70a2                	ld	ra,40(sp)
    8000543e:	7402                	ld	s0,32(sp)
    80005440:	6145                	addi	sp,sp,48
    80005442:	8082                	ret

0000000080005444 <sys_close>:
{
    80005444:	1101                	addi	sp,sp,-32
    80005446:	ec06                	sd	ra,24(sp)
    80005448:	e822                	sd	s0,16(sp)
    8000544a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000544c:	fe040613          	addi	a2,s0,-32
    80005450:	fec40593          	addi	a1,s0,-20
    80005454:	4501                	li	a0,0
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	cc8080e7          	jalr	-824(ra) # 8000511e <argfd>
    return -1;
    8000545e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005460:	02054463          	bltz	a0,80005488 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005464:	ffffc097          	auipc	ra,0xffffc
    80005468:	558080e7          	jalr	1368(ra) # 800019bc <myproc>
    8000546c:	fec42783          	lw	a5,-20(s0)
    80005470:	07e9                	addi	a5,a5,26
    80005472:	078e                	slli	a5,a5,0x3
    80005474:	953e                	add	a0,a0,a5
    80005476:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000547a:	fe043503          	ld	a0,-32(s0)
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	284080e7          	jalr	644(ra) # 80004702 <fileclose>
  return 0;
    80005486:	4781                	li	a5,0
}
    80005488:	853e                	mv	a0,a5
    8000548a:	60e2                	ld	ra,24(sp)
    8000548c:	6442                	ld	s0,16(sp)
    8000548e:	6105                	addi	sp,sp,32
    80005490:	8082                	ret

0000000080005492 <sys_fstat>:
{
    80005492:	1101                	addi	sp,sp,-32
    80005494:	ec06                	sd	ra,24(sp)
    80005496:	e822                	sd	s0,16(sp)
    80005498:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000549a:	fe040593          	addi	a1,s0,-32
    8000549e:	4505                	li	a0,1
    800054a0:	ffffd097          	auipc	ra,0xffffd
    800054a4:	754080e7          	jalr	1876(ra) # 80002bf4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054a8:	fe840613          	addi	a2,s0,-24
    800054ac:	4581                	li	a1,0
    800054ae:	4501                	li	a0,0
    800054b0:	00000097          	auipc	ra,0x0
    800054b4:	c6e080e7          	jalr	-914(ra) # 8000511e <argfd>
    800054b8:	87aa                	mv	a5,a0
    return -1;
    800054ba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054bc:	0007ca63          	bltz	a5,800054d0 <sys_fstat+0x3e>
  return filestat(f, st);
    800054c0:	fe043583          	ld	a1,-32(s0)
    800054c4:	fe843503          	ld	a0,-24(s0)
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	302080e7          	jalr	770(ra) # 800047ca <filestat>
}
    800054d0:	60e2                	ld	ra,24(sp)
    800054d2:	6442                	ld	s0,16(sp)
    800054d4:	6105                	addi	sp,sp,32
    800054d6:	8082                	ret

00000000800054d8 <sys_link>:
{
    800054d8:	7169                	addi	sp,sp,-304
    800054da:	f606                	sd	ra,296(sp)
    800054dc:	f222                	sd	s0,288(sp)
    800054de:	ee26                	sd	s1,280(sp)
    800054e0:	ea4a                	sd	s2,272(sp)
    800054e2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054e4:	08000613          	li	a2,128
    800054e8:	ed040593          	addi	a1,s0,-304
    800054ec:	4501                	li	a0,0
    800054ee:	ffffd097          	auipc	ra,0xffffd
    800054f2:	726080e7          	jalr	1830(ra) # 80002c14 <argstr>
    return -1;
    800054f6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f8:	10054e63          	bltz	a0,80005614 <sys_link+0x13c>
    800054fc:	08000613          	li	a2,128
    80005500:	f5040593          	addi	a1,s0,-176
    80005504:	4505                	li	a0,1
    80005506:	ffffd097          	auipc	ra,0xffffd
    8000550a:	70e080e7          	jalr	1806(ra) # 80002c14 <argstr>
    return -1;
    8000550e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005510:	10054263          	bltz	a0,80005614 <sys_link+0x13c>
  begin_op();
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	d2a080e7          	jalr	-726(ra) # 8000423e <begin_op>
  if((ip = namei(old)) == 0){
    8000551c:	ed040513          	addi	a0,s0,-304
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	b1e080e7          	jalr	-1250(ra) # 8000403e <namei>
    80005528:	84aa                	mv	s1,a0
    8000552a:	c551                	beqz	a0,800055b6 <sys_link+0xde>
  ilock(ip);
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	36c080e7          	jalr	876(ra) # 80003898 <ilock>
  if(ip->type == T_DIR){
    80005534:	04449703          	lh	a4,68(s1)
    80005538:	4785                	li	a5,1
    8000553a:	08f70463          	beq	a4,a5,800055c2 <sys_link+0xea>
  ip->nlink++;
    8000553e:	04a4d783          	lhu	a5,74(s1)
    80005542:	2785                	addiw	a5,a5,1
    80005544:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005548:	8526                	mv	a0,s1
    8000554a:	ffffe097          	auipc	ra,0xffffe
    8000554e:	282080e7          	jalr	642(ra) # 800037cc <iupdate>
  iunlock(ip);
    80005552:	8526                	mv	a0,s1
    80005554:	ffffe097          	auipc	ra,0xffffe
    80005558:	406080e7          	jalr	1030(ra) # 8000395a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000555c:	fd040593          	addi	a1,s0,-48
    80005560:	f5040513          	addi	a0,s0,-176
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	af8080e7          	jalr	-1288(ra) # 8000405c <nameiparent>
    8000556c:	892a                	mv	s2,a0
    8000556e:	c935                	beqz	a0,800055e2 <sys_link+0x10a>
  ilock(dp);
    80005570:	ffffe097          	auipc	ra,0xffffe
    80005574:	328080e7          	jalr	808(ra) # 80003898 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005578:	00092703          	lw	a4,0(s2)
    8000557c:	409c                	lw	a5,0(s1)
    8000557e:	04f71d63          	bne	a4,a5,800055d8 <sys_link+0x100>
    80005582:	40d0                	lw	a2,4(s1)
    80005584:	fd040593          	addi	a1,s0,-48
    80005588:	854a                	mv	a0,s2
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	a02080e7          	jalr	-1534(ra) # 80003f8c <dirlink>
    80005592:	04054363          	bltz	a0,800055d8 <sys_link+0x100>
  iunlockput(dp);
    80005596:	854a                	mv	a0,s2
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	562080e7          	jalr	1378(ra) # 80003afa <iunlockput>
  iput(ip);
    800055a0:	8526                	mv	a0,s1
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	4b0080e7          	jalr	1200(ra) # 80003a52 <iput>
  end_op();
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	d0e080e7          	jalr	-754(ra) # 800042b8 <end_op>
  return 0;
    800055b2:	4781                	li	a5,0
    800055b4:	a085                	j	80005614 <sys_link+0x13c>
    end_op();
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	d02080e7          	jalr	-766(ra) # 800042b8 <end_op>
    return -1;
    800055be:	57fd                	li	a5,-1
    800055c0:	a891                	j	80005614 <sys_link+0x13c>
    iunlockput(ip);
    800055c2:	8526                	mv	a0,s1
    800055c4:	ffffe097          	auipc	ra,0xffffe
    800055c8:	536080e7          	jalr	1334(ra) # 80003afa <iunlockput>
    end_op();
    800055cc:	fffff097          	auipc	ra,0xfffff
    800055d0:	cec080e7          	jalr	-788(ra) # 800042b8 <end_op>
    return -1;
    800055d4:	57fd                	li	a5,-1
    800055d6:	a83d                	j	80005614 <sys_link+0x13c>
    iunlockput(dp);
    800055d8:	854a                	mv	a0,s2
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	520080e7          	jalr	1312(ra) # 80003afa <iunlockput>
  ilock(ip);
    800055e2:	8526                	mv	a0,s1
    800055e4:	ffffe097          	auipc	ra,0xffffe
    800055e8:	2b4080e7          	jalr	692(ra) # 80003898 <ilock>
  ip->nlink--;
    800055ec:	04a4d783          	lhu	a5,74(s1)
    800055f0:	37fd                	addiw	a5,a5,-1
    800055f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	1d4080e7          	jalr	468(ra) # 800037cc <iupdate>
  iunlockput(ip);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	4f8080e7          	jalr	1272(ra) # 80003afa <iunlockput>
  end_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	cae080e7          	jalr	-850(ra) # 800042b8 <end_op>
  return -1;
    80005612:	57fd                	li	a5,-1
}
    80005614:	853e                	mv	a0,a5
    80005616:	70b2                	ld	ra,296(sp)
    80005618:	7412                	ld	s0,288(sp)
    8000561a:	64f2                	ld	s1,280(sp)
    8000561c:	6952                	ld	s2,272(sp)
    8000561e:	6155                	addi	sp,sp,304
    80005620:	8082                	ret

0000000080005622 <sys_unlink>:
{
    80005622:	7151                	addi	sp,sp,-240
    80005624:	f586                	sd	ra,232(sp)
    80005626:	f1a2                	sd	s0,224(sp)
    80005628:	eda6                	sd	s1,216(sp)
    8000562a:	e9ca                	sd	s2,208(sp)
    8000562c:	e5ce                	sd	s3,200(sp)
    8000562e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005630:	08000613          	li	a2,128
    80005634:	f3040593          	addi	a1,s0,-208
    80005638:	4501                	li	a0,0
    8000563a:	ffffd097          	auipc	ra,0xffffd
    8000563e:	5da080e7          	jalr	1498(ra) # 80002c14 <argstr>
    80005642:	18054163          	bltz	a0,800057c4 <sys_unlink+0x1a2>
  begin_op();
    80005646:	fffff097          	auipc	ra,0xfffff
    8000564a:	bf8080e7          	jalr	-1032(ra) # 8000423e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000564e:	fb040593          	addi	a1,s0,-80
    80005652:	f3040513          	addi	a0,s0,-208
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	a06080e7          	jalr	-1530(ra) # 8000405c <nameiparent>
    8000565e:	84aa                	mv	s1,a0
    80005660:	c979                	beqz	a0,80005736 <sys_unlink+0x114>
  ilock(dp);
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	236080e7          	jalr	566(ra) # 80003898 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000566a:	00003597          	auipc	a1,0x3
    8000566e:	0fe58593          	addi	a1,a1,254 # 80008768 <syscalls+0x300>
    80005672:	fb040513          	addi	a0,s0,-80
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	6ec080e7          	jalr	1772(ra) # 80003d62 <namecmp>
    8000567e:	14050a63          	beqz	a0,800057d2 <sys_unlink+0x1b0>
    80005682:	00003597          	auipc	a1,0x3
    80005686:	0ee58593          	addi	a1,a1,238 # 80008770 <syscalls+0x308>
    8000568a:	fb040513          	addi	a0,s0,-80
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	6d4080e7          	jalr	1748(ra) # 80003d62 <namecmp>
    80005696:	12050e63          	beqz	a0,800057d2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000569a:	f2c40613          	addi	a2,s0,-212
    8000569e:	fb040593          	addi	a1,s0,-80
    800056a2:	8526                	mv	a0,s1
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	6d8080e7          	jalr	1752(ra) # 80003d7c <dirlookup>
    800056ac:	892a                	mv	s2,a0
    800056ae:	12050263          	beqz	a0,800057d2 <sys_unlink+0x1b0>
  ilock(ip);
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	1e6080e7          	jalr	486(ra) # 80003898 <ilock>
  if(ip->nlink < 1)
    800056ba:	04a91783          	lh	a5,74(s2)
    800056be:	08f05263          	blez	a5,80005742 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056c2:	04491703          	lh	a4,68(s2)
    800056c6:	4785                	li	a5,1
    800056c8:	08f70563          	beq	a4,a5,80005752 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056cc:	4641                	li	a2,16
    800056ce:	4581                	li	a1,0
    800056d0:	fc040513          	addi	a0,s0,-64
    800056d4:	ffffb097          	auipc	ra,0xffffb
    800056d8:	610080e7          	jalr	1552(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056dc:	4741                	li	a4,16
    800056de:	f2c42683          	lw	a3,-212(s0)
    800056e2:	fc040613          	addi	a2,s0,-64
    800056e6:	4581                	li	a1,0
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	55a080e7          	jalr	1370(ra) # 80003c44 <writei>
    800056f2:	47c1                	li	a5,16
    800056f4:	0af51563          	bne	a0,a5,8000579e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056f8:	04491703          	lh	a4,68(s2)
    800056fc:	4785                	li	a5,1
    800056fe:	0af70863          	beq	a4,a5,800057ae <sys_unlink+0x18c>
  iunlockput(dp);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	3f6080e7          	jalr	1014(ra) # 80003afa <iunlockput>
  ip->nlink--;
    8000570c:	04a95783          	lhu	a5,74(s2)
    80005710:	37fd                	addiw	a5,a5,-1
    80005712:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005716:	854a                	mv	a0,s2
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	0b4080e7          	jalr	180(ra) # 800037cc <iupdate>
  iunlockput(ip);
    80005720:	854a                	mv	a0,s2
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	3d8080e7          	jalr	984(ra) # 80003afa <iunlockput>
  end_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	b8e080e7          	jalr	-1138(ra) # 800042b8 <end_op>
  return 0;
    80005732:	4501                	li	a0,0
    80005734:	a84d                	j	800057e6 <sys_unlink+0x1c4>
    end_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	b82080e7          	jalr	-1150(ra) # 800042b8 <end_op>
    return -1;
    8000573e:	557d                	li	a0,-1
    80005740:	a05d                	j	800057e6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005742:	00003517          	auipc	a0,0x3
    80005746:	03650513          	addi	a0,a0,54 # 80008778 <syscalls+0x310>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	df2080e7          	jalr	-526(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005752:	04c92703          	lw	a4,76(s2)
    80005756:	02000793          	li	a5,32
    8000575a:	f6e7f9e3          	bgeu	a5,a4,800056cc <sys_unlink+0xaa>
    8000575e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005762:	4741                	li	a4,16
    80005764:	86ce                	mv	a3,s3
    80005766:	f1840613          	addi	a2,s0,-232
    8000576a:	4581                	li	a1,0
    8000576c:	854a                	mv	a0,s2
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	3de080e7          	jalr	990(ra) # 80003b4c <readi>
    80005776:	47c1                	li	a5,16
    80005778:	00f51b63          	bne	a0,a5,8000578e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000577c:	f1845783          	lhu	a5,-232(s0)
    80005780:	e7a1                	bnez	a5,800057c8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005782:	29c1                	addiw	s3,s3,16
    80005784:	04c92783          	lw	a5,76(s2)
    80005788:	fcf9ede3          	bltu	s3,a5,80005762 <sys_unlink+0x140>
    8000578c:	b781                	j	800056cc <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000578e:	00003517          	auipc	a0,0x3
    80005792:	00250513          	addi	a0,a0,2 # 80008790 <syscalls+0x328>
    80005796:	ffffb097          	auipc	ra,0xffffb
    8000579a:	da6080e7          	jalr	-602(ra) # 8000053c <panic>
    panic("unlink: writei");
    8000579e:	00003517          	auipc	a0,0x3
    800057a2:	00a50513          	addi	a0,a0,10 # 800087a8 <syscalls+0x340>
    800057a6:	ffffb097          	auipc	ra,0xffffb
    800057aa:	d96080e7          	jalr	-618(ra) # 8000053c <panic>
    dp->nlink--;
    800057ae:	04a4d783          	lhu	a5,74(s1)
    800057b2:	37fd                	addiw	a5,a5,-1
    800057b4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	012080e7          	jalr	18(ra) # 800037cc <iupdate>
    800057c2:	b781                	j	80005702 <sys_unlink+0xe0>
    return -1;
    800057c4:	557d                	li	a0,-1
    800057c6:	a005                	j	800057e6 <sys_unlink+0x1c4>
    iunlockput(ip);
    800057c8:	854a                	mv	a0,s2
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	330080e7          	jalr	816(ra) # 80003afa <iunlockput>
  iunlockput(dp);
    800057d2:	8526                	mv	a0,s1
    800057d4:	ffffe097          	auipc	ra,0xffffe
    800057d8:	326080e7          	jalr	806(ra) # 80003afa <iunlockput>
  end_op();
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	adc080e7          	jalr	-1316(ra) # 800042b8 <end_op>
  return -1;
    800057e4:	557d                	li	a0,-1
}
    800057e6:	70ae                	ld	ra,232(sp)
    800057e8:	740e                	ld	s0,224(sp)
    800057ea:	64ee                	ld	s1,216(sp)
    800057ec:	694e                	ld	s2,208(sp)
    800057ee:	69ae                	ld	s3,200(sp)
    800057f0:	616d                	addi	sp,sp,240
    800057f2:	8082                	ret

00000000800057f4 <sys_open>:

uint64
sys_open(void)
{
    800057f4:	7131                	addi	sp,sp,-192
    800057f6:	fd06                	sd	ra,184(sp)
    800057f8:	f922                	sd	s0,176(sp)
    800057fa:	f526                	sd	s1,168(sp)
    800057fc:	f14a                	sd	s2,160(sp)
    800057fe:	ed4e                	sd	s3,152(sp)
    80005800:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005802:	f4c40593          	addi	a1,s0,-180
    80005806:	4505                	li	a0,1
    80005808:	ffffd097          	auipc	ra,0xffffd
    8000580c:	3cc080e7          	jalr	972(ra) # 80002bd4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005810:	08000613          	li	a2,128
    80005814:	f5040593          	addi	a1,s0,-176
    80005818:	4501                	li	a0,0
    8000581a:	ffffd097          	auipc	ra,0xffffd
    8000581e:	3fa080e7          	jalr	1018(ra) # 80002c14 <argstr>
    80005822:	87aa                	mv	a5,a0
    return -1;
    80005824:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005826:	0a07c863          	bltz	a5,800058d6 <sys_open+0xe2>

  begin_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	a14080e7          	jalr	-1516(ra) # 8000423e <begin_op>

  if(omode & O_CREATE){
    80005832:	f4c42783          	lw	a5,-180(s0)
    80005836:	2007f793          	andi	a5,a5,512
    8000583a:	cbdd                	beqz	a5,800058f0 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000583c:	4681                	li	a3,0
    8000583e:	4601                	li	a2,0
    80005840:	4589                	li	a1,2
    80005842:	f5040513          	addi	a0,s0,-176
    80005846:	00000097          	auipc	ra,0x0
    8000584a:	97a080e7          	jalr	-1670(ra) # 800051c0 <create>
    8000584e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005850:	c951                	beqz	a0,800058e4 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005852:	04449703          	lh	a4,68(s1)
    80005856:	478d                	li	a5,3
    80005858:	00f71763          	bne	a4,a5,80005866 <sys_open+0x72>
    8000585c:	0464d703          	lhu	a4,70(s1)
    80005860:	47a5                	li	a5,9
    80005862:	0ce7ec63          	bltu	a5,a4,8000593a <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	de0080e7          	jalr	-544(ra) # 80004646 <filealloc>
    8000586e:	892a                	mv	s2,a0
    80005870:	c56d                	beqz	a0,8000595a <sys_open+0x166>
    80005872:	00000097          	auipc	ra,0x0
    80005876:	90c080e7          	jalr	-1780(ra) # 8000517e <fdalloc>
    8000587a:	89aa                	mv	s3,a0
    8000587c:	0c054a63          	bltz	a0,80005950 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005880:	04449703          	lh	a4,68(s1)
    80005884:	478d                	li	a5,3
    80005886:	0ef70563          	beq	a4,a5,80005970 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000588a:	4789                	li	a5,2
    8000588c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005890:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005894:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005898:	f4c42783          	lw	a5,-180(s0)
    8000589c:	0017c713          	xori	a4,a5,1
    800058a0:	8b05                	andi	a4,a4,1
    800058a2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058a6:	0037f713          	andi	a4,a5,3
    800058aa:	00e03733          	snez	a4,a4
    800058ae:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058b2:	4007f793          	andi	a5,a5,1024
    800058b6:	c791                	beqz	a5,800058c2 <sys_open+0xce>
    800058b8:	04449703          	lh	a4,68(s1)
    800058bc:	4789                	li	a5,2
    800058be:	0cf70063          	beq	a4,a5,8000597e <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	096080e7          	jalr	150(ra) # 8000395a <iunlock>
  end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	9ec080e7          	jalr	-1556(ra) # 800042b8 <end_op>

  return fd;
    800058d4:	854e                	mv	a0,s3
}
    800058d6:	70ea                	ld	ra,184(sp)
    800058d8:	744a                	ld	s0,176(sp)
    800058da:	74aa                	ld	s1,168(sp)
    800058dc:	790a                	ld	s2,160(sp)
    800058de:	69ea                	ld	s3,152(sp)
    800058e0:	6129                	addi	sp,sp,192
    800058e2:	8082                	ret
      end_op();
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	9d4080e7          	jalr	-1580(ra) # 800042b8 <end_op>
      return -1;
    800058ec:	557d                	li	a0,-1
    800058ee:	b7e5                	j	800058d6 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800058f0:	f5040513          	addi	a0,s0,-176
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	74a080e7          	jalr	1866(ra) # 8000403e <namei>
    800058fc:	84aa                	mv	s1,a0
    800058fe:	c905                	beqz	a0,8000592e <sys_open+0x13a>
    ilock(ip);
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	f98080e7          	jalr	-104(ra) # 80003898 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005908:	04449703          	lh	a4,68(s1)
    8000590c:	4785                	li	a5,1
    8000590e:	f4f712e3          	bne	a4,a5,80005852 <sys_open+0x5e>
    80005912:	f4c42783          	lw	a5,-180(s0)
    80005916:	dba1                	beqz	a5,80005866 <sys_open+0x72>
      iunlockput(ip);
    80005918:	8526                	mv	a0,s1
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	1e0080e7          	jalr	480(ra) # 80003afa <iunlockput>
      end_op();
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	996080e7          	jalr	-1642(ra) # 800042b8 <end_op>
      return -1;
    8000592a:	557d                	li	a0,-1
    8000592c:	b76d                	j	800058d6 <sys_open+0xe2>
      end_op();
    8000592e:	fffff097          	auipc	ra,0xfffff
    80005932:	98a080e7          	jalr	-1654(ra) # 800042b8 <end_op>
      return -1;
    80005936:	557d                	li	a0,-1
    80005938:	bf79                	j	800058d6 <sys_open+0xe2>
    iunlockput(ip);
    8000593a:	8526                	mv	a0,s1
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	1be080e7          	jalr	446(ra) # 80003afa <iunlockput>
    end_op();
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	974080e7          	jalr	-1676(ra) # 800042b8 <end_op>
    return -1;
    8000594c:	557d                	li	a0,-1
    8000594e:	b761                	j	800058d6 <sys_open+0xe2>
      fileclose(f);
    80005950:	854a                	mv	a0,s2
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	db0080e7          	jalr	-592(ra) # 80004702 <fileclose>
    iunlockput(ip);
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	19e080e7          	jalr	414(ra) # 80003afa <iunlockput>
    end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	954080e7          	jalr	-1708(ra) # 800042b8 <end_op>
    return -1;
    8000596c:	557d                	li	a0,-1
    8000596e:	b7a5                	j	800058d6 <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005970:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005974:	04649783          	lh	a5,70(s1)
    80005978:	02f91223          	sh	a5,36(s2)
    8000597c:	bf21                	j	80005894 <sys_open+0xa0>
    itrunc(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	026080e7          	jalr	38(ra) # 800039a6 <itrunc>
    80005988:	bf2d                	j	800058c2 <sys_open+0xce>

000000008000598a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000598a:	7175                	addi	sp,sp,-144
    8000598c:	e506                	sd	ra,136(sp)
    8000598e:	e122                	sd	s0,128(sp)
    80005990:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	8ac080e7          	jalr	-1876(ra) # 8000423e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000599a:	08000613          	li	a2,128
    8000599e:	f7040593          	addi	a1,s0,-144
    800059a2:	4501                	li	a0,0
    800059a4:	ffffd097          	auipc	ra,0xffffd
    800059a8:	270080e7          	jalr	624(ra) # 80002c14 <argstr>
    800059ac:	02054963          	bltz	a0,800059de <sys_mkdir+0x54>
    800059b0:	4681                	li	a3,0
    800059b2:	4601                	li	a2,0
    800059b4:	4585                	li	a1,1
    800059b6:	f7040513          	addi	a0,s0,-144
    800059ba:	00000097          	auipc	ra,0x0
    800059be:	806080e7          	jalr	-2042(ra) # 800051c0 <create>
    800059c2:	cd11                	beqz	a0,800059de <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	136080e7          	jalr	310(ra) # 80003afa <iunlockput>
  end_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	8ec080e7          	jalr	-1812(ra) # 800042b8 <end_op>
  return 0;
    800059d4:	4501                	li	a0,0
}
    800059d6:	60aa                	ld	ra,136(sp)
    800059d8:	640a                	ld	s0,128(sp)
    800059da:	6149                	addi	sp,sp,144
    800059dc:	8082                	ret
    end_op();
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	8da080e7          	jalr	-1830(ra) # 800042b8 <end_op>
    return -1;
    800059e6:	557d                	li	a0,-1
    800059e8:	b7fd                	j	800059d6 <sys_mkdir+0x4c>

00000000800059ea <sys_mknod>:

uint64
sys_mknod(void)
{
    800059ea:	7135                	addi	sp,sp,-160
    800059ec:	ed06                	sd	ra,152(sp)
    800059ee:	e922                	sd	s0,144(sp)
    800059f0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	84c080e7          	jalr	-1972(ra) # 8000423e <begin_op>
  argint(1, &major);
    800059fa:	f6c40593          	addi	a1,s0,-148
    800059fe:	4505                	li	a0,1
    80005a00:	ffffd097          	auipc	ra,0xffffd
    80005a04:	1d4080e7          	jalr	468(ra) # 80002bd4 <argint>
  argint(2, &minor);
    80005a08:	f6840593          	addi	a1,s0,-152
    80005a0c:	4509                	li	a0,2
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	1c6080e7          	jalr	454(ra) # 80002bd4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a16:	08000613          	li	a2,128
    80005a1a:	f7040593          	addi	a1,s0,-144
    80005a1e:	4501                	li	a0,0
    80005a20:	ffffd097          	auipc	ra,0xffffd
    80005a24:	1f4080e7          	jalr	500(ra) # 80002c14 <argstr>
    80005a28:	02054b63          	bltz	a0,80005a5e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a2c:	f6841683          	lh	a3,-152(s0)
    80005a30:	f6c41603          	lh	a2,-148(s0)
    80005a34:	458d                	li	a1,3
    80005a36:	f7040513          	addi	a0,s0,-144
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	786080e7          	jalr	1926(ra) # 800051c0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a42:	cd11                	beqz	a0,80005a5e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	0b6080e7          	jalr	182(ra) # 80003afa <iunlockput>
  end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	86c080e7          	jalr	-1940(ra) # 800042b8 <end_op>
  return 0;
    80005a54:	4501                	li	a0,0
}
    80005a56:	60ea                	ld	ra,152(sp)
    80005a58:	644a                	ld	s0,144(sp)
    80005a5a:	610d                	addi	sp,sp,160
    80005a5c:	8082                	ret
    end_op();
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	85a080e7          	jalr	-1958(ra) # 800042b8 <end_op>
    return -1;
    80005a66:	557d                	li	a0,-1
    80005a68:	b7fd                	j	80005a56 <sys_mknod+0x6c>

0000000080005a6a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a6a:	7135                	addi	sp,sp,-160
    80005a6c:	ed06                	sd	ra,152(sp)
    80005a6e:	e922                	sd	s0,144(sp)
    80005a70:	e526                	sd	s1,136(sp)
    80005a72:	e14a                	sd	s2,128(sp)
    80005a74:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a76:	ffffc097          	auipc	ra,0xffffc
    80005a7a:	f46080e7          	jalr	-186(ra) # 800019bc <myproc>
    80005a7e:	892a                	mv	s2,a0
  
  begin_op();
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	7be080e7          	jalr	1982(ra) # 8000423e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a88:	08000613          	li	a2,128
    80005a8c:	f6040593          	addi	a1,s0,-160
    80005a90:	4501                	li	a0,0
    80005a92:	ffffd097          	auipc	ra,0xffffd
    80005a96:	182080e7          	jalr	386(ra) # 80002c14 <argstr>
    80005a9a:	04054b63          	bltz	a0,80005af0 <sys_chdir+0x86>
    80005a9e:	f6040513          	addi	a0,s0,-160
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	59c080e7          	jalr	1436(ra) # 8000403e <namei>
    80005aaa:	84aa                	mv	s1,a0
    80005aac:	c131                	beqz	a0,80005af0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	dea080e7          	jalr	-534(ra) # 80003898 <ilock>
  if(ip->type != T_DIR){
    80005ab6:	04449703          	lh	a4,68(s1)
    80005aba:	4785                	li	a5,1
    80005abc:	04f71063          	bne	a4,a5,80005afc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	e98080e7          	jalr	-360(ra) # 8000395a <iunlock>
  iput(p->cwd);
    80005aca:	15093503          	ld	a0,336(s2)
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	f84080e7          	jalr	-124(ra) # 80003a52 <iput>
  end_op();
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	7e2080e7          	jalr	2018(ra) # 800042b8 <end_op>
  p->cwd = ip;
    80005ade:	14993823          	sd	s1,336(s2)
  return 0;
    80005ae2:	4501                	li	a0,0
}
    80005ae4:	60ea                	ld	ra,152(sp)
    80005ae6:	644a                	ld	s0,144(sp)
    80005ae8:	64aa                	ld	s1,136(sp)
    80005aea:	690a                	ld	s2,128(sp)
    80005aec:	610d                	addi	sp,sp,160
    80005aee:	8082                	ret
    end_op();
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	7c8080e7          	jalr	1992(ra) # 800042b8 <end_op>
    return -1;
    80005af8:	557d                	li	a0,-1
    80005afa:	b7ed                	j	80005ae4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005afc:	8526                	mv	a0,s1
    80005afe:	ffffe097          	auipc	ra,0xffffe
    80005b02:	ffc080e7          	jalr	-4(ra) # 80003afa <iunlockput>
    end_op();
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	7b2080e7          	jalr	1970(ra) # 800042b8 <end_op>
    return -1;
    80005b0e:	557d                	li	a0,-1
    80005b10:	bfd1                	j	80005ae4 <sys_chdir+0x7a>

0000000080005b12 <sys_exec>:

uint64
sys_exec(void)
{
    80005b12:	7121                	addi	sp,sp,-448
    80005b14:	ff06                	sd	ra,440(sp)
    80005b16:	fb22                	sd	s0,432(sp)
    80005b18:	f726                	sd	s1,424(sp)
    80005b1a:	f34a                	sd	s2,416(sp)
    80005b1c:	ef4e                	sd	s3,408(sp)
    80005b1e:	eb52                	sd	s4,400(sp)
    80005b20:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b22:	e4840593          	addi	a1,s0,-440
    80005b26:	4505                	li	a0,1
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	0cc080e7          	jalr	204(ra) # 80002bf4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b30:	08000613          	li	a2,128
    80005b34:	f5040593          	addi	a1,s0,-176
    80005b38:	4501                	li	a0,0
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	0da080e7          	jalr	218(ra) # 80002c14 <argstr>
    80005b42:	87aa                	mv	a5,a0
    return -1;
    80005b44:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b46:	0c07c263          	bltz	a5,80005c0a <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005b4a:	10000613          	li	a2,256
    80005b4e:	4581                	li	a1,0
    80005b50:	e5040513          	addi	a0,s0,-432
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	190080e7          	jalr	400(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b5c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b60:	89a6                	mv	s3,s1
    80005b62:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b64:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b68:	00391513          	slli	a0,s2,0x3
    80005b6c:	e4040593          	addi	a1,s0,-448
    80005b70:	e4843783          	ld	a5,-440(s0)
    80005b74:	953e                	add	a0,a0,a5
    80005b76:	ffffd097          	auipc	ra,0xffffd
    80005b7a:	fc0080e7          	jalr	-64(ra) # 80002b36 <fetchaddr>
    80005b7e:	02054a63          	bltz	a0,80005bb2 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b82:	e4043783          	ld	a5,-448(s0)
    80005b86:	c3b9                	beqz	a5,80005bcc <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b88:	ffffb097          	auipc	ra,0xffffb
    80005b8c:	f5a080e7          	jalr	-166(ra) # 80000ae2 <kalloc>
    80005b90:	85aa                	mv	a1,a0
    80005b92:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b96:	cd11                	beqz	a0,80005bb2 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b98:	6605                	lui	a2,0x1
    80005b9a:	e4043503          	ld	a0,-448(s0)
    80005b9e:	ffffd097          	auipc	ra,0xffffd
    80005ba2:	fea080e7          	jalr	-22(ra) # 80002b88 <fetchstr>
    80005ba6:	00054663          	bltz	a0,80005bb2 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005baa:	0905                	addi	s2,s2,1
    80005bac:	09a1                	addi	s3,s3,8
    80005bae:	fb491de3          	bne	s2,s4,80005b68 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb2:	f5040913          	addi	s2,s0,-176
    80005bb6:	6088                	ld	a0,0(s1)
    80005bb8:	c921                	beqz	a0,80005c08 <sys_exec+0xf6>
    kfree(argv[i]);
    80005bba:	ffffb097          	auipc	ra,0xffffb
    80005bbe:	e2a080e7          	jalr	-470(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc2:	04a1                	addi	s1,s1,8
    80005bc4:	ff2499e3          	bne	s1,s2,80005bb6 <sys_exec+0xa4>
  return -1;
    80005bc8:	557d                	li	a0,-1
    80005bca:	a081                	j	80005c0a <sys_exec+0xf8>
      argv[i] = 0;
    80005bcc:	0009079b          	sext.w	a5,s2
    80005bd0:	078e                	slli	a5,a5,0x3
    80005bd2:	fd078793          	addi	a5,a5,-48
    80005bd6:	97a2                	add	a5,a5,s0
    80005bd8:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005bdc:	e5040593          	addi	a1,s0,-432
    80005be0:	f5040513          	addi	a0,s0,-176
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	194080e7          	jalr	404(ra) # 80004d78 <exec>
    80005bec:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bee:	f5040993          	addi	s3,s0,-176
    80005bf2:	6088                	ld	a0,0(s1)
    80005bf4:	c901                	beqz	a0,80005c04 <sys_exec+0xf2>
    kfree(argv[i]);
    80005bf6:	ffffb097          	auipc	ra,0xffffb
    80005bfa:	dee080e7          	jalr	-530(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bfe:	04a1                	addi	s1,s1,8
    80005c00:	ff3499e3          	bne	s1,s3,80005bf2 <sys_exec+0xe0>
  return ret;
    80005c04:	854a                	mv	a0,s2
    80005c06:	a011                	j	80005c0a <sys_exec+0xf8>
  return -1;
    80005c08:	557d                	li	a0,-1
}
    80005c0a:	70fa                	ld	ra,440(sp)
    80005c0c:	745a                	ld	s0,432(sp)
    80005c0e:	74ba                	ld	s1,424(sp)
    80005c10:	791a                	ld	s2,416(sp)
    80005c12:	69fa                	ld	s3,408(sp)
    80005c14:	6a5a                	ld	s4,400(sp)
    80005c16:	6139                	addi	sp,sp,448
    80005c18:	8082                	ret

0000000080005c1a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c1a:	7139                	addi	sp,sp,-64
    80005c1c:	fc06                	sd	ra,56(sp)
    80005c1e:	f822                	sd	s0,48(sp)
    80005c20:	f426                	sd	s1,40(sp)
    80005c22:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c24:	ffffc097          	auipc	ra,0xffffc
    80005c28:	d98080e7          	jalr	-616(ra) # 800019bc <myproc>
    80005c2c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c2e:	fd840593          	addi	a1,s0,-40
    80005c32:	4501                	li	a0,0
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	fc0080e7          	jalr	-64(ra) # 80002bf4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c3c:	fc840593          	addi	a1,s0,-56
    80005c40:	fd040513          	addi	a0,s0,-48
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	dea080e7          	jalr	-534(ra) # 80004a2e <pipealloc>
    return -1;
    80005c4c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c4e:	0c054463          	bltz	a0,80005d16 <sys_pipe+0xfc>
  fd0 = -1;
    80005c52:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c56:	fd043503          	ld	a0,-48(s0)
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	524080e7          	jalr	1316(ra) # 8000517e <fdalloc>
    80005c62:	fca42223          	sw	a0,-60(s0)
    80005c66:	08054b63          	bltz	a0,80005cfc <sys_pipe+0xe2>
    80005c6a:	fc843503          	ld	a0,-56(s0)
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	510080e7          	jalr	1296(ra) # 8000517e <fdalloc>
    80005c76:	fca42023          	sw	a0,-64(s0)
    80005c7a:	06054863          	bltz	a0,80005cea <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c7e:	4691                	li	a3,4
    80005c80:	fc440613          	addi	a2,s0,-60
    80005c84:	fd843583          	ld	a1,-40(s0)
    80005c88:	68a8                	ld	a0,80(s1)
    80005c8a:	ffffc097          	auipc	ra,0xffffc
    80005c8e:	9f2080e7          	jalr	-1550(ra) # 8000167c <copyout>
    80005c92:	02054063          	bltz	a0,80005cb2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c96:	4691                	li	a3,4
    80005c98:	fc040613          	addi	a2,s0,-64
    80005c9c:	fd843583          	ld	a1,-40(s0)
    80005ca0:	0591                	addi	a1,a1,4
    80005ca2:	68a8                	ld	a0,80(s1)
    80005ca4:	ffffc097          	auipc	ra,0xffffc
    80005ca8:	9d8080e7          	jalr	-1576(ra) # 8000167c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cac:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cae:	06055463          	bgez	a0,80005d16 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005cb2:	fc442783          	lw	a5,-60(s0)
    80005cb6:	07e9                	addi	a5,a5,26
    80005cb8:	078e                	slli	a5,a5,0x3
    80005cba:	97a6                	add	a5,a5,s1
    80005cbc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005cc0:	fc042783          	lw	a5,-64(s0)
    80005cc4:	07e9                	addi	a5,a5,26
    80005cc6:	078e                	slli	a5,a5,0x3
    80005cc8:	94be                	add	s1,s1,a5
    80005cca:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005cce:	fd043503          	ld	a0,-48(s0)
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	a30080e7          	jalr	-1488(ra) # 80004702 <fileclose>
    fileclose(wf);
    80005cda:	fc843503          	ld	a0,-56(s0)
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	a24080e7          	jalr	-1500(ra) # 80004702 <fileclose>
    return -1;
    80005ce6:	57fd                	li	a5,-1
    80005ce8:	a03d                	j	80005d16 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005cea:	fc442783          	lw	a5,-60(s0)
    80005cee:	0007c763          	bltz	a5,80005cfc <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005cf2:	07e9                	addi	a5,a5,26
    80005cf4:	078e                	slli	a5,a5,0x3
    80005cf6:	97a6                	add	a5,a5,s1
    80005cf8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cfc:	fd043503          	ld	a0,-48(s0)
    80005d00:	fffff097          	auipc	ra,0xfffff
    80005d04:	a02080e7          	jalr	-1534(ra) # 80004702 <fileclose>
    fileclose(wf);
    80005d08:	fc843503          	ld	a0,-56(s0)
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	9f6080e7          	jalr	-1546(ra) # 80004702 <fileclose>
    return -1;
    80005d14:	57fd                	li	a5,-1
}
    80005d16:	853e                	mv	a0,a5
    80005d18:	70e2                	ld	ra,56(sp)
    80005d1a:	7442                	ld	s0,48(sp)
    80005d1c:	74a2                	ld	s1,40(sp)
    80005d1e:	6121                	addi	sp,sp,64
    80005d20:	8082                	ret
	...

0000000080005d30 <kernelvec>:
    80005d30:	7111                	addi	sp,sp,-256
    80005d32:	e006                	sd	ra,0(sp)
    80005d34:	e40a                	sd	sp,8(sp)
    80005d36:	e80e                	sd	gp,16(sp)
    80005d38:	ec12                	sd	tp,24(sp)
    80005d3a:	f016                	sd	t0,32(sp)
    80005d3c:	f41a                	sd	t1,40(sp)
    80005d3e:	f81e                	sd	t2,48(sp)
    80005d40:	fc22                	sd	s0,56(sp)
    80005d42:	e0a6                	sd	s1,64(sp)
    80005d44:	e4aa                	sd	a0,72(sp)
    80005d46:	e8ae                	sd	a1,80(sp)
    80005d48:	ecb2                	sd	a2,88(sp)
    80005d4a:	f0b6                	sd	a3,96(sp)
    80005d4c:	f4ba                	sd	a4,104(sp)
    80005d4e:	f8be                	sd	a5,112(sp)
    80005d50:	fcc2                	sd	a6,120(sp)
    80005d52:	e146                	sd	a7,128(sp)
    80005d54:	e54a                	sd	s2,136(sp)
    80005d56:	e94e                	sd	s3,144(sp)
    80005d58:	ed52                	sd	s4,152(sp)
    80005d5a:	f156                	sd	s5,160(sp)
    80005d5c:	f55a                	sd	s6,168(sp)
    80005d5e:	f95e                	sd	s7,176(sp)
    80005d60:	fd62                	sd	s8,184(sp)
    80005d62:	e1e6                	sd	s9,192(sp)
    80005d64:	e5ea                	sd	s10,200(sp)
    80005d66:	e9ee                	sd	s11,208(sp)
    80005d68:	edf2                	sd	t3,216(sp)
    80005d6a:	f1f6                	sd	t4,224(sp)
    80005d6c:	f5fa                	sd	t5,232(sp)
    80005d6e:	f9fe                	sd	t6,240(sp)
    80005d70:	c93fc0ef          	jal	ra,80002a02 <kerneltrap>
    80005d74:	6082                	ld	ra,0(sp)
    80005d76:	6122                	ld	sp,8(sp)
    80005d78:	61c2                	ld	gp,16(sp)
    80005d7a:	7282                	ld	t0,32(sp)
    80005d7c:	7322                	ld	t1,40(sp)
    80005d7e:	73c2                	ld	t2,48(sp)
    80005d80:	7462                	ld	s0,56(sp)
    80005d82:	6486                	ld	s1,64(sp)
    80005d84:	6526                	ld	a0,72(sp)
    80005d86:	65c6                	ld	a1,80(sp)
    80005d88:	6666                	ld	a2,88(sp)
    80005d8a:	7686                	ld	a3,96(sp)
    80005d8c:	7726                	ld	a4,104(sp)
    80005d8e:	77c6                	ld	a5,112(sp)
    80005d90:	7866                	ld	a6,120(sp)
    80005d92:	688a                	ld	a7,128(sp)
    80005d94:	692a                	ld	s2,136(sp)
    80005d96:	69ca                	ld	s3,144(sp)
    80005d98:	6a6a                	ld	s4,152(sp)
    80005d9a:	7a8a                	ld	s5,160(sp)
    80005d9c:	7b2a                	ld	s6,168(sp)
    80005d9e:	7bca                	ld	s7,176(sp)
    80005da0:	7c6a                	ld	s8,184(sp)
    80005da2:	6c8e                	ld	s9,192(sp)
    80005da4:	6d2e                	ld	s10,200(sp)
    80005da6:	6dce                	ld	s11,208(sp)
    80005da8:	6e6e                	ld	t3,216(sp)
    80005daa:	7e8e                	ld	t4,224(sp)
    80005dac:	7f2e                	ld	t5,232(sp)
    80005dae:	7fce                	ld	t6,240(sp)
    80005db0:	6111                	addi	sp,sp,256
    80005db2:	10200073          	sret
    80005db6:	00000013          	nop
    80005dba:	00000013          	nop
    80005dbe:	0001                	nop

0000000080005dc0 <timervec>:
    80005dc0:	34051573          	csrrw	a0,mscratch,a0
    80005dc4:	e10c                	sd	a1,0(a0)
    80005dc6:	e510                	sd	a2,8(a0)
    80005dc8:	e914                	sd	a3,16(a0)
    80005dca:	6d0c                	ld	a1,24(a0)
    80005dcc:	7110                	ld	a2,32(a0)
    80005dce:	6194                	ld	a3,0(a1)
    80005dd0:	96b2                	add	a3,a3,a2
    80005dd2:	e194                	sd	a3,0(a1)
    80005dd4:	4589                	li	a1,2
    80005dd6:	14459073          	csrw	sip,a1
    80005dda:	6914                	ld	a3,16(a0)
    80005ddc:	6510                	ld	a2,8(a0)
    80005dde:	610c                	ld	a1,0(a0)
    80005de0:	34051573          	csrrw	a0,mscratch,a0
    80005de4:	30200073          	mret
	...

0000000080005dea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dea:	1141                	addi	sp,sp,-16
    80005dec:	e422                	sd	s0,8(sp)
    80005dee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005df0:	0c0007b7          	lui	a5,0xc000
    80005df4:	4705                	li	a4,1
    80005df6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005df8:	c3d8                	sw	a4,4(a5)
}
    80005dfa:	6422                	ld	s0,8(sp)
    80005dfc:	0141                	addi	sp,sp,16
    80005dfe:	8082                	ret

0000000080005e00 <plicinithart>:

void
plicinithart(void)
{
    80005e00:	1141                	addi	sp,sp,-16
    80005e02:	e406                	sd	ra,8(sp)
    80005e04:	e022                	sd	s0,0(sp)
    80005e06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	b88080e7          	jalr	-1144(ra) # 80001990 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e10:	0085171b          	slliw	a4,a0,0x8
    80005e14:	0c0027b7          	lui	a5,0xc002
    80005e18:	97ba                	add	a5,a5,a4
    80005e1a:	40200713          	li	a4,1026
    80005e1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e22:	00d5151b          	slliw	a0,a0,0xd
    80005e26:	0c2017b7          	lui	a5,0xc201
    80005e2a:	97aa                	add	a5,a5,a0
    80005e2c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e30:	60a2                	ld	ra,8(sp)
    80005e32:	6402                	ld	s0,0(sp)
    80005e34:	0141                	addi	sp,sp,16
    80005e36:	8082                	ret

0000000080005e38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e38:	1141                	addi	sp,sp,-16
    80005e3a:	e406                	sd	ra,8(sp)
    80005e3c:	e022                	sd	s0,0(sp)
    80005e3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	b50080e7          	jalr	-1200(ra) # 80001990 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e48:	00d5151b          	slliw	a0,a0,0xd
    80005e4c:	0c2017b7          	lui	a5,0xc201
    80005e50:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e52:	43c8                	lw	a0,4(a5)
    80005e54:	60a2                	ld	ra,8(sp)
    80005e56:	6402                	ld	s0,0(sp)
    80005e58:	0141                	addi	sp,sp,16
    80005e5a:	8082                	ret

0000000080005e5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e5c:	1101                	addi	sp,sp,-32
    80005e5e:	ec06                	sd	ra,24(sp)
    80005e60:	e822                	sd	s0,16(sp)
    80005e62:	e426                	sd	s1,8(sp)
    80005e64:	1000                	addi	s0,sp,32
    80005e66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	b28080e7          	jalr	-1240(ra) # 80001990 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e70:	00d5151b          	slliw	a0,a0,0xd
    80005e74:	0c2017b7          	lui	a5,0xc201
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	c3c4                	sw	s1,4(a5)
}
    80005e7c:	60e2                	ld	ra,24(sp)
    80005e7e:	6442                	ld	s0,16(sp)
    80005e80:	64a2                	ld	s1,8(sp)
    80005e82:	6105                	addi	sp,sp,32
    80005e84:	8082                	ret

0000000080005e86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e86:	1141                	addi	sp,sp,-16
    80005e88:	e406                	sd	ra,8(sp)
    80005e8a:	e022                	sd	s0,0(sp)
    80005e8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e8e:	479d                	li	a5,7
    80005e90:	04a7cc63          	blt	a5,a0,80005ee8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e94:	0001c797          	auipc	a5,0x1c
    80005e98:	e0c78793          	addi	a5,a5,-500 # 80021ca0 <disk>
    80005e9c:	97aa                	add	a5,a5,a0
    80005e9e:	0187c783          	lbu	a5,24(a5)
    80005ea2:	ebb9                	bnez	a5,80005ef8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ea4:	00451693          	slli	a3,a0,0x4
    80005ea8:	0001c797          	auipc	a5,0x1c
    80005eac:	df878793          	addi	a5,a5,-520 # 80021ca0 <disk>
    80005eb0:	6398                	ld	a4,0(a5)
    80005eb2:	9736                	add	a4,a4,a3
    80005eb4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005eb8:	6398                	ld	a4,0(a5)
    80005eba:	9736                	add	a4,a4,a3
    80005ebc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ec0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ec4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ec8:	97aa                	add	a5,a5,a0
    80005eca:	4705                	li	a4,1
    80005ecc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005ed0:	0001c517          	auipc	a0,0x1c
    80005ed4:	de850513          	addi	a0,a0,-536 # 80021cb8 <disk+0x18>
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	2ee080e7          	jalr	750(ra) # 800021c6 <wakeup>
}
    80005ee0:	60a2                	ld	ra,8(sp)
    80005ee2:	6402                	ld	s0,0(sp)
    80005ee4:	0141                	addi	sp,sp,16
    80005ee6:	8082                	ret
    panic("free_desc 1");
    80005ee8:	00003517          	auipc	a0,0x3
    80005eec:	8d050513          	addi	a0,a0,-1840 # 800087b8 <syscalls+0x350>
    80005ef0:	ffffa097          	auipc	ra,0xffffa
    80005ef4:	64c080e7          	jalr	1612(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005ef8:	00003517          	auipc	a0,0x3
    80005efc:	8d050513          	addi	a0,a0,-1840 # 800087c8 <syscalls+0x360>
    80005f00:	ffffa097          	auipc	ra,0xffffa
    80005f04:	63c080e7          	jalr	1596(ra) # 8000053c <panic>

0000000080005f08 <virtio_disk_init>:
{
    80005f08:	1101                	addi	sp,sp,-32
    80005f0a:	ec06                	sd	ra,24(sp)
    80005f0c:	e822                	sd	s0,16(sp)
    80005f0e:	e426                	sd	s1,8(sp)
    80005f10:	e04a                	sd	s2,0(sp)
    80005f12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f14:	00003597          	auipc	a1,0x3
    80005f18:	8c458593          	addi	a1,a1,-1852 # 800087d8 <syscalls+0x370>
    80005f1c:	0001c517          	auipc	a0,0x1c
    80005f20:	eac50513          	addi	a0,a0,-340 # 80021dc8 <disk+0x128>
    80005f24:	ffffb097          	auipc	ra,0xffffb
    80005f28:	c1e080e7          	jalr	-994(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f2c:	100017b7          	lui	a5,0x10001
    80005f30:	4398                	lw	a4,0(a5)
    80005f32:	2701                	sext.w	a4,a4
    80005f34:	747277b7          	lui	a5,0x74727
    80005f38:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f3c:	14f71b63          	bne	a4,a5,80006092 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f40:	100017b7          	lui	a5,0x10001
    80005f44:	43dc                	lw	a5,4(a5)
    80005f46:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f48:	4709                	li	a4,2
    80005f4a:	14e79463          	bne	a5,a4,80006092 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f4e:	100017b7          	lui	a5,0x10001
    80005f52:	479c                	lw	a5,8(a5)
    80005f54:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f56:	12e79e63          	bne	a5,a4,80006092 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f5a:	100017b7          	lui	a5,0x10001
    80005f5e:	47d8                	lw	a4,12(a5)
    80005f60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f62:	554d47b7          	lui	a5,0x554d4
    80005f66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f6a:	12f71463          	bne	a4,a5,80006092 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6e:	100017b7          	lui	a5,0x10001
    80005f72:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f76:	4705                	li	a4,1
    80005f78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f7a:	470d                	li	a4,3
    80005f7c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f7e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f80:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f84:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc97f>
    80005f88:	8f75                	and	a4,a4,a3
    80005f8a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f8c:	472d                	li	a4,11
    80005f8e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f90:	5bbc                	lw	a5,112(a5)
    80005f92:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f96:	8ba1                	andi	a5,a5,8
    80005f98:	10078563          	beqz	a5,800060a2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f9c:	100017b7          	lui	a5,0x10001
    80005fa0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005fa4:	43fc                	lw	a5,68(a5)
    80005fa6:	2781                	sext.w	a5,a5
    80005fa8:	10079563          	bnez	a5,800060b2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fac:	100017b7          	lui	a5,0x10001
    80005fb0:	5bdc                	lw	a5,52(a5)
    80005fb2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fb4:	10078763          	beqz	a5,800060c2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005fb8:	471d                	li	a4,7
    80005fba:	10f77c63          	bgeu	a4,a5,800060d2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005fbe:	ffffb097          	auipc	ra,0xffffb
    80005fc2:	b24080e7          	jalr	-1244(ra) # 80000ae2 <kalloc>
    80005fc6:	0001c497          	auipc	s1,0x1c
    80005fca:	cda48493          	addi	s1,s1,-806 # 80021ca0 <disk>
    80005fce:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fd0:	ffffb097          	auipc	ra,0xffffb
    80005fd4:	b12080e7          	jalr	-1262(ra) # 80000ae2 <kalloc>
    80005fd8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fda:	ffffb097          	auipc	ra,0xffffb
    80005fde:	b08080e7          	jalr	-1272(ra) # 80000ae2 <kalloc>
    80005fe2:	87aa                	mv	a5,a0
    80005fe4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fe6:	6088                	ld	a0,0(s1)
    80005fe8:	cd6d                	beqz	a0,800060e2 <virtio_disk_init+0x1da>
    80005fea:	0001c717          	auipc	a4,0x1c
    80005fee:	cbe73703          	ld	a4,-834(a4) # 80021ca8 <disk+0x8>
    80005ff2:	cb65                	beqz	a4,800060e2 <virtio_disk_init+0x1da>
    80005ff4:	c7fd                	beqz	a5,800060e2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ff6:	6605                	lui	a2,0x1
    80005ff8:	4581                	li	a1,0
    80005ffa:	ffffb097          	auipc	ra,0xffffb
    80005ffe:	cea080e7          	jalr	-790(ra) # 80000ce4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006002:	0001c497          	auipc	s1,0x1c
    80006006:	c9e48493          	addi	s1,s1,-866 # 80021ca0 <disk>
    8000600a:	6605                	lui	a2,0x1
    8000600c:	4581                	li	a1,0
    8000600e:	6488                	ld	a0,8(s1)
    80006010:	ffffb097          	auipc	ra,0xffffb
    80006014:	cd4080e7          	jalr	-812(ra) # 80000ce4 <memset>
  memset(disk.used, 0, PGSIZE);
    80006018:	6605                	lui	a2,0x1
    8000601a:	4581                	li	a1,0
    8000601c:	6888                	ld	a0,16(s1)
    8000601e:	ffffb097          	auipc	ra,0xffffb
    80006022:	cc6080e7          	jalr	-826(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006026:	100017b7          	lui	a5,0x10001
    8000602a:	4721                	li	a4,8
    8000602c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000602e:	4098                	lw	a4,0(s1)
    80006030:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006034:	40d8                	lw	a4,4(s1)
    80006036:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000603a:	6498                	ld	a4,8(s1)
    8000603c:	0007069b          	sext.w	a3,a4
    80006040:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006044:	9701                	srai	a4,a4,0x20
    80006046:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000604a:	6898                	ld	a4,16(s1)
    8000604c:	0007069b          	sext.w	a3,a4
    80006050:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006054:	9701                	srai	a4,a4,0x20
    80006056:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000605a:	4705                	li	a4,1
    8000605c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000605e:	00e48c23          	sb	a4,24(s1)
    80006062:	00e48ca3          	sb	a4,25(s1)
    80006066:	00e48d23          	sb	a4,26(s1)
    8000606a:	00e48da3          	sb	a4,27(s1)
    8000606e:	00e48e23          	sb	a4,28(s1)
    80006072:	00e48ea3          	sb	a4,29(s1)
    80006076:	00e48f23          	sb	a4,30(s1)
    8000607a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000607e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006082:	0727a823          	sw	s2,112(a5)
}
    80006086:	60e2                	ld	ra,24(sp)
    80006088:	6442                	ld	s0,16(sp)
    8000608a:	64a2                	ld	s1,8(sp)
    8000608c:	6902                	ld	s2,0(sp)
    8000608e:	6105                	addi	sp,sp,32
    80006090:	8082                	ret
    panic("could not find virtio disk");
    80006092:	00002517          	auipc	a0,0x2
    80006096:	75650513          	addi	a0,a0,1878 # 800087e8 <syscalls+0x380>
    8000609a:	ffffa097          	auipc	ra,0xffffa
    8000609e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    800060a2:	00002517          	auipc	a0,0x2
    800060a6:	76650513          	addi	a0,a0,1894 # 80008808 <syscalls+0x3a0>
    800060aa:	ffffa097          	auipc	ra,0xffffa
    800060ae:	492080e7          	jalr	1170(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800060b2:	00002517          	auipc	a0,0x2
    800060b6:	77650513          	addi	a0,a0,1910 # 80008828 <syscalls+0x3c0>
    800060ba:	ffffa097          	auipc	ra,0xffffa
    800060be:	482080e7          	jalr	1154(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800060c2:	00002517          	auipc	a0,0x2
    800060c6:	78650513          	addi	a0,a0,1926 # 80008848 <syscalls+0x3e0>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	472080e7          	jalr	1138(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800060d2:	00002517          	auipc	a0,0x2
    800060d6:	79650513          	addi	a0,a0,1942 # 80008868 <syscalls+0x400>
    800060da:	ffffa097          	auipc	ra,0xffffa
    800060de:	462080e7          	jalr	1122(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800060e2:	00002517          	auipc	a0,0x2
    800060e6:	7a650513          	addi	a0,a0,1958 # 80008888 <syscalls+0x420>
    800060ea:	ffffa097          	auipc	ra,0xffffa
    800060ee:	452080e7          	jalr	1106(ra) # 8000053c <panic>

00000000800060f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060f2:	7159                	addi	sp,sp,-112
    800060f4:	f486                	sd	ra,104(sp)
    800060f6:	f0a2                	sd	s0,96(sp)
    800060f8:	eca6                	sd	s1,88(sp)
    800060fa:	e8ca                	sd	s2,80(sp)
    800060fc:	e4ce                	sd	s3,72(sp)
    800060fe:	e0d2                	sd	s4,64(sp)
    80006100:	fc56                	sd	s5,56(sp)
    80006102:	f85a                	sd	s6,48(sp)
    80006104:	f45e                	sd	s7,40(sp)
    80006106:	f062                	sd	s8,32(sp)
    80006108:	ec66                	sd	s9,24(sp)
    8000610a:	e86a                	sd	s10,16(sp)
    8000610c:	1880                	addi	s0,sp,112
    8000610e:	8a2a                	mv	s4,a0
    80006110:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006112:	00c52c83          	lw	s9,12(a0)
    80006116:	001c9c9b          	slliw	s9,s9,0x1
    8000611a:	1c82                	slli	s9,s9,0x20
    8000611c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006120:	0001c517          	auipc	a0,0x1c
    80006124:	ca850513          	addi	a0,a0,-856 # 80021dc8 <disk+0x128>
    80006128:	ffffb097          	auipc	ra,0xffffb
    8000612c:	aaa080e7          	jalr	-1366(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006130:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006132:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006134:	0001cb17          	auipc	s6,0x1c
    80006138:	b6cb0b13          	addi	s6,s6,-1172 # 80021ca0 <disk>
  for(int i = 0; i < 3; i++){
    8000613c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000613e:	0001cc17          	auipc	s8,0x1c
    80006142:	c8ac0c13          	addi	s8,s8,-886 # 80021dc8 <disk+0x128>
    80006146:	a095                	j	800061aa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006148:	00fb0733          	add	a4,s6,a5
    8000614c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006150:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006152:	0207c563          	bltz	a5,8000617c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006156:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006158:	0591                	addi	a1,a1,4
    8000615a:	05560d63          	beq	a2,s5,800061b4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000615e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006160:	0001c717          	auipc	a4,0x1c
    80006164:	b4070713          	addi	a4,a4,-1216 # 80021ca0 <disk>
    80006168:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000616a:	01874683          	lbu	a3,24(a4)
    8000616e:	fee9                	bnez	a3,80006148 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006170:	2785                	addiw	a5,a5,1
    80006172:	0705                	addi	a4,a4,1
    80006174:	fe979be3          	bne	a5,s1,8000616a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006178:	57fd                	li	a5,-1
    8000617a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000617c:	00c05e63          	blez	a2,80006198 <virtio_disk_rw+0xa6>
    80006180:	060a                	slli	a2,a2,0x2
    80006182:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006186:	0009a503          	lw	a0,0(s3)
    8000618a:	00000097          	auipc	ra,0x0
    8000618e:	cfc080e7          	jalr	-772(ra) # 80005e86 <free_desc>
      for(int j = 0; j < i; j++)
    80006192:	0991                	addi	s3,s3,4
    80006194:	ffa999e3          	bne	s3,s10,80006186 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006198:	85e2                	mv	a1,s8
    8000619a:	0001c517          	auipc	a0,0x1c
    8000619e:	b1e50513          	addi	a0,a0,-1250 # 80021cb8 <disk+0x18>
    800061a2:	ffffc097          	auipc	ra,0xffffc
    800061a6:	fc0080e7          	jalr	-64(ra) # 80002162 <sleep>
  for(int i = 0; i < 3; i++){
    800061aa:	f9040993          	addi	s3,s0,-112
{
    800061ae:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800061b0:	864a                	mv	a2,s2
    800061b2:	b775                	j	8000615e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061b4:	f9042503          	lw	a0,-112(s0)
    800061b8:	00a50713          	addi	a4,a0,10
    800061bc:	0712                	slli	a4,a4,0x4

  if(write)
    800061be:	0001c797          	auipc	a5,0x1c
    800061c2:	ae278793          	addi	a5,a5,-1310 # 80021ca0 <disk>
    800061c6:	00e786b3          	add	a3,a5,a4
    800061ca:	01703633          	snez	a2,s7
    800061ce:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061d0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800061d4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061d8:	f6070613          	addi	a2,a4,-160
    800061dc:	6394                	ld	a3,0(a5)
    800061de:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061e0:	00870593          	addi	a1,a4,8
    800061e4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061e6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061e8:	0007b803          	ld	a6,0(a5)
    800061ec:	9642                	add	a2,a2,a6
    800061ee:	46c1                	li	a3,16
    800061f0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061f2:	4585                	li	a1,1
    800061f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800061f8:	f9442683          	lw	a3,-108(s0)
    800061fc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006200:	0692                	slli	a3,a3,0x4
    80006202:	9836                	add	a6,a6,a3
    80006204:	058a0613          	addi	a2,s4,88
    80006208:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000620c:	0007b803          	ld	a6,0(a5)
    80006210:	96c2                	add	a3,a3,a6
    80006212:	40000613          	li	a2,1024
    80006216:	c690                	sw	a2,8(a3)
  if(write)
    80006218:	001bb613          	seqz	a2,s7
    8000621c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006220:	00166613          	ori	a2,a2,1
    80006224:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006228:	f9842603          	lw	a2,-104(s0)
    8000622c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006230:	00250693          	addi	a3,a0,2
    80006234:	0692                	slli	a3,a3,0x4
    80006236:	96be                	add	a3,a3,a5
    80006238:	58fd                	li	a7,-1
    8000623a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000623e:	0612                	slli	a2,a2,0x4
    80006240:	9832                	add	a6,a6,a2
    80006242:	f9070713          	addi	a4,a4,-112
    80006246:	973e                	add	a4,a4,a5
    80006248:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000624c:	6398                	ld	a4,0(a5)
    8000624e:	9732                	add	a4,a4,a2
    80006250:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006252:	4609                	li	a2,2
    80006254:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006258:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000625c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006260:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006264:	6794                	ld	a3,8(a5)
    80006266:	0026d703          	lhu	a4,2(a3)
    8000626a:	8b1d                	andi	a4,a4,7
    8000626c:	0706                	slli	a4,a4,0x1
    8000626e:	96ba                	add	a3,a3,a4
    80006270:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006274:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006278:	6798                	ld	a4,8(a5)
    8000627a:	00275783          	lhu	a5,2(a4)
    8000627e:	2785                	addiw	a5,a5,1
    80006280:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006284:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006288:	100017b7          	lui	a5,0x10001
    8000628c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006290:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006294:	0001c917          	auipc	s2,0x1c
    80006298:	b3490913          	addi	s2,s2,-1228 # 80021dc8 <disk+0x128>
  while(b->disk == 1) {
    8000629c:	4485                	li	s1,1
    8000629e:	00b79c63          	bne	a5,a1,800062b6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800062a2:	85ca                	mv	a1,s2
    800062a4:	8552                	mv	a0,s4
    800062a6:	ffffc097          	auipc	ra,0xffffc
    800062aa:	ebc080e7          	jalr	-324(ra) # 80002162 <sleep>
  while(b->disk == 1) {
    800062ae:	004a2783          	lw	a5,4(s4)
    800062b2:	fe9788e3          	beq	a5,s1,800062a2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800062b6:	f9042903          	lw	s2,-112(s0)
    800062ba:	00290713          	addi	a4,s2,2
    800062be:	0712                	slli	a4,a4,0x4
    800062c0:	0001c797          	auipc	a5,0x1c
    800062c4:	9e078793          	addi	a5,a5,-1568 # 80021ca0 <disk>
    800062c8:	97ba                	add	a5,a5,a4
    800062ca:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800062ce:	0001c997          	auipc	s3,0x1c
    800062d2:	9d298993          	addi	s3,s3,-1582 # 80021ca0 <disk>
    800062d6:	00491713          	slli	a4,s2,0x4
    800062da:	0009b783          	ld	a5,0(s3)
    800062de:	97ba                	add	a5,a5,a4
    800062e0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062e4:	854a                	mv	a0,s2
    800062e6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062ea:	00000097          	auipc	ra,0x0
    800062ee:	b9c080e7          	jalr	-1124(ra) # 80005e86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062f2:	8885                	andi	s1,s1,1
    800062f4:	f0ed                	bnez	s1,800062d6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062f6:	0001c517          	auipc	a0,0x1c
    800062fa:	ad250513          	addi	a0,a0,-1326 # 80021dc8 <disk+0x128>
    800062fe:	ffffb097          	auipc	ra,0xffffb
    80006302:	99e080e7          	jalr	-1634(ra) # 80000c9c <release>
}
    80006306:	70a6                	ld	ra,104(sp)
    80006308:	7406                	ld	s0,96(sp)
    8000630a:	64e6                	ld	s1,88(sp)
    8000630c:	6946                	ld	s2,80(sp)
    8000630e:	69a6                	ld	s3,72(sp)
    80006310:	6a06                	ld	s4,64(sp)
    80006312:	7ae2                	ld	s5,56(sp)
    80006314:	7b42                	ld	s6,48(sp)
    80006316:	7ba2                	ld	s7,40(sp)
    80006318:	7c02                	ld	s8,32(sp)
    8000631a:	6ce2                	ld	s9,24(sp)
    8000631c:	6d42                	ld	s10,16(sp)
    8000631e:	6165                	addi	sp,sp,112
    80006320:	8082                	ret

0000000080006322 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006322:	1101                	addi	sp,sp,-32
    80006324:	ec06                	sd	ra,24(sp)
    80006326:	e822                	sd	s0,16(sp)
    80006328:	e426                	sd	s1,8(sp)
    8000632a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000632c:	0001c497          	auipc	s1,0x1c
    80006330:	97448493          	addi	s1,s1,-1676 # 80021ca0 <disk>
    80006334:	0001c517          	auipc	a0,0x1c
    80006338:	a9450513          	addi	a0,a0,-1388 # 80021dc8 <disk+0x128>
    8000633c:	ffffb097          	auipc	ra,0xffffb
    80006340:	896080e7          	jalr	-1898(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006344:	10001737          	lui	a4,0x10001
    80006348:	533c                	lw	a5,96(a4)
    8000634a:	8b8d                	andi	a5,a5,3
    8000634c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000634e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006352:	689c                	ld	a5,16(s1)
    80006354:	0204d703          	lhu	a4,32(s1)
    80006358:	0027d783          	lhu	a5,2(a5)
    8000635c:	04f70863          	beq	a4,a5,800063ac <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006360:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006364:	6898                	ld	a4,16(s1)
    80006366:	0204d783          	lhu	a5,32(s1)
    8000636a:	8b9d                	andi	a5,a5,7
    8000636c:	078e                	slli	a5,a5,0x3
    8000636e:	97ba                	add	a5,a5,a4
    80006370:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006372:	00278713          	addi	a4,a5,2
    80006376:	0712                	slli	a4,a4,0x4
    80006378:	9726                	add	a4,a4,s1
    8000637a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000637e:	e721                	bnez	a4,800063c6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006380:	0789                	addi	a5,a5,2
    80006382:	0792                	slli	a5,a5,0x4
    80006384:	97a6                	add	a5,a5,s1
    80006386:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006388:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000638c:	ffffc097          	auipc	ra,0xffffc
    80006390:	e3a080e7          	jalr	-454(ra) # 800021c6 <wakeup>

    disk.used_idx += 1;
    80006394:	0204d783          	lhu	a5,32(s1)
    80006398:	2785                	addiw	a5,a5,1
    8000639a:	17c2                	slli	a5,a5,0x30
    8000639c:	93c1                	srli	a5,a5,0x30
    8000639e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800063a2:	6898                	ld	a4,16(s1)
    800063a4:	00275703          	lhu	a4,2(a4)
    800063a8:	faf71ce3          	bne	a4,a5,80006360 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800063ac:	0001c517          	auipc	a0,0x1c
    800063b0:	a1c50513          	addi	a0,a0,-1508 # 80021dc8 <disk+0x128>
    800063b4:	ffffb097          	auipc	ra,0xffffb
    800063b8:	8e8080e7          	jalr	-1816(ra) # 80000c9c <release>
}
    800063bc:	60e2                	ld	ra,24(sp)
    800063be:	6442                	ld	s0,16(sp)
    800063c0:	64a2                	ld	s1,8(sp)
    800063c2:	6105                	addi	sp,sp,32
    800063c4:	8082                	ret
      panic("virtio_disk_intr status");
    800063c6:	00002517          	auipc	a0,0x2
    800063ca:	4da50513          	addi	a0,a0,1242 # 800088a0 <syscalls+0x438>
    800063ce:	ffffa097          	auipc	ra,0xffffa
    800063d2:	16e080e7          	jalr	366(ra) # 8000053c <panic>
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
