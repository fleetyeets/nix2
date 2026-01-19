{ config, pkgs, ... }:

{
  # Enable Niri - scrollable-tiling Wayland compositor
  programs.niri.enable = true;

  # Display manager for Wayland sessions
  # Note: When using GNOME, GDM is used instead (disable SDDM below)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  # x11 - Note: when using GNOME, services.xserver.enable is set in gnome.nix
  services.xserver.enable = true;
  programs.xwayland.enable = true;
  # Essential Wayland/desktop packages
  environment.systemPackages = with pkgs; [
    # Window manager
    niri
    
    # Status bar
    waybar
    
    # Application launcher
    fuzzel
    
    # Notification daemon
    mako
    
    # Terminal (foot is lightweight for Wayland)
    foot
    
    # Screenshot tool
    grim
    slurp
    
    # Clipboard manager
    wl-clipboard

    # xwayland satellite
    xwayland-satellite
    
    # File manager
    xfce.thunar
    
    # Basic utilities
    swaylock
    swayidle
  ];

  # XDG portal for screen sharing and other desktop integration
  # Note: xdg.portal is also configured in gnome.nix for GNOME desktop
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Deploy configuration files
  environment.etc."niri-config.kdl".source = ./niri-config.kdl;
  environment.etc."waybar-config.json".source = ./waybar-config.json;
  environment.etc."waybar-style.css".source = ./waybar-style.css;
  environment.etc."alacritty.toml".source = ./alacritty.toml;
  environment.etc."foot.ini".source = ./foot.ini;
  environment.etc."fuzzel.ini".source = ./fuzzel.ini;
  environment.etc."mako-config".source = ./mako-config;
  environment.etc."zathurarc".source = ./zathurarc;
  environment.etc."starship.toml".source = ./starship.toml;
  environment.etc."bat-config".source = ./bat-config;

  # Symlink config files to user home directory
  systemd.tmpfiles.rules = [
    # Create directories with proper ownership first
    "d /home/a/.config/niri 0755 a users -"
    "d /home/a/.config/waybar 0755 a users -"
    "d /home/a/.config/alacritty 0755 a users -"
    "d /home/a/.config/foot 0755 a users -"
    "d /home/a/.config/fuzzel 0755 a users -"
    "d /home/a/.config/mako 0755 a users -"
    "d /home/a/.config/zathura 0755 a users -"
    "d /home/a/.config/bat 0755 a users -"
    # Create symlinks
    "L+ /home/a/.config/niri/config.kdl - - - - /etc/niri-config.kdl"
    "L+ /home/a/.config/waybar/config - - - - /etc/waybar-config.json"
    "L+ /home/a/.config/waybar/style.css - - - - /etc/waybar-style.css"
    "L+ /home/a/.config/alacritty/alacritty.toml - - - - /etc/alacritty.toml"
    "L+ /home/a/.config/foot/foot.ini - - - - /etc/foot.ini"
    "L+ /home/a/.config/fuzzel/fuzzel.ini - - - - /etc/fuzzel.ini"
    "L+ /home/a/.config/mako/config - - - - /etc/mako-config"
    "L+ /home/a/.config/zathura/zathurarc - - - - /etc/zathurarc"
    "L+ /home/a/.config/starship.toml - - - - /etc/starship.toml"
    "L+ /home/a/.config/bat/config - - - - /etc/bat-config"
  ];
}
