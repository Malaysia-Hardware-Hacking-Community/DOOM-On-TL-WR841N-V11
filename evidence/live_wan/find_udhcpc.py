b = open('/tmp/fw/root/usr/bin/httpd', 'rb').read()
base = 0x400000
for imm in [0x578a, 0x578b]:
    hits = []
    for off in range(0, 0x18ae00 - 8, 4):
        w = int.from_bytes(b[off:off + 4], 'big')
        if (w >> 26) == 0x3c and (w & 0xffff) == imm:
            rt = (w >> 16) & 0x1f
            for j in range(1, 5):
                n = int.from_bytes(b[off + 4 * j:off + 4 * j + 4], 'big')
                op = (n >> 26) & 0x3f
                nrt = (n >> 16) & 0x1f
                nrs = (n >> 21) & 0x1f
                if op == 0x09 and nrs == rt and nrt == rt:
                    lo = n & 0xffff
                    if lo & 0x8000:
                        lo -= 0x10000
                    tgt = (imm << 16) + lo
                    if 0x578a20 <= tgt <= 0x578b60:
                        hits.append((off, rt, hex(tgt)))
                    break
    print('imm', hex(imm), [(hex(base + o), f'$r{r}', t) for o, r, t in hits[:12]])