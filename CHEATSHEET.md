# TL-WR841N v11 — DOOM-via-TFTP-Recovery Cheatsheet

Every command needed to go from "router on the bench" to "DOOM running in a
browser," in the order that actually works. No dead ends, no trial and error —
just copy/paste. Each section says which machine to run it on.

Everything here is also wrapped as subcommands in `./pwn-router.sh`
(`exploit:*` for the base chain, `doom:*` for the demo). Use this cheatsheet
when you want to see what each stage *actually* does, or when something fails
and you need to pick the chain back up by hand. For the fully-automated path,
run `./pwn-router.sh` with no arguments to see the command list.

**Script wrappers for each section:**

| Section | Equivalent `pwn-router.sh` command |
|---|---|
| §1 build DOOM | `./pwn-router.sh doom:build` |
| §2 fetch WAD | `./pwn-router.sh doom:wad` |
| §3 L2 bridge check | `./pwn-router.sh exploit:check-network` |
| §4 flash OpenWrt | `./pwn-router.sh exploit:flash-openwrt` |
| §5 SSH in | `./pwn-router.sh exploit:ssh` |
| §6-7 deploy + launch | `./pwn-router.sh doom:deploy` |
| §7.5 persistence | `./pwn-router.sh doom:persist` |
| §9 revert to stock | `./pwn-router.sh exploit:flash-stock` |
| recovery after reboot wedge | `./pwn-router.sh doom:restart` |

**Legend:** `[HOST]` = your physical machine (hypervisor). `[VM]` = the
attack VM (Kali, with the CP2102 UART adapter passed through). `[ROUTER]` =
typed at the serial console or over SSH, on the device itself.

---

## 0. Prerequisites

**[VM]**
```bash
sudo apt install atftpd iputils-arping picocom screen expect
```

Hardware: CP2102 (or similar) USB-UART adapter wired to the router's debug
header (bottom→top: TX, RX, GND — CP2102 TX→router RX, CP2102 RX→router TX,
GND→GND, **do not connect 3V3**, the router is self-powered).

Confirm the adapter shows up:
```bash
ls -la /dev/ttyUSB0
```

---

## 1. Cross-compile `doomgeneric` for this router's real architecture

The TL-WR841N v11 uses a Qualcomm QCA9533 SoC → OpenWrt's `ar71xx` target →
**big-endian MIPS**. The upstream `doom-on-router` project defaults to a
**little-endian** `mipsel` toolchain (works on MediaTek/Ralink routers, not
this one). Build with the matching big-endian toolchain instead:

**[VM]**
```bash
mkdir -p ~/doom-build && cd ~/doom-build

# Matches the OpenWrt version already proven on this exact board
wget https://archive.openwrt.org/releases/17.01.4/targets/ar71xx/generic/lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz
tar -xf lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz

TC_BIN="$(pwd)/lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64/staging_dir/toolchain-mips_24kc_gcc-5.4.0_musl-1.1.16/bin"
export PATH="$TC_BIN:$PATH"

cd doom/source/doomgeneric   # inside this repo
make -f Makefile.mips clean
make -f Makefile.mips CROSS_COMPILE=mips-openwrt-linux-musl- STATIC_LINKING=1 all
```

Verify it's actually big-endian before wasting a deploy cycle on it:
```bash
file build/doomgeneric
# Expect: ELF 32-bit MSB executable, MIPS ... statically linked
```

No source changes are needed — `i_swap.h` picks up `__BYTE_ORDER__`
automatically, and `i_video.c`'s `cmap_to_fb()` already byte-swaps pixels
under `#ifdef SYS_BIG_ENDIAN`, so the WebSocket color bytes land correctly
either way.

---

## 2. Get the WAD — use the real one, not a trimmed one

DOOM is deployed to `/tmp` (tmpfs, ~13.7M free), **not** `/overlay`
(~236K free) — so the "need a tiny WAD to fit on flash" concern doesn't
actually apply here. Use the full canonical shareware `doom1.wad`
(~4.0MB, SHA1 `5b2e249b9c5133ec987b3ea77596381dc0d6bc1d`): binary (~1MB) +
WAD (~4MB) = ~5MB, comfortably inside the 13.7MB budget.

**[VM]** — easiest path, it's packaged:
```bash
apt-get download doom-wad-shareware
dpkg-deb -x doom-wad-shareware_*.deb ./extracted
cp ./extracted/usr/share/games/doom/doom1.wad .
sha1sum doom1.wad   # confirm: 5b2e249b9c5133ec987b3ea77596381dc0d6bc1d
```

