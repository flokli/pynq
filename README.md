# pynq / zynq debug environment

## About this repository

This repository uses nix to provide a reproducible working environment. Please
follow https://nixos.org/nix to install it.

It is also necessary to install [direnv](https://direnv.net) to enter the
environment.

## Building a PYNQ
This code supports building full NixOS images with Nix.

The system configuration is described in `machines/pynq/configuration.nix`, and can be built with the following commands (from the repository root):

### SD Image
`nix-build -A pynq.sdImage` will build an image, that can be `dd`'ed to the
sdcard.

Use something like
```
zstdcat result/sd-image/nixos-sd-image-20.09pre-git-armv7l-linux.img.zst | dd bs=1M of=/dev/mmcblk0 status=progress
```

to write to the SD-Card.

#### Partition Layout
The NixOS tooling uses the following layout:

 - `FIRMWARE`, 30M, `vfat`:
    - `boot.bin`, containing initial chip initialization code.
    - `u-boot.img`, containing u-boot
    - `system.dtb`, containing u-boot's device tree file
 - `NIXOS_SD`, `ext4`:
    - `/boot/extlinux/extlinux.conf`
       containing the u-boot boot loader entries
    - `/boot/firmware`
      (empty, that's where the `FIRMWARE` partition is mounted to)
    - `/boot/nixos`
      containing the zImage, dtbs and initrd of all kernels referred in
      `extlinux.conf`.

#### Bootloader
We ship `pynqUboot` which contains two patches on top of mainline u-boot adding
support for `zynq-pynq-z1`.

Those still need to be mainlined.
They aren't yet, as SPI doesn't yet work (probably okay), but the
`ps7_init_gpl.c` also contains some lines from another board that might be
wrong.

This needs to be cross-referenced with their TRM.

For some reason, all the Zynq targets don't seem to properly detect their
boards, even though we set DEVICE_TREE as described in
https://gitlab.denx.de/u-boot/u-boot/-/commit/f7c6ee7fe7bcc387de4c92300f46cb725b845b53
.

This means instead of being able to use FDTDIR in extlinux and letting the
bootloader pick the right `.dtb` depending on what board it is, we need to
explicitly configure one via `FDT`. Work to make this possible in NixOS's
`extlinux` module has been sent upstream at
https://github.com/NixOS/nixpkgs/pull/91195.

### Incremental switching
This also supports switching already existing systems to a new configuration.

Run `pynq-deploy` from anywhere on the repo to build the system closure, copy
it over to a running PYNQ, switch and activate.

Do it more granular (and from the repo root) if you want to have finer control:

 - Run `nix-build -A pynq.toplevel` to obtain a new system closure (`$newClosure`)
 - Use `nix-copy-closure --to root@$pynqIP /nix/store/…` to copy the closure to
 - the target system
 - Set the new system profile by running
   `nix-env --profile /nix/var/nix/profiles/system --set $newClosure`
 - Activate it, by running `$newClosure/bin/switch-to-configuration switch`.
   Services referring to old configuration are automatically restarted. Kernel
   changes obviously require a reboot.

### Kernels
#### "Official" Xilinx Kernel
We provide Xilinx' official kernel (together with above mentioned device tree
file) at `linux_pynq_xilinx`, kernel modules at `linuxPackages_pynq_xilinx`.

As NixOS builds an `allmodyes` kernel by default, and uses a more recent
compiler toolchain than Xilinx, we found some issues and incompatibilities in
their kernel not detected by their test suite.

Some patches have been upstreamed, some other issues worked around by disabling
the offending kernel modules - see the git log at
https://github.com/Xilinx/linux-xlnx and nix/pkgs/linux-pynq for details.

When it's running, bitstreams from the kernels `firmware` folder can be
flashed by running

```
echo filename > /sys/class/fpga_manager/fpga0/firmware
```

#### Mainline Kernel (not recommended for now)
We provide a pretty recent mainline Linux Kernel, with the PYNQ-specific
devicetree file and more recent patches from xilinx to load an FPGA bitstream
via DEBUGFS in `./nix/pkgs/kernel/`.

It is available at `linux_pynq`, kernel modules at `linuxPackages_pynq`.

It should allow to flash bitstreams as simple as

```
cat path/to.bin > /sys/kernel/debug/fpga/fpga0/load
```

However, it seems loading bitstreams currently doesn't see to work. The kernel
only says

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

It might be some hardware state persistent across reboots that's missing from
our `ps7_init_gpl` code, but present in Xilinx' kernel - needs to be
investigated further.

## Building FPGA Firmware
Build FPGA bitstreams usually is not fun, requires proprietary tools, and is a
continuous source of errors.

This repo contains some helper functions meant to ease development - only the
location to some `.v` files needs to be specified, and Nix takes care of
providing all the required toolchains to build, synthesize, place and route,
all provided by and sanboxed with Nix.

See `machines/pynq/examples/blink` for an example, and
`machines/pynq/configuration.nix` how this can be used to be spliced into a
NixOS system.

### Tooling
#### `mkXilinxBit`
This consumes `src` pointing to some Verilog code (and optionally
`toplevelName`, which defaults to "main").

It will use `yosys` to synthesize this to `.edif` format, then use `vivado` to
place and route it to a `.bit` file - which will most likely be consumed by
`mkXilinxBin`.

#### `mkXilinxBin`
This consumes a `.bit` file and produces a `.bin` file in a `lib/firmware`
folder - ready for consumption by the `hardware.firmware` attribute.

### IP Cores
We tried programming without Xilinx' PS7 LogiCORE IP wrapper for the hard core.

Instead, we're using the primitives provided by yosys.

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

## Debugging
### OpenOCD
Nix provides a custom build of OpenOCD (mostly master), because the latest
OpenOCD release was years ago and doesn't work at all.

There's also a pynq-specific openocd config file at `openocd/zynq.conf`.

From inside the environment, invoke `openocd` like this:

```
openocd -d -f openocd/pynq.cfg
```

If you don't have the appropriate udev rules installed, you might need to run
it as root.

### GDB
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
