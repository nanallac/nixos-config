{ self, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./headscale.nix
    ./kanidm.nix
    ./peertube.nix
  ];

  # ACME certificates
  # Secrets
  sops.secrets = {
    porkbun_secret_api_key_file = {
      owner = "acme";
    };
    porkbun_api_key_file = {
      owner = "acme";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "josh@callanan.contact";

    certs."nanall.ac" = {
      domain = "nanall.ac";
      extraDomainNames = [ "*.nanall.ac" ];
      dnsProvider = "porkbun";
      credentialFiles = {
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets.porkbun_secret_api_key_file.path;
        "PORKBUN_API_KEY_FILE" = config.sops.secrets.porkbun_api_key_file.path;
      };
    };

    certs."callanan.contact" = {
      domain = "callanan.contact";
      extraDomainNames = [ "*.callanan.contact" ];
      dnsProvider = "porkbun";
      credentialFiles = {
        "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets.porkbun_secret_api_key_file.path;
        "PORKBUN_API_KEY_FILE" = config.sops.secrets.porkbun_api_key_file.path;
      };
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
    nameservers = [ "8.8.8.8" "9.9.9.9" ];
    enableIPv6 = false;
  };

  zramSwap.enable = true;

  system.stateVersion = "22.11";
}
