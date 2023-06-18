{ config, pkgs, options, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    hostName = "cloud.nanall.ac";

    https = true;

    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "02:00:00";

    caching = {
      redis = true;
      apcu = true;
    };

    config = {
      overwriteProtocol = "https";

      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = "/var/nextcloud-db-pass";

      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";

      defaultPhoneRegion = "AU";
    };

    phpOptions =  options.services.nextcloud.phpOptions.default // {
      memory_limit = "2048M";
    };

    phpExtraExtensions = all: [ all.pdlib all.bz2 all.redis ];

    extraOptions = {
      enabledPreviewProviders = [
        "OC\\Preview\\Image"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\TIFF"
        "OC\\Preview\\Movie"
        "OC\\Preview\\MKV"
        "OC\\Preview\\MP4"
        "OC\\Preview\\AVI"
      ];
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
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
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
    nextcloud-face-recognition = {
      serviceConfig.Type = "oneshot";
      script = "${pkgs.sudo}/bin/sudo -i nextcloud-occ face:background_job -t 900";
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
    nextcloud-face-recognition = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nextcloud-preview-generator.service"];
      timerConfig = {
        OnBootSec = "30min";
        OnUnitActiveSec = "30min";
        Unit = "nextcloud-face-recognition.service";
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
