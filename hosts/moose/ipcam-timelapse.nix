# modules/timelapse.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ipCameraTimelapse;

  # Script to capture a single frame
  captureScript = camera: pkgs.writeShellScript "capture-frame-${camera.name}" ''
    set -euo pipefail

    CAMERA_NAME="${camera.name}"
    CAMERA_URL="${camera.url}"
    OUTPUT_DIR="${cfg.storageDir}/frames/$CAMERA_NAME"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    FILENAME="$OUTPUT_DIR/$TIMESTAMP.jpg"

    mkdir -p "$OUTPUT_DIR"

    ${pkgs.ffmpeg}/bin/ffmpeg \
      -y \
      -rtsp_transport tcp \
      -i "$CAMERA_URL" \
      -frames:v 1 \
      -q:v 2 \
      "$FILENAME"

    echo "Captured frame: $FILENAME"
  '';

  # Script to compile weekly timelapse
  compileWeeklyScript = camera: pkgs.writeShellScript "compile-weekly-${camera.name}" ''
    set -euo pipefail

    CAMERA_NAME="${camera.name}"
    FRAMES_DIR="${cfg.storageDir}/frames/$CAMERA_NAME"
    OUTPUT_DIR="${cfg.storageDir}/timelapse/$CAMERA_NAME/weekly"

    mkdir -p "$OUTPUT_DIR"

    # Get the date range for last week
    WEEK_START=$(date -d "last monday -7 days" +%Y%m%d)
    WEEK_END=$(date -d "last sunday" +%Y%m%d)
    OUTPUT_FILE="$OUTPUT_DIR/week_''${WEEK_START}_to_''${WEEK_END}.mp4"

    # Check if we already have this week's timelapse
    if [ -f "$OUTPUT_FILE" ]; then
      echo "Weekly timelapse already exists: $OUTPUT_FILE"
      exit 0
    fi

    # Create a temporary file list
    TEMP_LIST=$(mktemp)
    trap "rm -f $TEMP_LIST" EXIT

    # Find all frames from last week
    find "$FRAMES_DIR" -name "*.jpg" -type f | \
      sort | \
      while read -r file; do
        echo "file '$file'" >> "$TEMP_LIST"
      done

    if [ ! -s "$TEMP_LIST" ]; then
      echo "No frames found for week $WEEK_START to $WEEK_END"
      exit 0
    fi

    ${pkgs.ffmpeg}/bin/ffmpeg \
      -f concat \
      -safe 0 \
      -i "$TEMP_LIST" \
      -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fps=${toString cfg.weeklyFps}" \
      -c:v libx264 \
      -preset ${cfg.ffmpegPreset} \
      -crf 23 \
      "$OUTPUT_FILE"

    echo "Created weekly timelapse: $OUTPUT_FILE"
  '';

  # Script to compile rolling 6-month timelapse
  compileRollingScript = camera: pkgs.writeShellScript "compile-rolling-${camera.name}" ''
    set -euo pipefail

    CAMERA_NAME="${camera.name}"
    FRAMES_DIR="${cfg.storageDir}/frames/$CAMERA_NAME"
    OUTPUT_DIR="${cfg.storageDir}/timelapse/$CAMERA_NAME"
    OUTPUT_FILE="$OUTPUT_DIR/rolling_6months.mp4"

    mkdir -p "$OUTPUT_DIR"

    # Get date 6 months ago
    SIX_MONTHS_AGO=$(date -d "6 months ago" +%Y%m%d)

    # Create a temporary file list
    TEMP_LIST=$(mktemp)
    trap 'rm -f $TEMP_LIST' EXIT

    # Find frames from the last 6 months, sample every Nth frame for performance
    find "$FRAMES_DIR" -name "*.jpg" -type f -newermt "6 months ago" | \
      sort | \
      ${pkgs.gawk}/bin/awk "NR % ${toString cfg.rollingSampleRate} == 0" | \
      while read -r file; do
        echo "file '$file'" >> "$TEMP_LIST"
      done

    if [ ! -s "$TEMP_LIST" ]; then
      echo "No frames found for the last 6 months"
      exit 0
    fi

    ${pkgs.ffmpeg}/bin/ffmpeg \
      -y \
      -f concat \
      -safe 0 \
      -i "$TEMP_LIST" \
      -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fps=${toString cfg.rollingFps}" \
      -c:v libx264 \
      -preset ${cfg.ffmpegPreset} \
      -crf 23 \
      "$OUTPUT_FILE"

    echo "Created rolling 6-month timelapse: $OUTPUT_FILE"
  '';

  # Cleanup script
  cleanupScript = camera: pkgs.writeShellScript "cleanup-${camera.name}" ''
    set -euo pipefail

    CAMERA_NAME="${camera.name}"
    FRAMES_DIR="${cfg.storageDir}/frames/$CAMERA_NAME"

    echo "Cleaning up old frames for $CAMERA_NAME..."

    # Delete frames older than retention period
    find "$FRAMES_DIR" -name "*.jpg" -type f -mtime +${toString cfg.retentionDays} -delete

    # Check disk usage if configured
    ${optionalString (cfg.maxDiskUsagePercent != null) ''
      DISK_USAGE=$(df -h "${cfg.storageDir}" | awk 'NR==2 {print $5}' | sed 's/%//')

      if [ "$DISK_USAGE" -gt ${toString cfg.maxDiskUsagePercent} ]; then
        echo "Disk usage at $DISK_USAGE%, removing oldest frames..."
        # Delete oldest 10% of frames
        find "$FRAMES_DIR" -name "*.jpg" -type f -printf '%T+ %p\n' | \
          sort | \
          head -n $(( $(find "$FRAMES_DIR" -name "*.jpg" -type f | wc -l) / 10 )) | \
          cut -d' ' -f2- | \
          xargs -r rm -f
      fi
    ''}

    echo "Cleanup complete for $CAMERA_NAME"
  '';

