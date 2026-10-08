            ; DATA XREF from sym.httpBPACfgInit @ 0x42dc9c(r)
┌ 2152: fcn.0042dd10 (int32_t arg1, int32_t arg2, int32_t arg3);
│ `- args(a0, a1, a2) vars(70:sp[0x4..0x2a8])
│           0x0042dd10      lui gp, 0x5c
│           0x0042dd14      addiu sp, sp, -0x2b8
│           0x0042dd18      addiu gp, gp, -0x2f0
│           0x0042dd1c      sw ra, (var_2b4h)
│           0x0042dd20      sw s3, (var_2b0h)
│           0x0042dd24      sw s2, (var_2ach)
│           0x0042dd28      sw s1, (var_2a8h)
│           0x0042dd2c      sw s0, (var_2a4h)
│           0x0042dd30      sw gp, (var_10h)
│           0x0042dd34      addiu v0, sp, 0x198
│           0x0042dd38      sw v0, (var_2ch)
│           0x0042dd3c      addiu v0, sp, 0x19c
│           0x0042dd40      sw v0, (var_34h)
│           ; CODE XREF from aav.0x00410f34 @ +0x483c(x)
│           0x0042dd44      addiu v0, sp, 0x1a0
│           0x0042dd48      sw v0, (var_3ch)
│           0x0042dd4c      addiu v0, sp, 0x1a4
│           0x0042dd50      sw v0, (var_44h)
│           0x0042dd54      addiu v0, sp, 0x1bd
│           ; CODE XREF from aav.0x00410f34 @ +0x4850(x)
│           0x0042dd58      sw v0, (var_4ch)
│           0x0042dd5c      addiu v0, sp, 0x1d6
│           0x0042dd60      sw v0, (var_54h)
│           0x0042dd64      addiu v0, sp, 0x226
│           0x0042dd68      sw v0, (var_5ch)
│           ; CODE XREF from aav.0x00410f34 @ +0x4864(x)
│           0x0042dd6c      addiu v0, sp, 0x278
│           0x0042dd70      sw v0, (var_64h)
│           0x0042dd74      addiu v0, sp, 0x27c
│           0x0042dd78      sw v0, (var_6ch)
│           0x0042dd7c      addiu v0, sp, 0x280
│           0x0042dd80      sw v0, (var_74h)
│           0x0042dd84      addiu v0, sp, 0x284
│           0x0042dd88      sw v0, (var_7ch)
│           0x0042dd8c      addiu v0, sp, 0x288
│           0x0042dd90      sw v0, (var_84h)
│           0x0042dd94      addiu v0, sp, 0x28c
│           0x0042dd98      sw v0, (var_8ch)
│           0x0042dd9c      addiu v0, sp, 0x290
│           0x0042dda0      lw t9, -sym.imp.memset(gp)                 ; [0x5b8cb8:4]=0x5616d0 sym.imp.memset
│           0x0042dda4      sw v0, (var_94h)
│           0x0042dda8      addiu v0, sp, 0x294
│           0x0042ddac      addiu v1, zero, 0x19
│           0x0042ddb0      addiu a1, zero, 0x50                       ; arg2
│           0x0042ddb4      sw v0, (var_9ch)
│           0x0042ddb8      addiu s0, sp, 0xb4
│           0x0042ddbc      addiu v0, sp, 0x298
│           0x0042ddc0      sw v1, (var_50h)
│           0x0042ddc4      sw v1, (var_48h)
│           0x0042ddc8      move s3, a0
│           0x0042ddcc      addiu a2, zero, 0xe4                       ; arg3
│           0x0042ddd0      sw v0, (var_a4h)
│           0x0042ddd4      sw a1, (var_60h)
│           0x0042ddd8      sw a1, (var_58h)
│           0x0042dddc      move a0, s0
│           0x0042dde0      move a1, zero
│           0x0042dde4      sw zero, (var_18h)
│           0x0042dde8      sw zero, (var_1ch)
│           0x0042ddec      sw zero, (var_ach)
│           0x0042ddf0      sw zero, (var_30h)
│           0x0042ddf4      sw zero, (var_38h)
│           0x0042ddf8      sw zero, (var_40h)
│           0x0042ddfc      sw zero, (var_68h)
│           0x0042de00      sw zero, (var_70h)
│           0x0042de04      sw zero, (var_78h)
│           0x0042de08      sw zero, (var_80h)
│           0x0042de0c      sw zero, (var_88h)
│           0x0042de10      sw zero, (var_90h)
│           0x0042de14      sw zero, (var_98h)
│           0x0042de18      sw zero, (var_a0h)
│           0x0042de1c      jalr t9
│           0x0042de20      sw zero, (var_a8h)
│           0x0042de24      lw gp, (var_10h)
│           0x0042de28      move a1, zero
│           0x0042de2c      lw t9, -sym.httpStatusSet(gp)              ; [0x5b9b20:4]=0x5186f0 sym.httpStatusSet
│           0x0042de30      nop
│           0x0042de34      jalr t9
│           0x0042de38      move a0, s3
│           ; CODE XREFS from aav.0x00410f34 @ +0xb04(x), +0xbd70(x)
│           0x0042de3c      lw gp, (var_10h)
│           0x0042de40      nop
│           0x0042de44      lw t9, -sym.httpHeaderGenerate(gp)         ; [0x5b9300:4]=0x503c78 sym.httpHeaderGenerate
│           0x0042de48      nop
│           0x0042de4c      jalr t9
│           0x0042de50      move a0, s3
│           0x0042de54      lw gp, (var_10h)
│           0x0042de58      nop
│           0x0042de5c      lw t9, -sym.HttpAccessPermit(gp)           ; [0x5b8d60:4]=0x43ec1c sym.HttpAccessPermit
│           0x0042de60      nop
│           0x0042de64      jalr t9
│           0x0042de68      move a0, s3
│           0x0042de6c      lw gp, (var_10h)
│       ┌─< 0x0042de70      bnez v0, 0x42de90
│       │   0x0042de74      nop
│       │   0x0042de78      lw t9, -sym.HttpDenyPage(gp)               ; [0x5b8da4:4]=0x43f0e0 sym.HttpDenyPage
│       │   0x0042de7c      nop
│       │   0x0042de80      jalr t9
│       │   0x0042de84      move a0, s3
│      ┌──< 0x0042de88      b 0x42e54c
│      ││   0x0042de8c      nop
│      ││   ; CODE XREF from fcn.0042dd10 @ 0x42de70(x)
│      │└─> 0x0042de90      lw t9, -sym.swGetBpaCfg(gp)                ; [0x5ba9a4:4]=0x47dad4 sym.swGetBpaCfg
│      │    0x0042de94      nop
│      │    0x0042de98      jalr t9
│      │    0x0042de9c      move a0, s0
│      │    0x0042dea0      lw gp, (var_10h)
│      │    0x0042dea4      lui a1, 0x57
│      │    0x0042dea8      addiu a1, a1, -0x6994                      ; arg2
│      │    0x0042deac      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│      │    0x0042deb0      nop
│      │    0x0042deb4      jalr t9
│      │    0x0042deb8      move a0, s3
│      │    0x0042debc      lw gp, (var_10h)
│      │┌─< 0x0042dec0      bnez v0, 0x42dee4
│      ││   0x0042dec4      lui a1, 0x57
│      ││   ; CODE XREF from aav.0x00410f34 @ +0x85fc(x)
│      ││   0x0042dec8      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│      ││   0x0042decc      addiu a1, a1, -0x5c7c                      ; arg2
│      ││   0x0042ded0      jalr t9
│      ││   0x0042ded4      move a0, s3
│      ││   0x0042ded8      lw gp, (var_10h)
│     ┌───< 0x0042dedc      beqz v0, 0x42e1d8
│     │││   0x0042dee0      lui a1, 0x57
│     │││   ; CODE XREF from fcn.0042dd10 @ 0x42dec0(x)
│     ││└─> 0x0042dee4      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042dee8      lui a1, 0x58
│     ││    0x0042deec      addiu a1, a1, -0x10e8                      ; arg2
│     ││    0x0042def0      jalr t9
│     ││    ; CODE XREF from aav.0x00410f34 @ +0x1a9c(x)
│     ││    0x0042def4      move a0, s3
│     ││    0x0042def8      lw gp, (var_10h)
│     ││┌─< 0x0042defc      beqz v0, 0x42df24
│     │││   0x0042df00      move a1, v0
│     │││   0x0042df04      lw t9, -sym.imp.strncpy(gp)                ; [0x5b907c:4]=0x561610 sym.imp.strncpy
│     │││   0x0042df08      sb zero, (var_cch)
│     │││   0x0042df0c      addiu a0, sp, 0xb4                         ; arg1
│     │││   0x0042df10      jalr t9
│     │││   0x0042df14      addiu a2, zero, 0x18                       ; arg3
│     │││   0x0042df18      lw gp, (var_10h)
│    ┌────< 0x0042df1c      b 0x42df28
│    ││││   0x0042df20      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42defc(x)
│    │││└─> 0x0042df24      sb zero, (var_b4h)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42df1c(x)
│    └────> 0x0042df28      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042df2c      lui a1, 0x58
│     ││    0x0042df30      addiu a1, a1, -0x10dc                      ; arg2
│     ││    0x0042df34      jalr t9
│     ││    0x0042df38      move a0, s3
│     ││    0x0042df3c      lw gp, (var_10h)
│     ││┌─< 0x0042df40      beqz v0, 0x42df68
│     │││   0x0042df44      move a1, v0
│     │││   0x0042df48      lw t9, -sym.imp.strncpy(gp)                ; [0x5b907c:4]=0x561610 sym.imp.strncpy
│     │││   0x0042df4c      sb zero, (var_e5h)
│     │││   0x0042df50      addiu a0, sp, 0xcd                         ; arg1
│     │││   0x0042df54      jalr t9
│     │││   0x0042df58      addiu a2, zero, 0x18                       ; arg3
│     │││   0x0042df5c      lw gp, (var_10h)
│    ┌────< 0x0042df60      b 0x42df6c
│    ││││   0x0042df64      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42df40(x)
│    │││└─> 0x0042df68      sb zero, (var_cdh)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42df60(x)
│    └────> 0x0042df6c      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042df70      lui a1, 0x57
│     ││    0x0042df74      addiu a1, a1, -0x5a2c                      ; arg2
│     ││    0x0042df78      jalr t9
│     ││    0x0042df7c      move a0, s3
│     ││    0x0042df80      lw gp, (var_10h)
│     ││┌─< 0x0042df84      beqz v0, 0x42dfac
│     │││   0x0042df88      move a1, v0
│     │││   0x0042df8c      lw t9, -sym.imp.strncpy(gp)                ; [0x5b907c:4]=0x561610 sym.imp.strncpy
│     │││   0x0042df90      sb zero, (var_135h)
│     │││   0x0042df94      addiu a0, sp, 0xe6                         ; arg1
│     │││   0x0042df98      jalr t9
│     │││   0x0042df9c      addiu a2, zero, 0x4f                       ; arg3
│     │││   0x0042dfa0      lw gp, (var_10h)
│    ┌────< 0x0042dfa4      b 0x42dfb0
│    ││││   0x0042dfa8      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42df84(x)
│    │││└─> 0x0042dfac      sb zero, (var_e6h)
│    │││    ; CODE XREF from aav.0x00410f34 @ +0x1aac(x)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42dfa4(x)
│    └────> 0x0042dfb0      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042dfb4      lui a1, 0x57
│     ││    0x0042dfb8      addiu a1, a1, -0x5a24                      ; arg2
│     ││    0x0042dfbc      jalr t9
│     ││    ; CODE XREF from aav.0x00410f34 @ +0x1abc(x)
│     ││    0x0042dfc0      move a0, s3
│     ││    0x0042dfc4      lw gp, (var_10h)
│     ││┌─< 0x0042dfc8      beqz v0, 0x42dff0
│     │││   0x0042dfcc      move a1, v0
│     │││   0x0042dfd0      lw t9, -sym.imp.strncpy(gp)                ; [0x5b907c:4]=0x561610 sym.imp.strncpy
│     │││   0x0042dfd4      sb zero, (var_185h)
│     │││   0x0042dfd8      addiu a0, sp, 0x136                        ; arg1
│     │││   0x0042dfdc      jalr t9
│     │││   0x0042dfe0      addiu a2, zero, 0x4f                       ; arg3
│     │││   0x0042dfe4      lw gp, (var_10h)
│    ┌────< 0x0042dfe8      b 0x42dff4
│    ││││   0x0042dfec      nop
│    ││││   ; CODE XREF from aav.0x00410f34 @ +0xa33c(x)
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42dfc8(x)
│    │││└─> 0x0042dff0      sb zero, (var_136h)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42dfe8(x)
│    └────> 0x0042dff4      lw t9, -sym.getMaxWanPortNumber(gp)        ; [0x5b9d8c:4]=0x4eaabc sym.getMaxWanPortNumber
│     ││    ; CODE XREF from aav.0x00410f34 @ +0x36f0(x)
│     ││    0x0042dff8      nop
│     ││    0x0042dffc      jalr t9
│     ││    0x0042e000      nop
│     ││    0x0042e004      slti v0, v0, 2
│     ││    0x0042e008      lw gp, (var_10h)
│     ││┌─< 0x0042e00c      bnez v0, 0x42e080
│     │││   0x0042e010      lui a1, 0x57
│     │││   0x0042e014      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     │││   0x0042e018      addiu a1, a1, -0x5a18                      ; arg2
│     │││   0x0042e01c      jalr t9
│     │││   ; CODE XREF from aav.0x00410f34 @ +0xbe0(x)
│     │││   0x0042e020      move a0, s3
│     │││   0x0042e024      lw gp, (var_10h)
│     │││   ; CODE XREF from aav.0x00410f34 @ +0x3720(x)
│    ┌────< 0x0042e028      beqz v0, 0x42e048
│    ││││   0x0042e02c      nop
│    ││││   ; CODE XREF from aav.0x00410f34 @ +0x1b2c(x)
│    ││││   0x0042e030      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│    ││││   0x0042e034      nop
│    ││││   0x0042e038      jalr t9
│    ││││   0x0042e03c      move a0, v0
│    ││││   0x0042e040      lw gp, (var_10h)
│    ││││   0x0042e044      sw v0, (var_20h)
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42e028(x)
│    └────> 0x0042e048      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     │││   0x0042e04c      lui a1, 0x57
│     │││   0x0042e050      addiu a1, a1, -0x5a0c                      ; arg2
│     │││   0x0042e054      jalr t9
│     │││   0x0042e058      move a0, s3
│     │││   0x0042e05c      lw gp, (var_10h)
│    ┌────< 0x0042e060      beqz v0, 0x42e080
│    ││││   0x0042e064      nop
│    ││││   0x0042e068      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│    ││││   0x0042e06c      nop
│    ││││   ; CODE XREF from aav.0x00410f34 @ +0xbff8(x)
│    ││││   0x0042e070      jalr t9
│    ││││   0x0042e074      move a0, v0
│    ││││   0x0042e078      lw gp, (var_10h)
│    ││││   0x0042e07c      sw v0, (var_20h)
│    ││││   ; CODE XREFS from fcn.0042dd10 @ 0x42e00c(x), 0x42e060(x)
│    └──└─> 0x0042e080      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042e084      lui a1, 0x58
│     ││    0x0042e088      addiu a1, a1, 0x360                        ; arg2
│     ││    0x0042e08c      jalr t9
│     ││    0x0042e090      move a0, s3
│     ││    0x0042e094      lw gp, (var_10h)
│     ││┌─< 0x0042e098      beqz v0, 0x42e0bc
│     │││   0x0042e09c      nop
│     │││   0x0042e0a0      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│     │││   0x0042e0a4      nop
│     │││   0x0042e0a8      jalr t9
│     │││   0x0042e0ac      move a0, v0
│     │││   0x0042e0b0      lw gp, (var_10h)
│    ┌────< 0x0042e0b4      b 0x42e0c0
│    ││││   0x0042e0b8      sw v0, (var_188h)
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42e098(x)
│    │││└─> 0x0042e0bc      sw zero, (var_188h)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42e0b4(x)
│    └────> 0x0042e0c0      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042e0c4      lui a1, 0x57
│     ││    0x0042e0c8      addiu a1, a1, -0x5a00                      ; arg2
│     ││    0x0042e0cc      jalr t9
│     ││    0x0042e0d0      move a0, s3
│     ││    0x0042e0d4      lw gp, (var_10h)
│     ││┌─< 0x0042e0d8      beqz v0, 0x42e0fc
│     │││   0x0042e0dc      nop
│     │││   0x0042e0e0      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│     │││   0x0042e0e4      nop
│     │││   ; CODE XREF from aav.0x00410f34 @ +0x1c8c(x)
│     │││   0x0042e0e8      jalr t9
│     │││   0x0042e0ec      move a0, v0
│     │││   0x0042e0f0      lw gp, (var_10h)
│    ┌────< 0x0042e0f4      b 0x42e104
│    ││││   0x0042e0f8      sw v0, (var_18ch)
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42e0d8(x)
│    │││└─> 0x0042e0fc      addiu v0, zero, 3
│    │││    0x0042e100      sw v0, (var_18ch)
│    │││    ; CODE XREF from fcn.0042dd10 @ 0x42e0f4(x)
│    └────> 0x0042e104      lw v1, (var_18ch)
│     ││    0x0042e108      addiu v0, zero, 1
│     ││┌─< 0x0042e10c      bne v1, v0, 0x42e14c
│     │││   0x0042e110      addiu v0, zero, 3
│     │││   ; CODE XREF from aav.0x00410f34 @ +0xa0c8(x)
│     │││   0x0042e114      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     │││   0x0042e118      lui a1, 0x57
│     │││   0x0042e11c      addiu a1, a1, -0x59f4                      ; arg2
│     │││   0x0042e120      jalr t9
│     │││   0x0042e124      move a0, s3
│     │││   0x0042e128      lw gp, (var_10h)
│    ┌────< 0x0042e12c      beqz v0, 0x42e18c
│    ││││   0x0042e130      nop
│    ││││   0x0042e134      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│    ││││   0x0042e138      nop
│    ││││   0x0042e13c      jalr t9
│    ││││   0x0042e140      move a0, v0
│   ┌─────< 0x0042e144      b 0x42e180
│   │││││   0x0042e148      nop
│   │││││   ; CODE XREF from fcn.0042dd10 @ 0x42e10c(x)
│  ┌────└─> 0x0042e14c      bne v1, v0, 0x42e194
│  │││││    0x0042e150      lui a1, 0x57
│  │││││    0x0042e154      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│  │││││    0x0042e158      addiu a1, a1, -0x59e8                      ; arg2
│  │││││    0x0042e15c      jalr t9
│  │││││    0x0042e160      move a0, s3
│  │││││    0x0042e164      lw gp, (var_10h)
│  │││││┌─< 0x0042e168      beqz v0, 0x42e18c
│  ││││││   0x0042e16c      nop
│  ││││││   0x0042e170      lw t9, -sym.imp.atoi(gp)                   ; [0x5b82e8:4]=0x561990 sym.imp.atoi
│  ││││││   0x0042e174      nop
│  ││││││   0x0042e178      jalr t9
│  ││││││   0x0042e17c      move a0, v0
│  ││││││   ; CODE XREF from fcn.0042dd10 @ 0x42e144(x)
│  │└─────> 0x0042e180      lw gp, (var_10h)
│  │┌─────< 0x0042e184      b 0x42e194
│  ││││││   0x0042e188      sw v0, (var_190h)
│  ││││││   ; CODE XREFS from fcn.0042dd10 @ 0x42e12c(x), 0x42e168(x)
│  ││└──└─> 0x0042e18c      addiu v0, zero, 0xf
│  ││ ││    0x0042e190      sw v0, (var_190h)
│  ││ ││    ; CODE XREFS from fcn.0042dd10 @ 0x42e14c(x), 0x42e184(x)
│  └└─────> 0x0042e194      lw t9, -sym.swSetBpaCfg(gp)                ; [0x5b9c00:4]=0x47dcb8 sym.swSetBpaCfg
│     ││    0x0042e198      nop
│     ││    0x0042e19c      jalr t9
│     ││    0x0042e1a0      addiu a0, sp, 0xb4                         ; arg1
│     ││    0x0042e1a4      lw gp, (var_10h)
│     ││    0x0042e1a8      lui a1, 0x57
│     ││    0x0042e1ac      addiu a1, a1, -0x5c7c                      ; arg2
│     ││    0x0042e1b0      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│     ││    0x0042e1b4      nop
│     ││    0x0042e1b8      jalr t9
│     ││    0x0042e1bc      move a0, s3
│     ││    0x0042e1c0      lw gp, (var_10h)
│     ││┌─< 0x0042e1c4      beqz v0, 0x42e20c
│     │││   0x0042e1c8      nop
│     │││   0x0042e1cc      lw t9, -sym.swBpaLinkUpReq(gp)             ; [0x5ba2cc:4]=0x47dddc sym.swBpaLinkUpReq
│    ┌────< 0x0042e1d0      b 0x42e1fc
│    ││││   0x0042e1d4      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42dedc(x)
│    │└───> 0x0042e1d8      lw t9, -sym.httpGetEnv(gp)                 ; [0x5ba034:4]=0x5064c8 sym.httpGetEnv
│    │ ││   0x0042e1dc      addiu a1, a1, -0x5c74                      ; arg2
│    │ ││   0x0042e1e0      jalr t9
│    │ ││   0x0042e1e4      move a0, s3
│    │ ││   0x0042e1e8      lw gp, (var_10h)
│    │┌───< 0x0042e1ec      beqz v0, 0x42e20c
│    ││││   0x0042e1f0      nop
│    ││││   0x0042e1f4      lw t9, -sym.swBpaLinkDownReq(gp)           ; [0x5b9a70:4]=0x47dc38 sym.swBpaLinkDownReq
│    ││││   ; CODE XREF from aav.0x00410f34 @ +0x90c(x)
│    ││││   0x0042e1f8      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42e1d0(x)
│    └────> 0x0042e1fc      jalr t9
│     │││   0x0042e200      move a0, zero
│     │││   0x0042e204      lw gp, (var_10h)
│     │││   0x0042e208      nop
│     │││   ; CODE XREFS from fcn.0042dd10 @ 0x42e1c4(x), 0x42e1ec(x)
│     └─└─> 0x0042e20c      lw t9, -sym.swGetBpaCfg(gp)                ; [0x5ba9a4:4]=0x47dad4 sym.swGetBpaCfg
│      │    ; CODE XREF from aav.0x00410f34 @ +0x4d08(x)
│      │    0x0042e210      addiu s2, sp, 0xb4
│      │    0x0042e214      jalr t9
│      │    0x0042e218      move a0, s2
│      │    0x0042e21c      lw gp, (var_10h)
│      │    0x0042e220      addiu a0, sp, 0x18                         ; arg1
│      │    0x0042e224      addiu s0, sp, 0x2c
│      │    0x0042e228      lw t9, -sym.swBpaLinkStateGet(gp)          ; [0x5ba668:4]=0x47daf8 sym.swBpaLinkStateGet
│      │    0x0042e22c      nop
│      │    0x0042e230      jalr t9
│      │    0x0042e234      addiu s1, sp, 0x20
│      │    0x0042e238      lw gp, (var_10h)
│      │    0x0042e23c      nop
│      │    0x0042e240      lw t9, -sym.getMaxWanPortNumber(gp)        ; [0x5b9d8c:4]=0x4eaabc sym.getMaxWanPortNumber
│      │    0x0042e244      nop
│      │    0x0042e248      jalr t9
│      │    0x0042e24c      nop
│      │    0x0042e250      lw gp, (var_10h)
│      │    0x0042e254      move a0, s0
│      │    0x0042e258      move a1, s1
│      │    0x0042e25c      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e260      move a2, zero
│      │    0x0042e264      jalr t9
│      │    0x0042e268      sw v0, (var_20h)
│      │    0x0042e26c      lw gp, (var_10h)
│      │    0x0042e270      move a0, s0
│      │    0x0042e274      move a1, s1
│      │    0x0042e278      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e27c      addiu a2, zero, 1                          ; arg3
│      │    0x0042e280      jalr t9
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1d80(x)
│      │    0x0042e284      sw zero, (var_20h)
│      │    ; CODE XREF from aav.0x00410f34 @ +0x2d80(x)
│      │    0x0042e288      lw gp, (var_10h)
│      │    0x0042e28c      addiu v0, zero, 5
│      │    0x0042e290      move a0, s0
│      │    0x0042e294      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e298      move a1, s1
│      │    0x0042e29c      addiu a2, zero, 2                          ; arg3
│      │    0x0042e2a0      jalr t9
│      │    0x0042e2a4      sw v0, (var_20h)
│      │    0x0042e2a8      lw gp, (var_10h)
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1de0(x)
│      │    0x0042e2ac      move a1, s2
│      │    0x0042e2b0      move a0, s0
│      │    0x0042e2b4      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e2b8      nop
│      │    0x0042e2bc      jalr t9
│      │    0x0042e2c0      addiu a2, zero, 3                          ; arg3
│      │    0x0042e2c4      lw gp, (var_10h)
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1dc4(x)
│      │    0x0042e2c8      move a0, s0
│      │    0x0042e2cc      addiu a1, sp, 0xcd                         ; arg2
│      │    0x0042e2d0      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e2d4      nop
│      │    0x0042e2d8      jalr t9
│      │    0x0042e2dc      addiu a2, zero, 4                          ; arg3
│      │    0x0042e2e0      lw gp, (var_10h)
│      │    0x0042e2e4      move a0, s0
│      │    0x0042e2e8      addiu a1, sp, 0xe6                         ; arg2
│      │    0x0042e2ec      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e2f0      nop
│      │    0x0042e2f4      jalr t9
│      │    0x0042e2f8      addiu a2, zero, 5                          ; arg3
│      │    0x0042e2fc      lw gp, (var_10h)
│      │    0x0042e300      move a0, s0
│      │    0x0042e304      addiu a1, sp, 0x136                        ; arg2
│      │    0x0042e308      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e30c      nop
│      │    0x0042e310      jalr t9
│      │    0x0042e314      addiu a2, zero, 6                          ; arg3
│      │    0x0042e318      lw gp, (var_10h)
│      │    0x0042e31c      lw v0, (var_188h)
│      │    ; CODE XREF from aav.0x00410f34 @ +0x4a30(x)
│      │    0x0042e320      move a0, s0
│      │    0x0042e324      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e328      move a1, s1
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1e28(x)
│      │    0x0042e32c      addiu a2, zero, 7                          ; arg3
│      │    0x0042e330      jalr t9
│      │    0x0042e334      sw v0, (var_20h)
│      │    0x0042e338      lw gp, (var_10h)
│      │    0x0042e33c      lw v0, (var_18ch)
│      │    0x0042e340      move a0, s0
│      │    0x0042e344      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e348      move a1, s1
│      │    0x0042e34c      addiu a2, zero, 8                          ; arg3
│      │    0x0042e350      jalr t9
│      │    0x0042e354      sw v0, (var_20h)
│      │    0x0042e358      lw gp, (var_10h)
│      │    0x0042e35c      lw v0, (var_190h)
│      │    0x0042e360      move a0, s0
│      │    0x0042e364      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e368      move a1, s1
│      │    0x0042e36c      addiu a2, zero, 9                          ; arg3
│      │    0x0042e370      jalr t9
│      │    0x0042e374      sw v0, (var_20h)
│      │    0x0042e378      lw gp, (var_10h)
│      │    0x0042e37c      lw v0, (var_18h)
│      │    0x0042e380      move a0, s0
│      │    0x0042e384      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e388      sw v0, (var_20h)
│      │    0x0042e38c      move a1, s1
│      │    0x0042e390      jalr t9
│      │    0x0042e394      addiu a2, zero, 0xb                        ; arg3
│      │    0x0042e398      lw v1, (var_18h)
│      │    0x0042e39c      addiu v0, zero, 1
│      │    0x0042e3a0      lw gp, (var_10h)
│      │┌─< 0x0042e3a4      beq v1, v0, 0x42e3bc
│      ││   0x0042e3a8      nop
│     ┌───< 0x0042e3ac      beqz v1, 0x42e3c4
│     │││   0x0042e3b0      addiu v0, zero, 2
│    ┌────< 0x0042e3b4      bne v1, v0, 0x42e3c4
│    ││││   0x0042e3b8      nop
│    ││││   ; CODE XREF from fcn.0042dd10 @ 0x42e3a4(x)
│   ┌───└─> 0x0042e3bc      b 0x42e3c8
│   ││││    0x0042e3c0      sw v1, (var_1ch)
│   ││││    ; CODE XREFS from fcn.0042dd10 @ 0x42e3ac(x), 0x42e3b4(x)
│   │└└───> 0x0042e3c4      sw zero, (var_1ch)
│   │  │    ; CODE XREF from fcn.0042dd10 @ 0x42e3bc(x)
│   └─────> 0x0042e3c8      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1ec8(x)
│      │    0x0042e3cc      addiu s0, sp, 0x2c
│      │    0x0042e3d0      move a0, s0
│      │    0x0042e3d4      addiu a1, sp, 0x1c                         ; arg2
│      │    0x0042e3d8      jalr t9
│      │    0x0042e3dc      addiu a2, zero, 0xa                        ; arg3
│      │    0x0042e3e0      lw gp, (var_10h)
│      │    0x0042e3e4      addiu s1, sp, 0x20
│      │    0x0042e3e8      addiu s2, zero, 1
│      │    0x0042e3ec      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e3f0      move a0, s0
│      │    0x0042e3f4      move a1, s1
│      │    0x0042e3f8      sw s2, (var_20h)
│      │    0x0042e3fc      jalr t9
│      │    0x0042e400      addiu a2, zero, 0xc                        ; arg3
│      │    0x0042e404      lw gp, (var_10h)
│      │    0x0042e408      move a0, s0
│      │    0x0042e40c      move a1, s1
│      │    0x0042e410      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e414      nop
│      │    0x0042e418      jalr t9
│      │    0x0042e41c      addiu a2, zero, 0xd                        ; arg3
│      │    0x0042e420      lw gp, (var_10h)
│      │    ; CODE XREF from aav.0x00410f34 @ +0x3724(x)
│      │    0x0042e424      move a1, s1
│      │    0x0042e428      addiu a2, zero, 0xe                        ; arg3
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1f28(x)
│      │    0x0042e42c      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e430      move a0, s0
│      │    ; CODE XREF from aav.0x00410f34 @ +0x4f1c(x)
│      │    0x0042e434      jalr t9
│      │    0x0042e438      sw s2, (var_20h)
│      │    0x0042e43c      lw gp, (var_10h)
│      │    0x0042e440      addiu a0, sp, 0x24                         ; arg1
│      │    0x0042e444      lw t9, -sym.swGetSystemMode(gp)            ; [0x5ba194:4]=0x47e304 sym.swGetSystemMode
│      │    0x0042e448      nop
│      │    0x0042e44c      jalr t9
│      │    0x0042e450      move s2, s0
│      │    0x0042e454      lw gp, (var_10h)
│      │    0x0042e458      addiu v0, zero, 3
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1f58(x)
│      │    0x0042e45c      move a1, s1
│      │    0x0042e460      lw t9, -sym.pageParaSet(gp)                ; [0x5b9aec:4]=0x440668 sym.pageParaSet
│      │    0x0042e464      move a0, s0
│      │    0x0042e468      addiu a2, zero, 0xf                        ; arg3
│      │    0x0042e46c      jalr t9
│      │    0x0042e470      sw v0, (var_20h)
│      │    0x0042e474      lw gp, (var_10h)
│      │    0x0042e478      lui a1, 0x57
│      │    ; CODE XREF from aav.0x00410f34 @ +0x3ba0(x)
│      │    0x0042e47c      lui a2, 0x57
│      │    0x0042e480      lw t9, -sym.httpPrintf(gp)                 ; [0x5b8848:4]=0x510200 sym.httpPrintf
│      │    0x0042e484      addiu a1, a1, -0x6978                      ; arg2
│      │    0x0042e488      addiu a2, a2, -0x59dc                      ; arg3
│      │    0x0042e48c      jalr t9
│      │    ; CODE XREF from aav.0x00410f34 @ +0x4c18(x)
│      │    0x0042e490      move a0, s3
│      │    0x0042e494      lw gp, (var_10h)
│      │    0x0042e498      move s0, zero
│      │    0x0042e49c      addiu s1, zero, 0x10
│      │    ; CODE XREF from fcn.0042dd10 @ 0x42e4bc(x)
│      │┌─> 0x0042e4a0      lw t9, -sym.pageDynParaPrintf(gp)          ; [0x5b8cd8:4]=0x440458 sym.pageDynParaPrintf
│      │╎   0x0042e4a4      move a1, s0
│      │╎   0x0042e4a8      move a0, s2
│      │╎   0x0042e4ac      move a2, s3
│      │╎   0x0042e4b0      jalr t9
│      │╎   0x0042e4b4      addiu s0, s0, 1
│      │╎   0x0042e4b8      lw gp, (var_10h)
│      ││   ; CODE XREF from aav.0x00410f34 @ +0x4ff8(x)
│      │└─< 0x0042e4bc      bne s0, s1, 0x42e4a0
│      │    0x0042e4c0      lui a1, 0x57
│      │    0x0042e4c4      lw t9, -sym.httpPrintf(gp)                 ; [0x5b8848:4]=0x510200 sym.httpPrintf
│      │    0x0042e4c8      addiu a1, a1, -0x6924                      ; arg2
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1c64(x)
│      │    0x0042e4cc      jalr t9
│      │    0x0042e4d0      move a0, s3
│      │    0x0042e4d4      lw gp, (var_10h)
│      │    0x0042e4d8      nop
│      │    0x0042e4dc      lw t9, -sym.httpPrintfWanTypeInfo(gp)      ; [0x5b8098:4]=0x42dafc sym.httpPrintfWanTypeInfo
│      │    0x0042e4e0      nop
│      │    0x0042e4e4      jalr t9
│      │    0x0042e4e8      move a0, s3
│      │    ; CODE XREF from aav.0x00410f34 @ +0x1bf4(x)
│      │    0x0042e4ec      lw gp, (var_10h)
│      │    0x0042e4f0      move a0, s3
│      │    0x0042e4f4      move a1, zero
│      │    0x0042e4f8      lw t9, -sym.HttpWebV4Head(gp)              ; [0x5b9f78:4]=0x43f724 sym.HttpWebV4Head
│      │    0x0042e4fc      nop
│      │    0x0042e500      jalr t9
│      │    0x0042e504      addiu a2, zero, 1                          ; arg3
│      │    0x0042e508      lw gp, (var_10h)
│      │    0x0042e50c      lui a1, 0x57
│      │    0x0042e510      move a0, s3
│      │    0x0042e514      lw t9, -sym.httpRpmFsA(gp)                 ; [0x5b9608:4]=0x509724 sym.httpRpmFsA
│      │    0x0042e518      nop
│      │    0x0042e51c      jalr t9
│      │    0x0042e520      addiu a1, a1, -0x5a54                      ; arg2
│      │    0x0042e524      addiu v1, zero, 2
│      │    0x0042e528      lw gp, (var_10h)
│      │┌─< 0x0042e52c      beq v0, v1, 0x42e558
│      ││   0x0042e530      addiu a0, zero, 2                          ; arg1
│      ││   0x0042e534      lw t9, -sym.HttpErrorPage(gp)              ; [0x5b93a8:4]=0x43ad20 sym.HttpErrorPage
│      ││   0x0042e538      move a0, s3
│      ││   0x0042e53c      addiu a1, zero, 0xa                        ; arg2
│      ││   0x0042e540      move a2, zero
│      ││   0x0042e544      jalr t9
│      ││   0x0042e548      move a3, zero
│      ││   ; CODE XREF from fcn.0042dd10 @ 0x42de88(x)
│      └──> 0x0042e54c      lw gp, (var_10h)
│       │   0x0042e550      sll a0, v0, 0x10                           ; arg1
│       │   0x0042e554      sra a0, a0, 0x10                           ; arg1
│       │   ; CODE XREF from fcn.0042dd10 @ 0x42e52c(x)
│       └─> 0x0042e558      lw ra, (var_2b4h)
│           0x0042e55c      move v0, a0
│           0x0042e560      lw s3, (var_2b0h)
│           0x0042e564      lw s2, (var_2ach)
│           0x0042e568      lw s1, (var_2a8h)
│           0x0042e56c      lw s0, (var_2a4h)
│           ; CODE XREF from aav.0x00410f34 @ +0x5068(x)
│           0x0042e570      jr ra
└           0x0042e574      addiu sp, sp, 0x2b8
