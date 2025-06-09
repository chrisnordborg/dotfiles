#!/bin/sh

folder="$HOME/OneDrive/Obsidian/Alpha/_NewNotes/"
logfile="$HOME/.cache/note_launcher.log"
menu="tofi -c ~/.config/tofi/configA"
timeout_duration=5  # seconds
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-')
log() {
  echo "[$(date '+%F %T')] $*" >> "$logfile"
}

newnote() {
  log "Prompting for new note name..."
  #name="$(timeout $timeout_duration tofi -c ~/.config/tofi/configA --prompt 'New note: ' 2>>"$logfile")"
  name=$(echo "$timestamp" | rofi -show drun -theme ~/.config/rofi/config.rasi "New note")
  #name=$(echo "$timestamp" | rofi -dmenu -p "New note")
  status=$?

  if [ $status -eq 124 ]; then
    log "tofi prompt for new note timed out."
    return
  elif [ $status -ne 0 ]; then
    log "tofi prompt canceled or failed (status $status)."
    return
  fi

  if [ -z "$name" ]; then
    name="$timestamp"
    log "No name entered, defaulting to timestamp: $name"
  else
    log "User entered note name: $name"
  fi

  filepath="$folder$name.md"
  log "Creating note: $filepath"

  "$terminal" nvim "$filepath" >/dev/null 2>&1
}

selected() {
  log "Listing notes in $folder"
  note_list=$(ls -t1 "$folder" 2>/dev/null)
  choice=$(echo -e "New\n$note_list" | timeout $timeout_duration tofi -c ~/.config/tofi/configA --prompt "Choose note or create new: ")
  status=$?

  if [ $status -eq 124 ]; then
    log "tofi selection prompt timed out."
    return
  elif [ $status -ne 0 ]; then
    log "tofi selection prompt canceled or failed (status $status)."
    return
  fi

  log "User selected: $choice"
  case "$choice" in
    New) newnote ;;
    *.md) 
      log "Opening existing note: $folder$choice"
      #setsid -f "$TERMINAL" -e nvim "$folder$choice" >/dev/null 2>&1
     "$terminal" nvim "$folder$choice" >/dev/null 2>&1 
      ;;
    *)
      log "Invalid selection or empty input."
      ;;
  esac
}

selected
