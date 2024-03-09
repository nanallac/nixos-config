{ pkgs, config, ... }:

let
  domain = "callanan.contact";
  url = "josh.${domain}";
  inherit (config.security.acme) certs;
in
{
  services.nginx.virtualHosts.${url} = {
    forceSSL = true;
    useACMEHost = "callanan.contact";
    locations = {
      "/" = {
        index = "index.html";
        root = pkgs.writeTextDir "index.html" ''
        <html>
          <head>
            <title>Josh Callanan</title>
          </head>
          <body>
            <h1>Josh Callanan</h1>
          </body>
        </html>
        '';
      };
    };
  };
}
