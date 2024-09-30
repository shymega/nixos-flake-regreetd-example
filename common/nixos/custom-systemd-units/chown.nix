# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
let
  inherit (config.networking) hostName;
in
{
  systemd = {
    services = {
      chown-data = lib.mkIf (hostName == "NEO-LINUX") {
        description = "Change permissions on /data";
        wantedBy = [ "multi-user.target" ];
        unitConfig = { RefuseManualStart = true; };
        serviceConfig.Type = "oneshot";
        script = ''
          	  chown -R 1000:100 /data
        '';
      };
    };
  };
}
