{ self, config, lib, pkgs, ...}:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ./hardware-configuration.nix
    ./frigate.nix
    ../common/services
  ];

  environment.systemPackages = [
    pkgs.nanallac-nur.libedgetpu1-std
  ];

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "josh@callanan.contact";

  #   certs."nanall.ac" = {
  #     domain = "nanall.ac";
  #     extraDomainNames = [ "*.nanall.ac" ];
  #     dnsProvider = "linode";
  #     dnsPropagationCheck = true;
  #     credentialsFile = "/root/linode.ini";
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

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
  ];

  system.stateVersion = "23.05";
}
