# ================================================================
# VortexOS Containerfile
# Base image : quay.io/fedora/fedora-bootc:45
# Target base  : --target vortexos
# Target nvidia: --target vortexos-nvidia
# ================================================================

FROM quay.io/fedora/fedora-bootc:45 AS vortexos

# COPRs
RUN dnf5 copr enable -y bieszczaders/kernel-cachyos \
 && dnf5 copr enable -y avengemedia/dms

# CachyOS kernel — sostituisce il kernel stock Fedora
RUN dnf5 install -y --allowerasing kernel-cachyos

# Stack desktop
RUN dnf5 install -y \
      dms \
      dms-greeter \
      greetd \
      hyprland \
      xdg-desktop-portal-hyprland \
      xdg-desktop-portal-gtk \
      hypridle \
      hyprlock \
      hyprpaper \
      waybar \
      wofi \
      dunst \
      kitty \
      flatpak \
      polkit \
      gnome-keyring \
      xdg-user-dirs \
      pipewire \
      pipewire-pulseaudio \
      wireplumber

# File di sistema
COPY system-files/ /
RUN chmod +x /usr/libexec/vortexos-flatpak-install.sh

# Variabili Wayland globali
RUN printf '%s\n' \
      'XDG_SESSION_TYPE=wayland' \
      'QT_QPA_PLATFORM=wayland' \
      'QT_QPA_PLATFORMTHEME=gtk3' \
      'ELECTRON_OZONE_PLATFORM_HINT=auto' \
      >> /etc/environment

# Branding VortexOS
RUN sed -i \
      -e 's|^NAME=.*|NAME="VortexOS"|' \
      -e 's|^ID=.*|ID=vortexos|' \
      -e 's|^PRETTY_NAME=.*|PRETTY_NAME="VortexOS"|' \
      /usr/lib/os-release

# Remote Flathub di sistema
RUN mkdir -p /etc/flatpak/remotes.d \
 && curl -fsSL https://dl.flathub.org/repo/flathub.flatpakrepo \
         -o /etc/flatpak/remotes.d/flathub.flatpakrepo

# Servizi e target di default
RUN systemctl enable greetd.service vortexos-flatpak.service \
 && systemctl --global enable dms.service \
 && systemctl set-default graphical.target

RUN bootc container lint

# ================================================================
# VortexOS Nvidia — estende la variante base
# ================================================================

FROM vortexos AS vortexos-nvidia

# RPMFusion
RUN dnf5 install -y \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-45.noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-45.noarch.rpm

# Driver Nvidia (akmod-595 default RPMFusion F45) + CUDA + headers per akmods
RUN dnf5 install -y \
      akmod-nvidia \
      xorg-x11-drv-nvidia-cuda \
      kernel-cachyos-devel

# Blacklist nouveau
RUN printf 'blacklist nouveau\noptions nouveau modeset=0\n' \
      > /etc/modprobe.d/blacklist-nouveau.conf

# Variabili Wayland specifiche Nvidia
RUN printf '%s\n' \
      'LIBVA_DRIVER_NAME=nvidia' \
      '__GLX_VENDOR_LIBRARY_NAME=nvidia' \
      'WLR_NO_HARDWARE_CURSORS=1' \
      >> /etc/environment

RUN bootc container lint
