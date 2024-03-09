{
  description = "My first flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    rust-overlay.url = "github:oxalica/rust-overlay";

    blocklist-hosts = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager
      , stylix, blocklist-hosts, rust-overlay, hyprland-plugins
      , ... }:
    let
      systemSettings = {
        system = "x86_64-linux";
        hostname = "enceladus";
        profile = "personal";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        bootMode = "bios";
        bootMountPath = "/boot"; #mount path for efi boot partition;
        grubDevice = "/dev/vda";
      };
      userSettings = rec {
        username = "pen";
        name = "Philipp Engel";
        email = "philipp.engel.1990@googlemail.com";
        dotfilesDir = "~/.dotfiles";
        theme = "catppuccin-mocha";
        wm = "hyprland";
        wmType = "wayland";
        term = "alacritty";
        font = "Intel One Mono";
        fontPkg = pkgs.intel-one-mono;
        editor = "nvim";
        browser = "librewolf";
      };

      pkgs = import nixpkgs {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        }; 
        overlays = [ rust-overlay.overlays.default ];
      };

      pkgs-stable = import nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
      
      lib = nixpkgs.lib;


      # Systems that can run tests:
      supportedSystems = [ "x86_64-linux" ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor =
        forAllSystems (system: import inputs.nixpkgs { inherit system; });
    in {
      nixosConfigurations = {
        enceladus = lib.nixosSystem {
	        system = systemSettings.system;
	        modules = [(./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")];
	        specialArgs = {
	          inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit (inputs) stylix;
            inherit (inputs) blocklist-hosts;
          };
        };
      };
      homeConfigurations = {
        pen = home-manager.lib.homeManagerConfiguration {
	        inherit pkgs;
	        modules = [(./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")];
	        extraSpecialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit (inputs) stylix;
            inherit (inputs) hyprland-plugins;
	        };
	      };
      };
    };
}
