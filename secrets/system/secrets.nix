# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

let
  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  TWINS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAp9kcBykTqbYroj9akZ7s6qY7NsX9uHwZMv64dOKvV";
  MORPHEUS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMXwoQwm7t9/KXJG5L4gk+Q5DGccetgbxYfhtsbBbgS";
  MORPHEUS-WSL = "";

  DELTA-ZERO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
  DIAL-IN = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";
  MTX-SRV = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtVMEyJgGsd26adPAyjYooDIfD30Ps0DzVlt3NnWorA";
  MEROVINGIAN = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvg02OiUAzWqTAtV/d3damszdlwjSNLhrF1ACRrhX1s";

  personal-machines = [
    NEO-LINUX
    TWINS-LINUX
    MORPHEUS-LINUX
    MORPHEUS-WSL
  ];

  rnet-machines = [
    DELTA-ZERO
    DIAL-IN
    MEROVINGIAN
    MTX-SRV
  ];
in
{
  "cloudflare_dns_token.age".publicKeys = personal-machines ++ rnet-machines;
  "dzrodriguez.age".publicKeys = personal-machines ++ rnet-machines;
  "geoclue_url.age".publicKeys = personal-machines ++ rnet-machines;
  "matrix-sliding-sync-env.age".publicKeys = personal-machines ++ rnet-machines;
  "nix_conf_access_tokens.age".publicKeys = personal-machines ++ rnet-machines;
  "nixbuild_ssh_priv_key.age".publicKeys = personal-machines ++ rnet-machines;
  "nixbuild_ssh_pub_key.age".publicKeys = personal-machines ++ rnet-machines;
  "postfix_sasl_passwd.age".publicKeys = personal-machines ++ rnet-machines;
  "postfix_sender_relay.age".publicKeys = personal-machines ++ rnet-machines;
  "restic/env.age".publicKeys = personal-machines ++ rnet-machines;
  "restic/pw.age".publicKeys = personal-machines ++ rnet-machines;
  "restic/repo.age".publicKeys = personal-machines ++ rnet-machines;
  "synapse_secret.age".publicKeys = personal-machines ++ rnet-machines;
  "wireless.age".publicKeys = personal-machines ++ rnet-machines;
  "zerotier_networks.age".publicKeys = personal-machines ++ rnet-machines;
}
