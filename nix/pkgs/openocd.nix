{ stdenv, fetchgit, fetchpatch, which, libtool, automake, autoconf, pkgconfig, git, libusb, extraConfigureFlags ? [] }:

stdenv.mkDerivation rec {
  name = "openocd-${version}";
  version = "0.10.0-977-g22b4abc4";

  src = fetchgit {
    url = "git://git.code.sf.net/p/openocd/code";
    rev = "22b4abc46c552bfc21003853b74e732da773cd1d";
    sha256 = "07xspyn4w5v47gv6dbliic8f73i4hqma1640y5108n9c5lx45ffp";
  };

  patches = [
    # http://openocd.zylin.com/#/c/4807/
    (fetchpatch {
      name = "4807.patch";
      url = "http://openocd.zylin.com/gitweb?p=openocd.git;a=patch;h=cf8a8ecfbc39118b0c90b3ca46815198a31a85b7";
      sha256 = "14f9d017l30i0l759p4l2vfqbkls2m7f0fidpwmnqkaca8f4mh05";
    })
    # http://openocd.zylin.com/#/c/5320/2
    (fetchpatch {
      name = "5320.patch";
      url = "http://openocd.zylin.com/gitweb?p=openocd.git;a=patch;h=9e5746b53c9063819770142eb5a40211266264bb";
      sha256 = "1f0z7qj92w4pak1bams0gyr8bd1qh5pwxawbd90q15pz713by3r2";
    })
  ];

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
