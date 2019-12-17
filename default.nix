let
  pkgs = (import ./nix).pkgs;
in {
  pynqKernel = pkgs.pkgsCross.armv7l-hf-multiplatform.linuxPynqZ1;
  pynqBootFS = pkgs.callPackage pkgs.makeBootFS {
    bootBin = pkgs.pkgsCross.armv7l-hf-multiplatform.pynq.bootBin;
    kernel = pkgs.pkgsCross.armv7l-hf-multiplatform.pynq.kernel;
  };
}
