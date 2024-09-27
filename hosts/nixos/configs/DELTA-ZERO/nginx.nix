{ config, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  # Grant nginx access to certificates
  systemd.services.nginx.serviceConfig.SupplementaryGroup = [ "acme" ];

  # Reload nginx after certificate renewal
  security.acme.defaults.reloadServices = [ "nginx.service" ];

  services.nginx = {
    enable = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    clientMaxBodySize = config.services.matrix-synapse.settings.max_upload_size;
    virtualHosts = {
      "matrix.rodriguez.org.uk" = import ./matrix-nginx.nix;
    };
  };
}
