{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    # db 
    ./postgres.nix
    # nginx
    ../../services/nginx.nix
    ./virtualhosts.nix
    # services
    ./mail.nix
    ./gitea.nix
    ./nextcloud.nix
    ./bitwarden.nix
    # comms
    ./znc.nix
    ./weechat.nix
    ./matrix.nix
  ];

  meta.deploy.ssh.host = "athame.kittywit.ch";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "athame";
    domain = "kittywit.ch";
    hostId = "7b0ac74e";
    useDHCP = false;
    interfaces.enp1s0.useDHCP = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "20.09";
}
