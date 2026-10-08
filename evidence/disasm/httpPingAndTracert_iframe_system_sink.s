; filename: usr/bin/httpd (TP-Link TL-WR841N v11 stock 160325)
; binary: /tmp/fw/root/usr/bin/httpd
; radare2: r2 -c 'aaa' -c 's 0x0047f4e4' -c 'pdf'
; capture: 2026-09-12T08:17:15Z
; finding: httpPingAndTracertIframeRpm web handler - sprintf(s0,"ping6 -I %s %s -i 1 -c 5 > /tmp/ping6.txt", getWanIpv6IfName(), a0) + system(s0)
; note: web-reachable via /userRpm/PingIframeRpm.htm?ping_addr=...  a0 = ping target param
; note: empirically wedges single-threaded httpd when diagnostic runs (observed on device)

            ; CALL XREFS from fcn.004810d4 @ 0x4813f0(x), 0x481408(x), 0x48141c(x)
┌ 456: fcn.0047f4e4 (int32_t arg1, int32_t arg2, int32_t arg3);
│ `- args(a0, a1, a2) vars(9:sp[0x4..0x120])
│           0x0047f4e4      lui gp, 0x5c
│           0x0047f4e8      addiu sp, sp, -0x130
│           0x0047f4ec      addiu gp, gp, -0x2f0
│           0x0047f4f0      sw ra, (var_12ch)
│           0x0047f4f4      sw s4, (var_128h)
│           0x0047f4f8      sw s3, (var_124h)
│           0x0047f4fc      sw s2, (var_120h)
│           0x0047f500      sw s1, (var_11ch)
│           0x0047f504      sw s0, (var_118h)
│           0x0047f508      sw gp, (var_10h)
│           0x0047f50c      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x0047f510      addiu s4, sp, 0x18
│           0x0047f514      move s2, a0                                ; 0x570918 ; "dhcp6c"
│           0x0047f518      move a1, zero
│           0x0047f51c      move a0, s4
│           0x0047f520      jalr t9
│           0x0047f524      addiu a2, zero, 0x80                       ; arg3
│           0x0047f528      lw gp, (var_10h)
│           0x0047f52c      addiu s0, sp, 0x98
│           0x0047f530      move a1, zero
│           0x0047f534      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x0047f538      addiu a2, zero, 0x80                       ; arg3
│           0x0047f53c      jalr t9
│           0x0047f540      move a0, s0
│           0x0047f544      lw gp, (var_10h)
│           0x0047f548      lui s1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x0047f54c      addiu a0, s1, 0x6f8                        ; 0x5706f8 ; "/tmp/ping6.txt" ; arg1 [0m; str._tmp_ping6.txt
│           0x0047f550      lw t9, -sym.imp.unlink(gp)                 ; [0x5616b0:4]=0x8f998010
│           0x0047f554      nop
│           0x0047f558      jalr t9
│           0x0047f55c      addiu s3, zero, 1
│           0x0047f560      lw gp, (var_10h)
│           0x0047f564      nop
│           0x0047f568      lw t9, -sym.getWanIpv6IfName(gp)           ; [0x4b4310:4]=0x3c1c005c ; "<\x1c"
│           0x0047f56c      nop
│           0x0047f570      jalr t9
│           0x0047f574      nop
│           0x0047f578      lw gp, (var_10h)
│           0x0047f57c      lui a1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x0047f580      move a3, s2                                ; 0x570918 ; "dhcp6c"
│           0x0047f584      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x0047f588      move a0, s0
│           0x0047f58c      addiu a1, a1, 0x708                        ; 0x570708 ; "ping6 -I %s %s -i 1 -c 5 > /tmp/ping6.txt" ; arg2 [0m; str.ping6__I__s__s__i_1__c_5____tmp_ping6.txt
│           0x0047f590      jalr t9
│           0x0047f594      move a2, v0
│           0x0047f598      lw gp, (var_10h)
│           0x0047f59c      lui a1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x0047f5a0      lui a0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x0047f5a4      lw t9, -sym.HTTP_DEBUG_PRINT(gp)           ; [0x4ccef0:4]=0xafa60008
│           0x0047f5a8      move a2, s0
│           0x0047f5ac      addiu a1, a1, 0x744                        ; 0x570744 ; "cmd = %s." ; arg2 [0m; str.cmd___s.
│           0x0047f5b0      jalr t9
│           0x0047f5b4      addiu a0, a0, 0x734                        ; 0x570734 ; "swIpv6.c:1781" ; arg1 [0m; str.swIpv6.c:1781
│           0x0047f5b8      lw gp, (var_10h)
│           0x0047f5bc      nop
│           0x0047f5c0      lw t9, -sym.imp.system(gp)                 ; [0x560f50:4]=0x8f998010
│           0x0047f5c4      nop
│           0x0047f5c8      jalr t9
│           0x0047f5cc      move a0, s0
│           0x0047f5d0      lw gp, (var_10h)
│           0x0047f5d4      lui a1, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│           0x0047f5d8      addiu a0, s1, 0x6f8                        ; 0x5706f8 ; "/tmp/ping6.txt" ; arg1 [0m; str._tmp_ping6.txt
│           0x0047f5dc      lw t9, -sym.imp.fopen(gp)                  ; [0x561400:4]=0x8f998010
│           0x0047f5e0      nop
│           0x0047f5e4      jalr t9
│           0x0047f5e8      addiu a1, a1, -0x159c                      ; arg2
│           0x0047f5ec      lw gp, (var_10h)
│       ┌─< 0x0047f5f0      bnez v0, 0x47f638
│       │   0x0047f5f4      move s0, v0
│      ┌──< 0x0047f5f8      b 0x47f688
│      ││   0x0047f5fc      move s3, zero
│      ││   ; CODE XREF from fcn.0047f4e4 @ 0x47f66c(x)
│     ┌───> 0x0047f600      jalr t9
│     ╎││   0x0047f604      nop
│     ╎││   0x0047f608      lw gp, (var_10h)
│    ┌────< 0x0047f60c      beqz v0, 0x47f64c
│    │╎││   0x0047f610      move a0, s1
│    │╎││   0x0047f614      lw t9, -sym.imp.strstr(gp)                 ; [0x561920:4]=0x8f998010
│    │╎││   0x0047f618      nop
│    │╎││   0x0047f61c      jalr t9
│    │╎││   0x0047f620      move a1, s2                                ; 0x570764 ; "100% packet loss"
│    │╎││   ; DATA XREF from fcn.0047f4e4 @ 0x47f61c(r)
│    │╎││   0x0047f624     .string "_B" ; len=2
│    │╎││   0x0047f626      unaligned
│    │╎││   0x0047f628      negu v0, v0
│    │╎││   0x0047f62c      lw gp, (var_10h)
│   ┌─────< 0x0047f630      b 0x47f64c
│   ││╎││   0x0047f634      and s3, s3, v0
│   ││╎││   ; CODE XREF from fcn.0047f4e4 @ 0x47f5f0(x)
│   ││╎│└─> 0x0047f638      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│   ││╎│    0x0047f63c      move s1, s4
│   ││╎│    0x0047f640      addiu s4, v0, 0x750                        ; 0x570750 ; "packets transmitted" ; str.packets_transmitted
│   ││╎│    0x0047f644      lui v0, 0x57                               ; 0x570000 ; "hould not be here: newOperSystemMode=%d "
│   ││╎│    0x0047f648      addiu s2, v0, 0x764                        ; 0x570764 ; "100% packet loss" ; str._00__packet_loss
│   ││╎│    ; CODE XREFS from fcn.0047f4e4 @ 0x47f60c(x), 0x47f630(x)
│   └└────> 0x0047f64c      lw t9, -sym.imp.fgets(gp)                  ; [0x5615b0:4]=0x8f998010
│     ╎│    0x0047f650      move a0, s1
│     ╎│    0x0047f654      addiu a1, zero, 0x80                       ; arg2
│     ╎│    0x0047f658      jalr t9
│     ╎│    0x0047f65c      move a2, s0
│     ╎│    0x0047f660      lw gp, (var_10h)
│     ╎│    0x0047f664      move a0, s1
│     ╎│    0x0047f668      lw t9, -sym.imp.strstr(gp)                 ; [0x561920:4]=0x8f998010
│     └───< 0x0047f66c      bnez v0, 0x47f600
│      │    0x0047f670      move a1, s4                                ; 0x570750 ; "packets transmitted"
│      │    0x0047f674      lw t9, -sym.imp.fclose(gp)                 ; [0x5613c0:4]=0x8f998010
│      │    0x0047f678      nop
│      │    0x0047f67c      jalr t9
│      │    0x0047f680      move a0, s0
│      │    0x0047f684      lw gp, (var_10h)
│      │    ; CODE XREF from fcn.0047f4e4 @ 0x47f5f8(x)
│      └──> 0x0047f688      lw ra, (var_12ch)
│           0x0047f68c      move v0, s3
│           0x0047f690      lw s4, (var_128h)
│           0x0047f694      lw s3, (var_124h)
│           0x0047f698      lw s2, (var_120h)
│           0x0047f69c      lw s1, (var_11ch)
│           0x0047f6a0      lw s0, (var_118h)
│           0x0047f6a4      jr ra
└           0x0047f6a8      addiu sp, sp, 0x130
