{ config, pkgs, ... }:

{
  # Enable nftables (required by Incus)
  networking.nftables.enable = true;

  # Enable Incus for containerization (LXD replacement)
  virtualisation.incus = {
    enable = true;
  };

  # Add user to incus-admin group for container management
  users.users.a.extraGroups = [ "incus-admin" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    incus
    
    # For X11/Wayland forwarding to container
    xorg.xhost
    
    # Helper script for launching Tor Browser with desktop entry
    (pkgs.makeDesktopItem {
      name = "tor-browser-isolated";
      desktopName = "Tor Browser (Isolated)";
      comment = "Anonymous browsing in isolated container";
      exec = "tor-browser-isolated";
      icon = "tor-browser";
      categories = [ "Network" "WebBrowser" "Security" ];
      keywords = [ "tor" "browser" "privacy" "anonymous" ];
    })
    
    (pkgs.writeScriptBin "tor-browser-isolated" ''
      #!/usr/bin/env bash
      set -e

      CONTAINER_NAME="tor-browser"
      
      # Check if container exists
      if ! incus info "$CONTAINER_NAME" &>/dev/null; then
        echo "Tor Browser container not found. Creating..."
        /etc/incus-tor-browser/setup-tor-container.sh
      fi

      # Check if container is running
      if [ "$(incus info "$CONTAINER_NAME" | grep Status: | awk '{print $2}')" != "RUNNING" ]; then
        echo "Starting Tor Browser container..."
        incus start "$CONTAINER_NAME"
        sleep 2
      fi

      # Allow X11/Wayland connection from container
      xhost +local:

      # Launch Tor Browser in container
      incus exec "$CONTAINER_NAME" -- sudo -u user DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR=/run/user/1000 /home/user/tor-browser/Browser/start-tor-browser --detach

      echo "Tor Browser launched in isolated container"
    '')
  ];

  # Deploy setup scripts
  environment.etc."incus-tor-browser/setup-tor-container.sh" = {
    source = ./tor-browser-setup.sh;
    mode = "0755";
  };

  # Firewall rules - block all non-Tor traffic from container
  # NOTE: Rules are permissive to allow container setup (apt-get)
  # Once Tor Browser is configured to run entirely via Tor daemon,
  # these rules can be tightened to only allow Tor ports
  networking.nftables.tables.tor-isolation = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority filter; policy accept;
        
        # Apply restrictions to traffic from Incus bridge
        iifname "incusbr0" jump tor_container
      }
      
      chain tor_container {
        # Only restrict traffic FROM containers (source is container subnet)
        ip saddr != 10.137.170.0/24 accept
        ip6 saddr != fd42:f064:8f16:2f80::/64 accept
        
        # Allow HTTPS (for apt-get and Tor Browser download)
        tcp dport 443 accept
        
        # Allow HTTP (for apt-get)
        tcp dport 80 accept
        
        # Allow Tor network traffic (9001, 9030, 9050, 9051, 9150)
        tcp dport { 9001, 9030, 9050, 9051, 9150 } accept
        
        # Allow DNS
        udp dport 53 accept
        tcp dport 53 accept
        
        # Allow established/related connections
        ct state { established, related } accept
        
        # Allow ICMP (for network diagnostics)
        ip protocol icmp accept
        icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, echo-request, echo-reply } accept
        
        # Block everything else from containers
        reject
      }
    '';
  };
}
