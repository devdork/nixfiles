{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    smartmontools
    hddtemp
    lm_sensors
    htop
    cachix
    ripgrep
    git
    nixfmt
    mprime
    wget
    rsync
    pv
    pinentry-curses
    progress
    bc
    zstd
    file
    whois
    fd
    exa
    socat
    tmux
    gnupg
  ];
}
