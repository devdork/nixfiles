{ config, lib, pkgs, ... }: {

  config = lib.mkIf (lib.elem "gaming" config.meta.deploy.profiles) {
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    hardware.pulseaudio.support32Bit = true;

    home-manager.users.kat = {
      home.packages = [ pkgs.lutris pkgs.steam-run ];
    };
  };
}