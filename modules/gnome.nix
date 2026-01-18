{ config, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  # GDM (GNOME Display Manager)
  # Note: Disabled by default to avoid conflict with SDDM from desktop.nix
  # To use GDM instead of SDDM, enable this and disable SDDM in desktop.nix
  services.displayManager.gdm = {
    enable = false;
    wayland = true;
  };

  # Essential GNOME services
  services.gnome = {
    gnome-keyring.enable = true;
    gnome-settings-daemon.enable = true;
    gnome-online-accounts.enable = true;
    localsearch.enable = true;  # Renamed from tracker-miners
    tinysparql.enable = true;  # Renamed from tracker
    sushi.enable = true;  # File previewer
  };

  # Additional useful services for GNOME
  services.gvfs.enable = true;  # Virtual filesystem support (for Nautilus)
  services.geoclue2.enable = true;  # Location services
  services.upower.enable = true;  # Power management

  # Exclude some default GNOME packages (optional - you can customize this)
  environment.gnome.excludePackages = with pkgs; [
    # Uncomment packages you want to exclude:
    # gnome-tour
    # epiphany  # Web browser
    # geary  # Email client
    # gnome-music
    # gnome-maps
    # gnome-weather
  ];

  # Core GNOME applications and utilities
  environment.systemPackages = with pkgs; [
    # GNOME core apps
    gnome-tweaks
    gnome-shell-extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.blur-my-shell
    gnomeExtensions.arcmenu
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals
    gnomeExtensions.just-perfection
    gnomeExtensions.user-themes
    gnomeExtensions.gsnap
    
    # File management
    nautilus
    file-roller  # Archive manager
    
    # System utilities
    gnome-disk-utility
    gnome-system-monitor
    gnome-calculator
    gnome-calendar
    gnome-contacts
    gnome-clocks
    
    # Text editors
    gnome-text-editor
    gedit
    
    # Multimedia
    gnome-photos
    eog  # Eye of GNOME image viewer
    evince  # Document viewer
    totem  # Video player
    
    # Terminal
    gnome-terminal
    
    # Development tools
    dconf-editor  # Advanced settings editor
    
    # Fonts for better GNOME experience
    cantarell-fonts
    dejavu_fonts
    liberation_ttf
    
    # Theme support
    adwaita-icon-theme
    gnome-themes-extra
  ];

  # Enable GSettings (required for GNOME configuration)
  programs.dconf.enable = true;

  # XDG portal for screen sharing, file picker, etc.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  # Sound server (PipeWire is recommended for GNOME)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable Avahi for network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable touchpad support (if on a laptop)
  services.libinput.enable = true;

  # Enable Flatpak support (optional, for GNOME Software)
  services.flatpak.enable = true;

  # Timezone and NTP for GNOME's calendar/clock
  services.timesyncd.enable = true;

  # Enable colord for color management
  services.colord.enable = true;

  # Enable GNOME's power profiles daemon
  # Note: conflicts with TLP if you have it enabled elsewhere
  services.power-profiles-daemon.enable = true;

  # Fonts configuration for better rendering
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Cantarell" "DejaVu Sans" ];
        monospace = [ "DejaVu Sans Mono" ];
      };
    };
  };

  # Hardware acceleration (useful for GNOME's compositor)
  hardware.graphics.enable = true;

  # Enable automatic login (optional - uncomment and configure)
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "a";
  # };

  # GNOME specific dconf settings (optional - can be customized)
  # These are examples and can be adjusted per user preference
  # programs.dconf.profiles.user.databases = [{
  #   settings = {
  #     "org/gnome/desktop/interface" = {
  #       color-scheme = "prefer-dark";
  #       enable-hot-corners = false;
  #     };
  #     "org/gnome/desktop/peripherals/touchpad" = {
  #       tap-to-click = true;
  #     };
  #     "org/gnome/mutter" = {
  #       edge-tiling = true;
  #       dynamic-workspaces = true;
  #     };
  #   };
  # }];
}
