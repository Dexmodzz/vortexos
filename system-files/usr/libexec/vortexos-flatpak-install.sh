#!/bin/bash
set -euo pipefail

# Registra Flathub come remote di sistema (idempotente)
flatpak remote-add --if-not-exists --system flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

apps=(
    com.vscodium.codium
    com.system76.CosmicStore
)

for app in "${apps[@]}"; do
    if ! flatpak info --system "$app" &>/dev/null; then
        flatpak install --system --noninteractive flathub "$app"
    fi
done

# Override Wayland per VSCodium
flatpak override --system com.vscodium.codium \
    --env=ELECTRON_OZONE_PLATFORM_HINT=wayland

touch /var/lib/vortexos-flatpak.done
