{ pkgs, lib, systemSettings, userSettings, ... }:
{
  imports = [
    ../../system/hardware-configuration.nix
    ../../system/hardware/systemd.nix
    ../../system/hardware/kernel.nix
    ../../system/hardware/power.nix
    ../../system/hardware/time.nix
    ../../system/hardware/opengl.nix
    ../../system/hardware/printing.nix
    ../../system/hardware/bluetooth.nix
    (./. + "../../../system/wm" + ("/" + userSettings.wm) + ".nix")
    ../../system/security/doas.nix
    ../../system/security/gpg.nix
    ../../system/security/blocklist.nix
    ../../system/security/firewall.nix
    ../../system/security/firejail.nix
    ../../system/security/openvpn.nix
    ../../system/security/automount.nix
    ../../system/style/stylix.nix
  ];
# Fix nix path
  nix.nixPath = [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
                  "nixos-config=$HOME/dotfiles/system/configuration.nix"
                  "/nix/var/nix/profiles/per-user/root/channels"
                ];

  # Ensure nix flakes are enabled
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # I'm sorry Stallman-taichou
  nixpkgs.config.allowUnfree = true;

  # Kernel modules
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "cpufreq_powersave" ];

  # Bootloader
  # Use systemd-boot if uefi, default to grub otherwise
  boot.loader.systemd-boot.enable = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.canTouchEfiVariables = if (systemSettings.bootMode == "uefi") then true else false;
  boot.loader.efi.efiSysMountPoint = systemSettings.bootMountPath; # does nothing if running bios rather than uefi
  boot.loader.grub.enable = if (systemSettings.bootMode == "uefi") then false else true;
  boot.loader.grub.device = systemSettings.grubDevice; # does nothing if running uefi rather than bios
  boot.loader.grub.useOSProber = if (systemSettings.bootMode == "uefi") then false else true;

  # Networking
  networking.hostName = systemSettings.hostname; # Define your hostname.
  networking.networkmanager.enable = true; # Use networkmanager

  # Timezone and locale
  time.timeZone = systemSettings.timezone; # time zone
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
  };

  # User account
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
    uid = 1000;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    zsh
    git
    cryptsetup
    home-manager
  ];

  # I use zsh btw
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  fonts.fontDir.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # It is ok to leave this unchanged for compatibility purposes
  system.stateVersion = "22.11";


}