{ config, ... }:
{
  services.peertube-runner = {
    enable = true;
    instancesToRegister = {
      "videos.nanall.ac" = {
        registrationTokenFile = config.sops.secrets.videos-nanall-ac.path;
        runnerDescription = "moose";
        runnerName = "moose";
        url = "https://videos.nanall.ac";
      };
    };
  };

  sops.secrets = {
    videos-nanall-ac = {
    mode = "0600";
    owner = config.services.peertube-runner.user;
    group = config.services.peertube-runner.group;
  };
};

}
