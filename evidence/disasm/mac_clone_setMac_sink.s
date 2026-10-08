// mac_clone_setMac_sink
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004b4f10; pd 80" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            0x004b4f10      27b00074       addiu s0, sp, 0x74
            0x004b4f14      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
            0x004b4f18      3c050057       lui a1, 0x57
            0x004b4f1c      24a5cc50       addiu a1, a1, -0x33b0
            0x004b4f20      02002021       move a0, s0
            0x004b4f24      0320f809       jalr t9
            0x004b4f28      02403021       move a2, s2
            0x004b4f2c      8fbc0010       lw gp, 0x10(sp)
            0x004b4f30      00000000       nop
            0x004b4f34      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x004b4f38      00000000       nop
            0x004b4f3c      0320f809       jalr t9
            0x004b4f40      02002021       move a0, s0
            0x004b4f44      8fbc0010       lw gp, 0x10(sp)
            0x004b4f48      00000000       nop
            0x004b4f4c      8f999920       lw t9, -sym.swMac2Str(gp)   ; [0x5b9630:4]=0x47420c sym.swMac2Str
            0x004b4f50      27b00020       addiu s0, sp, 0x20
            0x004b4f54      02202021       move a0, s1
            0x004b4f58      02002821       move a1, s0
            0x004b4f5c      0320f809       jalr t9
            0x004b4f60      24060001       addiu a2, zero, 1
            0x004b4f64      8fbc0010       lw gp, 0x10(sp)
            0x004b4f68      27b10074       addiu s1, sp, 0x74
            0x004b4f6c      3c050057       lui a1, 0x57
            0x004b4f70      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
            0x004b4f74      24a54720       addiu a1, a1, 0x4720
            0x004b4f78      02003821       move a3, s0
            0x004b4f7c      02403021       move a2, s2
            0x004b4f80      0320f809       jalr t9
            0x004b4f84      02202021       move a0, s1
            0x004b4f88      8fbc0010       lw gp, 0x10(sp)
            0x004b4f8c      00000000       nop
            0x004b4f90      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x004b4f94      00000000       nop
            0x004b4f98      0320f809       jalr t9
            0x004b4f9c      02202021       move a0, s1
            0x004b4fa0      8fbc0010       lw gp, 0x10(sp)
            0x004b4fa4      00000000       nop
            0x004b4fa8      8f99abe4       lw t9, -sym.swGetBoardType(gp) ; [0x5ba8f4:4]=0x473d30 sym.swGetBoardType
            0x004b4fac      00000000       nop
            0x004b4fb0      0320f809       jalr t9
            0x004b4fb4      00000000       nop
            0x004b4fb8      24030006       addiu v1, zero, 6
            0x004b4fbc      8fbc0010       lw gp, 0x10(sp)
        ┌─< 0x004b4fc0      10430017       beq v0, v1, 0x4b5020
        │   0x004b4fc4      00000000       nop
        │   0x004b4fc8      8f99a4d0       lw t9, -sym.getProductId(gp) ; [0x5ba1e0:4]=0x4eadf8 sym.getProductId
        │   0x004b4fcc      00000000       nop
        │   0x004b4fd0      0320f809       jalr t9
        │   0x004b4fd4      00000000       nop
        │   0x004b4fd8      3c039020       lui v1, 0x9020
        │   0x004b4fdc      34630001       ori v1, v1, 1
        │   0x004b4fe0      8fbc0010       lw gp, 0x10(sp)
       ┌──< 0x004b4fe4      1043000e       beq v0, v1, 0x4b5020
       ││   0x004b4fe8      3c050057       lui a1, 0x57
       ││   0x004b4fec      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
       ││   0x004b4ff0      24a5cc64       addiu a1, a1, -0x339c
       ││   0x004b4ff4      02403021       move a2, s2
       ││   0x004b4ff8      0320f809       jalr t9
       ││   0x004b4ffc      02202021       move a0, s1
       ││   0x004b5000      8fbc0010       lw gp, 0x10(sp)
       ││   0x004b5004      00000000       nop
       ││   0x004b5008      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
       ││   0x004b500c      00000000       nop
       ││   0x004b5010      0320f809       jalr t9
       ││   0x004b5014      02202021       move a0, s1
       ││   0x004b5018      8fbc0010       lw gp, 0x10(sp)
       ││   0x004b501c      00000000       nop
       └└─> 0x004b5020      8f998a1c       lw t9, -sym.getWanIfName(gp) ; [0x5b872c:4]=0x4b43ac sym.getWanIfName
            0x004b5024      00000000       nop
            0x004b5028      0320f809       jalr t9
            0x004b502c      00000000       nop
            0x004b5030      8fbc0010       lw gp, 0x10(sp)
            0x004b5034      00000000       nop
            0x004b5038      8f99a6c8       lw t9, -sym.getWanStaticIpIfName(gp) ; [0x5ba3d8:4]=0x4eaa84 sym.getWanStaticIpIfName
            0x004b503c      00000000       nop
            0x004b5040      0320f809       jalr t9
            0x004b5044      00408021       move s0, v0
            0x004b5048      8fbc0010       lw gp, 0x10(sp)
            0x004b504c      02002021       move a0, s0
