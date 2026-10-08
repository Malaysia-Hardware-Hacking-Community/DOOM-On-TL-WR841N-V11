// lan_domain_tp_domain_sink
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x00486f80; pd 70" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            0x00486f80      24060100       addiu a2, zero, 0x100
            0x00486f84      8fbc0018       lw gp, 0x18(sp)
            0x00486f88      00000000       nop
            0x00486f8c      8f99a4d0       lw t9, -sym.getProductId(gp) ; [0x5ba1e0:4]=0x4eadf8 sym.getProductId
            0x00486f90      00000000       nop
            0x00486f94      0320f809       jalr t9
            0x00486f98      00000000       nop
            0x00486f9c      8fbc0018       lw gp, 0x18(sp)
            0x00486fa0      3c030901       lui v1, 0x901
            0x00486fa4      34630003       ori v1, v1, 3
            0x00486fa8      8f998590       lw t9, -sym.getDefaultLanDomain(gp) ; [0x5b82a0:4]=0x4eaff8 sym.getDefaultLanDomain
        ┌─< 0x00486fac      14430013       bne v0, v1, 0x486ffc
        │   0x00486fb0      00000000       nop
        │   0x00486fb4      0320f809       jalr t9
        │   0x00486fb8      00000000       nop
        │   0x00486fbc      8fbc0018       lw gp, 0x18(sp)
        │   0x00486fc0      00002021       move a0, zero
        │   0x00486fc4      8f99ab34       lw t9, -sym.swGetWlanApOperMode(gp) ; [0x5ba844:4]=0x48486c sym.swGetWlanApOperMode
        │   0x00486fc8      00000000       nop
        │   0x00486fcc      0320f809       jalr t9
        │   0x00486fd0      00408021       move s0, v0
        │   0x00486fd4      8fbc0018       lw gp, 0x18(sp)
        │   0x00486fd8      3c050057       lui a1, 0x57
        │   0x00486fdc      02402021       move a0, s2
        │   0x00486fe0      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
        │   0x00486fe4      24a51708       addiu a1, a1, 0x1708
        │   0x00486fe8      02003021       move a2, s0
        │   0x00486fec      0320f809       jalr t9
        │   0x00486ff0      00403821       move a3, v0
       ┌──< 0x00486ff4      10000015       b 0x48704c
       ││   0x00486ff8      00000000       nop
       │└─> 0x00486ffc      8e020000       lw v0, (s0)
       │    0x00487000      00000000       nop
       │    0x00487004      8c510000       lw s1, (v0)
       │    0x00487008      0320f809       jalr t9
       │    0x0048700c      00000000       nop
       │    0x00487010      8fbc0018       lw gp, 0x18(sp)
       │    0x00487014      00000000       nop
       │    0x00487018      8f998e58       lw t9, -sym.getDefaultLanNewDomain(gp) ; [0x5b8b68:4]=0x4eb004 sym.getDefaultLanNewDomain
       │    0x0048701c      00000000       nop
       │    0x00487020      0320f809       jalr t9
       │    0x00487024      00408021       move s0, v0
       │    0x00487028      8fbc0018       lw gp, 0x18(sp)
       │    0x0048702c      3c050057       lui a1, 0x57
       │    0x00487030      afa20010       sw v0, 0x10(sp)
       │    0x00487034      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
       │    0x00487038      02402021       move a0, s2
       │    0x0048703c      24a51764       addiu a1, a1, 0x1764
       │    0x00487040      02203021       move a2, s1
       │    0x00487044      0320f809       jalr t9
       │    0x00487048      02003821       move a3, s0
       └──> 0x0048704c      8fbc0018       lw gp, 0x18(sp)
            0x00487050      3c040057       lui a0, 0x57
            0x00487054      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x00487058      00000000       nop
            0x0048705c      0320f809       jalr t9
            0x00487060      248413bc       addiu a0, a0, 0x13bc
            0x00487064      8fbc0018       lw gp, 0x18(sp)
            0x00487068      00000000       nop
            0x0048706c      8f99af08       lw t9, -sym.execFormatCmd(gp) ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x00487070      00000000       nop
            0x00487074      0320f809       jalr t9
            0x00487078      27a40020       addiu a0, sp, 0x20
            0x0048707c      8fbf012c       lw ra, 0x12c(sp)
            0x00487080      8fbc0018       lw gp, 0x18(sp)
            0x00487084      8fb20128       lw s2, 0x128(sp)
            0x00487088      8fb10124       lw s1, 0x124(sp)
            0x0048708c      8fb00120       lw s0, 0x120(sp)
            0x00487090      03e00008       jr ra
            0x00487094      27bd0130       addiu sp, sp, 0x130
