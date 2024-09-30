# SPDX-FileCopyrightText: 2024 Various Authors <generic@example.com>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, ... }:
let
  adminEmail = "shymega2011@gmail.com";
in
{
  security.acme = {
    defaults = {
      email = adminEmail;
      dnsProvider = "cloudflare";
      credentialFiles = {
        CLOUDFLARE_API_KEY_FILE = config.age.secrets.cloudflare_dns_token.path;
      };
    };
    acceptTerms = true;
  };
}
