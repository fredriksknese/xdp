#!/usr/bin/env bash
set -euo pipefail

# Install capture_cdp_lldp and its man page.
# Honours PREFIX (default /usr/local) and DESTDIR for staged installs.
# Re-runs itself with sudo when the target isn't writable.

PREFIX="${PREFIX:-/usr/local}"
DESTDIR="${DESTDIR:-}"

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$DESTDIR$PREFIX/bin"
MAN_DIR="$DESTDIR$PREFIX/share/man/man1"

# Elevate for real (non-staged) installs when the prefix isn't writable.
if [[ -z "$DESTDIR" && ! -w "$PREFIX" && $EUID -ne 0 ]]; then
    echo "Install requires elevated privileges; re-running with sudo..." >&2
    exec sudo -E PREFIX="$PREFIX" bash "$SRC_DIR/install.sh" "$@"
fi

install -Dm755 "$SRC_DIR/capture_cdp_lldp.sh" "$BIN_DIR/capture_cdp_lldp"
install -Dm644 "$SRC_DIR/capture_cdp_lldp.1" "$MAN_DIR/capture_cdp_lldp.1"

# Refresh the man database if available (non-fatal).
command -v mandb >/dev/null 2>&1 && [[ -z "$DESTDIR" ]] && mandb -q >/dev/null 2>&1 || true

echo "Installed:"
echo "  $BIN_DIR/capture_cdp_lldp"
echo "  $MAN_DIR/capture_cdp_lldp.1"
