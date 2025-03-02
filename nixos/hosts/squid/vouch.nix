{ config, pkgs, lib, ... }:

let
  port = 30764;
  domain = config.networking.domain;
  url = "vouch.${domain}";
in
{

  # sops.secrets.vouch-proxy.jwt = {
  #   owner = "vouch-proxy";
  # };

  systemd.services.vouch-proxy =
    let
      vouchConfig = {
        vouch = {
          # testing = true;
          listen = "[::1]";
          port = port;

          # TODO this allows everybody that can authenticate to kanidm, so no
          # further scoping possible atm.
          allowAllUsers = true;
          cookie.domain = domain;

          jwt.secret = "bc1dc26c9cdb063323724f8d3b81ba6686151f79db976548243e6dd982e9139d";
        };
        oauth =
          let
            kanidmOrigin = config.services.kanidm.serverSettings.origin;
          in
          rec {
            provider = "oidc";
            client_id = "vouch";
            # oauth2_rs_basic_secret from `kanidm system oauth2 get gollum`
            client_secret = "CvfjKJYhyghEUfwtJX3tZwKpEqtg01c06PKuMes8xQ75hZWx";
            auth_url = "${kanidmOrigin}/ui/oauth2";
            token_url = "${kanidmOrigin}/oauth2/token";
            user_info_url = "${kanidmOrigin}/oauth2/openid/${client_id}/userinfo";
            scopes = [ "login" ];
            callback_url = "https://vouch.nanall.ac/auth";
            code_challenge_method = "S256";
          };
      };
    in
    {
      description = "Vouch-proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          ''
            ${pkgs.vouch-proxy}/bin/vouch-proxy \
              -config ${(pkgs.formats.yaml {}).generate "config.yml" vouchConfig}
          '';
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = "/var/lib/vouch-proxy";
        StateDirectory = "vouch-proxy";
        RuntimeDirectory = "vouch-proxy";
        User = "vouch-proxy";
        Group = "vouch-proxy";
        StartLimitBurst = 3;
      };
    };

  users.users.vouch-proxy = {
    isSystemUser = true;
    group = "vouch-proxy";
  };
  users.groups.vouch-proxy = { };

  services.nginx = {
    enable = true;
    virtualHosts."vouch.nanall.ac" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}/";
        extraConfig = ''
          proxy_set_header Host $host;
          add_header Access-Control-Allow-Origin https://idm.nanall.ac;
        '';
      };
    };
  };

}
