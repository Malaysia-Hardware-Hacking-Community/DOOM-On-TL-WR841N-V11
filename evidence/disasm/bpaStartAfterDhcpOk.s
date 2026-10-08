            ; NULL XREF from aav.0x004051f4 @ +0x4bb4(r)
┌ 468: sym.bpaStartAfterDhcpOk (int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4);
│ `- args(a0, a1, a2, a3) vars(12:sp[0x4..0x370])
│           0x004e4934      lui gp, 0x5c
│           0x004e4938      addiu sp, sp, -0x380
│           0x004e493c      addiu gp, gp, -0x2f0
│           0x004e4940      sw ra, (var_37ch)
│           0x004e4944      sw s1, (var_378h)
│           0x004e4948      sw s0, (var_374h)
│           0x004e494c      sw gp, (var_18h)
│           0x004e4950      lw t9, -sym.swBpaIsLinkUp(gp)              ; [0x47dbec:4]=0x27bdffd8 ; "'\xbd\xff\u062f\xbf"
│           0x004e4954      nop
│           0x004e4958      jalr t9
│           0x004e495c      nop
│           0x004e4960      addiu v1, zero, 1
│           0x004e4964      lw gp, (var_18h)
│       ┌─< 0x004e4968      beq v0, v1, 0x4e4af4
│       │   0x004e496c      nop
│       │   0x004e4970      lw t9, -sym.swGetBpaCfg(gp)                ; [0x47dad4:4]=0x3c1c005c ; "<\x1c"
│       │   0x004e4974      nop
│       │   0x004e4978      jalr t9
│       │   0x004e497c      addiu a0, sp, 0x88                         ; arg1
│       │   0x004e4980      lw gp, (var_18h)
│       │   0x004e4984      move a0, zero
│       │   0x004e4988      lw t9, -sym.swGetDhcpcCfg(gp)              ; [0x477850:4]=0x3c1c005c ; "<\x1c"
│       │   0x004e498c      nop
│       │   0x004e4990      jalr t9
│       │   0x004e4994      addiu a1, sp, 0x20                         ; arg2
│       │   0x004e4998      lw gp, (var_18h)
│      ┌──< 0x004e499c      bnez v0, 0x4e4ac8
│      ││   0x004e49a0      nop
│      ││   0x004e49a4      lw t9, -sym.getWanStaticIpIfName(gp)       ; [0x4eaa84:4]=0x3c02005b ; "<\x02"
│      ││   0x004e49a8      lw s0, (var_60h)
│      ││   0x004e49ac      jalr t9
│      ││   0x004e49b0      addiu s1, sp, 0x16c
│      ││   0x004e49b4      lw gp, (var_18h)
│      ││   0x004e49b8      move a0, s0
│      ││   0x004e49bc      lw t9, -sym.imp.inet_ntoa(gp)              ; [0x5616e0:4]=0x8f998010
│      ││   0x004e49c0      nop
│      ││   0x004e49c4      jalr t9
│      ││   0x004e49c8      move s0, v0
│      ││   0x004e49cc      lw gp, (var_18h)
│      ││   0x004e49d0      lw v1, (var_15ch)
│      ││   0x004e49d4      lui a1, 0x58                               ; 0x580000 ; "me"
│      ││   0x004e49d8      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│      ││   0x004e49dc      sw v1, (var_10h)
│      ││   0x004e49e0      move a2, s0
│      ││   0x004e49e4      addiu a1, a1, -0x2624                      ; 0x57d9dc ; "ifconfig %s %s mtu %d" ; arg2 [0m; str.ifconfig__s__s_mtu__d
│      ││   0x004e49e8      move a3, v0
│      ││   0x004e49ec      jalr t9
│      ││   0x004e49f0      move a0, s1
│      ││   0x004e49f4      lw gp, (var_18h)
│      ││   0x004e49f8      nop
│      ││   0x004e49fc      lw t9, -sym.tp_systemEx(gp)                ; [0x4eeb74:4]=0x3c1c005c ; "<\x1c"
│      ││   0x004e4a00      nop
│      ││   0x004e4a04      jalr t9
│      ││   0x004e4a08      move a0, s1
│      ││   0x004e4a0c      lw gp, (var_18h)
│      ││   0x004e4a10      lw s0, (var_64h)
│      ││   0x004e4a14      lw t9, -sym.getWanStaticIpIfName(gp)       ; [0x4eaa84:4]=0x3c02005b ; "<\x02"
│      ││   0x004e4a18      nop
│      ││   0x004e4a1c      jalr t9
│      ││   0x004e4a20      nop
│      ││   0x004e4a24      lw gp, (var_18h)
│      ││   0x004e4a28      move a0, s0
│      ││   0x004e4a2c      lw t9, -sym.imp.inet_ntoa(gp)              ; [0x5616e0:4]=0x8f998010
│      ││   0x004e4a30      nop
│      ││   0x004e4a34      jalr t9
│      ││   0x004e4a38      move s0, v0
│      ││   0x004e4a3c      lw gp, (var_18h)
│      ││   0x004e4a40      lui a1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│      ││   0x004e4a44      addiu a1, a1, 0x7d2c                       ; 0x577d2c ; "ifconfig %s netmask %s" ; arg2 [0m; str.ifconfig__s_netmask__s
│      ││   0x004e4a48      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│      ││   0x004e4a4c      move a2, s0
│      ││   0x004e4a50      move a3, v0
│      ││   0x004e4a54      jalr t9
│      ││   0x004e4a58      move a0, s1
│      ││   0x004e4a5c      lw gp, (var_18h)
│      ││   0x004e4a60      nop
│      ││   0x004e4a64      lw t9, -sym.tp_systemEx(gp)                ; [0x4eeb74:4]=0x3c1c005c ; "<\x1c"
│      ││   0x004e4a68      nop
│      ││   0x004e4a6c      jalr t9
│      ││   0x004e4a70      move a0, s1
│      ││   0x004e4a74      lw gp, (var_18h)
│      ││   0x004e4a78      lw a0, (var_6ch)
│      ││   0x004e4a7c      lw t9, -sym.imp.inet_ntoa(gp)              ; [0x5616e0:4]=0x8f998010
│      ││   0x004e4a80      nop
│      ││   0x004e4a84      jalr t9
│      ││   0x004e4a88      nop
│      ││   0x004e4a8c      lw gp, (var_18h)
│      ││   0x004e4a90      lui a1, 0x58                               ; 0x580000 ; "me"
│      ││   0x004e4a94      lui a3, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│      ││   0x004e4a98      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│      ││   0x004e4a9c      addiu a1, a1, -0x3068                      ; 0x57cf98 ; "echo \"nameserver %s\" > %s" ; arg2 [0m; str.echo__nameserver__s_____s
│      ││   0x004e4aa0      move a2, v0
│      ││   0x004e4aa4      addiu a3, a3, 0x7ca8                       ; 0x577ca8 ; "/tmp/resolv.conf" ; arg4 [0m; str._tmp_resolv.conf
│      ││   0x004e4aa8      jalr t9
│      ││   0x004e4aac      move a0, s1
│      ││   0x004e4ab0      lw gp, (var_18h)
│      ││   0x004e4ab4      nop
│      ││   0x004e4ab8      lw t9, -sym.tp_systemEx(gp)                ; [0x4eeb74:4]=0x3c1c005c ; "<\x1c"
│      ││   0x004e4abc      nop
│      ││   0x004e4ac0      jalr t9
│      ││   0x004e4ac4      move a0, s1
│      ││   ; CODE XREF from sym.bpaStartAfterDhcpOk @ 0x4e499c(x)
│      └──> 0x004e4ac8      addiu s0, sp, 0x16c
│       │   0x004e4acc      addiu a0, sp, 0x88                         ; arg1
│       │   0x004e4ad0      jal fcn.004e46a4
│       │   0x004e4ad4      move a1, s0
│       │   0x004e4ad8      lw gp, (var_18h)
│       │   0x004e4adc      nop
│       │   0x004e4ae0      lw t9, -sym.tp_systemEx(gp)                ; [0x4eeb74:4]=0x3c1c005c ; "<\x1c"
│       │   0x004e4ae4      nop
│       │   0x004e4ae8      jalr t9
│       │   0x004e4aec      move a0, s0
│       │   0x004e4af0      lw gp, (var_18h)
│       │   ; CODE XREF from sym.bpaStartAfterDhcpOk @ 0x4e4968(x)
│       └─> 0x004e4af4      lw ra, (var_37ch)
│           0x004e4af8      lw s1, (var_378h)
│           0x004e4afc      lw s0, (var_374h)
│           0x004e4b00      jr ra
└           0x004e4b04      addiu sp, sp, 0x380
