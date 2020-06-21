{ writeText
, runCommand
, bit2bitbin }:

{ bit
, name }:

# Uses bit2bin to turn ${bit}/${name}.bit into a byte-swapped ${name}.bin file,
# to be loaded by the Xilinx-flavoured Linux kernel.

# Is placed into $out/lib/firmware/${name}.bit, to facilitate usage from inside
# NixOS.

runCommand ("bin") {
  nativeBuildInputs = [ bit2bitbin ];
} ''
  mkdir -p $out/lib/firmware
  bit2bitbin ${bit}/${name}.bit $out/lib/firmware/${name}.bin
''
