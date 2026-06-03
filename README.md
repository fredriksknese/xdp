# xdp

A small shell utility for discovering switch and port information by capturing
CDP (Cisco Discovery Protocol) and LLDP (Link Layer Discovery Protocol) frames
on a network interface.

## Installation

```bash
# Installs to /usr/local by default (re-runs with sudo if needed)
./install.sh

# Or choose a prefix
PREFIX=/usr ./install.sh
```

This copies the script to `$PREFIX/bin/capture_cdp_lldp` and the man page to
`$PREFIX/share/man/man1/`, so you can run `capture_cdp_lldp` from anywhere and
read `man capture_cdp_lldp`.

## `capture_cdp_lldp.sh`

Listens on a network interface for the first CDP or LLDP advertisement and
prints its full decoded contents (switch name, port ID, VLAN, etc.).

### Usage

```bash
# Auto-pick the first connected, non-loopback interface
./capture_cdp_lldp.sh

# Interactively select an interface from a menu
./capture_cdp_lldp.sh -s

# Specify an interface explicitly
./capture_cdp_lldp.sh eth0
```

The script waits for a single CDP/LLDP packet, decodes it verbosely, and exits.
These frames are typically broadcast every 30–60 seconds, so it may take up to a
minute to see output.

### Requirements

- [`tshark`](https://www.wireshark.org/docs/man-pages/tshark.html) (Wireshark CLI)
- `iproute2` (`ip`)

Packet capture usually needs elevated privileges. If the interface can't be
opened as the current user, the script automatically re-runs itself with `sudo`.
