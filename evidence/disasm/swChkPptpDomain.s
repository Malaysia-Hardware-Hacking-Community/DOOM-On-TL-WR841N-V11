            ; NULL XREF from aav.0x004051f4 @ +0x83c4(r)
┌ 152: sym.swChkPptpDomain (int32_t arg1);
│ `- args(a0) vars(3:sp[0x4..0x10])
│           0x0047adb4      lui gp, 0x5c
│           0x0047adb8      addiu sp, sp, -0x20
│           0x0047adbc      addiu gp, gp, -0x2f0
│           0x0047adc0      sw ra, (var_1ch)
│           0x0047adc4      sw s0, (var_18h)
│           0x0047adc8      sw gp, (var_10h)
│       ┌─< 0x0047adcc      beqz a0, 0x47ae3c
│       │   0x0047add0      addiu v0, zero, -1
│       │   0x0047add4      lbu v0, 0x1c(a0)                           ; arg1
│       │   0x0047add8      nop
│      ┌──< 0x0047addc      beqz v0, 0x47ae3c
│      ││   0x0047ade0      addiu v0, zero, 0x13a8
│      ││   0x0047ade4      lw t9, -sym.swChkDotIpAddr(gp)             ; [0x47440c:4]=0x3c1c005c ; "<\x1c"
│      ││   0x0047ade8      addiu s0, a0, 0x1c                         ; arg1
│      ││   0x0047adec      jalr t9
│      ││   0x0047adf0      move a0, s0
│      ││   0x0047adf4      addiu v1, zero, 1
│      ││   0x0047adf8      lw gp, (var_10h)
│     ┌───< 0x0047adfc      bne v0, v1, 0x47ae3c
│     │││   0x0047ae00      move v0, zero
│     │││   0x0047ae04      lw t9, -sym.imp.inet_addr(gp)              ; [0x561770:4]=0x8f998010
│     │││   0x0047ae08      nop
│     │││   0x0047ae0c      jalr t9
│     │││   0x0047ae10      move a0, s0
│     │││   0x0047ae14      lw gp, (var_10h)
│     │││   0x0047ae18      nop
│     │││   0x0047ae1c      lw t9, -sym.swChkLegalIpAddr(gp)           ; [0x474e70:4]=0x3c1c005c ; "<\x1c"
│     │││   0x0047ae20      nop
│     │││   0x0047ae24      jalr t9
│     │││   0x0047ae28      move a0, v0
│     │││   0x0047ae2c      lw gp, (var_10h)
│    ┌────< 0x0047ae30      beqz v0, 0x47ae3c
│    ││││   0x0047ae34      addiu v0, zero, 0x13a8
│    ││││   0x0047ae38      move v0, zero
│    ││││   ; CODE XREFS from sym.swChkPptpDomain @ 0x47adcc(x), 0x47addc(x), 0x47adfc(x), 0x47ae30(x)
│    └└└└─> 0x0047ae3c      lw ra, (var_1ch)
│           0x0047ae40      lw s0, (var_18h)
│           0x0047ae44      jr ra
└           0x0047ae48      addiu sp, sp, 0x20
