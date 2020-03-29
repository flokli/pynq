{ buildLinux, fetchFromGitHub }:

buildLinux rec {
  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "linux-xlnx";
    rev = "aa3f6d41fc14b1a11ae450bab22fecd249451bac";
    sha256 = "1pbr4qcy80m9f54idarx2zm3v4vb178mx88b4sq5wa2l6572wm67";
  };


  version = "5.4.0";
  modDirVersion = "5.4.0-xilinx";

  # branchVersion needs to be x.y.
  extraMeta.branch = "5.4";

  defconfig = "xilinx_zynq_defconfig";

  kernelPatches = [{
    name = "0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch";
    patch = ./0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch;
  } {
    name = "0001-v4l-xilinx-multi-scaler-fix-build.patch";
    patch = ./0001-v4l-xilinx-multi-scaler-fix-build.patch;
  } {
    name = "0001-drm-i2c-adv7511-add-missing-include-to-drm-drm_probe.patch";
    patch = ./0001-drm-i2c-adv7511-add-missing-include-to-drm-drm_probe.patch;
  } {
    name = "0001-xilinx-dma-fix-some-typos-in-the-Kconfig-help-texts.patch";
    patch = ./0001-xilinx-dma-fix-some-typos-in-the-Kconfig-help-texts.patch;
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
    DRM_XLNX n
    XILINX_APF n
    XILINX_DMA_APF n

    SPI_CADENCE_QUADSPI n
    COMMON_CLK_SI5324 n

    # ERROR: "__aeabi_ldivmod" [drivers/rtc/rtc-zynqmp.ko] undefined!
    # ERROR: "__aeabi_uldivmod" [drivers/rtc/rtc-zynqmp.ko] undefined!
    RTC_DRV_ZYNQMP n

    # drivers/misc/xilinx_flex_pm.c:356:22: error: 'struct xflex_dev_info' has no member named 'lock'
    XILINX_FLEX_PM n

    FRAME_POINTER y
    KGDB y
    KGDB_SERIAL_CONSOLE y
  '';
}
