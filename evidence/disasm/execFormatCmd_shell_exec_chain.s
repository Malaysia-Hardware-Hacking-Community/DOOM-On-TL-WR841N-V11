// execFormatCmd_shell_exec_chain
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004cb978; pd 40" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- execFormatCmd:
        ┌─> 0x004cb978      3c1c005c       lui gp, 0x5c
        ╎   0x004cb97c      27bdefd0       addiu sp, sp, -0x1030
        ╎   0x004cb980      279cfd10       addiu gp, gp, -0x2f0
        ╎   0x004cb984      afbf102c       sw ra, 0x102c(sp)
        ╎   0x004cb988      afb11028       sw s1, 0x1028(sp)
        ╎   0x004cb98c      afb01024       sw s0, 0x1024(sp)
        ╎   0x004cb990      afbc0010       sw gp, 0x10(sp)
        ╎   0x004cb994      8f9999a8       lw t9, -sym.imp.vsprintf(gp) ; [0x5b96b8:4]=0x561410 sym.imp.vsprintf
        ╎   0x004cb998      27b0001c       addiu s0, sp, 0x1c
        ╎   0x004cb99c      27a21034       addiu v0, sp, 0x1034
        ╎   0x004cb9a0      afa7103c       sw a3, 0x103c(sp)
        ╎   0x004cb9a4      afa51034       sw a1, 0x1034(sp)
        ╎   0x004cb9a8      afa61038       sw a2, 0x1038(sp)
        ╎   0x004cb9ac      00802821       move a1, a0
        ╎   0x004cb9b0      00403021       move a2, v0
        ╎   0x004cb9b4      02002021       move a0, s0
        ╎   0x004cb9b8      0320f809       jalr t9
        ╎   0x004cb9bc      afa20018       sw v0, 0x18(sp)
        ╎   0x004cb9c0      0c132cb2       jal sym.tpMutexLockByName
        ╎   0x004cb9c4      02002021       move a0, s0
        ╎   0x004cb9c8      8fbc0010       lw gp, 0x10(sp)
        ╎   0x004cb9cc      00000000       nop
        ╎   0x004cb9d0      8f99994c       lw t9, -sym.tp_systemEx(gp) ; [0x5b965c:4]=0x4eeb74 sym.tp_systemEx
        ╎   0x004cb9d4      00000000       nop
        ╎   0x004cb9d8      0320f809       jalr t9
        ╎   0x004cb9dc      02002021       move a0, s0
        ╎   0x004cb9e0      02002021       move a0, s0
        ╎   0x004cb9e4      0c132c89       jal sym.tpMutexUnlockByName
        ╎   0x004cb9e8      00408821       move s1, v0
        ╎   0x004cb9ec      8fbf102c       lw ra, 0x102c(sp)
        ╎   0x004cb9f0      02201021       move v0, s1
        ╎   0x004cb9f4      8fbc0010       lw gp, 0x10(sp)
        ╎   0x004cb9f8      8fb11028       lw s1, 0x1028(sp)
        ╎   0x004cb9fc      8fb01024       lw s0, 0x1024(sp)
        ╎   0x004cba00      03e00008       jr ra
        ╎   0x004cba04      27bd1030       addiu sp, sp, 0x1030
        ╎   0x004cba08      3c040058       lui a0, 0x58
        ╎   0x004cba0c      2484aab8       addiu a0, a0, -0x5548
        └─< 0x004cba10      08132e5e       j sym.execFormatCmd
            0x004cba14      00002821       move a1, zero
