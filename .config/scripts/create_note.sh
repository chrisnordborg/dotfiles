#!/bin/sh

folder="$HOME/OneDrive/Obsidian/Alpha/_NewNotes/"
menu="tofi -c $HOME/.config/tofi/configA"
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-')
log() {
  echo "[$(date '+%F %T')] $*" >> "$logfile"
}

newnote() {
  name=$( $menu --height 80 --width 500 --require-match=false --prompt 'New note: ' <<< "" 2>/dev/null)
  status=$?

  if [ -z "$name" ]; then
    name="$timestamp"
  fi

  filepath="$folder$name.md"
  "$terminal" nvim "$filepath" >/dev/null 2>&1
}

selected() {
  note_list=$(ls -t1 "$folder" 2>/dev/null)
  choice=$(echo -e "New\n$note_list" | $menu --prompt "Choose note or create new: ")
  status=$?

  case "$choice" in
    New) newnote ;;
    *.md) 
         "$terminal" nvim "$folder$choice" >/dev/null 2>&1 
         ;;
    *)
         ;;
  esac
}

selected
