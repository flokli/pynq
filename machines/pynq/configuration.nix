{ config, pkgs, lib, modulesPath, ... }:

let
  pynqBlinkBin = pkgs.buildPackages.mkXilinxBin {
    name = "blink";
    bit = pkgs.mkXilinxBit {
      toplevelName = "blink";
      src = ./examples/blink;
    };
  };
in {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/installer/cd-dvd/sd-image.nix"
  ];

  hardware.firmware = [ pynqBlinkBin ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems."/boot/firmware".options = ["auto"];

  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelPackages = pkgs.linuxPackages_pynq_xilinx;
  boot.kernelParams = [
    "systemd.log_target=console"
    "systemd.journald.forward_to_console=1"
  ];
  hardware.deviceTree.name = "zynq-pynq-z1.dtb";

  sdImage.populateFirmwareCommands = ''
    cp ${pkgs.ubootPynq}/boot.bin firmware/
    cp ${pkgs.ubootPynq}/u-boot.img firmware/
    cp ${pkgs.ubootPynq}/u-boot.dtb firmware/system.dtb
  '';
  sdImage.populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  '';

  nix.maxJobs = 2;

  networking.hostName = "pynq";
  networking.useNetworkd = true;
  networking.useDHCP = false; # disable non-networkd DHCP
  networking.interfaces.eth0.useDHCP = true;

  services.udisks2.enable = false; # pulls in btrfs, #50925
  security.polkit.enable = false; # pulls in gobject-introspection

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTVTXOutUZZjXLB0lUSgeKcSY/8mxKkC0ingGK1whD2 flokli"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEinGNp/dMkIT9cOuLepE4VJp5WLI+tvoRzpzStL2hkd heijligen"
  ];

  systemd.services."fpga-load" = {
    enable = true;
    script = ''
      echo "loading bitstream ${pynqBlinkBin}…"
      echo "blink.bin" > /sys/class/fpga_manager/fpga0/firmware
    '';
    serviceConfig.Type = "oneshot";
    restartTriggers = [ pynqBlinkBin ];
    wantedBy = [ "multi-user.target" ];
  };
}
