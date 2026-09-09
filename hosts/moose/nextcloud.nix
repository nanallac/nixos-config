{ lib, config, pkgs, options, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
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
      preview_ffmpeg_path = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
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

      # Run the exiftool bundled with Memories via system perl
      # instead of the prebuilt binary that can't execute on NixOS
      "memories.exiftool" = "${pkgs.exiftool}/bin/exiftool";
      "memories.vod.ffmpeg"  = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
    };
  };

  # memories hardware acceleration
  users.users.nextcloud.extraGroups = [ "video" ];
  systemd.services.phpfm-nextcloud.serviceConfig = {
    DeviceAllow = "/dev/dri/renderD128 rw";
    PrivateDevices = lib.mkForce false;
  };

  services.collabora-online = {
    enable = true;
    settings = {
      server_name = "office.nanall.ac";
      ssl = {
        enable = false;
        termination = true;
      };
      net.listen = "any";
      storage.wopi.host = [ "cloud.nanall.ac" ];
    };
  };

  fonts.packages = [
    pkgs.liberation_ttf
    pkgs.corefonts
  ];

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
    pkgs.nodejs_24 # for Recognize
    pkgs.ffmpeg
    pkgs.sudo
    pkgs.restic # for backups
    pkgs.perl
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

    # perl for the background indexer...
  systemd.services.nextcloud-cron.path = [ pkgs.perl ];
  # ...for the web UI (admin status check, on-upload indexing)...
  systemd.services.phpfpm-nextcloud.path = [ pkgs.perl ];
  # ...and for interactive `nextcloud-occ` runs as root



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

  # mount HDD ZFS dataset to the standard Nextcloud Data directory
  fileSystems."/keep/var/lib/nextcloud/data" = {
    device = "storage0/nextcloud-data";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # we don't want to keep preview images on the HDD so bind mount to an SSD folder
  fileSystems."/keep/var/lib/nextcloud/data/appdata_ocli5g3yaxxn/preview" = {
    device = "/keep/var/lib/nextcloud/preview";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/nextcloud/preview 0750 nextcloud nextcloud - -"
  ];

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
    exclude = [
      # bind mounted path
      "/keep/var/lib/nextcloud/data/appdata_ocli5g3yaxxn/preview"
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
      "office.nanall.ac" = {
        forceSSL = true;
        useACMEHost = "nanall.ac";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.collabora-online.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
