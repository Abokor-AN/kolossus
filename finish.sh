#!/bin/bash

set -Euo pipefail

KOLLOSSUS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if ((EUID == 0)); then
  printf 'Lance ce script avec ton utilisateur normal, pas avec sudo.\n' >&2
  exit 1
fi

if ! command -v sudo >/dev/null; then
  printf 'sudo est requis.\n' >&2
  exit 1
fi

enable_optional_unit() {
  local unit=$1

  if ! sudo systemctl enable --now "$unit"; then
    printf 'Avertissement : impossible d’activer %s.\n' "$unit" >&2
  fi
}

printf 'Validation de l’accès administrateur...\n'
sudo -v

printf '\nDéploiement des dotfiles Kolossus...\n'
xdg-user-dirs-update
"$KOLLOSSUS_DIR/install.sh"

printf '\nValidation des dépendances et de Hyprland...\n'
"$KOLLOSSUS_DIR/check.sh"
Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.conf"

printf '\nActivation des services complémentaires...\n'
enable_optional_unit bluetooth.service
enable_optional_unit fstrim.timer
enable_optional_unit power-profiles-daemon.service
enable_optional_unit thermald.service

if ! systemctl is-enabled NetworkManager.service >/dev/null 2>&1 && ! systemctl is-enabled iwd.service >/dev/null 2>&1; then
  enable_optional_unit NetworkManager.service
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket || true
  systemctl --user start wireplumber.service || true
fi

display_manager_path=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)
if [[ -n $display_manager_path ]]; then
  display_manager_unit=$(basename "$display_manager_path")
elif systemctl list-unit-files sddm.service --no-legend 2>/dev/null | grep -q '^sddm.service'; then
  display_manager_unit=sddm.service
  sudo systemctl enable "$display_manager_unit"
else
  printf 'Aucun gestionnaire graphique disponible. Le paquet sddm est manquant.\n' >&2
  exit 1
fi

printf '\nDémarrage de l’interface graphique avec %s...\n' "$display_manager_unit"
if ! sudo systemctl start "$display_manager_unit"; then
  printf '\nÉchec du gestionnaire graphique. Derniers journaux :\n' >&2
  sudo journalctl -b -u "$display_manager_unit" -n 80 --no-pager >&2
  exit 1
fi

printf 'Le gestionnaire graphique est démarré. Sélectionne Hyprland (uwsm-managed).\n'

