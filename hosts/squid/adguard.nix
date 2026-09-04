{ ... }:

let
  rewrites = [
    { enabled = true; domain = "cloud.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "chores.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "media.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "books.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "akita.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "otter.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "ha.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "sprinklers.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "music.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "search.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "streams.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "office.nanall.ac"; answer = "100.64.0.9"; }
    { enabled = true; domain = "chat.nanall.ac"; answer = "100.64.0.1"; }
    { enabled = true; domain = "sunshine.nanall.ac"; answer = "100.64.0.1"; }
  ];
in
{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = {
      dns = {
        bind_hosts = [ "127.0.0.1" "100.64.0.4" ];
        upstream_dns = [ "9.9.9.9" ];
        bootstrap_dns = [ "9.9.9.9" ];
      };
      filtering = {
        filtering_enabled = true;
        rewrites_enabled = true;
        rewrites = rewrites;
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedUDPPorts = [ 53 ];
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 53 ];
}
