{ config, pkgs, ... }:

let
  domain = "${config.networking.domain}";
  url = "videos.${domain}";
in
{
  sops.secrets = {
    "peertube/secrets/secretsFile" = {
      owner = config.services.peertube.user;
      group = config.services.peertube.group;
      mode = "0440";
    };
    "peertube/database/passwordFile" = {
      owner = config.services.peertube.user;
      group = config.services.peertube.group;
      mode = "0440";
    };
    "peertube/smtp/passwordFile" = {
      owner = config.services.peertube.user;
      group = config.services.peertube.group;
      mode = "0440";
    };
  };

  services.peertube = {
    enable = true;
    enableWebHttps = true;
    localDomain = url;
    listenWeb = 443;
    settings = {
      listen.hostname = "0.0.0.0";
      instance.name = "nanall.ac videos";
      menu.login.redirect_on_single_external_auth = true;
      log.level = "debug";
      object_storage = {
        enabled = true;
        endpoint = "s3.us-west-000.backblazeb2.com";
        max_upload_part = "10MB";
        upload_acl = {
          public = "public-read";
          private = "private";
        };
        max_request_attempts = 3;
        web_videos = {
          bucket_name = "videos-nanall-ac";
          prefix = "web-videos/";
        };
        original_video_files = {
          bucket_name = "videos-nanall-ac";
          prefix = "original-video-files/";
        };
        streaming_playlists= {
          bucket_name = "videos-nanall-ac";
          prefix = "streaming-playlists/";
        };
        credentials = {
          access_key_id = "0006150d456e59a000000000b";
          secret_access_key = "K000XA3neNS3oormM3uC1OVaebXhiRI";
        };
      };
    };
    secrets.secretsFile = config.sops.secrets."peertube/secrets/secretsFile".path;
    redis.createLocally = true;
    database.createLocally = true;
    database.passwordFile = config.sops.secrets."peertube/database/passwordFile".path;
    smtp.createLocally = true;
    smtp.passwordFile = config.sops.secrets."peertube/smtp/passwordFile".path;
    configureNginx = true;
  };

  services.nginx.virtualHosts."${url}" = {
    useACMEHost = config.networking.domain;
    forceSSL = true;
  };

  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
}
