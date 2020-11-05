
{ config, lib, pkgs, ... }:
{
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
  
  home-manager.users.kat = {
    home.packages = [
        pkgs.steam
        pkgs.steam-run
    ];
  };
}