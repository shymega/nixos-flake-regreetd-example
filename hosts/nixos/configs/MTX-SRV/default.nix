# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs
, lib
, config
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./synapse.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  time.timeZone = "Europe/London";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    cloudflared = {
      enable = true;
      package = pkgs.unstable.cloudflared;
      tunnels = {
        "5da5dbaf-7519-466b-bc94-49ad85cbf05d" = {
          ingress = {
            "ssh.mtx.shymega.org.uk".service = "ssh://localhost:22";
          };
          credentialsFile = "/var/lib/cloudflared/5da5dbaf-7519-466b-bc94-49ad85cbf05d.json";
          default = "http_status:404";
        };
        "8b244c80-6329-4c5f-84c1-4c7e79e737da" = {
          ingress = {
            "mtx.shymega.org.uk".service = "http://localhost:8008";
          };
          credentialsFile = "/var/lib/cloudflared/8b244c80-6329-4c5f-84c1-4c7e79e737da.json";
          default = "http_status:404";
        };
      };
    };
    dbus.enable = true;
    zerotierone.enable = true;
    tailscale.enable = true;
    cloud-init.enable = lib.mkForce false;
    fail2ban = {
      enable = true;
      maxretry = 2;
      ignoreIP = [
        "217.155.6.253"
        "2a02:8012:ade3:0:69c3:6693:9253:19c7"
      ];
      bantime = "30m";
      bantime-increment.enable = true;
    };
    resolved = {
      enable = lib.mkForce false;
    };
  };

  networking = {
    hostName = "mtx";
    domain = "shymega.org.uk";
    environment.etc = {
      "resolv.conf".text = "nameserver 1.1.1.1\nnameserver 1.0.0..1";
    };
    resolvconf.enable = true;

    timeServers = lib.mkForce [ "uk.pool.ntp.org" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      checkReversePath = false;
      extraCommands = ''
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.21.244.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.22.200.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.31.4.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 104.16.0.0/13 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 104.24.0.0/14 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 108.162.192.0/18 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 131.0.72.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 141.101.64.0/18 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 162.158.0.0/15 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 172.64.0.0/13 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 173.245.48.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 188.114.96.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 190.93.240.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 197.234.240.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 198.41.128.0/17 -j ACCEPT
                	
        	        ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2400:cb00::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2405:8100::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2405:b500::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2606:4700::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2803:f800::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2a06:98c0::/29 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2c0f:f248::/32 -j ACCEPT
      '';
    };
  };

  systemd = {
    network = {
      enable = true;
      networks."10-hetzner" = {
        matchConfig.Name = "enp1s0";
        dns = [ "1.1.1.1" ];
        networkConfig.DHCP = "ipv4";
        address = [ "2a01:4f9:c012:6ea::1/64" ];
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
      };
    };
  };

  programs = {
    zsh.enable = true;
    fish.enable = true;
    mosh.enable = true;
  };

  system.stateVersion = "24.05";

  services.openssh.authorizedKeysFiles = lib.mkOverride 40 [
    "%h/.ssh/authorized_keys"
    "/etc/ssh/authorized_keys.d/%u"
  ];

  users = {
    mutableUsers = false;
    users = {
      "root".password = "!"; # Lock account.
      "dzrodriguez" = {
        isNormalUser = true;
        shell = pkgs.zsh;
        description = "Dom RODRIGUEZ";
        hashedPasswordFile = config.age.secrets.dzrodriguez.path;
        linger = true;
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
        extraGroups = [
          "i2c"
          "adbusers"
          "dialout"
          "disk"
          "docker"
          "input"
          "kvm"
          "libvirt"
          "libvirtd"
          "lp"
          "lpadmin"
          "networkmanager"
          "plugdev"
          "qemu-libvirtd"
          "scanner"
          "systemd-journal"
          "uucp"
          "video"
          "wheel"
        ];
      };
    };
  };
}
