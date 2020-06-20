let
  pkgs = (import ./nix).pkgs;
  pCross = pkgs.pkgsCross.armv7l-hf-multiplatform;
in {
  pynqBootFS = pkgs.makeBootFS {
    uboot = pCross.ubootPynq;
    kernel = pCross.linux_pynq;
  };
  pynqBootFSXilinx = pkgs.makeBootFS {
    uboot = pCross.ubootPynq;
    kernel = pCross.linux_pynq_xilinx;
  };
}
