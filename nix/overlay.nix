self: super: {
  openocd = super.callPackage ./pkgs/openocd.nix {};

  # https://github.com/NixOS/nixpkgs/pull/75722
  xilinx-bootgen = super.callPackage ./pkgs/xilinx-bootgen.nix {};

  ubootZynqPynqZ1 = super.buildUBoot {
    patches = [
      ./pkgs/0001-ARM-zynq-add-Digilent-Zynq-PYNQ-Z1.patch
    ];
    defconfig = "zynq_pynq_z1_defconfig";
    extraMeta.platforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.elf"];
  };
}
