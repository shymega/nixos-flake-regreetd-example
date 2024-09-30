# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config
, self
, hostAddress
, hostType
, pkgs
, system
, inputs
, lib
, embedHm
, hostRole
, specialArgs
, deployable
, hostname
, hostPlatform
, ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."dzrodriguez" = import ../../homes;
    extraSpecialArgs = {
      inherit
        hostAddress
        hostType
        pkgs
        config
        system
        self
        inputs
        lib
        embedHm
        hostRole
        specialArgs
        deployable
        hostname
        hostPlatform;
    };
  };
}
