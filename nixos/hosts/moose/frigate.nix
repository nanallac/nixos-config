{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "nvr-uat.${domain}";
in
{
  services.frigate = {
    enable = true;
    hostname = url;
    settings = {
      mqtt.enabled = false;
      # ffmpeg.hwaccel_args = "preset-intel-qsv-h264";
      cameras = {
        "front_porch" = {
          ffmpeg.inputs = [{
            path = "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1";
            roles = [
              "record"
              "detect"
            ];
          }];
        };
      };

    };
  };

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/frigate";
        user = "frigate";
        group = "frigate";
        mode = "u=rwx,g=rwx,o=";
      }
    ];
  };

  sops.secrets = {
    "frigate/backblaze/env" = {};
    "frigate/backblaze/repo" = {};
    "frigate/restic" = {};
  };

  # services.restic.backups.nvr-nanall-ac = {
  #   initialize = true;
  #   passwordFile = config.sops.secrets."frigate/restic".path;
  #   repositoryFile = config.sops.secrets."frigate/backblaze/repo".path;
  #   environmentFile = config.sops.secrets."frigate/backblaze/env".path;
  #   backupPrepareCommand = "systemctl stop frigate";
  #   backupCleanupCommand = "systemctl start frigate";

  #   paths = [
  #     "/var/lib/frigate"
  #   ];
  #   timerConfig = {
  #     OnCalendar = "02:00";
  #     Persistent = true;
  #     RandomizedDelaySec = "1h";
  #   };
  #   pruneOpts = [
  #     "--keep-daily 3"
  #     "--keep-weekly 2"
  #     "--keep-yearly 1"
  #   ];
  # };


  # frigate module does most of this, just need to
  # specify the TLS certs.
  services.nginx = {
    virtualHosts = {
      "${url}" = {
        forceSSL = true;
        useACMEHost = domain;
      };
    };
  };
}
