# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib, ... }:
{
  boot.kernelParams = lib.mkAfter [
    "loglevel=3"
    "quiet"
    "rd.udev.log_level=3"
    "splash"
    "systemd.show_status=auto"
    "systemd.unified_cgroup_hierarchy=1"
  ];
}
