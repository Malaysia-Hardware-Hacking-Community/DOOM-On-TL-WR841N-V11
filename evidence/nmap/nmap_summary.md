# Nmap Scan — TL-WR841N v11 (Stock 160325)

Capture: 2026-09-12T08:18:02Z UTC
Target: 192.168.0.1 (MAC 98:DE:D0:D4:05:C6, TP-Link Technologies)
Host: gluppler linux workstation (eth1 192.168.0.100/24), nmap 7.99 --privileged
Context: router in AP-Client/Repeater mode (wanPara[0]=4), firmware "3.16.9 Build 160325 Rel.62500n", board "WR841N v11"

## TCP (top 1000 + full 1-65535)

| Port | State | Service | Version |
|---|---|---|---|
| 22/tcp  | open | ssh | Dropbear sshd 2012.55 (protocol 2.0) |
| 80/tcp  | open | http | TP-LINK WR841N WAP http config |
| 1900/tcp | open | upnp | ipOS upnpd (TP-LINK TL-WR841N WAP 11.0; UPnP 1.0) |

Full 1-65535 SYN scan: same 3 ports only. All other TCP: closed (RST).
Service Info: OSs: Linux, ipOS 7.0; Device: WAP; CPE: cpe:/o:linux:linux_kernel, cpe:/h:tp-link:wr841n, cpe:/h:tp-link:tl-wr841n, cpe:/o:ubicom:ipos:7.0

## UDP (top 20 and top 100)

UDP is largely silent (open|filtered = no ICMP-port-unreachable received; device drops most UDP silently).
UDP top-100 scan was time-limited by per-host timeout; only 1900/udp reports cleanly OPEN.

| Port | State | Service |
|---|---|---|
| 1900/udp | open | upnp (SSDP) |
| 53/udp | filtered | domain |
| 67/udp | open\|filtered | dhcps |
| 123/udp | open\|filtered | ntp |
| 137/udp | open\|filtered | netbios-ns |
| 139/udp | open\|filtered | netbios-ssn |
| 162/udp | open\|filtered | snmptrap |
| 427/udp | open\|filtered | svrloc |
| 445/udp | open\|filtered | microsoft-ds |
| 500/udp | open\|filtered | isakmp |
| 515/udp | open\|filtered | printer |
| 520/udp | open\|filtered | route |
| 623/udp | open\|filtered | asf-rmcp |
| 631/udp | open\|filtered | ipp |
| 997/udp | open\|filtered | maitrd |

Notes:
- SSDP unicast M-SEARCH on 239.255.255.250:1900 returned no response in this test (UPnP reachable on 1900/tcp per nmap but no rootDesc discovery reply observed).
- 161/udp (snmp) = closed (device sent ICMP unreachable) → SNMP agent not listening.
- UPNP SOAP (1900/tcp) is unauthenticated LAN surface -> relevant to Sec "UPnP" prior findings.

## Notes
- httpd stability after power-cycle: StatusRpm/WlanNetworkRpm/WanCfgRpm/DhcpCfgRpm all HTTP 200 in 11-21ms post reboot (see evidence/live_web/).
- DO NOT combine a later sym.wlanInit / ConfigRpm save test with nmap timing; previous diagnostic PingIframeRpm trigger wedged httpd (single worker) — see findings log update.
