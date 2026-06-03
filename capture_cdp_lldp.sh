#!/usr/bin/env bash
set -euo pipefail

IFACE=""

# -s: interactively select the interface from a menu.
if [[ "${1:-}" == "-s" ]]; then
    mapfile -t IFACES < <(ip -o link show up | awk -F': ' '$2 != "lo" {print $2}')
    if [[ ${#IFACES[@]} -eq 0 ]]; then
        echo "No non-loopback interfaces found." >&2
        exit 1
    fi
    echo "Select an interface:"
    select choice in "${IFACES[@]}"; do
        if [[ -n "$choice" ]]; then
            IFACE="$choice"
            break
        fi
        echo "Invalid selection, try again."
    done
else
    # Pick the first connected (carrier present), non-loopback interface if none supplied.
    # LOWER_UP in the flags means the link has carrier; exclude loopback.
    IFACE="${1:-$(ip -o link show up | awk -F': ' '$2 != "lo" && $0 ~ /LOWER_UP/ {print $2; exit}')}"
fi

if [[ -z "$IFACE" ]]; then
    echo "No connected non-loopback interface found." >&2
    exit 1
fi

echo "Listening for CDP/LLDP on interface: $IFACE"
echo "Waiting for first packet..."
echo

TSHARK_CMD=(
    tshark -i "$IFACE"
    -f "ether proto 0x88cc or ether dst 01:00:0c:cc:cc:cc"
    -c 1
    -V
)

# Probe whether we can open the interface without elevated privileges.
# A permission error from dumpcap surfaces immediately; if the probe instead
# blocks waiting for traffic, we have capture rights and kill it after a moment.
capture_needs_root() {
    local err
    err=$(timeout 1 tshark -i "$IFACE" -c 1 2>&1 >/dev/null || true)
    grep -qiE "permission|are you root|not allowed|couldn't run|lack of" <<<"$err"
}

if [[ $EUID -ne 0 ]] && capture_needs_root; then
    echo "Capture requires elevated privileges; re-running with sudo..." >&2
    exec sudo "${TSHARK_CMD[@]}"
fi

exec "${TSHARK_CMD[@]}"
