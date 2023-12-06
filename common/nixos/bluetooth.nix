# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ config, ... }: {
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };
}
