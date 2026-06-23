#!/bin/bash

set -eEuo pipefail

KOLLOSSUS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SYSTEM_DIR="$KOLLOSSUS_DIR/system"
BACKGROUND_SOURCE="$KOLLOSSUS_DIR/dotfiles/.config/swaybg/retro-82.jpg"
BACKUP_ROOT="/var/lib/kolossus/backups/$(date +%Y%m%d-%H%M%S)"
TEMP_DIR=$(mktemp -d)
KERNEL_OPTIONS_CONFIGURED=0
BOOTLOADER_REBUILD=mkinitcpio

cleanup() {
  rm -rf -- "$TEMP_DIR"
}

trap cleanup EXIT

if ((EUID == 0)); then
  printf 'Lance ce script avec ton utilisateur normal, pas avec sudo.\n' >&2
  exit 1
fi

for command in sudo plymouth-set-default-theme mkinitcpio; do
  if ! command -v "$command" >/dev/null; then
    printf 'Commande requise manquante : %s\n' "$command" >&2
    exit 1
  fi
done

sudo -v

backup_system_path() {
  local target=$1
  local backup_target="$BACKUP_ROOT/${target#/}"

  if ! sudo test -e "$target" && ! sudo test -L "$target"; then
    return
  fi

  sudo mkdir -p "$(dirname "$backup_target")"
  sudo cp -a -- "$target" "$backup_target"
  printf 'Sauvegardé : %s -> %s\n' "$target" "$backup_target"
}

install_system_file() {
  local source=$1
  local target=$2
  local mode=${3:-644}

  if sudo test -f "$target" && sudo cmp -s -- "$source" "$target"; then
    printf 'Déjà installé : %s\n' "$target"
    return
  fi

  backup_system_path "$target"
  sudo install -Dm"$mode" -- "$source" "$target"
  printf 'Installé : %s\n' "$target"
}

add_boot_options() {
  local value=$1
  local option

  for option in quiet splash; do
    if [[ " $value " != *" $option "* ]]; then
      value+=" $option"
    fi
  done

  printf '%s' "${value# }"
}

configure_kernel_cmdline() {
  local file=/etc/kernel/cmdline
  local current

  current=$(sudo cat "$file")
  add_boot_options "$current" >"$TEMP_DIR/kernel-cmdline"
  printf '\n' >>"$TEMP_DIR/kernel-cmdline"
  install_system_file "$TEMP_DIR/kernel-cmdline" "$file"
  KERNEL_OPTIONS_CONFIGURED=1
}

