#!/bin/sh

mainFolder="$HOME/OneDrive/Obsidian/Alpha"
newNoteFolder="$mainFolder/_NewNotes/"
menu="tofi -c $HOME/.config/tofi/configA"
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-') # e.g. 2025-06-21_21-24-00

# Create a new note
newnote() {
  name=$($menu --height 40 --width 500 --require-match=false --prompt 'New note: ' <<< "" 2>/dev/null)
  [ -z "$name" ] && name="$timestamp"
  filepath="$newNoteFolder$name.md"
  "$terminal" nvim "$filepath" >/dev/null 2>&1
}

selected() {
  # Map of filename -> full path (may include duplicates!)
  # find ... -printf "%T@ %p\n": prints epoch_time full/path/to/file.
  # sort -nr: sorts numerically and reverses, so newest is first.
  # cut -d' ' -f2-: strips the timestamp, keeping only the path.
  mapfile -t all_files < <(
  find "$mainFolder" -type f -name "*.md" -printf "%T@ %p\n" |
  sort -k1,1nr |
  cut -d' ' -f2-
  )
  filenames=$(printf "%s\n" "${all_files[@]##*/}")

  choice=$(echo -e "[New Note]\n$filenames" | $menu --height 600 --width 900 --num-results 0 --prompt "Choose note: ")
  [ $? -ne 0 ] && exit 1

  case "$choice" in
    "[New Note]")
      newnote
      ;;
    *.md)
      # Safely pick the first matching file (if duplicates exist)
      for path in "${all_files[@]}"; do
        [ "${path##*/}" = "$choice" ] && {
          "$terminal" nvim "$path" >/dev/null 2>&1
          return
        }
      done
      ;;
    *)
      ;;
  esac
}

selected
