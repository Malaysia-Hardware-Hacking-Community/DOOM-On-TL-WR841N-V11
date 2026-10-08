// httpWlanBasicCfg_handler_tail
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x00469a80; pd 130" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            0x00469a80      0320f809       jalr t9
            0x00469a84      00402021       move a0, v0
            0x00469a88      24030001       addiu v1, zero, 1
            0x00469a8c      8fbc0020       lw gp, 0x20(sp)
        ┌─< 0x00469a90      10430009       beq v0, v1, 0x469ab8
        │   0x00469a94      afa20030       sw v0, 0x30(sp)
       ┌──< 0x00469a98      10400005       beqz v0, 0x469ab0
       ││   0x00469a9c      2c420008       sltiu v0, v0, 8
      ┌───< 0x00469aa0      10400007       beqz v0, 0x469ac0
      │││   0x00469aa4      24020004       addiu v0, zero, 4
     ┌────< 0x00469aa8      10000005       b 0x469ac0
     ││││   0x00469aac      afa206f0       sw v0, 0x6f0(sp)
    ┌──└──> 0x00469ab0      10000003       b 0x469ac0
    │││ │   0x00469ab4      afa306f0       sw v1, 0x6f0(sp)
    │││ └─> 0x00469ab8      24020002       addiu v0, zero, 2
    │││     0x00469abc      afa206f0       sw v0, 0x6f0(sp)
    └└└───> 0x00469ac0      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x00469ac4      3c050057       lui a1, 0x57
            0x00469ac8      24a5f414       addiu a1, a1, -0xbec
            0x00469acc      0320f809       jalr t9
            0x00469ad0      02602021       move a0, s3
            0x00469ad4      8fbc0020       lw gp, 0x20(sp)
        ┌─< 0x00469ad8      10400055       beqz v0, 0x469c30
        │   0x00469adc      00000000       nop
        │   0x00469ae0      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
        │   0x00469ae4      00000000       nop
        │   0x00469ae8      0320f809       jalr t9
        │   0x00469aec      00402021       move a0, v0
        │   0x00469af0      8fbc0020       lw gp, 0x20(sp)
       ┌──< 0x00469af4      1000004e       b 0x469c30
       ││   0x00469af8      afa20058       sw v0, 0x58(sp)
       ││   0x00469afc      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
       ││   0x00469b00      3c050057       lui a1, 0x57
       ││   0x00469b04      24a5f41c       addiu a1, a1, -0xbe4
       ││   0x00469b08      0320f809       jalr t9
       ││   0x00469b0c      02602021       move a0, s3
       ││   0x00469b10      8fbc0020       lw gp, 0x20(sp)
      ┌───< 0x00469b14      10400046       beqz v0, 0x469c30
      │││   0x00469b18      00000000       nop
      │││   0x00469b1c      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
      │││   0x00469b20      00000000       nop
      │││   0x00469b24      0320f809       jalr t9
      │││   0x00469b28      00402021       move a0, v0
      │││   0x00469b2c      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469b30      3c050057       lui a1, 0x57
      │││   0x00469b34      24a5e99c       addiu a1, a1, -0x1664
      │││   0x00469b38      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
      │││   0x00469b3c      02602021       move a0, s3
      │││   0x00469b40      0320f809       jalr t9
      │││   0x00469b44      00408021       move s0, v0
      │││   0x00469b48      8fbc0020       lw gp, 0x20(sp)
     ┌────< 0x00469b4c      10400007       beqz v0, 0x469b6c
     ││││   0x00469b50      00000000       nop
     ││││   0x00469b54      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
     ││││   0x00469b58      00000000       nop
     ││││   0x00469b5c      0320f809       jalr t9
     ││││   0x00469b60      00402021       move a0, v0
     ││││   0x00469b64      8fbc0020       lw gp, 0x20(sp)
     ││││   0x00469b68      afa20698       sw v0, 0x698(sp)
     └────> 0x00469b6c      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
      │││   0x00469b70      3c050057       lui a1, 0x57
      │││   0x00469b74      24a5e9b0       addiu a1, a1, -0x1650
      │││   0x00469b78      0320f809       jalr t9
      │││   0x00469b7c      02602021       move a0, s3
      │││   0x00469b80      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469b84      10400007       beqz v0, 0x469ba4
      │││   0x00469b88      00000000       nop
      │││   0x00469b8c      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
      │││   0x00469b90      00000000       nop
      │││   0x00469b94      0320f809       jalr t9
      │││   0x00469b98      00402021       move a0, v0
      │││   0x00469b9c      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469ba0      afa206a4       sw v0, 0x6a4(sp)
      │││   0x00469ba4      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
      │││   0x00469ba8      3c050057       lui a1, 0x57
      │││   0x00469bac      24a5e9bc       addiu a1, a1, -0x1644
      │││   0x00469bb0      0320f809       jalr t9
      │││   0x00469bb4      02602021       move a0, s3
      │││   0x00469bb8      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469bbc      10400007       beqz v0, 0x469bdc
      │││   0x00469bc0      00000000       nop
      │││   0x00469bc4      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
      │││   0x00469bc8      00000000       nop
      │││   0x00469bcc      0320f809       jalr t9
      │││   0x00469bd0      00402021       move a0, v0
      │││   0x00469bd4      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469bd8      afa206a0       sw v0, 0x6a0(sp)
      │││   0x00469bdc      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
      │││   0x00469be0      3c050057       lui a1, 0x57
      │││   0x00469be4      24a5f42c       addiu a1, a1, -0xbd4
      │││   0x00469be8      0320f809       jalr t9
      │││   0x00469bec      02602021       move a0, s3
      │││   0x00469bf0      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469bf4      10400007       beqz v0, 0x469c14
      │││   0x00469bf8      00000000       nop
      │││   0x00469bfc      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
      │││   0x00469c00      00000000       nop
      │││   0x00469c04      0320f809       jalr t9
      │││   0x00469c08      00402021       move a0, v0
      │││   0x00469c0c      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469c10      afa206b0       sw v0, 0x6b0(sp)
      │││   0x00469c14      8f998bd0       lw t9, -sym.swWlanBasicDynSet(gp) ; [0x5b88e0:4]=0x4843d0 sym.swWlanBasicDynSet
      │││   0x00469c18      02802021       move a0, s4
      │││   0x00469c1c      27a50454       addiu a1, sp, 0x454
      │││   0x00469c20      0320f809       jalr t9
      │││   0x00469c24      27a605d0       addiu a2, sp, 0x5d0
      │││   0x00469c28      8fbc0020       lw gp, 0x20(sp)
      │││   0x00469c2c      afb005d4       sw s0, 0x5d4(sp)
      └└└─> 0x00469c30      8f99a324       lw t9, -sym.httpGetEnv(gp)  ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x00469c34      3c050057       lui a1, 0x57
            0x00469c38      24a5f420       addiu a1, a1, -0xbe0
            0x00469c3c      0320f809       jalr t9
            0x00469c40      02602021       move a0, s3
            0x00469c44      8fbc0020       lw gp, 0x20(sp)
            0x00469c48      10400007       beqz v0, 0x469c68
            0x00469c4c      00000000       nop
            0x00469c50      8f9985d8       lw t9, -sym.imp.atoi(gp)    ; [0x5b82e8:4]=0x561990 sym.imp.atoi
            0x00469c54      00000000       nop
            0x00469c58      0320f809       jalr t9
            0x00469c5c      00402021       move a0, v0
            0x00469c60      8fbc0020       lw gp, 0x20(sp)
            0x00469c64      afa205d4       sw v0, 0x5d4(sp)
            0x00469c68      8fa205d4       lw v0, 0x5d4(sp)
            0x00469c6c      24030003       addiu v1, zero, 3
            0x00469c70      14430006       bne v0, v1, 0x469c8c
            0x00469c74      24020003       addiu v0, zero, 3
            0x00469c78      8fa2006c       lw v0, 0x6c(sp)
            0x00469c7c      24030008       addiu v1, zero, 8
            0x00469c80      10430005       beq v0, v1, 0x469c98
            0x00469c84      24020005       addiu v0, zero, 5
