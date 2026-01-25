# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  # Apply overlays
  nixpkgs.overlays = [
    (import ./overlays/gsnap.nix)
  ];

  # Allow insecure packages required by work applications
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  imports =
    [ 
      # Include the results of the hardware scan
      ./hardware-configuration.nix
      
      # Modular configuration
      ./modules/desktop.nix
      #./modules/gnome.nix
      ./modules/hardware.nix
      ./modules/packages.nix
      ./modules/programs.nix
      ./modules/virt.nix
      ./modules/tor-browser-lxc.nix
      #./modules/work.nix; pending citrix fixing workspace dependency
      #./modules/cybersec-lab.nix
      #./modules/deskflow.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Steam local network features (game transfer, Remote Play, In-Home Streaming)
    allowedTCPPortRanges = [
      { from = 27015; to = 27030; }
      { from = 27036; to = 27037; }
    ];
    allowedUDPPortRanges = [
      { from = 27000; to = 27031; }
      { from = 27036; to = 27036; }
    ];
  };

  # Locale and timezone
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
