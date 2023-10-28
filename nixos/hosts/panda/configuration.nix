{ self, config, lib, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
    ./backup.nix
    ../../common
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

  system.stateVersion = "22.11";
}
