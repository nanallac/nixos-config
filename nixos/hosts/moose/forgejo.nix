{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "git.${domain}";
in
{
  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
      passwordFile = "/var/lib/forgejo/forgejo-dbpass";
    };
    settings = {
      DEFAULT.APP_NAME = "Josh Callanan's Forgejo server";
      service = {
        DISABLE_REGISTRATION = false;
        SHOW_REGISTRATION_BUTTON = false;
      };
      server = {
        DOMAIN = "${url}";
        ROOT_URL = "https://${url}";
        HTTP_PORT = 3001;
        LANDING_PAGE = "explore";
      };
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        OPENID_CONNECT_SCOPES = "profile email";
        UPDATE_AVATAR = true;
        ACCOUNT_LINKING = "auto";
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ config.services.forgejo.user ];
    ensureUsers = [
      {
        name = config.services.forgejo.database.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.virtualHosts."${url}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
  };
}
