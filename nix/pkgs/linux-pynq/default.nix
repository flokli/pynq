{ buildLinux
, fetchurl
, ...
}:

buildLinux rec {
  version = "5.4.7";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "1jgwg5qb7lb30m5ywvpfagzrl6d0i524qpy3v99mina6j4fv5jdb";
  };

  kernelPatches = [{
    name = "0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch";
    patch = ./0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch;
  } {
    name = "0001-fpga-fpga-mgr-Add-readback-support.patch";
    patch = ./0001-fpga-fpga-mgr-Add-readback-support.patch;
  } {
    name = "0002-fpga-fpga-mgr-Add-debugfs-entry-for-loading-fpga-ima.patch";
    patch = ./0002-fpga-fpga-mgr-Add-debugfs-entry-for-loading-fpga-ima.patch;
  } {
    name = "0003-fpga-mgr-Update-the-status-for-fpga-manager.patch";
    patch = ./0003-fpga-mgr-Update-the-status-for-fpga-manager.patch;
  }];

  extraConfig = ''
    FPGA_MGR_DEBUG_FS y
    FRAME_POINTER y
    KGDB y
    KGDB_SERIAL_CONSOLE y
  '';
}
