self: super: {
  openocd = super.callPackage ./pkgs/openocd.nix {};

  pynq = {
    uboot = super.callPackage ./pkgs/u-boot {};
    kernel = super.callPackage ./pkgs/kernel {};
    kernelXilinx = super.callPackage ./pkgs/kernel-xilinx {};
    linuxPackages = super.recurseIntoAttrs (super.linuxPackagesFor self.pynq.kernel);
  };

  mkXilinxBin = { name ? "image", bif, bit }: super.callPackage ./lib/mkXilinxBin.nix {
    inherit name bif bit;
  };

  makeBootFS = { uboot, kernel }:
    let
      extlinuxConf = super.writeText "extlinux.cfg" ''
        timeout 10
        default PynxOS

        label PynxOS
        kernel /boot/zImage
        append root=/dev/mmcblk0p3 systemd.log_target=console systemd.journald.forward_to_console=1
        fdt ../dtbs/zynq-pynq-z1.dtb
      '';
    in
    super.runCommand "boot-fs" {
      nativeBuildInputs = [ ];
    } ''
      mkdir -p $out
      cp ${uboot}/boot.bin $out/
      cp ${uboot}/u-boot.img $out/
      cp ${uboot}/u-boot.dtb $out/system.dtb
      mkdir -p $out/{boot,dtbs,extlinux}

      cp ${extlinuxConf} $out/extlinux/extlinux.conf
      cp ${kernel}/dtbs/zynq-pynq-z1.dtb $out/dtbs/
      cp ${kernel}/{zImage,System.map} $out/boot/
    '';
}
