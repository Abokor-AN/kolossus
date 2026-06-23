#!/bin/bash

set -euo pipefail

KOLLOSSUS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOTFILES_DIR="$KOLLOSSUS_DIR/dotfiles"
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/kolossus/backups/$(date +%Y%m%d-%H%M%S)"

backup_and_link() {
  local source=$1
  local target=$2
  local source_real
  local backup_target

  source_real=$(readlink -f "$source")

  if [[ -L $target ]] && [[ $(readlink -f "$target") == $source_real ]]; then
    printf 'Déjà lié : %s\n' "$target"
    return
  fi

  if [[ -e $target || -L $target ]]; then
    backup_target="$BACKUP_ROOT/${target#"$HOME"/}"
    mkdir -p "$(dirname "$backup_target")"
    mv "$target" "$backup_target"
    printf 'Sauvegardé : %s -> %s\n' "$target" "$backup_target"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  printf 'Lié : %s -> %s\n' "$target" "$source"
}

config_directories=(
  alacritty
  hypr
  mako
  swaybg
  swayosd
  fuzzel
  waybar
  wireplumber
)

config_files=(
  environment.d/kolossus.conf
  xdg-terminals.list
)

for directory in "${config_directories[@]}"; do
  backup_and_link "$DOTFILES_DIR/.config/$directory" "$CONFIG_HOME/$directory"
done

for file in "${config_files[@]}"; do
  backup_and_link "$DOTFILES_DIR/.config/$file" "$CONFIG_HOME/$file"
done

for script in "$KOLLOSSUS_DIR"/bin/*; do
  backup_and_link "$script" "$HOME/.local/bin/$(basename "$script")"
done

if command -v xdg-mime >/dev/null; then
  XDG_CONFIG_HOME="$CONFIG_HOME" xdg-mime default firefox.desktop x-scheme-handler/http
  XDG_CONFIG_HOME="$CONFIG_HOME" xdg-mime default firefox.desktop x-scheme-handler/https
  XDG_CONFIG_HOME="$CONFIG_HOME" xdg-mime default firefox.desktop text/html
  XDG_CONFIG_HOME="$CONFIG_HOME" xdg-mime default thunar.desktop inode/directory
fi

printf '\nKolossus est déployé. Ferme puis rouvre la session Hyprland.\n'
printf 'Sauvegardes éventuelles : %s\n' "$BACKUP_ROOT"

