; filename: usr/bin/httpd
; radare2: r2 -c 'aaa' -c 's 0x004810d4' -c 'pdf'
; capture: 2026-09-12T08:17:15Z
; finding: fcn.004810d4 (IPv6 connectivity check) calls ping6 sink with hardcoded 2001:4860:4860::8888 / ::8844
; note: distinguishes non-injectable path from web ping_addr path

            ; CALL XREF from fcn.004810d4 @ +0x414(x)
┌ 968: fcn.004810d4 (int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4);
│ `- args(a0, a1, a2, a3) vars(24:sp[0x4..0x150])
│           0x004810d4      lui gp, 0x5c
│           0x004810d8      addiu sp, sp, -0x160
│           0x004810dc      addiu gp, gp, -0x2f0
│           0x004810e0      sw ra, (var_15ch)
│           0x004810e4      sw s6, (var_158h)
│           0x004810e8      sw s5, (var_154h)
│           0x004810ec      sw s4, (var_150h)
│           0x004810f0      sw s3, (var_14ch)
│           0x004810f4      sw s2, (var_148h)
│           0x004810f8      sw s1, (var_144h)
│           0x004810fc      sw s0, (var_140h)
│           0x00481100      sw gp, (var_10h)
│           0x00481104      lui s0, 0x56
│           0x00481108      lbu v0, 0x23c0(s0)
│           0x0048110c      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x00481110      addiu a0, sp, 0x5d                         ; arg1
│           0x00481114      move a1, zero
│           0x00481118      addiu a2, zero, 0x2b                       ; arg3
│           0x0048111c      jalr t9
│           0x00481120      sb v0, (var_5ch)
│           0x00481124      lw gp, (var_10h)
│           0x00481128      lbu v0, 0x23c0(s0)
│           0x0048112c      addiu a0, sp, 0x89                         ; arg1
│           0x00481130      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x00481134      move a1, zero
│           0x00481138      addiu a2, zero, 0x2b                       ; arg3
│           0x0048113c      jalr t9
│           0x00481140      sb v0, (var_88h)
│           0x00481144      lw gp, (var_10h)
│           0x00481148      lbu v0, 0x23c0(s0)
│           0x0048114c      addiu a0, sp, 0xb5                         ; arg1
│           0x00481150      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x00481154      move a1, zero
│           0x00481158      addiu a2, zero, 0x2b                       ; arg3
│           0x0048115c      jalr t9
│           0x00481160      sb v0, (var_b4h)
│           0x00481164      lw gp, (var_10h)
│           0x00481168      addiu s0, sp, 0x1c
│           0x0048116c      addiu s1, sp, 0x3c
│           0x00481170      lw t9, -sym.ucGetWanIpv6Type(gp)           ; [0x4997d0:4]=0x3c02005c ; "<\x02"
│           0x00481174      move s5, s1
│           0x00481178      jalr t9
│           0x0048117c      move s2, s0
│           0x00481180      lw gp, (var_10h)
│           0x00481184      move a0, s0
│           0x00481188      move a1, zero
│           0x0048118c      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x00481190      addiu a2, zero, 0x20                       ; arg3
│           0x00481194      jalr t9
│           0x00481198      move s6, v0
│           0x0048119c      lw gp, (var_10h)
│           0x004811a0      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x004811a4      addiu v0, v0, 0xb18                        ; 0x570b18 ; "ipv6.google.com" ; str.ipv6.google.com
│           0x004811a8      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x004811ac      sw v0, (var_1ch)
│           0x004811b0      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x004811b4      addiu v0, v0, 0xb28                        ; 0x570b28 ; "test-ipv6.com" ; str.test_ipv6.com
│           0x004811b8      addiu a0, sp, 0xe0                         ; arg1
│           0x004811bc      move a1, zero
│           0x004811c0      addiu a2, zero, 0x2d                       ; arg3
│           0x004811c4      jalr t9
│           0x004811c8      sw v0, (var_20h)
│           0x004811cc      lw gp, (var_10h)
│           0x004811d0      addiu a0, sp, 0x110                        ; arg1
│           0x004811d4      move a1, zero
│           0x004811d8      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x004811dc      nop
│           0x004811e0      jalr t9
│           0x004811e4      addiu a2, zero, 0x2d                       ; arg3
│           0x004811e8      lw gp, (var_10h)
│           0x004811ec      move a0, s1
│           0x004811f0      move a1, zero
│           0x004811f4      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x004811f8      addiu a2, zero, 0x20                       ; arg3
│           0x004811fc      jalr t9
│           0x00481200      addiu s1, sp, 0x18
│           0x00481204      addiu v0, zero, 0xa
│           0x00481208      sw v0, (var_40h)
│           0x0048120c      addiu v0, zero, 2
│           0x00481210      sw v0, (var_44h)
│           0x00481214      addiu v0, zero, 0x29
│           0x00481218      sw v0, (var_48h)
│           0x0048121c      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x00481220      addiu s4, v0, 0xb38                        ; 0x570b38 ; "swIpv6.c:1636" ; str.swIpv6.c:1636
│           0x00481224      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x00481228      lw gp, (var_10h)
│       ┌─< 0x0048122c      b 0x481260
│       │   0x00481230      addiu s3, v0, 0xb48                        ; 0x570b48 ; "getaddrinfo %s failed." ; str.getaddrinfo__s_failed.
│       │   ; CODE XREF from fcn.004810d4 @ 0x481274(x)
│      ┌──> 0x00481234      jalr t9
│      ╎│   0x00481238      addiu s2, s2, 4
│      ╎│   0x0048123c      lw gp, (var_10h)
│      ╎│   0x00481240      move a2, s0
│      ╎│   0x00481244      move a0, s4                                ; 0x570b38 ; "swIpv6.c:1636"
│      ╎│   0x00481248      lw t9, -sym.HTTP_DEBUG_PRINT(gp)           ; [0x4ccef0:4]=0xafa60008
│     ┌───< 0x0048124c      beqz v0, 0x481430
│     │╎│   0x00481250      move a1, s3                                ; 0x570b48 ; "getaddrinfo %s failed."
│     │╎│   0x00481254      jalr t9
│     │╎│   0x00481258      nop
│     │╎│   0x0048125c      lw gp, (var_10h)
│     │╎│   ; CODE XREF from fcn.004810d4 @ 0x48122c(x)
│     │╎└─> 0x00481260      lw s0, (s2)
│     │╎    0x00481264      lw t9, -sym.imp.getaddrinfo(gp)            ; [0x561b20:4]=0x8f998010
│     │╎    0x00481268      move a2, s5
│     │╎    0x0048126c      move a3, s1
│     │╎    0x00481270      move a0, s0
│     │└──< 0x00481274      bnez s0, 0x481234
│     │     0x00481278      move a1, zero
│     │     0x0048127c      lw t9, -sym.getRuntimeDnsIpv6(gp)          ; [0x53cedc:4]=0x3c1c005c ; "<\x1c"
│     │     0x00481280      addiu s0, sp, 0xe0
│     │     0x00481284      addiu s1, sp, 0x110
│     │     0x00481288      move a0, s0
│     │     0x0048128c      jalr t9
│     │     0x00481290      move a1, s1
│     │     0x00481294      lw gp, (var_10h)
│     │ ┌─< 0x00481298      bnez v0, 0x481398
│     │ │   0x0048129c      lui a1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
