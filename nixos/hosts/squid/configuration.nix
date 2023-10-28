{ self, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ./headscale.nix
    ./kanidm.nix
    ./backup.nix
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

  services = {
    nginx = {
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
        "tailscale.nanall.ac" = {
          forceSSL = true;
          useACMEHost = "nanall.ac";
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
            "metrics" = {
              proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
            };
          };
        };
        "idm.nanall.ac" = {
          forceSSL = true;
          useACMEHost = "nanall.ac";
          locations = {
            "/" = {
              proxyPass = "https://localhost:8443";
              proxyWebsockets = true;
            };
          };
        };
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
