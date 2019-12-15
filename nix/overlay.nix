self: super: {
  openocd = super.callPackage ./pkgs/openocd.nix {};

  # https://github.com/NixOS/nixpkgs/pull/75722
  xilinx-bootgen = super.callPackage ./pkgs/xilinx-bootgen.nix {};
}
