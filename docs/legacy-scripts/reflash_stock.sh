#!/usr/bin/env bash
# =============================================================================
# TP-Link TL-WR841N v11 — Reflash Stock Firmware via U-Boot TFTP Recovery
# Restore the device to factory state (wr841n_v11_160325) for a fresh test run.
#
# Use this to reset the router between test iterations. It is the inverse of
# tplink_wr841n_v11_root_shell_poc.sh: same trigger mechanism (reset-hold
# during power-on -> is_auto_upload_firmware=1 -> U-Boot TFTP fetch), but it
# serves the STOCK image instead of the OpenWrt/LEDE factory image.
#
# Companion scripts in this directory:
#   tplink_wr841n_v11_root_shell_poc.sh  full attack PoC (UART->TFTP->SSH root)
#   serve_fw_tftp.sh                     serve a chosen firmware image via TFTP
#   ssh_root.sh                          OpenWrt/LEDE SSH with legacy KEX
#   capture_uart.sh                      boot/recovery log capture via UART
#
# Firmware on disk (moved into this report bundle):
#   firmwares/stock/wr841n_v11_160325.bin
#   firmwares/openwrt/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin
#
# KNOWN REQUIREMENT (learned in the field): the router MUST share L2 with this
# host. If the bridge is missing, U-Boot triggers recovery but TFTP times out
# and the router boots whatever is in flash. Step 3.5 detects this BEFORE you
# power-cycle. There are TWO machines involved — do NOT mix up the terminals:
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ HOST  (physical machine the router is cabled to, e.g. laptop/desktop)     │
# ├───────────────────────────────────────────────────────────────────────────┤
# │ 1. Find which NIC the router is on (look for a non-vnet, non-lo NIC with  │
# │    link):                                                                 │
# │       ip -br link show            # expect e.g. eno1 UP                    │
# │ 2. Confirm the VM bridge EXISTS and note what's already on it:            │
# │       sudo bridge link show master virbr0   # pre-action: vnet0 only      │
# │ 3. Enslave the router's NIC to the VM's bridge (THE fix from the field):  │
# │       sudo ip link set eno1 master virbr0    # 'eno1' = your NIC name     │
# │       sudo ip link set eno1 up                                          │
# │ 4. VERIFY the router + VM now share L2:                                  │
# │       sudo bridge link show master virbr0   # expect BOTH eno1 AND vnet0 │
# │    (Both must show 'state forwarding'.)                                   │
# └───────────────────────────────────────────────────────────────────────────┘
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ VM    (this Kali VM, where this script runs and the CP2102 is attached)   │
# ├───────────────────────────────────────────────────────────────────────────┤
# │ 1. Recovery IP on the bridge-facing NIC (script does this, sudo prompt):  │
# │       ip -br addr show eth0      # expect 192.168.0.66/24 present         │
# │ 2. TFTP server + payload (script does this):                              │
# │       ss -ulpn | grep :69        # expect atftpd bound to 192.168.0.66    │
# │ 3. UART capture (script arms; CP2102 = /dev/ttyUSB0 115200).              │
# └───────────────────────────────────────────────────────────────────────────┘
#
# Quick sanity the user can run to prove L2 end-to-end before power-cycling:
#   HOST:  ping -c2 192.168.0.1            # router's stock LAN IP (if booted)
#   VM:    arping -I eth0 -c2 192.168.0.1  # true L2 proof, needs router power
#
# Recovery specifics (observed via UART capture):
#   server IP           192.168.0.66   (this host)
#   client IP           192.168.0.86   (U-Boot, is_auto_upload_firmware=1)
#   U-Boot MAC          ba:be:fa:ce:08:41
#   filename            wr841nv11_tp_recovery.bin
#   transfer check      "Bytes transferred = 4063744 (3e0200 hex)"
#   flash check         "Firmware recovery: product id verify sucess!" + "Erased 60 sectors"
#   check            the ONLY validation U-Boot performs is the TP-Link
#                     product-ID string in the image header (no crypto).
#
# Tested on: Kali Linux VM with libvirt bridged networking (virbr0 + eno1)
# Report:    tplink_wr841n_v11_tftp_recovery_report.md (Appendix A)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── CONFIG ──────────────────────────────────────────────────────────────────
UART="/dev/ttyUSB0"
BAUD=115200
RECOVERY_IP="192.168.0.66"
RECOVERY_CLIENT_IP="192.168.0.86"
ROUTER_UBOOT_MAC="ba:be:fa:ce:08:41"
STOCK_LAN_IP="192.168.0.1"
LEDE_LAN_IP="192.168.1.1"
RECOVERY_FILENAME="wr841nv11_tp_recovery.bin"
FIRMWARE_DIR="/tmp/tftp"
STOCK_FW="${SCRIPT_DIR}/firmwares/stock/wr841n_v11_160325.bin"
CAPTURE_FILE="/tmp/wr841n_reflash_stock.txt"

