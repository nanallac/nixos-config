{ config, ...}:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.nanall.ac";

      listen-http = ":8090";
    };
  };

  services.nginx.virtualHosts."ntfy.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://localhost${toString config.services.ntfy-sh.settings.listen-http}";
        proxyWebsockets = true;
      };
    };
  };
}
