{ lib, pkgs, ... }:

{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
				device = "/dev/nvme0n1";
				content = {
					type = "gpt";
					partitions = {
						ESP = {
							size = "512M";
							type = "EF00";
							content = {
								type = "filesystem";
								format = "vfat";
								mountpoint = "/boot";
							};
						};
				    rpool = {
				      size = "100%";
				      content = {
				        type = "zfs";
								pool = "rpool";
				      };
				    };
				  };
				};
			};
	    nvme1 = {
	      type = "disk";
				device = "/dev/nvme1n1";
				content = {
					type = "gpt";
					partitions = {
						rpool = {
							size = "100%";
							content = {
								type = "zfs";
								pool = "rpool";
		      		};
		    		};
		  		};
				};
      };
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WUH721816ALE6L4_2CGGGPHJ";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage0";
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WUH721816ALE6L4_2CK22XAN";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage0";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
				mode = "mirror";
				options = {
	  			ashift = "12";
	  			autotrim = "on";
				};
				rootFsOptions = {
				  acltype = "posixacl";
				  compression = "zstd";
				  dnodesize = "auto";
				  normalization = "formD";
				  relatime = "on";
				  xattr = "sa";
				  mountpoint = "none";
				  checksum = "edonr";
				};
				postCreateHook = "zfs snapshot rpool/local/root@blank";
				datasets = {
				  "local/root" = {
				    type = "zfs_fs";
				    mountpoint = "/";
				  };
				  "local/nix" = {
				    type = "zfs_fs";
						mountpoint = "/nix";
				    options = {
				      atime = "off";
				    };
				  };
				  "safe/home" = {
				    type = "zfs_fs";
						mountpoint = "/home";
				  };
				  "safe/keep" = {
				    type = "zfs_fs";
						mountpoint = "/keep";
				  };
				};
      };
      storage0 = {
        type = "zpool";
        mode = "mirror";
        options = {
          ashift = 12;
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "lz4";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          "com.sun:autosnapshot" = "false";
        };
        datasets = {
          "media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/storage0/media";
            options = {
              compression = "lz4";
              recordsize = "1M";
              atime = "off";
              relatime = "off";
              logbias = "throughput";
            };
          };
          # "nextcloud-data" = {
          #   type = "zfs_fs";
          #   mountpoint = "/mnt/storage0/nextcloud-data";
          #   options = {
          #     compression = "lz4";
          #     atime = "off";
          #     xattr = "sa";
          #     recordsize = "128K";
          #     mountpoint = "legacy";
          #     sync = "standard";
          #     dedup = "off";
          #   };
          # };
        };
      };
    };
  };

  boot.initrd.systemd.services.zfs_rollback_root = {
    description = "Rollback ZFS root to blank snapshot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    path = [ pkgs.zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zfs rollback -r rpool/local/root@blank";
    };
  };

  boot.zfs.forceImportRoot = true;

  fileSystems."/keep".neededForBoot = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
    autoSnapshot.enable = true;

    zed = {
      enableMail = true;
      settings = {
        ZED_EMAIL_ADDR = [ "josh@callanan.contact" ];
        ZED_NOTIFY_VERBOSE = true;
      };
    };
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
