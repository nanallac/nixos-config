{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
    ../../common
    ./wyoming.satellite.nix
  ];

  # Keep this to make sure wifi works
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  environment.systemPackages = [
    pkgs.neofetch
    pkgs.htop
  ];

  system.stateVersion = "24.11";

  networking = {
    hostName = "finch";
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        Zebra.psk = "2304091040";
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
    extraModprobeConfig = '' options brcmfmac roamoff=1 feature_disable=0x82000 '';
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
