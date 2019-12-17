{ buildLinux, fetchurl }:

buildLinux rec {
  version = "5.4.3";
  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "0lgfg31pgvdhkh9y4y4yh075mlk3qa6npxp7n19yxcg168pnhcb7";
  };

  kernelPatches = [{
    name = "0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch";
    patch = ./0001-ARM-dts-pynq-Add-Digilent-Zynq-PYNQ-Z1-Board.patch;
  }];

  # TODO: check if these are modules in the default kernel anyways and we don't need custom config
  extraConfig = ''
    CONFIG_FPGA y
    CONFIG_ARCH_ZYNQ y
    CONFIG_FPGA_MGR_ZYNQ_FPGA y

    CONFIG_GPIO_XILINX y
    CONFIG_GPIO_XILINX_PS y

    CONFIG_I2C_XILINX y
    CONFIG_I2C_XILINX_PS y

    CONFIG_PCIE_XILINX y
    CONFIG_PCIE_XILINX_NWL y
    CONFIG_SERIAL_XILINX_PS_UART y
    CONFIG_SERIAL_XILINX_PS_UART_CONSOLE y

    CONFIG_SPI_XILINX y

    # Say Y here if you want to support bridges connected between host
    # processors and FPGAs or between FPGAs.
    CONFIG_FPGA_BRIDGE y

    # Say Y to enable drivers for Xilinx LogiCORE PR Decoupler.
    # The PR Decoupler exists in the FPGA fabric to isolate one.
    # region of the FPGA from the busses while that region is.
    # being reprogrammed during partial reconfig.
    CONFIG_XILINX_PR_DECOUPLER y
  '';
}
