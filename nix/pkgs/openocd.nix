{ stdenv, fetchgit, which, libtool, automake, autoconf, pkgconfig, git, libusb, extraConfigureFlags ? [] }:

stdenv.mkDerivation rec {
  name = "openocd-${version}";
  version = "0.10.0-1157-gd6541a81";

  src = fetchgit {
    url = "http://openocd.zylin.com/openocd";
    rev = "d6541a811dc32beafbb388a01289366f1f31fc00";
    sha256 = "1ilgziaiqs5788h4zigj485bhngviir9kyhm2vqssakxg3n036s9";
  };

  # The bootstrap code needs `.git` to fetch submodules which are already fetched by `fetchgit`. By
  # disallowing fetching, we can get rid of the `.git` directory (i.e. the default behavior of
  # fetchgit)
  SKIP_SUBMODULE=1;

  buildInputs = [ which libtool automake autoconf pkgconfig git libusb];

  configureFlags = extraConfigureFlags;

  preConfigure = ''
    ./bootstrap
  '';
}
