let
  pkgs = (import ./nix).pkgs;
  pCross = pkgs.pkgsCross.armv7l-hf-multiplatform;
  kernel = pCross.pynq.kernel;
  kernelXilinx = pCross.pynq.kernelXilinx;
  bootBin = pCross.pynq.bootBin;
in {
  pynqKernel = kernel;
  pynqKernelXilinx = kernelXilinx;
  pynqBootFS = pkgs.callPackage pkgs.makeBootFS {
    inherit bootBin kernel;
  };
  pynqBootFSXilinx = pkgs.callPackage pkgs.makeBootFS {
    inherit bootBin;
    kernel = pCross.pynq.kernelXilinx;
  };
}
