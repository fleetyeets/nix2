{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    alacritty
    bat
    ddcutil #monitor tools
    eza
    fd          # Fast alternative to find
    fzf         # Fuzzy finder for history/files
    gcc
    git
    grim        # Screenshot tool for Wayland
    mcfly       # Enhanced shell history with context-aware search
    mpv
    neovim
    obsidian
    proxychains
    quickemu
    ripgrep     # Fast grep alternative
    rustdesk-flutter
    slurp       # Area selection for Wayland screenshots
    socat
    serpl # find AND replace magic
    starship    # Cross-shell prompt
    swappy      # Screenshot annotation tool
    swtpm
    telegram-desktop #collection
    tor-browser
    tor
    typst
    vim
    wget
    wl-clipboard # Wayland clipboard utilities
    zathura
    zoxide      # Smart cd command that learns your patterns
  ];

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    roboto
    source-sans
    # Nerd Fonts for icons
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Font aliases for template compatibility
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>jetbrain mono</family>
        <prefer><family>JetBrains Mono</family></prefer>
      </alias>
      <alias>
        <family>source sans 3</family>
        <prefer><family>Source Sans 3</family></prefer>
      </alias>
    </fontconfig>
  '';

  # Shell aliases
  environment.shellAliases = {
    cat = "bat --style=full";
    ls = "eza --icons --group-directories-first";
    ll = "eza --icons --group-directories-first --all";
    replace = "serpl";
    screenshot = "grim -g \"$(slurp)\" - | swappy -f -";
    screenshot-full = "grim - | swappy -f -";
    screenshot-copy = "grim -g \"$(slurp)\" - | wl-copy";
    ts-getclip = "wl-copy";
    ts-putclip = "wl-paste";
  };

  # Neovim configuration with Dracula theme
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        " Enable Dracula theme
        colorscheme dracula
        
        " Basic settings
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ dracula-vim ];
      };
    };
  };

  # Bat is installed via environment.systemPackages
  # Configuration deployed via environment.etc

  # User-specific packages
  users.users.a = {
    isNormalUser = true;
    description = "a";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    packages = with pkgs; [
      warp-terminal
    ];
  };
}
