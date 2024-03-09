{ inputs, config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "tailscale.${domain}";
in
{
  sops.secrets = {
    "tailscale/oidc_client_secret" = {};
  };

  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://${url}";
      metrics_listen_addr = "127.0.0.1:8095";
      dns_config = {
        override_local_dns = true;
        base_domain = "${domain}";
        # magic_dns = true;
        nameservers = [
          "192.168.1.1"
          "9.9.9.9"
        ];
        restricted_nameservers = {
          "${domain}" = [ "192.168.1.1" ];
        };
      };
      ip_prefixes = [
        "100.64.0.0/10"
      ];
      oidc = {
        issuer = "https://idm.nanall.ac/oauth2/openid/headscale";
        client_id = "headscale";
        # client_secret_path = "/run/secrets/tailscale/oidc_client_secret";
        client_secret = "xZubCFPygLfp0M94g4DbkK66QEMEXLFecPXkhHCLtZQhDgbV";
        scope = [ "openid" "profile" "email" ];
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  services.nginx.virtualHosts."tailscale.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
  };
}
