{ inputs, config, pkgs, ... }:

{
  services.calibre-web = {
    enable = true;
    options = {
      calibreLibrary = "/var/lib/calibre-web/library/";
      enableBookConversion = true;
      enableBookUploading = true;
      enableKepubify = true;
    };
  };

  services.nginx.virtualHosts."books.nanall.ac" = {
    forceSSL = true;
    useACMEHost = "nanall.ac";
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString config.services.calibre-web.listen.port}";
        proxyWebsockets = true;
	extraConfig = ''
	  client_max_body_size 100M;
	'';
      };
    };
  };

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/calibre-web";
        user = "calibre-web" ;
        group = "calibre-web";
        mode = "u=rwx,g=rwx,o=";
      }
    ];
  };

  # Backups

  # environment.systemPackages = [ pkgs.restic ];

  # sops.secrets = {
  #   "books/backblaze/env" = {};
  #   "books/backblaze/repo" = {};
  #   "books/restic" = {};
  # };

  # Backup jellyfin folder
#   services.restic.backups.books-nanall-ac = {
#     initialize = true;
#     passwordFile = "/run/secrets/books/restic";
#     repositoryFile = "/run/secrets/books/backblaze/repo";
#     environmentFile = "/run/secrets/books/backblaze/env";
#     paths = [
#       "/keep/var/lib/calibre-web"
#     ];
#     backupPrepareCommand = "systemctl stop calibre-web";
#     backupCleanupCommand = "systemctl start calibre-web";
#     timerConfig = {
#       OnCalendar = "02:00";
#       Persistent = true;
#       RandomizedDelaySec = "1h";
#     };
#     pruneOpts = [
#       "--keep-daily 3"
#       "--keep-weekly 2"
#       "--keep-yearly 1"
#     ];
#   };
}
