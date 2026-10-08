// wlanInit_essid_sink
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004a9f90; pd 110" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- wlanInit:
            0x004a9f90      3c1c005c       lui gp, 0x5c
            0x004a9f94      27bdfe50       addiu sp, sp, -0x1b0
            0x004a9f98      279cfd10       addiu gp, gp, -0x2f0
            0x004a9f9c      afbf01ac       sw ra, 0x1ac(sp)
            0x004a9fa0      afb201a8       sw s2, 0x1a8(sp)
            0x004a9fa4      afb101a4       sw s1, 0x1a4(sp)
            0x004a9fa8      afb001a0       sw s0, 0x1a0(sp)
            0x004a9fac      afbc0010       sw gp, 0x10(sp)
            0x004a9fb0      8f99abe4       lw t9, -sym.swGetBoardType(gp) ; [0x5ba8f4:4]=0x473d30 sym.swGetBoardType
            0x004a9fb4      00000000       nop
            0x004a9fb8      0320f809       jalr t9
            0x004a9fbc      00000000       nop
            0x004a9fc0      8fbc0010       lw gp, 0x10(sp)
            0x004a9fc4      27a40018       addiu a0, sp, 0x18
            0x004a9fc8      8f99a484       lw t9, -sym.swGetSystemMode(gp) ; [0x5ba194:4]=0x47e304 sym.swGetSystemMode
            0x004a9fcc      00000000       nop
            0x004a9fd0      0320f809       jalr t9
            0x004a9fd4      00408021       move s0, v0
            0x004a9fd8      8fbc0010       lw gp, 0x10(sp)
            0x004a9fdc      00002021       move a0, zero
            0x004a9fe0      8f99ac58       lw t9, -sym.semBCreate(gp)  ; [0x5ba968:4]=0x50f9ec sym.semBCreate
            0x004a9fe4      00000000       nop
            0x004a9fe8      0320f809       jalr t9
            0x004a9fec      24050001       addiu a1, zero, 1
            0x004a9ff0      8fbc0010       lw gp, 0x10(sp)
            0x004a9ff4      3c03005c       lui v1, 0x5c
            0x004a9ff8      3c060056       lui a2, 0x56
            0x004a9ffc      8f99aca8       lw t9, -sym.HTTP_DEBUG_PRINT(gp) ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
            0x004aa000      3c050057       lui a1, 0x57
            0x004aa004      3c040057       lui a0, 0x57
            0x004aa008      ac62b300       sw v0, -0x4d00(v1)
            0x004aa00c      24c6287c       addiu a2, a2, 0x287c
            0x004aa010      00003821       move a3, zero
            0x004aa014      24a554cc       addiu a1, a1, 0x54cc
            0x004aa018      0320f809       jalr t9
            0x004aa01c      248454c0       addiu a0, a0, 0x54c0
            0x004aa020      8fbc0010       lw gp, 0x10(sp)
            0x004aa024      00000000       nop
            0x004aa028      8f998364       lw t9, -sym.swWlanGetMbssidNum(gp) ; [0x5b8074:4]=0x484454 sym.swWlanGetMbssidNum
            0x004aa02c      00000000       nop
            0x004aa030      0320f809       jalr t9
            0x004aa034      00002021       move a0, zero
            0x004aa038      8fbc0010       lw gp, 0x10(sp)
            0x004aa03c      00002021       move a0, zero
            0x004aa040      27a50020       addiu a1, sp, 0x20
            0x004aa044      8f998cd0       lw t9, -sym.swWlanBasicCfgGet(gp) ; [0x5b89e0:4]=0x48446c sym.swWlanBasicCfgGet
            0x004aa048      00000000       nop
            0x004aa04c      0320f809       jalr t9
            0x004aa050      00409021       move s2, v0
            0x004aa054      8fbc0010       lw gp, 0x10(sp)
            0x004aa058      00000000       nop
            0x004aa05c      8f999e08       lw t9, -sym.swWlanEnabled(gp) ; [0x5b9b18:4]=0x48483c sym.swWlanEnabled
            0x004aa060      00000000       nop
            0x004aa064      0320f809       jalr t9
            0x004aa068      00002021       move a0, zero
            0x004aa06c      8fbc0010       lw gp, 0x10(sp)
        ┌─< 0x004aa070      14400025       bnez v0, 0x4aa108
        │   0x004aa074      00000000       nop
        │   0x004aa078      8f9988f4       lw t9, -sym.wlanWpsLedTurnOff(gp) ; [0x5b8604:4]=0x4b30f8 sym.wlanWpsLedTurnOff
        │   0x004aa07c      00000000       nop
        │   0x004aa080      0320f809       jalr t9
        │   0x004aa084      00002021       move a0, zero
        │   0x004aa088      8fbc0010       lw gp, 0x10(sp)
        │   0x004aa08c      3c040057       lui a0, 0x57
        │   0x004aa090      3c050057       lui a1, 0x57
        │   0x004aa094      8f99aca8       lw t9, -sym.HTTP_DEBUG_PRINT(gp) ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
        │   0x004aa098      248454e4       addiu a0, a0, 0x54e4
        │   0x004aa09c      24a554f0       addiu a1, a1, 0x54f0
        │   0x004aa0a0      0320f809       jalr t9
        │   0x004aa0a4      00003021       move a2, zero
        │   0x004aa0a8      8fa20018       lw v0, 0x18(sp)
        │   0x004aa0ac      24030004       addiu v1, zero, 4
        │   0x004aa0b0      8fbc0010       lw gp, 0x10(sp)
        │   0x004aa0b4      1443011c       bne v0, v1, 0x4aa528
        │   0x004aa0b8      3c040057       lui a0, 0x57
        │   0x004aa0bc      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
        │   0x004aa0c0      3c050057       lui a1, 0x57
        │   0x004aa0c4      24844d14       addiu a0, a0, 0x4d14
        │   0x004aa0c8      0320f809       jalr t9
        │   0x004aa0cc      24a52a0c       addiu a1, a1, 0x2a0c
        │   0x004aa0d0      8fbc0010       lw gp, 0x10(sp)
        │   0x004aa0d4      00000000       nop
        │   0x004aa0d8      8f99861c       lw t9, -sym.getLanEth0Name(gp) ; [0x5b832c:4]=0x4eaaa8 sym.getLanEth0Name
        │   0x004aa0dc      00000000       nop
        │   0x004aa0e0      0320f809       jalr t9
        │   0x004aa0e4      00000000       nop
        │   0x004aa0e8      8fbc0010       lw gp, 0x10(sp)
        │   0x004aa0ec      3c040057       lui a0, 0x57
        │   0x004aa0f0      3c050057       lui a1, 0x57
        │   0x004aa0f4      8f99aca8       lw t9, -sym.HTTP_DEBUG_PRINT(gp) ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
        │   0x004aa0f8      24845518       addiu a0, a0, 0x5518
        │   0x004aa0fc      24a55524       addiu a1, a1, 0x5524
        │   0x004aa100      10000013       b 0x4aa150
        │   0x004aa104      00403021       move a2, v0
        └─> 0x004aa108      0c127e58       jal 0x49f960
            0x004aa10c      00002021       move a0, zero
            0x004aa110      8fbc0010       lw gp, 0x10(sp)
            0x004aa114      14400012       bnez v0, 0x4aa160
            0x004aa118      3c040057       lui a0, 0x57
            0x004aa11c      8f9985dc       lw t9, -sym.power_led_fast_blink(gp) ; [0x5b82ec:4]=0x4b8d20 sym.power_led_fast_blink
            0x004aa120      00000000       nop
            0x004aa124      0320f809       jalr t9
            0x004aa128      00000000       nop
            0x004aa12c      0c128ead       jal 0x4a3ab4
            0x004aa130      00000000       nop
            0x004aa134      8fbc0010       lw gp, 0x10(sp)
            0x004aa138      3c040057       lui a0, 0x57
            0x004aa13c      3c050057       lui a1, 0x57
            0x004aa140      8f99aca8       lw t9, -sym.HTTP_DEBUG_PRINT(gp) ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
            0x004aa144      24845540       addiu a0, a0, 0x5540
