#!/usr/bin/env bash

set -eou pipefail

if [[ -z "${PYNQ_IP-}" ]];then
	echo "PYNQ_IP needs to be provided - Please export in .envrc.local!" >&2
	exit 1
fi

echo "Building PYNQ closure…"
newClosure=$(nix-build $(git rev-parse --show-toplevel)/default.nix -A pynq.toplevel --no-out-link)

echo "Copying closure to PYNQ…"
nix-copy-closure --to root@$PYNQ_IP $newClosure

echo "Setting system profile and activating closure…"
ssh root@$PYNQ_IP "nix-env --profile /nix/var/nix/profiles/system --set $newClosure && $newClosure/bin/switch-to-configuration switch"
