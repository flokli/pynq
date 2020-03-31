{ buildLinux, fetchFromGitHub }:

buildLinux rec {
  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "linux-xlnx";
    rev = "bc1d49b390e66e6aa0d98e26d8f124ba25846c1b";
    sha256 = "1y4vhskr593x8w46jjgxdzcll3s5p0r0q366sfpyakc88r3d6l03";
  };


  version = "5.4.0";
  modDirVersion = "5.4.0-xilinx";

  # branchVersion needs to be x.y.
  extraMeta.branch = "5.4";

  defconfig = "xilinx_zynq_defconfig";

  kernelPatches = [{
    name = "0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch";
    patch = ./0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch;
  }];

  # Xilinx' kernel doesn't properly build entirely:
  # so we disable problematic modules, great!
  extraConfig = ''
    # armv7l-unknown-linux-gnueabihf-ld: drivers/gpu/drm/xlnx/xlnx_drv.o: in function `xlnx_drm_drv_exit':
    # xlnx_drv.c:(.exit.text+0x14): undefined reference to `xlnx_bridge_helper_fini'
    # armv7l-unknown-linux-gnueabihf-ld: drivers/gpu/drm/xlnx/xlnx_drv.o: in function `xlnx_drm_drv_init':
    # xlnx_drv.c:(.init.text+0x14): undefined reference to `xlnx_bridge_helper_init'
    DRM_XLNX n

    # ERROR: "__aeabi_ldivmod" [drivers/mtd/spi-nor/cadence-quadspi.ko] undefined!
    # ERROR: "__aeabi_uldivmod" [drivers/mtd/spi-nor/cadence-quadspi.ko] undefined!
    SPI_CADENCE_QUADSPI n

    # ERROR: "__aeabi_ldivmod" [drivers/clk/clk-si5324drv.ko] undefined!
    # ERROR: "__aeabi_uldivmod" [drivers/clk/clk-si5324drv.ko] undefined!
    COMMON_CLK_SI5324 n

    # ERROR: "__aeabi_ldivmod" [drivers/rtc/rtc-zynqmp.ko] undefined!
    # ERROR: "__aeabi_uldivmod" [drivers/rtc/rtc-zynqmp.ko] undefined!
    RTC_DRV_ZYNQMP n

    FRAME_POINTER y
    KGDB y
    KGDB_SERIAL_CONSOLE y
  '';
}
