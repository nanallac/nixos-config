{ config, pkgs, ... }:

let
  domain = "nanall.ac";
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
}
