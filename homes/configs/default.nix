# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs
, pkgs
, config
, username
, system
, osConfig ? null
, self
, lib
, libx
, ...
}:
let
  inherit (libx) isPC homePrefix;
  getHomeDirectory = username: homePrefix + "/${username}";
  homeDirectory = getHomeDirectory username;
in
{
  imports = [
    ./network-targets.nix
    (import ./programs/rofi.nix { inherit lib pkgs; })
    inputs.agenix.homeManagerModules.default
    inputs.nix-doom-emacs-unstraightened.hmModule
    inputs.nix-index-database.hmModules.nix-index
    inputs._1password-shell-plugins.hmModules.default
    inputs.shypkgs-public.hmModules.${system}.dwl

    inputs.nixfigs-secrets.user
    ({ config, ... }: {
      nixpkgs.config = self.nixpkgs-config;
    })
  ];

  nix =
    if osConfig == null then {
      settings = rec {
        substituters = [
          "https://attic.mildlyfunctional.gay/nixbsd?priority=50"
          "https://beam.attic.rs/riscv?priority=50"
          "https://cache.dataaturservice.se/spectrum/?priority=50"
          "https://cache.nixos.org/?priority=10"
          "https://cache.saumon.network/proxmox-nixos/?priority=50"
          "https://deckcheatz-nightlies.cachix.org/?priority=10"
          "https://deploy-rs.cachix.org/?priority=10"
          "https://devenv.cachix.org/?priority=5"
          "https://nix-community.cachix.org/?priority=5"
          "https://nix-gaming.cachix.org/?priority=5"
          "https://nix-on-droid.cachix.org/?priority=5"
          "https://numtide.cachix.org/?priority=5"
          "https://pre-commit-hooks.cachix.org/?priority=5"
          "ssh://eu.nixbuild.net?priority=50"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "deckcheatz-nightlies.cachix.org-1:ygkraChLCkqqirdkGjQ68Y3LgVrdFB2bErQfj5TbmxU="
          "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
          "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
          "nixbsd:gwcQlsUONBLrrGCOdEboIAeFq9eLaDqfhfXmHZs1mgc="
          "nixbuild.net/VNUM6K-1:ha1G8guB68/E1npRiatdXfLZfoFBddJ5b2fPt3R9JqU="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
          "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
        ];
        binary-caches = substituters;
        builders-use-substitutes = true;
        http-connections = 128;
        max-substitution-jobs = 128;
      };
      extraOptions = ''
        builders = @/etc/nix/machines
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
    } else {
      settings = {
        inherit (osConfig.nix.settings) substituters trusted-public-keys builders-use-substitutes http-connections max-substitution-jobs;
      };
      extraOptions = ''
        builders = @/etc/nix/machines
        !include ${config.age.secrets.nix_conf_access_tokens.path}
      '';
    };

  home = {
    inherit username homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "24.05";
    packages =
      with pkgs.unstable;
      [
        (isync.override { withCyrusSaslXoauth2 = true; })
        alpaca
        android-studio-for-platform
        android-tools
        ansible
        b4
        bat
        bc
        beeper
        brightnessctl
        cloudflared
        cocogitto
        curl
        dateutils
        devenv
        dex
        diesel-cli
        difftastic
        distrobox
        dogdns
        elf2uf2-rs
        encfs
        exiftool
        expect
        eza
        firefox
        fuse
        fzf
        gnumake
        gpicview
        httpie
        hub
        hut
        imagemagick
        inetutils
        itd
        jdk17
        jq
        khal
        khard
        m4
        maven
        mkcert
        modem-manager-gui
        moneydance
        mpc-cli
        mupdf
        ncmpcpp
        networkmanagerapplet
        nixpkgs-fmt
        nodejs
        notmuch
        p7zip
        parallel
        pass
        pavucontrol
        pdftk
        poetry
        poppler_utils
        pre-commit
        public-inbox
        python3Full
        python3Packages.pip
        python3Packages.pipx
        python3Packages.virtualenv
        q
        ranger
        rclone
        reuse
        ripgrep
        rustup
        scrcpy
        speedtest-go
        starship
        statix
        step-cli
        stow
        texlive.combined.scheme-full
        timewarrior
        tmuxp
        unrar
        unzip
        vdirsyncer
        virt-manager
        virtiofsd
        vlc
        w3m
        weechatWithMyPlugins
        wezterm
        wget
        xsv
        zathura
        zellij
        zenmonitor
        zip
        zoxide
      ]
      ++ [ inputs.agenix.packages.${system}.default ]
      ++ (with pkgs; [
        ispell
        android-studio
        aws-sam-cli
        azure-cli
        bestool
        dosbox
        gitkraken
        google-chrome
        google-cloud-sdk
        leafnode
        lutris
        mpv
        neomutt
        protontricks
        protonup-qt
        qemu_full
        steamcmd
        totp
        wemod-launcher
        wineWowPackages.stable
        winetricks
        yubikey-manager-qt
        yubioath-flutter
      ])
      ++ (
        with pkgs;
        lib.optionals isPC (
          with pkgs.unstable.jetbrains;
          [
            clion
            datagrip
            gateway
            goland
            idea-ultimate
            phpstorm
            pycharm-professional
            rider
            ruby-mine
            rust-rover
            webstorm
          ]
        )
      );
  };

  services = {
    darkman = {
      enable = true;
      package = pkgs.unstable.darkman;
      settings = {
        usegeoclue = true;
      };
      darkModeScripts.gtk-theme = ''
        ${pkgs.dconf.outPath}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';

      lightModeScripts.gtk-theme = ''
        ${pkgs.dconf.outPath}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';
    };
    keybase.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage = with pkgs; lib.mkForce pinentry-gtk2;
      enableScDaemon = true;
      enableSshSupport = false;
      enableExtraSocket = true;
      defaultCacheTtl = 43200;
      maxCacheTtl = 43200;
    };
    gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };
    dunst.enable = true;
    mpd-discord-rpc.enable = true;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    emacs = {
      enable = true;
      client.enable = true;
      startWithUserSession = true;
      socketActivation.enable = true;
    };
    mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Multimedia/Music/";
      extraConfig = ''
        audio_output {
            type "pipewire"
            name "PipeWire Output"
        }
      '';
    };
    gammastep = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs.unstable; [
        gh
        awscli2
        cachix
        flyctl
      ];
    };
    bash.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    dwl = {
      enable = false;
      cmd = {
        terminal = "${pkgs.wezterm}/bin/wezterm";
        editor = "${pkgs.emacs}/bin/emacslient -cq";
      };
    };
    yt-dlp.enable = true;
    htop.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
      ];
    };
    atuin = {
      enable = true;
      package = pkgs.unstable.atuin;
      settings = {
        key_path = config.age.secrets.atuin_key.path;
        sync_address = "https://api.atuin.sh";
        auto_sync = true;
        dialect = "uk";
        secrets_filter = true;
        enter_accept = false;
        workspaces = true;
        sync_frequency = 1800;
        sync = {
          records = true;
        };
        daemon = {
          enabled = true;
          systemd_socket = true;
          sync_frequency = 1800;
        };
      };
    };
    nix-index-database.comma.enable = true;
    nix-index.enable = true;
    rbw.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        #        gpg.format = "ssh";
        #        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        #        commit.gpgsign = true;
      };
      aliases = {
        aa = "add --all";
        amend = "commit --amend";
        br = "branch";
        checkpoint = "stash --include-untracked; stash apply";
        cp = "checkpoint";
        cm = "commit -m";
        co = "checkout";
        dc = "diff --cached";
        dft = "difftool";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        lg = "log --graph --branches --oneline --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C";
        loc = "!git diff --stat `git hash-object -t tree /dev/null` | tail -1 | cut -d' ' -f5";
        st = "status -sb";
        sum = "log --oneline --no-merges";
        unstage = "reset --soft HEAD";
        revert = "revert --no-edit";
        squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} -m 'A new start');};f";
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
    doom-emacs = {
      enable = true;
      emacs = pkgs.unstable.emacs29-pgtk;
      provideEmacs = true;
      experimentalFetchTree = true;
      doomDir = inputs.nixfigs-doom-emacs;
      doomLocalDir = "${homeDirectory}/.local/state/doom";
    };
    taskwarrior = {
      enable = true;
      config = {
        report = {
          minimal.filter = "status:pending";
          active.columns = [
            "id"
            "start"
            "entry.age"
            "priority"
            "project"
            "due"
            "description"
          ];
          active.labels = [
            "ID"
            "Started"
            "Age"
            "Priority"
            "Project"
            "Due"
            "Description"
          ];
        };
      };
    };
  };
  news.display = "silent";

  systemd.user =
    let
      atuinDataDir = "${config.xdg.dataHome}/atuin";
      atuinSocket = "${atuinDataDir}/atuin.sock";
      atuinCommonConfig = {
        ConditionPathIsDirectory = atuinDataDir;
        ConditionPathExists = "${config.xdg.configHome}/atuin/config.toml";
      };
      taskwCommonConfig = {
        ConditionPathExists = "${config.xdg.configHome}/task/taskrc";
        ConditionPathIsDirectory = "${config.xdg.dataHome}/task";
      };
    in
    {
      timers = {
        atuin-sync = {
          Unit = atuinCommonConfig // {
            Description = "Atuin - Sync Service Timer";
          };
          Timer.OnCalendar = "*:0/30";
          Install.WantedBy = [ "timers.target" ];
        };
        task-sync = {
          Unit = taskwCommonConfig // {
            Description = "Taskwarrior auto sync timer";
          };
          Timer.OnCalendar = "*:0/30";
          Install.WantedBy = [ "timers.target" ];
        };
      };
      sessionVariables = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        QT_QPA_PLATFORM = "wayland;xcb";
        MOZ_ENABLE_WAYLAND = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
      tmpfiles.rules = [ "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" ];
      sockets.atuin-daemon = {
        Unit = atuinCommonConfig // {
          Description = "Atuin - Magical Shell History Daemon Socket";
        };
        Install.WantedBy = [ "default.target" ];
        Socket = {
          ListenStream = atuinSocket;
          Accept = false;
          RemoveOnStop = true;
          SocketMode = [ "0600" ];
        };
      };
      services = {
        polkit-gnome-authentication-agent-1 = {
          Unit = {
            Description = "polkit-gnome-authentication-agent-1";
          };
          Install.WantedBy = [ "default.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        atuin-sync = {
          Unit = atuinCommonConfig // {
            Description = "Atuin - Sync Service";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.unstable.atuin}/bin/atuin sync";
          };
        };
        task-sync = {
          Unit = taskwCommonConfig // {
            Description = "Taskwarrior auto sync service";
          };
          Service = {
            Type = "oneshot";
            ExecStartPre = "${pkgs.taskwarrior}/bin/task";
            ExecStart = "${pkgs.taskwarrior}/bin/task sync";
            ExecStartPost = "${pkgs.taskwarrior}/bin/task sync";
          };
        };
        atuin-daemon = {
          Unit = atuinCommonConfig // {
            Requires = [ "atuin-daemon.socket" ];
            Description = "Atuin - Magical Shell History Daemon";

          };
          Service = {
            ExecStart = "${pkgs.unstable.atuin}/bin/atuin daemon";
          };
        };
      };
    };

  xdg = {
    enable = true;
    portal = {
      config = {
        sway = {
          default = [ "wlr" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
        };
      };
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
      xdgOpenUsePortal = true;
    };
  };
}
