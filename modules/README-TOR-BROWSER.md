# Isolated Tor Browser with Incus

This module provides a completely isolated Tor Browser running in an Incus container with strict network controls.

## Features

- **Complete Isolation**: Tor Browser runs in a separate Incus container, isolated from the host system
- **Network Restrictions**: Firewall rules ensure only Tor network traffic (ports 9001, 9030, 9050, 9051) can pass through
- **Resource Limits**: Container is limited to 2 CPU cores and 2GB RAM
- **Security Hardening**: 
  - No privileged operations
  - No container nesting
  - Syscall interception enabled
  - Non-root user inside container
- **Native Integration**: Launches like any other application from your app launcher (Fuzzel)

## Architecture

```
Host System (NixOS)
    |
    ├─ Incus (virtualisation.incus)
    |   |
    |   └─ tor-browser container (Debian 12)
    |       ├─ Tor Browser Bundle
    |       ├─ Tor daemon (configured for Tor-only traffic)
    |       └─ Display forwarding (X11/Wayland)
    |
    └─ Firewall (iptables)
        └─ TOR_CONTAINER chain (restricts to Tor ports only)
```

## Installation

1. Add the module to your `configuration.nix`:

```nix
imports = [
  # ... other modules
  ./modules/tor-browser-lxc.nix
];
```

2. Rebuild your system:

```bash
sudo nixos-rebuild switch
```

3. First launch will automatically create and configure the container:

```bash
tor-browser-isolated
```

Or launch from Fuzzel (Super+D) by typing "Tor Browser"

## Usage

### Launch Tor Browser
```bash
tor-browser-isolated
```

### Manage Container

```bash
# Check container status
incus list

# Stop container
incus stop tor-browser

# Start container
incus start tor-browser

# Get shell in container (for debugging)
incus exec tor-browser -- sudo -u user bash

# View container logs
incus info tor-browser --show-log
```

### Remove Container

```bash
# Stop and delete
incus stop tor-browser
incus delete tor-browser

# Next launch will recreate it
```

## Network Isolation

The container is restricted by nftables rules to ONLY communicate via Tor:

- **Allowed Ports**:
  - 9001: Tor directory port
  - 9030: Tor directory port (alternative)
  - 9050: Tor SOCKS proxy
  - 9051: Tor control port
  - 53: DNS (for initial setup only)

- **Blocked**: All other outbound connections

This means:
- ✅ All browser traffic goes through Tor
- ✅ No direct internet access possible
- ✅ DNS queries routed through Tor
- ❌ Cannot bypass Tor network
- ❌ Cannot access local network resources

## Security Considerations

### What's Protected
- Browser fingerprinting isolated from host
- All traffic forced through Tor
- Container cannot access host filesystem (except display socket)
- Resource limits prevent container from consuming all system resources
- No persistent data leakage to host

### What's NOT Protected
- Display server (X11/Wayland) is shared - theoretically could be exploited
- If you need maximum security, consider running on a dedicated machine
- Container shares kernel with host (not a full VM)

### Improving Security Further

For maximum security, you could:

1. **Use separate X server**: Run Xephyr or nested Wayland compositor
2. **Add AppArmor/SELinux**: Additional mandatory access controls
3. **Disable clipboard sharing**: Block wl-clipboard access
4. **Use full VM instead**: Trade performance for complete isolation

## Troubleshooting

### Container won't start
```bash
# Check Incus status
systemctl status incus

# Reinitialize Incus
incus admin init
```

### Display not working
```bash
# Ensure xhost allows local connections
xhost +local:

# Check display socket exists
echo $DISPLAY
ls -la /tmp/.X11-unix/
```

### Network not working in container
```bash
# Check firewall rules
sudo nft list table inet tor-isolation

# Check container can reach Tor network
incus exec tor-browser -- curl --socks5 localhost:9150 https://check.torproject.org
```

### Tor Browser won't launch
```bash
# Get shell in container
incus exec tor-browser -- sudo -u user bash

# Try launching manually
cd ~/tor-browser/Browser
./start-tor-browser
```

## File Locations

- Main module: `modules/tor-browser-lxc.nix`
- Setup script: `modules/tor-browser-setup.sh`
- Desktop entry: `/etc/xdg/applications/tor-browser-isolated.desktop`
- Launch command: `/run/current-system/sw/bin/tor-browser-isolated`
- Container data: `/var/lib/incus/containers/tor-browser/`

## Updates

To update Tor Browser:

1. Edit `tor-browser-setup.sh` and change `TOR_VERSION`
2. Rebuild system: `sudo nixos-rebuild switch`
3. Delete and recreate container:
   ```bash
   incus stop tor-browser
   incus delete tor-browser
   tor-browser-isolated  # Recreates with new version
   ```
