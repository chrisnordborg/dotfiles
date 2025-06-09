#!/usr/bin/env bash

folder="$HOME/OneDrive/Obsidian/Alpha/_New Notes/"
menu="tofi -c ~/.config/tofi/configA"

newnote() {
  name="$(tofi -c ~/.config/tofi/configA --prompt 'New note: ')"
  [ -z "$name" ] && name="$(date +%F_%T | tr ':' '-')"
  setsid -f "$TERMINAL" -e nvim "$folder$name.md" >/dev/null 2>&1
}

selected() {
  choice=$(echo -e "New\n$(ls -t1 "$folder")" | tofi -c ~/.config/tofi/configA --prompt "Choose note or create new:")
  case "$choice" in
    New) newnote ;;
    *.md) setsid -f "$TERMINAL" -e nvim "$folder$choice" >/dev/null 2>&1 ;;
    *) exit ;;
  esac
}

selected
