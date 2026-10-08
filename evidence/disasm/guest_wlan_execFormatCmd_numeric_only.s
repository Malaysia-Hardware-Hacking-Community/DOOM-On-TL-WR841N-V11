; filename: usr/bin/httpd
; radare2: r2 -c 'aaa' -c 's 0x0044ae00' -c 'pd 240'
; capture: 2026-09-12T08:17:15Z
; finding: fcn.0044ae00 guest WLAN cfg - httpGetEnv params are atoi()'d time values; execFormatCmd uses wlanGetGNVapName internal names
; note: web params numeric/sanitized -> NOT a text injection sink

            0x0044ae00      move a0, zero
            0x0044ae04      lw t9, -sym.wlanGetSTANum(gp)              ; [0x5ba2dc:4]=0x49d610 sym.wlanGetSTANum
            0x0044ae08      nop
            0x0044ae0c      jalr t9
            0x0044ae10      move s0, zero
            0x0044ae14      lw gp, 0x18(sp)
            0x0044ae18      lui a0, 0x57
            0x0044ae1c      move a1, v0
            0x0044ae20      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044ae24      nop
            0x0044ae28      jalr t9
            0x0044ae2c      addiu a0, a0, -0x33f8
            0x0044ae30      lw gp, 0x18(sp)
            0x0044ae34      nop
            0x0044ae38      lw t9, -sym.wlanGetWpaProcess(gp)          ; [0x5ba4bc:4]=0x49d648 sym.wlanGetWpaProcess
            0x0044ae3c      nop
            0x0044ae40      jalr t9
            0x0044ae44      move a0, zero
            0x0044ae48      lw gp, 0x18(sp)
            0x0044ae4c      addiu a1, zero, 0xf
            0x0044ae50      lw t9, -sym.findSystemProc(gp)             ; [0x5b8778:4]=0x4cbd80 sym.findSystemProc
            0x0044ae54      nop
            0x0044ae58      jalr t9
            0x0044ae5c      move a0, v0
            0x0044ae60      lw gp, 0x18(sp)
            0x0044ae64      nop
            0x0044ae68      lw t9, -sym.wlanGetSTANum(gp)              ; [0x5ba2dc:4]=0x49d610 sym.wlanGetSTANum
            0x0044ae6c      nop
            0x0044ae70      jalr t9
            0x0044ae74      move a0, zero
            0x0044ae78      lw gp, 0x18(sp)
            0x0044ae7c      lui a0, 0x57
            0x0044ae80      move a1, v0
            0x0044ae84      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044ae88      nop
            0x0044ae8c      jalr t9
            0x0044ae90      addiu a0, a0, -0x33e4
            0x0044ae94      lw gp, 0x18(sp)
            0x0044ae98      nop
            0x0044ae9c      lw t9, -sym.wlanGetSTANum(gp)              ; [0x5ba2dc:4]=0x49d610 sym.wlanGetSTANum
            0x0044aea0      nop
            0x0044aea4      jalr t9
            0x0044aea8      move a0, zero
            0x0044aeac      lw gp, 0x18(sp)
            0x0044aeb0      move a2, v0
            0x0044aeb4      addiu a1, zero, 1
            0x0044aeb8      lw t9, -sym.wlanMakeVap(gp)                ; [0x5b9fe4:4]=0x4a4c8c sym.wlanMakeVap
            0x0044aebc      nop
            0x0044aec0      jalr t9
            0x0044aec4      move a0, zero
            0x0044aec8      lw gp, 0x18(sp)
            0x0044aecc      nop
            0x0044aed0      lw t9, -sym.wlanGetSTANum(gp)              ; [0x5ba2dc:4]=0x49d610 sym.wlanGetSTANum
            0x0044aed4      nop
            0x0044aed8      jalr t9
            0x0044aedc      move a0, zero
            0x0044aee0      lw gp, 0x18(sp)
            0x0044aee4      lui a0, 0x57
            0x0044aee8      move a1, v0
            0x0044aeec      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044aef0      nop
            0x0044aef4      jalr t9
            0x0044aef8      addiu a0, a0, -0x33c8
            0x0044aefc      lw gp, 0x18(sp)
            0x0044af00      nop
            0x0044af04      lw t9, -sym.wlanWispFinalConf(gp)          ; [0x5b8728:4]=0x4a6c60 sym.wlanWispFinalConf
            0x0044af08      nop
            0x0044af0c      jalr t9
            0x0044af10      move a0, zero
            0x0044af14      lw gp, 0x18(sp)
            0x0044af18      nop
            0x0044af1c      lw t9, -sym.dhcpcKill(gp)                  ; [0x5b836c:4]=0x4bcc1c sym.dhcpcKill
            0x0044af20      nop
            0x0044af24      jalr t9
            0x0044af28      nop
            0x0044af2c      b 0x44af3c
            0x0044af30      nop
            ; CODE XREF from fcn.0044a0ac @ +0xeb8(x)
            0x0044af34      jalr t9
            0x0044af38      nop
            ; CODE XREF from fcn.0044a0ac @ +0xe80(x)
            0x0044af3c      lw gp, 0x18(sp)
            0x0044af40      nop
            0x0044af44      lw t9, -sym.getMaxWanPortNumber(gp)        ; [0x5b9d8c:4]=0x4eaabc sym.getMaxWanPortNumber
            0x0044af48      nop
            0x0044af4c      jalr t9
            0x0044af50      nop
            0x0044af54      lw gp, 0x18(sp)
            0x0044af58      sltu v0, s0, v0
            0x0044af5c      move a0, s0
            0x0044af60      lw t9, -sym.ucStartWanConn(gp)             ; [0x5b8478:4]=0x4886c8 sym.ucStartWanConn
            0x0044af64      bnez v0, 0x44af34
            0x0044af68      addiu s0, s0, 1
            ; CODE XREFS from fcn.0044a0ac @ +0xd20(x), +0xd30(x), +0xd40(x), +0xd50(x)
            0x0044af6c      lw t9, -sym.getAccStatus(gp)               ; [0x5b97d8:4]=0x55ebd0 sym.getAccStatus
            0x0044af70      nop
            0x0044af74      jalr t9
            0x0044af78      move a0, zero
            0x0044af7c      lw gp, 0x18(sp)
            0x0044af80      bnez v0, 0x44afbc
            0x0044af84      nop
            0x0044af88      lw t9, -sym.wlanGetGNVapName(gp)           ; [0x5b9cfc:4]=0x49d82c sym.wlanGetGNVapName
            0x0044af8c      nop
            0x0044af90      jalr t9
            0x0044af94      move a0, zero
            0x0044af98      lw gp, 0x18(sp)
            0x0044af9c      lui a0, 0x57
            0x0044afa0      addiu a0, a0, -0x33b0
            0x0044afa4      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044afa8      nop
            0x0044afac      jalr t9
            0x0044afb0      move a1, v0
            0x0044afb4      lw gp, 0x18(sp)
            0x0044afb8      nop
            ; CODE XREFS from fcn.0044a0ac @ +0xed4(x), +0x1ac8(x)
            0x0044afbc      lw t9, -sym.getProductId(gp)               ; [0x5ba1e0:4]=0x4eadf8 sym.getProductId
            0x0044afc0      nop
            0x0044afc4      jalr t9
            0x0044afc8      nop
            0x0044afcc      lui v1, 0x841
            0x0044afd0      ori v1, v1, 0x1002
            0x0044afd4      lw gp, 0x18(sp)
            0x0044afd8      bne v0, v1, 0x44b048
            0x0044afdc      nop
            0x0044afe0      lw t9, -sym.wlanGetGNVapName(gp)           ; [0x5b9cfc:4]=0x49d82c sym.wlanGetGNVapName
            0x0044afe4      nop
            0x0044afe8      jalr t9
            0x0044afec      addiu a0, zero, 1
            0x0044aff0      lw gp, 0x18(sp)
            0x0044aff4      lui a0, 0x57
            0x0044aff8      move a1, v0
            0x0044affc      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044b000      nop
            0x0044b004      jalr t9
            0x0044b008      addiu a0, a0, -0x33b0
            0x0044b00c      lw gp, 0x18(sp)
            0x0044b010      nop
            0x0044b014      lw t9, -sym.wlanGetGNVapName(gp)           ; [0x5b9cfc:4]=0x49d82c sym.wlanGetGNVapName
            0x0044b018      nop
            0x0044b01c      jalr t9
            0x0044b020      addiu a0, zero, 1
            0x0044b024      lw gp, 0x18(sp)
            0x0044b028      lui a0, 0x57
            0x0044b02c      addiu a0, a0, -0x339c
            0x0044b030      lw t9, -sym.execFormatCmd(gp)              ; [0x5bac18:4]=0x4cb978 sym.execFormatCmd
            0x0044b034      nop
            0x0044b038      jalr t9
            0x0044b03c      move a1, v0
            0x0044b040      lw gp, 0x18(sp)
            0x0044b044      nop
            ; CODE XREFS from fcn.0044a0ac @ +0xc28(x), +0xf2c(x)
            0x0044b048      lw t9, -sym.HTTP_DEBUG_PRINT(gp)           ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
            0x0044b04c      lui a0, 0x57
            0x0044b050      lui a1, 0x57
            0x0044b054      addiu a0, a0, -0x338c
            0x0044b058      jalr t9
            0x0044b05c      addiu a1, a1, -0x3364
            0x0044b060      lw gp, 0x18(sp)
            0x0044b064      addiu s0, sp, 0x9c
            0x0044b068      addiu a2, zero, 0x20
            0x0044b06c      lw t9, -sym.imp.memset(gp)                 ; [0x5b8cb8:4]=0x5616d0 sym.imp.memset
            0x0044b070      move a0, s0
            0x0044b074      jalr t9
            0x0044b078      move a1, zero
            0x0044b07c      lw gp, 0x18(sp)
            0x0044b080      move a0, s0
            0x0044b084      lw t9, -sym.swGetGuestAccTimeCfg(gp)       ; [0x5baa40:4]=0x47f2f4 sym.swGetGuestAccTimeCfg
            0x0044b088      nop
            0x0044b08c      jalr t9
            0x0044b090      move a1, zero
            0x0044b094      lw gp, 0x18(sp)
            0x0044b098      lui a1, 0x57
            0x0044b09c      addiu a1, a1, -0x3338
            0x0044b0a0      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x0044b0a4      nop
            0x0044b0a8      jalr t9
            0x0044b0ac      move a0, s2
            0x0044b0b0      lw gp, 0x18(sp)
            0x0044b0b4      beqz v0, 0x44b16c
            0x0044b0b8      nop
            0x0044b0bc      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
            0x0044b0c0      nop
            0x0044b0c4      jalr t9
            0x0044b0c8      move a0, v0
            0x0044b0cc      move s0, v0
            0x0044b0d0      sltiu v0, v0, 3
            0x0044b0d4      lw gp, 0x18(sp)
            0x0044b0d8      beqz v0, 0x44b16c
            0x0044b0dc      nop
            0x0044b0e0      beqz s0, 0x44b0fc
            0x0044b0e4      sw s0, 0x9c(sp)
            0x0044b0e8      addiu v0, zero, 1
            0x0044b0ec      bne s0, v0, 0x44b408
            0x0044b0f0      lui a0, 0x57
            0x0044b0f4      b 0x44b1b8
            0x0044b0f8      lui a1, 0x57
            ; CODE XREF from fcn.0044a0ac @ +0x1034(x)
            0x0044b0fc      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x0044b100      lui a1, 0x57
            0x0044b104      addiu a1, a1, -0x332c
            0x0044b108      jalr t9
            0x0044b10c      move a0, s2
            0x0044b110      lw gp, 0x18(sp)
            0x0044b114      beqz v0, 0x44b134
            0x0044b118      nop
            0x0044b11c      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
            0x0044b120      nop
            0x0044b124      jalr t9
            0x0044b128      move a0, v0
            0x0044b12c      lw gp, 0x18(sp)
            0x0044b130      sw v0, 0xa0(sp)
            ; CODE XREF from fcn.0044a0ac @ +0x1068(x)
            0x0044b134      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x0044b138      lui a1, 0x57
            0x0044b13c      addiu a1, a1, -0x3320
            0x0044b140      jalr t9
            0x0044b144      move a0, s2
            0x0044b148      lw gp, 0x18(sp)
            0x0044b14c      beqz v0, 0x44b16c
            0x0044b150      nop
            0x0044b154      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
            0x0044b158      nop
            0x0044b15c      jalr t9
            0x0044b160      move a0, v0
            0x0044b164      lw gp, 0x18(sp)
            0x0044b168      sw v0, 0xa4(sp)
            ; XREFS: CODE 0x0044b0b4  CODE 0x0044b0d8  CODE 0x0044b14c  
            ; XREFS: CODE 0x0044b38c  CODE 0x0044b3ec  CODE 0x0044b428  
            0x0044b16c      lw t9, -sym.swSetGuestAccTimeCfg(gp)       ; [0x5ba818:4]=0x47f2dc sym.swSetGuestAccTimeCfg
            0x0044b170      addiu a0, sp, 0x9c
            0x0044b174      jalr t9
            0x0044b178      move a1, zero
            0x0044b17c      lw gp, 0x18(sp)
            0x0044b180      lui a0, 0x57
            0x0044b184      lui a1, 0x57
            0x0044b188      lw t9, -sym.HTTP_DEBUG_PRINT(gp)           ; [0x5ba9b8:4]=0x4ccef0 sym.HTTP_DEBUG_PRINT
            0x0044b18c      addiu a0, a0, -0x3314
            0x0044b190      jalr t9
            0x0044b194      addiu a1, a1, -0x32ec
            0x0044b198      jal fcn.0044a0ac
            0x0044b19c      move a0, s2
            0x0044b1a0      addiu v1, zero, 2
            0x0044b1a4      lw gp, 0x18(sp)
            0x0044b1a8      beq v0, v1, 0x44ba14
            0x0044b1ac      addiu v0, zero, 2
            0x0044b1b0      b 0x44b430
            0x0044b1b4      lui a0, 0x57
            ; CODE XREF from fcn.0044a0ac @ +0x1048(x)
            0x0044b1b8      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
            0x0044b1bc      addiu a1, a1, -0x32c4
