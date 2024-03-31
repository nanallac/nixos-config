
{ lib, config, pkgs, options, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "cloud.nanall.ac";

    maxUploadSize = "16G";
    https = true;

    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "02:00:00";

    caching = {
      redis = true;
      apcu = true;
    };

    config = {

      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = "/var/nextcloud-db-pass";

      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";
    };

    phpExtraExtensions = all: [ all.pdlib all.bz2 all.redis all.smbclient ];

    settings = {
      defaultPhoneRegion = "AU";
      overwriteProtocol = "https";
      enabledPreviewProviders = [
        "OC\\Preview\\Image"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\TIFF"
        "OC\\Preview\\Movie"
        "OC\\Preview\\MKV"
        "OC\\Preview\\MP4"
        "OC\\Preview\\AVI"
        "OC\\Preview\\Imaginary"
      ];
      preview_imaginary_url = "http://${builtins.toString config.services.imaginary.address}:${builtins.toString config.services.imaginary.port}";
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
      };
      memcache = {
        local = "\\OC\\Memcache\\APCu";
        distributed = "\\OC\\Memcache\\Redis";
        locking = "\\OC\\Memcache\\Redis";
      };
      allow_local_remote_servers = true;
      allow_user_to_change_display_name = false;
      lost_password_link = "disabled";
      log_type = "syslog";
      loglevel = 0;
    };
  };

  services.imaginary = {
    enable = true;
    settings.return-size = true;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
    authentication = "local nextcloud nextcloud peer";
  };

  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
    port = 0;
  };

  services.samba.enable = true;
  services.postfix.enable = true;
  environment.systemPackages = [
    pkgs.nodejs_18 # for Recognize
    pkgs.ffmpeg
    pkgs.sudo
  ];

  systemd.services = {
    nextcloud-setup = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
    nextcloud-preview-generator = {
      serviceConfig.Type = "oneshot";
      script = "${pkgs.sudo}/bin/sudo -i nextcloud-occ preview:pre-generate";
    };
    nextcloud-postgresql-backup = {
      requires = [ "postgresql.service" ];
      serviceConfig.Type = "oneshot";
      preStart = "${pkgs.sudo}/bin/sudo -i nextcloud-occ maintenance:mode --on";
      postStop = "${pkgs.sudo}/bin/sudo -i nextcloud-occ maintenance:mode --off";
      script = ''
        ${pkgs.sudo}/bin/sudo -u nextcloud ${pkgs.postgresql}/bin/pg_dump nextcloud -f /var/lib/nextcloud/backup/nextcloud-sqlbkp_`date +'%Y%m%d'`.bak
        ${pkgs.findutils}/bin/find /var/lib/nextcloud/backup/ -type f -mtime +3 -delete
      '';
    };
  };

  systemd.timers = {
    nextcloud-preview-generator = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud-preview-generator.service"];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "nextcloud-preview-generator.service";
      };
    };
    nextcloud-postgresql-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud-postgresql-backup.service"];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "nextcloud-postgresql-backup.service";
      };
    };
  };
}
