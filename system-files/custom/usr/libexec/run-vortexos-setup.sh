#!/bin/bash
set -euo pipefail

# vortexos: Anaconda handles user/hostname/timezone on install.
# The niri-based Zena setup wizard is not used here (niri is not installed).
# We mark setup as done immediately so greetd starts normally on every boot.

if [ -f /var/lib/zena-setup.done ]; then
    exit 0
fi

hostnamectl set-hostname vortexos --static
hostnamectl set-hostname "VortexOS" --pretty

touch /var/lib/zena-setup.done
