{ inputs, config, lib, pkgs, system, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/wifi
    ../../modules/workstation
  ];

  # Display Manager & Desktop Manager

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.plasma-login-manager.enable = true;
  };

  programs.kdeconnect.enable = true;

  # KDE Wallet unlock
  boot.initrd.systemd.enable = true;
  systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
  security.pam.services.plasmalogin-autologin.rules.auth = {
    systemd_loadkey = {
      order = 0;
      control = "optional";
      modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
    };
    plasmalogin = {
      order = 1;
      control = "include";
      modulePath = "plasmalogin";
    };
  };

  #

  nixpkgs.hostPlatform = system;

  hardware.bluetooth.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;  # up to 8G of compressed swap in RAM
    algorithm = "zstd";
  };

  system.stateVersion = "26.05";
}
