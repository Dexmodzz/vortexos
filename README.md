# VortexOS

Distro immutabile basata su Fedora bootc 45 con kernel CachyOS, Hyprland e DMS.

## Stack

| Componente | Dettaglio |
|---|---|
| Base image | `quay.io/fedora/fedora-bootc:45` |
| Kernel | CachyOS (`bieszczaders/kernel-cachyos`) |
| Shell | DMS + DankGreeter (`avengemedia/dms`) |
| Compositor | Hyprland + hypridle + hyprlock + hyprpaper |
| Bar / Launcher | Waybar + Wofi |
| Notifiche | Dunst |
| Terminale | Kitty |
| App store | Flatpak + Flathub (VSCodium, Cosmic Store al primo avvio) |

## Varianti

| Target | Immagine |
|---|---|
| Base | `ghcr.io/<owner>/vortexos:latest` |
| Nvidia | `ghcr.io/<owner>/vortexos-nvidia:latest` |

La variante nvidia aggiunge `akmod-nvidia` (595) + CUDA + blacklist nouveau + variabili Wayland nvidia.

## Build locale

```bash
# Variante base
buildah bud --target vortexos -t vortexos:local .

# Variante nvidia
buildah bud --target vortexos-nvidia -t vortexos-nvidia:local .
```

## Aggiornamenti

```bash
sudo bootc upgrade && sudo reboot
```

## Primo avvio

Al primo avvio con rete disponibile, `vortexos-flatpak.service` installa automaticamente:
- `com.vscodium.codium` (con override Wayland)
- `com.system76.CosmicStore`
