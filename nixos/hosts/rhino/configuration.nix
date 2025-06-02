{ self, config, lib, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./frigate.nix
    ../../common
  ];

  environment.systemPackages = [
    pkgs.nanallac-nur.libedgetpu1-std
  ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "rhino";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  users.users.root.hashedPassword = "!";

  system.stateVersion = "23.05";
}
