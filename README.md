# pynq / zynq debug environment

## Credits
The research and work was done together with Thomas Heijligen!

Without working together there were no chance to get so far with upstream and
open source components. Contributing to upstream Projects is a benefit for
everyone. Not doing it is pain for for all doing the same work again.  When not
just simply clicking the ip cores together in Vivado, one needs a much deeper
understanding of the Zynq system and FPGA bitstream creation, at least until
sufficient documentation has been written.

Open tooling make it much easier to understand these internals and work with
it.

Thanks to:
	David Sahah @fpga_dave
	Claire /Clifford Wold @oe1cxw
	Karol Gugala @KGugala
	Dan Gisselquist @ZipCPU
	Tristan Gingold

## About this repository

This repository uses nix to provide a reproducible working environment. Please
follow https://nixos.org/nix to install it.

Afterwards, you can invoke `nix-shell` to enter the environment.

You can also use [direnv](https://direnv.net) to enter the environment
automatically.

## OpenOCD
Nix provides a custom build of OpenOCD (mostly master), because the latest
OpenOCD release was years ago and doesn't work at all.

There's also a pynq-specific openocd config file at `openocd/zynq.conf`.

From inside the environment, invoke `openocd` like this:

```
openocd -d -f openocd/pynq.cfg
```

If you don't have the appropriate udev rules installed, you might need to run
it as root.

## GDB
Nix provides a GDB multiarch binary. You should then be able run it simply by
invoking `gdb`.

Once in gdb, you want to invoke something like the following command sequence:

```
set pagination off
file /path/to/elf
target extended-remote :3333
monitor halt
load
layout asm
layout src
layout split
```

## U-boot
`nix/pkgs/u-boot provides a recent u-boot with two patches on top:
 - `0001-ARM-dts-xilinx-Fix-I2C-and-SPI-bus-warnings.patch`
   nailcare to shut up some warnings, already sent upstream at
   https://lists.denx.de/pipermail/u-boot/2019-December/393892.html
 - `0001-ARM-zynq-add-Digilent-Zynq-PYNQ-Z1.patch`
   adds a PYNQ devicetree file to u-boot.
   TODO: This isn't yet sent upstream, as SPI or other means to store the
   u-boot env don't work yet.

It also seems with the refactor to defconfigs, uboot's mainline the dtb
filename generation got messed up.

In a nice world, one could simply set `fdtdir` to a location containing
multiple ftds, and u-boot would read from `${soc}-${board}.dtb` (in our case
`zynq-pynq-z1.dtb`).
However, when starting uboot, currently `$soc` and `$board` currently both
contain `zynq`, and it seems `$board` can't really be set from the defconfigs.

For now, we set the `fdtfile` directly in extlinux config.

## Linux Kernel
### Mainline
We provide a pretty recent mainline Linux Kernel, with the PYNQ-specific
devicetree file and more recent patches from xilinx to load an FPGA bitstream
via DEBUGFS in `./nix/pkgs/kernel/`.

This allows to flash bitstreams as simple as

```
dd of=/sys/kernel/debug/fpga/fpga0/load bs=26M if=path/to.bin
```

However, it seems something with initial hardware setup is somewhat broken.
Sometimes the kernel only says

```
[   39.116802] fpga_manager fpga0: Error after writing image data to FPGA
[   39.123388] fpga_manager fpga0: fpga_mgr_load returned with value -110
[   39.123388] 
dd: writing to '/sys/kernel/debug/fpga/fpga0/load': Connection timed out
1+0 records in
0+0 records out
0 bytes copied, 2.52188 s, 0.0 kB/s
```

and doesn't load the bitstream.

However, if we previously booted a Xilinx kernel and programmed a bitstream via
that, then did a soft reset and booted into the mainline kernel, we were able
to program via that method.

### "Official" Xilinx Kernel
We also provide Xilinx' official kernel (together with above mentioned device
tree file). It lives in `./nix/pkgs/kernel-xilinx`.

When it's running, bitstreams can be flashed by copying the `.bin` to
`/lib/firmware`, then running

```
echo filename > /sys/class/fpga_manager/fpga0/firmware
```

## Partition Layout, SD Card Image
The initial bootcode only understands `dos` partitions, so the following layout
needs to be used:
 - /boot: 500M, vfat
 - swap: 10G, swap
 - /: rest, ext4

/boot is built via nix:
`nix-build -A pynqBootFS`, mount and rsync over to partition 1

/root is ArchlinuxARM (for now).
 - Download https://de5.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
 - extract it on the root partition
 - add `ttyPS0` to `etc/securetty`
 - make sure the file system is mounted rw in /etc/fstab! Otherwise, pam_tally2(login:auth): Couldn't create /var/log/tallylog, and you can't login :-/
   `/etc/fstab`:
   > /dev/root / auto auto 0 0
   > /dev/mmcblk0p1 /boot auto auto 0 0
   > /dev/mmcblk0p2 none swap sw 0 0
 - copy over kernel modules from `$(nix-build -A pynqKernel)/lib/modules`
 - copy over ssh pubkey
 - profit!

## Build bitstreams
bitstreams can be produced by invoking xilinx-bootgen with a text file, which
contains some syntactic sugar and effectively points to the .bit file, which
might have been built by vivado.

This can be simplified by calling

```
nix-build nix/default.nix -A pkgs.mkXilinxBin --arg bit ./somepath/foo.bit --arg bif null
```

If you already have an existing bif, you need to set bit to null and pass bif respectively.

The `Makefile` already has a `%.bin` target, which looks for a `.bit` file in
that same directory, so invoking `make somepath/foo.bin` will produce a
`somepath/foo.bin` if a `somepath/foo.bit` exists.

## Less Vivado <3
We tried programming without Xilinx' PS7 IP Core (yosys only synthesizing,
Vivado for place and route).

On first tries, we were able to get some somewhat working FPGA bitstreams, but
the PS "stalled" - serial didn't react anymore, and we could only get it back
by pressing the "PROG" switch, which resets the PL and causes DONE to be
de-asserted. Some things still seemed to be broken, as the kernel couldn't
actually access its root filesystem anymore - requiring a reboot.

Later, we discovered this can be fixed by simply properly connecting FCLKCLK
from PS7, and using it as a clock:

```verilog
PS7 the_PS (
  .FCLKCLK (fclk)
);
```

See
https://github.com/heijligen/zynq_yosys/commit/f5d0cd952e8a424c94b10077b72aef274e505ead
for a full example.

As written there, this approach does do synthesis with Yosys, and invokes
Vivado only for place & route. As yosys already has limited support to do
xilinx bitstream generation, chances are high it'll eventually get a backend
for the zynq-based ones too.

### Synthesize with Yosys:

```
yosys -p 'read_verilog +/xilinx/cells_xtra.v path/to/*.v; synth_xilinx -edif blink.edif -top blink
```

### Create tcl script to be executed by vivado:

We save the following contents inside `blink.tcl`:
```
read_xdc pynq.xdc
read_edif blink.edif
link_design -part xc7z020clg400 -top blink
place_design
route_design
write_bitstream -force blink.bit
```

The `pynq.xdc` comes from [the Digilent
Website](https://reference.digilentinc.com/reference/programmable-logic/pynq-z1/start),
with used ports commented in.


### Invoke Vivado
This starts Vivado headless in batch mode (not project mode, headless) to
execute above tcl script:

```
vivado -nolog -nojournal -mode batch -source blink.tcl
```

Afterwards, there should be a blink.bit.
You can use the Makefile from this repo to produce a `blink.bin`, which can be
programmed to the running device though FPGA manager as described above.
