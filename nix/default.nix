let
  pkgs = import ./pkgs.nix;

  profileEnv = pkgs.writeTextFile {
    name = "profile-env";
    destination = "/.profile";
    # This gets sourced by direnv. Set NIX_PATH, so `nix-shell` uses the same nixpkgs as here.
    text = ''
      export NIX_PATH=nixpkgs=${toString pkgs.path}
    '';
  };
in {
  inherit pkgs;

  env = pkgs.buildEnv {
    name = "dev-env";
    paths = with pkgs; [
      bluespec
      gdb
      openocd
      gnumake
      yosys

      profileEnv
    ];
  };
}
