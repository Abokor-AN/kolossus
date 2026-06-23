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

printf '\nValidation des dépendances et de Niri...\n'
"$KOLLOSSUS_DIR/check.sh"
niri validate --config "$HOME/.config/niri/config.kdl"

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

mkdir -p "$KOLLOSSUS_DIR/verification"
printf 'Vérification initiale en attente.\n' >"$KOLLOSSUS_DIR/verification/pending"

display_manager_unit=sddm.service

if ! systemctl list-unit-files "$display_manager_unit" --no-legend 2>/dev/null | grep -q '^sddm.service'; then
  printf 'Le paquet SDDM est installé sans unité sddm.service exploitable.\n' >&2
  printf 'Démarrage direct de Niri...\n'
  exec niri-session -l
fi

printf '\nActivation et démarrage de %s...\n' "$display_manager_unit"
if ! sudo systemctl enable --now "$display_manager_unit"; then
  printf '\nÉchec de SDDM. Derniers journaux :\n' >&2
  sudo journalctl -b -u "$display_manager_unit" -n 80 --no-pager >&2 || true
  printf 'Démarrage direct de Niri...\n'
  exec niri-session -l
fi

printf 'SDDM est démarré. Sélectionne Niri.\n'
