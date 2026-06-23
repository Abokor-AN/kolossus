#!/bin/bash

set -eEuo pipefail

KOLLOSSUS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PACKAGES_FILE="$KOLLOSSUS_DIR/packages.txt"

if ((EUID == 0)); then
  printf 'Lance ce script avec ton utilisateur normal, pas avec sudo.\n' >&2
  exit 1
fi

if [[ ! -f /etc/arch-release ]]; then
  printf 'Kolossus ne prend en charge qu’Arch Linux.\n' >&2
  exit 1
fi

if ! command -v sudo >/dev/null || ! command -v pacman >/dev/null; then
  printf 'sudo et pacman sont requis.\n' >&2
  exit 1
fi

mapfile -t packages < <(sed -E '/^[[:space:]]*(#|$)/d' "$PACKAGES_FILE")

printf 'Installation de %d paquets officiels Arch...\n' "${#packages[@]}"
sudo -v
sudo pacman -Syu --needed "${packages[@]}"
sudo usermod --shell /bin/bash "$USER"

printf '\nActivation des services système...\n'
sudo systemctl enable bluetooth.service
display_manager=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)
if [[ -z $display_manager ]]; then
  sudo systemctl enable sddm.service
elif [[ $display_manager != */sddm.service ]]; then
  printf 'Gestionnaire de connexion existant conservé : %s\n' "$display_manager"
fi
sudo systemctl enable fstrim.timer
sudo systemctl enable power-profiles-daemon.service
sudo systemctl enable thermald.service

sudo systemctl start bluetooth.service
sudo systemctl start fstrim.timer
sudo systemctl start power-profiles-daemon.service
sudo systemctl start thermald.service

if ! systemctl is-enabled NetworkManager.service >/dev/null 2>&1 && ! systemctl is-enabled iwd.service >/dev/null 2>&1; then
  sudo systemctl enable --now NetworkManager.service
fi

printf '\nActivation de la pile audio utilisateur...\n'
if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket || true
  systemctl --user start wireplumber.service || true
fi

xdg-user-dirs-update

printf '\nDéploiement des dotfiles...\n'
"$KOLLOSSUS_DIR/install.sh"

printf '\nValidation...\n'
"$KOLLOSSUS_DIR/check.sh"
Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.conf"

printf '\nInstallation terminée.\n'
printf 'Redémarre la machine, puis sélectionne Hyprland (UWSM) dans SDDM.\n'

