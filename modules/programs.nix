{ config, pkgs, ... }:

{
  # Install Firefox with Dracula theme
  programs.firefox = {
    enable = true;
    preferences = {
      "browser.theme.dark-private-windows" = true;
      "browser.theme.content-theme" = 0;
      "extensions.activeThemeID" = "dracula-dark-colorscheme@mozilla.org";
    };
  };

  # Enable Steam
  programs.steam.enable = true;
}
