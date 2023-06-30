{ self, config, lib, pkgs, ...}:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
    ./backup.nix
    ../../modules/services
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "porkbun";
      credentialsFile = "/root/porkbun";
    };
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    
    virtualHosts = {
      "cloud.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "panda";
    domain = "nanall.ac";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  users.users.root.hashedPassword = "!";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTkf9WjAcV3S2iHravn1okBw3YK81s/YjGr2kLyh6+j josh@callanan.contact"
  ];

  system.stateVersion = "22.11";
}
