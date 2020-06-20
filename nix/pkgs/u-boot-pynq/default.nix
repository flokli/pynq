{ buildUBoot, fetchFromGitLab }:
buildUBoot {
  version = "v2020.01-rc5-73";
  src = fetchFromGitLab {
    domain = "gitlab.denx.de";
    owner = "u-boot";
    repo = "u-boot";
    rev = "4b75aa5aa78768fc81b782ee51d960dfed76f6e1";
    sha256 = "1s1i7jjx4g999b2h5dp7p3a5ahgg002iip7h0ah14761wx1xizv1";
  };
  patches = [
    ./0001-ARM-zynq-add-Digilent-Zynq-PYNQ-Z1.patch
    ./0001-ARM-dts-xilinx-Fix-I2C-and-SPI-bus-warnings.patch
    ./0001-pynq-add-ps7_init_gpl.c.patch
  ];
  defconfig = "zynq_pynq_z1_defconfig";
  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = ["spl/boot.bin" "u-boot.img" "u-boot.dtb"];
}