> **Don't use a space-trimmed WAD like `squashware-1lev`** for anything
> beyond a single fixed level. Those variants save space by repointing
> *every* episode map marker (`E1M1`...`E1M9`) at the same underlying map
> data to cut file size — the level-select menu still shows 9 distinct
> names, but every one of them loads identical geometry. Confirmed by
> dumping the WAD directory: all 9 `E1MxX` markers pointed at the exact
> same byte offset. That's the "selected level doesn't match what's shown"
> bug — it's a property of that specific trimmed WAD, not a bug in
> `doomgeneric` or the build. The full WAD has 9 genuinely distinct offsets.

---

## 3. Give the VM real L2 adjacency to the router's LAN

A NAT'd VM NIC (e.g. libvirt's default `virbr0`) **cannot** see the router's
TFTP broadcast — U-Boot's recovery client ARPs on its local segment, it
doesn't route. Bridge your physical NIC (the one the router's cable is
plugged into) into the same bridge your VM's extra NIC uses:

**[HOST]**
```bash
virsh list --all                                   # find your VM's name
virsh domiflist <vmname>                            # find the NIC + its MAC/bridge
```

Then find your REAL physical interface name — **don't guess, and don't use
anything from the `virsh` output above**, that only lists the VM's own
virtual taps:
```bash
ip -br link show
```
Pick by elimination. None of these are it:
- `lo` — loopback
- `virbr0` — the bridge you're joining things *into*, not the thing joining it
- `vnet0`, `vnet1`, ... — **the VM's own virtual taps.** Common mistake:
  running `ip link set vnet1 master virbr0` is a no-op — libvirt already
  put it there itself, and it never touches your actual hardware.
- `veth*`, `docker0`, `br-*` — container networking, unrelated
- `wl*` / `wlan*` — Wi-Fi; wrong one if the router's on an Ethernet cable

What's left — usually `eno1`, `eth0`, or `enp<N>s<N>` — is the real NIC the
router's cable is plugged into. Use that name below (safe — does not touch
that NIC's own IP/routes):
```bash
sudo ip link set eno1 master virbr0
sudo ip link set eno1 up
sudo bridge link show master virbr0
# Expect: eno1 (or whatever yours is), AND vnet0, AND vnet1 — all three
# listed, all "state forwarding". Missing your physical NIC? Redo the
# ip link set above.
```

**If you want your HOST's own browser to reach the router too** (not just
the VM), don't put an address directly on `eno1` once it's a bridge
member — put it on `virbr0` instead. An address left on a bridged *port*
doesn't reliably get ARP replies handed up to the host's own IP stack
(confirmed live: `ping` from the host failed with a **locally-generated**
"Destination Host Unreachable" even though `eno1` had a real DHCP-leased
address from the router's own `dnsmasq` — that lease proved the bridge
itself was fine, the address was just on the wrong interface):
```bash
sudo ip addr del <whatever-address-landed-on-eno1>/24 dev eno1   # optional cleanup
sudo ip addr add 192.168.1.68/24 dev virbr0
```
Then `ping 192.168.1.1` / open `http://192.168.1.1:8000/` from the host
should work. If `eno1` picked up a DHCP lease on its own (the router's
`dnsmasq` will happily hand one out to anything on the LAN), that's a
useful sanity check that the bridge itself is working even while the address
sits on the wrong interface — it just doesn't fix host reachability on its own.

**[VM]** — give the bridged NIC the two addresses U-Boot/OpenWrt expect:
```bash
sudo ip addr add 192.168.0.66/24 dev eth1   # TFTP server address U-Boot is hardcoded to fetch from
sudo ip addr add 192.168.1.66/24 dev eth1   # OpenWrt's post-flash LAN subnet
sudo ip link set eth1 up
```

Sanity check before touching the router:
```bash
arping -I eth1 -c3 192.168.0.1    # should get real replies (the router's factory MAC), not timeouts
```

> If `virsh attach-interface ... direct <nic> --source-mode bridge` is
> tempting (macvtap, no host bridge needed) — it's a nicer design, but we
> hit `--mode` vs `--source-mode` naming differences and an "Invalid source
> mode" rejection across libvirt versions in practice. The host-bridge method
> above is the one that's actually proven to work here; don't burn time on
> macvtap first.

---

## 4. Flash OpenWrt via the unauthenticated U-Boot TFTP recovery path

