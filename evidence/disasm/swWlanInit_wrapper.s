// swWlanInit_wrapper
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x00484630; pd 20" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- swWlanInit:
            0x00484630      3c1c005c       lui gp, 0x5c
            0x00484634      279cfd10       addiu gp, gp, -0x2f0
            0x00484638      8f999ef8       lw t9, -sym.wlanInit(gp)    ; [0x5b9c08:4]=0x4a9f90 sym.wlanInit
            0x0048463c      00000000       nop
            0x00484640      03200008       jr t9
            0x00484644      00000000       nop
            ;-- swWlanSameMacWds:
            0x00484648      3c1c005c       lui gp, 0x5c
            0x0048464c      27bdffd0       addiu sp, sp, -0x30
            0x00484650      279cfd10       addiu gp, gp, -0x2f0
            0x00484654      afbf002c       sw ra, 0x2c(sp)
            0x00484658      afb10028       sw s1, 0x28(sp)
            0x0048465c      afb00024       sw s0, 0x24(sp)
            0x00484660      afbc0010       sw gp, 0x10(sp)
            0x00484664      27b10018       addiu s1, sp, 0x18
            0x00484668      02202821       move a1, s1
            0x0048466c      0c121186       jal sym.swWlanGetMac
            0x00484670      00808021       move s0, a0
            0x00484674      8fbc0010       lw gp, 0x10(sp)
            0x00484678      00000000       nop
            0x0048467c      8f999ec0       lw t9, -sym.wlanGetSTADevName(gp) ; [0x5b9bd0:4]=0x49d618 sym.wlanGetSTADevName
