{ writeText
, runCommand
, bit2bitbin }:

{ bit
, name }:

# Uses bit2bin to turn a .bit file into a byte-swapped .bin file, to be loaded
# by the Xilinx-flavoured Linux kernel.
# Is placed into $out/lib/firmware, to facilitate usage from inside NixOS.

runCommand ("bin") {
  nativeBuildInputs = [ bit2bitbin ];
} ''
  mkdir -p $out/lib/firmware
  bit2bitbin ${bit} $out/lib/firmware/${name}
''
