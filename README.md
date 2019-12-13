# pynq / zynq debug environment

This repository uses nix to provide a reproducible working environment. Please
follow https://nixos.org/nix to install it.

It also uses [direnv](https://direnv.net) to enter the environment
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
A `.gdbinit` file is provided in the repo root.
Make sure your `~/.gdbinit` contains a
```
add-auto-load-safe-path /path/to/repo/.gdbinit
```

You should then be able to invoke `gdb` without any parameters.
