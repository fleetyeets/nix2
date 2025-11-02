{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    alacritty
    bat
    eza
    fd          # Fast alternative to find
    fzf         # Fuzzy finder for history/files
    gcc
    git
    mcfly       # Enhanced shell history with context-aware search
    mpv
    neovim
    ripgrep     # Fast grep alternative
    rustdesk-flutter
    socat
    starship    # Cross-shell prompt
    typst
    vim
    wget
    zathura
    zoxide      # Smart cd command that learns your patterns
  ];

  # User-specific packages
  users.users.a = {
    isNormalUser = true;
    description = "a";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      warp-terminal
    ];
  };
}
