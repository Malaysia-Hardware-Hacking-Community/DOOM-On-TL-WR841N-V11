import socket, sys, threading, time
logfile = '/tmp/routerenum/tftp.log'
pwnfile = '/tmp/routerenum/pwn'
with open(pwnfile, 'w') as f:
    f.write('pwn_marker_' + str(int(time.time())) + '\n')

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 69))
print('tftp listener ready on 0.0.0.0:69', flush=True)
with open(logfile, 'w') as fl:
    fl.write('READY %s\n' % time.ctime())

while True:
    data, addr = s.recvfrom(1024)
    print('TFTP-RCVD %s:%d %r' % (addr[0], addr[1], data[:20]), flush=True)
    with open(logfile, 'a') as fl:
        fl.write('TFTP-CALLBACK %s:%d %s %r\n' % (addr[0], addr[1], time.ctime(), data[:40]))
    # RRQ: opcode 1 + filename + 0 + mode + 0
    if len(data) > 2 and data[0] == 0 and data[1] == 1:
        try:
            fname = data[2:data.index(b'\x00', 2)].decode()
        except Exception:
            fname = '?'
        print('RRQ for %r' % fname, flush=True)
        try:
            with open('/tmp/routerenum/pwn', 'rb') as f:
                payload = f.read()
            blk = 1
            tport = addr[1]
            for i in range(0, len(payload), 512):
                chunk = payload[i:i+512]
                s.sendto(b'\x00\x03' + blk.to_bytes(2, 'big') + chunk, addr)
                with open(logfile, 'a') as fl:
                    fl.write('SENT blk %d %d bytes to %s:%d\n' % (blk, len(chunk), addr[0], tport))
                blk += 1
        except FileNotFoundError:
            s.sendto(b'\x00\x05\x00\x01File not found', addr)
