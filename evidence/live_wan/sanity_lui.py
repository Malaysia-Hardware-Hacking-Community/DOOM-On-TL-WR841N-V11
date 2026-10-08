b = open('/tmp/fw/root/usr/bin/httpd', 'rb').read()
base = 0x400000
# sanity: any LUI with imm 0x57xx
cnt = {}
for off in range(0, 0x18ae00 - 4, 4):
    w = int.from_bytes(b[off:off + 4], 'big')
    if w >> 16 == 0x3c00:
        imm = w & 0xffff
        if imm >> 12 == 0x57:
            cnt.setdefault(imm, []).append(off)
print('LUI 0x57xx counts:')
for imm, offs in sorted(cnt.items()):
    print('  imm=%04x count=%d first=%s' % (imm, len(offs), hex(base + offs[0])))
# also scan ALL lui across binary for nearby addiu referencing 0x578000-0x579000 range any scheme
matches = []
for off in range(0, 0x18ae00 - 8, 4):
    w = int.from_bytes(b[off:off + 4], 'big')
    if w >> 16 == 0x3c00:
        for j in range(1, 5):
            n = int.from_bytes(b[off + 4 * j:off + 4 * j + 4], 'big')
            op = (n >> 26) & 0x3f
            if op == 0x09:  # addiu
                rt = (w >> 21) & 0x1f
                nrt = (n >> 16) & 0x1f
                nrs = (n >> 21) & 0x1f
                if nrt == nrs == rt:
                    lo = n & 0xffff
                    if lo & 0x8000: lo -= 0x10000
                    tgt = ((w & 0xffff) << 16) + lo
                    if 0x570000 <= tgt <= 0x579000:
                        matches.append((off, hex(tgt)))
print('any lui+addiu to 0x570000-0x579000:', len(matches))
for m in matches[:10]:
    print(' ', hex(base + m[0]), m[1])