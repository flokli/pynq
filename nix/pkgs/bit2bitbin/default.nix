{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "bit2bitbin";
  version = "2013-08-31";

  src = fetchFromGitHub {
    owner = "pgielda";
    repo = "zynq_bootloader";
    rev = "b14563c7b7c068551da1e073d164db54239a60ee";
    sha256 = "166bz9x7jq2h41ag27zdiznnkbzpksq2qa3nnqgg1l5f7vrg96c2";
  };

  buildPhase = ''
    $CC -o bit2bitbin/bit2bitbin bit2bitbin/bit2bitbin.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bit2bitbin/bit2bitbin $out/bin
    chmod +x $out/bin/bit2bitbin
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pgielda/zynq_bootloader";
    description = "A simple tool to convert .bit to .bit.bin file";
    maintainers = with maintainers; [ flokli ];
    platforms = platforms.linux;
  };
}
