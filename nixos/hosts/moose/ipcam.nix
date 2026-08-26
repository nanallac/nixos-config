{ config, pkgs, ... }:

{
  services.ipCameraTimelapse = {
    enable = true;

    cameras = [
      {
        name = "front_door";
        url = "rtsp://192.168.1.40:8554/front_door";
        captureInterval = "*:0/5";  # Every 5 minutes
      }
      {
        name = "backyard";
        url = "rtsp://192.168.1.40:8554/backyard";
        captureInterval = "*:0/5";  # Every 10 minutes
      }
    ];

    storageDir = "/var/lib/timelapse";

    # Compile weekly timelapses every Monday at 1 AM
    weeklyCompileSchedule = "Mon *-*-* 01:00:00";

    # Update rolling timelapse daily at 2 AM
    rollingCompileSchedule = "*-*-* 02:00:00";

    # Run cleanup daily at 3 AM
    cleanupSchedule = "*-*-* 03:00:00";

    # Keep frames for ~6.5 months
    retentionDays = 365;

    # Start aggressive cleanup at 85% disk usage
    maxDiskUsagePercent = 85;

    # Video settings
    weeklyFps = 30;
    rollingFps = 30;
    rollingSampleRate = 10;  # Use every 10th frame for rolling to keep file size reasonable

    ffmpegPreset = "medium";
  };
}
