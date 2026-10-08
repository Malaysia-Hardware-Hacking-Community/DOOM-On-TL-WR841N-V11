#!/usr/bin/env bash
# =============================================================================
# TP-Link TL-WR841N v11 — Serve a firmware image via TFTP for U-Boot recovery.
#
# Stages the chosen image into /tmp/tftp as wr841nv11_tp_recovery.bin and runs
# atftpd bound to 192.168.0.66:69. Then trigger recovery on the router
# (power-cycle with Reset held 8-10s) — U-Boot fetches the staged payload.
#
# Usage:
#   ./serve_fw_tftp.sh [IMAGE]         # serve any .bin (default = OpenWrt factory)
#   ./serve_fw_tftp.sh firmwares/stock/wr841n_v11_160325.bin
#
# Stop the server afterwards with:  pkill atftpd
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RECOVERY_IP="192.168.0.66"
RECOVERY_FILENAME="wr841nv11_tp_recovery.bin"
FIRMWARE_DIR="/tmp/tftp"
DEFAULT_FW="${SCRIPT_DIR}/firmwares/openwrt/lede-17.01.4-ar71xx-generic-tl-wr841-v11-squashfs-factory.bin"

MODE="${1:-}"
IMAGE="${2:-$DEFAULT_FW}"

info() { echo -e "\033[0;32m[+]\033[0m $*"; }
fail() { echo -e "\033[0;31m[-]\033[0m $*"; exit 1; }

case "$MODE" in
    ""|serve)
        [[ -f "$IMAGE" ]] || fail "Image not found: $IMAGE"
        command -v atftpd >/dev/null || fail "atftpd not installed"
        mkdir -p "$FIRMWARE_DIR"
        cp "$IMAGE" "$FIRMWARE_DIR/$RECOVERY_FILENAME"
        pkill atftpd 2>/dev/null || true
        sleep 1
        atftpd --daemon --bind-address "$RECOVERY_IP" --verbose "$FIRMWARE_DIR"
        sleep 1
        ss -ulpn | grep -q ":69" || fail "atftpd failed on ${RECOVERY_IP}:69"
        echo ""
        info "Serving: $IMAGE"
        info "  as:      $FIRMWARE_DIR/$RECOVERY_FILENAME"
        info "  bound:   ${RECOVERY_IP}:69"
        info "  size:    $(stat -c%s "$FIRMWARE_DIR/$RECOVERY_FILENAME") bytes"
        info "  sha1:    $(sha1sum "$FIRMWARE_DIR/$RECOVERY_FILENAME" | cut -d' ' -f1)"
        echo ""
        info "Now power-cycle the router holding Reset 8-10s to trigger recovery."
        info "Stop later with: pkill atftpd"
        ;;
    stop)
        pkill atftpd 2>/dev/null && info "atftpd stopped" || info "atftpd not running"
        ;;
    status)
        if ss -ulpn | grep -q ":69"; then
            info "atftpd RUNNING:"
            ss -ulpn | grep ":69"
        else
            info "atftpd NOT running"
        fi
        ;;
    *)
        fail "Usage: $0 [serve IMAGE|stop|status]"
        ;;
esac