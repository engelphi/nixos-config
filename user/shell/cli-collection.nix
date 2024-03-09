{ pkgs, ... }:

{
  # Collection of useful CLI apps
  home.packages = with pkgs; [
    # Command Line
    cava
    gnugrep gnused
    killall
    libnotify
    timer
    bat lsd fd bottom ripgrep
    rsync
    tmux
    htop
    hwinfo
    unzip
    brightnessctl
    w3m
    fzf
    pandoc
    pciutils
    starship
    gcc
    cmake
    alejandra
    deadnix
    statix
    gnumake
    (pkgs.writeShellScriptBin "airplane-mode" ''
      #!/bin/sh
      connectivity="$(nmcli n connectivity)"
      if [ "$connectivity" == "full" ]
      then
          nmcli n off
      else
          nmcli n on
      fi
    '')
    neovim
  ];
}