# ── COLORS ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[0;33m'
CYN='\033[0;36m'
RST='\033[0m'

info()  { echo -e "${GRN}[+]${RST} $*"; }
warn()  { echo -e "${YEL}[!]${RST} $*"; }
fail()  { echo -e "${RED}[-]${RST} $*"; exit 1; }
step()  { echo -e "\n${CYN}═══ STEP $1: $2 ═══${RST}"; }

# =============================================================================
step 1 "Check prerequisites"
# =============================================================================

[[ -e "$UART" ]]            || fail "Missing $UART — is the CP2102 plugged in?"
[[ -f "$STOCK_FW" ]]        || fail "Missing stock firmware: $STOCK_FW"
command -v atftpd >/dev/null || fail "atftpd not installed (apt install atftpd)"
command -v arping >/dev/null || warn "arping not installed — L2 pre-check degraded (apt install iputils-arping)"

STOCK_SIZE=$(stat -c%s "$STOCK_FW")
STOCK_SHA1=$(sha1sum "$STOCK_FW" | cut -d' ' -f1)
info "Stock firmware: $STOCK_FW"
info "  Size: $STOCK_SIZE bytes"
info "  SHA1: $STOCK_SHA1"

# =============================================================================
step 2 "Wire UART (read-only safety)"
# =============================================================================

info "CP2102 wiring (do NOT connect 3.3V — router is self-powered):"
info "  CP2102 TX  →  Router RX"
info "  CP2102 RX  →  Router TX"
info "  CP2102 GND →  Router GND"
info "  CP2102 VCC →  NOT CONNECTED"

# =============================================================================
step 3 "Configure recovery IP on the bridge-facing interface"
# =============================================================================

# U-Boot TFTPs to 192.168.0.66. The router sits on virbr0 (host bridges the
# physical NIC there); inside the guest that bridge appears as a virtual NIC
# (typically eth0). Pick the interface that carries the default route and put
# the recovery IP on it. Needs sudo if not already configured.
IFACE="${RECOVERY_IFACE:-}"
if [[ -z "$IFACE" ]]; then
    IFACE="$(ip -4 route show default | awk '{print $NF; exit}')"
    [[ -n "$IFACE" && "$IFACE" != "static" ]] || IFACE="eth0"
fi
info "Using interface: $IFACE"

if ip -4 addr show dev "$IFACE" 2>/dev/null | grep -q "inet ${RECOVERY_IP}/"; then
    info "Recovery IP ${RECOVERY_IP} already configured on $IFACE ✓"
else
    info "Adding ${RECOVERY_IP}/24 to ${IFACE} (sudo — will prompt for password)..."
    sudo -v
    sudo ip addr add "${RECOVERY_IP}/24" dev "$IFACE"
    sudo ip link set "$IFACE" up
    ip -4 addr show dev "$IFACE" | grep -q "inet ${RECOVERY_IP}/" \
        || fail "Recovery IP verification failed on $IFACE"
    info "Configured ${RECOVERY_IP}/24 on $IFACE ✓"
fi

# =============================================================================
step 3.5 "Verify L2 connectivity to the router (bridge sanity check)"
# =============================================================================
# The #1 field failure: the recovery triggers (is_auto_upload_firmware=1) but
# TFTP times out because the router shares no L2 with this VM (the host never
# bridged the router's physical NIC into virbr0). Detect it up-front.

