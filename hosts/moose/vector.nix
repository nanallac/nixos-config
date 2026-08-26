{ inputs, config, pkgs, ... }:

let
  port = 5140;
in
{
  services.vector = {
    enable = true;
    settings = {
      sources = {
        openwrt-syslog = {
          type = "syslog";
          address = "0.0.0.0:${builtins.toString port}";
          mode = "udp";
        };
      };
      transforms = {
        remap-openwrt-syslog = {
          inputs = [ "openwrt-syslog" ];
          type = "remap";
          drop_on_error = true;
          source = ''
            . = parse_syslog!(.message)
          '';
        };
        filter-openwrt-syslog = {
          type = "filter";
          inputs = [ "remap-openwrt-syslog" ];
          condition = ''.appname == "dnsmasq-dhcp" && contains(string!(.message), "DHCPACK")'';
        };
        add-uuid-openwrt-syslog = {
          type = "remap";
          inputs = [ "filter-openwrt-syslog" ];
          source = ''
            .uuid = uuid_v4()
          '';
        };
      };
      sinks = {
        testing = {
          type = "console";
          inputs = [ "add-uuid-openwrt-syslog" ];
          encoding = {
            codec = "json";
            timestamp_format = "rfc3339";
          };
        };
      };
    };
  };
  
  networking.firewall.allowedUDPPorts = [ port ];
}
