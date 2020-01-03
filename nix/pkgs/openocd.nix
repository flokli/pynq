{ stdenv, fetchgit, which, libtool, automake, autoconf, pkgconfig, git, libusb, extraConfigureFlags ? [] }:

stdenv.mkDerivation rec {
  name = "openocd-${version}";
  version = "0.10.0-977-g22b4abc4";

  src = fetchgit {
    url = "git://git.code.sf.net/p/openocd/code";
    rev = "22b4abc46c552bfc21003853b74e732da773cd1d";
    sha256 = "07xspyn4w5v47gv6dbliic8f73i4hqma1640y5108n9c5lx45ffp";
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
