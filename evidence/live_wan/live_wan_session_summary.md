# Live WAN-Side Test Session — 2026-09-12 (IPv4/IPv6 DHCP study)

Status: **Evidence of a stuck WAN state machine; BPA injection still static-proven, live trigger unproven.**

## Setup at time of capture
- Router WAN port cabled directly to host eth1 (up, `LOWER_UP`).
- Host eth1 IPv6: link-local `fe80::5054:ff:feb1:10c4/64`, ULA `fd00::100/64` (assigned; `tentative` → global after flap).
- `dnsmasq` 2.93 (detached, pid 167918) on eth1, dual-stack config `wan_dnsmasq_dualstack.conf`:
  - IPv4 DHCP: `192.168.0.50-100` + opt router/DNS `192.168.0.100`
  - IPv6: `enable-ra`, RA prefix `fd00::` (constructor:eth1), DHCPv6 stateless range `::50-::ff` template
  - `bind-interfaces`, `log-dhcp`, `log-queries`
- TFTP listener (pid 137207) on 0.0.0.0:69 → `/tmp/routerenum/pwn`.
- WAN link flapped once (eth1 down/up) to attempt to fire the router's link-up event.

## Observed behavior (captures in wan_dnsmasq.log + live tcpdump)
- Router WAN MAC `98:DE:D0:D4:05:C7` (TP-Link OUI) answers ICMPv6 neighbor discovery and unicast pings on the WAN port — **link is genuinely up and healthy**.
- **Before** an RA was present: user's earlier host capture showed the router emitting DHCPv6 SOLICIT + Router Solicitations and **zero IPv4 DHCPDISCOVER**.
- **After** host served RA (`fd00::`): router went fully silent — no repeat RS, no DHCPv6 SOLICIT, no IPv4 DISCOVER. All DHCPv6 SOLICIT / BOOTP-DHCP broadcast traffic seen in our 60s captures during the flap test came from **our own NetworkManager client on eth1**, not the router.
- dnsmasq leases file holds only our own DUID (`00:01:00:01:32:37:f6:88:52:54:00:40:5c:3c`, QEMU nic). No router lease.
- **No TFTP callback hit** (wan_tftp.log shows only listener restarts).

## Firmware static facts confirmed this session
1. Proc/event table at VA `0x409da8` (file `0x9da8`): entry rows `{func, size, event_id, name_off}`; name block base file `0x181c8`.
   - Row 0 (0x409da8): `func=0x4e4934` `size=0x1d4` `event=0x1200000a` `name_off=0xd63` → **`bpaStartAfterDhcpOk`**.
   - Same event 0x1200000a also registered by `GetSysTimeInSecond` (0x479130), `tSubscriptionSID` (0x55a0f0), and others → **0x1200000a is a shared periodic (second-tick) event family, not specifically "IPv4 DHCP-OK".**
2. `bpaStartAfterDhcpOk` (0x4e4934) control flow (bpaStartAfterDhcpOk.s):
   - clone: `swBpaIsLinkUp()` → if **link ALREADY UP**, return early (**no exec**).
   - else `swGetBpaCfg` + `swGetDhcpcCfg`; apply static WAN `ifconfig %s %s mtu %d` / `ifconfig %s netmask %s` / `echo "nameserver %s" > /tmp/resolv.conf` via `tp_systemEx`; then `fcn.004e46a4` (bpalogin builder from BPA cfg) → `tp_systemEx`.
   - **Conclusion: exec runs only when the BPA link is DOWN at event time.** Attacker wants: event fires while BPA link down.

## Interpretation / open questions
- The router never initiating IPv4 DHCP under bench conditions (factory-reset state, WAN cabled, RA served) is unexplained. Candidate causes:
  a. Saved WAN type is not DHCpc (wantype may have reverted / BPA expects a live cable-ISP link check).
  b. The `swBpaIsLinkUp` gate / a pre-step never lets the IPv4 client start without an upstream.
  c. Event `0x1200000a` never fires because DHCP completion never occurs.
- Unknown whether `udhcpc` runs *at all* post-boot on this unit's WAN — needs a **boot-time capture** from power-on to answer (see next steps).

## Next steps (for the next bench session)
1. **Boot-capture WAN from power-on**: `sudo tcpdump -i eth1 -nn -e -w boot.pcap` + power-cycle router; inspect whether udhcpc (IPv4 DISCOVER) or dhcp6c ever starts.
2. Move cable to LAN1, re-login web, dump `WanCfgRpm.htm` redirect to confirm saved wantype survived.
3. Physical WAN replug (real cable pull/reinsert) to see if the router's link-up state machine fires on *its* side.
4. If DHCP-event path proves unfirable on bench → fall back to `tplink_wr841n_v11_tftp_recovery_report.md` (poisoned-stock TFTP recovery) or dropbear/ART.

## Host-side operational notes (recurring)
- **Launch dnsmasq**: `sh /tmp/routerenum/launch_dnsmasq.sh` (detached sudo). Do **not** use `systemd-run` (its transient unit gets SIGTERM'd) and do **not** `pkill -f dnsmasq` from a shell whose own cmdline contains the word (kills the shell).
- sudo password = `420696`; web Basic auth = `admin:21232f297a57a5a743894a0e4a801fc3` (tokenized URLs, LAN-side only; WAN port is not bridged to br0).
- Listener scripts/logs preserved alongside this file.