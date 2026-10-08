// ucWlanGetSsid_struct_read
// binary: /tmp/fw/root/usr/bin/httpd
// VA=file_off+0x400000, ELF32 MSB MIPS
// cmd: r2 -q -e scr.color=false -c "s 0x0048de90; pd 30" usr/bin/httpd
// captured: 2026-09-12T07:55:45Z

            ;-- ucWlanGetSsid:
            0x0048de90      2405017c       addiu a1, zero, 0x17c
            0x0048de94      00850018       mult a0, a1
            0x0048de98      2403002c       addiu v1, zero, 0x2c
            0x0048de9c      3c02005c       lui v0, 0x5c
            0x0048dea0      8c42b0b0       lw v0, -0x4f50(v0)
            0x0048dea4      00002812       mflo a1
            0x0048dea8      00451021       addu v0, v0, a1
            0x0048deac      00000000       nop
            0x0048deb0      00830018       mult a0, v1
            0x0048deb4      00002012       mflo a0
            0x0048deb8      00441021       addu v0, v0, a0
            0x0048debc      03e00008       jr ra
            0x0048dec0      2442001c       addiu v0, v0, 0x1c
            ;-- ucWlanGetmSsid:
            0x0048dec4      2406017c       addiu a2, zero, 0x17c
            0x0048dec8      00860018       mult a0, a2
            0x0048decc      2403002c       addiu v1, zero, 0x2c
            0x0048ded0      3c02005c       lui v0, 0x5c
            0x0048ded4      8c42b0b0       lw v0, -0x4f50(v0)
            0x0048ded8      00003012       mflo a2
            0x0048dedc      00461021       addu v0, v0, a2
            0x0048dee0      00000000       nop
            0x0048dee4      00830018       mult a0, v1
            0x0048dee8      00002012       mflo a0
            0x0048deec      00a42821       addu a1, a1, a0
            0x0048def0      00451021       addu v0, v0, a1
            0x0048def4      03e00008       jr ra
            0x0048def8      2442001c       addiu v0, v0, 0x1c
            ;-- ucWlanGetCurRegion:
            0x0048defc      2402017c       addiu v0, zero, 0x17c
            0x0048df00      00820018       mult a0, v0
            0x0048df04      3c02005c       lui v0, 0x5c
