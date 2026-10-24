{ config, ... }:

{
  services.mattermost = {
    enable = true;

    siteUrl = "https://mattermost.nanall.ac";
    siteName = "nanall";

    host = "127.0.0.1";
    port = 8065;

    mutableConfig = true;

    database = {
      peerAuth = true;
      name = "mattermost";
      user = "mattermost";
    };

    socket.enable = true;
  };

  services.postgresql.authentication = "local mattermost mattermost peer";

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/mattermost/config 0750 mattermost mattermost -"
    "d /keep/var/lib/mattermost/logs 0750 mattermost mattermost -"
    "d /keep/var/lib/mattermost/data 0750 mattermost mattermost -"
    "L+ /keep/var/lib/mattermost/bin - - - - ${config.services.mattermost.package}/bin"
    "L+ /keep/var/lib/mattermost/fonts - - - - ${config.services.mattermost.package}/fonts"
    "L+ /keep/var/lib/mattermost/i18n - - - - ${config.services.mattermost.package}/i18n"
    "L+ /keep/var/lib/mattermost/templates - - - - ${config.services.mattermost.package}/templates"
    "L+ /keep/var/lib/mattermost/client - - - - ${config.services.mattermost.package}/client"
  ];

  systemd.services.mattermost.unitConfig.RequiresMountsFor = "/var/lib/mattermost";

  services.nginx.virtualHosts."mattermost.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.mattermost.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100M;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
      };
    };
  };

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/mattermost";
        user = "mattermost";
        group = "mattermost";
        mode = "0750";
      }
    ];
  };
}
