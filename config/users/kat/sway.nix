{ config, pkgs, lib, ... }:

let
  style = import ./style.nix;
  secrets = import ../../../secrets.nix;
in {
  imports = [ ./waybar ];

  config = lib.mkIf (lib.elem "sway" config.meta.deploy.profiles) {

    fonts.fonts = with pkgs; [
      font-awesome
      nerdfonts
      iosevka
      emacs-all-the-icons-fonts
    ];

    programs.sway.enable = true;
    users.users.kat.packages = with pkgs; [ grim slurp ];

    systemd.user.services.mako = {
      serviceConfig.ExecStart = "${pkgs.mako}/bin/mako";
      restartTriggers =
        [ config.home-manager.users.kat.xdg.configFile."mako/config".source ];
    };

    home-manager.users.kat = {
      programs.mako = {
        enable = true;
        defaultTimeout = 3000;
        borderColor = style.base16.color7;
        backgroundColor = "${style.base16.color0}70";
        textColor = style.base16.color7;
      };

      wayland.windowManager.sway = {
        enable = true;
        config = let
          dmenu =
            "${pkgs.bemenu}/bin/bemenu --fn '${style.font.name} ${style.font.size}' --nb '${style.base16.color0}' --nf '${style.base16.color7}' --sb '${style.base16.color1}' --sf '${style.base16.color7}' -l 5 -m -1 -i";
          lockCommand = "swaylock -i ${./wallpapers/main.png} -s fill";
          cfg = config.home-manager.users.kat.wayland.windowManager.sway.config;
        in {
          bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

          output = let
            left = {
              res = "1920x1080";
              pos = "0 0";
              bg = "${./wallpapers/left.jpg} fill";
            };
            middle = {
              res = "1920x1080";
              pos = "1920 0";
              bg = "${./wallpapers/main.png} fill";
            };
            right = {
              res = "1920x1080";
              pos = "3840 0";
              bg = "${./wallpapers/right.jpg} fill";
            };
            laptop = {
              res = "1920x1080";
              pos = "0 0";
              bg = "${./wallpapers/main.png} fill";
            };
          in {
            "DP-1" = left;
            "DVI-D-1" = middle;
            "HDMI-A-1" = right;
            "eDP-1" = laptop;
          };

          input = {
            "1739:33362:Synaptics_TM3336-002" = {
              dwt = "enabled";
              tap = "enabled";
              natural_scroll = "enabled";
              middle_emulation = "enabled";
              click_method = "clickfinger";
            };
            "*" = {
              xkb_layout = "gb";
              # xkb_variant = "nodeadkeys";
              #   xkb_options = "ctrl:nocaps";
            };
          };

          fonts = [ "${style.font.name} ${style.font.size}" ];
          terminal = "${pkgs.kitty}/bin/kitty";
          # TODO: replace with wofi
          menu =
            "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=\"${dmenu}\" --term='${cfg.terminal}'";
          modifier = "Mod4";

          startup = [
            {
              command = "systemctl --user restart mako";
              always = true;
            }
            {
              command =
                "${pkgs.swayidle}/bin/swayidle -w before-sleep '${lockCommand}'";
            }
          ];

          window = {
            border = 1;
            titlebar = true;
          };

          keybindings = {
            "${cfg.modifier}+Return" = "exec ${cfg.terminal}";

            "${cfg.modifier}+Left" = "focus left";
            "${cfg.modifier}+Down" = "focus down";
            "${cfg.modifier}+Up" = "focus up";
            "${cfg.modifier}+Right" = "focus right";

            "${cfg.modifier}+Shift+Left" = "move left";
            "${cfg.modifier}+Shift+Down" = "move down";
            "${cfg.modifier}+Shift+Up" = "move up";
            "${cfg.modifier}+Shift+Right" = "move right";

            "${cfg.modifier}+Shift+space" = "floating toggle";
            "${cfg.modifier}+space" = "focus mode_toggle";

            "${cfg.modifier}+1" = "workspace 1";
            "${cfg.modifier}+2" = "workspace 2";
            "${cfg.modifier}+3" = "workspace 3";
            "${cfg.modifier}+4" = "workspace 4";
            "${cfg.modifier}+5" = "workspace 5";
            "${cfg.modifier}+6" = "workspace 6";
            "${cfg.modifier}+7" = "workspace 7";
            "${cfg.modifier}+8" = "workspace 8";
            "${cfg.modifier}+9" = "workspace 9";
            "${cfg.modifier}+0" = "workspace 10";

            "${cfg.modifier}+Shift+1" = "move container to workspace 1";
            "${cfg.modifier}+Shift+2" = "move container to workspace 2";
            "${cfg.modifier}+Shift+3" = "move container to workspace 3";
            "${cfg.modifier}+Shift+4" = "move container to workspace 4";
            "${cfg.modifier}+Shift+5" = "move container to workspace 5";
            "${cfg.modifier}+Shift+6" = "move container to workspace 6";
            "${cfg.modifier}+Shift+7" = "move container to workspace 7";
            "${cfg.modifier}+Shift+8" = "move container to workspace 8";
            "${cfg.modifier}+Shift+9" = "move container to workspace 9";
            "${cfg.modifier}+Shift+0" = "move container to workspace 10";

            "XF86AudioRaiseVolume" =
              "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') +5%";
            "XF86AudioLowerVolume" =
              "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') -5%";
            "XF86AudioMute" =
              "exec pactl set-sink-mute $(pacmd list-sinks |awk '/* index:/{print $3}') toggle";
            "XF86AudioMicMute" =
              "exec pactl set-source-mute $(pacmd list-sources |awk '/* index:/{print $3}') toggle";
            "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";
            "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";

            "${cfg.modifier}+d" = "exec ${cfg.menu}";
            "${cfg.modifier}+x" = "exec ${lockCommand}";

            "${cfg.modifier}+i" = "move workspace to output left";
            "${cfg.modifier}+o" = "move workspace to output left";
            "${cfg.modifier}+b" = "splith";
            "${cfg.modifier}+v" = "splitv";
            "${cfg.modifier}+s" = "layout stacking";
            "${cfg.modifier}+w" = "layout tabbed";
            "${cfg.modifier}+e" = "layout toggle split";
            "${cfg.modifier}+f" = "fullscreen";

            "${cfg.modifier}+Shift+q" = "kill";
            "${cfg.modifier}+Shift+c" = "reload";

            "${cfg.modifier}+r" = "mode resize";
            "${cfg.modifier}+Delete" = ''
              mode "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown"'';
          };

          modes = {
            "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown" =
              {
                "l" = "exec ${lockCommand}, mode default";
                "e" = "exec swaymsg exit, mode default";
                "s" = "exec systemctl suspend, mode default";
                "h" = "exec systemctl hibernate, mode default";
                "r" = "exec systemctl reboot, mode default";
                "Shift+s" = "exec systemctl shutdown, mode default";
                "Return" = "mode default";
                "Escape" = "mode default";
              };
          };

          colors = {
            focused = {
              border = style.base16.color8;
              background = style.base16.color4;
              text = style.base16.color0;
              indicator = style.base16.color2;
              childBorder = style.base16.color8;
            };
            focusedInactive = {
              border = style.base16.color0;
              background = style.base16.color11;
              text = style.base16.color12;
              indicator = style.base16.color2;
              childBorder = style.base16.color8;
            };
            unfocused = {
              border = style.base16.color0;
              background = style.base16.color8;
              text = style.base16.color12;
              indicator = style.base16.color8;
              childBorder = style.base16.color8;
            };
            urgent = {
              border = style.base16.color8;
              background = style.base16.color9;
              text = style.base16.color0;
              indicator = style.base16.color1;
              childBorder = style.base16.color8;
            };
          };
        };
        wrapperFeatures.gtk = true;
        extraConfig = ''
          seat seat0 xcursor_theme breeze_cursors 20
        '';
      };

    };
  };
}
