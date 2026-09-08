{ config, ... }:

{
  users.groups.media = {
    gid = 973;
    members = [ "pinchflat" ];
  };

  services.pinchflat = {
    enable = true;
    openFirewall = true;
    selfhosted = true;
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/pinchflat/media - - - - /mnt/storage0/media/youtube"
  ];

  environment.persistence."/keep" = {
    directories = [
      {
        directory = "/var/lib/pinchflat";
        user = config.services.pinchflat.user;
        group = config.services.pinchflat.group;
        mode = "u=rwx,g=rwx,o=";
      }
    ];
  };
}
