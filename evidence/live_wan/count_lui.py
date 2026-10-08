b = open('/tmp/fw/root/usr/bin/httpd', 'rb').read()
base = 0x400000
# count all LUI correctly first
total = 0
by_hi = {}
for off in range(0, 0x18ae00 - 4, 4):
    w = int.from_bytes(b[off:off + 4], 'big')
    if (w >> 26) == 0x3c:
        total += 1
        imm = w & 0xffff
        by_hi.setdefault(imm >> 8, 0)
        by_hi[imm >> 8] += 1
print('total LUI (correct):', total)
print('by hi byte:', sorted(by_hi.items()))