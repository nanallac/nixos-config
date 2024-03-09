{ inputs, config, pkgs, ... }:

{
  imports = [
    ../../common
    ../../common/users/josh
    # ./disk-config.nix
    # inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mmcblk1";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  programs.zsh.enable = true;

  networking.networkmanager.enable = true;
  networking.hostName = "mouse";

  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";

}
