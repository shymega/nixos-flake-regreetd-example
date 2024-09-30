# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkNixosConfig =
    { system ? "x86_64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/nixos
        ../common/core
      ]
    , hardwareModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = import nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = {
          allowUnfree = true;
          allowBroken = false;
          allowInsecure = false;
          allowUnsupportedSystem = false;
        };
      };
      modules = [
        inputs.agenix.nixosModules.default
        inputs.nix-ld.nixosModules.nix-ld
        {
          environment.systemPackages = [
            inputs.agenix.packages.${system}.default
          ];
        }
        ../secrets
        (../hosts/nixos + "/${hostname}")
        (../hosts/nixos + "/${hostname}" + "/hardware-configuration.nix")
      ] ++ baseModules ++ hardwareModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs hostname system; };
    };
in
{
  ### Personal Devices ####

  ### Desktops ###

  ## Desktop (Beelink SER6 Pro) ##

  NEO-LINUX = mkNixosConfig {
    hostname = "NEO-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  ## End Desktop (Beelink SER6 Pro) ##

  ## Raspberry Pi - desk ##

  SMITH-LINUX = mkNixosConfig {
    hostname = "SMITH-LINUX";
    system = "aarch64-linux";
    baseModules = [ ];
    hardwareModules = [
      inputs.hardware.nixosModules.raspberry-pi-4
    ];
  };

  ## End Raspberry Pi - desk ##

  ### UMPC devices ###

  ## UMPC (GPD Pocket 3 (i7)) ##

  TRINITY-LINUX = mkNixosConfig {
    hostname = "TRINITY-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.gpd-pocket-3
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  ## End UMPC (GPD P3) ##

  ## Gaming Handheld (GPD Win Max 2 (2023)) ##
  ## TO BE ADDED. ##
  ## End Gaming Handheld (GPD Win Max 2 (2023) ##

  ### End UMPC devices ###

  # Laptop (ThinkPad X270) ##

  TWINS-LINUX = mkNixosConfig {
    hostname = "TWINS-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.lenovo-thinkpad-x270
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  # End Laptop (ThinkPad X270) ##

  GRDN-BED-UNIT = mkNixosConfig {
    hostname = "GRDN-BED-UNIT";
    system = "aarch64-linux";
    baseModules = [ ];
    hardwareModules = [
      inputs.hardware.nixosModules.raspberry-pi-4
    ];
  };

  ### Handhelds ###

  ## Gaming Handheld (Steam Deck (OLED/1TB)) ##
  ## TO BE ADDED. ##
  ## End Gaming Handheld (Steam Deck (OLED/1TB)) ##

  ### End Handhelds ###

  ### Experimental Device Ports ###

  ## RISC-V Experimental Tablet (Pine64 PineTab2-V) ##
  ## TO BE ADDED. ##
  ## End RISC-v Experimental Tablet (Pine64 PineTab2-V) ##

  ## ARM64 Experimental Tablet (Pine64 PineTab2 ARM64) ##
  ## TO BE ADDED. ##
  ## End ARM64 Experimental Tablet (Pine64 PineTab2 ARM) ##

  ## ClockworkPi uConsole (CM4) ##
  # Received, Debian installed. Work ongoing to upstream DTB and driver patches. #
  ## End ClockworkPi uConsole (CM4) ##

  ## ClockworkPi DevTerm (CM4) ##
  ## TO BE ADDED. ##
  ## End ClockworkPi DevTerm (CM4) ##

  ### End Experimental Device Ports ###
}