**[VM]** — stage the firmware and start the TFTP server:
```bash
mkdir -p /tmp/tftp
cp firmwares/openwrt/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin \
   /tmp/tftp/wr841nv11_tp_recovery.bin

# sanity checks the router's U-Boot itself performs:
stat -c%s /tmp/tftp/wr841nv11_tp_recovery.bin      # expect 3932160
xxd -l4 -p /tmp/tftp/wr841nv11_tp_recovery.bin      # expect 01000000 (TP-Link header magic)

sudo pkill atftpd 2>/dev/null
sudo atftpd --daemon --bind-address 192.168.0.66 --verbose /tmp/tftp
ss -ulpn | grep :69                                 # confirm it's bound
```

**[VM]** — arm the UART capture (run in background, it'll sit waiting):
```bash
fuser -k -9 /dev/ttyUSB0 2>/dev/null
stty -F /dev/ttyUSB0 115200 raw -echo
exec 9<>/dev/ttyUSB0
timeout 150 cat <&9 > /tmp/wr841n_flash.txt &
```

**[ROUTER]** — physically, right now:
1. Unplug power
2. Press and **hold** the Reset button
3. While still holding Reset, plug power back in
4. Keep holding for **8–10 seconds**
5. Release

Any cabled port works (WAN or LAN — U-Boot uses whichever has link).

**[VM]** — confirm success from the capture:
```bash
grep -a "Bytes transferred"      /tmp/wr841n_flash.txt   # expect 3932160 (3c0000 hex)
grep -a "product id verify"      /tmp/wr841n_flash.txt   # expect "product id verify sucess!"
grep -a "Erased.*sectors"        /tmp/wr841n_flash.txt   # expect "Erased 60 sectors"
grep -a "Linux version"          /tmp/wr841n_flash.txt   # confirms new LEDE kernel booted
```

---

## 5. SSH root in (legacy KEX required)

LEDE 17.01.4's Dropbear only offers algorithms modern OpenSSH clients
disable by default — force them on. `SSH_OPTS` below is reused by every
later `ssh`/`scp` command in this file (and by `exploit.sh`); full
rationale for each specific flag is in the assessment report's Appendix B
and §5.7:

**[VM]**
```bash
SSH_OPTS=(-o KexAlgorithms=diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa \
         -o Ciphers=aes128-ctr -o MACs=hmac-sha1 -o StrictHostKeyChecking=no \
         -o UserKnownHostsFile=/dev/null)

ssh "${SSH_OPTS[@]}" root@192.168.1.1 'cat /etc/openwrt_release; id'
# password: <empty, just Enter / BatchMode works since root has no password set>
```

(`./pwn-router.sh exploit:ssh` wraps the full `SSH_OPTS` for you — same effect.)

---

## 6. Deploy DOOM

**/overlay only has ~236K free — use `/tmp` (tmpfs, RAM-backed, 13.7M free).**
It won't survive a reboot, but it's the only place with room.

Dropbear has no `sftp-server`, so modern `scp` (which defaults to the SFTP
protocol) fails with `sftp-server: not found`. Force the legacy SCP protocol:

**[VM]**
```bash
SCPOPTS=(-O "${SSH_OPTS[@]}")   # -O = legacy scp protocol, works with Dropbear's plain "scp -t"

scp "${SCPOPTS[@]}" build/doomgeneric          root@192.168.1.1:/tmp/doomgeneric
scp "${SCPOPTS[@]}" doom1.wad                  root@192.168.1.1:/tmp/doom1.wad

ssh "${SSH_OPTS[@]}" root@192.168.1.1 'chmod +x /tmp/doomgeneric; df -h /tmp'
```

---

## 7. Launch it

Busybox ash on this image has **no `nohup` and no `disown`**. That's fine —
since we connect without a pty (`ssh host 'cmd &'`, no `-t`), there's no
controlling terminal to send SIGHUP in the first place, so a plain `&`
survives the SSH session closing:

**[VM]**
```bash
ssh "${SSH_OPTS[@]}" root@192.168.1.1 'cd /tmp && ./doomgeneric >/tmp/doom.log 2>&1 &'
sleep 2
ssh "${SSH_OPTS[@]}" root@192.168.1.1 'ps w | grep doomgeneric; ss -ltn | grep 8000'
```

Then open:
```
http://192.168.1.1:8000/
```
WASD/arrows move, Space fires, E uses, Q/R strafe. Touch controls render
automatically on mobile.

> To reach it from your actual host browser (not just the VM), give your
> host's physical NIC a secondary address in `192.168.1.0/24` too, the same
> way we did for the VM's `eth1` in step 3.

---

## 7.5. Make it persistent (survive a reboot)

`/tmp` is tmpfs — a reboot wipes the binary and WAD, and there's no room
in `/overlay` (236K) to install them to flash (the binary alone is 993K).
The practical fix: have the router **re-fetch and relaunch itself at every
boot** from a host on the LAN, instead of trying to store it on-device.

> **Note:** `/etc/init.d/<name> start` via the standard `#!/bin/sh
> /etc/rc.common` init-script mechanism silently no-ops on this LEDE
> 17.01.4 image — the `start()` function works fine when sourced and
> called directly, but not through rc.common's own dispatcher. Rather than
> chase that, use the simpler, universally-reliable `/etc/rc.local` hook
> instead.

**[VM]** — serve the firmware directory over HTTP so the router can fetch
from it at boot:
```bash
cd doom       # this repo's doom/ directory, where the MIPS binary + WAD live
python3 -m http.server 8080 --bind 192.168.1.66
```
This needs to be running and reachable *every time the router boots* —
leave it up for the duration of the demo (a long-lived background process,
not a one-shot).

**[ROUTER]** — append to `/etc/rc.local` (this file lives in `/overlay`, so
it *does* survive reboots — only `/tmp` is the problem):
```bash
cat >> /etc/rc.local <<'EOF'
SERVER="http://192.168.1.66:8080"
( i=0
  while [ "$i" -lt 30 ]; do
    wget -q --spider "$SERVER/doom1.wad" 2>/dev/null && break
    sleep 1
    i=$((i + 1))
  done
  wget -q -O /tmp/doom1.wad "$SERVER/doom1.wad"
  wget -q -O /tmp/doomgeneric "$SERVER/doomgeneric-mips-be"
  chmod +x /tmp/doomgeneric
  cd /tmp && ./doomgeneric >/tmp/doom.log 2>&1
) &
EOF
```
(Insert it *before* the existing `exit 0` line — easiest done by editing
the file directly rather than blindly appending, since `rc.local` already
ends in `exit 0`.)

Test it without yet another physical power-cycle — a plain SSH reboot
exercises the exact same boot path:
```bash
ssh "${SSH_OPTS[@]}" root@192.168.1.1 reboot
# wait ~25-30s for boot + fetch time, then:
curl -I http://192.168.1.1:8000/   # expect 200 OK, no manual redeploy needed
```

**Don't use a blind `sleep N` here** — a first version of this used
`sleep 5`, which is shorter than how long `br-lan` actually takes to reach
forwarding state (observed ~18-20s in the boot log, see §5's timestamps).
That caused a real, reproducible failure: the `doom1.wad` fetch raced the
network and failed silently (no `set -e`/`&&`, so the script just
continued), while the smaller binary fetch happened to land after the
network came up — leaving `doomgeneric` present but no WAD, and nothing
listening on 8000. The `while` loop above polls with `--spider` until the
server is actually reachable instead of guessing a fixed delay. If the LAN
host isn't reachable at all within 30s, the fetch gives up and DOOM simply
doesn't start that boot — it won't hang or block anything else.

---

## 8. UART interactive shell (optional, for poking around directly)

No login/password on the serial console — Enter drops straight into a root
shell once the OS has finished booting:

**[VM]**
```bash
picocom -b 115200 /dev/ttyUSB0
```
or
```bash
screen /dev/ttyUSB0 115200
```
Press Enter once connected to activate the console. Exit with `Ctrl-A`
`Ctrl-X` (picocom) or `Ctrl-A` `k` `y` (screen).

---

## 9. Revert to stock (optional)

Same mechanism, stock image instead:

**[VM]**
```bash
cp firmwares/stock/wr841n_v11_160325.bin /tmp/tftp/wr841nv11_tp_recovery.bin
sudo pkill atftpd && sudo atftpd --daemon --bind-address 192.168.0.66 --verbose /tmp/tftp
```
Then repeat the same power-off → hold Reset → power-on → hold 8-10s → release
sequence. Router comes back at `192.168.0.1`, `admin`/`admin`.

---

## Troubleshooting quick-reference

| Symptom | Cause | Fix |
|---|---|---|
| `ping` to router times out / `Destination Host Unreachable` immediately | VM only has an on-link route for one subnet; target is on a different one | Add a secondary address in the *other* subnet too (step 3) |
| ARP table shows `FAILED`, interface RX counters not increasing | No real L2 path — VM NIC is on NAT (`virbr0` alone), not bridged to the physical LAN | Bridge the physical NIC in per step 3 |
| `virsh detach-interface ... network --mac ...` → "No interface with MAC address found" | Wrong `<type>` argument — check `virsh domiflist <vm>`, it's probably `bridge` not `network` | Use the type shown in `domiflist` |
| Bridged `vnet1` (or `vnet0`) into `virbr0`, still no L2 adjacency | `vnetN` is the VM's own virtual tap — libvirt already attached it to `virbr0` itself. Bridging it again is a no-op; it never touches real hardware | Find the actual physical NIC via `ip -br link show` on the **host** (not `virsh` output), then bridge *that* — see step 3 |
| `virsh attach-interface ... direct ... --mode bridge` → unknown option / invalid source mode | `virsh` version differences in macvtap flag naming | Skip macvtap, bridge the physical NIC into the existing bridge instead (step 3) |
| TFTP recovery triggers (`is_auto_upload_firmware=1`) but transfer times out | No L2 adjacency, or `atftpd` not bound to `192.168.0.66` | Re-check step 3; `ss -ulpn \| grep :69` |
| `scp`: `ash: /usr/libexec/sftp-server: not found` | Dropbear has no SFTP subsystem; modern `scp` defaults to SFTP | Add `-O` to force legacy SCP protocol |
| `ssh`: `Unable to negotiate...no matching key exchange method found` | Old Dropbear only offers legacy KEX | Use the full `SSH_OPTS` block in step 5 |
| Backgrounded process on the router dies when the SSH session ends | Used `nohup`/`disown` — neither exists in this busybox | Don't request a pty (no `-t`); plain `cmd &` is enough |
| `sudo: a password is required` from an automated/non-interactive shell | No TTY for the password prompt | Run the `sudo` command yourself in a real terminal |
| Level-select menu shows 9 levels, but every level you warp to looks identical | Deployed a space-trimmed WAD (e.g. `squashware-1lev`) that aliases all `E1MxX` map markers to the same underlying data | Use the full `doom1.wad` (step 2) — `/tmp` has room, there's no need to trim |
| `/etc/init.d/<name> start` exits 0 but does nothing (no files fetched, nothing launched) | LEDE 17.01.4's `rc.common` dispatcher silently no-ops for this script; the function itself is fine (`. /etc/init.d/<name>; start` works) | Use `/etc/rc.local` instead (§7.5) — skip rc.common entirely |
| DOOM doesn't come back after a reboot | The LAN host serving the firmware over HTTP (§7.5) wasn't running/reachable at boot | Make sure `python3 -m http.server` on the VM is left running for the duration of the demo |
| `curl`/browser gets connection refused on :8000, but `ping` to the router works fine and `ps` shows `doomgeneric` running (even busy/`R` state) | Confirmed live: a stale/dropped browser connection (e.g. an old tab left open) wedges mongoose's single-threaded event loop into retrying a write that will never drain, instead of servicing the listen socket — `netstat -ltn` on the router shows 8000 genuinely absent despite the process being alive | **Auto-recovers within ~30s** — the supervisor (`/tmp/doom_watch.sh`, installed by `doom:deploy` / `doom:persist`) polls :8000 every 30s and kill-respawns on failure. Force immediate recovery with `./pwn-router.sh doom:restart` (kills `doomgeneric`; the supervisor respawns it in ~2s). |
| DOOM crashes or is killed manually (e.g. by another admin via SSH) | Game process exits; without a supervisor there'd be nothing to relaunch it | **Auto-respawns within ~2s** — the supervisor `wait`s on the game pid and relaunches as soon as `wait` returns. See `./pwn-router.sh doom:logs` for the `[watch]` entries confirming the respawn. |
| Ping/curl work with no interface forced, but fail when bound to a *specific* interface (`--interface`/`-I`) | Once the host's physical NIC is bridged into `virbr0`, both the VM's NICs end up on the same merged L2 segment — ARP may simply not have resolved yet on the one you forced | Flush and let it re-resolve: `ip neigh flush all`, retry without forcing an interface, or ping once first to warm the ARP entry |
| **[HOST]** `ping`/`curl` to the router fails with "Destination Host Unreachable" / "No route to host" — a **locally-generated** error, not a timeout — even though `eno1` has a real address (maybe even DHCP-leased from the router's own `dnsmasq`) | The address is sitting on `eno1` itself, but `eno1` is now a bridge **member** (`master virbr0`). ARP replies arriving on a bridged port don't reliably get handed up to the host's own IP stack — the DHCP lease succeeding is a red herring that the *bridge* is fine, it just doesn't make the port usable as a direct L3 interface | Move the address to the bridge device instead: `sudo ip addr add 192.168.1.68/24 dev virbr0` (leave `eno1` itself address-free) |
