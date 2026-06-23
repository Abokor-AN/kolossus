#!/bin/bash

required_commands=(
  Hyprland
  hypridle
  hyprlock
  waybar
  walker
  elephant
  alacritty
  firefox
  thunar
  zeditor
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

if command -v grimblast >/dev/null || command -v hyprshot >/dev/null; then
  printf 'ok       capture d’écran\n'
else
  printf 'manquant grimblast ou hyprshot\n'
  ((missing++))
fi


if ((missing > 0)); then
  printf '\n%d dépendance(s) requise(s) manquante(s).\n' "$missing" >&2
  exit 1
fi

printf '\nToutes les dépendances requises sont disponibles.\n'

