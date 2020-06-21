let
  pkgs = (import ./nix).pkgs;
  pCross = pkgs.pkgsCross.armv7l-hf-multiplatform;
in {
  pynq = (pCross.nixos ./machines/pynq/configuration.nix).config.system.build;
}
