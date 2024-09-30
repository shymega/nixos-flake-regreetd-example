# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk

#
# SPDX-License-Identifier: GPL-3.0-only

{
  nixConfig = {
    extra-trusted-substituters = [
      "https://attic.mildlyfunctional.gay/nixbsd"
      "https://cache.dataaturservice.se/spectrum/"
      "https://cache.nixos.org/"
      "https://deckcheatz-nightlies.cachix.org"
      "https://cache.saumon.network/proxmox-nixos"
      "https://deploy-rs.cachix.org/"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://numtide.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "deckcheatz-nightlies.cachix.org-1:ygkraChLCkqqirdkGjQ68Y3LgVrdFB2bErQfj5TbmxU="
      "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
      "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nixbsd:gwcQlsUONBLrrGCOdEboIAeFq9eLaDqfhfXmHZs1mgc="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
    ];

  };

  outputs =
    inputs:
    let
      inherit (inputs) self;
      genPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
          config = self.nixpkgs-config;
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
      treeFmtEval = treeFmtEachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./nix/formatter.nix);

      forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
      forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;
    in
    rec {
      libx = forAllSystems
        (system:
          let
            pkgs = genPkgs system;
          in
          import ./lib { inherit self inputs pkgs; });
      common = ./common;
      nixosModules = import ./modules/nixos;
      homeModules = import ./modules/home-manager;
      darwinModules = import ./modules/darwin;
      hmModules = homeModules;
      hosts = import ./hosts { inherit inputs self; };
      nixosConfigurations = import ./hosts/nixos { inherit inputs self; }; # // inputs.nixfigs-work.nixosConfigurations;
      darwinConfigurations = import ./hosts/darwin { inherit inputs; };
      homeConfigurations = import ./homes { inherit inputs; };
      overlays = import ./overlays { inherit inputs; inherit (inputs.nixpkgs) lib; };
      secrets = inputs.nixfigs-secrets.outputs.system // inputs.nixfigs-secrets.outputs.user;
      deploy = import ./nix/deploy.nix { inherit self inputs; inherit (inputs.nixpkgs) lib; };
      # for `nix fmt`
      formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks =
        treeFmtEachSystem
          (pkgs: {
            formatting = treeFmtEval.${pkgs.system}.config.build.wrapper;
          })
        // forEachSystem (system: {
          pre-commit-check = import ./nix/checks.nix {
            inherit
              self
              system
              inputs;
            inherit (inputs.nixpkgs) lib;
          };
        });
      devShells = forEachSystem (
        system:
        let
          pkgs = genPkgs system;
        in
        import ./nix/devshell.nix { inherit pkgs self system; }
      );
      nixpkgs-config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
        allowBroken = true;
        allowInsecurePredicate = _: true;
      };
      sdImages = rec {
        SMITH-LINUX = self.nixosConfigurations.SMITH-LINUX.config.system.build.sdImage;
        GRDN-BED-UNIT = self.nixosConfigurations.GRDN-BED-UNIT.config.system.build.sdImage;
        DZR-OFFICE-BUSY-LIGHT-UNIT = self.nixosConfigurations.DZR-OFFICE-BUSY-LIGHT-UNIT.config.system.build.sdImage;
        DZR-PETS-CAM-UNIT = self.nixosConfigurations.DZR-PETS-CAM-UNIT.config.system.build.sdImage;
        CLOCKWORK-DT-CM4 = self.nixosConfigurations.CLOCKWORK-DT-CM4.config.system.build.sdImage;
        CLOCKWORK-UC-CM4 = self.nixosConfigurations.CLOCKWORK-UC-CM4.config.system.build.sdImage;
        all = SMITH-LINUX // GRDN-BED-UNIT // DZR-OFFICE-BUSY-LIGHT-UNIT // DZR-PETS-CAM-UNIT // CLOCKWORK-DT-CM4 // CLOCKWORK-UC-CM4;
      };
      generators = import ./nix/generators.nix { inherit self; };
      packages =
        forEachSystem (system:
          (inputs.shypkgs-private.packages.${system} // inputs.shypkgs-public.packages.${system}));
    };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs/shymega/staging";
    nixfigs-secrets.url = "github:shymega/nixfigs-secrets";
    nixfigs-networks.url = "github:shymega/nixfigs-networks";
#    nixfigs-priv = {
#      url = "github:shymega/nixfigs-priv";
#      inputs = {
#        nixpkgs.follows = "nixpkgs";
#        nixpkgs-unstable.follows = "nixpkgs-unstable";
#        nixpkgs-master.follows = "nixpkgs-master";
#        nixpkgs-shymega.follows = "nixpkgs-shymega";
#        nixfigs-secrets.follows = "nixfigs-secrets";
#        nixfigs-networks.follows = "nixfigs-networks";
#        flake-registry.follows = "flake-registry";
#        auto-cpufreq.follows = "auto-cpufreq";
#        hardware.follows = "hardware";
#        nix-ld.follows = "nix-ld";
#        nix-alien.follows = "nix-alien";
#        nix-index-database.follows = "nix-index-database";
#        flake-compat.follows = "flake-compat";
#        flake-utils.follows = "flake-utils";
#        home-manager.follows = "home-manager";
#        lanzaboote.follows = "lanzaboote";
#        git-hooks.follows = "git-hooks";
#        treefmt-nix.follows = "treefmt-nix";
#        shypkgs-private.follows = "shypkgs-private";
#        shypkgs-public.follows = "shypkgs-public";
#      };
#    };
#
#    nixfigs-work = {
#      url = "github:shymega/nixfigs-work";
#      inputs = {
#        nixpkgs.follows = "nixpkgs";
#        nixpkgs-unstable.follows = "nixpkgs-unstable";
#        nixpkgs-master.follows = "nixpkgs-master";
#        nixpkgs-shymega.follows = "nixpkgs-shymega";
#        nixfigs-secrets.follows = "nixfigs-secrets";
#        nixfigs-networks.follows = "nixfigs-networks";
#        flake-registry.follows = "flake-registry";
#        auto-cpufreq.follows = "auto-cpufreq";
#        hardware.follows = "hardware";
#        nix-ld.follows = "nix-ld";
#        nix-alien.follows = "nix-alien";
#        nix-index-database.follows = "nix-index-database";
#        flake-compat.follows = "flake-compat";
#        flake-utils.follows = "flake-utils";
#        home-manager.follows = "home-manager";
#        lanzaboote.follows = "lanzaboote";
#        git-hooks.follows = "git-hooks";
#        treefmt-nix.follows = "treefmt-nix";
#        shypkgs-private.follows = "shypkgs-private";
#        shypkgs-public.follows = "shypkgs-public";
#      };
#    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq/a1ac308be7b558f85c91a6a3e86cbc0cebdadbbc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = "nix-darwin";
      };
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-index-database.follows = "nix-index-database";
      };
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
      };
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aimu.url = "github:shymega/aimu/refactor-shymega";
    base16-schemes.url = "github:SenchoPens/base16.nix";
    bestool.url = "github:shymega/bestool/shymega-all-fixes";
    deckcheatz.url = "github:deckcheatz/deckcheatz/develop";
    dzr-taskwarrior-recur.url = "github:shymega/dzr-taskwarrior-recur";
    emacs2nixpkg.url = "github:shymega/emacs2nixpkg";
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    cosmo-codios-codid.url = "github:cosmo-codios/codid";
    ei-wlroots-proxy.url = "github:input-leap/ei-wlroots-proxy";
    input-leap-shymega.url = "github:shymega/input-leap/feature/nix-support";
    nix-gaming.url = "github:fufexan/nix-gaming";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    wemod-launcher.url = "github:shymega/wemod-launcher/refactor-shymega";
    proxmox-nixos.url = "github:shymega/proxmox-nixos/shymega";
    nixfigs-doom-emacs = {
      url = "github:shymega/nixfigs-doom-emacs";
      flake = false;
    };
    doom-emacs-src = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    spacemacs-src = {
      url = "github:syl20bnr/spacemacs";
      flake = false;
    };
    shypkgs-private.url = "github:shymega/shypkgs-private";
    shypkgs-public.url = "github:shymega/shypkgs-public";
    home-statd.url = "github:shymega/home-statd";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";
    disko.url = "github:nix-community/disko";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
  };
}
