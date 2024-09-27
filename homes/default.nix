# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, ... }:
let
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  inherit (inputs) self;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  genConfiguration =
    _hostname:
    { type
    , hostPlatform
    , username
    , ...
    }:
    let
      libx = import ../lib {
        inherit self inputs;
        inherit (inputs.nixpkgs) lib;
        pkgs = genPkgs hostPlatform;
      };
    in
    homeManagerConfiguration {
      pkgs = libx.genPkgs hostPlatform;
      modules = [
        ./configs
      ];
      extraSpecialArgs = {
        system = hostPlatform;
        hostType = type;
        pkgs = libx.genPkgs hostPlatform;
        inherit inputs username self libx;
      };
    };
in
inputs.nixpkgs.lib.mapAttrs genConfiguration (inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "home-manager") self.hosts)
