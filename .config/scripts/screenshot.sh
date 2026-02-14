#!/bin/bash
set -euo pipefail

DIR="$HOME/pictures/screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date '+%Y-%m-%d_%H-%M-%S').png"

# Defaults to area if no argument is given.
MODE="${1:-area}"

case "$MODE" in
  area)
    grim -l 0 -g "$(slurp)" - \
      | tee "$FILE" \
      | wl-copy
    ;;
  full)
    grim -l 0 - \
      | tee "$FILE" \
      | wl-copy
    ;;
  *)
    echo "Usage: $0 [area|full]"
    exit 1
    ;;
esac
