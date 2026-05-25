# ================================================================
# VortexOS Containerfile
# Base image : quay.io/fedora/fedora-bootc:45
# Target base  : --target vortexos
# Target nvidia: --target vortexos-nvidia
# ================================================================

FROM quay.io/fedora/fedora-bootc:45 AS vortexos

# Plugin COPR (non incluso di default in fedora-bootc) + abilitazione COPR
RUN dnf5 install -y 'dnf5-command(copr)' \
 && dnf5 copr enable -y bieszczaders/kernel-cachyos \
 && dnf5 copr enable -y avengemedia/dms

# CachyOS kernel — pacchetti esistenti nel COPR: kernel-cachyos, -core, -modules
# (kernel-cachyos-modules-core e -extra non esistono nel COPR)
# dracut rigenera l'initramfs; richiede buildah --privileged in CI
RUN dnf5 install -y \
      --setopt=install_weak_deps=False \
      --downloadonly \
      --destdir=/tmp/kernel-rpms \
      kernel-cachyos \
      kernel-cachyos-core \
      kernel-cachyos-modules \
 && rpm -ivh --noscripts --nodeps /tmp/kernel-rpms/kernel-cachyos*.rpm \
 && KVER=$(rpm -q kernel-cachyos-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -1) \
 && echo "Kernel version: ${KVER}" \
 && depmod -a "${KVER}" \
 && dracut --no-hostonly \
           --kver "${KVER}" \
           --reproducible \
           --add ostree \
           -f "/boot/initramfs-${KVER}.img" \
 && rm -rf /tmp/kernel-rpms

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
