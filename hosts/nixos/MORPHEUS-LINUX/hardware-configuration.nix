# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "hid_apple"
    ];
    initrd.kernelModules = [ "dm-snapshot" "amdgpu" ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    resumeDevice = "/dev/disk/by-label/NIXOS_SWAP";
  };

  fileSystems = {
    "/" =
      {
        device = "tank/local/root";
        fsType = "zfs";
      };
    "/nix" =
      {
        device = "tank/local/nix";
        neededForBoot = true;
        fsType = "zfs";
      };
    "/persist" =
      {
        device = "tank/safe/persist";
        neededForBoot = true;
        fsType = "zfs";
      };
    "/var/log" =
      {
        device = "tank/safe/log";
        neededForBoot = true;
        fsType = "zfs";
      };
    "/etc/nixos" =
      {
        device = "tank/safe/nixos-config";
        neededForBoot = true;
        fsType = "zfs";
      };
    "/boot" = {
      device = "/dev/disk/by-label/ESP_NIXOS"; # Use Refind on /dev/disk/by-label/ESP_PRIMARY
      neededForBoot = true;
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-label/HOME";
      fsType = "xfs";
    };
    "/data" = {
      device = "/dev/disk/by-label/GAMES";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "ssd" ];
    };
    "/data/VMs" = {
      device = "/dev/disk/by-label/VMS";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "ssd" ];
    };
  };
  swapDevices = [{ device = "/dev/disk/by-label/NIXOS_SWAP"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}