let
  pkgs = (import ./nix).pkgs;
  pCross = pkgs.pkgsCross.armv7l-hf-multiplatform;
in rec {
  pynqBootFS = pkgs.makeBootFS {
    uboot = pCross.ubootPynq;
    kernel = pCross.linux_pynq;
  };
  pynqBootFSXilinx = pkgs.makeBootFS {
    uboot = pCross.ubootPynq;
    kernel = pCross.linux_pynq_xilinx;
  };

  pynqBlinkBin = pkgs.mkXilinxBin {
    name = "blink.bit";
    bit = pkgs.mkXilinxBit {
      toplevelName = "blink";
      src = ./examples/blink;
    };
  };
}
