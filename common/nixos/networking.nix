# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib
, libx
, self
, config
, pkgs
, inputs
, ...
}:
let
  inherit (libx) isNixOS;
  inherit (pkgs.lib) optionals hasSuffix optionalAttrs;
in
{
  networking.networkmanager = optionalAttrs (hasSuffix "-LINUX" config.networking.hostName) {
    dns = "systemd-resolved";
    unmanaged = [
      "iphone0"
      "android0"
    ];
    ensureProfiles.profiles = inputs.nixfigs-networks.networks.all;
    wifi.macAddress = "stable";
    wifi.powersave = true;
    enable = true;
    dispatcherScripts = optionals (isNixOS && hasSuffix "-LINUX" config.networking.hostName) [
      {
        source = "${self}/static/nixos/rootfs/etc/NetworkManager/dispatcher.d/05-wireless-toggle";
        type = "basic";
      }
      {
        source = "${self}/static/nixos/rootfs/etc/NetworkManager/dispatcher.d/10-net-targets";
        type = "basic";
      }
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