in {
  options.services.ipCameraTimelapse = {
    enable = mkEnableOption "IP Camera Timelapse Generator";

    user = mkOption {
      type = types.str;
      default = "ipcam-timelapse";
      description = "User account under which the timelapse services run";
    };

    group = mkOption {
      type = types.str;
      default = "ipcam-timelapse";
      description = "Group under which the timelapse services run";
    };

    cameras = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Camera name (used in filenames and directories)";
            example = "frontdoor";
          };

          url = mkOption {
            type = types.str;
            description = "Camera RTSP/HTTP URL";
            example = "rtsp://username:password@192.168.1.100:554/stream1";
          };

          captureInterval = mkOption {
            type = types.str;
            default = "*:0/5";  # Every 5 minutes
            description = "Systemd timer OnCalendar format for capture frequency";
          };
        };
      });
      default = [];
      description = "List of IP cameras to monitor";
    };

    storageDir = mkOption {
      type = types.path;
      default = "/var/lib/timelapse";
      description = "Base directory for storing frames and videos";
    };

    weeklyCompileSchedule = mkOption {
      type = types.str;
      default = "Mon *-*-* 01:00:00";
      description = "When to compile weekly timelapses (systemd OnCalendar format)";
    };

    rollingCompileSchedule = mkOption {
      type = types.str;
      default = "daily";
      description = "When to compile rolling 6-month timelapse (systemd OnCalendar format)";
    };

    cleanupSchedule = mkOption {
      type = types.str;
      default = "daily";
      description = "When to run cleanup (systemd OnCalendar format)";
    };

    retentionDays = mkOption {
      type = types.int;
      default = 190;  # ~6 months + buffer
      description = "How many days to retain raw frames";
    };

    maxDiskUsagePercent = mkOption {
      type = types.nullOr types.int;
      default = 85;
      description = "Maximum disk usage percentage before aggressive cleanup";
    };

    weeklyFps = mkOption {
      type = types.int;
      default = 30;
      description = "Frames per second for weekly timelapses";
    };

    rollingFps = mkOption {
      type = types.int;
      default = 30;
      description = "Frames per second for rolling timelapse";
    };

    rollingSampleRate = mkOption {
      type = types.int;
      default = 10;
      description = "Sample every Nth frame for rolling timelapse (to reduce processing)";
    };

    ffmpegPreset = mkOption {
      type = types.enum [ "ultrafast" "superfast" "veryfast" "faster" "fast" "medium" "slow" "slower" "veryslow" ];
      default = "medium";
      description = "FFmpeg encoding preset";
    };
  };

  config = mkIf cfg.enable {
    # Create user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "IP Camera Timelapse service user";
      home = cfg.storageDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};


    # Create the storage directory
    systemd.tmpfiles.rules = [
      "d ${cfg.storageDir} 0755 ${cfg.user} ${cfg.group} -"
    ] ++ (map (camera: "d ${cfg.storageDir}/frames/${camera.name} 0755 ${cfg.user} ${cfg.group} -") cfg.cameras)
      ++ (map (camera: "d ${cfg.storageDir}/timelapse/${camera.name} 0755 ${cfg.user} ${cfg.group} -") cfg.cameras);

    # Create capture services and timers for each camera
    systemd.services = listToAttrs (
      map (camera: {
        name = "timelapse-capture-${camera.name}";
        value = {
          description = "Capture frame from ${camera.name}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${captureScript camera}";
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-weekly-${camera.name}";
        value = {
          description = "Compile weekly timelapse for ${camera.name}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${compileWeeklyScript camera}";
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-rolling-${camera.name}";
        value = {
          description = "Compile rolling 6-month timelapse for ${camera.name}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${compileRollingScript camera}";
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-cleanup-${camera.name}";
        value = {
          description = "Cleanup old frames for ${camera.name}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${cleanupScript camera}";
          };
        };
      }) cfg.cameras
    );

    systemd.timers = listToAttrs (
      map (camera: {
        name = "timelapse-capture-${camera.name}";
        value = {
          description = "Timer for capturing frames from ${camera.name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = camera.captureInterval;
            Persistent = true;
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-weekly-${camera.name}";
        value = {
          description = "Timer for weekly timelapse compilation of ${camera.name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.weeklyCompileSchedule;
            Persistent = true;
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-rolling-${camera.name}";
        value = {
          description = "Timer for rolling timelapse compilation of ${camera.name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.rollingCompileSchedule;
            Persistent = true;
          };
        };
      }) cfg.cameras
      ++
      map (camera: {
        name = "timelapse-cleanup-${camera.name}";
        value = {
          description = "Timer for cleanup of ${camera.name}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.cleanupSchedule;
            Persistent = true;
          };
        };
      }) cfg.cameras
    );
  };
}
