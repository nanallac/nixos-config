{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "nvr.${domain}";
in
{
  environment.systemPackages = [
    pkgs.gasket
  ];
  services.frigate = {
    enable = true;
    hostname = url;
    settings = {
#       mqtt = {
#         enabled = true;
#         host = "192.168.1.186";
#       };
      objects.track = [ "person" "cat" "dog" ];
      record.enabled = false;
      snapshots.enabled = true;
      go2rtc.streams."front_porch" = [
        "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1"
      ];
      cameras."front_porch" = {
        ffmpeg.inputs = [
          {
            path = "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1";
            roles = [ "detect" ];
          }
          {
            path = "rtsp://admin:uPp5NUW6mvo7E4XP@192.168.40.2:554/cam/realmonitor?channel=1&subtype=0";
            roles = [ "record" ];
          }
        ];
        detect = {
          enabled = true;
          width = 480;
          height = 704;
        };
        # zones = {
        #   entire_yard.coordinates = "0,2688,1520,2688,1520,162,1267,147,988,238,348,234,0,362";
        #   porch.coordinates = "1215,1764,1279,1134,1279,596,728,536,325,936,0,1355,0,2482,426,2688,981,2688,1099,2329";
        #   driveway.coordinates = "988,345,616,326,300,345,0,395,0,555,339,524,731,530,1273,584,1269,385";
        # };
      };
    };
  };
}
