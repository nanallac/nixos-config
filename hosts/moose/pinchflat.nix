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
    "d /keep/var/lib/pinchflat/db 0770 ${config.services.pinchflat.user} ${config.services.pinchflat.group} -"
    "d /keep/var/lib/pinchflat/logs 0770 ${config.services.pinchflat.user} ${config.services.pinchflat.group} -"
    "d /keep/var/lib/pinchflat/metadata 0770 ${config.services.pinchflat.user} ${config.services.pinchflat.group} -"
    "d /keep/var/lib/pinchflat/extras 0770 ${config.services.pinchflat.user} ${config.services.pinchflat.group} -"
    "d /keep/var/lib/pinchflat/tmp 0770 ${config.services.pinchflat.user} ${config.services.pinchflat.group} -"
    "L+ /keep/var/lib/pinchflat/media - - - - /mnt/storage0/media/youtube"
  ];

  systemd.services.pinchflat.unitConfig.RequiresMountsFor = "/var/lib/pinchflat";

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
