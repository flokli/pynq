flash_mainline_boot:
	$(eval TMP := $(shell mktemp -d))
	sudo mount /dev/mmcblk0p1 $(TMP)
	sudo rsync -va $(shell nix-build -A pynqBootFS)/. $(TMP) --delete
	sudo umount $(TMP)

flash_mainline_kmods:
	$(eval TMP := $(shell mktemp -d))
	sudo mount /dev/mmcblk0p3 $(TMP)
	sudo rsync -va $(shell nix-build -A pynqKernel)/lib/modules/$(shell nix eval --raw -f . pynqKernel.modDirVersion) $(TMP) --delete
	sudo umount $(TMP)

flash_mainline: flash_mainline_boot flash_mainline_kmods

flash_xilinx_boot:
	$(eval TMP := $(shell mktemp -d))
	sudo mount /dev/mmcblk0p1 $(TMP)
	sudo rsync -va $(shell nix-build -A pynqBootFSXilinx)/. $(TMP) --delete
	sudo umount $(TMP)

flash_xilinx_kmods:
	$(eval TMP := $(shell mktemp -d))
	sudo mount /dev/mmcblk0p3 $(TMP)
	sudo rsync -va $(shell nix-build -A pynqKernelXilinx)/lib/modules/$(shell nix eval --raw -f . pynqKernelXilinx.modDirVersion) $(TMP) --delete
	sudo umount $(TMP)

make flash_xilinx: flash_xilinx_boot flash_xilinx_kmods
