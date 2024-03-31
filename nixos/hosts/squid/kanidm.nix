{ inputs, config, pkgs, ... }:

let
  domain = config.networking.domain;
  url = "idm.${domain}";
  inherit (config.security.acme) certs;
in
{
  users.users.kanidm.extraGroups = [ "acme" ];
  services.kanidm = {
    enableServer = true;
    enableClient = true;
    serverSettings = {
      domain = "${url}";
      origin = "https://${url}";
      bindaddress = "[::]:8443";
      trust_x_forward_for = true;
      # tls_key = "${config.security.acme.certs."nanall.ac".directory}/key.pem";
      # tls_chain = "${config.security.acme.certs."nanall.ac".directory}/fullchain.pem";
      tls_key = "/var/lib/kanidm/certs/key.pem";
      tls_chain = "/var/lib/kanidm/certs/fullchain.pem";
    };
    clientSettings.uri = "https://${url}";
  };

  services.nginx.virtualHosts."${url}" = {
    forceSSL = true;
    useACMEHost = domain;
    locations = {
      "/" = {
        proxyPass = "https://localhost:8443";
        proxyWebsockets = true;
      };
    };
  };

  # Backups

  environment.systemPackages = [ pkgs.restic ];

  sops.secrets = {
    "idm/backblaze/env" = {};
    "idm/backblaze/repo" = {};
    "idm/restic" = {};
  };

  services.restic.backups.idm-nanall-ac = {
    initialize = true;
    # passwordFile = "/run/secrets/idm/restic";
    passwordFile = config.sops.secrets."idm/restic".path;
    # repositoryFile = "/run/secrets/idm/backblaze/repo";
    repositoryFile = config.sops.secrets."idm/backblaze/repo".path;
    # environmentFile = "/run/secrets/idm/backblaze/env";
    environmentFile = config.sops.secrets."idm/backblaze/env".path;
    paths = [
      "/var/lib/kanidm"
    ];
    backupPrepareCommand = "systemctl stop kanidm";
    backupCleanupCommand = "systemctl start kanidm";
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
