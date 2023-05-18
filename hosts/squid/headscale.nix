{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "tailscale.${domain}";
in
{
  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://${url}";
      metrics_listen_addr = "127.0.0.1:8095";
      dns_config = {
        override_local_dns = true;
        base_domain = "${domain}";
        magic_dns = true;
        nameservers = [
          "9.9.9.9"
        ];
        restricted_nameservers = {
          "${domain}" = [ "192.168.1.10" ];
        };
      };
      ip_prefixes = [
        "100.64.0.0/10"
      ];
    };
    openIdConnect = {
      issuer = "https://idm.nanall.ac/oauth2/openid/headscale";
      clientId = "headscale";
      clientSecretFile = "/etc/headscale-client-secret";
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
}
