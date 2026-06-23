#!/bin/bash

set -eEuo pipefail

KOLLOSSUS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PACKAGES_FILE="$KOLLOSSUS_DIR/packages.txt"
OBSOLETE_PACKAGES_FILE="$KOLLOSSUS_DIR/obsolete-packages.txt"

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

mapfile -t obsolete_packages < <(sed -E '/^[[:space:]]*(#|$)/d' "$OBSOLETE_PACKAGES_FILE")
installed_obsolete_packages=()

for package in "${obsolete_packages[@]}"; do
  if pacman -Q "$package" >/dev/null 2>&1; then
    installed_obsolete_packages+=("$package")
  fi
done

if ((${#installed_obsolete_packages[@]} > 0)); then
  printf '\nSuppression de l’ancienne pile Hyprland et des outils remplacés...\n'
  sudo pacman -Rns "${installed_obsolete_packages[@]}"
fi

sudo usermod --shell /bin/bash "$USER"

printf '\nFinalisation du bureau Kolossus...\n'
exec "$KOLLOSSUS_DIR/finish.sh"