configure_grub() {
  local file=/etc/default/grub
  local key=GRUB_CMDLINE_LINUX_DEFAULT
  local line value
  local found=0

  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == "$key="* ]]; then
      value=${line#*=}
      if [[ $value == \"*\" ]]; then
        value=${value#\"}
        value=${value%\"}
      elif [[ $value == \'*\' ]]; then
        value=${value#\'}
        value=${value%\'}
      fi
      value=$(add_boot_options "$value")
      printf '%s="%s"\n' "$key" "$value" >>"$TEMP_DIR/grub"
      found=1
    else
      printf '%s\n' "$line" >>"$TEMP_DIR/grub"
    fi
  done < <(sudo cat "$file")

  if (( !found )); then
    printf '%s="quiet splash"\n' "$key" >>"$TEMP_DIR/grub"
  fi

  install_system_file "$TEMP_DIR/grub" "$file"
  KERNEL_OPTIONS_CONFIGURED=1
  BOOTLOADER_REBUILD=grub
}

configure_loader_entry() {
  local file=$1
  local output
  output=$(mktemp "$TEMP_DIR/loader.XXXXXX")
  local line options
  local has_linux=0
  local has_options=0

  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == linux\ * || $line == efi\ * ]]; then
      has_linux=1
    fi

    if [[ $line == options\ * ]]; then
      options=${line#options }
      printf 'options %s\n' "$(add_boot_options "$options")" >>"$output"
      has_options=1
    else
      printf '%s\n' "$line" >>"$output"
    fi
  done < <(sudo cat "$file")

  if ((has_linux && has_options)); then
    install_system_file "$output" "$file"
    KERNEL_OPTIONS_CONFIGURED=1
  fi
}

configure_boot_options() {
  local entry

  if command -v limine-mkinitcpio >/dev/null && sudo test -f /etc/default/limine; then
    install_system_file \
      "$SYSTEM_DIR/limine/20-kolossus-plymouth.conf" \
      /etc/limine-entry-tool.d/20-kolossus-plymouth.conf
    KERNEL_OPTIONS_CONFIGURED=1
    BOOTLOADER_REBUILD=limine
    return
  fi

  if sudo test -f /etc/default/grub && command -v grub-mkconfig >/dev/null; then
    configure_grub
    return
  fi

  if sudo test -f /etc/kernel/cmdline; then
    configure_kernel_cmdline
    return
  fi

  while IFS= read -r entry; do
    configure_loader_entry "$entry"
  done < <(sudo find /boot/loader/entries /efi/loader/entries \
    -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null || true)

  if (( !KERNEL_OPTIONS_CONFIGURED )) && grep -qw splash /proc/cmdline; then
    KERNEL_OPTIONS_CONFIGURED=1
  fi
}

printf 'Génération des assets Plymouth...\n'
bash "$SYSTEM_DIR/plymouth/kolossus/render-assets.sh" "$TEMP_DIR/plymouth"

for source in \
  "$SYSTEM_DIR/plymouth/kolossus/kolossus.plymouth" \
  "$SYSTEM_DIR/plymouth/kolossus/kolossus.script" \
  "$TEMP_DIR/plymouth"/*.png; do
  install_system_file \
    "$source" \
    "/usr/share/plymouth/themes/kolossus/$(basename "$source")"
done

if [[ $(plymouth-set-default-theme 2>/dev/null || true) != kolossus ]]; then
  backup_system_path /etc/plymouth/plymouthd.conf
  sudo plymouth-set-default-theme kolossus
fi

if sudo grep -RqsE '^[[:space:]]*ALL_config=' /etc/mkinitcpio.d; then
  printf 'Un preset mkinitcpio utilise ALL_config et ignore les drop-ins.\n' >&2
  printf 'Commente ALL_config dans /etc/mkinitcpio.d/*.preset puis relance ce script.\n' >&2
  exit 1
fi

install_system_file \
  "$SYSTEM_DIR/mkinitcpio/90-kolossus-plymouth.conf" \
  /etc/mkinitcpio.conf.d/90-kolossus-plymouth.conf

printf '\nInstallation du thème SDDM...\n'
for source in "$SYSTEM_DIR/sddm/kolossus"/*; do
  install_system_file \
    "$source" \
    "/usr/share/sddm/themes/kolossus/$(basename "$source")"
done
install_system_file \
  "$BACKGROUND_SOURCE" \
  /usr/share/sddm/themes/kolossus/background.jpg
install_system_file \
  "$SYSTEM_DIR/sddm/20-kolossus-theme.conf" \
  /etc/sddm.conf.d/zz-kolossus-theme.conf

printf '\nConfiguration du splash dans le chargeur de démarrage...\n'
configure_boot_options

if (( !KERNEL_OPTIONS_CONFIGURED )); then
  printf 'Avertissement : chargeur de démarrage non reconnu.\n' >&2
  printf 'Ajoute manuellement « quiet splash » aux paramètres du noyau.\n' >&2
fi

printf '\nRégénération des images de démarrage...\n'
case $BOOTLOADER_REBUILD in
  limine)
    sudo limine-mkinitcpio
    ;;
  grub)
    sudo mkinitcpio -P
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ;;
  *)
    sudo mkinitcpio -P
    ;;
esac

printf '\nThèmes système Kolossus installés.\n'
printf 'Sauvegardes éventuelles : %s\n' "$BACKUP_ROOT"
printf 'Redémarre la machine pour vérifier Plymouth ; SDDM sera visible à la prochaine déconnexion.\n'
