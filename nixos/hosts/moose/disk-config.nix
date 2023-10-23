{ lib, ... }:

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
							size = "64M";
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
    };
  };

	boot.initrd.postDeviceCommands = lib.mkAfter ''
		zfs rollback -r rpool/local/root@blank
	'';
}