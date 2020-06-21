{ stdenv
, gnumake
, yosys
, vivado }:

{ toplevelName ? "main"
, src
}:

# Library function. given a toplevelName and src
# builds a FPGA bitstream (.bit) via Vivado.

let
  name = "${toplevelName}.bit";
in stdenv.mkDerivation {
  inherit name;

  src = (builtins.filterSource (path: _:
    path != (toString(src + "/Makefile"))
    && path != (toString(src + "/pynq.xdc"))
    && ((builtins.match ".*\\.bit" path) == null)
    && ((builtins.match ".*\\.edif" path) == null)
    && ((builtins.match ".*\\.tcl" path) == null)
  ) src);

  nativeBuildInputs = [ gnumake vivado yosys ];

  preConfigure = ''
    cp ${../../lib/Makefile} Makefile
    cp ${../../lib/pynq.xdc} pynq.xdc
    export HOME=$(mktemp -d)
  '';

  makeFlags = [ name ];

  installPhase = ''
    cp ${toplevelName}.bit $out
  '';
}
