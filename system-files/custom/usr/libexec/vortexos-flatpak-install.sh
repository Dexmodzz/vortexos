#!/bin/bash
set -euo pipefail

apps=(
    com.system76.CosmicStore
)

for app in "${apps[@]}"; do
    if ! flatpak info --system "$app" &>/dev/null; then
        flatpak install --system --noninteractive flathub "$app"
    fi
done
