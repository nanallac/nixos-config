{ lib, config, pkgs, options, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
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
      dbpassFile = config.sops.secrets."nextcloud/database/dbpass".path;

      adminpassFile = config.sops.secrets."nextcloud/database/adminpass".path;
      adminuser = "admin";
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = "23";
    };

    phpExtraExtensions = all: [ all.pdlib all.bz2 all.redis all.smbclient ];

    settings = {
      default_phone_region = "AU";
      overwriteprotocol = "https";
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
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";
      maintenance_window_start = "20";
      allow_local_remote_servers = true;
      allow_user_to_change_display_name = false;
      lost_password_link = "disabled";
      log_type = "syslog";
      loglevel = 0;
      notify_push.enable = true;
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
    pkgs.restic # for backups
  ];

  systemd.services = {
    nextcloud-setup = {
      requires = [ "postgresql.service" "var-lib-nextcloud.mount" ];
      after = [ "postgresql.service" "var-lib-nextcloud.mount" ];
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

  # Impermanence


  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/nextcloud";
        user = "nextcloud";
        group = "nextcloud";
        mode = "u=rwx,g=rwx,o=";
      }
      {
        directory = "/var/lib/redis-nextcloud";
        user = "nextcloud";
        group = "nextcloud";
        mode = "u=rwx,g=rwx,o=";
      }
    ];
  };

  # Backups

  sops.secrets = {
    "nextcloud/database/dbpass" = {
      mode = "0600";
      owner = "nextcloud";
      group = "nextcloud";
    };
    "nextcloud/database/adminpass" = {
      mode = "0600";
      owner = "nextcloud";
      group = "nextcloud";
    };
    "nextcloud/backblaze/env" = {};
    "nextcloud/backblaze/repo" = {};
    "nextcloud/restic" = {};
  };

  services.restic.backups.cloud-nanall-ac = {
    initialize = true;
    passwordFile = config.sops.secrets."nextcloud/restic".path;
    repositoryFile = config.sops.secrets."nextcloud/backblaze/repo".path;
    environmentFile = config.sops.secrets."nextcloud/backblaze/env".path;
    paths = [
      "/keep/var/lib/nextcloud"
    ];
    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-yearly 1"
    ];
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "cloud.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
      };
    };
  };
}
