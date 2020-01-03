# pynq / zynq debug environment

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


## Partition Layout, SD Card Image
The initial bootcode only understands `dos` partitions, so the following layout
needs to be used:
 - /boot: 500M, vfat
 - swap: 10G, swap
 - /: rest, ext4

/boot is built via nix:
`nix-build -A pynqBootFS`, mount and rsync over to partition 1

/root is ArchlinuxARM (for now).
 - Download https://de5.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz and
 - extracted it on the 3rd partition
 - add `ttyPS0` to `etc/securetty`
 - make sure the file system is mounted rw in /etc/fstab! Otherwise, pam_tally2(login:auth): Couldn't create /var/log/tallylog, and you can't login :-/
   `/etc/fstab`:
   > /dev/root / auto auto 0 0
   > /dev/mmcblk0p1 /boot auto auto 0 0
   > /dev/mmcblk0p2 none swap sw 0 0
 - copy over kernel modules from `$(nix-build -A pynqKernel)/lib/modules`
 - copy over ssh pubkey
 - profit!

### Trying with the official Xilinx Kernel
If for some reason you want to use Xilinx' kernel, use `pynqBootFSXilinx` to
create new `/boot` instead of `pynqBootFS`.
Also remember to copy over the kernel modules from `pynqKernelXilinx` instead
of `pynqKernel`.
