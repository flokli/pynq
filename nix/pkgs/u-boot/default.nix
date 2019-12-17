{ buildUBoot }:
buildUBoot {
  patches = [
    ./0001-ARM-zynq-add-Digilent-Zynq-PYNQ-Z1.patch
    ./0001-ARM-dts-xilinx-Fix-I2C-and-SPI-bus-warnings.patch
  ];
  defconfig = "zynq_pynq_z1_defconfig";
  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = ["u-boot.elf"];
}