L2_OK=""
if command -v arping >/dev/null 2>&1; then
    # Cache sudo first — arping needs root and we must not use sudo -n cold.
    sudo -v 2>/dev/null || fail "sudo password required for the L2 check"
    # ARP-ping the router's known MAC. Only succeeds if the router actually
    # responds AND its frames reach this host — a true end-to-end L2 proof.
    if sudo -n arping -I "$IFACE" -c 2 -w 3 "$STOCK_LAN_IP" >/dev/null 2>&1 || \
       sudo -n arping -I "$IFACE" -c 2 -w 3 "$RECOVERY_CLIENT_IP" >/dev/null 2>&1; then
        L2_OK=1
        info "Router responded on L2 ($STOCK_LAN_IP / $RECOVERY_CLIENT_IP) ✓"
    fi
else
    # Degraded probe (no arping): try ICMP to stock + LEDE + recovery IPs.
    for ip in "$STOCK_LAN_IP" "$LEDE_LAN_IP" "$RECOVERY_CLIENT_IP"; do
        if ping -I "$IFACE" -c 1 -W 1 "$ip" >/dev/null 2>&1; then
            L2_OK=1
            info "Router reachable on $ip over $IFACE ✓"
            break
        fi
    done
fi

if [[ -z "$L2_OK" ]]; then
    warn "Router did NOT respond on L2 from $IFACE."
    warn "If recovery triggers but TFTP times out, the bridge is broken."
    warn ""
    warn " ── HOST (physical machine, the router's cable is here) ──"
    warn "   1. ip -br link show        # find the router NIC, e.g. eno1"
    warn "   2. sudo ip link set <nic> master virbr0"
    warn "   3. sudo ip link set <nic> up"
    warn "   4. sudo bridge link show master virbr0"
    warn "      # VERIFY: list shows BOTH your NIC AND vnet0, both 'state forwarding'"
    warn ""
    warn " ── VM (this Kali) ──"
    warn "   1. ip -br addr show eth0   # VERIFY: 192.168.0.66/24 present"
    warn "   2. ss -ulpn | grep :69     # VERIFY: atftpd bound to 192.168.0.66"
    warn "   3. Confirm a booted router answers: ping -c2 192.168.0.1"
    warn ""
    read -r -p "Continue anyway? [y/N] " ans
    [[ "${ans,,}" == "y" ]] || fail "Aborted — fix the bridge first (see above)."
fi

# =============================================================================
step 4 "Stage stock firmware + start TFTP server"
# =============================================================================

mkdir -p "$FIRMWARE_DIR"
cp "$STOCK_FW" "$FIRMWARE_DIR/$RECOVERY_FILENAME"

# Restart atftpd serving the new payload
pkill atftpd 2>/dev/null || true
sleep 1
atftpd --daemon --bind-address "$RECOVERY_IP" --verbose "$FIRMWARE_DIR"

sleep 1
if ss -ulpn | grep -q ":69"; then
    info "atftpd running, bound to ${RECOVERY_IP}:69 ✓"
else
    fail "atftpd failed to start — check port 69 availability"
fi

info "Payload ready: $FIRMWARE_DIR/$RECOVERY_FILENAME ($(stat -c%s "$FIRMWARE_DIR/$RECOVERY_FILENAME") bytes)"

# =============================================================================
step 5 "Arm UART capture + trigger TFTP recovery"
# =============================================================================

info "Arming UART capture (120s window)..."
(fuser -k -9 "$UART" 2>/dev/null || true; sleep 1
 stty -F "$UART" "$BAUD" raw -echo
 exec 9<>"$UART"
 timeout 120 cat <&9 > "$CAPTURE_FILE") &
CAPTURE_PID=$!
sleep 2

