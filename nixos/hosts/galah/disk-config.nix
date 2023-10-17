{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
	device = "/dev/nvme0n1";
	content = {
	  type = "gpt";
	  partitions = {
	    BOOT = {
	      size = "1M";
	      type = "EF02";
	    };
	    ESP = {
	      size = "500M";
	      type = "EF00";
	      content = {
	        type = "filesystem";
		format = "vfat";
	      };
	    };
	    bpool = {
	      size = "4G";
	      type = "BE00";
	      content = {
	        type = "zfs";
		pool = "bpool";
	      };
	    };
	    rpool = {
	      size = "100%";
	      type = "BF00";
	      content = {
	        type = "zfs";
		pool = "rpool";
	      };
	    };
	    swap = {
	      size = "2G";
	      content = {
	        type = "swap";
		randomEncryption = true;
		resumeDevice = false;
	      };
	    };
	  };
	};
      };
      nvme1n1 = {
        type = "disk";
	device = "/dev/nvme0n1";
	content = {
	  type = "gpt";
	  partitions = {
	    BOOT = {
	      size = "1M";
	      type = "EF02";
	    };
	    ESP = {
	      size = "500M";
	      type = "EF00";
	      content = {
	        type = "filesystem";
		format = "vfat";
	      };
	    };
	    bpool = {
	      size = "4G";
	      type = "BE00";
	      content = {
	        type = "zfs";
		pool = "bpool";
	      };
	    };
	    rpool = {
	      size = "100%";
	      type = "BF00";
	      content = {
	        type = "zfs";
		pool = "rpool";
	      };
	    };
	    swap = {
	      size = "2G";
	      content = {
	        type = "swap";
		randomEncryption = true;
		resumeDevice = false;
	      };
	    };
	  };
	};
      };
    };
    zpool = {
      bpool = {
        type = "zpool";
	mode = "mirror";
	options = {
	  compatibility = "grub2";
	  ashift = 12;
	  autotrim = "on";
	};
	rootFsOptions = {
	  compression = "lz4";
	  acltype = "posixacl";
	  devices = "off";
	  normalization = "formD";
	  relatime = "on";
	  xattr = "sa";
	  mountpoint = "none";
	  checkum = "sha256";
	};
	mountpoint = "/boot";
	datasets = {
	  "bpool/local/boot" = {
	    type = "zfs_fs";
	    mountpoint = "/boot";
	  };
	};
      };
      rpool = {
        type = "zpool";
	mode = "mirror";
	options = {
	  ashift = 12;
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
	mountpoint = "/";
	postCreateHook = ''
	  zfs snapshot rpool/local/usr@SYSINIT
	  zfs snapshot rpool/local/var@SYSINIT'';
	datasets = {
	  "rpool/local" = {
	    type = "zfs_fs";
	    mountpoint = "/";
	  };
	  "rpool/safe/home" = {
	    type = "zfs_fs";
	  };
	  "rpool/local/nix" = {
	    type = "zfs_fs";
	    options = {
	      atime = "off";
	    };
	  };
	  "rpool/local/usr" = {
            type = "zfs_fs";
          };
	  "rpool/local/var" = {
	    type = "zfs_fs";
	  };
	  "rpool/safe/keep" = {
	    type = "zfs_fs";
	  };
	};
      };
    };
  };
}