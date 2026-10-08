            ; CALL XREF from sym.pptpCmdReq @ 0x4e1624(x)
            ; CALL XREF from sym.pptpStartAfterDhcpOk @ 0x4e184c(x)
┌ 596: fcn.004e12fc (int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4, int32_t arg_10h, int32_t arg_218h, int32_t arg_21ch, int32_t arg_220h, int32_t arg_224h, int32_t arg_228h, int32_t arg_22ch);
│ `- args(a0, a1, a2, a3, sp[0x10..0x22c]) vars(9:sp[0x4..0x220])
│           0x004e12fc      lui gp, 0x5c
│           0x004e1300      addiu sp, sp, -0x230
│           0x004e1304      addiu gp, gp, -0x2f0
│           0x004e1308      sw ra, (var_22ch)
│           0x004e130c      sw s4, (var_228h)
│           0x004e1310      sw s3, (var_224h)
│           0x004e1314      sw s2, (var_220h)
│           0x004e1318      sw s1, (var_21ch)
│           0x004e131c      sw s0, (var_218h)
│           0x004e1320      sw gp, (var_10h)
│           0x004e1324      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x004e1328      addiu s1, sp, 0x18
│           0x004e132c      move s3, a1
│           0x004e1330      move s2, a0
│           0x004e1334      move a1, zero
│           0x004e1338      move a0, s1
│           0x004e133c      jalr t9
│           0x004e1340      addiu a2, zero, 0x100                      ; arg3
│           0x004e1344      lw gp, (var_10h)
│           0x004e1348      addiu s0, sp, 0x118
│           0x004e134c      move a0, s0
│           0x004e1350      lw t9, -sym.imp.memset(gp)                 ; [0x5616d0:4]=0x8f998010
│           0x004e1354      move a1, zero
│           0x004e1358      jalr t9
│           0x004e135c      addiu a2, zero, 0x100                      ; arg3
│           0x004e1360      lw gp, (var_10h)
│           0x004e1364      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e1368      addiu a1, a1, -0x2b5c                      ; 0x57d4a4 ; "pppd pptp pptp_server %s " ; arg2 [0m; str.pppd_pptp_pptp_server__s_
│           0x004e136c      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e1370      addiu a2, s2, 0x1c                         ; arg3
│           0x004e1374      jalr t9
│           0x004e1378      move a0, s3
│           0x004e137c      lw gp, (var_10h)
│           0x004e1380      move a0, s3
│           0x004e1384      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e1388      nop
│           0x004e138c      jalr t9
│           0x004e1390      lui s4, 0x58                               ; 0x580000 ; "me"
│           0x004e1394      lw gp, (var_10h)
│           0x004e1398      move a0, s1
│           0x004e139c      addiu a1, zero, 0x100                      ; arg2
│           0x004e13a0      lw t9, -sym.getConvertAsciiCode(gp)        ; [0x4cb154:4]=0x3c1c005c ; "<\x1c"
│           0x004e13a4      addiu a2, s2, 0x5c                         ; arg3
│           0x004e13a8      jalr t9
│           0x004e13ac      move s1, v0                                ; 0x56a6d1 ; "anDynamicIpCfgRpm.htm"
│           0x004e13b0      lw gp, (var_10h)
│           0x004e13b4      move a0, s0
│           0x004e13b8      addiu a1, zero, 0x100                      ; arg2
│           0x004e13bc      lw t9, -sym.getConvertAsciiCode(gp)        ; [0x4cb154:4]=0x3c1c005c ; "<\x1c"
│           0x004e13c0      addiu a2, s2, 0xd4                         ; arg3
│           0x004e13c4      jalr t9
│           0x004e13c8      move s0, v0                                ; 0x56a6d1 ; "anDynamicIpCfgRpm.htm"
│           0x004e13cc      lw gp, (var_10h)
│           0x004e13d0      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e13d4      move a2, s0                                ; 0x56a6d1 ; "anDynamicIpCfgRpm.htm"
│           0x004e13d8      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e13dc      move a3, v0                                ; 0x56a6d1 ; "anDynamicIpCfgRpm.htm"
│           0x004e13e0      addiu a1, a1, -0x2b40                      ; 0x57d4c0 ; " user \"%s\" password \"%s\" " ; arg2 [0m; str.user___s__password___s__
│           0x004e13e4      jalr t9
│           0x004e13e8      addu a0, s3, s1                            ; 0x56a6db ; "pCfgRpm.htm" ; arg1
│           0x004e13ec      lw gp, (var_10h)
│           0x004e13f0      nop
│           0x004e13f4      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e13f8      nop
│           0x004e13fc      jalr t9
│           0x004e1400      move a0, s3
│           0x004e1404      lw gp, (var_10h)
│           0x004e1408      lui a1, 0x58                               ; 0x580000 ; "me"
; arg2 ; str.defaultroute_default_asyncmap_nopcomp_noaccomp_nobsdcomp_
; nodeflate_noccp_novj_unit_0
│           0x004e140c      addiu a1, a1, -0x2b24                      ; 0x57d4dc ; " defaultroute default-asyncmap nopcomp noaccomp nobsdcomp nodeflate noccp novj unit 0"
│           0x004e1410      lw t9, -sym.imp.strcpy(gp)                 ; [0x561b30:4]=0x8f998010
│           0x004e1414      nop
│           0x004e1418      jalr t9
│           0x004e141c      addu a0, s3, v0                            ; 0x56a6db ; "pCfgRpm.htm" ; arg1
│           0x004e1420      lw gp, (var_10h)
│           0x004e1424      nop
│           0x004e1428      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e142c      nop
│           0x004e1430      jalr t9
│           0x004e1434      move a0, s3
│           0x004e1438      lw gp, (var_10h)
│           0x004e143c      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e1440      addiu a1, a1, -0x2acc                      ; 0x57d534 ; " refuse-eap" ; arg2 [0m; str.refuse_eap
│           0x004e1444      lw t9, -sym.imp.strcpy(gp)                 ; [0x561b30:4]=0x8f998010
│           0x004e1448      nop
│           0x004e144c      jalr t9
│           0x004e1450      addu a0, s3, v0                            ; 0x56a6db ; "pCfgRpm.htm" ; arg1
│           0x004e1454      lw gp, (var_10h)
│           0x004e1458      nop
│           0x004e145c      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e1460      nop
│           0x004e1464      jalr t9
│           0x004e1468      move a0, s3
│           0x004e146c      lw gp, (var_10h)
│           0x004e1470      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e1474      addu a0, s3, v0                            ; 0x56a6db ; "pCfgRpm.htm" ; arg1
│           0x004e1478      lw v1, -obj.linkModeThreadPid(gp)          ; [0x5bac7c:4]=0
│           0x004e147c      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e1480      lw a2, (v1)                                ; [0x5bac7c:4]=0
│                                                                      ; obj.linkModeThreadPid
│           0x004e1484      jalr t9
│           0x004e1488      addiu a1, a1, -0x2ac0                      ; 0x57d540 ; " httpd-pid %d" ; arg2 [0m; str.httpd_pid__d
│           0x004e148c      lw s0, 0x164(s2)
│           0x004e1490      lw gp, (var_10h)
│           0x004e1494      addiu v0, s0, -0x240
│           0x004e1498      sltiu v0, v0, 0x34d
│           0x004e149c      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│       ┌─< 0x004e14a0      beqz v0, 0x4e14cc
│       │   0x004e14a4      nop
│       │   0x004e14a8      jalr t9
│       │   0x004e14ac      move a0, s3
│       │   0x004e14b0      lw gp, (var_10h)
│       │   0x004e14b4      move a2, s0
│       │   0x004e14b8      addu a0, s3, v0                            ; arg1
│       │   0x004e14bc      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│       │   0x004e14c0      addiu a1, s4, -0x2c1c                      ; 0x57d3e4 ; " mru %d mtu %d " ; arg2 [0m; str.mru__d_mtu__d_
│      ┌──< 0x004e14c4      b 0x4e14ec
│      ││   0x004e14c8      move a3, s0
│      ││   ; CODE XREF from fcn.004e12fc @ 0x4e14a0(x)
│      │└─> 0x004e14cc      jalr t9
│      │    0x004e14d0      move a0, s3
│      │    0x004e14d4      lw gp, (var_10h)
│      │    0x004e14d8      addu a0, s3, v0                            ; arg1
│      │    0x004e14dc      addiu a1, s4, -0x2c1c                      ; 0x57d3e4 ; " mru %d mtu %d " ; arg2 [0m; str.mru__d_mtu__d_
│      │    0x004e14e0      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│      │    0x004e14e4      addiu a2, zero, 0x58c                      ; arg3
│      │    0x004e14e8      addiu a3, zero, 0x58c                      ; arg4
│      │    ; CODE XREF from fcn.004e12fc @ 0x4e14c4(x)
│      └──> 0x004e14ec      jalr t9
│           0x004e14f0      nop
│           0x004e14f4      lw gp, (var_10h)
│           0x004e14f8      nop
│           0x004e14fc      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e1500      nop
│           0x004e1504      jalr t9
│           0x004e1508      move a0, s3
│           0x004e150c      lw gp, (var_10h)
│           0x004e1510      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e1514      addu a0, s3, v0                            ; arg1
│           0x004e1518      lw t9, -sym.imp.strcpy(gp)                 ; [0x561b30:4]=0x8f998010
│           0x004e151c      nop
│           0x004e1520      jalr t9
│           0x004e1524      addiu a1, a1, -0x2ab0                      ; 0x57d550 ; " usepeerdns" ; arg2 [0m; str.usepeerdns
│           0x004e1528      lw ra, (var_22ch)
│           0x004e152c      lw gp, (var_10h)
│           0x004e1530      move v0, zero
│           0x004e1534      lw s4, (var_228h)
│           0x004e1538      lw s3, (var_224h)
│           0x004e153c      lw s2, (var_220h)
│           0x004e1540      lw s1, (var_21ch)
│           0x004e1544      lw s0, (var_218h)
│           0x004e1548      jr ra
└           0x004e154c      addiu sp, sp, 0x230
