{ inputs, config, pkgs, lib, ... }:

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
      dns = {
        override_local_dns = true;
        magic_dns = false;
        base_domain = "ts.nanall.ac";
        nameservers.global = [ "100.64.0.4" ];
        search_domains = [ "ts.nanall.ac" "nanall.ac" ];
        extra_records = [
          { name = "idm.nanall.ac";       type = "A"; value = "175.45.180.229"; }
          { name = "tailscale.nanall.ac"; type = "A"; value = "175.45.180.229"; }
        ];

      };
      ip_prefixes = [
        "100.64.0.0/10"
      ];
      derp.server = {
        enabled = true;
        region_id = 999;
        region_code = config.networking.hostName;
        stun_listen_addr = "0.0.0.0:3478";
      };
      oidc = {
        issuer = "https://idm.nanall.ac/oauth2/openid/headscale";
        client_id = "headscale";
        client_secret_path = config.sops.secrets."tailscale/oidc_client_secret".path;
        scope = [ "openid" "profile" "email" ];
      };
      policy = {
        mode = "file";
        path = (pkgs.formats.json { }).generate "headscale-policy.json" {
          groups."group:admins" = [ "nanall.ac@" "josh@idm.nanall.ac@" ];
          tagOwners = {
            "tag:server" = [ "group:admins" ];
            "tag:client" = [ "group:admins" ];
          };
          acls = [
            { action = "accept"; src = [ "*" ]; dst = [ "*:*" ]; }
          ];
          autoApprovers = {
            routes."192.168.1.0/24" = [ "tag:server" ];
            exitNode = [ "tag:server" ];
          };
          ssh = [
            # admins -> servers, any local account
            { action = "accept"; src = [ "group:admins" ];     dst = [ "tag:server" ];     users = [ "autogroup:nonroot" "root" ]; }
            # people -> their own devices (e.g. josh: eagle <-> tapir)
            { action = "accept"; src = [ "autogroup:member" ]; dst = [ "autogroup:self" ]; users = [ "autogroup:nonroot" "root" ]; }
          ];
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 3478 ]; # DERP/STUN

  environment.systemPackages = [ config.services.headscale.package ];

  services.nginx.virtualHosts."${url}" = {
    forceSSL = true;
    useACMEHost = config.networking.domain;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };
  };
}
