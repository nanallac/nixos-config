{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups.idm-nanall-ac = {
    initialize = true;
    passwordFile = "/etc/restic-password";
    environmentFile = "/etc/restic-env";
    paths = [
      "/var/lib/kanidm"
    ];
    repository = "b2:idm-nanall-ac";
    backupPrepareCommand = "systemctl stop kanidm";
    backupCleanupCommand = "systemctl start kanidm";
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
