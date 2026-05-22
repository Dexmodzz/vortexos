set -ouex pipefail

shopt -s nullglob

packages=(
  adw-gtk3-theme
  alacritty
  cava
  danksearch
  dgop
  dms
  dms-greeter
  glycin-thumbnailer
  kanshi
  khal
  kf6-kimageformats
  nautilus
  papirus-icon-theme
  quickshell
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
  wl-clipboard

  # Display manager
  greetd

  # Shell Hyprland: barra, launcher, notifiche, terminale
  waybar
  wofi
  dunst
  kitty
)
dnf5 -y install "${packages[@]}" --exclude=matugen --exclude=noctalia-qs

# Hyprland: installato dopo libdisplay-info.so.2 già presente (pre-installata
# in dnf.sh con priorità COPR solopasha/hyprland = 1).
dnf5 -y install \
  hyprland \
  xdg-desktop-portal-hyprland \
  hypridle \
  hyprlock \
  hyprpaper
dnf5 -y install nautilus-python matugen --releasever=44 --disablerepo='*copr*'

packages=(
  gnome-keyring
  gnome-keyring-pam
  mangowc
  pinentry-gnome3
  zenity
)

dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

XDG_EXT_TMPDIR="$(mktemp -d)"
curl -fsSLo - "$(curl -fsSL https://api.github.com/repos/tulilirockz/xdg-terminal-exec-nautilus/releases/latest | jq -rc .tarball_url)" | tar -xzvf - -C "${XDG_EXT_TMPDIR}"
install -Dpm0644 -t "/usr/share/nautilus-python/extensions/" "${XDG_EXT_TMPDIR}"/*/xdg-terminal-exec-nautilus.py
rm -rf "${XDG_EXT_TMPDIR}"

dconf update
systemctl set-default graphical.target

# niri rimosso: niente più manipolazione del niri.desktop

# Aggiorna la sessione mango (DMS) con il launcher corretto
sed -i 's|^Exec=.*|Exec=bash -c "mango -s mango-session > /dev/null 2>\&1"|' \
  /usr/share/wayland-sessions/mango.desktop

# Kitty come terminale xdg di default
echo "kitty.desktop" > /etc/xdg/xdg-terminals.list

