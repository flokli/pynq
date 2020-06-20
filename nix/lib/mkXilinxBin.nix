{
  writeText
, runCommand
, xilinx-bootgen
, name ? "image"
}:

{ bif ? null
, bit ? null
}:

assert bit != null -> bif == null;
assert bit == null -> bif != null;

let
  _bif =
    if bif != null then bif
    else (writeText "image.bif" ''
  image : {
    ${bit}
  }
  '');

in runCommand (name + ".bin") {
  nativeBuildInputs = [ xilinx-bootgen ];
} "bootgen -image ${_bif} -o i $out"
