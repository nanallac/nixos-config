{ config, ...}:

{
  users.groups.media = {
    gid = 973;
    members = [ "pinchflat" ];
  };

  services.sabnzbd = {
    enable = true;
    group = "media";
    openFirewall = true;
    configFile = null;
    settings.misc = {
      host = "0.0.0.0";
      port = 6767;
    };
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.auth.method = "Forms";
    settings.auth.required = "DisabledForLocalAddresses";
    settings.update.mechanism = "external";
  };

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.auth.method = "Forms";
    settings.auth.required = "DisabledForLocalAddresses";
    settings.update.mechanism = "external";
  };

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/sabnzbd 2775 sabnzbd media - -"
    "d /keep/var/lib/sonarr  2775 sonarr  media - -"
    "d /keep/var/lib/radarr  2775 radarr  media - -"
    "d /keep/var/lib/seerr   2775 seerr   seerr - -"
  ];

  environment.persistence."/keep" = {
    hideMounts = true;
    directories = [
      { directory = "/var/lib/sabnzbd"; }
      { directory = "/var/lib/sonarr";  }
      { directory = "/var/lib/radarr";  }
      { directory = "/var/lib/seerr";   }
    ];
  };
}