info "UART capture armed (PID $CAPTURE_PID → $CAPTURE_FILE)"
info ""
info "═══════════════════════════════════════════════════════════════════"
info "  NOW DO THE FOLLOWING ON THE ROUTER:"
info ""
info "  1. Unplug the router's power"
info "  2. Press and HOLD the Reset button"
info "  3. While holding Reset, plug power back in"
info "  4. KEEP HOLDING Reset for at least 8-10 seconds"
info "  5. Release Reset"
info ""
info "  Router fetches ${RECOVERY_FILENAME} from ${RECOVERY_IP}"
info "   (recovery works on ANY cabled port — LAN or WAN)"
info "═══════════════════════════════════════════════════════════════════"
info ""
info "Waiting up to 120s for TFTP transfer and flash..."

wait $CAPTURE_PID 2>/dev/null || true

# =============================================================================
step 6 "Verify flash results"
# =============================================================================
# The capture contains binary/control bytes; always grep with -a.

if grep -qa "is_auto_upload_firmware=1" "$CAPTURE_FILE" 2>/dev/null; then
    info "Recovery mode triggered (is_auto_upload_firmware=1) ✓"
else
    warn "Recovery mode NOT confirmed — may need to retry (hold reset longer)"
fi

if grep -qa "Bytes transferred" "$CAPTURE_FILE" 2>/dev/null; then
    BYTES=$(grep -a "Bytes transferred" "$CAPTURE_FILE" | grep -aoP '0x[0-9a-f]+' | tail -1)
    BYTES=${BYTES:-"(unknown)"}
    info "TFTP transfer complete: $BYTES bytes ✓"
else
    warn "TFTP transfer NOT seen in capture."
    if grep -qa "Retry count exceeded" "$CAPTURE_FILE" 2>/dev/null; then
        warn "  U-Boot reports: 'Retry count exceeded' (TFTP timeout)."
    fi

    # Was the router even heard on L2? If not, this is the host-bridge bug,
    # NOT a cable/port problem (recovery triggers on any port).
    if ip neigh show dev "$IFACE" | grep -q "$ROUTER_UBOOT_MAC\|$RECOVERY_CLIENT_IP"; then
        warn "  Router MAC was heard on $IFACE — L2 OK, investigate TFTP server side"
        warn "  (atftpd alive? bind-address=${RECOVERY_IP}? payload in ${FIRMWARE_DIR}?)"
    else
        warn "  Router MAC NOT heard on $IFACE — L2 to router is broken (host bridge)."
        warn "  ── HOST: sudo ip link set <nic> master virbr0 && sudo ip link set <nic> up"
        warn "  ── HOST VERIFY: sudo bridge link show master virbr0 (expect <nic> + vnet0)"
        warn "  ── VM VERIFY: ip -br addr show eth0 (expect 192.168.0.66/24)"
        warn "  Then re-run this script."
    fi
fi

if grep -qa "product id verify" "$CAPTURE_FILE" 2>/dev/null; then
    info "TP-Link product ID verified by U-Boot ✓"
fi
if grep -qa "Erased.*sectors" "$CAPTURE_FILE" 2>/dev/null; then
    ERASED=$(grep -a "Erased" "$CAPTURE_FILE" | head -1)
    info "Flash erase confirmed: $ERASED ✓"
fi

# =============================================================================
step 7 "Verify stock firmware boots"
# =============================================================================

info "Checking capture for stock TP-Link boot..."
if grep -qa "Linux version 2.6.31" "$CAPTURE_FILE" 2>/dev/null; then
    info "Stock kernel detected (Linux 2.6.31, #13 Mar 25 2016) ✓"
elif grep -qa "Loading modules backported" "$CAPTURE_FILE" 2>/dev/null; then
    warn "LEDE/OpenWrt kernel detected — flash did NOT take (retry recovery)."
else
    warn "No kernel banner captured — power-cycle the router manually."
fi

info ""
info "═══════════════════════════════════════════════════════════════════"
info "  AFTER STOCK REWRITE:"
info "    LAN IP:    192.168.0.1"
info "    Login:     admin / admin"
info "    Web:       http://192.168.0.1  (browser http://tplinkwifi.net)"
info ""
info "  To re-run the attack from this fresh state:"
info "    ./tplink_wr841n_v11_root_shell_poc.sh"
info "═══════════════════════════════════════════════════════════════════"