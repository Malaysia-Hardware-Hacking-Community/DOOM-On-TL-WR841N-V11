            ; CALL XREF from sym.bpaStartAfterDhcpOk @ 0x4e4ad0(x)
┌ 204: fcn.004e46a4 (int32_t arg1, int32_t arg2, int32_t arg3, int32_t arg4);
│ `- args(a0, a1, a2, a3) vars(4:sp[0x4..0x18])
│           0x004e46a4      lui gp, 0x5c
│           0x004e46a8      addiu sp, sp, -0x28
│           0x004e46ac      addiu gp, gp, -0x2f0
│           0x004e46b0      sw ra, (var_24h)
│           0x004e46b4      sw s1, (var_20h)
│           0x004e46b8      sw s0, (var_1ch)
│           0x004e46bc      sw gp, (var_10h)
│           0x004e46c0      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e46c4      move s1, a1
│           0x004e46c8      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e46cc      move s0, a0
│           0x004e46d0      move a2, a0
│           0x004e46d4      addiu a3, a0, 0x19                         ; arg4
│           0x004e46d8      addiu a1, a1, -0x2690                      ; 0x57d970 ; "bpalogin user %s password %s" ; arg2 [0m; str.bpalogin_user__s_password__s
│           0x004e46dc      jalr t9
│           0x004e46e0      move a0, s1
│           0x004e46e4      lw gp, (var_10h)
│           0x004e46e8      nop
│           0x004e46ec      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e46f0      nop
│           0x004e46f4      jalr t9
│           0x004e46f8      move a0, s1
│           0x004e46fc      lw gp, (var_10h)
│           0x004e4700      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e4704      addiu a3, s0, 0x82                         ; arg4
│           0x004e4708      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e470c      addiu a2, s0, 0x32                         ; arg3
│           0x004e4710      addiu a1, a1, -0x2670                      ; 0x57d990 ; " authserver \"%s\" authdomain \"%s\"" ; arg2 [0m; str.authserver___s__authdomain___s_
│           0x004e4714      jalr t9
│           0x004e4718      addu a0, s1, v0                            ; arg1
│           0x004e471c      lw gp, (var_10h)
│           0x004e4720      nop
│           0x004e4724      lw t9, -sym.imp.strlen(gp)                 ; [0x5611a0:4]=0x8f998010
│           0x004e4728      nop
│           0x004e472c      jalr t9
│           0x004e4730      move a0, s1
│           0x004e4734      lw gp, (var_10h)
│           0x004e4738      lui a1, 0x58                               ; 0x580000 ; "me"
│           0x004e473c      addu a0, s1, v0                            ; arg1
│           0x004e4740      lw v1, -obj.linkModeThreadPid(gp)          ; [0x5bac7c:4]=0
│           0x004e4744      lw t9, -sym.imp.sprintf(gp)                ; [0x561800:4]=0x8f998010
│           0x004e4748      lw a2, (v1)                                ; [0x5bac7c:4]=0
│                                                                      ; obj.linkModeThreadPid
│           0x004e474c      jalr t9
│           0x004e4750      addiu a1, a1, -0x2ac0                      ; 0x57d540 ; " httpd-pid %d" ; arg2 [0m; str.httpd_pid__d
│           0x004e4754      lw ra, (var_24h)
│           0x004e4758      lw gp, (var_10h)
│           0x004e475c      move v0, zero
│           0x004e4760      lw s1, (var_20h)
│           0x004e4764      lw s0, (var_1ch)
│           0x004e4768      jr ra
└           0x004e476c      addiu sp, sp, 0x28
