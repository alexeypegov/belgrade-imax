#!/usr/bin/env bash
# Generates home-screen icons: "bg|imax" in white, the bar is a vertical Serbian flag.
# Requires ImageMagick 7 (macOS system font).
set -euo pipefail

FONT="/System/Library/Fonts/Supplemental/DIN Alternate Bold.ttf"
RED="#c6363c"; BLUE="#3a6fc4"; WHITE="#f2f2f2"; BG="#181818"
P=400          # render pointsize
OUT=docs
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

label() { magick -background none -font "$FONT" -pointsize $P -fill "$WHITE" label:"$1" "$2"; }

# Measure the "|" glyph so the flag bar matches its height and baseline.
H=$(magick -background none -font "$FONT" -pointsize $P label:"|" -format "%h" info:)
read -r BW BH _ BY <<<"$(magick -background none -font "$FONT" -pointsize $P label:"|" -format "%@" info: | tr 'x+' '  ')"
W=$((BW * 5 / 2)); SP=55; SEG=$((BH / 3))

magick -size $((W + 2 * SP))x"$H" xc:none \
  -fill "$RED"   -draw "rectangle $SP,$BY $((SP + W - 1)),$((BY + SEG - 1))" \
  -fill "$BLUE"  -draw "rectangle $SP,$((BY + SEG)) $((SP + W - 1)),$((BY + 2 * SEG - 1))" \
  -fill "$WHITE" -draw "rectangle $SP,$((BY + 2 * SEG)) $((SP + W - 1)),$((BY + BH - 1))" \
  "$TMP/bar.png"

label bg "$TMP/bg.png"
label imax "$TMP/imax.png"

# Text block ~74% of width keeps it inside Android's maskable safe circle.
magick -background none "$TMP/bg.png" "$TMP/bar.png" "$TMP/imax.png" +append -trim +repage -resize 760x "$TMP/text.png"
magick -size 1024x1024 xc:"$BG" "$TMP/text.png" -gravity center -composite "$TMP/icon.png"

magick "$TMP/icon.png" -resize 180x180 -alpha off -depth 8 "$OUT/apple-touch-icon.png"
for s in 192 512; do
  magick "$TMP/icon.png" -resize ${s}x${s} -alpha off -depth 8 "$OUT/icon-$s.png"
done
