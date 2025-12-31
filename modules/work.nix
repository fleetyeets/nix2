{ config, pkgs, ... }:

# Overlay citrix-workspace with the last known working release from nixpkgs-unstable
  let
    pkgs = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/29b6e7097f50955f49a81d2665fb21c94c43df19.tar.gz";
      sha256 = "0zrkfxj130gbgixgk8yaxk5d9s5ppj667x38n4vys4zxw5r60bjz";
    }) {
      config = {
        allowUnfree = true;
        allowInsecure = true;
        permittedInsecurePackages = [
          "libsoup-2.74.3"
        ];
      };
    };

    citrix_workspace_overlay = pkgs.citrix_workspace;
  in
{
  # Enterprise/work-related applications
  environment.systemPackages = [
    citrix_workspace_overlay
  ];
}
