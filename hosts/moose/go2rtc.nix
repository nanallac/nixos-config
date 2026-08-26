{ config, pkgs, ... }:

{
  sops.secrets = {
    "go2rtc/front_door/username" = { };
    "go2rtc/front_door/password" = { };
    "go2rtc/front_porch/username" = { };
    "go2rtc/front_porch/password" = { };
    "go2rtc/backyard/username" = { };
    "go2rtc/backyard/password" = { };

  };

  systemd.services.go2rtc.serviceConfig.LoadCredential = [
    "FRONT_DOOR_USERNAME:${config.sops.secrets."go2rtc/front_door/username".path}"
    "FRONT_DOOR_PASSWORD:${config.sops.secrets."go2rtc/front_door/password".path}"
    "FRONT_PORCH_USERNAME:${config.sops.secrets."go2rtc/front_porch/username".path}"
    "FRONT_PORCH_PASSWORD:${config.sops.secrets."go2rtc/front_porch/password".path}"
    "BACKYARD_USERNAME:${config.sops.secrets."go2rtc/backyard/username".path}"
    "BACKYARD_PASSWORD:${config.sops.secrets."go2rtc/backyard/password".path}"
  ];

  sops.secrets."go2rtc/front_door/username".restartUnits = [ "go2rtc.service" ];
  sops.secrets."go2rtc/front_door/password".restartUnits = [ "go2rtc.service" ];
  sops.secrets."go2rtc/front_porch/username".restartUnits = [ "go2rtc.service" ];
  sops.secrets."go2rtc/front_porch/password".restartUnits = [ "go2rtc.service" ];
  sops.secrets."go2rtc/backyard/username".restartUnits = [ "go2rtc.service" ];
  sops.secrets."go2rtc/backyard/password".restartUnits = [ "go2rtc.service" ];

  services.go2rtc = {
    enable = true;
    settings = {
      ffmpeg.bin = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      streams = {
        front_door = [
          "rtsp://\${FRONT_DOOR_USERNAME}:\${FRONT_DOOR_PASSWORD}@192.168.40.221/h264Preview_01_sub"
          "ffmpeg:front_door#audio=opus#audio=copy"
        ];
        front_door_sub = "ffmpeg:https://192.168.40.221/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=\${FRONT_DOOR_USERNAME}&password=\${FRONT_DOOR_PASSWORD}";
        front_porch = "ffmpeg:rtsp://\${FRONT_PORCH_USERNAME}:\${FRONT_PORCH_PASSWORD}@192.168.40.2:554/cam/realmonitor?channel=1&subtype=0";
        front_porch_sub = "ffmpeg:rtsp://\${FRONT_PORCH_USERNAME}:\${FRONT_PORCH_PASSWORD}@192.168.40.2:554/cam/realmonitor?channel=1&subtype=1";
        backyard = "ffmpeg:https://192.168.40.236/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=\${BACKYARD_USERNAME}&password=\${BACKYARD_PASSWORD}#video=copy#audio=copy#audio=opus";
        backyard_sub = "ffmpeg:https://192.168.40.236/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=\${BACKYARD_USERNAME}&password=\${BACKYARD_PASSWORD}";

      };
      rtsp = {
        listen = ":8554";
      };
      webrtc = {
        listen = ":8555";
        candidates = [
          "streams.nanall.ac:8555"
          "192.168.1.109:8555"
          "192.168.1.186:8555"
          "stun:8555"
        ];
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 8554 8555 ];
    allowedUDPPorts = [ 8554 8555 ];
  };

  services.nginx.virtualHosts = {
    "streams.nanall.ac" = {
      forceSSL = true;
      useACMEHost = "nanall.ac";
      locations = {
        "/" = {
          proxyPass = "http://localhost${config.services.go2rtc.settings.api.listen}";
          proxyWebsockets = true;
        };
      };
    };
  };

}
