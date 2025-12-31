{ config, pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;

    onShutdown = "suspend";
    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  # Enable USB redirection
  virtualisation.spiceUSBRedirection.enable = true;

  # Allow VM management
  users.groups.libvirtd.members = [ "a" ];
  users.groups.kvm.members = [ "a" ];

  programs.virt-manager.enable = true;

  # Enable VM networking and file sharing
  environment.systemPackages = with pkgs; [
    gnome-boxes # VM management
    dnsmasq # VM networking
    phodav # (optional) Share files with guest VMs
    quickemu # easy qemu
  ];
}
