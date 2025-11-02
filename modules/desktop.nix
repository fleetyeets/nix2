{ config, pkgs, ... }:

{
  # Enable Niri - scrollable-tiling Wayland compositor
  programs.niri.enable = true;

  # Display manager for Wayland sessions
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  # x11
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
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Deploy configuration files to user home
  # Note: You'll need to manually copy these or use home-manager
  # Niri config: ~/.config/niri/config.kdl
  # Waybar config: ~/.config/waybar/config
  # Waybar style: ~/.config/waybar/style.css
  environment.etc."niri-config.kdl".source = ./niri-config.kdl;
  environment.etc."waybar-config.json".source = ./waybar-config.json;
  environment.etc."waybar-style.css".source = ./waybar-style.css;
}
