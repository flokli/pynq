{ buildLinux, fetchFromGitHub }:

buildLinux rec {
  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "linux-xlnx";
    rev = "efb8afa6517cc706ac1a722ab5551984c15932b2";
    sha256 = "03rq2izqns5vksby8gq9b0fkm3qhl5pgy30373bhx34lvqrdzgbj";
  };


  version = "4.19.0";
  modDirVersion = "4.19.0-xilinx";

  # branchVersion needs to be x.y.
  extraMeta.branch = "4.19";

  defconfig = "xilinx_zynq_defconfig";

  kernelPatches = [{
    name = "0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch";
    patch = ./0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch;
  }];

  # Xilinx' kernel doesn't even properly build entirely:

  # WARNING: modpost: missing MODULE_LICENSE() in drivers/clk/si5324drv.o
  # see include/linux/module.h for more information
  #   SHIPPED arch/arm/boot/compressed/hyp-stub.S
  #   SHIPPED arch/arm/boot/compressed/lib1funcs.S
  #   SHIPPED arch/arm/boot/compressed/ashldi3.S
  #   SHIPPED arch/arm/boot/compressed/bswapsdi2.S
  #   LDS     arch/arm/boot/compressed/vmlinux.lds
  #   AS      arch/arm/boot/compressed/head.o
  #   XZKERN  arch/arm/boot/compressed/piggy_data
  #   CC      arch/arm/boot/compressed/misc.o
  #   CC      arch/arm/boot/compressed/decompress.o
  #   CC      arch/arm/boot/compressed/string.o
  #   AS      arch/arm/boot/compressed/hyp-stub.o
  #   AS      arch/arm/boot/compressed/lib1funcs.o
  #   AS      arch/arm/boot/compressed/ashldi3.o
  #   AS      arch/arm/boot/compressed/bswapsdi2.o
  # ERROR: "xlate_irq" [drivers/staging/apf/xlnk.ko] undefined!
  # ERROR: "__aeabi_ldivmod" [drivers/mtd/spi-nor/cadence-quadspi.ko] undefined!
  # ERROR: "__aeabi_uldivmod" [drivers/mtd/spi-nor/cadence-quadspi.ko] undefined!
  # ERROR: "xilinx_vtc_probe" [drivers/gpu/drm/xilinx/xilinx_drm_sdi.ko] undefined!
  # ERROR: "xilinx_vtc_config_sig" [drivers/gpu/drm/xilinx/xilinx_drm_sdi.ko] undefined!
  # ERROR: "xilinx_vtc_reset" [drivers/gpu/drm/xilinx/xilinx_drm_sdi.ko] undefined!
  # ERROR: "xilinx_vtc_enable" [drivers/gpu/drm/xilinx/xilinx_drm_sdi.ko] undefined!
  # ERROR: "__aeabi_ldivmod" [drivers/clk/si5324drv.ko] undefined!
  # ERROR: "__aeabi_uldivmod" [drivers/clk/si5324drv.ko] undefined!
  # ERROR: "si5324_calcfreqsettings" [drivers/clk/clk-si5324.ko] undefined!
  # make[3]: *** [../scripts/Makefile.modpost:92: __modpost] Error 1
  # make[2]: *** [/build/source/Makefile:1229: modules] Error 2
  # make[2]: *** Waiting for unfinished jobs....
  #   AS      arch/arm/boot/compressed/piggy.o
  #   LD      arch/arm/boot/compressed/vmlinux
  #   OBJCOPY arch/arm/boot/zImage
  #   Kernel: arch/arm/boot/zImage is ready
  # make[1]: *** [Makefile:146: sub-make] Error 2
  # make: *** [Makefile:24: __sub-make] Error 2

  # so we disable problematic modules, great!
  extraConfig = ''
    # XILINX <3
    DRM_XILINX_DP n
    DRM_XILINX_DP_SUB n
    DRM_XILINX_MIPI_DSI n
    DRM_XILINX_SDI n
    XILINX_APF n
    XILINX_DMA_APF n

    SPI_CADENCE_QUADSPI n
    COMMON_CLK_SI5324 n


    FRAME_POINTER y
    KGDB y
    KGDB_SERIAL_CONSOLE y
  '';
}
