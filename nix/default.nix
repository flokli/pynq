let
  pkgs = import ./pkgs.nix;
in {
  inherit pkgs;
  shell = pkgs.mkShell {
    buildInputs = with pkgs; [
      gdb
      openocd
      gnumake
    ];
  };
}
