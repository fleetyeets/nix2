{ config, pkgs, lib, ... }:

{
  # Enable podman for containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # docker command alias
    defaultNetwork.settings.dns_enabled = true;
  };

  # Docker-compose support
  virtualisation.oci-containers.backend = "podman";

  # Add user to podman group
  users.users.a.extraGroups = [ "podman" "wireshark" ];

  # Cybersecurity tools
  environment.systemPackages = with pkgs; [
    # Container management
    podman-compose
    podman-tui
    
    # Network scanning & reconnaissance
    nmap
    masscan
    rustscan
    
    # Web application testing
    nikto
    sqlmap
    ffuf
    gobuster
    
    # Network analysis
    wireshark
    tcpdump
    netcat-gnu
    socat
    
    # Password attacks
    hashcat
    john
    hydra
    
    # Exploitation frameworks
    metasploit
    exploitdb
    
    # Reverse engineering
    ghidra
    radare2
    gdb
    
    # Utilities
    jq
    curl
    wget
  ];

  # Wireshark packet capture permissions
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  # Create lab directory structure
  systemd.tmpfiles.rules = [
    "d /home/a/cybersec-lab 0755 a users -"
    "d /home/a/cybersec-lab/scenarios 0755 a users -"
    "d /home/a/cybersec-lab/scripts 0755 a users -"
    "d /home/a/cybersec-lab/data 0755 a users -"
  ];

  # Network configuration for isolated lab network
  networking.firewall.trustedInterfaces = [ "podman0" ];
}
