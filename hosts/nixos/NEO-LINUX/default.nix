# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
let
  enableXanmod = false;
in
{
  environment.etc."crypttab".text = ''
    homecrypt /dev/disk/by-label/HOMECRYPT /persist/etc/.homecrypt.bin
  '';
  networking.hostName = "NEO-LINUX";
  networking.hostId = "7f9080b5";
  time.timeZone = "Europe/London";

  boot = {
    supportedFilesystems = [ "ntfs" "zfs" ];

    kernelPackages = if enableXanmod then
      pkgs.linuxPackages_xanmod_latest
    else
      config.boot.zfs.package.latestCompatibleLinuxPackages;
    
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    extraModprobeConfig = ''
      options kvm_amd nested=1
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    zfs.devNodes = "/dev/NEO-LINUX/ROOT";

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };

    initrd.luks.devices = {
      nixos = {
        device = "/dev/disk/by-label/NIXOS";
        preLVM = true;
        allowDiscards = true;
      };
    };

    plymouth = {
      enable = true;
      themePackages = with pkgs; [ breeze-plymouth ];
      theme = "breeze";
    };

    loader = {
      systemd-boot = {
        enable = false;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        device = "nodev";
        efiSupport = true;
        default = "saved";
        enable = true;
        useOSProber = true;
      };
      timeout = 6;
    };

    initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
        "zfs-import-tank.service"
      ];
      before = [
        "sysroot.mount"
      ];
      path = with pkgs; [
        zfs
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r tank/local/root@blank && echo "rollback complete"
      '';
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = false;
      extraPackages = pkgs.lib.mkForce (with pkgs; [
        amdvlk
      ]);
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    package = pkgs.unstable.ollama;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # 680M.
      #          HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
    zfs = {
      trim = {
        enable = true;
        interval = "Sat *-*-* 04:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sat *-*-* 05:00:00";
      };
    };
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
  };

  programs.steam = {
    enable = false;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };
}
