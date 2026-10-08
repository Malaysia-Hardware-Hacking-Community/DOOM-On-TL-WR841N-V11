b = open('/tmp/fw/root/usr/bin/httpd', 'rb').read()

def show(off, n):
    for i in range(n):
        w = int.from_bytes(b[off + 4 * i:off + 4 * i + 4], 'big')
        print('  %08x  %08x' % (0x400000 + off + 4 * i, w))

# known function vaddr 0x42010c (from r2 earlier) -> file offset?
# LOAD1 maps file 0 => vaddr 0x400000, so file = vaddr - 0x400000
print('entry-area dump at vaddr 0x42010c (LUI gp,0x5c expected):')
show(0x2010c, 3)

# find the string '/sbin/udhcpc' file offset
i = b.find(b'/sbin/udhcpc')
print('udhcpc str file off %#x -> vaddr %#x' % (i, 0x400000 + i))

# dump around it
print('string context:', b[i - 16:i + 32])

# count total LUI instructions (opcode 0x3c) to prove scanner works
total = 0
for off in range(0, 0x18ae00 - 4, 4):
    w = int.from_bytes(b[off:off + 4], 'big')
    if w >> 26 == 0x3c:
        total += 1
print('total LUI instrs in text:', total)