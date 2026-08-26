{ config, ...}:

{
  users.groups.media = {};

  services.sabnzbd = {
    enable = true;
    group = "media";
    configFile = null;
    settings.misc = {
      host = "127.0.0.1";
      port = 9090;
    };
  };

  services.nginx.virtualHosts."newsreader.media.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass =
          let
            host = config.services.sabnzbd.settings.misc.host;
            port = config.services.sabnzbd.settings.misc.port;
          in
            "http://${host}:${toString port}";
      };
    };
  };

  services.prowlarr = {
    enable = true;
    settings = {
      Auth.Method = "External";
    };
  };

  services.nginx.virtualHosts."indexers.media.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass =
          let
            port = config.services.prowlarr.settings.server.port;
          in
        "http://localhost:${toString port}";
      };
    };
  };

  environment.persistence."/keep" = {
    hideMounts = true;
    directories = [
      {
        directory = "/var/lib/sabnzbd";
        mode = "0700";
      }
      {
        directory = "/var/lib/private/prowlarr";
        mode = "0700";
      }
    ];
  };

}
