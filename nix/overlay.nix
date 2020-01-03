self: super: {
  openocd = super.callPackage ./pkgs/openocd.nix {};

  mkXilinxBin = super.callPackage ({ name ? "boot", xilinx-bootgen, bif, runCommand }:
    runCommand (name + ".bin") {
      nativeBuildInputs = [ xilinx-bootgen ];
    } ''
    bootgen -image ${bif} -o i $out
  '');


  pynq = {
    # everybody loves blobs, right?
    fsbl = ./pkgs/fsbl/fsbl.elf;

    uboot = super.callPackage ./pkgs/u-boot {};
    kernel = super.callPackage ./pkgs/kernel {};
    kernelXilinx = super.callPackage ./pkgs/kernel-xilinx {};

    bif = super.writeText "pynq.bif" ''
      image:
      {
          [bootloader]${self.pynq.fsbl}
          ${self.pynq.uboot}/u-boot.elf
      }
    '';

    bootBin = self.mkXilinxBin {
      bif = self.pynq.bif;
    };

    linuxPackages = super.recurseIntoAttrs (super.linuxPackagesFor self.pynq.kernel);
  };

  makeBootFS = { pkgs, runCommand, bootBin, kernel }:
    let
      extlinuxConf = pkgs.writeText "extlinux.cfg" ''
        timeout 10
        default PynxOS

        label PynxOS
        kernel /boot/zImage
        append root=/dev/mmcblk0p3 systemd.log_target=console systemd.journald.forward_to_console=1
        fdt ../dtbs/zynq-pynq-z1.dtb
      '';
    in
    runCommand "boot-fs" {
      nativeBuildInputs = [ ];
    } ''
      mkdir -p $out
      cp ${bootBin} $out/boot.bin
      mkdir -p $out/{boot,dtbs,extlinux}

      cp ${extlinuxConf} $out/extlinux/extlinux.conf
      cp ${kernel}/dtbs/zynq-pynq-z1.dtb $out/dtbs/
      cp ${kernel}/{zImage,System.map} $out/boot/
    '';
}
