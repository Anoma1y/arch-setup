#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

maim -s | swappy -f - -o "$FILE"

if [[ -s "$FILE" ]]; then
    xclip -selection clipboard -t image/png -i "$FILE"
    notify-send "Screenshot saved" "$FILE" -i "$FILE"
else
    notify-send "Screenshot failed" "File was not written"
fi
