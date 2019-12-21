let
  pkgs = (import ./nix).pkgs;
  kernel =       pkgs.pkgsCross.armv7l-hf-multiplatform.pynq.kernel;
  bootBin =      pkgs.pkgsCross.armv7l-hf-multiplatform.pynq.bootBin;
in {
  pynqKernel = kernel;
  pynqBootFS = pkgs.callPackage pkgs.makeBootFS {
    inherit bootBin kernel;
  };
}
