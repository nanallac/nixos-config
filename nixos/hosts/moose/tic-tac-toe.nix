{ inputs, config, self, ... }:

let
  domain = "nanall.ac";
  url = "tic-tac-toe.${domain}";
in

{
  services.nginx.virtualHosts = {
    ${url} = {
      forceSSL = true;
      useACMEHost = "${domain}";
      locations = {
        "/" = {
          root = "${inputs.tic-tac-toe.packages."x86_64-linux".default}/public/";
        };
      };
    };
  };
}
