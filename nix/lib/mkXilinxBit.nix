{ stdenv
, gnumake
, yosys
, vivado }:

{ toplevelName ? "main"
, src
}:

# Library function. given a toplevelName and src
# builds a FPGA bitstream (.bit) via Vivado, all nicely isolated and sandboxed
# with Nix.

# The build works like this:

# `src` is copied into the nix store, a Makefile and `pynq.xdc` are added to
# the src passed in, then `make $toplevelName` is invoked.
#
# It roughly does the following:
#
# ## Synthesize with Yosys
#  - `yosys -p 'read_verilog +/xilinx/cells_xtra.v path/to/*.v; synth_xilinx -edif $toplevelName.edif -top $toplevelName`
#
# ## Create tcl script to instrument vivado:
# A `$toplevelName.tcl` similar to the following is produced:
#   ```
#   read_xdc pynq.xdc
#   read_edif $toplevelName.edif
#   link_design -part xc7z020clg400 -top $toplevelName
#   place_design
#   route_design
#   write_bitstream -force $toplevelName.bit
#   ```
#
# The `pynq.xdc` comes from [the Digilent
# Website](https://reference.digilentinc.com/reference/programmable-logic/pynq-z1/start),
# with all ports commented in.
#
# ### Invoke Vivado
# We invoke Vivado headless in batch mode (not project mode) to execute above
# tcl script:
#
# - vivado -nolog -nojournal -mode batch -source $toplevelName.tcl
#
# Vivado will produce a `blink.bin`.
# This one most likely will need to be packaged to a blob with the
# `mkXilinxBin` helper, so it's accepted by the kernels FPGA manager with the
# mkXilinxBin helper.
#
# As written there, this approach does do synthesis with Yosys, and invokes
# Vivado only for place & route. As yosys already has limited support to do
# xilinx bitstream generation, chances are high it'll eventually get a backend
# for the zynq-based ones too.

let
  name = "${toplevelName}.bit";
in stdenv.mkDerivation {
  inherit name;

  # Ensure .src doesn't contain any Makefile, pynq.xdc or intermediate outputs
  src = (builtins.filterSource (path: _:
    path != (toString(src + "/Makefile"))
    && path != (toString(src + "/pynq.xdc"))
    && ((builtins.match ".*\\.bit" path) == null)
    && ((builtins.match ".*\\.edif" path) == null)
    && ((builtins.match ".*\\.tcl" path) == null)
  ) src);

  nativeBuildInputs = [ gnumake yosys ];
  # ensure don't try to cross-compile vivado, or provide some cross
  # dependencies during build.
  # Just adding vivado to nativeBuildInputs drags in tons of graphical
  # dependencies, which do not (yet) cross-compile.
  depsBuildBuild = [ vivado ];
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
