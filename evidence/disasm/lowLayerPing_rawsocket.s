            ; NULL XREF from aav.0x004051f4 @ +0x6354(r)
            ; CALL XREFS from sym.diagnosticThread @ 0x4c1498(r), 0x4c14b8(r)
┌ 1448: sym.lowLayerPing (int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4, int32_t arg_d38h, int32_t arg_d3ch, int32_t arg_d40h, int32_t arg_d44h, int32_t arg_d48h, int32_t arg_d4ch, int32_t arg_d50h);
│ `- args(a0, a1, a2, a3, sp[0x0..0x18]) vars(48:sp[0x4..0xd28])
│           0x004c02fc      lui gp, 0x5c
│           0x004c0300      addiu sp, sp, -0xd38
│           0x004c0304      addiu gp, gp, -0x2f0
│           0x004c0308      sw ra, (var_d34h)
│           0x004c030c      sw fp, (var_d30h)
│           0x004c0310      sw s7, (var_d2ch)
│           0x004c0314      sw s6, (var_d28h)
│           0x004c0318      sw s5, (var_d24h)
│           0x004c031c      sw s4, (var_d20h)
│           0x004c0320      sw s3, (var_d1ch)
│           0x004c0324      sw s2, (var_d18h)
│           0x004c0328      sw s1, (var_d14h)
│           0x004c032c      sw s0, (var_d10h)
│           0x004c0330      sw gp, (var_20h)
│           0x004c0334      lw s0, (arg_d4ch)
│           0x004c0338      addiu s1, zero, 0x3e8
│           0x004c033c      addiu s4, sp, 0x50
│       ┌─< 0x004c0340      bnez s1, 0x4c034c
│       │   0x004c0344      div zero, s0, s1
│       │   0x004c0348      break 7
│       │   ; CODE XREF from sym.lowLayerPing @ 0x4c0340(x)
│       └─> 0x004c034c      sw a0, (arg_d38h)
│           0x004c0350      sw a1, (arg_d3ch)
│           0x004c0354      sw a2, (arg_d40h)
│           0x004c0358      sw a3, (arg_d44h)
│           0x004c035c      lw t9, -sym.imp.socket(gp)                 ; [0x561820:4]=0x8f998010
│           0x004c0360      sw zero, (var_50h)
│           0x004c0364      addiu a0, zero, 2                          ; arg1
│           0x004c0368      addiu a1, zero, 3                          ; arg2
│           0x004c036c      addiu a2, zero, 1                          ; arg3
│           0x004c0370      lw fp, (arg_d50h)
│           0x004c0374      mfhi v1
│           0x004c0378      mflo v0
│           0x004c037c      sw v0, (var_cech)
│           0x004c0380      sw zero, (var_54h)
│           0x004c0384      mult v1, s1
│           0x004c0388      sw zero, (var_8h)
│           0x004c038c      sw zero, (var_ch)
│           0x004c0390      addiu v0, zero, 0x10
│           0x004c0394      sw v0, (var_28h)
│           0x004c0398      lw v1, (var_cech)
│           0x004c039c      lui v0, 0x5c
│           0x004c03a0      sw zero, -0x45e0(v0)
│           0x004c03a4      addiu v0, sp, 0x60
│           0x004c03a8      sw v0, (var_cc8h)
│           0x004c03ac      sw v1, (var_30h)
│           0x004c03b0      mflo v0
│           0x004c03b4      sw v0, (var_ce8h)
│           0x004c03b8      jalr t9
│           0x004c03bc      sw v0, (var_34h)
│           0x004c03c0      move s2, v0
│           0x004c03c4      addiu v0, zero, -1
│           0x004c03c8      lw gp, (var_20h)
│       ┌─< 0x004c03cc      beq s2, v0, 0x4c0874
│       │   0x004c03d0      mult s0, s1
│       │   0x004c03d4      lw t9, -sym.imp.ioctl(gp)                  ; [0x561170:4]=0x8f998010
│       │   0x004c03d8      move a0, s2
│       │   0x004c03dc      addiu a1, zero, 0x667e                     ; arg2
│       │   0x004c03e0      addiu a2, zero, 1                          ; arg3
│       │   0x004c03e4      addiu s0, sp, 0x78
│       │   0x004c03e8      move s1, zero
│       │   0x004c03ec      addiu s7, sp, 0x688
│       │   0x004c03f0      mflo v0
│       │   0x004c03f4      jalr t9
│       │   0x004c03f8      sw v0, (var_cd0h)
│       │   0x004c03fc      lw gp, (var_20h)
│       │   0x004c0400      lw v1, (arg_d40h)
│       │   0x004c0404      lw a0, (arg_d48h)
│       │   0x004c0408      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│       │   0x004c040c      addiu v0, zero, 2
│       │   0x004c0410      sw v1, (var_ce4h)
│       │   0x004c0414      sw v1, (var_44h)
│       │   0x004c0418      sw a0, (var_ce0h)
│       │   0x004c041c      move a1, zero
│       │   0x004c0420      move a0, s0
│       │   0x004c0424      addiu a2, zero, 0x60e                      ; arg3
│       │   0x004c0428      jalr t9
│       │   0x004c042c      sh v0, (var_40h)
│       │   0x004c0430      lw gp, (var_20h)
│       │   0x004c0434      lw v0, (var_ce0h)
│       │   0x004c0438      move a0, s0
│       │   0x004c043c      lw t9, -sym.fillIcmpPkt(gp)                ; [0x4c1168:4]=0x3c1c005c ; "<\x1c"
│       │   0x004c0440      addiu s6, v0, 8
│       │   0x004c0444      jalr t9
│       │   0x004c0448      move a1, s6
│       │   0x004c044c      lw gp, (var_20h)
│       │   0x004c0450      srl v1, fp, 5
│       │   0x004c0454      sll v1, v1, 2
│       │   0x004c0458      sw v1, (var_cf8h)
│       │   0x004c045c      lw v1, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│       │   0x004c0460      srl v0, s2, 5
│       │   0x004c0464      sll v0, v0, 2
│       │   0x004c0468      addu s5, v1, v0
│       │   0x004c046c      addiu v1, zero, 1
│       │   0x004c0470      sllv v0, v1, s2
│       │   0x004c0474      sw v0, (var_cd4h)
│       │   0x004c0478      lw v0, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│       │   0x004c047c      andi a0, fp, 0x1f                          ; arg1
│       │   0x004c0480      sw a0, (var_cdch)
│       │   0x004c0484      addiu s3, v0, 0xc
│       │   0x004c0488      lw v0, (var_cdch)
│       │   0x004c048c      lw a0, (arg_d44h)
│       │   0x004c0490      sw s4, (var_d0ch)
│       │   0x004c0494      sllv v1, v1, v0
│       │   0x004c0498      sw a0, (var_ccch)
│       │   0x004c049c      sw v1, (var_cd8h)
│       │   0x004c04a0      lw a0, (var_cf8h)
│       │   0x004c04a4      lw v1, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│       │   0x004c04a8      slt v0, s2, fp
│       │   0x004c04ac      sw v0, (var_d00h)
│       │   0x004c04b0      addu v1, v1, a0                            ; arg1
│       │   0x004c04b4      sw v1, (var_cfch)
│       │   0x004c04b8      addiu v1, sp, 0x30
│       │   0x004c04bc      sw v1, (var_d04h)
│      ┌──< 0x004c04c0      b 0x4c0810
│      ││   0x004c04c4      sw s5, (var_d08h)
│      ││   ; CODE XREF from sym.lowLayerPing @ 0x4c081c(x)
│     ┌───> 0x004c04c8      lw v0, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│     ╎││   0x004c04cc      lw a0, (var_ce0h)
│     ╎││   0x004c04d0      addiu a2, sp, 0x10                         ; arg3
│     ╎││   0x004c04d4      sh a0, 8(v0)
│     ╎││   0x004c04d8      lw a0, (var_ce4h)
│     ╎││   0x004c04dc      addiu a3, sp, 0x40                         ; arg4
│    ┌────< 0x004c04e0      b 0x4c04f4
│    │╎││   0x004c04e4      sw a0, 4(v0)
│    │╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c0500(x)
│   ┌─────> 0x004c04e8      lbu v0, (a1)                               ; arg2
│   ╎│╎││   0x004c04ec      nop
│   ╎│╎││   0x004c04f0      sb v0, (a0)                                ; arg1
│   ╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c04e0(x)
│   ╎└────> 0x004c04f4     .string "_b" ; len=2
│   ╎ ╎││   0x004c04f6      unaligned
│   ╎ ╎││   0x004c04f8      addu a1, a3, v1                            ; arg4
│   ╎ ╎││   0x004c04fc      addu a0, a2, v1                            ; arg3
│   └─────< 0x004c0500      bnez v0, 0x4c04e8
│     ╎││   0x004c0504      addiu v1, v1, 1
│     ╎││   0x004c0508      lw t9, -sym.sendIcmpPkt(gp)                ; [0x4c1544:4]=0x3c1c005c ; "<\x1c"
│     ╎││   0x004c050c      addiu a1, sp, 0x78                         ; arg2
│     ╎││   0x004c0510      move a0, s2
│     ╎││   0x004c0514      move a2, s6
│     ╎││   0x004c0518      jalr t9
│     ╎││   0x004c051c      move a3, s1
│     ╎││   0x004c0520      addiu v0, sp, 0x28
│     ╎││   0x004c0524      addiu v1, sp, 0x69c
│     ╎││   0x004c0528      lw gp, (var_20h)
│     ╎││   0x004c052c      sw v0, (var_cf0h)
│     ╎││   0x004c0530      sw v1, (var_cf4h)
│    ┌────< 0x004c0534      b 0x4c07f0
│    │╎││   0x004c0538      addiu s4, sp, 0x78
│    │╎││   ; CODE XREFS from sym.lowLayerPing @ 0x4c054c(x), 0x4c07f4(x)
│  ┌┌─────> 0x004c053c      lw a0, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│  ╎╎│╎││   0x004c0540      sw zero, (v0)                              ; 0x5e9fb4
│  ╎╎│╎││                                                              ; obj.icmp_fdset
│  ╎╎│╎││   0x004c0544      addiu v0, v0, 4
│  ╎╎│╎││   0x004c0548      addiu a0, a0, 0x80                         ; arg1
│  └──────< 0x004c054c      bne v0, a0, 0x4c053c
│   ╎│╎││   0x004c0550      nop
│   ╎│╎││   0x004c0554      lw v1, (var_cfch)
│   ╎│╎││   0x004c0558      lw a0, (var_cech)
│   ╎│╎││   0x004c055c      lw v0, (v1)
│   ╎│╎││   0x004c0560      lw v1, (var_ce8h)
│   ╎│╎││   0x004c0564      sw a0, (var_30h)
│   ╎│╎││   0x004c0568      lw a0, (var_cd8h)
│   ╎│╎││   0x004c056c      sw v1, (var_34h)
│   ╎│╎││   0x004c0570      lw v1, (var_cfch)
│   ╎│╎││   0x004c0574      or v0, v0, a0                              ; arg1
│   ╎│╎││   0x004c0578      sw v0, (v1)
│   ╎│╎││   0x004c057c      lw v0, (s5)                                ; [0x5e9fb4:4]=0
│   ╎│╎││                                                              ; obj.icmp_fdset
│   ╎│╎││   0x004c0580      lw v1, (var_cd4h)
│   ╎│╎││   0x004c0584      nop
│   ╎│╎││   0x004c0588      or v0, v0, v1
│   ╎│╎││   0x004c058c      sw v0, (s5)                                ; 0x5e9fb4
│   ╎│╎││                                                              ; obj.icmp_fdset
│   ╎│╎││   0x004c0590      lw v0, (var_d00h)
│   ╎│╎││   0x004c0594      nop
│  ┌──────< 0x004c0598      beqz v0, 0x4c05a4
│  │╎│╎││   0x004c059c      move a0, s2
│  │╎│╎││   0x004c05a0      move a0, fp
│  │╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c0598(x)
│  └──────> 0x004c05a4      lw v1, (var_d04h)
│   ╎│╎││   0x004c05a8      lw t9, -sym.imp.select(gp)                 ; [0x5612c0:4]=0x8f998010
│   ╎│╎││   0x004c05ac      lw a1, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│   ╎│╎││   0x004c05b0      sw v1, (var_10h)
│   ╎│╎││   0x004c05b4      addiu a0, a0, 1                            ; arg1
│   ╎│╎││   0x004c05b8      move a2, zero
│   ╎│╎││   0x004c05bc      jalr t9
│   ╎│╎││   0x004c05c0      move a3, zero
│   ╎│╎││   0x004c05c4      lw gp, (var_20h)
│  ┌──────< 0x004c05c8      blez v0, 0x4c07d8
│  │╎│╎││   0x004c05cc      nop
│  │╎│╎││   0x004c05d0      lw a0, (var_d08h)
│  │╎│╎││   0x004c05d4      lw v1, (var_cd4h)
│  │╎│╎││   0x004c05d8      lw v0, (a0)                                ; arg1
│  │╎│╎││   0x004c05dc      nop
│  │╎│╎││   0x004c05e0      and v0, v1, v0
│ ┌───────< 0x004c05e4      beqz v0, 0x4c0780
│ ││╎│╎││   0x004c05e8      move a1, zero
│ ││╎│╎││   0x004c05ec      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│ ││╎│╎││   0x004c05f0      move a0, s7
│ ││╎│╎││   0x004c05f4      jalr t9
│ ││╎│╎││   0x004c05f8      addiu a2, zero, 0x640                      ; arg3
│ ││╎│╎││   0x004c05fc      lw gp, (var_20h)
│ ││╎│╎││   0x004c0600      lw a0, (var_d0ch)
│ ││╎│╎││   0x004c0604      lw v0, (var_cf0h)
│ ││╎│╎││   0x004c0608      lw t9, -sym.imp.recvfrom(gp)               ; [0x5617d0:4]=0x8f998010
│ ││╎│╎││   0x004c060c      sw a0, (var_10h)
│ ││╎│╎││   0x004c0610      move a1, s7
│ ││╎│╎││   0x004c0614      move a0, s2
│ ││╎│╎││   0x004c0618      addiu a2, zero, 0x640                      ; arg3
│ ││╎│╎││   0x004c061c      move a3, zero
│ ││╎│╎││   0x004c0620      jalr t9
│ ││╎│╎││   0x004c0624      sw v0, (var_14h)
│ ││╎│╎││   0x004c0628      lw gp, (var_20h)
│ ││╎│╎││   0x004c062c      move a0, s7
│ ││╎│╎││   0x004c0630      lw t9, -sym.icmpVerifyId(gp)               ; [0x4c101c:4]=0x3c1c005c ; "<\x1c"
│ ││╎│╎││   0x004c0634      nop
│ ││╎│╎││   0x004c0638      jalr t9
│ ││╎│╎││   0x004c063c      move s0, v0
│ ││╎│╎││   0x004c0640      lw gp, (var_20h)
│ ────────< 0x004c0644      beqz v0, 0x4c07f0
│ ││╎│╎││   0x004c0648      move a1, s4
│ ││╎│╎││   0x004c064c      lw t9, -sym.imp.memcmp(gp)                 ; [0x5617b0:4]=0x8f998010
│ ││╎│╎││   0x004c0650      lw a0, (var_cf4h)
│ ││╎│╎││   0x004c0654      jalr t9
│ ││╎│╎││   0x004c0658      move a2, s6
│ ││╎│╎││   0x004c065c      lw gp, (var_20h)
│ ────────< 0x004c0660      beqz v0, 0x4c07f0
│ ││╎│╎││   0x004c0664      nop
│ ││╎│╎││   0x004c0668      addiu v0, zero, -1
│ ────────< 0x004c066c      bne s0, v0, 0x4c067c
│ ││╎│╎││   0x004c0670      move a1, zero
│ ────────< 0x004c0674      b 0x4c0780
│ ││╎│╎││   0x004c0678      sb s0, (s3)
│ ││╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c066c(x)
│ ────────> 0x004c067c      lw t9, -sym.imp.gettimeofday(gp)           ; [0x561060:4]=0x8f998010
│ ││╎│╎││   0x004c0680      nop
│ ││╎│╎││   0x004c0684      jalr t9
│ ││╎│╎││   0x004c0688      addiu a0, sp, 0x38                         ; arg1
│ ││╎│╎││   0x004c068c      lbu v0, (var_688h)                         ; [0x561060:1]=143
│ ││╎│╎││                                                              ; sym.imp.gettimeofday
│ ││╎│╎││   0x004c0690      lw gp, (var_20h)
│ ││╎│╎││   0x004c0694      andi v0, v0, 0xf
│ ││╎│╎││   0x004c0698      sll a1, v0, 2                              ; arg2
│ ││╎│╎││   0x004c069c      addu v1, s7, a1                            ; arg2
│ ││╎│╎││   0x004c06a0      lbu v0, (v1)
│ ││╎│╎││   0x004c06a4      nop
│ ────────< 0x004c06a8      bnez v0, 0x4c0770
│ ││╎│╎││   0x004c06ac      addiu v0, zero, 3
│ ││╎│╎││   0x004c06b0      lhu s4, 6(v1)
│ ││╎│╎││   0x004c06b4      nop
│ ────────< 0x004c06b8      bne s4, s1, 0x4c0770
│ ││╎│╎││   0x004c06bc      addiu v1, zero, 0x14
│ ││╎│╎││   0x004c06c0      mult s1, v1
│ ││╎│╎││   0x004c06c4      lw v0, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│ ││╎│╎││   0x004c06c8      addiu a3, s1, 1                            ; arg4
│ ││╎│╎││   0x004c06cc      addiu t0, s0, -0x1c
│ ││╎│╎││   0x004c06d0      lw t9, -sym.imp.memcpy(gp)                 ; [0x560f70:4]=0x8f998010
│ ││╎│╎││   0x004c06d4      addiu a1, a1, 8                            ; arg2
│ ││╎│╎││   0x004c06d8      addiu a0, sp, 0x2c                         ; arg1
│ ││╎│╎││   0x004c06dc      addu a1, s7, a1                            ; arg2
│ ││╎│╎││   0x004c06e0      addiu a2, zero, 4                          ; arg3
│ ││╎│╎││   0x004c06e4      mflo v1
│ ││╎│╎││   0x004c06e8      addu v0, v0, v1
│ ││╎│╎││   0x004c06ec      sb a3, 0x1d(v0)
│ ││╎│╎││   0x004c06f0      lw v1, (var_54h)
│ ││╎│╎││   0x004c06f4      sh t0, 0x14(v0)
│ ││╎│╎││   0x004c06f8      sw v1, 0x10(v0)
│ ││╎│╎││   0x004c06fc      lbu v1, (var_690h)
│ ││╎│╎││   0x004c0700      sb zero, 0xc(v0)
│ ││╎│╎││   0x004c0704      jalr t9
│ ││╎│╎││   0x004c0708      sb v1, 0x1c(v0)
│ ││╎│╎││   0x004c070c      lw v0, (var_38h)
│ ││╎│╎││   0x004c0710      lui v1, 0xf
│ ││╎│╎││   0x004c0714      ori v1, v1, 0x4240
│ ││╎│╎││   0x004c0718      mult v0, v1
│ ││╎│╎││   0x004c071c      lw v1, (var_3ch)
│ ││╎│╎││   0x004c0720      addiu a0, zero, 0x3e8                      ; arg1
│ ││╎│╎││   0x004c0724      lw gp, (var_20h)
│ ││╎│╎││   0x004c0728      mflo v0
│ ││╎│╎││   0x004c072c      addu v0, v0, v1
│ ││╎│╎││   0x004c0730      lw v1, (var_2ch)
│ ││╎│╎││   0x004c0734      nop
│ ││╎│╎││   0x004c0738      subu v0, v0, v1
│ ────────< 0x004c073c      bnez a0, 0x4c0748
│ ││╎│╎││   0x004c0740      divu zero, v0, a0                          ; arg1
│ ││╎│╎││   0x004c0744      break 7
│ ││╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c073c(x)
│ ────────> 0x004c0748      mflo a0
│ ────────< 0x004c074c      bnez a0, 0x4c0758
│ ││╎│╎││   0x004c0750      addiu v1, zero, 0x14
│ ││╎│╎││   0x004c0754      addiu a0, zero, 1                          ; arg1
│ ││╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c074c(x)
│ ────────> 0x004c0758      mult s4, v1
│ ││╎│╎││   0x004c075c      lw v0, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│ ││╎│╎││   0x004c0760      mflo v1
│ ││╎│╎││   0x004c0764      addu v0, v0, v1
│ ────────< 0x004c0768      b 0x4c0780
│ ││╎│╎││   0x004c076c      sw a0, 0x18(v0)
│ ││╎│╎││   ; CODE XREFS from sym.lowLayerPing @ 0x4c06a8(x), 0x4c06b8(x)
│ ────────> 0x004c0770      sb v0, (s3)
│ ││╎│╎││   0x004c0774      lw v0, (var_54h)
│ ││╎│╎││   0x004c0778      nop
│ ││╎│╎││   0x004c077c      sw v0, 4(s3)
│ ││╎│╎││   ; CODE XREFS from sym.lowLayerPing @ 0x4c05e4(x), 0x4c0674(x), 0x4c0768(x)
│ └───────> 0x004c0780      lw v1, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│  │╎│╎││   0x004c0784      lw a0, (var_cf8h)
│  │╎│╎││   0x004c0788      nop
│  │╎│╎││   0x004c078c      addu v0, v1, a0                            ; arg1
│  │╎│╎││   0x004c0790      lw v0, (v0)                                ; [0x5e9fb4:4]=0
│  │╎│╎││                                                              ; obj.icmp_fdset
│  │╎│╎││   0x004c0794      lw v1, (var_cdch)
│  │╎│╎││   0x004c0798      nop
│  │╎│╎││   0x004c079c      srav v0, v0, v1
│  │╎│╎││   0x004c07a0      andi v0, v0, 1
│ ┌───────< 0x004c07a4      beqz v0, 0x4c0850
│ ││╎│╎││   0x004c07a8      move a0, zero
│ ││╎│╎││   0x004c07ac      lw t9, -sym.imp.recvfrom(gp)               ; [0x5617d0:4]=0x8f998010
│ ││╎│╎││   0x004c07b0      lw a1, (var_cc8h)
│ ││╎│╎││   0x004c07b4      move a0, fp
│ ││╎│╎││   0x004c07b8      sw zero, (var_10h)
│ ││╎│╎││   0x004c07bc      sw zero, (var_14h)
│ ││╎│╎││   0x004c07c0      addiu a2, zero, 0x18                       ; arg3
│ ││╎│╎││   0x004c07c4      jalr t9
│ ││╎│╎││   0x004c07c8      move a3, zero
│ ││╎│╎││   0x004c07cc      lw gp, (var_20h)
│ ────────< 0x004c07d0      b 0x4c0850
│ ││╎│╎││   0x004c07d4      addiu a0, zero, 1                          ; arg1
│ ││╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c05c8(x)
│ ─└──────> 0x004c07d8      beqz v0, 0x4c07e4
│ │ ╎│╎││   0x004c07dc      addiu v0, zero, -1
│ │ ╎│╎││   0x004c07e0      addiu v0, zero, 3
│ │ ╎│╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c07d8(x)
│ ────────> 0x004c07e4      sb v0, (s3)
│ │┌──────< 0x004c07e8      b 0x4c0850
│ ││╎│╎││   0x004c07ec      move a0, zero
│ ││╎│╎││   ; CODE XREFS from sym.lowLayerPing @ 0x4c0534(x), 0x4c0644(x), 0x4c0660(x)
│ ───└────> 0x004c07f0      lw v0, -obj.icmp_fdset(gp)                 ; [0x5e9fb4:4]=0
│ ││└─────< 0x004c07f4      b 0x4c053c
│ ││  ╎││   0x004c07f8      nop
│ ││  ╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c0864(x)
│ ││ ┌────> 0x004c07fc      lw t9, -sym.imp.usleep(gp)                 ; [0x560f60:4]=0x8f998010
│ ││ ╎╎││   0x004c0800      lw a0, (var_cd0h)
│ ││ ╎╎││   0x004c0804      jalr t9
│ ││ ╎╎││   0x004c0808      addiu s1, s1, 1
│ ││ ╎╎││   0x004c080c      lw gp, (var_20h)
│ ││ ╎╎││   ; CODE XREF from sym.lowLayerPing @ 0x4c04c0(x)
│ ││ ╎╎└──> 0x004c0810      lw a0, (var_ccch)
│ ││ ╎╎ │   0x004c0814      nop
│ ││ ╎╎ │   0x004c0818      slt v0, s1, a0
│ ││ ╎└───< 0x004c081c      bnez v0, 0x4c04c8
│ ││ ╎  │   0x004c0820      move v1, zero
│ ││ ╎  │   ; CODE XREF from sym.lowLayerPing @ 0x4c086c(x)
│ ││ ╎ ┌──> 0x004c0824      lw v0, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│ ││ ╎ ╎│   0x004c0828      lw t9, -sym.imp.close(gp)                  ; [0x561520:4]=0x8f998010
│ ││ ╎ ╎│   0x004c082c      addiu v1, zero, 1
│ ││ ╎ ╎│   0x004c0830      sb s1, 0xa(v0)
│ ││ ╎ ╎│   0x004c0834      lui v0, 0x5c
│ ││ ╎ ╎│   0x004c0838      sw v1, -0x45e0(v0)
│ ││ ╎ ╎│   0x004c083c      jalr t9
│ ││ ╎ ╎│   0x004c0840      move a0, s2
│ ││ ╎ ╎│   0x004c0844      lw gp, (var_20h)
│ ││ ╎┌───< 0x004c0848      b 0x4c0874
│ ││ ╎│╎│   0x004c084c      nop
│ ││ ╎│╎│   ; CODE XREFS from sym.lowLayerPing @ 0x4c07a4(x), 0x4c07d0(x), 0x4c07e8(x)
│ └└──────> 0x004c0850      lw v1, -obj.g_pingResult(gp)               ; [0x5e8cb4:4]=0
│    ╎│╎│   0x004c0854      addiu s3, s3, 0x14
│    ╎│╎│   0x004c0858      lbu v0, 0xb(v1)                            ; [0x5e8cb4:1]=0
│    ╎│╎│                                                              ; obj.g_pingResult
│    ╎│╎│   0x004c085c      nop
│    ╎│╎│   0x004c0860      addiu v0, v0, 1
│    └────< 0x004c0864      beqz a0, 0x4c07fc
│     │╎│   0x004c0868      sb v0, 0xb(v1)
│     │└──< 0x004c086c      b 0x4c0824
│     │ │   0x004c0870      nop
│     │ │   ; CODE XREFS from sym.lowLayerPing @ 0x4c03cc(x), 0x4c0848(x)
│     └─└─> 0x004c0874      lw ra, (var_d34h)
│           0x004c0878      lw fp, (var_d30h)
│           0x004c087c      lw s7, (var_d2ch)
│           0x004c0880      lw s6, (var_d28h)
│           0x004c0884      lw s5, (var_d24h)
│           0x004c0888      lw s4, (var_d20h)
│           0x004c088c      lw s3, (var_d1ch)
│           0x004c0890      lw s2, (var_d18h)
│           0x004c0894      lw s1, (var_d14h)
│           0x004c0898      lw s0, (var_d10h)
│           0x004c089c      jr ra
└           0x004c08a0      addiu sp, sp, 0xd38
