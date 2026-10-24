{ config, ... }:

{
  services.forgejo = {
    enable = true;

    database.type = "postgres";

    settings = {
      server = {
        DOMAIN = "forge.nanall.ac";
        ROOT_URL = "https://forge.nanall.ac/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
      };

      service.DISABLE_REGISTRATION = true;
    };
  };

  services.postgresql.authentication = "local forgejo forgejo peer";

  services.nginx.virtualHosts."forge.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 100M;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/forgejo/conf 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/custom 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/custom/conf 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/data 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/log 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/repositories 0750 forgejo forgejo -"
    "d /keep/var/lib/forgejo/dump 0750 forgejo forgejo -"
  ];

  systemd.services.forgejo.unitConfig.RequiresMountsFor = "/var/lib/forgejo";

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/forgejo";
        user = "forgejo";
        group = "forgejo";
        mode = "0750";
      }
    ];
  };
}
