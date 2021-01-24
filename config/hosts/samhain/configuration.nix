{ config, pkgs, lib, ... }:

{
  imports = [
    ../../services/zfs.nix
    ./hardware-configuration.nix
    ./services/nginx.nix
    ./services/thermal/thermal.nix
    ./services/torrenting.nix
  ];

  meta.deploy.profiles = [ "desktop" "development" "sway" "gaming" "network" "yubikey" ];
  meta.deploy.ssh.host = "192.168.1.135";
  
  # libvirtd is used for our virtual machine
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # required for guest reboots with the 580
  boot.extraModulePackages = [ (pkgs.linuxPackagesFor config.boot.kernelPackages.kernel).vendor-reset ];

  # required groups for various intentions  
  users.users.kat.extraGroups = [ "libvirtd" "input" "qemu-libvirtd" ];

  # video=efifb:off allows the 580 to be passed through regardless of being the boot display and allows the 560 to act as a console device
  # pci=noats means that it doesn't kernel panic on my specific configuration
  boot.kernelParams = [
    "amd_iommu=on"
    "pci=noats"
    "video=efifb:off"
  ]; # eventually switch to vfio-pci.ids to replace the boot.initrd.preDeviceCommands block
  boot.initrd.availableKernelModules =
    [ "amdgpu" "vfio-pci" ]; # vfio-pci is required for pci passthrough
  boot.kernelModules =
    [ "i2c-dev" "kvm-amd" ]; # i2c-dev is required for DDC/CI for screenstub

  # this section makes vfio-pci be injected as the driver for the 580 and its audio thingy
  # it should be replaced as mentioned with vfio-pci.ids
  # the script provided: https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html can be used to find iommu groups
  boot.initrd.preDeviceCommands = ''
    DEVS="0000:26:00.0 0000:26:00.1"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
  '';

  # the nur is used for arc's packages, so we include it here
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
  };

  # rules are for:
  # * monitor ddc/ci
  # * input for qemu
  # * rule for event-mouse (i hope?)
  # * uinput rule
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", GROUP="users", MODE="0660"
    SUBSYSTEM=="input", ACTION=="add", DEVPATH=="/devices/virtual/input/*", MODE="0660", GROUP="qemu-libvirtd"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="fa58", ATTRS{idProduct}=="04d9", GROUP="users"
    SUBSYSTEM=="misc", KERNEL=="uinput", OPTIONS+="static_node=uinput", MODE="0660", GROUP="uinput"
  '';

  environment.systemPackages = [
    # pkgs.nur.repos.arc.packages.screenstub # for DDC/CI and input forwarding (currently disabled due to using changed source)
    pkgs.nur.repos.arc.packages.scream-arc # for audio forwarding
    pkgs.ddcutil # for diagnostics on DDC/CI
    pkgs.virt-manager # obvious reasons
    pkgs.cachix # arc caching
  ];

  # arc caching
  nix = {
    binaryCaches = [ "https://arc.cachix.org" ];
    binaryCachePublicKeys =
      [ "arc.cachix.org-1:DZmhclLkB6UO0rc0rBzNpwFbbaeLfyn+fYccuAy7YVY=" ];
  };

  # audio for vm on startup
  systemd.user.services.scream-arc = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description = "Scream - Audio forwarding from the VM.";
    serviceConfig = {
      ExecStart =
        "${pkgs.nur.repos.arc.packages.scream-arc}/bin/scream -i virbr0 -o alsa";
      Restart = "always";
    };
  };

  # BusId is used to specify the graphics card used for X / lightdm / wayland
  # BusId must be decimal conversion of the equivalent but matching the format, this was 0000:25:00.0
  services.xserver.deviceSection = lib.mkDefault ''
    Option "TearFree" "true"
    BusID "PCI:37:0:0"
  '';

  # graphics tablet
  services.xserver.wacom.enable = true;

  # other stuffs
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "xfs" ];
  networking.hostName = "samhain";
  networking.hostId = "617050fc";
  networking.useDHCP = false;
  networking.interfaces.enp34s0.useDHCP = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 445 139 9091 ]; # smb transmission
  networking.firewall.allowedUDPPorts = [ 137 138 4010 ]; # smb scream

  system.stateVersion = "20.09";

}
