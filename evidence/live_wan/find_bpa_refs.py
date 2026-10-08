b = open('/tmp/fw/root/usr/bin/httpd', 'rb').read()
base = 0x400000
# refs to 0x4e4934 (bpaStartAfterDhcpOk) as absolute pointer in text/data
pat = int.to_bytes(0x4e4934, 4, 'big')
hits = []
off = 0
while True:
    i = b.find(pat, off)
    if i < 0:
        break
    hits.append(0x400000 + i)
    off = i + 1
print('raw ptr refs to bpaStartAfterDhcpOk:', [hex(h) for h in hits])