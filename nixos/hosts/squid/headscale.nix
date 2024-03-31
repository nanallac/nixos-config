{ inputs, config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "tailscale.${domain}";
in
{
  sops.secrets = {
    "tailscale/oidc_client_secret" = {
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
      mode = "0440";
    };
  };

  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://${url}";
      dns_config = {
        override_local_dns = true;
        base_domain = "${domain}";
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
        client_secret_path = config.sops.secrets."tailscale/oidc_client_secret".path;
        scope = [ "openid" "profile" "email" ];
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  services.nginx.virtualHosts."${url}" = {
    forceSSL = true;
    useACMEHost = config.networking.domain;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
  };
}
