{ stdenv, fetchgit, which, libtool, automake, autoconf, pkgconfig, git, libusb, extraConfigureFlags ? [] }:

stdenv.mkDerivation rec {
  name = "openocd-${version}";
  version = "0.10.0+dev-20190912";

  src = fetchgit {
    url = "git://git.code.sf.net/p/openocd/code";
    rev = "31100927203a4e9d5e4f8e019b1a9e1c9d7b51c6";
    sha256 = "0f0p4j0hlf35m4gfb5lbyvbfq4ws37cmzrqn02pc1qa6vbl22fql";
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
