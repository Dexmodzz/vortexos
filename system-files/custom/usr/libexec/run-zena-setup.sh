#!/bin/bash
set -euo pipefail

# vortexos: Anaconda handles user/hostname/timezone at install time.
# The niri-based Zena setup wizard is intentionally skipped (niri not installed).
# greetd is NOT masked here — it must start normally on every boot.

if [ -f /var/lib/zena-setup.done ]; then
    exit 0
fi

touch /var/lib/zena-setup.done
