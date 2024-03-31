{ inputs, config, pkgs, ... }:

{
  services.jellyfin.enable = true;
  users.users.jellyfin.extraGroups = [ "video" "render" ];

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

  # Media shares for Jellyfin - temporary, reassess once NAS migrated to be local.
  fileSystems."/mnt/media" = {
    device = "192.168.1.100:/mnt/storage0/media";
    fsType = "nfs";
    options = [
      "auto"
      "noatime"
      "x-systemd.automount"
    ];
  };

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

  # TODO get this working!
  # Restore backup if location is empty
  # systemd.services = {
  #   "restic-media-nanall-ac-restore" = {
  #     serviceConfig.Type = "oneshot";
  #     requires = [ "network.target" ];
  #     before = [ "jellyfin.service" ];
  #     script = ''
  #       if [ -z "$(ls -A /keep/var/lib/jellyfin)" ]; then
  #       ${config.pkgs.restic-media-nanall-ac} restore $(${config.pkgs.restic-media-nanall-ac} snapshots | grep /keep/var/lib/jellyfin | tail -n 1 | cut -d " " -f 1) --target /keep/var/lib/jellyfin
  #       fi
  #     '';
  #   };
  # };
}
