{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "nvr-uat.${domain}";

  frigateConfig = {
    mqtt.enabled = false;
    auth.enabled = false;
    cameras = {
      "front_porch" = {
        ffmpeg = {
          hwaccel_args = "preset-vaapi";
          inputs = [
            {
              path = "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1";
              roles = [ "detect" ];
            }
          ];
        };
      };
    };
  };

  frigateConfigYaml = pkgs.writeText "config.yaml" (builtins.toJSON frigateConfig);

in
{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      frigate = {
        image = "ghcr.io/blakeblackshear/frigate:stable";
        ports = [ "8971:8971" ];
        volumes = [
          "/etc/frigate:/config"
          #   "/media/frigate:/media/frigate"
          "/tmp/cache:/tmp/cache"
          #   # Add your camera storage path
          #   # "/path/to/recordings:/recordings"
        ];
        devices = [
          "/dev/dri/renderD128:/dev/dri/renderD128"
        ];
        # environment = {
        #   FRIGATE_RTSP_PASSWORD = "your_password_here";
        # };
        extraOptions = [
          "--privileged"
          "--shm-size=64m"
        ];
      };
    };
  };

  environment.etc."frigate/config.yaml".source =
    (pkgs.formats.yaml {}).generate "config.yaml" frigateConfig;

  # services.frigate = {
  #   enable = true;
  #   hostname = "${url}";
  #   vaapiDriver = "iHD";
  #   settings = {
  #     mqtt.enabled = false;
  #     detect.enabled = false;
  #     cameras = {
  #       "front_porch" = {
  #         ffmpeg = {
  #           hwaccel_args = "preset-vaapi";
  #           inputs = [
  #             {
  #               path = "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1";
  #               roles = [ "detect" ];
  #             }
  #           ];
  #         };
  #       };
  #     };
  #   };
  # };

  # environment.persistence."/keep" = {
  #   directories = [
  #     {
  #       directory = "/var/lib/frigate";
  #       user = "frigate";
  #       group = "frigate";
  #       mode = "u=rwx,g=rx,o=";
  #     }
  #   ];
  # };

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
        useACMEHost = "${domain}";
        locations."/" = {
          proxyPass = "http://localhost:8971";
          proxyWebsockets = true;
          extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Important for Frigate's video streaming
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection "upgrade";
        proxy_set_header Upgrade $http_upgrade;
      '';
        };
      };
    };
  };
}
