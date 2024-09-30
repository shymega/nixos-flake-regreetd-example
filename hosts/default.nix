# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  lib = hostPlatform: inputs.nixpkgs.lib.extend
    (
      _final: prev: {
        my = import ../../lib {
          inherit self inputs;
          lib = prev;
          pkgs = genPkgs hostPlatform;
        };
      }
    ) // inputs.nixpkgs.lib;
  hasSuffix =
    suffix: content:
    let
      inherit (builtins) stringLength substring;
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix && substring (lenContent - lenSuffix) lenContent content == suffix;
  mkHost =
    { type ? "nixos"
    , address ? null
    , hostname ? null
    , hostPlatform ? "x86_64-linux"
    , username ? "dzrodriguez"
    , baseModules ? [
        inputs.agenix.nixosModules.default
        inputs.auto-cpufreq.nixosModules.default
        {
          environment.systemPackages = [
            inputs.agenix.packages.${hostPlatform}.default
            inputs.nix-alien.packages.${hostPlatform}.nix-alien
          ];
        }
        ../common
        inputs.nixfigs-secrets.system
      ]
    , monolithConfig ? true
    , overlays ? [ ]
    , hostRoles ? [ "workstation" ]
    , hardwareModules ? [ ]
    , extraModules ? [ ]
    , pubkey ? null
    , remoteBuild ? true
    , deployable ? false
    , embedHm ? false
    ,
    }:
    if type == "nixos" then
      assert address != null;
      assert (hasSuffix "linux" hostPlatform);
      {
        inherit
          address
          baseModules
          deployable
          embedHm
          extraModules
          hardwareModules
          hostPlatform
          hostRoles
          hostname
          monolithConfig
          overlays
          pubkey
          remoteBuild
          type
          username
          ;
      }
    else if type == "darwin" then
      assert pubkey != null && address != null;
      assert (hasSuffix "darwin" hostPlatform);
      {
        inherit
          address
          baseModules
          deployable
          extraModules
          hardwareModules
          hostPlatform
          hostname
          monolithConfig
          pubkey
          remoteBuild
          type
          username
          ;
      }
    else if type == "home-manager" then
      assert ((hasSuffix "linux" hostPlatform) || (hasSuffix "darwin" hostPlatform) && hostname == null);
      assert pubkey == null;
      {
        inherit
          deployable
          hostPlatform
          hostRoles
          hostname
          type
          username
          ;
      }
    else
      throw "unknown host type '${type}'";
