{ config, pkgs, stylix, userSettings, ... }:

{
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  programs.home-manager.enable = true;

  imports = [
    stylix.homeManagerModules.stylix
    (./. + "../../../user/wm"+("/"+userSettings.wm+"/"+userSettings.wm)+".nix")
    (./. + "../../../user/app/browser"+("/"+userSettings.browser)+".nix")
    ../../user/shell/zsh.nix
    ../../user/shell/cli-collection.nix
    ../../user/shell/tmux.nix
    ../../user/shell/starship.nix
    ../../user/app/git/git.nix
    ../../user/style/stylix.nix
    ../../user/lang/rust/rust.nix
    ../../user/hardware/bluetooth.nix
  ];


  home.stateVersion = "22.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Core
    zsh
    alacritty
    librewolf
    brave
    dmenu
    rofi
    git
    syncthing

    # Office
    evince 
    glib
    newsflash
    gnome.nautilus
    gnome.seahorse
    openvpn
    protonmail-bridge

    wine
    
    vlc
    mpv
    obs-studio
    ffmpeg
    mediainfo
    libmediainfo
    mediainfo-gui
    audio-recorder

    # Various dev packages
    texinfo
    libffi zlib
    nodePackages.ungit
  ];

  services.syncthing.enable = true;

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Media/Music";
    videos = "${config.home.homeDirectory}/Media/Videos";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = null;
    publicShare = null;
    extraConfig = {
      XDG_DOTFILES_DIR = "${config.home.homeDirectory}/.dotfiles";
      XDG_ARCHIVE_DIR = "${config.home.homeDirectory}/Archive";
      XDG_VM_DIR = "${config.home.homeDirectory}/Machines";
      XDG_ORG_DIR = "${config.home.homeDirectory}/Org";
      XDG_PODCAST_DIR = "${config.home.homeDirectory}/Media/Podcasts";
      XDG_BOOK_DIR = "${config.home.homeDirectory}/Media/Books";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;


  home.sessionVariables = {
    EDITOR = userSettings.editor;
    TERM = userSettings.term;
    BROWSER = userSettings.browser;
  };
}
