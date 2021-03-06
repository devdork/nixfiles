{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.deploy.profile.gui {
    fonts.fontconfig.enable = true;
    fonts.fonts = with pkgs; [
      font-awesome
      nerdfonts
      iosevka
      emacs-all-the-icons-fonts
    ];
  };
}
