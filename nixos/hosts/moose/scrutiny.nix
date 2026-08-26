{ config, ...}:
{
  services.scrutiny = {
    enable = true;
    collector = {
      enable = true;
      settings.host.id = "moose";
      schedule = "hourly";
    };
    settings = {
      notify.urls = [
        "ntfy://ntfy.nanall.ac/scrutiny"
      ];
    };
  };

  services.nginx.virtualHosts."disks.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString config.services.scrutiny.settings.web.listen.port}";
        proxyWebsockets = true;
      };
    };
  };
}
