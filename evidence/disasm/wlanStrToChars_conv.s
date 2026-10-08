// wlanStrToChars_conv
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004a3d80; pd 40" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            0x004a3d80      00808021       move s0, a0
            0x004a3d84      0320f809       jalr t9
            0x004a3d88      00a08821       move s1, a1
            0x004a3d8c      8fbc0010       lw gp, 0x10(sp)
            0x004a3d90      02002021       move a0, s0
            0x004a3d94      8f998bc4       lw t9, -sym.wlanWpsStart(gp) ; [0x5b88d4:4]=0x4b0510 sym.wlanWpsStart
            0x004a3d98      00000000       nop
            0x004a3d9c      0320f809       jalr t9
            0x004a3da0      02202821       move a1, s1
            0x004a3da4      8fbc0010       lw gp, 0x10(sp)
        ┌─< 0x004a3da8      10400008       beqz v0, 0x4a3dcc
        │   0x004a3dac      3c040057       lui a0, 0x57
        │   0x004a3db0      8f99aca8       lw t9, -sym.HTTP_DEBUG_PRINT(gp) ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
        │   0x004a3db4      3c050057       lui a1, 0x57
        │   0x004a3db8      24844478       addiu a0, a0, 0x4478
        │   0x004a3dbc      0320f809       jalr t9
        │   0x004a3dc0      24a54484       addiu a1, a1, 0x4484
        │   0x004a3dc4      8fbc0010       lw gp, 0x10(sp)
        │   0x004a3dc8      00000000       nop
        └─> 0x004a3dcc      8f99a9e4       lw t9, -sym.imp.usleep(gp)  ; [0x5ba6f4:4]=0x560f60 sym.imp.usleep
            0x004a3dd0      3c040007       lui a0, 7
            0x004a3dd4      8fbf0024       lw ra, 0x24(sp)
            0x004a3dd8      8fb10020       lw s1, 0x20(sp)
            0x004a3ddc      8fb0001c       lw s0, 0x1c(sp)
            0x004a3de0      3484a120       ori a0, a0, 0xa120
            0x004a3de4      03200008       jr t9
            0x004a3de8      27bd0028       addiu sp, sp, 0x28
            0x004a3dec      3c1c005c       lui gp, 0x5c
            0x004a3df0      27bdfe70       addiu sp, sp, -0x190
            0x004a3df4      279cfd10       addiu gp, gp, -0x2f0
            0x004a3df8      afbf018c       sw ra, 0x18c(sp)
            0x004a3dfc      afb60188       sw s6, 0x188(sp)
            0x004a3e00      afb50184       sw s5, 0x184(sp)
            0x004a3e04      afb40180       sw s4, 0x180(sp)
            0x004a3e08      afb3017c       sw s3, 0x17c(sp)
            0x004a3e0c      afb20178       sw s2, 0x178(sp)
            0x004a3e10      afb10174       sw s1, 0x174(sp)
            0x004a3e14      afb00170       sw s0, 0x170(sp)
            0x004a3e18      afbc0018       sw gp, 0x18(sp)
            0x004a3e1c      8cc200d4       lw v0, 0xd4(a2)
