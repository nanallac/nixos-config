{ inputs, config, pkgs, ... }:

{
  services.jellyfin.enable = true;
  systemd.services.jellyfin.path = [ pkgs.yt-dlp ];
  users.users.jellyfin.extraGroups = [ "video" "render" "media"];

  services.nginx.virtualHosts."media.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
      };
    };
  };

  # TODO keep working on switching systemd.tmpfiles for impermanence!
  # environment.persistence."/keep" = {
  #   directories = [
  #     {
  #       directory = "/var/lib/jellyfin";
  #       user = "jellyfin" ;
  #       group = "jellyfin";
  #       mode = "u=rwx,g=rwx,o=";
  #     }
  #   ];
  # };

  systemd.tmpfiles.rules = [
    "d /keep/var/lib/jellyfin 0700 jellyfin jellyfin -"
    "L /var/lib/jellyfin - - - - /keep/var/lib/jellyfin"
  ];

  # Backups

  environment.systemPackages = [ pkgs.restic ];

  sops.secrets = {
    "media/backblaze/env" = {};
    "media/backblaze/repo" = {};
    "media/restic" = {};
  };

  # Backup jellyfin folder
  services.restic.backups.media-nanall-ac = {
    initialize = true;
    passwordFile = config.sops.secrets."media/restic".path;
    repositoryFile = config.sops.secrets."media/backblaze/repo".path;
    environmentFile = config.sops.secrets."media/backblaze/env".path;
    paths = [
      "/keep/var/lib/jellyfin"
    ];
    exclude = [
      "/keep/var/lib/jellyfin/transcodes"
      "/keep/var/lib/jellyfin/metadata"
    ];
    backupPrepareCommand = "systemctl stop jellyfin";
    backupCleanupCommand = "systemctl start jellyfin";
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
}
