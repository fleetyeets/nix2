{ config, pkgs, ... }:

{
  # Deskflow server configuration for remote access
  environment.systemPackages = with pkgs; [
    deskflow
  ];

  # Create deskflow config directory and file
  environment.etc."deskflow-server.conf".text = ''
    section: screens
      ${config.networking.hostName}:
      allies.mac.mini.lan:
    end
    section: links
      ${config.networking.hostName}:
        right = allies.mac.mini.lan
      allies.mac.mini.lan:
        left = ${config.networking.hostName}
    end
    section: options
      clipboardSharing = false
      clipboardSharingSize = 3072
    end
  '';

  # Enable deskflow service to run at startup
  systemd.user.services.deskflow = {
    description = "Deskflow server for remote keyboard/mouse access";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.deskflow}/bin/deskflow-core server --no-daemon --config /etc/deskflow-server.conf --name ${config.networking.hostName}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Open firewall port for deskflow (default: 24800)
  networking.firewall = {
    allowedTCPPorts = [ 24800 ];
  };
}
