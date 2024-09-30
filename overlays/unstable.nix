# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ inputs, lib, ... }:
_final: prev:
let
  importUnstableOverlay =
    overlay: lib.composeExtensions (_: _: { __inputs = inputs; }) (import (./unstable + "/${overlay}"));

  unstableOverlays = lib.mapAttrs'
    (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importUnstableOverlay overlay)
    )
    (builtins.readDir ./unstable);
in
{
  unstable = import inputs.nixpkgs-unstable {
    inherit (prev) system;
    config = inputs.self.nixpkgs-config;
    overlays = builtins.attrValues unstableOverlays;
  };
}