in
{
  NEO-LINUX = mkHost rec {
    type = "nixos";
    address = "NEO-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "NEO-LINUX";
    hostPlatform = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "";
    embedHm = true;
    remoteBuild = true;
    deployable = false;
  };

  NEO-WSL = mkHost {
    type = "nixos";
    address = "NEO-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "NEO-WSL";
    hostRoles = [ "minimal" ];
    hostPlatform = "x86_64-linux";
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  NEO-JOVIAN = mkHost {
    type = "nixos";
    address = "NEO-JOVIAN.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "NEO-JOVIAN";
    hostPlatform = "x86_64-linux";
    embedHm = false;
    monolithConfig = true;
    hostRoles = [ "gaming" ];
    extraModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      inputs.chaotic.nixosModules.default
    ];
    pubkey = null;
    remoteBuild = true;
    deployable = false;
  };

  MORPHEUS-LINUX = mkHost rec {
    type = "nixos";
    address = "MORPHEUS-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "MORPHEUS-LINUX";
    hostPlatform = "x86_64-linux";
    embedHm = true;
    hardwareModules = [ inputs.hardware.nixosModules.gpd-win-max-2-2023 ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqOAfNq3lGPElJ0L6qAqQLDykRWsN9dE4sMZkD6YVKu";
    remoteBuild = true;
    deployable = true;
  };

  MORPHEUS-WSL = mkHost {
    type = "nixos";
    address = "MORPHEUS-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "MORPHEUS-WINDOWS";
    hostRoles = [ "minimal" ];
    hostPlatform = "x86_64-linux";
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqOAfNq3lGPElJ0L6qAqQLDykRWsN9dE4sMZkD6YVKu";
    remoteBuild = true;
    deployable = false;
  };

  MORPHEUS-JOVIAN = mkHost {
    type = "nixos";
    address = "MORPHEUS-JOVIAN.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "MORPHEUS-JOVIAN";
    hostPlatform = "x86_64-linux";
    embedHm = false;
    monolithConfig = true;
    hostRoles = [ "gaming" ];
    hardwareModules = [ inputs.hardware.nixosModules.gpd-win-max-2-2023 ];
    extraModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      inputs.chaotic.nixosModules.default
    ];
    pubkey = null;
    remoteBuild = true;
    deployable = false;
  };

  TWINS-LINUX = mkHost rec {
    type = "nixos";
    address = "TWINS-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "TWINS-LINUX";
    hostPlatform = "x86_64-linux";
    hardwareModules = [ inputs.hardware.nixosModules.lenovo-thinkpad-x270 ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  TWINS-WSL = mkHost {
    type = "nixos";
    address = "TWINS-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "TWINS-WINDOWS";
    hostRoles = [ "minimal" ];
    hostPlatform = "x86_64-linux";
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  TRINITY-JOVIAN = mkHost {
    type = "nixos";
    address = "TRINITY-JOVIAN.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "TRINITY-JOVIAN";
    hostPlatform = "x86_64-linux";
    embedHm = false;
    monolithConfig = true;
    hostRoles = [ "gaming" ];
    extraModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      inputs.chaotic.nixosModules.default
    ];
    pubkey = null;
    remoteBuild = true;
    deployable = false;
  };

  SMITH-LINUX = mkHost rec {
    type = "nixos";
    address = "SMITH-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "SMITH-LINUX";
    hostPlatform = "aarch64-linux";
    monolithConfig = false;
    hostRoles = [ "minimal" ];
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  GRDN-BED-UNIT = mkHost rec {
    type = "nixos";
    address = "GRDN-BED-UNIT.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "GRDN-BED-UNIT";
    hostPlatform = "aarch64-linux";
    hostRoles = [ "minimal" ];
    monolithConfig = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  DELTA-ZERO = mkHost {
    type = "nixos";
    address = "delta-zero.rodriguez.org.uk";
    hostname = "DELTA-ZERO";
    username = "dzrodriguez";
    monolithConfig = false;
    hostPlatform = "aarch64-linux";
    hostRoles = [ "server" ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
    remoteBuild = true;
    deployable = true;
  };

  DIAL-IN-RNET = mkHost {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    hostname = "DIAL-IN-RNET";
    username = "dzrodriguez";
    monolithConfig = false;
    hostPlatform = "aarch64-linux";
    hostRoles = [ "server" ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";
    remoteBuild = true;
    deployable = true;
  };

  MATRIX-LXC = mkHost {
    type = "nixos";
    address = "matrix.rodriguez.org.uk";
    hostname = "MATRIX-LXC";
    username = "dzrodriguez";
    monolithConfig = false;
    hostRoles = [ "server" ];
    hostPlatform = "x86_64-linux";
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  BUILDER-HYDRA-CONTAINER = mkHost {
    type = "nixos";
    address = "hydra.shymega.org.uk";
    hostname = "BUILDER-HYDRA-CONTAINER";
    username = "dzrodriguez";
    baseModules = [ inputs.agenix.nixosModules.default inputs.nixfigs-secrets.system ];
    monolithConfig = false;
    hostPlatform = "x86_64-linux";
    hostRoles = [ "server" ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  BUILDER-AGENT-CONTAINER = mkHost {
    type = "nixos";
    address = "builder.shymega.org.uk";
    hostname = "BUILDER-CONTAINER";
    username = "dzrodriguez";
    baseModules = [ inputs.agenix.nixosModules.default inputs.nixfigs-secrets.system ];
    monolithConfig = false;
    hostPlatform = "x86_64-linux";
    hostRoles = [ "server" ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  "dzrodriguez@x86_64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "x86_64-linux";
  };

  "dzrodriguez@aarch64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
  };

  DZR-OFFICE-BUSY-LIGHT-UNIT = mkHost rec {
    type = "nixos";
    address = "dzr-office-busy-light-unit.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    baseModules = [ ../common inputs.nixfigs-secrets.system ];
    hostPlatform = "armv6l-linux";
    remoteBuild = true;
    deployable = false;
    hostRoles = [ "minimal" ];
    monolithConfig = false;
    hostname = "DZR-OFFICE-BUSY-LIGHT-UNIT";
    extraModules = [
      ../nix/24.05-compat.nix
      (import ../nix/sd-image-pi0v1.nix {
        inherit inputs;
        lib = lib hostPlatform;
        pkgs = (lib hostPlatform).my.genPkgs hostPlatform;
      })
    ];
  };

  DZR-PETS-CAM-UNIT = mkHost rec {
    type = "nixos";
    address = "dzr-pets-cam-unit.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    baseModules = [ ../common inputs.nixfigs-secrets.system ];
    hostPlatform = "armv6l-linux";
    remoteBuild = true;
    deployable = false;
    hostRoles = [ "minimal" ];
    monolithConfig = false;
    hostname = "DZR-PETS-CAM-UNIT";
    extraModules = [
      ../nix/24.05-compat.nix
      (import ../nix/sd-image-pi0v1.nix {
        inherit inputs;
        lib = lib hostPlatform;
        pkgs = (lib hostPlatform).my.genPkgs hostPlatform;
      })
    ];
  };

  ### Experimental Device Ports ###
  ## ClockworkPi uConsole (CM4) ##
  # Received, Debian installed. Work ongoing to upstream DTB and driver patches. #
  CLOCKWORK-UC-CM4 = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "CLOCKWORK-UC-CM4";
    remoteBuild = true;
    deployable = false;
    monolithConfig = false;
    hostRoles = [ "minimal" ];
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };

  ## End ClockworkPi uConsole (CM4) ##

  ## ClockworkPi DevTerm (CM4) ##
  CLOCKWORK-DT-CM4 = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "CLOCKWORK-DT-CM4";
    hostRoles = [ "minimal" ];
    remoteBuild = true;
    deployable = false;
    monolithConfig = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };
  ## End ClockworkPi DevTerm (CM4) ##

  INSTALLER-SERVER-ISO-X86-64 = mkHost {
    type = "nixos";
    address = "install-server.shymega.org.uk";
    username = "dzrodriguez";
    hostPlatform = "x86_64-linux";
    hostname = "INSTALLER-SERVER-ISO-X86-64";
    hostRoles = [ "minimal" ];
    remoteBuild = false;
    deployable = false;
    monolithConfig = false;
    baseModules = [ ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../nix/24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  }; # TODO: Add Headscale as domain?

  INSTALLER-WORKSTATION-ISO-X86-64 = mkHost {
    type = "nixos";
    address = "install-workstation.shymega.org.uk";
    username = "dzrodriguez";
    hostPlatform = "x86_64-linux";
    hostname = "INSTALLER-WORKSTATION-ISO-x86-64";
    hostRoles = [ "minimal" ];
    remoteBuild = false;
    deployable = false;
    monolithConfig = false;
    baseModules = [ ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../nix/24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  }; # TODO: Add Headscale as domain?

  INSTALLER-SERVER-ISO-ARM = mkHost {
    type = "nixos";
    address = "install-server.shymega.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "INSTALLER-SERVER-ISO-ARM";
    hostRoles = [ "minimal" ];
    remoteBuild = false;
    deployable = false;
    monolithConfig = false;
    baseModules = [ ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../nix/24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  }; # TODO: Add Headscale as domain?

  INSTALLER-WORKSTATION-ISO-ARM = mkHost {
    type = "nixos";
    address = "install-workstation.shymega.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "INSTALLER-WORKSTATION-ISO-ARM";
    hostRoles = [ "minimal" ];
    remoteBuild = false;
    deployable = false;
    monolithConfig = false;
    baseModules = [ ];
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../nix/24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  }; # TODO: Add Headscale as domain?
}
