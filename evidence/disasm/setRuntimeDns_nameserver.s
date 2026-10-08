// setRuntimeDns_nameserver
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x004b4410; pd 130" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- setRuntimeDns:
            0x004b4410      3c1c005c       lui gp, 0x5c
            0x004b4414      27bdff50       addiu sp, sp, -0xb0
            0x004b4418      279cfd10       addiu gp, gp, -0x2f0
            0x004b441c      afbf00ac       sw ra, 0xac(sp)
            0x004b4420      afb100a8       sw s1, 0xa8(sp)
            0x004b4424      afb000a4       sw s0, 0xa4(sp)
            0x004b4428      afbc0018       sw gp, 0x18(sp)
        ┌─< 0x004b442c      14800004       bnez a0, 0x4b4440
        │   0x004b4430      00808821       move s1, a0
        │   0x004b4434      8f999dac       lw t9, -sym.set_dns_server(gp) ; [0x5b9abc:4]=0x4b6220 sym.set_dns_server
       ┌──< 0x004b4438      1000003d       b 0x4b4530
       ││   0x004b443c      00002821       move a1, zero
       │└─> 0x004b4440      8c840000       lw a0, (a0)
       │    0x004b4444      00000000       nop
       │┌─< 0x004b4448      10800015       beqz a0, 0x4b44a0
       ││   0x004b444c      00000000       nop
       ││   0x004b4450      8f998f68       lw t9, -sym.imp.inet_ntoa(gp) ; [0x5b8c78:4]=0x5616e0 sym.imp.inet_ntoa
       ││   0x004b4454      00000000       nop
       ││   0x004b4458      0320f809       jalr t9
       ││   0x004b445c      27b00020       addiu s0, sp, 0x20
       ││   0x004b4460      8fbc0018       lw gp, 0x18(sp)
       ││   0x004b4464      3c050057       lui a1, 0x57
       ││   0x004b4468      3c070057       lui a3, 0x57
       ││   0x004b446c      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
       ││   0x004b4470      24a57c8c       addiu a1, a1, 0x7c8c
       ││   0x004b4474      00403021       move a2, v0
       ││   0x004b4478      24e77ca8       addiu a3, a3, 0x7ca8
       ││   0x004b447c      0320f809       jalr t9
       ││   0x004b4480      02002021       move a0, s0
       ││   0x004b4484      8fbc0018       lw gp, 0x18(sp)
       ││   0x004b4488      00000000       nop
       ││   0x004b448c      8f99aa88       lw t9, -sym.imp.system(gp)  ; [0x5ba798:4]=0x560f50 sym.imp.system
       ││   0x004b4490      00000000       nop
       ││   0x004b4494      0320f809       jalr t9
       ││   0x004b4498      02002021       move a0, s0
       ││   0x004b449c      8fbc0018       lw gp, 0x18(sp)
       │└─> 0x004b44a0      8e240004       lw a0, 4(s1)
       │    0x004b44a4      00000000       nop
       │┌─< 0x004b44a8      1080001e       beqz a0, 0x4b4524
       ││   0x004b44ac      00000000       nop
       ││   0x004b44b0      8f998f68       lw t9, -sym.imp.inet_ntoa(gp) ; [0x5b8c78:4]=0x5616e0 sym.imp.inet_ntoa
       ││   0x004b44b4      00000000       nop
       ││   0x004b44b8      0320f809       jalr t9
       ││   0x004b44bc      00000000       nop
       ││   0x004b44c0      8e230000       lw v1, (s1)
       ││   0x004b44c4      8fbc0018       lw gp, 0x18(sp)
      ┌───< 0x004b44c8      14600004       bnez v1, 0x4b44dc
      │││   0x004b44cc      00403021       move a2, v0
      │││   0x004b44d0      3c020059       lui v0, 0x59
     ┌────< 0x004b44d4      10000003       b 0x4b44e4
     ││││   0x004b44d8      2447987c       addiu a3, v0, -0x6784
     │└───> 0x004b44dc      3c020057       lui v0, 0x57
     │ ││   0x004b44e0      24477cbc       addiu a3, v0, 0x7cbc
     └────> 0x004b44e4      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
       ││   0x004b44e8      3c020057       lui v0, 0x57
       ││   0x004b44ec      27b00020       addiu s0, sp, 0x20
       ││   0x004b44f0      24427ca8       addiu v0, v0, 0x7ca8
       ││   0x004b44f4      3c050057       lui a1, 0x57
       ││   0x004b44f8      24a57cc0       addiu a1, a1, 0x7cc0
       ││   0x004b44fc      02002021       move a0, s0
       ││   0x004b4500      0320f809       jalr t9
       ││   0x004b4504      afa20010       sw v0, 0x10(sp)
       ││   0x004b4508      8fbc0018       lw gp, 0x18(sp)
       ││   0x004b450c      00000000       nop
       ││   0x004b4510      8f99aa88       lw t9, -sym.imp.system(gp)  ; [0x5ba798:4]=0x560f50 sym.imp.system
       ││   0x004b4514      00000000       nop
       ││   0x004b4518      0320f809       jalr t9
       ││   0x004b451c      02002021       move a0, s0
       ││   0x004b4520      8fbc0018       lw gp, 0x18(sp)
       │└─> 0x004b4524      8e250004       lw a1, 4(s1)
       │    0x004b4528      8f999dac       lw t9, -sym.set_dns_server(gp) ; [0x5b9abc:4]=0x4b6220 sym.set_dns_server
       │    0x004b452c      8e240000       lw a0, (s1)
       └──> 0x004b4530      0320f809       jalr t9
            0x004b4534      00000000       nop
            0x004b4538      8fbf00ac       lw ra, 0xac(sp)
            0x004b453c      8fbc0018       lw gp, 0x18(sp)
            0x004b4540      8fb100a8       lw s1, 0xa8(sp)
            0x004b4544      8fb000a4       lw s0, 0xa4(sp)
            0x004b4548      03e00008       jr ra
            0x004b454c      27bd00b0       addiu sp, sp, 0xb0
            ;-- setRunTimeMtu:
            0x004b4550      3c1c005c       lui gp, 0x5c
            0x004b4554      27bdfed8       addiu sp, sp, -0x128
            0x004b4558      279cfd10       addiu gp, gp, -0x2f0
            0x004b455c      afbf0124       sw ra, 0x124(sp)
            0x004b4560      afb10120       sw s1, 0x120(sp)
            0x004b4564      afb0011c       sw s0, 0x11c(sp)
            0x004b4568      afbc0010       sw gp, 0x10(sp)
            0x004b456c      2482fdc0       addiu v0, a0, -0x240
            0x004b4570      2c42039d       sltiu v0, v0, 0x39d
            0x004b4574      10400012       beqz v0, 0x4b45c0
            0x004b4578      00808821       move s1, a0
            0x004b457c      0c12d0eb       jal sym.getWanIfName
            0x004b4580      27b00018       addiu s0, sp, 0x18
            0x004b4584      8fbc0010       lw gp, 0x10(sp)
            0x004b4588      3c050057       lui a1, 0x57
            0x004b458c      8f998c54       lw t9, -sym.imp.sprintf(gp) ; [0x5b8964:4]=0x561800 sym.imp.sprintf
            0x004b4590      24a57cdc       addiu a1, a1, 0x7cdc
            0x004b4594      00403021       move a2, v0
            0x004b4598      02203821       move a3, s1
            0x004b459c      0320f809       jalr t9
            0x004b45a0      02002021       move a0, s0
            0x004b45a4      8fbc0010       lw gp, 0x10(sp)
            0x004b45a8      00000000       nop
            0x004b45ac      8f99aa88       lw t9, -sym.imp.system(gp)  ; [0x5ba798:4]=0x560f50 sym.imp.system
            0x004b45b0      00000000       nop
            0x004b45b4      0320f809       jalr t9
            0x004b45b8      02002021       move a0, s0
            0x004b45bc      8fbc0010       lw gp, 0x10(sp)
            0x004b45c0      8fbf0124       lw ra, 0x124(sp)
            0x004b45c4      8fb10120       lw s1, 0x120(sp)
            0x004b45c8      8fb0011c       lw s0, 0x11c(sp)
            0x004b45cc      03e00008       jr ra
            0x004b45d0      27bd0128       addiu sp, sp, 0x128
            ;-- updateWanRuntimeDnsCfg:
            0x004b45d4      3c1c005c       lui gp, 0x5c
            0x004b45d8      27bdffe0       addiu sp, sp, -0x20
            0x004b45dc      279cfd10       addiu gp, gp, -0x2f0
            0x004b45e0      afbf001c       sw ra, 0x1c(sp)
            0x004b45e4      afbc0010       sw gp, 0x10(sp)
            0x004b45e8      0c12d104       jal sym.setRuntimeDns
            0x004b45ec      00a02021       move a0, a1
            0x004b45f0      8fbc0010       lw gp, 0x10(sp)
            0x004b45f4      14400005       bnez v0, 0x4b460c
            0x004b45f8      00000000       nop
            0x004b45fc      8f9980dc       lw t9, -sym.ipt_update(gp)  ; [0x5b7dec:4]=0x4cac58 sym.ipt_update
            0x004b4600      8fbf001c       lw ra, 0x1c(sp)
            0x004b4604      03200008       jr t9
            0x004b4608      27bd0020       addiu sp, sp, 0x20
            0x004b460c      8fbf001c       lw ra, 0x1c(sp)
            0x004b4610      00000000       nop
            0x004b4614      03e00008       jr ra
