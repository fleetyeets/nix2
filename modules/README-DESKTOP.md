# Desktop Environment Configuration

This NixOS configuration supports both GNOME and Niri desktop environments.

## Current Setup

Both desktop environments are configured to work together:
- **GNOME** (modules/gnome.nix) - Full-featured desktop with GDM display manager
- **Niri** (modules/desktop.nix) - Scrollable-tiling Wayland compositor

## Switching Between Desktops

At the GDM login screen, you can select which desktop environment to use:
1. Click your username
2. Look for the gear icon (⚙) at the bottom right
3. Select either "GNOME" or "Niri"

## Configuration Details

### Resolved Conflicts

The following conflicts have been addressed:

1. **Display Manager**: GDM (from gnome.nix) is used as the primary display manager
   - SDDM in desktop.nix is disabled
   
2. **X Server**: Enabled in gnome.nix
   - desktop.nix only enables XWayland support
   
3. **XDG Portal**: Configured in gnome.nix with GNOME-specific portals
   - desktop.nix has wlr portal commented out

### Using Only GNOME

To use only GNOME, comment out in `configuration.nix`:
```nix
# ./modules/desktop.nix
```

### Using Only Niri

To use only Niri, in `modules/desktop.nix`:
1. Set `services.displayManager.sddm.enable = true;`
2. Uncomment the `xdg.portal` section
3. Comment out `./modules/gnome.nix` in `configuration.nix`

## Included Features

### GNOME (modules/gnome.nix)
- Full GNOME desktop environment with Wayland
- GDM display manager
- Popular extensions (Dash to Dock, Blur My Shell, Vitals, etc.)
- Core apps (Nautilus, Calculator, Calendar, System Monitor)
- PipeWire audio
- Printing support (CUPS)
- Flatpak support

### Niri (modules/desktop.nix)
- Niri scrollable-tiling compositor
- Waybar status bar
- Fuzzel launcher
- Mako notifications
- Foot terminal
- Screenshot tools (grim, slurp)
- Thunar file manager

## Notes

- Both desktop environments can coexist and be selected at login
- Niri tools (waybar, fuzzel, etc.) are available in GNOME if needed
- Power profiles daemon is enabled for GNOME (conflicts with TLP if used)
