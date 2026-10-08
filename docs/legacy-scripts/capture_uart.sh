#!/usr/bin/env bash
# =============================================================================
# TP-Link TL-WR841N v11 — Capture serial output via UART (CP2102 @ 115200).
#
# Use to observe a boot, a U-Boot recovery run, or the stock/LEDE boot banner.
# Output is saved (append mode) to the file given as the optional argument.
#
# Usage:
#   ./capture_uart.sh                  # capture to /tmp/uart_capture.txt
#   ./capture_uart.sh /tmp/boot1.txt   # capture to a specific file
#
# Cancel with Ctrl-C. The router must be powered on (or power-cycled) while
# this is listening to catch the boot banner.
# =============================================================================

set -euo pipefail

UART="/dev/ttyUSB0"
BAUD=115200
OUT="${1:-/tmp/uart_capture.txt}"

[[ -e "$UART" ]] || { echo "[-] Missing $UART — CP2102 plugged in?"; exit 1; }

fuser -k -9 "$UART" 2>/dev/null || true
sleep 1
stty -F "$UART" "$BAUD" raw -echo

echo "[+] Capturing $UART @ $BAUD → $OUT   (Ctrl-C to stop)"
exec 9<>"$UART"
cat -v <&9 | tee "$OUT"