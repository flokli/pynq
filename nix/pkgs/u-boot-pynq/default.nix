{ buildUBoot, fetchFromGitLab }:
buildUBoot {
  version = "v2020.01-rc5-73";
  src = fetchFromGitLab {
    domain = "gitlab.denx.de";
    owner = "u-boot";
    repo = "u-boot";
    rev = "2b8692bac1e8795cbb87b0d00213fd193409851d";
    sha256 = "0i73l22cs0pf4vaa46cwa590d6wc5zqi5gwmchmx3k60d0fdbcyv";
  };
  patches = [
    ./0001-ARM-zynq-add-Digilent-Zynq-PYNQ-Z1.patch
    ./0002-pynq-add-ps7_init_gpl.c.patch
  ];
  defconfig = "xilinx_zynq_virt_defconfig";
  preConfigure = ''
    export DEVICE_TREE=zynq-pynq-z1
  '';
  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = ["spl/boot.bin" "u-boot.img" "u-boot.dtb"];
}
