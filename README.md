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
