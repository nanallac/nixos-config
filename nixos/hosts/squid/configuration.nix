{ self, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ./headscale.nix
    ./kanidm.nix
    ./josh.callanan.contact.nix
  ];

  # ACME certificates
  # Secrets
  sops.secrets.porkbun = {
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "porkbun";
      credentialsFile = "/run/secrets/porkbun";
    };

    certs."callanan.contact" = {
      domain = "callanan.contact";
      extraDomainNames = [ "*.callanan.contact" ];
      dnsProvider = "porkbun";
      credentialsFile = "/run/secrets/porkbun";
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts = {
      "_" = {
        default = true;
        rejectSSL = true;
        extraConfig = "return 444;";
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  networking = {
    hostName = "squid";
    domain = "nanall.ac";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  zramSwap.enable = true;

  system.stateVersion = "22.11";
}
