#!/bin/bash

set -euo pipefail

OUTPUT_DIR=${1:?Usage: render-assets.sh OUTPUT_DIR}

if command -v magick >/dev/null; then
  image_tool=(magick)
elif command -v convert >/dev/null; then
  image_tool=(convert)
else
  printf 'ImageMagick est requis pour générer les assets Plymouth.\n' >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Palette Retro-82. C’est le point principal à modifier pour recolorer Plymouth.
surface='#00172e'
foreground='#f6dcac'
accent='#faa968'
font='/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf'

if [[ ! -f $font ]]; then
  font='DejaVu-Sans-Mono'
fi

"${image_tool[@]}" -size 176x176 xc:none \
  -fill "$surface" -stroke "$accent" -strokewidth 7 \
  -draw 'rectangle 7,7 169,169' \
  -fill none -stroke "$foreground" -strokewidth 12 \
  -draw 'line 57,43 57,133 line 57,88 119,43 line 57,88 119,133' \
  "$OUTPUT_DIR/logo.png"

"${image_tool[@]}" -size 650x88 "xc:$surface" \
  -alpha set -channel A -evaluate set 88% +channel \
  -fill none -stroke "$foreground" -strokewidth 4 \
  -draw 'rectangle 2,2 647,85' \
  "$OUTPUT_DIR/entry.png"

"${image_tool[@]}" -size 56x68 xc:none \
  -fill none -stroke "$foreground" -strokewidth 5 \
  -draw 'roundrectangle 5,28 51,63 3,3 arc 13,4 43,42 180,180' \
  "$OUTPUT_DIR/lock.png"

"${image_tool[@]}" -size 10x10 "xc:$accent" "$OUTPUT_DIR/bullet.png"

"${image_tool[@]}" -size 650x10 "xc:$surface" \
  -fill none -stroke "$foreground" -strokewidth 2 \
  -draw 'rectangle 0,0 649,9' \
  "$OUTPUT_DIR/progress-box.png"

"${image_tool[@]}" -size 640x6 "xc:$accent" "$OUTPUT_DIR/progress-bar.png"

"${image_tool[@]}" -background none -fill "$foreground" -font "$font" \
  -pointsize 21 -gravity center label:'INITIALISATION DU SYSTÈME' \
  "$OUTPUT_DIR/boot-label.png"

"${image_tool[@]}" -background none -fill "$foreground" -font "$font" \
  -pointsize 21 -gravity center label:'DISQUE CHIFFRÉ · MOT DE PASSE' \
  "$OUTPUT_DIR/password-label.png"

for asset in "$OUTPUT_DIR"/*.png; do
  "${image_tool[@]}" "$asset" -depth 8 "$asset"
done

printf 'Assets Plymouth générés dans %s\n' "$OUTPUT_DIR"
