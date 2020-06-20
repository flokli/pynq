{ stdenv
, fetchFromGitHub
, ghdl
, readline
, yosys
, zlib
}:

stdenv.mkDerivation {
  name = "ghdl-yosys-plugin";
  version = "2020.06.20";

  src = fetchFromGitHub {
    owner = "ghdl";
    repo = "ghdl-yosys-plugin";
    rev = "20f45f5644f82df437b09838a2fbdbfc7b6aa4e7";
    sha256 = "0znngyp2sksrvzmxbf22s2yhj7vigz7nqyldsag1lvxf24z650nz";
  };

  buildInputs = [
    readline
    zlib
  ];

  # This is super cursed. We basically had to rewrite the Makefile
  # `yosys-config --build` is used to invoke gcc with some arguments.
  # The ghdl-yosys-plugin Makefile adds some arguments on top, by asking ghdl
  # for `--libghdl-{include-dir,library-path}`.
  # This argument however doesn't seem to exist in ghdl.

  # The upstream Makefile also seems to suggest libghdl-*.so is a dynamic
  # library (its extension as well), but here, it's a static one, so all the
  # -Wl runpath trickery doesn't work, and we need to literally pass it to gcc
  # (without `-L`)

  # I'm not sure if this is already broken upstream, or if we just build ghdl
  # somehow wrongly.

  # On top of that, we need to define YOSYS_ENABLE_GHDL (otherwise only a stub
  # is built, which just prints GHDL is disabled, yay)

  # The build process spits out a .so file, which people are supposed to pass
  # to yosys via their `-m path/to.so` parameter.
  buildPhase = ''
    ${yosys}/bin/yosys-config --build ghdl.so src/ghdl.cc -DYOSYS_ENABLE_GHDL -I${ghdl}/include ${ghdl}/lib/libghdl-*.so
  '';

  installPhase = ''
    mkdir -p $out/share/yosys/plugins
    mv ghdl.so $out/share/yosys/plugins
  '';

  meta = with lib; {
    homepage = "https://github.com/ghdl/ghdl-yosys-plugin";
    description = "VHDL synthesis for yosys";
    maintainers = with maintainers; [ flokli ];
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
