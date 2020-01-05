let
  pkgs = (import ./nix).pkgs;
  pCross = pkgs.pkgsCross.armv7l-hf-multiplatform;
  kernel = pCross.pynq.kernel;
  kernelXilinx = pCross.pynq.kernelXilinx;
  uboot = pCross.pynq.uboot;
in {
  pynqKernel = kernel;
  pynqKernelXilinx = kernelXilinx;
  pynqBootFS = pkgs.makeBootFS {
    inherit uboot kernel;
  };
  pynqBootFSXilinx = pkgs.makeBootFS {
    inherit uboot;
    kernel = pCross.pynq.kernelXilinx;
  };
}
