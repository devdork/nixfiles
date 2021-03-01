{ config ? { }, system ? builtins.currentSystem, ... }@args:

let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs args;

  overlay = self: super: {
    dino = super.callPackage "${sources.qyliss-nixlib}/overlays/patches/dino" {
      inherit (super) dino;
    };

    discord = super.discord.override { nss = self.nss_latest; };

    arc = import sources.arc-nixexprs { pkgs = super; };
    unstable = import sources.nixpkgs-unstable { inherit (self) config; };
    nur = import sources.NUR { nurpkgs = self; pkgs = self; };

    linuxPackagesFor = kernel:
      (super.linuxPackagesFor kernel).extend (_: ksuper: {
        vendor-reset =
          (super.callPackage ./vendor-reset { kernel = ksuper.kernel; }).out;
      });

    colorhelpers = import ../lib/colorhelpers.nix { inherit (self) lib; };
  };

in pkgs.extend(overlay)