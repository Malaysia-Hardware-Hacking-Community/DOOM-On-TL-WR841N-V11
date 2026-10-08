// tp_systemEx_fork_execve
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004eeb74; pd 60" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- tp_systemEx:
            0x004eeb74      3c1c005c       lui gp, 0x5c
            0x004eeb78      27bdffb8       addiu sp, sp, -0x48
            0x004eeb7c      279cfd10       addiu gp, gp, -0x2f0
            0x004eeb80      afbf0044       sw ra, 0x44(sp)
            0x004eeb84      afb30040       sw s3, 0x40(sp)
            0x004eeb88      afb2003c       sw s2, 0x3c(sp)
            0x004eeb8c      afb10038       sw s1, 0x38(sp)
            0x004eeb90      afb00034       sw s0, 0x34(sp)
            0x004eeb94      afbc0010       sw gp, 0x10(sp)
        ┌─< 0x004eeb98      10800037       beqz a0, 0x4eec78
        │   0x004eeb9c      00808821       move s1, a0
        │   0x004eeba0      8f998944       lw t9, -sym.imp.fork(gp)    ; [0x5b8654:4]=0x5618a0 sym.imp.fork
        │   0x004eeba4      00000000       nop
        │   0x004eeba8      0320f809       jalr t9
        │   0x004eebac      afa00018       sw zero, 0x18(sp)
        │   0x004eebb0      00408021       move s0, v0
        │   0x004eebb4      2402ffff       addiu v0, zero, -1
        │   0x004eebb8      8fbc0010       lw gp, 0x10(sp)
       ┌──< 0x004eebbc      1202002f       beq s0, v0, 0x4eec7c
       ││   0x004eebc0      00000000       nop
      ┌───< 0x004eebc4      16000015       bnez s0, 0x4eec1c
      │││   0x004eebc8      27b30018       addiu s3, sp, 0x18
      │││   0x004eebcc      3c020057       lui v0, 0x57
      │││   0x004eebd0      24422b60       addiu v0, v0, 0x2b60
      │││   0x004eebd4      8f99a5b4       lw t9, -sym.imp.execve(gp)  ; [0x5ba2c4:4]=0x561090 sym.imp.execve
      │││   0x004eebd8      afa2001c       sw v0, 0x1c(sp)
      │││   0x004eebdc      3c020058       lui v0, 0x58
      │││   0x004eebe0      2442acc4       addiu v0, v0, -0x533c
      │││   0x004eebe4      3c040058       lui a0, 0x58
      │││   0x004eebe8      2484acc8       addiu a0, a0, -0x5338
      │││   0x004eebec      afa20020       sw v0, 0x20(sp)
      │││   0x004eebf0      afb10024       sw s1, 0x24(sp)
      │││   0x004eebf4      afa00028       sw zero, 0x28(sp)
      │││   0x004eebf8      27a5001c       addiu a1, sp, 0x1c
      │││   0x004eebfc      0320f809       jalr t9
      │││   0x004eec00      00003021       move a2, zero
      │││   0x004eec04      8fbc0010       lw gp, 0x10(sp)
      │││   0x004eec08      00000000       nop
      │││   0x004eec0c      8f998968       lw t9, -sym.imp.exit(gp)    ; [0x5b8678:4]=0x561890 sym.imp.exit
      │││   0x004eec10      00000000       nop
      │││   0x004eec14      0320f809       jalr t9
      │││   0x004eec18      2404007f       addiu a0, zero, 0x7f
      └───> 0x004eec1c      2412ffff       addiu s2, zero, -1
       ││   0x004eec20      24110004       addiu s1, zero, 4
      ┌───> 0x004eec24      8f998740       lw t9, -sym.imp.waitpid(gp) ; [0x5b8450:4]=0x561950 sym.imp.waitpid
      ╎││   0x004eec28      02002021       move a0, s0
      ╎││   0x004eec2c      02602821       move a1, s3
      ╎││   0x004eec30      0320f809       jalr t9
      ╎││   0x004eec34      00003021       move a2, zero
      ╎││   0x004eec38      8fbc0010       lw gp, 0x10(sp)
     ┌────< 0x004eec3c      1452000b       bne v0, s2, 0x4eec6c
     │╎││   0x004eec40      00000000       nop
     │╎││   0x004eec44      8f99abfc       lw t9, -sym.imp.__errno_location(gp) ; [0x5ba90c:4]=0x560ec0 sym.imp.__errno_location
     │╎││   0x004eec48      00000000       nop
     │╎││   0x004eec4c      0320f809       jalr t9
     │╎││   0x004eec50      00000000       nop
     │╎││   0x004eec54      8c420000       lw v0, (v0)
     │╎││   0x004eec58      8fbc0010       lw gp, 0x10(sp)
     │└───< 0x004eec5c      1051fff1       beq v0, s1, 0x4eec24
     │ ││   0x004eec60      2402ffff       addiu v0, zero, -1
