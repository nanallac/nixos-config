{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups.cloud-nanall-ac = {
    initialize = true;
    passwordFile = "/etc/restic-password";
    environmentFile = "/etc/restic-env";
    paths = [
      "/var/lib/nextcloud"
    ];
    repository = "b2:cloud-nanall-ac";
    timerConfig = {
      OnUnitActiveSec = "1d";
    };
    pruneOpts = [
      "--keep-daily 3"
      "--keep-weekly 2"
      "--keep-yearly 1"
    ];
  };
}
