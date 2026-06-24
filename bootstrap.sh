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

printf '\nFinalisation du bureau Kolossus...\n'
exec "$KOLLOSSUS_DIR/finish.sh"
