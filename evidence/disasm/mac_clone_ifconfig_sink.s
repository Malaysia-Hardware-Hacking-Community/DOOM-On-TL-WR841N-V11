// mac_clone_ifconfig_sink
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004a4870; pd 140" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            0x004a4870      8fbc0010       lw gp, 0x10(sp)
        ┌─< 0x004a4874      1043000a       beq v0, v1, 0x4a48a0
        │   0x004a4878      00000000       nop
        │   0x004a487c      8f99a8e0       lw t9, -sym.swGetProductId(gp) ; [0x5ba5f0:4]=0x473d18 sym.swGetProductId
        │   0x004a4880      00000000       nop
        │   0x004a4884      0320f809       jalr t9
        │   0x004a4888      00000000       nop
        │   0x004a488c      3c030941       lui v1, 0x941
        │   0x004a4890      34631001       ori v1, v1, 0x1001
        │   0x004a4894      8fbc0010       lw gp, 0x10(sp)
       ┌──< 0x004a4898      1443001e       bne v0, v1, 0x4a4914
       ││   0x004a489c      00000000       nop
       │└─> 0x004a48a0      8fa30020       lw v1, 0x20(sp)
       │    0x004a48a4      24020006       addiu v0, zero, 6
       │┌─< 0x004a48a8      10620003       beq v1, v0, 0x4a48b8
       ││   0x004a48ac      24020003       addiu v0, zero, 3
      ┌───< 0x004a48b0      14620018       bne v1, v0, 0x4a4914
      │││   0x004a48b4      00000000       nop
      ││└─> 0x004a48b8      8f999870       lw t9, -sym.swWlanGetMac(gp) ; [0x5b9580:4]=0x484618 sym.swWlanGetMac
      ││    0x004a48bc      27b00018       addiu s0, sp, 0x18
      ││    0x004a48c0      02202021       move a0, s1
      ││    0x004a48c4      0320f809       jalr t9
      ││    0x004a48c8      02002821       move a1, s0
      ││    0x004a48cc      8fbc0010       lw gp, 0x10(sp)
      ││    0x004a48d0      27a50028       addiu a1, sp, 0x28
      ││    0x004a48d4      02002021       move a0, s0
      ││    0x004a48d8      8f999920       lw t9, -sym.swMac2Str(gp)   ; [0x5b9630:4]=0x47420c sym.swMac2Str
      ││    0x004a48dc      00000000       nop
      ││    0x004a48e0      0320f809       jalr t9
      ││    0x004a48e4      24060001       addiu a2, zero, 1
      ││    0x004a48e8      8fbc0010       lw gp, 0x10(sp)
      ││┌─< 0x004a48ec      16200003       bnez s1, 0x4a48fc
      │││   0x004a48f0      00002821       move a1, zero
      │││   0x004a48f4      3c020057       lui v0, 0x57
      │││   0x004a48f8      24452960       addiu a1, v0, 0x2960
      ││└─> 0x004a48fc      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
      ││    0x004a4900      3c040057       lui a0, 0x57
      ││    0x004a4904      24844720       addiu a0, a0, 0x4720
      ││    0x004a4908      0320f809       jalr t9
      ││    0x004a490c      27a60028       addiu a2, sp, 0x28
      ││    0x004a4910      8fbc0010       lw gp, 0x10(sp)
      └└──> 0x004a4914      8fa4020c       lw a0, 0x20c(sp)
            0x004a4918      24020003       addiu v0, zero, 3
        ┌─< 0x004a491c      14820020       bne a0, v0, 0x4a49a0
        │   0x004a4920      24020004       addiu v0, zero, 4
        │   0x004a4924      8fa200e4       lw v0, 0xe4(sp)
        │   0x004a4928      00000000       nop
       ┌──< 0x004a492c      1440000b       bnez v0, 0x4a495c
       ││   0x004a4930      27a3010d       addiu v1, sp, 0x10d
       ││   0x004a4934      27a400ec       addiu a0, sp, 0xec
       ││   0x004a4938      0c1279a6       jal sym.wlanStrToChars
       ││   0x004a493c      27a50060       addiu a1, sp, 0x60
       ││   0x004a4940      8fbc0010       lw gp, 0x10(sp)
       ││   0x004a4944      3c040057       lui a0, 0x57
       ││   0x004a4948      24844708       addiu a0, a0, 0x4708
       ││   0x004a494c      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
       ││   0x004a4950      00403021       move a2, v0
      ┌───< 0x004a4954      10000036       b 0x4a4a30
      │││   0x004a4958      24050007       addiu a1, zero, 7
      │└──> 0x004a495c      2406002d       addiu a2, zero, 0x2d
      │ │   0x004a4960      2405003a       addiu a1, zero, 0x3a
      │ │   0x004a4964      27a4011f       addiu a0, sp, 0x11f
      │ │   0x004a4968      90620000       lbu v0, (v1)
      │ │   0x004a496c      00000000       nop
      │ │   0x004a4970      14460002       bne v0, a2, 0x4a497c
      │ │   0x004a4974      00000000       nop
      │ │   0x004a4978      a0650000       sb a1, (v1)
      │ │   0x004a497c      24630001       addiu v1, v1, 1
      │ │   0x004a4980      1464fff9       bne v1, a0, 0x4a4968
      │ │   0x004a4984      00000000       nop
      │ │   0x004a4988      3c040057       lui a0, 0x57
      │ │   0x004a498c      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
      │ │   0x004a4990      24844738       addiu a0, a0, 0x4738
      │ │   0x004a4994      24050007       addiu a1, zero, 7
      │ │   0x004a4998      10000025       b 0x4a4a30
      │ │   0x004a499c      27a6010d       addiu a2, sp, 0x10d
      │ └─> 0x004a49a0      14820013       bne a0, v0, 0x4a49f0
      │     0x004a49a4      27a30131       addiu v1, sp, 0x131
      │     0x004a49a8      00603021       move a2, v1
      │     0x004a49ac      2405002d       addiu a1, zero, 0x2d
      │     0x004a49b0      27a3011f       addiu v1, sp, 0x11f
      │     0x004a49b4      2404003a       addiu a0, zero, 0x3a
      │     0x004a49b8      90620000       lbu v0, (v1)
      │     0x004a49bc      00000000       nop
      │     0x004a49c0      14450002       bne v0, a1, 0x4a49cc
      │     0x004a49c4      00000000       nop
      │     0x004a49c8      a0640000       sb a0, (v1)
      │     0x004a49cc      24630001       addiu v1, v1, 1
      │     0x004a49d0      1466fff9       bne v1, a2, 0x4a49b8
      │     0x004a49d4      00000000       nop
      │     0x004a49d8      3c040057       lui a0, 0x57
      │     0x004a49dc      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
      │     0x004a49e0      24844738       addiu a0, a0, 0x4738
      │     0x004a49e4      24050007       addiu a1, zero, 7
      │     0x004a49e8      10000011       b 0x4a4a30
      │     0x004a49ec      27a6011f       addiu a2, sp, 0x11f
      │     0x004a49f0      2406002d       addiu a2, zero, 0x2d
      │     0x004a49f4      2405003a       addiu a1, zero, 0x3a
      │     0x004a49f8      27a40143       addiu a0, sp, 0x143
      │     0x004a49fc      90620000       lbu v0, (v1)
      │     0x004a4a00      00000000       nop
      │     0x004a4a04      14460002       bne v0, a2, 0x4a4a10
      │     0x004a4a08      00000000       nop
      │     0x004a4a0c      a0650000       sb a1, (v1)
      │     0x004a4a10      24630001       addiu v1, v1, 1
      │     0x004a4a14      1464fff9       bne v1, a0, 0x4a49fc
      │     0x004a4a18      00000000       nop
      │     0x004a4a1c      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
      │     0x004a4a20      3c040057       lui a0, 0x57
      │     0x004a4a24      24844738       addiu a0, a0, 0x4738
      │     0x004a4a28      24050007       addiu a1, zero, 7
      │     0x004a4a2c      27a60131       addiu a2, sp, 0x131
      └───> 0x004a4a30      0320f809       jalr t9
            0x004a4a34      00000000       nop
            0x004a4a38      16200003       bnez s1, 0x4a4a48
            0x004a4a3c      00002821       move a1, zero
            0x004a4a40      3c020057       lui v0, 0x57
            0x004a4a44      24452960       addiu a1, v0, 0x2960
            0x004a4a48      02202021       move a0, s1
            0x004a4a4c      0c128f7b       jal 0x4a3dec
            0x004a4a50      27a60208       addiu a2, sp, 0x208
            0x004a4a54      8fbc0010       lw gp, 0x10(sp)
            0x004a4a58      00000000       nop
            0x004a4a5c      8f99a4d0       lw t9, -sym.getProductId(gp) ; [0x5ba1e0:4]=0x4eadf8 sym.getProductId
            0x004a4a60      00000000       nop
            0x004a4a64      0320f809       jalr t9
            0x004a4a68      3c100802       lui s0, 0x802
            0x004a4a6c      36030001       ori v1, s0, 1
            0x004a4a70      8fbc0010       lw gp, 0x10(sp)
            0x004a4a74      10430013       beq v0, v1, 0x4a4ac4
            0x004a4a78      00000000       nop
            0x004a4a7c      8f99a4d0       lw t9, -sym.getProductId(gp) ; [0x5ba1e0:4]=0x4eadf8 sym.getProductId
            0x004a4a80      00000000       nop
            0x004a4a84      0320f809       jalr t9
            0x004a4a88      00000000       nop
            0x004a4a8c      36030002       ori v1, s0, 2
            0x004a4a90      8fbc0010       lw gp, 0x10(sp)
            0x004a4a94      1043000b       beq v0, v1, 0x4a4ac4
            0x004a4a98      00000000       nop
            0x004a4a9c      16200003       bnez s1, 0x4a4aac
