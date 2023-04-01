
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	f5a080e7          	jalr	-166(ra) # fea <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	40650513          	addi	a0,a0,1030 # 14a0 <malloc+0xee>
      a2:	00001097          	auipc	ra,0x1
      a6:	f28080e7          	jalr	-216(ra) # fca <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	3f650513          	addi	a0,a0,1014 # 14a0 <malloc+0xee>
      b2:	00001097          	auipc	ra,0x1
      b6:	f20080e7          	jalr	-224(ra) # fd2 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	3ec50513          	addi	a0,a0,1004 # 14a8 <malloc+0xf6>
      c4:	00001097          	auipc	ra,0x1
      c8:	236080e7          	jalr	566(ra) # 12fa <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	e94080e7          	jalr	-364(ra) # f62 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	3f250513          	addi	a0,a0,1010 # 14c8 <malloc+0x116>
      de:	00001097          	auipc	ra,0x1
      e2:	ef4080e7          	jalr	-268(ra) # fd2 <chdir>
      e6:	00001997          	auipc	s3,0x1
      ea:	3f298993          	addi	s3,s3,1010 # 14d8 <malloc+0x126>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	3e098993          	addi	s3,s3,992 # 14d0 <malloc+0x11e>
  uint64 iters = 0;
      f8:	4481                	li	s1,0
  int fd = -1;
      fa:	5a7d                	li	s4,-1
      fc:	00001917          	auipc	s2,0x1
     100:	68c90913          	addi	s2,s2,1676 # 1788 <malloc+0x3d6>
     104:	a839                	j	122 <go+0xaa>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	3d650513          	addi	a0,a0,982 # 14e0 <malloc+0x12e>
     112:	00001097          	auipc	ra,0x1
     116:	e90080e7          	jalr	-368(ra) # fa2 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	e70080e7          	jalr	-400(ra) # f8a <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	e4e080e7          	jalr	-434(ra) # f82 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	47d9                	li	a5,22
     152:	fca7e8e3          	bltu	a5,a0,122 <go+0xaa>
     156:	050a                	slli	a0,a0,0x2
     158:	954a                	add	a0,a0,s2
     15a:	411c                	lw	a5,0(a0)
     15c:	97ca                	add	a5,a5,s2
     15e:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     160:	20200593          	li	a1,514
     164:	00001517          	auipc	a0,0x1
     168:	38c50513          	addi	a0,a0,908 # 14f0 <malloc+0x13e>
     16c:	00001097          	auipc	ra,0x1
     170:	e36080e7          	jalr	-458(ra) # fa2 <open>
     174:	00001097          	auipc	ra,0x1
     178:	e16080e7          	jalr	-490(ra) # f8a <close>
     17c:	b75d                	j	122 <go+0xaa>
    } else if(what == 3){
      unlink("grindir/../a");
     17e:	00001517          	auipc	a0,0x1
     182:	36250513          	addi	a0,a0,866 # 14e0 <malloc+0x12e>
     186:	00001097          	auipc	ra,0x1
     18a:	e2c080e7          	jalr	-468(ra) # fb2 <unlink>
     18e:	bf51                	j	122 <go+0xaa>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     190:	00001517          	auipc	a0,0x1
     194:	31050513          	addi	a0,a0,784 # 14a0 <malloc+0xee>
     198:	00001097          	auipc	ra,0x1
     19c:	e3a080e7          	jalr	-454(ra) # fd2 <chdir>
     1a0:	e115                	bnez	a0,1c4 <go+0x14c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1a2:	00001517          	auipc	a0,0x1
     1a6:	36650513          	addi	a0,a0,870 # 1508 <malloc+0x156>
     1aa:	00001097          	auipc	ra,0x1
     1ae:	e08080e7          	jalr	-504(ra) # fb2 <unlink>
      chdir("/");
     1b2:	00001517          	auipc	a0,0x1
     1b6:	31650513          	addi	a0,a0,790 # 14c8 <malloc+0x116>
     1ba:	00001097          	auipc	ra,0x1
     1be:	e18080e7          	jalr	-488(ra) # fd2 <chdir>
     1c2:	b785                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     1c4:	00001517          	auipc	a0,0x1
     1c8:	2e450513          	addi	a0,a0,740 # 14a8 <malloc+0xf6>
     1cc:	00001097          	auipc	ra,0x1
     1d0:	12e080e7          	jalr	302(ra) # 12fa <printf>
        exit(1);
     1d4:	4505                	li	a0,1
     1d6:	00001097          	auipc	ra,0x1
     1da:	d8c080e7          	jalr	-628(ra) # f62 <exit>
    } else if(what == 5){
      close(fd);
     1de:	8552                	mv	a0,s4
     1e0:	00001097          	auipc	ra,0x1
     1e4:	daa080e7          	jalr	-598(ra) # f8a <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1e8:	20200593          	li	a1,514
     1ec:	00001517          	auipc	a0,0x1
     1f0:	32450513          	addi	a0,a0,804 # 1510 <malloc+0x15e>
     1f4:	00001097          	auipc	ra,0x1
     1f8:	dae080e7          	jalr	-594(ra) # fa2 <open>
     1fc:	8a2a                	mv	s4,a0
     1fe:	b715                	j	122 <go+0xaa>
    } else if(what == 6){
      close(fd);
     200:	8552                	mv	a0,s4
     202:	00001097          	auipc	ra,0x1
     206:	d88080e7          	jalr	-632(ra) # f8a <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	31250513          	addi	a0,a0,786 # 1520 <malloc+0x16e>
     216:	00001097          	auipc	ra,0x1
     21a:	d8c080e7          	jalr	-628(ra) # fa2 <open>
     21e:	8a2a                	mv	s4,a0
     220:	b709                	j	122 <go+0xaa>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     222:	3e700613          	li	a2,999
     226:	00002597          	auipc	a1,0x2
     22a:	dfa58593          	addi	a1,a1,-518 # 2020 <buf.0>
     22e:	8552                	mv	a0,s4
     230:	00001097          	auipc	ra,0x1
     234:	d52080e7          	jalr	-686(ra) # f82 <write>
     238:	b5ed                	j	122 <go+0xaa>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     23a:	3e700613          	li	a2,999
     23e:	00002597          	auipc	a1,0x2
     242:	de258593          	addi	a1,a1,-542 # 2020 <buf.0>
     246:	8552                	mv	a0,s4
     248:	00001097          	auipc	ra,0x1
     24c:	d32080e7          	jalr	-718(ra) # f7a <read>
     250:	bdc9                	j	122 <go+0xaa>
    } else if(what == 9){
      mkdir("grindir/../a");
     252:	00001517          	auipc	a0,0x1
     256:	28e50513          	addi	a0,a0,654 # 14e0 <malloc+0x12e>
     25a:	00001097          	auipc	ra,0x1
     25e:	d70080e7          	jalr	-656(ra) # fca <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     262:	20200593          	li	a1,514
     266:	00001517          	auipc	a0,0x1
     26a:	2d250513          	addi	a0,a0,722 # 1538 <malloc+0x186>
     26e:	00001097          	auipc	ra,0x1
     272:	d34080e7          	jalr	-716(ra) # fa2 <open>
     276:	00001097          	auipc	ra,0x1
     27a:	d14080e7          	jalr	-748(ra) # f8a <close>
      unlink("a/a");
     27e:	00001517          	auipc	a0,0x1
     282:	2ca50513          	addi	a0,a0,714 # 1548 <malloc+0x196>
     286:	00001097          	auipc	ra,0x1
     28a:	d2c080e7          	jalr	-724(ra) # fb2 <unlink>
     28e:	bd51                	j	122 <go+0xaa>
    } else if(what == 10){
      mkdir("/../b");
     290:	00001517          	auipc	a0,0x1
     294:	2c050513          	addi	a0,a0,704 # 1550 <malloc+0x19e>
     298:	00001097          	auipc	ra,0x1
     29c:	d32080e7          	jalr	-718(ra) # fca <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2a0:	20200593          	li	a1,514
     2a4:	00001517          	auipc	a0,0x1
     2a8:	2b450513          	addi	a0,a0,692 # 1558 <malloc+0x1a6>
     2ac:	00001097          	auipc	ra,0x1
     2b0:	cf6080e7          	jalr	-778(ra) # fa2 <open>
     2b4:	00001097          	auipc	ra,0x1
     2b8:	cd6080e7          	jalr	-810(ra) # f8a <close>
      unlink("b/b");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	2ac50513          	addi	a0,a0,684 # 1568 <malloc+0x1b6>
     2c4:	00001097          	auipc	ra,0x1
     2c8:	cee080e7          	jalr	-786(ra) # fb2 <unlink>
     2cc:	bd99                	j	122 <go+0xaa>
    } else if(what == 11){
      unlink("b");
     2ce:	00001517          	auipc	a0,0x1
     2d2:	26250513          	addi	a0,a0,610 # 1530 <malloc+0x17e>
     2d6:	00001097          	auipc	ra,0x1
     2da:	cdc080e7          	jalr	-804(ra) # fb2 <unlink>
      link("../grindir/./../a", "../b");
     2de:	00001597          	auipc	a1,0x1
     2e2:	22a58593          	addi	a1,a1,554 # 1508 <malloc+0x156>
     2e6:	00001517          	auipc	a0,0x1
     2ea:	28a50513          	addi	a0,a0,650 # 1570 <malloc+0x1be>
     2ee:	00001097          	auipc	ra,0x1
     2f2:	cd4080e7          	jalr	-812(ra) # fc2 <link>
     2f6:	b535                	j	122 <go+0xaa>
    } else if(what == 12){
      unlink("../grindir/../a");
     2f8:	00001517          	auipc	a0,0x1
     2fc:	29050513          	addi	a0,a0,656 # 1588 <malloc+0x1d6>
     300:	00001097          	auipc	ra,0x1
     304:	cb2080e7          	jalr	-846(ra) # fb2 <unlink>
      link(".././b", "/grindir/../a");
     308:	00001597          	auipc	a1,0x1
     30c:	20858593          	addi	a1,a1,520 # 1510 <malloc+0x15e>
     310:	00001517          	auipc	a0,0x1
     314:	28850513          	addi	a0,a0,648 # 1598 <malloc+0x1e6>
     318:	00001097          	auipc	ra,0x1
     31c:	caa080e7          	jalr	-854(ra) # fc2 <link>
     320:	b509                	j	122 <go+0xaa>
    } else if(what == 13){
      int pid = fork();
     322:	00001097          	auipc	ra,0x1
     326:	c38080e7          	jalr	-968(ra) # f5a <fork>
      if(pid == 0){
     32a:	c909                	beqz	a0,33c <go+0x2c4>
        exit(0);
      } else if(pid < 0){
     32c:	00054c63          	bltz	a0,344 <go+0x2cc>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     330:	4501                	li	a0,0
     332:	00001097          	auipc	ra,0x1
     336:	c38080e7          	jalr	-968(ra) # f6a <wait>
     33a:	b3e5                	j	122 <go+0xaa>
        exit(0);
     33c:	00001097          	auipc	ra,0x1
     340:	c26080e7          	jalr	-986(ra) # f62 <exit>
        printf("grind: fork failed\n");
     344:	00001517          	auipc	a0,0x1
     348:	25c50513          	addi	a0,a0,604 # 15a0 <malloc+0x1ee>
     34c:	00001097          	auipc	ra,0x1
     350:	fae080e7          	jalr	-82(ra) # 12fa <printf>
        exit(1);
     354:	4505                	li	a0,1
     356:	00001097          	auipc	ra,0x1
     35a:	c0c080e7          	jalr	-1012(ra) # f62 <exit>
    } else if(what == 14){
      int pid = fork();
     35e:	00001097          	auipc	ra,0x1
     362:	bfc080e7          	jalr	-1028(ra) # f5a <fork>
      if(pid == 0){
     366:	c909                	beqz	a0,378 <go+0x300>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     368:	02054563          	bltz	a0,392 <go+0x31a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     36c:	4501                	li	a0,0
     36e:	00001097          	auipc	ra,0x1
     372:	bfc080e7          	jalr	-1028(ra) # f6a <wait>
     376:	b375                	j	122 <go+0xaa>
        fork();
     378:	00001097          	auipc	ra,0x1
     37c:	be2080e7          	jalr	-1054(ra) # f5a <fork>
        fork();
     380:	00001097          	auipc	ra,0x1
     384:	bda080e7          	jalr	-1062(ra) # f5a <fork>
        exit(0);
     388:	4501                	li	a0,0
     38a:	00001097          	auipc	ra,0x1
     38e:	bd8080e7          	jalr	-1064(ra) # f62 <exit>
        printf("grind: fork failed\n");
     392:	00001517          	auipc	a0,0x1
     396:	20e50513          	addi	a0,a0,526 # 15a0 <malloc+0x1ee>
     39a:	00001097          	auipc	ra,0x1
     39e:	f60080e7          	jalr	-160(ra) # 12fa <printf>
        exit(1);
     3a2:	4505                	li	a0,1
     3a4:	00001097          	auipc	ra,0x1
     3a8:	bbe080e7          	jalr	-1090(ra) # f62 <exit>
    } else if(what == 15){
      sbrk(6011);
     3ac:	6505                	lui	a0,0x1
     3ae:	77b50513          	addi	a0,a0,1915 # 177b <malloc+0x3c9>
     3b2:	00001097          	auipc	ra,0x1
     3b6:	c38080e7          	jalr	-968(ra) # fea <sbrk>
     3ba:	b3a5                	j	122 <go+0xaa>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3bc:	4501                	li	a0,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	c2c080e7          	jalr	-980(ra) # fea <sbrk>
     3c6:	d4aafee3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     3ca:	4501                	li	a0,0
     3cc:	00001097          	auipc	ra,0x1
     3d0:	c1e080e7          	jalr	-994(ra) # fea <sbrk>
     3d4:	40aa853b          	subw	a0,s5,a0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	c12080e7          	jalr	-1006(ra) # fea <sbrk>
     3e0:	b389                	j	122 <go+0xaa>
    } else if(what == 17){
      int pid = fork();
     3e2:	00001097          	auipc	ra,0x1
     3e6:	b78080e7          	jalr	-1160(ra) # f5a <fork>
     3ea:	8b2a                	mv	s6,a0
      if(pid == 0){
     3ec:	c51d                	beqz	a0,41a <go+0x3a2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3ee:	04054963          	bltz	a0,440 <go+0x3c8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3f2:	00001517          	auipc	a0,0x1
     3f6:	1c650513          	addi	a0,a0,454 # 15b8 <malloc+0x206>
     3fa:	00001097          	auipc	ra,0x1
     3fe:	bd8080e7          	jalr	-1064(ra) # fd2 <chdir>
     402:	ed21                	bnez	a0,45a <go+0x3e2>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     404:	855a                	mv	a0,s6
     406:	00001097          	auipc	ra,0x1
     40a:	b8c080e7          	jalr	-1140(ra) # f92 <kill>
      wait(0);
     40e:	4501                	li	a0,0
     410:	00001097          	auipc	ra,0x1
     414:	b5a080e7          	jalr	-1190(ra) # f6a <wait>
     418:	b329                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     41a:	20200593          	li	a1,514
     41e:	00001517          	auipc	a0,0x1
     422:	16250513          	addi	a0,a0,354 # 1580 <malloc+0x1ce>
     426:	00001097          	auipc	ra,0x1
     42a:	b7c080e7          	jalr	-1156(ra) # fa2 <open>
     42e:	00001097          	auipc	ra,0x1
     432:	b5c080e7          	jalr	-1188(ra) # f8a <close>
        exit(0);
     436:	4501                	li	a0,0
     438:	00001097          	auipc	ra,0x1
     43c:	b2a080e7          	jalr	-1238(ra) # f62 <exit>
        printf("grind: fork failed\n");
     440:	00001517          	auipc	a0,0x1
     444:	16050513          	addi	a0,a0,352 # 15a0 <malloc+0x1ee>
     448:	00001097          	auipc	ra,0x1
     44c:	eb2080e7          	jalr	-334(ra) # 12fa <printf>
        exit(1);
     450:	4505                	li	a0,1
     452:	00001097          	auipc	ra,0x1
     456:	b10080e7          	jalr	-1264(ra) # f62 <exit>
        printf("grind: chdir failed\n");
     45a:	00001517          	auipc	a0,0x1
     45e:	16e50513          	addi	a0,a0,366 # 15c8 <malloc+0x216>
     462:	00001097          	auipc	ra,0x1
     466:	e98080e7          	jalr	-360(ra) # 12fa <printf>
        exit(1);
     46a:	4505                	li	a0,1
     46c:	00001097          	auipc	ra,0x1
     470:	af6080e7          	jalr	-1290(ra) # f62 <exit>
    } else if(what == 18){
      int pid = fork();
     474:	00001097          	auipc	ra,0x1
     478:	ae6080e7          	jalr	-1306(ra) # f5a <fork>
      if(pid == 0){
     47c:	c909                	beqz	a0,48e <go+0x416>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     47e:	02054563          	bltz	a0,4a8 <go+0x430>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     482:	4501                	li	a0,0
     484:	00001097          	auipc	ra,0x1
     488:	ae6080e7          	jalr	-1306(ra) # f6a <wait>
     48c:	b959                	j	122 <go+0xaa>
        kill(getpid());
     48e:	00001097          	auipc	ra,0x1
     492:	b54080e7          	jalr	-1196(ra) # fe2 <getpid>
     496:	00001097          	auipc	ra,0x1
     49a:	afc080e7          	jalr	-1284(ra) # f92 <kill>
        exit(0);
     49e:	4501                	li	a0,0
     4a0:	00001097          	auipc	ra,0x1
     4a4:	ac2080e7          	jalr	-1342(ra) # f62 <exit>
        printf("grind: fork failed\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	0f850513          	addi	a0,a0,248 # 15a0 <malloc+0x1ee>
     4b0:	00001097          	auipc	ra,0x1
     4b4:	e4a080e7          	jalr	-438(ra) # 12fa <printf>
        exit(1);
     4b8:	4505                	li	a0,1
     4ba:	00001097          	auipc	ra,0x1
     4be:	aa8080e7          	jalr	-1368(ra) # f62 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4c2:	fa840513          	addi	a0,s0,-88
     4c6:	00001097          	auipc	ra,0x1
     4ca:	aac080e7          	jalr	-1364(ra) # f72 <pipe>
     4ce:	02054b63          	bltz	a0,504 <go+0x48c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4d2:	00001097          	auipc	ra,0x1
     4d6:	a88080e7          	jalr	-1400(ra) # f5a <fork>
      if(pid == 0){
     4da:	c131                	beqz	a0,51e <go+0x4a6>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4dc:	0a054a63          	bltz	a0,590 <go+0x518>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4e0:	fa842503          	lw	a0,-88(s0)
     4e4:	00001097          	auipc	ra,0x1
     4e8:	aa6080e7          	jalr	-1370(ra) # f8a <close>
      close(fds[1]);
     4ec:	fac42503          	lw	a0,-84(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	a9a080e7          	jalr	-1382(ra) # f8a <close>
      wait(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	a70080e7          	jalr	-1424(ra) # f6a <wait>
     502:	b105                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	0dc50513          	addi	a0,a0,220 # 15e0 <malloc+0x22e>
     50c:	00001097          	auipc	ra,0x1
     510:	dee080e7          	jalr	-530(ra) # 12fa <printf>
        exit(1);
     514:	4505                	li	a0,1
     516:	00001097          	auipc	ra,0x1
     51a:	a4c080e7          	jalr	-1460(ra) # f62 <exit>
        fork();
     51e:	00001097          	auipc	ra,0x1
     522:	a3c080e7          	jalr	-1476(ra) # f5a <fork>
        fork();
     526:	00001097          	auipc	ra,0x1
     52a:	a34080e7          	jalr	-1484(ra) # f5a <fork>
        if(write(fds[1], "x", 1) != 1)
     52e:	4605                	li	a2,1
     530:	00001597          	auipc	a1,0x1
     534:	0c858593          	addi	a1,a1,200 # 15f8 <malloc+0x246>
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00001097          	auipc	ra,0x1
     540:	a46080e7          	jalr	-1466(ra) # f82 <write>
     544:	4785                	li	a5,1
     546:	02f51363          	bne	a0,a5,56c <go+0x4f4>
        if(read(fds[0], &c, 1) != 1)
     54a:	4605                	li	a2,1
     54c:	fa040593          	addi	a1,s0,-96
     550:	fa842503          	lw	a0,-88(s0)
     554:	00001097          	auipc	ra,0x1
     558:	a26080e7          	jalr	-1498(ra) # f7a <read>
     55c:	4785                	li	a5,1
     55e:	02f51063          	bne	a0,a5,57e <go+0x506>
        exit(0);
     562:	4501                	li	a0,0
     564:	00001097          	auipc	ra,0x1
     568:	9fe080e7          	jalr	-1538(ra) # f62 <exit>
          printf("grind: pipe write failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	09450513          	addi	a0,a0,148 # 1600 <malloc+0x24e>
     574:	00001097          	auipc	ra,0x1
     578:	d86080e7          	jalr	-634(ra) # 12fa <printf>
     57c:	b7f9                	j	54a <go+0x4d2>
          printf("grind: pipe read failed\n");
     57e:	00001517          	auipc	a0,0x1
     582:	0a250513          	addi	a0,a0,162 # 1620 <malloc+0x26e>
     586:	00001097          	auipc	ra,0x1
     58a:	d74080e7          	jalr	-652(ra) # 12fa <printf>
     58e:	bfd1                	j	562 <go+0x4ea>
        printf("grind: fork failed\n");
     590:	00001517          	auipc	a0,0x1
     594:	01050513          	addi	a0,a0,16 # 15a0 <malloc+0x1ee>
     598:	00001097          	auipc	ra,0x1
     59c:	d62080e7          	jalr	-670(ra) # 12fa <printf>
        exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00001097          	auipc	ra,0x1
     5a6:	9c0080e7          	jalr	-1600(ra) # f62 <exit>
    } else if(what == 20){
      int pid = fork();
     5aa:	00001097          	auipc	ra,0x1
     5ae:	9b0080e7          	jalr	-1616(ra) # f5a <fork>
      if(pid == 0){
     5b2:	c909                	beqz	a0,5c4 <go+0x54c>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5b4:	06054f63          	bltz	a0,632 <go+0x5ba>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5b8:	4501                	li	a0,0
     5ba:	00001097          	auipc	ra,0x1
     5be:	9b0080e7          	jalr	-1616(ra) # f6a <wait>
     5c2:	b685                	j	122 <go+0xaa>
        unlink("a");
     5c4:	00001517          	auipc	a0,0x1
     5c8:	fbc50513          	addi	a0,a0,-68 # 1580 <malloc+0x1ce>
     5cc:	00001097          	auipc	ra,0x1
     5d0:	9e6080e7          	jalr	-1562(ra) # fb2 <unlink>
        mkdir("a");
     5d4:	00001517          	auipc	a0,0x1
     5d8:	fac50513          	addi	a0,a0,-84 # 1580 <malloc+0x1ce>
     5dc:	00001097          	auipc	ra,0x1
     5e0:	9ee080e7          	jalr	-1554(ra) # fca <mkdir>
        chdir("a");
     5e4:	00001517          	auipc	a0,0x1
     5e8:	f9c50513          	addi	a0,a0,-100 # 1580 <malloc+0x1ce>
     5ec:	00001097          	auipc	ra,0x1
     5f0:	9e6080e7          	jalr	-1562(ra) # fd2 <chdir>
        unlink("../a");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	ef450513          	addi	a0,a0,-268 # 14e8 <malloc+0x136>
     5fc:	00001097          	auipc	ra,0x1
     600:	9b6080e7          	jalr	-1610(ra) # fb2 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     604:	20200593          	li	a1,514
     608:	00001517          	auipc	a0,0x1
     60c:	ff050513          	addi	a0,a0,-16 # 15f8 <malloc+0x246>
     610:	00001097          	auipc	ra,0x1
     614:	992080e7          	jalr	-1646(ra) # fa2 <open>
        unlink("x");
     618:	00001517          	auipc	a0,0x1
     61c:	fe050513          	addi	a0,a0,-32 # 15f8 <malloc+0x246>
     620:	00001097          	auipc	ra,0x1
     624:	992080e7          	jalr	-1646(ra) # fb2 <unlink>
        exit(0);
     628:	4501                	li	a0,0
     62a:	00001097          	auipc	ra,0x1
     62e:	938080e7          	jalr	-1736(ra) # f62 <exit>
        printf("grind: fork failed\n");
     632:	00001517          	auipc	a0,0x1
     636:	f6e50513          	addi	a0,a0,-146 # 15a0 <malloc+0x1ee>
     63a:	00001097          	auipc	ra,0x1
     63e:	cc0080e7          	jalr	-832(ra) # 12fa <printf>
        exit(1);
     642:	4505                	li	a0,1
     644:	00001097          	auipc	ra,0x1
     648:	91e080e7          	jalr	-1762(ra) # f62 <exit>
    } else if(what == 21){
      unlink("c");
     64c:	00001517          	auipc	a0,0x1
     650:	ff450513          	addi	a0,a0,-12 # 1640 <malloc+0x28e>
     654:	00001097          	auipc	ra,0x1
     658:	95e080e7          	jalr	-1698(ra) # fb2 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     65c:	20200593          	li	a1,514
     660:	00001517          	auipc	a0,0x1
     664:	fe050513          	addi	a0,a0,-32 # 1640 <malloc+0x28e>
     668:	00001097          	auipc	ra,0x1
     66c:	93a080e7          	jalr	-1734(ra) # fa2 <open>
     670:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     672:	04054f63          	bltz	a0,6d0 <go+0x658>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     676:	4605                	li	a2,1
     678:	00001597          	auipc	a1,0x1
     67c:	f8058593          	addi	a1,a1,-128 # 15f8 <malloc+0x246>
     680:	00001097          	auipc	ra,0x1
     684:	902080e7          	jalr	-1790(ra) # f82 <write>
     688:	4785                	li	a5,1
     68a:	06f51063          	bne	a0,a5,6ea <go+0x672>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     68e:	fa840593          	addi	a1,s0,-88
     692:	855a                	mv	a0,s6
     694:	00001097          	auipc	ra,0x1
     698:	926080e7          	jalr	-1754(ra) # fba <fstat>
     69c:	e525                	bnez	a0,704 <go+0x68c>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     69e:	fb843583          	ld	a1,-72(s0)
     6a2:	4785                	li	a5,1
     6a4:	06f59d63          	bne	a1,a5,71e <go+0x6a6>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6a8:	fac42583          	lw	a1,-84(s0)
     6ac:	0c800793          	li	a5,200
     6b0:	08b7e563          	bltu	a5,a1,73a <go+0x6c2>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6b4:	855a                	mv	a0,s6
     6b6:	00001097          	auipc	ra,0x1
     6ba:	8d4080e7          	jalr	-1836(ra) # f8a <close>
      unlink("c");
     6be:	00001517          	auipc	a0,0x1
     6c2:	f8250513          	addi	a0,a0,-126 # 1640 <malloc+0x28e>
     6c6:	00001097          	auipc	ra,0x1
     6ca:	8ec080e7          	jalr	-1812(ra) # fb2 <unlink>
     6ce:	bc91                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     6d0:	00001517          	auipc	a0,0x1
     6d4:	f7850513          	addi	a0,a0,-136 # 1648 <malloc+0x296>
     6d8:	00001097          	auipc	ra,0x1
     6dc:	c22080e7          	jalr	-990(ra) # 12fa <printf>
        exit(1);
     6e0:	4505                	li	a0,1
     6e2:	00001097          	auipc	ra,0x1
     6e6:	880080e7          	jalr	-1920(ra) # f62 <exit>
        printf("grind: write c failed\n");
     6ea:	00001517          	auipc	a0,0x1
     6ee:	f7650513          	addi	a0,a0,-138 # 1660 <malloc+0x2ae>
     6f2:	00001097          	auipc	ra,0x1
     6f6:	c08080e7          	jalr	-1016(ra) # 12fa <printf>
        exit(1);
     6fa:	4505                	li	a0,1
     6fc:	00001097          	auipc	ra,0x1
     700:	866080e7          	jalr	-1946(ra) # f62 <exit>
        printf("grind: fstat failed\n");
     704:	00001517          	auipc	a0,0x1
     708:	f7450513          	addi	a0,a0,-140 # 1678 <malloc+0x2c6>
     70c:	00001097          	auipc	ra,0x1
     710:	bee080e7          	jalr	-1042(ra) # 12fa <printf>
        exit(1);
     714:	4505                	li	a0,1
     716:	00001097          	auipc	ra,0x1
     71a:	84c080e7          	jalr	-1972(ra) # f62 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     71e:	2581                	sext.w	a1,a1
     720:	00001517          	auipc	a0,0x1
     724:	f7050513          	addi	a0,a0,-144 # 1690 <malloc+0x2de>
     728:	00001097          	auipc	ra,0x1
     72c:	bd2080e7          	jalr	-1070(ra) # 12fa <printf>
        exit(1);
     730:	4505                	li	a0,1
     732:	00001097          	auipc	ra,0x1
     736:	830080e7          	jalr	-2000(ra) # f62 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     73a:	00001517          	auipc	a0,0x1
     73e:	f7e50513          	addi	a0,a0,-130 # 16b8 <malloc+0x306>
     742:	00001097          	auipc	ra,0x1
     746:	bb8080e7          	jalr	-1096(ra) # 12fa <printf>
        exit(1);
     74a:	4505                	li	a0,1
     74c:	00001097          	auipc	ra,0x1
     750:	816080e7          	jalr	-2026(ra) # f62 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     754:	f9840513          	addi	a0,s0,-104
     758:	00001097          	auipc	ra,0x1
     75c:	81a080e7          	jalr	-2022(ra) # f72 <pipe>
     760:	10054063          	bltz	a0,860 <go+0x7e8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     764:	fa040513          	addi	a0,s0,-96
     768:	00001097          	auipc	ra,0x1
     76c:	80a080e7          	jalr	-2038(ra) # f72 <pipe>
     770:	10054663          	bltz	a0,87c <go+0x804>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     774:	00000097          	auipc	ra,0x0
     778:	7e6080e7          	jalr	2022(ra) # f5a <fork>
      if(pid1 == 0){
     77c:	10050e63          	beqz	a0,898 <go+0x820>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     780:	1c054663          	bltz	a0,94c <go+0x8d4>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     784:	00000097          	auipc	ra,0x0
     788:	7d6080e7          	jalr	2006(ra) # f5a <fork>
      if(pid2 == 0){
     78c:	1c050e63          	beqz	a0,968 <go+0x8f0>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     790:	2a054a63          	bltz	a0,a44 <go+0x9cc>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     794:	f9842503          	lw	a0,-104(s0)
     798:	00000097          	auipc	ra,0x0
     79c:	7f2080e7          	jalr	2034(ra) # f8a <close>
      close(aa[1]);
     7a0:	f9c42503          	lw	a0,-100(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	7e6080e7          	jalr	2022(ra) # f8a <close>
      close(bb[1]);
     7ac:	fa442503          	lw	a0,-92(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	7da080e7          	jalr	2010(ra) # f8a <close>
      char buf[4] = { 0, 0, 0, 0 };
     7b8:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7bc:	4605                	li	a2,1
     7be:	f9040593          	addi	a1,s0,-112
     7c2:	fa042503          	lw	a0,-96(s0)
     7c6:	00000097          	auipc	ra,0x0
     7ca:	7b4080e7          	jalr	1972(ra) # f7a <read>
      read(bb[0], buf+1, 1);
     7ce:	4605                	li	a2,1
     7d0:	f9140593          	addi	a1,s0,-111
     7d4:	fa042503          	lw	a0,-96(s0)
     7d8:	00000097          	auipc	ra,0x0
     7dc:	7a2080e7          	jalr	1954(ra) # f7a <read>
      read(bb[0], buf+2, 1);
     7e0:	4605                	li	a2,1
     7e2:	f9240593          	addi	a1,s0,-110
     7e6:	fa042503          	lw	a0,-96(s0)
     7ea:	00000097          	auipc	ra,0x0
     7ee:	790080e7          	jalr	1936(ra) # f7a <read>
      close(bb[0]);
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	794080e7          	jalr	1940(ra) # f8a <close>
      int st1, st2;
      wait(&st1);
     7fe:	f9440513          	addi	a0,s0,-108
     802:	00000097          	auipc	ra,0x0
     806:	768080e7          	jalr	1896(ra) # f6a <wait>
      wait(&st2);
     80a:	fa840513          	addi	a0,s0,-88
     80e:	00000097          	auipc	ra,0x0
     812:	75c080e7          	jalr	1884(ra) # f6a <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     816:	f9442783          	lw	a5,-108(s0)
     81a:	fa842703          	lw	a4,-88(s0)
     81e:	8fd9                	or	a5,a5,a4
     820:	ef89                	bnez	a5,83a <go+0x7c2>
     822:	00001597          	auipc	a1,0x1
     826:	f3658593          	addi	a1,a1,-202 # 1758 <malloc+0x3a6>
     82a:	f9040513          	addi	a0,s0,-112
     82e:	00000097          	auipc	ra,0x0
     832:	3b0080e7          	jalr	944(ra) # bde <strcmp>
     836:	8e0506e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     83a:	f9040693          	addi	a3,s0,-112
     83e:	fa842603          	lw	a2,-88(s0)
     842:	f9442583          	lw	a1,-108(s0)
     846:	00001517          	auipc	a0,0x1
     84a:	f1a50513          	addi	a0,a0,-230 # 1760 <malloc+0x3ae>
     84e:	00001097          	auipc	ra,0x1
     852:	aac080e7          	jalr	-1364(ra) # 12fa <printf>
        exit(1);
     856:	4505                	li	a0,1
     858:	00000097          	auipc	ra,0x0
     85c:	70a080e7          	jalr	1802(ra) # f62 <exit>
        fprintf(2, "grind: pipe failed\n");
     860:	00001597          	auipc	a1,0x1
     864:	d8058593          	addi	a1,a1,-640 # 15e0 <malloc+0x22e>
     868:	4509                	li	a0,2
     86a:	00001097          	auipc	ra,0x1
     86e:	a62080e7          	jalr	-1438(ra) # 12cc <fprintf>
        exit(1);
     872:	4505                	li	a0,1
     874:	00000097          	auipc	ra,0x0
     878:	6ee080e7          	jalr	1774(ra) # f62 <exit>
        fprintf(2, "grind: pipe failed\n");
     87c:	00001597          	auipc	a1,0x1
     880:	d6458593          	addi	a1,a1,-668 # 15e0 <malloc+0x22e>
     884:	4509                	li	a0,2
     886:	00001097          	auipc	ra,0x1
     88a:	a46080e7          	jalr	-1466(ra) # 12cc <fprintf>
        exit(1);
     88e:	4505                	li	a0,1
     890:	00000097          	auipc	ra,0x0
     894:	6d2080e7          	jalr	1746(ra) # f62 <exit>
        close(bb[0]);
     898:	fa042503          	lw	a0,-96(s0)
     89c:	00000097          	auipc	ra,0x0
     8a0:	6ee080e7          	jalr	1774(ra) # f8a <close>
        close(bb[1]);
     8a4:	fa442503          	lw	a0,-92(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	6e2080e7          	jalr	1762(ra) # f8a <close>
        close(aa[0]);
     8b0:	f9842503          	lw	a0,-104(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	6d6080e7          	jalr	1750(ra) # f8a <close>
        close(1);
     8bc:	4505                	li	a0,1
     8be:	00000097          	auipc	ra,0x0
     8c2:	6cc080e7          	jalr	1740(ra) # f8a <close>
        if(dup(aa[1]) != 1){
     8c6:	f9c42503          	lw	a0,-100(s0)
     8ca:	00000097          	auipc	ra,0x0
     8ce:	710080e7          	jalr	1808(ra) # fda <dup>
     8d2:	4785                	li	a5,1
     8d4:	02f50063          	beq	a0,a5,8f4 <go+0x87c>
          fprintf(2, "grind: dup failed\n");
     8d8:	00001597          	auipc	a1,0x1
     8dc:	e0858593          	addi	a1,a1,-504 # 16e0 <malloc+0x32e>
     8e0:	4509                	li	a0,2
     8e2:	00001097          	auipc	ra,0x1
     8e6:	9ea080e7          	jalr	-1558(ra) # 12cc <fprintf>
          exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	676080e7          	jalr	1654(ra) # f62 <exit>
        close(aa[1]);
     8f4:	f9c42503          	lw	a0,-100(s0)
     8f8:	00000097          	auipc	ra,0x0
     8fc:	692080e7          	jalr	1682(ra) # f8a <close>
        char *args[3] = { "echo", "hi", 0 };
     900:	00001797          	auipc	a5,0x1
     904:	df878793          	addi	a5,a5,-520 # 16f8 <malloc+0x346>
     908:	faf43423          	sd	a5,-88(s0)
     90c:	00001797          	auipc	a5,0x1
     910:	df478793          	addi	a5,a5,-524 # 1700 <malloc+0x34e>
     914:	faf43823          	sd	a5,-80(s0)
     918:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     91c:	fa840593          	addi	a1,s0,-88
     920:	00001517          	auipc	a0,0x1
     924:	de850513          	addi	a0,a0,-536 # 1708 <malloc+0x356>
     928:	00000097          	auipc	ra,0x0
     92c:	672080e7          	jalr	1650(ra) # f9a <exec>
        fprintf(2, "grind: echo: not found\n");
     930:	00001597          	auipc	a1,0x1
     934:	de858593          	addi	a1,a1,-536 # 1718 <malloc+0x366>
     938:	4509                	li	a0,2
     93a:	00001097          	auipc	ra,0x1
     93e:	992080e7          	jalr	-1646(ra) # 12cc <fprintf>
        exit(2);
     942:	4509                	li	a0,2
     944:	00000097          	auipc	ra,0x0
     948:	61e080e7          	jalr	1566(ra) # f62 <exit>
        fprintf(2, "grind: fork failed\n");
     94c:	00001597          	auipc	a1,0x1
     950:	c5458593          	addi	a1,a1,-940 # 15a0 <malloc+0x1ee>
     954:	4509                	li	a0,2
     956:	00001097          	auipc	ra,0x1
     95a:	976080e7          	jalr	-1674(ra) # 12cc <fprintf>
        exit(3);
     95e:	450d                	li	a0,3
     960:	00000097          	auipc	ra,0x0
     964:	602080e7          	jalr	1538(ra) # f62 <exit>
        close(aa[1]);
     968:	f9c42503          	lw	a0,-100(s0)
     96c:	00000097          	auipc	ra,0x0
     970:	61e080e7          	jalr	1566(ra) # f8a <close>
        close(bb[0]);
     974:	fa042503          	lw	a0,-96(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	612080e7          	jalr	1554(ra) # f8a <close>
        close(0);
     980:	4501                	li	a0,0
     982:	00000097          	auipc	ra,0x0
     986:	608080e7          	jalr	1544(ra) # f8a <close>
        if(dup(aa[0]) != 0){
     98a:	f9842503          	lw	a0,-104(s0)
     98e:	00000097          	auipc	ra,0x0
     992:	64c080e7          	jalr	1612(ra) # fda <dup>
     996:	cd19                	beqz	a0,9b4 <go+0x93c>
          fprintf(2, "grind: dup failed\n");
     998:	00001597          	auipc	a1,0x1
     99c:	d4858593          	addi	a1,a1,-696 # 16e0 <malloc+0x32e>
     9a0:	4509                	li	a0,2
     9a2:	00001097          	auipc	ra,0x1
     9a6:	92a080e7          	jalr	-1750(ra) # 12cc <fprintf>
          exit(4);
     9aa:	4511                	li	a0,4
     9ac:	00000097          	auipc	ra,0x0
     9b0:	5b6080e7          	jalr	1462(ra) # f62 <exit>
        close(aa[0]);
     9b4:	f9842503          	lw	a0,-104(s0)
     9b8:	00000097          	auipc	ra,0x0
     9bc:	5d2080e7          	jalr	1490(ra) # f8a <close>
        close(1);
     9c0:	4505                	li	a0,1
     9c2:	00000097          	auipc	ra,0x0
     9c6:	5c8080e7          	jalr	1480(ra) # f8a <close>
        if(dup(bb[1]) != 1){
     9ca:	fa442503          	lw	a0,-92(s0)
     9ce:	00000097          	auipc	ra,0x0
     9d2:	60c080e7          	jalr	1548(ra) # fda <dup>
     9d6:	4785                	li	a5,1
     9d8:	02f50063          	beq	a0,a5,9f8 <go+0x980>
          fprintf(2, "grind: dup failed\n");
     9dc:	00001597          	auipc	a1,0x1
     9e0:	d0458593          	addi	a1,a1,-764 # 16e0 <malloc+0x32e>
     9e4:	4509                	li	a0,2
     9e6:	00001097          	auipc	ra,0x1
     9ea:	8e6080e7          	jalr	-1818(ra) # 12cc <fprintf>
          exit(5);
     9ee:	4515                	li	a0,5
     9f0:	00000097          	auipc	ra,0x0
     9f4:	572080e7          	jalr	1394(ra) # f62 <exit>
        close(bb[1]);
     9f8:	fa442503          	lw	a0,-92(s0)
     9fc:	00000097          	auipc	ra,0x0
     a00:	58e080e7          	jalr	1422(ra) # f8a <close>
        char *args[2] = { "cat", 0 };
     a04:	00001797          	auipc	a5,0x1
     a08:	d2c78793          	addi	a5,a5,-724 # 1730 <malloc+0x37e>
     a0c:	faf43423          	sd	a5,-88(s0)
     a10:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a14:	fa840593          	addi	a1,s0,-88
     a18:	00001517          	auipc	a0,0x1
     a1c:	d2050513          	addi	a0,a0,-736 # 1738 <malloc+0x386>
     a20:	00000097          	auipc	ra,0x0
     a24:	57a080e7          	jalr	1402(ra) # f9a <exec>
        fprintf(2, "grind: cat: not found\n");
     a28:	00001597          	auipc	a1,0x1
     a2c:	d1858593          	addi	a1,a1,-744 # 1740 <malloc+0x38e>
     a30:	4509                	li	a0,2
     a32:	00001097          	auipc	ra,0x1
     a36:	89a080e7          	jalr	-1894(ra) # 12cc <fprintf>
        exit(6);
     a3a:	4519                	li	a0,6
     a3c:	00000097          	auipc	ra,0x0
     a40:	526080e7          	jalr	1318(ra) # f62 <exit>
        fprintf(2, "grind: fork failed\n");
     a44:	00001597          	auipc	a1,0x1
     a48:	b5c58593          	addi	a1,a1,-1188 # 15a0 <malloc+0x1ee>
     a4c:	4509                	li	a0,2
     a4e:	00001097          	auipc	ra,0x1
     a52:	87e080e7          	jalr	-1922(ra) # 12cc <fprintf>
        exit(7);
     a56:	451d                	li	a0,7
     a58:	00000097          	auipc	ra,0x0
     a5c:	50a080e7          	jalr	1290(ra) # f62 <exit>

0000000000000a60 <iter>:
  }
}

void
iter()
{
     a60:	7179                	addi	sp,sp,-48
     a62:	f406                	sd	ra,40(sp)
     a64:	f022                	sd	s0,32(sp)
     a66:	ec26                	sd	s1,24(sp)
     a68:	e84a                	sd	s2,16(sp)
     a6a:	1800                	addi	s0,sp,48
  unlink("a");
     a6c:	00001517          	auipc	a0,0x1
     a70:	b1450513          	addi	a0,a0,-1260 # 1580 <malloc+0x1ce>
     a74:	00000097          	auipc	ra,0x0
     a78:	53e080e7          	jalr	1342(ra) # fb2 <unlink>
  unlink("b");
     a7c:	00001517          	auipc	a0,0x1
     a80:	ab450513          	addi	a0,a0,-1356 # 1530 <malloc+0x17e>
     a84:	00000097          	auipc	ra,0x0
     a88:	52e080e7          	jalr	1326(ra) # fb2 <unlink>
  
  int pid1 = fork();
     a8c:	00000097          	auipc	ra,0x0
     a90:	4ce080e7          	jalr	1230(ra) # f5a <fork>
  if(pid1 < 0){
     a94:	02054163          	bltz	a0,ab6 <iter+0x56>
     a98:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     a9a:	e91d                	bnez	a0,ad0 <iter+0x70>
    rand_next ^= 31;
     a9c:	00001717          	auipc	a4,0x1
     aa0:	56470713          	addi	a4,a4,1380 # 2000 <rand_next>
     aa4:	631c                	ld	a5,0(a4)
     aa6:	01f7c793          	xori	a5,a5,31
     aaa:	e31c                	sd	a5,0(a4)
    go(0);
     aac:	4501                	li	a0,0
     aae:	fffff097          	auipc	ra,0xfffff
     ab2:	5ca080e7          	jalr	1482(ra) # 78 <go>
    printf("grind: fork failed\n");
     ab6:	00001517          	auipc	a0,0x1
     aba:	aea50513          	addi	a0,a0,-1302 # 15a0 <malloc+0x1ee>
     abe:	00001097          	auipc	ra,0x1
     ac2:	83c080e7          	jalr	-1988(ra) # 12fa <printf>
    exit(1);
     ac6:	4505                	li	a0,1
     ac8:	00000097          	auipc	ra,0x0
     acc:	49a080e7          	jalr	1178(ra) # f62 <exit>
    exit(0);
  }

  int pid2 = fork();
     ad0:	00000097          	auipc	ra,0x0
     ad4:	48a080e7          	jalr	1162(ra) # f5a <fork>
     ad8:	892a                	mv	s2,a0
  if(pid2 < 0){
     ada:	02054263          	bltz	a0,afe <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     ade:	ed0d                	bnez	a0,b18 <iter+0xb8>
    rand_next ^= 7177;
     ae0:	00001697          	auipc	a3,0x1
     ae4:	52068693          	addi	a3,a3,1312 # 2000 <rand_next>
     ae8:	629c                	ld	a5,0(a3)
     aea:	6709                	lui	a4,0x2
     aec:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x3c1>
     af0:	8fb9                	xor	a5,a5,a4
     af2:	e29c                	sd	a5,0(a3)
    go(1);
     af4:	4505                	li	a0,1
     af6:	fffff097          	auipc	ra,0xfffff
     afa:	582080e7          	jalr	1410(ra) # 78 <go>
    printf("grind: fork failed\n");
     afe:	00001517          	auipc	a0,0x1
     b02:	aa250513          	addi	a0,a0,-1374 # 15a0 <malloc+0x1ee>
     b06:	00000097          	auipc	ra,0x0
     b0a:	7f4080e7          	jalr	2036(ra) # 12fa <printf>
    exit(1);
     b0e:	4505                	li	a0,1
     b10:	00000097          	auipc	ra,0x0
     b14:	452080e7          	jalr	1106(ra) # f62 <exit>
    exit(0);
  }

  int st1 = -1;
     b18:	57fd                	li	a5,-1
     b1a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b1e:	fdc40513          	addi	a0,s0,-36
     b22:	00000097          	auipc	ra,0x0
     b26:	448080e7          	jalr	1096(ra) # f6a <wait>
  if(st1 != 0){
     b2a:	fdc42783          	lw	a5,-36(s0)
     b2e:	ef99                	bnez	a5,b4c <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b30:	57fd                	li	a5,-1
     b32:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b36:	fd840513          	addi	a0,s0,-40
     b3a:	00000097          	auipc	ra,0x0
     b3e:	430080e7          	jalr	1072(ra) # f6a <wait>

  exit(0);
     b42:	4501                	li	a0,0
     b44:	00000097          	auipc	ra,0x0
     b48:	41e080e7          	jalr	1054(ra) # f62 <exit>
    kill(pid1);
     b4c:	8526                	mv	a0,s1
     b4e:	00000097          	auipc	ra,0x0
     b52:	444080e7          	jalr	1092(ra) # f92 <kill>
    kill(pid2);
     b56:	854a                	mv	a0,s2
     b58:	00000097          	auipc	ra,0x0
     b5c:	43a080e7          	jalr	1082(ra) # f92 <kill>
     b60:	bfc1                	j	b30 <iter+0xd0>

0000000000000b62 <main>:
}

int
main()
{
     b62:	1101                	addi	sp,sp,-32
     b64:	ec06                	sd	ra,24(sp)
     b66:	e822                	sd	s0,16(sp)
     b68:	e426                	sd	s1,8(sp)
     b6a:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     b6c:	00001497          	auipc	s1,0x1
     b70:	49448493          	addi	s1,s1,1172 # 2000 <rand_next>
     b74:	a829                	j	b8e <main+0x2c>
      iter();
     b76:	00000097          	auipc	ra,0x0
     b7a:	eea080e7          	jalr	-278(ra) # a60 <iter>
    sleep(20);
     b7e:	4551                	li	a0,20
     b80:	00000097          	auipc	ra,0x0
     b84:	472080e7          	jalr	1138(ra) # ff2 <sleep>
    rand_next += 1;
     b88:	609c                	ld	a5,0(s1)
     b8a:	0785                	addi	a5,a5,1
     b8c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     b8e:	00000097          	auipc	ra,0x0
     b92:	3cc080e7          	jalr	972(ra) # f5a <fork>
    if(pid == 0){
     b96:	d165                	beqz	a0,b76 <main+0x14>
    if(pid > 0){
     b98:	fea053e3          	blez	a0,b7e <main+0x1c>
      wait(0);
     b9c:	4501                	li	a0,0
     b9e:	00000097          	auipc	ra,0x0
     ba2:	3cc080e7          	jalr	972(ra) # f6a <wait>
     ba6:	bfe1                	j	b7e <main+0x1c>

0000000000000ba8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bb0:	00000097          	auipc	ra,0x0
     bb4:	fb2080e7          	jalr	-78(ra) # b62 <main>
  exit(0);
     bb8:	4501                	li	a0,0
     bba:	00000097          	auipc	ra,0x0
     bbe:	3a8080e7          	jalr	936(ra) # f62 <exit>

0000000000000bc2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e422                	sd	s0,8(sp)
     bc6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc8:	87aa                	mv	a5,a0
     bca:	0585                	addi	a1,a1,1
     bcc:	0785                	addi	a5,a5,1
     bce:	fff5c703          	lbu	a4,-1(a1)
     bd2:	fee78fa3          	sb	a4,-1(a5)
     bd6:	fb75                	bnez	a4,bca <strcpy+0x8>
    ;
  return os;
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret

0000000000000bde <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bde:	1141                	addi	sp,sp,-16
     be0:	e422                	sd	s0,8(sp)
     be2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     be4:	00054783          	lbu	a5,0(a0)
     be8:	cb91                	beqz	a5,bfc <strcmp+0x1e>
     bea:	0005c703          	lbu	a4,0(a1)
     bee:	00f71763          	bne	a4,a5,bfc <strcmp+0x1e>
    p++, q++;
     bf2:	0505                	addi	a0,a0,1
     bf4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bf6:	00054783          	lbu	a5,0(a0)
     bfa:	fbe5                	bnez	a5,bea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bfc:	0005c503          	lbu	a0,0(a1)
}
     c00:	40a7853b          	subw	a0,a5,a0
     c04:	6422                	ld	s0,8(sp)
     c06:	0141                	addi	sp,sp,16
     c08:	8082                	ret

0000000000000c0a <strlen>:

uint
strlen(const char *s)
{
     c0a:	1141                	addi	sp,sp,-16
     c0c:	e422                	sd	s0,8(sp)
     c0e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c10:	00054783          	lbu	a5,0(a0)
     c14:	cf91                	beqz	a5,c30 <strlen+0x26>
     c16:	0505                	addi	a0,a0,1
     c18:	87aa                	mv	a5,a0
     c1a:	86be                	mv	a3,a5
     c1c:	0785                	addi	a5,a5,1
     c1e:	fff7c703          	lbu	a4,-1(a5)
     c22:	ff65                	bnez	a4,c1a <strlen+0x10>
     c24:	40a6853b          	subw	a0,a3,a0
     c28:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c2a:	6422                	ld	s0,8(sp)
     c2c:	0141                	addi	sp,sp,16
     c2e:	8082                	ret
  for(n = 0; s[n]; n++)
     c30:	4501                	li	a0,0
     c32:	bfe5                	j	c2a <strlen+0x20>

0000000000000c34 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c34:	1141                	addi	sp,sp,-16
     c36:	e422                	sd	s0,8(sp)
     c38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c3a:	ca19                	beqz	a2,c50 <memset+0x1c>
     c3c:	87aa                	mv	a5,a0
     c3e:	1602                	slli	a2,a2,0x20
     c40:	9201                	srli	a2,a2,0x20
     c42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c4a:	0785                	addi	a5,a5,1
     c4c:	fee79de3          	bne	a5,a4,c46 <memset+0x12>
  }
  return dst;
}
     c50:	6422                	ld	s0,8(sp)
     c52:	0141                	addi	sp,sp,16
     c54:	8082                	ret

0000000000000c56 <strchr>:

char*
strchr(const char *s, char c)
{
     c56:	1141                	addi	sp,sp,-16
     c58:	e422                	sd	s0,8(sp)
     c5a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c5c:	00054783          	lbu	a5,0(a0)
     c60:	cb99                	beqz	a5,c76 <strchr+0x20>
    if(*s == c)
     c62:	00f58763          	beq	a1,a5,c70 <strchr+0x1a>
  for(; *s; s++)
     c66:	0505                	addi	a0,a0,1
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	fbfd                	bnez	a5,c62 <strchr+0xc>
      return (char*)s;
  return 0;
     c6e:	4501                	li	a0,0
}
     c70:	6422                	ld	s0,8(sp)
     c72:	0141                	addi	sp,sp,16
     c74:	8082                	ret
  return 0;
     c76:	4501                	li	a0,0
     c78:	bfe5                	j	c70 <strchr+0x1a>

0000000000000c7a <gets>:

char*
gets(char *buf, int max)
{
     c7a:	711d                	addi	sp,sp,-96
     c7c:	ec86                	sd	ra,88(sp)
     c7e:	e8a2                	sd	s0,80(sp)
     c80:	e4a6                	sd	s1,72(sp)
     c82:	e0ca                	sd	s2,64(sp)
     c84:	fc4e                	sd	s3,56(sp)
     c86:	f852                	sd	s4,48(sp)
     c88:	f456                	sd	s5,40(sp)
     c8a:	f05a                	sd	s6,32(sp)
     c8c:	ec5e                	sd	s7,24(sp)
     c8e:	1080                	addi	s0,sp,96
     c90:	8baa                	mv	s7,a0
     c92:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c94:	892a                	mv	s2,a0
     c96:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c98:	4aa9                	li	s5,10
     c9a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c9c:	89a6                	mv	s3,s1
     c9e:	2485                	addiw	s1,s1,1
     ca0:	0344d863          	bge	s1,s4,cd0 <gets+0x56>
    cc = read(0, &c, 1);
     ca4:	4605                	li	a2,1
     ca6:	faf40593          	addi	a1,s0,-81
     caa:	4501                	li	a0,0
     cac:	00000097          	auipc	ra,0x0
     cb0:	2ce080e7          	jalr	718(ra) # f7a <read>
    if(cc < 1)
     cb4:	00a05e63          	blez	a0,cd0 <gets+0x56>
    buf[i++] = c;
     cb8:	faf44783          	lbu	a5,-81(s0)
     cbc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cc0:	01578763          	beq	a5,s5,cce <gets+0x54>
     cc4:	0905                	addi	s2,s2,1
     cc6:	fd679be3          	bne	a5,s6,c9c <gets+0x22>
  for(i=0; i+1 < max; ){
     cca:	89a6                	mv	s3,s1
     ccc:	a011                	j	cd0 <gets+0x56>
     cce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cd0:	99de                	add	s3,s3,s7
     cd2:	00098023          	sb	zero,0(s3)
  return buf;
}
     cd6:	855e                	mv	a0,s7
     cd8:	60e6                	ld	ra,88(sp)
     cda:	6446                	ld	s0,80(sp)
     cdc:	64a6                	ld	s1,72(sp)
     cde:	6906                	ld	s2,64(sp)
     ce0:	79e2                	ld	s3,56(sp)
     ce2:	7a42                	ld	s4,48(sp)
     ce4:	7aa2                	ld	s5,40(sp)
     ce6:	7b02                	ld	s6,32(sp)
     ce8:	6be2                	ld	s7,24(sp)
     cea:	6125                	addi	sp,sp,96
     cec:	8082                	ret

0000000000000cee <stat>:

int
stat(const char *n, struct stat *st)
{
     cee:	1101                	addi	sp,sp,-32
     cf0:	ec06                	sd	ra,24(sp)
     cf2:	e822                	sd	s0,16(sp)
     cf4:	e426                	sd	s1,8(sp)
     cf6:	e04a                	sd	s2,0(sp)
     cf8:	1000                	addi	s0,sp,32
     cfa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cfc:	4581                	li	a1,0
     cfe:	00000097          	auipc	ra,0x0
     d02:	2a4080e7          	jalr	676(ra) # fa2 <open>
  if(fd < 0)
     d06:	02054563          	bltz	a0,d30 <stat+0x42>
     d0a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d0c:	85ca                	mv	a1,s2
     d0e:	00000097          	auipc	ra,0x0
     d12:	2ac080e7          	jalr	684(ra) # fba <fstat>
     d16:	892a                	mv	s2,a0
  close(fd);
     d18:	8526                	mv	a0,s1
     d1a:	00000097          	auipc	ra,0x0
     d1e:	270080e7          	jalr	624(ra) # f8a <close>
  return r;
}
     d22:	854a                	mv	a0,s2
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	64a2                	ld	s1,8(sp)
     d2a:	6902                	ld	s2,0(sp)
     d2c:	6105                	addi	sp,sp,32
     d2e:	8082                	ret
    return -1;
     d30:	597d                	li	s2,-1
     d32:	bfc5                	j	d22 <stat+0x34>

0000000000000d34 <atoi>:

int
atoi(const char *s)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e422                	sd	s0,8(sp)
     d38:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
     d3a:	00054683          	lbu	a3,0(a0)
     d3e:	fd06879b          	addiw	a5,a3,-48
     d42:	0ff7f793          	zext.b	a5,a5
     d46:	4625                	li	a2,9
     d48:	02f66863          	bltu	a2,a5,d78 <atoi+0x44>
     d4c:	872a                	mv	a4,a0
  n = 0;
     d4e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d50:	0705                	addi	a4,a4,1
     d52:	0025179b          	slliw	a5,a0,0x2
     d56:	9fa9                	addw	a5,a5,a0
     d58:	0017979b          	slliw	a5,a5,0x1
     d5c:	9fb5                	addw	a5,a5,a3
     d5e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d62:	00074683          	lbu	a3,0(a4)
     d66:	fd06879b          	addiw	a5,a3,-48
     d6a:	0ff7f793          	zext.b	a5,a5
     d6e:	fef671e3          	bgeu	a2,a5,d50 <atoi+0x1c>

  return n;
}
     d72:	6422                	ld	s0,8(sp)
     d74:	0141                	addi	sp,sp,16
     d76:	8082                	ret
  n = 0;
     d78:	4501                	li	a0,0
     d7a:	bfe5                	j	d72 <atoi+0x3e>

0000000000000d7c <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e422                	sd	s0,8(sp)
     d80:	0800                	addi	s0,sp,16
     d82:	8eaa                	mv	t4,a0
    register const char *s = strt;
     d84:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
     d86:	02000693          	li	a3,32
        c = *s++;
     d8a:	883e                	mv	a6,a5
     d8c:	0785                	addi	a5,a5,1
     d8e:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
     d92:	fed70ce3          	beq	a4,a3,d8a <strtoi+0xe>
        c = *s++;
     d96:	2701                	sext.w	a4,a4

    if (c == '-') {
     d98:	02d00693          	li	a3,45
     d9c:	04d70d63          	beq	a4,a3,df6 <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
     da0:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
     da4:	4f01                	li	t5,0
    } else if (c == '+')
     da6:	04d70e63          	beq	a4,a3,e02 <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
     daa:	fef67693          	andi	a3,a2,-17
     dae:	ea99                	bnez	a3,dc4 <strtoi+0x48>
     db0:	03000693          	li	a3,48
     db4:	04d70c63          	beq	a4,a3,e0c <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
     db8:	e611                	bnez	a2,dc4 <strtoi+0x48>
        base = c == '0' ? 8 : 10;
     dba:	03000693          	li	a3,48
     dbe:	0cd70b63          	beq	a4,a3,e94 <strtoi+0x118>
     dc2:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
     dc4:	800008b7          	lui	a7,0x80000
     dc8:	fff8c893          	not	a7,a7
     dcc:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
     dd0:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
     dd4:	1882                	slli	a7,a7,0x20
     dd6:	0208d893          	srli	a7,a7,0x20
     dda:	02c8d8b3          	divu	a7,a7,a2
     dde:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
     de2:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
     de6:	0ac75163          	bge	a4,a2,e88 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
     dea:	4681                	li	a3,0
     dec:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
     dee:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     df0:	2881                	sext.w	a7,a7
        else {
            any = 1;
     df2:	4f85                	li	t6,1
     df4:	a0a9                	j	e3e <strtoi+0xc2>
        c = *s++;
     df6:	0007c703          	lbu	a4,0(a5)
     dfa:	00280793          	addi	a5,a6,2
        neg = 1;
     dfe:	4f05                	li	t5,1
     e00:	b76d                	j	daa <strtoi+0x2e>
        c = *s++;
     e02:	0007c703          	lbu	a4,0(a5)
     e06:	00280793          	addi	a5,a6,2
     e0a:	b745                	j	daa <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
     e0c:	0007c683          	lbu	a3,0(a5)
     e10:	0df6f693          	andi	a3,a3,223
     e14:	05800513          	li	a0,88
     e18:	faa690e3          	bne	a3,a0,db8 <strtoi+0x3c>
        c = s[1];
     e1c:	0017c703          	lbu	a4,1(a5)
        s += 2;
     e20:	0789                	addi	a5,a5,2
        base = 16;
     e22:	4641                	li	a2,16
     e24:	b745                	j	dc4 <strtoi+0x48>
            any = -1;
     e26:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     e28:	00e2c463          	blt	t0,a4,e30 <strtoi+0xb4>
     e2c:	a015                	j	e50 <strtoi+0xd4>
            any = -1;
     e2e:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
     e30:	0785                	addi	a5,a5,1
     e32:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
     e36:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
     e3a:	02c75063          	bge	a4,a2,e5a <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     e3e:	fe06c8e3          	bltz	a3,e2e <strtoi+0xb2>
     e42:	0005081b          	sext.w	a6,a0
            any = -1;
     e46:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     e48:	ff0e64e3          	bltu	t3,a6,e30 <strtoi+0xb4>
     e4c:	fca88de3          	beq	a7,a0,e26 <strtoi+0xaa>
            acc *= base;
     e50:	02c5053b          	mulw	a0,a0,a2
            acc += c;
     e54:	9d39                	addw	a0,a0,a4
            any = 1;
     e56:	86fe                	mv	a3,t6
     e58:	bfe1                	j	e30 <strtoi+0xb4>
        }
    }
    if (any < 0) {
     e5a:	0006cd63          	bltz	a3,e74 <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
     e5e:	000f0463          	beqz	t5,e66 <strtoi+0xea>
        acc = -acc;
     e62:	40a0053b          	negw	a0,a0
    if (end != 0)
     e66:	c581                	beqz	a1,e6e <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
     e68:	ee89                	bnez	a3,e82 <strtoi+0x106>
     e6a:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
     e6e:	6422                	ld	s0,8(sp)
     e70:	0141                	addi	sp,sp,16
     e72:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
     e74:	000f1d63          	bnez	t5,e8e <strtoi+0x112>
     e78:	80000537          	lui	a0,0x80000
     e7c:	fff54513          	not	a0,a0
    if (end != 0)
     e80:	d5fd                	beqz	a1,e6e <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
     e82:	fff78e93          	addi	t4,a5,-1
     e86:	b7d5                	j	e6a <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
     e88:	4681                	li	a3,0
     e8a:	4501                	li	a0,0
     e8c:	bfc9                	j	e5e <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
     e8e:	80000537          	lui	a0,0x80000
     e92:	b7fd                	j	e80 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
     e94:	80000e37          	lui	t3,0x80000
     e98:	fffe4e13          	not	t3,t3
     e9c:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
     ea0:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
     ea4:	003e589b          	srliw	a7,t3,0x3
     ea8:	8e46                	mv	t3,a7
            c -= '0';
     eaa:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
     eac:	4621                	li	a2,8
     eae:	bf35                	j	dea <strtoi+0x6e>

0000000000000eb0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     eb0:	1141                	addi	sp,sp,-16
     eb2:	e422                	sd	s0,8(sp)
     eb4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     eb6:	02b57463          	bgeu	a0,a1,ede <memmove+0x2e>
    while(n-- > 0)
     eba:	00c05f63          	blez	a2,ed8 <memmove+0x28>
     ebe:	1602                	slli	a2,a2,0x20
     ec0:	9201                	srli	a2,a2,0x20
     ec2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ec6:	872a                	mv	a4,a0
      *dst++ = *src++;
     ec8:	0585                	addi	a1,a1,1
     eca:	0705                	addi	a4,a4,1
     ecc:	fff5c683          	lbu	a3,-1(a1)
     ed0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ed4:	fee79ae3          	bne	a5,a4,ec8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ed8:	6422                	ld	s0,8(sp)
     eda:	0141                	addi	sp,sp,16
     edc:	8082                	ret
    dst += n;
     ede:	00c50733          	add	a4,a0,a2
    src += n;
     ee2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     ee4:	fec05ae3          	blez	a2,ed8 <memmove+0x28>
     ee8:	fff6079b          	addiw	a5,a2,-1
     eec:	1782                	slli	a5,a5,0x20
     eee:	9381                	srli	a5,a5,0x20
     ef0:	fff7c793          	not	a5,a5
     ef4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ef6:	15fd                	addi	a1,a1,-1
     ef8:	177d                	addi	a4,a4,-1
     efa:	0005c683          	lbu	a3,0(a1)
     efe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     f02:	fee79ae3          	bne	a5,a4,ef6 <memmove+0x46>
     f06:	bfc9                	j	ed8 <memmove+0x28>

0000000000000f08 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     f08:	1141                	addi	sp,sp,-16
     f0a:	e422                	sd	s0,8(sp)
     f0c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     f0e:	ca05                	beqz	a2,f3e <memcmp+0x36>
     f10:	fff6069b          	addiw	a3,a2,-1
     f14:	1682                	slli	a3,a3,0x20
     f16:	9281                	srli	a3,a3,0x20
     f18:	0685                	addi	a3,a3,1
     f1a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     f1c:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffdbf8>
     f20:	0005c703          	lbu	a4,0(a1)
     f24:	00e79863          	bne	a5,a4,f34 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     f28:	0505                	addi	a0,a0,1
    p2++;
     f2a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     f2c:	fed518e3          	bne	a0,a3,f1c <memcmp+0x14>
  }
  return 0;
     f30:	4501                	li	a0,0
     f32:	a019                	j	f38 <memcmp+0x30>
      return *p1 - *p2;
     f34:	40e7853b          	subw	a0,a5,a4
}
     f38:	6422                	ld	s0,8(sp)
     f3a:	0141                	addi	sp,sp,16
     f3c:	8082                	ret
  return 0;
     f3e:	4501                	li	a0,0
     f40:	bfe5                	j	f38 <memcmp+0x30>

0000000000000f42 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     f42:	1141                	addi	sp,sp,-16
     f44:	e406                	sd	ra,8(sp)
     f46:	e022                	sd	s0,0(sp)
     f48:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     f4a:	00000097          	auipc	ra,0x0
     f4e:	f66080e7          	jalr	-154(ra) # eb0 <memmove>
}
     f52:	60a2                	ld	ra,8(sp)
     f54:	6402                	ld	s0,0(sp)
     f56:	0141                	addi	sp,sp,16
     f58:	8082                	ret

0000000000000f5a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     f5a:	4885                	li	a7,1
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <exit>:
.global exit
exit:
 li a7, SYS_exit
     f62:	4889                	li	a7,2
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <wait>:
.global wait
wait:
 li a7, SYS_wait
     f6a:	488d                	li	a7,3
 ecall
     f6c:	00000073          	ecall
 ret
     f70:	8082                	ret

0000000000000f72 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     f72:	4891                	li	a7,4
 ecall
     f74:	00000073          	ecall
 ret
     f78:	8082                	ret

0000000000000f7a <read>:
.global read
read:
 li a7, SYS_read
     f7a:	4895                	li	a7,5
 ecall
     f7c:	00000073          	ecall
 ret
     f80:	8082                	ret

0000000000000f82 <write>:
.global write
write:
 li a7, SYS_write
     f82:	48c1                	li	a7,16
 ecall
     f84:	00000073          	ecall
 ret
     f88:	8082                	ret

0000000000000f8a <close>:
.global close
close:
 li a7, SYS_close
     f8a:	48d5                	li	a7,21
 ecall
     f8c:	00000073          	ecall
 ret
     f90:	8082                	ret

0000000000000f92 <kill>:
.global kill
kill:
 li a7, SYS_kill
     f92:	4899                	li	a7,6
 ecall
     f94:	00000073          	ecall
 ret
     f98:	8082                	ret

0000000000000f9a <exec>:
.global exec
exec:
 li a7, SYS_exec
     f9a:	489d                	li	a7,7
 ecall
     f9c:	00000073          	ecall
 ret
     fa0:	8082                	ret

0000000000000fa2 <open>:
.global open
open:
 li a7, SYS_open
     fa2:	48bd                	li	a7,15
 ecall
     fa4:	00000073          	ecall
 ret
     fa8:	8082                	ret

0000000000000faa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     faa:	48c5                	li	a7,17
 ecall
     fac:	00000073          	ecall
 ret
     fb0:	8082                	ret

0000000000000fb2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     fb2:	48c9                	li	a7,18
 ecall
     fb4:	00000073          	ecall
 ret
     fb8:	8082                	ret

0000000000000fba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     fba:	48a1                	li	a7,8
 ecall
     fbc:	00000073          	ecall
 ret
     fc0:	8082                	ret

0000000000000fc2 <link>:
.global link
link:
 li a7, SYS_link
     fc2:	48cd                	li	a7,19
 ecall
     fc4:	00000073          	ecall
 ret
     fc8:	8082                	ret

0000000000000fca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     fca:	48d1                	li	a7,20
 ecall
     fcc:	00000073          	ecall
 ret
     fd0:	8082                	ret

0000000000000fd2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     fd2:	48a5                	li	a7,9
 ecall
     fd4:	00000073          	ecall
 ret
     fd8:	8082                	ret

0000000000000fda <dup>:
.global dup
dup:
 li a7, SYS_dup
     fda:	48a9                	li	a7,10
 ecall
     fdc:	00000073          	ecall
 ret
     fe0:	8082                	ret

0000000000000fe2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     fe2:	48ad                	li	a7,11
 ecall
     fe4:	00000073          	ecall
 ret
     fe8:	8082                	ret

0000000000000fea <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     fea:	48b1                	li	a7,12
 ecall
     fec:	00000073          	ecall
 ret
     ff0:	8082                	ret

0000000000000ff2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ff2:	48b5                	li	a7,13
 ecall
     ff4:	00000073          	ecall
 ret
     ff8:	8082                	ret

0000000000000ffa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ffa:	48b9                	li	a7,14
 ecall
     ffc:	00000073          	ecall
 ret
    1000:	8082                	ret

0000000000001002 <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
    1002:	48d9                	li	a7,22
 ecall
    1004:	00000073          	ecall
 ret
    1008:	8082                	ret

000000000000100a <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
    100a:	48dd                	li	a7,23
 ecall
    100c:	00000073          	ecall
 ret
    1010:	8082                	ret

0000000000001012 <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
    1012:	48e1                	li	a7,24
 ecall
    1014:	00000073          	ecall
 ret
    1018:	8082                	ret

000000000000101a <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
    101a:	48e5                	li	a7,25
 ecall
    101c:	00000073          	ecall
 ret
    1020:	8082                	ret

0000000000001022 <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
    1022:	48e9                	li	a7,26
 ecall
    1024:	00000073          	ecall
 ret
    1028:	8082                	ret

000000000000102a <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
    102a:	48ed                	li	a7,27
 ecall
    102c:	00000073          	ecall
 ret
    1030:	8082                	ret

0000000000001032 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    1032:	1101                	addi	sp,sp,-32
    1034:	ec06                	sd	ra,24(sp)
    1036:	e822                	sd	s0,16(sp)
    1038:	1000                	addi	s0,sp,32
    103a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    103e:	4605                	li	a2,1
    1040:	fef40593          	addi	a1,s0,-17
    1044:	00000097          	auipc	ra,0x0
    1048:	f3e080e7          	jalr	-194(ra) # f82 <write>
}
    104c:	60e2                	ld	ra,24(sp)
    104e:	6442                	ld	s0,16(sp)
    1050:	6105                	addi	sp,sp,32
    1052:	8082                	ret

0000000000001054 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1054:	7139                	addi	sp,sp,-64
    1056:	fc06                	sd	ra,56(sp)
    1058:	f822                	sd	s0,48(sp)
    105a:	f426                	sd	s1,40(sp)
    105c:	f04a                	sd	s2,32(sp)
    105e:	ec4e                	sd	s3,24(sp)
    1060:	0080                	addi	s0,sp,64
    1062:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    1064:	c299                	beqz	a3,106a <printint+0x16>
    1066:	0805c963          	bltz	a1,10f8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    106a:	2581                	sext.w	a1,a1
  neg = 0;
    106c:	4881                	li	a7,0
    106e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1072:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1074:	2601                	sext.w	a2,a2
    1076:	00000517          	auipc	a0,0x0
    107a:	7d250513          	addi	a0,a0,2002 # 1848 <digits>
    107e:	883a                	mv	a6,a4
    1080:	2705                	addiw	a4,a4,1
    1082:	02c5f7bb          	remuw	a5,a1,a2
    1086:	1782                	slli	a5,a5,0x20
    1088:	9381                	srli	a5,a5,0x20
    108a:	97aa                	add	a5,a5,a0
    108c:	0007c783          	lbu	a5,0(a5)
    1090:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1094:	0005879b          	sext.w	a5,a1
    1098:	02c5d5bb          	divuw	a1,a1,a2
    109c:	0685                	addi	a3,a3,1
    109e:	fec7f0e3          	bgeu	a5,a2,107e <printint+0x2a>
  if(neg)
    10a2:	00088c63          	beqz	a7,10ba <printint+0x66>
    buf[i++] = '-';
    10a6:	fd070793          	addi	a5,a4,-48
    10aa:	00878733          	add	a4,a5,s0
    10ae:	02d00793          	li	a5,45
    10b2:	fef70823          	sb	a5,-16(a4)
    10b6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    10ba:	02e05863          	blez	a4,10ea <printint+0x96>
    10be:	fc040793          	addi	a5,s0,-64
    10c2:	00e78933          	add	s2,a5,a4
    10c6:	fff78993          	addi	s3,a5,-1
    10ca:	99ba                	add	s3,s3,a4
    10cc:	377d                	addiw	a4,a4,-1
    10ce:	1702                	slli	a4,a4,0x20
    10d0:	9301                	srli	a4,a4,0x20
    10d2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    10d6:	fff94583          	lbu	a1,-1(s2)
    10da:	8526                	mv	a0,s1
    10dc:	00000097          	auipc	ra,0x0
    10e0:	f56080e7          	jalr	-170(ra) # 1032 <putc>
  while(--i >= 0)
    10e4:	197d                	addi	s2,s2,-1
    10e6:	ff3918e3          	bne	s2,s3,10d6 <printint+0x82>
}
    10ea:	70e2                	ld	ra,56(sp)
    10ec:	7442                	ld	s0,48(sp)
    10ee:	74a2                	ld	s1,40(sp)
    10f0:	7902                	ld	s2,32(sp)
    10f2:	69e2                	ld	s3,24(sp)
    10f4:	6121                	addi	sp,sp,64
    10f6:	8082                	ret
    x = -xx;
    10f8:	40b005bb          	negw	a1,a1
    neg = 1;
    10fc:	4885                	li	a7,1
    x = -xx;
    10fe:	bf85                	j	106e <printint+0x1a>

0000000000001100 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1100:	715d                	addi	sp,sp,-80
    1102:	e486                	sd	ra,72(sp)
    1104:	e0a2                	sd	s0,64(sp)
    1106:	fc26                	sd	s1,56(sp)
    1108:	f84a                	sd	s2,48(sp)
    110a:	f44e                	sd	s3,40(sp)
    110c:	f052                	sd	s4,32(sp)
    110e:	ec56                	sd	s5,24(sp)
    1110:	e85a                	sd	s6,16(sp)
    1112:	e45e                	sd	s7,8(sp)
    1114:	e062                	sd	s8,0(sp)
    1116:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1118:	0005c903          	lbu	s2,0(a1)
    111c:	18090c63          	beqz	s2,12b4 <vprintf+0x1b4>
    1120:	8aaa                	mv	s5,a0
    1122:	8bb2                	mv	s7,a2
    1124:	00158493          	addi	s1,a1,1
  state = 0;
    1128:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    112a:	02500a13          	li	s4,37
    112e:	4b55                	li	s6,21
    1130:	a839                	j	114e <vprintf+0x4e>
        putc(fd, c);
    1132:	85ca                	mv	a1,s2
    1134:	8556                	mv	a0,s5
    1136:	00000097          	auipc	ra,0x0
    113a:	efc080e7          	jalr	-260(ra) # 1032 <putc>
    113e:	a019                	j	1144 <vprintf+0x44>
    } else if(state == '%'){
    1140:	01498d63          	beq	s3,s4,115a <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
    1144:	0485                	addi	s1,s1,1
    1146:	fff4c903          	lbu	s2,-1(s1)
    114a:	16090563          	beqz	s2,12b4 <vprintf+0x1b4>
    if(state == 0){
    114e:	fe0999e3          	bnez	s3,1140 <vprintf+0x40>
      if(c == '%'){
    1152:	ff4910e3          	bne	s2,s4,1132 <vprintf+0x32>
        state = '%';
    1156:	89d2                	mv	s3,s4
    1158:	b7f5                	j	1144 <vprintf+0x44>
      if(c == 'd'){
    115a:	13490263          	beq	s2,s4,127e <vprintf+0x17e>
    115e:	f9d9079b          	addiw	a5,s2,-99
    1162:	0ff7f793          	zext.b	a5,a5
    1166:	12fb6563          	bltu	s6,a5,1290 <vprintf+0x190>
    116a:	f9d9079b          	addiw	a5,s2,-99
    116e:	0ff7f713          	zext.b	a4,a5
    1172:	10eb6f63          	bltu	s6,a4,1290 <vprintf+0x190>
    1176:	00271793          	slli	a5,a4,0x2
    117a:	00000717          	auipc	a4,0x0
    117e:	67670713          	addi	a4,a4,1654 # 17f0 <malloc+0x43e>
    1182:	97ba                	add	a5,a5,a4
    1184:	439c                	lw	a5,0(a5)
    1186:	97ba                	add	a5,a5,a4
    1188:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    118a:	008b8913          	addi	s2,s7,8
    118e:	4685                	li	a3,1
    1190:	4629                	li	a2,10
    1192:	000ba583          	lw	a1,0(s7)
    1196:	8556                	mv	a0,s5
    1198:	00000097          	auipc	ra,0x0
    119c:	ebc080e7          	jalr	-324(ra) # 1054 <printint>
    11a0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    11a2:	4981                	li	s3,0
    11a4:	b745                	j	1144 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    11a6:	008b8913          	addi	s2,s7,8
    11aa:	4681                	li	a3,0
    11ac:	4629                	li	a2,10
    11ae:	000ba583          	lw	a1,0(s7)
    11b2:	8556                	mv	a0,s5
    11b4:	00000097          	auipc	ra,0x0
    11b8:	ea0080e7          	jalr	-352(ra) # 1054 <printint>
    11bc:	8bca                	mv	s7,s2
      state = 0;
    11be:	4981                	li	s3,0
    11c0:	b751                	j	1144 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    11c2:	008b8913          	addi	s2,s7,8
    11c6:	4681                	li	a3,0
    11c8:	4641                	li	a2,16
    11ca:	000ba583          	lw	a1,0(s7)
    11ce:	8556                	mv	a0,s5
    11d0:	00000097          	auipc	ra,0x0
    11d4:	e84080e7          	jalr	-380(ra) # 1054 <printint>
    11d8:	8bca                	mv	s7,s2
      state = 0;
    11da:	4981                	li	s3,0
    11dc:	b7a5                	j	1144 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    11de:	008b8c13          	addi	s8,s7,8
    11e2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    11e6:	03000593          	li	a1,48
    11ea:	8556                	mv	a0,s5
    11ec:	00000097          	auipc	ra,0x0
    11f0:	e46080e7          	jalr	-442(ra) # 1032 <putc>
  putc(fd, 'x');
    11f4:	07800593          	li	a1,120
    11f8:	8556                	mv	a0,s5
    11fa:	00000097          	auipc	ra,0x0
    11fe:	e38080e7          	jalr	-456(ra) # 1032 <putc>
    1202:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1204:	00000b97          	auipc	s7,0x0
    1208:	644b8b93          	addi	s7,s7,1604 # 1848 <digits>
    120c:	03c9d793          	srli	a5,s3,0x3c
    1210:	97de                	add	a5,a5,s7
    1212:	0007c583          	lbu	a1,0(a5)
    1216:	8556                	mv	a0,s5
    1218:	00000097          	auipc	ra,0x0
    121c:	e1a080e7          	jalr	-486(ra) # 1032 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1220:	0992                	slli	s3,s3,0x4
    1222:	397d                	addiw	s2,s2,-1
    1224:	fe0914e3          	bnez	s2,120c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    1228:	8be2                	mv	s7,s8
      state = 0;
    122a:	4981                	li	s3,0
    122c:	bf21                	j	1144 <vprintf+0x44>
        s = va_arg(ap, char*);
    122e:	008b8993          	addi	s3,s7,8
    1232:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    1236:	02090163          	beqz	s2,1258 <vprintf+0x158>
        while(*s != 0){
    123a:	00094583          	lbu	a1,0(s2)
    123e:	c9a5                	beqz	a1,12ae <vprintf+0x1ae>
          putc(fd, *s);
    1240:	8556                	mv	a0,s5
    1242:	00000097          	auipc	ra,0x0
    1246:	df0080e7          	jalr	-528(ra) # 1032 <putc>
          s++;
    124a:	0905                	addi	s2,s2,1
        while(*s != 0){
    124c:	00094583          	lbu	a1,0(s2)
    1250:	f9e5                	bnez	a1,1240 <vprintf+0x140>
        s = va_arg(ap, char*);
    1252:	8bce                	mv	s7,s3
      state = 0;
    1254:	4981                	li	s3,0
    1256:	b5fd                	j	1144 <vprintf+0x44>
          s = "(null)";
    1258:	00000917          	auipc	s2,0x0
    125c:	59090913          	addi	s2,s2,1424 # 17e8 <malloc+0x436>
        while(*s != 0){
    1260:	02800593          	li	a1,40
    1264:	bff1                	j	1240 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    1266:	008b8913          	addi	s2,s7,8
    126a:	000bc583          	lbu	a1,0(s7)
    126e:	8556                	mv	a0,s5
    1270:	00000097          	auipc	ra,0x0
    1274:	dc2080e7          	jalr	-574(ra) # 1032 <putc>
    1278:	8bca                	mv	s7,s2
      state = 0;
    127a:	4981                	li	s3,0
    127c:	b5e1                	j	1144 <vprintf+0x44>
        putc(fd, c);
    127e:	02500593          	li	a1,37
    1282:	8556                	mv	a0,s5
    1284:	00000097          	auipc	ra,0x0
    1288:	dae080e7          	jalr	-594(ra) # 1032 <putc>
      state = 0;
    128c:	4981                	li	s3,0
    128e:	bd5d                	j	1144 <vprintf+0x44>
        putc(fd, '%');
    1290:	02500593          	li	a1,37
    1294:	8556                	mv	a0,s5
    1296:	00000097          	auipc	ra,0x0
    129a:	d9c080e7          	jalr	-612(ra) # 1032 <putc>
        putc(fd, c);
    129e:	85ca                	mv	a1,s2
    12a0:	8556                	mv	a0,s5
    12a2:	00000097          	auipc	ra,0x0
    12a6:	d90080e7          	jalr	-624(ra) # 1032 <putc>
      state = 0;
    12aa:	4981                	li	s3,0
    12ac:	bd61                	j	1144 <vprintf+0x44>
        s = va_arg(ap, char*);
    12ae:	8bce                	mv	s7,s3
      state = 0;
    12b0:	4981                	li	s3,0
    12b2:	bd49                	j	1144 <vprintf+0x44>
    }
  }
}
    12b4:	60a6                	ld	ra,72(sp)
    12b6:	6406                	ld	s0,64(sp)
    12b8:	74e2                	ld	s1,56(sp)
    12ba:	7942                	ld	s2,48(sp)
    12bc:	79a2                	ld	s3,40(sp)
    12be:	7a02                	ld	s4,32(sp)
    12c0:	6ae2                	ld	s5,24(sp)
    12c2:	6b42                	ld	s6,16(sp)
    12c4:	6ba2                	ld	s7,8(sp)
    12c6:	6c02                	ld	s8,0(sp)
    12c8:	6161                	addi	sp,sp,80
    12ca:	8082                	ret

00000000000012cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    12cc:	715d                	addi	sp,sp,-80
    12ce:	ec06                	sd	ra,24(sp)
    12d0:	e822                	sd	s0,16(sp)
    12d2:	1000                	addi	s0,sp,32
    12d4:	e010                	sd	a2,0(s0)
    12d6:	e414                	sd	a3,8(s0)
    12d8:	e818                	sd	a4,16(s0)
    12da:	ec1c                	sd	a5,24(s0)
    12dc:	03043023          	sd	a6,32(s0)
    12e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    12e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    12e8:	8622                	mv	a2,s0
    12ea:	00000097          	auipc	ra,0x0
    12ee:	e16080e7          	jalr	-490(ra) # 1100 <vprintf>
}
    12f2:	60e2                	ld	ra,24(sp)
    12f4:	6442                	ld	s0,16(sp)
    12f6:	6161                	addi	sp,sp,80
    12f8:	8082                	ret

00000000000012fa <printf>:

void
printf(const char *fmt, ...)
{
    12fa:	711d                	addi	sp,sp,-96
    12fc:	ec06                	sd	ra,24(sp)
    12fe:	e822                	sd	s0,16(sp)
    1300:	1000                	addi	s0,sp,32
    1302:	e40c                	sd	a1,8(s0)
    1304:	e810                	sd	a2,16(s0)
    1306:	ec14                	sd	a3,24(s0)
    1308:	f018                	sd	a4,32(s0)
    130a:	f41c                	sd	a5,40(s0)
    130c:	03043823          	sd	a6,48(s0)
    1310:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1314:	00840613          	addi	a2,s0,8
    1318:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    131c:	85aa                	mv	a1,a0
    131e:	4505                	li	a0,1
    1320:	00000097          	auipc	ra,0x0
    1324:	de0080e7          	jalr	-544(ra) # 1100 <vprintf>
}
    1328:	60e2                	ld	ra,24(sp)
    132a:	6442                	ld	s0,16(sp)
    132c:	6125                	addi	sp,sp,96
    132e:	8082                	ret

0000000000001330 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1330:	1141                	addi	sp,sp,-16
    1332:	e422                	sd	s0,8(sp)
    1334:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1336:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    133a:	00001797          	auipc	a5,0x1
    133e:	cd67b783          	ld	a5,-810(a5) # 2010 <freep>
    1342:	a02d                	j	136c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1344:	4618                	lw	a4,8(a2)
    1346:	9f2d                	addw	a4,a4,a1
    1348:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    134c:	6398                	ld	a4,0(a5)
    134e:	6310                	ld	a2,0(a4)
    1350:	a83d                	j	138e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1352:	ff852703          	lw	a4,-8(a0)
    1356:	9f31                	addw	a4,a4,a2
    1358:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    135a:	ff053683          	ld	a3,-16(a0)
    135e:	a091                	j	13a2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1360:	6398                	ld	a4,0(a5)
    1362:	00e7e463          	bltu	a5,a4,136a <free+0x3a>
    1366:	00e6ea63          	bltu	a3,a4,137a <free+0x4a>
{
    136a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    136c:	fed7fae3          	bgeu	a5,a3,1360 <free+0x30>
    1370:	6398                	ld	a4,0(a5)
    1372:	00e6e463          	bltu	a3,a4,137a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1376:	fee7eae3          	bltu	a5,a4,136a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    137a:	ff852583          	lw	a1,-8(a0)
    137e:	6390                	ld	a2,0(a5)
    1380:	02059813          	slli	a6,a1,0x20
    1384:	01c85713          	srli	a4,a6,0x1c
    1388:	9736                	add	a4,a4,a3
    138a:	fae60de3          	beq	a2,a4,1344 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    138e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1392:	4790                	lw	a2,8(a5)
    1394:	02061593          	slli	a1,a2,0x20
    1398:	01c5d713          	srli	a4,a1,0x1c
    139c:	973e                	add	a4,a4,a5
    139e:	fae68ae3          	beq	a3,a4,1352 <free+0x22>
    p->s.ptr = bp->s.ptr;
    13a2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    13a4:	00001717          	auipc	a4,0x1
    13a8:	c6f73623          	sd	a5,-916(a4) # 2010 <freep>
}
    13ac:	6422                	ld	s0,8(sp)
    13ae:	0141                	addi	sp,sp,16
    13b0:	8082                	ret

00000000000013b2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    13b2:	7139                	addi	sp,sp,-64
    13b4:	fc06                	sd	ra,56(sp)
    13b6:	f822                	sd	s0,48(sp)
    13b8:	f426                	sd	s1,40(sp)
    13ba:	f04a                	sd	s2,32(sp)
    13bc:	ec4e                	sd	s3,24(sp)
    13be:	e852                	sd	s4,16(sp)
    13c0:	e456                	sd	s5,8(sp)
    13c2:	e05a                	sd	s6,0(sp)
    13c4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13c6:	02051493          	slli	s1,a0,0x20
    13ca:	9081                	srli	s1,s1,0x20
    13cc:	04bd                	addi	s1,s1,15
    13ce:	8091                	srli	s1,s1,0x4
    13d0:	0014899b          	addiw	s3,s1,1
    13d4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    13d6:	00001517          	auipc	a0,0x1
    13da:	c3a53503          	ld	a0,-966(a0) # 2010 <freep>
    13de:	c515                	beqz	a0,140a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13e2:	4798                	lw	a4,8(a5)
    13e4:	02977f63          	bgeu	a4,s1,1422 <malloc+0x70>
  if(nu < 4096)
    13e8:	8a4e                	mv	s4,s3
    13ea:	0009871b          	sext.w	a4,s3
    13ee:	6685                	lui	a3,0x1
    13f0:	00d77363          	bgeu	a4,a3,13f6 <malloc+0x44>
    13f4:	6a05                	lui	s4,0x1
    13f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    13fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    13fe:	00001917          	auipc	s2,0x1
    1402:	c1290913          	addi	s2,s2,-1006 # 2010 <freep>
  if(p == (char*)-1)
    1406:	5afd                	li	s5,-1
    1408:	a895                	j	147c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    140a:	00001797          	auipc	a5,0x1
    140e:	ffe78793          	addi	a5,a5,-2 # 2408 <base>
    1412:	00001717          	auipc	a4,0x1
    1416:	bef73f23          	sd	a5,-1026(a4) # 2010 <freep>
    141a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    141c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1420:	b7e1                	j	13e8 <malloc+0x36>
      if(p->s.size == nunits)
    1422:	02e48c63          	beq	s1,a4,145a <malloc+0xa8>
        p->s.size -= nunits;
    1426:	4137073b          	subw	a4,a4,s3
    142a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    142c:	02071693          	slli	a3,a4,0x20
    1430:	01c6d713          	srli	a4,a3,0x1c
    1434:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1436:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    143a:	00001717          	auipc	a4,0x1
    143e:	bca73b23          	sd	a0,-1066(a4) # 2010 <freep>
      return (void*)(p + 1);
    1442:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1446:	70e2                	ld	ra,56(sp)
    1448:	7442                	ld	s0,48(sp)
    144a:	74a2                	ld	s1,40(sp)
    144c:	7902                	ld	s2,32(sp)
    144e:	69e2                	ld	s3,24(sp)
    1450:	6a42                	ld	s4,16(sp)
    1452:	6aa2                	ld	s5,8(sp)
    1454:	6b02                	ld	s6,0(sp)
    1456:	6121                	addi	sp,sp,64
    1458:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    145a:	6398                	ld	a4,0(a5)
    145c:	e118                	sd	a4,0(a0)
    145e:	bff1                	j	143a <malloc+0x88>
  hp->s.size = nu;
    1460:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1464:	0541                	addi	a0,a0,16
    1466:	00000097          	auipc	ra,0x0
    146a:	eca080e7          	jalr	-310(ra) # 1330 <free>
  return freep;
    146e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1472:	d971                	beqz	a0,1446 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1474:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1476:	4798                	lw	a4,8(a5)
    1478:	fa9775e3          	bgeu	a4,s1,1422 <malloc+0x70>
    if(p == freep)
    147c:	00093703          	ld	a4,0(s2)
    1480:	853e                	mv	a0,a5
    1482:	fef719e3          	bne	a4,a5,1474 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1486:	8552                	mv	a0,s4
    1488:	00000097          	auipc	ra,0x0
    148c:	b62080e7          	jalr	-1182(ra) # fea <sbrk>
  if(p == (char*)-1)
    1490:	fd5518e3          	bne	a0,s5,1460 <malloc+0xae>
        return 0;
    1494:	4501                	li	a0,0
    1496:	bf45                	j	1446 <malloc+0x94>
