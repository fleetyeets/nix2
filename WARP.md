# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build and Deployment Commands

### Apply Configuration
```bash
# Build and apply system configuration (requires sudo)
sudo nixos-rebuild switch

# Test configuration without making it default
sudo nixos-rebuild test

# Build configuration without activating
sudo nixos-rebuild build

# Dry run to see what would change
sudo nixos-rebuild dry-build
```

### Validation
```bash
# Check Nix syntax
nix-instantiate --parse configuration.nix
nix-instantiate --parse modules/*.nix

# Evaluate configuration without building
sudo nixos-rebuild dry-activate
```

### Rollback
```bash
# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## Architecture

### Module Structure
This is a modular NixOS configuration split across specialized files:

- **`configuration.nix`**: Main entry point defining core system settings (bootloader, networking, locale)
- **`hardware-configuration.nix`**: Auto-generated hardware detection (DO NOT EDIT manually)
- **`modules/desktop.nix`**: Wayland compositor setup using Niri with Waybar, SDDM, and desktop utilities
- **`modules/hardware.nix`**: Hardware support (NVIDIA drivers, PipeWire audio, CUPS printing)
- **`modules/packages.nix`**: System packages and user `a` configuration; sets `allowUnfree = true`
- **`modules/programs.nix`**: Pre-configured programs (Firefox, Steam)
- **`modules/virt.nix`**: Virtualization with libvirt/KVM for QEMU VMs
- **`modules/tor-browser-lxc.nix`**: Isolated Tor Browser in Incus container with network restrictions (see `modules/README-TOR-BROWSER.md`)

### Desktop Environment
Uses **Niri** (scrollable-tiling Wayland compositor) instead of traditional DEs. The desktop stack includes:
- Display Manager: SDDM (Wayland)
- Status Bar: Waybar (configured via `/etc/waybar-config.json`)
- App Launcher: Fuzzel
- Notifications: Mako
- Screen Locking: swaylock

Configuration files for Niri and Waybar are deployed system-wide via `environment.etc` from the `modules/` directory.

### Graphics
System configured for **NVIDIA GPU** with proprietary drivers. Uses closed-source driver (`open = false`) with modesetting enabled for Wayland compatibility.

## Key Patterns

### Adding System Packages
Add to `modules/packages.nix` in the `environment.systemPackages` list.

### Adding User-Specific Packages
Add to `modules/packages.nix` under `users.users.a.packages`.

### Hardware Changes
If hardware changes significantly, regenerate `hardware-configuration.nix`:
```bash
sudo nixos-generate-config --show-hardware-config
```
Then manually merge changes (don't overwrite the file directly).

### Desktop Configuration Files
Edit source files in `modules/` (e.g., `niri-config.kdl`, `waybar-config.json`), then rebuild to deploy changes to `/etc/`.

## System Information
- **User**: `a` (wheel, networkmanager groups)
- **State Version**: 25.05
- **Platform**: x86_64-linux (AMD CPU)
- **Timezone**: America/New_York
- **Bootloader**: systemd-boot with EFI
