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

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "josh@callanan.contact";

  #   certs."nanall.ac" = {
  #     domain = "nanall.ac";
  #     dnsProvider = "porkbun";
  #     credentialsFile = "/root/porkbun";
  #   };
  # };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "rhino";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
    # interfaces.eth0.ipv4.addresses = [ {
    #   address = "192.168.1.40";
    #   prefixLength = 24;
    # }];
  };

  users.users.root.hashedPassword = "!";

  system.stateVersion = "23.05";
}
