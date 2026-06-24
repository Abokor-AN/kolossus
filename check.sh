#!/bin/bash

required_commands=(
  Hyprland
  hypridle
  hyprlock
  waybar
  fuzzel
  cliphist
  grim
  rofimoji
  slurp
  wl-copy
  alacritty
  firefox
  thunar
  zeditor
  plymouth-set-default-theme
  sddm-greeter-qt6
  mako
  swaybg
  swayosd-server
  swayosd-client
  brightnessctl
  playerctl
  wpctl
  wiremix
  impala
  bluetui
  btop
  jq
  hyprpicker
)

missing=0

for command in "${required_commands[@]}"; do
  if command -v "$command" >/dev/null; then
    printf 'ok       %s\n' "$command"
  else
    printf 'manquant %s\n' "$command"
    ((missing++))
  fi
done

if ((missing > 0)); then
  printf '\n%d dépendance(s) requise(s) manquante(s).\n' "$missing" >&2
  exit 1
fi

printf '\nToutes les dépendances requises sont disponibles.\n'

