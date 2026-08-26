{ config, ... }:

{
  services.pinchflat = {
    enable = true;
    openFirewall = true;
    selfhosted = true;
  };

  systemd.services.pinchflat = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/pinchflat/media - - - - /mnt/media/media/youtube"
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
