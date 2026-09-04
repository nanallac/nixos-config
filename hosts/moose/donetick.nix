{ config, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.containers = {
    enable = true;
    registries.settings = {
      registry = [
        { location = "docker.io"; }
        { location = "quay.io"; }
      ];
    };
  };

  sops.secrets = {
    "donetick/jwt_secret" = {};
    "donetick/oauth2_client_secret" = {};
  };

  sops.templates."donetick.env" = {
    content = ''
      DT_JWT_SECRET=${config.sops.placeholder."donetick/jwt_secret"}
      DT_OAUTH2_CLIENT_SECRET=${config.sops.placeholder."donetick/oauth2_client_secret"}
    '';
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    donetick = {
      image = "donetick/donetick:latest";
      autoStart = true;
      ports = [ "127.0.0.1:2021:2021" ];
      environment = {
        DT_ENV = "selfhosted";
        DT_SQLITE_PATH = "/donetick-data/donetick.db";

        DT_NAME = "selfhosted";
        DT_IS_DONE_TICK_DOT_COM = "false";
        DT_IS_USER_CREATION_DISABLED = "true";

        DT_DATABASE_TYPE = "sqlite";
        DT_DATABASE_MIGRATION = "true";

        DT_JWT_SESSION_TIME = "168h";
        DT_JWT_MAX_REFRESH = "1440h";

        DT_SERVER_PORT = "2021";
        DT_SERVER_READ_TIMEOUT = "10s";
        DT_SERVER_WRITE_TIMEOUT = "10s";
        DT_SERVER_RATE_PERIOD = "60s";
        DT_SERVER_RATE_LIMIT = "300";
        DT_SERVER_CORS_ALLOW_ORIGINS = "http://localhost:5173,http://localhost:7926,https://localhost,http://localhost,capacitor://localhost";
        DT_SERVER_SERVE_FRONTEND = "true";
        DT_SERVER_SERVE_SWAGGER = "true";
        DT_SERVER_PUBLIC_HOST = "https://chores.nanall.ac";

        DT_OAUTH2_CLIENT_ID = "donetick";
        DT_OAUTH2_AUTH_URL = "https://idm.nanall.ac/ui/oauth2";
        DT_OAUTH2_TOKEN_URL = "https://idm.nanall.ac/oauth2/token";
        DT_OAUTH2_USER_INFO_URL = "https://idm.nanall.ac/oauth2/openid/donetick/userinfo";
        DT_OAUTH2_REDIRECT_URL = "https://chores.nanall.ac/auth/oauth2";
        DT_OAUTH2_NAME = "kanidm";
        DT_OAUTH2_ADMIN_GROUPS = "donetick_admins";
        DT_OAUTH2_MANAGER_GROUPS = "donetick_managers";

        DT_SINGLE_CIRCLE_INSTANCE = "true";
        DT_DISABLE_PASSWORD_AUTH = "true";
        DT_DISABLE_SIGNUP = "true";

        TZ = "Australia/Perth";
      };
      environmentFiles = [
        config.sops.templates."donetick.env".path
      ];
      volumes = [
        "/var/lib/donetick/data:/donetick-data"
        "/var/lib/donetick/config:/config"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/donetick 0750 root root -"
    "d /keep/var/lib/donetick/data 0750 root root -"
    "d /keep/var/lib/donetick/config 0750 root root -"
  ];

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/donetick";
        user = "root" ;
        group = "root";
        mode = "0750";
      }
    ];
  };

  # prevent container coming up into impermanence binds exist
  systemd.services.podman-donetick.unitConfig.RequiresMountsFor = "/var/lib/donetick";

  services.nginx.virtualHosts."chores.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:2021";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_buffering off;
        '';
      };
    };
  };
}
