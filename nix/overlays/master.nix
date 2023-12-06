{ inputs, lib, ... }:
final: prev: {
  master = import inputs.nixpkgs-master {
    inherit (prev) system;
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays =
      let
        importMasterOverlay = overlay:
          lib.composeExtensions
            (_: _: { __inputs = inputs; })
            (import (./master + "/${overlay}"));

        masterOverlays =
          lib.mapAttrs'
            (overlay: _: lib.nameValuePair
              (lib.removeSuffix ".nix" overlay)
              (importMasterOverlay overlay))
            (builtins.readDir ./master);
      in
      lib.attrValues masterOverlays;
  };
}
