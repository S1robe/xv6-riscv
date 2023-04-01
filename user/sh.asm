
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	44e58593          	addi	a1,a1,1102 # 1460 <malloc+0xe6>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	f2e080e7          	jalr	-210(ra) # f4a <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	bd2080e7          	jalr	-1070(ra) # bfc <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c0c080e7          	jalr	-1012(ra) # c42 <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0);
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	40858593          	addi	a1,a1,1032 # 1468 <malloc+0xee>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	22a080e7          	jalr	554(ra) # 1294 <fprintf>
  exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	eb6080e7          	jalr	-330(ra) # f2a <exit>

000000000000007c <fork1>:
}

int
fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	e9e080e7          	jalr	-354(ra) # f22 <fork>
  if(pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
    panic("fork");
  return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
    panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	3d650513          	addi	a0,a0,982 # 1470 <malloc+0xf6>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
  if(cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
  switch(cmd->type){
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	4aa70713          	addi	a4,a4,1194 # 1570 <malloc+0x1f6>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
    exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	e52080e7          	jalr	-430(ra) # f2a <exit>
    panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	39850513          	addi	a0,a0,920 # 1478 <malloc+0xfe>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	e6a080e7          	jalr	-406(ra) # f62 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	37e58593          	addi	a1,a1,894 # 1480 <malloc+0x106>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	188080e7          	jalr	392(ra) # 1294 <fprintf>
  exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	e14080e7          	jalr	-492(ra) # f2a <exit>
      exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	e0a080e7          	jalr	-502(ra) # f2a <exit>
    close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	e28080e7          	jalr	-472(ra) # f52 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	e34080e7          	jalr	-460(ra) # f6a <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
    runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	34258593          	addi	a1,a1,834 # 1490 <malloc+0x116>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	13c080e7          	jalr	316(ra) # 1294 <fprintf>
      exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	dc8080e7          	jalr	-568(ra) # f2a <exit>
    if(fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
      runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
    wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	db2080e7          	jalr	-590(ra) # f32 <wait>
    runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f20080e7          	jalr	-224(ra) # aa <runcmd>
    if(pipe(p) < 0)
     192:	fd840513          	addi	a0,s0,-40
     196:	00001097          	auipc	ra,0x1
     19a:	da4080e7          	jalr	-604(ra) # f3a <pipe>
     19e:	04054363          	bltz	a0,1e4 <runcmd+0x13a>
    if(fork1() == 0){
     1a2:	00000097          	auipc	ra,0x0
     1a6:	eda080e7          	jalr	-294(ra) # 7c <fork1>
     1aa:	e529                	bnez	a0,1f4 <runcmd+0x14a>
      close(1);
     1ac:	4505                	li	a0,1
     1ae:	00001097          	auipc	ra,0x1
     1b2:	da4080e7          	jalr	-604(ra) # f52 <close>
      dup(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	00001097          	auipc	ra,0x1
     1be:	de8080e7          	jalr	-536(ra) # fa2 <dup>
      close(p[0]);
     1c2:	fd842503          	lw	a0,-40(s0)
     1c6:	00001097          	auipc	ra,0x1
     1ca:	d8c080e7          	jalr	-628(ra) # f52 <close>
      close(p[1]);
     1ce:	fdc42503          	lw	a0,-36(s0)
     1d2:	00001097          	auipc	ra,0x1
     1d6:	d80080e7          	jalr	-640(ra) # f52 <close>
      runcmd(pcmd->left);
     1da:	6488                	ld	a0,8(s1)
     1dc:	00000097          	auipc	ra,0x0
     1e0:	ece080e7          	jalr	-306(ra) # aa <runcmd>
      panic("pipe");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	2bc50513          	addi	a0,a0,700 # 14a0 <malloc+0x126>
     1ec:	00000097          	auipc	ra,0x0
     1f0:	e6a080e7          	jalr	-406(ra) # 56 <panic>
    if(fork1() == 0){
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e88080e7          	jalr	-376(ra) # 7c <fork1>
     1fc:	ed05                	bnez	a0,234 <runcmd+0x18a>
      close(0);
     1fe:	00001097          	auipc	ra,0x1
     202:	d54080e7          	jalr	-684(ra) # f52 <close>
      dup(p[0]);
     206:	fd842503          	lw	a0,-40(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	d98080e7          	jalr	-616(ra) # fa2 <dup>
      close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	d3c080e7          	jalr	-708(ra) # f52 <close>
      close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	d30080e7          	jalr	-720(ra) # f52 <close>
      runcmd(pcmd->right);
     22a:	6888                	ld	a0,16(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e7e080e7          	jalr	-386(ra) # aa <runcmd>
    close(p[0]);
     234:	fd842503          	lw	a0,-40(s0)
     238:	00001097          	auipc	ra,0x1
     23c:	d1a080e7          	jalr	-742(ra) # f52 <close>
    close(p[1]);
     240:	fdc42503          	lw	a0,-36(s0)
     244:	00001097          	auipc	ra,0x1
     248:	d0e080e7          	jalr	-754(ra) # f52 <close>
    wait(0);
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	ce4080e7          	jalr	-796(ra) # f32 <wait>
    wait(0);
     256:	4501                	li	a0,0
     258:	00001097          	auipc	ra,0x1
     25c:	cda080e7          	jalr	-806(ra) # f32 <wait>
    break;
     260:	bd55                	j	114 <runcmd+0x6a>
    if(fork1() == 0)
     262:	00000097          	auipc	ra,0x0
     266:	e1a080e7          	jalr	-486(ra) # 7c <fork1>
     26a:	ea0515e3          	bnez	a0,114 <runcmd+0x6a>
      runcmd(bcmd->cmd);
     26e:	6488                	ld	a0,8(s1)
     270:	00000097          	auipc	ra,0x0
     274:	e3a080e7          	jalr	-454(ra) # aa <runcmd>

0000000000000278 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     278:	1101                	addi	sp,sp,-32
     27a:	ec06                	sd	ra,24(sp)
     27c:	e822                	sd	s0,16(sp)
     27e:	e426                	sd	s1,8(sp)
     280:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     282:	0a800513          	li	a0,168
     286:	00001097          	auipc	ra,0x1
     28a:	0f4080e7          	jalr	244(ra) # 137a <malloc>
     28e:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     290:	0a800613          	li	a2,168
     294:	4581                	li	a1,0
     296:	00001097          	auipc	ra,0x1
     29a:	966080e7          	jalr	-1690(ra) # bfc <memset>
  cmd->type = EXEC;
     29e:	4785                	li	a5,1
     2a0:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2a2:	8526                	mv	a0,s1
     2a4:	60e2                	ld	ra,24(sp)
     2a6:	6442                	ld	s0,16(sp)
     2a8:	64a2                	ld	s1,8(sp)
     2aa:	6105                	addi	sp,sp,32
     2ac:	8082                	ret

00000000000002ae <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ae:	7139                	addi	sp,sp,-64
     2b0:	fc06                	sd	ra,56(sp)
     2b2:	f822                	sd	s0,48(sp)
     2b4:	f426                	sd	s1,40(sp)
     2b6:	f04a                	sd	s2,32(sp)
     2b8:	ec4e                	sd	s3,24(sp)
     2ba:	e852                	sd	s4,16(sp)
     2bc:	e456                	sd	s5,8(sp)
     2be:	e05a                	sd	s6,0(sp)
     2c0:	0080                	addi	s0,sp,64
     2c2:	8b2a                	mv	s6,a0
     2c4:	8aae                	mv	s5,a1
     2c6:	8a32                	mv	s4,a2
     2c8:	89b6                	mv	s3,a3
     2ca:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2cc:	02800513          	li	a0,40
     2d0:	00001097          	auipc	ra,0x1
     2d4:	0aa080e7          	jalr	170(ra) # 137a <malloc>
     2d8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2da:	02800613          	li	a2,40
     2de:	4581                	li	a1,0
     2e0:	00001097          	auipc	ra,0x1
     2e4:	91c080e7          	jalr	-1764(ra) # bfc <memset>
  cmd->type = REDIR;
     2e8:	4789                	li	a5,2
     2ea:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2ec:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     2f0:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     2f4:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     2f8:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     2fc:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     300:	8526                	mv	a0,s1
     302:	70e2                	ld	ra,56(sp)
     304:	7442                	ld	s0,48(sp)
     306:	74a2                	ld	s1,40(sp)
     308:	7902                	ld	s2,32(sp)
     30a:	69e2                	ld	s3,24(sp)
     30c:	6a42                	ld	s4,16(sp)
     30e:	6aa2                	ld	s5,8(sp)
     310:	6b02                	ld	s6,0(sp)
     312:	6121                	addi	sp,sp,64
     314:	8082                	ret

0000000000000316 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     316:	7179                	addi	sp,sp,-48
     318:	f406                	sd	ra,40(sp)
     31a:	f022                	sd	s0,32(sp)
     31c:	ec26                	sd	s1,24(sp)
     31e:	e84a                	sd	s2,16(sp)
     320:	e44e                	sd	s3,8(sp)
     322:	1800                	addi	s0,sp,48
     324:	89aa                	mv	s3,a0
     326:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     328:	4561                	li	a0,24
     32a:	00001097          	auipc	ra,0x1
     32e:	050080e7          	jalr	80(ra) # 137a <malloc>
     332:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     334:	4661                	li	a2,24
     336:	4581                	li	a1,0
     338:	00001097          	auipc	ra,0x1
     33c:	8c4080e7          	jalr	-1852(ra) # bfc <memset>
  cmd->type = PIPE;
     340:	478d                	li	a5,3
     342:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     344:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     348:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     34c:	8526                	mv	a0,s1
     34e:	70a2                	ld	ra,40(sp)
     350:	7402                	ld	s0,32(sp)
     352:	64e2                	ld	s1,24(sp)
     354:	6942                	ld	s2,16(sp)
     356:	69a2                	ld	s3,8(sp)
     358:	6145                	addi	sp,sp,48
     35a:	8082                	ret

000000000000035c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	1800                	addi	s0,sp,48
     36a:	89aa                	mv	s3,a0
     36c:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     36e:	4561                	li	a0,24
     370:	00001097          	auipc	ra,0x1
     374:	00a080e7          	jalr	10(ra) # 137a <malloc>
     378:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     37a:	4661                	li	a2,24
     37c:	4581                	li	a1,0
     37e:	00001097          	auipc	ra,0x1
     382:	87e080e7          	jalr	-1922(ra) # bfc <memset>
  cmd->type = LIST;
     386:	4791                	li	a5,4
     388:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     38a:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     38e:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     392:	8526                	mv	a0,s1
     394:	70a2                	ld	ra,40(sp)
     396:	7402                	ld	s0,32(sp)
     398:	64e2                	ld	s1,24(sp)
     39a:	6942                	ld	s2,16(sp)
     39c:	69a2                	ld	s3,8(sp)
     39e:	6145                	addi	sp,sp,48
     3a0:	8082                	ret

00000000000003a2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	e04a                	sd	s2,0(sp)
     3ac:	1000                	addi	s0,sp,32
     3ae:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3b0:	4541                	li	a0,16
     3b2:	00001097          	auipc	ra,0x1
     3b6:	fc8080e7          	jalr	-56(ra) # 137a <malloc>
     3ba:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3bc:	4641                	li	a2,16
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	83c080e7          	jalr	-1988(ra) # bfc <memset>
  cmd->type = BACK;
     3c8:	4795                	li	a5,5
     3ca:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3cc:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3d0:	8526                	mv	a0,s1
     3d2:	60e2                	ld	ra,24(sp)
     3d4:	6442                	ld	s0,16(sp)
     3d6:	64a2                	ld	s1,8(sp)
     3d8:	6902                	ld	s2,0(sp)
     3da:	6105                	addi	sp,sp,32
     3dc:	8082                	ret

00000000000003de <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3de:	7139                	addi	sp,sp,-64
     3e0:	fc06                	sd	ra,56(sp)
     3e2:	f822                	sd	s0,48(sp)
     3e4:	f426                	sd	s1,40(sp)
     3e6:	f04a                	sd	s2,32(sp)
     3e8:	ec4e                	sd	s3,24(sp)
     3ea:	e852                	sd	s4,16(sp)
     3ec:	e456                	sd	s5,8(sp)
     3ee:	e05a                	sd	s6,0(sp)
     3f0:	0080                	addi	s0,sp,64
     3f2:	8a2a                	mv	s4,a0
     3f4:	892e                	mv	s2,a1
     3f6:	8ab2                	mv	s5,a2
     3f8:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     3fa:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     3fc:	00002997          	auipc	s3,0x2
     400:	c0c98993          	addi	s3,s3,-1012 # 2008 <whitespace>
     404:	00b4fe63          	bgeu	s1,a1,420 <gettoken+0x42>
     408:	0004c583          	lbu	a1,0(s1)
     40c:	854e                	mv	a0,s3
     40e:	00001097          	auipc	ra,0x1
     412:	810080e7          	jalr	-2032(ra) # c1e <strchr>
     416:	c509                	beqz	a0,420 <gettoken+0x42>
    s++;
     418:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     41a:	fe9917e3          	bne	s2,s1,408 <gettoken+0x2a>
    s++;
     41e:	84ca                	mv	s1,s2
  if(q)
     420:	000a8463          	beqz	s5,428 <gettoken+0x4a>
    *q = s;
     424:	009ab023          	sd	s1,0(s5)
  ret = *s;
     428:	0004c783          	lbu	a5,0(s1)
     42c:	00078a9b          	sext.w	s5,a5
  switch(*s){
     430:	03c00713          	li	a4,60
     434:	06f76663          	bltu	a4,a5,4a0 <gettoken+0xc2>
     438:	03a00713          	li	a4,58
     43c:	00f76e63          	bltu	a4,a5,458 <gettoken+0x7a>
     440:	cf89                	beqz	a5,45a <gettoken+0x7c>
     442:	02600713          	li	a4,38
     446:	00e78963          	beq	a5,a4,458 <gettoken+0x7a>
     44a:	fd87879b          	addiw	a5,a5,-40
     44e:	0ff7f793          	zext.b	a5,a5
     452:	4705                	li	a4,1
     454:	06f76d63          	bltu	a4,a5,4ce <gettoken+0xf0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     458:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     45a:	000b0463          	beqz	s6,462 <gettoken+0x84>
    *eq = s;
     45e:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     462:	00002997          	auipc	s3,0x2
     466:	ba698993          	addi	s3,s3,-1114 # 2008 <whitespace>
     46a:	0124fe63          	bgeu	s1,s2,486 <gettoken+0xa8>
     46e:	0004c583          	lbu	a1,0(s1)
     472:	854e                	mv	a0,s3
     474:	00000097          	auipc	ra,0x0
     478:	7aa080e7          	jalr	1962(ra) # c1e <strchr>
     47c:	c509                	beqz	a0,486 <gettoken+0xa8>
    s++;
     47e:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     480:	fe9917e3          	bne	s2,s1,46e <gettoken+0x90>
    s++;
     484:	84ca                	mv	s1,s2
  *ps = s;
     486:	009a3023          	sd	s1,0(s4)
  return ret;
}
     48a:	8556                	mv	a0,s5
     48c:	70e2                	ld	ra,56(sp)
     48e:	7442                	ld	s0,48(sp)
     490:	74a2                	ld	s1,40(sp)
     492:	7902                	ld	s2,32(sp)
     494:	69e2                	ld	s3,24(sp)
     496:	6a42                	ld	s4,16(sp)
     498:	6aa2                	ld	s5,8(sp)
     49a:	6b02                	ld	s6,0(sp)
     49c:	6121                	addi	sp,sp,64
     49e:	8082                	ret
  switch(*s){
     4a0:	03e00713          	li	a4,62
     4a4:	02e79163          	bne	a5,a4,4c6 <gettoken+0xe8>
    s++;
     4a8:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4ac:	0014c703          	lbu	a4,1(s1)
     4b0:	03e00793          	li	a5,62
      s++;
     4b4:	0489                	addi	s1,s1,2
      ret = '+';
     4b6:	02b00a93          	li	s5,43
    if(*s == '>'){
     4ba:	faf700e3          	beq	a4,a5,45a <gettoken+0x7c>
    s++;
     4be:	84b6                	mv	s1,a3
  ret = *s;
     4c0:	03e00a93          	li	s5,62
     4c4:	bf59                	j	45a <gettoken+0x7c>
  switch(*s){
     4c6:	07c00713          	li	a4,124
     4ca:	f8e787e3          	beq	a5,a4,458 <gettoken+0x7a>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4ce:	00002997          	auipc	s3,0x2
     4d2:	b3a98993          	addi	s3,s3,-1222 # 2008 <whitespace>
     4d6:	00002a97          	auipc	s5,0x2
     4da:	b2aa8a93          	addi	s5,s5,-1238 # 2000 <symbols>
     4de:	0524f163          	bgeu	s1,s2,520 <gettoken+0x142>
     4e2:	0004c583          	lbu	a1,0(s1)
     4e6:	854e                	mv	a0,s3
     4e8:	00000097          	auipc	ra,0x0
     4ec:	736080e7          	jalr	1846(ra) # c1e <strchr>
     4f0:	e50d                	bnez	a0,51a <gettoken+0x13c>
     4f2:	0004c583          	lbu	a1,0(s1)
     4f6:	8556                	mv	a0,s5
     4f8:	00000097          	auipc	ra,0x0
     4fc:	726080e7          	jalr	1830(ra) # c1e <strchr>
     500:	e911                	bnez	a0,514 <gettoken+0x136>
      s++;
     502:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     504:	fc991fe3          	bne	s2,s1,4e2 <gettoken+0x104>
      s++;
     508:	84ca                	mv	s1,s2
    ret = 'a';
     50a:	06100a93          	li	s5,97
  if(eq)
     50e:	f40b18e3          	bnez	s6,45e <gettoken+0x80>
     512:	bf95                	j	486 <gettoken+0xa8>
    ret = 'a';
     514:	06100a93          	li	s5,97
     518:	b789                	j	45a <gettoken+0x7c>
     51a:	06100a93          	li	s5,97
     51e:	bf35                	j	45a <gettoken+0x7c>
     520:	06100a93          	li	s5,97
  if(eq)
     524:	f20b1de3          	bnez	s6,45e <gettoken+0x80>
     528:	bfb9                	j	486 <gettoken+0xa8>

000000000000052a <peek>:

int
peek(char **ps, char *es, char *toks)
{
     52a:	7139                	addi	sp,sp,-64
     52c:	fc06                	sd	ra,56(sp)
     52e:	f822                	sd	s0,48(sp)
     530:	f426                	sd	s1,40(sp)
     532:	f04a                	sd	s2,32(sp)
     534:	ec4e                	sd	s3,24(sp)
     536:	e852                	sd	s4,16(sp)
     538:	e456                	sd	s5,8(sp)
     53a:	0080                	addi	s0,sp,64
     53c:	8a2a                	mv	s4,a0
     53e:	892e                	mv	s2,a1
     540:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     542:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     544:	00002997          	auipc	s3,0x2
     548:	ac498993          	addi	s3,s3,-1340 # 2008 <whitespace>
     54c:	00b4fe63          	bgeu	s1,a1,568 <peek+0x3e>
     550:	0004c583          	lbu	a1,0(s1)
     554:	854e                	mv	a0,s3
     556:	00000097          	auipc	ra,0x0
     55a:	6c8080e7          	jalr	1736(ra) # c1e <strchr>
     55e:	c509                	beqz	a0,568 <peek+0x3e>
    s++;
     560:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     562:	fe9917e3          	bne	s2,s1,550 <peek+0x26>
    s++;
     566:	84ca                	mv	s1,s2
  *ps = s;
     568:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     56c:	0004c583          	lbu	a1,0(s1)
     570:	4501                	li	a0,0
     572:	e991                	bnez	a1,586 <peek+0x5c>
}
     574:	70e2                	ld	ra,56(sp)
     576:	7442                	ld	s0,48(sp)
     578:	74a2                	ld	s1,40(sp)
     57a:	7902                	ld	s2,32(sp)
     57c:	69e2                	ld	s3,24(sp)
     57e:	6a42                	ld	s4,16(sp)
     580:	6aa2                	ld	s5,8(sp)
     582:	6121                	addi	sp,sp,64
     584:	8082                	ret
  return *s && strchr(toks, *s);
     586:	8556                	mv	a0,s5
     588:	00000097          	auipc	ra,0x0
     58c:	696080e7          	jalr	1686(ra) # c1e <strchr>
     590:	00a03533          	snez	a0,a0
     594:	b7c5                	j	574 <peek+0x4a>

0000000000000596 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     596:	7159                	addi	sp,sp,-112
     598:	f486                	sd	ra,104(sp)
     59a:	f0a2                	sd	s0,96(sp)
     59c:	eca6                	sd	s1,88(sp)
     59e:	e8ca                	sd	s2,80(sp)
     5a0:	e4ce                	sd	s3,72(sp)
     5a2:	e0d2                	sd	s4,64(sp)
     5a4:	fc56                	sd	s5,56(sp)
     5a6:	f85a                	sd	s6,48(sp)
     5a8:	f45e                	sd	s7,40(sp)
     5aa:	f062                	sd	s8,32(sp)
     5ac:	ec66                	sd	s9,24(sp)
     5ae:	1880                	addi	s0,sp,112
     5b0:	8a2a                	mv	s4,a0
     5b2:	89ae                	mv	s3,a1
     5b4:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5b6:	00001b97          	auipc	s7,0x1
     5ba:	f12b8b93          	addi	s7,s7,-238 # 14c8 <malloc+0x14e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5be:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5c2:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5c6:	a02d                	j	5f0 <parseredirs+0x5a>
      panic("missing file for redirection");
     5c8:	00001517          	auipc	a0,0x1
     5cc:	ee050513          	addi	a0,a0,-288 # 14a8 <malloc+0x12e>
     5d0:	00000097          	auipc	ra,0x0
     5d4:	a86080e7          	jalr	-1402(ra) # 56 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5d8:	4701                	li	a4,0
     5da:	4681                	li	a3,0
     5dc:	f9043603          	ld	a2,-112(s0)
     5e0:	f9843583          	ld	a1,-104(s0)
     5e4:	8552                	mv	a0,s4
     5e6:	00000097          	auipc	ra,0x0
     5ea:	cc8080e7          	jalr	-824(ra) # 2ae <redircmd>
     5ee:	8a2a                	mv	s4,a0
    switch(tok){
     5f0:	03e00b13          	li	s6,62
     5f4:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     5f8:	865e                	mv	a2,s7
     5fa:	85ca                	mv	a1,s2
     5fc:	854e                	mv	a0,s3
     5fe:	00000097          	auipc	ra,0x0
     602:	f2c080e7          	jalr	-212(ra) # 52a <peek>
     606:	c925                	beqz	a0,676 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     608:	4681                	li	a3,0
     60a:	4601                	li	a2,0
     60c:	85ca                	mv	a1,s2
     60e:	854e                	mv	a0,s3
     610:	00000097          	auipc	ra,0x0
     614:	dce080e7          	jalr	-562(ra) # 3de <gettoken>
     618:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     61a:	f9040693          	addi	a3,s0,-112
     61e:	f9840613          	addi	a2,s0,-104
     622:	85ca                	mv	a1,s2
     624:	854e                	mv	a0,s3
     626:	00000097          	auipc	ra,0x0
     62a:	db8080e7          	jalr	-584(ra) # 3de <gettoken>
     62e:	f9851de3          	bne	a0,s8,5c8 <parseredirs+0x32>
    switch(tok){
     632:	fb9483e3          	beq	s1,s9,5d8 <parseredirs+0x42>
     636:	03648263          	beq	s1,s6,65a <parseredirs+0xc4>
     63a:	fb549fe3          	bne	s1,s5,5f8 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     63e:	4705                	li	a4,1
     640:	20100693          	li	a3,513
     644:	f9043603          	ld	a2,-112(s0)
     648:	f9843583          	ld	a1,-104(s0)
     64c:	8552                	mv	a0,s4
     64e:	00000097          	auipc	ra,0x0
     652:	c60080e7          	jalr	-928(ra) # 2ae <redircmd>
     656:	8a2a                	mv	s4,a0
      break;
     658:	bf61                	j	5f0 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     65a:	4705                	li	a4,1
     65c:	60100693          	li	a3,1537
     660:	f9043603          	ld	a2,-112(s0)
     664:	f9843583          	ld	a1,-104(s0)
     668:	8552                	mv	a0,s4
     66a:	00000097          	auipc	ra,0x0
     66e:	c44080e7          	jalr	-956(ra) # 2ae <redircmd>
     672:	8a2a                	mv	s4,a0
      break;
     674:	bfb5                	j	5f0 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     676:	8552                	mv	a0,s4
     678:	70a6                	ld	ra,104(sp)
     67a:	7406                	ld	s0,96(sp)
     67c:	64e6                	ld	s1,88(sp)
     67e:	6946                	ld	s2,80(sp)
     680:	69a6                	ld	s3,72(sp)
     682:	6a06                	ld	s4,64(sp)
     684:	7ae2                	ld	s5,56(sp)
     686:	7b42                	ld	s6,48(sp)
     688:	7ba2                	ld	s7,40(sp)
     68a:	7c02                	ld	s8,32(sp)
     68c:	6ce2                	ld	s9,24(sp)
     68e:	6165                	addi	sp,sp,112
     690:	8082                	ret

0000000000000692 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     692:	7159                	addi	sp,sp,-112
     694:	f486                	sd	ra,104(sp)
     696:	f0a2                	sd	s0,96(sp)
     698:	eca6                	sd	s1,88(sp)
     69a:	e8ca                	sd	s2,80(sp)
     69c:	e4ce                	sd	s3,72(sp)
     69e:	e0d2                	sd	s4,64(sp)
     6a0:	fc56                	sd	s5,56(sp)
     6a2:	f85a                	sd	s6,48(sp)
     6a4:	f45e                	sd	s7,40(sp)
     6a6:	f062                	sd	s8,32(sp)
     6a8:	ec66                	sd	s9,24(sp)
     6aa:	1880                	addi	s0,sp,112
     6ac:	8a2a                	mv	s4,a0
     6ae:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6b0:	00001617          	auipc	a2,0x1
     6b4:	e2060613          	addi	a2,a2,-480 # 14d0 <malloc+0x156>
     6b8:	00000097          	auipc	ra,0x0
     6bc:	e72080e7          	jalr	-398(ra) # 52a <peek>
     6c0:	e905                	bnez	a0,6f0 <parseexec+0x5e>
     6c2:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6c4:	00000097          	auipc	ra,0x0
     6c8:	bb4080e7          	jalr	-1100(ra) # 278 <execcmd>
     6cc:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6ce:	8656                	mv	a2,s5
     6d0:	85d2                	mv	a1,s4
     6d2:	00000097          	auipc	ra,0x0
     6d6:	ec4080e7          	jalr	-316(ra) # 596 <parseredirs>
     6da:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6dc:	008c0913          	addi	s2,s8,8
     6e0:	00001b17          	auipc	s6,0x1
     6e4:	e10b0b13          	addi	s6,s6,-496 # 14f0 <malloc+0x176>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     6e8:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6ec:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     6ee:	a0b1                	j	73a <parseexec+0xa8>
    return parseblock(ps, es);
     6f0:	85d6                	mv	a1,s5
     6f2:	8552                	mv	a0,s4
     6f4:	00000097          	auipc	ra,0x0
     6f8:	1bc080e7          	jalr	444(ra) # 8b0 <parseblock>
     6fc:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     6fe:	8526                	mv	a0,s1
     700:	70a6                	ld	ra,104(sp)
     702:	7406                	ld	s0,96(sp)
     704:	64e6                	ld	s1,88(sp)
     706:	6946                	ld	s2,80(sp)
     708:	69a6                	ld	s3,72(sp)
     70a:	6a06                	ld	s4,64(sp)
     70c:	7ae2                	ld	s5,56(sp)
     70e:	7b42                	ld	s6,48(sp)
     710:	7ba2                	ld	s7,40(sp)
     712:	7c02                	ld	s8,32(sp)
     714:	6ce2                	ld	s9,24(sp)
     716:	6165                	addi	sp,sp,112
     718:	8082                	ret
      panic("syntax");
     71a:	00001517          	auipc	a0,0x1
     71e:	dbe50513          	addi	a0,a0,-578 # 14d8 <malloc+0x15e>
     722:	00000097          	auipc	ra,0x0
     726:	934080e7          	jalr	-1740(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     72a:	8656                	mv	a2,s5
     72c:	85d2                	mv	a1,s4
     72e:	8526                	mv	a0,s1
     730:	00000097          	auipc	ra,0x0
     734:	e66080e7          	jalr	-410(ra) # 596 <parseredirs>
     738:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     73a:	865a                	mv	a2,s6
     73c:	85d6                	mv	a1,s5
     73e:	8552                	mv	a0,s4
     740:	00000097          	auipc	ra,0x0
     744:	dea080e7          	jalr	-534(ra) # 52a <peek>
     748:	e131                	bnez	a0,78c <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     74a:	f9040693          	addi	a3,s0,-112
     74e:	f9840613          	addi	a2,s0,-104
     752:	85d6                	mv	a1,s5
     754:	8552                	mv	a0,s4
     756:	00000097          	auipc	ra,0x0
     75a:	c88080e7          	jalr	-888(ra) # 3de <gettoken>
     75e:	c51d                	beqz	a0,78c <parseexec+0xfa>
    if(tok != 'a')
     760:	fb951de3          	bne	a0,s9,71a <parseexec+0x88>
    cmd->argv[argc] = q;
     764:	f9843783          	ld	a5,-104(s0)
     768:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     76c:	f9043783          	ld	a5,-112(s0)
     770:	04f93823          	sd	a5,80(s2)
    argc++;
     774:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     776:	0921                	addi	s2,s2,8
     778:	fb7999e3          	bne	s3,s7,72a <parseexec+0x98>
      panic("too many args");
     77c:	00001517          	auipc	a0,0x1
     780:	d6450513          	addi	a0,a0,-668 # 14e0 <malloc+0x166>
     784:	00000097          	auipc	ra,0x0
     788:	8d2080e7          	jalr	-1838(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     78c:	098e                	slli	s3,s3,0x3
     78e:	9c4e                	add	s8,s8,s3
     790:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     794:	040c3c23          	sd	zero,88(s8)
  return ret;
     798:	b79d                	j	6fe <parseexec+0x6c>

000000000000079a <parsepipe>:
{
     79a:	7179                	addi	sp,sp,-48
     79c:	f406                	sd	ra,40(sp)
     79e:	f022                	sd	s0,32(sp)
     7a0:	ec26                	sd	s1,24(sp)
     7a2:	e84a                	sd	s2,16(sp)
     7a4:	e44e                	sd	s3,8(sp)
     7a6:	1800                	addi	s0,sp,48
     7a8:	892a                	mv	s2,a0
     7aa:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7ac:	00000097          	auipc	ra,0x0
     7b0:	ee6080e7          	jalr	-282(ra) # 692 <parseexec>
     7b4:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7b6:	00001617          	auipc	a2,0x1
     7ba:	d4260613          	addi	a2,a2,-702 # 14f8 <malloc+0x17e>
     7be:	85ce                	mv	a1,s3
     7c0:	854a                	mv	a0,s2
     7c2:	00000097          	auipc	ra,0x0
     7c6:	d68080e7          	jalr	-664(ra) # 52a <peek>
     7ca:	e909                	bnez	a0,7dc <parsepipe+0x42>
}
     7cc:	8526                	mv	a0,s1
     7ce:	70a2                	ld	ra,40(sp)
     7d0:	7402                	ld	s0,32(sp)
     7d2:	64e2                	ld	s1,24(sp)
     7d4:	6942                	ld	s2,16(sp)
     7d6:	69a2                	ld	s3,8(sp)
     7d8:	6145                	addi	sp,sp,48
     7da:	8082                	ret
    gettoken(ps, es, 0, 0);
     7dc:	4681                	li	a3,0
     7de:	4601                	li	a2,0
     7e0:	85ce                	mv	a1,s3
     7e2:	854a                	mv	a0,s2
     7e4:	00000097          	auipc	ra,0x0
     7e8:	bfa080e7          	jalr	-1030(ra) # 3de <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7ec:	85ce                	mv	a1,s3
     7ee:	854a                	mv	a0,s2
     7f0:	00000097          	auipc	ra,0x0
     7f4:	faa080e7          	jalr	-86(ra) # 79a <parsepipe>
     7f8:	85aa                	mv	a1,a0
     7fa:	8526                	mv	a0,s1
     7fc:	00000097          	auipc	ra,0x0
     800:	b1a080e7          	jalr	-1254(ra) # 316 <pipecmd>
     804:	84aa                	mv	s1,a0
  return cmd;
     806:	b7d9                	j	7cc <parsepipe+0x32>

0000000000000808 <parseline>:
{
     808:	7179                	addi	sp,sp,-48
     80a:	f406                	sd	ra,40(sp)
     80c:	f022                	sd	s0,32(sp)
     80e:	ec26                	sd	s1,24(sp)
     810:	e84a                	sd	s2,16(sp)
     812:	e44e                	sd	s3,8(sp)
     814:	e052                	sd	s4,0(sp)
     816:	1800                	addi	s0,sp,48
     818:	892a                	mv	s2,a0
     81a:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     81c:	00000097          	auipc	ra,0x0
     820:	f7e080e7          	jalr	-130(ra) # 79a <parsepipe>
     824:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     826:	00001a17          	auipc	s4,0x1
     82a:	cdaa0a13          	addi	s4,s4,-806 # 1500 <malloc+0x186>
     82e:	a839                	j	84c <parseline+0x44>
    gettoken(ps, es, 0, 0);
     830:	4681                	li	a3,0
     832:	4601                	li	a2,0
     834:	85ce                	mv	a1,s3
     836:	854a                	mv	a0,s2
     838:	00000097          	auipc	ra,0x0
     83c:	ba6080e7          	jalr	-1114(ra) # 3de <gettoken>
    cmd = backcmd(cmd);
     840:	8526                	mv	a0,s1
     842:	00000097          	auipc	ra,0x0
     846:	b60080e7          	jalr	-1184(ra) # 3a2 <backcmd>
     84a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     84c:	8652                	mv	a2,s4
     84e:	85ce                	mv	a1,s3
     850:	854a                	mv	a0,s2
     852:	00000097          	auipc	ra,0x0
     856:	cd8080e7          	jalr	-808(ra) # 52a <peek>
     85a:	f979                	bnez	a0,830 <parseline+0x28>
  if(peek(ps, es, ";")){
     85c:	00001617          	auipc	a2,0x1
     860:	cac60613          	addi	a2,a2,-852 # 1508 <malloc+0x18e>
     864:	85ce                	mv	a1,s3
     866:	854a                	mv	a0,s2
     868:	00000097          	auipc	ra,0x0
     86c:	cc2080e7          	jalr	-830(ra) # 52a <peek>
     870:	e911                	bnez	a0,884 <parseline+0x7c>
}
     872:	8526                	mv	a0,s1
     874:	70a2                	ld	ra,40(sp)
     876:	7402                	ld	s0,32(sp)
     878:	64e2                	ld	s1,24(sp)
     87a:	6942                	ld	s2,16(sp)
     87c:	69a2                	ld	s3,8(sp)
     87e:	6a02                	ld	s4,0(sp)
     880:	6145                	addi	sp,sp,48
     882:	8082                	ret
    gettoken(ps, es, 0, 0);
     884:	4681                	li	a3,0
     886:	4601                	li	a2,0
     888:	85ce                	mv	a1,s3
     88a:	854a                	mv	a0,s2
     88c:	00000097          	auipc	ra,0x0
     890:	b52080e7          	jalr	-1198(ra) # 3de <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     894:	85ce                	mv	a1,s3
     896:	854a                	mv	a0,s2
     898:	00000097          	auipc	ra,0x0
     89c:	f70080e7          	jalr	-144(ra) # 808 <parseline>
     8a0:	85aa                	mv	a1,a0
     8a2:	8526                	mv	a0,s1
     8a4:	00000097          	auipc	ra,0x0
     8a8:	ab8080e7          	jalr	-1352(ra) # 35c <listcmd>
     8ac:	84aa                	mv	s1,a0
  return cmd;
     8ae:	b7d1                	j	872 <parseline+0x6a>

00000000000008b0 <parseblock>:
{
     8b0:	7179                	addi	sp,sp,-48
     8b2:	f406                	sd	ra,40(sp)
     8b4:	f022                	sd	s0,32(sp)
     8b6:	ec26                	sd	s1,24(sp)
     8b8:	e84a                	sd	s2,16(sp)
     8ba:	e44e                	sd	s3,8(sp)
     8bc:	1800                	addi	s0,sp,48
     8be:	84aa                	mv	s1,a0
     8c0:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8c2:	00001617          	auipc	a2,0x1
     8c6:	c0e60613          	addi	a2,a2,-1010 # 14d0 <malloc+0x156>
     8ca:	00000097          	auipc	ra,0x0
     8ce:	c60080e7          	jalr	-928(ra) # 52a <peek>
     8d2:	c12d                	beqz	a0,934 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8d4:	4681                	li	a3,0
     8d6:	4601                	li	a2,0
     8d8:	85ca                	mv	a1,s2
     8da:	8526                	mv	a0,s1
     8dc:	00000097          	auipc	ra,0x0
     8e0:	b02080e7          	jalr	-1278(ra) # 3de <gettoken>
  cmd = parseline(ps, es);
     8e4:	85ca                	mv	a1,s2
     8e6:	8526                	mv	a0,s1
     8e8:	00000097          	auipc	ra,0x0
     8ec:	f20080e7          	jalr	-224(ra) # 808 <parseline>
     8f0:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8f2:	00001617          	auipc	a2,0x1
     8f6:	c2e60613          	addi	a2,a2,-978 # 1520 <malloc+0x1a6>
     8fa:	85ca                	mv	a1,s2
     8fc:	8526                	mv	a0,s1
     8fe:	00000097          	auipc	ra,0x0
     902:	c2c080e7          	jalr	-980(ra) # 52a <peek>
     906:	cd1d                	beqz	a0,944 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     908:	4681                	li	a3,0
     90a:	4601                	li	a2,0
     90c:	85ca                	mv	a1,s2
     90e:	8526                	mv	a0,s1
     910:	00000097          	auipc	ra,0x0
     914:	ace080e7          	jalr	-1330(ra) # 3de <gettoken>
  cmd = parseredirs(cmd, ps, es);
     918:	864a                	mv	a2,s2
     91a:	85a6                	mv	a1,s1
     91c:	854e                	mv	a0,s3
     91e:	00000097          	auipc	ra,0x0
     922:	c78080e7          	jalr	-904(ra) # 596 <parseredirs>
}
     926:	70a2                	ld	ra,40(sp)
     928:	7402                	ld	s0,32(sp)
     92a:	64e2                	ld	s1,24(sp)
     92c:	6942                	ld	s2,16(sp)
     92e:	69a2                	ld	s3,8(sp)
     930:	6145                	addi	sp,sp,48
     932:	8082                	ret
    panic("parseblock");
     934:	00001517          	auipc	a0,0x1
     938:	bdc50513          	addi	a0,a0,-1060 # 1510 <malloc+0x196>
     93c:	fffff097          	auipc	ra,0xfffff
     940:	71a080e7          	jalr	1818(ra) # 56 <panic>
    panic("syntax - missing )");
     944:	00001517          	auipc	a0,0x1
     948:	be450513          	addi	a0,a0,-1052 # 1528 <malloc+0x1ae>
     94c:	fffff097          	auipc	ra,0xfffff
     950:	70a080e7          	jalr	1802(ra) # 56 <panic>

0000000000000954 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     954:	1101                	addi	sp,sp,-32
     956:	ec06                	sd	ra,24(sp)
     958:	e822                	sd	s0,16(sp)
     95a:	e426                	sd	s1,8(sp)
     95c:	1000                	addi	s0,sp,32
     95e:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     960:	c521                	beqz	a0,9a8 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     962:	4118                	lw	a4,0(a0)
     964:	4795                	li	a5,5
     966:	04e7e163          	bltu	a5,a4,9a8 <nulterminate+0x54>
     96a:	00056783          	lwu	a5,0(a0)
     96e:	078a                	slli	a5,a5,0x2
     970:	00001717          	auipc	a4,0x1
     974:	c1870713          	addi	a4,a4,-1000 # 1588 <malloc+0x20e>
     978:	97ba                	add	a5,a5,a4
     97a:	439c                	lw	a5,0(a5)
     97c:	97ba                	add	a5,a5,a4
     97e:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     980:	651c                	ld	a5,8(a0)
     982:	c39d                	beqz	a5,9a8 <nulterminate+0x54>
     984:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     988:	67b8                	ld	a4,72(a5)
     98a:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     98e:	07a1                	addi	a5,a5,8
     990:	ff87b703          	ld	a4,-8(a5)
     994:	fb75                	bnez	a4,988 <nulterminate+0x34>
     996:	a809                	j	9a8 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     998:	6508                	ld	a0,8(a0)
     99a:	00000097          	auipc	ra,0x0
     99e:	fba080e7          	jalr	-70(ra) # 954 <nulterminate>
    *rcmd->efile = 0;
     9a2:	6c9c                	ld	a5,24(s1)
     9a4:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9a8:	8526                	mv	a0,s1
     9aa:	60e2                	ld	ra,24(sp)
     9ac:	6442                	ld	s0,16(sp)
     9ae:	64a2                	ld	s1,8(sp)
     9b0:	6105                	addi	sp,sp,32
     9b2:	8082                	ret
    nulterminate(pcmd->left);
     9b4:	6508                	ld	a0,8(a0)
     9b6:	00000097          	auipc	ra,0x0
     9ba:	f9e080e7          	jalr	-98(ra) # 954 <nulterminate>
    nulterminate(pcmd->right);
     9be:	6888                	ld	a0,16(s1)
     9c0:	00000097          	auipc	ra,0x0
     9c4:	f94080e7          	jalr	-108(ra) # 954 <nulterminate>
    break;
     9c8:	b7c5                	j	9a8 <nulterminate+0x54>
    nulterminate(lcmd->left);
     9ca:	6508                	ld	a0,8(a0)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f88080e7          	jalr	-120(ra) # 954 <nulterminate>
    nulterminate(lcmd->right);
     9d4:	6888                	ld	a0,16(s1)
     9d6:	00000097          	auipc	ra,0x0
     9da:	f7e080e7          	jalr	-130(ra) # 954 <nulterminate>
    break;
     9de:	b7e9                	j	9a8 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9e0:	6508                	ld	a0,8(a0)
     9e2:	00000097          	auipc	ra,0x0
     9e6:	f72080e7          	jalr	-142(ra) # 954 <nulterminate>
    break;
     9ea:	bf7d                	j	9a8 <nulterminate+0x54>

00000000000009ec <parsecmd>:
{
     9ec:	7179                	addi	sp,sp,-48
     9ee:	f406                	sd	ra,40(sp)
     9f0:	f022                	sd	s0,32(sp)
     9f2:	ec26                	sd	s1,24(sp)
     9f4:	e84a                	sd	s2,16(sp)
     9f6:	1800                	addi	s0,sp,48
     9f8:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9fc:	84aa                	mv	s1,a0
     9fe:	00000097          	auipc	ra,0x0
     a02:	1d4080e7          	jalr	468(ra) # bd2 <strlen>
     a06:	1502                	slli	a0,a0,0x20
     a08:	9101                	srli	a0,a0,0x20
     a0a:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a0c:	85a6                	mv	a1,s1
     a0e:	fd840513          	addi	a0,s0,-40
     a12:	00000097          	auipc	ra,0x0
     a16:	df6080e7          	jalr	-522(ra) # 808 <parseline>
     a1a:	892a                	mv	s2,a0
  peek(&s, es, "");
     a1c:	00001617          	auipc	a2,0x1
     a20:	b2460613          	addi	a2,a2,-1244 # 1540 <malloc+0x1c6>
     a24:	85a6                	mv	a1,s1
     a26:	fd840513          	addi	a0,s0,-40
     a2a:	00000097          	auipc	ra,0x0
     a2e:	b00080e7          	jalr	-1280(ra) # 52a <peek>
  if(s != es){
     a32:	fd843603          	ld	a2,-40(s0)
     a36:	00961e63          	bne	a2,s1,a52 <parsecmd+0x66>
  nulterminate(cmd);
     a3a:	854a                	mv	a0,s2
     a3c:	00000097          	auipc	ra,0x0
     a40:	f18080e7          	jalr	-232(ra) # 954 <nulterminate>
}
     a44:	854a                	mv	a0,s2
     a46:	70a2                	ld	ra,40(sp)
     a48:	7402                	ld	s0,32(sp)
     a4a:	64e2                	ld	s1,24(sp)
     a4c:	6942                	ld	s2,16(sp)
     a4e:	6145                	addi	sp,sp,48
     a50:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a52:	00001597          	auipc	a1,0x1
     a56:	af658593          	addi	a1,a1,-1290 # 1548 <malloc+0x1ce>
     a5a:	4509                	li	a0,2
     a5c:	00001097          	auipc	ra,0x1
     a60:	838080e7          	jalr	-1992(ra) # 1294 <fprintf>
    panic("syntax");
     a64:	00001517          	auipc	a0,0x1
     a68:	a7450513          	addi	a0,a0,-1420 # 14d8 <malloc+0x15e>
     a6c:	fffff097          	auipc	ra,0xfffff
     a70:	5ea080e7          	jalr	1514(ra) # 56 <panic>

0000000000000a74 <main>:
{
     a74:	7179                	addi	sp,sp,-48
     a76:	f406                	sd	ra,40(sp)
     a78:	f022                	sd	s0,32(sp)
     a7a:	ec26                	sd	s1,24(sp)
     a7c:	e84a                	sd	s2,16(sp)
     a7e:	e44e                	sd	s3,8(sp)
     a80:	e052                	sd	s4,0(sp)
     a82:	1800                	addi	s0,sp,48
  while((fd = open("console", O_RDWR)) >= 0){
     a84:	00001497          	auipc	s1,0x1
     a88:	ad448493          	addi	s1,s1,-1324 # 1558 <malloc+0x1de>
     a8c:	4589                	li	a1,2
     a8e:	8526                	mv	a0,s1
     a90:	00000097          	auipc	ra,0x0
     a94:	4da080e7          	jalr	1242(ra) # f6a <open>
     a98:	00054963          	bltz	a0,aaa <main+0x36>
    if(fd >= 3){
     a9c:	4789                	li	a5,2
     a9e:	fea7d7e3          	bge	a5,a0,a8c <main+0x18>
      close(fd);
     aa2:	00000097          	auipc	ra,0x0
     aa6:	4b0080e7          	jalr	1200(ra) # f52 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     aaa:	00001497          	auipc	s1,0x1
     aae:	57648493          	addi	s1,s1,1398 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ab2:	06300913          	li	s2,99
     ab6:	02000993          	li	s3,32
     aba:	a819                	j	ad0 <main+0x5c>
    if(fork1() == 0)
     abc:	fffff097          	auipc	ra,0xfffff
     ac0:	5c0080e7          	jalr	1472(ra) # 7c <fork1>
     ac4:	c549                	beqz	a0,b4e <main+0xda>
    wait(0);
     ac6:	4501                	li	a0,0
     ac8:	00000097          	auipc	ra,0x0
     acc:	46a080e7          	jalr	1130(ra) # f32 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ad0:	06400593          	li	a1,100
     ad4:	8526                	mv	a0,s1
     ad6:	fffff097          	auipc	ra,0xfffff
     ada:	52a080e7          	jalr	1322(ra) # 0 <getcmd>
     ade:	08054463          	bltz	a0,b66 <main+0xf2>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ae2:	0004c783          	lbu	a5,0(s1)
     ae6:	fd279be3          	bne	a5,s2,abc <main+0x48>
     aea:	0014c703          	lbu	a4,1(s1)
     aee:	06400793          	li	a5,100
     af2:	fcf715e3          	bne	a4,a5,abc <main+0x48>
     af6:	0024c783          	lbu	a5,2(s1)
     afa:	fd3791e3          	bne	a5,s3,abc <main+0x48>
      buf[strlen(buf)-1] = 0;  // chop \n
     afe:	00001a17          	auipc	s4,0x1
     b02:	522a0a13          	addi	s4,s4,1314 # 2020 <buf.0>
     b06:	8552                	mv	a0,s4
     b08:	00000097          	auipc	ra,0x0
     b0c:	0ca080e7          	jalr	202(ra) # bd2 <strlen>
     b10:	fff5079b          	addiw	a5,a0,-1
     b14:	1782                	slli	a5,a5,0x20
     b16:	9381                	srli	a5,a5,0x20
     b18:	9a3e                	add	s4,s4,a5
     b1a:	000a0023          	sb	zero,0(s4)
      if(chdir(buf+3) < 0)
     b1e:	00001517          	auipc	a0,0x1
     b22:	50550513          	addi	a0,a0,1285 # 2023 <buf.0+0x3>
     b26:	00000097          	auipc	ra,0x0
     b2a:	474080e7          	jalr	1140(ra) # f9a <chdir>
     b2e:	fa0551e3          	bgez	a0,ad0 <main+0x5c>
        fprintf(2, "cannot cd %s\n", buf+3);
     b32:	00001617          	auipc	a2,0x1
     b36:	4f160613          	addi	a2,a2,1265 # 2023 <buf.0+0x3>
     b3a:	00001597          	auipc	a1,0x1
     b3e:	a2658593          	addi	a1,a1,-1498 # 1560 <malloc+0x1e6>
     b42:	4509                	li	a0,2
     b44:	00000097          	auipc	ra,0x0
     b48:	750080e7          	jalr	1872(ra) # 1294 <fprintf>
     b4c:	b751                	j	ad0 <main+0x5c>
      runcmd(parsecmd(buf));
     b4e:	00001517          	auipc	a0,0x1
     b52:	4d250513          	addi	a0,a0,1234 # 2020 <buf.0>
     b56:	00000097          	auipc	ra,0x0
     b5a:	e96080e7          	jalr	-362(ra) # 9ec <parsecmd>
     b5e:	fffff097          	auipc	ra,0xfffff
     b62:	54c080e7          	jalr	1356(ra) # aa <runcmd>
  exit(0);
     b66:	4501                	li	a0,0
     b68:	00000097          	auipc	ra,0x0
     b6c:	3c2080e7          	jalr	962(ra) # f2a <exit>

0000000000000b70 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     b70:	1141                	addi	sp,sp,-16
     b72:	e406                	sd	ra,8(sp)
     b74:	e022                	sd	s0,0(sp)
     b76:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b78:	00000097          	auipc	ra,0x0
     b7c:	efc080e7          	jalr	-260(ra) # a74 <main>
  exit(0);
     b80:	4501                	li	a0,0
     b82:	00000097          	auipc	ra,0x0
     b86:	3a8080e7          	jalr	936(ra) # f2a <exit>

0000000000000b8a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     b8a:	1141                	addi	sp,sp,-16
     b8c:	e422                	sd	s0,8(sp)
     b8e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b90:	87aa                	mv	a5,a0
     b92:	0585                	addi	a1,a1,1
     b94:	0785                	addi	a5,a5,1
     b96:	fff5c703          	lbu	a4,-1(a1)
     b9a:	fee78fa3          	sb	a4,-1(a5)
     b9e:	fb75                	bnez	a4,b92 <strcpy+0x8>
    ;
  return os;
}
     ba0:	6422                	ld	s0,8(sp)
     ba2:	0141                	addi	sp,sp,16
     ba4:	8082                	ret

0000000000000ba6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     ba6:	1141                	addi	sp,sp,-16
     ba8:	e422                	sd	s0,8(sp)
     baa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bac:	00054783          	lbu	a5,0(a0)
     bb0:	cb91                	beqz	a5,bc4 <strcmp+0x1e>
     bb2:	0005c703          	lbu	a4,0(a1)
     bb6:	00f71763          	bne	a4,a5,bc4 <strcmp+0x1e>
    p++, q++;
     bba:	0505                	addi	a0,a0,1
     bbc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bbe:	00054783          	lbu	a5,0(a0)
     bc2:	fbe5                	bnez	a5,bb2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bc4:	0005c503          	lbu	a0,0(a1)
}
     bc8:	40a7853b          	subw	a0,a5,a0
     bcc:	6422                	ld	s0,8(sp)
     bce:	0141                	addi	sp,sp,16
     bd0:	8082                	ret

0000000000000bd2 <strlen>:

uint
strlen(const char *s)
{
     bd2:	1141                	addi	sp,sp,-16
     bd4:	e422                	sd	s0,8(sp)
     bd6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     bd8:	00054783          	lbu	a5,0(a0)
     bdc:	cf91                	beqz	a5,bf8 <strlen+0x26>
     bde:	0505                	addi	a0,a0,1
     be0:	87aa                	mv	a5,a0
     be2:	86be                	mv	a3,a5
     be4:	0785                	addi	a5,a5,1
     be6:	fff7c703          	lbu	a4,-1(a5)
     bea:	ff65                	bnez	a4,be2 <strlen+0x10>
     bec:	40a6853b          	subw	a0,a3,a0
     bf0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     bf2:	6422                	ld	s0,8(sp)
     bf4:	0141                	addi	sp,sp,16
     bf6:	8082                	ret
  for(n = 0; s[n]; n++)
     bf8:	4501                	li	a0,0
     bfa:	bfe5                	j	bf2 <strlen+0x20>

0000000000000bfc <memset>:

void*
memset(void *dst, int c, uint n)
{
     bfc:	1141                	addi	sp,sp,-16
     bfe:	e422                	sd	s0,8(sp)
     c00:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c02:	ca19                	beqz	a2,c18 <memset+0x1c>
     c04:	87aa                	mv	a5,a0
     c06:	1602                	slli	a2,a2,0x20
     c08:	9201                	srli	a2,a2,0x20
     c0a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c0e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c12:	0785                	addi	a5,a5,1
     c14:	fee79de3          	bne	a5,a4,c0e <memset+0x12>
  }
  return dst;
}
     c18:	6422                	ld	s0,8(sp)
     c1a:	0141                	addi	sp,sp,16
     c1c:	8082                	ret

0000000000000c1e <strchr>:

char*
strchr(const char *s, char c)
{
     c1e:	1141                	addi	sp,sp,-16
     c20:	e422                	sd	s0,8(sp)
     c22:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c24:	00054783          	lbu	a5,0(a0)
     c28:	cb99                	beqz	a5,c3e <strchr+0x20>
    if(*s == c)
     c2a:	00f58763          	beq	a1,a5,c38 <strchr+0x1a>
  for(; *s; s++)
     c2e:	0505                	addi	a0,a0,1
     c30:	00054783          	lbu	a5,0(a0)
     c34:	fbfd                	bnez	a5,c2a <strchr+0xc>
      return (char*)s;
  return 0;
     c36:	4501                	li	a0,0
}
     c38:	6422                	ld	s0,8(sp)
     c3a:	0141                	addi	sp,sp,16
     c3c:	8082                	ret
  return 0;
     c3e:	4501                	li	a0,0
     c40:	bfe5                	j	c38 <strchr+0x1a>

0000000000000c42 <gets>:

char*
gets(char *buf, int max)
{
     c42:	711d                	addi	sp,sp,-96
     c44:	ec86                	sd	ra,88(sp)
     c46:	e8a2                	sd	s0,80(sp)
     c48:	e4a6                	sd	s1,72(sp)
     c4a:	e0ca                	sd	s2,64(sp)
     c4c:	fc4e                	sd	s3,56(sp)
     c4e:	f852                	sd	s4,48(sp)
     c50:	f456                	sd	s5,40(sp)
     c52:	f05a                	sd	s6,32(sp)
     c54:	ec5e                	sd	s7,24(sp)
     c56:	1080                	addi	s0,sp,96
     c58:	8baa                	mv	s7,a0
     c5a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c5c:	892a                	mv	s2,a0
     c5e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c60:	4aa9                	li	s5,10
     c62:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c64:	89a6                	mv	s3,s1
     c66:	2485                	addiw	s1,s1,1
     c68:	0344d863          	bge	s1,s4,c98 <gets+0x56>
    cc = read(0, &c, 1);
     c6c:	4605                	li	a2,1
     c6e:	faf40593          	addi	a1,s0,-81
     c72:	4501                	li	a0,0
     c74:	00000097          	auipc	ra,0x0
     c78:	2ce080e7          	jalr	718(ra) # f42 <read>
    if(cc < 1)
     c7c:	00a05e63          	blez	a0,c98 <gets+0x56>
    buf[i++] = c;
     c80:	faf44783          	lbu	a5,-81(s0)
     c84:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     c88:	01578763          	beq	a5,s5,c96 <gets+0x54>
     c8c:	0905                	addi	s2,s2,1
     c8e:	fd679be3          	bne	a5,s6,c64 <gets+0x22>
  for(i=0; i+1 < max; ){
     c92:	89a6                	mv	s3,s1
     c94:	a011                	j	c98 <gets+0x56>
     c96:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     c98:	99de                	add	s3,s3,s7
     c9a:	00098023          	sb	zero,0(s3)
  return buf;
}
     c9e:	855e                	mv	a0,s7
     ca0:	60e6                	ld	ra,88(sp)
     ca2:	6446                	ld	s0,80(sp)
     ca4:	64a6                	ld	s1,72(sp)
     ca6:	6906                	ld	s2,64(sp)
     ca8:	79e2                	ld	s3,56(sp)
     caa:	7a42                	ld	s4,48(sp)
     cac:	7aa2                	ld	s5,40(sp)
     cae:	7b02                	ld	s6,32(sp)
     cb0:	6be2                	ld	s7,24(sp)
     cb2:	6125                	addi	sp,sp,96
     cb4:	8082                	ret

0000000000000cb6 <stat>:

int
stat(const char *n, struct stat *st)
{
     cb6:	1101                	addi	sp,sp,-32
     cb8:	ec06                	sd	ra,24(sp)
     cba:	e822                	sd	s0,16(sp)
     cbc:	e426                	sd	s1,8(sp)
     cbe:	e04a                	sd	s2,0(sp)
     cc0:	1000                	addi	s0,sp,32
     cc2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cc4:	4581                	li	a1,0
     cc6:	00000097          	auipc	ra,0x0
     cca:	2a4080e7          	jalr	676(ra) # f6a <open>
  if(fd < 0)
     cce:	02054563          	bltz	a0,cf8 <stat+0x42>
     cd2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     cd4:	85ca                	mv	a1,s2
     cd6:	00000097          	auipc	ra,0x0
     cda:	2ac080e7          	jalr	684(ra) # f82 <fstat>
     cde:	892a                	mv	s2,a0
  close(fd);
     ce0:	8526                	mv	a0,s1
     ce2:	00000097          	auipc	ra,0x0
     ce6:	270080e7          	jalr	624(ra) # f52 <close>
  return r;
}
     cea:	854a                	mv	a0,s2
     cec:	60e2                	ld	ra,24(sp)
     cee:	6442                	ld	s0,16(sp)
     cf0:	64a2                	ld	s1,8(sp)
     cf2:	6902                	ld	s2,0(sp)
     cf4:	6105                	addi	sp,sp,32
     cf6:	8082                	ret
    return -1;
     cf8:	597d                	li	s2,-1
     cfa:	bfc5                	j	cea <stat+0x34>

0000000000000cfc <atoi>:

int
atoi(const char *s)
{
     cfc:	1141                	addi	sp,sp,-16
     cfe:	e422                	sd	s0,8(sp)
     d00:	0800                	addi	s0,sp,16
  int n;
  n = 0;
  while('0' <= *s && *s <= '9')
     d02:	00054683          	lbu	a3,0(a0)
     d06:	fd06879b          	addiw	a5,a3,-48
     d0a:	0ff7f793          	zext.b	a5,a5
     d0e:	4625                	li	a2,9
     d10:	02f66863          	bltu	a2,a5,d40 <atoi+0x44>
     d14:	872a                	mv	a4,a0
  n = 0;
     d16:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d18:	0705                	addi	a4,a4,1
     d1a:	0025179b          	slliw	a5,a0,0x2
     d1e:	9fa9                	addw	a5,a5,a0
     d20:	0017979b          	slliw	a5,a5,0x1
     d24:	9fb5                	addw	a5,a5,a3
     d26:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d2a:	00074683          	lbu	a3,0(a4)
     d2e:	fd06879b          	addiw	a5,a3,-48
     d32:	0ff7f793          	zext.b	a5,a5
     d36:	fef671e3          	bgeu	a2,a5,d18 <atoi+0x1c>

  return n;
}
     d3a:	6422                	ld	s0,8(sp)
     d3c:	0141                	addi	sp,sp,16
     d3e:	8082                	ret
  n = 0;
     d40:	4501                	li	a0,0
     d42:	bfe5                	j	d3a <atoi+0x3e>

0000000000000d44 <strtoi>:
}

// Added by me
int
strtoi(const char *strt, const char** end, int base)
{
     d44:	1141                	addi	sp,sp,-16
     d46:	e422                	sd	s0,8(sp)
     d48:	0800                	addi	s0,sp,16
     d4a:	8eaa                	mv	t4,a0
    register const char *s = strt;
     d4c:	87aa                	mv	a5,a0
    register unsigned int cutoff;
    register int neg = 0, any, cutlim;

    do {
        c = *s++;
    } while (ISSPACE(c));
     d4e:	02000693          	li	a3,32
        c = *s++;
     d52:	883e                	mv	a6,a5
     d54:	0785                	addi	a5,a5,1
     d56:	fff7c703          	lbu	a4,-1(a5)
    } while (ISSPACE(c));
     d5a:	fed70ce3          	beq	a4,a3,d52 <strtoi+0xe>
        c = *s++;
     d5e:	2701                	sext.w	a4,a4

    if (c == '-') {
     d60:	02d00693          	li	a3,45
     d64:	04d70d63          	beq	a4,a3,dbe <strtoi+0x7a>
        neg = 1;
        c = *s++;
    } else if (c == '+')
     d68:	02b00693          	li	a3,43
    register int neg = 0, any, cutlim;
     d6c:	4f01                	li	t5,0
    } else if (c == '+')
     d6e:	04d70e63          	beq	a4,a3,dca <strtoi+0x86>
        c = *s++;
    if ((base == 0 || base == 16) &&
     d72:	fef67693          	andi	a3,a2,-17
     d76:	ea99                	bnez	a3,d8c <strtoi+0x48>
     d78:	03000693          	li	a3,48
     d7c:	04d70c63          	beq	a4,a3,dd4 <strtoi+0x90>
        c == '0' && (*s == 'x' || *s == 'X')) {
        c = s[1];
        s += 2;
        base = 16;
    }
    if (base == 0)
     d80:	e611                	bnez	a2,d8c <strtoi+0x48>
        base = c == '0' ? 8 : 10;
     d82:	03000693          	li	a3,48
     d86:	0cd70b63          	beq	a4,a3,e5c <strtoi+0x118>
     d8a:	4629                	li	a2,10

    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
     d8c:	800008b7          	lui	a7,0x80000
     d90:	fff8c893          	not	a7,a7
     d94:	011f08bb          	addw	a7,t5,a7
    cutlim = cutoff % (unsigned int)base;
     d98:	02c8f2bb          	remuw	t0,a7,a2
    cutoff /= (unsigned long)base;
     d9c:	1882                	slli	a7,a7,0x20
     d9e:	0208d893          	srli	a7,a7,0x20
     da2:	02c8d8b3          	divu	a7,a7,a2
     da6:	00088e1b          	sext.w	t3,a7
    for (acc = 0, any = 0;; c = *s++) {
        if (ISDIGIT(c))
            c -= '0';
     daa:	fd07071b          	addiw	a4,a4,-48
        else if (ISALPHA(c))
            c -= ISUPPER(c) ? 'A' - 10 : 'a' - 10;
        else
            break;
        if (c >= base)
     dae:	0ac75163          	bge	a4,a2,e50 <strtoi+0x10c>
        base = c == '0' ? 8 : 10;
     db2:	4681                	li	a3,0
     db4:	4501                	li	a0,0
            break;
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
            any = -1;
     db6:	537d                	li	t1,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     db8:	2881                	sext.w	a7,a7
        else {
            any = 1;
     dba:	4f85                	li	t6,1
     dbc:	a0a9                	j	e06 <strtoi+0xc2>
        c = *s++;
     dbe:	0007c703          	lbu	a4,0(a5)
     dc2:	00280793          	addi	a5,a6,2
        neg = 1;
     dc6:	4f05                	li	t5,1
     dc8:	b76d                	j	d72 <strtoi+0x2e>
        c = *s++;
     dca:	0007c703          	lbu	a4,0(a5)
     dce:	00280793          	addi	a5,a6,2
     dd2:	b745                	j	d72 <strtoi+0x2e>
        c == '0' && (*s == 'x' || *s == 'X')) {
     dd4:	0007c683          	lbu	a3,0(a5)
     dd8:	0df6f693          	andi	a3,a3,223
     ddc:	05800513          	li	a0,88
     de0:	faa690e3          	bne	a3,a0,d80 <strtoi+0x3c>
        c = s[1];
     de4:	0017c703          	lbu	a4,1(a5)
        s += 2;
     de8:	0789                	addi	a5,a5,2
        base = 16;
     dea:	4641                	li	a2,16
     dec:	b745                	j	d8c <strtoi+0x48>
            any = -1;
     dee:	56fd                	li	a3,-1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     df0:	00e2c463          	blt	t0,a4,df8 <strtoi+0xb4>
     df4:	a015                	j	e18 <strtoi+0xd4>
            any = -1;
     df6:	869a                	mv	a3,t1
    for (acc = 0, any = 0;; c = *s++) {
     df8:	0785                	addi	a5,a5,1
     dfa:	fff7c703          	lbu	a4,-1(a5)
            c -= '0';
     dfe:	fd07071b          	addiw	a4,a4,-48
        if (c >= base)
     e02:	02c75063          	bge	a4,a2,e22 <strtoi+0xde>
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     e06:	fe06c8e3          	bltz	a3,df6 <strtoi+0xb2>
     e0a:	0005081b          	sext.w	a6,a0
            any = -1;
     e0e:	869a                	mv	a3,t1
        if (any < 0 || acc > cutoff || (acc == cutoff && c > cutlim))
     e10:	ff0e64e3          	bltu	t3,a6,df8 <strtoi+0xb4>
     e14:	fca88de3          	beq	a7,a0,dee <strtoi+0xaa>
            acc *= base;
     e18:	02c5053b          	mulw	a0,a0,a2
            acc += c;
     e1c:	9d39                	addw	a0,a0,a4
            any = 1;
     e1e:	86fe                	mv	a3,t6
     e20:	bfe1                	j	df8 <strtoi+0xb4>
        }
    }
    if (any < 0) {
     e22:	0006cd63          	bltz	a3,e3c <strtoi+0xf8>
        acc = neg ? -2147483648 : 2147483647;

    } else if (neg)
     e26:	000f0463          	beqz	t5,e2e <strtoi+0xea>
        acc = -acc;
     e2a:	40a0053b          	negw	a0,a0
    if (end != 0)
     e2e:	c581                	beqz	a1,e36 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
     e30:	ee89                	bnez	a3,e4a <strtoi+0x106>
     e32:	01d5b023          	sd	t4,0(a1)
    return (acc);
}
     e36:	6422                	ld	s0,8(sp)
     e38:	0141                	addi	sp,sp,16
     e3a:	8082                	ret
        acc = neg ? -2147483648 : 2147483647;
     e3c:	000f1d63          	bnez	t5,e56 <strtoi+0x112>
     e40:	80000537          	lui	a0,0x80000
     e44:	fff54513          	not	a0,a0
    if (end != 0)
     e48:	d5fd                	beqz	a1,e36 <strtoi+0xf2>
        *end = (char *) (any ? s - 1 : strt);
     e4a:	fff78e93          	addi	t4,a5,-1
     e4e:	b7d5                	j	e32 <strtoi+0xee>
    for (acc = 0, any = 0;; c = *s++) {
     e50:	4681                	li	a3,0
     e52:	4501                	li	a0,0
     e54:	bfc9                	j	e26 <strtoi+0xe2>
        acc = neg ? -2147483648 : 2147483647;
     e56:	80000537          	lui	a0,0x80000
     e5a:	b7fd                	j	e48 <strtoi+0x104>
    cutoff = neg ? -(unsigned int)-2147483648 : 2147483647;
     e5c:	80000e37          	lui	t3,0x80000
     e60:	fffe4e13          	not	t3,t3
     e64:	01cf0e3b          	addw	t3,t5,t3
    cutlim = cutoff % (unsigned int)base;
     e68:	007e7293          	andi	t0,t3,7
    cutoff /= (unsigned long)base;
     e6c:	003e589b          	srliw	a7,t3,0x3
     e70:	8e46                	mv	t3,a7
            c -= '0';
     e72:	8732                	mv	a4,a2
        base = c == '0' ? 8 : 10;
     e74:	4621                	li	a2,8
     e76:	bf35                	j	db2 <strtoi+0x6e>

0000000000000e78 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e78:	1141                	addi	sp,sp,-16
     e7a:	e422                	sd	s0,8(sp)
     e7c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e7e:	02b57463          	bgeu	a0,a1,ea6 <memmove+0x2e>
    while(n-- > 0)
     e82:	00c05f63          	blez	a2,ea0 <memmove+0x28>
     e86:	1602                	slli	a2,a2,0x20
     e88:	9201                	srli	a2,a2,0x20
     e8a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e8e:	872a                	mv	a4,a0
      *dst++ = *src++;
     e90:	0585                	addi	a1,a1,1
     e92:	0705                	addi	a4,a4,1
     e94:	fff5c683          	lbu	a3,-1(a1)
     e98:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e9c:	fee79ae3          	bne	a5,a4,e90 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ea0:	6422                	ld	s0,8(sp)
     ea2:	0141                	addi	sp,sp,16
     ea4:	8082                	ret
    dst += n;
     ea6:	00c50733          	add	a4,a0,a2
    src += n;
     eaa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     eac:	fec05ae3          	blez	a2,ea0 <memmove+0x28>
     eb0:	fff6079b          	addiw	a5,a2,-1
     eb4:	1782                	slli	a5,a5,0x20
     eb6:	9381                	srli	a5,a5,0x20
     eb8:	fff7c793          	not	a5,a5
     ebc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ebe:	15fd                	addi	a1,a1,-1
     ec0:	177d                	addi	a4,a4,-1
     ec2:	0005c683          	lbu	a3,0(a1)
     ec6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     eca:	fee79ae3          	bne	a5,a4,ebe <memmove+0x46>
     ece:	bfc9                	j	ea0 <memmove+0x28>

0000000000000ed0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     ed0:	1141                	addi	sp,sp,-16
     ed2:	e422                	sd	s0,8(sp)
     ed4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     ed6:	ca05                	beqz	a2,f06 <memcmp+0x36>
     ed8:	fff6069b          	addiw	a3,a2,-1
     edc:	1682                	slli	a3,a3,0x20
     ede:	9281                	srli	a3,a3,0x20
     ee0:	0685                	addi	a3,a3,1
     ee2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     ee4:	00054783          	lbu	a5,0(a0) # ffffffff80000000 <base+0xffffffff7fffdf78>
     ee8:	0005c703          	lbu	a4,0(a1)
     eec:	00e79863          	bne	a5,a4,efc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ef0:	0505                	addi	a0,a0,1
    p2++;
     ef2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ef4:	fed518e3          	bne	a0,a3,ee4 <memcmp+0x14>
  }
  return 0;
     ef8:	4501                	li	a0,0
     efa:	a019                	j	f00 <memcmp+0x30>
      return *p1 - *p2;
     efc:	40e7853b          	subw	a0,a5,a4
}
     f00:	6422                	ld	s0,8(sp)
     f02:	0141                	addi	sp,sp,16
     f04:	8082                	ret
  return 0;
     f06:	4501                	li	a0,0
     f08:	bfe5                	j	f00 <memcmp+0x30>

0000000000000f0a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     f0a:	1141                	addi	sp,sp,-16
     f0c:	e406                	sd	ra,8(sp)
     f0e:	e022                	sd	s0,0(sp)
     f10:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     f12:	00000097          	auipc	ra,0x0
     f16:	f66080e7          	jalr	-154(ra) # e78 <memmove>
}
     f1a:	60a2                	ld	ra,8(sp)
     f1c:	6402                	ld	s0,0(sp)
     f1e:	0141                	addi	sp,sp,16
     f20:	8082                	ret

0000000000000f22 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     f22:	4885                	li	a7,1
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <exit>:
.global exit
exit:
 li a7, SYS_exit
     f2a:	4889                	li	a7,2
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <wait>:
.global wait
wait:
 li a7, SYS_wait
     f32:	488d                	li	a7,3
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     f3a:	4891                	li	a7,4
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <read>:
.global read
read:
 li a7, SYS_read
     f42:	4895                	li	a7,5
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <write>:
.global write
write:
 li a7, SYS_write
     f4a:	48c1                	li	a7,16
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <close>:
.global close
close:
 li a7, SYS_close
     f52:	48d5                	li	a7,21
 ecall
     f54:	00000073          	ecall
 ret
     f58:	8082                	ret

0000000000000f5a <kill>:
.global kill
kill:
 li a7, SYS_kill
     f5a:	4899                	li	a7,6
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f62:	489d                	li	a7,7
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <open>:
.global open
open:
 li a7, SYS_open
     f6a:	48bd                	li	a7,15
 ecall
     f6c:	00000073          	ecall
 ret
     f70:	8082                	ret

0000000000000f72 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f72:	48c5                	li	a7,17
 ecall
     f74:	00000073          	ecall
 ret
     f78:	8082                	ret

0000000000000f7a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f7a:	48c9                	li	a7,18
 ecall
     f7c:	00000073          	ecall
 ret
     f80:	8082                	ret

0000000000000f82 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f82:	48a1                	li	a7,8
 ecall
     f84:	00000073          	ecall
 ret
     f88:	8082                	ret

0000000000000f8a <link>:
.global link
link:
 li a7, SYS_link
     f8a:	48cd                	li	a7,19
 ecall
     f8c:	00000073          	ecall
 ret
     f90:	8082                	ret

0000000000000f92 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f92:	48d1                	li	a7,20
 ecall
     f94:	00000073          	ecall
 ret
     f98:	8082                	ret

0000000000000f9a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f9a:	48a5                	li	a7,9
 ecall
     f9c:	00000073          	ecall
 ret
     fa0:	8082                	ret

0000000000000fa2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     fa2:	48a9                	li	a7,10
 ecall
     fa4:	00000073          	ecall
 ret
     fa8:	8082                	ret

0000000000000faa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     faa:	48ad                	li	a7,11
 ecall
     fac:	00000073          	ecall
 ret
     fb0:	8082                	ret

0000000000000fb2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     fb2:	48b1                	li	a7,12
 ecall
     fb4:	00000073          	ecall
 ret
     fb8:	8082                	ret

0000000000000fba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     fba:	48b5                	li	a7,13
 ecall
     fbc:	00000073          	ecall
 ret
     fc0:	8082                	ret

0000000000000fc2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     fc2:	48b9                	li	a7,14
 ecall
     fc4:	00000073          	ecall
 ret
     fc8:	8082                	ret

0000000000000fca <getmem>:
.global getmem
getmem:
 li a7, SYS_getmem
     fca:	48d9                	li	a7,22
 ecall
     fcc:	00000073          	ecall
 ret
     fd0:	8082                	ret

0000000000000fd2 <getstate>:
.global getstate
getstate:
 li a7, SYS_getstate
     fd2:	48dd                	li	a7,23
 ecall
     fd4:	00000073          	ecall
 ret
     fd8:	8082                	ret

0000000000000fda <getparentpid>:
.global getparentpid
getparentpid:
 li a7, SYS_getparentpid
     fda:	48e1                	li	a7,24
 ecall
     fdc:	00000073          	ecall
 ret
     fe0:	8082                	ret

0000000000000fe2 <getkstack>:
.global getkstack
getkstack:
 li a7, SYS_getkstack
     fe2:	48e5                	li	a7,25
 ecall
     fe4:	00000073          	ecall
 ret
     fe8:	8082                	ret

0000000000000fea <getpri>:
.global getpri
getpri:
 li a7, SYS_getpri
     fea:	48e9                	li	a7,26
 ecall
     fec:	00000073          	ecall
 ret
     ff0:	8082                	ret

0000000000000ff2 <setpri>:
.global setpri
setpri:
 li a7, SYS_setpri
     ff2:	48ed                	li	a7,27
 ecall
     ff4:	00000073          	ecall
 ret
     ff8:	8082                	ret

0000000000000ffa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ffa:	1101                	addi	sp,sp,-32
     ffc:	ec06                	sd	ra,24(sp)
     ffe:	e822                	sd	s0,16(sp)
    1000:	1000                	addi	s0,sp,32
    1002:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    1006:	4605                	li	a2,1
    1008:	fef40593          	addi	a1,s0,-17
    100c:	00000097          	auipc	ra,0x0
    1010:	f3e080e7          	jalr	-194(ra) # f4a <write>
}
    1014:	60e2                	ld	ra,24(sp)
    1016:	6442                	ld	s0,16(sp)
    1018:	6105                	addi	sp,sp,32
    101a:	8082                	ret

000000000000101c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    101c:	7139                	addi	sp,sp,-64
    101e:	fc06                	sd	ra,56(sp)
    1020:	f822                	sd	s0,48(sp)
    1022:	f426                	sd	s1,40(sp)
    1024:	f04a                	sd	s2,32(sp)
    1026:	ec4e                	sd	s3,24(sp)
    1028:	0080                	addi	s0,sp,64
    102a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    102c:	c299                	beqz	a3,1032 <printint+0x16>
    102e:	0805c963          	bltz	a1,10c0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    1032:	2581                	sext.w	a1,a1
  neg = 0;
    1034:	4881                	li	a7,0
    1036:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    103a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    103c:	2601                	sext.w	a2,a2
    103e:	00000517          	auipc	a0,0x0
    1042:	5c250513          	addi	a0,a0,1474 # 1600 <digits>
    1046:	883a                	mv	a6,a4
    1048:	2705                	addiw	a4,a4,1
    104a:	02c5f7bb          	remuw	a5,a1,a2
    104e:	1782                	slli	a5,a5,0x20
    1050:	9381                	srli	a5,a5,0x20
    1052:	97aa                	add	a5,a5,a0
    1054:	0007c783          	lbu	a5,0(a5)
    1058:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    105c:	0005879b          	sext.w	a5,a1
    1060:	02c5d5bb          	divuw	a1,a1,a2
    1064:	0685                	addi	a3,a3,1
    1066:	fec7f0e3          	bgeu	a5,a2,1046 <printint+0x2a>
  if(neg)
    106a:	00088c63          	beqz	a7,1082 <printint+0x66>
    buf[i++] = '-';
    106e:	fd070793          	addi	a5,a4,-48
    1072:	00878733          	add	a4,a5,s0
    1076:	02d00793          	li	a5,45
    107a:	fef70823          	sb	a5,-16(a4)
    107e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1082:	02e05863          	blez	a4,10b2 <printint+0x96>
    1086:	fc040793          	addi	a5,s0,-64
    108a:	00e78933          	add	s2,a5,a4
    108e:	fff78993          	addi	s3,a5,-1
    1092:	99ba                	add	s3,s3,a4
    1094:	377d                	addiw	a4,a4,-1
    1096:	1702                	slli	a4,a4,0x20
    1098:	9301                	srli	a4,a4,0x20
    109a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    109e:	fff94583          	lbu	a1,-1(s2)
    10a2:	8526                	mv	a0,s1
    10a4:	00000097          	auipc	ra,0x0
    10a8:	f56080e7          	jalr	-170(ra) # ffa <putc>
  while(--i >= 0)
    10ac:	197d                	addi	s2,s2,-1
    10ae:	ff3918e3          	bne	s2,s3,109e <printint+0x82>
}
    10b2:	70e2                	ld	ra,56(sp)
    10b4:	7442                	ld	s0,48(sp)
    10b6:	74a2                	ld	s1,40(sp)
    10b8:	7902                	ld	s2,32(sp)
    10ba:	69e2                	ld	s3,24(sp)
    10bc:	6121                	addi	sp,sp,64
    10be:	8082                	ret
    x = -xx;
    10c0:	40b005bb          	negw	a1,a1
    neg = 1;
    10c4:	4885                	li	a7,1
    x = -xx;
    10c6:	bf85                	j	1036 <printint+0x1a>

00000000000010c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    10c8:	715d                	addi	sp,sp,-80
    10ca:	e486                	sd	ra,72(sp)
    10cc:	e0a2                	sd	s0,64(sp)
    10ce:	fc26                	sd	s1,56(sp)
    10d0:	f84a                	sd	s2,48(sp)
    10d2:	f44e                	sd	s3,40(sp)
    10d4:	f052                	sd	s4,32(sp)
    10d6:	ec56                	sd	s5,24(sp)
    10d8:	e85a                	sd	s6,16(sp)
    10da:	e45e                	sd	s7,8(sp)
    10dc:	e062                	sd	s8,0(sp)
    10de:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    10e0:	0005c903          	lbu	s2,0(a1)
    10e4:	18090c63          	beqz	s2,127c <vprintf+0x1b4>
    10e8:	8aaa                	mv	s5,a0
    10ea:	8bb2                	mv	s7,a2
    10ec:	00158493          	addi	s1,a1,1
  state = 0;
    10f0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    10f2:	02500a13          	li	s4,37
    10f6:	4b55                	li	s6,21
    10f8:	a839                	j	1116 <vprintf+0x4e>
        putc(fd, c);
    10fa:	85ca                	mv	a1,s2
    10fc:	8556                	mv	a0,s5
    10fe:	00000097          	auipc	ra,0x0
    1102:	efc080e7          	jalr	-260(ra) # ffa <putc>
    1106:	a019                	j	110c <vprintf+0x44>
    } else if(state == '%'){
    1108:	01498d63          	beq	s3,s4,1122 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
    110c:	0485                	addi	s1,s1,1
    110e:	fff4c903          	lbu	s2,-1(s1)
    1112:	16090563          	beqz	s2,127c <vprintf+0x1b4>
    if(state == 0){
    1116:	fe0999e3          	bnez	s3,1108 <vprintf+0x40>
      if(c == '%'){
    111a:	ff4910e3          	bne	s2,s4,10fa <vprintf+0x32>
        state = '%';
    111e:	89d2                	mv	s3,s4
    1120:	b7f5                	j	110c <vprintf+0x44>
      if(c == 'd'){
    1122:	13490263          	beq	s2,s4,1246 <vprintf+0x17e>
    1126:	f9d9079b          	addiw	a5,s2,-99
    112a:	0ff7f793          	zext.b	a5,a5
    112e:	12fb6563          	bltu	s6,a5,1258 <vprintf+0x190>
    1132:	f9d9079b          	addiw	a5,s2,-99
    1136:	0ff7f713          	zext.b	a4,a5
    113a:	10eb6f63          	bltu	s6,a4,1258 <vprintf+0x190>
    113e:	00271793          	slli	a5,a4,0x2
    1142:	00000717          	auipc	a4,0x0
    1146:	46670713          	addi	a4,a4,1126 # 15a8 <malloc+0x22e>
    114a:	97ba                	add	a5,a5,a4
    114c:	439c                	lw	a5,0(a5)
    114e:	97ba                	add	a5,a5,a4
    1150:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    1152:	008b8913          	addi	s2,s7,8
    1156:	4685                	li	a3,1
    1158:	4629                	li	a2,10
    115a:	000ba583          	lw	a1,0(s7)
    115e:	8556                	mv	a0,s5
    1160:	00000097          	auipc	ra,0x0
    1164:	ebc080e7          	jalr	-324(ra) # 101c <printint>
    1168:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    116a:	4981                	li	s3,0
    116c:	b745                	j	110c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    116e:	008b8913          	addi	s2,s7,8
    1172:	4681                	li	a3,0
    1174:	4629                	li	a2,10
    1176:	000ba583          	lw	a1,0(s7)
    117a:	8556                	mv	a0,s5
    117c:	00000097          	auipc	ra,0x0
    1180:	ea0080e7          	jalr	-352(ra) # 101c <printint>
    1184:	8bca                	mv	s7,s2
      state = 0;
    1186:	4981                	li	s3,0
    1188:	b751                	j	110c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    118a:	008b8913          	addi	s2,s7,8
    118e:	4681                	li	a3,0
    1190:	4641                	li	a2,16
    1192:	000ba583          	lw	a1,0(s7)
    1196:	8556                	mv	a0,s5
    1198:	00000097          	auipc	ra,0x0
    119c:	e84080e7          	jalr	-380(ra) # 101c <printint>
    11a0:	8bca                	mv	s7,s2
      state = 0;
    11a2:	4981                	li	s3,0
    11a4:	b7a5                	j	110c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    11a6:	008b8c13          	addi	s8,s7,8
    11aa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    11ae:	03000593          	li	a1,48
    11b2:	8556                	mv	a0,s5
    11b4:	00000097          	auipc	ra,0x0
    11b8:	e46080e7          	jalr	-442(ra) # ffa <putc>
  putc(fd, 'x');
    11bc:	07800593          	li	a1,120
    11c0:	8556                	mv	a0,s5
    11c2:	00000097          	auipc	ra,0x0
    11c6:	e38080e7          	jalr	-456(ra) # ffa <putc>
    11ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11cc:	00000b97          	auipc	s7,0x0
    11d0:	434b8b93          	addi	s7,s7,1076 # 1600 <digits>
    11d4:	03c9d793          	srli	a5,s3,0x3c
    11d8:	97de                	add	a5,a5,s7
    11da:	0007c583          	lbu	a1,0(a5)
    11de:	8556                	mv	a0,s5
    11e0:	00000097          	auipc	ra,0x0
    11e4:	e1a080e7          	jalr	-486(ra) # ffa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11e8:	0992                	slli	s3,s3,0x4
    11ea:	397d                	addiw	s2,s2,-1
    11ec:	fe0914e3          	bnez	s2,11d4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    11f0:	8be2                	mv	s7,s8
      state = 0;
    11f2:	4981                	li	s3,0
    11f4:	bf21                	j	110c <vprintf+0x44>
        s = va_arg(ap, char*);
    11f6:	008b8993          	addi	s3,s7,8
    11fa:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    11fe:	02090163          	beqz	s2,1220 <vprintf+0x158>
        while(*s != 0){
    1202:	00094583          	lbu	a1,0(s2)
    1206:	c9a5                	beqz	a1,1276 <vprintf+0x1ae>
          putc(fd, *s);
    1208:	8556                	mv	a0,s5
    120a:	00000097          	auipc	ra,0x0
    120e:	df0080e7          	jalr	-528(ra) # ffa <putc>
          s++;
    1212:	0905                	addi	s2,s2,1
        while(*s != 0){
    1214:	00094583          	lbu	a1,0(s2)
    1218:	f9e5                	bnez	a1,1208 <vprintf+0x140>
        s = va_arg(ap, char*);
    121a:	8bce                	mv	s7,s3
      state = 0;
    121c:	4981                	li	s3,0
    121e:	b5fd                	j	110c <vprintf+0x44>
          s = "(null)";
    1220:	00000917          	auipc	s2,0x0
    1224:	38090913          	addi	s2,s2,896 # 15a0 <malloc+0x226>
        while(*s != 0){
    1228:	02800593          	li	a1,40
    122c:	bff1                	j	1208 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    122e:	008b8913          	addi	s2,s7,8
    1232:	000bc583          	lbu	a1,0(s7)
    1236:	8556                	mv	a0,s5
    1238:	00000097          	auipc	ra,0x0
    123c:	dc2080e7          	jalr	-574(ra) # ffa <putc>
    1240:	8bca                	mv	s7,s2
      state = 0;
    1242:	4981                	li	s3,0
    1244:	b5e1                	j	110c <vprintf+0x44>
        putc(fd, c);
    1246:	02500593          	li	a1,37
    124a:	8556                	mv	a0,s5
    124c:	00000097          	auipc	ra,0x0
    1250:	dae080e7          	jalr	-594(ra) # ffa <putc>
      state = 0;
    1254:	4981                	li	s3,0
    1256:	bd5d                	j	110c <vprintf+0x44>
        putc(fd, '%');
    1258:	02500593          	li	a1,37
    125c:	8556                	mv	a0,s5
    125e:	00000097          	auipc	ra,0x0
    1262:	d9c080e7          	jalr	-612(ra) # ffa <putc>
        putc(fd, c);
    1266:	85ca                	mv	a1,s2
    1268:	8556                	mv	a0,s5
    126a:	00000097          	auipc	ra,0x0
    126e:	d90080e7          	jalr	-624(ra) # ffa <putc>
      state = 0;
    1272:	4981                	li	s3,0
    1274:	bd61                	j	110c <vprintf+0x44>
        s = va_arg(ap, char*);
    1276:	8bce                	mv	s7,s3
      state = 0;
    1278:	4981                	li	s3,0
    127a:	bd49                	j	110c <vprintf+0x44>
    }
  }
}
    127c:	60a6                	ld	ra,72(sp)
    127e:	6406                	ld	s0,64(sp)
    1280:	74e2                	ld	s1,56(sp)
    1282:	7942                	ld	s2,48(sp)
    1284:	79a2                	ld	s3,40(sp)
    1286:	7a02                	ld	s4,32(sp)
    1288:	6ae2                	ld	s5,24(sp)
    128a:	6b42                	ld	s6,16(sp)
    128c:	6ba2                	ld	s7,8(sp)
    128e:	6c02                	ld	s8,0(sp)
    1290:	6161                	addi	sp,sp,80
    1292:	8082                	ret

0000000000001294 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1294:	715d                	addi	sp,sp,-80
    1296:	ec06                	sd	ra,24(sp)
    1298:	e822                	sd	s0,16(sp)
    129a:	1000                	addi	s0,sp,32
    129c:	e010                	sd	a2,0(s0)
    129e:	e414                	sd	a3,8(s0)
    12a0:	e818                	sd	a4,16(s0)
    12a2:	ec1c                	sd	a5,24(s0)
    12a4:	03043023          	sd	a6,32(s0)
    12a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    12ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    12b0:	8622                	mv	a2,s0
    12b2:	00000097          	auipc	ra,0x0
    12b6:	e16080e7          	jalr	-490(ra) # 10c8 <vprintf>
}
    12ba:	60e2                	ld	ra,24(sp)
    12bc:	6442                	ld	s0,16(sp)
    12be:	6161                	addi	sp,sp,80
    12c0:	8082                	ret

00000000000012c2 <printf>:

void
printf(const char *fmt, ...)
{
    12c2:	711d                	addi	sp,sp,-96
    12c4:	ec06                	sd	ra,24(sp)
    12c6:	e822                	sd	s0,16(sp)
    12c8:	1000                	addi	s0,sp,32
    12ca:	e40c                	sd	a1,8(s0)
    12cc:	e810                	sd	a2,16(s0)
    12ce:	ec14                	sd	a3,24(s0)
    12d0:	f018                	sd	a4,32(s0)
    12d2:	f41c                	sd	a5,40(s0)
    12d4:	03043823          	sd	a6,48(s0)
    12d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    12dc:	00840613          	addi	a2,s0,8
    12e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    12e4:	85aa                	mv	a1,a0
    12e6:	4505                	li	a0,1
    12e8:	00000097          	auipc	ra,0x0
    12ec:	de0080e7          	jalr	-544(ra) # 10c8 <vprintf>
}
    12f0:	60e2                	ld	ra,24(sp)
    12f2:	6442                	ld	s0,16(sp)
    12f4:	6125                	addi	sp,sp,96
    12f6:	8082                	ret

00000000000012f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12f8:	1141                	addi	sp,sp,-16
    12fa:	e422                	sd	s0,8(sp)
    12fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1302:	00001797          	auipc	a5,0x1
    1306:	d0e7b783          	ld	a5,-754(a5) # 2010 <freep>
    130a:	a02d                	j	1334 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    130c:	4618                	lw	a4,8(a2)
    130e:	9f2d                	addw	a4,a4,a1
    1310:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1314:	6398                	ld	a4,0(a5)
    1316:	6310                	ld	a2,0(a4)
    1318:	a83d                	j	1356 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    131a:	ff852703          	lw	a4,-8(a0)
    131e:	9f31                	addw	a4,a4,a2
    1320:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1322:	ff053683          	ld	a3,-16(a0)
    1326:	a091                	j	136a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1328:	6398                	ld	a4,0(a5)
    132a:	00e7e463          	bltu	a5,a4,1332 <free+0x3a>
    132e:	00e6ea63          	bltu	a3,a4,1342 <free+0x4a>
{
    1332:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1334:	fed7fae3          	bgeu	a5,a3,1328 <free+0x30>
    1338:	6398                	ld	a4,0(a5)
    133a:	00e6e463          	bltu	a3,a4,1342 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    133e:	fee7eae3          	bltu	a5,a4,1332 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1342:	ff852583          	lw	a1,-8(a0)
    1346:	6390                	ld	a2,0(a5)
    1348:	02059813          	slli	a6,a1,0x20
    134c:	01c85713          	srli	a4,a6,0x1c
    1350:	9736                	add	a4,a4,a3
    1352:	fae60de3          	beq	a2,a4,130c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1356:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    135a:	4790                	lw	a2,8(a5)
    135c:	02061593          	slli	a1,a2,0x20
    1360:	01c5d713          	srli	a4,a1,0x1c
    1364:	973e                	add	a4,a4,a5
    1366:	fae68ae3          	beq	a3,a4,131a <free+0x22>
    p->s.ptr = bp->s.ptr;
    136a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    136c:	00001717          	auipc	a4,0x1
    1370:	caf73223          	sd	a5,-860(a4) # 2010 <freep>
}
    1374:	6422                	ld	s0,8(sp)
    1376:	0141                	addi	sp,sp,16
    1378:	8082                	ret

000000000000137a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    137a:	7139                	addi	sp,sp,-64
    137c:	fc06                	sd	ra,56(sp)
    137e:	f822                	sd	s0,48(sp)
    1380:	f426                	sd	s1,40(sp)
    1382:	f04a                	sd	s2,32(sp)
    1384:	ec4e                	sd	s3,24(sp)
    1386:	e852                	sd	s4,16(sp)
    1388:	e456                	sd	s5,8(sp)
    138a:	e05a                	sd	s6,0(sp)
    138c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    138e:	02051493          	slli	s1,a0,0x20
    1392:	9081                	srli	s1,s1,0x20
    1394:	04bd                	addi	s1,s1,15
    1396:	8091                	srli	s1,s1,0x4
    1398:	0014899b          	addiw	s3,s1,1
    139c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    139e:	00001517          	auipc	a0,0x1
    13a2:	c7253503          	ld	a0,-910(a0) # 2010 <freep>
    13a6:	c515                	beqz	a0,13d2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13aa:	4798                	lw	a4,8(a5)
    13ac:	02977f63          	bgeu	a4,s1,13ea <malloc+0x70>
  if(nu < 4096)
    13b0:	8a4e                	mv	s4,s3
    13b2:	0009871b          	sext.w	a4,s3
    13b6:	6685                	lui	a3,0x1
    13b8:	00d77363          	bgeu	a4,a3,13be <malloc+0x44>
    13bc:	6a05                	lui	s4,0x1
    13be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    13c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    13c6:	00001917          	auipc	s2,0x1
    13ca:	c4a90913          	addi	s2,s2,-950 # 2010 <freep>
  if(p == (char*)-1)
    13ce:	5afd                	li	s5,-1
    13d0:	a895                	j	1444 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    13d2:	00001797          	auipc	a5,0x1
    13d6:	cb678793          	addi	a5,a5,-842 # 2088 <base>
    13da:	00001717          	auipc	a4,0x1
    13de:	c2f73b23          	sd	a5,-970(a4) # 2010 <freep>
    13e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    13e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    13e8:	b7e1                	j	13b0 <malloc+0x36>
      if(p->s.size == nunits)
    13ea:	02e48c63          	beq	s1,a4,1422 <malloc+0xa8>
        p->s.size -= nunits;
    13ee:	4137073b          	subw	a4,a4,s3
    13f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13f4:	02071693          	slli	a3,a4,0x20
    13f8:	01c6d713          	srli	a4,a3,0x1c
    13fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1402:	00001717          	auipc	a4,0x1
    1406:	c0a73723          	sd	a0,-1010(a4) # 2010 <freep>
      return (void*)(p + 1);
    140a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    140e:	70e2                	ld	ra,56(sp)
    1410:	7442                	ld	s0,48(sp)
    1412:	74a2                	ld	s1,40(sp)
    1414:	7902                	ld	s2,32(sp)
    1416:	69e2                	ld	s3,24(sp)
    1418:	6a42                	ld	s4,16(sp)
    141a:	6aa2                	ld	s5,8(sp)
    141c:	6b02                	ld	s6,0(sp)
    141e:	6121                	addi	sp,sp,64
    1420:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1422:	6398                	ld	a4,0(a5)
    1424:	e118                	sd	a4,0(a0)
    1426:	bff1                	j	1402 <malloc+0x88>
  hp->s.size = nu;
    1428:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    142c:	0541                	addi	a0,a0,16
    142e:	00000097          	auipc	ra,0x0
    1432:	eca080e7          	jalr	-310(ra) # 12f8 <free>
  return freep;
    1436:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    143a:	d971                	beqz	a0,140e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    143c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    143e:	4798                	lw	a4,8(a5)
    1440:	fa9775e3          	bgeu	a4,s1,13ea <malloc+0x70>
    if(p == freep)
    1444:	00093703          	ld	a4,0(s2)
    1448:	853e                	mv	a0,a5
    144a:	fef719e3          	bne	a4,a5,143c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    144e:	8552                	mv	a0,s4
    1450:	00000097          	auipc	ra,0x0
    1454:	b62080e7          	jalr	-1182(ra) # fb2 <sbrk>
  if(p == (char*)-1)
    1458:	fd5518e3          	bne	a0,s5,1428 <malloc+0xae>
        return 0;
    145c:	4501                	li	a0,0
    145e:	bf45                	j	140e <malloc+0x94>
